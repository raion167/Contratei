import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'prestador_detalhes_page.dart';
import 'config/api.dart';

class ListaPrestadoresPage extends StatefulWidget {
  final String ocupacao;
  const ListaPrestadoresPage({super.key, required this.ocupacao});

  @override
  State<ListaPrestadoresPage> createState() => _ListaPrestadoresPageState();
}

class _ListaPrestadoresPageState extends State<ListaPrestadoresPage> {
  List<Map<String, dynamic>> prestadores = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    fetchPrestadores();
  }

  Future<void> fetchPrestadores() async {
    try {
      final url = Uri.parse(
        "${ApiConfig.baseUrl}/getPrestadores.php=${Uri.encodeComponent(widget.ocupacao)}",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"]) {
          setState(() {
            prestadores = List<Map<String, dynamic>>.from(data["prestadores"]);
          });
        } else {
          _showMsg(data["message"] ?? "Erro ao carregar prestadores");
        }
      } else {
        _showMsg("Erro HTTP: ${response.statusCode}");
      }
    } catch (e) {
      _showMsg("Erro: $e");
    } finally {
      setState(() => carregando = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(widget.ocupacao),
        backgroundColor: const Color(0xFFFF4E00),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : prestadores.isEmpty
          ? const Center(child: Text("Nenhum prestador encontrado"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prestadores.length,
              itemBuilder: (context, index) {
                final p = prestadores[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrestadorDetalhesPage(prestador: p),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== AVATAR =====
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.orange.shade100,
                          child: const Icon(
                            Icons.person,
                            size: 36,
                            color: Colors.orange,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // ===== DADOS =====
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p["nome"] ?? "",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p["ocupacao"] ?? "",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    p["avaliacao"]?.toString() ?? "4.8",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Disponível",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ===== SETA =====
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

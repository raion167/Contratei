import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'cadastrar_servico_page.dart';
import 'config/api.dart';

class MeusServicosPage extends StatefulWidget {
  final Usuario usuario;
  const MeusServicosPage({super.key, required this.usuario});

  @override
  State<MeusServicosPage> createState() => _MeusServicosPageState();
}

class _MeusServicosPageState extends State<MeusServicosPage> {
  List servicos = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    buscarServicos();
  }

  Future<void> buscarServicos() async {
    try {
      final url = Uri.parse(
        "${ApiConfig.baseUrl}/getPrestadores.php?prestador_id=${widget.usuario.id}",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"]) {
          setState(() {
            servicos = data["servicos"];
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar serviços: $e");
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  // ================= EXCLUIR SERVIÇO =================
  Future<void> excluirServico(int idServico) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Excluir serviço"),
        content: const Text("Deseja realmente excluir este serviço?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/excluir_servico.php");

      await http.post(url, body: {"id": idServico});

      buscarServicos();
    } catch (e) {
      debugPrint("Erro ao excluir serviço: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4E00),
        foregroundColor: Colors.white,
      ),

      // ================= FAB (+) =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF4E00),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CadastrarServicoPage(usuario: widget.usuario),
            ),
          );
          buscarServicos();
        },
      ),

      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : servicos.isEmpty
          ? const Center(child: Text("Nenhum serviço cadastrado"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: servicos.length,
              itemBuilder: (context, index) {
                final s = servicos[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ÍCONE
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.build, color: Colors.orange),
                        ),

                        const SizedBox(width: 12),

                        // INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s["nome_servico"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                s["descricao"] ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "R\$ ${s["preco"]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // AÇÕES
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.blue,
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CadastrarServicoPage(
                                      usuario: widget.usuario,
                                    ),
                                  ),
                                );
                                buscarServicos();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () =>
                                  excluirServico(int.parse(s["id"].toString())),
                            ),
                          ],
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

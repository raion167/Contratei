import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'prestador_detalhes_page.dart'; // 🔹 certifique-se do caminho correto

class ListaPrestadoresPage extends StatefulWidget {
  final String ocupacao;
  const ListaPrestadoresPage({super.key, required this.ocupacao});

  @override
  State<ListaPrestadoresPage> createState() => _ListaPrestadoresPageState();
}

class _ListaPrestadoresPageState extends State<ListaPrestadoresPage> {
  List prestadores = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    fetchPrestadores();
  }

  Future<void> fetchPrestadores() async {
    try {
      var url = Uri.parse(
        "http://localhost:8080/app/getPrestadores.php?ocupacao=${Uri.encodeComponent(widget.ocupacao)}",
      );
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["success"]) {
          setState(() {
            prestadores = List<Map<String, dynamic>>.from(data["prestadores"]);
          });
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(data["message"])));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao buscar prestadores: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      print("Erro ao buscar prestadores: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao buscar prestadores: $e")));
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  void abrirContato(String telefone, String email) async {
    final Uri telUri = Uri(scheme: 'tel', path: telefone);
    final Uri emailUri = Uri(scheme: 'mailto', path: email);

    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível abrir contato")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Prestadores: ${widget.ocupacao}")),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : prestadores.isEmpty
          ? const Center(child: Text("Nenhum prestador encontrado"))
          : ListView.builder(
              itemCount: prestadores.length,
              itemBuilder: (context, index) {
                final p = prestadores[index];
                final fotoUrl = p["foto"] != ""
                    ? "http://localhost:8080/app/uploads/${p["foto"]}"
                    : "https://via.placeholder.com/150";

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrestadorDetalhesPage(
                          prestador: Map<String, dynamic>.from(p),
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(fotoUrl),
                        radius: 30,
                      ),
                      title: Text(p["nome"]),
                      subtitle: Text(p["ocupacao"]),
                      trailing: IconButton(
                        icon: const Icon(Icons.info),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(p["nome"]),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Telefone: ${p["telefone"]}"),
                                  Text("Email: ${p["email"]}"),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Fechar"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    abrirContato(p["telefone"], p["email"]);
                                  },
                                  child: const Text("Entrar em contato"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

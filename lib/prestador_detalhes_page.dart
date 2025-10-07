import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PrestadorDetalhesPage extends StatefulWidget {
  final Map prestador;
  const PrestadorDetalhesPage({super.key, required this.prestador});

  @override
  State<PrestadorDetalhesPage> createState() => _PrestadorDetalhesPageState();
}

class _PrestadorDetalhesPageState extends State<PrestadorDetalhesPage> {
  List servicos = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    fetchServicos();
  }

  Future<void> fetchServicos() async {
    try {
      var url = Uri.parse(
        "http://localhost:8080/app/listar_servicos.php?prestador_id=${widget.prestador['id']}",
      );

      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["success"] == true) {
          setState(() {
            servicos = data["servicos"];
          });
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(data["message"])));
        }
      }
    } catch (e) {
      print("Erro ao buscar serviços: $e");
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  void solicitarOrcamento(Map servico) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Solicitar Orçamento"),
        content: Text(
          "Deseja solicitar um orçamento para:\n${servico['nome_servico']}?\nPreço: R\$${servico['preco']}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              // Aqui você pode enviar a solicitação para o banco via PHP
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Orçamento solicitado!")),
              );
            },
            child: const Text("Solicitar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prestador = widget.prestador;
    final fotoUrl = prestador["foto"] != ""
        ? "http://localhost:8080/app/uploads/${prestador["foto"]}"
        : "https://via.placeholder.com/150";

    return Scaffold(
      appBar: AppBar(title: Text(prestador["nome"])),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(fotoUrl),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Email: ${prestador['email']}"),
                  Text("Telefone: ${prestador['telefone']}"),
                  const SizedBox(height: 20),
                  const Text(
                    "Serviços oferecidos:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...servicos.map(
                    (s) => Card(
                      child: ListTile(
                        title: Text(s["nome_servico"]),
                        subtitle: Text(
                          "Preço: R\$${s['preco'] ?? '0.00'}\n${s["descricao"] ?? ''}",
                        ),
                        trailing: ElevatedButton(
                          child: const Text("Solicitar Orçamento"),
                          onPressed: () => solicitarOrcamento(s),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

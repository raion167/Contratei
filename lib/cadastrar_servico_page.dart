import 'package:contratei/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CadastrarServicoPage extends StatefulWidget {
  final Usuario usuario;

  const CadastrarServicoPage({super.key, required this.usuario});

  @override
  State<CadastrarServicoPage> createState() => _CadastrarServicoPageState();
}

class _CadastrarServicoPageState extends State<CadastrarServicoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController precoController = TextEditingController();

  Future<void> cadastrarServico() async {
    if (!_formKey.currentState!.validate()) return;

    var url = Uri.parse("http://localhost:8080/app/cadastrar_servico.php");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "prestador_id": widget.usuario.id,
        "nome_servico": nomeController.text,
        "descricao": descricaoController.text,
        "preco": double.parse(precoController.text),
      }),
    );

    var data = jsonDecode(response.body);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data["message"])));
    if (data["success"]) {
      nomeController.clear();
      descricaoController.clear();
      precoController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar Serviço")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: "Nome do Serviço"),
                validator: (v) =>
                    v!.isEmpty ? "Informe o nome do serviço" : null,
              ),
              TextFormField(
                controller: descricaoController,
                decoration: const InputDecoration(labelText: "Descrição"),
                maxLines: 2,
              ),
              TextFormField(
                controller: precoController,
                decoration: const InputDecoration(labelText: "Valor (R\$)"),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => v!.isEmpty ? "Informe o valor" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: cadastrarServico,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 12,
                  ),
                ),
                child: const Text("Cadastrar", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

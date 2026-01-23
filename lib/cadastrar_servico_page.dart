import 'package:contratei/main.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config/api.dart';

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

    final url = Uri.parse("${ApiConfig.baseUrl}/cadastrar_servico.php");

    final response = await http.post(
      url,
      body: {
        "prestador_id": widget.usuario.id,
        "nome_servico": nomeController.text,
        "descricao": descricaoController.text,
        "preco": double.parse(precoController.text),
      },
    );

    final data = jsonDecode(response.body);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data["message"])));

    if (data["success"]) {
      nomeController.clear();
      descricaoController.clear();
      precoController.clear();
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null
          ? Icon(icon, color: const Color(0xFFFF4E00))
          : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("Cadastrar Serviço"),
        backgroundColor: const Color(0xFFFF4E00),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informações do Serviço",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: nomeController,
                    decoration: _inputDecoration(
                      "Nome do serviço",
                      icon: Icons.build,
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Informe o nome do serviço" : null,
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: descricaoController,
                    maxLines: 3,
                    decoration: _inputDecoration(
                      "Descrição",
                      icon: Icons.description,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: precoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _inputDecoration(
                      "Valor (R\$)",
                      icon: Icons.attach_money,
                    ),
                    validator: (v) => v!.isEmpty ? "Informe o valor" : null,
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: cadastrarServico,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4E00),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        "Cadastrar Serviço",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

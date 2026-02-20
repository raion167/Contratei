import 'package:contratei/pix_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class CheckoutPage extends StatelessWidget {
  final Map prestador;
  final Map servico;
  final Map contratante;

  const CheckoutPage({
    super.key,
    required this.prestador,
    required this.servico,
    required this.contratante,
  });

  @override
  Widget build(BuildContext context) {
    final preco = servico["preco"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Finalizar Serviço"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resumo do Pedido",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _linha("Prestador", prestador["nome"]),
                    const SizedBox(height: 8),
                    _linha("Serviço", servico["nome_servico"]),
                    const Divider(height: 24),
                    _linha("Total", "R\$ $preco", destaque: true),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  // VALOR TOTAL DO SERVIÇO
                  final double valorTotal = (servico["preco"] as num)
                      .toDouble();

                  // TAXA DE RETENÇÃO DA PLATAFORMA (15%)
                  final double taxaRetencao = 0.15;

                  // VALOR A SER RETIDO
                  final double valorRetido = valorTotal * taxaRetencao;

                  // VALOR LIQUIDO QUE VAI PARA O PRESTADOR
                  final double valorParaPrestador = valorTotal - valorRetido;

                  // Monta os dados da ordem para salvar no Supabase
                  final Map<String, dynamic> ordem = {
                    "contratante_id": contratante["id"], // uuid do contratante
                    "prestador_id": prestador["id"], // uuid do prestador
                    "servico_id": servico["id"], // id do serviço
                    "valor_total": valorTotal,
                    "taxa_retencao": valorRetido,
                    "valor_liquido": valorParaPrestador,
                    "status": "pendente",
                  };

                  try {
                    await supabase.from("ordens_de_servico").insert(ordem);
                    print("Ordem de serviço criada com sucesso!");
                  } catch (e) {
                    print("Erro ao criar ordem de serviço: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Erro ao criar ordem de serviço."),
                      ),
                    );
                    return; // não prossegue para a PixPage se houver erro
                  }

                  // Chave PIX aleatória
                  const chavePix = "ea4b42bd-e123-4b76-b4a8-142b37804243";

                  // Redireciona para a PixPage mostrando apenas o valor total
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PixPage(chavePix: chavePix, valor: valorTotal),
                    ),
                  );
                },
                child: const Text(
                  "Confirmar Pedido",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linha(String titulo, String valor, {bool destaque = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo),
        Text(
          valor,
          style: TextStyle(
            fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
            fontSize: destaque ? 16 : 14,
          ),
        ),
      ],
    );
  }
}

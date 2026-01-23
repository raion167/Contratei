import 'package:flutter/material.dart';
import 'main.dart';

class FinanceiroPrestadorPage extends StatelessWidget {
  final Usuario usuario;
  const FinanceiroPrestadorPage({super.key, required this.usuario});

  // 🔹 Mock de dados (depois você liga na API)
  List<Map<String, dynamic>> get extrato => [
    {
      "descricao": "Serviço concluído - Instalação elétrica",
      "data": "10/01/2026",
      "valor": 250.00,
    },
    {
      "descricao": "Serviço concluído - Manutenção",
      "data": "05/01/2026",
      "valor": 180.00,
    },
    {"descricao": "Taxa plataforma", "data": "05/01/2026", "valor": -30.00},
  ];

  double get totalGanho =>
      extrato.fold(0, (soma, item) => soma + item["valor"]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4E00),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ================= HEADER COM CARDS =================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFF4E00),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                _cardResumo(
                  titulo: "Total ganho",
                  valor: "R\$ ${totalGanho.toStringAsFixed(2)}",
                ),
                const SizedBox(width: 12),
                _cardResumo(
                  titulo: "Mês atual",
                  valor: "R\$ ${totalGanho.toStringAsFixed(2)}",
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ================= EXTRATO =================
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: extrato.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = extrato[index];
                final bool positivo = item["valor"] >= 0;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: positivo
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      positivo ? Icons.arrow_downward : Icons.arrow_upward,
                      color: positivo ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    item["descricao"],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(item["data"]),
                  trailing: Text(
                    "R\$ ${item["valor"].toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: positivo ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= CARD DE RESUMO =================
  Widget _cardResumo({required String titulo, required String valor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF4E00),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinanceiroPrestadorPage extends StatefulWidget {
  final Usuario usuario;
  const FinanceiroPrestadorPage({super.key, required this.usuario});

  @override
  State<FinanceiroPrestadorPage> createState() =>
      _FinanceiroPrestadorPageState();
}

class _FinanceiroPrestadorPageState extends State<FinanceiroPrestadorPage> {
  List<Map<String, dynamic>> extrato = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    buscarFinanceiro();
  }

  Future<void> buscarFinanceiro() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('financeiro')
          .select()
          .eq('prestador_id', widget.usuario.id)
          .order('created_at', ascending: false);

      setState(() {
        extrato = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Erro ao buscar financeiro: $e");
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  double get totalGanho =>
      extrato.fold(0.0, (soma, item) => soma + (item["valor"] ?? 0));

  double get totalMesAtual {
    final now = DateTime.now();
    return extrato
        .where((item) {
          final data = DateTime.parse(item["created_at"]);
          return data.month == now.month && data.year == now.year;
        })
        .fold(0.0, (soma, item) => soma + (item["valor"] ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4E00),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ================= HEADER COM CARDS =================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4E00),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
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
                        valor: "R\$ ${totalMesAtual.toStringAsFixed(2)}",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ================= EXTRATO =================
                Expanded(
                  child: extrato.isEmpty
                      ? const Center(
                          child: Text("Nenhuma movimentação encontrada"),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: extrato.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = extrato[index];
                            final bool positivo = (item["valor"] ?? 0) >= 0;

                            final dataFormatada =
                                DateTime.parse(item["created_at"])
                                    .toString()
                                    .substring(0, 10)
                                    .split("-")
                                    .reversed
                                    .join("/");

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: positivo
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                child: Icon(
                                  positivo
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: positivo ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(
                                item["descricao"] ?? "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(dataFormatada),
                              trailing: Text(
                                "R\$ ${(item["valor"] ?? 0).toStringAsFixed(2)}",
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

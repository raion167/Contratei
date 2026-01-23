import 'package:flutter/material.dart';
import 'main.dart';

class OrdensServicoPage extends StatefulWidget {
  final Usuario usuario;
  const OrdensServicoPage({super.key, required this.usuario});

  @override
  State<OrdensServicoPage> createState() => _OrdensServicoPageState();
}

class _OrdensServicoPageState extends State<OrdensServicoPage> {
  int abaSelecionada = 0; // 0 = lista | 1 = calendario
  DateTime mesAtual = DateTime.now();
  DateTime? diaSelecionado;

  // ================= MOCK =================
  final List<Map<String, dynamic>> ordens = [
    {
      "servico": "Instalação Elétrica",
      "cliente": "João Silva",
      "data": DateTime.now(),
      "valor": 250.0,
      "status": "AGENDADO",
    },
    {
      "servico": "Manutenção Hidráulica",
      "cliente": "Maria Souza",
      "data": DateTime.now().subtract(const Duration(days: 1)),
      "valor": 180.0,
      "status": "CONCLUIDO",
    },
    {
      "servico": "Pintura Residencial",
      "cliente": "Carlos Lima",
      "data": DateTime.now().add(const Duration(days: 3)),
      "valor": 500.0,
      "status": "ABERTO",
    },
    {
      "servico": "Troca de Chuveiro",
      "cliente": "Ana Paula",
      "data": DateTime.now().add(const Duration(days: 7)),
      "valor": 120.0,
      "status": "AGENDADO",
    },
  ];

  // ================= CORES =================
  Color corStatus(String status) {
    switch (status) {
      case "ABERTO":
        return Colors.orange;
      case "AGENDADO":
        return Colors.blue;
      case "CONCLUIDO":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4E00),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(abaSelecionada == 0 ? Icons.calendar_month : Icons.list),
            onPressed: () {
              setState(() {
                abaSelecionada = abaSelecionada == 0 ? 1 : 0;
              });
            },
          ),
        ],
      ),
      body: abaSelecionada == 0 ? _listaView() : _calendarioView(),
    );
  }

  // ================= LISTA =================
  Widget _listaView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ordens.length,
      itemBuilder: (context, index) {
        final o = ordens[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: corStatus(o["status"]),
              child: const Icon(Icons.work, color: Colors.white),
            ),
            title: Text(o["servico"]),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Cliente: ${o["cliente"]}"),
                Text(
                  "Data: ${o["data"].day}/${o["data"].month}/${o["data"].year}",
                ),
                Text("Valor: R\$ ${o["valor"]}"),
              ],
            ),
            trailing: Chip(
              label: Text(o["status"]),
              backgroundColor: corStatus(o["status"]).withOpacity(0.2),
            ),
          ),
        );
      },
    );
  }

  // ================= CALENDÁRIO =================
  Widget _calendarioView() {
    final meses = [
      "Janeiro",
      "Fevereiro",
      "Março",
      "Abril",
      "Maio",
      "Junho",
      "Julho",
      "Agosto",
      "Setembro",
      "Outubro",
      "Novembro",
      "Dezembro",
    ];

    final diasSemana = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"];

    final primeiroDiaMes = DateTime(mesAtual.year, mesAtual.month, 1);
    final ultimoDiaMes = DateTime(mesAtual.year, mesAtual.month + 1, 0);

    // Ajuste para domingo = 0
    final int offset = primeiroDiaMes.weekday % 7;

    List<Widget> grid = [];

    // Cabeçalho dias da semana
    for (final d in diasSemana) {
      grid.add(
        Center(
          child: Text(
            d,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      );
    }

    // Espaços vazios antes do primeiro dia
    for (int i = 0; i < offset; i++) {
      grid.add(const SizedBox());
    }

    // Dias do mês
    for (int i = 1; i <= ultimoDiaMes.day; i++) {
      final data = DateTime(mesAtual.year, mesAtual.month, i);
      final ordensDia = ordens
          .where((o) => _mesmoDia(o["data"], data))
          .toList();

      Color? corMarcacao;
      if (ordensDia.isNotEmpty) {
        corMarcacao = corStatus(ordensDia.first["status"]);
      }

      grid.add(
        GestureDetector(
          onTap: ordensDia.isNotEmpty
              ? () {
                  setState(() {
                    diaSelecionado = data;
                  });
                }
              : null,
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: diaSelecionado == data
                  ? corMarcacao?.withOpacity(0.7)
                  : corMarcacao?.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                "$i",
                style: TextStyle(
                  color: corMarcacao != null ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 12),

        // ===== HEADER MÊS =====
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  mesAtual = DateTime(mesAtual.year, mesAtual.month - 1);
                  diaSelecionado = null;
                });
              },
            ),
            Text(
              "${meses[mesAtual.month - 1]} ${mesAtual.year}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  mesAtual = DateTime(mesAtual.year, mesAtual.month + 1);
                  diaSelecionado = null;
                });
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ===== GRID CALENDÁRIO =====
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            crossAxisCount: 7,
            children: grid,
          ),
        ),

        // ===== DETALHES DO DIA =====
        if (diaSelecionado != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ordens
                  .where((o) => _mesmoDia(o["data"], diaSelecionado!))
                  .map(
                    (o) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 6,
                            backgroundColor: corStatus(o["status"]),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text("${o["servico"]} - R\$ ${o["valor"]}"),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  bool _mesmoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

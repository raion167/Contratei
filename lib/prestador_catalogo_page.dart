// ${DateTime.now()}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config/api.dart';

class PrestadorCatalogoPage extends StatefulWidget {
  final Map<String, dynamic> prestador;

  const PrestadorCatalogoPage({super.key, required this.prestador});

  @override
  State<PrestadorCatalogoPage> createState() => _PrestadorCatalogoPageState();
}

class _PrestadorCatalogoPageState extends State<PrestadorCatalogoPage> {
  List servicos = [];
  bool loading = true;
  bool favorito = false;

  // MOCKS
  double avaliacaoMedia = 4.7;
  int totalAvaliacoes = 124;
  double distanciaKm = 2.4;

  @override
  void initState() {
    super.initState();
    fetchServicos();
  }

  Widget estrelas(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 18);
        } else if (index < rating) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 18);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 18);
        }
      }),
    );
  }

  Future<void> fetchServicos() async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/getServicosPrestador.php");
      var response = await http.post(
        url,
        body: {"prestador_id": widget.prestador["id"]},
      );

      var data = jsonDecode(response.body);
      if (data["success"]) {
        setState(() {
          servicos = data["servicos"];
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Erro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          // ================= HEADER REAL =================
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.orange,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  favorito ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () => setState(() => favorito = !favorito),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6A00), Color(0xFFFF8C42)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== TEXTO ESQUERDA =====
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.prestador["nome"],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.prestador["categoria"] ?? "Categoria",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              estrelas(avaliacaoMedia),
                              const SizedBox(width: 6),
                              Text(
                                avaliacaoMedia.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "•",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${distanciaKm.toStringAsFixed(1)} km",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$totalAvaliacoes avaliações",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ===== LOGO DIREITA =====
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.store,
                        size: 40,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================= SERVIÇOS =================
          loading
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.only(top: 12),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final s = servicos[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.build,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s["nome_servico"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s["descricao"],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "R\$ ${s["preco"]}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    }, childCount: servicos.length),
                  ),
                ),
        ],
      ),
    );
  }
}

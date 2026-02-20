import 'package:contratei/checkout_page.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final contratante = Supabase.instance.client.auth.currentUser;

class PrestadorDetalhesPage extends StatefulWidget {
  final Map prestador;
  const PrestadorDetalhesPage({super.key, required this.prestador});

  @override
  State<PrestadorDetalhesPage> createState() => _PrestadorDetalhesPageState();
}

class _PrestadorDetalhesPageState extends State<PrestadorDetalhesPage> {
  List servicos = [];
  bool carregando = true;
  bool favorito = false;

  @override
  void initState() {
    super.initState();
    fetchServicos();
  }

  Future<void> fetchServicos() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('servicos')
          .select()
          .eq('prestador_id', widget.prestador['id'])
          .order('created_at', ascending: false);

      setState(() {
        servicos = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Erro ao buscar serviços: $e");
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prestador = widget.prestador;
    final fotoUrl = prestador["foto"] != null && prestador["foto"] != ""
        ? "http://localhost:8080/app/uploads/${prestador["foto"]}"
        : null;

    final categoria =
        prestador["categoria_nome"] ??
        prestador["nome_categoria"] ??
        prestador["categoria"]?["nome"] ??
        "Categoria";

    return Scaffold(
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // ================= HEADER =================
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 56, 16, 20),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF6A00), Color(0xFFFF8C42)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prestador["nome"],
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      categoria,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        Icon(
                                          Icons.star_half,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          "4.8 • 1.2 km",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // FOTO
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.white,
                                child: fotoUrl != null
                                    ? ClipOval(
                                        child: Image.network(
                                          fotoUrl,
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.person,
                                                size: 40,
                                              ),
                                        ),
                                      )
                                    : const Icon(Icons.person, size: 40),
                              ),
                            ],
                          ),
                        ),

                        // BOTÃO VOLTAR
                        Positioned(
                          top: 8,
                          left: 8,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.orange,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.arrow_back, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),

                        // BOTÃO FAVORITAR
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                favorito
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  favorito = !favorito;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ================= TÍTULO =================
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text(
                      "Serviços oferecidos",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // ================= LISTA DE SERVIÇOS =================
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final s = servicos[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.build,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s["nome_servico"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    s["descricao"] ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "R\$ ${s["preco"]}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    // 🔵 BOTÃO ABRIR CHAT
                                    SizedBox(
                                      height: 32,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Colors.orange,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          final supabase =
                                              Supabase.instance.client;
                                          final currentUser =
                                              supabase.auth.currentUser!;

                                          final prestadorId = prestador["id"]
                                              .toString();

                                          // 🔎 Verificar se já existe conversa
                                          final conversaExistente = await supabase
                                              .from('conversas')
                                              .select()
                                              .or(
                                                'and(usuario1_id.eq.${currentUser.id},usuario2_id.eq.$prestadorId),'
                                                'and(usuario1_id.eq.$prestadorId,usuario2_id.eq.${currentUser.id})',
                                              )
                                              .maybeSingle();

                                          String conversaId;

                                          if (conversaExistente != null) {
                                            conversaId = conversaExistente["id"]
                                                .toString();
                                          } else {
                                            // 🆕 Criar nova conversa
                                            final novaConversa = await supabase
                                                .from('conversas')
                                                .insert({
                                                  "usuario1_id": currentUser.id,
                                                  "usuario2_id": prestadorId,
                                                })
                                                .select()
                                                .single();

                                            conversaId = novaConversa["id"]
                                                .toString();
                                          }

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ChatPage(
                                                conversaId: conversaId,
                                                usuarioDestinoId: prestadorId,
                                                nomeDestino: prestador["nome"],
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Abrir Chat",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // 🟠 BOTÃO SOLICITAR
                                    SizedBox(
                                      height: 32,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          // <- async adicionado
                                          final supabase =
                                              Supabase.instance.client;
                                          final currentUser =
                                              supabase.auth.currentUser;

                                          if (currentUser == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Usuário não logado.",
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          final contratanteMap = await supabase
                                              .from('usuarios')
                                              .select()
                                              .eq('id', currentUser.id)
                                              .maybeSingle(); // retorna Map<String, dynamic>?

                                          if (contratanteMap == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Erro ao obter dados do usuário.",
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => CheckoutPage(
                                                prestador: prestador,
                                                servico: s,
                                                contratante: contratanteMap,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Solicitar",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: servicos.length),
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_page.dart';

class ConversasPage extends StatefulWidget {
  final dynamic usuario;

  const ConversasPage({super.key, required this.usuario});

  @override
  State<ConversasPage> createState() => _ConversasPageState();
}

class _ConversasPageState extends State<ConversasPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> conversas = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    carregarConversas();
  }

  Future<void> carregarConversas() async {
    final userId = widget.usuario.id;

    final response = await supabase
        .from('conversas')
        .select('''
      id,
      cliente:cliente_id ( id, nome ),
      prestador:prestador_id ( id, nome ),
      mensagens (
        texto,
        created_at,
        lida,
        remetente_id
      )
    ''')
        .or('cliente_id.eq.$userId,prestador_id.eq.$userId')
        .order('created_at', ascending: false);

    setState(() {
      conversas = response;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversas"),
        backgroundColor: const Color(0xFFFF4E00),
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : conversas.isEmpty
          ? const Center(child: Text("Nenhuma conversa ainda"))
          : ListView.builder(
              itemCount: conversas.length,
              itemBuilder: (context, index) {
                final conversa = conversas[index];
                final mensagens = conversa['mensagens'] as List;
                final userId = widget.usuario.id;

                final cliente = conversa['cliente'];
                final prestador = conversa['prestador'];

                String nomeOutro;
                String outroId;

                String ultimaMensagem = "Sem mensagens";

                if (cliente['id'] == userId) {
                  nomeOutro = prestador['nome'];
                  outroId = prestador['id'];
                } else {
                  nomeOutro = cliente['nome'];
                  outroId = cliente['id'];
                }

                if (mensagens.isNotEmpty) {
                  ultimaMensagem = mensagens.last['texto'];
                }

                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFF4E00),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(nomeOutro),
                  subtitle: Text(ultimaMensagem),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          usuarioDestinoId: outroId,
                          conversaId: conversa['id'],
                          nomeDestino: nomeOutro,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

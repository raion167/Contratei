import 'package:contratei/meus_servicos_page.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'cadastrar_servico_page.dart';
// importe sua tela financeira
import 'financeiro_prestador_page.dart';
import 'ordens_servico_page.dart';

class PerfilMenuScreen extends StatelessWidget {
  final Usuario usuario;
  const PerfilMenuScreen({super.key, required this.usuario});

  Widget _botaoQuadrado({
    required IconData icon,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: const Color(0xFFFF4E00)),
            const SizedBox(height: 14),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF4E00),
      appBar: AppBar(
        title: const Text("Meu Perfil"),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF4E00),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            // ===== MEUS DADOS =====
            _botaoQuadrado(
              icon: Icons.person,
              titulo: "Meus Dados",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MeusDadosScreen(usuario: usuario),
                  ),
                );
              },
            ),

            // ===== PAGAMENTOS (CLIENTE) OU FINANCEIRO (PRESTADOR) =====
            if (usuario.tipoUsuario == "Prestador")
              _botaoQuadrado(
                icon: Icons.account_balance_wallet,
                titulo: "Financeiro",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FinanceiroPrestadorPage(usuario: usuario),
                    ),
                  );
                },
              )
            else
              _botaoQuadrado(
                icon: Icons.credit_card,
                titulo: "Pagamentos",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormasPagamentoScreen(usuario: usuario),
                    ),
                  );
                },
              ),
            if (usuario.tipoUsuario == "Prestador")
              _botaoQuadrado(
                icon: Icons.calendar_month_outlined,
                titulo: "Ordens de Serviço",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrdensServicoPage(usuario: usuario),
                    ),
                  );
                },
              ),
            // ===== SERVIÇOS (SÓ PRESTADOR) =====
            if (usuario.tipoUsuario == "Prestador")
              _botaoQuadrado(
                icon: Icons.build,
                titulo: "Meus Serviços",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MeusServicosPage(usuario: usuario),
                    ),
                  );
                },
              ),

            // ===== HISTÓRICO =====
            /*_botaoQuadrado(
              icon: Icons.history,
              titulo: "Histórico",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Histórico em desenvolvimento")),
                );
              },
            ),*/

            // ===== SAIR =====
            _botaoQuadrado(
              icon: Icons.exit_to_app,
              titulo: "Sair",
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

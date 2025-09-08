import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showLogin ? "Entrar" : "Cadastrar"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              showLogin ? const LoginForm() : const CadastroScreen(),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    showLogin = !showLogin;
                  });
                },
                child: Text(
                  showLogin
                      ? "Não tem conta? Cadastre-se"
                      : "Já tem conta? Entre",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- LOGIN ----------------
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  List<bool> isSelected = [true, false]; // contratante por padrão

  @override
  Widget build(BuildContext context) {
    String tipoUsuario = isSelected[0] ? "Contratante" : "Prestador";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "Email"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: senhaController,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Senha"),
        ),
        const SizedBox(height: 20),

        const Text(
          "Selecione o tipo de usuário:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        Center(
          child: ToggleButtons(
            borderRadius: BorderRadius.circular(12),
            fillColor: Colors.green,
            selectedColor: Colors.white,
            color: Colors.black,
            isSelected: isSelected,
            onPressed: (int index) {
              setState(() {
                for (int i = 0; i < isSelected.length; i++) {
                  isSelected[i] = i == index;
                }
              });
            },

            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Contratante"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Prestador"),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              String emailValido = "admin";
              String senhaValida = "1234";

              if (emailController.text == emailValido &&
                  senhaController.text == senhaValida) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Email ou senha Incorretos")),
                );
              }
            },
            child: const Text("Entrar"),
          ),
        ),
      ],
    );
  }
}

// ---------------- CADASTRO ----------------
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<CadastroScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController ocupacaoController = TextEditingController();

  List<bool> isSelected = [true, false]; // contratante por padrão
  @override
  Widget build(BuildContext context) {
    String tipoUsuario = isSelected[0] ? "Contratante" : "Prestador";
    return Column(
      children: [
        const SizedBox(height: 10),

        Center(
          child: ToggleButtons(
            borderRadius: BorderRadius.circular(12),
            fillColor: Colors.green,
            selectedColor: Colors.white,
            color: Colors.black,
            isSelected: isSelected,
            onPressed: (int index) {
              setState(() {
                for (int i = 0; i < isSelected.length; i++) {
                  isSelected[i] = i == index;
                }
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Contratante"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Prestador"),
              ),
            ],
          ),
        ),
        TextField(
          controller: nomeController,
          decoration: const InputDecoration(labelText: "Nome"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "Email"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: senhaController,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Senha"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: cpfController,
          decoration: const InputDecoration(labelText: "CPF"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: telefoneController,
          decoration: const InputDecoration(labelText: "Telefone"),
        ),
        const SizedBox(height: 10),
        if (isSelected[1]) ...[
          TextField(
            controller: ocupacaoController,
            decoration: const InputDecoration(labelText: "Ocupação"),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Aqui você faria a lógica de cadastro
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cadastro realizado!")),
            );
          },
          child: const Text("Cadastrar"),
        ),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<String> allCategorias = [
    "Categoria 1",
    "Categoria 2",
    "Categoria 3",
    "Categoria 4",
  ];

  List<String> filteredCategorias = [];
  @override
  void initState() {
    super.initState();
    filteredCategorias = allCategorias;
  }

  void filterCategorias(String query) {
    setState(() {
      filteredCategorias = allCategorias
          .where((cat) => cat.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Página Inicial"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: filterCategorias,
              decoration: InputDecoration(
                hintText: "Pesquisar Categorias...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: List.generate(4, (index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "Categoria ${index + 1}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MeuPerfilScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Meu Perfil",
          ),
        ],
      ),
    );
  }
}

class MeuPerfilScreen extends StatelessWidget {
  const MeuPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meu Perfil"), centerTitle: true),
      body: const Center(
        child: Text("Perfil do Usuário", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

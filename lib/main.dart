import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database/database_helper.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

   if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cadastro de produtos',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();

  List<Produto> produtos = [];
  int? codigoEmEdicao;

  void novoProduto(){
    setState((){
      codigoController.clear();
      nomeController.clear();
      codigoEmEdicao = null; 
    });
  }
  Future<void> salvarProduto() async {
    final codigo = codigoController.text.trim();
    final nome = nomeController.text.trim();

    if (codigo.isEmpty || nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos os campos são obrigatorios')),
      );
      return;
    }

    final codigoInt = int.tryParse(codigo);

    if(codigoInt == null || codigoInt <= 0){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Codigo deve ser maior que zero')),
      );
      return;
    }

    try {
      if (codigoEmEdicao == null) {
       
        await DatabaseHelper.inserirProduto(codigoInt, nome);
      } else {
       
        await DatabaseHelper.atualizarProduto(codigoEmEdicao!, nome);
      }

      await carregarProdutos();
      await imprimirLogsNoTerminal();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto salvo com sucesso')),
      );

      novoProduto();
      
    } on DatabaseException catch (e) {
    if (e.isUniqueConstraintError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código já cadastrado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no banco: ${e.toString()}')),
      );
    }
  }
}

    void excluirProduto() async {
      final codigo = codigoController.text.trim();

      if (codigo.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text ('Informe o codigo para excluir')),
        );
        return;
    }

    final codigoInt = int.tryParse(codigo);

    if (codigoInt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Codigo invalido')),
      );
      return;
    }

    //MODAL DE CONFIRMAÇÃO
    final bool? confirmou = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context){
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Quer excluir este produto?'),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: (){
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
    if (confirmou != true) {
      return;
    }

  await DatabaseHelper.excluirProduto(codigoInt);
  await carregarProdutos();
  await imprimirLogsNoTerminal();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text ('Produto excluido!')),
  );

  novoProduto();

}

Future<void> carregarProdutos() async {
  final resultado = await DatabaseHelper.listarProdutos();

  setState((){
    produtos = resultado.map((map){
      return Produto(
        codigo: map['codigo_produto'],
        nome: map['nome_produto'],
      );
    }).toList();
  });
}

  Future<void> imprimirLogsNoTerminal() async {
    final logs = await DatabaseHelper.listarLogs();

    debugPrint('====== LOGS DO BANCO ======');

    for (var log in logs) {
      debugPrint(
        '[${log['data_hora']}] '
        'Operação: ${log['operacao']} '
        '| Código: ${log['codigo_produto']}'
      );
    }

    debugPrint('==========================');
  }

  @override
  void initState(){
    super.initState();
    carregarProdutos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Produtos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: codigoController,
              enabled: codigoEmEdicao == null,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'Código',
                border: OutlineInputBorder()
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do produto',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),

           Row(
            children: [
              ElevatedButton(
                onPressed: novoProduto,
                child: const Text('Novo'),
              ),

              const SizedBox(width: 16),

              ElevatedButton(
                onPressed: salvarProduto,
                child: const Text('Salvar'),
              ),

              const SizedBox(width: 16),

              ElevatedButton(
                onPressed: codigoEmEdicao == null ? null : excluirProduto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Excluir'),
              )
            ]
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];

                return Card(
                  child: ListTile(
                    title: Text(produto.nome),
                    subtitle: Text('Codigo: ${produto.codigo}'),
                    onTap: () {
                      setState((){
                        codigoController.text = produto.codigo.toString();
                        nomeController.text = produto.nome;
                        codigoEmEdicao = produto.codigo;
                      });
                    },
                  ),
                );
              },
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class Produto {
  final int codigo;
  final String nome;

  Produto({
    required this.codigo,
    required this.nome,
  });
}
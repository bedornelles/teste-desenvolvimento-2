import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static Database? _database;

  static const String _databaseName = 'produtos.db';

  static const int _databaseVersion = 1;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }


  static Future<void> _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE produto (
        codigo_produto INTEGER PRIMARY KEY,
        nome_produto TEXT NOT NULL,
        CHECK (codigo_produto > 0)
      );
    ''');

    await db.execute('''
      CREATE TABLE log_operacoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        operacao TEXT NOT NULL,
        codigo_produto INTEGER
      );
    ''');

    await db.execute('''
      CREATE TRIGGER trg_produto_insert
      AFTER INSERT ON produto
      BEGIN
        INSERT INTO log_operacoes (operacao, codigo_produto)
        VALUES ('INSERT', NEW.codigo_produto);
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER trg_produto_update
      AFTER UPDATE ON produto
      BEGIN
        INSERT INTO log_operacoes (operacao, codigo_produto)
        VALUES (
          'UPDATE mudou de ' || OLD.nome_produto || ' para ' || NEW.nome_produto,
          NEW.codigo_produto
        );
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER trg_produto_delete
      AFTER DELETE ON produto
      BEGIN
        INSERT INTO log_operacoes (operacao, codigo_produto)
        VALUES ('DELETE', OLD.codigo_produto);
      END;
    ''');
  }

  static Future<void> inserirProduto(int codigo, String nome) async {
    final db = await database;

    await db.insert(
      'produto',
      {
        'codigo_produto': codigo,
        'nome_produto': nome,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  static Future<void> atualizarProduto(int codigo, String nome) async {
    final db = await database;

    await db.update(
      'produto',
      {
        'nome_produto': nome,
      },
      where: 'codigo_produto = ?',
      whereArgs: [codigo],
    );
  }

  static Future<void> excluirProduto(int codigo) async {
    final db = await database;

    await db.delete(
      'produto',
      where: 'codigo_produto = ?',
      whereArgs: [codigo],
    );
  }

  static Future<List<Map<String, dynamic>>> listarProdutos() async {
    final db = await database;

    final List<Map<String, dynamic>> resultado = 
      await db.query('produto');
    
    return resultado;
  }

  static Future<List<Map<String, dynamic>>> listarLogs() async {
    final db = await database;

    return await db.query(
      'log_operacoes',
      orderBy: 'data_hora DESC',
    );
  }

}
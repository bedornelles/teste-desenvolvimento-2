// import '../models/produto.dart';

// class ProdutoRepository {

//   // Lista privada que armazena os produtos em memória
//   final List<Produto> _produtos = [];

//   // Retorna uma cópia da lista de produtos
//   // Evita que alguém altere a lista diretamente
//   List<Produto> listar() {
//     return List.unmodifiable(_produtos);
//   }

//   // Insere um novo produto
//   void inserir(Produto produto) {
//     _produtos.add(produto);
//   }

//   // Atualiza um produto existente
//   void atualizar(Produto produto) {

//     // Procura o índice do produto com o mesmo código
//     final index = _produtos.indexWhere(
//       (p) => p.codigo == produto.codigo,
//     );

//     // Se não encontrar, não faz nada
//     if (index == -1) return;

//     // Substitui o produto antigo pelo novo
//     _produtos[index] = produto;
//   }

//   // Remove um produto pelo código
//   void excluir(int codigo) {

//     // Remove o primeiro produto que tiver o código informado
//     _produtos.removeWhere(
//       (p) => p.codigo == codigo,
//     );
//   }

//   // Verifica se já existe produto com o código informado
//   bool existeCodigo(int codigo) {
//     return _produtos.any(
//       (p) => p.codigo == codigo,
//     );
//   }
// }
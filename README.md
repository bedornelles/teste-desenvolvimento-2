# Cadastro de Produtos – Teste de Desenvolvimento

Este projeto foi desenvolvido como parte de um teste de desenvolvimento, consistindo em uma aplicação desktop construída com **Flutter**, para cadastro e gerenciamento de produtos, utilizando **SQLite** como banco de dados local.

---

## 📌 Funcionalidades

* **Listagem** de produtos cadastrados.
* **Inclusão** de novos produtos.
* **Atualização** de produtos existentes.
* **Exclusão** de produtos.
* **Validações de entrada:** Campos obrigatórios e código do produto deve ser maior que zero ($codigo > 0$).
* **Código único:** Garantia de que o código do produto não se repete.
* **Registro automático (Logs):** Operações no banco de dados (`INSERT`, `UPDATE` e `DELETE`) são registradas automaticamente.

---

## 🛠️ Tecnologias Utilizadas

* **Flutter** (Desktop – Windows)
* **Dart**
* **SQLite**
* **DB Browser for SQLite** (para visualização externa)
* **Git / GitHub**

---

## 🗄️ Banco de Dados

O banco de dados utilizado é o SQLite, armazenado no arquivo `produtos.db`. O script SQL para criação do banco está disponível na pasta `/database`.

O script contempla:
1.  Criação da tabela `produto`.
2.  Criação da tabela `log_operacoes`.
3.  **Triggers** para registro automático de:
    * Inserções (`INSERT`)
    * Atualizações (`UPDATE`)
    * Exclusões (`DELETE`)

> [!IMPORTANT]
> Todas as validações exigidas (campos obrigatórios, código > 0 e código único) são implementadas via **constraints** diretamente no banco de dados.

---

## ⚙️ Configuração do Banco

A aplicação foi projetada para ser "Plug and Play":
* O arquivo `produtos.db` é **criado automaticamente** na primeira execução.
* O banco é gerado na mesma pasta do executável.
* A tabela `log_operacoes` é manipulada exclusivamente pelo banco via triggers, sem necessidade de lógica extra no Flutter.

---

## ▶️ Como Executar

O executável já compilado está disponível na pasta `/executavel`.

1.  Acesse a pasta `executavel`.
2.  Execute o arquivo `.exe`.
3.  O arquivo `produtos.db` surgirá na mesma pasta após a abertura.

---

## 🔍 Verificação dos Logs de Operações

Para verificar os registros gerados pelas triggers:
1.  Abra o **DB Browser for SQLite**.
2.  Clique em `Open Database` e selecione o arquivo `executavel/produtos.db`.
3.  Vá até a aba `Browse Data`.
4.  Selecione a tabela `log_operacoes`.

Lá você encontrará a data/hora, o tipo da operação e o código do produto afetado.

---

## 📌 Observações Finais

* As regras de negócio são garantidas pela integridade do banco de dados.
* O banco pode ser analisado externamente sem necessidade de alterações no código.

PRAGMA foreign_keys = ON;

CREATE TABLE produto (
    codigo_produto INT NOT NULL,
    nome_produto TEXT NOT NULL,
    check (codigo_produto > 0)
);

CREATE TABLE log_operacoes (
    id int PRIMARY KEY AUTOINCREMENT,
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    operacao TEXT NOT NULL,
    codigo_produto INT
);

CREATE TRIGGER trg_produto_insert
AFTER INSERT ON produto
BEGIN
    INSERT INTO log_operacoes(operacao, codigo_produto)
    VALUES ('INSERT', NEW.codigo_produto);
END;

CREATE TRIGGER trg_produto_update
AFTER UPDATE ON produto
BEGIN
    INSERT INTO log_operacoes (operacao, codigo_produto)
    VALUES (
        'UPDATE mudou de ' || OLD.nome_produto || ' para ' || NEW.nome_produto,
        NEW.codigo_produto
    );
END;

CREATE TRIGGER trg_produto_delete
AFTER DELETE ON produto
BEGIN
    INSERT INTO log_operacoes (operacao, codigo_produto)
    VALUES ('DELETE', OLD.codigo_produto);
END;
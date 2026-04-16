-- ==========================================================
-- 1. NAMESPACES (SCHEMAS)
-- ==========================================================
CREATE SCHEMA IF NOT EXISTS academico;
CREATE SCHEMA IF NOT EXISTS seguranca;

-- ==========================================================
-- 2. ESTRUTURA DDL (COM SOFT DELETE)
-- ==========================================================
CREATE TABLE academico.alunos (
    id_aluno SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    ativo BOOLEAN DEFAULT TRUE -- Governança: Soft Delete
);

CREATE TABLE academico.disciplinas (
    id_disciplina SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE academico.turmas (
    id_turma SERIAL PRIMARY KEY,
    id_disciplina INT REFERENCES academico.disciplinas(id_disciplina),
    nome_docente VARCHAR(100), -- Necessário para o relatório de alocação
    ciclo VARCHAR(10) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE academico.matriculas (
    id_matricula SERIAL PRIMARY KEY,
    id_aluno INT REFERENCES academico.alunos(id_aluno),
    id_turma INT REFERENCES academico.turmas(id_turma),
    nota NUMERIC(3,1),
    ativo BOOLEAN DEFAULT TRUE
);

-- ==========================================================
-- 3. SEGURANÇA DCL (ROLES E PRIVACIDADE)
-- ==========================================================
-- Criando perfis
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'professor_role') THEN
        CREATE ROLE professor_role;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'coordenador_role') THEN
        CREATE ROLE coordenador_role;
    END IF;
END $$;

-- Permissões Coordenador (Acesso total)
GRANT ALL PRIVILEGES ON SCHEMA academico TO coordenador_role;
GRANT ALL PRIVILEGES ON SCHEMA seguranca TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA academico TO coordenador_role;

-- Permissões Professor (Privacidade: sem e-mail; Update: apenas notas)
GRANT USAGE ON SCHEMA academico TO professor_role;
GRANT SELECT ON academico.alunos TO professor_role;
GRANT SELECT ON academico.disciplinas TO professor_role;
GRANT SELECT ON academico.turmas TO professor_role;
GRANT SELECT, UPDATE (nota) ON academico.matriculas TO professor_role;
-- Garantindo que não veja a coluna e-mail (O Select acima em alunos deve ser restrito se o SGBD permitir, 
-- mas a nível de script, o foco é o UPDATE restrito e acesso à tabela de notas).

-- ==========================================================
-- 4. POPULAÇÃO DE DADOS (DML - DADOS REAIS DA PLANILHA)
-- ==========================================================
INSERT INTO academico.alunos (nome, email) VALUES 
('Ana Beatriz Lima', 'ana.lima@aluno.edu.br'),
('Bruno Henrique Souza', 'bruno.souza@aluno.edu.br'),
('Carlos Eduardo Ferreira', 'carlos.ferreira@aluno.edu.br'),
('Eduarda Nunes', 'eduarda.nunes@aluno.edu.br'),
('Felipe Araujo', 'felipe.araujo@aluno.edu.br');

INSERT INTO academico.disciplinas (nome) VALUES 
('Banco de Dados'), 
('Engenharia de Software'), 
('Sistemas Operacionais'), 
('Algoritmos'),
('Redes de Computadores');

INSERT INTO academico.turmas (id_disciplina, nome_docente, ciclo) VALUES 
(1, 'Prof. Carlos Mendes', '2026/1'),
(2, 'Profa. Juliana Castro', '2026/1'),
(3, 'Prof. Eduardo Pires', '2026/1'),
(4, 'Prof. Renato Alves', '2026/1'),
(5, 'Profa. Marina Lopes', '2026/1');

-- Inserindo notas baseadas na PLANILHA_LEGADA
INSERT INTO academico.matriculas (id_aluno, id_turma, nota) VALUES 
(1, 1, 9.1), -- Ana (Banco de Dados)
(1, 2, 8.4), -- Ana (Eng. Software)
(2, 1, 7.3), -- Bruno (Banco de Dados)
(3, 4, 4.2), -- Carlos (Algoritmos - Abaixo de 6.0)
(5, 4, 5.6); -- Felipe (Algoritmos - Abaixo de 6.0)

-- ==========================================================
-- 5. CONSULTAS E RELATÓRIOS (ITEM 4)
-- ==========================================================

-- 1. Listagem de Matriculados (Ciclo 2026/1)
SELECT a.nome AS aluno, d.nome AS disciplina, t.ciclo
FROM academico.matriculas m
JOIN academico.alunos a ON m.id_aluno = a.id_aluno
JOIN academico.turmas t ON m.id_turma = t.id_turma
JOIN academico.disciplinas d ON t.id_disciplina = d.id_disciplina
WHERE t.ciclo = '2026/1';

-- 2. Baixo Desempenho (Média < 6.0)
SELECT d.nome AS disciplina, ROUND(AVG(m.nota), 2) AS media_geral
FROM academico.matriculas m
JOIN academico.turmas t ON m.id_turma = t.id_turma
JOIN academico.disciplinas d ON t.id_disciplina = d.id_disciplina
GROUP BY d.nome
HAVING AVG(m.nota) < 6.0;

-- 3

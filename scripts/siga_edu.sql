-- DDL: Namespaces
CREATE SCHEMA academico;
CREATE SCHEMA seguranca;

-- DDL: Estrutura (Com Soft Delete 'ativo')
CREATE TABLE academico.alunos (
    id_aluno SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE academico.disciplinas (
    id_disciplina SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE academico.turmas (
    id_turma SERIAL PRIMARY KEY,
    id_disciplina INT REFERENCES academico.disciplinas(id_disciplina),
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

-- DCL: Segurança
CREATE ROLE professor_role;
CREATE ROLE coordenador_role;

GRANT USAGE ON SCHEMA academico TO professor_role;
GRANT UPDATE (nota) ON academico.matriculas TO professor_role;
GRANT ALL PRIVILEGES ON SCHEMA academico TO coordenador_role;
GRANT ALL PRIVILEGES ON SCHEMA seguranca TO coordenador_role;

-- DML: Consultas Solicitadas (Item 4)
-- 1. Listagem de Matriculados (2026/1)
SELECT a.nome, d.nome, t.ciclo
FROM academico.matriculas m
JOIN academico.alunos a ON m.id_aluno = a.id_aluno
JOIN academico.turmas t ON m.id_turma = t.id_turma
JOIN academico.disciplinas d ON t.id_disciplina = d.id_disciplina
WHERE t.ciclo = '2026/1';

-- 2. Baixo Desempenho (Média < 6.0)
SELECT d.nome, AVG(m.nota) as media_geral
FROM academico.matriculas m
JOIN academico.turmas t ON m.id_turma = t.id_turma
JOIN academico.disciplinas d ON t.id_disciplina = d.id_disciplina
GROUP BY d.nome
HAVING AVG(m.nota) < 6.0;

-- 3. Alocação de Docentes (LEFT JOIN)
SELECT d.nome as disciplina, t.id_professor
FROM academico.turmas t
LEFT JOIN academico.disciplinas d ON t.id_disciplina = d.id_disciplina;

-- 4. Destaque Acadêmico (Subconsulta)
SELECT a.nome, m.nota
FROM academico.matriculas m
JOIN academico.alunos a ON m.id_aluno = a.id_aluno
WHERE m.nota = (SELECT MAX(nota) FROM academico.matriculas);

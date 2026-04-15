# Respostas da Prova Prática - Sistema SigaEdu

## 1. Modelagem e Arquitetura (Teoria)

### Escolha do SGBD Relacional (PostgreSQL)
A escolha de um SGBD Relacional, como o PostgreSQL, é fundamental para sistemas de gestão acadêmica devido à necessidade de **Integridade de Dados** e conformidade com as propriedades **ACID** (Atomicidade, Consistência, Isolamento e Durabilidade):

* **Atomicidade:** Garante que uma operação complexa (ex: matricular um aluno e gerar boletos) seja concluída totalmente ou revertida em caso de erro.
* **Consistência:** As regras de negócio (como chaves estrangeiras e restrições de nota) são validadas pelo banco, impedindo dados órfãos ou inválidos.
* **Isolamento:** Garante que transações simultâneas não interfiram umas nas outras (essencial em períodos de rematrícula).
* **Durabilidade:** Uma vez confirmada a transação, os dados permanecem salvos mesmo em falhas de energia.

Modelos NoSQL, embora escaláveis, geralmente sacrificam a consistência imediata (Teorema CAP), o que poderia gerar inconsistências graves em registros de notas e históricos escolares.

### Uso de Esquemas (Namespaces)
Em um ambiente de Engenharia de Dados profissional, não utilizamos o esquema `public` para tudo por questões de:
1.  **Segurança:** Permite aplicar políticas de acesso granulares (ex: o setor financeiro não acessa o esquema `seguranca`).
2.  **Organização:** Facilita a manutenção e evita conflitos de nomes em bancos de dados com centenas de tabelas.
3.  **Governança:** Separa logicamente os domínios de negócio (Acadêmico vs. Segurança/RH).

---

## 2. Projeto e Normalização (Modelo Lógico)

Para atender à 1NF, 2NF e 3NF, a planilha legada foi decomposta nas seguintes entidades:

* **seguranca.usuarios**: `(id_usuario [PK], nome, email, senha, perfil, ativo [bool])`
* **academico.professores**: `(id_professor [PK], id_usuario [FK], titulacao, ativo [bool])`
* **academico.alunos**: `(id_aluno [PK], id_usuario [FK], ra, ativo [bool])`
* **academico.disciplinas**: `(id_disciplina [PK], nome, carga_horaria, ativo [bool])`
* **academico.turmas**: `(id_turma [PK], id_disciplina [FK], id_professor [FK], ciclo, ativo [bool])`
* **academico.matriculas**: `(id_matricula [PK], id_aluno [FK], id_turma [FK], nota, situacao [bool])`

---

## 5. Transações e Concorrência

No cenário onde dois operadores tentam alterar a nota do mesmo `ID_Matricula` simultaneamente, o SGBD utiliza mecanismos de **Controle de Concorrência**:

1.  **Locks (Bloqueios):** O primeiro operador a executar o comando `UPDATE` adquire um **Row-Level Lock** (bloqueio de linha). 
2.  **Isolamento:** Enquanto a transação do Operador A não for finalizada (`COMMIT`), o Operador B entrará em estado de espera ou será bloqueado para evitar o fenômeno de "Perda de Atualização".
3.  **Consistência Final:** O SGBD garante que a última alteração confirmada seja a válida ou que as alterações sejam serializadas, impedindo que o banco de dados entre em um estado inconsistente onde metade do dado pertence a um operador e metade ao outro.

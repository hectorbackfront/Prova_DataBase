1. Modelagem e Arquitetura
SGBD: Escolhemos o PostgreSQL (SGBD Relacional) por ser rigoroso com as propriedades ACID (Atomicidade, Consistência, Isolamento e Durabilidade). Em um sistema acadêmico, a integridade dos dados (como a relação entre um aluno e sua nota) é crítica. O modelo relacional, através de chaves estrangeiras, garante que não existam registros órfãos, o que seria arriscado em sistemas NoSQL.

Organização: O uso de Schemas (academico, seguranca) é fundamental em Engenharia de Dados para separar o namespace. Isso permite aplicar políticas de segurança granulares (ex: o professor_role só enxerga o schema academico) e evita conflitos de nomes entre tabelas de módulos diferentes, mantendo o ambiente escalável e organizado.

2. Modelo Lógico
academico.alunos: (id_aluno [PK], nome, ativo)

academico.disciplinas: (id_disciplina [PK], nome, ativo)

academico.turmas: (id_turma [PK], id_disciplina [FK], ciclo, ativo)

academico.matriculas: (id_matricula [PK], id_aluno [FK], id_turma [FK], nota, ativo)

5. Transações e Concorrência
Quando dois operadores tentam alterar a nota da mesma matrícula simultaneamente, o SGBD utiliza Locks (bloqueios) em nível de linha. Isso é possível devido aos níveis de isolamento da transação (ACID). O SGBD garante que a segunda operação espere a conclusão da primeira (ou a bloqueie), evitando o fenômeno de "atualização perdida" e garantindo que o dado final seja consistente e íntegro.

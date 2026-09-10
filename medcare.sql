-- Cadastrando Especialidades
INSERT INTO especialidades (nome) VALUES 
('Cardiologia'), 
('Pediatria'), 
('Dermatologia');

-- Cadastrando Pacientes
INSERT INTO pacientes (nome, email, cpf, data_nascimento) VALUES
('Carlos Silva', 'carlos.silva@email.com', '11111111111', '1985-05-20'),
('Ana Oliveira', 'ana.oliveira@email.com', '22222222222', '1990-08-15'),
('Mariana Costa', 'mariana.costa@email.com', '33333333333', '2000-12-10');

-- Cadastrando Médicos 
INSERT INTO medicos (especialidade_id, nome, crm, valor_consulta) VALUES
(1, 'Dr. Roberto Almeida', 'CRM12345', 350.00), 
(2, 'Dra. Fernanda Lima', 'CRM54321', 250.00), 
(3, 'Dra. Juliana Mendes', 'CRM98765', 400.00); 

-- Agendando Consultas 
INSERT INTO consultas (medico_id, paciente_id, data_hora, status) VALUES
(1, 1, '2023-11-01 10:00:00', 'Realizada'), 
(2, 2, '2023-11-02 14:30:00', 'Realizada'), 
(3, 1, '2023-11-05 09:00:00', 'Agendada'),  
(1, 3, '2023-11-10 16:00:00', 'Cancelada'); 

-- Cadastrando Exames 
INSERT INTO exames_consulta (consulta_id, nome_exame, valor_exame) VALUES
(1, 'Eletrocardiograma', 150.00),     
(1, 'Ecocardiograma', 200.00),        
(2, 'Hemograma Completo', 50.00),     
(3, 'Biópsia de Pele', 300.00);

-- SQL

--Q1
SELECT medicos.nome, medicos.crm, especialidades.nome, medicos.valor_consulta 
FROM 
medicos
JOIN 
especialidades ON medicos.especialidade_id = especialidades.id
ORDER BY 
medicos.valor_consulta DESC;

--Q2
SELECT consultas.id, consultas.data_hora, medicos.nome, especialidades.nome, consultas.status
FROM 
consultas
JOIN 
pacientes 
ON 
consultas.paciente_id = pacientes.id
JOIN 
medicos 
ON 
consultas.medico_id = medicos.id
JOIN 
especialidades 
ON 
medicos.especialidade_id = especialidades.id
WHERE pacientes.nome = 'Carlos Silva';

--Q3
SELECT 
    consultas.id, 
    pacientes.nome, 
    medicos.nome, 
    medicos.valor_consulta + COALESCE(SUM(exames_consulta.valor_exame), 0)
FROM 
consultas
JOIN 
pacientes 
ON 
consultas.paciente_id = pacientes.id
JOIN 
medicos 
ON 
consultas.medico_id = medicos.id
LEFT JOIN 
exames_consulta 
ON 
consultas.id = exames_consulta.consulta_id
GROUP BY 
consultas.id, pacientes.nome, medicos.nome, medicos.valor_consulta
ORDER BY consultas.id;

--Q4
SELECT nome, crm, valor_consulta 
FROM medicos 
WHERE valor_consulta > 300.00;

--Q5
SELECT 
    especialidades.nome, 
    SUM(medicos.valor_consulta + COALESCE(exames.soma_exames, 0))
FROM 
consultas
JOIN 
medicos 
ON 
consultas.medico_id = medicos.id
JOIN 
especialidades 
ON 
medicos.especialidade_id = especialidades.id
LEFT JOIN (
    SELECT consulta_id, SUM(valor_exame) soma_exames
    FROM exames_consulta 
    GROUP BY consulta_id
) exames ON consultas.id = exames.consulta_id
WHERE consultas.status = 'Realizada'
GROUP BY especialidades.nome;

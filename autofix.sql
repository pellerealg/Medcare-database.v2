-- 1. Tabela de Clientes
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabela de Mecânicos
CREATE TABLE mecanicos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    valor_hora DECIMAL(10, 2) NOT NULL CHECK (valor_hora > 0)
);

-- 3. Tabela de Veículos
CREATE TABLE veiculos (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    placa CHAR(7) NOT NULL UNIQUE,
    modelo VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    ano INT NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- 4. Tabela de Ordens de Serviço
CREATE TABLE ordens_servico (
    id SERIAL PRIMARY KEY,
    veiculo_id INT NOT NULL,
    mecanico_id INT NOT NULL,
    data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_mao_obra DECIMAL(10, 2) NOT NULL CHECK (valor_mao_obra >= 0),
    status VARCHAR(20) DEFAULT 'Em Aberto' CHECK (status IN ('Em Aberto', 'Em Andamento', 'Concluida', 'Cancelada')),
    FOREIGN KEY (veiculo_id) REFERENCES veiculos(id),
    FOREIGN KEY (mecanico_id) REFERENCES mecanicos(id)
);

-- 5. Tabela de Peças 
CREATE TABLE pecas_os (
    id SERIAL PRIMARY KEY,
    os_id INT NOT NULL,
    nome_peca VARCHAR(150) NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    valor_unitario DECIMAL(10, 2) NOT NULL CHECK (valor_unitario > 0),
    FOREIGN KEY (os_id) REFERENCES ordens_servico(id)
);

-- colocando Clientes 
INSERT INTO clientes (nome, email, telefone, cpf) VALUES
('Fernanda Lima', 'fernanda.lima@email.com', '(11) 98888-1111', '12345678901'),
('Carlos Eduardo', 'carlos.eduardo@email.com', '(11) 97777-2222', '23456789012'),
('Beatriz Souza', 'beatriz.souza@email.com', '(11) 96666-3333', '34567890123');

-- colocando Mecânicos
INSERT INTO mecanicos (nome, especialidade, valor_hora) VALUES
('Ricardo Alves', 'Motor', 120.00),           
('Marcelo Dias', 'Suspensão', 85.00),
('André Santos', 'Injeção Eletrônica', 105.00); 

-- colocando Veículos vinculados aos clientes
INSERT INTO veiculos (cliente_id, placa, modelo, marca, ano) VALUES
(1, 'ABC1D23', 'Civic', 'Honda', 2020),    
(2, 'XYZ9K88', 'Corolla', 'Toyota', 2021),    
(3, 'MNO4P56', 'Onix', 'Chevrolet', 2019);    

-- colocando 4 Ordens de Serviço
INSERT INTO ordens_servico (veiculo_id, mecanico_id, data_abertura, valor_mao_obra, status) VALUES
(1, 1, '2026-03-01 09:00:00', 300.00, 'Concluida'),   
(1, 3, '2026-03-05 14:00:00', 150.00, 'Em Andamento'),
(2, 2, '2026-03-02 10:30:00', 200.00, 'Concluida'),   
(3, 1, '2026-03-04 11:00:00', 250.00, 'Concluida');  

-- colocando 4 Peças associados às Ordens de Serviço
INSERT INTO pecas_os (os_id, nome_peca, quantidade, valor_unitario) VALUES
(1, 'Junta do Cabeçote', 1, 180.00),  
(1, 'Óleo de Motor 5W30', 4, 45.00),   
(2, 'Bico Injetor', 2, 220.00),        
(3, 'Amortecedor Dianteiro', 2, 350.00);

--Q1
SELECT 
    veiculos.modelo, 
    veiculos.marca, 
    veiculos.placa, 
    clientes.nome, 
    clientes.telefone
FROM 
veiculos
JOIN 
clientes 
ON veiculos.cliente_id = clientes.id
ORDER BY veiculos.marca, veiculos.modelo;

--Q2
SELECT 
    ordens_servico.id, 
    veiculos.placa, 
    veiculos.modelo, 
    ordens_servico.data_abertura, 
    mecanicos.nome, 
    ordens_servico.status
FROM 
ordens_servico
JOIN 
veiculos 
ON ordens_servico.veiculo_id = veiculos.id
JOIN 
clientes 
ON veiculos.cliente_id = clientes.id
JOIN 
mecanicos 
ON ordens_servico.mecanico_id = mecanicos.id
WHERE clientes.nome = 'Fernanda Lima';

--Q3
SELECT 
    ordens_servico.id, 
    veiculos.placa, 
    mecanicos.nome, 
    ordens_servico.valor_mao_obra, 
    ordens_servico.valor_mao_obra + COALESCE(SUM(pecas_os.quantidade * pecas_os.valor_unitario), 0)
FROM 
ordens_servico
JOIN 
veiculos
ON 
ordens_servico.veiculo_id = veiculos.id
JOIN 
mecanicos 
ON ordens_servico.mecanico_id = mecanicos.id
LEFT JOIN 
pecas_os 
ON 
ordens_servico.id = pecas_os.os_id
GROUP BY ordens_servico.id, veiculos.placa, mecanicos.nome, ordens_servico.valor_mao_obra
ORDER BY ordens_servico.id;

--Q4
SELECT nome, especialidade, valor_hora 
FROM 
mecanicos 
WHERE 
valor_hora > 90.00;

--Q5
SELECT 
    mecanicos.especialidade, 
    SUM(ordens_servico.valor_mao_obra)
FROM 
ordens_servico
JOIN 
mecanicos 
ON ordens_servico.mecanico_id = mecanicos.id
WHERE
ordens_servico.status = 'Concluida'
GROUP BY 
mecanicos.especialidade;
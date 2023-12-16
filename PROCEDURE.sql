--crio a base de dados se ela ainda não existir
IF NOT EXISTS(SELECT name FROM sys.databases WHERE name='aula8')
	BEGIN
		CREATE DATABASE aula8;
	END
ELSE
	BEGIN
		PRINT 'A base de dados já existe'
	END;

--se a base de dados existir, irei selecioná-la
IF EXISTS(SELECT name FROM sys.databases WHERE name='aula8')
	BEGIN
		USE aula8;
	END
ELSE
	BEGIN
		PRINT 'A base de dados não foi encontrada';
	END;

--crio as tabelas na base de dados, caso ainda não existam
IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE 
	TABLE_NAME = 'funcionario')
	BEGIN
		CREATE TABLE funcionario(
			COD_FUNC INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
			NASC_FUNC INT NOT NULL,
			NOME_FUNC VARCHAR(50) NOT NULL,
			IDADE_FUNC INT NOT NULL,
			BONUS_FUNC DECIMAL (7,2),
			SAL_FUNC DECIMAL (7,2)
		);
	END
ELSE
	BEGIN
		PRINT 'A tabela já existe';
	END; 

--insiro valores na base de dados
INSERT INTO funcionario(NASC_FUNC, NOME_FUNC, IDADE_FUNC, BONUS_FUNC, SAL_FUNC) VALUES
		(1, 'HELENA APARECIDA', 62, 0, 5000),
		(1, 'DANIEL APARECIDO', 61, 0, 7000),
		(2, 'JOÃO CARLOS', 38, 0, 1000),
		(2, 'ROBERTA SILVA', 32, 0, 500),
		(3, 'GIOVANNA', 18, 0, 500),
		(3, 'FERNANDO TORRES', 35, 0, 2500),
		(4, 'JAIRO BATISTA', 33, 0, 1800);

--crio variaveis
DECLARE @nome VARCHAR(50);

--under...
SELECT @nome = NOME_FUNC 
	FROM FUNCIONARIO
		WHERE COD_FUNC = 1

--uso as variaveis em outro select
SELECT SAL_FUNC
	FROM FUNCIONARIO
		WHERE NOME_FUNC = @nome;


SELECT * FROM funcionario
DECLARE @ModificaSalario INT, @aumenta25 DECIMAL(3,2) = 0.25, @aumenta5 DECIMAL(3,2)=0.05;
SELECT @ModificaSalario = IDADE_FUNC FROM funcionario WHERE COD_FUNC = 1

--SELCIONANDO SE O FUNCIONARIO TEM MAIS DE 50 ANOS, SE SIM +25% SE NÃO =5%

IF(@ModificaSalario) > 50 
	BEGIN
		UPDATE funcionario SET SAL_FUNC = SAL_FUNC + (0.25*SAL_FUNC) WHERE COD_FUNC=1;
	END
ELSE
	BEGIN
		UPDATE funcionario SET SAL_FUNC = SAL_FUNC +(0.05 * SAL_FUNC) WHERE COD_FUNC=1;
	END
SELECT COD_FUNC, IDADE_FUNC, BONUS_FUNC, SAL_FUNC, 'Nacionalidade' = 
	CASE NASC_FUNC
		WHEN 1 THEN 'Brasileiro(a)'
		WHEN 2 THEN 'Chinês(a)'
		WHEN 3 THEN 'Japonês(a)'
		ELSE 'Lugar de nascimento desconhecido'
	END
FROM funcionario

SELECT COD_FUNC, IDADE_FUNC, BONUS_FUNC, SAL_FUNC, 'Idade' = 
	CASE 
		WHEN IDADE_FUNC BETWEEN 18 AND 30 THEN 'Jovem'
		WHEN IDADE_FUNC BETWEEN 31 AND 40 THEN 'Adulto - Fase 1'
		WHEN IDADE_FUNC BETWEEN 41 AND 50 THEN 'Adulto - Fase 2'
		WHEN IDADE_FUNC BETWEEN 51 AND 60 THEN 'Adulto - Fase 3'
		WHEN IDADE_FUNC BETWEEN 61 AND 65 THEN 'Adulto - Fase 4'
		ELSE IDADE_FUNC >65 THEN 'Trabalhador inexistente' 
	END
FROM funcionario

DECLARE @Salario DECIMAL(6,2), @bonus DECIMAL(6,2);

SELECT @Salario = SAL_FUNC, @bonus = BONUS_FUNC FROM funcionario WHERE COD_FUNC = 4
WHILE @salario < 1000
	BEGIN
		SET @Salario = @Salario * 0.9;
		SET @bonus = @bonus +@Salario;
		IF @bonus < 1000
			BEGIN
				SET @bonus = 1000;
				BREAK
			END
		ELSE
			BEGIN
				CONTINUE
			END
	END;
	UPDATE funcionario SET BONUS_FUNC = @bonus WHERE COD_FUNC = 5;
PRINT @bonus
PRINT @salario

SELECT * FROM funcionario

CREATE PROCEDURE retirarDecimoTerceiroSalario
	AS
		BEGIN
			UPDATE funcionario	
			SET BONUS_FUNC = 0;
		END;

SELECT * FROM funcionario;
EXECUTE retirarDecimoTerceiroSalario;
SELECT * FROM funcionario;

CREATE TRIGGER supersalario
	ON funcionario
		AFTER INSERT
			AS
				BEGIN
					IF EXISTS(SELECT 1 FROM inserted WHERE SAL_FUNC > 10000)
						BEGIN
							RAISERROR('Não é possível inserir funcionários com supersalário',16,1);
							ROLLBACK TRANSACTION;
						END
					END;
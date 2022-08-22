use master
go

--		drop database EGP   -- EXCLUI O BANCO


--cria o banco de dados, caso nao exista
if (  SELECT count(*) FROM master.dbo.sysdatabases WHERE name = 'EGP' ) = 0
begin 
	exec( 'CREATE DATABASE EGP' );		
end
go
 

-- abre o banco de dados
use EGP
GO

-- cria as tabela - PARTIDO 

if( Select count(*) From sysobjects where id=object_id('PARTIDO') and xtype = 'U' ) = 0
begin
	create table PARTIDO
	(
		ID_PARTIDO				INT					IDENTITY		PRIMARY KEY, -- chave primaria
		SIGLA					VARCHAR(10)			NOT NULL		UNIQUE,		 -- cada partido tem apenas uma sigla
		NOME					VARCHAR(200)		NOT NULL,
		DESCRICAO				VARCHAR(2000)		NOT NULL,
		SERIAL_CAMARA			VARCHAR(100),
		IMAGEM					VARCHAR(200)
	)
end 
go

-- cria a tabela movel para gerenciar os usuários do aplicativo

if( Select count(*) From sysobjects where id=object_id('MOVEL') and xtype = 'U' ) = 0
begin
	CREATE TABLE MOVEL
	(
		ID_MOVEL			INT					IDENTITY		PRIMARY KEY,		--chave primaria
		LOGIN				VARCHAR(100)		NOT NULL		unique,				--login precisa ser unico, não poderá existir dois iguais
		SENHA				VARCHAR(100)		NOT NULL,
		SERIAL_CAMARA		VARCHAR(100)
	)
end 
go

-- cria tabela endereco 

if( Select count(*) From sysobjects where id=object_id('ENDERECO') and xtype = 'U' ) = 0
begin
	CREATE TABLE ENDERECO
	(
		ID_ENDERECO			INT					IDENTITY		PRIMARY KEY, --chave primaria
		CEP					CHAR(10)			NOT NULL,
		RUA					VARCHAR(200)		NOT NULL,
		NUMERO				VARCHAR(20)			NOT NULL,
		BAIRRO				VARCHAR(100)		NOT NULL,
		CIDADE				VARCHAR(100)		NOT NULL,
		SERIAL_CAMARA		VARCHAR(100)
	)
end 
go

-- Existira o participante da sessão que poderá ou não exercer algum cargo politico, ex: vereador, senador, deputado
-- cria a tabela CARGO_POLITICO


if( Select count(*) From sysobjects where id=object_id('CARGO_POLITICO') and xtype = 'U' ) = 0
begin
	CREATE TABLE CARGO_POLITICO
	(
		ID_CARGO_POLITICO	INT					IDENTITY		PRIMARY KEY, --chave primaria
		NOME				VARCHAR(100)		NOT NULL,
		DESCRICAO			VARCHAR(2000)		NOT NULL,
		SERIAL_CAMARA		VARCHAR(100)
	)
end 
go


-- um participante da sessão poderá exercer funções como: secretário, presidente da mesa etc;
-- cria a tabela FUNCAO


if( Select count(*) From sysobjects where id=object_id('FUNCAO') and xtype = 'U' ) = 0
begin
	CREATE TABLE FUNCAO
	(
		ID_FUNCAO			INT					IDENTITY		PRIMARY KEY, --chave primaria
		NOME				VARCHAR(100)		NOT NULL,
		DESCRICAO			VARCHAR(2000)		NOT NULL,
		SERIAL_CAMARA		VARCHAR(100)
	)
end 
go


-- cria a tabela ATA que atualmente está vinculada aos projetos, e não à PAUTA


if( Select count(*) From sysobjects where id=object_id('ATA') and xtype = 'U' ) = 0
begin
	CREATE TABLE ATA
	(
		ID_ATA				INT					IDENTITY		PRIMARY KEY, -- chave primaria
		DATA_HORA			DATE				NOT NULL,
		TEXTO				TEXT				NOT NULL,
		SERIAL_CAMARA		VARCHAR(100)
	)
end 
go


-- cria a tabela CAMARA que possui uma chave estrangeira representando a tabela ENDERECO

if( Select count(*) From sysobjects where id=object_id('CAMARA') and xtype = 'U' ) = 0
begin
	CREATE TABLE CAMARA
	(
		SERIAL_CAMARA		VARCHAR(100)		NOT NULL		PRIMARY KEY, -- chave primaria
		NOME				VARCHAR(300)		NOT NULL,
		CNPJ				CHAR(19)			NOT NULL,
		EMAIL				VARCHAR(150)		NOT NULL,
		TELEFONE			CHAR(11)			NOT NULL,
		CELULAR				CHAR(12)			NOT NULL,
		IMAGEM				VARCHAR(150)		NOT NULL,
		FK_ENDERECO			INT					NOT NULL,					 -- chave estrangeira
		CONSTRAINT		FK_ENDERECO_ID_ENDERECO		FOREIGN KEY (FK_ENDERECO)  REFERENCES ENDERECO (ID_ENDERECO)
	)
end 
go


-- esta tabela RESULTADOS_PROJETO irá guardar informações do projeto e do seu resultado na votação
-- possui uma chave estrangeira que representa a ata, como explicado anteriormente, a ata está vinculada ao
-- projeto em si

if( Select count(*) From sysobjects where id=object_id('RESULTADOS_PROJETO') and xtype = 'U' ) = 0
begin
	CREATE TABLE RESULTADOS_PROJETO
	(
		ID_PROJETO			INT					IDENTITY		PRIMARY KEY,	-- chave primaria
		VOTOS_AFAVOR		INT,
		VOTOS_CONTRA		INT,
		TOTAL_FINAL			INT,
		ABSTENCOES			INT,
		SERIAL_CAMARA		VARCHAR(100),
		DATA_CRIACAO		DATE				NOT NULL,
		STATUS				VARCHAR(100)		NOT NULL,
		DATA_APRESENTACAO	DATE,
		INDEXACAO			TEXT,
		EMENDA				TEXT				NOT NULL,
		TIPO_TITULO			VARCHAR(200)		NOT NULL,
		SIGLA				VARCHAR(20)			NOT NULL,
		FK_ATA				INT,												-- chave estrangeira tabela ATA
		CONSTRAINT		FK_ATA_ID_ATA	FOREIGN KEY (FK_ATA) REFERENCES ATA (ID_ATA)
	)
end 
go


-- cria os participantes da sessão com chave estrageira para tabela, partido, cargo_politico, movel e endereco

if( Select count(*) From sysobjects where id=object_id('PARTICIPANTE_SESSAO') and xtype = 'U' ) = 0
begin
	CREATE TABLE PARTICIPANTE_SESSAO
	(
		CPF								CHAR(14)   		    PRIMARY KEY,		--chave primaria
		NOME							VARCHAR(200)		NOT NULL,
		SEXO							VARCHAR(50)			NOT NULL,
		EMAIL							VARCHAR(150)		NOT NULL,
		CELULAR							VARCHAR(100)		NOT NULL,
		TELEFONE						VARCHAR(100)		NOT NULL,
		IMAGEM							VARCHAR(150)		NOT NULL,
		SERIAL_CAMARA					VARCHAR(100),
		FK_PARTIDO						INT,									--chave estrangeira - partido
		FK_CARGO_POLITICO				INT,									--chave estrangeira - cargo_politico
		FK_MOVEL						INT,									--chave estrangeira - movel
		FK_ENDERECO_PARTICIPANTE		INT					NOT NULL,			--chave estrangeira - endereco

		CONSTRAINT	FK_PARTIDO_ID_PARTIDO FOREIGN KEY (FK_PARTIDO) REFERENCES PARTIDO (ID_PARTIDO),
		CONSTRAINT	FK_CARGO_POLITICO_ID_CARGO_POLITICO FOREIGN KEY (FK_CARGO_POLITICO) REFERENCES CARGO_POLITICO (ID_CARGO_POLITICO),
		CONSTRAINT	FK_MOVEL_ID_MOVEL FOREIGN KEY (FK_MOVEL) REFERENCES MOVEL (ID_MOVEL),
		CONSTRAINT	FK_ENDERECO_ID_ENDERECO_PARTICIPANTE FOREIGN KEY (FK_ENDERECO_PARTICIPANTE) REFERENCES ENDERECO (ID_ENDERECO)
	)
end 
go


-- cria a tabela VOTACAO para gerenciar e armazenar as votações nos progetos, quem votou, qual foi o voto, projeto votado etc
-- possui chave estrangeira para o projeto e para o participante

if( Select count(*) From sysobjects where id=object_id('VOTACAO') and xtype = 'U' ) = 0
begin
	CREATE TABLE VOTACAO
	(
		ID_VOTACAO			INT				IDENTITY		PRIMARY KEY,	--chave primaria
		VOTO				VARCHAR(20)		NOT NULL,
		SERIAL_CAMARA		VARCHAR(100),
		DATA				DATE			NOT NULL,
		FK_PARTICIPANTE		CHAR(14)		NOT NULL,						--chave estrangeira - participante
		FK_PROJETO			INT				NOT NULL,						--chave estrangeira - projeto

		CONSTRAINT	FK_PARTICIPANTE_VOTACAO	FOREIGN KEY(FK_PARTICIPANTE) REFERENCES PARTICIPANTE_SESSAO (CPF),
		CONSTRAINT	FK_PROJETO_VOTACAO		FOREIGN	KEY(FK_PROJETO)		 REFERENCES RESULTADOS_PROJETO (ID_PROJETO)
	)
end 
go


-- esta tabela PROJETO_PARTICIPANTE serve para gerenciar os autores de um projeto, ou seja, cada projeto pode ter 
-- mais de um autor, ex: projeto 1 tem os autores 2 e 3, então nesta tabela ficará duas linhas assim

-- fk_participante		fk_projeto
--		2			|		1
--		3			|		1


if( Select count(*) From sysobjects where id=object_id('PROJETO_PARTICIPANTE') and xtype = 'U' ) = 0
begin
	CREATE TABLE PROJETO_PARTICIPANTE
	(
		ID_PROJETO_PARTICIPANTE		INT		IDENTITY		PRIMARY KEY,		-- chave primaria
		FK_PARTICIPANTE				CHAR(14)		NOT NULL,					-- chave estrangeira - PARTICIPANTE_SESSAO
		FK_PROJETO					INT				NOT NULL,					-- chave estrangeira - RESULTADOS_PROJETO

		CONSTRAINT	FK_PARTICIPANTE_PROJETO_PARTICIPANTE	FOREIGN KEY(FK_PARTICIPANTE) REFERENCES PARTICIPANTE_SESSAO (CPF),
		CONSTRAINT	FK_PROJETO_PROJETO_PARTICIPANTE			FOREIGN KEY(FK_PROJETO) REFERENCES RESULTADOS_PROJETO (ID_PROJETO)
	)
end 
go

-- esta tabela serve para gerenciar os cargos que um participante exerce, ou seja, um participante pode exercer mais de um cargo
-- e um cargo pode ser exercido por mais de um participante ex: 3 secretários

if( Select count(*) From sysobjects where id=object_id('EXERCE') and xtype = 'U' ) = 0
begin
	CREATE TABLE EXERCE
	(
		ID_EXERCE					INT				IDENTITY		PRIMARY KEY,	-- chave primaria
		FK_FUNCAO					INT				NOT NULL,						-- chave estrangeira  - função
		FK_PARTICIPANTE				CHAR(14)		NOT NULL,						-- chave estrangeira  - PARTICIPANTE_SESSAO

		CONSTRAINT	FK_FUNCAO_EXERCE		FOREIGN KEY(FK_FUNCAO) REFERENCES FUNCAO (ID_FUNCAO),
		CONSTRAINT	FK_PARTICIPANTE_EXERCE	FOREIGN KEY(FK_PARTICIPANTE) REFERENCES PARTICIPANTE_SESSAO (CPF)
	)
end 
go


if ( select count(*) from sysobjects where id=OBJECT_ID('USUARIOS') and xtype = 'U' ) = 0
begin
	CREATE TABLE USUARIOS
	(
		ID_USUARIO						INT					IDENTITY(1,1)		PRIMARY KEY,
		FK_CPF_PESSOA					CHAR(14)			NOT NULL,
		LOGIN							VARCHAR(100)		NOT NULL  UNIQUE,
		SENHA							VARCHAR(100)		NOT NULL,
		SERIAL_CAMARA					VARCHAR(100),
		
		CONSTRAINT	FK_ID_PESSOA_USUARIOS		FOREIGN KEY (FK_CPF_PESSOA)	REFERENCES PARTICIPANTE_SESSAO (CPF)
	)
end
go


if ( select count(*) from sysobjects where id=OBJECT_ID('MENU_NOMES') and xtype = 'U' ) = 0
begin
	
	CREATE TABLE MENU_NOMES
	(
		POSICAO_MENU			INT				PRIMARY KEY,      -- INDICA A POSICAO DO MENU SUPERIOR DE OPÇÕES
																  -- SE É O PRIMEIRO, SEGUNDO, TERCEIRO ETC.
		NOME					VARCHAR(100)	NOT NULL	UNIQUE		
	)
end


if ( select count(*) from sysobjects where id=OBJECT_ID('MENU_ITENS_SUSPENSOS') and xtype = 'U' ) = 0
begin
	CREATE TABLE MENU_ITENS_SUSPENSOS
	(
		ID_MENU_ITENS_SUSPENSOS		INT				IDENTITY (1,1)		PRIMARY KEY,

		NUMERO_ITEM					INT,  
		
		-- REPRESENTA A POSIÇÃO DESTE ITEM SUSPENSO NA LISTA SUSPENSA QUANDO O USUÁRIO CLICA
		-- EM UM MENU E ELE ABRE ESTA LISTA SUSPENSA

		FK_POSICAO_MENU			    INT				NOT NULL,

		-- CHAVE ESTRANGEIRA QUE REPRESENTA O MENU SUPERIOR QUE CONTÉM A LISTA SUSPENSA

		NOME_ITEM					VARCHAR(100)	NOT NULL		UNIQUE,

		CONSTRAINT FK_POSICAO_MENU_ITENS_SUSPENSOS	FOREIGN KEY (FK_POSICAO_MENU)	REFERENCES MENU_NOMES (POSICAO_MENU),

	)
end


if ( select count(*) from sysobjects where id=OBJECT_ID('ACESSOS') and xtype = 'U' ) = 0
begin
	CREATE TABLE ACESSOS
	(
		ID_ACESSOS						INT					IDENTITY(1,1)		PRIMARY KEY,
		
		ACESSO							CHAR(1)				NOT NULL,
		ALTERAR							CHAR(1)				NOT NULL,
		NOVO							CHAR(1)				NOT NULL,

		FK_MENU_ITENS_SUSPENSOS			INT					NOT NULL,	
		FK_ID_PESSOA					INT					NOT NULL,
		
		CONSTRAINT	FK_CPF_PESSOA_ACESSOS			FOREIGN KEY	(FK_ID_PESSOA)	REFERENCES USUARIOS (ID_USUARIO),
		CONSTRAINT	FK_MENU_ITENS_SUSPENSOS_ACESSOS	FOREIGN KEY	(FK_MENU_ITENS_SUSPENSOS)	REFERENCES MENU_ITENS_SUSPENSOS (ID_MENU_ITENS_SUSPENSOS)

	)
end

--alter table acessos add constraint FK_MENU_ITENS_SUSPENSOS unique

ALTER TABLE CAMARA alter column IMAGEM varbinary(max)


-- cria novos campos 
-- if not exists (select * from syscolumns where id=object_id('PARTIDOS') and name='DATA_CAD' ) 
-- begin
--   alter table		PARTIDOS		add		DATA_CAD	DATETIME CONSTRAINT DF_PARTIDOS_DATA_CAD DEFAULT GETDATE()
-- end
-- go


-- SELECT * FROM PARTIDOS			-- VERIFICA OS DADOS
-- EXEC SP_HELP PARTIDOS			-- VERIFICA A ESTRUTURA

-- ALTERA O TIPO DE DADO DA COLUNA IMAGEM NO BANco





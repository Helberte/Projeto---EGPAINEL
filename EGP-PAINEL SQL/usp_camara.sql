/*
	usp_camara

	esta sp altera, e insere, exclui as c�maras

	parametros

	N = Cadastrar. Porque N? N de Novo
	A = Alterar o cadastro
	E = Excluir o Cadastro
	C = Consulta - retorna todas as linhas da tabela camara

	retornos

	-- 0 [result] = deu errado
	-- 1 [result] = deu certo
	-- [message] = mensagem do erro ou de alguma informa��o		

	OBS = VERIFICAR A POSS�BILIDADE DE HAVER SERIAL
	OBS = VAI PODER EXISTIR DUAS CAMARAS COM O MESMO CNPJ?
	OBS = N�O IR� SALVAR DUAS C�MARAS NO MESMO ENDERE�O
--*/

use EGP
set dateformat dmy
go

if OBJECT_ID( 'usp_camara' ) is not null drop procedure usp_camara
go

create procedure usp_camara
(
	@acao			char(1),
	@fk_endereco	int					= null,
	@serial_camara	varchar(100)		= null,
	@nome			varchar(300)		= null,
	@cnpj			char(19)			= null,
	@email			varchar(150)		= null,
	@telefone		char(11)			= null,
	@celular		char(12)			= null,
	@imagem			varbinary(max)		= null,
	@cep			char(10)			= null,
	@rua			varchar(200)		= null,
	@numero			varchar(20)			= null,
	@bairro			varchar(100)		= null,
	@cidade			varchar(100)		= null
)
as
begin
	
	begin try

		if (UPPER(@acao) = 'N') -- NOVO
		begin
			
			if (select COUNT(*) from CAMARA c where c.NOME = @nome) != 0
			begin								
				select 'Este nome para C�mara j� est� sendo usado.' [message], 0 [result]	
			end
			else if (select COUNT(*) from CAMARA c where c.CNPJ = @cnpj) != 0
			begin
				select 'Este CNPJ j� est� sendo usado por outra c�mara' [message], 0 [result]
			end
			else if (select COUNT(*) from CAMARA c where c.FK_ENDERECO = @fk_endereco) != 0
			begin
				select 'Este endere�o est� sendo usado por outra c�mara' [message], 0 [result]
			end
			else
			begin
				-- cria 4 grupos de numeros aleat�rios para servir de serial
					
				declare @serial varchar(100), @ultimo_endereco int

				set @serial = LEFT(ABS(CHECKSUM(NEWID())), 4) + '-' +
							  LEFT(ABS(CHECKSUM(NEWID())), 4) + '-' + 
							  LEFT(ABS(CHECKSUM(NEWID())), 4) + '-' + 
							  LEFT(ABS(CHECKSUM(NEWID())), 4)


				-- ja insere o endereco
				insert into ENDERECO (cep, RUA, NUMERO, BAIRRO, CIDADE)
				   values (@cep, @rua, @numero, @bairro, @cidade)

				set	@ultimo_endereco = SCOPE_IDENTITY();
				
				insert into CAMARA(SERIAL_CAMARA, NOME, CNPJ, EMAIL, TELEFONE, CELULAR, IMAGEM, FK_ENDERECO)
				values (@serial,
						@nome,
						@cnpj,
						@email,
						@telefone,
						@celular,
						@imagem,
						@ultimo_endereco)

				select 1 [result], @ultimo_endereco [Id_endereco], @serial [Id_camara]
			end
		end
		else if (UPPER(@acao) = 'A')  -- ALTERAR - UPDATE
		begin
			
			declare @id_endereco_na_camara int			

			-- verifica se existe outra camara diferente da atual que tem o mesmo cnpj
			-- passado por parametro
			if (select COUNT(*) from CAMARA c where c.CNPJ = @cnpj 
													and c.SERIAL_CAMARA != @serial_camara) > 0
			begin
				select 0 [result], 'J� existe outra c�mara com este CNPJ.' [message]
			end
			else
			begin
				-- obtem o numero do endere�o na camara
				select @id_endereco_na_camara=c.FK_ENDERECO from CAMARA c where c.SERIAL_CAMARA = @serial_camara

				-- atualiza a camara atual
				update CAMARA set NOME = @nome,
								  CNPJ = @cnpj,
								  EMAIL = @email,
								  TELEFONE = @telefone,
								  CELULAR = @celular,
								  IMAGEM = @imagem
					   where CAMARA.SERIAL_CAMARA = @serial_camara
			
				-- atualiza o endere�o da camara com base no valor obtido
				update endereco set cep = @cep,
									rua = @rua,
									numero = @numero,
									bairro = @bairro,
									cidade = @cidade
					   where ID_ENDERECO = @id_endereco_na_camara
					   
				select 1 [result]
			end
		end
		else if (UPPER(@acao) = 'E') -- EXCLUIR
		begin
			
			declare @fk_end_camara_atual int
			select @fk_end_camara_atual=c.FK_ENDERECO from CAMARA c
													  where c.SERIAL_CAMARA = @serial_camara

			-- Exclui primeiro a camara
			delete from CAMARA where SERIAL_CAMARA = @serial_camara

			-- Depois o endere�o da camara
			-- por isso este endere�o n�o pode ser usado em duas c�maras diferentes
			-- EXCLUI O ENDERE�O PORQUE � 1 END PARA 1 CAMARA

			delete from ENDERECO where ENDERECO.ID_ENDERECO = @fk_end_camara_atual						

			select 1 [result]			
		end
		else if (UPPER(@acao) = 'C') -- CONSULTA
		begin
			
			select c.SERIAL_CAMARA [Serial],
				   c.NOME [Nome],
				   c.CNPJ [CNPJ],
				   c.EMAIL [Email],
				   c.TELEFONE [Telefone],
				   c.CELULAR [Celular],
				   c.IMAGEM [Imagem],
				   c.FK_ENDERECO,
				   e.BAIRRO [Bairro],
				   e.CEP [Cep],
				   e.CIDADE [Cidades],
				   e.NUMERO [N�mero],
				   e.RUA [Rua]				   
				   from CAMARA c, ENDERECO e
				   where c.FK_ENDERECO = e.ID_ENDERECO
		end

	end try
	begin catch
		
		select 'Erro. Procedimento: ' + ERROR_PROCEDURE() + ' | Linha: ' +
		CONVERT(varchar(100), ERROR_LINE(), 103) + ' | Mensagem: ' + ERROR_MESSAGE() [message], 0 [result]
	end catch
end
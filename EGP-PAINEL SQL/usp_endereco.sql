/*

	usp_endereco

	esta sp insere os endereços e retorna o id do último inserido

	parametros

	N = Cadastrar. Porque N? N de Novo
	A = Alterar o cadastro
	E = Excluir o Cadastro
	C = Consulta - retorna todas as linhas da tabela camara

	retornos

	-- 0 [result] = deu errado
	-- 1 [result] = deu certo
	-- [message] = mensagem do erro ou de alguma informação		
	
*/

use EGP
set dateformat dmy
go

if OBJECT_ID ( 'usp_endereco' ) is not null drop procedure usp_endereco
go

create procedure usp_endereco
(
	@acao			char(1),
	@cep			char(10)		   = null,
	@rua			varchar(200)	   = null,
	@numero			varchar(20)		   = null,
	@bairro			varchar(100)	   = null,
	@cidade			varchar(100)	   = null,
	@serial_camara	varchar(100)	   = null,
	@id				int				   = null

)
as 
begin
		
	begin try

		if (UPPER(@acao) = 'N') -- NOVO
		begin
			
			insert into ENDERECO (cep, RUA, NUMERO, BAIRRO, CIDADE)
				   values (@cep, @rua, @numero, @bairro, @cidade)

			select 1 [result], SCOPE_IDENTITY() [Id]
			
		end
		else if (UPPER(@acao) = 'A')  -- ALTERAR - UPDATE
		begin
			
			update ENDERECO set CEP = @cep,
								RUA = @rua,
								NUMERO = @numero,
								BAIRRO = @bairro,
								CIDADE = @cidade
								where ENDERECO.ID_ENDERECO = @id
			select 1 [result]
		end
		else if (UPPER(@acao) = 'E') -- EXCLUIR
		begin
			
			delete from ENDERECO where ENDERECO.ID_ENDERECO = @id

			select 1 [result]
		end
		else if (UPPER(@acao) = 'C') -- CONSULTA
		begin
			
			select * from ENDERECO
		end

	end try
	begin catch
		
		select 'Erro. Procedimento: ' + ERROR_PROCEDURE() + ' | Linha: ' +
		CONVERT(varchar(100), ERROR_LINE(), 103) + ' | Mensagem: ' + ERROR_MESSAGE() [message], 0 [result]
	end catch
end
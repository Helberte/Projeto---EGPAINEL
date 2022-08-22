/*
	usp_funcao 

	Esta sp cadastra, exclui e altera as funcoes da camara

	valores para o parametro @acao

	N = Cadastrar. Porque N? N de Novo
	A = Alterar o cadastro
	E = Excluir o Cadastro
	C = Consulta - retorna todas as linhas da tabela funcao

	retornos

	-- 0 [result] = deu errado
	-- 1 [result] = deu certo
	-- [message] = mensagem do erro ou de alguma informação
*/

use EGP
set dateformat dmy
go

if OBJECT_ID( 'usp_funcao' ) is not null	drop procedure usp_funcao


go
create procedure usp_funcao
(
	@acao			char(1),
	@nome			varchar(100) = null,
	@descricao		varchar(2000) = null,
	@serial_camara	varchar(100) = null,
	@id_funcao		int		= null
)
as 
begin

	begin try
		
		-- Novo cadastro
		if UPPER(@acao) = 'N'
		begin
			
			-- verifica se já existe uma função com o mesmo nome

			if (select COUNT(*) from FUNCAO f where UPPER(f.NOME) = UPPER(@nome)) = 0
			begin
				
				insert into FUNCAO (NOME, DESCRICAO, SERIAL_CAMARA) values 
									(@nome, @descricao, @serial_camara)

				select 1 [result], SCOPE_IDENTITY() [id]

			end
			else
			begin
				
				select 'Já existe uma função com o mesmo nome.' [message], 0 [result]
			end			

		end
		-- Alterar
		else if UPPER(@acao) = 'A'
		begin
			
			-- verifica se o id da função está vazio

			if @id_funcao is null or @id_funcao = ''
			begin
				select 'Falta o ID da função.' [message], 0 [result]
			end
			else
			begin
			
			-- verifica se já existe uma função diferente com o mesmo nome
				
				if (select COUNT(*) from FUNCAO f where UPPER( f.NOME ) = UPPER( @nome )
													and f.ID_FUNCAO <> @id_funcao) > 0
				begin
					select 'Já existe uma função com o mesmo nome.' [message], 0 [result]
				end
				else
				begin
					update FUNCAO set NOME = @nome,
							     DESCRICAO = @descricao,
						     SERIAL_CAMARA = @serial_camara
					       where ID_FUNCAO = @id_funcao

					select 1 [result]
				end
			end			
		end
		else if UPPER(@acao) = 'E'
		begin

			-- verifica se a função está sendo usada 

			if (select COUNT(*) from EXERCE e, FUNCAO f 
								where e.FK_FUNCAO = f.ID_FUNCAO 
								and f.ID_FUNCAO = @id_funcao) = 0
			begin
				delete from FUNCAO where FUNCAO.ID_FUNCAO = @id_funcao
				
				select 1 [result]
			end
			else 
			begin
				
				-- retorna o nome das pessoas que exercem esta função

				select p.NOME [message], 0 [result] from PARTICIPANTE_SESSAO p, EXERCE e, FUNCAO f
				where p.CPF = e.FK_PARTICIPANTE
				and e.FK_FUNCAO = f.ID_FUNCAO
				and f.ID_FUNCAO = @id_funcao

			end				
		end
		else if UPPER(@acao) = 'C'
		begin
			
			select UPPER( f.ID_FUNCAO ) [CÓDIGO],
				   UPPER( f.NOME ) [NOME],
				   UPPER( f.DESCRICAO ) [DESCRIÇÃO],
				   f.SERIAL_CAMARA [Serial da Câmara] from FUNCAO f
		end

	end try
	begin catch
		
		select 'Erro. Procedimento: ' + ERROR_PROCEDURE() + ' | Linha: ' +
		CONVERT(varchar(100), ERROR_LINE(), 103) + ' | Mensagem: ' + ERROR_MESSAGE() [message], 0 [result]
	end catch
end

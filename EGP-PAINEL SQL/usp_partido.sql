/*
	PROJETO EGP PAINEL
	PROCEDURE : usp_partido  -  grava dados dos partidos
	Esta procedure exclui, insere e altera novos partidos
*/

use EGP
set dateformat dmy
go

if  OBJECT_ID( 'usp_partido' ) is not null drop procedure usp_partido
go

create procedure usp_partido
(
	@acao				char(1),		--  E = Excluir, N = Novo, A = Alterar
	@id_partido			int				= null,
	@sigla				varchar(10)		= NULL,
	@nome			    varchar(200)	= NULL,
	@descricao			varchar(2000)	= NULL,
	@serial_camara		varchar(100)	= NULL,
	@imagem				varchar(200)	= NULL
)
as
begin

	-- 0 [result] = deu errado
	-- 1 [result] = deu certo

	
	begin try
	
		-- EXCLUI

		if @acao = 'E' or @acao = 'e'
		begin
			delete from PARTIDO where id_partido = @id_partido
			select 1 [result]

		-- INSERE
		end
		else if @acao = 'N' or @acao = 'n'
		begin
			
			-- verifica se já existe um partido com a mesma sigla

			if (select COUNT(*) from PARTIDO p where UPPER(p.SIGLA) = UPPER(@sigla)) = 0
			begin
					-- Inclui no banco			
				insert into PARTIDO ( sigla, nome, descricao, serial_camara, imagem ) values 
									(@sigla,@nome,@descricao,@serial_camara,@imagem )
				select 1 [result]
			end
			else
			begin
				declare @nomePartido varchar(100)

				select @nomePartido=p.NOME from PARTIDO p where UPPER(p.SIGLA) = UPPER(@sigla)

				select 'Já existe um partido com esta mesma sigla, nome: ' + @nomePartido [message], 0 [result]

			end		
		end

		-- ALTERA
		else if  @acao = 'A' or @acao = 'a'
		begin 				
				
			update PARTIDO set   sigla = @sigla,
								  nome = @nome,
							 descricao = @descricao,
						 serial_camara = @serial_camara,
								imagem = @imagem
					  where id_partido = @id_partido
			select 1 [result]					 
		end	
		declare @teste int
		set @teste = 8/0
	end try
	begin catch
		
		select 'Erro. Procedimento: ' + ERROR_PROCEDURE() + ' | Linha: ' +
		CONVERT(varchar(100), ERROR_LINE(), 103) + ' | Mensagem: ' + ERROR_MESSAGE() [message], 0 [result]
	end catch		
end
go







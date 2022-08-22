



use EGP
set dateformat dmy
go

if OBJECT_ID( 'usp_atualiza_acessos_usuario' ) is not null	drop procedure usp_atualiza_acessos_usuario

go
create procedure usp_atualiza_acessos_usuario
(
	@acessos				varchar(max),
	@itens_alterados		int
)
as
begin	
					declare @contador		int
					declare @linha			varchar(200)

					declare @id_acessos int
					declare @fk_menu_itens_suspensos int
					declare @id_pessoa int
					declare @novo int 
					declare @alterar int
					declare @acesso int

					declare @str_id_acessos varchar(100)
					declare @str_acesso varchar(100)
					declare @str_alterar varchar(100)
					declare @str_novo varchar(100)
					declare @str_fk_menu_itens_suspensos varchar(100)
					declare @str_id_pessoa varchar(100)

					set @contador = 0

					while @contador < @itens_alterados
					begin

				--						ORDEM DOS CAMPOS

				--						id_acessos              
				--						fk_menu_itens_suspensos
				--						id_usuario         
				--						acesso                
				--						alterar              
				--						novo   
			  
						set @linha = SUBSTRING(@acessos, 0, CHARINDEX('|', @acessos))
						-- corta a string maior em uma que representa apenas uma linha do grid e da tabela acessos
				
						set @str_id_acessos = SUBSTRING(@linha, 0, charindex(';', @linha))	
						set @linha = REPLACE(@linha, @str_id_acessos + ';', '')					-- ATUALIZA

						set @str_fk_menu_itens_suspensos = SUBSTRING(@linha, 0, charindex(';', @linha))
						set @linha = REPLACE(@linha, @str_fk_menu_itens_suspensos + ';', '')	-- ATUALIZA

						set @str_id_pessoa = SUBSTRING(@linha, 0, charindex(';', @linha))
						set @linha = REPLACE(@linha, @str_id_pessoa + ';', '')					-- ATUALIZA

						set @str_acesso = SUBSTRING(@linha, 0, charindex(';', @linha))
						set @linha = REPLACE(@linha, @str_acesso + ';', '')						-- ATUALIZA
		
						set @str_alterar = SUBSTRING(@linha, 0, charindex(';', @linha))
						set @linha = REPLACE(@linha, @str_alterar + ';', '')					-- ATUALIZA

						set @str_novo = SUBSTRING(@linha, 0, charindex(';', @linha))

						-- SETANDO VARIÁVEIS PARA INSERÇÃO NO BANCO DE DADOS

						set @id_acessos =			   CONVERT(int, substring(@str_id_acessos, CHARINDEX('=', @str_id_acessos) + 1, LEN(@str_id_acessos)))
						set @fk_menu_itens_suspensos = CONVERT(int, substring(@str_fk_menu_itens_suspensos, CHARINDEX('=', @str_fk_menu_itens_suspensos) + 1, LEN(@str_fk_menu_itens_suspensos)))
						set @id_pessoa =			   CONVERT(int, substring(@str_id_pessoa, CHARINDEX('=', @str_id_pessoa) + 1, LEN(@str_id_pessoa)))
						set @acesso =				   CONVERT(int, substring(@str_acesso, CHARINDEX('=', @str_acesso) + 1, LEN(@str_acesso)))
						set @alterar =				   CONVERT(int, substring(@str_alterar, CHARINDEX('=', @str_alterar) + 1, LEN(@str_alterar)))
						set @novo =					   CONVERT(int, substring(@str_novo, CHARINDEX('=', @str_novo) + 1, LEN(@str_novo)))
					
				
						update ACESSOS set ACESSO = @acesso, ALTERAR = @alterar, NOVO = @novo
						where ID_ACESSOS = @id_acessos and FK_ID_PESSOA = @id_pessoa		
						
						if (@contador <> @itens_alterados - 1)
						begin
							set @acessos = SUBSTRING(@acessos, CHARINDEX('|', @acessos) + 2, LEN(@acessos))			
						end	

						set @contador = @contador + 1
					end	
end


select * from ACESSOS


---update ACESSOS set ACESSO = 0, ALTERAR = 1, NOVO = 0 where ID_ACESSOS = 1 and FK_ID_PESSOA = 1
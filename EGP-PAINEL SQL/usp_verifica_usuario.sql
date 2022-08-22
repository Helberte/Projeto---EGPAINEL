


use EGP
set dateformat dmy
go

if OBJECT_ID( 'usp_verifica_usuario' ) is not null	drop procedure usp_verifica_usuario
go


create procedure usp_verifica_usuario
(
	@login		varchar(100),
	@senha		varchar(100)
)
as
begin

	begin try

		-- verifica se o usuario existe
		if( select COUNT(*) from USUARIOS u where UPPER(u.LOGIN) = UPPER(@login) ) > 0
		begin
			-- verifica se a senha está correta
			if (select u.SENHA from USUARIOS u where UPPER(u.LOGIN) = UPPER(@login)) = @senha
			begin
				declare @id_usuario int
				declare @nome_usuario varchar(100)

				select @id_usuario=u.ID_USUARIO, @nome_usuario=p.NOME from USUARIOS u, PARTICIPANTE_SESSAO p
				where u.FK_CPF_PESSOA = p.CPF
				and UPPER(u.LOGIN) = UPPER(@login)

				-- retorna o id do usuario
				select @id_usuario [ID], 1 [result], UPPER(@nome_usuario) [NOME]
			end
			else
			begin
				select 0 [result], 'Senha incorreta' [message]
			end
		end
		else
		begin

			select 0 [result], 'Usuário não existe.' [message]
		end

	end try
	begin catch
		select 'Erro. Procedimento: ' + ERROR_PROCEDURE() + ' | Linha: ' +
		CONVERT(varchar(100), ERROR_LINE(), 103) + ' | Mensagem: ' + ERROR_MESSAGE() [message], 0 [result]
	end catch
end
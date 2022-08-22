



use EGP
set dateformat dmy
go

if OBJECT_ID( 'usp_retorna_usuarios' ) is not null	drop procedure usp_retorna_usuarios
go


create procedure usp_retorna_usuarios
as
begin

	select UPPER(u.ID_USUARIO) [ID], UPPER(p.NOME) [NOME],
		   UPPER(u.LOGIN) [LOGIN], UPPER(p.CPF) [CPF] 
		   from USUARIOS u, PARTICIPANTE_SESSAO p
		   where u.FK_CPF_PESSOA = p.CPF

end


--exec usp_retorna_usuarios
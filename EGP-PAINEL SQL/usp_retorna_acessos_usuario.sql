

use EGP
set dateformat dmy
go

if OBJECT_ID( 'usp_retorna_acessos_usuario' ) is not null	drop procedure usp_retorna_acessos_usuario


go
create procedure usp_retorna_acessos_usuario
(
	@id_usuario			int
)
as
begin 
	 
	 if (@id_usuario = -1)
	 begin		
		select	m.NOME_ITEM, m.FK_POSICAO_MENU, m.NUMERO_ITEM 
		from MENU_ITENS_SUSPENSOS m, MENU_NOMES n
		where 
		m.FK_POSICAO_MENU = n.POSICAO_MENU
		and UPPER(n.NOME) <> 'LATERAL'		
	 end
	 else
	 begin
		select	m.NOME_ITEM, 
				m.FK_POSICAO_MENU, m.NUMERO_ITEM 
				from ACESSOS, MENU_ITENS_SUSPENSOS m, USUARIOS u, PARTICIPANTE_SESSAO part, MENU_NOMES n
		where 
			ACESSOS.FK_MENU_ITENS_SUSPENSOS = m.ID_MENU_ITENS_SUSPENSOS
		and ACESSos.FK_ID_PESSOA = u.ID_USUARIO
		and u.FK_CPF_PESSOA = part.CPF
		and n.POSICAO_MENU = m.FK_POSICAO_MENU
		and u.ID_USUARIO = @id_usuario
		and ACESSOS.ACESSO = 1
		and UPPER(n.NOME) <> 'LATERAL'	
	 end
end

--exec usp_retorna_acessos_usuario -1



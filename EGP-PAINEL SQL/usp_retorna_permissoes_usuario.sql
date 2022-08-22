

use EGP
set dateformat dmy
go

if OBJECT_ID( 'usp_retorna_permissoes_usuario' ) is not null	drop procedure usp_retorna_permissoes_usuario
go


create procedure usp_retorna_permissoes_usuario
(
	@id_usuario		int
)
as
begin

		select a.ID_ACESSOS, m.ID_MENU_ITENS_SUSPENSOS, u.ID_USUARIO, n.POSICAO_MENU, m.NOME_ITEM, a.ACESSO, a.ALTERAR, a.NOVO, n.NOME [NOME_MENU]
		from ACESSOS a, USUARIOS u, MENU_ITENS_SUSPENSOS m, PARTICIPANTE_SESSAO p, MENU_NOMES n
		where a.FK_ID_PESSOA = u.ID_USUARIO
		and a.FK_MENU_ITENS_SUSPENSOS = m.ID_MENU_ITENS_SUSPENSOS
		and u.FK_CPF_PESSOA = p.CPF
		and m.FK_POSICAO_MENU = n.POSICAO_MENU
		and u.ID_USUARIO = @id_usuario
		order by n.POSICAO_MENU asc

end

-- id_acessos
-- fk_menu_itens_suspensos
-- fk_id_pessoa

--exec usp_retorna_permissoes_usuario 1

--select * from ACESSOS a where a.FK_ID_PESSOA = 2

--update ACESSOS set ACESSO = 1 where ID_ACESSOS = 19
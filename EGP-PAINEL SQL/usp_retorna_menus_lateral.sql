

use EGP
set dateformat dmy
go

if OBJECT_ID( 'usp_retorna_menus_lateral' ) is not null	drop procedure usp_retorna_menus_lateral
go

create procedure usp_retorna_menus_lateral
(
	@id_usuario			int
)
as
begin
	
	if(@id_usuario = -1)
	begin
				
		select suspensos.NOME_ITEM, suspensos.NUMERO_ITEM from MENU_NOMES nomes, MENU_ITENS_SUSPENSOS suspensos
		where nomes.POSICAO_MENU = suspensos.FK_POSICAO_MENU
		and nomes.NOME = 'LATERAL'  -- posição 7 se refere à opções laterais		
	end
	else
	begin
		select m.NOME_ITEM, m.NUMERO_ITEM from ACESSOS a, USUARIOS u, PARTICIPANTE_SESSAO p, MENU_ITENS_SUSPENSOS m, MENU_NOMES n
		where a.FK_ID_PESSOA = u.ID_USUARIO
		and u.FK_CPF_PESSOA = p.CPF
		and a.FK_MENU_ITENS_SUSPENSOS = m.ID_MENU_ITENS_SUSPENSOS
		and m.FK_POSICAO_MENU = n.POSICAO_MENU
		and UPPER(n.NOME) = 'LATERAL' -- posição 7 se refere à opções laterais
		and u.ID_USUARIO = @id_usuario
		and a.ACESSO = 1
	end		
end

--exec usp_retorna_menus_lateral -1

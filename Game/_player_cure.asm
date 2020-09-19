INCLUDE project.inc
INCLUDE macros.inc
.code
player_cure PROC,
	p_maxhp:DWORD,
	now_hp:DWORD

	mov eax,p_maxhp;
	shr eax,4;
	mov esi,now_hp
	add esi,eax
	shl eax,4;
	.IF now_hp>eax
		mov now_hp,eax;
	.ENDIF
	mov eax, now_hp
	ret
player_cure ENDP
END
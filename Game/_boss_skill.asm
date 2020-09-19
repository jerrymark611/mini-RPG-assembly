INCLUDE project.inc
INCLUDE macros.inc
.code
boss_skill PROC,
	damage:PTR DWORD,
	phy_atk:DWORD,
	mag_atk:DWORD,
	p_phy_def:DWORD,
	p_mag_def:DWORD

	mov eax,phy_atk;
	sub eax,p_phy_def;
	.IF eax<0
		mov eax, 0;
	.ENDIF
	mov ebx,mag_atk;
	sub ebx,p_mag_def;
	.IF ebx<0
		mov ebx, 0;
	.ENDIF
	add eax,ebx;
	ret
boss_skill ENDP
END

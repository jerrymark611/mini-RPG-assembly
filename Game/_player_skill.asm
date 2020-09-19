INCLUDE project.inc
INCLUDE macros.inc
.code
player_skill PROC,
	damage:PTR DWORD,
	phy_rate:BYTE,
	phy_atk:DWORD,
	mag_rate:BYTE,
	mag_atk:DWORD,
	b_phy_def:DWORD,
	b_mag_def:DWORD

	mov eax,phy_atk;
	mov edx, b_phy_def
	sub eax,edx;
	.IF eax<0
		mov eax, 0;防禦力比攻擊力高傷害等於0
	.ENDIF

	mov ecx,mag_atk;
	mov ebx, b_mag_def
	sub ecx,ebx;
	.IF ecx<0
		mov ecx, 0;防禦力比攻擊力高傷害等於0
	.ENDIF

	mov edx,eax;
	shr edx,4;
	mov bl,phy_rate
	.IF bl==-4
		shl edx,4;
		sub eax,edx
		jmp L1
	.ENDIF
	.IF bl==0
		shl edx,0;
	.ENDIF
	.IF bl==1
		shl edx,1;
	.ENDIF
	.IF bl==2
		shl edx,2;
	.ENDIF
	.IF bl==3
		shl edx,3;
	.ENDIF
	add eax,edx
L1:
	mov edx,ecx;
	shr edx,4;
	mov bl,mag_rate
	.IF bl==-4
		shl edx,4;
		sub eax,edx
		jmp L2
	.ENDIF
	.IF bl==0
		shl edx,0;
	.ENDIF
	.IF bl==1
		shl edx,1;
	.ENDIF
	.IF bl==2
		shl edx,2;
	.ENDIF
	.IF bl==3
		shl edx,3;
	.ENDIF
	add ecx,edx
L2:
	add eax,ecx;
	;mov [damage],eax
	ret
player_skill ENDP
END

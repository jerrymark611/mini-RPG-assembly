INCLUDE project.inc
INCLUDE macros.inc

earase_arrows proto
.data
	leftlocation byte 15,29, 16,29, 16,30, 17,30, 17,31, 18,31,   18,32, 19,32   ,15,35, 16,35, 16,34, 17,34, 17,33, 18,33
	rightlocation byte 76,29, 77,29, 77,30, 78,30, 78,31, 79,31,   79,32, 80,32   ,76,35, 77,35, 77,34, 78,34, 78,33, 79,33
	occupation BYTE 1 ;1 for Swordsman 2 for Magician 3 for archer
	quality BYTE 1 ;1~6
	skill BYTE 0 ;1~3
	gen_skill BYTE 0 ; 1~5

	currentlocation byte 1 ;1 ~ 21
	starttime dword ?
	erase byte 1
	ready byte 0
	eraseaccu byte 1
.code
Setup PROC, rea: byte
	mov al, rea
	mov ready, al
	.IF rea == 1
		INVOKE print_scene, 2
	.ELSE
		INVOKE print_scene, 1
		INVOKE blink,0,1,1
		INVOKE blink,1,1,1
		INVOKE blink,2,1,1
	.ENDIF


	INVOKE GetTickCount
	mov startTime,eax
	LookForKey:
		INVOKE GetTickCount
		sub eax, startTime
	.IF ready == 0
		.IF eax > 1000
			.IF erase == 1
				.IF occupation == 1
					INVOKE Blink,0,1,1
				.ELSEIF occupation ==2
					INVOKE Blink,1,1,1
				.ELSEIF occupation ==3
					INVOKE Blink,2,1,1
				.ENDIF
				mov erase, 0
			.ENDIF
			INVOKE GetTickCount
			mov startTime,eax
		.ELSEIF eax >500
			.IF erase == 0
				.IF occupation == 1
					INVOKE Blink,0,0,1
				.ELSEIF occupation ==2

					INVOKE Blink,1,0,1
				.ELSEIF occupation ==3
					INVOKE Blink,2,0,1
				.ENDIF
				mov erase, 1
			.ENDIF
		.ENDIF
	.ELSEIF ready ==1
		.IF eax > 1000
			.IF erase == 1
				INVOKE blink,currentlocation,1,2
				mov erase, 0
			.ENDIF
			INVOKE GetTickCount
			mov startTime,eax
		.ELSEIF eax >500
			.IF erase == 0
				INVOKE blink,currentlocation,0,2
				mov erase, 1
			.ENDIF
		.ENDIF
	.ENDIF
	mov  eax,50          ; sleep, to allow OS to time slice
	call Delay           ; (otherwise, some key presses are lost)
	call ReadKey         ; look for keyboard input

	.IF ready == 0 ; choose character
		.IF dx == 26h;determine where is arrow
			.IF occupation == 2
				mov occupation, 1

				INVOKE Blink,1,1,1
			.ELSEIF occupation == 3
				mov occupation, 2
				INVOKE Blink,2,1,1
			.ENDIF
		.ELSEIF dx == 28h
			.IF occupation == 1
				mov occupation, 2
				INVOKE Blink,0,1,1
			.ELSEIF occupation == 2
				mov occupation, 3
				INVOKE Blink,1,1,1
			.ENDIF
		.ENDIF

	.ELSEIF ready == 1 ; choose skill
		.IF dx == 26h ;up
			INVOKE Blink,currentlocation,1,2
			.IF currentlocation < 8
				.IF currentlocation >1
					dec currentlocation
				.ENDIF
			.ELSEIF currentlocation < 17
				.IF occupation ==1
					dec currentlocation
				.ELSEIF occupation ==2
					.IF currentlocation ==11
						mov currentlocation, 7
					.ELSE
						dec currentlocation
					.ENDIF
				.ELSEIF occupation ==3
					.IF currentlocation ==14
						mov currentlocation, 7
					.ELSE
						dec currentlocation
					.ENDIF
				.ENDIF
			.ELSEIF currentlocation <19
				.IF currentlocation ==18
					dec currentlocation
				.ELSE
					.IF occupation ==1
							mov currentlocation, 9
					.ELSEIF occupation ==2
							mov currentlocation, 13
					.ELSEIF occupation ==3
							dec currentlocation
					.ENDIF
				.ENDIF
			.ENDIF
		.ELSEIF dx == 28h ; down
			INVOKE Blink,currentlocation,1,2
			.IF currentlocation < 8
				.IF currentlocation ==7
					.IF occupation ==2
						mov currentlocation, 11
					.ELSEIF occupation ==3
						mov currentlocation, 14
					.ELSE
						inc currentlocation
					.ENDIF
				.ELSE
					inc currentlocation
				.ENDIF
			.ELSEIF currentlocation < 17
				.IF occupation ==1
					.IF currentlocation ==9
						mov currentlocation, 17
					.ELSE
						inc currentlocation
					.ENDIF
				.ELSEIF occupation ==2
					.IF currentlocation ==13
						mov currentlocation, 17
					.ELSE
						inc currentlocation
					.ENDIF
				.ELSEIF occupation == 3
						inc currentlocation
				.ENDIF
			.ELSEIF currentlocation >16
				.IF currentlocation <18
					inc currentlocation
				.ENDIF
			.ENDIF
		.ENDIF
	.ENDIF

	compare:
		cmp    dx,VK_ESCAPE  ; time to quit?
		je quit
		.IF ready == 0
			.IF dx ==0dh
				mov ready, 1
				mov dx, 0 ;clear
				call Clrscr
				INVOKE print_scene, 2
				call earase_arrows
			.ENDIF
		.ELSEIF ready == 1
			.IF dx ==0dh
				mov al, occupation
				mov ah, currentlocation
				jmp quit
			.ENDIF
		.ENDIF
		jmp LookForKey    ; no, go get next key.

quit:
	call Clrscr
	ret
Setup ENDP

earase_arrows proc
	.while eraseaccu <22 ; clear arrows
			INVOKE Blink,eraseaccu,1,2
			inc eraseaccu
	.endw
		ret
earase_arrows endp
END

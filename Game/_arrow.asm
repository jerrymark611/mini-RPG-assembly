INCLUDE project.inc
INCLUDE macros.inc
.data
	leftarrow byte 1
	starttime dword ?
	erase byte 1
	start byte 1
.code
Arrow PROC
	INVOKE blink,0,1,0
	INVOKE blink,1,1,0
	INVOKE GetTickCount
	mov startTime,eax
	LookForKey:
		INVOKE GetTickCount
		sub eax, startTime

		.IF eax > 1000
			.IF erase == 0
				.IF leftarrow == 0
					INVOKE Blink,0,0,0
				.ELSE
					INVOKE Blink,1,0,0
				.ENDIF
				mov erase, 1
			.ENDIF
			INVOKE GetTickCount
			mov startTime,eax
		.ELSEIF eax >500
			.IF erase == 1
				.IF leftarrow == 0
					INVOKE Blink,0,1,0
				.ELSE
					INVOKE Blink,1,1,0
				.ENDIF
				mov erase,0
			.ENDIF
		.ENDIF

		mov  eax,50          ; sleep, to allow OS to time slice
		call Delay           ; (otherwise, some key presses are lost)
		call ReadKey         ; look for keyboard input
		.IF dx == 25h;determine where is arrow
			mov start, 1
			.IF leftarrow == 0
				mov leftarrow, 1
				INVOKE Blink,0,1,0
		.ENDIF
		.ELSEIF dx == 27h
			mov start, 0
			.IF leftarrow == 1
				mov leftarrow, 0
				INVOKE Blink,1,1,0
			.ENDIF
		.ENDIF
	compare:
		cmp    dx,VK_ESCAPE  ; time to quit?
		je quit
		cmp    dx,VK_RETURN  ; time to quit?
		mov dx, 0 ;clear
		jne    LookForKey    ; no, go get next key.
	mov al, start
quit:
	ret
Arrow ENDP

END


main          EQU start@0
INCLUDE project.inc
include macros.inc
BUFFER_SIZE = 10000
Interval = 0
print_scene proto, typ: BYTE ;0 for title 1 for occupation choosing 2 for skill choosing 3 for battle
.data
fileHandle HANDLE ?
windowRect SMALL_RECT<0,0,139,49>
buffersize COORD <130,130>
outHandle HANDLE 0
buffer byte BUFFER_SIZE DUP(0)
battlefile byte "battle.txt",0
titlefile byte "title.txt",0
skillfile byte "learn_skill.txt",0
playerchoosefile byte "player_choose.txt",0

	boss1file byte "boss1.txt",0
	boss2file byte "boss2.txt",0
	boss3file byte "boss3.txt",0
	boss4file byte "boss4.txt",0
	boss5file byte "boss5.txt",0
	boss6file byte "boss6.txt",0
	boss7file byte "boss7.txt",0
	boss8file byte "boss8.txt",0
	boss9file byte "boss9.txt",0
	boss10file byte "boss10.txt",0
.code

main PROC
	pushad
start:
	call Clrscr
;get handle
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov outHandle, eax

;set buffer console size
	INVOKE SetConsoleScreenBufferSize,
	outHandle,
	buffersize
;set console size
	;INVOKE SetConsoleWindowInfo,
	;outHandle,
	;TRUE,
	;ADDR windowRect


;print title
	INVOKE print_scene,0
;arrow blinking
	call Arrow
	cmp    dx,VK_ESCAPE  ; time to quit?
	je quit
;choose exit
	cmp al, 0
	je quit
	call Clrscr
;choose start

;choose character

	INVOKE Setup, 0
	cmp    dx,VK_ESCAPE  ; time to quit?
	je quit
;battle
	call Battle
	;cmp    dx,VK_ESCAPE  ; time to quit?
	;jmp quit
;LookForKey:
;	mov  eax,50          ; sleep, to allow OS to time slice
;	call Delay           ; (otherwise, some key presses are lost)
;	call ReadKey
;	compare:
;		cmp    dx,VK_ESCAPE  ; time to quit?
;		je quit
;		mov dx, 0 ;clear
;		jne    LookForKey

quit:
	call Clrscr
	popad
	exit
main ENDP

print_scene PROC,
	typ: BYTE
	;read titlefile
		.IF typ ==0
			mov   edx,OFFSET titlefile
		.ELSEIF typ ==1
			mov   edx,OFFSET playerchoosefile
		.ELSEIF typ ==2
			mov   edx,OFFSET skillfile
		.ELSEIF typ ==3
			mov   edx,OFFSET boss1file
		.ELSEIF typ ==4
			mov   edx,OFFSET boss2file
		.ELSEIF typ ==5
			mov   edx,OFFSET boss3file
		.ELSEIF typ ==6
			mov   edx,OFFSET boss4file
		.ELSEIF typ ==7
			mov   edx,OFFSET boss5file
		.ELSEIF typ ==8
			mov   edx,OFFSET boss6file
		.ELSEIF typ ==9
			mov   edx,OFFSET boss7file
		.ELSEIF typ ==10
			mov   edx,OFFSET boss8file
		.ELSEIF typ ==11
			mov   edx,OFFSET boss9file
		.ELSEIF typ ==12
			mov   edx,OFFSET boss10file
		.ENDIF

		call  OpenInputFile

		mov   edx,OFFSET buffer
		mov   ecx,BUFFER_SIZE
		call  ReadFromFile
	;insert null
		mov buffer[eax], 0
		.IF typ ==0
			mov  ecx, 37
		.ELSEIF typ ==1
			mov  ecx, 45
		.ELSEIF typ ==2
			mov edx, offset buffer
			call writestring
			mov   eax,fileHandle
			call  CloseFile
			jmp quit
		.ELSE
			mov ecx, 43
		.ENDIF
		mov ebx, 1
		mov edi, offset buffer
;print scene
	print_sce:
		scene_line:
			inc edi
			inc ebx
			mov eax, ebx
			.IF typ ==0
				mov esi, 144
			.ELSEIF typ==1
				mov esi, 39
			.ELSEIF typ ==2
				mov esi, 90
			.ELSE
				mov esi, 155
			.ENDIF
			mov edx, 0
			div esi
			.IF edx == 0
					mov eax, Interval
					call Delay
			.ELSE
				mov al, [edi]
				call writechar
				jmp scene_line
			.ENDIF
		loop print_sce
	;close file
		mov   eax,fileHandle
		call  CloseFile
quit:
	ret
print_scene endp

END main

INCLUDE project.inc
INCLUDE macros.inc
BUFFER_SIZE = 10000
Interval = 50
player struct
	hp DWORD ?		;hp
	maxhp DWORD ?		;maxhp
	phy_atk DWORD ?		;物攻
	mag_atk DWORD ?		;魔攻
	phy_def DWORD ?		;物防
	mag_def DWORD ?		;魔防
	speed DWORD ?		;速度
	skillCD_1 sBYTE -1;
	skillCD_2 sBYTE -1;
	skillCD_3 sBYTE -1;
	gen_skillCD_1 sBYTE -1;
	gen_skillCD_2 sBYTE -1;
	cureCD    sBYTE 0;
player ends

boss struct
	hp DWORD ?		;hp
	maxhp DWORD ?
	phy_atk DWORD ?		;物攻
	mag_atk DWORD ?		;魔攻
	atk_attributes DWORD ?	;普攻屬性
	phy_def DWORD ?		;物防
	mag_def DWORD ?		;魔防
	speed DWORD ?		;速度
boss ends
skill_column proto
print_char proto, char: BYTE
load_boss proto
movement proto
box_udate proto
status_up proto
.data
	leftarrow byte 1
	start byte 1
	round byte 1
	char1file byte "char1.txt",0
	char2file byte "char2.txt",0
	char3file byte "char3.txt",0
	fileHandle HANDLE ?
	buffer byte BUFFER_SIZE DUP(0)

	player_data player<>;玩家資料
	boss_data boss<>;BOSS資料
	damage DWORD ?

	level byte 1
	current_occu byte ?
	currentlocation byte 1 ;1 ~ 6
	starttime dword ?
	erase byte 1
	first_strike byte 0
.code

Battle PROC
	mov current_occu, al
	.IF al==1
		mov player_data.hp,1300
		mov player_data.maxhp,1300
		mov player_data.phy_atk,350   ;物攻
		mov player_data.mag_atk,50	;
		mov player_data.phy_def,200	;物防
		mov player_data.mag_def,100	;魔防
		mov player_data.speed,70	;速度
	.ELSEIF al==2
		mov player_data.hp,800
		mov player_data.maxhp,800
		mov player_data.phy_atk,150
		mov player_data.mag_atk,250
		mov player_data.phy_def,150	;物防
		mov player_data.mag_def,150	;魔防
		mov player_data.speed,35	;速度
	.ELSEIF al==3
		mov player_data.hp,700
		mov player_data.maxhp,700
		mov player_data.phy_atk,400
		mov player_data.mag_atk,50
		mov player_data.phy_def,100	;物防
		mov player_data.mag_def,100	;魔防
		mov player_data.speed,90	;速度
	.ENDIF
	mov current_occu, al ; 1~7 體質 8~15職業技能 17 18通用
	.IF ah == 1
		.IF current_occu == 1
			add player_data.hp, 300
			add player_data.maxhp, 300
		.elseIF current_occu ==2
			add player_data.hp, 250
			add player_data.maxhp, 250
		.elseIF current_occu ==3
			add player_data.hp, 200
			add player_data.maxhp, 200
		.ENDIF
	.ELSEIF ah == 3
		.IF current_occu == 1
			add player_data.phy_atk, 40
		.elseIF current_occu ==2
			add player_data.phy_atk, 20
		.elseIF current_occu ==3
			add player_data.phy_atk, 50
		.ENDIF
	.ELSEIF ah == 4
		.IF current_occu == 1
			add player_data.mag_atk, 10
		.elseIF current_occu ==2
			add player_data.mag_atk, 40
		.elseIF current_occu ==3
			add player_data.mag_atk, 10
		.ENDIF
	.ELSEIF ah ==5
		.IF current_occu == 1
			add player_data.phy_def, 65
		.elseIF current_occu ==2
			add player_data.phy_def, 50
		.elseIF current_occu ==3
			add player_data.phy_def, 35
		.ENDIF
	.ELSEIF ah == 6
		.IF current_occu == 1
			add player_data.mag_def, 50
		.elseIF current_occu ==2
			add player_data.mag_def, 55
		.elseIF current_occu ==3
			add player_data.mag_def, 35
		.ENDIF
	.ELSEIF ah == 7
		.IF current_occu == 1
			add player_data.speed, 4
		.elseIF current_occu ==2
			add player_data.speed, 3
		.elseIF current_occu ==3
			add player_data.speed, 5
		.ENDIF
	.elseIF ah ==16
		mov player_data.skillCD_3, 0
	.ELSEIF ah == 15
		mov player_data.skillCD_2, 0
	.ELSEIF ah == 14
		mov player_data.skillCD_1, 0
	.ELSEIF ah ==13
		mov player_data.skillCD_3, 0
	.ELSEIF ah == 12
		mov player_data.skillCD_2, 0
	.ELSEIF ah == 11
		mov player_data.skillCD_1, 0
	.ELSEIF ah == 9
		mov player_data.skillCD_2, 0
	.ELSEIF ah == 8
		mov player_data.skillCD_1, 0
	.elseIF ah ==18
		mov player_data.gen_skillCD_2, 0
	.ELSEif ah == 17
		mov player_data.gen_skillCD_2, 0
	.ENDIF

new_round:
	mov bh, level
	add bh, 2
	INVOKE print_scene, bh
	INVOKE print_char, current_occu
	call load_boss

	fight:
		.IF player_data.skillCD_1 >0
			DEC player_data.skillCD_1
		.ENDIF
		.IF player_data.skillCD_2 >0
			dec player_data.skillCD_1
		.ENDIF
		.IF player_data.skillCD_2 >0
			dec player_data.skillCD_1
		.ENDIF
		call box_udate
		mov  eax, player_data.speed
		.IF boss_data.speed>eax ; boss first
			INVOKE boss_skill,
				offset damage,
				boss_data.phy_atk,
				boss_data.mag_atk,
				player_data.phy_def,
				player_data.mag_def
			.IF player_data.hp < eax  ;扣血
					mov player_data	.hp, 0
					mov al, 1
					jmp round_over
			.else
				sub player_data.hp, eax
				mov al, 0
			.ENDIF
			call Delay
			call movement
			mov eax, 0
			.IF boss_data.hp ==0
				mov al, 2
				jmp round_over
			.ELSE
				mov al, 0
			.ENDIF
		.elseIF boss_data.speed==eax ; player first
			call movement
			.IF boss_data.hp ==0
				mov al, 2
				jmp round_over
			.ELSE
				mov al, 0
			.ENDIF
			call Delay
			INVOKE boss_skill,
				offset damage,
				boss_data.phy_atk,
				boss_data.mag_atk,
				player_data.phy_def,
				player_data.mag_def
			.IF player_data.hp < eax  ;玩家死
				mov player_data.hp, 0
				mov al, 1
				jmp round_over
			.else
				sub player_data.hp, eax
				mov al, 0
			.ENDIF
		.elseIF boss_data.speed<eax ; player first
			call movement
			.IF boss_data.hp ==0
				mov al, 2
				jmp round_over
			.ELSE
				mov al, 0
			.ENDIF
			call Delay
			INVOKE boss_skill,
				offset damage,
				boss_data.phy_atk,
				boss_data.mag_atk,
				player_data.phy_def,
				player_data.mag_def
			.IF player_data.hp < eax  ;玩家死
				mov player_data.hp, 0
				mov al, 1
				jmp round_over
			.else
				sub player_data.hp, eax
				mov al, 0
			.ENDIF
		.ENDIF
round_over:
		inc round
		cmp dx,VK_ESCAPE  ; time to quit?
		je quit
		cmp al, 1 ;lose
		je lose
		cmp al, 2 ;win
		je win
		cmp al, 0 ;continue
		je fight

win:   ;win a round
	call box_udate
	inc level
	cmp level, 6
	mov round, 1
	call status_up
	mov dl, 83
	mov dh, 36
	call gotoxy
	mwrite<"You won!">
	mov dl, 83
	mov dh, 37
	call gotoxy
	call waitmsg
	call clrscr
	mov dl, 0
	mov dh, 0
	call gotoxy
	;INVOKE SETup, 1
	;call clrscr
	jne new_round
lose:
	call box_udate
	mov dl, 83
	mov dh, 36
	call gotoxy
	mwrite<"You lose!">
	call waitmsg
quit:
	ret
Battle ENDP

print_char PROC,
	char: BYTE
	;read charfile
		.IF char == 1
			mov   edx,OFFSET char1file
		.ELSEIF char ==2
			mov   edx,OFFSET char2file
		.ELSEIF char ==3
			mov   edx,OFFSET char3file
		.ENDIF
		call  OpenInputFile

		mov   edx,OFFSET buffer
		mov   ecx,BUFFER_SIZE
		call  ReadFromFile
	;insert null
		mov buffer[eax], 0
		mov ecx, 12
		mov ebx, 1
		mov edi, offset buffer

		mov dl, 0
		mov dh, 23
		call gotoxy
	;print character
	print_character:
		char_line:
			inc edi
			inc ebx
			mov eax, ebx
			mov esi, 25
			mov edx, 0
			div esi
			.IF edx == 0
					mov eax, Interval
					call Delay
			.ELSE
				mov al, [edi]
				call writechar
				jmp char_line
			.ENDIF
		loop print_character
	;close file
		mov   eax,fileHandle
		call  CloseFile
	ret
print_char endp

movement PROC

INVOKE GetTickCount
mov startTime,eax

LookForKey:
	INVOKE GetTickCount
	sub eax, startTime

	.IF eax > 1000
		.IF erase == 1
			.IF currentlocation == 1
				INVOKE Blink,1,1,3
			.ELSEIF currentlocation ==2
				INVOKE Blink,2,1,3
			.ELSEIF currentlocation ==3
				INVOKE Blink,3,1,3
			.ELSEIF currentlocation ==4
				INVOKE Blink,4,1,3
			.ELSEIF currentlocation ==5
				INVOKE Blink,5,1,3
			.ELSEIF currentlocation ==6
				INVOKE Blink,6,1,3
			.ENDIF
			mov erase, 0
		.ENDIF
		INVOKE GetTickCount
		mov startTime,eax
	.ELSEIF eax >500
		.IF erase == 0
			.IF currentlocation == 1
				INVOKE Blink,1,0,3
			.ELSEIF currentlocation ==2
				INVOKE Blink,2,0,3
			.ELSEIF currentlocation ==3
				INVOKE Blink,3,0,3
			.ELSEIF currentlocation ==4
				INVOKE Blink,4,0,3
			.ELSEIF currentlocation ==5
				INVOKE Blink,5,0,3
			.ELSEIF currentlocation ==6
				INVOKE Blink,6,0,3
			.ENDIF
			mov erase, 1
		.ENDIF
	.ENDIF

	mov  eax,50          ; sleep, to allow OS to time slice
	call Delay           ; (otherwise, some key presses are lost)
	call ReadKey

	.IF dx == 26h ;up
		INVOKE Blink,currentlocation,1,3
		.IF currentlocation ==2
			mov currentlocation, 1
		.ELSEIF currentlocation ==3
			mov currentlocation, 2
		.ELSEIF currentlocation ==4
			mov currentlocation, 3
		.ELSEIF currentlocation ==5
			mov currentlocation, 4
		.ELSEIF currentlocation ==6
			mov currentlocation, 5
		.ENDIF
		call box_udate
	.ELSEIF dx == 28h ; down
		INVOKE Blink,currentlocation,1,3
		.IF currentlocation ==1
			mov currentlocation, 2
		.ELSEIF currentlocation ==2
			mov currentlocation, 3
		.ELSEIF currentlocation ==3
			mov currentlocation, 4
		.ELSEIF currentlocation ==4
			mov currentlocation, 5
		.ELSEIF currentlocation ==5
			mov currentlocation, 6
		.ENDIF
		call box_udate
	.ENDIF
	compare:
		cmp    dx,VK_ESCAPE  ; time to quit?
		je quit
		cmp    dx,VK_RETURN  ; time to quit?
		mov dx, 0 ;clear
		jne    LookForKey
choose:
	.IF currentlocation == 1 ;普功
		INVOKE player_skill,ADDR damage,0, player_data.phy_atk,-4, player_data.mag_atk,
					boss_data.phy_def,boss_data.mag_def
		jmp quit
	.ELSEIF currentlocation == 2
		.IF player_data.skillCD_1 == 0
			.IF current_occu == 1
				INVOKE player_skill,ADDR damage,2, player_data.phy_atk,-4, player_data.mag_atk,
						boss_data.phy_def,boss_data.mag_def
					mov player_data.skillCD_1, 3 ;劍士技能1
			.elseIF current_occu ==2
				INVOKE player_skill,ADDR damage,-4, player_data.phy_atk,0, player_data.mag_atk,
						boss_data.phy_def,boss_data.mag_def
				mov player_data.skillCD_1, 2 ;法師技能1
			.elseIF current_occu ==3
				INVOKE player_skill,ADDR damage,3, player_data.phy_atk,-4, player_data.mag_atk,
					boss_data.phy_def,boss_data.mag_def
				mov player_data.skillCD_1, 4 ;弓箭手技能1
			.ENDIF
			jmp quit
		.ELSE
			jmp LookForKey
		.ENDIF
	.ELSEIF currentlocation == 3
		.IF player_data.skillCD_2 == 0
			.IF current_occu == 1
				INVOKE player_skill,ADDR damage,1,player_data.phy_atk,0, player_data.mag_atk,
						boss_data.phy_def,boss_data.mag_def

				mov player_data.skillCD_2, 4;劍士技能2
			.elseIF current_occu ==2
				INVOKE player_skill,ADDR damage,-4, player_data.phy_atk,0, player_data.mag_atk,
								boss_data.phy_def,boss_data.mag_def

				mov player_data.skillCD_2, 2;法師技能2
			.elseIF current_occu ==3
				INVOKE player_skill,ADDR damage,0,player_data.phy_atk,0,player_data.mag_atk,
						boss_data.phy_def,boss_data.mag_def

				mov player_data.skillCD_2, 2;弓箭手技能2
			.ENDIF
			jmp quit
		.ELSE
			jmp LookForKey
		.ENDIF
	.ELSEIF currentlocation == 4
		.IF player_data.skillCD_3 == 0
			.IF current_occu ==2
				INVOKE player_skill,ADDR damage,-4, player_data.phy_atk,0, player_data.mag_atk,
								boss_data.phy_def,boss_data.mag_def

				mov player_data.skillCD_3, 3;法師技能3
			.elseIF current_occu ==3
				INVOKE player_skill,ADDR damage,0,player_data.phy_atk,0,player_data.mag_atk,
						boss_data.phy_def,boss_data.mag_def

				mov player_data.skillCD_3, 3;弓箭手技能3
			.ELSE
				jmp LookForKey
			.ENDIF
			jmp quit
		.ELSE
			jmp LookForKey
		.ENDIF
	.ELSEIF currentlocation == 5
		.IF player_data.gen_skillCD_1 == 0
			mov first_strike, 1
			mov player_data.gen_skillCD_1, 2
			jmp quit
		.ELSE
			jmp LookForKey
		.ENDIF
	.ELSEIF currentlocation == 6
		.IF player_data.gen_skillCD_2 == 0
			INVOKE player_cure,player_data.maxhp,player_data.hp
			mov player_data.hp, eax
			mov player_data.cureCD, 2
			jmp quit
		.ELSE
			jmp LookForKey
		.ENDIF
	.ENDIF
quit:
	.IF boss_data.hp < eax
		mov boss_data.hp, 0
	.else
		sub boss_data.hp, eax
	.ENDIF
	mov eax, 0
	ret
movement endp


load_boss proc
	.IF level ==1
		mov boss_data.hp, 2000		;hp
		mov boss_data.maxhp,2000
		mov boss_data.phy_atk, 350		;物攻
		mov boss_data.mag_atk, 10		;魔攻
		mov boss_data.phy_def, 150		;物防
		mov boss_data.mag_def, 30		;魔防
		mov boss_data.speed, 30		;速度
	.ELSEIF level ==2
		mov boss_data.hp, 2500		;hp
		mov boss_data.maxhp, 2500
		mov boss_data.phy_atk, 300		;物攻
		mov boss_data.mag_atk, 300		;魔攻
		mov boss_data.phy_def, 100		;物防
		mov boss_data.mag_def, 250		;魔防
		mov boss_data.speed, 40		;速度
	.ELSEIF level ==3
		mov boss_data.hp, 3000		;hp
		mov boss_data.maxhp, 3000
		mov boss_data.phy_atk, 350		;物攻
		mov boss_data.mag_atk, 10		;魔攻
		mov boss_data.phy_def, 200		;物防
		mov boss_data.mag_def, 200		;魔防
		mov boss_data.speed, 30		;速度
	.ELSEIF level ==4
		mov boss_data.hp, 3000		;hp
		mov boss_data.maxhp, 3000
		mov boss_data.phy_atk, 550		;物攻
		mov boss_data.mag_atk, 400		;魔攻
		mov boss_data.phy_def, 200		;物防
		mov boss_data.mag_def, 350		;魔防
		mov boss_data.speed, 50		;速度
	.ELSEIF level ==5
		mov boss_data.hp, 6500		;hp
		mov boss_data.maxhp, 6500
		mov boss_data.phy_atk, 100		;物攻
		mov boss_data.mag_atk, 650		;魔攻
		mov boss_data.phy_def, 0		;物防
		mov boss_data.mag_def, 0		;魔防
		mov boss_data.speed, 100		;速度
	.ELSEIF level ==6
	.ELSEIF level ==7
	.ELSEIF level ==8
	.ELSEIF level ==9
	.ELSEIF level ==10
	.ENDIF

quit:
	ret
load_boss endp

box_udate PROC
;player skill
	mov dl, 29
	mov dh, 23
	call gotoxy
	mWrite<"Strike">
	.IF current_occu == 1;劍士
		mov dl, 29
		mov dh, 24
		call gotoxy
		mWrite<"Slam">

		mov dl, 29
		mov dh, 25
		call gotoxy
		mWrite<"Behead">

		mov dl, 29
		mov dh, 26
		call gotoxy
		mWrite<"None">
	.elseIF current_occu ==2 ;法師
		mov dl, 29
		mov dh, 24
		call gotoxy
		mWrite<"Black Art">

		mov dl, 29
		mov dh, 25
		call gotoxy
		mWrite<"Cure">

		mov dl, 29
		mov dh, 26
		call gotoxy
		mWrite<"Magic Barrier">
	.elseIF current_occu ==3;弓箭手
		mov dl, 29
		mov dh, 24
		call gotoxy
		mWrite<"Burst arrow">

		mov dl, 29
		mov dh, 25
		call gotoxy
		mWrite<"Magearrow">

		mov dl, 29
		mov dh, 26
		call gotoxy
		mWrite<"Dodge">
	.ENDIF
	mov dl, 29
	mov dh, 27
	call gotoxy
	mWrite<"Break Out">

	mov dl, 29
	mov dh, 28
	call gotoxy
	mWrite<"Fortitude">
;player status

	mov dl, 2
	mov dh, 12
	call gotoxy
	mWrite<"Phy_atk: ">
	mov eax, player_data.phy_atk
	call writedec

	inc dh
	call gotoxy
	mWrite<"Mag_atk: ">
	mov eax, player_data.mag_atk
	call writedec

	inc dh
	call gotoxy
	mWrite<"Phy_def: ">
	mov eax, player_data.phy_def
	call writedec

	inc dh
	call gotoxy
	mWrite<"Mag_def: ">
	mov eax, player_data.mag_def
	call writedec

	inc dh
	call gotoxy
	mWrite<"Speed: ">
	mov eax, player_data.speed
	call writedec
;move/skill hint
hint:
	mov dl, 1
	mov dh, 1
	call gotoxy
	mWrite<"Strike cause: ">
	INVOKE player_skill,ADDR damage,0, player_data.phy_atk,-4, player_data.mag_atk,
				boss_data.phy_def,boss_data.mag_def
	call writedec
	mWrite<" damage">
	mov dl, 1
	mov dh, 2
	call gotoxy
	mWrite<"Boss cause: ">
	INVOKE boss_skill,offset damage,boss_data.phy_atk,boss_data.mag_atk,
		player_data.phy_def, player_data.mag_def
	call writedec
	mWrite<" damage">

	.IF current_occu == 1;劍士
		mov dl, 1
		mov dh, 3
		call gotoxy
		.IF currentlocation == 1
			mWrite<"                                                ">
			inc dh
			call gotoxy
			mWrite<"                                                ">
			inc dh
			call gotoxy
			mWrite<"            ">
		.elseIF  currentlocation == 2
			mWrite<"Slam(initiative):150% phy damage                ">
			inc dh
			call gotoxy
			mWrite<"CD3   LV1">
			.IF player_data.skillCD_1 == -1
				inc dh
				call gotoxy
				mWrite<"Not acquired">
			.ELSE
				inc dh
				call gotoxy
				mWrite<"            ">
			.ENDIF
		.elseIF  currentlocation == 3
			mWrite<"Behead(initiative):125% phy+100%mag damage      ">
			inc dh
			call gotoxy
			mWrite<"CD4   LV1">
			.IF player_data.skillCD_2 == -1
				inc dh
				call gotoxy
				mWrite<"Not acquired">
			.ELSE
				inc dh
				call gotoxy
				mWrite<"            ">
			.ENDIF
		.elseIF  currentlocation == 4
			mWrite<"None                                            ">
			inc dh
			call gotoxy
			mWrite<"                                                ">
			inc dh
			call gotoxy
			mWrite<"            ">
		.elseIF  currentlocation == 5
			mWrite<"break out(initiative)：next round100% priority">
			inc dh
			call gotoxy
			mWrite<"CD3   LV1">
			.IF player_data.gen_skillCD_1 == -1
				inc dh
				call gotoxy
				mWrite<"Not acquired">
			.ELSE
				inc dh
				call gotoxy
				mWrite<"            ">
			.ENDIF
		.elseIF  currentlocation == 6
			mWrite<"Fortitude(passive)：3round hp+25%               ">
			inc dh
			call gotoxy
			mWrite<"      LV1">
			.IF player_data.gen_skillCD_2 == -1
				inc dh
				call gotoxy
				mWrite<"Not acquired">
			.ELSE
				inc dh
				call gotoxy
				mWrite<"            ">
			.ENDIF
		.ENDIF
	.elseIF current_occu ==2 ;法師
		mov dl, 1
		mov dh, 3
		call gotoxy
		.IF currentlocation == 1
			mWrite<"                                                ">
			inc dh
			call gotoxy
			mWrite<"                                                ">
			inc dh
			call gotoxy
			mWrite<"            ">
		.elseIF  currentlocation ==2
			mWrite<"Black Art(initiative):150%mag damage            ">
			inc dh
			call gotoxy
			mWrite<"CD2   LV1">
			.IF player_data.skillCD_1 == -1
				inc dh
				call gotoxy
				mWrite<"Not acquired">
			.ELSE
				inc dh
				call gotoxy
				mWrite<"            ">
			.ENDIF
		.elseIF  currentlocation == 3
			mWrite<"Cure(initiative):hp+25%                         ">
			inc dh
			call gotoxy
			mWrite<"CD2   LV1">
			.IF player_data.skillCD_2 == -1
				inc dh
				call gotoxy
				mWrite<"Not acquired">
			.ELSE
				inc dh
				call gotoxy
				mWrite<"            ">
			.ENDIF
		.elseIF  currentlocation == 4
			mWrite<"Magic Barrier(passive):mag def+25%              ">
			inc dh
			call gotoxy
			mWrite<"CD3   LV1">
			.IF player_data.skillCD_3 == -1
				inc dh
				call gotoxy
				mWrite<"Not acquired">
			.ELSE
				inc dh
				call gotoxy
				mWrite<"            ">
			.ENDIF
		.elseIF  currentlocation == 5
			mWrite<"break out(initiative)：next round100% priority">
			inc dh
			call gotoxy
			mWrite<"CD3   LV1">
			.IF player_data.gen_skillCD_1 == -1
				inc dh
				call gotoxy
				mWrite<"Not acquired">
			.ELSE
				inc dh
				call gotoxy
				mWrite<"            ">
			.ENDIF
		.elseIF  currentlocation == 6
			mWrite<"Fortitude(passive)：3round hp+25%               ">
			inc dh
			call gotoxy
			mWrite<"      LV1">
			.IF player_data.gen_skillCD_1 == -1
				inc dh
				call gotoxy
				mWrite<"Not acquired">
			.ELSE
				inc dh
				call gotoxy
				mWrite<"            ">
			.ENDIF
		.ENDIF
	.elseIF current_occu ==3;弓箭手
		mov dl, 1
		mov dh, 3
		call gotoxy
		.IF currentlocation == 1
			mWrite<"                                                ">
			inc dh
			call gotoxy
			mWrite<"                                                ">
			inc dh
			call gotoxy
			mWrite<"            ">
		.elseIF  currentlocation == 2
			mWrite<"Burst Arrow(initiative):175% phy damage">
			inc dh
			call gotoxy
			mWrite<"CD4   LV1">
			.IF player_data.skillCD_1 == -1
				inc dh
				call gotoxy
				mWrite<"Not acquired">
			.ELSE
				inc dh
				call gotoxy
				mWrite<"            ">
			.ENDIF
		.elseIF  currentlocation == 3
			mWrite<"Magearrow(initiative):100% phy+100%mag damage   ">
			inc dh
			call gotoxy
			mWrite<"CD2   LV1">
			.IF player_data.skillCD_2 == -1
				inc dh
				call gotoxy
				mWrite<"Not acquired">
			.ELSE
				inc dh
				call gotoxy
				mWrite<"            ">
			.ENDIF
		.elseIF  currentlocation == 4
			mWrite<"Dodge(initiative):100%	Dodge next atk          ">
			inc dh
			call gotoxy
			mWrite<"CD3   LV1">
			.IF player_data.skillCD_3 == -1
				inc dh
				call gotoxy
				mWrite<"Not acquired">
			.ELSE
				inc dh
				call gotoxy
				mWrite<"            ">
			.ENDIF
		.elseIF  currentlocation == 5
			mWrite<"break out(initiative)：next round100% priority">
			inc dh
			call gotoxy
			mWrite<"CD3   LV1">
			.IF player_data.gen_skillCD_1 == -1
				inc dh
				call gotoxy
				mWrite<"Not acquired">
			.ELSE
				inc dh
				call gotoxy
				mWrite<"            ">
			.ENDIF
		.elseIF  currentlocation == 6
			mWrite<"Fortitude(passive)：3round hp+25%               ">
			inc dh
			call gotoxy
			mWrite<"      LV1">
			.IF player_data.gen_skillCD_2 == -1
				inc dh
				call gotoxy
				mWrite<"Not acquired">
			.ELSE
				inc dh
				call gotoxy
				mWrite<"            ">
			.ENDIF
		.ENDIF
	.ENDIF

;level info
	mov dl, 84
	mov dh, 34
	call gotoxy
	mov al, level
	mWrite<"Level  ">
	call writedec

	inc dh
	call gotoxy
	mWrite<"Round  ">
	mov al, round
	call writedec

	mov dl, 1
	mov dh, 36
	call gotoxy
	mov eax, player_data.hp
	mWrite <"    ">

	mov dl, 1
	mov dh, 36
	call gotoxy
	mov eax, player_data.hp
	call writedec

	mov dl, 6
	mov dh, 36
	call gotoxy
	mov eax, player_data.hp
	mWrite <"    ">

	mov dl, 6
	mov dh, 36
	call gotoxy
	mov eax, player_data.maxhp
	call writedec
;boss
	mov dl, 83
	mov dh, 28
	call gotoxy
	mov eax, boss_data.hp
	mWrite <"    ">

	mov dl, 83
	mov dh, 28
	call gotoxy
	mov eax, boss_data.hp
	call writedec

	mov dl, 89
	mov dh, 28
	call gotoxy
	mov eax, boss_data.maxhp
	call writedec

	mov dl, 100
	mov dh, 25
	call gotoxy
	mWrite<"Phy_atk: ">
	mov eax, boss_data.phy_atk
	call writedec

	inc dh
	call gotoxy
	mWrite<"Mag_atk: ">
	mov eax, boss_data.mag_atk
	call writedec

	inc dh
	call gotoxy
	mWrite<"Phy_def: ">
	mov eax, boss_data.phy_def
	call writedec

	inc dh
	call gotoxy
	mWrite<"Mag_def: ">
	mov eax, boss_data.mag_def
	call writedec

	inc dh
	call gotoxy
	mWrite<"Speed: ">
	mov eax, boss_data.speed
	call writedec

quit:
	ret
box_udate endp

status_up PROC
	.IF current_occu ==1
	add player_data.maxHP, 300
		mov eax, player_data.maxHP
		mov player_data.HP, eax
		add player_data.phy_atk, 40
		add player_data.mag_atk, 10
		add player_data.phy_def, 65
		add player_data.mag_def, 50
		add player_data.speed, 4
	.elseIF current_occu ==2
		add player_data.maxHP, 250
		mov eax, player_data.maxHP
		mov player_data.HP, eax
		add player_data.phy_atk, 20
		add player_data.mag_atk, 40
		add player_data.phy_def, 50
		add player_data.mag_def, 55
		add player_data.speed, 3
	.ELSEIF current_occu ==3
		add player_data.maxHP, 200
		mov eax, player_data.maxHP
		mov player_data.HP, eax
		add player_data.phy_atk, 50
		add player_data.mag_atk, 40
		add player_data.phy_def, 35
		add player_data.mag_def, 35
		add player_data.speed, 5
	.ENDIF
	ret
status_up endp
END

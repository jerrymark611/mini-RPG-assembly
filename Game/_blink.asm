INCLUDE project.inc
INCLUDE macros.inc

coor struct
	x byte ?
	y byte ?
coor ends
.data
	leftlocation byte 15,29, 16,29, 16,30, 17,30, 17,31, 18,31,   18,32, 19,32   ,15,35, 16,35, 16,34, 17,34, 17,33, 18,33
	rightlocation byte 76,29, 77,29, 77,30, 78,30, 78,31, 79,31,   79,32, 80,32   ,76,35, 77,35, 77,34, 78,34, 78,33, 79,33
	skilllocation coor <>
								coor <11,0>,<21,0>,<31,0>,<43,0>,<55,0>,<68,0>,<80,0>
								coor <6,6>,<6,8>,<6,10>,<6,14>,<6,16>,<6,18>,<6,22>,<6,24>,<6,26>
								coor <6,30>,<6,32>,<6,34>,<6,36>,<6,38>

.code
Blink PROC,
	location : BYTE,
	clear :BYTE,
	status :BYTE ;(0 for title, 1 for occupation choosing 2 for skill choosing, 3 for battle)
	.IF status ==0
		.IF clear == 1 ;erase
				mov ecx, 14
				.IF location == 1 ;erase location arrow
					mov esi, offset leftlocation
				.ELSEIF location ==0 ;right arrow
					mov esi, offset rightlocation
					jmp clean_right
				.ENDIF
				clean_location:
					mov dl, [esi]
					inc esi
					mov dh, [esi]
					inc esi
					call Gotoxy
					mWrite<" ">
					loop clean_location
					jmp bye
				clean_right:
					mov dl, [esi]
					inc esi
					mov dh, [esi]
					inc esi
					inc edi
					call Gotoxy
					mWrite<" ">
					loop clean_right
		.ELSEIF clear == 0
				mov ecx, 14
				mov edi, 0
				.IF location == 1
					mov esi, offset leftlocation
					write_location:
						.IF edi < 6;upper
							mov dl,   [esi]
							inc  esi
							mov dh,   [esi]
							inc  esi
							inc edi
							call Gotoxy
							mWrite<"\">
							jmp write_location
						.ELSEIF edi == 6;middle
							mov dl, [esi]
							inc esi
							mov dh, [esi]
							inc esi
							inc edi
							call Gotoxy
							mWrite<"|">
							jmp write_location
						.ELSEIF edi == 7;middle
							mov dl, [esi]
							inc esi
							mov dh, [esi]
							inc esi
							inc edi
							call Gotoxy
							mWrite<">">
							jmp write_location
						.ELSEIF EDI > 7;lower
							.IF  EDI < 14
								mov dl, [esi]
								inc  esi
								mov dh, [esi]
								inc  esi
								inc edi
								call Gotoxy
								mWrite<"/">
								jmp write_location
							.ENDIF
						.ENDIF
				.ELSEIF;right arrow
						mov esi, offset rightlocation
						write_right:
							.IF edi < 6;upper
								mov dl, [esi]
								inc  esi
								mov dh, [esi]
								inc  esi
								inc edi
								call Gotoxy
								mWrite<"\">
								jmp write_right
							.ELSEIF edi == 6;middle
								mov dl, [esi]
								inc esi
								mov dh, [esi]
								inc esi
								inc edi
								call Gotoxy
								mWrite<"|">
								jmp write_right
							.ELSEIF edi == 7;middle
								mov dl, [esi]
								inc esi
								mov dh, [esi]
								inc esi
								inc edi
								call Gotoxy
								mWrite<">">
								jmp write_right
							.ELSEIF EDI > 7;lower
								.IF  EDI < 14
									mov dl, [esi]
									inc  esi
									mov dh, [esi]
									inc  esi
									inc edi
									call Gotoxy
									mWrite<"/">
									jmp write_right
							.ENDIF
						.ENDIF
				.ENDIF
		.ENDIF
	.ELSEIF status == 1
		.IF clear == 1
			.IF location ==0 ;up
				mov dl, 5
				mov dh, 7
				call Gotoxy
				mWrite<"  ">
			.ELSEIF location ==1 ;mid
				mov dl, 5
				mov dh, 22
				call Gotoxy
				mWrite<"  ">
			.ELSEIF location ==2 ;down
				mov dl, 5
				mov dh, 37
				call Gotoxy
				mWrite<"  ">
			.ENDIF
		.ELSEIF clear ==0
			.IF location ==0 ;up
				mov dl, 5
				mov dh, 7
				call Gotoxy
				mWrite<">>">
			.ELSEIF location ==1 ;mid
				mov dl, 5
				mov dh, 22
				call Gotoxy
				mWrite<">>">
			.ELSEIF location ==2 ;down
				mov dl, 5
				mov dh, 37
				call Gotoxy
				mWrite<">>">
			.ENDIF
		.ENDIF
	.ELSEIF status ==2
		.IF clear == 1
			.IF location == 1
				mov dl, 14
				mov dh, 0
			.ELSEIF location ==2
				mov dl, 23
				mov dh, 0
			.ELSEIF location ==3
				mov dl, 32
				mov dh, 0
			.ELSEIF location ==4
				mov dl, 46
				mov dh, 0
			.ELSEIF location ==5
				mov dl, 61
				mov dh, 0
			.ELSEIF location ==6
				mov dl, 75
				mov dh, 0
			.ELSEIF location ==7
				mov dl, 89
				mov dh, 0
			.ELSEIF location ==8
				mov dl, 6
				mov dh, 6
			.ELSEIF location ==9
				mov dl, 6
				mov dh, 8
			.ELSEIF location ==11
				mov dl, 6
				mov dh, 14
			.ELSEIF location ==12
				mov dl, 6
				mov dh, 16
			.ELSEIF location ==13
				mov dl, 6
				mov dh, 18
			.ELSEIF location ==14
				mov dl, 6
				mov dh, 22
			.ELSEIF location ==15
				mov dl, 6
				mov dh, 24
			.ELSEIF location ==16
				mov dl, 6
				mov dh, 26
			.ELSEIF location ==17
				mov dl, 6
				mov dh, 30
			.ELSEIF location ==18
				mov dl, 6
				mov dh, 32
			.ENDIF
			call Gotoxy
			mWrite<"  ">
		.ELSEIF clear ==0
			.IF location == 1
				mov dl, 14
				mov dh, 0
			.ELSEIF location ==2
				mov dl, 23
				mov dh, 0
			.ELSEIF location ==3
				mov dl, 32
				mov dh, 0
			.ELSEIF location ==4
				mov dl, 46
				mov dh, 0
			.ELSEIF location ==5
				mov dl, 61
				mov dh, 0
			.ELSEIF location ==6
				mov dl, 75
				mov dh, 0
			.ELSEIF location ==7
				mov dl, 89
				mov dh, 0
			.ELSEIF location ==8
				mov dl, 6
				mov dh, 6
			.ELSEIF location ==9
				mov dl, 6
				mov dh, 8
			.ELSEIF location ==11
				mov dl, 6
				mov dh, 14
			.ELSEIF location ==12
				mov dl, 6
				mov dh, 16
			.ELSEIF location ==13
				mov dl, 6
				mov dh, 18
			.ELSEIF location ==14
				mov dl, 6
				mov dh, 22
			.ELSEIF location ==15
				mov dl, 6
				mov dh, 24
			.ELSEIF location ==16
				mov dl, 6
				mov dh, 26
			.ELSEIF location ==17
				mov dl, 6
				mov dh, 30
			.ELSEIF location ==18
				mov dl, 6
				mov dh, 32
			.ENDIF
			call Gotoxy
			mWrite<">>">
		.ENDIF
	.ELSEIF status ==3
		.IF clear == 1
			.IF location == 1
				mov dl, 26
				mov dh, 23
			.ELSEIF location ==2
				mov dl, 26
				mov dh, 24
			.ELSEIF location ==3
				mov dl, 26
				mov dh, 25
			.ELSEIF location ==4
				mov dl, 26
				mov dh, 26
			.ELSEIF location ==5
				mov dl, 26
				mov dh, 27
			.ELSEIF location ==6
				mov dl, 26
				mov dh, 28
			.ENDIF
			call Gotoxy
			mWrite<"  ">
		.ELSEIF clear ==0
			.IF location == 1
				mov dl, 26
				mov dh, 23
			.ELSEIF location ==2
				mov dl, 26
				mov dh, 24
			.ELSEIF location ==3
				mov dl, 26
				mov dh, 25
			.ELSEIF location ==4
				mov dl, 26
				mov dh, 26
			.ELSEIF location ==5
				mov dl, 26
				mov dh, 27
			.ELSEIF location ==6
				mov dl, 26
				mov dh, 28
			.ENDIF
			call Gotoxy
			mWrite<">>">
		.ENDIF
	.ENDIF
bye:
	ret
blink ENDP

END

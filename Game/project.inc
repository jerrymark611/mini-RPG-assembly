INCLUDE irvine32.inc

Arrow PROTO

Blink PROTO,
	left:BYTE,
	clear:BYTE,
	status :BYTE ;(0 for title, 1 for skill choosing, 2 for battle)	
Setup PROTO, rea:byte
Battle PROTO
print_scene proto, bat: BYTE
boss_skill PRoto ,
	damage:PTR DWORD,
	phy_atk:DWORD,
	mag_atk:DWORD,
	p_phy_def:DWORD,
	p_mag_def:DWORD
player_skill proto,
	damage:PTR DWORD,
	phy_rate:BYTE,
	phy_atk:DWORD,
	mag_rate:BYTE,
	mag_atk:DWORD,
	b_phy_def:DWORD,
	b_mag_def:DWORD
player_cure proto,
	p_maxhp:DWORD,
	now_hp:DWORD
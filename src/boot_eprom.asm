; z80dasm 1.1.3
; command line: z80dasm -atl -b boot_eprom.blk -g 0x8000 -o boot_eprom.asm boot_eprom.bin

	org	08000h

l8000h:
	ld sp,00002h		;8000	31 02 00 
l8003h:
	push af			;8003	f5 	
	ld iy,00000h		;8004	fd 21 00 00
	add iy,sp		;8008	fd 39 
	ld a,0fch		;800a	3e fc      Select PROM memory
	out (0a2h),a		;800c	d3 a2      Map PROM into 3rd memory page (0x8000)
	jp l8011h		;800e	c3 11 80
l8011h:
	di			;8011	f3 
l8012h:
	ld a,028h		;8012	3e 28           Blank display | Acquire mode 
	out (0f8h),a		;8014	d3 f8           Set IOC register 	
	xor a			;8016	af 
l8017h:
	ex (sp),hl		;8017	e3 	
	djnz l8017h		;8018	10 fd           Weird loop here? 
	dec a			;801a	3d 	 
	jr nz,l8017h		;801b	20 fa           Loop on 256 values. Delay?? 	
	ld bc,00fa0h		;801d	01 a0 0f          	
	ld a,03fh		;8020	3e 3f           3F (00111111): 
                                                        ;Change all-caps  	
                                                        ;Remove Acquire mode
                                                        ;Keyboard reset
                                                        ;Blank display
	out (0f8h),a		;8022	d3 f8           Set IOC register	
l8024h:
	in a,(0e0h)		;8024	db e0           Read SR1
	and 008h		;8026	e6 08           Check NMI 
	jr nz,l8012h		;8028	20 e8           Repeat if no NMI
	dec bc			;802a	0b 	 
	ld a,b			;802b	78 	 
	or c			;802c	b1 	         
	jr nz,l8024h		;802d	20 f5 	        Try 4000 (0x0fa0) times 
	out (0c0h),a		;802f	d3 c0 	        Undocumented port
	in a,(073h)		;8031	db 73 	        Read Board 3 ID
	and 0f8h		;8033	e6 f8 	
	sub 0e8h		;8035	d6 e8           Zero with %11101xxx Ids
                                                        ;May be some internal design
                                                        ;It doesn't match any known board
	ld b,a			;8037	47 
	jr nz,l8054h		;8038	20 1a           With serial board in 
                                                        ;slot 3, jump to 8054h
;-------------------------------------------------------
;This code seems to be
;for an unknown board. ID: 11101xxx (0xE80 - 0xEF)
 
	ld a,07eh		;803a	3e 7e
	ld hl,l814dh		;803c	21 4d 81 	
	ld bc,00331h		;803f	01 31 03 	
	otir	        	;8042	ed b3 	        Out 0x80, 0x80, 0x40 
                                                        ;to IO=0x31
	out (038h),a		;8044	d3 38 	        Baud rate register?   
	ld a,0ceh		;8046	3e ce 	 
	out (031h),a		;8048	d3 31 	        USART command? 
	ld a,037h		;804a	3e 37 	 
	out (031h),a		;804c	d3 31 	        Undocumented? 
l804eh:
	djnz l804eh		;804e	10 fe 	
	in a,(030h)		;8050	db 30 	
	in a,(030h)		;8052	db 30 
        ;------------------------------------------------------
l8054h:
	in a,(083h)		;8054	db 83 	WTF! Actually an out register
	ld hl,00000h		;8056	21 00 00 	
	add hl,sp		;8059	39 	
	ld a,h			;805a	7c 	 
	or l			;805b	b5 	 SP == 0? 
	jp nz,l815eh		;805c	c2 5e 81 
	jp l8fe0h		;805f	c3 e0 8f 
	nop			;8062	00 	 
	nop			;8063	00 	 
	nop			;8064	00 	 
	nop			;8065	00 	 
	nop			;8066	00 	 
	nop			;8067	00 	 
	nop			;8068	00 	
	jr l8003h		;8069	18 98 	. . 
sub_806bh:
	cp 00bh		;806b	fe 0b 	. . 
	ret nc			;806d	d0 	. 
	ld d,a			;806e	57 	W 
l806fh:
    #include <sys/types.h>
	     #include <sys/uio.h>
	     #include <unistd.h>
	call sub_8078h		;806f	cd 78 80 	. x . 
	ret nc			;8072	d0 	. 
	cp d			;8073	ba 	. 
	jr nz,l806fh		;8074	20 f9 	  . 
	scf			;8076	37 	7 
	ret			;8077	c9 	. 
sub_8078h:
	ld b,020h		;8078	06 20 	.   
l807ah:
	dec bc			;807a	0b 	. 
	ld a,b			;807b	78 	x 
	or c			;807c	b1 	. 
	ret z			;807d	c8 	. 
	in a,(0e0h)		;807e	db e0 	. . 
	and 040h		;8080	e6 40 	. @ 
	jr z,l807ah		;8082	28 f6 	( . 
	ld b,020h		;8084	06 20 	.   
l8086h:
	dec bc			;8086	0b 	. 
	ld a,b			;8087	78 	x 
	or c			;8088	b1 	. 
	ret z			;8089	c8 	. 
	in a,(0e0h)		;808a	db e0 	. . 
	and 040h		;808c	e6 40 	. @ 
	jr nz,l8086h		;808e	20 f6 	  . 
	in a,(0d0h)		;8090	db d0 	. . 
	and 00fh		;8092	e6 0f 	. . 
	scf			;8094	37 	7 
	ret			;8095	c9 	. 
sub_8096h:
	ld b,00ah		;8096	06 0a 	. . 
l8098h:
	ld a,0a0h		;8098	3e a0 	> . 
	call sub_80b5h		;809a	cd b5 80 	. . . 
	in a,(0e0h)		;809d	db e0 	. . 
	and 020h		;809f	e6 20 	.   
	jr z,l80a6h		;80a1	28 03 	( . 
	djnz l8098h		;80a3	10 f3 	. . 
	ret			;80a5	c9 	. 
l80a6h:
	ld b,028h		;80a6	06 28 	. ( 
l80a8h:
	ld a,080h		;80a8	3e 80 	> . 
	call sub_80b5h		;80aa	cd b5 80 	. . . 
	in a,(0e0h)		;80ad	db e0 	. . 
	and 020h		;80af	e6 20 	.   
	ret nz			;80b1	c0 	. 
	djnz l80a8h		;80b2	10 f4 	. . 
	ret			;80b4	c9 	. 
sub_80b5h:
	exx			;80b5	d9 	. 
	or c			;80b6	b1 	. 
	exx			;80b7	d9 	. 
	out (081h),a		;80b8	d3 81 	. . 
	or 010h		;80ba	f6 10 	. . 
	out (081h),a		;80bc	d3 81 	. . 
	xor 010h		;80be	ee 10 	. . 
	out (081h),a		;80c0	d3 81 	. . 
	ld a,028h		;80c2	3e 28 	> ( 

; Delay routine, loops 250 * A times
delay:
	ld c,0fah		;80c4	0e fa 	
l80c6h:
	dec c			;80c6	0d 	 
	jr nz,l80c6h		;80c7	20 fd 	 
	dec a			;80c9	3d 	 
	jr nz,delay	;80ca	20 f8 	 
	ret			;80cc	c9 	 

sub_80cdh:
	ld hl,003fdh		;80cd	21 fd 03 	! . . 
l80d0h:
	in a,(0e0h)		;80d0	db e0 	. . 
	and 040h		;80d2	e6 40 	. @ 
	jr nz,l80d0h		;80d4	20 fa 	  . 
l80d6h:
	in a,(0e0h)		;80d6	db e0 	. . 
	and 040h		;80d8	e6 40 	. @ 
	jr z,l80d6h		;80da	28 fa 	( . 
	ld a,064h		;80dc	3e 64 	> d 
l80deh:
	dec a			;80de	3d 	= 
	jr nz,l80deh		;80df	20 fd 	  . 
	ld a,015h		;80e1	3e 15 	> . 
	out (0f8h),a		;80e3	d3 f8 	. . 
	out (082h),a		;80e5	d3 82 	. . 
	ld a,018h		;80e7	3e 18 	> . 
l80e9h:
	dec a			;80e9	3d 	= 
	jr nz,l80e9h		;80ea	20 fd 	  . 
	ld a,01dh		;80ec	3e 1d 	> . 
	out (0f8h),a		;80ee	d3 f8 	. . 
	ld a,b			;80f0	78 	x 
	ld bc,064e0h		;80f1	01 e0 64 	. . d 
l80f4h:
	defb 0edh;next byte illegal after ed		;80f4	ed 	. 
	ld (hl),b			;80f5	70 	p 
	jp m,l80fdh		;80f6	fa fd 80 	. . . 
	djnz l80f4h		;80f9	10 f9 	. . 
	jr l810ah		;80fb	18 0d 	. . 
l80fdh:
	ld b,a			;80fd	47 	G 
	in a,(081h)		;80fe	db 81 	. . 
	cp 0fbh		;8100	fe fb 	. . 
	jr nz,l810ah		;8102	20 06 	  . 
	in a,(080h)		;8104	db 80 	. . 
	ld c,000h		;8106	0e 00 	. . 
	or a			;8108	b7 	. 
	ret			;8109	c9 	. 
l810ah:
	scf			;810a	37 	7 
	ret			;810b	c9 	. 
l810ch:
	in a,(080h)		;810c	db 80 	. . 
	ld (de),a			;810e	12 	. 
	xor c			;810f	a9 	. 
	rlca			;8110	07 	. 
	ld c,a			;8111	4f 	O 
	inc de			;8112	13 	. 
	in a,(080h)		;8113	db 80 	. . 
	ld (de),a			;8115	12 	. 
	xor c			;8116	a9 	. 
	rlca			;8117	07 	. 
	ld c,a			;8118	4f 	O 
	inc de			;8119	13 	. 
	djnz l810ch		;811a	10 f0 	. . 
	ret			;811c	c9 	. 
sub_811dh:
	ld b,004h		;811d	06 04 	. . 
l811fh:
	out (082h),a		;811f	d3 82 	. . 
	ld a,07dh		;8121	3e 7d 	> } 
	call delay		;8123	cd c4 80 	. . . 
	in a,(082h)		;8126	db 82 	. . 
	ld a,07dh		;8128	3e 7d 	> } 
	call delay	;812a	cd c4 80 	. . . 
	djnz l811fh		;812d	10 f0 	. . 
	ret			;812f	c9 	. 

; Executes a command through the IOCR
; A: Holds the command to execute
iocr_exec:
	push af			;8130	f5 	 
	in a,(0d0h)		;8131	db d0 	Read Status Register 2
	and 080h		;8133	e6 80   Mask Complement Acknowledge	
	ld b,a			;8135	47 	Store in b 
	pop af			;8136	f1 	 
	out (0f8h),a		;8137	d3 f8 	Send command
l8139h:
	in a,(0d0h)		;8139	db d0 	Read Status Register 2
	and 080h		;813b	e6 80 	Mask complement acknowledge
	xor b			;813d	a8 	Compare with last result 
	jr z,l8139h		;813e	28 f9 	Wait for the command to execute
	ret			;8140	c9 	 

; BLOCK 'start_message' (start 0x8141 end 0x814c)
system_start_msg:
	defb 04ch		;8141	4c 	L 
	defb 04fh		;8142	4f 	O 
	defb 041h		;8143	41 	A 
	defb 044h		;8144	44 	D 
	defb 020h		;8145	20 	  
	defb 053h		;8146	53 	S 
	defb 059h		;8147	59 	Y 
	defb 053h		;8148	53 	S 
	defb 054h		;8149	54 	T 
	defb 045h		;814a	45 	E 
	defb 04dh		;814b	4d 	M 
start_message_end:
	nop			;814c	00 	. 
l814dh:
	add a,b			;814d	80 	. 
	add a,b			;814e	80 	. 
	ld b,b			;814f	40 	@ 
	inc c			;8150	0c 	. 
	djnz l8169h		;8151	10 16 	. . 
	or a			;8153	b7 	. 
	djnz $+24		;8154	10 16 	. . 
	dec b			;8156	05 	. 
	rst 38h			;8157	ff 	. 
	djnz $+24		;8158	10 16 	. . 
	inc b			;815a	04 	. 
	ld bc,0ff05h		;815b	01 05 ff 	. . . 

l815eh:
	ld a,080h		;815e	3e 80 	 
	out (0a0h),a		;8160	d3 a0 	Load screen (low) in page 0 
	ld a,081h		;8162	3e 81 	 
	out (0a1h),a		;8164	d3 a1 	Load screen (high) in page 1 
	ld sp,00200h		;8166	31 00 02 Stack pointer points to screen now 
l8169h:
	ld a,b			;8169	78 	 
	ld (002fdh),a		;816a	32 fd 02 	
	ld a,000h		;816d	3e 00 	
	out (0a3h),a		;816f	d3 a3   Low 16 Kbytes to page 3
	out (090h),a		;8171	d3 90   Start Scan register to zero
	out (0b0h),a		;8173	d3 b0   Clear display
	jr z,l8180h		;8175	28 09   IMPORTANT: Where is this flag set? 
	call video_init		;8177	cd c7 83
	ld hl,system_start_msg	;817a	21 41 81
	call puts		;817d	cd a5 8c
l8180h:
	ld a,018h		;8180	3e 18
	out (0f8h),a		;8182	d3 f8   Set IOCR <- 00011000
                                                ; xxx1xxxx -> Remove I/O reset 
                                                ; xxxx1xxx -> Remove Acquire mode
get_action:
	call line_feed		;8184	cd b2 83 
	ld hl,l81a6h		;8187	21 a6 81
	push hl			;818a	e5      Probably return address for subsequent jumps
	call get_char_echo	;818b	cd 78 8a
	cp 04eh		        ;818e	fe 4e 
	jp z,l83ebh		;8190	ca eb 83 If character = 'N'
	cp 044h		        ;8193	fe 44
	jr z,l81beh		;8195	28 27    If character = 'D'
	cp 053h		        ;8197	fe 53
	jp z,l8235h		;8199	ca 35 82 If character = 'S'
	cp 001h		        ;819c	fe 01 
	jp z,l8000h		;819e	ca 00 80 If character = \001  Enter?
	sub 00dh		;81a1	d6 0d
	jr z,l81bbh		;81a3	28 16
	ret			;81a5	c9

l81a6h:
	ld b,03fh		;81a6	06 3f 	. ? 
	call emit_char		;81a8	cd 7f 8a 	.  . 
l81abh:
	call line_feed		;81ab	cd b2 83 	. . . 
	ld hl,system_start_msg	;81ae	21 41 81 	! A . 
	call puts		;81b1	cd a5 8c 	. . . 
	ld a,002h		;81b4	3e 02 	> . 
	call delay	        ;81b6	cd c4 80 	. . . 
	jr get_action		;81b9	18 c9 	. . 
l81bbh:
	inc a			;81bb	3c 	< 
	jr l81cfh		;81bc	18 11 	. . 
l81beh:
	call get_char_echo	;81be	cd 78 8a
	cp 031h		        ;81c1	fe 31   Compare read char with '1' 
	ret c			;81c3	d8 	If lower return.
	cp 035h		        ;81c4	fe 35 	Compare with '5'
	ret nc			;81c6	d0 	If higher return 
	sub 030h		;81c7	d6 30 	Convert to decimal
	ld b,a			;81c9	47 	 
	xor a			;81ca	af 	 
	scf			;81cb	37 	Set carry flag 
l81cch:
	rla			;81cc	17 	. 
	djnz l81cch		;81cd	10 fd 	Set a bit in A with the driver unit 
                                                ; 00000001 Drive 1
                                                ; 00000010 Drive 2
l81cfh:
	exx			;81cf	d9 	. 
	ld c,a			;81d0	4f 	O 
	exx			;81d1	d9 	. 
	ld a,01dh		;81d2	3e 1d 	> . 
	out (0f8h),a		;81d4	d3 f8 	. . 
	ld a,002h		;81d6	3e 02 	> . 
	out (060h),a		;81d8	d3 60 	. ` 
	call sub_8096h		;81da	cd 96 80 	. . . 
	ret z			;81dd	c8 	. 
	call sub_811dh		;81de	cd 1d 81 	. . . 
	exx			;81e1	d9 	. 
	ld b,028h		;81e2	06 28 	. ( 
	exx			;81e4	d9 	. 
l81e5h:
	in a,(082h)		;81e5	db 82 	. . 
	exx			;81e7	d9 	. 
	dec b			;81e8	05 	. 
	exx			;81e9	d9 	. 
	ret z			;81ea	c8 	. 
	ld a,003h		;81eb	3e 03 	> . 
	call sub_806bh		;81ed	cd 6b 80 	. k . 
	ret nc			;81f0	d0 	. 
	ld a,004h		;81f1	3e 04 	> . 
	ex af,af'			;81f3	08 	. 
	ld e,000h		;81f4	1e 00 	. . 
	ld b,0ffh		;81f6	06 ff 	. . 
	call sub_80cdh		;81f8	cd cd 80 	. . . 
	jr c,l81e5h		;81fb	38 e8 	8 . 
	in a,(080h)		;81fd	db 80 	. . 
	cp 0c0h		;81ff	fe c0 	. . 
	ret c			;8201	d8 	. 
	cp 0f9h		;8202	fe f9 	. . 
	ret nc			;8204	d0 	. 
	ld d,a			;8205	57 	W 
	ld (de),a			;8206	12 	. 
	inc de			;8207	13 	. 
	rlca			;8208	07 	. 
	ld c,a			;8209	4f 	O 
	in a,(080h)		;820a	db 80 	. . 
	ld (de),a			;820c	12 	. 
	inc de			;820d	13 	. 
	xor c			;820e	a9 	. 
	rlca			;820f	07 	. 
	ld c,a			;8210	4f 	O 
l8211h:
	call l810ch		;8211	cd 0c 81 	. . . 
	in a,(080h)		;8214	db 80 	. . 
	xor c			;8216	a9 	. 
	in a,(082h)		;8217	db 82 	. . 
	jr nz,l81e5h		;8219	20 ca 	  . 
	ex af,af'			;821b	08 	. 
	dec a			;821c	3d 	= 
	jr z,l8227h		;821d	28 08 	( . 
	ex af,af'			;821f	08 	. 
	call sub_80cdh		;8220	cd cd 80 	. . . 
	jr c,l81e5h		;8223	38 c0 	8 . 
	jr l8211h		;8225	18 ea 	. . 
l8227h:
	ld hl,0f80ah		;8227	21 0a f8 	! . . 
	add hl,de			;822a	19 	. 
	ld a,(hl)			;822b	7e 	~ 
	cp 0c3h		;822c	fe c3 	. . 
	ret nz			;822e	c0 	. 
	xor a			;822f	af 	. 
	out (0a0h),a		;8230	d3 a0 	. . 
	out (0a1h),a		;8232	d3 a1 	. . 
	jp (hl)			;8234	e9 	. 
l8235h:
	in a,(073h)		;8235	db 73 	. s 
	and 0f8h		;8237	e6 f8 	. . 
	cp 0f0h		;8239	fe f0 	. . 
	ret nz			;823b	c0 	. 
	call get_char_echo		;823c	cd 78 8a 	. x . 
	cp 00dh		;823f	fe 0d 	. . 
	ret nz			;8241	c0 	. 
	ld a,000h		;8242	3e 00 	> . 
	call sub_8af6h		;8244	cd f6 8a 	. . . 
	ld b,004h		;8247	06 04 	. . 
	ld d,b			;8249	50 	P 
	otir		;824a	ed b3 	. . 
	in a,(030h)		;824c	db 30 	. 0 
	in a,(030h)		;824e	db 30 	. 0 
	call serial_put		;8250	cd e3 8a 	. . . 
	ld c,b			;8253	48 	H 
l8254h:
	dec bc			;8254	0b 	. 
	ld a,b			;8255	78 	x 
	or c			;8256	b1 	. 
	jr nz,l825dh		;8257	20 04 	  . 
	ld a,d			;8259	7a 	z 
	cp 003h		;825a	fe 03 	. . 
	ret nc			;825c	d0 	. 
l825dh:
	in a,(031h)		;825d	db 31 	. 1 
	and 002h		;825f	e6 02 	. . 
	jr z,l8254h		;8261	28 f1 	( . 
	in a,(030h)		;8263	db 30 	. 0 
	cp (hl)			;8265	be 	. 
	jr nz,l8254h		;8266	20 ec 	  . 
	inc hl			;8268	23 	# 
	dec d			;8269	15 	. 
	jr nz,l8254h		;826a	20 e8 	  . 
	ld b,d			;826c	42 	B 
l826dh:
	djnz l826dh		;826d	10 fe 	. . 
	dec d			;826f	15 	. 
	jr nz,l826dh		;8270	20 fb 	  . 
	ld c,006h		;8272	0e 06 	. . 
l8274h:
	ld b,(hl)			;8274	46 	F 
	call serial_put		;8275	cd e3 8a 	. . . 
	inc hl			;8278	23 	# 
	dec c			;8279	0d 	. 
	jr nz,l8274h		;827a	20 f8 	  . 
l827ch:
	call serial_get		;827c	cd ed 8a 	. . . 
	cp 002h		;827f	fe 02 	. . 
	jr nz,l827ch		;8281	20 f9 	  . 
	call serial_get		;8283	cd ed 8a 	. . . 
	ld d,a			;8286	57 	W 
	ld e,000h		;8287	1e 00 	. . 
	ld b,e			;8289	43 	C 
	ld ix,0000ah		;828a	dd 21 0a 00 	. ! . . 
	add ix,de		;828e	dd 19 	. . 
	ld hl,00001h		;8290	21 01 00 	! . . 
l8293h:
	ld (de),a			;8293	12 	. 
	inc de			;8294	13 	. 
	ld c,a			;8295	4f 	O 
	add hl,bc			;8296	09 	. 
l8297h:
	call serial_get		;8297	cd ed 8a 	. . . 
	cp 010h		;829a	fe 10 	. . 
	jr nz,l8293h		;829c	20 f5 	  . 
	call serial_get		;829e	cd ed 8a 	. . . 
	cp 016h		;82a1	fe 16 	. . 
	jr z,l8297h		;82a3	28 f2 	( . 
	cp 003h		;82a5	fe 03 	. . 
	jr nz,l8293h		;82a7	20 ea 	  . 
	call serial_get		;82a9	cd ed 8a 	. . . 
	cp l			;82ac	bd 	. 
	ret nz			;82ad	c0 	. 
	call serial_get		;82ae	cd ed 8a 	. . . 
	cp h			;82b1	bc 	. 
	ret nz			;82b2	c0 	. 
	call serial_get		;82b3	cd ed 8a 	. . . 
	xor a			;82b6	af 	. 
	out (0a0h),a		;82b7	d3 a0 	. . 
	out (0a1h),a		;82b9	d3 a1 	. . 
	jp (ix)		;82bb	dd e9 	. . 
l82bdh:
	ld b,02ah		;82bd	06 2a 	. * 
	call emit_char		;82bf	cd 7f 8a 	.  . 
	call get_char_echo		;82c2	cd 78 8a 	. x . 
	cp 044h		;82c5	fe 44 	. D 
	jr z,l8305h		;82c7	28 3c 	( < 
	cp 04ah		;82c9	fe 4a 	. J 
	jr z,l82fdh		;82cb	28 30 	( 0 
	cp 049h		;82cd	fe 49 	. I 
	jr z,l82f3h		;82cf	28 22 	( " 
	cp 04fh		;82d1	fe 4f 	. O 
	jr z,l82ech		;82d3	28 17 	( . 
	cp 051h		;82d5	fe 51 	. Q 
	jp z,l81abh		;82d7	ca ab 81 	. . . 
	cp 041h		;82da	fe 41 	. A 
	jp z,l897dh		;82dc	ca 7d 89 	. } . 
l82dfh:
	ld sp,00200h		;82df	31 00 02 	1 . . 
	ld b,018h		;82e2	06 18 	. . 
	call video_driver_8ad2h		;82e4	cd d2 8a 	. . . 
	call line_feed		;82e7	cd b2 83 	. . . 
	jr l82bdh		;82ea	18 d1 	. . 
l82ech:
	call sub_8336h		;82ec	cd 36 83 	. 6 . 
	out (c),b		;82ef	ed 41 	. A 
	jr l82dfh		;82f1	18 ec 	. . 
l82f3h:
	call sub_8341h		;82f3	cd 41 83 	. A . 
	in b,(c)		;82f6	ed 40 	. @ 
	call sub_8370h		;82f8	cd 70 83 	. p . 
	jr l82dfh		;82fb	18 e2 	. . 
l82fdh:
	call sub_8336h		;82fd	cd 36 83 	. 6 . 
	ld hl,l82dfh		;8300	21 df 82 	! . . 
	push bc			;8303	c5 	. 
	ret			;8304	c9 	. 
l8305h:
	call sub_8336h		;8305	cd 36 83 	. 6 . 
	ld (002feh),bc		;8308	ed 43 fe 02 	. C . . 
l830ch:
	ld hl,(002feh)		;830c	2a fe 02 	* . . 
	ld b,(hl)			;830f	46 	F 
	inc hl			;8310	23 	# 
	ld (002feh),hl		;8311	22 fe 02 	" . . 
	call sub_8370h		;8314	cd 70 83 	. p . 
	ld b,02dh		;8317	06 2d 	. - 
	call emit_char		;8319	cd 7f 8a 	.  . 
	call get_char_echo		;831c	cd 78 8a 	. x . 
	cp 020h		;831f	fe 20 	.   
	jr nz,l8328h		;8321	20 05 	  . 
	call emit_char		;8323	cd 7f 8a 	.  . 
	jr l830ch		;8326	18 e4 	. . 
l8328h:
	cp 00dh		;8328	fe 0d 	. . 
	jr z,l82dfh		;832a	28 b3 	( . 
	call sub_8344h		;832c	cd 44 83 	. D . 
	ld hl,(002feh)		;832f	2a fe 02 	* . . 
	dec hl			;8332	2b 	+ 
	ld (hl),c			;8333	71 	q 
	jr l830ch		;8334	18 d6 	. . 
sub_8336h:
	call get_char_echo		;8336	cd 78 8a 	. x . 
	ld l,a			;8339	6f 	o 
	call get_char_echo		;833a	cd 78 8a 	. x . 
	ld h,a			;833d	67 	g 
	ld (000fch),hl		;833e	22 fc 00 	" . . 
sub_8341h:
	call get_char_echo		;8341	cd 78 8a 	. x . 
sub_8344h:
	ld l,a			;8344	6f 	o 
	call get_char_echo		;8345	cd 78 8a 	. x . 
	ld h,a			;8348	67 	g 
	ld (000feh),hl		;8349	22 fe 00 	" . . 
	ld hl,000fch		;834c	21 fc 00 	! . . 
	ld b,004h		;834f	06 04 	. . 
l8351h:
	ld a,(hl)			;8351	7e 	~ 
	sub 030h		;8352	d6 30 	. 0 
	cp 00ah		;8354	fe 0a 	. . 
	jr c,l835ah		;8356	38 02 	8 . 
	sub 007h		;8358	d6 07 	. . 
l835ah:
	bit 0,b		;835a	cb 40 	. @ 
	jr nz,l8365h		;835c	20 07 	  . 
	add a,a			;835e	87 	. 
	add a,a			;835f	87 	. 
	add a,a			;8360	87 	. 
	add a,a			;8361	87 	. 
	ld c,a			;8362	4f 	O 
	jr l8367h		;8363	18 02 	. . 
l8365h:
	add a,c			;8365	81 	. 
	ld (hl),a			;8366	77 	w 
l8367h:
	inc hl			;8367	23 	# 
	djnz l8351h		;8368	10 e7 	. . 
	dec hl			;836a	2b 	+ 
	ld c,(hl)			;836b	4e 	N 
	dec hl			;836c	2b 	+ 
	dec hl			;836d	2b 	+ 
	ld b,(hl)			;836e	46 	F 
	ret			;836f	c9 	. 
sub_8370h:
	ld a,(000f0h)		;8370	3a f0 00 	: . . 
	cp 04bh		;8373	fe 4b 	. K 
	ld c,b			;8375	48 	H 
	jr c,l8391h		;8376	38 19 	8 . 
	call line_feed		;8378	cd b2 83 	. . . 
	ld b,020h		;837b	06 20 	.   
	call emit_char		;837d	cd 7f 8a 	.  . 
	call emit_char		;8380	cd 7f 8a 	.  . 
	ld hl,(002feh)		;8383	2a fe 02 	* . . 
	dec hl			;8386	2b 	+ 
	ld e,c			;8387	59 	Y 
	ld c,h			;8388	4c 	L 
	call sub_8396h		;8389	cd 96 83 	. . . 
	ld c,l			;838c	4d 	M 
	call sub_8396h		;838d	cd 96 83 	. . . 
	ld c,e			;8390	4b 	K 
l8391h:
	ld b,020h		;8391	06 20 	.   
	call emit_char		;8393	cd 7f 8a 	.  . 
sub_8396h:
	ld d,002h		;8396	16 02 	. . 
	ld a,c			;8398	79 	y 
	and 0f0h		;8399	e6 f0 	. . 
	rrca			;839b	0f 	. 
	rrca			;839c	0f 	. 
	rrca			;839d	0f 	. 
	rrca			;839e	0f 	. 
l839fh:
	add a,030h		;839f	c6 30 	. 0 
	cp 03ah		;83a1	fe 3a 	. : 
	jr c,l83a7h		;83a3	38 02 	8 . 
	add a,007h		;83a5	c6 07 	. . 
l83a7h:
	ld b,a			;83a7	47 	G 
	call emit_char		;83a8	cd 7f 8a 	.  . 
	ld a,c			;83ab	79 	y 
	and 00fh		;83ac	e6 0f 	. . 
	dec d			;83ae	15 	. 
	jr nz,l839fh		;83af	20 ee 	  . 
	ret			;83b1	c9 	. 

line_feed:
	ld b,01fh		;83b2	06 1f 	        0x1F == New Line 
	call emit_char	        ;83b4	cd 7f 8a
	ld a,(000f1h)		;83b7	3a f1 00        Get cursorY from video data block
	cp 0e6h		        ;83ba	fe e6 	                Compare with 230 (0xe6).
	ret nz			;83bc	c0 
	ld b,01eh		;83bd	06 1e           0x1E = Cursor Home	
	call video_driver_8ad2h	;83bf	cd d2 8a 	 
	ld b,00fh		;83c2	06 0f 	        0x0F = Clear to end of screen 
	jp video_driver_8ad2h	;83c4	c3 d2 8a 	Will return from subroutine itself 

video_init:
	xor a			;83c7	af 	 
	ld h,07fh		;83c8	26 7f 	
l83cah:
	ld l,0f0h		;83ca	2e f0 	
l83cch:
	dec l			;83cc	2d 	
	ld (hl),a		;83cd	77 	
	jr nz,l83cch		;83ce	20 fc Zeroes memory from 0x07F0 to 0x0700	   
	dec h			;83d0	25 	 
	jr nz,l83cah		;83d1	20 f7 Zeroes memory from        0x06F0 - 0x0600 
                                                ;                       0x05F0 - 0x0500 
                                                ;                       0x04F0 - 0x0400 
                                                ;                       0x03F0 - 0x0300 
                                                ;                       0x02F0 - 0x0200 
                                                ;                       0x01F0 - 0x0100 
l83d3h:
	ld (hl),a		;83d3	77 	
	dec l			;83d4	2d 	
	jr nz,l83d3h		;83d5	20 fc 	  Zeroes last segment 0x00FF - 0x0000 
	ld hl,pixel_data	;83d7	21 61 85 	 
	ld (000f2h),hl		;83da	22 f2 00  Pixel Data to video data block 	
	ld hl,002f0h		;83dd	21 f0 02 	
	ld (000f8h),hl		;83e0	22 f8 00  Cursor template address (10 bytes) 	
	ld bc,00affh		;83e3	01 ff 0a 
l83e6h:
	ld (hl),c		;83e6	71      Fill cursor template (10 lines x 0xFF) 
	inc l			;83e7	2c  
	djnz l83e6h		;83e8	10 fc  
	ret			;83ea	c9 	

l83ebh:
	in a,(071h)		;83eb	db 71 	Get Card Id in Slot 5
	cp 0dfh		        ;83ed	fe df 	Compare with 0xDF 
	jr z,l83f6h		;83ef	28 05 	 
	in a,(060h)		;83f1	db 60 	Read Memory Parity Status 
	and 080h		;83f3	e6 80 	Undocumented bit
	ret nz			;83f5	c0 	 
l83f6h:
	xor a			;83f6	af 	 
	out (011h),a		;83f7	d3 11 	Send a NULL in Slot 5 Card (UART?)
	ld b,032h		;83f9	06 32 	 
l83fbh:
	ld a,064h		;83fb	3e 64 	 
	call delay	        ;83fd	cd c4 80 	Big delay here!! 
	in a,(011h)		;8400	db 11 	        Read from card 
	and 001h		;8402	e6 01 	        Check status? 
	jr nz,l840ah		;8404	20 04 	        OK, let's go         
	dec b			;8406	05 	 
	ret z			;8407	c8              Try 50 (0x32) times	 
	jr l83fbh		;8408	18 f1 
l840ah:
	ld bc,00010h		;840a	01 10 00 	B = 0, C = 0x10 !!
	ld hl,0fc00h		;840d	21 00 fc 	Buffer address = 0xFC00
	push hl			;8410	e5 	 
	inir		        ;8411	ed b2 	        Read to FC00, but B == 0, nothing is read! 
	ret			;8413	c9 	 

vdriver:
	and 07fh	;8414	e6 7f  	
	cp 07fh		;8416	fe 7f 	
	jp z,l84b1h	;8418	ca b1 84 
	cp 020h		;841b	fe 20 	   
	jp nc,l84f0h	;841d	d2 f0 84 
	ld c,a		;8420	4f 	 
	jr l848ch	;8421	18 69 	i 
l8423h:
	ld a,c		;8423	79 	 
	ld h,(ix+005h)	;8424	dd 66 05  
	ld l,(ix+004h)	;8427	dd 6e 04 
	cp 00dh		;842a	fe 0d 	
	jr z,l845bh	;842c	28 2d 	
	cp 00ah		;842e	fe 0a 	
	jr z,l8477h	;8430	28 45 	
	cp 00ch		;8432	fe 0c 	
	jr z,l8467h	;8434	28 31 	
	cp 01fh		;8436	fe 1f 	
	jr z,l8471h	;8438	28 37 	
	cp 00eh		;843a	fe 0e 	
	jp z,l854dh	;843c	ca 4d 85
	cp 00fh		;843f	fe 0f 	
	jp z,l8539h	;8441	ca 39 85
	cp 018h		;8444	fe 18 	
	jr z,l845fh	;8446	28 17 	
	cp 019h		;8448	fe 19 
	jr z,l8463h	;844a	28 17 
	cp 008h		;844c	fe 08 
	jr z,l84b8h	;844e	28 68 
	cp 00bh		;8450	fe 0b 
	jr z,l84c5h	;8452	28 71 
	cp 01eh		;8454	fe 1e 
	jr nz,l848ah	;8456	20 32 
	ld (ix+001h),l	;8458	dd 75 01
l845bh:
	xor a			;845b	af 	. 
l845ch:
	inc c			;845c	0c 	. 
	jr l8472h		;845d	18 13 	. . 
l845fh:
	res 0,h		;845f	cb 84 	. . 
	jr l8487h		;8461	18 24 	. $ 
l8463h:
	set 0,h		;8463	cb c4 	. . 
	jr l8487h		;8465	18 20 	.   
l8467h:
	ld a,d			;8467	7a 	z 
	inc a			;8468	3c 	< 
	cp 050h		;8469	fe 50 	. P 
	jr nz,l8472h		;846b	20 05 	  . 
	bit 1,h		;846d	cb 4c 	. L 
	jr nz,l848ah		;846f	20 19 	  . 
l8471h:
	xor a			;8471	af 	. 
l8472h:
	ld (ix+000h),a		;8472	dd 77 00 	. w . 
	jr nz,l848ah		;8475	20 13 	  . 
l8477h:
	ld (ix+001h),e		;8477	dd 73 01 	. s . 
	set 7,h		;847a	cb fc 	. . 
	ld a,l			;847c	7d 	} 
	add a,00ah		;847d	c6 0a 	. . 
	ld c,a			;847f	4f 	O 
	add a,0e6h		;8480	c6 e6 	. . 
	sub e			;8482	93 	. 
	jr nz,l848ah		;8483	20 05 	  . 
	jr l84d5h		;8485	18 4e 	. N 
l8487h:
	ld (ix+005h),h		;8487	dd 74 05 	. t . 
l848ah:
	set 7,c		;848a	cb f9 	. . 
l848ch:
	ld d,(ix+000h)		;848c	dd 56 00 	. V . 
	ld e,(ix+001h)		;848f	dd 5e 01 	. ^ . 
	ld b,00ah		;8492	06 0a 	. . 
	bit 0,(ix+005h)		;8494	dd cb 05 46 	. . . F 
	jr z,l849fh		;8498	28 05 	( . 
	ld a,e			;849a	7b 	{ 
	add a,b			;849b	80 	. 
	ld e,a			;849c	5f 	_ 
	jr l84ach		;849d	18 0d 	. . 
l849fh:
	ld h,(ix+009h)		;849f	dd 66 09 	. f . 
	ld l,(ix+008h)		;84a2	dd 6e 08 	. n . 
l84a5h:
	ld a,(de)			;84a5	1a 	. 
	xor (hl)			;84a6	ae 	. 
	ld (de),a			;84a7	12 	. 
	inc hl			;84a8	23 	# 
	inc e			;84a9	1c 	. 
	djnz l84a5h		;84aa	10 f9 	. . 
l84ach:
	bit 7,c		;84ac	cb 79 	. y 
	jp z,l8423h		;84ae	ca 23 84 	. # . 
l84b1h:
	ld l,(ix+006h)		;84b1	dd 6e 06 	. n . 
	ld h,(ix+007h)		;84b4	dd 66 07 	. f . 
	jp (hl)			;84b7	e9 	. 
l84b8h:
	ld a,d			;84b8	7a 	z 
	dec a			;84b9	3d 	= 
	jp p,l845ch		;84ba	f2 5c 84 	. \ . 
	bit 1,h		;84bd	cb 4c 	. L 
	jr nz,l848ah		;84bf	20 c9 	  . 
	ld (ix+000h),04fh		;84c1	dd 36 00 4f 	. 6 . O 
l84c5h:
	ld a,e			;84c5	7b 	{ 
	sub 014h		;84c6	d6 14 	. . 
	ld (ix+001h),a		;84c8	dd 77 01 	. w . 
	ld e,a			;84cb	5f 	_ 
	ld a,l			;84cc	7d 	} 
	sub 00ah		;84cd	d6 0a 	. . 
	cp e			;84cf	bb 	. 
	jr nz,l848ah		;84d0	20 b8 	  . 
	set 6,h		;84d2	cb f4 	. . 
	ld c,e			;84d4	4b 	K 
l84d5h:
	ld d,050h		;84d5	16 50 	. P 
	ld l,e			;84d7	6b 	k 
l84d8h:
	ld b,00ah		;84d8	06 0a 	. . 
	dec d			;84da	15 	. 
	xor a			;84db	af 	. 
l84dch:
	ld (de),a			;84dc	12 	. 
	inc e			;84dd	1c 	. 
	djnz l84dch		;84de	10 fc 	. . 
	ld e,l			;84e0	5d 	] 
	or d			;84e1	b2 	. 
	jr nz,l84d8h		;84e2	20 f4 	  . 
	ld (ix+004h),c		;84e4	dd 71 04 	. q . 
	bit 2,h		;84e7	cb 54 	. T 
	jr nz,l8487h		;84e9	20 9c 	  . 
	ld a,c			;84eb	79 	y 
	out (090h),a		;84ec	d3 90 	. . 
	jr l848ah		;84ee	18 9a 	. . 
l84f0h:
	sub 020h		;84f0	d6 20 	.   
	ld c,a			;84f2	4f 	O 
	xor a			;84f3	af 	. 
	ld b,a			;84f4	47 	G 
	ld h,(ix+003h)		;84f5	dd 66 03 	. f . 
	ld l,(ix+002h)		;84f8	dd 6e 02 	. n . 
	add hl,bc			;84fb	09 	. 
	add hl,bc			;84fc	09 	. 
	add hl,bc			;84fd	09 	. 
	add hl,bc			;84fe	09 	. 
	add hl,bc			;84ff	09 	. 
	add hl,bc			;8500	09 	. 
	add hl,bc			;8501	09 	. 
	ld d,(ix+000h)		;8502	dd 56 00 	. V . 
	ld e,(ix+001h)		;8505	dd 5e 01 	. ^ . 
	ld a,(ix+00ah)		;8508	dd 7e 0a 	. ~ . 
	ld (de),a			;850b	12 	. 
	inc e			;850c	1c 	. 
	ld bc,00702h		;850d	01 02 07 	. . . 
	bit 7,(hl)		;8510	cb 7e 	. ~ 
	jr z,l851eh		;8512	28 0a 	( . 
	ld (de),a			;8514	12 	. 
	inc e			;8515	1c 	. 
	dec c			;8516	0d 	. 
	bit 6,(hl)		;8517	cb 76 	. v 
	jr z,l851eh		;8519	28 03 	( . 
	ld (de),a			;851b	12 	. 
	inc e			;851c	1c 	. 
	dec c			;851d	0d 	. 
l851eh:
	ld a,(hl)			;851e	7e 	~ 
	and 03fh		;851f	e6 3f 	. ? 
	xor (ix+00ah)		;8521	dd ae 0a 	. . . 
	ld (de),a			;8524	12 	. 
	inc hl			;8525	23 	# 
	inc e			;8526	1c 	. 
	djnz l851eh		;8527	10 f5 	. . 
	ld a,(ix+00ah)		;8529	dd 7e 0a 	. ~ . 
l852ch:
	dec c			;852c	0d 	. 
	jp m,l8534h		;852d	fa 34 85 	. 4 . 
	ld (de),a			;8530	12 	. 
	inc e			;8531	1c 	. 
	jr l852ch		;8532	18 f8 	. . 
l8534h:
	ld c,00ch		;8534	0e 0c 	. . 
	jp l8423h		;8536	c3 23 84 	. # . 
l8539h:
	ld a,l			;8539	7d 	} 
	sub e			;853a	93 	. 
	sub 010h		;853b	d6 10 	. . 
	jr z,l854dh		;853d	28 0e 	( . 
	ld c,a			;853f	4f 	O 
	ld h,04fh		;8540	26 4f 	& O 
l8542h:
	ld b,c			;8542	41 	A 
	xor a			;8543	af 	. 
	ld l,e			;8544	6b 	k 
l8545h:
	ld (hl),a			;8545	77 	w 
	inc l			;8546	2c 	, 
	djnz l8545h		;8547	10 fc 	. . 
	dec h			;8549	25 	% 
	jp p,l8542h		;854a	f2 42 85 	. B . 
l854dh:
	ex de,hl			;854d	eb 	. 
	dec l			;854e	2d 	- 
	ld e,l			;854f	5d 	] 
l8550h:
	ld b,00ah		;8550	06 0a 	. . 
	xor a			;8552	af 	. 
	ld l,e			;8553	6b 	k 
l8554h:
	ld (hl),a			;8554	77 	w 
	dec l			;8555	2d 	- 
	djnz l8554h		;8556	10 fc 	. . 
	inc h			;8558	24 	$ 
	ld a,h			;8559	7c 	| 
	cp 050h		;855a	fe 50 	. P 
	jr nz,l8550h		;855c	20 f2 	  . 
	jp l848ah		;855e	c3 8a 84 	. . . 
pixel_data:
	defb	000h		;8561	........
	defb	000h		;8562	........
	defb	000h		;8563	........
	defb	000h		;8564	........
	defb	000h		;8565	........
	defb	000h		;8566	........
	defb	000h		;8567	........
	defb	008h		;8568	....x...
	defb	008h		;8569	....x...
	defb	008h		;856a	....x...
	defb	008h		;856b	....x...
	defb	008h		;856c	....x...
	defb	000h		;856d	........
	defb	008h		;856e	....x...
	defb	014h		;856f	...x.x..
	defb	014h		;8570	...x.x..
	defb	014h		;8571	...x.x..
	defb	000h		;8572	........
	defb	000h		;8573	........
	defb	000h		;8574	........
	defb	000h		;8575	........
	defb	014h		;8576	...x.x..
	defb	014h		;8577	...x.x..
	defb	03eh		;8578	..xxxxx.
	defb	014h		;8579	...x.x..
	defb	03eh		;857a	..xxxxx.
	defb	014h		;857b	...x.x..
	defb	014h		;857c	...x.x..
	defb	008h		;857d	....x...
	defb	01eh		;857e	...xxxx.
	defb	028h		;857f	..x.x...
	defb	01ch		;8580	...xxx..
	defb	00ah		;8581	....x.x.
	defb	03ch		;8582	..xxxx..
	defb	008h		;8583	....x...
	defb	032h		;8584	..xx..x.
	defb	032h		;8585	..xx..x.
	defb	004h		;8586	.....x..
	defb	008h		;8587	....x...
	defb	010h		;8588	...x....
	defb	026h		;8589	..x..xx.
	defb	026h		;858a	..x..xx.
	defb	010h		;858b	...x....
	defb	028h		;858c	..x.x...
	defb	028h		;858d	..x.x...
	defb	010h		;858e	...x....
	defb	02ah		;858f	..x.x.x.
	defb	024h		;8590	..x..x..
	defb	01ah		;8591	...xx.x.
	defb	008h		;8592	....x...
	defb	008h		;8593	....x...
	defb	010h		;8594	...x....
	defb	000h		;8595	........
	defb	000h		;8596	........
	defb	000h		;8597	........
	defb	000h		;8598	........
	defb	004h		;8599	.....x..
	defb	008h		;859a	....x...
	defb	010h		;859b	...x....
	defb	010h		;859c	...x....
	defb	010h		;859d	...x....
	defb	008h		;859e	....x...
	defb	004h		;859f	.....x..
	defb	010h		;85a0	...x....
	defb	008h		;85a1	....x...
	defb	004h		;85a2	.....x..
	defb	004h		;85a3	.....x..
	defb	004h		;85a4	.....x..
	defb	008h		;85a5	....x...
	defb	010h		;85a6	...x....
	defb	008h		;85a7	....x...
	defb	02ah		;85a8	..x.x.x.
	defb	01ch		;85a9	...xxx..
	defb	008h		;85aa	....x...
	defb	01ch		;85ab	...xxx..
	defb	02ah		;85ac	..x.x.x.
	defb	008h		;85ad	....x...
	defb	000h		;85ae	........
	defb	008h		;85af	....x...
	defb	008h		;85b0	....x...
	defb	03eh		;85b1	..xxxxx.
	defb	008h		;85b2	....x...
	defb	008h		;85b3	....x...
	defb	000h		;85b4	........
	defb	080h		;85b5	x.......
	defb	000h		;85b6	........
	defb	000h		;85b7	........
	defb	000h		;85b8	........
	defb	008h		;85b9	....x...
	defb	008h		;85ba	....x...
	defb	010h		;85bb	...x....
	defb	000h		;85bc	........
	defb	000h		;85bd	........
	defb	000h		;85be	........
	defb	03eh		;85bf	..xxxxx.
	defb	000h		;85c0	........
	defb	000h		;85c1	........
	defb	000h		;85c2	........
	defb	000h		;85c3	........
	defb	000h		;85c4	........
	defb	000h		;85c5	........
	defb	000h		;85c6	........
	defb	000h		;85c7	........
	defb	000h		;85c8	........
	defb	008h		;85c9	....x...
	defb	002h		;85ca	......x.
	defb	002h		;85cb	......x.
	defb	004h		;85cc	.....x..
	defb	008h		;85cd	....x...
	defb	010h		;85ce	...x....
	defb	020h		;85cf	..x.....
	defb	020h		;85d0	..x.....
	defb	01ch		;85d1	...xxx..
	defb	022h		;85d2	..x...x.
	defb	026h		;85d3	..x..xx.
	defb	02ah		;85d4	..x.x.x.
	defb	032h		;85d5	..xx..x.
	defb	022h		;85d6	..x...x.
	defb	01ch		;85d7	...xxx..
	defb	008h		;85d8	....x...
	defb	018h		;85d9	...xx...
	defb	008h		;85da	....x...
	defb	008h		;85db	....x...
	defb	008h		;85dc	....x...
	defb	008h		;85dd	....x...
	defb	01ch		;85de	...xxx..
	defb	01ch		;85df	...xxx..
	defb	022h		;85e0	..x...x.
	defb	002h		;85e1	......x.
	defb	00ch		;85e2	....xx..
	defb	010h		;85e3	...x....
	defb	020h		;85e4	..x.....
	defb	03eh		;85e5	..xxxxx.
	defb	03eh		;85e6	..xxxxx.
	defb	002h		;85e7	......x.
	defb	004h		;85e8	.....x..
	defb	00ch		;85e9	....xx..
	defb	002h		;85ea	......x.
	defb	022h		;85eb	..x...x.
	defb	01ch		;85ec	...xxx..
	defb	004h		;85ed	.....x..
	defb	00ch		;85ee	....xx..
	defb	014h		;85ef	...x.x..
	defb	024h		;85f0	..x..x..
	defb	03eh		;85f1	..xxxxx.
	defb	004h		;85f2	.....x..
	defb	004h		;85f3	.....x..
	defb	03eh		;85f4	..xxxxx.
	defb	020h		;85f5	..x.....
	defb	03ch		;85f6	..xxxx..
	defb	002h		;85f7	......x.
	defb	002h		;85f8	......x.
	defb	022h		;85f9	..x...x.
	defb	01ch		;85fa	...xxx..
	defb	00ch		;85fb	....xx..
	defb	010h		;85fc	...x....
	defb	020h		;85fd	..x.....
	defb	03ch		;85fe	..xxxx..
	defb	022h		;85ff	..x...x.
	defb	022h		;8600	..x...x.
	defb	01ch		;8601	...xxx..
	defb	03eh		;8602	..xxxxx.
	defb	002h		;8603	......x.
	defb	004h		;8604	.....x..
	defb	008h		;8605	....x...
	defb	010h		;8606	...x....
	defb	020h		;8607	..x.....
	defb	020h		;8608	..x.....
	defb	01ch		;8609	...xxx..
	defb	022h		;860a	..x...x.
	defb	022h		;860b	..x...x.
	defb	01ch		;860c	...xxx..
	defb	022h		;860d	..x...x.
	defb	022h		;860e	..x...x.
	defb	01ch		;860f	...xxx..
	defb	01ch		;8610	...xxx..
	defb	022h		;8611	..x...x.
	defb	022h		;8612	..x...x.
	defb	01eh		;8613	...xxxx.
	defb	002h		;8614	......x.
	defb	004h		;8615	.....x..
	defb	018h		;8616	...xx...
	defb	000h		;8617	........
	defb	000h		;8618	........
	defb	008h		;8619	....x...
	defb	000h		;861a	........
	defb	000h		;861b	........
	defb	008h		;861c	....x...
	defb	000h		;861d	........
	defb	080h		;861e	x.......
	defb	008h		;861f	....x...
	defb	000h		;8620	........
	defb	000h		;8621	........
	defb	008h		;8622	....x...
	defb	008h		;8623	....x...
	defb	010h		;8624	...x....
	defb	004h		;8625	.....x..
	defb	008h		;8626	....x...
	defb	010h		;8627	...x....
	defb	020h		;8628	..x.....
	defb	010h		;8629	...x....
	defb	008h		;862a	....x...
	defb	004h		;862b	.....x..
	defb	000h		;862c	........
	defb	000h		;862d	........
	defb	03eh		;862e	..xxxxx.
	defb	000h		;862f	........
	defb	03eh		;8630	..xxxxx.
	defb	000h		;8631	........
	defb	000h		;8632	........
	defb	010h		;8633	...x....
	defb	008h		;8634	....x...
	defb	004h		;8635	.....x..
	defb	002h		;8636	......x.
	defb	004h		;8637	.....x..
	defb	008h		;8638	....x...
	defb	010h		;8639	...x....
	defb	01ch		;863a	...xxx..
	defb	022h		;863b	..x...x.
	defb	004h		;863c	.....x..
	defb	008h		;863d	....x...
	defb	008h		;863e	....x...
	defb	000h		;863f	........
	defb	008h		;8640	....x...
	defb	01ch		;8641	...xxx..
	defb	022h		;8642	..x...x.
	defb	02eh		;8643	..x.xxx.
	defb	02ah		;8644	..x.x.x.
	defb	02eh		;8645	..x.xxx.
	defb	020h		;8646	..x.....
	defb	01eh		;8647	...xxxx.
	defb	01ch		;8648	...xxx..
	defb	022h		;8649	..x...x.
	defb	022h		;864a	..x...x.
	defb	022h		;864b	..x...x.
	defb	03eh		;864c	..xxxxx.
	defb	022h		;864d	..x...x.
	defb	022h		;864e	..x...x.
	defb	03ch		;864f	..xxxx..
	defb	022h		;8650	..x...x.
	defb	022h		;8651	..x...x.
	defb	03ch		;8652	..xxxx..
	defb	022h		;8653	..x...x.
	defb	022h		;8654	..x...x.
	defb	03ch		;8655	..xxxx..
	defb	01ch		;8656	...xxx..
	defb	022h		;8657	..x...x.
	defb	020h		;8658	..x.....
	defb	020h		;8659	..x.....
	defb	020h		;865a	..x.....
	defb	022h		;865b	..x...x.
	defb	01ch		;865c	...xxx..
	defb	03ch		;865d	..xxxx..
	defb	022h		;865e	..x...x.
	defb	022h		;865f	..x...x.
	defb	022h		;8660	..x...x.
	defb	022h		;8661	..x...x.
	defb	022h		;8662	..x...x.
	defb	03ch		;8663	..xxxx..
	defb	03eh		;8664	..xxxxx.
	defb	020h		;8665	..x.....
	defb	020h		;8666	..x.....
	defb	03ch		;8667	..xxxx..
	defb	020h		;8668	..x.....
	defb	020h		;8669	..x.....
	defb	03eh		;866a	..xxxxx.
	defb	03eh		;866b	..xxxxx.
	defb	020h		;866c	..x.....
	defb	020h		;866d	..x.....
	defb	03ch		;866e	..xxxx..
	defb	020h		;866f	..x.....
	defb	020h		;8670	..x.....
	defb	020h		;8671	..x.....
	defb	01ch		;8672	...xxx..
	defb	022h		;8673	..x...x.
	defb	020h		;8674	..x.....
	defb	020h		;8675	..x.....
	defb	02eh		;8676	..x.xxx.
	defb	022h		;8677	..x...x.
	defb	01eh		;8678	...xxxx.
	defb	022h		;8679	..x...x.
	defb	022h		;867a	..x...x.
	defb	022h		;867b	..x...x.
	defb	03eh		;867c	..xxxxx.
	defb	022h		;867d	..x...x.
	defb	022h		;867e	..x...x.
	defb	022h		;867f	..x...x.
	defb	01ch		;8680	...xxx..
	defb	008h		;8681	....x...
	defb	008h		;8682	....x...
	defb	008h		;8683	....x...
	defb	008h		;8684	....x...
	defb	008h		;8685	....x...
	defb	01ch		;8686	...xxx..
	defb	00eh		;8687	....xxx.
	defb	004h		;8688	.....x..
	defb	004h		;8689	.....x..
	defb	004h		;868a	.....x..
	defb	004h		;868b	.....x..
	defb	024h		;868c	..x..x..
	defb	018h		;868d	...xx...
	defb	022h		;868e	..x...x.
	defb	024h		;868f	..x..x..
	defb	028h		;8690	..x.x...
	defb	030h		;8691	..xx....
	defb	028h		;8692	..x.x...
	defb	024h		;8693	..x..x..
	defb	022h		;8694	..x...x.
	defb	020h		;8695	..x.....
	defb	020h		;8696	..x.....
	defb	020h		;8697	..x.....
	defb	020h		;8698	..x.....
	defb	020h		;8699	..x.....
	defb	020h		;869a	..x.....
	defb	03eh		;869b	..xxxxx.
	defb	022h		;869c	..x...x.
	defb	036h		;869d	..xx.xx.
	defb	02ah		;869e	..x.x.x.
	defb	02ah		;869f	..x.x.x.
	defb	022h		;86a0	..x...x.
	defb	022h		;86a1	..x...x.
	defb	022h		;86a2	..x...x.
	defb	022h		;86a3	..x...x.
	defb	032h		;86a4	..xx..x.
	defb	032h		;86a5	..xx..x.
	defb	02ah		;86a6	..x.x.x.
	defb	026h		;86a7	..x..xx.
	defb	026h		;86a8	..x..xx.
	defb	022h		;86a9	..x...x.
	defb	01ch		;86aa	...xxx..
	defb	022h		;86ab	..x...x.
	defb	022h		;86ac	..x...x.
	defb	022h		;86ad	..x...x.
	defb	022h		;86ae	..x...x.
	defb	022h		;86af	..x...x.
	defb	01ch		;86b0	...xxx..
	defb	03ch		;86b1	..xxxx..
	defb	022h		;86b2	..x...x.
	defb	022h		;86b3	..x...x.
	defb	03ch		;86b4	..xxxx..
	defb	020h		;86b5	..x.....
	defb	020h		;86b6	..x.....
	defb	020h		;86b7	..x.....
	defb	01ch		;86b8	...xxx..
	defb	022h		;86b9	..x...x.
	defb	022h		;86ba	..x...x.
	defb	022h		;86bb	..x...x.
	defb	02ah		;86bc	..x.x.x.
	defb	024h		;86bd	..x..x..
	defb	01ah		;86be	...xx.x.
	defb	03ch		;86bf	..xxxx..
	defb	022h		;86c0	..x...x.
	defb	022h		;86c1	..x...x.
	defb	03ch		;86c2	..xxxx..
	defb	028h		;86c3	..x.x...
	defb	024h		;86c4	..x..x..
	defb	022h		;86c5	..x...x.
	defb	01ch		;86c6	...xxx..
	defb	022h		;86c7	..x...x.
	defb	020h		;86c8	..x.....
	defb	01ch		;86c9	...xxx..
	defb	002h		;86ca	......x.
	defb	022h		;86cb	..x...x.
	defb	01ch		;86cc	...xxx..
	defb	03eh		;86cd	..xxxxx.
	defb	008h		;86ce	....x...
	defb	008h		;86cf	....x...
	defb	008h		;86d0	....x...
	defb	008h		;86d1	....x...
	defb	008h		;86d2	....x...
	defb	008h		;86d3	....x...
	defb	022h		;86d4	..x...x.
	defb	022h		;86d5	..x...x.
	defb	022h		;86d6	..x...x.
	defb	022h		;86d7	..x...x.
	defb	022h		;86d8	..x...x.
	defb	022h		;86d9	..x...x.
	defb	01ch		;86da	...xxx..
	defb	022h		;86db	..x...x.
	defb	022h		;86dc	..x...x.
	defb	022h		;86dd	..x...x.
	defb	022h		;86de	..x...x.
	defb	014h		;86df	...x.x..
	defb	014h		;86e0	...x.x..
	defb	008h		;86e1	....x...
	defb	022h		;86e2	..x...x.
	defb	022h		;86e3	..x...x.
	defb	022h		;86e4	..x...x.
	defb	02ah		;86e5	..x.x.x.
	defb	02ah		;86e6	..x.x.x.
	defb	02ah		;86e7	..x.x.x.
	defb	014h		;86e8	...x.x..
	defb	022h		;86e9	..x...x.
	defb	022h		;86ea	..x...x.
	defb	014h		;86eb	...x.x..
	defb	008h		;86ec	....x...
	defb	014h		;86ed	...x.x..
	defb	022h		;86ee	..x...x.
	defb	022h		;86ef	..x...x.
	defb	022h		;86f0	..x...x.
	defb	022h		;86f1	..x...x.
	defb	014h		;86f2	...x.x..
	defb	008h		;86f3	....x...
	defb	008h		;86f4	....x...
	defb	008h		;86f5	....x...
	defb	008h		;86f6	....x...
	defb	03eh		;86f7	..xxxxx.
	defb	002h		;86f8	......x.
	defb	004h		;86f9	.....x..
	defb	008h		;86fa	....x...
	defb	010h		;86fb	...x....
	defb	020h		;86fc	..x.....
	defb	03eh		;86fd	..xxxxx.
	defb	01ch		;86fe	...xxx..
	defb	010h		;86ff	...x....
	defb	010h		;8700	...x....
	defb	010h		;8701	...x....
	defb	010h		;8702	...x....
	defb	010h		;8703	...x....
	defb	01ch		;8704	...xxx..
	defb	020h		;8705	..x.....
	defb	020h		;8706	..x.....
	defb	010h		;8707	...x....
	defb	008h		;8708	....x...
	defb	004h		;8709	.....x..
	defb	002h		;870a	......x.
	defb	002h		;870b	......x.
	defb	01ch		;870c	...xxx..
	defb	004h		;870d	.....x..
	defb	004h		;870e	.....x..
	defb	004h		;870f	.....x..
	defb	004h		;8710	.....x..
	defb	004h		;8711	.....x..
	defb	01ch		;8712	...xxx..
	defb	008h		;8713	....x...
	defb	014h		;8714	...x.x..
	defb	022h		;8715	..x...x.
	defb	000h		;8716	........
	defb	000h		;8717	........
	defb	000h		;8718	........
	defb	000h		;8719	........
	defb	0c0h		;871a	xx......
	defb	000h		;871b	........
	defb	000h		;871c	........
	defb	000h		;871d	........
	defb	000h		;871e	........
	defb	000h		;871f	........
	defb	03eh		;8720	..xxxxx.
	defb	010h		;8721	...x....
	defb	008h		;8722	....x...
	defb	004h		;8723	.....x..
	defb	000h		;8724	........
	defb	000h		;8725	........
	defb	000h		;8726	........
	defb	000h		;8727	........
	defb	000h		;8728	........
	defb	000h		;8729	........
	defb	038h		;872a	..xxx...
	defb	004h		;872b	.....x..
	defb	03ch		;872c	..xxxx..
	defb	024h		;872d	..x..x..
	defb	01eh		;872e	...xxxx.
	defb	020h		;872f	..x.....
	defb	020h		;8730	..x.....
	defb	03ch		;8731	..xxxx..
	defb	022h		;8732	..x...x.
	defb	022h		;8733	..x...x.
	defb	022h		;8734	..x...x.
	defb	03ch		;8735	..xxxx..
	defb	000h		;8736	........
	defb	000h		;8737	........
	defb	01eh		;8738	...xxxx.
	defb	020h		;8739	..x.....
	defb	020h		;873a	..x.....
	defb	020h		;873b	..x.....
	defb	01eh		;873c	...xxxx.
	defb	002h		;873d	......x.
	defb	002h		;873e	......x.
	defb	01eh		;873f	...xxxx.
	defb	022h		;8740	..x...x.
	defb	022h		;8741	..x...x.
	defb	022h		;8742	..x...x.
	defb	01eh		;8743	...xxxx.
	defb	000h		;8744	........
	defb	000h		;8745	........
	defb	01ch		;8746	...xxx..
	defb	022h		;8747	..x...x.
	defb	03eh		;8748	..xxxxx.
	defb	020h		;8749	..x.....
	defb	01ch		;874a	...xxx..
	defb	00ch		;874b	....xx..
	defb	012h		;874c	...x..x.
	defb	010h		;874d	...x....
	defb	03ch		;874e	..xxxx..
	defb	010h		;874f	...x....
	defb	010h		;8750	...x....
	defb	010h		;8751	...x....
	defb	0dch		;8752	xx.xxx..
	defb	022h		;8753	..x...x.
	defb	022h		;8754	..x...x.
	defb	022h		;8755	..x...x.
	defb	01eh		;8756	...xxxx.
	defb	002h		;8757	......x.
	defb	01ch		;8758	...xxx..
	defb	020h		;8759	..x.....
	defb	020h		;875a	..x.....
	defb	02ch		;875b	..x.xx..
	defb	032h		;875c	..xx..x.
	defb	022h		;875d	..x...x.
	defb	022h		;875e	..x...x.
	defb	022h		;875f	..x...x.
	defb	000h		;8760	........
	defb	008h		;8761	....x...
	defb	000h		;8762	........
	defb	008h		;8763	....x...
	defb	008h		;8764	....x...
	defb	008h		;8765	....x...
	defb	01ch		;8766	...xxx..
	defb	084h		;8767	x....x..
	defb	000h		;8768	........
	defb	004h		;8769	.....x..
	defb	004h		;876a	.....x..
	defb	004h		;876b	.....x..
	defb	014h		;876c	...x.x..
	defb	008h		;876d	....x...
	defb	020h		;876e	..x.....
	defb	020h		;876f	..x.....
	defb	024h		;8770	..x..x..
	defb	028h		;8771	..x.x...
	defb	030h		;8772	..xx....
	defb	028h		;8773	..x.x...
	defb	024h		;8774	..x..x..
	defb	018h		;8775	...xx...
	defb	008h		;8776	....x...
	defb	008h		;8777	....x...
	defb	008h		;8778	....x...
	defb	008h		;8779	....x...
	defb	008h		;877a	....x...
	defb	01ch		;877b	...xxx..
	defb	000h		;877c	........
	defb	000h		;877d	........
	defb	034h		;877e	..xx.x..
	defb	02ah		;877f	..x.x.x.
	defb	02ah		;8780	..x.x.x.
	defb	02ah		;8781	..x.x.x.
	defb	02ah		;8782	..x.x.x.
	defb	000h		;8783	........
	defb	000h		;8784	........
	defb	02ch		;8785	..x.xx..
	defb	032h		;8786	..xx..x.
	defb	022h		;8787	..x...x.
	defb	022h		;8788	..x...x.
	defb	022h		;8789	..x...x.
	defb	000h		;878a	........
	defb	000h		;878b	........
	defb	01ch		;878c	...xxx..
	defb	022h		;878d	..x...x.
	defb	022h		;878e	..x...x.
	defb	022h		;878f	..x...x.
	defb	01ch		;8790	...xxx..
	defb	0fch		;8791	xxxxxx..
	defb	022h		;8792	..x...x.
	defb	022h		;8793	..x...x.
	defb	022h		;8794	..x...x.
	defb	03ch		;8795	..xxxx..
	defb	020h		;8796	..x.....
	defb	020h		;8797	..x.....
	defb	0dch		;8798	xx.xxx..
	defb	024h		;8799	..x..x..
	defb	024h		;879a	..x..x..
	defb	024h		;879b	..x..x..
	defb	01ch		;879c	...xxx..
	defb	004h		;879d	.....x..
	defb	006h		;879e	.....xx.
	defb	000h		;879f	........
	defb	000h		;87a0	........
	defb	02ch		;87a1	..x.xx..
	defb	032h		;87a2	..xx..x.
	defb	020h		;87a3	..x.....
	defb	020h		;87a4	..x.....
	defb	020h		;87a5	..x.....
	defb	000h		;87a6	........
	defb	000h		;87a7	........
	defb	01eh		;87a8	...xxxx.
	defb	020h		;87a9	..x.....
	defb	01ch		;87aa	...xxx..
	defb	002h		;87ab	......x.
	defb	03ch		;87ac	..xxxx..
	defb	008h		;87ad	....x...
	defb	008h		;87ae	....x...
	defb	01ch		;87af	...xxx..
	defb	008h		;87b0	....x...
	defb	008h		;87b1	....x...
	defb	008h		;87b2	....x...
	defb	004h		;87b3	.....x..
	defb	000h		;87b4	........
	defb	000h		;87b5	........
	defb	022h		;87b6	..x...x.
	defb	022h		;87b7	..x...x.
	defb	022h		;87b8	..x...x.
	defb	026h		;87b9	..x..xx.
	defb	01ah		;87ba	...xx.x.
	defb	000h		;87bb	........
	defb	000h		;87bc	........
	defb	022h		;87bd	..x...x.
	defb	022h		;87be	..x...x.
	defb	014h		;87bf	...x.x..
	defb	014h		;87c0	...x.x..
	defb	008h		;87c1	....x...
	defb	000h		;87c2	........
	defb	000h		;87c3	........
	defb	022h		;87c4	..x...x.
	defb	022h		;87c5	..x...x.
	defb	02ah		;87c6	..x.x.x.
	defb	02ah		;87c7	..x.x.x.
	defb	014h		;87c8	...x.x..
	defb	000h		;87c9	........
	defb	000h		;87ca	........
	defb	022h		;87cb	..x...x.
	defb	014h		;87cc	...x.x..
	defb	008h		;87cd	....x...
	defb	014h		;87ce	...x.x..
	defb	022h		;87cf	..x...x.
	defb	0e2h		;87d0	xxx...x.
	defb	022h		;87d1	..x...x.
	defb	022h		;87d2	..x...x.
	defb	026h		;87d3	..x..xx.
	defb	01ah		;87d4	...xx.x.
	defb	002h		;87d5	......x.
	defb	01ch		;87d6	...xxx..
	defb	000h		;87d7	........
	defb	000h		;87d8	........
	defb	03eh		;87d9	..xxxxx.
	defb	004h		;87da	.....x..
	defb	008h		;87db	....x...
	defb	010h		;87dc	...x....
	defb	03eh		;87dd	..xxxxx.
	defb	004h		;87de	.....x..
	defb	008h		;87df	....x...
	defb	008h		;87e0	....x...
	defb	010h		;87e1	...x....
	defb	008h		;87e2	....x...
	defb	008h		;87e3	....x...
	defb	004h		;87e4	.....x..
	defb	008h		;87e5	....x...
	defb	008h		;87e6	....x...
	defb	008h		;87e7	....x...
	defb	000h		;87e8	........
	defb	008h		;87e9	....x...
	defb	008h		;87ea	....x...
	defb	008h		;87eb	....x...
	defb	010h		;87ec	...x....
	defb	008h		;87ed	....x...
	defb	008h		;87ee	....x...
	defb	004h		;87ef	.....x..
	defb	008h		;87f0	....x...
	defb	008h		;87f1	....x...
	defb	010h		;87f2	...x....
	defb	002h		;87f3	......x.
	defb	01ch		;87f4	...xxx..
	defb	020h		;87f5	..x.....
	defb	000h		;87f6	........
	defb	000h		;87f7	........
	defb	000h		;87f8	........
	defb	000h		;87f9	........

	jp l848ah		;87fa	c3 8a 84 	. . . 
	jp vdriver		;87fd	c3 14 84 	Official video driver entry point
l8800h:
	xor a			;8800	af 	 
	ld d,a			;8801	57 	 
	ld e,a			;8802	5f 	 
	exx			;8803	d9 	Exchange BC, DE, HL
	in a,(0d0h)		;8804	db d0 	Read Status Register 2
	and 080h		;8806	e6 80 	Read CommandACK value
	ld b,a			;8808	47 	Store CommandACK in b 
	ld a,038h		;8809	3e 38 	 
	out (0f8h),a		;880b	d3 f8   Set IOCR
                                                ; xx1xxxxx -> Blank display
                                                ; xxx1xxxx -> Remove I/O reset
                                                ; xxxx1xxx -> Remove acquire mode
                                                ; xxxxx000 -> Command: Show sector
	ld c,0b5h		;880d	0e b5 	
l880fh:
	in a,(0d0h)		;880f	db d0   Read Status Register 2	
	and 080h		;8811	e6 80 	Get CommandACK value
	xor b			;8813	a8 	Compare with previous value. 
	jr nz,l881bh		;8814	20 05 	On command performed, to l881bh
	dec c			;8816	0d 	
	jr nz,l880fh		;8817	20 f6   Else repeat 180 (0xB5) times
	jr l8823h		;8819	18 08 	If no success, to l8823
l881bh:
	in a,(0d0h)		;881b	db d0   Read status register 
	and 00fh		;881d	e6 0f 	Get low nibble (show sector result) 
	cp 00eh		        ;881f	fe 0e 	On 0x0E driver motors are off 
	jr z,l8829h		;8821	28 06   On motors off, jump to l8829h	
l8823h:
	exx			;8823	d9 	
	ld a,d			;8824	7a 	
	or 002h		        ;8825	f6 02 	
	ld d,a			;8827	57 	 
	exx			;8828	d9 	d |= 2 in normal registers 
;; -------- Unknown Card initialization ---------------------------
l8829h:
	in a,(071h)		;8829	db 71 	Get BoardId on slot 5
	cp 0dfh		        ;882b	fe df 	Compare with board 0xDF (unknown)
	jr nz,l8861h		;882d	20 32 	   
	ld a,019h		;882f	3e 19 	If board is 0xDF
	out (011h),a		;8831	d3 11 	0x19 -> 0x11
	ld bc,02000h		;8833	01 00 20         
l8836h:
	in a,(011h)		;8836	db 11   Read status port from board	
	and 080h		;8838	e6 80 	
	jr nz,l8843h		;883a	20 07  	Wait for bit 7 to be zeroed 
	dec bc			;883c	0b 	 
	ld a,b			;883d	78 	 
	or c			;883e	b1 	 
	jr nz,l8836h		;883f	20 f5  Try this for 0x2000 times	  
	jr l885bh		;8841	18 18  On no success	 
l8843h:
	in a,(011h)		;8843	db 11 	Read status port from board
	and 008h		;8845	e6 08 	Check for bit 3 to be zeroed
	jr nz,l885bh		;8847	20 12 	Give up 
	ld a,018h		;8849	3e 18 	 
	out (011h),a		;884b	d3 11 	Out 0x18 on control port 
	ld bc,02000h		;884d	01 00 20 
l8850h:
	in a,(011h)		;8850	db 11 	 
	and 080h		;8852	e6 80 	
	jr z,l8861h		;8854	28 0b 	Wait for bit 7 to be zeroed 
	dec bc			;8856	0b 	 
	ld a,b			;8857	78 	 
	or c			;8858	b1 	 
	jr nz,l8850h		;8859	20 f5 	Try 0x2000 times. 
l885bh:
	exx			;885b	d9 	 
	ld a,d			;885c	7a 	 
	or 004h		;885d	f6 04 	 
	ld d,a			;885f	57 	D |= 0x04 on failure 
	exx			;8860	d9 	 
;; -------- End of Unknown Card initialization ---------------------------
l8861h:
	ld a,03dh		;8861	3e 3d 	
	out (0f8h),a		;8863	d3 f8 	IOCR <- 00111101
                                                ; xx1xxxxx -> Blank display
                                                ; xxx1xxxx -> I/O Reset removed
                                                ; xxxx1xxx -> Acquire mode unset
                                                ; xxxxx101 -> Command Start disk drive motors
	ld b,004h		;8865	06 04 	 
l8867h:
	dec a			;8867	3d 	 
	jr nz,l8867h		;8868	20 fd 	Loop on a 
	djnz l8867h		;886a	10 fb 	Loop 4 times (256 times a)
	ld a,038h		;886c	3e 38 	8 
	out (0f8h),a		;886e	d3 f8 	IOCR <- 00111000 
                                                ; xx1xxxxx -> Blank display
                                                ; xxx1xxxx -> Remove I/O reset
                                                ; xxxx1xxx -> Remove acquire mode
                                                ; xxxxx000 -> Command: Show sector
	ld a,0a1h		;8870	3e a1 	 
	out (081h),a		;8872	d3 81 	; Drive Control Register <- 10100001
                                                ; 1xxxxxxx -> Not used
                                                ; x0xxxxxx -> Disquete side 0 
                                                ; xx1xxxxx -> Disquete side 0 
                                                ; xxx0xxxx -> Step towards outer cylinder
                                                ; xxxx00xx -> Not used
                                                ; xxxxxx0x -> Disk drive 2
                                                ; xxxxxxx1 -> Disk drive 1
	exx			;8874	d9 	 
	ld a,d			;8875	7a 	 
	or 008h		        ;8876	f6 08 	 
	ld d,a			;8878	57 	 
	ld a,e			;8879	7b 	 
	or 060h		        ;887a	f6 60 	 
	ld e,a			;887c	5f 	 
	exx			;887d	d9 	d | = 0x08 && e |= 0x60 in normal registers 
	ld a,002h		;887e	3e 02 	 
	out (060h),a		;8880	d3 60 	Clear parity error flag
	ld b,004h		;8882	06 04 	 
l8884h:                         ; Repeated for the four RAM pages (A selects the page)
	ld a,b			;8884	78 	 
	dec a			;8885	3d 	 
	out (0a0h),a		;8886	d3 a0   MMR0 <- 0x03  
                                                ; Page 3 of RAM to 0x0000
	out (082h),a		;8888	d3 82 	Set disk read flag (output data ignored) 
	ld hl,04000h		;888a	21 00 40 	 
l888dh:
	dec hl			;888d	2b 	 
	ld a,(hl)		;888e	7e 	 
	ld a,l			;888f	7d 	 
	add a,h			;8890	84 	 
	ld (hl),a		;8891	77 	mem[hl] = h + l 
	ld a,l			;8892	7d 	 
	or h			;8893	b4 	
	jr nz,l888dh		;8894	20 f7   Write memory test	
                                                ;We have loaded page 3 on 0x0000 - 0x3fff
	in a,(082h)		;8896	db 82 	Clear disk read flag (arbitrary input data)
	ld c,000h		;8898	0e 00   C = flag for memory comparison	
	ld hl,04000h		;889a	21 00 40 	 
l889dh:
	dec hl			;889d	2b 	 
	ld a,l			;889e	7d 	 
	add a,h			;889f	84 	 
	cp (hl)			;88a0	be 	 
	jr z,l88a5h		;88a1	28 02 	 
	ld c,001h		;88a3	0e 01 	Set C on failure in memory comparison 
l88a5h:
	ld a,l			;88a5	7d 	 
	or h			;88a6	b4 	 
	jr nz,l889dh		;88a7	20 f4 	Loop through the first mapped RAM page 
	ld a,c			;88a9	79 	 
	or a			;88aa	b7 	 
	jr z,l88b8h		;88ab	28 0b 	Jump to l88b8h if no memory error 
	xor a			;88ad	af 	Clear a 
	scf			;88ae	37 	 
	ld c,b			;88af	48 	B should hold 4 
l88b0h:
	rra			;88b0	1f 	Rotate right four times, with carry set 
	dec c			;88b1	0d 	 
	jr nz,l88b0h		;88b2	20 fc 	A should be 00010000 -> 0x10
	exx			;88b4	d9 	 
	or d			;88b5	b2 	 
	ld d,a			;88b6	57 	d |= 0x10 
	exx			;88b7	d9 	 
l88b8h:
	djnz l8884h		;88b8	10 ca 	Repeat for all the 64 kbytes of RAM
	in a,(060h)		;88ba	db 60 	Read parity error flag (xxxxxxx0) zero means error
	and 001h		;88bc	e6 01 	
	exx			;88be	d9 	 
	jr nz,l88c9h		;88bf	20 08 	If no parity error jump to l88c9h 
	ld a,e			;88c1	7b 	 
	and 0bfh		;88c2	e6 bf 	 
	ld e,a			;88c4	5f 	E &= 0xBF 
	ld a,d			;88c5	7a 	 
	and 0f7h		;88c6	e6 f7 	 
	ld d,a			;88c8	57 	D &= 0xF7 
l88c9h:
	ld a,002h		;88c9	3e 02 	 
	out (060h),a		;88cb	d3 60 	Clear parity error flag 
	ld a,d			;88cd	7a 	 
	exx			;88ce	d9 	 
	ld b,004h		;88cf	06 04 	 
l88d1h:
	dec b			;88d1	05 	 
	jr nz,l88d7h		;88d2	20 03 	 
	xor a			;88d4	af 	 
	jr l88ddh		;88d5	18 06 	 
l88d7h:
	rlca			;88d7	07 	 
	jr c,l88d1h		;88d8	38 f7 	 
	ld a,003h		;88da	3e 03 	 
	sub b			;88dc	90 	A contains (3 - position of first zero bit in D) 
                                                ;Probably RAM page without errors
l88ddh:
	out (0a3h),a		;88dd	d3 a3 	        Sets RAM page 3
	ld (0c002h),a		;88df	32 02 c0 	Store A in 0xC002 (RAM page) 
	ld a,080h		;88e2	3e 80 	 
	out (0a0h),a		;88e4	d3 a0 	        Display RAM (first page) to page 1 
	inc a			;88e6	3c 	 
	out (0a1h),a		;88e7	d3 a1 	        Display RAM (second page) to page 2
	ld sp,0d000h		;88e9	31 00 d0 	Stack pointer to RAM 0xD000
	exx			;88ec	d9 	 
	ld a,d			;88ed	7a 	 
	ld (0c001h),a		;88ee	32 01 c0 	D to 0xC001
	ld a,e			;88f1	7b 	 
	ld (0c000h),a		;88f2	32 00 c0 	E to 0xC000 
	ld a,b			;88f5	78 	         
	exx			;88f6	d9 	 
	call sub_8967h		;88f7	cd 67 89 	 
	jp nz,l895dh		;88fa	c2 5d 89 	 
	ld a,03dh		;88fd	3e 3d 	 
	out (0f8h),a		;88ff	d3 f8 	IOCR <- 00111101 
                                                ; xx1xxxxx -> Blank display
                                                ; xxx1xxxx -> I/O Reset removed
                                                ; xxxx1xxx -> Acquire mode unset
                                                ; xxxxx101 -> Command Start disk drive motors
	ld a,003h		;8901	3e 03   
	call delay	;8903	cd c4 80 
	ld hl,05000h		;8906	21 00 50 0x5000 = 20 kbytes
l8909h:
	dec hl			;8909	2b 	From Top display video 
	ld a,(hl)		;890a	7e 	 
	ld a,l			;890b	7d 	 
	add a,h			;890c	84 	 
	ld (hl),a		;890d	77 	 
	ld a,l			;890e	7d 	 
	or h			;890f	b4 	 
	jr nz,l8909h		;8910	20 f7 	Loop through the whole screen video 
	ld b,000h		;8912	06 00 	Check written RAM 
	ld hl,05000h		;8914	21 00 50 
l8917h:
	dec hl			;8917	2b 	 
	ld a,l			;8918	7d 	 
	add a,h			;8919	84 	 
	cp (hl)			;891a	be 	 
	jr z,l8922h		;891b	28 05 	 
	ld b,001h		;891d	06 01 	        Set B = 1 on RAM mismatch 
	jp l8926h		;891f	c3 26 89        Break on mismatch  
l8922h:
	ld a,l			;8922	7d 	 
	or h			;8923	b4 	
	jr nz,l8917h		;8924	20 f1 	Repeat to check the whole video ram (20Kb). 
l8926h:
	ld a,b			;8926	78 	 
	cp 001h		        ;8927	fe 01 	 
	jr nz,l8933h		;8929	20 08 	   
	ld a,(0c001h)		;892b	3a 01 c0  
	or 001h		        ;892e	f6 01 	  
	ld (0c001h),a		;8930	32 01 c0        Set bit 0 on 0xC001 on memory mismatch 	
l8933h:
	in a,(060h)		;8933	db 60 	
	and 001h		;8935	e6 01 	        Check for parity errors
	jr nz,l8941h		;8937	20 08 	        Jump on no parity error 
	ld a,(0c000h)		;8939	3a 00 c0 	
	and 0dfh		;893c	e6 df 	        
	ld (0c000h),a		;893e	32 00 c0 	0xC000 &= 0xDF on parity error  
l8941h:
	ld a,002h		;8941	3e 02 	
	out (060h),a		;8943	d3 60 	Clear parity errors
	xor a			;8945	af 	 
	out (090h),a		;8946	d3 90 	Start Scan Register (Line 0 on top of screen). 
	call video_init	        ;8948	cd c7 83 	 
	exx			;894b	d9 	 
	ld a,b			;894c	78 	 
	exx			;894d	d9 	 
	ld (002fdh),a		;894e	32 fd 02        B to 0x02FD 	 
	ld a,038h		;8951	3e 38 	
	out (0f8h),a		;8953	d3 f8 	IOCR <- 0x00111000 
                                                ; xx1xxxxx -> Blank display
                                                ; xxx1xxxx -> Remove I/O reset
                                                ; xxxx1xxx -> Remove acquire mode
                                                ; xxxxx000 -> Command: Show sector
	ld a,003h		;8955	3e 03 	 
	call delay	        ;8957	cd c4 80 	 
	jp l8bb6h		;895a	c3 b6 8b 	 

l895dh:
	exx			;895d	d9 	 
	ld a,001h		;895e	3e 01 	
	or a			;8960	b7 
	jp l815eh		;8961	c3 5e 81 

sub_8964h:
	ld a,(002fdh)		;8964	3a fd 02 	: . . 
sub_8967h:
	or a			;8967	b7 	. 
	jr nz,l896fh		;8968	20 05 	  . 
	in a,(031h)		;896a	db 31 	. 1 
	and 002h		;896c	e6 02 	. . 
	ret			;896e	c9 	. 
l896fh:
	ld a,(0c001h)		;896f	3a 01 c0 	: . . 
	and 002h		;8972	e6 02 	. . 
	jr z,l8978h		;8974	28 02 	( . 
	xor a			;8976	af 	. 
	ret			;8977	c9 	. 
l8978h:
	in a,(0d0h)		;8978	db d0 	. . 
	and 040h		;897a	e6 40 	. @ 
	ret			;897c	c9 	. 
l897dh:
	ld b,01eh		;897d	06 1e 	. . 
	call video_driver_8ad2h		;897f	cd d2 8a 	. . . 
	ld b,00fh		;8982	06 0f 	. . 
	call video_driver_8ad2h		;8984	cd d2 8a 	. . . 
	ld hl,l8a21h		;8987	21 21 8a 	! ! . 
	call puts		;898a	cd a5 8c 	. . . 
	xor a			;898d	af 	. 
	ld e,a			;898e	5f 	_ 
	exx			;898f	d9 	. 
	ld c,a			;8990	4f 	O 
	exx			;8991	d9 	. 
	ld d,081h		;8992	16 81 	. . 
	ld b,019h		;8994	06 19 	. . 
	call video_driver_8ad2h		;8996	cd d2 8a 	. . . 
	ld a,01dh		;8999	3e 1d 	> . 
	call iocr_exec		;899b	cd 30 81 	. 0 . 
	ld a,018h		;899e	3e 18 	> . 
	call iocr_exec		;89a0	cd 30 81 	. 0 . 
	call sub_8096h		;89a3	cd 96 80 	. . . 
	call sub_811dh		;89a6	cd 1d 81 	. . . 
l89a9h:
	ld a,d			;89a9	7a 	z 
	out (081h),a		;89aa	d3 81 	. . 
	ld a,01dh		;89ac	3e 1d 	> . 
	call iocr_exec		;89ae	cd 30 81 	. 0 . 
	ld a,018h		;89b1	3e 18 	> . 
	call iocr_exec		;89b3	cd 30 81 	. 0 . 
	in a,(0e0h)		;89b6	db e0 	. . 
	bit 5,a		;89b8	cb 6f 	. o 
	jr z,l89beh		;89ba	28 02 	( . 
	ld e,000h		;89bc	1e 00 	. . 
l89beh:
	call print_diag		;89be	cd 5f 8a 	. _ . 
	ld a,d			;89c1	7a 	z 
	call print_diag		;89c2	cd 5f 8a 	. _ . 
	ld b,020h		;89c5	06 20 	.   
	call emit_char		;89c7	cd 7f 8a 	.  . 
	call emit_char		;89ca	cd 7f 8a 	.  . 
	ld a,e			;89cd	7b 	{ 
	and 0f0h		;89ce	e6 f0 	. . 
	rrca			;89d0	0f 	. 
	rrca			;89d1	0f 	. 
	rrca			;89d2	0f 	. 
	rrca			;89d3	0f 	. 
	add a,030h		;89d4	c6 30 	. 0 
	ld b,a			;89d6	47 	G 
	call emit_char		;89d7	cd 7f 8a 	.  . 
	ld a,e			;89da	7b 	{ 
	and 00fh		;89db	e6 0f 	. . 
	add a,030h		;89dd	c6 30 	. 0 
	ld b,a			;89df	47 	G 
	call emit_char		;89e0	cd 7f 8a 	.  . 
	ld b,00dh		;89e3	06 0d 	. . 
	call emit_char		;89e5	cd 7f 8a 	.  . 
	call sub_8964h		;89e8	cd 64 89 	. d . 
	jr z,l8a0ah		;89eb	28 1d 	( . 
	call read_char		;89ed	cd 8b 8a 	. . . 
	cp 048h		;89f0	fe 48 	. H 
	jr z,l8a0ch		;89f2	28 18 	( . 
	cp 044h		;89f4	fe 44 	. D 
	jr z,l8a12h		;89f6	28 1a 	( . 
	cp 049h		;89f8	fe 49 	. I 
	jr z,l8a3fh		;89fa	28 43 	( C 
	cp 04fh		;89fc	fe 4f 	. O 
	jr z,l8a4fh		;89fe	28 4f 	( O 
	cp 051h		;8a00	fe 51 	. Q 
	jp z,l82dfh		;8a02	ca df 82 	. . . 
	cp 017h		;8a05	fe 17 	. . 
	call z,sub_8cc2h		;8a07	cc c2 8c 	. . . 
l8a0ah:
	jr l89a9h		;8a0a	18 9d 	. . 
l8a0ch:
	ld a,d			;8a0c	7a 	z 
	xor 040h		;8a0d	ee 40 	. @ 
	ld d,a			;8a0f	57 	W 
	jr l8a0ah		;8a10	18 f8 	. . 
l8a12h:
	ld a,d			;8a12	7a 	z 
	add a,a			;8a13	87 	. 
	and 00fh		;8a14	e6 0f 	. . 
	jr nz,l8a19h		;8a16	20 01 	  . 
	inc a			;8a18	3c 	< 
l8a19h:
	ld b,a			;8a19	47 	G 
	ld a,d			;8a1a	7a 	z 
	and 0f0h		;8a1b	e6 f0 	. . 
	or b			;8a1d	b0 	. 
	ld d,a			;8a1e	57 	W 
	jr l8a0ah		;8a1f	18 e9 	. . 
l8a21h:
	rra			;8a21	1f 	. 
	ld (hl),b			;8a22	70 	p 
	ld l,a			;8a23	6f 	o 
	ld (hl),d			;8a24	72 	r 
	ld (hl),h			;8a25	74 	t 
	jr nz,l8a6dh		;8a26	20 45 	  E 
	jr nc,$+74		;8a28	30 48 	0 H 
	jr nz,$+34		;8a2a	20 20 	    
	ld (hl),b			;8a2c	70 	p 
	ld l,a			;8a2d	6f 	o 
	ld (hl),d			;8a2e	72 	r 
	ld (hl),h			;8a2f	74 	t 
	jr nz,$+58		;8a30	20 38 	  8 
	ld sp,02048h		;8a32	31 48 20 	1 H   
	jr nz,l8aabh		;8a35	20 74 	  t 
	ld (hl),d			;8a37	72 	r 
	ld h,c			;8a38	61 	a 
	ld h,e			;8a39	63 	c 
	ld l,e			;8a3a	6b 	k 
	inc hl			;8a3b	23 	# 
	rra			;8a3c	1f 	. 
	rra			;8a3d	1f 	. 
	nop			;8a3e	00 	. 
l8a3fh:
	ld a,e			;8a3f	7b 	{ 
	inc a			;8a40	3c 	< 
	daa			;8a41	27 	' 
	ld e,a			;8a42	5f 	_ 
	ld a,020h		;8a43	3e 20 	>   
	or d			;8a45	b2 	. 
	exx			;8a46	d9 	. 
	ld c,000h		;8a47	0e 00 	. . 
	exx			;8a49	d9 	. 
	call sub_80b5h		;8a4a	cd b5 80 	. . . 
	jr l8a0ah		;8a4d	18 bb 	. . 
l8a4fh:
	ld a,e			;8a4f	7b 	{ 
	dec a			;8a50	3d 	= 
	daa			;8a51	27 	' 
	ld e,a			;8a52	5f 	_ 
	ld a,d			;8a53	7a 	z 
	and 0dfh		;8a54	e6 df 	. . 
	exx			;8a56	d9 	. 
	ld c,000h		;8a57	0e 00 	. . 
	exx			;8a59	d9 	. 
	call sub_80b5h		;8a5a	cd b5 80 	. . . 
	jr l8a0ah		;8a5d	18 ab 	. . 

print_diag:
	ld c,008h		;8a5f	0e 08 
l8a61h:
	rlca			;8a61	07 	Carry <- (A << 1)
	ld b,030h		;8a62	06 30 	B = '0' 
	jr nc,l8a67h		;8a64	30 01 	
	inc b			;8a66	04      If carry, B = '1'	
l8a67h:
	push af			;8a67	f5 
	call emit_char	;8a68	cd 7f 8a  Prints 0 or 1, on hardware failure or not
	pop af			;8a6b	f1 
	dec c			;8a6c	0d        
l8a6dh:
	jr nz,l8a61h		;8a6d	20 f2 	        Do it for the 8 bits of A. 
	ld b,020h		;8a6f	06 20 	   
	call emit_char	;8a71	cd 7f 8a  
	call emit_char	;8a74	cd 7f 8a        Print two spaces
	ret			;8a77	c9 	 

get_char_echo:
	call read_char		;8a78	cd 8b 8a
	call emit_char		;8a7b	cd 7f 8a
	ret			;8a7e	c9 

;; Prints a character on screen and serial if configured
;; Args: Character to print: B
;; 0x02FD controls serial output

emit_char:
	call video_driver_8ad2h	;8a7f	cd d2 8a 	
	ld a,(002fdh)		;8a82	3a fd 02 0x02fd controls serial communication	
	or a			;8a85	b7 	
	ld a,b			;8a86	78 	 
	call z,serial_put	;8a87	cc e3 8a
	ret			;8a8a	c9

read_char:
	ld a,(002fdh)		;8a8b	3a fd 02
	or a			;8a8e	b7
	jr z,l8acdh		;8a8f	28 3c
	ld a,003h		;8a91	3e 03
	call delay		;8a93	cd c4 80
l8a96h:
	in a,(0d0h)		;8a96	db d0  Get Status Register 2
	bit 6,a		        ;8a98	cb 77  Bit 6 Set when characters from keyboard available
	jr z,l8a96h		;8a9a	28 fa  Wait for characters	
	ld a,019h		;8a9c	3e 19  Command to IOCR 00011001 -> 001 Show Char LSB 
                                               ; 
	call iocr_exec		;8a9e	cd 30 81 
	in a,(0d0h)		;8aa1	db d0  Read status register 2
	and 00fh		;8aa3	e6 0f  Mask command result
	ld c,a			;8aa5	4f     Put character in C	 
	ld a,01ah		;8aa6	3e 1a  Command to IOCR 00011010 -> 010 Show Char MSB 
	call iocr_exec		;8aa8	cd 30 81 
l8aabh:
	in a,(0d0h)		;8aab	db d0 	
	add a,a			;8aad	87 	 
	add a,a			;8aae	87 	 
	add a,a			;8aaf	87 	 
	add a,a			;8ab0	87      Shift high nibble (A <<= 4)
	add a,c			;8ab1	81 	Compose character 
	cp 0ffh		        ;8ab2	fe ff 	
	jr z,l8ab9h		;8ab4	28 03 	 
	ld (003ffh),a		;8ab6	32 ff 03 Put in 0x03FF if not 0xFF	
l8ab9h:
	ld a,(003ffh)		;8ab9	3a ff 03 
l8abch:
	ld b,a			;8abc	47 	 
	ld a,018h		;8abd	3e 18 	
	out (0f8h),a		;8abf	d3 f8   Set IOCR <- 00011000
                                                ; xxx1xxxx -> Remove I/O reset
                                                ; xxxx1xxx -> Remove Acquired mode
	ld a,003h		;8ac1	3e 03 
	call delay		;8ac3	cd c4 80
	ld a,b			;8ac6	78
	cp 003h		        ;8ac7	fe 03   Value in 0x03FF
	jp z,l82dfh		;8ac9	ca df 82
	ret			;8acc	c9

l8acdh:
	call serial_get		;8acd	cd ed 8a 	. . . 
	jr l8abch		;8ad0	18 ea 	. . 

; Prints a character on the screen using the video driver
; Args: B. Character to print
; 0x00f0 holds the video display vector
video_driver_8ad2h:
	ld a,b			;8ad2	78 	 
	exx			;8ad3	d9 	 
	ld ix,000f0h		;8ad4	dd 21 f0 00 	IX points to Video Driver RAM block
	ld hl,l8ae1h		;8ad8	21 e1 8a 	
	ld (000f6h),hl		;8adb	22 f6 00        Return address 	
	jp vdriver		;8ade	c3 14 84        This is the video driver address
l8ae1h:
	exx			;8ae1	d9 
	ret			;8ae2	c9 

;; Prints a character on the serial port
;; waiting for TX ready
;; Args: B: Character to print
serial_put:
	in a,(031h)		;8ae3	db 31 	 Input USART status (if SIO in board 3).
	and 001h		;8ae5	e6 01 	 TX Ready? 
	jr z,serial_put	;8ae7	28 fa 	  
	ld a,b			;8ae9	78 	  
	out (030h),a		;8aea	d3 30 	 Output value to serial port
	ret			;8aec	c9 	  

;; Gets a character from the serial port
;; waiting for RX ready
;; Returns A: Character read
serial_get:
	in a,(031h)		;8aed	db 31 	Input USART status (if SIO in board 3)
	and 002h		;8aef	e6 02 	RX Ready?
	jr z,serial_get		;8af1	28 fa 	
	in a,(030h)		;8af3	db 30 	Get value from USART
	ret			;8af5	c9 	 

sub_8af6h:
	ld hl,l814dh		;8af6	21 4d 81 	! M . 
	ld bc,00331h		;8af9	01 31 03 	. 1 . 
	otir		;8afc	ed b3 	. . 
l8afeh:
	djnz l8afeh		;8afe	10 fe 	. . 
	out (038h),a		;8b00	d3 38 	. 8 
	ret			;8b02	c9 	. 
l8b03h:
	ld de,0c003h		;8b03	11 03 c0 	. . . 
	ld c,070h		;8b06	0e 70 	. p 
	ld b,006h		;8b08	06 06 	. . 
l8b0ah:
	push bc			;8b0a	c5 	. 
	in b,(c)		;8b0b	ed 40 	. @ 
	ld hl,l8b9dh		;8b0d	21 9d 8b 	! . . 
l8b10h:
	ld a,(hl)			;8b10	7e 	~ 
	inc hl			;8b11	23 	# 
	cp 0ffh		;8b12	fe ff 	. . 
	jr z,l8b1dh		;8b14	28 07 	( . 
	cp b			;8b16	b8 	. 
	jr z,l8b1dh		;8b17	28 04 	( . 
	inc hl			;8b19	23 	# 
	inc hl			;8b1a	23 	# 
	jr l8b10h		;8b1b	18 f3 	. . 
l8b1dh:
	pop bc			;8b1d	c1 	. 
	ld a,(hl)			;8b1e	7e 	~ 
	ld (de),a			;8b1f	12 	. 
	inc de			;8b20	13 	. 
	inc hl			;8b21	23 	# 
	ld a,(hl)			;8b22	7e 	~ 
	ld (de),a			;8b23	12 	. 
	inc de			;8b24	13 	. 
	inc hl			;8b25	23 	# 
	inc c			;8b26	0c 	. 
	djnz l8b0ah		;8b27	10 e1 	. . 
	ld hl,l8df4h		;8b29	21 f4 8d 	! . . 
	ex de,hl			;8b2c	eb 	. 
	ld (hl),e			;8b2d	73 	s 
	inc hl			;8b2e	23 	# 
	ld (hl),d			;8b2f	72 	r 
	ld de,0c003h		;8b30	11 03 c0 	. . . 
	ld ix,l8ba6h		;8b33	dd 21 a6 8b 	. ! . . 
	ld iy,0c012h		;8b37	fd 21 12 c0 	. ! . . 
	ld b,007h		;8b3b	06 07 	. . 
l8b3dh:
	ld l,(ix+000h)		;8b3d	dd 6e 00 	. n . 
	ld (iy+000h),l		;8b40	fd 75 00 	. u . 
	inc ix		;8b43	dd 23 	. # 
	inc iy		;8b45	fd 23 	. # 
	ld h,(ix+000h)		;8b47	dd 66 00 	. f . 
	ld (iy+000h),h		;8b4a	fd 74 00 	. t . 
	inc ix		;8b4d	dd 23 	. # 
	inc iy		;8b4f	fd 23 	. # 
	ld a,(de)			;8b51	1a 	. 
	ld (hl),a			;8b52	77 	w 
	inc hl			;8b53	23 	# 
	inc de			;8b54	13 	. 
	ld a,(de)			;8b55	1a 	. 
	ld (hl),a			;8b56	77 	w 
	inc de			;8b57	13 	. 
	djnz l8b3dh		;8b58	10 e3 	. . 
	xor a			;8b5a	af 	. 
	call sub_8b78h		;8b5b	cd 78 8b 	. x . 
sub_8b5eh:
	ld ix,(0c020h)		;8b5e	dd 2a 20 c0 	. *   . 
	ld hl,00000h		;8b62	21 00 00 	! . . 
	add hl,sp			;8b65	39 	9 
	ld (ix+000h),l		;8b66	dd 75 00 	. u . 
	inc ix		;8b69	dd 23 	. # 
	ld (ix+000h),h		;8b6b	dd 74 00 	. t . 
	ld a,(0c011h)		;8b6e	3a 11 c0 	: . . 
	inc a			;8b71	3c 	< 
	cp 007h		;8b72	fe 07 	. . 
	jp c,sub_8b78h		;8b74	da 78 8b 	. x . 
	xor a			;8b77	af 	. 
sub_8b78h:
	ld (0c011h),a		;8b78	32 11 c0 	2 . . 
	ld hl,0c012h		;8b7b	21 12 c0 	! . . 
	add a,a			;8b7e	87 	. 
	add a,l			;8b7f	85 	. 
	ld l,a			;8b80	6f 	o 
	adc a,h			;8b81	8c 	. 
	sub l			;8b82	95 	. 
	ld h,a			;8b83	67 	g 
	ld (0c020h),hl		;8b84	22 20 c0 	"   . 
	ld a,(hl)			;8b87	7e 	~ 
	inc hl			;8b88	23 	# 
	ld h,(hl)			;8b89	66 	f 
	ld l,a			;8b8a	6f 	o 
	ld sp,hl			;8b8b	f9 	. 
	ret			;8b8c	c9 	. 
sub_8b8dh:
	push af			;8b8d	f5 	. 
	push bc			;8b8e	c5 	. 
	push de			;8b8f	d5 	. 
	push hl			;8b90	e5 	. 
	call sub_8b5eh		;8b91	cd 5e 8b 	. ^ . 
	pop hl			;8b94	e1 	. 
	pop de			;8b95	d1 	. 
	pop bc			;8b96	c1 	. 
	pop af			;8b97	f1 	. 
	ret			;8b98	c9 	. 
sub_8b99h:
	call sub_8b5eh		;8b99	cd 5e 8b 	. ^ . 
	ret			;8b9c	c9 	. 
l8b9dh:
	rst 30h			;8b9d	f7 	. 
	rst 38h			;8b9e	ff 	. 
	adc a,l			;8b9f	8d 	. 
	rst 18h			;8ba0	df 	. 
	ld (bc),a			;8ba1	02 	. 
	adc a,a			;8ba2	8f 	. 
	rst 38h			;8ba3	ff 	. 
	rst 28h			;8ba4	ef 	. 
	adc a,l			;8ba5	8d 	. 
l8ba6h:
	and d			;8ba6	a2 	. 
	ret nz			;8ba7	c0 	. 
	inc h			;8ba8	24 	$ 
	pop bc			;8ba9	c1 	. 
	and (hl)			;8baa	a6 	. 
	pop bc			;8bab	c1 	. 
	jr z,$-60		;8bac	28 c2 	( . 
	xor d			;8bae	aa 	. 
	jp nz,0c32ch		;8baf	c2 2c c3 	. , . 
	xor (hl)			;8bb2	ae 	. 
	jp 0c430h		;8bb3	c3 30 c4 	. 0 . 
l8bb6h:
	ld hl,system_start_msg	;8bb6	21 41 81
	call puts		;8bb9	cd a5 8c 	
	call line_feed	;8bbc	cd b2 83 
	ld a,(0c001h)		;8bbf	3a 01 c0 
	or a			;8bc2	b7 
	jr z,l8bd2h		;8bc3	28 0d 	
	ld b,a			;8bc5	47 
	call print_diag		;8bc6	cd 5f 8a
	ld hl,hw_failure_msg	;8bc9	21 af 8c
	call puts		;8bcc	cd a5 8c
	call line_feed	;8bcf	cd b2 83
l8bd2h:
	call sub_8964h		;8bd2	cd 64 89 	. d . 
	jp nz,l8c09h		;8bd5	c2 09 8c 	. . . 
	ld a,01dh		;8bd8	3e 1d 	> . 
	out (0f8h),a		;8bda	d3 f8 	. . 
	ld a,(0c001h)		;8bdc	3a 01 c0 	: . . 
	and 0f2h		;8bdf	e6 f2 	. . 
	ld a,(0c000h)		;8be1	3a 00 c0 	: . . 
	jp nz,l8c9fh		;8be4	c2 9f 8c 	. . . 
	ld (0c432h),a		;8be7	32 32 c4 	2 2 . 
	exx			;8bea	d9 	. 
	ld c,001h		;8beb	0e 01 	. . 
	exx			;8bed	d9 	. 
	call sub_8096h		;8bee	cd 96 80 	. . . 
	jr nz,l8bfbh		;8bf1	20 08 	  . 
	ld a,(0c432h)		;8bf3	3a 32 c4 	: 2 . 
	or 010h		;8bf6	f6 10 	. . 
	ld (0c432h),a		;8bf8	32 32 c4 	2 2 . 
l8bfbh:
	exx			;8bfb	d9 	. 
	ld b,00ah		;8bfc	06 0a 	. . 
	exx			;8bfe	d9 	. 
l8bffh:
	ld a,0c8h		;8bff	3e c8 	> . 
	call delay		;8c01	cd c4 80 	. . . 
	call sub_8964h		;8c04	cd 64 89 	. d . 
	jr z,l8c11h		;8c07	28 08 	( . 
l8c09h:
	ld a,(002fdh)		;8c09	3a fd 02 	: . . 
	ld b,a			;8c0c	47 	G 
	xor a			;8c0d	af 	. 
	jp l815eh		;8c0e	c3 5e 81 	. ^ . 
l8c11h:
	ld a,018h		;8c11	3e 18 	> . 
	call iocr_exec		;8c13	cd 30 81 	. 0 . 
	in a,(082h)		;8c16	db 82 	. . 
	ld a,003h		;8c18	3e 03 	> . 
	call sub_806bh		;8c1a	cd 6b 80 	. k . 
	jr c,l8c2bh		;8c1d	38 0c 	8 . 
	ld a,01dh		;8c1f	3e 1d 	> . 
	call iocr_exec		;8c21	cd 30 81 	. 0 . 
	ld a,(0c432h)		;8c24	3a 32 c4 	: 2 . 
	or 008h		;8c27	f6 08 	. . 
	jr l8c94h		;8c29	18 69 	. i 
l8c2bh:
	ex af,af'			;8c2b	08 	. 
	ld a,004h		;8c2c	3e 04 	> . 
	ex af,af'			;8c2e	08 	. 
	ld e,000h		;8c2f	1e 00 	. . 
	ld b,000h		;8c31	06 00 	. . 
	call sub_80cdh		;8c33	cd cd 80 	. . . 
	jr nc,l8c3fh		;8c36	30 07 	0 . 
l8c38h:
	ld a,(0c432h)		;8c38	3a 32 c4 	: 2 . 
	or 004h		;8c3b	f6 04 	. . 
	jr l8c94h		;8c3d	18 55 	. U 
l8c3fh:
	in a,(080h)		;8c3f	db 80 	. . 
	cp 0d0h		;8c41	fe d0 	. . 
	jr c,l8c54h		;8c43	38 0f 	8 . 
	cp 0f9h		;8c45	fe f9 	. . 
	jr nc,l8c54h		;8c47	30 0b 	0 . 
	ld d,a			;8c49	57 	W 
	ld (de),a			;8c4a	12 	. 
	inc de			;8c4b	13 	. 
	rlca			;8c4c	07 	. 
	ld c,a			;8c4d	4f 	O 
	in a,(080h)		;8c4e	db 80 	. . 
	cp 076h		;8c50	fe 76 	. v 
	jr z,l8c5bh		;8c52	28 07 	( . 
l8c54h:
	ld a,(0c432h)		;8c54	3a 32 c4 	: 2 . 
	or 002h		;8c57	f6 02 	. . 
	jr l8c94h		;8c59	18 39 	. 9 
l8c5bh:
	ld (de),a			;8c5b	12 	. 
	inc de			;8c5c	13 	. 
	xor c			;8c5d	a9 	. 
	rlca			;8c5e	07 	. 
	ld c,a			;8c5f	4f 	O 
	dec b			;8c60	05 	. 
l8c61h:
	call l810ch		;8c61	cd 0c 81 	. . . 
	in a,(080h)		;8c64	db 80 	. . 
	xor c			;8c66	a9 	. 
	in a,(082h)		;8c67	db 82 	. . 
	jr z,l8c72h		;8c69	28 07 	( . 
	ld a,(0c432h)		;8c6b	3a 32 c4 	: 2 . 
	or 001h		;8c6e	f6 01 	. . 
	jr l8c94h		;8c70	18 22 	. " 
l8c72h:
	ex af,af'			;8c72	08 	. 
	dec a			;8c73	3d 	= 
	jr z,l8c7eh		;8c74	28 08 	( . 
	ex af,af'			;8c76	08 	. 
	call sub_80cdh		;8c77	cd cd 80 	. . . 
	jr c,l8c38h		;8c7a	38 bc 	8 . 
	jr l8c61h		;8c7c	18 e3 	. . 
l8c7eh:
	ld hl,0f80ah		;8c7e	21 0a f8 	! . . 
	add hl,de			;8c81	19 	. 
	ld a,(hl)			;8c82	7e 	~ 
	cp 0c3h		;8c83	fe c3 	. . 
	jr z,l8c8eh		;8c85	28 07 	( . 
	ld a,(0c432h)		;8c87	3a 32 c4 	: 2 . 
	or 002h		;8c8a	f6 02 	. . 
	jr l8c94h		;8c8c	18 06 	. . 
l8c8eh:
	xor a			;8c8e	af 	. 
	out (0a0h),a		;8c8f	d3 a0 	. . 
	out (0a1h),a		;8c91	d3 a1 	. . 
	jp (hl)			;8c93	e9 	. 
l8c94h:
	ld (0c432h),a		;8c94	32 32 c4 	2 2 . 
	exx			;8c97	d9 	. 
	dec b			;8c98	05 	. 
	exx			;8c99	d9 	. 
	jr z,l8c9fh		;8c9a	28 03 	( . 
	jp l8bffh		;8c9c	c3 ff 8b 	. . . 
l8c9fh:
	ld (0c000h),a		;8c9f	32 00 c0 	2 . . 
	jp l8b03h		;8ca2	c3 03 8b 	. . . 

; Prints a null terminated string
; HL: Points to the string address
puts:
	ld a,(hl)		;8ca5	7e 	 
	or a			;8ca6	b7 	 
	ret z			;8ca7	c8 	If value in (HL) is zero, return 
	ld b,a			;8ca8	47 	B holds character to print 
	call emit_char	;8ca9	cd 7f 8a 	 
	inc hl			;8cac	23 	Next character 
	jr puts		        ;8cad	18 f6 	Loop

hw_failure_msg:
        defb    020h            ;8caf    
        defb    020h            ;8cb0  
        defb    048h            ;8cb1   H
        defb    061h            ;8cb2   a
        defb    072h            ;8cb3   r
        defb    064h            ;8cb4   d
        defb    077h            ;8cb5   w
        defb    061h            ;8cb6   a
        defb    072h            ;8cb7   r
        defb    065h            ;8cb8   e
        defb    020h            ;8cb9   
        defb    066h            ;8cba   f
        defb    061h            ;8cbb   a
        defb    069h            ;8cbc   i
        defb    06ch            ;8cbd   l
        defb    075h            ;8cbe   u
        defb    072h            ;8cbf   r
        defb    065h            ;8cc0   e
        defb    000h            ;8cc1   .
sub_8cc2h:
	ld a,e			;8cc2	7b 	{ 
	cp 015h		;8cc3	fe 15 	. . 
	ld a,d			;8cc5	7a 	z 
	jr c,l8ccch		;8cc6	38 04 	8 . 
	or 020h		;8cc8	f6 20 	.   
	jr l8cceh		;8cca	18 02 	. . 
l8ccch:
	and 0dfh		;8ccc	e6 df 	. . 
l8cceh:
	ld d,a			;8cce	57 	W 
	ld a,01dh		;8ccf	3e 1d 	> . 
l8cd1h:
	call iocr_exec		;8cd1	cd 30 81 	. 0 . 
	ld a,018h		;8cd4	3e 18 	> . 
	call iocr_exec		;8cd6	cd 30 81 	. 0 . 
	ld b,019h		;8cd9	06 19 	. . 
	call video_driver_8ad2h	;8cdb	cd d2 8a 	. . . 
	call line_feed		;8cde	cd b2 83 	. . . 
	ld a,01dh		;8ce1	3e 1d 	> . 
	call iocr_exec		;8ce3	cd 30 81 	. 0 . 
	in a,(082h)		;8ce6	db 82 	. . 
	xor a			;8ce8	af 	. 
	ld (003fch),a		;8ce9	32 fc 03 	2 . . 
l8cech:
	ld a,002h		;8cec	3e 02 	> . 
	call delay		;8cee	cd c4 80 	. . . 
	ld a,018h		;8cf1	3e 18 	> . 
	out (0f8h),a		;8cf3	d3 f8 	. . 
	call sub_8964h		;8cf5	cd 64 89 	. d . 
	jr z,l8d05h		;8cf8	28 0b 	( . 
	call read_char		;8cfa	cd 8b 8a 	. . . 
	cp 051h		;8cfd	fe 51 	. Q 
	jr nz,l8d05h		;8cff	20 04 	  . 
	call line_feed		;8d01	cd b2 83 	. . . 
	ret			;8d04	c9 	. 
l8d05h:
	in a,(0e0h)		;8d05	db e0 	. . 
	and 010h		;8d07	e6 10 	. . 
	jr z,l8d10h		;8d09	28 05 	( . 
	ld a,036h		;8d0b	3e 36 	> 6 
	jp l8da9h		;8d0d	c3 a9 8d 	. . . 
l8d10h:
	ld a,001h		;8d10	3e 01 	> . 
	push de			;8d12	d5 	. 
	call sub_806bh		;8d13	cd 6b 80 	. k . 
	pop de			;8d16	d1 	. 
	jr c,l8d1eh		;8d17	38 05 	8 . 
	ld a,034h		;8d19	3e 34 	> 4 
	jp l8da9h		;8d1b	c3 a9 8d 	. . . 
l8d1eh:
	in a,(0e0h)		;8d1e	db e0 	. . 
	and 040h		;8d20	e6 40 	. @ 
	jr nz,l8d1eh		;8d22	20 fa 	  . 
l8d24h:
	in a,(0e0h)		;8d24	db e0 	. . 
	and 040h		;8d26	e6 40 	. @ 
	jr z,l8d24h		;8d28	28 fa 	( . 
	out (083h),a		;8d2a	d3 83 	. . 
	ld b,021h		;8d2c	06 21 	. ! 
	xor a			;8d2e	af 	. 
l8d2fh:
	out (080h),a		;8d2f	d3 80 	. . 
	djnz l8d2fh		;8d31	10 fc 	. . 
	ld a,0fbh		;8d33	3e fb 	> . 
	out (080h),a		;8d35	d3 80 	. . 
	ld a,002h		;8d37	3e 02 	> . 
	out (080h),a		;8d39	d3 80 	. . 
	ld b,000h		;8d3b	06 00 	. . 
	ld c,b			;8d3d	48 	H 
l8d3eh:
	ld a,(003fch)		;8d3e	3a fc 03 	: . . 
	out (080h),a		;8d41	d3 80 	. . 
	xor c			;8d43	a9 	. 
	rlca			;8d44	07 	. 
	ld c,a			;8d45	4f 	O 
	ld a,(003fch)		;8d46	3a fc 03 	: . . 
	out (080h),a		;8d49	d3 80 	. . 
	xor c			;8d4b	a9 	. 
	rlca			;8d4c	07 	. 
	ld c,a			;8d4d	4f 	O 
	djnz l8d3eh		;8d4e	10 ee 	. . 
	out (080h),a		;8d50	d3 80 	. . 
	ld b,077h		;8d52	06 77 	. w 
	call emit_char		;8d54	cd 7f 8a 	.  . 
	ld b,00dh		;8d57	06 0d 	. . 
	call emit_char		;8d59	cd 7f 8a 	.  . 
	in a,(082h)		;8d5c	db 82 	. . 
	ld a,001h		;8d5e	3e 01 	> . 
	push de			;8d60	d5 	. 
	call sub_806bh		;8d61	cd 6b 80 	. k . 
	pop de			;8d64	d1 	. 
	jr c,l8d6bh		;8d65	38 04 	8 . 
	ld a,034h		;8d67	3e 34 	> 4 
	jr l8da9h		;8d69	18 3e 	. > 
l8d6bh:
	ld b,000h		;8d6b	06 00 	. . 
	call sub_80cdh		;8d6d	cd cd 80 	. . . 
	jr nc,l8d76h		;8d70	30 04 	0 . 
	ld a,031h		;8d72	3e 31 	> 1 
	jr l8da9h		;8d74	18 33 	. 3 
l8d76h:
	ld a,(003fch)		;8d76	3a fc 03 	: . . 
	ld h,a			;8d79	67 	g 
l8d7ah:
	in a,(080h)		;8d7a	db 80 	. . 
	cp h			;8d7c	bc 	. 
	jr nz,l8d8eh		;8d7d	20 0f 	  . 
	xor c			;8d7f	a9 	. 
	rlca			;8d80	07 	. 
	ld c,a			;8d81	4f 	O 
	in a,(080h)		;8d82	db 80 	. . 
	cp h			;8d84	bc 	. 
	jr nz,l8d8eh		;8d85	20 07 	  . 
	xor c			;8d87	a9 	. 
	rlca			;8d88	07 	. 
	ld c,a			;8d89	4f 	O 
	djnz l8d7ah		;8d8a	10 ee 	. . 
	jr l8d92h		;8d8c	18 04 	. . 
l8d8eh:
	ld a,033h		;8d8e	3e 33 	> 3 
	jr l8da9h		;8d90	18 17 	. . 
l8d92h:
	in a,(080h)		;8d92	db 80 	. . 
	xor c			;8d94	a9 	. 
	jr z,l8d9bh		;8d95	28 04 	( . 
	ld a,032h		;8d97	3e 32 	> 2 
	jr l8da9h		;8d99	18 0e 	. . 
l8d9bh:
	in a,(082h)		;8d9b	db 82 	. . 
	ld b,072h		;8d9d	06 72 	. r 
	call emit_char		;8d9f	cd 7f 8a 	.  . 
	ld b,00dh		;8da2	06 0d 	. . 
	call emit_char		;8da4	cd 7f 8a 	.  . 
	jr l8db0h		;8da7	18 07 	. . 
l8da9h:
	call sub_8dc1h		;8da9	cd c1 8d 	. . . 
	ld a,01dh		;8dac	3e 1d 	> . 
	out (0f8h),a		;8dae	d3 f8 	. . 
l8db0h:
	ld a,d			;8db0	7a 	z 
	xor 040h		;8db1	ee 40 	. @ 
	ld d,a			;8db3	57 	W 
	out (081h),a		;8db4	d3 81 	. . 
	and 040h		;8db6	e6 40 	. @ 
	jr nz,l8dbeh		;8db8	20 04 	  . 
	ld hl,003fch		;8dba	21 fc 03 	! . . 
	inc (hl)		;8dbd	34 	4 
l8dbeh:
	jp l8cech		;8dbe	c3 ec 8c 	. . . 
sub_8dc1h:
	push de			;8dc1	d5 	. 
	push af			;8dc2	f5 	. 
	call line_feed		;8dc3	cd b2 83 	. . . 
	ld b,054h		;8dc6	06 54 	. T 
	call emit_char	        ;8dc8	cd 7f 8a 	.  . 
	ld b,020h		;8dcb	06 20 	.   
	call emit_char	        ;8dcd	cd 7f 8a 	.  . 
	pop af			;8dd0	f1 	. 
	ld b,a			;8dd1	47 	G 
	call emit_char	        ;8dd2	cd 7f 8a 	.  . 
	ld b,020h		;8dd5	06 20 	.   
	call emit_char	        ;8dd7	cd 7f 8a 	.  . 
	ld b,d			;8dda	42 	B 
	call sub_8370h		;8ddb	cd 70 83 	. p . 
	ld a,(003fch)		;8dde	3a fc 03 	: . . 
	ld b,a			;8de1	47 	G 
	call sub_8370h		;8de2	cd 70 83 	. p . 
	call line_feed	        ;8de5	cd b2 83 	. . . 
	ld a,0fah		;8de8	3e fa 	> . 
	call delay		;8dea	cd c4 80 	. . . 
	pop de			;8ded	d1 	. 
	ret			;8dee	c9 	. 
l8defh:
	call sub_8b99h		;8def	cd 99 8b 	. . . 
	jr l8defh		;8df2	18 fb 	. . 
l8df4h:
	call sub_8964h		;8df4	cd 64 89 	. d . 
	jp nz,l8c09h		;8df7	c2 09 8c 	. . . 
	call sub_8b99h		;8dfa	cd 99 8b 	. . . 
	jr l8df4h		;8dfd	18 f5 	. . 
	ld hl,l814dh		;8dff	21 4d 81 	! M . 
	ld c,001h		;8e02	0e 01 	. . 
	call sub_8edbh		;8e04	cd db 8e 	. . . 
	ld b,003h		;8e07	06 03 	. . 
	otir		;8e09	ed b3 	. . 
l8e0bh:
	djnz l8e0bh		;8e0b	10 fe 	. . 
	ld c,008h		;8e0d	0e 08 	. . 
	call sub_8edbh		;8e0f	cd db 8e 	. . . 
	ld a,07eh		;8e12	3e 7e 	> ~ 
	out (c),a		;8e14	ed 79 	. y 
	ld c,001h		;8e16	0e 01 	. . 
	call sub_8edbh		;8e18	cd db 8e 	. . . 
	ld a,0ceh		;8e1b	3e ce 	> . 
	out (c),a		;8e1d	ed 79 	. y 
	ld a,037h		;8e1f	3e 37 	> 7 
	out (c),a		;8e21	ed 79 	. y 
	ld c,000h		;8e23	0e 00 	. . 
	call sub_8edbh		;8e25	cd db 8e 	. . . 
	in a,(c)		;8e28	ed 78 	. x 
	in a,(c)		;8e2a	ed 78 	. x 
l8e2ch:
	call sub_8eb2h		;8e2c	cd b2 8e 	. . . 
l8e2fh:
	cp 010h		;8e2f	fe 10 	. . 
	jr nz,l8e2ch		;8e31	20 f9 	  . 
	call sub_8eb2h		;8e33	cd b2 8e 	. . . 
	cp 016h		;8e36	fe 16 	. . 
	jr nz,l8e2fh		;8e38	20 f5 	  . 
	call sub_8eb2h		;8e3a	cd b2 8e 	. . . 
	cp 005h		;8e3d	fe 05 	. . 
	jr nz,l8e2fh		;8e3f	20 ee 	  . 
	call sub_8eb2h		;8e41	cd b2 8e 	. . . 
l8e44h:
	ld hl,l8efdh		;8e44	21 fd 8e 	! . . 
	call sub_8ea9h		;8e47	cd a9 8e 	. . . 
	ld a,(0c001h)		;8e4a	3a 01 c0 	: . . 
	call sub_8ee5h		;8e4d	cd e5 8e 	. . . 
	ld a,(0c000h)		;8e50	3a 00 c0 	: . . 
	call sub_8ee5h		;8e53	cd e5 8e 	. . . 
	ld a,(0c002h)		;8e56	3a 02 c0 	: . . 
	call sub_8ee5h		;8e59	cd e5 8e 	. . . 
	ld a,005h		;8e5c	3e 05 	> . 
	call sub_8ee5h		;8e5e	cd e5 8e 	. . . 
	ld a,0ffh		;8e61	3e ff 	> . 
	call sub_8ee5h		;8e63	cd e5 8e 	. . . 
l8e66h:
	call sub_8eb2h		;8e66	cd b2 8e 	. . . 
	cp 002h		;8e69	fe 02 	. . 
	jr nz,l8e66h		;8e6b	20 f9 	  . 
	call sub_8ec8h		;8e6d	cd c8 8e 	. . . 
	ld d,a			;8e70	57 	W 
	ld e,000h		;8e71	1e 00 	. . 
	ld b,e			;8e73	43 	C 
	ld ix,0000ah		;8e74	dd 21 0a 00 	. ! . . 
	add ix,de		;8e78	dd 19 	. . 
	ld hl,00001h		;8e7a	21 01 00 	! . . 
l8e7dh:
	ld (de),a			;8e7d	12 	. 
	inc de			;8e7e	13 	. 
	ld c,a			;8e7f	4f 	O 
	add hl,bc			;8e80	09 	. 
l8e81h:
	call sub_8ec8h		;8e81	cd c8 8e 	. . . 
	cp 010h		;8e84	fe 10 	. . 
	jr nz,l8e7dh		;8e86	20 f5 	  . 
	call sub_8ec8h		;8e88	cd c8 8e 	. . . 
	cp 016h		;8e8b	fe 16 	. . 
	jr z,l8e81h		;8e8d	28 f2 	( . 
	cp 003h		;8e8f	fe 03 	. . 
	jr nz,l8e7dh		;8e91	20 ea 	  . 
	call sub_8ec8h		;8e93	cd c8 8e 	. . . 
	cp l			;8e96	bd 	. 
	jr nz,l8e44h		;8e97	20 ab 	  . 
	call sub_8ec8h		;8e99	cd c8 8e 	. . . 
	cp h			;8e9c	bc 	. 
	jr nz,l8e44h		;8e9d	20 a5 	  . 
	call sub_8ec8h		;8e9f	cd c8 8e 	. . . 
	xor a			;8ea2	af 	. 
	out (0a0h),a		;8ea3	d3 a0 	. . 
	out (0a1h),a		;8ea5	d3 a1 	. . 
	jp (ix)		;8ea7	dd e9 	. . 
sub_8ea9h:
	ld a,(hl)			;8ea9	7e 	~ 
	inc hl			;8eaa	23 	# 
	or a			;8eab	b7 	. 
	ret z			;8eac	c8 	. 
	call sub_8ee5h		;8ead	cd e5 8e 	. . . 
	jr sub_8ea9h		;8eb0	18 f7 	. . 
sub_8eb2h:
	call sub_8b8dh		;8eb2	cd 8d 8b 	. . . 
	ld c,001h		;8eb5	0e 01 	. . 
	call sub_8edbh		;8eb7	cd db 8e 	. . . 
	in a,(c)		;8eba	ed 78 	. x 
	and 002h		;8ebc	e6 02 	. . 
	jr z,sub_8eb2h		;8ebe	28 f2 	( . 
	ld c,000h		;8ec0	0e 00 	. . 
	call sub_8edbh		;8ec2	cd db 8e 	. . . 
	in a,(c)		;8ec5	ed 78 	. x 
	ret			;8ec7	c9 	. 
sub_8ec8h:
	ld c,001h		;8ec8	0e 01 	. . 
	call sub_8edbh		;8eca	cd db 8e 	. . . 
l8ecdh:
	in a,(c)		;8ecd	ed 78 	. x 
	and 002h		;8ecf	e6 02 	. . 
	jr z,l8ecdh		;8ed1	28 fa 	( . 
	ld c,000h		;8ed3	0e 00 	. . 
	call sub_8edbh		;8ed5	cd db 8e 	. . . 
	in a,(c)		;8ed8	ed 78 	. x 
	ret			;8eda	c9 	. 
sub_8edbh:
	ld a,(0c011h)		;8edb	3a 11 c0 	: . . 
	add a,a			;8ede	87 	. 
	add a,a			;8edf	87 	. 
	add a,a			;8ee0	87 	. 
	add a,a			;8ee1	87 	. 
	or c			;8ee2	b1 	. 
	ld c,a			;8ee3	4f 	O 
	ret			;8ee4	c9 	. 
sub_8ee5h:
	ld b,a			;8ee5	47 	G 
	ld c,001h		;8ee6	0e 01 	. . 
	call sub_8edbh		;8ee8	cd db 8e 	. . . 
l8eebh:
	call sub_8b8dh		;8eeb	cd 8d 8b 	. . . 
	in a,(c)		;8eee	ed 78 	. x 
	and 001h		;8ef0	e6 01 	. . 
	jr z,l8eebh		;8ef2	28 f7 	( . 
	ld c,000h		;8ef4	0e 00 	. . 
	call sub_8edbh		;8ef6	cd db 8e 	. . . 
	ld a,b			;8ef9	78 	x 
	out (c),a		;8efa	ed 79 	. y 
	ret			;8efc	c9 	. 
l8efdh:
	djnz l8f15h		;8efd	10 16 	. . 
	inc b			;8eff	04 	. 
	ld bc,00100h		;8f00	01 00 01 	. . . 
	rlca			;8f03	07 	. 
	nop			;8f04	00 	. 
	ld hl,l8fd9h		;8f05	21 d9 8f 	! . . 
	ld de,0c433h		;8f08	11 33 c4 	. 3 . 
	ldir		;8f0b	ed b0 	. . 
	ld a,001h		;8f0d	3e 01 	> . 
	ld (0c43ah),a		;8f0f	32 3a c4 	2 : . 
	ld a,(0c001h)		;8f12	3a 01 c0 	: . . 
l8f15h:
	ld (0c43bh),a		;8f15	32 3b c4 	2 ; . 
	ld a,(0c000h)		;8f18	3a 00 c0 	: . . 
	ld (0c43ch),a		;8f1b	32 3c c4 	2 < . 
	ld a,(0c002h)		;8f1e	3a 02 c0 	: . . 
	ld (0c43dh),a		;8f21	32 3d c4 	2 = . 
	ld a,010h		;8f24	3e 10 	> . 
	call sub_8fc6h		;8f26	cd c6 8f 	. . . 
	call sub_8f93h		;8f29	cd 93 8f 	. . . 
l8f2ch:
	jr nz,l8f32h		;8f2c	20 04 	  . 
	cp 001h		;8f2e	fe 01 	. . 
	jr z,l8f3ch		;8f30	28 0a 	( . 
l8f32h:
	ld a,02ch		;8f32	3e 2c 	> , 
	call sub_8fc6h		;8f34	cd c6 8f 	. . . 
	call sub_8f93h		;8f37	cd 93 8f 	. . . 
	jr l8f2ch		;8f3a	18 f0 	. . 
l8f3ch:
	in a,(010h)		;8f3c	db 10 	. . 
	ld (0c435h),a		;8f3e	32 35 c4 	2 5 . 
	in a,(010h)		;8f41	db 10 	. . 
	ld (0c437h),a		;8f43	32 37 c4 	2 7 . 
	call sub_8fafh		;8f46	cd af 8f 	. . . 
	call sub_8f6ah		;8f49	cd 6a 8f 	. j . 
	call sub_8f93h		;8f4c	cd 93 8f 	. . . 
	jr nz,l8f2ch		;8f4f	20 db 	  . 
	cp 006h		;8f51	fe 06 	. . 
	jr nz,l8f2ch		;8f53	20 d7 	  . 
	ld hl,0fde6h		;8f55	21 e6 fd 	! . . 
	ld bc,0021ah		;8f58	01 1a 02 	. . . 
l8f5bh:
	in a,(010h)		;8f5b	db 10 	. . 
	ld (hl),a			;8f5d	77 	w 
	inc hl			;8f5e	23 	# 
	dec bc			;8f5f	0b 	. 
	ld a,b			;8f60	78 	x 
	or c			;8f61	b1 	. 
	jr nz,l8f5bh		;8f62	20 f7 	  . 
	call sub_8fafh		;8f64	cd af 8f 	. . . 
	jp 0fe00h		;8f67	c3 00 fe 	. . . 
sub_8f6ah:
	ld a,00ah		;8f6a	3e 0a 	> . 
	call sub_8fc6h		;8f6c	cd c6 8f 	. . . 
	call sub_8fb8h		;8f6f	cd b8 8f 	. . . 
	ld hl,0c433h		;8f72	21 33 c4 	! 3 . 
	ld b,006h		;8f75	06 06 	. . 
	ld c,010h		;8f77	0e 10 	. . 
	otir		;8f79	ed b3 	. . 
	call sub_8fafh		;8f7b	cd af 8f 	. . . 
	ld a,00bh		;8f7e	3e 0b 	> . 
	call sub_8fc6h		;8f80	cd c6 8f 	. . . 
	call sub_8fb8h		;8f83	cd b8 8f 	. . . 
	ld hl,0c438h		;8f86	21 38 c4 	! 8 . 
	ld b,00bh		;8f89	06 0b 	. . 
	ld c,010h		;8f8b	0e 10 	. . 
	otir		;8f8d	ed b3 	. . 
	call sub_8fafh		;8f8f	cd af 8f 	. . . 
	ret			;8f92	c9 	. 
sub_8f93h:
	ld a,013h		;8f93	3e 13 	> . 
	call sub_8fc6h		;8f95	cd c6 8f 	. . . 
l8f98h:
	call sub_8fc0h		;8f98	cd c0 8f 	. . . 
	and 004h		;8f9b	e6 04 	. . 
	jr z,l8f98h		;8f9d	28 f9 	( . 
	ld a,002h		;8f9f	3e 02 	> . 
	call sub_8fc6h		;8fa1	cd c6 8f 	. . . 
	call sub_8fb8h		;8fa4	cd b8 8f 	. . . 
	in a,(010h)		;8fa7	db 10 	. . 
	ld b,a			;8fa9	47 	G 
	in a,(010h)		;8faa	db 10 	. . 
	cpl			;8fac	2f 	/ 
	cp b			;8fad	b8 	. 
	ret			;8fae	c9 	. 
sub_8fafh:
	in a,(010h)		;8faf	db 10 	. . 
	in a,(011h)		;8fb1	db 11 	. . 
	and 001h		;8fb3	e6 01 	. . 
	jr nz,sub_8fafh		;8fb5	20 f8 	  . 
	ret			;8fb7	c9 	. 
sub_8fb8h:
	call sub_8fc0h		;8fb8	cd c0 8f 	. . . 
	and 001h		;8fbb	e6 01 	. . 
	jr z,sub_8fb8h		;8fbd	28 f9 	( . 
	ret			;8fbf	c9 	. 
sub_8fc0h:
	call sub_8b8dh		;8fc0	cd 8d 8b 	. . . 
	in a,(011h)		;8fc3	db 11 	. . 
	ret			;8fc5	c9 	. 
sub_8fc6h:
	push af			;8fc6	f5 	. 
	call sub_8fc0h		;8fc7	cd c0 8f 	. . . 
	and 002h		;8fca	e6 02 	. . 
	ld b,a			;8fcc	47 	G 
	pop af			;8fcd	f1 	. 
	out (011h),a		;8fce	d3 11 	. . 
l8fd0h:
	call sub_8fc0h		;8fd0	cd c0 8f 	. . . 
	and 002h		;8fd3	e6 02 	. . 
	cp b			;8fd5	b8 	. 
	jr z,l8fd0h		;8fd6	28 f8 	( . 
	ret			;8fd8	c9 	. 
l8fd9h:
	ld b,000h		;8fd9	06 00 	. . 
	nop			;8fdb	00 	. 
	ld bc,00800h		;8fdc	01 00 08 	. . . 
	rst 30h			;8fdf	f7 	. 
l8fe0h:
	in a,(070h)		;8fe0	db 70 	Get Board ID in Slot 6
	xor 0bfh		;8fe2	ee bf 	. . 
	jr nz,l8fe8h		;8fe4	20 02 	  . 
	out (006h),a		;8fe6	d3 06 	If BoardID is 0xBF? Unknown
l8fe8h:
	jp l8800h		;8fe8	c3 00 88 	. . . 
	nop			;8feb	00 	. 
	nop			;8fec	00 	. 
	nop			;8fed	00 	. 
	nop			;8fee	00 	. 
	nop			;8fef	00 	. 
	nop			;8ff0	00 	. 
	nop			;8ff1	00 	. 
	nop			;8ff2	00 	. 
	nop			;8ff3	00 	. 
	nop			;8ff4	00 	. 
	nop			;8ff5	00 	. 
	nop			;8ff6	00 	. 
	nop			;8ff7	00 	. 
	nop			;8ff8	00 	. 
	nop			;8ff9	00 	. 
	ld d,d			;8ffa	52 	R 
	ld b,l			;8ffb	45 	E 
	ld d,(hl)			;8ffc	56 	V 
	dec l			;8ffd	2d 	- 
	ld b,d			;8ffe	42 	B 
	ld c,e			;8fff	4b 	K 

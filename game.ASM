
format binary as ""                     ; Binary file format without extension

use32                                   ; Tell compiler to use 32 bit instructions

org 0                                   ; the base address of code, always 0x0

; The header

db 'MENUET01'
dd 1
dd START
dd I_END
dd MEM
dd STACKTOP
dd 0, 0

include 'macros.inc'
include 'syscalls.inc'
include 'utils.asm'

WIN_X			equ		100
WIN_Y			equ		100
WIN_W			equ		400
WIN_H			equ		300

WIN_FRAME_W		equ		6
WIN_HEADER_H	equ		25

WIN_AREA_COLOR	equ		0x14ff0000
RECT_X			equ		0
RECT_Y			equ		0
RECT_W			equ		20
RECT_H			equ		20
RECT_COLOR		equ		0x8000ff00

START:
	call draw_window
event_loop:
	;; event ga tekshirish kerak
	mov		eax,	SYS_delay
	mov		ebx,	3
	mcall

	mov		eax,	SYS_check_for_event
	mcall

	cmp		eax,	1
	je		redraw

	cmp		eax,	3
	je		button

	call	draw_rectangle

	jmp event_loop

redraw:
	call	draw_window
	jmp		event_loop

button:
	mov		eax,	SYS_get_button_info
	mcall

	cmp		eax,	1
	je		event_loop

	mov		eax,	-1
	mcall

draw_window:
	sys_win_begin_draw

	mov		eax,	SYS_draw_window
	mov		ebx,	WIN_X shl 16 + WIN_W
	mov		ecx,	WIN_Y shl 16 + WIN_H
	mov		edx,	WIN_AREA_COLOR
	mov		esi,	0x808899ff
	mov		edi,	title
	mcall

	sys_win_end_draw
	ret

collides_with_left:
	;; input:
	;;	eax - x coord
	;;
	;;	returns:
	;;		eax = 1 if collides with left else 0
	cmp		eax,	WIN_FRAME_W
	jl		.collides
	xor		eax,	eax
	ret
	.collides:
	mov		eax,	1
	ret

collides_with_right:
	cmp		eax,	WIN_W - WIN_FRAME_W - RECT_W
	jg		.collides
	xor		eax,	eax
	ret
	.collides:
	mov		eax,	1
	ret

collides_with_top:
	cmp		eax,	WIN_HEADER_H
	jl		.collides
	xor		eax,	eax
	ret
	.collides:
	mov		eax,	1
	ret

collides_with_bottom:
	cmp		eax,	WIN_H - WIN_FRAME_W - RECT_H
	jg		.collides
	xor		eax,	eax
	ret
	.collides:
	mov		eax,	1
	ret

draw_rectangle:
	push	eax
	push	ebx
	push	ecx
	push	edx

	;; eski rectangle ni tozalab yuboramiz
	sys_draw_rectangle [ball_x],[ball_y],RECT_W,RECT_H,WIN_AREA_COLOR

	;;	x coord ni incr qildik
	mov		eax,	[ball_x]
	add		eax,	[ball_x_inc]

	mov		ebx,	eax
	call	collides_with_left
	cmp		eax,	0
	je		.not_collides_with_left
	mov		ebx,	WIN_FRAME_W
	neg		[ball_x_inc]
	.not_collides_with_left:
	mov		[ball_x],	ebx

	mov		eax,	[ball_x]
	call	collides_with_right
	cmp		eax,	0
	je		.not_collides_with_right
	mov		[ball_x],	WIN_W - WIN_FRAME_W - RECT_W
	neg		[ball_x_inc]

	.not_collides_with_right:

	;; y coord ni incr qilamiz
	mov		eax,	[ball_y]
	add		eax,	[ball_y_inc]

	;; tepa bilan to'qnashishni tekshiramiz
	mov		ebx,	eax
	call	collides_with_top
	cmp		eax,	0
	je		.not_collides_with_top
	mov		ebx,	WIN_HEADER_H
	neg		[ball_y_inc]
	.not_collides_with_top:
	mov		[ball_y],	ebx

	;; past bilan to'qnashishni tekshiramiz
	mov		eax,	[ball_y]
	call	collides_with_bottom
	cmp		eax,	0
	je		.not_collides_with_bottom
	neg		[ball_y_inc]
	mov		[ball_y],	WIN_H - WIN_FRAME_W - RECT_H

	.not_collides_with_bottom:

	mov		eax,	[ball_color]
	;; qizilni o'zgartiramiz
	ror		eax,	16
	add		al,		1
	;; yashilni o'zgartiramiz
	rol		eax,	8
	add		al,		2
	;; ko'kni o'zgartiamiz
	rol		eax,	8
	add		al,		3

	mov		[ball_color],	eax

	sys_draw_rectangle [ball_x],[ball_y],RECT_W,RECT_H,[ball_color]

	pop		edx
	pop		ecx
	pop		ebx
	pop		eax

	ret

title:
	db	"Hello,World!",0

ball_x		dd		WIN_FRAME_W
ball_y		dd		WIN_HEADER_H
ball_x_inc	dd		3
ball_y_inc	dd		3

ball_color	dd		0x00ff00

I_END:
        rb 4096
align 16
STACKTOP:

MEM:

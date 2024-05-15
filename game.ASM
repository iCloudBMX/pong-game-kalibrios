
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

PADDLE_H		equ		10
PADDLE_W		equ		25
PADDLE_COLOR	equ		0x80c3d6c5

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

	cmp		eax,	2
	je		key_pressed

	cmp		eax,	3
	je		button_pressed

	call	update_ball_pos

	jmp event_loop

redraw:
	call	draw_window
	jmp		event_loop

key_pressed:
	mov		eax,	SYS_get_key_info
	mcall

	cmp		eax,	1
	je		event_loop
	call	update_paddle_pos
	jmp		event_loop

button_pressed:
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

update_paddle_pos:
	cmp		ah,		key_right_arrow
	je		.to_right
	cmp		ah,		key_left_arrow
	je		.to_left
	jmp		.update_end

	.to_right:
	sys_draw_rectangle [paddle_x],[paddle_y],PADDLE_W,PADDLE_H,WIN_AREA_COLOR
	mov		edi,	title
	movzx	eax,	ah
	call	to_string
	call	draw_window

	mov		eax,	[paddle_x]
	add		eax,	[paddle_speed]
	cmp		eax,	WIN_W - WIN_FRAME_W - PADDLE_W
	jg		.update_end
	mov		[paddle_x],	eax
	jmp		.update_end

	.to_left:
	sys_draw_rectangle [paddle_x],[paddle_y],PADDLE_W,PADDLE_H,WIN_AREA_COLOR
	mov		eax,	[paddle_x]
	sub		eax,	[paddle_speed]
	cmp		eax,	WIN_FRAME_W
	jl		.update_end
	mov		[paddle_x],	eax
	jmp		.update_end

	.update_end:
	sys_draw_rectangle [paddle_x],[paddle_y],PADDLE_W,PADDLE_H,PADDLE_COLOR

	ret

update_ball_pos:
	push	eax
	push	ebx
	push	ecx
	push	edx

	;; eski rectangle ni tozalab yuboramiz
	sys_draw_rectangle [ball_x],[ball_y],RECT_W,RECT_H,WIN_AREA_COLOR

	;;	x coord ni incr qildik
	mov		eax,	[ball_x]
	add		eax,	[ball_x_speed]

	mov		ebx,	eax
	call	collides_with_left
	cmp		eax,	0
	je		.not_collides_with_left
	mov		ebx,	WIN_FRAME_W
	neg		[ball_x_speed]
	.not_collides_with_left:
	mov		[ball_x],	ebx

	mov		eax,	[ball_x]
	call	collides_with_right
	cmp		eax,	0
	je		.not_collides_with_right
	mov		[ball_x],	WIN_W - WIN_FRAME_W - RECT_W
	neg		[ball_x_speed]

	.not_collides_with_right:

	;; y coord ni incr qilamiz
	mov		eax,	[ball_y]
	add		eax,	[ball_y_speed]

	;; tepa bilan to'qnashishni tekshiramiz
	mov		ebx,	eax
	call	collides_with_top
	cmp		eax,	0
	je		.not_collides_with_top
	mov		ebx,	WIN_HEADER_H
	neg		[ball_y_speed]
	.not_collides_with_top:
	mov		[ball_y],	ebx

	;; past bilan to'qnashishni tekshiramiz
	mov		eax,	[ball_y]
	call	collides_with_bottom
	cmp		eax,	0
	je		.not_collides_with_bottom
	neg		[ball_y_speed]
	mov		[ball_y],	WIN_H - WIN_FRAME_W - RECT_H

	.not_collides_with_bottom:

	sys_draw_rectangle [ball_x],[ball_y],RECT_W,RECT_H,RECT_COLOR

	pop		edx
	pop		ecx
	pop		ebx
	pop		eax

	ret

title:
	db	"Hello,World!",0

ball_x		dd		WIN_FRAME_W
ball_y		dd		WIN_HEADER_H
ball_x_speed	dd		3
ball_y_speed	dd		3

paddle_x		dd		WIN_W/2 - PADDLE_W/2
paddle_y		dd		WIN_H - PADDLE_H - WIN_FRAME_W
paddle_speed 	dd		5


I_END:
        rb 4096
align 16
STACKTOP:

MEM:

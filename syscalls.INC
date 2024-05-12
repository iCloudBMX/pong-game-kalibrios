
SYS_draw_window		equ		0
SYS_check_for_event	equ		11
SYS_get_button_info	equ		17
SYS_draw_rectangle	equ		13
SYS_delay			equ		5

macro sys_win_begin_draw
{
	mov		eax,	12
	mov		ebx,	1
	mcall
}

macro sys_win_end_draw
{
	mov		eax,	12
	mov		ebx,	2
	mcall
}

macro sys_draw_rectangle x,y,w,h,color
{
	mov		eax,	SYS_draw_rectangle
	mov		ebx,	x
	;; add		ebx,	6		; frame w
	shl		ebx,	16
	add		ebx,	w
	mov		ecx,	y
	;; add		ecx,	25
	shl		ecx,	16
	add		ecx,	h
	mov		edx,	color
	mcall
}


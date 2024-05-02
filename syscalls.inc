SYS_draw_window		equ		0
SYS_check_for_event	equ		11
SYS_get_button_info	equ		17

macro sys_win_begin_draw
{
	mov eax, 12
	mov	ebx, 1
	mcall
}

macro sys_win_end_draw
{
	mov	eax, 12
	mov	ebx, 2
	mcall
}
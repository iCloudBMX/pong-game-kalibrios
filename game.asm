format binary as ""          ; Binary file format without extension

use32                        ; Tell compiler to use 32 bit instructions

org 0                        ; the base address of code, always 0x0

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

WIN_X equ 100
WIN_Y equ 100
WIN_W equ 400
WIN_H equ 300
	
START:
	call draw_window
event_loop:
	;; event ga tekshirish kerak
	mov eax, SYS_check_for_event
	mcall
	
	cmp eax, 1
	je redraw
	
	cmp eax, 3
	je button
	
	jmp event_loop
	
redraw:
	call draw_window
	jmp event_loop
	
button:
	mov eax, SYS_get_button_info
	mcall
	
	cmp eax, 1
	jmp event_loop
	
	mov eax, - 1
	mcall
	
draw_window:
	sys_win_begin_draw
	
	mov eax, SYS_draw_window
	mov ebx, WIN_X shl 16 + WIN_W
	mov ecx, WIN_Y shl 16 + WIN_H
	mov edx, 0x14ff0000
	mov esi, 0x808899ff
	mov edi, title
	mcall
	
	sys_win_end_draw
	ret
	
title:
	db "Hello, World!", 0
	
I_END:
	rb 4096
	align 16
STACKTOP:
	
MEM:
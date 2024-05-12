to_string:
  ;; input
  ;;     eax = the int to convert
  ;;     edi = address of the result
  ;; output:
  ;;     None

    xor   ebx, ebx        ; clear the ebx, I will use as counter for stack pushes

.push_chars:
    xor edx, edx          ; clear edx
    mov ecx, 10           ; ecx is divisor, divide by 10
    div ecx               ; divide edx by ecx, result in eax remainder in edx
    add edx, 0x30         ; add 0x30 to edx convert int => ascii
    push edx              ; push result to stack
    inc ebx               ; increment my stack push counter
    test eax, eax         ; is eax 0?
    jnz .push_chars       ; if eax not 0 repeat

.pop_chars:
    pop eax               ; pop result from stack into eax
    stosb                 ; store contents of eax in at the address of num which is in EDI
    dec ebx               ; decrement my stack push counter
    cmp ebx, 0            ; check if stack push counter is 0
    jg .pop_chars         ; not 0 repeat
    mov eax, 0x0a
    stosb                 ; add line feed
    ret                   ; return to main



increment_and_check_point:
	;;	Input:
	;;	point - stack 0 - 4 bytes	ebp + 12 - ptr
	;;	start - stack 1 - 4 bytes	ebp + 16
	;; 	end   - stack 2 - 4 bytes	ebp + 20
	;;  inc   - stack 3 - 4 bytes   ebp + 24 - ptr

	push	ebp
	mov		ebp,	esp
	push	eax
	push	ebx
	push	edx

	mov		eax,	[ebp+8]
	mov		eax,	[eax]
	mov		edx,	[ebp+20]
	mov		edx,	[edx]				; edx = inc_val
	add		eax,	edx

	cmp		eax,	[ebp+12]
	jg		.l1
	neg		edx
	mov		eax,	[ebp+12]

	.l1:
	cmp		eax,	[ebp+16]
	jl		.l2
	neg		edx
	mov		eax,	[ebp+16]

	.l2:
	mov		ebx,	[ebp+8]
	mov		[ebx],	eax
	mov		ebx,	[ebp+20]
	mov		[ebx],	edx

	pop		edx
	pop		ebx
	pop		eax
	mov		esp,	ebp
	pop		ebp
	ret		16


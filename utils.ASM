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

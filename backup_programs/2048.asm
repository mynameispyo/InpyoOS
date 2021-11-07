move_left:
    mov ah, 0 ; spaces left
    mov ch, 0 ; i
    mov cl, 0 ; space -i or
    mov bl, 0 ; j
    mov ch, 0 ; i * 4+3
    mov dl, 0 ; data
    mov dh, 0 ; data

.each_row: ; for (BYTE j = 0; j <= 3; j++)
    cmp ch, 3
    jle .each_col
    jmp move

.each_col:
    mov ah, 0
    mov bl, ch

    add bl, bl ; bl * 4 for 4-byte per nums
    add bl, bl
    
    mov ch, bl
    add ch, 3

.each_col_loop:

    cmp bl, ch
    jg .next_row

    movzx bx, bl
    mov ax, bx
    call os_print_4hex

    mov byte dh, [board + bx] 
    cmp dh, 0 ; board[i] == 0
    je .iter_space
    
    mov cl, bl
    sub cl, ah
    dec cl
    
    cmp cl, 0
    jge near .if_greater_than_zero

    jmp .check_zero_then_move_ele_right_next

.if_greater_than_zero:
    movzx bx, bl
    mov ch, [board + bx]

    cmp dl, dh
    je .com_two_ele

    jmp .check_zero_then_move_ele_right_next

.com_two_ele:
    inc dl
    movzx bx, cl
    mov [board + bx], byte dl
    movzx bx, bl
    mov byte [board + bx], 0
    inc ah

    inc bl
    jmp .each_col_loop

.check_zero_then_move_ele_right_next:
    inc cl ; i-space
    movzx bx, cl
    mov byte ch, [board + bx]
    cmp dl, 0
    je .move_ele_right_next

    inc bl
    jmp .each_col_loop

.move_ele_right_next:
    movzx bx, cl
    mov [board + bx], dh
    movzx bx, bl
    mov byte [board + bx], 0
    
    inc bl
    jmp .each_col_loop

.next_row:
    inc ch
    jmp .each_row

.iter_space:
    inc ah
    inc bl
    jmp .each_col_loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

move_left:
    mov ax, 0 ; spaces left
    mov cx, 0 ; i
    mov bx, 0 ; j
    mov dx, 0 ; i * 4+3
    mov ch, 0 ; last value

.each_row: ; for (BYTE j = 0; j <= 3; j++)
    cmp cx, 3
    jle .each_col
    jmp move

.each_col:
    mov ax, 0
    mov bx, cx

    add bx, bx ; bx * 4 for 4-byte per nums
    add bx, bx
    
    mov dx, bx
    add dx, 3

.each_col_loop:

    cmp bx, dx
    jg .next_row

    mov byte dh, [board + bx] 
    cmp dh, 0 ; board[i] == 0
    je .iter_space
    
    push cx ; i-space-1 for this time

    mov cx, bx
    sub cx, ax
    
    cmp cx, 1
    jge .if_greater_than_zero

    jmp .check_zero_then_move_ele_right_next

.if_greater_than_zero:
    push bx
    mov bx, cx
    dec bx
    mov ch, [board + bx]
    pop bx

    cmp ch, dh ; board[i-space-1] == board[i]
    je .com_two_ele

    jmp .check_zero_then_move_ele_right_next

.com_two_ele:
    mov byte [board + bx], 0
    add ch, 1
    push bx
    mov bx, cx
    dec bx
    mov [board + bx], byte 4
    pop bx

    inc ax ;space++;

    pop cx

    inc bx
    jmp .each_col_loop

.check_zero_then_move_ele_right_next:
    push bx
    mov bx, cx
    mov byte ch, [board + bx]
    pop bx
    cmp ch, 0
    je .move_ele_right_next

    pop cx
    
    inc bx
    jmp .each_col_loop

.move_ele_right_next:
    push bx
    mov bx, cx
    mov [board + bx], dh
    pop bx
    mov byte [board + bx], 0
    
    pop cx

    inc bx
    jmp .each_col_loop

.next_row:
    inc cx
    jmp .each_row

.iter_space:
    inc ax
    inc bx
    jmp .each_col_loop

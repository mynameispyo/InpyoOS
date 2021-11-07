; ------------------------------------------------------------------
; MichalOS Sudoku
; ------------------------------------------------------------------

	BITS 16
	%INCLUDE "osdev.inc"
	ORG 100h

start:
	call draw_background
	call os_hide_cursor

.loop:
	call check_board
	call draw_board
	call os_wait_for_key
	
	cmp al, '0'
	jl .not_a_number
	
	cmp al, '9'
	jle .put_number
	
.not_a_number:
	cmp ah, 72
	je .go_up
	
	cmp ah, 75
	je .go_left
	
	cmp ah, 77
	je .go_right
	
	cmp ah, 80
	je .go_down
	
	cmp al, 27
	jne .loop
	ret
	
.put_number:
	sub al, '0' - 10
	
	cmp al, 10
	jne .no_clear

	mov al, 0
	
.no_clear:
	mov dx, [cursor_x]	; Load the entire word
	call sub_set_board_number
	jmp .loop
	
.go_up:
	cmp byte [cursor_y], 0
	je .loop
	
	dec byte [cursor_y]
	jmp .loop
	
.go_down:
	cmp byte [cursor_y], 8
	je .loop
	
	inc byte [cursor_y]
	jmp .loop
	
.go_left:
	cmp byte [cursor_x], 0
	je .loop
	
	dec byte [cursor_x]
	jmp .loop
	
.go_right:
	cmp byte [cursor_x], 8
	je .loop
	
	inc byte [cursor_x]
	jmp .loop
	
check_board:
	pusha
	call check_free_spaces

	mov dx, 0
	
.check_loop:
	call check_horizontal_lines
	call check_vertical_lines
	
	inc dl
	cmp dl, 9
	jne .check_loop
	
	mov dl, 0
	inc dh
	cmp dh, 9
	jne .check_loop
	
	popa
	ret
	
check_vertical_lines:
	pusha
	mov [.cursor_x], dx

	call sub_get_board_number
	cmp al, 10
	jl .end
	
	call sub_adjust_board_number
	mov bl, al
	
	mov dh, -1
	
.loop:
	inc dh
	call sub_get_board_number
	call sub_adjust_board_number

	cmp dh, [.cursor_y]
	je .loop
	
	cmp dh, 9
	je .end

	cmp al, bl
	jne .no_bad
	
	pusha
	add al, 20
	mov dx, [.cursor_x]
	call sub_set_board_number
	popa
	
.no_bad:
	jmp .loop

.end:
	popa
	ret
	
	.cursor_x	db 0
	.cursor_y	db 0
	
check_horizontal_lines:
	pusha
	mov [.cursor_x], dx
	
	call sub_get_board_number
	cmp al, 10
	jl .end
	
	call sub_adjust_board_number
	mov bl, al
	
	mov dl, -1
	
.loop:
	inc dl
	call sub_get_board_number
	call sub_adjust_board_number

	cmp dl, [.cursor_x]
	je .loop
	
	cmp dl, 9
	je .end

	cmp al, bl
	jne .no_bad
	
	pusha
	add al, 20
	mov dx, [.cursor_x]
	call sub_set_board_number
	popa
	
.no_bad:
	jmp .loop

.end:
	popa
	ret
	
	.cursor_x	db 0
	.cursor_y	db 0
	
sub_adjust_board_number:
	pusha
	cmp al, 10
	jl .no_adjust
	
	sub al, 10

	cmp al, 10
	jl .no_adjust
	
	sub al, 10
	
.no_adjust:
	mov [.tmp], al
	popa
	mov al, [.tmp]
	ret
	
	.tmp	db 0

check_free_spaces:
	pusha
	mov si, [level_pointer]
	mov bx, 0
	mov cx, 0
	
.loop:
	lodsb
	cmp al, 0
	jne .no_free_space
	
	inc cx
	
.no_free_space:
	inc bx
	cmp bx, 81
	jne .loop
	
	mov dh, 22
	mov dl, 1
	call os_move_cursor
	
	mov si, .free_msg
	call os_print_string
	mov ax, cx
	call os_int_to_string
	mov si, ax
	call os_print_string

	popa
	ret

	.free_msg	db 'Free spaces: ', 0
	
draw_board:
	pusha
	mov dl, 27
	mov dh, 5
	call os_move_cursor

	mov bx, 0
	call sub_draw_line
	inc dh
	call os_move_cursor

	mov si, .x_spacer
	call os_print_string


	mov si, [level_pointer]

	mov cx, 0
	
.loop:
	lodsb

	cmp al, 10
	jl .no_adjust
	
	sub al, 10
	pusha
	mov ax, 0920h
	mov bx, 0Fh
	mov cx, 1
	int 10h
	popa
	
	cmp al, 10
	jl .no_adjust
	
	sub al, 10
	pusha
	mov ax, 0920h
	mov bx, 0Ch
	mov cx, 1
	int 10h
	popa
	
.no_adjust:
	cmp al, 0
	je .no_print

	call os_print_1hex
	jmp .print_end
	
.no_print:
	call os_print_space

.print_end:
	call os_print_space
	inc cl
	cmp cl, 3
	jne .no_x_spacer
	
	pusha
	mov si, .x_spacer
	call os_print_string
	popa
	
	mov cl, 0

	inc ch
	cmp ch, 3
	jne .no_x_spacer
	
	mov ch, 0
	inc dh
	call os_move_cursor
	
	inc bl
	cmp bl, 3
	jne .no_y_spacer
	
	mov bl, 0

	inc bh
	call sub_draw_line
	inc dh
	call os_move_cursor

	cmp dh, 5 + 13
	je .exit
	
.no_y_spacer:	
	pusha
	mov si, .x_spacer
	call os_print_string
	popa

.no_x_spacer:
	jmp .loop

.exit:
	movzx bx, byte [cursor_x]
	mov dl, [.x_cursor_coords + bx]
	
	movzx bx, byte [cursor_y]
	mov dh, [.y_cursor_coords + bx]
	
	call os_move_cursor
	
	mov ax, 0910h
	mov bx, 0Eh
	mov cx, 1
	int 10h
	
	add dl, 2
	call os_move_cursor
	
	mov al, 11h
	int 10h
	
	popa
	ret
	
	.x_spacer			db 0B3h, 020h, 0
	.x_cursor_coords	db 28, 30, 32, 36, 38, 40, 44, 46, 48
	.y_cursor_coords	db 6, 7, 8, 10, 11, 12, 14, 15, 16
	
sub_get_board_number:	; In: DL/DH = X/Y position, out: AL = number
	pusha
	mov al, dh
	mov bl, 9
	mul bl
	
	add al, dl
	movzx si, al
	add si, [level_pointer]
	lodsb
	
	mov [.tmp], al
	popa
	mov al, [.tmp]
	ret
	
	.tmp	db 0

sub_set_board_number:	; In: DL/DH = X/Y position, AL = number
	pusha
	push ax

	mov al, dh
	mov bl, 9
	mul bl
	
	add al, dl
	movzx di, al
	add di, [level_pointer]
	pop ax

	cmp byte [di], 1
	jl .free_space
	
	cmp byte [di], 10
	jl .exit
	
.free_space:
	stosb

.exit:
	popa
	ret
	
sub_draw_line:		; In: BH = line number (0-3)
	pusha
	shl bh, 2
	movzx bx, bh
	mov si, .chars_top
	add si, bx
	
	lodsb
	call sub_putchar
	
	mov dx, 3
	mov cx, 7
	
.loop:
	mov al, 0C4h
	call sub_putchar
	loop .loop
	
	lodsb
	call sub_putchar
	
	mov cx, 7
	dec dx
	cmp dx, 0
	jne .loop
	
	popa
	ret
	
	.chars_top		db 0DAh, 0C2h, 0C2h, 0BFh
	.chars_center1	db 0C3h, 0C5h, 0C5h, 0B4h
	.chars_center2	db 0C3h, 0C5h, 0C5h, 0B4h
	.chars_bottom	db 0C0h, 0C1h, 0C1h, 0D9h

sub_putchar:
	pusha
	mov ah, 0Eh
	mov bh, 0
	int 10h
	popa
	ret
	
draw_background:
	mov ax, .title_msg
	mov bx, .footer_msg
	mov cx, 7
	call os_draw_background
	ret
	
	.title_msg			db 'InpyoOS Sudoku', 0
	.footer_msg			db 18h, 2Fh, 19h, 2Fh, 1Bh, 2Fh, 1Ah, ' - Move the cursor, [1-9] - Enter a number, 0 - Clear', 0
	
; ------------------------------------------------------------------

level_pointer	dw level_easy
cursor_x		db 0
cursor_y		db 0

level_easy:
db 0, 5, 0, 0, 8, 1, 0, 0, 7
db 4, 6, 0, 0, 0, 0, 3, 5, 0
db 0, 0, 1, 3, 4, 0, 0, 6, 0
db 0, 0, 4, 8, 0, 6, 0, 0, 9
db 8, 0, 7, 0, 5, 0, 2, 0, 6
db 6, 0, 0, 1, 0, 2, 7, 0, 0
db 0, 1, 0, 0, 3, 4, 6, 0, 0
db 0, 8, 6, 0, 0, 0, 0, 2, 3
db 2, 0, 0, 7, 6, 0, 0, 9, 0

level_medium:
db 0, 7, 0, 0, 2, 0, 0, 3, 0
db 8, 0, 0, 0, 0, 0, 0, 0, 9
db 0, 0, 5, 0, 9, 0, 4, 0, 0
db 0, 5, 0, 0, 8, 0, 0, 4, 0
db 3, 0, 1, 9, 0, 7, 6, 0, 2
db 0, 9, 0, 0, 6, 0, 0, 8, 0
db 0, 0, 9, 0, 7, 0, 8, 0, 0
db 1, 0, 0, 0, 0, 0, 0, 0, 6
db 0, 4, 0, 0, 5, 0, 0, 7, 0

level_hard:
db 0, 0, 0, 1, 6, 8, 0, 0, 0
db 0, 0, 0, 4, 7, 9, 1, 0, 0
db 0, 0, 0, 0, 0, 0, 0, 0, 0
db 2, 0, 0, 0, 0, 6, 4, 0, 7
db 1, 0, 0, 3, 0, 0, 5, 0, 9
db 0, 0, 9, 0, 0, 7, 0, 8, 0
db 0, 0, 0, 0, 0, 0, 2, 0, 0
db 0, 0, 8, 0, 0, 0, 7, 0, 3
db 0, 0, 5, 6, 4, 3, 0, 0, 0

; ------------------------------------------------------------------
; MichalOS Memory Editor
; ------------------------------------------------------------------

	BITS 16
	%INCLUDE "michalos.inc"
	ORG 100h

start:
	call .draw_background
	mov dl, 10
	mov dh, 4
	call os_move_cursor
	mov al, 0

.hexcharsloop1:
	call os_print_2hex
	call os_print_space
	inc al
	cmp al, 16
	jl .hexcharsloop1
	
	call os_print_space
	mov al, 0
	
.hexcharsloop2:
	call os_print_1hex
	inc al
	cmp al, 16
	jl .hexcharsloop2
	
;	call os_print_string

.loop:
	call .draw

	lodsb
	cmp al, 'Q'				; 'Q' typed?
	je near .exit
	cmp al, 'A'
	je near .inputaddress
	cmp al, 'D'
	je near .inputdata
	cmp al, 'R'
	je near .runcode
	cmp al, 'H'
	je near .help
	cmp al, 'S'
	je near .save
	cmp al, 'L'
	je near .load
	jmp .loop
	
.save:
	lodsb
	cmp al, 'D'
	je near .savedecimal
	cmp al, 'H'
	je near .savehexadecimal
	jmp .loop
	
.savedecimal:
	sub si, 2
	call os_string_parse
	add ax, 2
	mov si, ax
	call os_string_to_int
	
	jmp .copy
	
.savehexadecimal:
	sub si, 2
	call os_string_parse
	add ax, 2
	mov si, ax
	call os_string_to_hex
	
.copy:
	push bx			; Store the filename
	mov cx, ax
	push cx			; Store the file size
	mov esi, [.address]
	sub esi, 65536
	mov edi, 20000h - 65536

.copy_loop:
	mov al, [esi]
	mov [edi], al
	inc esi
	inc edi
	dec cx
	cmp cx, 0
	jne .copy_loop
	
	; Save the file

	mov bx, 0
	pop cx
	pop ax
	push es
	mov dx, 2000h
	mov es, dx
	call os_write_file
	pop es
	
	jc .error
	
	jmp .loop	

.load:
	mov ax, si
	
	push es
	push ax
	mov ax, 2000h
	mov es, ax
	pop ax
	mov cx, 0
	call os_load_file
	pop es
	
	jc .error
	
	mov cx, bx
	mov edi, [.address]
	sub edi, 65536
	mov esi, 10000h

.load_loop:
	mov al, [esi]
	mov [edi], al
	inc esi
	inc edi
	dec cx
	cmp cx, 0
	jne .load_loop
	
	jmp .loop	


.help:
	mov ax, .help_msg0
	mov bx, .help_title0
	mov cx, .help_title1
	call os_list_dialog
	
	jmp start
	
.inputaddress:
	lodsb
	cmp al, 'D'
	je near .addressdecimal
	cmp al, 'H'
	je near .addresshexadecimal
	jmp .loop
	
.addressdecimal:
	call os_string_to_32int
	mov [.address], eax
	jmp .loop
	
.addresshexadecimal:
	call os_string_to_hex
	mov [.address], eax
	jmp .loop
	
.inputdata:
	lodsb
	cmp al, 'D'
	je near .datadecimal
	cmp al, 'H'
	je near .datahexadecimal
	jmp .loop
	
.datadecimal:
	mov byte [.data_mode], 1
	call .draw
	mov byte [.data_mode], 0
	
	cmp byte [si], 'Q'
	je .loop

	call os_string_to_32int
	mov esi, [.address]
	mov [esi-65536], al
	inc dword [.address]
	jmp .datadecimal
	
.datahexadecimal:
	mov byte [.data_mode], 1
	call .draw
	mov byte [.data_mode], 0
	
	cmp byte [si], 'Q'
	je .loop

	call os_string_to_hex
	mov esi, [.address]
	mov [esi-65536], al
	inc dword [.address]
	jmp .datahexadecimal
	
.runcode:
	lodsb
	inc si
	cmp al, 'D'
	je near .codedecimal
	cmp al, 'H'
	je near .codehexadecimal
	jmp .loop

.codedecimal:
	call os_string_to_32int
	
	jmp .long_call
	
.codehexadecimal:
	call os_string_to_hex
	
	jmp .long_call
	
.draw:
	call .bardraw
	
	call .datadraw
	
	call .asciidraw
	
	mov dl, 0				; Print the input label
	mov dh, 2
	call os_move_cursor
	cmp byte [.data_mode], 0
	je .normal_label
	
	mov si, .data_label
	call os_print_string
	
	jmp .finish_label
	
.normal_label:
	mov si, .input_label
	call os_print_string
	
.finish_label:
	mov ah, 09h				; Clear the screen for the next input
	mov al, ' '
	mov bh, 0
	mov bl, [57000]
	mov cx, 60
	int 10h
	
	mov dl, 40
	mov dh, 2
	call os_move_cursor
	mov eax, [.address]
	call os_print_8hex

	mov dl, 2
	mov dh, 2
	call os_move_cursor
	call os_show_cursor		; Get a command from the user
	mov ax, .input_buffer
	call os_input_string
	
	mov si, .input_buffer	; Decode the command
	call os_string_uppercase

	ret
	
.asciidraw:
	pusha
	
	mov dl, 59
	mov dh, 6
	call os_move_cursor

	mov esi, [.address]
	and esi, 0FFFFFFF0h	; Mask off the lowest 4 bits (divide by 16)
	
.asciiloop:
	mov al, [esi-65536-40h]
	inc esi

	cmp al, 32
	jge near .asciichar
	mov al, '.'
	
.asciichar:
	mov ah, 0Eh
	mov bh, 0
	int 10h
	
	call os_get_cursor_pos
	cmp dl, 75
	jl .asciiloop
	
	mov dl, 59
	inc dh	
	call os_move_cursor

	cmp dh, 22
	jl .asciiloop
	
	popa
	ret

.datadraw:
	pusha

	mov dl, 10
	mov dh, 6
	call os_move_cursor
	
	mov esi, [.address]
	and esi, 0FFFFFFF0h	; Mask off the lowest 4 bits (divide by 16)

.dataloop:
	mov al, [esi-65536-40h]
	inc esi
	
	call os_print_2hex
		
	call os_print_space
		
	call os_get_cursor_pos
	cmp dl, 58
	jl .dataloop
	
	mov dl, 10
	inc dh	
	call os_move_cursor

	cmp dh, 22
	jl .dataloop
	
	popa
	ret
	
.exit:
	call os_clear_screen
	ret

.draw_background:
	mov ax, .title_msg
	mov bx, .footer_msg
	mov cx, [57000]
	call os_draw_background
	ret

.bardraw:
	mov dl, 0
	mov dh, 6
	call os_move_cursor
	mov eax, [.address]
	and eax, 0FFFFFFF0h
	sub eax, 40h
	mov cl, 0
.barloop:
	call os_print_space
	call os_print_8hex
	call os_print_newline
	add eax, 16
	inc cl
	cmp cl, 16
	jne .barloop
	
	ret
	
.error:
	mov ax, .error_msg
	mov bx, 0
	mov cx, 0
	mov dx, 0
	call os_dialog_box
	jmp start
	
.long_call:
	mov [.call_address], ax
	shr eax, 4
	and ax, 0F000h			; Make it a segment
	mov [.call_segment], ax
	
	.call_instruction	db 9Ah
	.call_address		dw 0
	.call_segment		dw 0

	jmp start			; I don't think we'll actually get here...
	
; DAAAAAAATAAAAAAA!
	
	.title_msg			db 'InpyoOS Memory Editor', 0
	.footer_msg			db '[h], [Enter] = Command list', 0
	
	.input_label		db ' >', 0
	.data_label			db 'D>', 0
	
	.data_mode			db 0
	.address			dd 0

	.help_title0		db 'Command list:', 0
	.help_title1		db 0
	.help_msg0			db 'q = Quit,'
	.help_msg1			db 'ad/ahXXXXXXXX = Choose a 32-bit address (dec/hex),'
	.help_msg2			db 'dd/dh = Enter the data write mode (dec/hex),'
	.help_msg3			db 'rd/rhXXXXX = Run code on a 20-bit address,'
	.help_msg4			db 'sd/shXXXX ABC.XYZ = Save a file (XXXX bytes; filename ABC.XYZ),'
	.help_msg5			db 'lABC.XYZ = Load a file (filename ABC.XYZ)', 0
	.error_msg			db 'File access error!', 0
	
	.input_buffer		db 0		; Has to be on the end!
; ------------------------------------------------------------------


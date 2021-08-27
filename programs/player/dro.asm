; ------------------------------------------------------------------
; MichalOS Music Player - DRO decoder
; ------------------------------------------------------------------


start_dro:
	call os_check_adlib
	jc .adliberror

.error_bypass:
	call os_get_memory
	cmp ax, 256				; Do we have enough RAM?
	jl .not_enough_ram
	popa

	push bx
	
	push es
	mov ax, 2000h
	mov es, ax
	mov ax, bx
	mov cx, 0
	call os_load_file
	pop es
	
	jc .stop
		
	mov byte [.play], 0
	mov byte [.no_render], 0	
	mov dword [.current_pos], 0
	
	call os_clear_screen

	call start.draw_background
	
	mov si, .playmsg1
	mov ax, 0
	mov bx, .playmsg2
	mov cx, 0
	mov dx, .playmsg3
	call os_temp_box
	
	mov dx, 0A21h
	call os_move_cursor
	pop si
	call os_print_string
	
	call .clear_adlib

	mov al,00110110b
	out 43h, al
	mov cx, 1193
	mov al, cl
	out 40h, al
	mov al, ch
	out 40h, al
	
	mov esi, 10000h

	mov si, 0Ch	; Song length (ignore first 16 bits)
	mov eax, [esi]
	shl eax, 1	; Register pairs -> bytes
	mov [.length], eax
	
	mov si, 10h	; Song length in miliseconds
	mov eax, [esi]
	mov [.song_length], eax
	
	mov si, 17h
	mov al, [esi]
	inc si
	mov [cs:.short_delay], al
	mov al, [esi]
	inc si
	mov [cs:.long_delay], al
	mov al, [esi]		; Codemap length

	movzx bx, al
	mov [.codemap], bx
	
	and eax, 000000FFh
	add eax, 1Ah	; Get the data start
	push ax
	add [.length], eax
	add dword [.length], 10000h
	pop ax
	mov si, ax
	
	pusha
	mov si, .int_handler
	call os_attach_app_timer
	popa
	
.loop:
	cmp [.length], esi
	je .stop

	mov ax, [esi]
	inc esi
	inc esi
	xchg ah, al
	
	cmp ah, [.short_delay]
	je .do_short
	
	cmp ah, [.long_delay]
	je .do_long
	
	mov ebx, 10000h
	movzx bx, ah
	cmp bx, [.codemap]
	jg .loop
	mov ah, [1Ah + ebx]
	
	call os_adlib_regwrite
	
	call os_check_for_key
	cmp al, 27
	je .stop
	cmp al, 32
	je .playpause
	cmp al, 13
	je .fastmode
	
	jmp .loop
	
.playpause:
	xor byte [.play], 1
	jmp .loop
	
.fastmode:
	xor byte [.no_render], 1
	jmp .loop
	
.do_short:
	pusha
	mov ah, 0
	inc ax
	mov [.timer], ax
	jmp .wait_loop
	
.do_long:
	pusha
	mov ah, al
	inc ah
	mov al, 0
	mov [.timer], ax
	
.wait_loop:
	cmp byte [.play], 2
	je .wait_stop
	
	cmp word [.timer], 0
	jg .wait_loop
	
	popa
	jmp .loop
	
.wait_stop:
	popa
	
.stop:
	call .clear_adlib

	mov al,00110110b
	out 43h, al
	mov cx, 0
	mov al, cl
	out 40h, al
	mov al, ch
	out 40h, al
	
	call os_return_app_timer
	
	jmp start
	
.clear_adlib:
	mov al, 0
	mov ah, 0
	
.exit_loop:
	call os_adlib_regwrite
	inc ah
	cmp ah, 0
	jne .exit_loop
	
	ret

.not_enough_ram:
	popa
	mov ax, .no_ram
	mov bx, 0
	mov cx, 0
	mov dx, 0
	call os_dialog_box
	
	jmp start

.int_handler:
	call os_check_for_key
	cmp al, 27
	je .int_stop
	cmp al, 32
	jne .noplaypause

	xor byte [.play], 1
	
.noplaypause:
	cmp byte [.play], 1
	je .no_dec_timer
	
	mov eax, [.current_pos]
	inc dword [.current_pos]
	mov ebx, 1000
	mov edx, 0
	div ebx

	cmp edx, 0
	jne .no_update_timer
	
	call os_get_cursor_pos
	push dx
	mov dx, 0C26h
	call os_move_cursor

	call os_32int_to_string
	mov si, ax
	call os_print_string
	
	mov ax, 0E73h		; Print a "s"
	mov bh, 0
	int 10h
	
	mov al, 2Fh			; "/"
	int 10h
	
	mov eax, [.song_length]
	mov edx, 0
	mov ebx, 1000
	div ebx
	call os_32int_to_string
	mov si, ax
	call os_print_string
	
	mov ax, 0E73h		; Print a "s"
	mov bh, 0
	int 10h

	pop dx
	call os_move_cursor
	
.no_update_timer:
	dec word [.timer]

.no_dec_timer:
	ret
	
.int_stop:
	mov byte [.play], 2		; Stop state
	ret
	
.adliberror:
	mov byte [0085h], 1
	mov ax, start.adlib_msg1
	mov bx, start.adlib_msg2
	mov cx, 0
	mov dx, 1
	call os_dialog_box
	mov byte [0085h], 0
	
	cmp ax, 0
	je .error_bypass
	
	popa
	jmp start.play_file

	.short_delay		db 0
	.long_delay			db 0
	.length				dd 0
	.codemap			dw 0
	.song_length		dd 0
	.current_pos		dd 0
	.timer				dw 0
	.play				db 0
	.no_render			db 0
	.channel_timer		times 9 db 0
	
	.no_ram				db 'Not enough RAM!', 0
	.millilength_msg	db 'Song length (in milliseconds): ', 0
	.position_msg		db 'Current position (milliseconds): ', 0
	.playmsg1			db 'Now playing:', 0
	.playmsg2			db 'Current position:', 0
	.playmsg3			db '(Escape - stop, Space - play/pause)', 0

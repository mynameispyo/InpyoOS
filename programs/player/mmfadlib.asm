; ------------------------------------------------------------------
; MichalOS Music Player - MMF (AdLib) decoder
; ------------------------------------------------------------------


start_adlib_mmf:
	mov byte [0082h], 1

	mov ax, 0120h
	call os_adlib_regwrite
	
	mov al, [buffer + 2]
	movzx ax, al
	push ax
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov si, .instrument_msg
	call os_print_string
	
	pop ax
	mov bx, 11
	mul bx
	mov si, ax		; Skip the instrument data and go directly to song data
	add si, buffer + 3
	
	pusha
	mov si, .int_handler
	call os_attach_app_timer
	popa

	call os_print_newline
	
.play_loop:
	mov cl, 0

.channel_loop:
	lodsw
	
;	pusha
;	call os_dump_registers
;	call os_wait_for_key
;	popa
	
	cmp ah, 0
	jl .special_function

	movzx bx, cl
	shl bx, 1
	mov [.channel_data + bx], ax
	
;	call os_dump_registers

	push ax
	mov ah, 0A0h
	add ah, cl
;	call os_dump_registers
	call os_adlib_regwrite
	pop ax

	mov al, ah
	mov ah, 0B0h
	add ah, cl
	push ax
	and al, 1fh				; KEY-ON off
;	call os_dump_registers
	call os_adlib_regwrite
	pop ax
	or al, 20h
	call os_adlib_regwrite

;	call os_wait_for_key
	
.function_ret:	
	inc cl
	cmp cl, 9
	jne .channel_loop

	lodsw
	cmp ax, 0
	je .play_loop
	
	mov [.timer], ax
	
.timer_loop:
	cmp word [.timer], 0
	jne .timer_loop
	
	jmp .play_loop
	
.special_function:
	cmp ah, 0FFh			; 'Load instrument' function
	je .load_instrument
	
	cmp ah, 0FEh
	je .song_function
	
	; Now we're assuming the register write function
	
	movzx bx, cl
	mov ch, [.channel_map + bx]

	and ah, 0Fh
	movzx bx, ah
	mov ah, [.register_map]
	
	add ah, ch
	call os_adlib_regwrite
	
	jmp .function_ret
	
.song_function:
	cmp al, 2
	je .function_ret
	
	cmp al, 1
	je .exit
	
	; Now we're assuming that AL contains 00
	
	movzx bx, cl
	shl bx, 1
	
	mov ax, [.channel_data + bx]
	and ax, 1FFFh			; Mask off the KEY-ON bit
	mov [.channel_data + bx], ax
	
	mov al, ah
	mov ah, 0B0h
	add ah, cl
	call os_adlib_regwrite

	jmp .function_ret
	
.load_instrument:
	pusha
	movzx bx, cl
	mov ch, [.channel_map + bx]

	push cx
	movzx cx, al
	mov ax, 11
	mul cx
	pop cx
	add ax, buffer + 3				; Get to the instrument data
	mov si, ax
	
	mov bl, 0
	
.instrument_loop:
	mov ah, [.register_map + bx]
	add ah, ch
	lodsb

;	call os_dump_registers
	call os_adlib_regwrite
	
	inc bl
	cmp bl, 10
	jne .instrument_loop
	
	mov ah, 0C0h
	add ah, cl
	lodsb
	
;	call os_dump_registers
	call os_adlib_regwrite

;	call os_wait_for_key
	
	popa
	jmp .function_ret

.int_handler:
	dec word [.timer]
	ret
	
.exit:
	call .clear_adlib

	mov al,00110110b
	out 43h, al
	mov cx, 0
	mov al, cl
	out 40h, al
	mov al, ch
	out 40h, al
	
	mov byte [0082h], 0
	
	call os_return_app_timer
	
	ret
	
.clear_adlib:
	mov al, 0
	mov ah, 0
	
.exit_loop:
	call os_adlib_regwrite
	inc ah
	cmp ah, 0
	jne .exit_loop
	ret
	jmp start
	
	.channel_map		db 0, 1, 2, 8, 9, 10, 16, 17, 18
	.register_map		db 20h, 23h, 40h, 43h, 60h, 63h, 80h, 83h, 0F0h, 0F3h
	.instrument_msg		db ' instruments found.', 0
	.timer				dw 0
	.channel_data		times 18 db 0
	

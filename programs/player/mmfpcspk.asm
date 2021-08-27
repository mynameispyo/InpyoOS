; ------------------------------------------------------------------
; MichalOS Music Player - MMF (PC Speaker) decoder
; ------------------------------------------------------------------


start_pcspk_mmf:
	push bx

	mov ax, bx
	mov cx, buffer
	call os_load_file

	mov al,00110110b
	out 43h, al
	mov cx, [buffer]
	mov al, cl
	out 40h, al
	mov al, ch
	out 40h, al
	
	call os_clear_screen
	mov si, .msgstart
	call os_print_string
	call os_wait_for_key
	cmp al, 27
	je start
	
	mov byte [0082h], 1

	call os_clear_screen

	call start.draw_background

	mov si, start_dro.playmsg1
	mov ax, 0
	mov bx, start_dro.playmsg2
	mov cx, 0
	mov dx, start_dro.playmsg3
	call os_temp_box

	mov dx, 0A21h
	call os_move_cursor
	pop si
	call os_print_string

.play_loop:
	call .int_handler
	call os_check_for_key
	cmp al, 27
	je .exit
	cmp al, 32
	je .pause
	
	mov ax, 1
	call os_pause
	cmp word [.pointer], .track0
	jne .play_loop
	cmp byte [.delay], 0
	jne .play_loop

.exit:
	mov word [.pointer], .track0	; Reset the values when we press Esc
	mov word [.previous], 0
	mov word [.counter], 0
	mov byte [.paused], 0
	mov al,00110110b
	out 43h, al
	mov cx, 0						; 18.2 Hz
	mov al, cl
	out 40h, al
	mov al, ch
	out 40h, al
	ret
	
.pause:
	xor byte [.paused], 1
	jmp .play_loop
	
.int_handler:
	pusha
	cmp byte [.paused], 0
	jne .skip_play
	
	inc byte [.delay]
	mov al, [.song_delay]
	cmp byte [.delay], al
	jl .skip_play
	
	inc word [.counter]
	pusha
	mov dx, 0C26h
	call os_move_cursor
	mov ax, [.counter]
	call os_int_to_string
	mov si, ax
	call os_print_string
	popa

	mov byte [.delay], 0
	
	mov si, [.pointer]
	lodsw
	mov [.pointer], si
	
	cmp ax, [.previous]
	je .skip_play
	
	mov [.previous], ax
	
	cmp ax, 0
	je near .notone
	
	cmp ax, 1
	je near .end
	
	call os_speaker_tone
	
.skip_play:
	popa
	ret
	
.notone:
	call os_speaker_off
	popa
	ret
	
.end:
	call os_speaker_off
	mov word [.pointer], .track0
	popa
	ret

	.previous	dw 0
	.pointer	dw .track0
	.counter	dw 0
	.delay		db 0
	.paused		db 0
	.song_delay	equ buffer + 2
	.track0		equ buffer + 3
	.msg0		db 'Playing a note (frequency ', 0
	.msg1		db ')', 0
	.msg0alt	db 'Pausing', 0
	.msg2		db ' @ offset 0x', 0
 	.msgstart			db 'Press any key to play...', 0

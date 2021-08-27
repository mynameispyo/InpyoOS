; ------------------------------------------------------------------
; MichalOS Music Player
; ------------------------------------------------------------------


	BITS 16
	%INCLUDE "michalos.inc"
	%INCLUDE "notelist.txt"
	ORG 100h

start:
	call os_speaker_off
	call .draw_background
	
	mov ax, .choice
	mov bx, .choice_msg1
	mov cx, .choice_msg2
	call os_list_dialog
	
	jc .exit
	
	cmp ax, 1
	je near .piano
	
	cmp ax, 2
	je near .play_file
	
	cmp ax, 3
	je near .exit
	
.play_file:
	mov byte [0087h], 1
	mov bx, .extension_number
	call os_file_selector		; Get filename
	mov byte [0087h], 0
	jc start

	mov bx, ax			; Save filename for now

	mov di, ax

	call os_string_length
	add di, ax			; DI now points to last char in filename

	dec di
	dec di
	dec di				; ...and now to first char of extension!
	
	pusha
	mov si, .mmf_extension
	mov cx, 3
	rep cmpsb			; Does the extension contain 'MMF'?
	je .valid_mmf_extension		; Skip ahead if so
	popa
	
	pusha
	mov si, .dro_extension
	mov cx, 3
	rep cmpsb
	je start_dro
	popa
	
	pusha
	mov si, .rad_extension
	mov cx, 3
	rep cmpsb
	je start_rad
	popa
	
					; Otherwise show error dialog
	mov dx, 0			; One button for dialog box
	mov ax, .err_string
	mov bx, .err_string2
	mov cx, 0
	call os_dialog_box

	jmp .play_file			; And retry
	
.valid_mmf_extension:
	popa

	call start_pcspk_mmf
	jmp start
	
.piano:
	call .draw_clear_background
	
	mov dl, 1
	mov dh, 9
	call os_move_cursor
	mov si, .piano0
	call os_print_string
	call os_hide_cursor
	
.pianoloop:
	call os_wait_for_key

	cmp al, ' '
	je .execstop
	cmp al, 27
	je start
	
	mov si, .keydata1
	mov di, .notedata1
	
.decodeloop:
	mov bh, [si]
	inc si
	add di, 2
	
	cmp bh, 0
	je .pianoloop
	
	cmp ah, bh
	jne .decodeloop
	
	sub di, 2				; We've overflowed a bit
	mov ax, [di]
	call os_speaker_tone
	
	jmp .pianoloop
	
.execstop:
	call os_speaker_off
	jmp .pianoloop
	
.draw_background:
	pusha
	mov ax, .title_msg
	mov bx, .footer_msg
	mov cx, 256
	call os_draw_background
	popa
	ret

.draw_clear_background:
	pusha
	mov ax, .title_msg
	mov bx, .footer_msg
	movzx cx, byte [57000]
	call os_draw_background
	popa
	ret
	
.exit:
	call os_clear_screen
	ret
		
	jmp .play_file

	.choice_msg1		db 'Choose an option...', 0
	.choice_msg2		db 0
	.choice				db 'Virtual piano,Play a file,Quit', 0

;	.adlib_msg			db 'AdLib support is not yet supported!', 0
	
	.title_msg			db 'InpyoOS Music Player', 0
	.footer_msg			db 0

	.keydata1			db 2Ch, 2Dh, 2Eh, 2Fh, 30h, 31h, 32h, 33h, 34h, 35h
	.keydata2			db 1Fh, 20h, 22h, 23h, 24h, 26h, 27h
	.keydata3			db 10h, 11h, 12h, 13h, 14h, 15h, 16h, 17h, 18h, 19h, 1Ah, 1Bh
	.keydata4			db 03h, 04h, 06h, 07h, 08h, 0Ah, 0Bh, 0Dh, 00h
	
	.notedata1			dw C3, D3, E3, F3, G3, A3, B3, C4, D4, E4
	.notedata2			dw CS3, DS3, FS3, GS3, AS3, CS4, DS4
	.notedata3			dw C4, D4, E4, F4, G4, A4, B4, C5, D5, E5, F5, G5
	.notedata4			dw CS4, DS4, FS4, GS4, AS4, CS5, DS5, FS5
	
	.err_string			db 'Invalid file type!', 0
	.err_string2		db 'MMF, DRO 2.0 or RAD only!', 0
	.extension_number	db 3
	.mmf_extension		db 'MMF', 0
	.dro_extension		db 'DRO', 0
	.rad_extension		db 'RAD', 0
	.adlib_msg1			db 'YM3812 not detected.', 0
	.adlib_msg2			db 'Do you want to continue?', 0
	
	.piano0 db 179, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 179, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 179, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 179, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 179, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 179, 32, 32, 32, 219, 32, 32, 32, 179, 13, 10
	.piano1 db 32, 179, 32, 32, 32, 83, 32, 32, 32, 68, 32, 32, 32, 179, 32, 32, 32, 71, 32, 32, 32, 72, 32, 32, 32, 74, 32, 32, 32, 179, 32, 32, 32, 50, 32, 32, 32, 51, 32, 32, 32, 179, 32, 32, 32, 53, 32, 32, 32, 54, 32, 32, 32, 55, 32, 32, 32, 179, 32, 32, 32, 57, 32, 32, 32, 48, 32, 32, 32, 179, 32, 32, 32, 61, 32, 32, 32, 179, 13, 10
	.piano2 db 32, 179, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 179, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 179, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 179, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 179, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 179, 32, 32, 32, 219, 32, 32, 32, 179, 13, 10
	.piano3 db 32, 179, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 179, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 179, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 179, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 179, 32, 32, 32, 219, 32, 32, 32, 219, 32, 32, 32, 179, 32, 32, 32, 219, 32, 32, 32, 179, 13, 10
	.piano4 db 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 32, 32, 32, 179, 13, 10
	.piano5 db 32, 179, 32, 90, 32, 179, 32, 88, 32, 179, 32, 67, 32, 179, 32, 86, 32, 179, 32, 66, 32, 179, 32, 78, 32, 179, 32, 77, 32, 179, 32, 81, 32, 179, 32, 87, 32, 179, 32, 69, 32, 179, 32, 82, 32, 179, 32, 84, 32, 179, 32, 89, 32, 179, 32, 85, 32, 179, 32, 73, 32, 179, 32, 79, 32, 179, 32, 80, 32, 179, 32, 91, 32, 179, 32, 93, 32, 179, 13, 10
	.piano6 db 32, 192, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 193, 196, 196, 196, 217, 0

	%include "player/dro.asm"
	%include "player/mmfpcspk.asm"
;	%include "player/mmfadlib.asm"
	%include "player/rad.asm"
	
align 16
;test_module: incbin RAD_MODULE_NAME
buffer	db 0
	
; ------------------------------------------------------------------


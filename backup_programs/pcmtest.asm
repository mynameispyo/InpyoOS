; ------------------------------------------------------------------
; MichalOS PC Speaker PCM Demo
;
; WARNING: This demo uses the top 1.44 MB of a 2.88 MB disk.
; It is not possible to run this demo from a 1.44 MB floppy disk.
; Use the "build-linux.sh" build script, then run the following:
; > dd if=audio.raw of=disk_images/michalos.flp bs=512 seek=2880
; "audio.raw" has to contain raw uncompressed 11025 Hz single-channel 8-bit PCM audio.
; Then, boot it on a *REAL* PC. Emulators do NOT work with non-standard
; floppy image sizes.
; > sudo dd if=michalos.flp of=/dev/sdX
; (where X is a USB flash drive that you wish to overwrite)
; ------------------------------------------------------------------

        %include "osdev.inc"
        bits    16
        org     100h

        samplecount		equ 2880 * 512
		counter			equ	0x1234DC / 22050

start:
;	mov byte [0082h], 1

	call os_hide_cursor
	
	mov ax, .titlemsg
	mov bx, .footermsg
	mov cx, 7
 	call os_draw_background
	
	mov dl, 8
	mov dh, 15
	call os_move_cursor
	mov ax, 09C4h
	mov cx, 64
	mov bx, 7
	int 10h
	mov dh, 17
	call os_move_cursor
	int 10h
	
	push es

	mov ax, 2000h
	mov es, ax
	mov bx, 0
	
.load_loop:
	mov ax, [.current_position]
	call os_disk_l2hts
	mov ah, 02
	mov al, 90
	int 13h
	
	mov esi, 10000h
	mov edi, 0
	mov di, [.current_position]
	sub di, 2880
	shl edi, 9			; Multiply by 512
	add edi, 100000h - 65536
	
.copy_loop:
	mov eax, [esi]
	mov [edi], eax
	
	add esi, 4
	add edi, 4
	cmp esi, 1B400h		; End of loaded data
	jne .copy_loop
	
	add word [.current_position], 90
;	cmp word [.current_position], samplecount / 512 + 2880 + 1
	cmp word [.current_position], samplecount / 512 + 2880
	jl .load_loop
	
	pop es
	
;	push es
;	mov ax, 2000h
;	mov es, ax
;	mov ax, filename
;	mov cx, 0
;	call os_load_file
;	pop es

;	add ebx, 10000h
;	
;	mov [datasize], ebx
	
	;; Replace IRQ0 with our sound code
	mov     si, tick
	call os_attach_app_timer

	;; Attach the PC Speaker to PIT Channel 2
	in      al, 0x61
	or      al, 3
	out     0x61, al

	;; Reprogram PIT Channel 0 to fire IRQ0 at 16kHz
	cli
	mov     al, 0x36
	out     0x43, al
	mov     ax, counter
	out     0x40, al
	mov     al, ah
	out     0x40, al
	sti

	;; Keep processing interrupts until it says we're done
.mainlp: 
	hlt
	call os_check_for_key
	cmp al, "1"
	je .dec_volume
	cmp al, "2"
	je .inc_volume
	cmp al, "3"
	je .dec_skip
	cmp al, "4"
	je .inc_skip
	cmp al, "5"
	je .dec_tick
	cmp al, "6"
	je .inc_tick
	cmp al, 32
	je .playpause
	cmp al, 27
	je .exit
	
	; Draw the VU meter
	
	mov dl, 8
	mov dh, 16
	call os_move_cursor
	
	mov esi, [offset]
	movzx cx, byte [esi]
	cmp cx, 80h
	jge .subtract
	
	mov al, 80h
	sub al, cl
	mov cl, al
	jmp .done
	
.subtract:
	sub cl, 80h

.done:
	shr cx, 1
	
	mov ax, 09DBh
	mov bx, 7
	int 10h
	
	mov dl, 8
	mov dh, 16
	add dl, cl
	call os_move_cursor
	
	mov al, 78
	sub al, cl
	mov cl, al
	mov ax, 0920h
	int 10h

.no_display:
	; Show how many samples have been read
	
	mov dl, 2
	mov dh, 18
	call os_move_cursor
	
	mov eax, [offset]
	sub eax, 0F0000h
	call os_32int_to_string
	mov si, ax
	call os_print_string

	mov si, .separator
	call os_print_string
	
	mov eax, samplecount
	call os_32int_to_string
	mov si, ax
	call os_print_string

	mov si, .samplemsg
	call os_print_string

	; Show how long has the song been playing
	
	mov dl, 2
	mov dh, 19
	call os_move_cursor
	
	mov eax, [offset]
	sub eax, 0F0000h
	movzx ebx, byte [skipbytevalue]
	mul ebx

	mov ebx, [.current_samplerate]
	div ebx
		
	call os_int_to_string
	mov si, ax
	call os_print_string
	
	mov si, .separator
	call os_print_string
	
	mov eax, samplecount
	movzx ebx, byte [skipbytevalue]
	mul ebx

	mov ebx, [.current_samplerate]
	div ebx
		
	call os_int_to_string
	mov si, ax
	call os_print_string

	mov si, .secondmsg
	call os_print_string
	
	cmp word [done], 0
	je .mainlp
	
.exit:
	;; Restore original IRQ0
	
	call os_return_app_timer

	mov     al, 0x36        ; ... and slow the timer back down
	out     0x43, al        ; to 18.2 Hz
	xor     al, al
	out     0x40, al
	out     0x40, al
	
	;; Turn off the PC speaker
	in      al, 0x61
	and     al, 0xfc
	out     0x61, al

	;; And quit with success
	ret
	
.playpause:
	xor byte [pausestate], 1
	jmp .mainlp
	
.inc_volume:
	cmp byte [shr_value], 00h
	je .mainlp
	
	dec byte [shr_value]
	jmp .mainlp
	
.dec_volume:
	cmp byte [shr_value], 07h
	je .mainlp
	
	inc byte [shr_value]
	jmp .mainlp
	
.inc_skip:
	inc byte [skipbytevalue]
	jmp .mainlp
	
.dec_skip:
	dec byte [skipbytevalue]
	jmp .mainlp
	
.inc_tick:
	mov eax, [.current_samplerate]
	cmp eax, 44100
	je .mainlp
	imul eax, 2
	mov [.current_samplerate], eax

	jmp .modify_tick
	
.dec_tick:
	mov eax, [.current_samplerate]
	cmp eax, 22050
	je .mainlp
	mov edx, 0
	mov ebx, 2
	div ebx
	mov [.current_samplerate], eax

	call os_print_newline
	
;	jmp .modify_tick  ; Unnecessary
	
.modify_tick:	
	mov eax, 1234DCh
	mov ebx, [.current_samplerate]
	mov edx, 0
	div ebx

	cli
	push ax
	mov     al, 0x36
	out     0x43, al
	pop ax
	out     0x40, al
	mov     al, ah
	out     0x40, al
	sti
	
	jmp .mainlp
	
	.current_samplerate	dd 22050
	.current_position	dw 2880
	.titlemsg			db 'InpyoOS PCM Test', 0
	.footermsg			db 0
	.samplemsg			db ' samples read     ', 0
	.secondmsg			db ' seconds played      ', 0
	.separator			db '/', 0
	
	;; *** IRQ0 TICK ROUTINE ***
tick:   
	cmp byte [pausestate], 1
	je .no_update_timer

	mov     esi, [offset]
	cmp     esi, datasize    ; past the end?
	je     .nosnd

	mov     ah, [esi]  ; If not, load up the value
	mov cl, [shr_value]
	shr     ax, cl           ; Make it a 7-bit value
	cmp ah, 0
	je .no_play				; If the value is 0, the PIT thinks it's actually 0x100, so it'll clip

	mov     al, 0xb0        ; And program PIT Channel 2 to
	out     0x43, al        ; deliver a pulse that many
	mov     al, ah          ; microseconds long
	out     0x42, al
	mov al, 0
	out     0x42, al

.no_play:
	inc byte [skipbyte]
	mov al, [skipbytevalue]
	cmp byte [skipbyte], al
	jne .no_update_timer
	
	mov byte [skipbyte], 0
	inc     esi              ; Update pointer
	mov     [offset], esi

.no_update_timer:
	jmp     .intend         ; ... and jump to end of interrupt
	
	;; If we get here, we're past the end of the sound.
.nosnd:
	mov     ax, [done]      ; Have we already marked it done?
	jnz     .intend         ; If so, nothing left to do
	mov     ax, 1           ; Otherwise, mark it done...
	mov     [done], ax
.intend:

	ret

	done   dw      0
	offset dd      100000h - 65536
	skipbyte	db 0
	datasize	equ samplecount + 100000h - 65536
;	datasize	equ 1474560 + 100000h - 65536
	shr_value	db 2
	skipbytevalue	db 2
	pausestate	db 0
	
	;dataptr: dd 0
	;data:   incbin "wow.raw"        ; Up to 64KB of 16 kHz 8-bit unsigned LPCM
	;dataend:

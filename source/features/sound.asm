; ==================================================================
; PC SPEAKER SOUND ROUTINES
; ==================================================================

; ------------------------------------------------------------------
; os_speaker_tone -- Generate PC speaker tone (call os_speaker_off to turn off)
; IN: AX = note frequency; OUT: Nothing (registers preserved)

os_speaker_tone:
	pusha
	cmp byte [0083h], 0
	je near .exit
	popa
	
	pusha
	cmp ax, 0
	je near .exit
	
	call os_speaker_off
	mov cx, ax			; Store note value for now

	mov al, 10110110b
	out 43h, al
	mov dx, 12h			; Set up frequency
	mov ax, 34DCh
	div cx
	out 42h, al
	mov al, ah
	out 42h, al

	in al, 61h			; Switch PC speaker on
	or al, 03h
	out 61h, al

.exit:
	popa
	ret


; ------------------------------------------------------------------
; os_speaker_off -- Turn off PC speaker
; IN/OUT: Nothing (registers preserved)

os_speaker_off:
	pusha

	in al, 61h
	and al, 0FCh
	out 61h, al

	popa
	ret

; ------------------------------------------------------------------
; os_check_adlib -- Checks if YM3812 is present in the system
; OUT: CF clear if YM3812 is present

os_check_adlib:
	pusha
	mov ax, 0460h
	call os_adlib_regwrite
	mov ax, 0480h
	call os_adlib_regwrite
	
	mov dx, 388h
	in al, dx
	cmp al, 0
	jne .error
	
	popa
	clc
	ret
	
.error:
	popa
	stc
	ret
	
; ------------------------------------------------------------------
; os_adlib_regwrite -- Write to a YM3812 register on ports 388h & 389h
; IN: AH/AL - register address/value to write

os_adlib_regwrite:
	pusha
	mov dx, [57077]
	push ax
	mov al, ah
	out dx, al
	pop ax
	mov dx, [57079]
	out dx, al
	popa
	ret
	
; ------------------------------------------------------------------
; os_adlib_calcfreq -- Calculate a frequency into YM3812 registers
; IN: AX - frequency; OUT: AL/BL - register (AXh/BXh) values

os_adlib_calcfreq:
	pushad
	
	movzx eax, ax
	mov cl, 0		; Block number
	
	push eax
.block_loop:		; f-num = freq * 2^(20 - block) / 49716
	mov al, 2
	mov bl, 20
	sub bl, cl
	movzx eax, al
	movzx ebx, bl
	
	call os_math_power
	
	mov ebx, eax
	pop eax
	push eax
	mul ebx
		
	mov ebx, 49716
	div ebx

	inc cl
	
	cmp eax, 1024
	jge .block_loop
	
	dec cl
	
	shl cl, 2
	add ah, cl
	
	mov [.tmp_word], ax
	
	pop eax
	popad
	
	mov al, [.tmp_word]
	mov bl, [.tmp_word + 1]
	ret
	
	.tmp_word	dw 0
	
; ==================================================================


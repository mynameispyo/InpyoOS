; ------------------------------------------------------------------
; MichalOS Ascii Test
; ------------------------------------------------------------------


	BITS 16
	%INCLUDE "osdev.inc"
	ORG 100h

start:
	mov byte [0082h], 1
	mov ah, 9
	mov al, 0
	mov bh, 0
	mov bl, 0Fh
	mov cx, 1
	mov dl, 0
	mov dh, 0
	
.loop:
	call os_move_cursor
	int 10h
	
	inc al
	inc dl
	cmp dl, 16
	jne .loop
	
	mov dl, 0
	inc dh
	cmp dh, 16
	jne .loop

	call os_wait_for_key
	ret

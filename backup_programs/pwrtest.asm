; ------------------------------------------------------------------
; MichalOS VBE Power Management checker
; ------------------------------------------------------------------

	BITS 16
	%INCLUDE "michalos.inc"
	ORG 100h

start:
	mov si, .hellomsg
	call os_print_string
	
	mov ax, 4F10h
	mov bl, 1
	mov bh, 4
	int 10h

	call os_wait_for_key
	
	mov ax, 4F10h
	mov bl, 1
	mov bh, 0
	int 10h	
	
	ret
	
	.hellomsg	db 'Hi, I am not working!', 0

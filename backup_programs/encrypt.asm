; ------------------------------------------------------------------
; MichalOS Ascii Test
; ------------------------------------------------------------------


	BITS 16
	%INCLUDE "michalos.inc"
	ORG 100h

start:
	mov byte [0082h], 1

	mov si, .test
	call os_string_encrypt
	
	call os_print_string

	call os_print_newline

	mov si, .test1
	call os_string_encrypt
	
	call os_print_string

	call os_print_newline

	mov si, .test2
	call os_string_encrypt
	
	call os_print_string

	call os_print_newline

	mov si, .test3
	call os_string_encrypt
	
	call os_print_string

	call os_print_newline


	call os_wait_for_key
	ret

	.test	db "Hello, World!", 0
	.test1	db "Hello, World!", 0
	.test2	db "Testtesttest!", 0
	.test3	db "Testtesttesttestdsjafosufoidufisuioaouafiodsufoufasuiofiufdufoisuoi!", 0
	

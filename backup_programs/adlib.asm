; ------------------------------------------------------------------
; MichalOS AdLib Test
; ------------------------------------------------------------------


	BITS 16
	%INCLUDE "osdev.inc"
	ORG 100h

start:
	mov byte [0082h], 1
	
	mov ax, 0120h
	call os_adlib_regwrite
	mov ax, 2301h
	call os_adlib_regwrite
	mov ax, 63F0h
	call os_adlib_regwrite
	mov ax, 83F0h
	call os_adlib_regwrite
	mov ax, 2401h
	call os_adlib_regwrite
	mov ax, 64F0h
	call os_adlib_regwrite
	mov ax, 84F0h
	call os_adlib_regwrite

	mov ax, 440
	call os_adlib_calcfreq
	mov ah, 0A0h
	call os_adlib_regwrite
	mov al, bl
	mov ah, 0B0h
	or al, 00100000b
	call os_adlib_regwrite
	
	mov ax, 441
	call os_adlib_calcfreq
	mov ah, 0A1h
	call os_adlib_regwrite
	mov al, bl
	mov ah, 0B1h
	or al, 00100000b
	call os_adlib_regwrite
	
	
	jmp $
	ret

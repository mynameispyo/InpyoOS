
	BITS 16
	%INCLUDE "osdev.inc"
	ORG 100h

start: 
	push es
	mov dl, [0]
	mov ah, 8					; Get drive parameters
	int 13h
	pop es
	and cx, 3Fh					; Maximum sector number
	movzx dx, dh				; Maximum head number
	add dx, 1					; Head numbers start at 0 - add 1 for total

	mov si, .sectors
	call os_print_string
	mov ax, cx
	call os_int_to_string
	mov si, ax
	call os_print_string

	mov si, .sides
	call os_print_string
	mov ax, dx
	call os_int_to_string
	mov si, ax
	call os_print_string
	
	call os_wait_for_key
	ret
	
	.sectors	db 'Sector count: ', 0
	.sides		db 13, 10, 'Side count: ', 0

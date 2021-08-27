; ------------------------------------------------------------------
; MichalOS VESA mode checker
; ------------------------------------------------------------------

	BITS 16
	%INCLUDE "michalos.inc"
	ORG 100h

start:
	mov si, 16384
	mov cx, 100h
	mov di, buffer
	mov bx, 0
	
.loop:
	push di
	mov di, 16384
	mov ax, 4F01h
	int 10h
	pop di
	
	cmp ah, 00h
	jne .not_good
	
	mov [databuffer + bx], cx
	add bx, 2
	
;	mov ax, cx
;	call os_print_4hex
	
;	call os_print_space
	
	mov ax, [si + 12h]
	push si
	call os_int_to_string
	mov si, ax
	call string_copy
	pop si
	
	mov al, " "
	stosb
	
	mov ax, [si + 14h]
	push si
	call os_int_to_string
	mov si, ax
	call string_copy
	pop si
	
	mov al, " "
	stosb
	
	mov ah, 0
	mov al, [si + 19h]
	push si
	call os_int_to_string
	mov si, ax
	call string_copy
	pop si
	
	mov al, ","
	stosb
	
.not_good:
	inc cx
	cmp cx, 200h
	jne .loop

	dec di			; We last put a ",", so remove it
	mov al, 0
	stosb
	
	mov ax, buffer
	mov bx, .null
	mov cx, .null
	call os_list_dialog
	
	dec ax
	mov bx, ax
	shl bx, 2		; The buffer is stored in words
	mov cx, [databuffer + bx]

	mov di, 16384
	mov ax, 4F01h
	int 10h
	mov ax, cx
	mov cx, [16384 + 12h]
	mov dx, [16384 + 14h]
	mov bx, dx
	
	pusha
	call os_dump_registers
	call os_wait_for_key
	popa
	
	call os_vesa_mode
	
	mov al, 0FFh
	mov cx, 0
	
.drawloop:
	mov dx, cx
	call os_vesa_pixel
	inc cx
	cmp cx, bx
	jne .drawloop
	
	call os_wait_for_key
	
	ret
	
	.null		db 0
	
string_copy:
	lodsb
	stosb
	cmp byte al, 0
	jne string_copy
	dec di
	ret
	
	buffer:
	databuffer equ 6000h

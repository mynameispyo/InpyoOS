; ------------------------------------------------------------------
; MichalOS Number test
; ------------------------------------------------------------------


	BITS 16
	%INCLUDE "michalos.inc"
	ORG 100h

start:
	mov ax, buffer
	call os_input_string
	call os_print_newline
	
	mov si, buffer
	mov di, numbers1
	call string_to_numarray

	mov ax, buffer
	call os_input_string
	call os_print_newline
	
	mov si, buffer
	mov di, numbers2
	call string_to_numarray

	call numarray_add

	mov si, result
	mov di, buffer
	call numarray_to_string
	
	mov si, buffer
	call os_print_string
	
	call os_wait_for_key
	ret
	
numarray_add:
	pusha
	mov si, numbers1 + length - 1
	mov cx, length
	
.loop:
	mov al, [si]
	add al, [si + length]
	add al, [si + length * 2]
	cmp al, 10
	jl .no_adjust
	
	sub al, 10
	inc byte [si + length * 2 - 1]
	
.no_adjust:
	mov [si + length * 2], al
	dec si
	
	loop .loop
	popa
	ret

; SI = input array; DI = output string
numarray_to_string:
	pusha
	
	; Find the beginning zeros and cut them

	mov bx, 0
	
.find_loop:
	cmp bx, length / 2 - 1
	je .end_find

	inc bx
	inc si
	mov al, [si]
	
	cmp byte [si], 0
	je .find_loop
	
.end_find:
	mov cx, length / 2
	sub cx, bx
	call .move_with_adjust
	
	mov al, '.'
	stosb
	
	mov bx, length / 2
	
	; Find the zeros at the end and cut them
	
.find_loop2:
	cmp bx, 0
	je .end
	
	dec bx
	mov al, [si + bx]
	
	cmp byte [si + bx], 0
	je .find_loop2
	
	inc bx
	mov cx, bx

	call .move_with_adjust
	
.end:
	mov al, 0
	stosb
	
	popa
	ret
	
.move_with_adjust:
	lodsb
	add al, '0'
	stosb
	loop .move_with_adjust
	ret
	
; SI = input string; DI = output array
string_to_numarray:
	pusha
	push di
	mov al, 0		; Clear the output array first
	mov cx, length
	rep stosb
	pop di
	
	mov al, '.'
	call os_find_char_in_string
	
	cmp ax, 0
	je .no_decimal
	
	dec ax
	mov cx, length / 2
	sub cx, ax
	
	add di, cx
	
.whole_loop:
	lodsb
	cmp al, '.'
	je .decimal_loop
	sub al, '0'
	stosb
	jmp .whole_loop

.prepare_for_decimal:
	inc si		; Skip the decimal point
	
.decimal_loop:
	lodsb
	cmp al, 0
	je .exit
	sub al, '0'
	stosb
	jmp .decimal_loop
	
.no_decimal:
	mov ax, si
	call os_string_length
	
	mov cx, length / 2
	sub cx, ax
	
	add di, cx

	jmp .decimal_loop
	
.exit:
	popa
	ret
	
	length		equ 20
	numbers1	times length db 0
	numbers2	times length db 0
	result		times length db 0
	
buffer:

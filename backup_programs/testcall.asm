BITS 16
ORG 4000h
%include "michalos.inc"

start:
	mov ax, 32768-1024
	mov bx, 32768-1024+128
	mov cx, 07h
	call os_draw_background
	ret

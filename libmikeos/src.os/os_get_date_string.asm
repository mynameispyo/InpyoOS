
; @@@ void mikeos_get_date_string(char *buf);

%include "os_vector.inc"

	section .text
	use16
	global	_mikeos_get_date_string

_mikeos_get_date_string:
	push	bp
	mov	bp, sp

	mov	bx, [bp + 4]

	mov	bp, os_get_date_string
	call	bp

	pop	bp
	ret

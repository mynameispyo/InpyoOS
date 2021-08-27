; ------------------------------------------------------------------
; os_debug_string -- Displays text in serial
; IN: SI = message location (zero-terminated string)

os_debug_string:
	pusha

.repeat:
	lodsb				; Get char from string
	cmp al, 0
	je .done			; If char is zero, end of string

	call os_send_via_serial
	jmp .repeat			; And move on to next char

.done:
	popa
	ret


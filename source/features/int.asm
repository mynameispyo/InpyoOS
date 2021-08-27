; -----------------------------------------------------------------
; os_modify_int_handler -- Change location of interrupt handler
; IN: CL = int number, DI:SI = handler location

os_modify_int_handler:
	pusha

	cli

	push es
	
	mov es, [driversgmt]
	
	movzx bx, cl			; Move supplied int into BX

	shl bx, 2			; Multiply by four to get position
	
	mov [es:bx], si		; First store offset

	add bx, 2
	
	mov [es:bx], di		; Then segment of our handler

	pop es
	
	sti

	popa
	ret

; -----------------------------------------------------------------
; os_get_int_handler -- Change location of interrupt handler
; IN: CL = int number; OUT: DI:SI = handler location

os_get_int_handler:
	pusha

	push ds
	
	mov ds, [driversgmt]
	
	movzx bx, cl			; Move supplied int into BX

	shl bx, 2			; Multiply by four to get position
	
	mov si, [ds:bx]		; First store offset
	add bx, 2

	mov di, [ds:bx]		; Then segment of our handler

	pop ds

	mov [.tmp_word], si
	mov [.tmp_sgmt], di
	popa
	mov si, [.tmp_word]
	mov di, [.tmp_sgmt]
	ret

	.tmp_word	dw 0
	.tmp_sgmt	dw 0
	

; -----------------------------------------------------------------
; os_attach_timer_interrupt -- Attach a timer interrupt to an application
; IN: SI = handler location

os_attach_app_timer:
	pusha
	mov [timer_application_offset], si
	mov byte [timer_application_attached], 1
	popa
	ret
	
; -----------------------------------------------------------------
; os_return_timer_interrupt -- Returns the timer interrupt back to the system
; IN: SI = handler location

os_return_app_timer:
	pusha
	mov byte [timer_application_attached], 0
	popa
	ret
	
; -----------------------------------------------------------------
; Interrupt call parsers

os_compat_int00:				; Division by 0 error handler
	mov ax, .msg
	jmp 1000h:os_crash_application

	.msg db 'CPU: Division by zero error', 0

os_compat_int04:				; INTO instruction error handler
	mov ax, .msg
	jmp 1000h:os_crash_application

	.msg db 'CPU: INTO detected overflow', 0

os_compat_int05:				; Print screen handler	
;	pusha
;	push ds
;	push es
;	mov ax, cs
;	mov ds, ax
;	mov ax, 0B800h
;	mov es, ax
	
;	mov byte [0082h], 1
	
;	mov ax, .screenshot
;	mov bx, 0
;	mov cx, 4000
;	call os_write_file
	
;	mov byte [0082h], 0
	
;	pop es
;	pop ds
;	popa
	iret

;	.screenshot		db 'SCRNSHOT.MSS', 0

os_compat_int06:				; Invalid opcode handler
	mov ax, .msg
	jmp 1000h:os_crash_application

	.msg db 'CPU: Invalid opcode', 0

os_compat_int07:				; Processor extension error handler
	mov ax, .msg
	jmp 1000h:os_crash_application

	.msg db 'CPU: Processor extension error', 0

os_compat_int1C:				; System timer handler (8253/8254)
	cli
	pushad
	push ds
	push es
	
	mov ax, 1000h
	mov ds, ax
	mov es, ax
	
	cmp byte [0082h], 1
	je .no_update
	
	call os_update_clock

.no_update:
	cmp byte [cs:timer_application_attached], 1
	je .app_routine

	pop es
	pop ds
	popad
	sti
	iret

.app_routine:
	call [cs:timer_application_offset]
	
	pop es
	pop ds	
	popad
	iret

	timer_application_attached	db 0
	timer_application_offset	dw 0

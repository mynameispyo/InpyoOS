; ------------------------------------------------------------------
; MichalOS ACPI Test
; ------------------------------------------------------------------

	BITS 16
	%INCLUDE "michalos.inc"
	ORG 100h

start:
	mov byte [0082h], 1

	mov es, [fs:040Eh]	; Get the EDBA segment (FS in MichalOS is always 0!)
	
	mov si, .check_string
	mov di, 0
	mov cx, 8
	mov dx, 1024 / 16
	
.find_loop:
	pusha
	rep cmpsb
	popa
	je .found_rsdp
	
	mov ax, es
	inc ax
	mov es, ax	
	
	dec dx
	cmp dx, 0
	jne .find_loop
	
	mov ax, 0E000h
	mov es, ax
	
.find_loop_2:
	pusha
	rep cmpsb
	popa
	je .found_rsdp
	
	mov ax, es
	inc ax
	mov es, ax
	
	cmp ax, 0
	jne .find_loop_2
	
	mov si, .not_found
	call os_print_string
	
	call os_wait_for_key
	ret
	
.found_rsdp:
	mov si, .found_msg
	call os_print_string

	mov ax, es
	call os_print_4hex
	
	call os_print_newline
	mov si, .oemidmsg
	call os_print_string
	
	mov ah, 0Eh
	mov bh, 0
	mov si, 9
	
.print_loop:
	mov al, [es:si]
	int 10h
	inc si
	cmp si, 9 + 6
	jne .print_loop
	
	call os_print_newline
	mov al, [es:si]
	mov [.xsdtflag], al
	shl byte [.xsdtflag], 1
	mov si, .acpirevmsg
	call os_print_string
	call os_print_2hex
	call os_print_newline
	
	mov si, .pointermsg
	call os_print_string
	
	cmp byte [.xsdtflag], 4
	je .load_xsdt_ptr
	
	mov eax, [es:16]
	jmp .ptr_loaded
	
.load_xsdt_ptr:
	mov eax, [es:24]
	
.ptr_loaded:
	call os_print_8hex

	sub eax, 10000h			; We live in segment 1000
	mov esi, eax
	
	add esi, 4				; Get the length of RSDT
	mov eax, [esi]
	
	mov ebx, 36				; Get the number of table pointers
	sub eax, ebx
	shr eax, 2
	
	cmp byte [.xsdtflag], 0
	je .no_64bit
	
	shr eax, 1
	
.no_64bit:
	mov ecx, eax
	
	pusha
	call os_print_newline
	mov si, .numtablemsg
	call os_print_string
	popa
	
	pusha
	call os_32int_to_string
	mov si, ax
	call os_print_string
	call os_print_newline
	popa
	
	add esi, 32				; ESI = RSDT position + 36 (the entry table)
	
.entry_check_loop:
	mov eax, esi
	call os_print_8hex
	call os_print_space

	pusha
	mov si, .entrycheckmsg
	call os_print_string
	popa
	
	mov eax, [esi]
	call os_print_8hex
	call os_print_newline
	
	push esi
	sub eax, 10000h
	mov esi, eax
	
	mov eax, [esi]

	cmp eax, 50434146h		; "FACP" in hex
	je .facp_found

	pop esi

	add esi, 4
	movzx eax, byte [.xsdtflag]
	add esi, eax
	
	call os_wait_for_key
	
	dec ecx
	cmp ecx, 0
	jne .entry_check_loop
	
	mov si, .facpnotfound
	call os_print_string
	
	call os_wait_for_key
	ret
	
.facp_found:
	add sp, 4				; We pushed an ESI earlier, get rid of it
	
	pusha
	mov si, .facpmsg
	call os_print_string
	popa
	
	mov eax, esi
	add eax, 10000h
	call os_print_8hex
	
	
	
	call os_wait_for_key
	
	ret
	
	.xsdtflag		db 0
	
	.check_string	db 'RSD PTR '
	.not_found		db 'ACPI RSDP not found!', 0
	.found_msg		db 'ACPI RSDP found at segment ', 0
	.oemidmsg		db 'OEM ID: ', 0
	.acpirevmsg		db 'ACPI revision: ', 0
	.pointermsg		db 'Pointer to RSDT: ', 0
	.numtablemsg	db 'Number of entries in RSDT: ', 0
	.entrycheckmsg	db 'Checking RSDT entry ', 0
	.facpnotfound	db 'ACPI FACP not found!', 0
	.facpmsg		db 'FACP found at address ', 0
	
; ------------------------------------------------------------------
; 3E157C

; 3E1458
; 3E14CC
; 3E1544

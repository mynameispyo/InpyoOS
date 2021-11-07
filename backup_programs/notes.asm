; ------------------------------------------------------------------
; MichalOS Notes
; ------------------------------------------------------------------

; NOTES.NDB file structure:
;	ORG 8000h
;	note_count	dw X
;	note_db		times X dw note_ptr, note_size, year, month + day * 256, hours + minutes * 256
;	note_data	times X db note_title, 0, note_body, 0

	BITS 16
	%INCLUDE "osdev.inc"
	ORG 100h

start:
	cmp byte [7FFEh], 1
	je .restart

	push es
	mov ax, 2000h
	mov es, ax
	mov al, 0
	mov di, 8000h
	mov cx, di
	rep stosb
	
	mov cx, 8000h
	mov ax, .db_name
	call os_load_file
	mov [gs:7FFEh], bx		; Store the file size
	pop es

.ui_start:
	push ds
	mov ax, 2000h
	mov ds, ax
	mov si, 8000h
	mov di, buffer - 1			; Underflow to the zero-termination of the ".list" string
	lodsw
	mov [cs:.notecount], ax
	mov cx, ax

	dec ax
	mov bx, 10
	mul bx
	add si, ax
	
	
.decode_loop:
	mov ax, ',('
	stosw
	
	push si
	; Copy the note's date
	add si, 4
	
	lodsw			; Year
	call os_int_to_string
	
	call .sub_copy_no_source_segment
	mov al, '/'
	stosb
	
	lodsb			; Month
	movzx ax, al
	call os_int_to_string
	
	call .sub_copy_no_source_segment
	mov al, '/'
	stosb

	lodsb			; Day
	movzx ax, al
	call os_int_to_string
	
	call .sub_copy_no_source_segment
	mov al, ' '
	stosb

	lodsb			; Hour
	movzx ax, al
	call os_int_to_string
	
	call .sub_copy_no_source_segment
	mov al, ':'
	stosb

	lodsb			; Minute
	movzx ax, al
	call os_int_to_string
	
	call .sub_copy_no_source_segment
	mov ax, ') '
	stosw
	
	; Copy the note name
	pop si
	lodsw
	sub si, 12
	
	push si
	mov si, ax
	
.copy_loop:
	lodsb
	stosb
	cmp al, 0
	jne .copy_loop
	
	dec di
	pop si
	
	loop .decode_loop
	
	pop ds
	
	mov al, 0
	stosb
	
	; Display the remaining note space
	
	mov ax, 8000h
	sub ax, [gs:7FFEh]
	
	mov byte [string_buffer], '('
	call os_int_to_string
	mov si, ax
	mov di, string_buffer + 1
	call os_string_copy
	
	mov ax, string_buffer
	mov bx, .free_msg
	call os_string_add
	
	call .draw_background
	
.loop:
	mov ax, .list
	mov bx, .option_msg1
	mov cx, string_buffer
	call os_list_dialog
	
	jc .exit
	
	cmp ax, 1
	je .new_note
	
	cmp ax, 2
	je .remove_note
	
	; User has selected a note, pass it to the text editor
	
	; (the notes are in reversed order, flip it)
	sub ax, 2
	mov bx, ax

	mov ax, [gs:8000h]
	sub ax, bx
	
	
	push ds
	push es
	push ax
	mov ax, gs
	mov ds, ax
	mov es, ax
	pop ax
	
	mov di, 2048
	mov si, 8002h
	
	mov bx, 10
	mul bx
	add si, ax
	
	lodsw
	mov bx, ax
	lodsw
	mov cx, ax
	mov si, bx
	
.title_pass_loop:
	lodsb
	stosb
	dec cx
	cmp al, 0
	jne .title_pass_loop
	
	mov [es:4094], cx
	mov di, 4096
	rep movsb
	
	pop es
	pop ds
	
	mov si, .notes_name
	mov di, 00F0h
	call os_string_copy
	
	mov byte [7FFFh], 1
	mov byte [7FFEh], 1
	mov ax, .edit_name
	ret
	
.new_note:
	call .draw_background

	mov ax, .box_msg1
	mov bx, .box_msg2
	mov cx, .box_msg3
	mov dx, 0
	call os_dialog_box
	
	mov si, .notes_name
	mov di, 00F0h
	call os_string_copy
	
	mov byte [gs:4094], 0
	
	mov byte [7FFFh], 1
	mov byte [7FFEh], 1
	mov ax, .edit_name
	ret
	
.remove_note:
	mov ax, buffer
	mov bx, .option_msg1
	mov cx, .blank
	call os_list_dialog
	
	jc .loop
	
	jmp .loop
	
.restart:
	call .draw_background

	mov si, .notes_name
	mov di, 00F0h
	call os_string_compare
	jnc .launch_error
	
	mov byte [7FFEh], 0
	
	mov di, 00F0h
	mov cx, 16
	mov al, 0
	rep stosb	
	jmp .ui_start

.launch_error:
	mov ax, .error_msg
	mov bx, 0
	mov cx, 0
	mov dx, 0
	call os_dialog_box
	ret
	
.draw_background:
	mov ax, .title_msg
	mov bx, .blank
	mov cx, 256
	call os_draw_background
	ret
	
.exit:
	ret

.sub_copy_no_source_segment:
	push ds
	push ax
	push si
	
	mov si, ax
	mov ax, cs
	mov ds, ax
	
.sub_copy_no_source_segment_loop:
	lodsb
	cmp al, 0
	je .sub_copy_no_source_segment_exit
	
	stosb
	jmp .sub_copy_no_source_segment_loop
	
.sub_copy_no_source_segment_exit:
	pop si
	pop ax
	pop ds
	ret
	
	.title_msg			db 'InpyoOS Notes', 0
	.blank				db 0
	.box_msg1			db 'Text Editor will now open. Enter your', 0
	.box_msg2			db 'note as usual and then press Ctrl+S.', 0
	.box_msg3			db '(Or press Esc to abort.)', 0
	.ret_msg			db 'Returned from EDIT.APP.', 0
	.edit_name			db 'EDIT.APP', 0
	.notes_name			db 'NOTES.APP', 0
	.db_name			db 'NOTES.NDB', 0
	.error_msg			db 'Notes cannot run in this environment.', 0
	.option_msg1		db 'Choose an option...', 0
	.free_msg			db ' bytes of note space free)', 0
	
	.notecount			dw 0
	.list				db '+ Add a note,X Delete a note', 0

buffer:
; ------------------------------------------------------------------

string_buffer			equ 4000h

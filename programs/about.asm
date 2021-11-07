; ------------------------------------------------------------------
; About MichalOS
; ------------------------------------------------------------------

	BITS 16
	%INCLUDE "osdev.inc"
	ORG 100h

start:
	call draw_background

	call os_draw_logo
	
	mov dh, 10
	mov dl, 2
	call os_move_cursor
	mov si, osname
	call os_print_string
	
	mov dh, 12
	mov dl, 0
	call os_move_cursor
	mov si, .introtext0
	call os_print_string
	
	call os_hide_cursor
	
	call os_wait_for_key
	cmp al, 32
	je .hall_of_fame
	
	call os_clear_screen
	ret

.hall_of_fame:
	call draw_background

	call os_draw_logo
	
	mov dh, 10
	mov dl, 0
	call os_move_cursor
	mov si, .hoftext0
	call os_print_string
	
	call os_hide_cursor
	
	call os_wait_for_key
	cmp al, 32
	je start
	
	call os_clear_screen
	ret
	
	.introtext0				db '  InpyoOS: Copyright (C) Inpyo Lee 2021', 13, 10
	.introtext2				db '  Press Space to enter the hall of fame...', 13, 10, 10
	.introtextend			db '  Please report any bugs or glitches on mynameispyo@gmail.com', 0
	
	
	.hoftext0				db '  Special thanks to:', 13, 10
	.hoftext1				db '    Michal Prochazka for making MichalOS', 13, 10
	.hoftext10				db '    Ivan Ivanov for discovering and helping with fixing bugs', 13, 10
	.hoftext8				db '    REALITY for releasing the Reality AdLib Tracker source code back in 1995', 13, 10
	.hoftext2				db '    @fanzyflani for porting the Reality AdLib Tracker to NASM', 13, 10
	.hoftext4				db '    ZeroKelvinKeyboard for creating TachyonOS & writing apps for MikeOS', 13, 10
	.hoftext3				db '    Sebastian Mihai for creating & releasing the source code of aSMtris', 13, 10
	.hoftext6				db '    Jasper Ziller for making the Fisher game', 13, 10
	.hoftext7				db '    Leonardo Ono for making the Snake game', 13, 10
	.hoftext9				db '    My wonderful classmates for providing feedback (and doing bug-hunting)', 13, 10
	.hoftext5				db '    And, of course, best for last, Mike Saunders, for making MikeOS :)', 13, 10
	.hoftextend				db 13, 10, '  Press Space to return...', 0

	%INCLUDE "../source/features/name.asm"
	
draw_background:
	mov ax, .title_msg
	mov bx, .footer_msg
	mov cx, 7
	call os_draw_background
	ret
	
	.title_msg			db 'About InpyoOS', 0
	.footer_msg			db 0

; ------------------------------------------------------------------

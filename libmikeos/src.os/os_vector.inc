; %define os_main                         0000h
; %define os_print_string                 0003h
; %define os_move_cursor                  0006h
; %define os_clear_screen                 0009h
; %define os_print_horiz_line             000Ch
; %define os_print_newline                000Fh
; %define os_wait_for_key                 0012h
; %define os_check_for_key                0015h
; %define os_int_to_string                0018h
; %define os_speaker_tone                 001Bh
; %define os_speaker_off                  001Eh
; %define os_load_file                    0021h
; %define os_pause                        0024h
; %define os_fatal_error                  0027h
; %define os_draw_background              002Ah
; %define os_string_length                002Dh
; %define os_string_uppercase             0030h
; %define os_string_lowercase             0033h
; %define os_input_string                 0036h
; %define os_string_copy                  0039h
; %define os_dialog_box                   003Ch
; %define os_string_join                  003Fh
; %define os_get_file_list                0042h
; %define os_string_compare               0045h
; %define os_string_chomp                 0048h
; %define os_string_strip                 004Bh
; %define os_string_truncate              004Eh
; %define os_bcd_to_int                   0051h
; %define os_get_time_string              0054h
; %define os_get_api_version              0057h
; %define os_file_selector                005Ah
; %define os_get_date_string              005Dh
; %define os_send_via_serial              0060h
; %define os_get_via_serial               0063h
; %define os_find_char_in_string          0066h
; %define os_get_cursor_pos               0069h
; %define os_print_space                  006Ch
; %define os_dump_string                  006Fh
; %define os_print_digit                  0072h
; %define os_print_1hex                   0075h
; %define os_print_2hex                   0078h
; %define os_print_4hex                   007Bh
; %define os_long_int_to_string           007Eh
; %define os_long_int_negate              0081h
; %define os_set_time_fmt                 0084h
; %define os_set_date_fmt                 0087h
; %define os_show_cursor                  008Ah
; %define os_hide_cursor                  008Dh
; %define os_dump_registers               0090h
; %define os_string_strincmp              0093h
; %define os_write_file                   0096h
; %define os_file_exists                  0099h
; %define os_create_file                  009Ch
; %define os_remove_file                  009Fh
; %define os_rename_file                  00A2h
; %define os_get_file_size                00A5h
; %define os_input_dialog                 00A8h
; %define os_list_dialog                  00ABh
; %define os_string_reverse               00AEh
; %define os_string_to_int                00B1h
; %define os_draw_block                   00B4h
; %define os_get_random                   00B7h
; %define os_string_charchange            00BAh
; %define os_serial_port_enable           00BDh
; %define os_sint_to_string               00C0h
; %define os_string_parse                 00C3h
; %define os_run_basic                    00C6h
; %define os_port_byte_out                00C9h
; %define os_port_byte_in                 00CCh
; %define os_string_tokenize              00CFh
%define os_main					8000h
%define os_print_string			8003h
%define os_move_cursor			8006h
%define os_clear_screen			8009h
%define os_print_horiz_line		800Ch
%define os_print_newline		800Fh
%define os_wait_for_key			8012h
%define os_check_for_key		8015h
%define os_int_to_string		8018h
%define os_speaker_tone			801Bh
%define os_speaker_off			801Eh
%define os_load_file			8021h
%define os_pause				8024h
%define os_fatal_error			8027h
%define os_draw_background		802Ah
%define os_string_length		802Dh
%define os_string_uppercase		8030h
%define os_string_lowercase		8033h
%define os_input_string			8036h
%define os_string_copy			8039h
%define os_dialog_box			803Ch
%define os_string_join			803Fh
%define os_get_file_list		8042h
%define os_string_compare		8045h
%define os_string_chomp			8048h
%define os_string_to_hex		804Bh
%define os_adlib_regwrite		804Eh
%define os_bcd_to_int			8051h
%define os_get_time_string		8054h
%define os_draw_logo			8057h
%define os_file_selector		805Ah
%define os_get_date_string		805Dh
%define os_send_via_serial		8060h
%define os_get_via_serial		8063h
%define os_find_char_in_string	8066h
%define os_get_cursor_pos		8069h
%define os_print_space			806Ch
%define os_option_menu			806Fh
%define os_print_digit			8072h
%define os_print_1hex			8075h
%define os_print_2hex			8078h
%define os_print_4hex			807Bh
%define os_vesa_scan			807Eh
%define os_report_free_space	8081h
%define os_string_add			8084h
%define os_draw_char			8087h
%define os_show_cursor			808Ah
%define os_hide_cursor			808Dh
%define os_dump_registers		8090h
%define UPC						8093h
%define os_write_file			8096h
%define os_file_exists			8099h
%define os_create_file			809Ch
%define os_remove_file			809Fh
%define os_rename_file			80A2h
%define os_get_file_size		80A5h
%define os_input_dialog			80A8h
%define os_list_dialog			80ABh
%define os_string_reverse		80AEh
%define os_string_to_int		80B1h
%define os_draw_block			80B4h
%define os_get_random			80B7h
%define os_print_32int			80BAh
%define os_serial_port_enable	80BDh
%define os_sint_to_string		80C0h
%define os_string_parse			80C3h
%define os_run_basic			80C6h
%define os_adlib_calcfreq		80C9h
%define os_attach_app_timer		80CCh
%define os_string_tokenize		80CFh
%define os_clear_registers		80D2h
%define os_format_string		80D5h
%define os_vesa_mode			80D8h
%define os_vesa_pixel			80DBh
%define os_return_app_timer		80DEh
%define os_reset_font			80E1h
%define os_update_clock			80E4h
%define os_crash_application	80E7h
%define os_check_adlib			80EAh
%define os_draw_line			80EDh
%define os_draw_polygon			80F0h
%define os_draw_circle			80F3h
%define os_clear_graphics		80F6h
%define os_get_file_datetime	80F9h
%define os_string_encrypt		80FCh
%define os_put_pixel			80FFh
%define os_get_pixel			8102h
%define os_draw_icon			8105h
%define os_change_disk			8108h
%define os_drive_letter			810Bh
%define os_int_1Ah				810Eh
%define os_int_to_bcd			8111h
%define os_illegal_call			8114h
%define os_password_dialog		8117h
%define os_illegal_call			811Ah
%define os_draw_rectangle		811Dh
%define os_get_memory			8120h
%define os_color_selector		8123h
%define os_modify_int_handler	8126h
%define os_32int_to_string		8129h
%define os_print_footer			812Ch
%define os_print_8hex			812Fh
%define os_string_to_32int		8132h
%define os_math_power			8135h
%define os_math_root			8138h
%define os_input_password		813Bh
%define os_get_int_handler		813Eh
%define os_illegal_call			8141h
%define os_temp_box				8144h
%define os_illegal_call			8147h
%define os_read_root			814Ah
%define os_illegal_call			814Dh
%define os_illegal_call			8150h
%define os_illegal_call			8153h
%define disk_convert_l2hts		8156h
%define mouselib_locate			8159h
%define mouselib_move			815Ch
%define mouselib_show			815Fh
%define mouselib_hide			8162h
%define mouselib_range			8165h
%define mouselib_wait			8168h
%define mouselib_anyclick		816Bh
%define mouselib_leftclick		816Eh
%define mouselib_middleclick	8171h
%define mouselib_rightclick		8174h
%define mouselib_scale			8177h
%define mouselib_setup			817Ah
%define mouselib_remove_driver	817Dh
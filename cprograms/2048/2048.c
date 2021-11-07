/*
2048 game for InpyoOS
*/

#include <mikeos.h>



#define BOX_TOPLEFT     218 // ┌
#define BOX_HORIZ       196 // ─
#define BOX_TOPRIGHT    191 // ┐
#define BOX_VERT        179 // │
#define BOX_BOTTOMLEFT  192 // └
#define BOX_BOTTOMRIGHT 217 // ┘
#define BOX_TOPJUNCT    194 // ┬
#define BOX_LEFTJUNCT   195 // ├
#define BOX_RIGHTJUNCT  180 // ┤
#define BOX_MIDJUNCT    197 // ┼
#define BOX_BOTTOMJUNCT 193 // ┴
#define BOX_SPACE       32 // ' '

static char TOP_LINE[22] = {BOX_TOPLEFT, 
						BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_TOPJUNCT, 
						BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_TOPJUNCT,
						BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_TOPJUNCT,
						BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_TOPRIGHT};
						
static char MIDDLE_SPACE_LINE[22] = {BOX_VERT,
						BOX_SPACE, BOX_SPACE, BOX_SPACE, BOX_SPACE, BOX_VERT,
						BOX_SPACE, BOX_SPACE, BOX_SPACE, BOX_SPACE, BOX_VERT,
						BOX_SPACE, BOX_SPACE, BOX_SPACE, BOX_SPACE, BOX_VERT,
						BOX_SPACE, BOX_SPACE, BOX_SPACE, BOX_SPACE, BOX_VERT};
						
static char MIDDLE_LINE[22] = {BOX_LEFTJUNCT,
						BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_MIDJUNCT,
						BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_MIDJUNCT,
						BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_MIDJUNCT,
						BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_RIGHTJUNCT};

static char BOTTOM_LINE[22] = {BOX_BOTTOMLEFT,
						BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_BOTTOMJUNCT,
						BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_BOTTOMJUNCT,
						BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_BOTTOMJUNCT,
						BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_HORIZ, BOX_BOTTOMRIGHT};

static int board[16] = {0,0,0,0,
						0,0,0,0,
						0,0,0,0,
						0,0,0,0};

static int score = 0;


void copy_board(int* new_borad, int* board_to_copy)
{
	int i;
	for (i = 0; i < 16; i++)
	{
		new_borad[i] = board_to_copy[i];
	}
}

int same_board(int* borad1, int* board2)
{
	int i;
	for (i = 0; i < 16; i++)
	{
		if (borad1[i] != board2[i])
		{
			return 0;
		}
	}
	return 1;
}

int board_has_empty_place(){
	int i;
	for (i = 0; i < 16; i++){
		if(board[i] == 0){
			return 1;
		}
	}
	return 0;
}

void put_in_random_place_in_board(){
	unsigned int pos = mikeos_get_random(0, 15);
	unsigned int rpos;
	for(; pos <= 15; pos++){
		rpos = pos % 16;
		if(board[rpos] == 0){
			board[rpos] = 2;
			return;
		}
	}
}

int game_win_or_nostaus_or_lose(){
	int i,j;
	for(i=0; i < 16; i++){
		if(board[i] == 2048){
			return 2;
		} else if(board[i] == 0){
			return 1;
		} 
	}
	for(i = 0; i < 16; i+=4){
		for(j = 0; j < 3; j++){
			if(board[i+j] == board[i+j + 1]){
				return 1;
			}
		}
	}
	for(i = 0; i < 4; i++){
		for(j = i; j < 12; j+=4){
			if(board[j] == board[j+ 4]){
				return 1;
			}
		}
	}
	return 0;
}

int can_move_left_or_write(int *board){
	int i,j = 0;
	for(i = 0; i < 16; i+=4){
		for(j = 0; j < 3; j++){
			if(board[i+j] == board[i+j + 1]){
				return 1;
			}
		}
	}
	return 0;
}

void merge_left(int *board) {
 	int space, i,j;
	for (j = 0; j <= 3; j++) {
		space=0;
		for (i = j*4; i <= j*4+3; i++) {
			if (board[i] == 0 ){
				space++;
			} else if (i-space-1 >= j*4 && board[i-space-1] == board[i]){
				score += board[i-space-1]*2;
				board[i-space-1]*=2;
				board[i] = 0;
				space++;
			} else if (i-space >= j*4 && board[i-space] == 0) {
				board[i-space] = board[i];
				board[i] = 0;
			}
		}
	}
}

void merge_up(int *board) {
 	int space, i,j;
	for (j = 0; j <= 3; j++) {
		space=0;
		for (i = j; i < 16; i+=4) {
			if (board[i] == 0 ){
				space++;
			} else if (i-space*4-4 >= j && board[i-space*4-4] == board[i]){
				score += board[i-space*4-4]*2;
				board[i-space*4-4]*=2;
				board[i] = 0;
				space++;
			} else if (i-space*4 >= j && board[i-space*4] == 0) {
				board[i-space*4] = board[i];
				board[i] = 0;
			}
		}
	}
}

void merge_down(int *board) {
 	int space, i,j;
	for (j = 12; j <= 15; j++) {
		space=0;
		for (i = j; i >= 0; i-=4) {
			if (board[i] == 0 ){
				space++;
			} else if (i+(space*4)+4 <= j && board[i+(space*4)+4] == board[i]){
				score += board[i+(space*4)+4]*2;
				board[i+(space*4)+4]*=2;
				board[i] = 0;
				space++;
			} else if (i+(space*4) <= j && board[i+(space*4)] == 0) {
				board[i+(space*4)] = board[i];
				board[i] = 0;
			}
		}
	}
}

void merge_right(int *board) {
 	int space, i,j;
	for (j = 0; j <= 3; j++) {
		space=0;
		for (i = j*4+3; i >= j*4; i--) {
			if (board[i] == 0 ){
				space++;
			} else if (i+space+1 <= j*4+3 && board[i+space+1] == board[i] ){
				score += board[i+space+1]*2;
				board[i+space+1]*=2;
				board[i] = 0;
				space++;
			} else if (i+space <= j*4+3 && board[i+space] == 0 ) {
				board[i+space] = board[i];
				board[i] = 0;
			}
		}
	}
}

void draw_table(){
	int i=0;
	mikeos_move_cursor(30, 8);
	mikeos_print_string(TOP_LINE);
	
	for(i=9; i<=14; i+=2){
		mikeos_move_cursor(30, i);
		mikeos_print_string(MIDDLE_SPACE_LINE);
		mikeos_move_cursor(30, i+1);
		mikeos_print_string(MIDDLE_LINE);
	}
	mikeos_move_cursor(30, 15);
	mikeos_print_string(MIDDLE_SPACE_LINE);
	mikeos_move_cursor(30, 16);
	mikeos_print_string(BOTTOM_LINE);
}

int four_digit_left_space(int n){
	if(n < 10){return 3;}
	if(n < 100){return 2;}
	if(n < 1000){return 1;}
	return 0;
}

void  update_score(){
	static char score_string[6];
	mikeos_int_to_string(score_string, score);
	mikeos_move_cursor(15, 6);
	mikeos_print_string(score_string);
}

void draw_board(){
	static char out_string[5];
	int i,j,k = 0;
	update_score();
	for(i = 0; i < 4; i++){
		for(j=0; j < 4; j++){
			mikeos_move_cursor(31+(j*5), 9+i*2);
			mikeos_int_to_string(out_string, board[i*4+j]);

			mikeos_print_string("    ");
			mikeos_move_cursor(31+(j*5), 9+i*2);
			if (board[i*4+j] != 0){

				mikeos_print_string(out_string);
			}
			
		}
	}
}

void draw_background(){
	static char title[] = "InpyoOS 2048 GAME";
	static char subtitle[] = "Press Esc to exit";

	static char desc[]  = "        Use your w,a,s,d keys to move the tiles.";
	static char desc2[] = "        Tiles with the same number merge into one when they touch.";
	static char desc3[] = "        Add them up to reach 2048!";
	static char score_desc[] = "        SCORE: ";

	mikeos_draw_background(title, subtitle, 0x0060);

	mikeos_print_newline();
	mikeos_print_string(desc);
	mikeos_print_newline();
	mikeos_print_string(desc2);
	mikeos_print_newline();
	mikeos_print_string(desc3);
	mikeos_print_newline();
	mikeos_print_newline();

	mikeos_print_string(score_desc);
}

void reset(){
	int i;
	score = 0;
	draw_background();

	draw_table();
	for(i = 0; i < 16; i++){
		board[i] = 0;
	}
	mikeos_hide_cursor();
}

int play(){
	int ok_to_put=1;
	unsigned int key, status, ascii;
	static int pre_board[16];
	reset();

	while(1){
		if(board_has_empty_place() == 1 && ok_to_put == 1){
			put_in_random_place_in_board();
		}
		ok_to_put = 0;
		draw_board();

		status = game_win_or_nostaus_or_lose();
		if (status == 2){
			return mikeos_dialog_box("You Win!", "press OK for redo", "press CANCEL for exit", 1);
		} else if (status == 0){
			return mikeos_dialog_box("You Lose!", "press OK for redo", "press CANCEL for exit", 1);
		}


		key = mikeos_wait_for_key();
		ascii = key & 0x00ff;


		/* determine next cursor position */
		copy_board(pre_board, board);
		switch (ascii) {
		case	0x0077:	/* up */
			merge_up(board);
			break;
		case	0x0073:	/* down */
			merge_down(board);
			break;
		case	0x0061:	/* left */
			merge_left(board);
			break;
		case	0x0064:	/* right */
			merge_right(board);
			break;
		case 0x001B:
			return 1;
		default:	/* do nothing */
			break;
		}
		if (same_board(pre_board, board) == 0){
			ok_to_put = 1;
		}
	}
}


int	MikeMain(void *argument)
{	

	while (play() == 0);
	mikeos_clear_screen();
	// mikeos_print_4hex(game_win_or_nostaus_or_lose());
	return 0;
}

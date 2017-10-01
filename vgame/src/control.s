;PERSONAL TRIES
	;;=====================
	;; checkUserInput: Our approach (Doesn't work for firmware disabled)
	;;=====================

	;RIGHT BUTTON FIRST
	;------------------

	;ld a, (key_right)		;check if right button is pressed
	;call #0xBB1E			;call the checker KM_TEST KEY
	;jr nz, pressedRight		;Not Zero = pressed.
	;jr skipRight			;Skips right function

	;	pressedRight:
	;		call moveRightMain	;Moves main character to right

	;skipRight:

	;ld a, (key_left)		;check if left button is pressed
	;call #0xBB1E			;call the checker KM_TEST KEY
	;jr nz, pressedLeft		;Not Zero = pressed.
	;jr skipLeft			;Skips right function

	;	pressedLeft:
	;		call moveLeftMain	;Moves main character to right

	;skipLeft:


.area _DATA
	;==================
	;;;PRIVATE DATA
	;==================

	;key positions
.equ key_right ,#0x2007
.equ key_left  ,#0x2008
.equ key_up    ,#0x0807
.equ key_down  ,#0x1007
	;shoot dir
.equ key_dir_right ,#0x0200
.equ key_dir_left  ,#0x0101
.equ key_dir_up    ,#0x0100
.equ key_p  	   ,#0x0803
	;general directions
.equ up 		,#0
.equ down 		,#1
.equ left 		,#2
.equ right 		,#3

.equ key_jump  ,#0x8005

	;==================
	;;;PUBLIC FUNCIONS
	;==================

	;main character data
	hero_x:: .db #60
	hero_y:: .db #160
	hero_x_size:: .db #0x04
	hero_y_size:: .db #0x08
	hero_jump: .db #-1		;initially, it's not jumping
	hero_dir: .db #0
	jump_table:
		.db #-5 ,#-4 ,#-3 ,#-2
		.db #-1 ,#-1 ,#0

.area _CODE

	;===================
	;;;INCLUDE FUNCTIONS
	;===================

	.include "cpctelera.h.s"
	.include "collision.h.s"
	;NEW
	.include "shoot.h.s"
	;===================
	;;;PRIVATE FUNCTIONS
	;===================

	;Moving in the direction given
	;Specify the object to move
	;	and the direction
	;
	;NEEDS:	
	;	B-> direction to move (0,up,1,right,2,down,3,left)
	;	HL-> Beginning memory direction of the object
	;
	;CORRUPTS:
	; 	A, B, HL

	moveObject::
		ld a, b 						;load direction of movement in B to A

		cp #up 							;check if it is going up
		jr nz, end_moveObject_1			;if 0, then not moving up, continue trying

			;Is going up
			inc hl 				;increment hl position to access its Y
			ld a, (hl)			;load in A to
			sub #02				;displaces the object 2 positions up
			ld (hl), a 			;reloads info in position Y of the object
			jr end_moveObject 	;jumps to end of movement

		end_moveObject_1:

		cp #down 						;check if it is 0
		jr nz, end_moveObject_2			;if 0, then not moving down, continue trying

			;Is going down
			inc hl 				;increment hl position to access its Y
			ld a, (hl)			;load in A to
			add a, #02	 		;displaces the object 2 positions down
			ld (hl), a 			;reloads info in position Y of the object
			jr end_moveObject 	;jumps to end of movement

		end_moveObject_2:

		cp #left 						;check if it is 0
		jr nz, end_moveObject_3			;if 0, then not moving left, continue trying

			;Is going left
			ld a, (hl)			;load in A to
			dec a				;displaces the object to the left
			ld (hl), a 			;reloads info in position X of the object
			jr end_moveObject 	;jumps to end of movement

		end_moveObject_3:

		cp #right 						;check if it is 0
		jr nz, end_moveObject			;if 0, then not moving right, then not moving

			;Is going right
			ld a, (hl)			;load in A to
			inc a				;displaces the object to the right
			ld (hl), a 			;reloads info in position X of the object

		end_moveObject:

		ret



	;Moving main character throughout 4 axis
	;CORRUPTS:
	;	HL, B, A

	moveRightMain:
		ld a, (hero_x)
		cp #80-8
		ret z 			;can't move further than 80-8

		ld hl, #hero_x 		;loading hero x data
		ld b, #right 		;loading in B the axis to move on

		call moveObject
		;NEW
		ld 		a, #2
		ld 		(hero_dir), a
		ret

	moveLeftMain:
		ld a, (hero_x)
		cp #0
		ret z 			;can't move further than 0


		ld hl, #hero_x
		ld b, #left
		call moveObject
		;NEW
		ld 		a, #1
		ld 		(hero_dir), a
		ret

	moveJumpMain:
		ld 	a, (hero_jump)	; A = hero jump iteration
		cp 	#-1
		ret nz 				;if it's -1,  jump

		;Main character is not jumping, so jump
		inc a
		ld (hero_jump), a 	;iteration starts at next position

		ret
	;======
	;NUEVO|
	;======
	shootLeftDir:
		ld 		a, #1
		;ld 		(bullet_dir), a
		ret
	shootRightDir:
		ld 		a, #2
		;ld 		(bullet_dir), a
		ret
	shootTop:
		;ld 		a, #1
		ret
	shootPressed:
	ld 		a, (hero_dir)
		call 	shootBullet
		ret
	;===================
	;;;PUBLIC FUNCTIONS
	;===================

	;;Checks if main character is jumping
	;;CORRUPTS:
	;;	HL, A, BC.
	jumpControl::
		ld a, (hero_jump)					;loading jumping situation
		cp #-1 								;-1 indica que no está saltando
		jr nz, continue_jumpControl	 		;Si se da con que no está saltando, salta

			;if it is not jumping, it tries to fall

			;;First we check if there are obstacles under
			;ld hl, #hero_x
			;ld de, #obs_x
			;call avoidCollisionDown		; |
			;cp #1						; 1 means, you can't keep falling.
			;jp z, stop_falling_jumpControl

			;;Now we check if its the end of the map
			ld a, (hero_y) 					; A = hero_y
			ld b, a
			ld a, #200-64 					; preparing positive substraction
			sub b 							; if this is negative (actual position - 136), then it must fall
			
			jp z, stop_falling_jumpControl	; |
			jp m, stop_falling_jumpControl	; if it is negative, you can't keep falling


			ld a, (hero_y)
			add #03 						; hero_y += 3 -> gravity
			ld (hero_y), a

			stop_falling_jumpControl:		;deja de caer

			ret



		continue_jumpControl:

		;load jumping iteration
		ld hl, #jump_table	;load first position of jumping
		ld c,  a 			;load the jump situation in c, and 0 in b
		ld b, #0
		add hl, bc 			;move to the position of actual jump

			;make it jump
			ld b, (hl)		;B = jump value
			ld a, (hero_y)	;A = hero_y
			add b 			;a = a + b
			ld (hero_y), a  ;hero_y = new jump position

		;update hero_jump index
		ld a, (hero_jump)	;loading actual jump iteration
		cp #06
		jr nz, continue_main_jump ;continue hero jumping

			;;End jumping
			ld a, #-2		;I load -2, cause later it adds 1 so it stays at -1

		continue_main_jump:
		inc a 				;
		ld (hero_jump), a 	;jumping iteration set to next

		ret					;termina el salto y salta



	;;Checks user input and then moves the main character
	;;CORRUPTS:
	;;	HL, A.

	checkUserInput::
		;;======
		;; Fran's approach
		;;======

		;;FIRST OF ALL: Examine keyboard
		call cpct_scanKeyboard_asm  ;checks a key is pressed
		
		;;CHECK COLLISIONS WITH ENVIRORMENT
		ld hl, #hero_x
		ld de, #obs_x
		call avoidCollisionRight
		cp #1
		jp z, skipRight			 ;;-----TESTING---------- if there is a collision, you can't move right


		ld hl, #key_right 			 ;loads key_D in hl
		call cpct_isKeyPressed_asm	 ;checks if the key loaded in hl is pressed
		cp #0 						 ;checks if debugger leaves a 0 behind, if it is 0, then D is not pressed
		jr z, skipRight				 ;This goes to Right not pressed

			;right is pressed
			call moveRightMain

		skipRight:


		ld hl, #key_left			 ;loads key_A in hl
		call cpct_isKeyPressed_asm	 ;checks if the key loaded in hl is pressed
		cp #0 						 ;checks if debugger leaves a 0 behind, if it is 0, then A is not pressed
		jr z, skipLeft			 	 ;This goes to Left not pressed

			;left is pressed
			call moveLeftMain

		skipLeft:


		ld hl, #key_up				 ;loads key_W in hl
		call cpct_isKeyPressed_asm	 ;checks if the key loaded in hl is pressed
		cp #0 						 ;checks if debugger leaves a 0 behind, if it is 0, then W is not pressed
		jr z, skipUp			 	 ;This goes to up not pressed

			;left is pressed
			call moveJumpMain

		;======
		;NUEVO|
		;======
		skipUp:
		ld hl, #key_dir_up				 ;loads key_W in hl
		call cpct_isKeyPressed_asm	 ;checks if the key loaded in hl is pressed
		cp #0 						 ;checks if debugger leaves a 0 behind, if it is 0, then W is not pressed
		jr z, skipDirUp			 	 ;This goes to up not pressed

			;dirUp is pressed
			call shootTop
		skipDirUp:
		ld hl, #key_dir_left				 ;loads key_W in hl
		call cpct_isKeyPressed_asm	 ;checks if the key loaded in hl is pressed
		cp #0 						 ;checks if debugger leaves a 0 behind, if it is 0, then W is not pressed
		jr z, skipDirLeft			 	 ;This goes to up not pressed

			;dirLeft is pressed
			call shootLeftDir

		skipDirLeft:
		ld hl, #key_dir_right				 ;loads key_W in hl
		call cpct_isKeyPressed_asm	 ;checks if the key loaded in hl is pressed
		cp #0 						 ;checks if debugger leaves a 0 behind, if it is 0, then W is not pressed
		jr z, skipDirRight			 	 ;This goes to up not pressed

			;dirRight is pressed
			call shootRightDir

		skipDirRight:
		ld hl, #key_p				 ;loads key_W in hl
		call cpct_isKeyPressed_asm	 ;checks if the key loaded in hl is pressed
		cp #0 						 ;checks if debugger leaves a 0 behind, if it is 0, then W is not pressed
		jr z, skipP			 	 ;This goes to up not pressed

			;keyP is pressed
			call shootPressed

		skipP:



		continueEnd:

		ret
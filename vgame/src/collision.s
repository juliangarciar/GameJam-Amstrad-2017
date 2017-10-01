.area _DATA
	;==================
	;;;PRIVATE DATA
	;==================


	;==================
	;;;PUBLIC FUNCIONS
	;==================

	;main character data
	obs_x:: .db #20
	obs_y:: .db #80

	obs_x_size:: .db #0x04
	obs_y_size:: .db #0x08

.area _CODE

	.include "cpctelera.h.s"

	;==================
	;;;TEST FUNCTIONS
	;==================

	drawBox::
		push	af 							;;Save A in the stack

		;;Calculate Screen position
		ld 		de, #0xC000					;;Video memory Pointer
		ld		a, (obs_x)					;; C=Hero_x
		ld		c, a        

		ld		a, (obs_y)					
		ld		b, a 						;; B=Hero_y

		call 	cpct_getScreenPtr_asm		;; Get pointer to screen

		ex		de, hl        				;;Swap data
		pop		af

		ld 		bc, #0x0804					;;Width && height
		call 	cpct_drawSolidBox_asm

		ret

	moveBox::
		ld a, (obs_x)
		cp #20
		jr nz, moveBox_bien

			;no mover la cajita
			ret

		moveBox_bien:
		dec a
		ld (obs_x),a 	;just moving to the left, testing

		ret

	;==================
	;;;PRIVATE FUNCTIONS
	;==================

	checkObstacleX:
		;Formulae for collisions on X
		;if(obs_x + obs_w <= hero_x) -> if(obs_x + obs_w - hero_x <= 0)

		ld a, (de)			; |
		ld c, a 			; C = obs_x
		inc de
		inc de 				; +2 positions in memory in x_size
		ld a, (de)			; A = obs_x_size
		dec de
		dec de 				; -2 positions to return to original
		add c 				; A = obs_x + obs_x_size
		sub (hl)			; A = obs_x + obs_x_size - hero_x

		jr z, no_collision_x ;if it gives a 0, then no collision is done
		jp m, no_collision_x ;if its less than 0, it's collision

			;;here it might still collide
			;;formulae: if(hero_x + hero_x_size <= obs_x) -> if(hero_x + hero_x_size - obs_x <= 0)

				ld a, (hl)		; |
				ld c, a 		; C = hero_x
				inc hl
				inc hl			; +2 positions in memory is x_size
				ld a, (hl)		; A = hero_x_size
				dec hl
				dec hl 			; -2 positions to return to original
				add c 			; A = hero_x + hero_x_size
				ld b, a			; B = A
				ld a, (de)	; A = obs_X
				ld c, a 		; C = obs_x
				ld a, b 		; A = hero_x + hero_x_size
				sub c			; A = hero_x + hero_x_size - obs_x

				jr z, no_collision_x ;if it gives a 0, then no collision either
				jp m, no_collision_x ;if its less than 0, less of a collision, NOTHING

				;;If it goes by here, there is collision in both sides
				ld a, #1
				ret 			;return in A a 1

		no_collision_x:

		ld a, #0
		ret 			;return without collision

	checkObstacleY:
		;Formulae for collisions on Y
		;if(obs_y + obs_h <= hero_y) -> if(obs_y + obs_h - hero_y <= 0)

		ld a, (de)			; |
		ld c, a 			; C = obs_y
		inc de
		inc de 				; +2 positions in memory to reach y_size
		ld a, (de)			; A = obs_y_size
		dec de
		dec de 				; -2 positions in memory so to return
		add c 				; A = obs_y + obs_y_size
		sub (hl)			; A = obs_y + obs_y_size - hero_y

		jr z, no_collision_y ;if it gives a 0, then no collision is done
		jp m, no_collision_y ;if its less than 0, it's collision

			;;here it might still collide
			;;formulae: if(hero_y + hero_y_size <= obs_y) -> if(hero_y + hero_y_size - obs_y <= 0)

				ld a, (hl)		; |
				ld c, a 		; C = hero_y
				inc hl
				inc hl			; +2 positions in memory is y_size
				ld a, (hl)		; A = hero_y_size
				dec hl
				dec hl 			; -2 positions to return to original
				add c 			; A = hero_y + hero_y_size
				ld b, a			; B = A
				ld a, (de)		;A = obs_y
				ld c, a 		; C = obs_y
				ld a, b 		; A = hero_y + hero_y_size
				sub c			; A = hero_y + hero_y_size - obs_y

				jr z, no_collision_y ;if it gives a 0, then no collision either
				jp m, no_collision_y ;if its less than 0, less of a collision, NOTHING

				;;If it goes by here, there is collision in both sides
				ld a, #1
				ret 			;return in A a 1

		no_collision_y:

		ld a, #0
		ret 			;return without collision


	;==================
	;;;PUBLIC FUNCTIONS
	;==================


	avoidCollisionRight::

		;;FOR NOW: IT ONLY AVOIDS RIGHT COLLISIONS

		ld a, (hl) 		;loading actual X in A
		inc a 			;moving 2 position to the right
		ld (hl), a 		;relocating

		call deathCollision 		;analizing collision
		cp #1
		jr z, right_avoidCollision 	;avoid collision if returns a 1

			;continue the movement
			ld a, #0

			ld b, (hl)
			dec b
			ld (hl), b 		;reflourish position
			ret

		right_avoidCollision:
		ld a, #1

		ld b, (hl)
		dec b
		ld (hl), b 			;reflourish position

		ret

	avoidCollisionDown::

		;;FOR NOW: IT ONLY AVOIDS DOWN COLLISIONS

		inc hl			;increasing Y so to make prediction

		ld a, (hl) 		;loading actual X in A
		add #01 		;moving 2 positions to the right
		ld (hl), a 		;relocating
		
		dec hl			;returning to original position

		call deathCollision ;analizing collision
		cp #1
		jr z, down_avoidCollision

			;no need to avoid
			inc hl
			ld a, (hl)
			sub #01
			ld (hl), a 		;restoring values to object position

			dec hl			;return to initial position

			ld a, #1
			ret


		down_avoidCollision:
		inc hl

		ld a, (hl)
		sub #01
		ld (hl), a 		;restoring values to object position

		dec hl 			;return to initial position

		ld a, #0
		ret

	avoidCollision::
		ret

	deathCollision::
		call checkObstacleX
		cp #0					
		jr z, no_deathCollision_X		;if A turns to be 0, there's no collision on X

		inc hl						;set Y position to check
		inc de 						;same
		call checkObstacleY
		cp #0
		jr z, no_deathCollision		;if A turns to be 0, there's no collision on Y

			;;Collision zone
			dec hl
			dec de 				;restoring values to default
			ld a, #1
			ret 				;if collision, returns A with a 1

		no_deathCollision:
		dec hl
		dec de 				;restoring values to default

		no_deathCollision_X:
		ld a, #0
		ret					;if no collision, returns A with a 0

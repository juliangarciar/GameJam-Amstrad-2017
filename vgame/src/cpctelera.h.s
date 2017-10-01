;;;;;;;;;;;;;;;;;;;
;CPCTELERA SYMBOLS;
;;;;;;;;;;;;;;;;;;;

;============================
;JUST IN CASE CODE
;============================

;Reenables firmware to be used
;CORRUPTS:
;	HL
;.globl cpct_reenableFirmware_asm

;============================
;USING CODE
;============================

	;============================
	;SPRITE CODE
	;============================


;2B DE) screen_start	Pointer to the start of the screen (or a backbuffer)
;(1B C ) x	[0-79] Byte-aligned column starting from 0 (x coordinate,
;(1B B ) y	[0-199] row starting from 0 (y coordinate) in bytes)
.globl cpct_getScreenPtr_asm


;(2B DE) memory	Video memory pointer to the upper left box corner byte
;(1B A ) colour_pattern	1-byte colour pattern (in screen pixel format) to fill the box with
;(1B C ) width	Box width in bytes [1-64] (Beware!  not in pixels!)
;(1B B ) height	Box height in bytes (>0)
.globl cpct_drawSolidBox_asm


	;============================
	;FIRMWARE CODE
	;============================

;wait por de raster to be at lowest screen part, to refresh all _DATA
;CORRUPTS:
;	AF, VC
.globl cpct_waitVSYNC_asm

;Disables firmware control, so we can use our colour mode, for example
.globl cpct_disableFirmware_asm

;Loads the video mode expressed in register C
;CORRUPTS
;	AF, BC, HL
.globl cpct_setVideoMode_asm

	;============================
	;KEYBOARD CODE
	;============================

;Checks if any key is pressed scanning through all the keyboard
.globl cpct_scanKeyboard_asm


;checks if a given key in HL is pressed
.globl cpct_isKeyPressed_asm


.globl cpct_drawCharM0_asm

.globl cpct_drawStringM0_asm










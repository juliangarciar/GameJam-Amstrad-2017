;===================
;;;PUBLIC DATA
;===================
.globl obs_x
.globl obs_y
.globl obs_x_size
.globl obs_y_size


;===================
;;;PUBLIC FUNCTIONS
;===================

.globl drawBox
.globl moveBox

;;Avoids collision between hero and objects
;;Saves in register A if pushed or not
;;NEEDS:
;;	HL:pointer to hero position
;;  DE:pointer to list of objects
;;CORRUPTS: MY SOUL
.globl avoidCollision

.globl avoidCollisionRight

.globl avoidCollisionDown

;;Checks if death collision happened between hero and object
;;Saves in register A 1 death, 0 no death
;;NEEDS:
;;	Pushed 2 pointers to objects to check
;;CORRUPTS: 
;;  AF, BC

.globl deathCollision
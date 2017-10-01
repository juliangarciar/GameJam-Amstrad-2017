.area _DATA
.area _CODE
.include "cpctelera.h.s"

enemy1_x:: .db #0
enemy1_y:: .db #0
enemy1_width:: .db #0x02
enemy1_heigth:: .db #0x02

enemy2_x:: .db #0
enemy2_y:: .db #0
enemy2_width:: .db #0x02
enemy2_heigth:: .db #0x02

updateEnemys::
	ret
moveEnemys::
	ret
dirEnemys::
	ret
checkBorders:
	ret
outside:
	ret
drawEnemys:;
	ret
eraseEnemys:
	ret
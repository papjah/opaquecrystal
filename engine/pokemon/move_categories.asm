; Copy the move category name of move b to wStringBuffer1
; @param b: move index
GetMoveCategoryName:
    ld a, b
    push hl
	ld l, a
	ld a, MOVE_CATEGORY
	call GetMoveAttribute
	pop hl

    ld hl, CategoryNames
    ld e, a
    ld d, 0
    add hl, de
    add hl, de
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld de, wStringBuffer1
    ld bc, MOVE_NAME_LENGTH
    jp CopyBytes

INCLUDE "data/moves/category_names.asm"

; TODO: These learnset check functions from the wiki tutorial need to be refactored and tested

CheckPartyCanLearnMove:
; Check if monster in party can learn move d
	ld e, 0
	xor a
	ld [wCurPartyMon], a
.loop
	ld c, e
	ld b, 0
	ld hl, wPartySpecies
	add hl, bc
	ld a, [hl]
	and a
	jr z, .no
	cp -1
	jr z, .no
	cp EGG
	jr z, .next

	ld [wCurPartySpecies], a
	ld a, d
; Check the TM/HM/Move Tutor list
	ld [wPutativeTMHMMove], a
	push de
	farcall CanLearnTMHMMove
	pop de
.check
	ld a, c
	and a
	jr nz, .yes
; Check the Pokemon's Level-Up Learnset
	ld b,b
	ld a, d
	push de
	call CheckLvlUpMoves
	pop de
	jr nc, .yes
; done checking

.next
	inc e
	jr .loop

.yes
	ld a, e
	; which mon can learn the move
	ld [wCurPartyMon], a
	xor a
	ret
.no
	ld a, 1
	ret

CheckMonCanLearn_TM_HM:
; Check if wCurPartySpecies can learn move in 'a'
	ld [wPutativeTMHMMove], a
	ld a, [wCurPartySpecies]
	farcall CanLearnTMHMMove
.check
	ld a, c
	and a
	ret z
; yes
	scf
	ret

CheckMonKnowsMove:
	ld b, a
	ld a, MON_MOVES
	call GetPartyParamLocation
	ld d, h
	ld e, l
	ld c, NUM_MOVES
.loop
	ld a, [de]
	and a
	jr z, .next
	cp b
	jr z, .found ; knows move
.next
	inc de
	dec c
	jr nz, .loop
	ld a, -1
	scf ; mon doesnt know move
	ret
.found
	xor a
	ret z

CheckLvlUpMoves:
	ld d, a
	ld a, [wCurPartySpecies]
	call GetPokemonIndexFromID
	ld b, h
	ld c, l
	ld hl, EvosAttacksPointers
	ld a, BANK(EvosAttacksPointers)
	call LoadDoubleIndirectPointer
	ld [wStatsScreenFlags], a ; bank
	call FarSkipEvolutions
.learnset_loop
	call GetFarByte
  	and a
	jr z, .notfound
	inc hl
	call GetFarWord
	call GetMoveIDFromIndex
	cp d
	jr z, .found
	inc hl
	inc hl
	jr .learnset_loop

.found
	xor a
	ret ; move is in lvl up learnset
.notfound
	scf ; move isnt in lvl up learnset
	ret
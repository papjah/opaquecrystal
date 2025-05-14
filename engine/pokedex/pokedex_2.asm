	const_def
	const DEXENTRY_LORE      ; 0 ; bit 0, $1
	const DEXENTRY_BASESTATS ; 1 ; bit 1, $2
	const DEXENTRY_LVLUP     ; 2 ; bit 2, $4
	const DEXENTRY_FIELD     ; 3 ; bit 3, $8
	const DEXENTRY_EGG		 ; 4 ; bit 4, $10, 16
	const DEXENTRY_TMS       ; 5 ; bit 5, $20, 32
	; const DEXENTRY_HMS       ; bit 6, $40, 64
	const DEXENTRY_MTS       ; 6 ;bit 7, $80, 128
	const DEXENTRY_EVO		 ; 7
	const DEXENTRY_PICS      ; 8
	const DEXENTRY_AREA_NONE	;  9
	const DEXENTRY_AREA_GRASS_JOHTO   ; 10 / A
	const DEXENTRY_AREA_GRASS_KANTO   ; 11 / B
	const DEXENTRY_AREA_GRASS_SWARM   ; 12 / C
	const DEXENTRY_AREA_SURF_JOHTO    ; 13 / D
	const DEXENTRY_AREA_SURF_KANTO    ; 14 / E
	const DEXENTRY_AREA_SURF_SWARM   ; 15 / F
	const DEXENTRY_AREA_RODS    ; 16 / 0x10
	const DEXENTRY_AREA_TREES_COMMON   ; 17 / 0x11
	const DEXENTRY_AREA_TREES_RARE   ; 18 / 0x12
	const DEXENTRY_AREA_ROCKSMASH   ; 19 / 0x13
	const DEXENTRY_AREA_CONTEST ; 20 / 0x14
	const DEXENTRY_AREA_ROAMING ; 21 / 0x15
	const DEXENTRY_AREA_CASINO ; 22 / 0x16
	const DEXENTRY_AREA_NPCTRADES ; 23 / 0x17
	const DEXENTRY_AREA_EVENTWILDMONS ; 24 / 0x18
	const DEXENTRY_AREA_GIFTMONS ; 25 / 0x19
	
EXPORT DEXENTRY_LORE
EXPORT DEXENTRY_BASESTATS
EXPORT DEXENTRY_LVLUP
EXPORT DEXENTRY_FIELD
EXPORT DEXENTRY_EGG
EXPORT DEXENTRY_TMS
; EXPORT DEXENTRY_HMS
EXPORT DEXENTRY_MTS
EXPORT DEXENTRY_EVO		 ; 7
EXPORT DEXENTRY_PICS      ; 8

EXPORT DEXENTRY_AREA_GRASS_JOHTO
EXPORT DEXENTRY_AREA_GRASS_KANTO
EXPORT DEXENTRY_AREA_GRASS_SWARM

EXPORT DEXENTRY_AREA_SURF_JOHTO
EXPORT DEXENTRY_AREA_SURF_KANTO
EXPORT DEXENTRY_AREA_SURF_SWARM

EXPORT DEXENTRY_AREA_RODS
EXPORT DEXENTRY_AREA_TREES_COMMON
EXPORT DEXENTRY_AREA_TREES_RARE
EXPORT DEXENTRY_AREA_ROCKSMASH
EXPORT DEXENTRY_AREA_CONTEST
EXPORT DEXENTRY_AREA_ROAMING
EXPORT DEXENTRY_AREA_CASINO
EXPORT DEXENTRY_AREA_NPCTRADES
EXPORT DEXENTRY_AREA_EVENTWILDMONS
EXPORT DEXENTRY_AREA_GIFTMONS

EXPORT DEXENTRY_AREA_NONE

DEF NUM_FIELD_MOVES EQU 14 
DEF MOVESPAGES_CONT_MASK EQU %00000011

AnimateDexSearchSlowpoke:
	ld hl, .FrameIDs
	ld b, 25
.loop
	ld a, [hli]

	; Wrap around
	cp $fe
	jr nz, .ok
	ld hl, .FrameIDs
	ld a, [hli]
.ok

	ld [wDexSearchSlowpokeFrame], a
	ld a, [hli]
	ld c, a
	push bc
	push hl
	call DoDexSearchSlowpokeFrame
	pop hl
	pop bc
	call DelayFrames
	dec b
	jr nz, .loop
	xor a
	ld [wDexSearchSlowpokeFrame], a
	call DoDexSearchSlowpokeFrame
	ld c, 32
	call DelayFrames
	ret

.FrameIDs:
	; frame ID, duration
	db 0, 7
	db 1, 7
	db 2, 7
	db 3, 7
	db 4, 7
	db -2

DoDexSearchSlowpokeFrame:
	ld a, [wDexSearchSlowpokeFrame]
	ld hl, .SlowpokeSpriteData
	ld de, wShadowOAMSprite00
.loop
	ld a, [hli]
	cp -1
	ret z
	ld [de], a ; y
	inc de
	ld a, [hli]
	ld [de], a ; x
	inc de
	ld a, [wDexSearchSlowpokeFrame]
	ld b, a
	add a
	add b
	add [hl]
	inc hl
	ld [de], a ; tile id
	inc de
	ld a, [hli]
	ld [de], a ; attributes
	inc de
	jr .loop

.SlowpokeSpriteData:
	dbsprite  9, 11, 0, 0, $00, 0
	dbsprite 10, 11, 0, 0, $01, 0
	dbsprite 11, 11, 0, 0, $02, 0
	dbsprite  9, 12, 0, 0, $10, 0
	dbsprite 10, 12, 0, 0, $11, 0
	dbsprite 11, 12, 0, 0, $12, 0
	dbsprite  9, 13, 0, 0, $20, 0
	dbsprite 10, 13, 0, 0, $21, 0
	dbsprite 11, 13, 0, 0, $22, 0
	db -1

HandlePageNumReset:
	ld b, a
	ld a, [wPokedexEntryType]
	cp b
	ret z
	ld a, b
	ld [wPokedexEntryType], a
	xor a
	ld [wPokedexEntryPageNum], a
	ret

DisplayDexEntry:
	ld a, [wPokedexEntryType]
	and a
	jr nz, .next
	ld a, DEXENTRY_LORE
	call HandlePageNumReset
	hlcoord 8, 1
	ld a, [wPokedexShinyToggle]
	bit 0, a
	jr z, .not_shiny
	ld [hl], "<DEX_⁂>"
	jr .next
.not_shiny
	ld [hl], " "	
.next
	ld a, DEXENTRY_LORE
	call HandlePageNumReset
; erase bottom half of page
	hlcoord 1, 8
	lb bc, 8, SCREEN_WIDTH - 1
	call ClearBox
; take away page num and A press since we're assuming we haven't seen the mon
; will re-print if we have, later
	hlcoord 17, 5
	ld bc, 3 ; box 2 tiles high, 9 wide
	ld a, $4e ; category box horizontal line
	call ByteFill
; skinny horizontal line halfway down page
	hlcoord 1, 8
	ld bc, SCREEN_WIDTH - 1
	ld a, $55
	call ByteFill

	ld a, [wTempSpecies]
	ld b, a
	call GetDexEntryPointer ; returns b:de, bank and dex entry ptr
	ld a, b
	push af ; bank
	; de is already loaded
	hlcoord 9, 6
	call PlaceFarString ; dex species nickname
	push bc ; bank?
	push de ; dex entry ptr
	hlcoord 9, 7
	ld de, String_pokemon
	call PlaceString
	pop de ; dex entry ptr
	pop bc ; bank?
	ld h, b
	ld l, c
	push de ; dex entry ptr
	ld a, [wTempSpecies]
	call CheckCaughtMon
	pop hl ; dex entry ptr
	pop bc ; bank?
	jp z, UncaughtMon_Info_Erase_PageNum ; ret z ; leave if we havent caught
; Get the height of the Pokemon.
	ld a, [wCurPartySpecies]
	ld [wCurSpecies], a
	inc hl
	ld a, b
	push af
	inc hl
	inc hl
	inc hl
	push hl
	ld a, [wPokedexEntryPageNum]
	and a ; check for page 2
	jr nz, .page2
; Page 1
	call Pokedex_PrintPageNum
	pop de
	inc de
	pop af
	hlcoord 2, 10
	push af
	call PlaceFarString
	pop bc
	call DexEntry_IncPageNum
	ret

; Page 2
.page2
	pop de
	inc de
	pop af
	hlcoord 2, 10
	push af
	call PlaceFarString
	pop bc
	push bc
	push de
	lb bc, 5, SCREEN_WIDTH - 1
	hlcoord 1, 10
	call ClearBox
	hlcoord 1, 8
	ld bc, 19
	ld a, $55
	call ByteFill
	call Pokedex_PrintPageNum
	pop de
	inc de
	pop af
	hlcoord 2, 10
	call PlaceFarString
	xor a
	ld [wPokedexEntryPageNum], a
	ret

String_pokemon:
	db " #MON @"

GetDexEntryPointer:
; return dex entry pointer b:de
	push hl
	ld a, b
	call GetPokemonIndexFromID
	dec hl
	ld d, h
	ld e, l
	add hl, hl
	add hl, de
	ld de, PokedexDataPointerTable
	add hl, de
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld d, [hl]
	pop hl
	ret

GetDexEntryPagePointer:
	call GetDexEntryPointer
	push hl
	ld h, d
	ld l, e
; skip species name
.loop1
	ld a, b
	call GetFarByte
	inc hl
	cp "@"
	jr nz, .loop1
; skip height and weight
rept 4
	inc hl
endr
; if c != 1: skip entry
	dec c
	jr z, .done
; skip entry
.loop2
	ld a, b
	call GetFarByte
	inc hl
	cp "@"
	jr nz, .loop2

.done
	ld d, h
	ld e, l
	pop hl
	ret

DisplayDexMonType_CustomGFX:
	call GetBaseData
	ld a, [wBaseType1]

	ld c, a ; farcall will clobber a for the bank
	predef GetMonTypeIndex ; returns adjusted Type Index in 'c'
	ld a, c
; load the tiles
	ld hl, TypeLightIconGFX ; gfx\pokedex\types_light.png
	ld bc, 4 * LEN_2BPP_TILE ; Type GFX are 4 Tiles wide
	call AddNTimes ; increments the TypeLightIconGFX pointer to the right address of the needed Type Tiles
	ld d, h
	ld e, l

	ld a, $1
	ldh [rVBK], a
	ld hl, vTiles2 tile $77
	lb bc, BANK(TypeLightIconGFX), 4
	call Request2bpp
; place type 1 gfx
	hlcoord 9, 4
	ld [hl], $77
	inc hl
	ld [hl], $78
	inc hl
	ld [hl], $79
	inc hl
	ld [hl], $7a

	ld a, $0
	ldh [rVBK], a

; 2nd Type
	ld a, [wBaseType1]
	ld b, a
	ld a, [wBaseType2]
	cp b
	ret z ; mon doesn't have two types

	ld c, a ; farcall will clobber a for the bank
	predef GetMonTypeIndex ; returns adjusted Type Index in 'c'
	ld a, c
; load type 2 tiles
	ld hl, TypeDarkIconGFX ; gfx\pokedex\types_dark.png
	ld bc, 4 * LEN_2BPP_TILE ; Type GFX are 4 Tiles wide
	call AddNTimes ; increments the TypeDarkIconGFX pointer to the right address of the needed Type Tiles
	ld d, h
	ld e, l

	ld a, $1
	ldh [rVBK], a

	ld hl, vTiles2 tile $7b
	lb bc, BANK(TypeDarkIconGFX), 4
	call Request2bpp
	hlcoord 13, 4
	ld [hl], $7b
	inc hl
	ld [hl], $7c
	inc hl
	ld [hl], $7d
	inc hl
	ld [hl], $7e
	ld a, $0
	ldh [rVBK], a
	ret

; DEX_NO_CUSTOM_GFX_PrintType_Short:
; ; Print type a at hl.
; 	; shouldnt need to double index
; 	push hl
; 	ld hl, .Types
; 	ld bc, 4 ; since each entry is 4 bytes
; 	call AddNTimes
; 	ld d, h
; 	ld e, l
; 	pop hl
; 	jp PlaceString

; .Types
; 	db "NRM@"
; 	db "FGT@"
; 	db "FLY@"
; 	db "PSN@"
; 	db "GRD@"
; 	db "RCK@"
; 	db "BUG@"
; 	db "GST@"
; 	db "STL@"
; 	db "FIR@"
; 	db "WTR@"
; 	db "GRS@"
; 	db "ELC@"
; 	db "PSY@"
; 	db "ICE@"
; 	db "DRG@"
; 	db "DRK@"

INCLUDE "data/pokemon/dex_entry_pointers.asm"
INCLUDE "engine/pokedex/pokedex_evolution_page.asm"
INCLUDE "engine/pokedex/pokedex_stats_page.asm"
INCLUDE "engine/pokedex/pokedex_pics_page.asm"
INCLUDE "engine/pokedex/pokedex_moves_page.asm"
INCLUDE "engine/pokedex/pokedex_area_page.asm"

Pokedex_Clearbox:
	lb bc, 7, SCREEN_WIDTH - 1
	hlcoord 1, 9
	call ClearBox
	ret

DexEntry_adjusthlcoord:
	; given: current printed lines in c
	push af
	push de
	ld a, 20
	; the num of moves already printed should still be in bc
	call SimpleMultiply ; uses c as the other number
	; result in a
	ld d, 0
	ld e, a
	add hl, de ; allows us to print on the proper row lol
	pop de
	pop af
	ret

DexEntry_IncPageNum:
	ld a, [wPokedexEntryPageNum]
	inc a
	ld [wPokedexEntryPageNum], a
	ret

Pokedex_PrintPageNum:
	push hl
; print A > indicator
	hlcoord 19, 5
	ld [hl], $60
	dec hl
	ld [hl], $6c
; ; vertical line, right side	
; 	hlcoord 19, 6
; 	ld [hl], $6e	
; print page num
	ld a, [wPokedexEntryPageNum]
	; a = page num, starting with 0 as page 1
	hlcoord 18, 7
	ld [hl], $61 ; p. vram1
	inc hl
	cp 10 ; if we are past nine pages
	jr c, .checkdone
	ld a, 9
.checkdone
	add $62 ; this is how we get the page num tile
	ld [hl], a ; #
	pop hl
	ld a, [wPokedexEntryPageNum]
	ret

DexEntry_NextCategory:
	ld [wPokedexEntryType], a
	xor a
	ld [wPokedexEntryPageNum], a
	ld [wPokedexStatus], a
	ret

Print_Category_text:
	; given: hl is bottom str ptr, de is top string ptr
	; they all go at 8,6 and 8,7, all strings are 12 chars
	push hl ; bottom str ptr
	hlcoord 9, 6
	; de is already loaded
	call PlaceString
	hlcoord 9, 7
	pop de ; bottom string ptr
	call PlaceString
	ret

UncaughtMon_Info_Erase_PageNum:
; overwrite the A button with plain line
; erase page num
	hlcoord 18, 5
	ld bc, 2
	ld a, $4e ; category box border
	call ByteFill
	hlcoord 18, 7
	ld bc, 2
	ld a, " " ; category box border
	call ByteFill	
	ret
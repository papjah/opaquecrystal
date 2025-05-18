INCLUDE "data/mon_menu.asm"

MonSubmenu:
	xor a
	ldh [hBGMapMode], a
	call GetMonSubmenuItems
	farcall FreezeMonIcons
	ld hl, .MenuHeader
	call LoadMenuHeader
	call .GetTopCoord
	call PopulateMonMenu

	ld a, 1
	ldh [hBGMapMode], a
	call MonMenuLoop
	ld [wMenuSelection], a

	call ExitMenu
	ret

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 6, 0, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1
	dw 0
	db 1 ; default option

.GetTopCoord:
; [wMenuBorderTopCoord] = 1 + [wMenuBorderBottomCoord] - 2 * ([wMonSubmenuCount] + 1)
	ld a, [wMonSubmenuCount]
	inc a
	add a
	ld b, a
	ld a, [wMenuBorderBottomCoord]
	sub b
	inc a
	ld [wMenuBorderTopCoord], a
	call MenuBox
	ret

MonMenuLoop:
.loop
	ld a, MENU_UNUSED_3 | MENU_BACKUP_TILES_2 ; flags
	ld [wMenuDataFlags], a
	ld a, [wMonSubmenuCount]
	ld [wMenuDataItems], a
	call InitVerticalMenuCursor
	ld hl, w2DMenuFlags1
	set 6, [hl]
	call StaticMenuJoypad
	ld de, SFX_READ_TEXT_2
	call PlaySFX
	ldh a, [hJoyPressed]
	bit A_BUTTON_F, a
	jr nz, .select
	bit B_BUTTON_F, a
	jr nz, .cancel
	jr .loop

.cancel
	ld a, MONMENUITEM_CANCEL
	ret

.select
	ld a, [wMenuCursorY]
	dec a
	ld c, a
	ld b, 0
	ld hl, wMonSubmenuItems
	add hl, bc
	ld a, [hl]
	ret

PopulateMonMenu:
	call MenuBoxCoord2Tile
	ld bc, 2 * SCREEN_WIDTH + 2
	add hl, bc
	ld de, wMonSubmenuItems
.loop
	ld a, [de]
	inc de
	cp -1
	ret z
	push de
	push hl
	call GetMonMenuString
	pop hl
	call PlaceString
	ld bc, 2 * SCREEN_WIDTH
	add hl, bc
	pop de
	jr .loop

GetMonMenuString:
	ld hl, MonMenuOptions + 1
	ld de, 4
	call IsInArray
	dec hl
	ld a, [hli]
	inc hl
	cp MONMENU_MENUOPTION
	jr z, .NotMove
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetMoveIDFromIndex
	ld [wNamedObjectIndex], a
	jp GetMoveName

.NotMove:
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ret

GetMonSubmenuItems:
	call ResetMonSubmenu
	ld a, [wCurPartySpecies]
	cp EGG
	jr z, .egg
	ld a, [wLinkMode]
	and a
	jr nz, .skip_moves
	call CanUseFlash
	call CanUseFly
	call CanUseDig
	call CanUseSweetScent
	call CanUseTeleport
	call CanUseSoftboiled
	call CanUseMilkDrink

.skip_moves
	ld a, MONMENUITEM_STATS
	call AddMonMenuItem
	ld a, MONMENUITEM_SWITCH
	call AddMonMenuItem
	ld a, MONMENUITEM_MOVE
	call AddMonMenuItem
	ld a, [wLinkMode]
	and a
	jr nz, .skip2
	push hl
	ld a, MON_ITEM
	call GetPartyParamLocation
	ld d, [hl]
	farcall ItemIsMail
	pop hl
	ld a, MONMENUITEM_MAIL
	jr c, .ok
	ld a, MONMENUITEM_ITEM

.ok
	call AddMonMenuItem

.skip2
	ld a, [wMonSubmenuCount]
	cp NUM_MONMENU_ITEMS
	jr z, .ok2
	ld a, MONMENUITEM_CANCEL
	call AddMonMenuItem

.ok2
	call TerminateMonSubmenu
	ret

.egg
	ld a, MONMENUITEM_STATS
	call AddMonMenuItem
	ld a, MONMENUITEM_SWITCH
	call AddMonMenuItem
	ld a, MONMENUITEM_CANCEL
	call AddMonMenuItem
	call TerminateMonSubmenu
	ret

IsFieldMove:
	call GetMoveIndexFromID
	ld b, h
	ld c, l
	ld hl, MonMenuOptions
.next
	ld a, [hli]
	cp -1
	ret z
	cp MONMENU_MENUOPTION
	ret z
	ld a, [hli]
	ld d, a
	ld a, [hli]
	cp c
	ld a, [hli]
	jr nz, .next
	cp b
	jr nz, .next
	ld a, d
	scf
	ret

ResetMonSubmenu:
	xor a
	ld [wMonSubmenuCount], a
	ld hl, wMonSubmenuItems
	ld bc, NUM_MONMENU_ITEMS + 1
	call ByteFill
	ret

TerminateMonSubmenu:
	ld a, [wMonSubmenuCount]
	ld e, a
	ld d, 0
	ld hl, wMonSubmenuItems
	add hl, de
	ld [hl], -1
	ret

AddMonMenuItem:
	push hl
	push de
	push af
	ld a, [wMonSubmenuCount]
	ld e, a
	inc a
	ld [wMonSubmenuCount], a
	ld d, 0
	ld hl, wMonSubmenuItems
	add hl, de
	pop af
	ld [hl], a
	pop de
	pop hl
	ret

BattleMonMenu:
	ld hl, .MenuHeader
	call CopyMenuHeader
	xor a
	ldh [hBGMapMode], a
	call MenuBox
	call UpdateSprites
	call PlaceVerticalMenuItems
	call WaitBGMap
	call CopyMenuData
	ld a, [wMenuDataFlags]
	bit 7, a
	jr z, .set_carry
	call InitVerticalMenuCursor
	ld hl, w2DMenuFlags1
	set 6, [hl]
	call StaticMenuJoypad
	ld de, SFX_READ_TEXT_2
	call PlaySFX
	ldh a, [hJoyPressed]
	bit B_BUTTON_F, a
	jr z, .clear_carry
	ret z

.set_carry
	scf
	ret

.clear_carry
	and a
	ret

.MenuHeader:
	db 0 ; flags
	menu_coords 11, 11, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR | STATICMENU_NO_TOP_SPACING ; flags
	db 3 ; items
	db "SWITCH@"
	db "STATS@"
	db "CANCEL@"

CanUseFlash:
; Step 1: Badge Check
	ld de, ENGINE_ZEPHYRBADGE
	ld b, CHECK_FLAG
	farcall EngineFlagAction
	ld a, c
	and a
	ret z ; .fail, dont have needed badge

; Step 2: Location Check
	farcall SpecialAerodactylChamber
	jr c, .valid_location ; can use flash
	ld a, [wTimeOfDayPalset]
	cp DARKNESS_PALSET
	ret nz ; .fail ; not a darkcave

.valid_location
; Step 3: Check if Mon knows Move
	ld hl, FLASH
	call GetMoveIDFromIndex
	call CheckMonKnowsMove
	and a
	jr z, .yes

; Step 4: Check for TM/HM in bag
	ld a, HM_FLASH
	ld [wCurItem], a
	ld hl, wNumItems
	call CheckItem
	ret nc ; hm isnt in bag

; Step 5: Check if Mon can learn move from TM/HM/Move Tutor
	ld hl, FLASH
	call GetMoveIDFromIndex
	call CheckMonCanLearn_TM_HM
	jr c, .yes

; Step 6: Check if Mon can learn move from LVL-UP
	ld hl, FLASH
	call GetMoveIDFromIndex
	call CheckLvlUpMoves
	ret c ; fail

.yes
	ld a, MONMENUITEM_FLASH
	call AddMonMenuItem
	ret

CanUseFly:
; Step 1: Badge Check
	ld de, ENGINE_STORMBADGE
	ld b, CHECK_FLAG
	farcall EngineFlagAction
	ld a, c
	and a
	ret z ; .fail, dont have needed badge

; Step 2: Location Check
	call GetMapEnvironment
	call CheckOutdoorMap
	ret nz ; not outdoors, cant fly

; Step 3: Check if Mon knows Move
	ld hl, FLY
	call GetMoveIDFromIndex
	call CheckMonKnowsMove
	and a
	jr z, .yes

; Step 4: Check if HM is in bag
	ld a, HM_FLY
	ld [wCurItem], a
	ld hl, wNumItems
	call CheckItem
	ret nc ; .fail, hm isnt in bag

; Step 5: Check if mon can learn move via HM/TM/Move Tutor
	ld hl, FLY
	call GetMoveIDFromIndex
	call CheckMonCanLearn_TM_HM
	jr c, .yes

; Step 6: Check if Mon can learn move via LVL-UP
	ld hl, FLY
	call GetMoveIDFromIndex
	call CheckLvlUpMoves
	ret c ; fail
.yes
	ld a, MONMENUITEM_FLY
	call AddMonMenuItem
	ret

CanUseSweetScent:
; Step 1: Location check
	farcall CanEncounterWildMon ; CanUseSweetScent instead for older versions of pokecrystal
	ret nc
	farcall GetMapEncounterRate
	ld a, b
	and a
	ret z

.valid_location
; Step 2: Check if mon knows Move 
	ld hl, SWEET_SCENT
	call GetMoveIDFromIndex
	call CheckMonKnowsMove
	and a
	jr z, .yes

; Step 3: Check if TM is in bag
	ld a, TM_SWEET_SCENT
	ld [wCurItem], a
	ld hl, wNumItems
	call CheckItem
	ret nc ; .fail, tm not in bag

; Step 4: Check if mon can learn Move via TM/HM/Move tutor
	ld hl, SWEET_SCENT
	call GetMoveIDFromIndex
	call CheckMonCanLearn_TM_HM
	jr c, .yes

; Step 5: Check if mon can learn move via LVL-UP
	ld hl, SWEET_SCENT
	call GetMoveIDFromIndex
	call CheckLvlUpMoves
	ret c ; fail
.yes
	ld a, MONMENUITEM_SWEETSCENT
	call AddMonMenuItem
	ret

CanUseDig:
; Step 1: Location Check
	call GetMapEnvironment
	cp CAVE
	jr z, .valid_location
	cp DUNGEON
	ret nz ; fail, not inside cave or dungeon

.valid_location
; Step 2: Check if Mon knows Move
	ld hl, DIG
	call GetMoveIDFromIndex
	call CheckMonKnowsMove
	and a
	jr z, .yes

; Step 3: Check if TM/HM is in bag
	ld a, TM_DIG
	ld [wCurItem], a
	ld hl, wNumItems
	call CheckItem
	ret nc ; .fail ; TM not in bag

; Step 4: Check if Mon can learn Dig via TM/HM/Move Tutor
	ld hl, DIG
	call GetMoveIDFromIndex
	call CheckMonCanLearn_TM_HM
	jr c, .yes

; Step 5: Check if Mon can learn move via LVL-UP
	ld hl, DIG
	call GetMoveIDFromIndex
	call CheckLvlUpMoves
	ret c ; fail
.yes
	ld a, MONMENUITEM_DIG
	call AddMonMenuItem
	ret

CanUseTeleport:
; Step 1: Location Check
	call GetMapEnvironment
	call CheckOutdoorMap
	ret nz ; .fail
	
; Step 2: Check if mon knows move
	ld hl, TELEPORT
	call GetMoveIDFromIndex
	call CheckMonKnowsMove
	and a
	jr z, .yes

; Step 3: Check if mon learns move via LVL-UP
	ld hl, TELEPORT
	call GetMoveIDFromIndex
	call CheckLvlUpMoves
	ret c ; fail
.yes
	ld a, MONMENUITEM_TELEPORT
	call AddMonMenuItem	
	ret

CanUseSoftboiled:
	ld hl, SOFTBOILED
	call GetMoveIDFromIndex
	call CheckMonKnowsMove
	and a
	ret nz
	ld a, MONMENUITEM_SOFTBOILED
	call AddMonMenuItem
	ret

CanUseMilkDrink:
	ld hl, MILK_DRINK
	call GetMoveIDFromIndex
	call CheckMonKnowsMove
	and a
	ret nz

	ld a, MONMENUITEM_MILKDRINK
	call AddMonMenuItem
	ret
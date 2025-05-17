; TypeNames indexes (see data/types/names.asm)
; also used in:
; - PokedexTypeSearchConversionTable (see data/types/search_types.asm)
; - PokedexTypeSearchStrings (see data/types/search_strings.asm)
; - TypeMatchups (see data/types/type_matchups.asm)
; - TypeBoostItems (see data/types/type_boost_items.asm)
	const_def
	const NORMAL
	const FIGHTING
	const FLYING
	const POISON
	const GROUND
	const ROCK
	const BUG
	const GHOST
	const STEEL
	const FIRE
	const WATER
	const GRASS
	const ELECTRIC
	const PSYCHIC_TYPE
	const ICE
	const DRAGON
	const DARK
	const FAIRY
	const UNKNOWN_TYPE
DEF TYPES_END EQU const_value

DEF NUM_TYPES EQU TYPES_END

DEF POKEDEX_TYPE_STRING_LENGTH EQU 9

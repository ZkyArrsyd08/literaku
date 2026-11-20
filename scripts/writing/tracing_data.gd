class_name TracingData
extends RefCounted

## Every alphabet form resolves to stroke data. Coordinates are normalized 0..1.
static func strokes(letter: String, letter_case: String) -> Array:
	var l := letter.to_upper()
	var map := _upper_map() if letter_case == "upper" else _lower_map()
	return map.get(l, [[[Vector2(0.25, 0.15), Vector2(0.75, 0.85)]]])


static func _upper_map() -> Dictionary:
	return {
		"A": [[Vector2(.2,.85),Vector2(.5,.12),Vector2(.8,.85)],[Vector2(.35,.58),Vector2(.65,.58)]], "B": [[Vector2(.25,.12),Vector2(.25,.88)],[Vector2(.25,.12),Vector2(.7,.2),Vector2(.25,.5)],[Vector2(.25,.5),Vector2(.72,.65),Vector2(.25,.88)]], "C": [[Vector2(.78,.2),Vector2(.55,.12),Vector2(.25,.3),Vector2(.2,.7),Vector2(.55,.88),Vector2(.78,.8)]],
		"D": [[Vector2(.25,.12),Vector2(.25,.88)],[Vector2(.25,.12),Vector2(.72,.3),Vector2(.72,.7),Vector2(.25,.88)]], "E": [[Vector2(.72,.12),Vector2(.25,.12),Vector2(.25,.88),Vector2(.72,.88)],[Vector2(.25,.5),Vector2(.62,.5)]], "F": [[Vector2(.25,.88),Vector2(.25,.12),Vector2(.75,.12)],[Vector2(.25,.5),Vector2(.62,.5)]],
		"G": [[Vector2(.78,.25),Vector2(.55,.12),Vector2(.22,.3),Vector2(.22,.72),Vector2(.55,.88),Vector2(.78,.7),Vector2(.52,.7)]], "H": [[Vector2(.25,.12),Vector2(.25,.88)],[Vector2(.75,.12),Vector2(.75,.88)],[Vector2(.25,.5),Vector2(.75,.5)]], "I": [[Vector2(.3,.12),Vector2(.7,.12)],[Vector2(.5,.12),Vector2(.5,.88)],[Vector2(.3,.88),Vector2(.7,.88)]],
		"J": [[Vector2(.72,.12),Vector2(.72,.72),Vector2(.55,.88),Vector2(.3,.82)]], "K": [[Vector2(.25,.12),Vector2(.25,.88)],[Vector2(.75,.12),Vector2(.25,.5),Vector2(.75,.88)]], "L": [[Vector2(.25,.12),Vector2(.25,.88),Vector2(.75,.88)]], "M": [[Vector2(.2,.88),Vector2(.2,.12),Vector2(.5,.52),Vector2(.8,.12),Vector2(.8,.88)]],
		"N": [[Vector2(.25,.88),Vector2(.25,.12),Vector2(.75,.88),Vector2(.75,.12)]], "O": [[Vector2(.5,.12),Vector2(.75,.28),Vector2(.75,.72),Vector2(.5,.88),Vector2(.25,.72),Vector2(.25,.28),Vector2(.5,.12)]], "P": [[Vector2(.25,.88),Vector2(.25,.12),Vector2(.72,.25),Vector2(.25,.52)]],
		"Q": [[Vector2(.5,.12),Vector2(.75,.28),Vector2(.75,.72),Vector2(.5,.88),Vector2(.25,.72),Vector2(.25,.28),Vector2(.5,.12)],[Vector2(.58,.65),Vector2(.8,.9)]], "R": [[Vector2(.25,.88),Vector2(.25,.12),Vector2(.7,.25),Vector2(.25,.5),Vector2(.75,.88)]], "S": [[Vector2(.75,.2),Vector2(.5,.12),Vector2(.25,.3),Vector2(.7,.65),Vector2(.5,.88),Vector2(.22,.78)]],
		"T": [[Vector2(.2,.12),Vector2(.8,.12)],[Vector2(.5,.12),Vector2(.5,.88)]], "U": [[Vector2(.25,.12),Vector2(.25,.72),Vector2(.5,.88),Vector2(.75,.72),Vector2(.75,.12)]], "V": [[Vector2(.2,.12),Vector2(.5,.88),Vector2(.8,.12)]], "W": [[Vector2(.15,.12),Vector2(.32,.88),Vector2(.5,.5),Vector2(.68,.88),Vector2(.85,.12)]],
		"X": [[Vector2(.22,.12),Vector2(.78,.88)],[Vector2(.78,.12),Vector2(.22,.88)]], "Y": [[Vector2(.2,.12),Vector2(.5,.5),Vector2(.8,.12)],[Vector2(.5,.5),Vector2(.5,.88)]], "Z": [[Vector2(.2,.12),Vector2(.8,.12),Vector2(.2,.88),Vector2(.8,.88)]] }


static func _lower_map() -> Dictionary:
	var map := _upper_map().duplicate(true)
	# Simplified child-friendly lowercase forms; separate configurations exist for all 26 letters.
	map["A"] = [[Vector2(.3,.55),Vector2(.5,.35),Vector2(.7,.55),Vector2(.7,.85),Vector2(.3,.85),Vector2(.3,.55)]]
	map["B"] = [[Vector2(.3,.12),Vector2(.3,.88)],[Vector2(.3,.5),Vector2(.65,.55),Vector2(.65,.82),Vector2(.3,.88)]]
	map["D"] = [[Vector2(.7,.12),Vector2(.7,.88)],[Vector2(.7,.55),Vector2(.35,.55),Vector2(.25,.7),Vector2(.35,.88),Vector2(.7,.88)]]
	map["G"] = [[Vector2(.7,.55),Vector2(.35,.55),Vector2(.25,.7),Vector2(.35,.88),Vector2(.7,.88),Vector2(.7,.5),Vector2(.55,.38)]]
	map["H"] = [[Vector2(.3,.12),Vector2(.3,.88)],[Vector2(.3,.55),Vector2(.65,.55),Vector2(.65,.88)]]
	map["I"] = [[Vector2(.5,.55),Vector2(.5,.88)],[Vector2(.5,.3),Vector2(.5,.3)]]
	map["J"] = [[Vector2(.6,.55),Vector2(.6,.85),Vector2(.42,.92),Vector2(.28,.82)],[Vector2(.6,.3),Vector2(.6,.3)]]
	map["K"] = [[Vector2(.3,.12),Vector2(.3,.88)],[Vector2(.7,.55),Vector2(.3,.72),Vector2(.68,.88)]]
	map["L"] = [[Vector2(.45,.12),Vector2(.45,.82),Vector2(.65,.88)]]
	map["T"] = [[Vector2(.5,.25),Vector2(.5,.88)],[Vector2(.3,.55),Vector2(.7,.55)]]
	map["Y"] = [[Vector2(.7,.55),Vector2(.5,.7),Vector2(.3,.55)],[Vector2(.5,.7),Vector2(.5,.98)]]
	return map



## Jalur goresan yang mengikuti aset garis putus-putus di
## res://assets/ui/alphabet/dashed/ (hanya untuk huruf kapital).
## Koordinat dinormalisasi terhadap gambar PNG masing-masing (0..1).
static func asset_strokes(letter: String) -> Array:
	return _asset_map().get(letter.to_upper(), [])


static func _asset_map() -> Dictionary:
	return {
		"A": [[Vector2(.49,.14),Vector2(.09,.93)],[Vector2(.5,.14),Vector2(.94,.92)],[Vector2(.24,.58),Vector2(.79,.58)]],
		"B": [[Vector2(.2,.17),Vector2(.2,.91)],[Vector2(.2,.17),Vector2(.4,.17),Vector2(.56,.18),Vector2(.68,.25),Vector2(.7,.35),Vector2(.67,.45),Vector2(.6,.52),Vector2(.45,.53),Vector2(.2,.53)],[Vector2(.66,.54),Vector2(.79,.57),Vector2(.86,.68),Vector2(.8,.8),Vector2(.66,.88),Vector2(.48,.9),Vector2(.21,.91)]],
		"C": [[Vector2(.25,.25),Vector2(.38,.185),Vector2(.55,.17),Vector2(.69,.2),Vector2(.8,.27),Vector2(.87,.36)],[Vector2(.84,.74),Vector2(.71,.82),Vector2(.59,.85),Vector2(.46,.857),Vector2(.34,.83),Vector2(.25,.78),Vector2(.2,.71),Vector2(.16,.64),Vector2(.145,.53),Vector2(.15,.43),Vector2(.19,.35),Vector2(.25,.25)]],
		"D": [[Vector2(.2,.19),Vector2(.2,.9)],[Vector2(.28,.17),Vector2(.5,.19),Vector2(.64,.25),Vector2(.79,.39),Vector2(.83,.52),Vector2(.79,.67),Vector2(.64,.81),Vector2(.46,.87),Vector2(.27,.89),Vector2(.2,.89)]],
		"E": [[Vector2(.26,.19),Vector2(.26,.88)],[Vector2(.28,.19),Vector2(.86,.2)],[Vector2(.27,.52),Vector2(.65,.53)],[Vector2(.27,.88),Vector2(.63,.88)]],
		"F": [[Vector2(.22,.19),Vector2(.22,.9)],[Vector2(.25,.19),Vector2(.86,.2)],[Vector2(.24,.53),Vector2(.71,.54)]],
		"G": [[Vector2(.28,.32),Vector2(.35,.24),Vector2(.435,.2),Vector2(.52,.18),Vector2(.64,.18),Vector2(.71,.2),Vector2(.8,.29)],[Vector2(.5,.56),Vector2(.64,.56),Vector2(.81,.57),Vector2(.84,.69),Vector2(.82,.75),Vector2(.76,.82),Vector2(.675,.87),Vector2(.58,.89),Vector2(.456,.88),Vector2(.35,.84),Vector2(.27,.78),Vector2(.215,.71),Vector2(.18,.65),Vector2(.16,.56),Vector2(.17,.47),Vector2(.215,.38),Vector2(.28,.32)]],
		"H": [[Vector2(.16,.22),Vector2(.16,.92)],[Vector2(.77,.22),Vector2(.77,.92)],[Vector2(.18,.51),Vector2(.77,.51)]],
		"I": [[Vector2(.49,.2),Vector2(.49,.88)]],
		"J": [[Vector2(.456,.154),Vector2(.686,.154)],[Vector2(.686,.17),Vector2(.686,.62),Vector2(.655,.73),Vector2(.58,.78),Vector2(.477,.81),Vector2(.372,.805),Vector2(.3,.78)]],
		"K": [[Vector2(.183,.19),Vector2(.183,.88)],[Vector2(.83,.067),Vector2(.63,.2),Vector2(.47,.3),Vector2(.34,.386),Vector2(.25,.45),Vector2(.2,.5)],[Vector2(.277,.456),Vector2(.385,.553),Vector2(.52,.664),Vector2(.653,.776),Vector2(.77,.86)]],
		"L": [[Vector2(.213,.19),Vector2(.213,.855)],[Vector2(.213,.857),Vector2(.715,.857)]],
		"M": [[Vector2(.182,.22),Vector2(.182,.85)],[Vector2(.24,.21),Vector2(.49,.62),Vector2(.74,.21)],[Vector2(.8,.22),Vector2(.8,.85)]],
		"N": [[Vector2(.203,.22),Vector2(.205,.89)],[Vector2(.21,.23),Vector2(.4,.4),Vector2(.558,.577),Vector2(.71,.756),Vector2(.81,.835)],[Vector2(.823,.22),Vector2(.823,.835)]],
		"O": [[Vector2(.28,.21),Vector2(.363,.165),Vector2(.52,.14),Vector2(.666,.152),Vector2(.775,.2),Vector2(.87,.275),Vector2(.92,.38),Vector2(.927,.486),Vector2(.908,.59),Vector2(.86,.677),Vector2(.775,.744),Vector2(.666,.787),Vector2(.6,.8)],[Vector2(.6,.8),Vector2(.533,.808),Vector2(.41,.8),Vector2(.3,.75),Vector2(.205,.687),Vector2(.12,.613),Vector2(.073,.518),Vector2(.085,.433),Vector2(.12,.36),Vector2(.205,.275),Vector2(.28,.21)]],
		"P": [[Vector2(.197,.22),Vector2(.197,.925)],[Vector2(.28,.19),Vector2(.405,.185),Vector2(.557,.205),Vector2(.684,.248),Vector2(.76,.333),Vector2(.772,.417),Vector2(.747,.5),Vector2(.696,.566),Vector2(.582,.608),Vector2(.43,.63),Vector2(.2,.636)]],
		"Q": [[Vector2(.22,.274),Vector2(.33,.21),Vector2(.41,.177),Vector2(.515,.16),Vector2(.62,.177),Vector2(.71,.233),Vector2(.787,.315),Vector2(.83,.41),Vector2(.845,.51),Vector2(.83,.604),Vector2(.8,.687),Vector2(.745,.75),Vector2(.66,.81)],[Vector2(.6,.83),Vector2(.495,.85),Vector2(.39,.847),Vector2(.307,.83),Vector2(.244,.8),Vector2(.17,.728),Vector2(.13,.625),Vector2(.108,.5),Vector2(.14,.4),Vector2(.17,.336),Vector2(.22,.274)],[Vector2(.58,.64),Vector2(.68,.77),Vector2(.78,.86),Vector2(.86,.92)]],
		"R": [[Vector2(.212,.21),Vector2(.212,.84)],[Vector2(.285,.157),Vector2(.42,.157),Vector2(.56,.167),Vector2(.7,.21),Vector2(.753,.289),Vector2(.765,.367),Vector2(.73,.456),Vector2(.65,.51),Vector2(.54,.54),Vector2(.4,.548),Vector2(.217,.548)],[Vector2(.45,.56),Vector2(.56,.652),Vector2(.674,.74),Vector2(.81,.85),Vector2(.88,.915)]],
		"S": [[Vector2(.16,.28),Vector2(.29,.2),Vector2(.49,.18),Vector2(.7,.205),Vector2(.79,.28)],[Vector2(.14,.34),Vector2(.14,.38),Vector2(.17,.42),Vector2(.29,.46),Vector2(.49,.51),Vector2(.675,.56),Vector2(.78,.63),Vector2(.8,.69),Vector2(.755,.78),Vector2(.63,.83),Vector2(.49,.84),Vector2(.33,.83),Vector2(.17,.79),Vector2(.13,.74)]],
		"T": [[Vector2(.28,.16),Vector2(.72,.16)],[Vector2(.5,.22),Vector2(.5,.88)]],
		"U": [[Vector2(.235,.19),Vector2(.237,.62),Vector2(.265,.76),Vector2(.315,.83),Vector2(.413,.868),Vector2(.5,.883)],[Vector2(.772,.19),Vector2(.772,.62),Vector2(.75,.76),Vector2(.707,.82),Vector2(.61,.868),Vector2(.5,.883)]],
		"V": [[Vector2(.16,.26),Vector2(.49,.85)],[Vector2(.8,.25),Vector2(.5,.85)]],
		"W": [[Vector2(.1,.19),Vector2(.3,.78),Vector2(.45,.19)],[Vector2(.48,.19),Vector2(.7,.78)],[Vector2(.92,.19),Vector2(.7,.78)]],
		"X": [[Vector2(.12,.12),Vector2(.88,.88)],[Vector2(.88,.12),Vector2(.12,.88)]],
		"Y": [[Vector2(.123,.208),Vector2(.478,.571)],[Vector2(.825,.208),Vector2(.52,.55)],[Vector2(.49,.57),Vector2(.49,.76)]],
		"Z": [[Vector2(.27,.164),Vector2(.68,.164)],[Vector2(.71,.21),Vector2(.16,.77)],[Vector2(.16,.805),Vector2(.71,.805)]]
	}

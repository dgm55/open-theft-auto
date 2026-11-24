class_name PropertyCatalog
## Safehouses sold by the Free Harbor realtor.
##
## Each property is a real house standing in the world (world.gd builds one at
## every entry). Buying the deed lets the player set it as their home — the
## point they respawn at after dying. `x`/`z` is the front-yard respawn spot;
## the house itself is built just behind it.

const LIST: Array = [
	{"name": "Manoel Honório House", "price": 300_000, "x": -250.0, "z": 340.0},
	{"name": "Bairu Home", "price": 1_500_000, "x": 250.0, "z": -340.0},
	{"name": "Mariano Procópio Villa", "price": 6_000_000, "x": -250.0, "z": -340.0},
	{"name": "Centro Estate", "price": 25_000_000, "x": 250.0, "z": 340.0},
]

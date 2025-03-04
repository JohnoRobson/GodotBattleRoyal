class_name AmmoType extends Resource

@export_range(0, 500, 1) var ammo_in_full_magazine: int
@export var ammo_category: AmmoCategory

enum AmmoCategory {
    NONE,
    SMG,
    SHOTGUN,
    SNIPER,
    COOL
}
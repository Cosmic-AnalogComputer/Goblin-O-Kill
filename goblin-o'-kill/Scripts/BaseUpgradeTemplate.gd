class_name Upgrade
extends Resource

@export_category("Item")
@export var texture : AtlasTexture
@export var name : StringName = ""
@export_multiline var description : String = ""
@export var price : int = 10
@export_category("Bonuses")
@export_subgroup("Health")
@export var max_health : int
@export var health : int
@export_subgroup("Combat")
@export var damage : int
@export var knockback : float
@export var crit_chance : float
@export var crit_mod : float
@export var attack_speed : float
@export_subgroup("Visual")
@export var hasVisualEffect : bool
@export var particle : PackedScene

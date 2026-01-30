class_name Upgrade
extends Resource

@export_category("Item")
@export var texture : AtlasTexture
@export var name : StringName = ""
@export_multiline var description : String = ""
@export var price : int = 10
@export_subgroup("Visual")
@export var has_outline : bool
@export var shader_color : Color
@export_range(0.01,1.0, 0.1, "or_greater") var shader_thickness := 1.0
@export var item_particles : ParticleProcessMaterial
@export var particle_amount : int
@export_category("Bonuses")
@export_group("Numerical")
@export_subgroup("Stats")
@export var max_health : int
@export var health : int
@export var gold_gain : float ## x100
@export_subgroup("Combat")
@export var damage : int
@export var crit_chance : float
@export var crit_mod : float
@export var attack_speed : float
@export_group("Percentages")
@export var p_max_health : float
@export var p_health : float
@export var p_damage : float
@export var p_crit_mod : float
@export var p_attack_speed : float
@export_category("Custom")
@export var instantiate_custom_upgrade := false
@export var custom_upgrade : GDScript

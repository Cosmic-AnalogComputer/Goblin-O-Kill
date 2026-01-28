class_name waveEvent
extends Resource

@export_group("Display")
@export var name : String
@export_group("Wave")
@export var appearOnce : bool = true ## If false, will happen at every wave that can be divided by the wave
@export var DoubleEachInstance : bool = false
@export var wave : int
@export_group("Goblins")
@export var goblins : Dictionary[PackedScene, int]

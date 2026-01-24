extends StaticBody2D

@export var Dialogues : Array[String] = ["Buy me some items, ya?"]
var current_dialogue := ""
var text_anim := 12

func _process(delta: float) -> void:
	if text_anim < 12 + current_dialogue.length():
		text_anim += 1
	$PanelContainer/MarginContainer/Dialogue.visible_characters = text_anim

func dialogue():
	text_anim = 12
	$DialogueTimer.start()
	$PanelContainer.show()
	$ColorRect.show()
	var dupe = Dialogues.duplicate(true)
	if current_dialogue in dupe:
		dupe.erase(current_dialogue)
	current_dialogue = dupe.pick_random()
	$PanelContainer/MarginContainer/Dialogue.text = "[color=green]Shopkeeper:[/color] " + current_dialogue

func _on_dialogue_timer_timeout() -> void:
	$PanelContainer.hide()
	$ColorRect.hide()

func _on_interaction_component_interacted(_user: Player) -> void:
	dialogue()

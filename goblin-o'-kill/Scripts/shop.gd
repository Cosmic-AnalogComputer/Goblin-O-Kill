extends StaticBody2D

@export var Dialogues : Array[String] = ["Buy me some items, ya?"]
var current_dialogue : int = 1

func dialogue():
	$DialogueTimer.start()
	$PanelContainer.show()
	$ColorRect.show()
	var dupe = Dialogues.duplicate(true)
	dupe.erase(dupe[current_dialogue])
	current_dialogue = randi_range(0,dupe.size() - 1)
	$PanelContainer/MarginContainer/Dialogue.text = "[color=green]Shopkeeper:[/color] " + dupe[current_dialogue]

func _on_dialogue_timer_timeout() -> void:
	$PanelContainer.hide()
	$ColorRect.hide()

func _on_interaction_component_interacted(user: Player) -> void:
	dialogue()

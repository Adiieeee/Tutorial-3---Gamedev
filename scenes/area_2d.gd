extends Area2D

@onready var victory_ui = $"../VictoryUI"

func _on_body_entered(body):
	if body.name == "Player":
		print("VICTORY!")
		victory_ui.show()
		get_tree().paused = true

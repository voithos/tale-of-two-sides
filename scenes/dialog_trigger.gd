extends Node2D


export(String) var dialog = "intro"

var started = false;
onready var player = $"../player"

func create_dialog():
	started = true;
	var new_dialog = Dialogic.start(dialog)
	new_dialog.connect("timeline_end", self, "_dialog_end")
	player.enter_cutscene();
	get_parent().add_child(new_dialog)

func _dialog_end(signal_type):
	player.exit_cutscene();

func _on_Area2D_body_entered(body):
	if !started && body.name == "player":
		create_dialog();

extends Node2D


export(String) var dialog = "intro"

onready var player = $"../player"

func _ready():
    pass;

func _on_Area2D_body_entered(body):
    if body.is_in_group("player"):
        body.queue_dialog(dialog);

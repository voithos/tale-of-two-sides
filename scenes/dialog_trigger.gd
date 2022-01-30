extends Node2D


export(String) var dialog = "intro"

export(bool) var require_box = true;

onready var player = $"../player"

func _ready():
    pass;

func _on_Area2D_body_entered(body):
    if body.is_in_group("player"):
        body.queue_dialog(dialog);


func _on_Area2D_body_exited(body):
     if body.is_in_group("player") && require_box:
        body.dequeue_dialog();

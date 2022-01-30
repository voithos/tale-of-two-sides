class_name Crystal
extends Node2D


func _on_Area2D_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        print("Player touched crystal")
        body.on_touched_crystal(self)

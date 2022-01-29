class_name Crystal
extends RigidBody2D


func _on_Crystal_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        print("Player touched crystal")
        body.on_touched_crystal(self)

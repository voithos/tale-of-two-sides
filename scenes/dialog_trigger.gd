extends Node2D


export(String) var dialog = "intro"
export(Vector2) var box_size = Vector2(10,10)

onready var player = $"../player"

func _ready():
    $Area2D/CollisionShape2D.get_shape().set_extents(box_size);

func _on_Area2D_body_entered(body):
    var spoken = npc_store.has_spoken_with_npc(dialog)
    if !spoken && body.is_in_group("player"):
        body.queue_dialog(dialog);
        npc_store.record_npc_interaction(dialog)

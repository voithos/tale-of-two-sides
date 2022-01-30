extends Node

# Store for storing NPC interactions. Each level can have multiple NPCs.

# Note, level names must be unique!
var level_npcs = {}

func _ready():
    add_to_group("persistable")

func has_spoken_with_npc(npc_id) -> bool:
    return _get_level_npcs().has(npc_id)

# Record that we've spoken with an NPC.
func record_npc_interaction(npc_id):
    var npcs = _get_level_npcs()
    if !npcs.has(npc_id):
        npcs.append(npc_id)
        # Persist the data.
        saving.save_game()

func _level_name():
    return get_tree().get_current_scene().get_name()

func _get_level_npcs():
    var level = _level_name()
    if !level_npcs.has(level):
        level_npcs[level] = []
    return level_npcs[level]

func save_state():
    return level_npcs

func load_state(save_data):
    level_npcs = save_data

extends Plugin

const recapture_scene := preload("res://plugins/recapture/core/recapture_menu.tscn")
const icon := preload("res://plugins/recapture/assets/record-rec.svg")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	logger = Log.get_logger("Recapture", Log.LEVEL.DEBUG)
	logger.info("Recapture plugin loaded")
	var recapture_menu := recapture_scene.instantiate()
	add_to_qam.call_deferred(recapture_menu, icon, recapture_menu.focus_node)

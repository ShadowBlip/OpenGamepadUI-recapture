extends Control

const NotificationManager := preload("res://core/global/notification_manager.tres")
const icon := preload("res://plugins/recapture/assets/record-rec.svg")

@onready var rec_button := $%RecButton
@onready var focus_node := $%RecButton
@onready var timer := $Timer

var plugins_dir := ProjectSettings.globalize_path(PluginLoader.PLUGINS_DIR)
var deps_dir := "/".join([plugins_dir, "recapture", "plugins", "recapture", "assets", "deps"])
var recapture_bin := "/".join([deps_dir, "recapture"])
var gst_plugin_path := "/".join([deps_dir, "plugins"])
var ld_library_path := "/".join([deps_dir, "lib"])

var pid := -1
var recording := false
var logger := Log.get_logger("Recapture")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rec_button.pressed.connect(_on_button_pressed)
	timer.timeout.connect(_check_recording)


func _on_button_pressed() -> void:
	if recording:
		_stop_recording()
		return
	_start_recording()


func _start_recording() -> void:
	# Build the command to run
	var cmd := "env"
	var args := PackedStringArray()
	var env_vars := ["GST_VAAPI_ALL_DRIVERS=1", "GST_PLUGIN_PATH="+gst_plugin_path, "LD_LIBRARY_PATH="+ld_library_path]
	args.append_array(env_vars)
	args.append(recapture_bin)
	args.append("record")
	OS.execute("chmod", ["+x", recapture_bin])
	logger.info("Starting capture command: " + cmd + " " + str(args))
	pid = OS.create_process(cmd, args)
	if pid < 1:
		var notify := Notification.new("Unable to start capture")
		notify.icon = icon
		NotificationManager.show(notify)
		return
	logger.info("Started capture with pid: " + str(pid))
	
	# Update the button text
	rec_button.text = "Stop recording"
	recording = true
	timer.start()
	
	
func _stop_recording() -> void:
	timer.stop()
	# Update the button text
	rec_button.text = "Start recording"
	recording = false
	if pid > 0:
		logger.info("Stopping capture with: kill -SIGINT " + str(pid))
		OS.execute("bash", ["-c", "kill -SIGINT " + str(pid)])


func _check_recording() -> void:
	if OS.is_process_running(pid):
		return
	logger.warn("Recording process is not running anymore")
	var notify := Notification.new("Recording has stopped")
	notify.icon = icon
	NotificationManager.show(notify)
	_stop_recording()

extends CanvasLayer

onready var parent_container: VSplitContainer = get_node("VSplitContainer")
onready var text_editor: LineEdit = get_node("VSplitContainer/LineEdit")
onready var output: TextEdit = get_node("VSplitContainer/TextEdit")

var commands = {
	"clear": funcref(self, "clear"),
	"test": funcref(self, "test")
}

func _ready():
	parent_container.visible = false
	self.pause_mode = PAUSE_MODE_PROCESS

	text_editor.connect("text_entered", self, "_on_command_enter")

func _process(delta):
	if Input.is_action_just_pressed("toggle_console"):
		toggle_visibility()

func _on_command_enter(text: String):
	self.clear()

	if text in commands:
		var cmd = commands[text].call_func()

func add_command(cmd: String, function: FuncRef):
	commands[cmd] = function
	
func toggle_visibility():
	parent_container.visible = not parent_container.visible

	if parent_container.visible:
		text_editor.grab_focus()
		get_tree().paused = true
	else:
		get_tree().paused = false
		self.clear()

func clear():
	text_editor.text = ""
	output.text = ""
	
func test():
	self.print("Testing!")

func print(text: String):
	output.text = output.text + "\n" + text
	

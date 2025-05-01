extends Node
signal update_score(amount)
signal _reset_score()

@export var mob_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var mob_speed: float = 10.0

var score: int = 0
var spawn_positions: Array
var screen_size: Vector2

@onready var pause_label = $PauseLabel
@onready var score_label = $CanvasLayer/Label
@onready var texture_rect = $TextureRect
@onready var trees = [$Tree1, $Tree2, $Tree3]
@onready var sloth = $Sloth
@onready var spawn_timer = $SpawnTimer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_screen()
	_init_spawn_positions()
	_setup_trees()
	_setup_sloth()
	_setup_spawn_timer()
	pause_label.hide()

func _setup_screen():
	screen_size = get_viewport().get_visible_rect().size
	texture_rect.size = Vector2(screen_size.x, screen_size.x)

func _init_spawn_positions():
	for i in range(1, 4):
		spawn_positions.append(screen_size.x / 4 * i - 25)
		spawn_positions.append(screen_size.x / 4 * i + 25)

func _setup_trees():
	for i in trees.size():
		trees[i].position = Vector2(screen_size.x / 4 * (i + 1), screen_size.y / 2)

func _setup_sloth():
	sloth.position.x = spawn_positions[0]

func _setup_spawn_timer():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_SpawnTimer_timeout)
	spawn_timer.start()

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	pause_label.visible = get_tree().paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if get_tree().paused else Input.MOUSE_MODE_HIDDEN)

func add_score(amount):
	score += amount
	update_score.emit(score)
	score_label.text = str(score)
	spawn_timer.wait_time = spawn_interval + score * 0.01

func reset_score():
	score = 0
	_reset_score.emit(score)
	score_label.text = str(score)

func _on_SpawnTimer_timeout():
	var mob = mob_scene.instantiate()
	add_child(mob)
	
	var pos_index = randi() % spawn_positions.size()
	mob.position = Vector2(spawn_positions[pos_index], screen_size.y)
	
	if mob.has_method("flip_sprite"):
		mob.flip_sprite(pos_index % 2 == 0)
	if mob.has_method("set_speed"):
		mob.set_speed(mob_speed)

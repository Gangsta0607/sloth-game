extends Area2D
signal hit
var current_tree = 0
var current_side = -1
var attacking = false
@onready var main_node = get_node("/root/Main")

func _ready():
	z_index = 10
	body_entered.connect(_on_body_entered)
	var spawn_pos_index = current_tree * 2 + (0 if current_side == -1 else 1)
		
func is_attacking():
	return attacking

func take_hit():
	if not attacking:
		hide()
		hit.emit()
		$CollisionShape2D.set_deferred("disabled", true)

func switch_tree(left):
	if left:
		if current_side == 1:
			current_side = -1
		elif current_side == -1 and current_tree > 0:
			current_tree -= 1
			current_side = 1
	else:
		if current_side == -1:
			current_side = 1
		elif current_side == 1 and current_tree < 2:
			current_tree += 1
			current_side = -1
	$AnimatedSprite2D.flip_h = current_side == 1
	var spawn_pos_index = current_tree * 2 + (0 if current_side == -1 else 1)
	position.x = main_node.spawn_positions[spawn_pos_index]
	$CollisionShape2D.position.x = current_side * 30

func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_just_pressed("right"):
		switch_tree(false)
	if Input.is_action_just_pressed("left"):
		switch_tree(true)
	if Input.is_action_pressed("down") or Input.is_action_pressed("attack"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	
	attacking = Input.is_action_pressed("attack")
	if velocity.length() > 0:
		velocity = velocity.normalized()
	
	position += velocity * delta * 400
	position.y = max(65, min(main_node.screen_size.y - 80, position.y))

func _on_body_entered(body):
	if body.is_in_group("bugs"):  # Проверяем, что это жук
		if attacking:
			body.queue_free() # Удаляем моба, если игрок атакует
			var main = get_node("/root/Main")
			main.add_score(1)
		else:
			take_hit() # Вызываем метод получения урона у игрока	
			var death_screen = preload("res://death_screen.tscn").instantiate()
			death_screen.score = main_node.score if not main_node == null else 0
			get_tree().root.add_child(death_screen)

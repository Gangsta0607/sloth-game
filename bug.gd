extends RigidBody2D

var speed: float = 50.0
var velocity: Vector2 = Vector2(0, -1)

func _ready():
	$AnimatedSprite2D.play("default")
	sleeping = false  # Запрещаем "засыпание"
	freeze = false

func get_difficulty_multiplier():
	var main_node = get_node("/root/Main")  # Или другой путь к вашему main.gd
	return 1.0 + log(main_node.score + 1) * 0.2

func _physics_process(delta):
	var movement = velocity * speed * delta
	move_and_collide(movement)

	if position.y < 0:
		queue_free()

func set_speed(new_speed: float):
	speed = new_speed

func flip_sprite(flip):
	$AnimatedSprite2D.flip_v = not flip

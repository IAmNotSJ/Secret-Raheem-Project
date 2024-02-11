class_name BulletBase extends Node2D

@export var hitbox:Area2D
@export var screenNotifier:VisibleOnScreenNotifier2D

@export var bullet_speed:int = 600
@export var damage:float = 1

enum {
	STANDARD,
	SWIRVE
}
var type = STANDARD

func _ready():
	hitbox.area_entered.connect(_on_area_2d_area_entered)
	screenNotifier.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)

func start(_position, _direction, _damage):
	position = _position
	rotation = _direction
	damage *= _damage


func _physics_process(delta):
	position.x += bullet_speed * cos(rotation) * delta
	position.y += bullet_speed * sin(rotation) * delta

func _on_area_2d_area_entered(_area):
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

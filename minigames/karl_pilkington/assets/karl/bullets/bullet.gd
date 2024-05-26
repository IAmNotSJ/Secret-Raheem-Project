class_name BulletBase extends Node2D

@export var usePhysics:bool = true
@export var freeOnHit:bool = true
@export var freeOnOutOfBounds:bool = true

@export var hitbox:Area2D
@export var screenNotifier:VisibleOnScreenNotifier2D

@export var bullet_speed:int = 600
@export var damage:float = 1

var velocity:Vector2 = Vector2.ZERO

enum {
	STANDARD,
	SWIRVE
}
var type = STANDARD

func _ready():
	hitbox.area_entered.connect(_on_area_2d_area_entered)
	if screenNotifier != null:
		screenNotifier.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)

func start(_position, _direction, _damage):
	position = _position
	rotation = _direction
	damage *= _damage
	
	velocity.x = bullet_speed * cos(rotation)
	velocity.y = bullet_speed * sin(rotation)


func _physics_process(delta):
	if usePhysics:
		position.x += velocity.x * delta
		position.y += velocity.y * delta

func _on_area_2d_area_entered(_area):
	if freeOnHit:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if freeOnOutOfBounds:
		queue_free()

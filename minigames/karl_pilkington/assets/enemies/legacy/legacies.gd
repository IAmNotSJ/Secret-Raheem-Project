extends Node2D

@export var song:AudioStream
@onready var sand = $Sand
@onready var wheel = $Wheel
@onready var block = $Block
@onready var flame = $Flame
@onready var scaleLol = $Scale
@onready var pipe = $Pipe
@onready var spark = $Spark
@onready var alloy = $Alloy
@onready var blade = $Blade
var target

var rng = RandomNumberGenerator.new()

signal died

@onready var members = [wheel, block, flame, sand, scaleLol, pipe, spark, alloy, blade]

var membersAlive = []
func _ready():
	for i in range(3):
		spawn_new_legacy()
	block.died.connect(on_legacy_died.bind(block))
	flame.died.connect(on_legacy_died.bind(flame))
	wheel.died.connect(on_legacy_died.bind(wheel))
	sand.died.connect(on_legacy_died.bind(sand))
	scaleLol.died.connect(on_legacy_died.bind(scaleLol))
	pipe.died.connect(on_legacy_died.bind(pipe))
	spark.died.connect(on_legacy_died.bind(spark))
	alloy.died.connect(on_legacy_died.bind(alloy))
	blade.died.connect(on_legacy_died.bind(blade))

func spawn_new_legacy():
	members.shuffle()
	members[0].target = target
	members[0].change_active()
	membersAlive.append(members[0])
	members.remove_at(0)

func on_legacy_died(member):
	if members != []:
		spawn_new_legacy()
	
	membersAlive.erase(member)
	print(membersAlive)
	if membersAlive == []:
		died.emit()
		queue_free()

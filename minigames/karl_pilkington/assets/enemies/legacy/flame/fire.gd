extends Node2D


const SPEED = 150

var daTarget
var curGap = 20
var curAngle
var yOffset

var targetPos

var cooldown = 5

var phase = 0

func initialize(target, gap, angle, offset):
	self.daTarget = target
	self.curGap = gap
	self.curAngle = angle
	self.yOffset = offset
func _process(delta):
	if phase == 0:
		if cooldown > 0:
			global_position.x = daTarget.global_position.x + curGap * cos(deg_to_rad(curAngle)) 
			global_position.y = daTarget.global_position.y + curGap * sin(deg_to_rad(curAngle))  + yOffset
			cooldown -= delta
		else:
			phase = 1
			targetPos = daTarget.global_position
	else:
		curGap -= delta * SPEED
		global_position.x = targetPos.x + curGap * cos(deg_to_rad(curAngle)) 
		global_position.y = targetPos.y + curGap * sin(deg_to_rad(curAngle))  + yOffset
		
		if curGap <= 0:
			queue_free()

func _on_area_2d_area_entered(area):
	area.owner.hit()
	queue_free()

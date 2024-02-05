extends EnemyAttack

var daTarget
var curGap = 20
var curAngle
var yOffset

var targetPos

var cooldown = 5

var phase = 0

func initialize(target, gap, angle, daOffset):
	self.daTarget = target
	self.curGap = gap
	self.curAngle = angle
	self.yOffset = daOffset
	
	global_position.x = daTarget.global_position.x + curGap * cos(deg_to_rad(curAngle)) 
	global_position.y = daTarget.global_position.y + curGap * sin(deg_to_rad(curAngle))  + yOffset
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
		curGap -= delta * speed
		global_position.x = targetPos.x + curGap * cos(deg_to_rad(curAngle)) 
		global_position.y = targetPos.y + curGap * sin(deg_to_rad(curAngle))  + yOffset
		
		if curGap <= 0:
			queue_free()
	super(delta)

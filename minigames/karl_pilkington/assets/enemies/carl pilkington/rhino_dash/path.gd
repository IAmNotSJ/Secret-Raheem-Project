extends ColorRect

var target

func start(_target):
	target = _target

func _process(_delta):
	var direction = target.global_position - global_position
	
	var angleTo = $Marker2D.transform.x.angle_to(direction)
	rotation = angleTo
	
	size.x = sqrt(pow(direction.x, 2) + pow(direction.y, 2))

extends OverworldCharacter

@onready var animationPlayer = $AnimationPlayer

func _ready():
	if global.unlocks["Cleft"] == true:
		animationPlayer.play('empty')

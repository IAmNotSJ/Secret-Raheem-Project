class_name BattleOpponent extends Sprite2D

enum Emotions {
	NEUTRAL,
	HAPPY,
	SAD,
	ANGRY,
	WUT,
	SMUG,
	CONFUSED,
	SHOCKED, 
	POUT
}

const card_sprite = preload("res://minigames/raheem_battle/opponents/card_back.png")

var cards_left:int = 8 : 
	set(value):
		cards_left = value
		make_cards()


@export var animation_player:AnimationPlayer
@export var card_container:HBoxContainer

func _ready():
	make_cards()

func change_emotion(emotion:String):
	if emotion != "nvm":
		animation_player.play(emotion)

func make_cards():
	if card_container != null:
		for child in card_container.get_children():
			child.queue_free()
		for i in range(cards_left):
			var texture_rect = TextureRect.new()
			texture_rect.texture = card_sprite
			texture_rect.z_index = 1
			card_container.add_child(texture_rect)

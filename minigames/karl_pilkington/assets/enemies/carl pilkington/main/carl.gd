extends EnemyBase

enum {
	IDLE,
	AVOID
}

const max_attack_timer = 15
var attack_Timer = max_attack_timer

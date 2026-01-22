class_name Attack
extends State

var delay = Timer.new()
var cd = Timer.new()
var direction : Vector2

func _ready() -> void:
	delay.connect("timeout",_on_delay_timeout)
	delay.one_shot = true
	add_child(delay)
	cd.connect("timeout",_on_cd_timeout)
	cd.one_shot = true
	add_child(cd)


func enter():
	direction = target.global_position - enemy.position
	attack()

func _get_anim(num : int) -> String:
	var rot = int(rad_to_deg(enemy.get_angle_to(target.position)) + 90)
	if enemy.hasSimetricAnimation:
		if rot in range(0,180):
			enemy.anim.flip_h = false
		else:
			enemy.anim.flip_h = true
	
	if num == 4:
		var arc = -45
		var arc_2 = 45
		for a in 4:
			if rot in range(arc,arc_2):
				return enemy.attack_anim[a]
			else:
				arc = arc_2
				arc_2 += 90
	
	return enemy.attack_anim[3]

func _on_delay_timeout() -> void:
	cd.start(enemy.cooldown)
	var attack = enemy.attackScene.instantiate()
	if enemy.meleeAttack:
		attack.position = direction.normalized() * enemy.range
	else:
		attack.position = enemy.position
	
	if enemy.goodAim:
		attack.look_at(target.global_position)
	else:
		attack.look_at(direction * 60)
	
	if attack is Punch:
		attack.set_collision_mask(2)
	attack.damage = enemy.damage * GlobalVariables.difficulty
	if attack is Punch:
		attack.play = "null"
	if enemy.attackIsChild:
		enemy.add_child(attack)
	else:
		get_parent().get_parent().add_child(attack)

func attack():
	enemy.anim.play(_get_anim(enemy.attack_anim.size()))
	delay.start(enemy.delay)

func _on_cd_timeout() -> void:
	direction = target.global_position - enemy.position
	if direction.length() > enemy.range:
		emit_signal("transitioned", self, "chase")
	else:
		attack()

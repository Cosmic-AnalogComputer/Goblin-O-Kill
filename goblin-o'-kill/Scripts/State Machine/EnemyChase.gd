class_name chase
extends State

var direction : Vector2

func physics_update(delta : float):
	if target:
		direction = target.global_position - enemy.position
		enemy.anim.play(_get_anim())
		
		if direction.length() > enemy.range:
			enemy.velocity = direction.normalized() * enemy.speed
		else:
			emit_signal("transitioned",self,"attack")


func _get_anim() -> String:
	var rot = int(rad_to_deg(enemy.get_angle_to(target.position)) + 90)
	
	if enemy.hasSimetricAnimation:
		if direction.x > 0.0:
			enemy.anim.flip_h = false
		else:
			enemy.anim.flip_h = true
	
	var arc = -45
	var arc_2 = 45
	for a in 4:
		if rot in range(arc,arc_2):
			return enemy.walk[a]
		else:
			arc = arc_2
			arc_2 += 90
	
	return enemy.walk[3]

func exit():
	enemy.velocity = Vector2.ZERO

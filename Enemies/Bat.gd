extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

# @todo Change to const after debug
export var ACCELERATION := 300
export var MAX_SPEED := 50
export var FRICTION := 200

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var state = CHASE

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $Sprite
onready var hurtbox = $Hurtbox

func _ready():
	var numFrames = sprite.frames.get_frame_count("fly")
	sprite.frame = randi() % numFrames + 1

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
		WANDER:
			pass
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				# or (player.global_position - global_position).normalized()
				var direction = position.direction_to(player.global_position)
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
			sprite.flip_h = velocity.x < 0

	velocity = move_and_slide(velocity)

	
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 100
	hurtbox.create_hit_effect()

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	enemyDeathEffect.position = position
	get_parent().add_child(enemyDeathEffect)

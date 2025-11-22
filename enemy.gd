extends RigidBody3D

signal killed

var health = 200
var initial_position: Vector3
var respawn_time = 5.0 # Time in seconds before respawning
var is_dead = false

@onready var respawn_timer = Timer.new()

func _ready():
	initial_position = global_transform.origin
	respawn_timer.wait_time = respawn_time
	respawn_timer.one_shot = true
	respawn_timer.connect("timeout", Callable(self, "_on_respawn_timer_timeout"))
	add_child(respawn_timer)

func _process(_delta):
	if health <= 0 and not is_dead:
		emit_signal("killed")
		is_dead = true
		get_node("CollisionShape3D").disabled = true
		hide()
		respawn_timer.start()

func _on_respawn_timer_timeout():
	global_transform.origin = initial_position
	health = 200
	is_dead = false
	get_node("CollisionShape3D").disabled = false
	show()

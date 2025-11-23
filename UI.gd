extends Control

@onready var bullets = [$Background/Bullet, $Background/Bullet2, $Background/Bullet3, $Background/Bullet4, $Background/Bullet5, $Background/Bullet6, $Background/Bullet7]
@onready var main = $"../main"
@onready var score_label = $ScoreLabel
@onready var health_bar = $HealthBar  # Assuming there's a HealthBar node in the scene
var score = 0
var player

func _ready():
	player = get_tree().get_first_node_in_group("player")  # Find the player node
	update_score_label()
	update_health_bar()

func increment_score():
	score += 1
	update_score_label()

func update_score_label():
	score_label.text = "Score: " + str(score)

func update_health_bar():
	if player:
		if health_bar:
			# Update the health bar's value (assuming it's a ProgressBar node)
			health_bar.value = player.health
			health_bar.max_value = player.MAX_HEALTH
			# Change color based on health
			if player.health <= 0:
				health_bar.modulate = Color.RED
			elif player.health <= player.MAX_HEALTH * 0.3:
				health_bar.modulate = Color.YELLOW
			else:
				health_bar.modulate = Color.GREEN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if main.ammo == 6:
		bullets[0].visible = false
	elif main.ammo == 5:
		bullets[1].visible = false
	elif main.ammo == 4:
		bullets[2].visible = false
	elif main.ammo == 3:
		bullets[3].visible = false
	elif main.ammo == 2:
		bullets[4].visible = false
	elif main.ammo == 1:
		bullets[5].visible = false
	elif main.ammo == 0:
		bullets[6].visible = false
	else:
		for bullet in bullets:
			bullet.visible = true

	# Update health bar continuously
	update_health_bar()

extends Node

const TORII_URL = "http://localhost:8080/graphql"
const PLAYER_ADDRESS = "0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec"  # Replace with actual player address

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var timer: Timer = $Timer
@onready var score_label: Label = get_node("../HUD/ScoreLabel")

func _ready():
	# Create HTTPRequest node if it doesn't exist
	if not has_node("HTTPRequest"):
		http_request = HTTPRequest.new()
		add_child(http_request)
	
	# Connect the request completed signal
	http_request.request_completed.connect(_on_request_completed)
	
	# Create Timer node if it doesn't exist
	if not has_node("Timer"):
		timer = Timer.new()
		add_child(timer)
	
	# Configure the timer to tick every 1 second
	timer.timeout.connect(_make_request)
	timer.wait_time = 1.0
	timer.start()
	
	# Make initial request
	_make_request()

func _make_request():
	var query = {
		"query": """query {
			playerModels(where: { address: \"%s\" }) {
				edges {
					node {
						health
						kills
						deaths
					}
				}
			}
		""" % [PLAYER_ADDRESS]
	}
	
	var headers = ["Content-Type: application/json"]
	
	var error = http_request.request(
		TORII_URL,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(query)
	)
	
	if error != OK:
		print("Error making request: ", error)

func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Request failed with result: ", result)
		score_label.text = "Health: Error"
		return

	var response_text = body.get_string_from_utf8()
	var json_result = JSON.parse_string(response_text)

	if json_result == null:
		print("Failed to parse JSON response: ", response_text)
		score_label.text = "Health: Parse Error"
		return

	if not json_result.has("data") or not json_result.data.has("playerModels"):
		print("Invalid response format: ", json_result)
		score_label.text = "Health: Format Error"
		return

	var player_models = json_result.data.playerModels
	if not player_models.has("edges") or player_models.edges.is_empty():
		# Handle case where player hasn't spawned yet
		score_label.text = "Health: 0"
		print("Player not found in indexer yet")
		return

	if not player_models.edges[0].has("node") or not player_models.edges[0].node.has("health"):
		print("Health field not found in response")
		score_label.text = "Health: Missing"
		return

	var health = player_models.edges[0].node.health
	var kills = player_models.edges[0].node.kills if player_models.edges[0].node.has("kills") else 0
	var deaths = player_models.edges[0].node.deaths if player_models.edges[0].node.has("deaths") else 0
	var verified = player_models.edges[0].node.verified if player_models.edges[0].node.has("verified") else true

	score_label.text = "Health: " + str(health) + " | Kills: " + str(kills) + " | Deaths: " + str(deaths)

	# Check if player is banned/unverified (caught cheating)
	if not verified and health == 0:
		score_label.text += "\nSTATUS: FROZEN - CHEATER DETECTED"
		# In your game logic, you would freeze the player's controls here
		# For example, you could disable input, freeze the player in place, etc.
		print("Player has been caught cheating and frozen!")

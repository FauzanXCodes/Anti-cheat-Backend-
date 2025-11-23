extends Node

# IMPORTANT: Use the IP address we found earlier to avoid "Error 44"
const RELAY_URL = "http://192.168.1.102:3000/shoot"

func send_shoot_action(angle: int, recoil: int):
	# Create a temporary HTTP request node
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	
	# Prepare the data
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"angle": angle,
		"recoil": recoil
	})
	
	print("🚀 Sending shot to Relay...")
	var error = http.request(RELAY_URL, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		print("❌ Connection Error: ", error)
		http.queue_free()

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		print("✅ Shot verified on Blockchain!")
	else:
		print("❌ Server Error: ", response_code)
	
	# Clean up
	var http = get_child(get_child_count() - 1)
	if http:
		http.queue_free()

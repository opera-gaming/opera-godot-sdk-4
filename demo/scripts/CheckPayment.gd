extends Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GxGames.payment_status_received.connect(on_payment_status_received)

func _on_button_up() -> void:
	GxGames.get_full_version_payment_status()

func on_payment_status_received(
	is_full_version_purchased: bool,
	ok: bool, 
	error_codes: Array
) -> void:
	print("has full version: " + str(is_full_version_purchased) + \
		"; OK: " + str(ok) + \
		"; error_codes: " + str(error_codes))

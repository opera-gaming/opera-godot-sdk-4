extends Button

func _ready() -> void:
	GxGames.payment_completed.connect(_on_payment_completed)

func _on_button_up() -> void:
	GxGames.trigger_payment("some ID")

func _on_payment_completed(id: String) -> void:
	print("Payment completed for: " + id)

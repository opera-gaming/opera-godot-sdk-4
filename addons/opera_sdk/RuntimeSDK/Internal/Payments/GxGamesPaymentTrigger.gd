extends RefCounted
class_name GxGamesPaymentTrigger

signal payment_completed(id: String)

var _window: JavaScriptObject

# JS callbacks references should be stored, see the docs.
var _js_callback_on_payment_completed: JavaScriptObject

func _init(window: JavaScriptObject):
	_window = window
	
	_js_callback_on_payment_completed = JavaScriptBridge.create_callback(_on_payment_completed)
	_window.onPaymentCompleted = _js_callback_on_payment_completed

func trigger_payment(id: String) -> void:
	if !_window:
		payment_completed.emit(id)
		return
	
	if !_window.triggerPayment:
		printerr('Function "window.triggerPayment" is not defined.')
		payment_completed.emit(id)
		return
	
	_window.triggerPayment(id)

func _on_payment_completed(args: Array) -> void:
	payment_completed.emit(args[0])

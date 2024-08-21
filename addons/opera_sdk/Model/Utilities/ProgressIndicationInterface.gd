extends RefCounted
class_name ProgressIndicationInterface

signal on_progress_began
signal on_progress_step(title: String, info: String, progressValue: float)
signal on_progress_ended

var is_cancelled: bool

func OnProgressBegin(title: String, info: String) -> void:
	is_cancelled = false
	on_progress_began.emit(title, info, 0)

func DisplayCancelableProgressBar(
	title: String, info: String, progressValue: float) -> bool:
	on_progress_step.emit(title, info, progressValue)
	return is_cancelled

func OnProgressEnd() -> void:
	is_cancelled = false
	on_progress_ended.emit()
	pass

func CancelProgress() -> void:
	is_cancelled = true;

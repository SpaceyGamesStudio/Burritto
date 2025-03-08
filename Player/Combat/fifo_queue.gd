extends Node
class_name FifoQueue

var queue: Array = []

# Dodaje na koniec kolejki
func enqueue(value):
	queue.append(value)  

# Sciaga element
func dequeue():
	if not queue.is_empty():
		return queue.pop_front()  # Pobiera i usuwa pierwszy element
	return null  # Jeśli kolejka pusta

func is_empty() -> bool:
	return queue.is_empty()

func size() -> int:
	return queue.size()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("TODO: Wyniesc Player.Combat.Queue") # TODO
	print("TODO: Pomyslec nad implementacja ArrayDeque [class_name Queue]")

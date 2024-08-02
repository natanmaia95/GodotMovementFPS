class_name InteractableComponent
extends Area3D

signal interacted(source:Node3D)

func interact(source:Node3D = null) -> void:
	interacted.emit(source)

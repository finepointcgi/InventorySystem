extends Resource
class_name Item

@export var ID : int
@export var Name : String
@export var ResourcePath : String
@export var Icon : Texture2D
@export var Quantity : int
@export var StackSize : int
@export var IsStackable : bool
@export var Weight : float

func UseItem():
	print("Used Item!")
	pass

extends Button
class_name InventoryButton

enum InventoryButtonStates{
	Inventory, 
	Craftable
}

var currentItem : Item
var currentIcon
var currentLabel
var index
signal OnButtonClick(Index, item, state)
@export var currentState : InventoryButtonStates

# Called when the node enters the scene tree for the first time.
func _ready():
	currentIcon = $TextureRect
	currentLabel = $Label
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func UpdateItem(item : Item, index : int, state : InventoryButtonStates):
	self.index = index
	currentItem = item
	
	if currentItem == null:
		$TextureRect.texture = null
		$Label.text = ""
		$NameOfItem.text = ""
	else:
		if item.Quantity <= 0:
			$TextureRect.texture = null
			$Label.text = ""
			$NameOfItem.text = ""
		else:
			$TextureRect.texture = item.Icon
			$Label.text = str(item.Quantity)
			$NameOfItem.text = item.Name
			
	self.currentState = state
	

func _on_area_2d_area_entered(area):
	pass # Replace with function body.


func _on_area_2d_area_exited(area):
	pass # Replace with function body.


func _on_button_down():
	emit_signal("OnButtonClick", index, currentItem, currentState)
	pass # Replace with function body.

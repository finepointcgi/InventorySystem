extends Control

@export var componentListElementScene : PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func SetupInventoryPopupMenu(currentItem:Item):
	$HeaderTitle.text = currentItem.Name
	$WeightValue.text = str(currentItem.Weight)
	
	for i in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(i)
	
	for item in currentItem.ItemCraftableMakeup:
		var componentElement = componentListElementScene.instantiate()
		$VBoxContainer.add_child(componentElement)
		componentElement.SetUpComponent(item.Name, currentItem.ItemCraftableMakeup[item])

extends Control

class_name Inventory

enum State{
	inventory, 
	invesigation
}

var gridContainer : GridContainer
var items : Array
var capacity := 20
var hoveredButton
var grabbedButton
var lastClickedMousePos : Vector2
var overTrash : bool
@export var CanSwapEmpty : bool
@export var MaxWeight := 0
@export var AllowOverWeight : bool
var IsOverWeight : bool
var currentWeight := 0
var currentState : State = State.inventory

@export var CraftingMenuScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	gridContainer = $InventoryMenu/ScrollContainer/GridContainer
	populateButtons()
	$InventoryMenu/WeightValue.text = str(currentWeight) + "/" + str(MaxWeight)
	if GameManager.Inventory == null:
		GameManager.Inventory = self
	else:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if currentState == State.inventory:
		$MouseArea.position = get_tree().root.get_mouse_position()
		if hoveredButton != null:
			if hoveredButton is InventoryButton:
				if hoveredButton.currentState != InventoryButton.InventoryButtonStates.Craftable:
					if CanSwapEmpty:
						CheckForDrag()
					else:
						if hoveredButton.get("currentItem"):
							if hoveredButton.currentItem != null:
								CheckForDrag()
				else:
					$MouseArea/InventoryPopupMenu.show()
					$MouseArea/InventoryPopupMenu.SetupInventoryPopupMenu(hoveredButton.currentItem)
		else:
			$MouseArea/InventoryPopupMenu.hide()
		if Input.is_action_just_released("Throw") && $MouseArea/InventoryButton.visible:
			$MouseArea/InventoryButton.hide()
			if overTrash:
				DeleteButton(grabbedButton)
			grabbedButton = null
	if Input.is_action_just_pressed("RightMouseDown"):
		if currentState == State.inventory:
			if hoveredButton != null:
				$InvestigationObject.ShowObject(hoveredButton.currentItem)
				$InventoryMenu.hide()
				currentState = State.invesigation
				pass
		elif(currentState == State.invesigation):
			$InventoryMenu.show()
			$InvestigationObject.HideObject()
			currentState = State.inventory

func CheckForDrag():
	if Input.is_action_just_pressed("Throw"):
		if(hoveredButton.currentState == InventoryButton.InventoryButtonStates.Craftable):
			return
		grabbedButton = hoveredButton
		lastClickedMousePos = get_tree().root.get_mouse_position()
	
	if lastClickedMousePos.distance_to(get_tree().root.get_mouse_position()) > 2:
		if Input.is_action_pressed("Throw"):
			if grabbedButton == null:
				grabbedButton = hoveredButton
			$MouseArea/InventoryButton.show()
			$MouseArea/InventoryButton.UpdateItem(grabbedButton.currentItem, 0, InventoryButton.InventoryButtonStates.Inventory)
		if Input.is_action_just_released("Throw"):
			if overTrash:
				DeleteButton(grabbedButton)
			else:
				if(grabbedButton != null && hoveredButton != null):
					SwapButtons(grabbedButton, hoveredButton)
				$MouseArea/InventoryButton.hide()
				pass

func DeleteButton(button):
	items.remove_at(items.find(button.currentItem))
	reflowButtons()

func populateButtons():
	for i in capacity:
		var packedScene = ResourceLoader.load("res://addons/FPCGI/InventorySystem/Scenes/InventoryButton.tscn")
		var itemButton : Button = packedScene.instantiate()
		itemButton.connect("OnButtonClick", OnButtonClicked)
		$InventoryMenu/ScrollContainer/GridContainer.add_child(itemButton)

func SwapButtons(button1, button2):
	
	var button1Index = button1.get_index()
	var button2Index = button2.get_index()
	gridContainer.move_child(button1, button2Index)
	gridContainer.move_child(button2, button1Index)

func Add(item : Item):
	if MaxWeight > 0 :
		if currentWeight >= MaxWeight && !AllowOverWeight:
			return 
	var currentItem = item.duplicate()
	for i in gridContainer.get_children():
		if i.currentItem != null:
			if i.currentItem.ID == item.ID:
				if i.currentItem.ID == currentItem.ID && i.currentItem.Quantity != i.currentItem.StackSize:
					if i.currentItem.Quantity + currentItem.Quantity > i.currentItem.StackSize:
						i.currentItem.Quantity = currentItem.StackSize
						currentItem.Quantity = -(currentItem.Quantity - i.currentItem.StackSize)
						UpdateButton(i.get_index(), i.currentItem)
					else:
						i.currentItem.Quantity += currentItem.Quantity
						currentItem.Quantity = 0
						UpdateButton(i.get_index(), i.currentItem)

	if currentItem.Quantity > 0:
		if currentItem.Quantity <= currentItem.StackSize:
			for i in gridContainer.get_children():
				if i.currentItem == null:
					items.append(currentItem)
					UpdateButton(i.get_index(), currentItem)
					break
		else:
			for i in gridContainer.get_children():
				if i.currentItem == null:
					var tempItem = currentItem.duplicate()
					tempItem.Quantity = currentItem.StackSize
					items.append(tempItem)
					UpdateButton(i.get_index(), i.currentItem)
					currentItem.Quantity -= currentItem.StackSize
					Add(currentItem)
					break
	reflowButtons()

func Remove(item : Item, quantity : int = 0) -> bool:
	if quantity == 0:
		quantity = item.Quantity
	
	if CanAfford(item):
		var currentItem = item
		for i in gridContainer.get_children():
			if i.currentItem != null:
				if i.currentItem.ID == currentItem.ID:
					if i.currentItem.Quantity - quantity < 0:
						quantity -= i.currentItem.Quantity
						i.currentItem.Quantity = 0
						UpdateButton(i.get_index(), i.currentItem)
					else:
						i.currentItem.Quantity -= quantity
						quantity = 0
						UpdateButton(i.get_index(), i.currentItem)
				
			if quantity <= 0:
				break
		var tempItems = items.duplicate()
		var offset = 0
		# removes buttons that have 0 quantity
		for i in tempItems.size():
			if items[i - offset].Quantity == 0:
				items.remove_at(i - offset)
				offset += 1
				
		reflowButtons()
		return true
	return false

func CanAfford(item : Item, quantity : int = 0) -> bool:
	var count : int
	if quantity == 0:
		quantity = item.Quantity
	for i in gridContainer.get_children():
		if i.currentItem != null:
			if i.currentItem.ID == item.ID:
				count += quantity
	return count >= quantity

func reflowButtons():
	currentWeight = 0
	for i in gridContainer.get_children():
		if i.currentItem == null:
			UpdateButton(i.get_index())
		else:
			if i.currentItem.Quantity > 0:
				UpdateButton(i.get_index(), i.currentItem)
				currentWeight += i.currentItem.Weight * i.currentItem.Quantity
			else:
				UpdateButton(i.get_index())
	$InventoryMenu/WeightValue.text = str(currentWeight) + "/" + str(MaxWeight)
	if(AllowOverWeight):
		IsOverWeight =  currentWeight > MaxWeight
	if IsOverWeight:
		$InventoryMenu/WeightValue.add_theme_color_override("font_color", Color(1,0,0))
	else:
		$InventoryMenu/WeightValue.add_theme_color_override("font_color", Color(1,1,1))
		
func UpdateButton(index : int, item : Item = null):
	if gridContainer.get_child(index) == null:
		print("Error: Child At Index " + str(index) + " Is null")
		return
	gridContainer.get_child(index).UpdateItem(item, index, InventoryButton.InventoryButtonStates.Inventory)

func OnButtonClicked(index, currentItem : Item, state):
	if currentItem != null:
		currentItem.UseItem()

func _on_button_button_down():
	Add(ResourceLoader.load("res://Coal.tres"))
	pass # Replace with function body.

func _on_button_2_button_down():
	print(Remove(ResourceLoader.load("res://Coal.tres")))
	pass # Replace with function body.

func _on_mouse_area_area_entered(area):
	hoveredButton = area.get_parent()
	pass # Replace with function body.

func _on_mouse_area_area_exited(area):
	hoveredButton = null
	pass # Replace with function body.


func _on_trash_area_area_entered(area):
	overTrash = true
	pass # Replace with function body.


func _on_trash_area_area_exited(area):
	overTrash = false
	pass # Replace with function body.


func _on_button_5_button_down():
	Remove(ResourceLoader.load("res://Iron.tres"))
	pass # Replace with function body.


func _on_button_4_button_down():
	Add(ResourceLoader.load("res://Iron.tres"))
	pass # Replace with function body.


func _on_open_craft_menu_button_down():
	var menu = CraftingMenuScene.instantiate()
	add_child(menu)
	pass # Replace with function body.

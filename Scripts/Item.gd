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
@export var SubItem : Item
@export var SubItemFound : bool
@export var DeleteItemAfterFound : bool
@export var AfterFoundBaseItem : Item
@export var ItemCraftableMakeup : Dictionary # item, required amount

func UseItem():
	print("Used Item!")
	pass

func CanCraftItem() -> bool:
	var countOfAffordedItems = 0
	for item in ItemCraftableMakeup:
		if GameManager.Inventory.CanAfford(item, ItemCraftableMakeup[item]):
			countOfAffordedItems += 1
			
	if countOfAffordedItems >= ItemCraftableMakeup.size():
		return true
	return false

func CraftItem():
	if CanCraftItem():
		for item in ItemCraftableMakeup:
			var success = GameManager.Inventory.Remove(item, ItemCraftableMakeup[item])
			if !success:
				print("failed to remove " + item.Name)
		GameManager.Inventory.Add(self)

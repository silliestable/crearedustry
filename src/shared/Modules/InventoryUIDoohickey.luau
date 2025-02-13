local InventorySystem = {}
InventorySystem.__index = InventorySystem

-- Configuration
local SLOT_SIZE = UDim2.new(0, 64, 0, 64)
local GRID_PADDING = UDim.new(0, 5)
local ITEMS_PER_ROW = 5

function InventorySystem.new(screenGui)
	local self = setmetatable({}, InventorySystem)

	self.inventory = {}
	self.screenGui = screenGui
	self.inventorySlots = {}
	self.inventoryFrame = nil
	self.gridLayout = nil

	self:InitializeInventoryUI()
	return self
end

function InventorySystem:InitializeInventoryUI()
	-- Create main inventory frame
	self.inventoryFrame = Instance.new("Frame")
	self.inventoryFrame.BackgroundTransparency = 1
	self.inventoryFrame.Size = UDim2.new(0, (SLOT_SIZE.X.Offset * ITEMS_PER_ROW) + (GRID_PADDING.Offset * (ITEMS_PER_ROW - 1)), 0, 200)
	self.inventoryFrame.Position = UDim2.new(0.5, 0, 0.95, 0)
	self.inventoryFrame.AnchorPoint = Vector2.new(0.5, 1)
	self.inventoryFrame.Parent = self.screenGui

	-- Create grid layout
	self.gridLayout = Instance.new("UIGridLayout")
	self.gridLayout.CellSize = SLOT_SIZE
	self.gridLayout.CellPadding = UDim2.new(GRID_PADDING, GRID_PADDING)
	self.gridLayout.FillDirection = Enum.FillDirection.Horizontal
	self.gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	self.gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self.gridLayout.Parent = self.inventoryFrame
end

function InventorySystem:CreateItemSlot(itemName, icon, count)
	local slot = Instance.new("Frame")
	slot.BackgroundTransparency = 1
	slot.Size = SLOT_SIZE
	slot.LayoutOrder = #self.inventorySlots + 1

	local itemIcon = Instance.new("ImageLabel")
	itemIcon.Name = "Icon"
	itemIcon.Image = icon
	itemIcon.Size = UDim2.new(1, 0, 1, 0)
	itemIcon.BackgroundTransparency = 1
	itemIcon.Parent = slot

	local countLabel = Instance.new("TextLabel")
	countLabel.Name = "Count"
	countLabel.Text = tostring(count)
	countLabel.Font = Enum.Font.SciFi
	countLabel.TextSize = 18
	countLabel.TextColor3 = Color3.new(1, 1, 1)
	countLabel.BackgroundTransparency = 1
	countLabel.Position = UDim2.new(0.7, 0, 0.7, 0)
	countLabel.Parent = slot

	return slot
end

function InventorySystem:UpdateItemCount(itemName, newCount)
	for _, slot in pairs(self.inventorySlots) do
		if slot:FindFirstChild("Icon") and slot.Icon.Image == self.inventory[itemName].icon then
			slot.Count.Text = tostring(newCount)
			break
		end
	end
end

function InventorySystem:AddItem(itemName, icon, amount)
	if self.inventory[itemName] then
		self.inventory[itemName].count += amount
		self:UpdateItemCount(itemName, self.inventory[itemName].count)
	else
		self.inventory[itemName] = {
			count = amount,
			icon = icon
		}

		local newSlot = self:CreateItemSlot(itemName, icon, amount)
		newSlot.Parent = self.inventoryFrame
		table.insert(self.inventorySlots, newSlot)
	end
end

function InventorySystem:RemoveItem(itemName, amount)
	if self.inventory[itemName] then
		self.inventory[itemName].count = math.max(0, self.inventory[itemName].count - amount)
		self:UpdateItemCount(itemName, self.inventory[itemName].count)

		if self.inventory[itemName].count <= 0 then
			self.inventory[itemName] = nil
			-- Remove slot from UI
			for i, slot in pairs(self.inventorySlots) do
				if slot.Icon.Image == self.inventory[itemName].icon then
					slot:Destroy()
					table.remove(self.inventorySlots, i)
					break
				end
			end
		end
	end
end

return InventorySystem
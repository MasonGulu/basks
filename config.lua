local basalt = require("basalt")

local main = basalt.createFrame():setTheme({FrameBG = colors.lightGray, FrameFG = colors.black})


local frameAnim = main:addAnimation()
local frames = {
  main = main:addFrame():setSize("parent.w", "parent.h"),
}
local currentFrame = "main"

local function openFrame(name, side)
  local f = frames[name]
  if(f~=nil)then
    frameAnim:clear()
    side = side or "right"
    for k,v in pairs(frames)do
      v:hide()
    end
    f:show()
    local newFrameX, newFrameY = 1, 1
    local oldFrameX, oldFrameY = 1, 1
    if(side=="left")then
      newFrameX = -main:getWidth()
      oldFrameX = main:getWidth() + 1
    elseif(side=="right")then
      newFrameX = main:getWidth()
      oldFrameX = -main:getWidth() - 1
    elseif (side == "top") then
      newFrameY = main:getHeight()
      oldFrameY = -main:getHeight() - 1
    elseif (side == "bottom") then
      newFrameY = -main:getHeight()
      oldFrameY = main:getHeight() + 1
    end
    f:setPosition(newFrameX, newFrameY)
    local oldFrame = frames[currentFrame]
    oldFrame:show()
    oldFrame:setPosition(1,1)
    frameAnim:setObject(oldFrame):move(oldFrameX, oldFrameY, 0.5):play()
    frameAnim:setObject(f):move(1, 1, 0.5):play()
    currentFrame = name
  end
end

frames.main:addLabel()
  :setText("Shop Config")
  :setSize("parent.w - 2", 1)
  :setPosition(2,2)
  :setFontSize(2)
  :show()

frames.main:addButton()
  :setText("Edit config")
  :setPosition(2, 5)
  :setSize("parent.w - 2", 3)
  :show()
  :onClick(function ()
    openFrame("config", "left")
  end)

frames.main:addButton()
  :setText("Edit listings")
  :setPosition(2, 9)
  :setSize("parent.w - 2", 3)
  :show()
  :onClick(function ()
    openFrame("listings", "right")
  end)

  frames.main:addButton()
    :setText("Quit")
    :setPosition(2, 13)
    :setSize("parent.w - 2", 3)
    :show()
    :onClick(function ()
      basalt.stopUpdate()
    end)

local function getAttachedInventories()
  local inv = {}
  local function getAttachedInventoriesToModem(modem)
    modem = peripheral.wrap(modem)
    if not modem.isWireless() then return end
    for _, v in ipairs(modem.getNamesRemote()) do
      if peripheral.hasType(v, "inventory") then inv[#inv+1] = v end
    end
  end
  for _, v in ipairs(peripheral.getNames()) do
    if peripheral.hasType(v, "inventory") then inv[#inv+1] = v
    elseif peripheral.hasType(v, "modem") then getAttachedInventoriesToModem(v) end
  end
  return inv
end

local function loadTFile(fn)
  fn = fn or "conf"
  local cf = fs.open(fn, "r")
  if cf then
    local ct = cf.readAll()
    cf.close()
    return textutils.unserialise(ct) or {}
  end
  return {}
end

local function saveTFile(conf, fn)
  fn = fn or "conf"
  local cf = fs.open(fn, "w")
  if cf then
    cf.write(textutils.serialise(conf))
    -- local p = require("cc.pretty")
    -- cf.write(p.render(p.pretty(conf)))
    cf.close()
    return
  end
  error("Failed to open config file")
end

--[[
..######...#######..##....##.########.####..######..
.##....##.##.....##.###...##.##........##..##....##.
.##.......##.....##.####..##.##........##..##.......
.##.......##.....##.##.##.##.######....##..##...####
.##.......##.....##.##..####.##........##..##....##.
.##....##.##.....##.##...###.##........##..##....##.
..######...#######..##....##.##.......####..######..
]]
local function loadConfig()
  local config = loadTFile("conf")
  config.shopName = config.shopName or ""
  config.shopOwner = config.shopOwner or ""
  config.address = config.address or ""
  config.privateKey = config.privateKey or ""
  config.name = config.name or ""
  config.shopOwner = config.shopOwner or ""
  config.url = config.url or "https://krist.dev"
  config.timeout = config.timeout or 60
  config.pass = config.pass or ""
  config.diskID = config.diskID -- nillable option
  config.input = config.input or {}
  config.description = config.description or {}
  return config
end

local function setupConfigMenu()
  frames.config = main:addFrame():setSize("parent.w", "parent.h")
  frames.config:setScrollable(true)

  local yPos = 6
  local function addSetting(label, obj)
    frames.config:addLabel()
      :setText(label)
      :setPosition(2,yPos)
      :setSize("parent.w / 2", 1)
      :show()

    obj:setPosition("parent.w / 2 + 1",yPos):setSize("parent.w / 2 - 2", 1):show()

    yPos = yPos + 2

    return obj
  end

  local config = loadConfig()

  local shopName = addSetting("Shop Name: ", frames.config:addInput()):setInputType("text"):setValue(config.shopName)

  local shopOwner = addSetting("Contact info: ", frames.config:addInput()):setInputType("text"):setValue(config.shopOwner)

  local address = addSetting("Krist Address: ", frames.config:addInput()):setInputType("text"):setValue(config.address)

  local url = addSetting("URL: ", frames.config:addInput()):setInputType("text"):setValue(config.url)

  local privateKey = addSetting("Private key: ", frames.config:addInput()):setInputType("password"):setValue(config.privateKey)

  local name = addSetting("Name (opt): ", frames.config:addInput()):setInputType("text"):setValue(config.name)
  
  local timeout = addSetting("Purchase Timeout:", frames.config:addInput():setInputType("number"):setValue(config.timeout))

  local terminatePassword = addSetting("Terminate password:", frames.config:addInput():setInputType("password"):setValue(config.pass))

  local diskID = addSetting("Terminate diskID:", frames.config:addInput():setInputType("number"):setValue(config.diskID or ""))

  frames.config:addLabel():setText("Shop Description: "):setPosition(2,yPos):setSize("parent.w-2",1)
  yPos = yPos + 2

  local description = frames.config:addTextfield():setPosition(2,yPos):setSize("parent.w-2",10)
  description:addKeywords(colors.purple, {"trans rights"})
  for k,v in pairs(config.description) do
    description:addLine(v, k)
  end
  yPos = yPos + 11

  local inventoryPeripherals = getAttachedInventories()

  local outputPerpheral = addSetting("Output Inventory: ", frames.config:addDropdown()):setDropdownSize(math.floor(main:getWidth() / 2 + 0.5) - 2, 12):setZIndex(7)

  yPos = yPos + 1

  frames.config:addLabel():setPosition(2,yPos):setSize("parent.w - 2", 1):setText("--- Input Inventories ---")

  yPos = yPos + 2

  local inputPeripheralList = frames.config:addList()

  local inputPeripheral
  inputPeripheral = addSetting("Add Inventory: ", frames.config:addDropdown()):setDropdownSize(math.floor(main:getWidth() / 2 + 0.5) - 2, 12)
    :onChange(function(input)
      if input:getValue().text then
        inputPeripheralList:addItem(input:getValue().text)
        inputPeripheralList:selectItem(0)
      end
    end):onClick(basalt.schedule(function(self)
      sleep(0.1)
      self:selectItem(0)
    end))
  frames.config:onResize(function()
    outputPerpheral:setDropdownSize(math.floor(main:getWidth() / 2 + 0.5) - 2, 12)
    inputPeripheral:setDropdownSize(math.floor(main:getWidth() / 2 + 0.5) - 2, 12)
  end)

  frames.config:addLabel():setPosition(2,yPos):setSize("parent.w - 2", 1):setText("Click one to remove")
  yPos = yPos + 2

  inputPeripheralList:setPosition(2,yPos):setSize("parent.w - 2", 8)
    :onChange(function(input)
      input:removeItem(input:getItemIndex())
      input:selectItem(0)
    end)

  for _,v in ipairs(config.input) do
    inputPeripheralList:addItem(v)
  end

  inputPeripheralList:selectItem(0)
  for k,v in ipairs(inventoryPeripherals) do
    outputPerpheral:addItem(v)
    inputPeripheral:addItem(v)
    if v == config.output then
      outputPerpheral:selectItem(k)
    end
  end

  frames.config:addButton()
    :setText("Back")
    :setPosition(2, 2)
    :setSize("parent.w / 2 - 2", 3)
    :show()
    :onClick(function() openFrame("main", "right") end)

  frames.config:addButton()
    :setText("Save")
    :setPosition("parent.w / 2 + 1", 2)
    :setSize("parent.w / 2 - 2", 3)
    :show()
    :onClick(function()
      config.shopName = shopName:getValue()
      config.shopOwner = shopOwner:getValue()
      config.address = address:getValue()
      config.privateKey = privateKey:getValue()
      config.url = url:getValue()
      config.name = name:getValue()
      config.output = (outputPerpheral:getValue() or {text=""}).text
      config.input = {}
      config.timeout = timeout:getValue()
      config.pass = terminatePassword:getValue()
      config.description = description:getLines()
      if diskID:getValue() == "" then
        config.diskID = nil
      else
        config.diskID = diskID:getValue()
      end
      for k,v in pairs(inputPeripheralList:getAll()) do
        config.input[#config.input+1] = v.text
      end

      saveTFile(config)

      openFrame("main", "right")
    end)

end

local function setupListingEditMenu()
  local function addSetting(label, obj, yPos)
    frames.listingEdit:addLabel()
      :setText(label)
      :setPosition(2,yPos)
      :setSize("parent.w / 3", 1)
      :show()

    obj:setPosition("parent.w / 3 + 1",yPos):setSize("parent.w / 3 * 2 - 2", 1):show()

    return obj
  end

  local inv = require("abstractInvLib")(loadConfig().input)
  pcall(inv.refreshStorage)
  local items = inv.listNames()

  frames.listingEdit = main:addFrame():setSize("parent.w", "parent.h")
  frames.listingEdit:addLabel()
    :setText("Editing listing")
    :setPosition(2,2)
    :setSize("parent.w - 2", 3)
    :setFontSize(2)
    :show()

  frames.listingEdit:addLabel():setText("Price calculations:"):setPosition(2,12):setSize("parent.w / 2 - 2", 1):show()
  local function addPrediction(y, text)
    local label = frames.listingEdit:addLabel():setPosition(3,y):setSize("parent.w / 2 - 4", 1)
    return function(...)
      label:setText(text:format(...))
    end
  end

  local prediction64  = addPrediction(13, "64 = %.2f")
  local prediction128 = addPrediction(14, "256 = %.2f")
  local prediction256 = addPrediction(15, "1024 = %.2f")

  local function updatePredictions(price)
    prediction64(price*64)
    prediction128(price*256)
    prediction256(price*1024)
  end

  updatePredictions(1)
  local name = addSetting("Name: ", frames.listingEdit:addInput():setInputType("text"), 6)

  local id = addSetting("Item ID: ", frames.listingEdit:addInput():setInputType("text"), 8):setSize("parent.w / 2 - 3", 1):setZIndex(10)
  local dd = frames.listingEdit:addDropdown():setPosition("parent.w / 3 + 1",8):setSize("parent.w / 3 * 2 - 2", 1):onChange(function (v)
    id:setValue(v:getValue().text)
  end):setDropdownSize(math.floor(main:getWidth() / 3 * 2 - 2 + 0.5), 12)

  frames.listingEdit:addLabel():setPosition("parent.w/2+1",12):setSize("parent.w/2-2",1):setText("Description:")
  local description = frames.listingEdit:addTextfield():setPosition("parent.w/2+1",13):setSize("parent.w/2-2",3)
  description:addKeywords(colors.purple, {"trans rights"})

  for k,v in pairs(items) do
    dd:addItem(v)
  end

  frames.listingEdit:onResize(function()
    dd:setDropdownSize(math.floor(main:getWidth() / 3 * 2 - 3 + 0.5), 12)
  end)

  local price = addSetting("Price: ", frames.listingEdit:addInput():setInputType("number"):onChange(function(v)
    -- update the price predictions
    local price = v:getValue()
    if type(price) == "number" then
      updatePredictions(v:getValue())
    end
  end), 10)

  local cancelButton = frames.listingEdit:addButton()
    :setText("Cancel")
    :setPosition(2, 17)
    :setSize("parent.w / 2 - 2", 3)
  
  local saveButton = frames.listingEdit:addButton()
    :setText("Save")
    :setPosition("parent.w / 2 + 1", 17)
    :setSize("parent.w / 2 - 2", 3)
    :show()

  local listing, index
  cancelButton:onClick(function()
    os.queueEvent("submit_pressed", listing, index)
    openFrame("listings", "top")
  end)
  saveButton:onClick(function()
    if type(price:getValue()) ~= "number" then
      basalt.debug("Attempted to set no price")
    elseif price:getValue() < 0 then
      basalt.debug("Attempted to negative price")
    else
      listing.price = price:getValue()
      listing.id = id:getValue()
      listing.name = name:getValue()
      listing.description = description:getLines()
      os.queueEvent("submit_pressed", listing, index)
      openFrame("listings", "top")
    end
  end)
  return function(l, i)
    listing, index = l, i
    name:setValue(l.name)
    id:setValue(l.id)
    price:setValue(l.price)
    -- reset the description since there's no clear method
    description = frames.listingEdit:addTextfield():setPosition("parent.w/2+1",13):setSize("parent.w/2-2",3)
    description:addKeywords(colors.purple, {"trans rights"})
    for k,v in pairs(l.description or {}) do
      description:addLine(v, k)
    end
    openFrame("listingEdit", "bottom")
  end
end

local function setupListingsMenu()
  local listingEditMenu = setupListingEditMenu()
  frames.listings = main:addFrame():setSize("parent.w", "parent.h")
  frames.listings:setScrollable(false)

  local listingList = frames.listings:addList():setPosition(2, 10):setSize("parent.w - 2", "parent.h - 10")
  local listings = loadTFile("listings")

  local function syncLists()
    listingList:clear()
    for k,v in pairs(listings) do
      listingList:addItem(string.format("%10s | %15s | %5s", v.name, v.id, v.price))
    end
  end

  syncLists()

  local thread = frames.listings:addThread()

  local function awaitListingEdit()
    local n,l,index
    repeat
      n, l, index = os.pullEvent("submit_pressed")
    until n == "submit_pressed"
    listings[index] = l
    syncLists()
  end

  frames.listings:addButton()
    :setText("Back")
    :setPosition(2, 2)
    :setSize("parent.w / 2 - 2", 3)
    :show()
    :onClick(function() openFrame("main", "left") end)

  frames.listings:addButton()
    :setText("Save")
    :setPosition("parent.w / 2 + 1", 2)
    :setSize("parent.w / 2 - 2", 3)
    :show()
    :onClick(function()
      saveTFile(listings, "listings")
      openFrame("main", "left")
    end)
  frames.listings:addButton()
    :setText("Add")
    :setPosition(2, 6)
    :setSize("parent.w / 3 - 2", 3)
    :show()
    :onClick(function()
      if thread:getStatus() ~= "running" then
        thread:start(awaitListingEdit)
        listingEditMenu({name="", id="", price=0}, #listings + 1)
      end
    end)
  
  frames.listings:addButton()
    :setText("Edit")
    :setPosition("parent.w / 3 + 1", 6)
    :setSize("parent.w / 3 - 2", 3)
    :show()
    :onClick(function()
      if thread:getStatus() ~= "running" then
        thread:start(awaitListingEdit)
        listingEditMenu(listings[listingList:getItemIndex()], listingList:getItemIndex())
      end
    end)
  
  frames.listings:addButton()
    :setText("Delete")
    :setPosition("parent.w / 3 * 2 + 1", 6)
    :setSize("parent.w / 3 - 2", 3)
    :show()
    :onClick(function()
      table.remove(listings, listingList:getItemIndex())
      syncLists()
    end)
  
end


setupConfigMenu()
setupListingsMenu()
openFrame("main","bottom")
basalt.autoUpdate()
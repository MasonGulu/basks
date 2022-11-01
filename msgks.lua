local basalt = require("basalt")

local main = basalt.createFrame():setTheme({FrameBG = colors.lightGray, FrameFG = colors.black}) 

local frameAnim = main:addAnimation()
local frames = {}
local currentFrame = "main"
local config, inv, listings, cart, kst, shopAddress, selectedListing, err

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

local function openUp(name)
  local f = frames[name]
  basalt.log("openUp called!")
  if f ~= nil then
    basalt.log("openUp nil passed")
    basalt.log("name="..name)
    basalt.log("currentFrame="..currentFrame)
    frameAnim:clear()
    
    for k,v in pairs(frames)do
      v:hide()
    end
    local w, h = main:getWidth(), main:getHeight()
    f:setPosition("parent.w / 2","parent.h / 2")
    f:setSize(1,1)
    f:show()
    local time = 1
    frameAnim:setObject(f):move(1,1,time):size(w,h,time):setMode("easeOutBounce"):play()
    main:addTimer():setTime(time+0.1):onCall(function()
      frameAnim:cancel()
      f:setSize("parent.w","parent.h")
      f:setPosition(1,1)
    end):start()
    currentFrame = name
  end
end

local function showFrame(name)
  local f = frames[name]
  if f ~= nil then
    frameAnim:clear()
    
    for k,v in pairs(frames)do
      v:hide()
    end
    f:setPosition(1,1)
    f:setSize("parent.w", "parent.h")
    f:show()
    currentFrame = name
  end
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

local function initialize()
  config = loadTFile("conf")
  inv = require("abstractInvLib")(config.input)
  inv.refreshStorage()
  listings = loadTFile("listings")
  cart = {}

  kst = require("ktwsl")(config.url, config.privateKey)
  kst.start()

  shopAddress = config.address
  if config.name ~= "" then
    shopAddress = config.name
  end
  kst.subscribeAddress(shopAddress)

  selectedListing = listings[1]

  local i = 0
  main:addThread():start(function()
    while true do
      local e, reason = os.pullEvent()
      if e == "krist_stop" then
        i = i + 1
        err("Krist Stopped", reason..i)
      elseif e == "terminateApproved" then
        kst.stop()
        basalt.stopUpdate()
      end
    end
  end)
end



local function getCartTotal()
  local total = 0
  for k,v in pairs(cart) do
    total = total + v.price * v.cart
  end
  return total
end


--[[
.##.....##....###....####.##....##
.###...###...##.##....##..###...##
.####.####..##...##...##..####..##
.##.###.##.##.....##..##..##.##.##
.##.....##.#########..##..##..####
.##.....##.##.....##..##..##...###
.##.....##.##.....##.####.##....##
]]
local function setupMain()
  frames.main = main:addFrame():setSize("parent.w", "parent.h")
  frames.main:addLabel():setText("Owner: "..config.shopOwner):setPosition(1,1):setSize("parent.w", 1):show()
  frames.main:addLabel():setText(config.shopName):setFontSize(2):setPosition(2,2):setSize("parent.w", 1):show()

  local listingList = frames.main:addList():setPosition(2,5):setSize("parent.w / 3 * 2 - 2", "parent.h - 5"):show():onChange(function(self)
    selectedListing = listings[self:getItemIndex()]
    os.queueEvent("selectionChange")
  end)
  local thirdw = "parent.w / 3 - 1"
  local sixthw = "parent.w / 6 - 1"
  local thirdp = "parent.w / 3 * 2 + 1"
  local fifthp = "parent.w / 6 * 4 + 1"
  local sixthp = "parent.w / 6 * 5 + 1"

  local cartButton = frames.main:addButton():setText("Cart(0KST)"):setPosition(fifthp, 2):setSize(thirdw, 3):show():onClick(function ()
    openFrame("cart","bottom")
  end)

  local infoButton = frames.main:addButton():setText("?"):setPosition("parent.w-3", "parent.h-3"):setSize(3,3):show():onClick(function ()
    openFrame("info","top")
  end)

  frames.main:addLabel():setText("Name:"):setPosition(thirdp,6):setSize(sixthw,1):show()
  local nameLabel = frames.main:addLabel():setText(""):setPosition(sixthp,6):setSize(sixthw,1):show()

  frames.main:addLabel():setText("KST/I:"):setPosition(fifthp,8):setSize(sixthw,1):show()
  local priceLabel = frames.main:addLabel():setText(""):setPosition(sixthp,8):setSize(sixthw,1):show()

  frames.main:addLabel():setText("Stock:"):setPosition(fifthp,10):setSize(sixthw,1):show()
  local stockLabel = frames.main:addLabel():setText(""):setPosition(sixthp,10):setSize(sixthw,1):show()


  ------ Quantity input
  frames.main:addLabel():setText("In Cart:"):setPosition(thirdp,12):setSize(thirdw,1):show()
  local quantityInput -- define this so it can be assigned later

  local quantityDropdown = frames.main:addDropdown():setPosition(thirdp, 13):setSize(thirdw,1):show():onChange(function (self)
    quantityInput:setValue(self:getValue().text)
    self:selectItem(0)
  end):addItem("")
    :addItem(8):addItem(16):addItem(32):addItem(64)
    :addItem(128):addItem(256):addItem(512):addItem(1024)
    :setDropdownSize(math.floor(main:getWidth() / 3 - 2), 5)

  frames.main:onResize(function()
    quantityDropdown:setDropdownSize(math.floor(main:getWidth() / 3 - 2), 6)
  end)

  local subTotalLabel = frames.main:addLabel():setText("-"):setPosition(thirdp,15):setSize(thirdw,1):show()

  local totalLabel = frames.main:addLabel():setText(0):setPosition(thirdp,16):setSize(thirdw,1):show()

  -- The concat is to make this 1 char narrower. I put this overtop of a dropdown
  quantityInput = frames.main:addInput():setInputType("number"):setPosition(thirdp,13):setSize(thirdw.."-1",1):show():onChange(function(self)
    local v = self.getValue()
    if type(v) == "number" then
      if v < 0 then
        v = 0
      end
      -- Ensure we don't go over the amount of items there are
      v = math.min(math.floor(v + 0.5), inv.getCount(selectedListing.id))
      self:setValue(v)
      selectedListing.cart = v
      subTotalLabel:setText(string.format("%.2f",v * selectedListing.price))
      cart[selectedListing] = selectedListing
    else
      cart[selectedListing] = nil
      selectedListing.cart = nil
      subTotalLabel:setText("-") -- show no price when box is invalid
    end
    os.queueEvent("syncListings")
  end):setZIndex(9)

  frames.main:addThread():start(function ()
    while true do
      local e, total = os.pullEvent()
      if e == "selectionChange" then
        -- the selectedListing has been changed, adjust gui values
        nameLabel:setText(selectedListing.name)
        priceLabel:setText(selectedListing.price)
        quantityInput:setValue(selectedListing.cart or "")
        stockLabel:setValue(inv.getCount(selectedListing.id))
      elseif e == "totalChange" then
        -- the total changed, update gui values
        totalLabel:setValue(string.format("%.2f", total))
        cartButton:setText(string.format("Cart(%uKST)", math.ceil(total)))
      elseif e == "syncListings" then
        -- information about the listings changed, rerender list
        local i = listingList:getItemIndex()
        if i == 0 then i = 1 end -- ensure that there's something selected
        listingList:clear()
        for k,v in pairs(listings) do
          listingList:addItem(string.format("%s@%sKST;%sstk;%scart", v.name, v.price, inv.getCount(v.id), v.cart or 0))
        end
        listingList:selectItem(i)
        os.queueEvent("totalChange", getCartTotal()) -- queue the totalChange event from here
        -- if the listings change, the total is gonna change
        os.queueEvent("selectionChange")
      end
    end
  end)

end

--[[
.####.##....##.########..#######.
..##..###...##.##.......##.....##
..##..####..##.##.......##.....##
..##..##.##.##.######...##.....##
..##..##..####.##.......##.....##
..##..##...###.##.......##.....##
.####.##....##.##........#######.
]]
local function setupInfo()
  frames.info = main:addFrame():setSize("parent.w", "parent.h"):setScrollable(true)

  local hw = "parent.w / 2 - 2"
  local hp = "parent.w / 2 + 1"

  local tw = "parent.w / 3 - 2"
  local t2w = "parent.w / 3 * 2 - 2"
  local t1p = "parent.w / 3 + 1"
  local t2p = "parent.w / 3 * 2 + 1"
  local function addLabel(y, text)
    frames.info:addLabel():setText(text):setPosition(3,y):setSize(tw.."-1",1)
    return frames.info:addLabel():setPosition(t1p,y):setSize(t2w,1):setText("")
  end

  frames.info:addLabel():setPosition(2,2):setSize("parent.w",1):setText("Information"):setFontSize(2)

  frames.info:addLabel():setPosition(2,5):setSize("parent.w",1):setText("Shop info")
  addLabel(6, "Name:"):setText(config.shopName)
  addLabel(7, "Owner:"):setText(config.shopOwner)

  config.description = config.description or {}
  frames.info:addLabel():setPosition(3,8):setSize("parent.w-3",1):setText("Description:")
  local description = frames.info:addTextfield():setPosition(4,9):setSize("parent.w-5",#config.description):disable()
  description:addKeywords(colors.purple, {"trans rights"})
  for k,v in pairs(config.description) do
    description:addLine(v, k)
  end

  local itemInfoStart = 9 + #config.description
  frames.info:addLabel():setPosition(2,itemInfoStart):setSize("parent.w",1):setText("Item info")
  local nameLabel = addLabel(itemInfoStart+1, "Name:")
  local idLabel = addLabel(itemInfoStart+2, "ID:")
  local priceLabel = addLabel(itemInfoStart+3, "Price:")


  config.description = config.description or {}
  frames.info:addLabel():setPosition(3,itemInfoStart+4):setSize("parent.w-3",1):setText("Description:")
  local itemDescription = frames.info:addTextfield():setPosition(4,itemInfoStart+5):setSize("parent.w-5",5):disable()
  itemDescription:addKeywords(colors.purple, {"trans rights"})

  local footerStart = itemInfoStart+6+5

  local creditLabel = frames.info:addLabel():setPosition(2,footerStart):setSize("parent.w-2",1):setText("MSGKS by ShreksHellraiser"):show()
  -- BASalt Krist Shop
  local backButton = frames.info:addButton():setPosition(2, footerStart+1):setSize("parent.w-2",3):setText("Back"):onClick(function ()
    openFrame("main", "bottom")
  end)

  frames.info:addThread():start(function ()
    while true do
      os.pullEvent("selectionChange")
      nameLabel:setText(selectedListing.name)
      idLabel:setValue(selectedListing.id)
      priceLabel:setText(selectedListing.price)
      -- reset the textbox since you can't clear it
      selectedListing.description = selectedListing.description or {}
      local descriptionHeight = #selectedListing.description
      itemDescription:clear()
      itemDescription:setSize("parent.w-5",descriptionHeight)
      for k,v in pairs(selectedListing.description) do
        itemDescription:addLine(v, k)
      end
      footerStart = itemInfoStart+6+descriptionHeight
      backButton:setPosition(2,footerStart+1)
      creditLabel:setPosition(2,footerStart)
    end
  end)
end

local function clearCart()
  for _,v in pairs(cart) do
    v.cart = nil
  end
  cart = {}
  os.queueEvent("syncListings")
end


--[[
..######.....###....########..########.....######..########.########.##.....##.########.
.##....##...##.##...##.....##....##.......##....##.##..........##....##.....##.##.....##
.##........##...##..##.....##....##.......##.......##..........##....##.....##.##.....##
.##.......##.....##.########.....##........######..######......##....##.....##.########.
.##.......#########.##...##......##.............##.##..........##....##.....##.##.......
.##....##.##.....##.##....##.....##.......##....##.##..........##....##.....##.##.......
..######..##.....##.##.....##....##........######..########....##.....#######..##.......
]]
local function setupCart()
  frames.cart = main:addFrame():setSize("parent.w","parent.h")
  frames.cart:addLabel():setPosition(2,2):setText("Cart"):setFontSize(2)
  frames.cart:addLabel():setPosition(2,5):setText(string.format("%10s | %8s | %6s | %8s", "Name", "Price", "Cart", "Subtotal"))
  local cartList = frames.cart:addList():setPosition(2,6):setSize("parent.w - 2", "parent.h - 12")
  
  frames.cart:addLabel():setPosition(2,"parent.h-6"):setSize("parent.w / 2 - 2",1):setText("Raw Total")
  local rawTotalLabel = frames.cart:addLabel():setPosition("parent.w / 2 + 1","parent.h-6"):setSize("parent.w / 2 - 2",1):setText("")

  frames.cart:addLabel():setPosition(2,"parent.h-5"):setSize("parent.w / 2 - 2",1):setText("Total")
  local totalLabel = frames.cart:addLabel():setPosition("parent.w / 2 + 1","parent.h-5"):setSize("parent.w / 2 - 2",1):setText("")

  frames.cart:addButton():setPosition(2,"parent.h-3"):setSize("parent.w / 2 - 2", 3):setText("Back"):onClick(function()
    openFrame("main", "top")
  end)
  
  local purchaseButton = frames.cart:addButton():setPosition("parent.w / 2 + 1","parent.h-3"):setSize("parent.w / 2 - 2", 3):setText("Purchase"):onClick(function ()
    os.queueEvent("purchaseStart")
  end)

  local removeButton = frames.cart:addButton():setPosition("parent.w - 16", 2):setSize(8,3):setText("Remove"):onClick(function()
    local item = cartList:getValue()
    if item then
      item.args[1].cart = nil
      cart[item.args[1]] = nil
      os.queueEvent("syncListings")
      -- end
    end
  end)
  local clearButton = frames.cart:addButton():setPosition("parent.w - 7", 2):setSize(7,3):setText("Clear"):onClick(clearCart)

  frames.cart:addThread():start(function()
    while true do
      local e, total = os.pullEvent()
      if e == "syncListings" then
        -- information about the listings changed, rerender list
        local i = cartList:getItemIndex()
        if i == 0 then i = 1 end -- ensure that there's something selected
        cartList:clear()
        for k,v in pairs(cart) do
          cartList:addItem(string.format("%10s | %8s | %6s | %8s", v.name, v.price, v.cart, v.cart * v.price), nil, nil, v)
        end
        cartList:selectItem(i)
      elseif e == "totalChange" then
        totalLabel:setText(math.ceil(total))
        rawTotalLabel:setText(string.format("%.2f", total))
        -- if #cart > 0 then
        --   purchaseButton:enable()
        -- else
        --   purchaseButton:disable()
        -- end
      end
    end
  end)
end

--[[
.########.########..########...#######..########.
.##.......##.....##.##.....##.##.....##.##.....##
.##.......##.....##.##.....##.##.....##.##.....##
.######...########..########..##.....##.########.
.##.......##...##...##...##...##.....##.##...##..
.##.......##....##..##....##..##.....##.##....##.
.########.##.....##.##.....##..#######..##.....##
]]
local function setupError()
  frames.error = main:addFrame():setSize("parent.w","parent.h"):setBackground(colors.black)

  frames.error:addLabel():setPosition(1,1):setFontSize(3):setText("ERROR"):setForeground(colors.red):setBackground(colors.black)

  local subtitleLabel = frames.error:addLabel():setPosition(4,7):setFontSize(2):setText("Uh oh, fucky wucky"):setForeground(colors.red):setBackground(colors.black)

  local stacktraceFrame = frames.error:addFrame():setSize("parent.w - 2", "parent.h - 12"):setPosition(2,10):setScrollable(true)
    :addFrame():setSize("parent.w", 30)

  local stacktraceLabel = stacktraceFrame:addLabel():setPosition(1,1):setText("Stacktrace"):setSize("parent.w", "parent.h")

  frames.error:addLabel():setPosition(2,"parent.h-2"):setText(("Shop operated by %s"):format(config.shopOwner))
  frames.error:addLabel():setPosition(2,"parent.h-1"):setText("Please reboot the computer")

  return function(subtitle, stacktrace)
    subtitleLabel:setText(subtitle)
    stacktraceLabel:setText(stacktrace)
    showFrame("error")
  end

end

--[[
.########..##.....##.########...######..##.....##....###.....######..########
.##.....##.##.....##.##.....##.##....##.##.....##...##.##...##....##.##......
.##.....##.##.....##.##.....##.##.......##.....##..##...##..##.......##......
.########..##.....##.########..##.......#########.##.....##..######..######..
.##........##.....##.##...##...##.......##.....##.#########.......##.##......
.##........##.....##.##....##..##....##.##.....##.##.....##.##....##.##......
.##.........#######..##.....##..######..##.....##.##.....##..######..########
]]
local function setupPurchase()
  frames.purchase = main:addFrame():setSize("parent.w","parent.h")
  frames.purchase:addLabel():setText("Please send"):setPosition(2,2)
  local priceLabel = frames.purchase:addLabel():setText("0KST"):setPosition(2,3):setFontSize(2)
  frames.purchase:addLabel():setText("To"):setPosition(2,6)
  local addressLabel = frames.purchase:addLabel():setPosition(2,7):setText(shopAddress):setFontSize(2)
  frames.purchase:addLabel()
    :setText("Within the next "..config.timeout.." seconds, or your cart will be erased. The back button will not clear your cart.")
    :setPosition(2,10):setSize("parent.w - 2", 2)

  frames.purchase:addButton():setText("Back"):setPosition(2, "parent.h-3"):setSize("parent.w-2", 3):onClick(function()
    os.queueEvent("purchaseCancel")
  end)

  local timer

  local function issueRefund(address, amount)
    local stat, er = kst.makeTransaction(address, amount)
    if not stat then
      if timer then
        timer:cancel()
      end
      err("Refund failure", er)
    end
  end

  local function finishTransaction()
    for k,v in pairs(cart) do
      inv.pushItems(config.output, v.id, v.cart)
    end
    clearCart()
    openFrame("main","top")
    if timer then
      timer:cancel()
    end
  end

  frames.purchase:addThread():start(function()
    local expectingPurchase = false
    local totalExpected = 0
    while true do
      local e, val, fromAddress, krist = os.pullEvent()
      if e == "purchaseStart" then
        -- call this event when wanting to display the purchase screen
        openUp("purchase")
        if totalExpected == 0 then
          finishTransaction()
        end
        timer = frames.purchase:addTimer()
        timer:setTime(config.timeout)
        timer:onCall(function()
          clearCart()
          os.queueEvent("purchaseCancel")
        end):start()
        expectingPurchase = true
      elseif e == "purchaseCancel" then
        if timer then
          timer:cancel()
        end
        if not val then
          openFrame("main", "top")
        end
        expectingPurchase = false
      elseif e == "totalChange" then
        totalExpected = math.ceil(val)
        priceLabel:setText(totalExpected.."KST")
      elseif e == "krist_transaction" then
        local toAddress = val
        if toAddress == shopAddress then
          if expectingPurchase then
            if krist >= totalExpected then
              local refund = krist - totalExpected
              if refund > 0 then
                -- issue a refund
                issueRefund(fromAddress, refund)
              end
              finishTransaction()
              expectingPurchase = false
            else
              issueRefund(fromAddress, krist)
            end
          else
            -- Issue a refund
            issueRefund(fromAddress, krist)
          end
        end
      end
    end
  end)
end


local successfulTerminate = false
--[[
.########.########.########..##.....##.####.##....##....###....########.########
....##....##.......##.....##.###...###..##..###...##...##.##......##....##......
....##....##.......##.....##.####.####..##..####..##..##...##.....##....##......
....##....######...########..##.###.##..##..##.##.##.##.....##....##....######..
....##....##.......##...##...##.....##..##..##..####.#########....##....##......
....##....##.......##....##..##.....##..##..##...###.##.....##....##....##......
....##....########.##.....##.##.....##.####.##....##.##.....##....##....########
]]
local function setupTerminate()
  local oldFrame
  frames.terminate = main:addFrame():setSize("parent.w","parent.h")
  frames.terminate:addLabel():setPosition(2,2):setText("TERMINATE?"):setFontSize(2)

  local menuOpen = false

  frames.terminate:addLabel():setPosition(2,6):setText("Enter passcode:")
  local passwordInput = frames.terminate:addInput():setInputType("password"):setPosition(2,7):setSize("parent.w-2",1):onChange(function (self)
    if self:getValue() == config.pass then
      os.queueEvent("terminateApproved")
      successfulTerminate = true
    end
  end)

  frames.terminate:addLabel():setPosition(2,9):setText("Or insert your disk.")

  frames.terminate:addButton():setText("Cancel"):setPosition(2,"parent.h-3"):setSize("parent.w-2",3):onClick(function ()
    openFrame(oldFrame, "top")
    menuOpen = false
  end)

  basalt.onEvent(function(event, disk)
    if(event=="terminate")then
      if not menuOpen then
        oldFrame = currentFrame
        menuOpen = true
        passwordInput:setValue("")
        os.queueEvent("purchaseCancel", true) -- Ensure that if you terminate while in the cart, the purchase is cancelled
        openUp("terminate")
      end
      return false
    elseif (event=="disk") and menuOpen and config.diskID then
      if peripheral.call(disk, "getDiskID") == config.diskID then
        successfulTerminate = true
        os.queueEvent("terminateApproved")
      end
    end
  end)
end



local stat, v = pcall(initialize)
if not stat or (not (config and config.pass and config.pass ~= "")) then
  term.setTextColor(colors.red)
  print("Failed to initialize shop...")
  print(v)
  print("Please restart the computer")
  if kst then
    kst.stop()
  end
  if not (config and config.pass and config.pass ~= "") then
    print("WARNING! You do not have a termination password set.")
    print("The program has been stopped for your protection.")
    return
  end
  while true do
    os.pullEventRaw()
  end
end


err = setupError()
setupTerminate()
setupInfo()
setupMain()
setupCart()
setupPurchase()
openFrame(currentFrame,"bottom")
os.queueEvent("syncListings")
basalt.autoUpdate()
if not successfulTerminate then
  term.setCursorPos(1,term.getSize()[2])
  term.setTextColor(colors.red)
  term.setBackgroundColor(colors.gray)
  term.clearLine()
  term.write("Please restart the computer")
  while true do
    os.pullEventRaw()
  end
end
jumpDialog = nil
-- margins used to move the button
local marginRight = 0
local marginBottom = 0
-- interval for button jumping values
local randomInterval = {30,80}
-- holds the scheduledEvent moveHorizontal
local moveEvent

function init()
  connect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd
  }, true)

   g_ui.importStyle('jumpmodal')

  local dialog = rootWidget:recursiveGetChildById('modalDialog')
  if dialog then
    jumpDialog = dialog
  end
end

function terminate()
  disconnect(g_game, { onJumpDialog = onJumpDialog,
                       onGameEnd = destroyJumpDialog })
end

-- we use extended OP codes to receive the sign that we shoul start this dialog 
-- the packet consists of 0x32 (50 in base 10) the code for extended OPcodes, 0x37 (55 in base 10) the extended code for this request and the string "1"
-- the codes 10 and 55 are consumed when received and onJumpDialog is called
function onGameStart()
    ProtocolGame.registerExtendedOpcode(55, onJumpDialog)
end

-- Unregistering what we registered in onGameStart when the player leaves the game.

function onGameEnd()
    ProtocolGame.unregisterExtendedOpcode(55, true)
end


function destroyJumpDialog()
  if jumpDialog then
    jumpDialog:destroy()
    jumpDialog = nil
  end

  if moveEvent then
    removeEvent(moveEvent)
    moveEvent = nil
  end
end

function moveVertical(button)
  
    if not button then
        return
    end

    local buttonsPanel = jumpDialog:getChildById('buttonsPanel')
    if not buttonsPanel then
        return
    end

    -- calculate the jump, I've chosen to interpter the video showing the vertical movement as alternating between up and down in a random interval
    marginBottom = marginBottom + math.random(randomInterval[1], randomInterval[2])
    -- flip the sign of the interval between positive and negative to alternate between jumping up and down
    randomInterval[1] = -randomInterval[1]
    randomInterval[2] = -randomInterval[2]
    -- this is the limit of the bottom margin in which the button remains on the dialog - bottom margin is [0,limitY]
    local limitY = jumpDialog:getHeight() - jumpDialog:getPaddingBottom() - jumpDialog:getPaddingTop() - buttonsPanel:getHeight()

    -- if the margin is outside the limit we clamp it
    if marginBottom < 0 then
      marginBottom = 0
    elseif marginBottom > limitY then
      marginBottom = limitY
    end

    -- position the button at the far right
    marginRight = 0

    -- we move the button panel up/down instead of the button as its about the same height as the button
    buttonsPanel:setMarginBottom(marginBottom)

    -- stop and restart the button horizontal movement
    removeEvent(moveEvent)
    moveEvent = nil
    moveHorizontal(button)
end

function moveHorizontal(button)
    if not button then
        return
    end

    local buttonsPanel = jumpDialog:getChildById('buttonsPanel')
    if not buttonsPanel then
      return
    end

    -- the limit of the right margin of the button in which the button still remains on the dialog
    local limitX = buttonsPanel:getWidth() - buttonsPanel:getPaddingLeft() - buttonsPanel:getPaddingRight() - button:getWidth()

    -- we move the button by increasing its margin
    button:setMarginRight(marginRight - buttonsPanel:getPaddingRight())

    -- when the button reaches the far left of the dialog, return it to the right
    if (marginRight > limitX) then
      marginRight = 0
    end

    -- we move every 1px per 25ms
    moveEvent = scheduleEvent(function() moveHorizontal(button) end, 25)
    marginRight = marginRight + 1
  
    return true
end


function onJumpDialog(protocol, opcode, packet)

    if jumpDialog then
      return
    end
    marginRight = 0
    marginBottom = 0

    jumpDialog = g_ui.createWidget('ModalDialog', rootWidget)

    local buttonsPanel = jumpDialog:getChildById('buttonsPanel')

    local buttonId = "1"
    local buttonText = "Jump"

    local button = g_ui.createWidget('ModalButton', buttonsPanel)
    button:setText(buttonText)
    -- clicking causes the button to move vertically
    button.onClick = function(self)
                        moveVertical(button)
                        end
    -- start the horizontal movement upon dialog creation
    moveHorizontal(button)

    local buttonsWidth = 0
    buttonsWidth = buttonsWidth + button:getWidth() + button:getMarginLeft() + button:getMarginRight()

    local horizontalPadding = jumpDialog:getPaddingLeft() + jumpDialog:getPaddingRight()
    buttonsWidth = buttonsWidth + horizontalPadding

    jumpDialog:setWidth(math.min(jumpDialog.maximumWidth, math.max(buttonsWidth, jumpDialog.minimumWidth)))
    jumpDialog:setHeight(jumpDialog:getHeight() - 8)

    -- exit the dialog with enter or ecs keys
    local enterFunc = function()
      destroyJumpDialog()
    end

    local escapeFunc = function()
      destroyJumpDialog()
    end

    jumpDialog.onEnter = enterFunc
    jumpDialog.onEscape = escapeFunc

end
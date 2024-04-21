
-- Original
--[[
local function releaseStorage(player)
    player:setStorageValue(1000, -1)
    end
    
    function onLogout(player)
    if player:getStorageValue(1000) == 1 then
    addEvent(releaseStorage, 1000, player)
    end
    return true
    end

]]

-- changed

function onLogout(player)
    -- check if player is not nil
    if not player then
        return false
    end

    if player:getStorageValue(1000) == 1 then
    -- there is no guarantee that addEvent would execute
    --the associated timer might be cleared due to player logout
    -- instead we call the function directly
    releaseStorage(player)
    end
    return true
end
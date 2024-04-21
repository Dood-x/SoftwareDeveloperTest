
-- original

--[[
function do_sth_with_PlayerParty(playerId, membername)
player = Player(playerId)
local party = player:getParty()

for k,v in pairs(party:getMembers()) do
if v == Player(membername) then
party:removeMember(Player(membername))
end
end
end
]]

-- changed

-- renamed the function, i would also add the following comment above the function signature
-- removes the member with membername from the party of the player with playerId
function removeMemberFromPlayerParty(playerId, membername)
    player = Player(playerId)

    -- preform checks for all the Get functions
    if not player then
        return
    end

    local party = player:getParty()
    if not party then
       return
    end

    local members = party:getMembers()
    if not members then
        return
    end

    for k,v in pairs(party:getMembers()) do
        if v == Player(membername) then
            party:removeMember(Player(membername))
            -- break the loop once the member has been removed
            break
        end
    end
end

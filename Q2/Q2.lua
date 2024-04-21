

--[[ 

--original 

function printSmallGuildNames(memberCount)
-- this method is supposed to print names of all guilds that have less than memberCount max members
local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < %d;"
local resultId = db.storeQuery(string.format(selectGuildQuery, memberCount))
local guildName = result.getString("name")
print(guildName)
end

]]


-- changed


function printSmallGuildNames(memberCount)
    -- This method is supposed to print names of all guilds that have less than memberCount max members
    local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < %d;"

    -- 'db' seemengly appears out of nowhere, if this is from the TFS library then we know that db is part of the 
    -- TFS API for sql queries
    local resultId = db.storeQuery(string.format(selectGuildQuery, memberCount))

    -- added check
    if not resultId then
        return
    end


    -- Loop through the results and print the guild names
    -- the result variable is also part of the TFS API and can be used as follows
    while result.next(resultId) do
        local guildName = result.getString(resultId, "name")
        print(guildName)
    end
    -- result needs to be freed
    result.free(resultId)
end

-- interval at which the spell is animated
local spellInterval = 200

-- area of effect pattens of the spell (this is approximately according to the video in sequence)
-- 0 is no spell, 1 is spell, 3 is the players position

local area = {

	{
		{0, 0, 0, 1, 0, 0, 0},
		{0, 0, 0, 0, 1, 0, 0},
		{0, 0, 0, 0, 0, 1, 0},
		{1, 0, 0, 3, 0, 0, 1},
		{0, 0, 0, 0, 0, 1, 0},
		{0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0}
	},

	{
		{0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0},
		{0, 1, 0, 1, 0, 0, 0},
		{0, 0, 0, 3, 0, 0, 1},
		{0, 1, 0, 0, 0, 0, 0},
		{0, 0, 1, 0, 1, 0, 0},
		{0, 0, 0, 0, 0, 0, 0}
	},

	{
		{0, 0, 0, 0, 0, 0, 0},
		{0, 0, 1, 0, 1, 0, 0},
		{0, 0, 0, 0, 0, 0, 0},
		{0, 0, 1, 3, 1, 0, 0},
		{0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0}
	},

	{
		{0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 3, 0, 0, 0},
		{0, 0, 0, 1, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 1, 0, 0, 0}
	}

}

-- for some reason the spells are flipped up down and left right
-- the areas have to be flipped right to left and upside down to correspond to the positions written
-- this makes it easier to write the tables by hand
function reverseArea(area)
	local reverseArea = area
	local areaCount = #area

	-- for every area
	for key, value in ipairs(area) do

		local reverseMatrix = {}
		local areaHeight = #area[key] 

		-- area row
		for keyi, valuei in ipairs(area[key]) do

			local reverseRow = {}
			local areaWidth = #area[key][keyi]

		-- int inside the row
			for keyj, valuej in ipairs(area[key][keyi]) do
				-- place them reverse in the new row to flip left-right
				reverseRow[areaWidth+1-keyj] = valuej
			end
			-- place reverse in the new matrix to flip up-down
			reverseMatrix[areaHeight+1-keyi] = reverseRow
		end

		-- same order of areas
		reverseArea[key] = reverseMatrix
	end
	return reverseArea
end 

area = reverseArea(area)

-- we loop the 4 areas 3 times
local combat = {
	Combat(),Combat(),Combat(),Combat(),
	Combat(),Combat(),Combat(),Combat(),
	Combat(),Combat(),Combat(),Combat()
}

-- set each combat to ice damage and sprite
for key, value in ipairs(combat) do
	value:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)

	-- note this sprite is bugged on some clients, other sprites work
	value:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO) 

	-- areas are casted sequentally and loop, starting from 1
	value:setArea(createCombatArea(area[((key-1) % #area) + 1]))

	function onGetFormulaValues(player, level, magicLevel)
		local min = (level / 5) + (magicLevel * 5.5) + 25
		local max = (level / 5) + (magicLevel * 11) + 50
		return -min, -max
	end
	
	
	value:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")
end


function castSpell(combat, creatureId, variant)
	local creature = Creature(creatureId)
    if not creature then
        return
    end
    if not combat then
        print("no combat!")
        return
    end

	combat:execute(creature, variant)
end

function onCastSpell(creature, variant)
	local creatureId = creature:getId()
	
	for key, value in ipairs(combat) do
		-- add events to cast the spell separated by the interval
		addEvent(castSpell, spellInterval * (key-1), value, creatureId, variant)
	end

	return
end

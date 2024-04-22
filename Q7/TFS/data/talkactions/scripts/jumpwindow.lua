
function onSay(player, words, param)
	local packet = NetworkMessage()
	-- we used extended Opcodes - custom codes designed for creating custom features
	packet:addByte(0x32) -- Extended Opcode (0x32 = 50 (in dec))
	packet:addByte(0x37) -- The Opcode of this Request (0x37 = 55 (in dec))
	-- all this packet needs to do is be received to activate the window, we send a simple 1
	packet:addString(tostring(1))
	packet:sendToPlayer(player)
	packet:delete()
end



toolranks = {
	colors = {
		grey = minetest.get_color_escape_sequence("#9d9d9d"),
		green = minetest.get_color_escape_sequence("#1eff00"),
		gold = minetest.get_color_escape_sequence("#ffdf00"),
		white = minetest.get_color_escape_sequence("#ffffff")
	}
}


function toolranks.create_description(name, uses, level)

	return toolranks.colors.green .. (name or "") .. "\n"
		.. toolranks.colors.gold .. "Level: " .. (level or 1) .. "\n"
		.. toolranks.colors.grey .. "Used: " .. (uses or 0) .. " times"
end


function toolranks.get_level(uses)

	if uses >= 3200 then
		return 6
	elseif uses >= 2000 then
		return 5
	elseif uses >= 1000 then
		return 4
	elseif uses >= 400 then
		return 3
	elseif uses >= 200 then
		return 2
	else
		return 1
	end
end


function toolranks.new_afteruse(itemstack, user, node, digparams)

	-- Get tool metadata and number of times used
	local itemmeta = itemstack:get_meta()
	local dugnodes = tonumber(itemmeta:get_string("dug")) or 0

	-- Only count nodes that spend the tool
	if digparams.wear > 0 then

		dugnodes = dugnodes + 1

		itemmeta:set_string("dug", dugnodes)
	else
		return
	end

	-- Get tool description and last level
	local itemdef   = itemstack:get_definition()
	local itemdesc  = itemdef.original_description or itemdef.description or "Tool"
	local lastlevel = tonumber(itemmeta:get_string("lastlevel")) or 1
	local name = user:get_player_name()

	-- Warn player when tool is almost broken
	if itemstack:get_wear() > 60100 then

		minetest.chat_send_player(name,
			toolranks.colors.gold .. "Your tool is almost broken!")

		minetest.sound_play("default_tool_breaks", {
			to_player = name,
			gain = 1.0
		})
	end

	local level = toolranks.get_level(dugnodes)

	-- Alert player when tool has leveled up
	if lastlevel < level then

		minetest.chat_send_player(name, "Your "
			.. toolranks.colors.green .. itemdesc
			.. toolranks.colors.white .. " just leveled up!")

		minetest.sound_play("toolranks_levelup", {
			to_player = name,
			gain = 1.0
		})

		itemmeta:set_string("lastlevel", level)
	end

	-- Set new meta
	itemmeta:set_string("description",
			toolranks.create_description(itemdesc, dugnodes, level))

	local wear = digparams.wear

	-- Set wear level
	if level > 1 then
		wear = digparams.wear * 4 / (4 + level)
	end

	itemstack:add_wear(wear)

	return itemstack
end


-- Default tool list
local tools = {

	"default:sword_wood", "default:sword_stone", "default:sword_steel",
	"default:sword_bronze", "default:sword_mese", "default:sword_diamond",

	"default:pick_wood", "default:pick_stone", "default:pick_steel",
	"default:pick_bronze", "default:pick_mese", "default:pick_diamond",

	"default:axe_wood", "default:axe_stone", "default:axe_steel",
	"default:axe_bronze", "default:axe_mese", "default:axe_diamond",

	"default:shovel_wood", "default:shovel_stone", "default:shovel_steel",
	"default:shovel_bronze", "default:shovel_mese", "default:shovel_diamond",
	
	--"nether:shovel_nether", "nether:axe_nether", "nether:sword_nether",
	--"nether:pick_nether",
}


-- Loop through tool list and add new toolranks description
for n = 1, #tools do

	local name = tools[n]
	local def = minetest.registered_tools[name]
	local desc = def and def.description

	if desc then

		minetest.override_item(name, {
			original_description = desc,
			description = toolranks.create_description(desc),
			after_use = toolranks.new_afteruse
		})
	end
end

-- Nuke Mod 1.5 by sfan5
-- Licensed under GPLv2

function spawn_tnt(pos, entname)
    minetest.sound_play("nuke_ignite", {pos = pos,gain = 1.0,max_hear_distance = 8,})
    return minetest.env:add_entity(pos, entname)
end

function activate_if_tnt(nname, np, tnt_np, tntr)
	--Added to if condition  - Jonathan 5/16/2013
    if nname == "nuke:iron_tnt" or nname == "nuke:mese_tnt" or nname == "nuke:hardcore_iron_tnt" or nname == "nuke:hardcore_mese_tnt" or nname == "nuke:pink_tnt" or nname == "nuke:blue_tnt" or nname == "nuke:brown_tnt" or nname == "nuke:purple_tnt" or nname == "nuke:red_tnt" or nname == "nuke:black_tnt" or nname == "nuke:green_tnt" or nname == "nuke:teal_tnt" or nname == "nuke:dark_green_tnt" or nname == "nuke:orange_tnt" or nname == "nuke:light_blue_tnt" then
        local e = spawn_tnt(np, nname)
		e:setvelocity({x=(np.x - tnt_np.x)*3+(tntr / 4), y=(np.y - tnt_np.y)*3+(tntr / 3), z=(np.z - tnt_np.z)*3+(tntr / 4)})
    end
end

--New argument passed to do_tnt_physics (damage) - Jonathan 5/15/2013
function do_tnt_physics(tnt_np,tntr,damage)
    local objs = minetest.env:get_objects_inside_radius(tnt_np, tntr)
    for k, obj in pairs(objs) do
        local oname = obj:get_entity_name()
        local v = obj:getvelocity()
        local p = obj:getpos()
		--Added to if condition  - Jonathan 5/16/2013
        if oname == "nuke:iron_tnt" or oname == "nuke:mese_tnt" or oname == "nuke:hardcore_iron_tnt" or oname == "nuke:hardcore_mese_tnt" or oname == "nuke:pink_tnt" or oname == "nuke:blue_tnt" or oname == "nuke:brown_tnt" or oname == "nuke:purple_tnt" or oname == "nuke:red_tnt" or oname == "nuke:black_tnt" or oname == "nuke:green_tnt" or oname == "nuke:teal_tnt" or oname == "nuke:dark_green_tnt" or oname == "nuke:orange_tnt" or oname == "nuke:light_blue_tnt" then
            obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 2) + v.x, y=(p.y - tnt_np.y) + tntr + v.y, z=(p.z - tnt_np.z) + (tntr / 2) + v.z})
        else
            if v ~= nil then
                obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 4) + v.x, y=(p.y - tnt_np.y) + (tntr / 2) + v.y, z=(p.z - tnt_np.z) + (tntr / 4) + v.z})
            else
                if obj:get_player_name() ~= nil then
					--Now subtract "damage" from hp instead of 1 - Jonathan 5/15/2013
                    obj:set_hp(obj:get_hp() - damage)
                end
            end
        end
    end
end

-- Iron TNT

minetest.register_craft({
	output = 'nuke:iron_tnt 4',
	recipe = {
		{'','default:wood',''},
		{'default:steel_ingot','default:coal_lump','default:steel_ingot'},
		{'','default:wood',''}
	}
})
minetest.register_node("nuke:iron_tnt", {
	tiles = {"nuke_iron_tnt_top.png", "nuke_iron_tnt_bottom.png",
			"nuke_iron_tnt_side.png", "nuke_iron_tnt_side.png",
			"nuke_iron_tnt_side.png", "nuke_iron_tnt_side.png"},
	inventory_image = minetest.inventorycube("nuke_iron_tnt_top.png",
			"nuke_iron_tnt_side.png", "nuke_iron_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Iron TNT",
	--Added on_punch - Jonathan 5/29/2013
	on_punch = function(pos, node, puncher)
		minetest.env:remove_node(pos)
		spawn_tnt(pos, "nuke:iron_tnt")
	end,
})

--Commented out on_punchnode - Jonathan 5/29/2013
--[[
minetest.register_on_punchnode(function(p, node)
	if node.name == "nuke:iron_tnt" then
		minetest.env:remove_node(p)
		spawn_tnt(p, "nuke:iron_tnt")
		nodeupdate(p)
	end
end)
]]

local IRON_TNT_RANGE = 6
local IRON_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"nuke_iron_tnt_top.png", "nuke_iron_tnt_bottom.png",
			"nuke_iron_tnt_side.png", "nuke_iron_tnt_side.png",
			"nuke_iron_tnt_side.png", "nuke_iron_tnt_side.png"},
	-- Initial value for our timer
	--changed timer from 0 to 4 - Jonathan 5/21/2013
	timer = 4,
	-- Number of punches required to defuse
	--changed health value from 1 to 200 - Jonathan 5/15/2013
	health = 200,

	blinktimer = 0,
	blinkstatus = true,
}

function IRON_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function IRON_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 10 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)

		--Moved some of the code to IRON_BOOM - Jonathan 5/16/2013
		IRON_BOOM(pos)
		self.object:remove()
	end
end

function IRON_BOOM(pos)
	--Added env variable. Supposed to be a faster way to reference functions in env. - Jonathan 5/29/2013
	local env = minetest.env
	--Added new argument to do_tnt_physics (damage) - Jonathan 5/15/2013
	do_tnt_physics(pos, IRON_TNT_RANGE, 6)
	minetest.sound_play("nuke_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})

--Commented Out - Jonathan 5/15/2013
--[[
        if minetest.env:get_node(pos).name == "default:water_source" or minetest.env:get_node(pos).name == "default:water_flowing" then
            -- Cancel the Explosion
            self.object:remove()
            return
        end
]]--
	for x=-IRON_TNT_RANGE,IRON_TNT_RANGE do
	for y=-IRON_TNT_RANGE,IRON_TNT_RANGE do
	for z=-IRON_TNT_RANGE,IRON_TNT_RANGE do
		if x*x+y*y+z*z <= IRON_TNT_RANGE * IRON_TNT_RANGE + IRON_TNT_RANGE then
			local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			--Removed "minetest." - Jonathan 5/29/2013
			local n = env:get_node(np)
			--modified if condition - Jonathan 5/21/2013
			if n.name ~= "air" and n.name ~= "default:obsidian" then
				--Removed "minetest." - Jonathan 5/29/2013
				env:remove_node(np)
			end
			activate_if_tnt(n.name, np, pos, IRON_TNT_RANGE)
		end
	end
	end
	end
end

function IRON_TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "nuke:iron_tnt")
	end
end

minetest.register_entity("nuke:iron_tnt", IRON_TNT)




-- Mese TNT
minetest.register_craft({
	output = 'nuke:mese_tnt 4',
	recipe = {
		{'','default:wood',''},
		{'default:mese_crystal','default:coal_lump','default:mese_crystal'},
		{'','default:wood',''}
	}
})
minetest.register_node("nuke:mese_tnt", {
	tiles = {"nuke_mese_tnt_top.png", "nuke_mese_tnt_bottom.png",
			"nuke_mese_tnt_side.png", "nuke_mese_tnt_side.png",
			"nuke_mese_tnt_side.png", "nuke_mese_tnt_side.png"},
	inventory_image = minetest.inventorycube("nuke_mese_tnt_top.png",
			"nuke_mese_tnt_side.png", "nuke_mese_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Mese TNT",
	--Added on_punch - Jonathan 5/29/2013
	on_punch = function(pos, node, puncher)
		minetest.env:remove_node(pos)
		spawn_tnt(pos, "nuke:mese_tnt")
	end,
})

--Commented out on_punchnode - Jonathan 5/29/2013
--[[
minetest.register_on_punchnode(function(p, node)
	if node.name == "nuke:mese_tnt" then
		minetest.env:remove_node(p)
		spawn_tnt(p, "nuke:mese_tnt")
		nodeupdate(p)
	end
end)
]]

--changed MESE_TNT_RANGE from 12 to 4 - Jonathan 5/17/2013
local MESE_TNT_RANGE = 4
local MESE_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"nuke_mese_tnt_top.png", "nuke_mese_tnt_bottom.png",
			"nuke_mese_tnt_side.png", "nuke_mese_tnt_side.png",
			"nuke_mese_tnt_side.png", "nuke_mese_tnt_side.png"},
	-- Initial value for our timer
	--changed timer from 0 to 4 - Jonathan 5/21/2013
	timer = 4,
	-- Number of punches required to defuse
	--changed health value from 1 to 200 - Jonathan 5/15/2013
	health = 200,
	blinktimer = 0,
	blinkstatus = true,
}

function MESE_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function MESE_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 10 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)

		--Moved some of the code to MESE_BOOM function - Jonathan 5/16/2013
		MESE_BOOM(pos)
		self.object:remove()
	end
end

function MESE_BOOM(pos)
	--Added env variable. Supposed to be a faster way to reference functions in env. - Jonathan 5/29/2013
	local env = minetest.env
	--Added new argument to do_tnt_physics (demage) - Jonathan 5/15/2013
	do_tnt_physics(pos, MESE_TNT_RANGE, 6)
	minetest.sound_play("nuke_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})

--Commented Out - Jonathan 5/15/2013
--[[
        if minetest.env:get_node(pos).name == "default:water_source" or minetest.env:get_node(pos).name == "default:water_flowing" then
            -- Cancel the Explosion
            self.object:remove()
            return
        end
]]--

	for x=-MESE_TNT_RANGE,MESE_TNT_RANGE do
	for y=-MESE_TNT_RANGE,MESE_TNT_RANGE do
	for z=-MESE_TNT_RANGE,MESE_TNT_RANGE do
		if x*x+y*y+z*z <= MESE_TNT_RANGE * MESE_TNT_RANGE + MESE_TNT_RANGE then
			local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			--removed "minetest." - Jonathan 5/29/2013
			local n = env:get_node(np)
			--Modified if condition - Jonathan 5/21/2013
			if n.name ~= "air" and n.name ~= "default:obsidian" then
				--removed "minetest." - Jonathan 5/29/2013
				env:remove_node(np)
			end
			activate_if_tnt(n.name, np, pos, MESE_TNT_RANGE)
		end
	end
	end
	end
end

function MESE_TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "nuke:mese_tnt")
	end
end

minetest.register_entity("nuke:mese_tnt", MESE_TNT)




-- Hardcore Iron TNT
minetest.register_craft({
	output = 'nuke:hardcore_iron_tnt',
	recipe = {
		{'','default:coal_lump',''},
		{'default:coal_lump','nuke:iron_tnt','default:coal_lump'},
		{'','default:coal_lump',''}
	}
})
minetest.register_node("nuke:hardcore_iron_tnt", {
	tiles = {"nuke_iron_tnt_top.png", "nuke_iron_tnt_bottom.png",
			"nuke_hardcore_iron_tnt_side.png", "nuke_hardcore_iron_tnt_side.png",
			"nuke_hardcore_iron_tnt_side.png", "nuke_hardcore_iron_tnt_side.png"},
	inventory_image = minetest.inventorycube("nuke_iron_tnt_top.png",
			"nuke_hardcore_iron_tnt_side.png", "nuke_hardcore_iron_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Hardcore Iron TNT",
})

minetest.register_on_punchnode(function(p, node)
	if node.name == "nuke:hardcore_iron_tnt" then
		minetest.env:remove_node(p)
		spawn_tnt(p, "nuke:hardcore_iron_tnt")
		nodeupdate(p)
	end
end)

local HARDCORE_IRON_TNT_RANGE = 4
local HARDCORE_IRON_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"nuke_iron_tnt_top.png", "nuke_iron_tnt_bottom.png",
			"nuke_hardcore_iron_tnt_side.png", "nuke_hardcore_iron_tnt_side.png",
			"nuke_hardcore_iron_tnt_side.png", "nuke_hardcore_iron_tnt_side.png"},
	-- Initial value for our timer
	timer = 0,
	-- Number of punches required to defuse
	health = 1,
	blinktimer = 0,
	blinkstatus = true,
}

function HARDCORE_IRON_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function HARDCORE_IRON_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 10 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)
        minetest.sound_play("nuke_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})
        for x=-HARDCORE_IRON_TNT_RANGE,HARDCORE_IRON_TNT_RANGE do
        for z=-HARDCORE_IRON_TNT_RANGE,HARDCORE_IRON_TNT_RANGE do
            if x*x+z*z <= HARDCORE_IRON_TNT_RANGE * HARDCORE_IRON_TNT_RANGE + HARDCORE_IRON_TNT_RANGE then
                local np={x=pos.x+x,y=pos.y,z=pos.z+z}
                minetest.env:add_entity(np, "nuke:iron_tnt")
            end
        end
        end
		self.object:remove()
	end
end

function HARDCORE_IRON_TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "nuke:hardcore_iron_tnt 1")
	end
end

minetest.register_entity("nuke:hardcore_iron_tnt", HARDCORE_IRON_TNT)

-- Hardcore Mese TNT

minetest.register_craft({
	output = 'nuke:hardcore_mese_tnt',
	recipe = {
		{'','default:coal_lump',''},
		{'default:coal_lump','nuke:mese_tnt','default:coal_lump'},
		{'','default:coal_lump',''}
	}
})
minetest.register_node("nuke:hardcore_mese_tnt", {
	tiles = {"nuke_mese_tnt_top.png", "nuke_mese_tnt_bottom.png",
			"nuke_hardcore_mese_tnt_side.png", "nuke_hardcore_mese_tnt_side.png",
			"nuke_hardcore_mese_tnt_side.png", "nuke_hardcore_mese_tnt_side.png"},
	inventory_image = minetest.inventorycube("nuke_mese_tnt_top.png",
			"nuke_hardcore_mese_tnt_side.png", "nuke_hardcore_mese_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Hardcore Mese TNT",
})

minetest.register_on_punchnode(function(p, node)
	if node.name == "nuke:hardcore_mese_tnt" then
		minetest.env:remove_node(p)
		spawn_tnt(p, "nuke:hardcore_mese_tnt")
		nodeupdate(p)
	end
end)

local HARDCORE_MESE_TNT_RANGE = 4
local HARDCORE_MESE_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"nuke_mese_tnt_top.png", "nuke_mese_tnt_bottom.png",
			"nuke_hardcore_mese_tnt_side.png", "nuke_hardcore_mese_tnt_side.png",
			"nuke_hardcore_mese_tnt_side.png", "nuke_hardcore_mese_tnt_side.png"},
	-- Initial value for our timer
	timer = 0,
	-- Number of punches required to defuse
	health = 1,
	blinktimer = 0,
	blinkstatus = true,
}

function HARDCORE_MESE_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function HARDCORE_MESE_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 10 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)
        minetest.sound_play("nuke_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})
        for x=-HARDCORE_MESE_TNT_RANGE,HARDCORE_MESE_TNT_RANGE do
        for z=-HARDCORE_MESE_TNT_RANGE,HARDCORE_MESE_TNT_RANGE do
            if x*x+z*z <= HARDCORE_MESE_TNT_RANGE * HARDCORE_MESE_TNT_RANGE + HARDCORE_MESE_TNT_RANGE then
                local np={x=pos.x+x,y=pos.y,z=pos.z+z}
                minetest.env:add_entity(np, "nuke:mese_tnt")
            end
        end
        end
		self.object:remove()
	end
end

function HARDCORE_MESE_TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "nuke:hardcore_mese_tnt 1")
	end
end

minetest.register_entity("nuke:hardcore_mese_tnt", HARDCORE_MESE_TNT)




--Added green tnt (Copied iron tnt code and modified) - Jonathan 5/15/2013
--Green TNT
minetest.register_node("nuke:green_tnt", {
	tiles = {"green_tnt_top.png", "green_tnt_bottom.png",
			"green_tnt_side.png", "green_tnt_side.png",
			"green_tnt_side.png", "green_tnt_side.png"},
	inventory_image = minetest.inventorycube("green_tnt_top.png",
			"green_tnt_side.png", "green_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Green TNT",
	on_punch = function(pos, node, puncher)
		minetest.env:remove_node(pos)
		spawn_tnt(pos, "nuke:green_tnt")
	end,
})

local GREEN_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"green_tnt_top.png", "green_tnt_bottom.png",
			"green_tnt_side.png", "green_tnt_side.png",
			"green_tnt_side.png", "green_tnt_side.png"},
	-- Initial value for our timer
	timer = 4,
	-- Number of punches required to defuse
	health = 200,

	blinktimer = 0,
	blinkstatus = true,
}

function GREEN_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function GREEN_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 10 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)

		GREEN_BOOM(pos)
		self.object:remove()
	end
end

function GREEN_BOOM(pos)
	local env = minetest.env
	local GREEN_TNT_RANGE = math.random(3,9)
	do_tnt_physics(pos, GREEN_TNT_RANGE, 2)
	minetest.sound_play("nuke_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})

	for x=-GREEN_TNT_RANGE,GREEN_TNT_RANGE do
	for y=-GREEN_TNT_RANGE,GREEN_TNT_RANGE do
	for z=-GREEN_TNT_RANGE,GREEN_TNT_RANGE do
		if x*x+y*y+z*z <= GREEN_TNT_RANGE * GREEN_TNT_RANGE + GREEN_TNT_RANGE then
			local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			local n = env:get_node(np)
			if n.name == "air" then
				env:set_node(np, {name = "default:dirt"})
			end
			--activate_if_tnt(n.name, np, pos, GREEN_TNT_RANGE)
		end
	end
	end
	end
end

function GREEN_TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "nuke:green_tnt")
	end
end

minetest.register_entity("nuke:green_tnt", GREEN_TNT)




--Added pink tnt (Copied mese tnt code and modified) - Jonathan 5/16/2013
--Pink TNT
minetest.register_node("nuke:pink_tnt", {
	tiles = {"pink_tnt_top.png", "pink_tnt_bottom.png",
			"pink_tnt_side.png", "pink_tnt_side.png",
			"pink_tnt_side.png", "pink_tnt_side.png"},
	inventory_image = minetest.inventorycube("pink_tnt_top.png",
			"pink_tnt_side.png", "pink_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Pink TNT",
	on_punch = function(pos, node, puncher)
		minetest.env:remove_node(pos)
		spawn_tnt(pos, "nuke:pink_tnt")
	end,
})

local PINK_TNT_RANGE = 12
local PINK_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"pink_tnt_top.png", "pink_tnt_bottom.png",
			"pink_tnt_side.png", "pink_tnt_side.png",
			"pink_tnt_side.png", "pink_tnt_side.png"},
	-- Initial value for our timer
	timer = 4,
	-- Number of punches required to defuse
	health = 200,
	blinktimer = 0,
	blinkstatus = true,
}

function PINK_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function PINK_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 10 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)

		PINK_BOOM(pos)
		self.object:remove()
	end
end

function PINK_BOOM(pos)
	local env = minetest.env
	do_tnt_physics(pos, PINK_TNT_RANGE, 6)
	minetest.sound_play("nuke_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})

	for x=-PINK_TNT_RANGE,PINK_TNT_RANGE do
	for y=-PINK_TNT_RANGE,PINK_TNT_RANGE do
	for z=-PINK_TNT_RANGE,PINK_TNT_RANGE do
		if x*x+y*y+z*z <= PINK_TNT_RANGE * PINK_TNT_RANGE + PINK_TNT_RANGE then
			local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			local n = env:get_node(np)
			if n.name ~= "air" and n.name ~= "default:obsidian" then
				env:remove_node(np)
			end
			activate_if_tnt(n.name, np, pos, PINK_TNT_RANGE)
		end
	end
	end
	end
end

function PINK_TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "nuke:pink_tnt")
	end
end

minetest.register_entity("nuke:pink_tnt", PINK_TNT)




--Added dark_green tnt (Copied mese tnt code and modified) - Jonathan 5/17/2013
--Dark Green TNT
minetest.register_node("nuke:dark_green_tnt", {
	tiles = {"dark_green_tnt_top.png", "dark_green_tnt_bottom.png",
			"dark_green_tnt_side.png", "dark_green_tnt_side.png",
			"dark_green_tnt_side.png", "dark_green_tnt_side.png"},
	inventory_image = minetest.inventorycube("dark_green_tnt_top.png",
			"dark_green_tnt_side.png", "dark_green_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Dark Green Package",
	on_punch = function(pos, node, puncher)
		minetest.env:remove_node(pos)
		spawn_tnt(pos, "nuke:dark_green_tnt")
	end,
})

local DARK_GREEN_TNT_RANGE = 9
local DARK_GREEN_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"dark_green_tnt_top.png", "dark_green_tnt_bottom.png",
			"dark_green_tnt_side.png", "dark_green_tnt_side.png",
			"dark_green_tnt_side.png", "dark_green_tnt_side.png"},
	-- Initial value for our timer
	timer = 4,
	-- Number of punches required to defuse
	health = 200,
	blinktimer = 0,
	blinkstatus = true,
}

function DARK_GREEN_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function DARK_GREEN_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 10 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)

		DARK_GREEN_BOOM(pos)
		self.object:remove()
	end
end

function DARK_GREEN_BOOM(pos)
	local env = minetest.env
	--Added new argument to do_tnt_physics (damage) - Jonathan 5/15/2013
	do_tnt_physics(pos, DARK_GREEN_TNT_RANGE, 0)
	minetest.sound_play("nuke_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})

	for x=-DARK_GREEN_TNT_RANGE,DARK_GREEN_TNT_RANGE do
	for y=-DARK_GREEN_TNT_RANGE,DARK_GREEN_TNT_RANGE do
	for z=-DARK_GREEN_TNT_RANGE,DARK_GREEN_TNT_RANGE do
		if x*x+y*y+z*z <= DARK_GREEN_TNT_RANGE * DARK_GREEN_TNT_RANGE + DARK_GREEN_TNT_RANGE then
			local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			local n = env:get_node(np)
			if n.name ~= "default:obsidian" then
				if math.abs(x) == DARK_GREEN_TNT_RANGE - 3 or math.abs(y) == DARK_GREEN_TNT_RANGE - 2 or math.abs(z) == DARK_GREEN_TNT_RANGE - 3 then
					env:set_node(np, {name = "default:stone"})
				elseif math.abs(np.x - pos.x) == 1  and math.abs(np.z - pos.z) == 1 and np.y == pos.y then
					env:set_node(np, {name = "nuke:mese_tnt"})
					env:punch_node(np)
				elseif math.abs(np.x - pos.x) == 3  and math.abs(np.z - pos.z) == 3 and np.y == pos.y then
					env:set_node(np, {name = "nuke:mese_tnt"})
					env:punch_node(np)
				else
					--if n.name ~= "air" then
					--	minetest.env:remove_node(np)
					--end
				end
			end
			--activate_if_tnt(n.name, np, pos, DARK_GREEN_TNT_RANGE)
		end
	end
	end
	end
end

function DARK_GREEN_TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "nuke:dark_green_tnt")
	end
end

minetest.register_entity("nuke:dark_green_tnt", DARK_GREEN_TNT)




--Added red tnt (Copied mese tnt code and modified) - Jonathan 5/17/2013
--Red TNT
minetest.register_node("nuke:red_tnt", {
	tiles = {"red_tnt_top.png", "red_tnt_bottom.png",
			"red_tnt_side.png", "red_tnt_side.png",
			"red_tnt_side.png", "red_tnt_side.png"},
	inventory_image = minetest.inventorycube("red_tnt_top.png",
			"red_tnt_side.png", "red_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Red TNT",
	on_punch = function(pos, node, puncher)
		minetest.env:remove_node(pos)
		spawn_tnt(pos, "nuke:red_tnt")
	end,
})

local RED_TNT_RANGE = 2
local RED_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"red_tnt_top.png", "red_tnt_bottom.png",
			"red_tnt_side.png", "red_tnt_side.png",
			"red_tnt_side.png", "red_tnt_side.png"},
	-- Initial value for our timer
	timer = 4,
	-- Number of punches required to defuse
	health = 200,
	blinktimer = 0,
	blinkstatus = true,
}

function RED_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function RED_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 10 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)

		RED_BOOM(pos)
		self.object:remove()
	end
end

function RED_BOOM(pos)
	local env = minetest.env
	do_tnt_physics(pos, RED_TNT_RANGE, 6)
	minetest.sound_play("nuke_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})

	for x=-RED_TNT_RANGE,RED_TNT_RANGE do
	for y=-RED_TNT_RANGE,RED_TNT_RANGE do
	for z=-RED_TNT_RANGE,RED_TNT_RANGE do
		if x*x+y*y+z*z <= RED_TNT_RANGE * RED_TNT_RANGE + RED_TNT_RANGE then
			local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			local n = env:get_node(np)
			local c = math.random(0,100)
			if n.name ~= "air" and n.name ~= "default:obsidian" then
				if c <= 1 then
					env:set_node(np, {name = "fire:basic_flame"})
				else
					env:remove_node(np)
				end
			end
			activate_if_tnt(n.name, np, pos, RED_TNT_RANGE)
		end
	end
	end
	end
end

function RED_TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "nuke:red_tnt")
	end
end

minetest.register_entity("nuke:red_tnt", RED_TNT)




--Added black tnt (Copied mese tnt code and modified) - Jonathan 5/17/2013
--Black TNT
minetest.register_node("nuke:black_tnt", {
	tiles = {"black_tnt_top.png", "black_tnt_bottom.png",
			"black_tnt_side.png", "black_tnt_side.png",
			"black_tnt_side.png", "black_tnt_side.png"},
	inventory_image = minetest.inventorycube("black_tnt_top.png",
			"black_tnt_side.png", "black_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Black TNT",
	on_punch = function(pos, node, puncher)
		minetest.env:remove_node(pos)
		spawn_tnt(pos, "nuke:black_tnt")
	end,
})

local BLACK_TNT_RANGE = 15
local BLACK_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"black_tnt_top.png", "black_tnt_bottom.png",
			"black_tnt_side.png", "black_tnt_side.png",
			"black_tnt_side.png", "black_tnt_side.png"},
	-- Initial value for our timer
	timer = 3,
	-- Number of punches required to defuse
	health = 200,
	blinktimer = 0,
	blinkstatus = true,
}

function BLACK_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function BLACK_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 10 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)

		BLACK_BOOM(pos)
		self.object:remove()
	end
end

function BLACK_BOOM(pos)
	local env = minetest.env
	do_tnt_physics(pos, BLACK_TNT_RANGE, 0)
	minetest.sound_play("nuke_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})

	for x=-BLACK_TNT_RANGE,BLACK_TNT_RANGE, 2 do
	for y=-BLACK_TNT_RANGE,BLACK_TNT_RANGE do
	for z=-BLACK_TNT_RANGE,BLACK_TNT_RANGE, 2 do
		if x*x+y*y+z*z <= BLACK_TNT_RANGE * BLACK_TNT_RANGE + BLACK_TNT_RANGE then
			local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			local n = env:get_node(np)
			if n.name ~= "air" and n.name ~= "default:obsidian" then
				env:remove_node(np)
			end
			activate_if_tnt(n.name, np, pos, BLACK_TNT_RANGE)
		end
	end
	end
	end
end

function BLACK_TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "nuke:black_tnt")
	end
end

minetest.register_entity("nuke:black_tnt", BLACK_TNT)




--Added teal tnt (Copied mese tnt code and modified) - Jonathan 5/16/2013
--Teal TNT
minetest.register_node("nuke:teal_tnt", {
	tiles = {"teal_tnt_top.png", "teal_tnt_bottom.png",
			"teal_tnt_side.png", "teal_tnt_side.png",
			"teal_tnt_side.png", "teal_tnt_side.png"},
	inventory_image = minetest.inventorycube("teal_tnt_top.png",
			"teal_tnt_side.png", "teal_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Experimental TNT",
	on_punch = function(pos, node, puncher)
		minetest.env:remove_node(pos)
		spawn_tnt(pos, "nuke:teal_tnt")
	end,
})

local TEAL_TNT_RANGE = 4
local TEAL_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"teal_tnt_top.png", "teal_tnt_bottom.png",
			"teal_tnt_side.png", "teal_tnt_side.png",
			"teal_tnt_side.png", "teal_tnt_side.png"},
	-- Initial value for our timer
	timer = 4,
	-- Number of punches required to defuse
	health = 200,
	blinktimer = 0,
	blinkstatus = true,
}

function TEAL_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function TEAL_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 10 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)

		TEAL_BOOM(pos)
		self.object:remove()
	end
end

function TEAL_BOOM(pos)
	local env = minetest.env
	do_tnt_physics(pos, TEAL_TNT_RANGE, 6)
	minetest.sound_play("nuke_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})

	for x=-TEAL_TNT_RANGE,TEAL_TNT_RANGE do
	for y=-TEAL_TNT_RANGE,TEAL_TNT_RANGE do
	for z=-TEAL_TNT_RANGE,TEAL_TNT_RANGE do
		if x*x+y*y+z*z <= TEAL_TNT_RANGE * TEAL_TNT_RANGE + TEAL_TNT_RANGE then
			local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			local n = env:get_node(np)
			if n.name ~= "default:obsidian" then
				env:set_node(np, {name = "default:lava_source"})
			end
			--activate_if_tnt(n.name, np, pos, TEAL_TNT_RANGE)
		end
	end
	end
	end
end

function TEAL_TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "nuke:teal_tnt")
	end
end

minetest.register_entity("nuke:teal_tnt", TEAL_TNT)




--Added blue tnt (Copied mese tnt code and modified) - Jonathan 5/16/2013
--Blue TNT
minetest.register_node("nuke:blue_tnt", {
	tiles = {"blue_tnt_top.png", "blue_tnt_bottom.png",
			"blue_tnt_side.png", "blue_tnt_side.png",
			"blue_tnt_side.png", "blue_tnt_side.png"},
	inventory_image = minetest.inventorycube("blue_tnt_top.png",
			"blue_tnt_side.png", "blue_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Blue TNT",
	on_punch = function(pos, node, puncher)
		minetest.env:remove_node(pos)
		spawn_tnt(pos, "nuke:blue_tnt")
	end,
})

local BLUE_TNT_RANGE = 15
local BLUE_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"blue_tnt_top.png", "blue_tnt_bottom.png",
			"blue_tnt_side.png", "blue_tnt_side.png",
			"blue_tnt_side.png", "blue_tnt_side.png"},
	-- Initial value for our timer
	timer = 4,
	-- Number of punches required to defuse
	health = 200,
	blinktimer = 0,
	blinkstatus = true,
}

function BLUE_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function BLUE_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 10 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)

		BLUE_BOOM(pos)
		self.object:remove()
	end
end

function BLUE_BOOM(pos)
	local env = minetest.env
	blue_tnt_physics(pos, BLUE_TNT_RANGE, 6)
	minetest.sound_play("nuke_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})

	for x=-BLUE_TNT_RANGE,BLUE_TNT_RANGE do
	for y=-1,1 do
	for z=-BLUE_TNT_RANGE,BLUE_TNT_RANGE do
		if x*x+y*y+z*z <= BLUE_TNT_RANGE * BLUE_TNT_RANGE + BLUE_TNT_RANGE then
			local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			local n = env:get_node(np)
			if n.name ~= "air" and n.name ~= "default:obsidian" then
				env:remove_node(np)
			end
			activate_if_tnt(n.name, np, pos, BLUE_TNT_RANGE)
		end
	end
	end
	end
end

function BLUE_TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "nuke:blue_tnt")
	end
end

--Copied do_tnt_physics and modified - Jonathan 5/16/2013
function blue_tnt_physics(tnt_np,tntr,damage)
    local objs = minetest.env:get_objects_inside_radius(tnt_np, tntr)
    for k, obj in pairs(objs) do
        local oname = obj:get_entity_name()
        local v = obj:getvelocity()
        local p = obj:getpos()

		if math.abs(p.y - tnt_np.y) < 1 then
			if oname == "nuke:iron_tnt" or oname == "nuke:mese_tnt" or oname == "nuke:hardcore_iron_tnt" or oname == "nuke:hardcore_mese_tnt" or oname == "nuke:pink_tnt" or oname == "nuke:blue_tnt" or oname == "nuke:brown_tnt" or oname == "nuke:purple_tnt" or oname == "nuke:red_tnt" or oname == "nuke:black_tnt" or oname == "nuke:green_tnt" or oname == "nuke:teal_tnt" or oname == "nuke:dark_green_tnt" or oname == "nuke:orange_tnt" then
				obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 2) + v.x, y=(p.y - tnt_np.y) + tntr + v.y, z=(p.z - tnt_np.z) + (tntr / 2) + v.z})
			else
				if v ~= nil then
					obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 4) + v.x, y=(p.y - tnt_np.y) + (tntr / 2) + v.y, z=(p.z - tnt_np.z) + (tntr / 4) + v.z})
				else
					if obj:get_player_name() ~= nil then
						obj:set_hp(obj:get_hp() - damage)
					end
				end
			end
		end
    end
end

minetest.register_entity("nuke:blue_tnt", BLUE_TNT)




--Added brown tnt (Copied mese tnt code and modified) - Jonathan 5/16/2013
--Brown TNT
minetest.register_node("nuke:brown_tnt", {
	tiles = {"brown_tnt_top.png", "brown_tnt_bottom.png",
			"brown_tnt_side.png", "brown_tnt_side.png",
			"brown_tnt_side.png", "brown_tnt_side.png"},
	inventory_image = minetest.inventorycube("brown_tnt_top.png",
			"brown_tnt_side.png", "brown_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Brown TNT",
	on_punch = function(pos, node, puncher)
		minetest.env:remove_node(pos)
		spawn_tnt(pos, "nuke:brown_tnt")
	end,
})

local BROWN_TNT_RANGE = 15
local BROWN_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"brown_tnt_top.png", "brown_tnt_bottom.png",
			"brown_tnt_side.png", "brown_tnt_side.png",
			"brown_tnt_side.png", "brown_tnt_side.png"},
	-- Initial value for our timer
	timer = 4,
	-- Number of punches required to defuse
	health = 200,
	blinktimer = 0,
	blinkstatus = true,
}

function BROWN_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function BROWN_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 10 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)

        BROWN_BOOM(pos)
		self.object:remove()
	end
end

function BROWN_BOOM(pos)
	local env = minetest.env
	--Added new argument to do_tnt_physics (damage) - Jonathan 5/15/2013
	brown_tnt_physics(pos, BROWN_TNT_RANGE, 6)
	minetest.sound_play("nuke_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})

	for x=-1,1 do
	for y=-BROWN_TNT_RANGE,BROWN_TNT_RANGE do
	for z=-1,1 do
		if x*x+y*y+z*z <= BROWN_TNT_RANGE * BROWN_TNT_RANGE + BROWN_TNT_RANGE then
			local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			local n = env:get_node(np)
			if n.name ~= "air" and n.name ~= "default:obsidian" then
				env:remove_node(np)
			end
			activate_if_tnt(n.name, np, pos, BROWN_TNT_RANGE)
		end
	end
	end
	end
end

function BROWN_TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "nuke:brown_tnt")
	end
end

--Copied do_tnt_physics and modified - Jonathan 5/16/2013
function brown_tnt_physics(tnt_np,tntr,damage)
    local objs = minetest.env:get_objects_inside_radius(tnt_np, tntr)
    for k, obj in pairs(objs) do
        local oname = obj:get_entity_name()
        local v = obj:getvelocity()
        local p = obj:getpos()

		if math.abs(p.x - tnt_np.x) < 1 and math.abs(p.z - tnt_np.z) < 1 then
			if oname == "nuke:iron_tnt" or oname == "nuke:mese_tnt" or oname == "nuke:hardcore_iron_tnt" or oname == "nuke:hardcore_mese_tnt" or oname == "nuke:pink_tnt" or oname == "nuke:blue_tnt" or oname == "nuke:brown_tnt" or oname == "nuke:purple_tnt" or oname == "nuke:red_tnt" or oname == "nuke:black_tnt" or oname == "nuke:green_tnt" or oname == "nuke:teal_tnt" or oname == "nuke:dark_green_tnt" or oname == "nuke:orange_tnt" then
				obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 2) + v.x, y=(p.y - tnt_np.y) + tntr + v.y, z=(p.z - tnt_np.z) + (tntr / 2) + v.z})
			else
				if v ~= nil then
					obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 4) + v.x, y=(p.y - tnt_np.y) + (tntr / 2) + v.y, z=(p.z - tnt_np.z) + (tntr / 4) + v.z})
				else
					if obj:get_player_name() ~= nil then
						obj:set_hp(obj:get_hp() - damage)
					end
				end
			end
		end
    end
end

minetest.register_entity("nuke:brown_tnt", BROWN_TNT)




--Added orange tnt (Copied mese tnt code and modified) - Jonathan 5/29/2013
--Orange TNT
minetest.register_node("nuke:orange_tnt", {
	tiles = {"orange_tnt_top.png", "orange_tnt_bottom.png",
			"orange_tnt_side.png", "orange_tnt_side.png",
			"orange_tnt_side.png", "orange_tnt_side.png"},
	inventory_image = minetest.inventorycube("orange_tnt_top.png",
			"orange_tnt_side.png", "orange_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "Orange TNT",
	on_punch = function(pos, node, puncher)
		minetest.env:remove_node(pos)
		spawn_tnt(pos, "nuke:orange_tnt")
	end,
})

local ORANGE_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"orange_tnt_top.png", "orange_tnt_bottom.png",
			"orange_tnt_side.png", "orange_tnt_side.png",
			"orange_tnt_side.png", "orange_tnt_side.png"},
	-- Initial value for our timer
	timer = 4,
	-- Number of punches required to defuse
	health = 200,
	blinktimer = 0,
	blinkstatus = true,
}

function ORANGE_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function ORANGE_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 10 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)

		ORANGE_BOOM(pos)
		self.object:remove()
	end
end

function ORANGE_BOOM(pos)
	local env = minetest.env
	local ORANGE_TNT_RANGE = math.random(5,10)
	local ORANGE_TNT_HEIGHT = math.random(5,20)
	local choice = math.random(0,300)
	if choice <= 100 then
		material = "default:cobble"
	elseif choice <= 200 then
		material = "default:brick"
	elseif choice <= 250 then
		material = "default:junglewood"
	else
		material = "default:steelblock"
	end

	minetest.sound_play("nuke_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})

	for y=-1,ORANGE_TNT_HEIGHT do
	for x=-ORANGE_TNT_RANGE,ORANGE_TNT_RANGE do
	for z=-ORANGE_TNT_RANGE,ORANGE_TNT_RANGE do
		local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
		local n = env:get_node(np)
		if n.name ~= "default:obsidian" then
			if x == 0 and z == 0 then
				if y == ORANGE_TNT_HEIGHT then
					env:set_node(np, {name = "default:water_source"})
				else
					env:remove_node(np)
				end
			elseif (x == ORANGE_TNT_RANGE and z == ORANGE_TNT_RANGE-1 and y == 0) or (x == ORANGE_TNT_RANGE and z == ORANGE_TNT_RANGE-1 and y == 1) then
				env:remove_node(np)
			else
				if (y+1)%4 == 0 or y == -1 then
					env:set_node(np, {name = material})
				elseif (y-1)%4 == 0 and (math.abs(x) == ORANGE_TNT_RANGE or math.abs(z) == ORANGE_TNT_RANGE) then
					if math.abs(x) == ORANGE_TNT_RANGE and math.abs(z) == ORANGE_TNT_RANGE then
						env:set_node(np, {name = material})
					else
						env:set_node(np, {name = "default:glass"})
					end
				elseif math.abs(x) == ORANGE_TNT_RANGE or math.abs(z) == ORANGE_TNT_RANGE then
					env:set_node(np, {name = material})
				else
					env:remove_node(np)
				end
			end
		end
	end
	end
	end
end

function ORANGE_TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "nuke:orange_tnt")
	end
end

minetest.register_entity("nuke:orange_tnt", ORANGE_TNT)




--Added purple tnt (Copied mese tnt code and modified) - Jonathan 5/16/2013
--Purple TNT
minetest.register_node("nuke:purple_tnt", {
	tiles = {"purple_tnt_top.png", "purple_tnt_bottom.png",
			"purple_tnt_side.png", "purple_tnt_side.png",
			"purple_tnt_side.png", "purple_tnt_side.png"},
	inventory_image = minetest.inventorycube("purple_tnt_top.png",
			"purple_tnt_side.png", "purple_tnt_side.png"),
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	description = "???",
	on_punch = function(pos, node, puncher)
		minetest.env:remove_node(pos)
		spawn_tnt(pos, "nuke:purple_tnt")
	end,
})

local PURPLE_TNT_RANGE = 12
local PURPLE_TNT = {
	-- Static definition
	physical = true, -- Collides with things
	-- weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"purple_tnt_top.png", "purple_tnt_bottom.png",
			"purple_tnt_side.png", "purple_tnt_side.png",
			"purple_tnt_side.png", "purple_tnt_side.png"},
	-- Initial value for our timer
	timer = 4,
	-- Number of punches required to defuse
	health = 200,
	blinktimer = 0,
	blinkstatus = true,
}

function PURPLE_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function PURPLE_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>5 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>8 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 10 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)
		local decider = math.random(1,875)

		if decider <= 100 then
			BROWN_BOOM(pos)
		elseif decider <= 200 then
			BLUE_BOOM(pos)
		elseif decider <= 300 then
			PINK_BOOM(pos)
		elseif decider <= 400 then
			IRON_BOOM(pos)
		elseif decider <= 500 then
			MESE_BOOM(pos)
		elseif decider <= 600 then
			BLACK_BOOM(pos)
		elseif decider <= 700 then
			RED_BOOM(pos)
		elseif decider <= 800 then
			DARK_GREEN_BOOM(pos)
		elseif decider <= 825 then
			GREEN_BOOM(pos)
		elseif decider <= 850 then
			ORANGE_BOOM(pos)
		else
			TEAL_BOOM(pos)
		end
		self.object:remove()
	end
end

function PURPLE_TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "nuke:purple_tnt")
	end
end

minetest.register_entity("nuke:purple_tnt", PURPLE_TNT)




--Added light blue tnt (Copied mese tnt code and modified) - Jonathan 5/31/2013
--light blue TNT
minetest.register_node("nuke:light_blue_tnt", {
	tiles = {"light_blue_tnt_top.png", "light_blue_tnt_bottom.png",
			"light_blue_tnt_side.png", "light_blue_tnt_side.png",
			"light_blue_tnt_side.png", "light_blue_tnt_side.png"},
	inventory_image = minetest.inventorycube("light_blue_tnt_top.png",
			"light_blue_tnt_side.png", "light_blue_tnt_side.png"),
	dug_item = '',
	material = {
		diggability = "not",
	},
	description = "Light Blue TNT",
	on_punch = function(pos, node, puncher)
		minetest.env:remove_node(pos)
		spawn_tnt(pos, "nuke:light_blue_tnt")
	end,
})

local LIGHT_BLUE_TNT_RANGE = 3
local LIGHT_BLUE_TNT = {
	physical = true,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"light_blue_tnt_top.png", "light_blue_tnt_bottom.png",
			"light_blue_face_tnt_side.png", "light_blue_face_tnt_side.png",
			"light_blue_face_tnt_side.png", "light_blue_face_tnt_side.png"},
	type = "plane",
	timer = 0,
	boomtimer = 0.00,
	health = 200,
	blinktimer = 0,
	blinkstatus = true,
	automatic_rotate = true,
	crash_pos={},
	targetset = false,
	velocityset = false,
	tar_vel = {x=0,y=0,z=0},
	target = 0,
}

function LIGHT_BLUE_TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
	self.target = math.random(1,5)
end

function LIGHT_BLUE_TNT:on_step(dtime)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>15 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>18 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 20 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)

		LIGHT_BLUE_BOOM(pos)
		self.object:remove()
	end

--on_step code below copied from plane mod and modified - Jonathan 5/31/2013
	local pos = self.object:getpos()
	self.boomtimer = self.boomtimer + dtime

	if self.targetset == false then
		if pos ~= nil then
			local objects = minetest.env:get_objects_inside_radius(pos, 25)
				for _,obj in ipairs(objects) do
					if obj:is_player() then
							self.crash_pos = obj:getpos()
							--self.targetset = true
							break
						--else
							--self.object:remove()
					end
				end
		end
	end

	if self.targetset == false and self.velocityset == false then
		if self.crash_pos.x ~= nil then
			if self.target ~= nil then
				if self.target == 1 then
					self.crash_pos.x = self.crash_pos.x - 2
				elseif self.target == 2 then
					self.crash_pos.x = self.crash_pos.x + 2
				elseif self.target == 3 then
					self.crash_pos.z = self.crash_pos.z - 2
				elseif self.target == 4 then
					self.crash_pos.z = self.crash_pos.z + 2
				elseif self.target == 5 then
					self.crash_pos.y = self.crash_pos.y + 3
				end

				--Calculate x velocity.
				if (40000 + pos.x) - (40000 + self.crash_pos.x) >= 0.9 then
					self.tar_vel.x = -2.1
				elseif (40000 + pos.x) - (40000 + self.crash_pos.x) <= -0.9 then
					self.tar_vel.x = 2.1
				else
					self.tar_vel.x = 0
				end

				--Calculate y velocity.
				if (40000 + pos.y) - (40001 + self.crash_pos.y) >= 0.9 then
					self.tar_vel.y = -2.1
				elseif (40000 + pos.y) - (40001 + self.crash_pos.y) <= -0.9 then
					self.tar_vel.y = 2.1
				else
					self.tar_vel.y = 0
				end

				--Calculate z velocity.
				if (40000 + pos.z) - (40000 + self.crash_pos.z) >= 0.9 then
					self.tar_vel.z = -2.1
				elseif (40000 + pos.z) - (40000 + self.crash_pos.z) <= -0.9 then
					self.tar_vel.z = 2.1
				else
					self.tar_vel.z = 0
				end

				--local tar_vel = {x=self.crash_pos.x - pos.x,y=self.crash_pos.y+1 - pos.y,z=self.crash_pos.z - pos.z}
				self.object:setvelocity({x=self.tar_vel.x,y=self.tar_vel.y,z=self.tar_vel.z})
				--self.velocityset = true
			end
		end
	end
end

function LIGHT_BLUE_BOOM(pos)
	local env = minetest.env
	do_tnt_physics(pos, LIGHT_BLUE_TNT_RANGE, 2)
	minetest.sound_play("nuke_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})

	for x=-LIGHT_BLUE_TNT_RANGE,LIGHT_BLUE_TNT_RANGE do
	for y=-LIGHT_BLUE_TNT_RANGE,LIGHT_BLUE_TNT_RANGE do
	for z=-LIGHT_BLUE_TNT_RANGE,LIGHT_BLUE_TNT_RANGE do
		if x*x+y*y+z*z <= LIGHT_BLUE_TNT_RANGE * LIGHT_BLUE_TNT_RANGE + LIGHT_BLUE_TNT_RANGE then
			local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			local n = env:get_node(np)
			if n.name ~= "air" and n.name ~= "default:obsidian" then
				env:remove_node(np)
			end
			activate_if_tnt(n.name, np, pos, LIGHT_BLUE_TNT_RANGE)
		end
	end
	end
	end
end

function LIGHT_BLUE_TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "nuke:light_blue_tnt")
	end
end

minetest.register_entity("nuke:light_blue_tnt", ORANGE_TNT)



--[[
minetest.add_to_creative_inventory("nuke:iron_tnt")
minetest.add_to_creative_inventory("nuke:mese_tnt")
minetest.add_to_creative_inventory("nuke:hardcore_iron_tnt")
minetest.add_to_creative_inventory("nuke:hardcore_mese_tnt")

--Added the minetest.add_to_creative_inventory lines below - Jonathan 5/29/2013
minetest.add_to_creative_inventory("nuke:green_tnt")
minetest.add_to_creative_inventory("nuke:pink_tnt")
minetest.add_to_creative_inventory("nuke:teal_tnt")
minetest.add_to_creative_inventory("nuke:blue_tnt")
minetest.add_to_creative_inventory("nuke:brown_tnt")
minetest.add_to_creative_inventory("nuke:purple_tnt")
minetest.add_to_creative_inventory("nuke:red_tnt")
minetest.add_to_creative_inventory("nuke:black_tnt")
minetest.add_to_creative_inventory("nuke:dark_green_tnt")
minetest.add_to_creative_inventory("nuke:orange_tnt")
minetest.add_to_creative_inventory("nuke:light_blue_tnt")
--]]

--extra crafts

minetest.register_craft({
	output = 'nuke:light_blue_tnt 4',
	recipe = {
		{'','default:wood',''},
		{'dye:blue','default:apple','dye:white'},
		{'','default:wood',''}
	}
})

local function register_tnt_craft_color(color)
	minetest.register_craft({
		output = 'nuke:'..color..'_tnt 4',
		recipe = {
			{'','default:wood',''},
			{'dye:'..color,'default:coal_lump','dye:'..color},
			{'','default:wood',''}
		}
	})
end

minetest.register_alias("dye:teal", "dye:cyan")
minetest.register_alias("dye:purple", "dye:violet")

register_tnt_craft_color("green")
register_tnt_craft_color("pink")
register_tnt_craft_color("teal")
register_tnt_craft_color("blue")
register_tnt_craft_color("brown")
register_tnt_craft_color("purple")
register_tnt_craft_color("red")
register_tnt_craft_color("black")
register_tnt_craft_color("dark_green")
register_tnt_craft_color("orange")

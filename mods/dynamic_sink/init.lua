minetest.register_node(":dynamic_liquid:sink", {
	description = "Sink",
	tiles = {"default_cobble.png^nether_pearl.png",
		"default_cobble.png","default_cobble.png","default_cobble.png","default_cobble.png","default_cobble.png",
	},
	groups = {cracky = 3, stone = 2},
})

minetest.register_abm({
	nodenames = {"dynamic_liquid:sink"},
	interval = 1,
	chance = 1,
	catch_up = false,
	action = function(pos)
		if minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z}).name == "default:water_source" or minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z}).name == "default:water_flowing" then
			minetest.set_node({x=pos.x,y=pos.y+1,z=pos.z}, {name="air"})
		end
	end
})

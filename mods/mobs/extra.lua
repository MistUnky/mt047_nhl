function mobs_extra_register_sheeplike(name, hp, textures, textures_shear, sheared, fodder, biomes, mx, my, downer, chancer, amtp)
	mobs:register_mob(name, {
		type = "animal",
		hp_max = hp,
		collisionbox = {-0.4, downer, -0.4, 0.4, 1, 0.4},
		visual_size = {x=mx,y=my},
		textures = textures,
		visual = "upright_sprite",
		makes_footstep_sound = true,
		walk_velocity = 1,
		armor = 200,
		drops = {
			{name = "mobs:meat_raw",
			chance = 1,
			min = 2,
			max = 3,},
		},
		drawtype = "front",
		water_damage = 1,
		lava_damage = 5,
		light_damage = 0,
		sounds = {
			random = "mobs_sheep",
		},
		animation = {
			speed_normal = 15,
			stand_start = 0,
			stand_end = 80,
			walk_start = 81,
			walk_end = 100,
		},
		follow = fodder,
		view_range = 5,
		
		on_rightclick = function(self, clicker)
			local item = clicker:get_wielded_item()
			if item:get_name() == fodder then
				if not self.tamed then
					if not minetest.setting_getbool("creative_mode") then
						item:take_item()
						clicker:set_wielded_item(item)
					end
					self.tamed = true
				elseif self.naked then
					if not minetest.setting_getbool("creative_mode") then
						item:take_item()
						clicker:set_wielded_item(item)
					end
					self.food = (self.food or 0) + 1
					if self.food >= 8 then
						self.food = 0
						self.naked = false
						self.object:set_properties({
							textures = textures,
						})
					end
				end
				return
			end
			if clicker:get_inventory() and not self.naked then
				self.naked = true
				if minetest.registered_items[sheared] then
					clicker:get_inventory():add_item("main", ItemStack(sheared.." "..math.random(1,3)))
				end
				self.object:set_properties({
					textures = textures_shear,
				})
			end
		end,
	})
	mobs:register_spawn(name, biomes, 20, 8, chancer, amtp, 31000)
end

--mobs_extra_register_sheeplike("mobs:sheep", 5, {"mobs_sheep.png", "mobs_sheep.png"}, {"mobs_sheep_naked.png", "mobs_sheep_naked.png"}, "wool:white", "farming:wheat", {"default:dirt_with_grass"})

minetest.register_craftitem("mobs:egg", {
	description = "Egg",
	inventory_image = "mobs_egg.png",
	on_use = minetest.item_eat(1),
})

minetest.register_craftitem("mobs:omelet", {
	description = "Omelet",
	inventory_image = "mobs_omelet.png",
	on_use = minetest.item_eat(8),
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:omelet",
	recipe = "mobs:egg",
	cooktime = 3,
})

mobs_extra_register_sheeplike("mobs:chicken", 5, {"mobs_chicken.png", "mobs_chicken.png"}, {"mobs_chicken.png", "mobs_chicken.png"}, "mobs:egg", "farming:wheat", {"default:dirt_with_grass"}, 0.5, 0.5, -0.4, 8000, 4)

minetest.register_craftitem("mobs:milk", {
	description = "Milk",
	inventory_image = "mobs_milk.png",
	on_use = minetest.item_eat(4),
})

minetest.register_craftitem("mobs:cheese", {
	description = "Cheese",
	inventory_image = "mobs_cheese.png",
	on_use = minetest.item_eat(13),
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:cheese",
	recipe = "mobs:milk",
	cooktime = 17,
})

mobs_extra_register_sheeplike("mobs:cow", 5, {"mobs_cow.png", "mobs_cow.png"}, {"mobs_cow.png", "mobs_cow.png"}, "mobs:milk", "farming:wheat", {"default:dirt_with_grass"}, 3, 4, -1.0, 9000, 1)

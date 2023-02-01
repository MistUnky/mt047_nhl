minetest.register_alias("nyancat:nyancat", "default:nyancat")
minetest.register_alias("nyancat:nyancat_rainbow", "default:nyancat_rainbow")

nyancat = {}

function nyancat.place(pos, facedir, length)
	if facedir > 3 then
		facedir = 0
	end
	local tailvec = minetest.facedir_to_dir(facedir)
	local p = {x = pos.x, y = pos.y, z = pos.z}
	minetest.set_node(p, {name = "nyancat:nyancat", param2 = facedir})
	for i = 1, length do
		p.x = p.x + tailvec.x
		p.z = p.z + tailvec.z
		minetest.set_node(p, {name = "nyancat:nyancat_rainbow", param2 = facedir})
	end
end

function nyancat.generate(minp, maxp, seed)
	local height_min = -31000
	local height_max = -32
	if maxp.y < height_min or minp.y > height_max then
		return
	end
	local y_min = math.max(minp.y, height_min)
	local y_max = math.min(maxp.y, height_max)
	local volume = (maxp.x - minp.x + 1) * (y_max - y_min + 1) * (maxp.z - minp.z + 1)
	local pr = PseudoRandom(seed + 9324342)
	local max_num_nyancats = math.floor(volume / (16 * 16 * 16))
	for i = 1, max_num_nyancats do
		if pr:next(0, 1000) == 0 then
			local x0 = pr:next(minp.x, maxp.x)
			local y0 = pr:next(minp.y, maxp.y)
			local z0 = pr:next(minp.z, maxp.z)
			local p0 = {x = x0, y = y0, z = z0}
			nyancat.place(p0, pr:next(0, 3), pr:next(3, 15))
		end
	end
end

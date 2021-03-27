--[[

  ITB (insidethebox) minetest game - Copyright (C) 2017-2018 sofar & nore

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public License
  as published by the Free Software Foundation; either version 2.1
  of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free
  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
  MA 02111-1307 USA

]]--

--[[

  terminal - an interactive terminal

]]--

fsc = {}

local _data = {}

local SRNG = SecureRandom()
assert(SRNG)

local function make_new_random_id()
	local s = SRNG:next_bytes(16)
	return s:gsub(".", function(c) return string.format("%02x", string.byte(c)) end)
end

function fsc.show(name, formspec, context, callback)
	assert(name)
	assert(formspec)
	assert(callback)

	if not context then
		context = {}
	end

	-- erase old context!
	local id = "fsc:" .. make_new_random_id()
	_data[name] = {
		id = id,
		name = name,
		context = context,
		callback = callback,
	}

	minetest.show_formspec(name, id, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if not formname:match("fsc:") then
		return false
	end

	local name = player:get_player_name()
	local data = _data[name]
	if not data then
		minetest.log("warning", "fsc: no data for formspec sent by " .. name)
		minetest.close_formspec(name, formname)
		return
	end
	if data.id ~= formname then
		minetest.log("warning", "fsc: invalid id for formspec sent by " .. name)
		minetest.close_formspec(name, formname)
		_data[name] = nil
		return
	end
	if data.name ~= name then
		minetest.log("error", "fsc: possible hash collision or exploit (name mismatch)")
		minetest.close_formspec(name, formname)
		_data[name] = nil
		return
	end
	if data then
		if data.callback(player, fields, data.context) then
			minetest.close_formspec(name, formname)
			_data[name] = nil
		elseif fields.quit then
			_data[name] = nil
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	_data[player:get_player_name()] = nil
end)

log = {}

function log.fs_data(player, name, formname, fields)
	assert(player or name)

	local pos = "(unknown pos)"
	if name and not player then
		player = minetest.get_player_by_name(name)
	end
	if player then
		pos = minetest.pos_to_string(vector.floor(player:get_pos()))
	end
	if not name and player then
		name = player:get_player_name()
	end
	local f = ""
	for k, _ in pairs(fields) do
		if f ~= "" then
			f = f .. ", "
		end
		f = f .. k
	end

	minetest.log("error", "invalid formspec data: player " .. name .. " at " ..
		pos .. " sends " .. formname .. ": [" .. f .. "]")
end

local term = {}

local function get_cmd_params(line)
	local cmd = ""
	local params = ""
	for w in line:gmatch("%w+") do
		if cmd == "" then
			cmd = w
		elseif params == "" then
			params = w
		else
			params = params .. " " .. w
		end
	end
	return cmd, params
end

term.help = {
	append = "append text to a file",
	clear = "clear the output",
	echo = "echoes the input back to you",
	help = "display help information for commands",
	list = "list available files",
	lock = "lock the terminal",
	read = "read the content of a file",
	remove = "removes a file",
	unlock = "unlocks the terminal",
	write = "write text to a file",
	edit = "edits a file in an editor",
}

local function make_formspec(output, prompt)
	local f =
		"size[12,8]" ..
		"field_close_on_enter[input;false]" ..
		"textlist[0.4,0.5;11,6;output;"

	local c = 1
	if output then
		for part in output:gmatch("([^\r\n]*)\n?") do
			f = f .. minetest.formspec_escape(part) .. ","
			c = c + 1
		end
	end
	f = f .. minetest.formspec_escape(prompt) .. ";" .. c .. ";false]"

	f = f .. "field[0.7,7;11.2,1;input;;]"
	return f
end

term.commands = {
	clear = function(output, params, c)
		return ""
	end,
	append = function(output, params, c)
		if not c.rw then
			return output .. "\nError: No write access"
		end
		local what, _ = get_cmd_params(params)
		if what == "" then
			return output .. "\nError: Missing file name"
		end
		c.writing = what
		return output .. "\nWriting \"" .. what .. "\". Enter STOP on a line by itself to finish"
	end,
	write = function(output, params, c)
		return output .. "\nError: No change access"
		--[[if not c.rw then
			return output .. "\nError: No write access"
		end
		local what, _ = get_cmd_params(params)
		if what == "" then
			return output .. "\nError: Missing file name"
		end
		c.writing = what
		local meta = minetest.get_meta(c.pos)
		local meta_files = meta:get_string("files")
		if meta_files and meta_files ~= "" then
			local files = minetest.parse_json(meta_files) or {}
			if files and files[what] then
				files[what] = ""
				meta:set_string("files", minetest.write_json(files))
				meta:mark_as_private("files")
			end
		end
		return output .. "\nWriting \"" .. what .. "\". Enter STOP on a line by itself to finish" --]]
	end,
	edit = function(output, params, c)
		return output .. "\nError: No change access"
		--[[if not c.rw then
			return output .. "\nError: No write access"
		end
		local what, _ = get_cmd_params(params)
		if what == "" then
			return output .. "\nError: Missing file name"
		end
		c.what = what
		c.output = output

		local text = ""
		local meta = minetest.get_meta(c.pos)
		local meta_files = meta:get_string("files")
		if meta_files and meta_files ~= "" then
			local files = minetest.parse_json(meta_files) or {}
			if files and files[what] then
				text = files[what]
			end
		end

		fsc.show(c.name, "size[12,8]" ..
			"textarea[0.5,0.5;11.5,7.0;text;text;" ..
			minetest.formspec_escape(text) .. "]" ..
			"button[5.2,7.2;1.6,0.5;exit;Save]",
			c,
			term.edit)

		return false --]]
	end,
	remove = function(output, params, c)
		return output .. "\nError: No change access"
		--[[if not c.rw then
			return output .. "\nError: No write access"
		end
		local meta = minetest.get_meta(c.pos)
		local meta_files = meta:get_string("files")
		if not meta_files or meta_files == "" then
			return output .. "\nError: No such file"
		end
		local files = minetest.parse_json(meta_files) or {}
		local first, _ = get_cmd_params(params)
		if files[first] then
			files[first] = nil
		else
			return output .. "\nError: No such file"
		end
		meta:set_string("files", minetest.write_json(files))
		meta:mark_as_private("files")
		return output .. "\nRemoved \"" .. first .. "\"" --]]
	end,
	list = function(output, params, c)
		local meta = minetest.get_meta(c.pos)
		local meta_files = meta:get_string("files")
		local files
		if not meta_files or meta_files == "" then
			return output .. "\nError: No files found"
		end
		files = minetest.parse_json(meta_files) or {}
		if not files then
			return output .. "\nError: No files found"
		end
		for k, _ in pairs(files) do
			output = output .. "\n" .. k
		end
		return output
	end,
	echo = function(output, params, c)
		return output .. "\n" .. params
	end,
	read = function(output, params, c)
		local meta = minetest.get_meta(c.pos)
		local meta_files = meta:get_string("files")
		if not meta_files or meta_files == "" then
			return output .. "\nError: No such file"
		end
		local files = minetest.parse_json(meta_files) or {}
		local first, _ = get_cmd_params(params)
		if files[first] then
			if first == "rules" then
				rules.show(c.name, "player")
				return false
			end
			return output .. "\n" .. files[first]
		else
			return output .. "\nError: No such file"
		end
	end,
	lock = function(output, params, c)
		if not c.rw then
			return output .. "\nError: no write access"
		end
		local meta = minetest.get_meta(c.pos)
		meta:set_int("locked", 1)
		--meta:mark_as_private("locked")
		return output .. "\n" .. "Terminal locked"
	end,
	unlock = function(output, params, c)
		--return output .. "\n" .. "Error: unable to connect to authentication service"
		if not c.rw then
			return output .. "\n" .. "Error: invalid credentials"
		end
		local meta = minetest.get_meta(c.pos)
		meta:set_int("locked", 0)
		return output .. "\n" .. "Terminal unlocked"
	end,
	help = function(output, params, c)
		if params ~= "" then
			local h, _ = get_cmd_params(params)
			if term.help[h] then
				return output .. "\n" .. term.help[h]
			else
				return output .. "\nError: No help for \"" .. h .. "\""
			end
		end
		local o = ""
		local ot = {}
		for k, _ in pairs(term.help) do
			ot[#ot + 1] = k
		end
		table.sort(ot)
		for _, v in ipairs(ot) do
			o = o .. "  " .. v .. "\n"
		end
		return output .. "\n" ..
			"Available commands:\n" ..
			o ..
			"Type `help <command>` for more help about that command"
	end,
}

function term.recv(player, fields, context)
	-- input validation
	local name = player:get_player_name()
	local c = context
	if not c or not c.pos then
		log.fs_data(player, name, "term.recv/context", fields)
		return true
	end

	local line = fields.input
	if line and line ~= "" then
		local output = c.output or ""
		minetest.sound_play("terminal_keyboard_clicks", {pos = c.pos})

		if c.writing then
			-- this shouldn't get reached, but just to be safe, check ro
			if not c.rw then
				c.writing = nil
				output = output .. "\n" .. line
				output = output .. "\nError: no write access"
				c.output = output
				fsc.show(name,
					make_formspec(output, "> "),
					c,
					term.recv)
				return
			end
			-- are we writing a file?
			if line == "STOP" then
				-- done writing a file
				c.writing = nil
				output = output .. "\n" .. line
				c.output = output
				fsc.show(name,
					make_formspec(output, "> "),
					c,
					term.recv)
				return
			end
			local meta = minetest.get_meta(c.pos)
			local meta_files = meta:get_string("files")
			local files = {}
			if not meta_files or meta_files == "" then
				files[c.writing] = line
			else
				files = minetest.parse_json(meta_files) or {}
				if not files[c.writing] then
					files[c.writing] = line
				else
					files[c.writing] = files[c.writing] .. "\n" .. line
				end
			end
			if string.len(files[c.writing]) < 16384 then
				local json = minetest.write_json(files)
				if string.len(json) < 49152 then
					meta:set_string("files", json)
					meta:mark_as_private("files")
					output = output .. "\n" .. line
				else
					output = output .. "\n" .. "Error: no space left on device"
				end
			else
				output = output .. "\n" .. "Error: maximum file length exceeded"
			end
			c.output = output
			fsc.show(name,
				make_formspec(output, ""),
				c,
				term.recv)
			return
		else
			-- else parse cmd
			output = output .. "\n> " .. line

			local meta = minetest.get_meta(c.pos)
			local cmd, params = get_cmd_params(line)
			if meta:get_int("locked") == 1 and cmd ~= "unlock" then
				output = output .. "\nError: Terminal locked, type \"unlock\" to unlock it"
				c.output = output
				fsc.show(name,
					make_formspec(output, "> "),
					c,
					term.recv)
				return
			end

			local fn = term.commands[cmd]
			if fn then
				output = fn(output, params, c)
			else
				output = output .. "\n" .. "Error: Syntax Error. Try \"help\""
			end
			if output ~= false then
				c.output = output
				fsc.show(name,
					make_formspec(output, "> "),
					c,
					term.recv)
			end
			return
		end
	elseif fields.quit then
		minetest.sound_play("terminal_power_off", {pos = c.pos})
		return true
	elseif fields.output then
		-- CHG events - do not return true
		return
	elseif fields.input then
		-- KEYBOARD events - do not return true
		return
	end

	log.fs_data(player, name, "term.recv/default", fields)
	return true
end

function term.edit(player, fields, context)
	if not fields.text then
		return true
	end

	local name = player:get_player_name()
	local c = context
	if not c or not c.pos or not c.output then
		log.fs_data(player, name, "term.edit/terminal", fields)
		return true
	end
	local output = c.output

	if not c.what then
		output = output .. "\n" .. "Error: no such file\n"
		fsc.show(name,
			make_formspec(output, "> "),
			c,
			term.recv)
		return
	end

	local meta = minetest.get_meta(c.pos)
	local meta_files = meta:get_string("files")
	local files
	files = minetest.parse_json(meta_files) or {}
	files[c.what] = fields.text

	-- validate it fits
	local json = minetest.write_json(files)
	if string.len(json) < 49152 then
		meta:set_string("files", json)
		meta:mark_as_private("files")
		output = output .. "\n" .. "Wrote: " .. c.what .. "\n"
	else
		output = output .. "\n" .. "Error: no space left on device\n"
	end

	c.output = output

	fsc.show(name,
		make_formspec(output, "> "),
		c,
		term.recv)
	return
end

local terminal_use = function(pos, node, clicker, itemstack, pointed_thing)
	if not clicker then
		return
	end
	local name = clicker:get_player_name()
	local context = {
		pos = pos,
		rw = false,
		output = "",
		name = name,
	}
	context.rw = true
	-- send formspec to player
	fsc.show(name,
		make_formspec(nil, "> "),
		context,
		term.recv)
	minetest.sound_play("terminal_power_on", {pos = pos})
	-- trigger on first use
	local meta = minetest.get_meta(pos)
	if meta:get_int("locked") ~= 1 then
		--mech.trigger(pos)
		--minetest.after(1.0, mech.untrigger, pos)
	end
end

minetest.register_node("terminal:terminal", {
	description = "Interactive terminal console emulator access interface unit controller",
	--drawtype = "mesh",
	mesh = "terminal.obj",
	groups = {mech = 1, trigger = 1},
	tiles = {
		--{name = "terminal_base.png"},
		{name = "terminal_idle.png", animation = {type = "vertical_frames", aspect_w = 14, aspect_h = 13, length = 4.0}},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	on_trigger = function(pos)
		local meta = minetest.get_meta(pos)
		minetest.sound_play("terminal_power_on", {pos = pos})
		meta:set_int("locked", 0)
		meta:mark_as_private("locked")
	end,
	on_untrigger = function(pos)
		local meta = minetest.get_meta(pos)
		minetest.sound_play("terminal_power_off", {pos = pos})
		meta:set_int("locked", 1)
		meta:mark_as_private("locked")
	end,
	on_rightclick = terminal_use,
	--sounds = default.node_sound_metal_defaults(),
	
	sunlight_propagates = true,
	is_ground_content = false,
	light_source = 0,--default.LIGHT_MAX,
})

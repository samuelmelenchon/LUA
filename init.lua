
--[[
Basic mod to control Minetest using a NodeMCU
--]]
DEBUG = false
-- [[VARIABLES]]
name_of_the_mod_folder = "nodemcu_control_quete"
-- IP Address of the arduino card
IP_ADDRESS = "192.168.1.144"
-- waiting that the player connects to the game before looping
List_of_players = {}
-- Timer
Timer = 0
Timer_has_started = 0
-- Leds
rqLedOn = false
rqLedOff = false

-- [[LIBARY]]
L_secret_door = {closed = 0, opened = 0}
-- [[Giant Door]]
GD_module_has_been_activated = 0
GD_player_is_around_giant_door = 0
GD_lamp_is_activated = 0
GD_player_has_lost = 0
GD_lamps_state = {0, 0, 0, 0}
GD_done = 0
-- [[Didacticiel]]
DI_module_has_been_activated = 0
DI_player_is_around_didacticiel = 0
DI_lamp_is_activated = 0
DI_player_has_lost = 0
DI_lamps_state = {0, 0, 0, 0}
DI_done = 0
-- [[SIMON]]
S_player_is_around_simon = 0
S_game_stage = 0
S_lamps_state = {0, 0, 0, 0}
S_concatenated_lamps_states = {}
S_concatenated_buttons_states = {}
S_switch_is_on = 0
S_switch_counter = 0
S_player_won = 0
S_player_lost = 0
S_done = 0
-- [[RANDOM THREADS]]
T_player_is_around_threads = 0
T_switch_is_on = 0
T_player_won = 0
T_player_lost = 0
T_threads_colors_register = {}
T_amount_of_threads = 0
T_button_soluce = ""
T_done = 0
-- [[SYMBOLS]]
SY_number_of_symbols = 16
SY_number_of_references_tables = 6
SY_number_of_values_in_each_table = 5
-- /!\ si modification de SY_number_of_values_to_trigger, alors modifier le nombre de rand ~= indexes_to_avoid[x] dans le module 4
-- il doit y avoir autant de valeurs x que de valeurs de 1 à (SY_number_of_values_to_trigger - 1)
SY_number_of_values_to_trigger = 4
SY_reference_1 = {1, 2, 3, 4, 5}
SY_reference_2 = {6, 7, 8, 9, 10}
SY_reference_3 = {11, 12, 13, 14, 15}
SY_reference_4 = {16, 2, 5, 8, 10}
SY_reference_5 = {12, 15, 7, 3, 9}
SY_reference_6 = {1, 14, 5, 16, 13}
SY_pos_random_symbol_1 = {x=488, y=0.5, z=-477}
SY_pos_random_symbol_2 = {x=488, y=0.5, z=-478}
SY_pos_random_symbol_3 = {x=488, y=0.5, z=-479}
SY_pos_random_symbol_4 = {x=488, y=0.5, z=-480}
SY_pos_symbol_1 = {x=480, y=3.5, z=-475}
SY_pos_symbol_2 = {x=481, y=3.5, z=-475}
SY_pos_symbol_3 = {x=482, y=3.5, z=-475}
SY_pos_symbol_4 = {x=483, y=3.5, z=-475}
SY_pos_symbol_5 = {x=480, y=2.5, z=-475}
SY_pos_symbol_6 = {x=481, y=2.5, z=-475}
SY_pos_symbol_7 = {x=482, y=2.5, z=-475}
SY_pos_symbol_8 = {x=483, y=2.5, z=-475}
SY_pos_symbol_9 = {x=480, y=1.5, z=-475}
SY_pos_symbol_10 = {x=481, y=1.5, z=-475}
SY_pos_symbol_11 = {x=482, y=1.5, z=-475}
SY_pos_symbol_12 = {x=483, y=1.5, z=-475}
SY_pos_symbol_13 = {x=480, y=0.5, z=-475}
SY_pos_symbol_14 = {x=481, y=0.5, z=-475}
SY_pos_symbol_15 = {x=482, y=0.5, z=-475}
SY_pos_symbol_16 = {x=483, y=0.5, z=-475}
-- adding symbols' textures through function and calls
local lightstone_rules = {
	{x=0,  y=0,  z=-1},
	{x=1,  y=0,  z=0},
	{x=-1, y=0,  z=0},
	{x=0,  y=0,  z=1},
	{x=1,  y=1,  z=0},
	{x=1,  y=-1, z=0},
	{x=-1, y=1,  z=0},
	{x=-1, y=-1, z=0},
	{x=0,  y=1,  z=1},
	{x=0,  y=-1, z=1},
	{x=0,  y=1,  z=-1},
	{x=0,  y=-1, z=-1},
	{x=0,  y=-1, z=0},
}
function lightstone_add_symbol(name, desc)
	if not desc then
		desc = "Symbole " .. name
	end
	minetest.register_node(name_of_the_mod_folder .. ":" .. name .. "_symbol_off", {
		tiles = {"lightstone_white_off.png^" .. name_of_the_mod_folder .. "_" .. name .. ".png"},
		is_ground_content = false,
		groups = {cracky = 2, mesecon_effector_off = 1, mesecon = 2},
		description = desc,
		sounds = default.node_sound_stone_defaults(),
		mesecons = {effector = {
			rules = lightstone_rules,
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = name_of_the_mod_folder .. ":" .. name .. "_symbol_on", param2 = node.param2})
			end,
		}},
		on_blast = mesecon.on_blastnode,
	})
	minetest.register_node(name_of_the_mod_folder .. ":" .. name .. "_symbol_on", {
		tiles = {"lightstone_white_on.png^" .. name_of_the_mod_folder .. "_" .. name .. ".png"},
		is_ground_content = false,
		groups = {cracky = 2, not_in_creative_inventory = 1, mesecon = 2},
		drop = name_of_the_mod_folder .. ":" .. name .. "_symbol_off",
		light_source = minetest.LIGHT_MAX - 2,
		sounds = default.node_sound_stone_defaults(),
		mesecons = {effector = {
			rules = lightstone_rules,
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = name_of_the_mod_folder .. ":" .. name .. "_symbol_off", param2 = node.param2})
			end,
		}},
		on_blast = mesecon.on_blastnode,
	})
end
lightstone_add_symbol("gamma")
lightstone_add_symbol("delta")
lightstone_add_symbol("lambda")
lightstone_add_symbol("phi")
lightstone_add_symbol("pi")
lightstone_add_symbol("sigma")
lightstone_add_symbol("theta")
lightstone_add_symbol("xi")
lightstone_add_symbol("psi")
lightstone_add_symbol("omega")
lightstone_add_symbol("chi")
lightstone_add_symbol("epsilon")
lightstone_add_symbol("alpha")
lightstone_add_symbol("beta")
lightstone_add_symbol("zeta")
lightstone_add_symbol("kappa")
-- adding symbols' variables
SY_player_is_around_symbols = 0
SY_switch_is_on = 0
SY_player_won = 0
SY_player_lost = 0
SY_selected_references = {}
SY_selected_reference = {}
SY_indexes_to_avoid = {}
SY_index_to_avoid = 0
SY_random_nodes = {}
SY_random_nodes_ordered = {}
SY_concatenated_buttons_states = {}
SY_done = 0
--[[BOSS]]
B_player_is_in_boss_zone = 0
B_button_has_been_activated = 0
B_done = 0
--[[BUTTON]]
BU_player_is_in_button_zone = 0
BU_button_has_been_activated = 0

-- small function to check emptiness of a table (needed to send messages when players enter a zone)
function is_empty(t)
    for _,_ in pairs(t) do
        return false
    end
    return true
end


-- Loading HTTP API
local http_api = minetest.request_http_api()
if not http_api then
   print("ERROR: in minetest.conf, this mod must be in secure.http_mods!")
end



-- [[FUNCTIONS]]
-- Playing an animation when the switch is on
function launch_module(pos_1, pos_2, pos_3, pos_4)
	lightning.strike(pos_1)
	lightning.strike(pos_2)
	lightning.strike(pos_3)
	lightning.strike(pos_4)
	minetest.after(0.2, function()
		minetest.set_node(pos_1, {name="xdecor:iron_lightbox"})
		minetest.set_node(pos_2, {name="xdecor:iron_lightbox"})
		minetest.set_node(pos_3, {name="xdecor:iron_lightbox"})
		minetest.set_node(pos_4, {name="xdecor:iron_lightbox"})
		minetest.after(0.2, function()
			lightning.strike({x=pos_1.x, y=pos_1.y+1, z=pos_1.z})
			lightning.strike({x=pos_2.x, y=pos_2.y+1, z=pos_2.z})
			lightning.strike({x=pos_3.x, y=pos_3.y+1, z=pos_3.z})
			lightning.strike({x=pos_4.x, y=pos_4.y+1, z=pos_4.z})
		end)
	end)
end

-- Playing an animation when the switch is off
function close_module(pos_1, pos_2, pos_3, pos_4)
	minetest.set_node(pos_1, {name="air"})
	minetest.set_node(pos_2, {name="air"})
	minetest.set_node(pos_3, {name="air"})
	minetest.set_node(pos_4, {name="air"})
end

-- Placing node function to open library secret door
function place_node_bibli_on(res)
	-- Get the status of the button
	local place = tonumber(res.data)

	-- If the button is pushed, place the node
	if place == 1 then
		--minetest.place_node({x=POS_X, y=POS_Y, z=POS_Z}, {name=NODE_TYPE})
		minetest.set_node({x=58, y=1.5, z=30}, {name="air"})
		minetest.set_node({x=59, y=1.5, z=30}, {name="air"})
		minetest.place_node({x=59, y=1.5, z=30}, {name="mesecons_gates:not_on"})
	end
end
-- Placing node function to close library secret door
function place_node_bibli_off(res)
	-- Get the status of the button
	local place = tonumber(res.data)

	-- If the button is pushed, place the node
	if place == 1 then
		--minetest.place_node({x=POS_X, y=POS_Y, z=POS_Z}, {name=NODE_TYPE})
		minetest.place_node({x=58, y=1.5, z=30}, {name="mesecons_gates:not_on"})
	end
end
-- Opening giant door with lamps' mini-game
function open_giant_door(res)
	-- Get the status of the button
	local buttons_state = res.data

	--minetest.chat_send_all(buttons_state)
	--minetest.chat_send_all(table.concat(GD_lamps_state, ' '))

	-- écouter la suite de 3 chiffres envoyée par les boutons
	if buttons_state ~= "0000" then
		if buttons_state == table.concat(GD_lamps_state, '') then
			-- si ça correspond avec les statuts des lamps du jeu, ouvrir...
			for i = 0, 7, 1 do
				for j = 0, 8, 1 do
					for k = 0, 2, 1 do
						minetest.set_node({x=217+k, y=0.5+j, z=-427+i}, {name="air"})
					end
				end
			end
			for i = 0, 1, 1 do
				for j = 0, 8, 1 do
					minetest.set_node({x=218+i, y=0.5+j, z=-427}, {name="bedrock:glass"})
					minetest.set_node({x=218+i, y=0.5+j, z=-420}, {name="bedrock:glass"})
				end
			end
			for i = 0, 1, 1 do
				for k = 0, 7, 1 do
					minetest.set_node({x=218+i, y=8.5, z=-427+k}, {name="bedrock:glass"})
				end
			end
			Player_wins({x=209, y=0.5, z=-419}, {x=209, y=0.5, z=-418})
			GD_done = 1
		-- ...sinon, fermer
		else
			-- vitre face avant
			for i = 0, 13, 1 do
				for j = 0, 10, 1 do
					minetest.set_node({x=217, y=0.5+j, z=-430+i}, {name="bedrock:glass"})
				end
			end
			-- centre
			for j = 0, 8, 1 do
				minetest.set_node({x=218, y=0.5+j, z=-427}, {name="air"})
				minetest.set_node({x=218, y=0.5+j, z=-420}, {name="air"})
			end
			for k = 0, 7, 1 do
				minetest.set_node({x=218, y=8.5, z=-427+k}, {name="air"})
			end
			if GD_player_has_lost == 0 then
				Player_loses({x=209, y=0.5, z=-419}, {x=209, y=0.5, z=-418})
				GD_player_has_lost = 1
			end
		end
	end
end
function put_wagon(res)
	-- Get the status of the button
	local buttons_state = res.data

	--minetest.chat_send_all(buttons_state)
	--minetest.chat_send_all(table.concat(GD_lamps_state, ' '))

	-- écouter la suite de 3 chiffres envoyée par les boutons
	if buttons_state ~= "0000" then
		if buttons_state == table.concat(D_lamps_state, '') then
			minetest.set_node({x=19, y=0.5, z=-1}, {name="chariot"})
		else
			minetest.set_node({x=19, y=0.5, z=-1}, {name="air"})
		end
	end
end

-- Useful function to play sound on player
function play_sound_at_player(sound)
	local parameters = {
		pos = player_position,
		gain = 0.5,
		max_hear_distance = 10,
		}
	local spec = sound
	minetest.sound_play(spec, parameters, true)
end
-- Useful functions switching each simon's lamp on and off with sound
function S_switch_yellow_lamp()
	minetest.set_node({x=417, y=3.5, z=-482}, {name="mesecons_lightstone:lightstone_yellow_on"})
	minetest.set_node({x=417, y=2.5, z=-482}, {name="mesecons_lightstone:lightstone_yellow_on"})
	minetest.set_node({x=417, y=3.5, z=-481}, {name="mesecons_lightstone:lightstone_yellow_on"})
	minetest.set_node({x=417, y=2.5, z=-481}, {name="mesecons_lightstone:lightstone_yellow_on"})
	play_sound_at_player("Note_1")
	minetest.after(0.3, function()
		minetest.set_node({x=417, y=3.5, z=-482}, {name="mesecons_lightstone:lightstone_yellow_off"})
		minetest.set_node({x=417, y=2.5, z=-482}, {name="mesecons_lightstone:lightstone_yellow_off"})
		minetest.set_node({x=417, y=3.5, z=-481}, {name="mesecons_lightstone:lightstone_yellow_off"})
		minetest.set_node({x=417, y=2.5, z=-481}, {name="mesecons_lightstone:lightstone_yellow_off"})
	end)
end
function S_switch_green_lamp()
	minetest.set_node({x=417, y=3.5, z=-484}, {name="mesecons_lightstone:lightstone_green_on"})
	minetest.set_node({x=417, y=2.5, z=-484}, {name="mesecons_lightstone:lightstone_green_on"})
	minetest.set_node({x=417, y=3.5, z=-483}, {name="mesecons_lightstone:lightstone_green_on"})
	minetest.set_node({x=417, y=2.5, z=-483}, {name="mesecons_lightstone:lightstone_green_on"})
	play_sound_at_player("Note_2")
	minetest.after(0.3, function()
		minetest.set_node({x=417, y=3.5, z=-484}, {name="mesecons_lightstone:lightstone_green_off"})
		minetest.set_node({x=417, y=2.5, z=-484}, {name="mesecons_lightstone:lightstone_green_off"})
		minetest.set_node({x=417, y=3.5, z=-483}, {name="mesecons_lightstone:lightstone_green_off"})
		minetest.set_node({x=417, y=2.5, z=-483}, {name="mesecons_lightstone:lightstone_green_off"})
	end)
end
function S_switch_blue_lamp()
	minetest.set_node({x=417, y=1.5, z=-482}, {name="mesecons_lightstone:lightstone_blue_on"})
	minetest.set_node({x=417, y=0.5, z=-482}, {name="mesecons_lightstone:lightstone_blue_on"})
	minetest.set_node({x=417, y=1.5, z=-481}, {name="mesecons_lightstone:lightstone_blue_on"})
	minetest.set_node({x=417, y=0.5, z=-481}, {name="mesecons_lightstone:lightstone_blue_on"})
	play_sound_at_player("Note_3")
	minetest.after(0.3, function()
		minetest.set_node({x=417, y=1.5, z=-482}, {name="mesecons_lightstone:lightstone_blue_off"})
		minetest.set_node({x=417, y=0.5, z=-482}, {name="mesecons_lightstone:lightstone_blue_off"})
		minetest.set_node({x=417, y=1.5, z=-481}, {name="mesecons_lightstone:lightstone_blue_off"})
		minetest.set_node({x=417, y=0.5, z=-481}, {name="mesecons_lightstone:lightstone_blue_off"})
	end)
end
function S_switch_red_lamp()
	minetest.set_node({x=417, y=1.5, z=-484}, {name="mesecons_lightstone:lightstone_red_on"})
	minetest.set_node({x=417, y=0.5, z=-484}, {name="mesecons_lightstone:lightstone_red_on"})
	minetest.set_node({x=417, y=1.5, z=-483}, {name="mesecons_lightstone:lightstone_red_on"})
	minetest.set_node({x=417, y=0.5, z=-483}, {name="mesecons_lightstone:lightstone_red_on"})
	play_sound_at_player("Note_4")
	minetest.after(0.3, function()
		minetest.set_node({x=417, y=1.5, z=-484}, {name="mesecons_lightstone:lightstone_red_off"})
		minetest.set_node({x=417, y=0.5, z=-484}, {name="mesecons_lightstone:lightstone_red_off"})
		minetest.set_node({x=417, y=1.5, z=-483}, {name="mesecons_lightstone:lightstone_red_off"})
		minetest.set_node({x=417, y=0.5, z=-483}, {name="mesecons_lightstone:lightstone_red_off"})
	end)
end
-- Useful function to trigger a loss
function Player_loses(pos_wall_lever, pos_switch)
	-- replacing lever
	minetest.set_node(pos_wall_lever, {name="air"})
	minetest.set_node(pos_wall_lever, {name="mesecons_walllever:wall_lever_off"})
	-- replacing switch lamp
	minetest.set_node(pos_switch, {name="air"})
	minetest.set_node(pos_switch, {name="default:mese"})
	-- playing sound and sending message
	play_sound_at_player("yl_speak_up_low_blow")
	lightning.strike(pos_switch)
	minetest.after(0.3, function()
		for i = 0, 10, 10 do
			for j = 0, 10, 10 do
				if (math.random(0,1)) then
					minetest.add_entity({x=pos_switch.x-5+i, y=pos_switch.y ,z=pos_switch.z-5+j}, "nssm:duck")
				else
					minetest.add_entity({x=pos_switch.x-5+i, y=pos_switch.y+2 ,z=pos_switch.z-5+j}, "nssm:flying_duck")
				end
			end
		end
	end)
	minetest.chat_send_all('Echec !')
end
function Player_wins(pos_wall_lever, pos_switch)
	-- replacing lever
	minetest.set_node(pos_wall_lever, {name="air"})
	minetest.set_node(pos_wall_lever, {name="mesecons_walllever:wall_lever_off"})
	-- replacing switch lamp
	minetest.set_node(pos_switch, {name="air"})
	minetest.set_node(pos_switch, {name="default:mese"})
	-- playing sound and sending message
	local parameters = {
		pos = player_position,
		gain = 0.2,
		max_hear_distance = 10,
		}
	local spec = "final_fantasy_victory"
	minetest.sound_play(spec, parameters, true)
	minetest.chat_send_all('Gagné !')
end
-- Switching random simon's lamps on and playing sounds according to the mini-game stage
function simon_switch_random_lamp(S_game_stage)
	-- allumer les lampes dans le jeu d'après le numéro du niveau (niveau 2 : 2 lampes à allumer), ensuite envoyer les requêtes http
	if S_switch_counter < S_game_stage then
		for i = 1, S_game_stage, 1 do
			local rand = math.random(1,4)
			if rand == 1 then
				table.insert(S_concatenated_lamps_states, "1000")
				-- A l'oeil nu, les i lampes vont toutes s'allumer en même temps, donc on ajoute la fonction after(i,...)
				-- Au niveau 3, on aura i=1 puis i=2 puis i=3, donc chaque allumage de lampe se fera avec 1 seconde d'intervalle,
				-- bien que la commande soit passée quasi-simultanément
				minetest.after(i, S_switch_yellow_lamp)
			end
			if rand == 2 then
				table.insert(S_concatenated_lamps_states, "0100")
				minetest.after(i, S_switch_green_lamp)
			end
			if rand == 3 then
				table.insert(S_concatenated_lamps_states, "0010")
				minetest.after(i, S_switch_blue_lamp)
			end
			if rand == 4 then
				table.insert(S_concatenated_lamps_states, "0001")
				minetest.after(i, S_switch_red_lamp)
			end
			S_switch_counter = S_switch_counter + 1
			minetest.chat_send_all("Lampe activée.")
		end
	else
		http_api.fetch({url = "http://" .. IP_ADDRESS .. "/simon_next_stage", timeout = 1}, simon_next_stage)
	end
end
-- moving to the next stage when the right IRL buttons are pressed in the right order
function simon_next_stage(res)
	-- Get the status of the button
	local buttons_state = res.data
	if DEBUG then
		minetest.chat_send_all(buttons_state)
		minetest.chat_send_all(table.concat(S_concatenated_buttons_states, ' '))
		minetest.chat_send_all(table.concat(S_concatenated_lamps_states, ' '))
	end
	-- écouter la suite de 4 chiffres envoyée par les boutons
	if buttons_state ~= "0000" and buttons_state ~= nil then
		table.insert(S_concatenated_buttons_states, buttons_state)
		if buttons_state == "1000" then
			S_switch_yellow_lamp()
		elseif buttons_state == "0100" then
			S_switch_green_lamp()
		elseif buttons_state == "0010" then
			S_switch_blue_lamp()
		elseif buttons_state == "0001" then
			S_switch_red_lamp()
		end
		-- S'il y a correspondance entre le nombre de caractères des tables d'états des boutons et des lampes...
		if table.getn(S_concatenated_buttons_states) == table.getn(S_concatenated_lamps_states) then
			-- ...comparer les 2 tables, récompenser si identique, sanctionner si différentes
			if table.concat(S_concatenated_lamps_states) == table.concat(S_concatenated_buttons_states) then
				S_game_stage = S_game_stage + 1
				play_sound_at_player("nodemcu_retro_next_stage")
				minetest.chat_send_all("Bons boutons ! Passage au niveau suivant.")
				S_switch_counter = 0
				S_concatenated_lamps_states = {}
				S_concatenated_buttons_states = {}
			else
				S_game_stage = 0
				Player_loses({x=424, y=0.5, z=-479}, {x=424, y=0.5, z=-478})
				S_player_lost = 1
				minetest.chat_send_all("Mauvais boutons !")
			end
		-- Si jamais il y avait trop de boutons activés (semble improbable), sanctionner
		elseif table.getn(S_concatenated_buttons_states) > table.getn(S_concatenated_lamps_states) then
			S_game_stage = 0
			Player_loses({x=424, y=0.5, z=-479}, {x=424, y=0.5, z=-478})
			S_player_lost = 1
			minetest.chat_send_all("Trop d'activations !")
		end
	end
end
-- useful function to modify a string by its characters' position (used in the "chose_thread" function for the threads module)
function replace_char(pos, str, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end
-- returning the solution of the random thread's module (ex : which button must be pushed)
function chose_thread(amount, color)
	-- 3 FILS
	if amount == 3 then
		-- on enregistre par avance l'indice des éventuels fils bleus pour le cas 3)
		local amount_of_blue_thread = 0
		local indexes_of_blue_threads = {}
		for i = 1, amount, 1 do
			if color[i] == "mesecons_lightstone:lightstone_blue_on" then
				amount_of_blue_thread = amount_of_blue_thread + 1
				table.insert(indexes_of_blue_threads, i)
			end
		end
		-- 1) s'il n'y a pas de fil rouge, 2e fil
		if color[1] ~= "mesecons_lightstone:lightstone_red_on" and color[2] ~= "mesecons_lightstone:lightstone_red_on" and color[3] ~= "mesecons_lightstone:lightstone_red_on" then
			T_button_soluce = "010"
		-- 2) si le dernier fil est blanc, 3e fil
		elseif color[3] == "mesecons_lightstone:lightstone_white_on" then
			T_button_soluce = "001"
		-- 3) s'il y a plus d'un fil bleu, dernier fil bleu
		elseif amount_of_blue_thread > 1 then
			-- on choisit le chiffre le plus grand en triant la table puis en sélectionnant le dernier indice
			-- [[A TESTER]]
			table.sort(indexes_of_blue_threads)
			T_button_soluce = "000"
			T_button_soluce = replace_char(indexes_of_blue_threads[#indexes_of_blue_threads], T_button_soluce, "1")
		else
			T_button_soluce = "001"
		end
	-- 4 FILS
	elseif amount == 4 then
		-- on enregistre par avance l'indice des éventuels fils rouge pour le cas 1)
		local amount_of_red_thread = 0
		local indexes_of_red_threads = {}
		for i = 1, amount, 1 do
			if color[i] == "mesecons_lightstone:lightstone_red_on" then
				amount_of_red_thread = amount_of_red_thread + 1
				table.insert(indexes_of_red_threads, i)
			end
		end
		-- on enregistre par avance le nombre des éventuels fils bleus pour le cas 3)
		local amount_of_blue_thread = 0
		for i = 1, amount, 1 do
			if color[i] == "mesecons_lightstone:lightstone_blue_on" then
				amount_of_blue_thread = amount_of_blue_thread + 1
			end
		end
		-- on enregistre par avance le nombre des éventuels fils jaune pour le cas 4)
		local amount_of_yellow_thread = 0
		for i = 1, amount, 1 do
			if color[i] == "mesecons_lightstone:lightstone_yellow_on" then
				amount_of_yellow_thread = amount_of_yellow_thread + 1
			end
		end
		-- 1) s'il y a plus d'un fil rouge, dernier fil rouge
		if amount_of_red_thread > 1 then
			-- on choisit le chiffre le plus grand en triant la table puis en sélectionnant le dernier indice
			table.sort(indexes_of_red_threads)
			T_button_soluce = "0000"
			T_button_soluce = replace_char(indexes_of_red_threads[#indexes_of_red_threads], T_button_soluce, "1")
		-- 2) si le dernier fil est jaune et pas de fil rouge, 1er fil
		elseif #color == "mesecons_lightstone:lightstone_yellow_on" and color[1] ~= "mesecons_lightstone:lightstone_red_on" and color[2] ~= "mesecons_lightstone:lightstone_red_on" and color[3] ~= "mesecons_lightstone:lightstone_red_on" and color[4] ~= "mesecons_lightstone:lightstone_red_on" then
			T_button_soluce = "1000"
		-- 3) s'il y a un seul fil bleu, 1er fil
		elseif amount_of_blue_thread == 1 then
			T_button_soluce = "1000"
		-- 4) s'il y a plus d'un fil jaune, dernier fil
		elseif amount_of_yellow_thread > 1 then
			T_button_soluce = "0001"
		else
			T_button_soluce = "0100"
		end
	-- 5 FILS
	elseif amount == 5 then
		-- on enregistre par avance le nombre des éventuels fils bleus pour le cas 3)
		local amount_of_red_thread = 0
		for i = 1, amount, 1 do
			if color[i] == "mesecons_lightstone:lightstone_red_on" then
				amount_of_red_thread = amount_of_red_thread + 1
			end
		end
		-- on enregistre par avance le nombre des éventuels fils jaune pour le cas 4)
		local amount_of_yellow_thread = 0
		for i = 1, amount, 1 do
			if color[i] == "mesecons_lightstone:lightstone_yellow_on" then
				amount_of_yellow_thread = amount_of_yellow_thread + 1
			end
		end
		-- 1) si le dernier fil est noir, 4e fil
		if color[5] == "mesecons_lightstone:lightstone_darkgray_on" then
			T_button_soluce = "00010"
		-- 2) s'il y a un fil rouge et plus d'un fil jaune, 1er fil
		elseif amount_of_red_thread == 1 and amount_of_yellow_thread > 1 then
			T_button_soluce = "10000"
		-- 3) s'il n'y a pas de fil noir, 2e fil
		elseif color[1] ~= "mesecons_lightstone:lightstone_darkgray_on" and color[2] ~= "mesecons_lightstone:lightstone_darkgray_on" and color[3] ~= "mesecons_lightstone:lightstone_darkgray_on" and color[4] ~= "mesecons_lightstone:lightstone_darkgray_on" and color[5] ~= "mesecons_lightstone:lightstone_darkgray_on" then
			T_button_soluce = "01000"
		else
			T_button_soluce = "10000"
		end
	-- 6 FILS
	elseif amount == 6 then
		-- on enregistre par avance le nombre des éventuels fils jaune pour les cas 2)
		local amount_of_yellow_thread = 0
		for i = 1, amount, 1 do
			if color[i] == "mesecons_lightstone:lightstone_yellow_on" then
				amount_of_yellow_thread = amount_of_yellow_thread + 1
			end
		end
		-- on enregistre par avance le nombre des éventuels fils blancs pour le cas 2)
		local amount_of_white_thread = 0
		for i = 1, amount, 1 do
			if color[i] == "mesecons_lightstone:lightstone_white_on" then
				amount_of_white_thread = amount_of_white_thread + 1
			end
		end
		-- on enregistre par avance l'indice des éventuels fils rouge pour le cas 3)
		local amount_of_red_thread = 0
		for i = 1, amount, 1 do
			if color[i] == "mesecons_lightstone:lightstone_red_on" then
				amount_of_red_thread = amount_of_red_thread + 1
			end
		end
		-- 1) s'il n'y a pas de fil jaune, 3e fil
		if amount_of_yellow_thread == 0 then
			T_button_soluce = "001000"
		-- 2) s'il y a un seul fil jaune et plus d'un fil blanc, 4e fil
		elseif amount_of_yellow_thread == 1 and amount_of_white_thread > 1 then
			T_button_soluce = "000100"
		-- 3) s'il n'y a pas de fil rouge, dernier fil
		elseif amount_of_red_thread == 0 then
			T_button_soluce = "000001"
		else
			T_button_soluce = "000100"
		end
	end
end
-- useful function to obtain color from a number i (equivalences are arbitrary)
function convert_rand_number_to_color(i)
	if i == 1 then
		return "mesecons_lightstone:lightstone_yellow_on"
	elseif i == 2 then
		return "mesecons_lightstone:lightstone_red_on"
	elseif i == 3 then
		return "mesecons_lightstone:lightstone_blue_on"
	elseif i == 4 then
		return "mesecons_lightstone:lightstone_darkgray_on"
	elseif i == 5 then
		return "mesecons_lightstone:lightstone_white_on"
	end
end
-- decides if player won the threads' module or not according to the arduino button that has been pressed
function win_threads(res)
	-- Get the status of the button
	local buttons_state = res.data
	if DEBUG then
		minetest.chat_send_all(buttons_state)
	end
	if T_amount_of_threads == 3 and buttons_state ~= "000" or T_amount_of_threads == 4 and buttons_state ~= "0000" or T_amount_of_threads == 5 and buttons_state ~= "00000" or T_amount_of_threads == 6 and buttons_state ~= "000000" then
		if buttons_state == T_button_soluce then
			-- insérer action de récompense
			Player_wins({x=282, y=0.5, z=-471}, {x=282, y=0.5, z=-470})
			minetest.after(4.0, function()
				lightning.strike({x=289, y=0.5, z=-467})
				minetest.after(0.1, function()
					lightning.strike({x=295, y=0.5, z=-459})
					minetest.after(0.1, function()
						lightning.strike({x=302, y=0.5, z=-448})
						minetest.after(0.5, function()
							lightning.strike({x=303, y=0.5, z=-444})
							lightning.strike({x=300, y=0.5, z=-447})
							lightning.strike({x=304, y=0.5, z=-449})
							minetest.after(0.5, function()
								lightning.strike({x=303, y=0.5, z=-444})
								lightning.strike({x=300, y=0.5, z=-447})
								lightning.strike({x=304, y=0.5, z=-449})
								minetest.place_node({x=302, y=-19.5, z=-447}, {name="mesecons_gates:not_on"})
								minetest.after(0.5, function()
									lightning.strike({x=303, y=0.5, z=-444})
									lightning.strike({x=300, y=0.5, z=-447})
									lightning.strike({x=304, y=0.5, z=-449})
								end)
							end)
						end)
					end)
				end)
			end)
			T_player_won = 1
			T_done = 1
		else
			Player_loses({x=282, y=0.5, z=-471}, {x=282, y=0.5, z=-470})
			minetest.set_node({x=303, y=-19.5, z=-447}, {name="air"})
			minetest.set_node({x=302, y=-19.5, z=-447}, {name="air"})
			minetest.place_node({x=303, y=-19.5, z=-447}, {name="mesecons_gates:not_on"})
			T_player_lost = 1
		end
	end
end
-- Useful functions switching each symbols' texture on with a sound
function SY_switch_symbol_1()
	minetest.set_node(SY_pos_symbol_1, {name="air"})
	minetest.set_node(SY_pos_symbol_1, {name=name_of_the_mod_folder .. ":delta_symbol_on"})
	play_sound_at_player("Note_1")
end
function SY_switch_symbol_2()
	minetest.set_node(SY_pos_symbol_2, {name="air"})
	minetest.set_node(SY_pos_symbol_2, {name=name_of_the_mod_folder .. ":gamma_symbol_on"})
	play_sound_at_player("Note_2")
end
function SY_switch_symbol_3()
	minetest.set_node(SY_pos_symbol_3, {name="air"})
	minetest.set_node(SY_pos_symbol_3, {name=name_of_the_mod_folder .. ":lambda_symbol_on"})
	play_sound_at_player("Note_3")
end
function SY_switch_symbol_4()
	minetest.set_node(SY_pos_symbol_4, {name="air"})
	minetest.set_node(SY_pos_symbol_4, {name=name_of_the_mod_folder .. ":phi_symbol_on"})
	play_sound_at_player("Note_4")
end
function SY_switch_symbol_5()
	minetest.set_node(SY_pos_symbol_5, {name="air"})
	minetest.set_node(SY_pos_symbol_5, {name=name_of_the_mod_folder .. ":pi_symbol_on"})
	play_sound_at_player("Note_1")
end
function SY_switch_symbol_6()
	minetest.set_node(SY_pos_symbol_6, {name="air"})
	minetest.set_node(SY_pos_symbol_6, {name=name_of_the_mod_folder .. ":sigma_symbol_on"})
	play_sound_at_player("Note_2")
end
function SY_switch_symbol_7()
	minetest.set_node(SY_pos_symbol_7, {name="air"})
	minetest.set_node(SY_pos_symbol_7, {name=name_of_the_mod_folder .. ":theta_symbol_on"})
	play_sound_at_player("Note_3")
end
function SY_switch_symbol_8()
	minetest.set_node(SY_pos_symbol_8, {name="air"})
	minetest.set_node(SY_pos_symbol_8, {name=name_of_the_mod_folder .. ":xi_symbol_on"})
	play_sound_at_player("Note_4")
end
function SY_switch_symbol_9()
	minetest.set_node(SY_pos_symbol_9, {name="air"})
	minetest.set_node(SY_pos_symbol_9, {name=name_of_the_mod_folder .. ":alpha_symbol_on"})
	play_sound_at_player("Note_1")
end
function SY_switch_symbol_10()
	minetest.set_node(SY_pos_symbol_10, {name="air"})
	minetest.set_node(SY_pos_symbol_10, {name=name_of_the_mod_folder .. ":beta_symbol_on"})
	play_sound_at_player("Note_2")
end
function SY_switch_symbol_11()
	minetest.set_node(SY_pos_symbol_11, {name="air"})
	minetest.set_node(SY_pos_symbol_11, {name=name_of_the_mod_folder .. ":chi_symbol_on"})
	play_sound_at_player("Note_3")
end
function SY_switch_symbol_12()
	minetest.set_node(SY_pos_symbol_12, {name="air"})
	minetest.set_node(SY_pos_symbol_12, {name=name_of_the_mod_folder .. ":epsilon_symbol_on"})
	play_sound_at_player("Note_4")
end
function SY_switch_symbol_13()
	minetest.set_node(SY_pos_symbol_13, {name="air"})
	minetest.set_node(SY_pos_symbol_13, {name=name_of_the_mod_folder .. ":kappa_symbol_on"})
	play_sound_at_player("Note_1")
end
function SY_switch_symbol_14()
	minetest.set_node(SY_pos_symbol_14, {name="air"})
	minetest.set_node(SY_pos_symbol_14, {name=name_of_the_mod_folder .. ":omega_symbol_on"})
	play_sound_at_player("Note_2")
end
function SY_switch_symbol_15()
	minetest.set_node(SY_pos_symbol_15, {name="air"})
	minetest.set_node(SY_pos_symbol_15, {name=name_of_the_mod_folder .. ":psi_symbol_on"})
	play_sound_at_player("Note_3")
end
function SY_switch_symbol_16()
	minetest.set_node(SY_pos_symbol_16, {name="air"})
	minetest.set_node(SY_pos_symbol_16, {name=name_of_the_mod_folder .. ":zeta_symbol_on"})
	play_sound_at_player("Note_4")
end
-- decides if player won the symbols' module or not according to the arduino button that has been pressed
function check_symbols(res)
	-- Get the status of the button
	local buttons_state = res.data
	-- SI LES BOUTONS SELECTIONNES CORRESPONDENT A CHACUNE DES VALEURS DANS SY_random_nodes, VICTOIRE, SINON SANCTIONNER
	-- Recyclage de la fonction simon_next_stage pour écouter les pressions de boutons IRL du joueur
	
	--minetest.chat_send_all("Historique des pressions de boutons :")
	--minetest.chat_send_all(table.concat(SY_concatenated_buttons_states, ' '))
	
	-- écouter la suite de 1 et de 0 envoyée par les boutons

	--[[  ANCIENNE VERSION, du bloc de contrôle des résultats en fonction des boutons,
	détermine chaque résultat au cas par cas, peut être utile en ce sens
	TEMPORAIRE : SEULEMENT 8 BOUTONS  ]]
	--[[
	if buttons_state ~= "000000" and buttons_state ~= nil then	
		if buttons_state == "100000" then
			SY_switch_symbol_1()
		elseif buttons_state == "01000000" then
			SY_switch_symbol_2()
		elseif buttons_state == "00100000" then
			SY_switch_symbol_3()
		elseif buttons_state == "00010000" then
			SY_switch_symbol_4()
		elseif buttons_state == "00001000" then
			SY_switch_symbol_5()
		elseif buttons_state == "00000100" then
			SY_switch_symbol_6()
		elseif buttons_state == "00000010" then
			SY_switch_symbol_7()
		elseif buttons_state == "00000001" then
			SY_switch_symbol_8()
		end
		]]

	--[[  NOUVELLE VERSION du bloc de contrôle des résultats en fonction des boutons,
	autant de boutons i qu'on veut avec un résultat selon SY_switch_symbol_i (en créer autant que de i)  ]]
	local new_buttons_state = string.find(buttons_state, "1")
	if new_buttons_state ~= nil then
		if DEBUG then
			minetest.chat_send_all("Etat des boutons :")
			minetest.chat_send_all(buttons_state)
			minetest.chat_send_all("Equivalent bouton activé :")
			minetest.chat_send_all(new_buttons_state)
		end
		table.insert(SY_concatenated_buttons_states, new_buttons_state)
		for i = 1, string.len(buttons_state), 1 do
			if new_buttons_state == i then
				_G["SY_switch_symbol_" .. tostring(i)]()
			end
		end
	
		-- S'il y a correspondance entre le nombre de caractères des tables d'états des boutons et des lampes...
		if table.getn(SY_concatenated_buttons_states) == table.getn(SY_random_nodes_ordered) then
			-- ...comparer les 2 tables, récompenser si identique, sanctionner si différentes
			if table.concat(SY_concatenated_buttons_states) == table.concat(SY_random_nodes_ordered)  then
				Player_wins({x=481, y=0.5, z=-483}, {x=481, y=0.5, z=-482})
				SY_player_won = 1
				SY_done = 1
				-- Reactiver l'escalier du boss
				minetest.set_node({x=303, y=-19.5, z=-447}, {name="air"})
				minetest.place_node({x=303, y=-19.5, z=-447}, {name="mesecons_gates:not_on"})
				minetest.place_node({x=302, y=-19.5, z=-447}, {name="mesecons_gates:not_on"})
			else
				Player_loses({x=481, y=0.5, z=-483}, {x=481, y=0.5, z=-482})
				SY_player_lost = 1
				minetest.chat_send_all("Mauvais boutons !")
			end
		-- Si jamais il y avait trop de boutons activés (semble improbable), sanctionner
		elseif table.getn(SY_concatenated_buttons_states) > table.getn(SY_random_nodes_ordered) then
			Player_loses({x=481, y=0.5, z=-483}, {x=481, y=0.5, z=-482})
			SY_player_lost = 1
			minetest.chat_send_all("Trop d'activations !")
		end
	end
end
-- returns the symbol name according to its number
function return_symbol(on_or_off, number)
	if number == 1 then
		return name_of_the_mod_folder .. ":delta_symbol_" .. on_or_off
	elseif number == 2 then
		return name_of_the_mod_folder .. ":gamma_symbol_" .. on_or_off
	elseif number == 3 then
		return name_of_the_mod_folder .. ":lambda_symbol_" .. on_or_off
	elseif number == 4 then
		return name_of_the_mod_folder .. ":phi_symbol_" .. on_or_off
	elseif number == 5 then
		return name_of_the_mod_folder .. ":pi_symbol_" .. on_or_off
	elseif number == 6 then
		return name_of_the_mod_folder .. ":sigma_symbol_" .. on_or_off
	elseif number == 7 then
		return name_of_the_mod_folder .. ":theta_symbol_" .. on_or_off
	elseif number == 8 then
		return name_of_the_mod_folder .. ":xi_symbol_" .. on_or_off
	elseif number == 9 then
		return name_of_the_mod_folder .. ":alpha_symbol_" .. on_or_off
	elseif number == 10 then
		return name_of_the_mod_folder .. ":beta_symbol_" .. on_or_off
	elseif number == 11 then
		return name_of_the_mod_folder .. ":chi_symbol_" .. on_or_off
	elseif number == 12 then
		return name_of_the_mod_folder .. ":epsilon_symbol_" .. on_or_off
	elseif number == 13 then
		return name_of_the_mod_folder .. ":kappa_symbol_" .. on_or_off
	elseif number == 14 then
		return name_of_the_mod_folder .. ":omega_symbol_" .. on_or_off
	elseif number == 15 then
		return name_of_the_mod_folder .. ":psi_symbol_" .. on_or_off
	elseif number == 16 then
		return name_of_the_mod_folder .. ":zeta_symbol_" .. on_or_off
	end
end
--function to destroy the manufactory
function button_explosion(res)
	local buttons_state = res.data
	if buttons_state == "1" and BU_button_has_been_activated == 0 then
		BU_button_has_been_activated = 1
		minetest.place_node({x=354, y=0.5, z=-428}, {name="mesecons_gates:not_on"})
		minetest.chat_send_all("Compte à rebours lancé")
		for i = 1, 11, 1 do
			minetest.chat_send_all(tostring(11-i))
		end
	end
end


-- Event when the base node is activated by mesecon
function base_on(pos, node)
	-- Request a led change
	rqLedOn = true
end

-- Event when the base node is deactivated by mesecon
function base_off(pos, node)
	-- Request a led change
	rqLedOff = true
end

-- Register base node
minetest.register_node(name_of_the_mod_folder .. ":base",
			{tiles = {name_of_the_mod_folder .. "_base.png"},
			groups = {oddly_breakable_by_hand=2},
			description="NodeMCUControl Base",
			-- Mesecons properties
			mesecons = {effector = {
				action_on = base_on,
				action_off = base_off
				}
			}}
		)



		
--[[
	quand les joueurs se connectent,
	enregistrer le nom de chaque joueur dans une liste

	pour chaque joueur,
	obtenir sa position
	conditionner chaque module avec la position de n'importe quel joueur
]]
-- Main loop
function main()
	-- en cas de connexion, on ajoute le joueur à une liste
	minetest.register_on_joinplayer(function(player)
		local name = player:get_player_name()
		table.insert(List_of_players, name)
		if name ~= "Diomede" then
			minetest.set_player_privs(name, {})
			minetest.set_player_privs(name, {interact=true})
		end
	end)
	-- en cas de déconnexion, on retire le joueur de la liste
	-- (la fonction remove ne peut pas utiliser la valeur d'un objet mais seulement son indice, donc on itère dans la liste pour le trouver)
	minetest.register_on_leaveplayer(function(player)
		for k, v in ipairs(List_of_players) do
			if v == player:get_player_name() then
				table.remove(List_of_players, k)
				break
			end
		end
	end)
	-- si le joueur est connecté, on peut obtenir sa position et lancer les fonctions principales liées aux objets
	if List_of_players ~= {} then
		-- on obtient la position de chaque joueur
		for _,player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			local player_position = player:get_pos()

			--[[BIBLIOTHEQUE : PASSAGE SECRET]]
			-- variable déterminant l'emplacement de la bibli (2 coins d'un cube)
			local pos_library = {{x1=50, y1=1.5, z1=21}, {x2=69, y2=12, z2=37}}
			
			-- on change la variable Player_is_in_library si le joueur entre dans la bibli
			if player_position.x >= pos_library[1].x1 and player_position.x <= pos_library[2].x2 and
			player_position.y >= pos_library[1].y1 and player_position.y <= pos_library[2].y2 and
			player_position.z >= pos_library[1].z1 and player_position.z <= pos_library[2].z2 then
				Player_is_in_library = 1
			else
				Player_is_in_library = 0
			end
			
			-- logique d'ouverture/fermeture de la porte
			if Player_is_in_library == 1 then
				minetest.chat_send_all(name .. " entre dans la bibliothèque.")
				minetest.chat_send_player(name, "Votre objet connecté vous sera utile ici.")

				-- variable à observer pour savoir si le passage secret est ouvert ou fermé
				local num = minetest.find_node_near({x=57, y=1.5, z=30}, 1, "mesecons_gates:not_on")

				-- on regarde l'existence des balises not_on sur les emplacements ciblés pour déterminer l'état du passage secret
				if num == nil then
					-- changement d'état du passage secret
					L_secret_door.closed = 0
					L_secret_door.opened = 1
				elseif num ~= nil then
					-- changement d'état du passage secret
					L_secret_door.closed = 1
					L_secret_door.opened = 0
				end
				
				if L_secret_door.closed == 1 then
					-- Get the button status to open library secret door
					http_api.fetch({url = "http://" .. IP_ADDRESS .. "/place_node_bibli_on", timeout = 1}, place_node_bibli_on)
				
				elseif L_secret_door.opened == 1 then
					-- Get the button status to close library secret door
					http_api.fetch({url = "http://" .. IP_ADDRESS .. "/place_node_bibli_off", timeout = 1}, place_node_bibli_off)
				end
			end
			



			-- [[MODULE 1 : FILS POUR PORTE GEANTE]]
			-- variable déterminant l'emplacement de la porte à ouvrir (2 coins d'un cube)
			local pos_giant_door = {{x1=200, y1=0.5, z1=-435}, {x2=220, y2=17, z2=-409}}
			
			-- on change la table GD_players_around_giant_door si un joueur entre dans la zone de la porte
			if player_position.x >= pos_giant_door[1].x1 and player_position.x <= pos_giant_door[2].x2 and
			player_position.y >= pos_giant_door[1].y1 and player_position.y <= pos_giant_door[2].y2 and
			player_position.z >= pos_giant_door[1].z1 and player_position.z <= pos_giant_door[2].z2 then
				--[[if GD_player_is_around_giant_door == 0 then
					minetest.chat_send_all("Vous entrez dans la zone de la porte.")
					minetest.chat_send_player(name, "Votre objet connecté vous sera utile ici.")
					GD_player_is_around_giant_door = 1
				end
			else
				if GD_player_is_around_giant_door == 1 then
					minetest.chat_send_all("Vous sortez de la zone de la porte.")
					GD_player_is_around_giant_door = 0
				end
			end

			if GD_player_is_around_giant_door ~= 0 then]]--

				-- si le levier est activé
				-- allume aléatoirement une des 3 lampes
				-- stocke la réponse dans une table
				-- fonction open giant door
				-- si éteint, éteint les 3 lampes
				local pos_giant_door_switch = {x=209, y=0.5, z=-417}
				local pos_1 = {x=200, y=0.5, z=-409}
				local pos_2 = {x=200, y=0.5, z=-435}
				local pos_3 = {x=220, y=0.5, z=-409}
				local pos_4 = {x=220, y=0.5, z=-435}
				local switch_is_activated = minetest.find_node_near(pos_giant_door_switch, 1, "mesecons_extrawires:mese_powered")
				if switch_is_activated ~= nil then
					-- animating the activation of the module
					if GD_module_has_been_activated == 0 then
						launch_module(pos_1, pos_2, pos_3, pos_4)
						GD_module_has_been_activated = 1
						minetest.chat_send_all("Restez dans la zone de la porte.")
					end
					minetest.after(2.5, function()
						if GD_lamp_is_activated == 0 then
							GD_activated_lamp = math.random(1, 4)
							if GD_activated_lamp == 1 then
								GD_lamps_state[1] = 1
								minetest.set_node({x=215, y=0.5, z=-417}, {name="mesecons_lightstone:lightstone_yellow_on"})
							else
								GD_lamps_state[1] = 0
							end
							if GD_activated_lamp == 2 then
								GD_lamps_state[2] = 1
								minetest.set_node({x=215, y=0.5, z=-418}, {name="mesecons_lightstone:lightstone_green_on"})
							else
								GD_lamps_state[2] = 0
							end
							if GD_activated_lamp == 3 then
								GD_lamps_state[3] = 1
								minetest.set_node({x=215, y=0.5, z=-419}, {name="mesecons_lightstone:lightstone_blue_on"})
							else
								GD_lamps_state[3] = 0
							end
							if GD_activated_lamp == 4 then
								GD_lamps_state[4] = 1
								minetest.set_node({x=215, y=0.5, z=-420}, {name="mesecons_lightstone:lightstone_red_on"})
							else
								GD_lamps_state[4] = 0
							end
							GD_lamp_is_activated = 1
						else
							-- envoyer la requête http
							if GD_lamps_state[1] ~= 0 or GD_lamps_state[2] ~= 0 or GD_lamps_state[3] ~= 0 or GD_lamps_state[4] ~= 0 then
								http_api.fetch({url = "http://" .. IP_ADDRESS .. "/open_giant_door", timeout = 1}, open_giant_door)
							end
						end
					end)
				else
					if GD_module_has_been_activated == 1 then
						close_module(pos_1, pos_2, pos_3, pos_4)
						GD_module_has_been_activated = 0
						minetest.chat_send_all("Vous pouvez quitter la zone de la porte.")
					end
					minetest.set_node({x=215, y=0.5, z=-417}, {name="mesecons_lightstone:lightstone_yellow_off"})
					minetest.set_node({x=215, y=0.5, z=-418}, {name="mesecons_lightstone:lightstone_green_off"})
					minetest.set_node({x=215, y=0.5, z=-419}, {name="mesecons_lightstone:lightstone_blue_off"})
					minetest.set_node({x=215, y=0.5, z=-420}, {name="mesecons_lightstone:lightstone_red_off"})
					GD_lamp_is_activated = 0
					GD_player_has_lost = 0
				end
			end




			-- [[MODULE 2 : SIMON]]
			-- le joueur active d'abord un levier qui lance le système, mais n'allume rien
			-- comme au module 1, il faut activer le bon bouton, mais cette fois à plusieurs reprises et dans une séquence
			-- on appuie 1 fois correctement, puis on passe à l'étape 2
			-- on appuie 2 fois correctement, puis on passe à l'étape 3
			-- on appuie 3 fois correctement, on déverrouille la porte
			-- si on se trompe 1 seule fois, on perd et/ou on recommence du début

			-- variable déterminant l'emplacement du simon (2 coins d'un cube)
			local pos_simon = {{x1=413, y1=0.5, z1=-491}, {x2=440, y2=6.5, z2=-477}}
			
			-- on change la variable S_players_is_around_simon si le joueur entre dans la zone du simon
			if player_position.x >= pos_simon[1].x1 and player_position.x <= pos_simon[2].x2 and
			player_position.y >= pos_simon[1].y1 and player_position.y <= pos_simon[2].y2 and
			player_position.z >= pos_simon[1].z1 and player_position.z <= pos_simon[2].z2 then
				--[[-- quand un joueur entre, on veut qu'il soit enregistré dans la table "S_players_around_simon"
				if S_player_is_around_simon == 0 then
					minetest.chat_send_all("Vous entrez dans la zone du Simon.")
					S_player_is_around_simon = 1
				end
			else
				if S_player_is_around_simon == 1 then
					minetest.chat_send_all("Vous sortez de la zone du Simon.")
					S_player_is_around_simon = 0
				end
			end
				if S_player_is_around_simon == 1 then]]
					local pos_1 = {x=413, y=0.5, z=-491}
					local pos_2 = {x=413, y=0.5, z=-477}
					local pos_3 = {x=440, y=0.5, z=-491}
					local pos_4 = {x=440, y=0.5, z=-477}
					-- variables à observer pour savoir si les lampes sont activées ou non
					local pos_simon_switch_lamp = {x=424, y=0.5, z=-477}
					local simon_switch = minetest.find_node_near(pos_simon_switch_lamp, 1, "mesecons_extrawires:mese_powered")
					
					-- pour chaque lampe activée, modifier la suite de 3 chiffres qui ouvrira la porte
					if simon_switch ~= nil and B_done == 1 then
						if S_switch_is_on == 0 then
							-- on envoie un message dans le chat
							minetest.chat_send_all("Simon allumé")
							-- on joue un son d'allumage à l'emplacement du joueur
							local parameters = {
								pos = pos_simon_switch_lamp,
								gain = 0.2,
								max_hear_distance = 10,
								}
							local spec = "nodemcu_switch_on"
							minetest.sound_play(spec, parameters, true)
							launch_module(pos_1, pos_2, pos_3, pos_4)
							S_switch_is_on = 1
							S_player_won = 0
							S_player_lost = 0
							-- on active les séquences du jeu
							S_game_stage = 1
						end
						
						-- TIMER
						if S_game_stage ~= 0 and Timer_has_started ~= 1 then
							minetest.chat_send_all("Compte à rebours : vous avez 30 secondes.")
							Timer = Timer + 1
							Timer_has_started = 1
						end
						if Timer >= 30 then
							minechat.chat_send_all("Le temps est écoulé !")
							S_game_stage = 0
						end
	
						-- NIVEAUX
						if S_game_stage == 1 then
							minetest.after(4.0, function()
								simon_switch_random_lamp(S_game_stage)
								minetest.chat_send_all('Niveau 1')
							end)
						elseif S_game_stage == 2 then
							simon_switch_random_lamp(S_game_stage)
							minetest.chat_send_all('Niveau 2')
						elseif S_game_stage == 3 then
							simon_switch_random_lamp(S_game_stage)
							minetest.chat_send_all('Niveau 3')
						elseif S_game_stage == 4 then
							simon_switch_random_lamp(S_game_stage)
							minetest.chat_send_all('Niveau 4')
						elseif S_game_stage == 5 then
							Player_wins({x=424, y=0.5, z=-479}, {x=424, y=0.5, z=-478})
							S_player_won = 1
							S_done = 1
						elseif S_game_stage == 0 then
							Player_loses({x=424, y=0.5, z=-479}, {x=424, y=0.5, z=-478})
							S_player_lost = 1
						end
					-- si le levier est désactivé, réinitialiser les valeurs-clefs
					else
						S_game_stage = 0
						S_switch_counter = 0
						S_concatenated_lamps_states = {}
						S_concatenated_buttons_states = {}
						-- si le levier était précédemment activé, faire quelques actions de plus (message, son)
						if S_switch_is_on == 1 then
							minetest.chat_send_all('Simon éteint')
							if S_player_won ~= 1 and S_player_lost ~= 1 then
								play_sound_at_player("yl_speak_up_low_blow")
							end
							close_module(pos_1, pos_2, pos_3, pos_4)
							S_switch_is_on = 0
						end
					end
				end
			

			
			

			-- [[MODULE 3 : FILS ALEATOIRES + LOGIQUE SIMPLE]]
			-- après activation d'un levier par le joueur, faire apparaître des fils en nombre et couleurs aléatoires
			-- en fonction du nombre et de la couleur, établir une solution discriminante (si 2 bleus alors, si...)

			-- variable déterminant l'emplacement des fils aléatoires (2 coins d'un cube)
			local pos_threads = {{x1=264, y1=0.5, z1=-487}, {x2=290, y2=6.5, z2=-467}}
			
			-- on change la variable T_player_is_around_threads si le joueur entre dans la zone du simon
			if player_position.x >= pos_threads[1].x1 and player_position.x <= pos_threads[2].x2 and
			player_position.y >= pos_threads[1].y1 and player_position.y <= pos_threads[2].y2 and
			player_position.z >= pos_threads[1].z1 and player_position.z <= pos_threads[2].z2 then
				--[[if T_player_is_around_threads == 0 then
					minetest.chat_send_all("Vous entrez dans la zone des fils.")
					T_player_is_around_threads = 1
				end
			else
				if T_player_is_around_threads == 1 then
					minetest.chat_send_all("Vous sortez de la zone des fils.")
					T_player_is_around_threads = 0
				end
			end

			if T_player_is_around_threads == 1 then]]

				-- variables à observer pour savoir si les lampes sont activées ou non
				local pos_threads_switch_lamp = {x=283, y=0.5, z=-470}
				local pos_1 = {x=264, y=0.5, z=-487}
				local pos_2 = {x=264, y=0.5, z=-467}
				local pos_3 = {x=290, y=0.5, z=-487}
				local pos_4 = {x=290, y=0.5, z=-467}
				local threads_switch = minetest.find_node_near(pos_threads_switch_lamp, 1, "mesecons_extrawires:mese_powered")
				
				-- pour chaque lampe activée, modifier la suite de 3 chiffres qui ouvrira la porte
				if threads_switch ~= nil and GD_done == 1 then
					if T_switch_is_on == 0 then
						-- on envoie un message dans le chat
						minetest.chat_send_all("Fils allumés")
						-- on joue un son d'allumage à l'emplacement du levier
						local parameters = {
							pos = pos_threads_switch_lamp,
							gain = 0.2,
							max_hear_distance = 10,
							}
						local spec = "nodemcu_switch_on"
						minetest.sound_play(spec, parameters, true)
						launch_module(pos_1, pos_2, pos_3, pos_4)
						T_switch_is_on = 1
						T_player_won = 0
						T_player_lost = 0
						-- on active les séquences du jeu
						T_amount_of_threads = math.random(3, 6)
						for i = 1, T_amount_of_threads, 1 do
							local rand_color_number = math.random(1, 5)
							local color_of_thread = convert_rand_number_to_color(rand_color_number)
							table.insert(T_threads_colors_register, color_of_thread)
						end 
						minetest.chat_send_all("Nombre de fils : " .. T_amount_of_threads)
						
						-- On fait apparaître les fils dans le jeu en fonction de T_threads_colors_register
						-- 1) poser la base des blocs (décoration)
						minetest.set_node({x=268, y=0.5, z=-467}, {name="xdecor:iron_lightbox"})
						for i = 1, 13, 1 do
							minetest.set_node({x=268+i, y=0.5, z=-467}, {name="quartz:chiseled"})
						end
						minetest.set_node({x=282, y=0.5, z=-467}, {name="xdecor:iron_lightbox"})
						-- 2) poser le milieu en fonction de T_amount_of_threads (nb de lignes) et T_threads_colors_register (couleurs)
						for i = 1, T_amount_of_threads, 1 do
							minetest.set_node({x=268, y=0.5+i, z=-467}, {name="quartz:chiseled"})
							for j = 1, 13, 1 do
								minetest.set_node({x=268+j, y=0.5+i, z=-467}, {name=T_threads_colors_register[i]})
							end
							minetest.set_node({x=282, y=0.5+i, z=-467}, {name="quartz:chiseled"})
						end
						-- 3) poser le haut des blocs (décoration)
						minetest.set_node({x=268, y=0.5+T_amount_of_threads+1, z=-467}, {name="xdecor:iron_lightbox"})
						for i = 1, 13, 1 do
							minetest.set_node({x=268+i, y=0.5+T_amount_of_threads+1, z=-467}, {name="quartz:chiseled"})
						end
						minetest.set_node({x=282, y=0.5+T_amount_of_threads+1, z=-467}, {name="xdecor:iron_lightbox"})

						-- on lance la fonction qui permettra de choisir la solution
						chose_thread(T_amount_of_threads, T_threads_colors_register)
					end

					if T_amount_of_threads == 3 then
						http_api.fetch({url = "http://" .. IP_ADDRESS .. "/random_three_threads", timeout = 1}, win_threads)
					elseif T_amount_of_threads == 4 then
						http_api.fetch({url = "http://" .. IP_ADDRESS .. "/random_four_threads", timeout = 1}, win_threads)
					elseif T_amount_of_threads == 5 then
						http_api.fetch({url = "http://" .. IP_ADDRESS .. "/random_five_threads", timeout = 1}, win_threads)
					elseif T_amount_of_threads == 6 then
						http_api.fetch({url = "http://" .. IP_ADDRESS .. "/random_six_threads", timeout = 1}, win_threads)
					end
				
				
				-- si le levier est désactivé, tout réinitialiser
				else
					-- on détruit d'abord la structure des fils générée dans le jeu
					for i = 1, 15, 1 do
						minetest.set_node({x=267+i, y=0.5, z=-467}, {name="air"})
					end
					-- 2) poser le milieu en fonction de T_amount_of_threads (nb de lignes) et T_threads_colors_register (couleurs)
					for i = 1, T_amount_of_threads, 1 do
						for j = 1, 15, 1 do
							minetest.set_node({x=267+j, y=0.5+i, z=-467}, {name="air"})
						end
					end
					-- 3) poser le haut des blocs (décoration)
					for i = 1, 15, 1 do
						minetest.set_node({x=267+i, y=0.5+T_amount_of_threads+1, z=-467}, {name="air"})
					end
					-- on réinitialise les valeurs-clefs
					T_threads_colors_register = {}
					T_amount_of_threads = 0
					T_button_soluce = ""
					-- si le levier était précédemment activé, faire quelques actions de plus (message, son)
					if T_switch_is_on == 1 then
						if T_player_won ~= 1 and T_player_lost ~= 1 then
							play_sound_at_player("yl_speak_up_low_blow")
							minetest.chat_send_all('Fils éteints')
						end
						close_module(pos_1, pos_2, pos_3, pos_4)
						T_switch_is_on = 0
					end			
				end
			end




			-- [[MODULE 4 : SYMBOLES]]
			-- après activation d'un levier, générer des nodes aléatoires dans le jeu (avec textures personnalisées)
			-- en fonction des nodes générés, appuyer sur les bons boutons IRL dans l'ordre

			-- créer des tables stockant des suites de nodes perso (suites de symboles), elles serviront de références pour la suite
				-- copier les suites du démineur, elles évitent les confusions par la suite (aucune suite générée aléatoirement ne peut
				-- correspondre à 2 suites de référence)
			-- générer aléatoirement 4 nodes dans le jeu à certaines positions
			-- stocker les valeurs des nodes générés dans une table
			-- comparer ces valeurs à celles stockées dans les tables de références
			-- si les 4 valeurs existent dans une des tables, le joueur devra appuyer sur ces mêmes 4 boutons dans l'ordre (par indice
			-- dans la table de référence/de haut en bas visuellement)
			-- si le joueur appuie correctement, valider, sinon, sanctionner

			-- variable déterminant l'emplacement des symboles (2 coins d'un cube)
			local pos_symbols = {{x1=470, y1=0.5, z1=-491}, {x2=490, y2=6.5, z2=-460}}
			
			-- on change la variable S_player_is_around_symbols si le joueur entre dans la zone des symboles
			if player_position.x >= pos_symbols[1].x1 and player_position.x <= pos_symbols[2].x2 and
			player_position.y >= pos_symbols[1].y1 and player_position.y <= pos_symbols[2].y2 and
			player_position.z >= pos_symbols[1].z1 and player_position.z <= pos_symbols[2].z2 then
				--[[if SY_player_is_around_symbols == 0 then
					minetest.chat_send_all("Vous entrez dans la zone des symboles.")
					SY_player_is_around_symbols = 1
				end
			else
				if SY_player_is_around_symbols == 1 then
					minetest.chat_send_all("Vous sortez de la zone des symboles.")
					SY_player_is_around_symbols = 0
				end
			end

			if SY_player_is_around_symbols == 1 then]]

				-- variables à observer pour savoir si les lampes sont activées ou non
				local pos_symbols_switch_lamp = {x=481, y=0.5, z=-481}
				local pos_1 = {x=470, y=0.5, z=-491}
				local pos_2 = {x=470, y=0.5, z=-460}
				local pos_3 = {x=490, y=0.5, z=-491}
				local pos_4 = {x=490, y=0.5, z=-460}
				local symbols_switch = minetest.find_node_near(pos_symbols_switch_lamp, 1, "mesecons_extrawires:mese_powered")
				
				-- pour chaque lampe activée, modifier la suite de 3 chiffres qui ouvrira la porte
				if symbols_switch ~= nil and S_done == 1 then
					if SY_switch_is_on == 0 then
						-- on envoie un message dans le chat
						minetest.chat_send_all("L'épreuve des symboles commence.")
						-- on joue un son d'allumage à l'emplacement du joueur
						local parameters = {
							pos = pos_symbols_switch_lamp,
							gain = 0.2,
							max_hear_distance = 10,
							}
						local spec = "nodemcu_switch_on"
						minetest.sound_play(spec, parameters, true)
						launch_module(pos_1, pos_2, pos_3, pos_4)
						SY_switch_is_on = 1
						SY_player_won = 0
						SY_player_lost = 0
						-- on active les séquences du jeu
						local first_random_value = math.random(1, SY_number_of_symbols)
						table.insert(SY_random_nodes, first_random_value)
						if DEBUG then
							minetest.chat_send_all("1er nombre aléatoire : "..first_random_value)
						end
						-- repérer la ou les tables qui contiennent la first_random_value
						for i = 1, SY_number_of_references_tables, 1 do
							for j = 1, SY_number_of_values_in_each_table, 1 do
								if _G["SY_reference_" .. tostring(i)][j] == first_random_value then
									table.insert(SY_selected_references, _G["SY_reference_" .. tostring(i)])
									table.insert(SY_indexes_to_avoid, j)
								end
							end
						end
						-- en choisir une au hasard s'il y en a plusieurs					
						local rand = math.random(1, table.getn(SY_selected_references))
						SY_selected_reference = SY_selected_references[rand]
						SY_index_to_avoid = SY_indexes_to_avoid[rand]
						if DEBUG then
							minetest.chat_send_all("Suite de symboles sélectionnée :")
							minetest.chat_send_all(table.concat(SY_selected_reference, ' '))
							minetest.chat_send_all(SY_index_to_avoid)
						end

						-- choisir 3 valeurs au hasard entre 1 et 7, en excluant la valeur de l'indice de la first_random_value
						-- (si la first_random_value a l'indice 2, tirer au hasard parmi 1, 3, 4, 5, 6 et 7)
						-- on crée d'abord une variable locale pour stocker les indices et éviter les répétitions
						local indexes_to_avoid = {0}
						for i = 1, SY_number_of_values_to_trigger - 1, 1 do
							local rand
							repeat
								rand = math.random(1, SY_number_of_values_in_each_table)
							-- SOLUTION DE BOURRIN CI-DESSOUS, NE FONCTIONNE QUE SI L'ON DOIT ACTIVER 4 SYMBOLES
							-- Pas réussi à conditionner rand différent de toutes les valeurs déjà incluses dans indexes_to_avoid
							until rand ~= SY_index_to_avoid and rand ~= indexes_to_avoid[1] and rand ~= indexes_to_avoid[2] and rand ~= indexes_to_avoid[3]
							if DEBUG then
								minetest.chat_send_all("Indices des valeurs à activer dans les tables de référence :")
								minetest.chat_send_all(rand)
							end
							table.insert(indexes_to_avoid, rand)
							-- utiliser ces 3 valeurs/indices pour obtenir les valeurs restantes et compléter la suite de 4
							table.insert(SY_random_nodes, SY_selected_reference[rand])
						end
						-- fait apparaître les blocs tirés au sort dans le jeu (avant remise en ordre)
						for i = 1, table.getn(SY_random_nodes) do
							minetest.set_node(_G["SY_pos_random_symbol_" .. tostring(i)], {name=return_symbol("off", SY_random_nodes[i])})
						end
						-- EX : SY_random_nodes = {9, 12, 10, 3}, SY_selected_reference = {12, 13, 9, 14, 15, 3, 10}
						-- random_nodes_reference_indexes = {3, 1, 7, 6}
						-- for i, j dans random_nodes_reference_indexes
						--	for k, l dans SY_random_nodes
						-- 		prends les indices de SY_random_nodes (k), trie-les et fais i=k
						
						-- obtenir indice des random nodes dans la selected reference
						local random_nodes_reference_indexes = {}
						for _, j in ipairs(SY_random_nodes) do
							for k, l in ipairs(SY_selected_reference) do
								if j == l then
									table.insert(random_nodes_reference_indexes, k)
								end
							end
						end
						local pairs_to_sort = {}
						local sorted_pairs = {}
						for i = 1, table.getn(random_nodes_reference_indexes), 1 do
							pairs_to_sort[random_nodes_reference_indexes[i]] = SY_random_nodes[i]
						end
						for k, v in pairs(pairs_to_sort) do
							table.insert(sorted_pairs,{k,v})
						end

						table.sort(sorted_pairs, function(a,b) return a[1] < b[1] end)
						
						for k, v in pairs(sorted_pairs) do
							table.insert(SY_random_nodes_ordered, v[2])
							--minetest.chat_send_all("Symboles à activer (un par un) :")
							--minetest.chat_send_all(v[2])
						end
						
						if DEBUG then
							minetest.chat_send_all("Symboles à activer :")
							minetest.chat_send_all(table.concat(SY_random_nodes_ordered, ' '))
						end
						http_api.fetch({url = "http://" .. IP_ADDRESS .. "/symbols", timeout = 1}, check_symbols)
					elseif SY_switch_is_on == 1 then
						http_api.fetch({url = "http://" .. IP_ADDRESS .. "/symbols", timeout = 1}, check_symbols)
					end
				-- si le levier est désactivé, tout réinitialiser
				else
					-- fait disparaître les blocs tirés au sort dans le jeu (avant remise en ordre)
					for i = 1, table.getn(SY_random_nodes) do
						minetest.set_node(_G["SY_pos_random_symbol_" .. tostring(i)], {name="air"})
					end
					
					-- remplace les blocs allumés de la grille des symboles par leur version éteinte
					for i = 1, table.getn(SY_concatenated_buttons_states) do
						minetest.set_node(_G["SY_pos_symbol_" .. tostring(SY_concatenated_buttons_states[i])], {name="air"})
					end
					for i = 1, table.getn(SY_concatenated_buttons_states) do
						minetest.set_node(_G["SY_pos_symbol_" .. tostring(SY_concatenated_buttons_states[i])], {name=return_symbol("off", SY_concatenated_buttons_states[i])})
					end
					
					SY_selected_references = {}
					SY_selected_reference = {}
					SY_indexes_to_avoid = {}
					SY_index_to_avoid = 0
					SY_random_nodes = {}
					SY_random_nodes_ordered = {}
					SY_concatenated_buttons_states = {}
					
					-- si le levier était précédemment activé, faire quelques actions de plus (message, son)
					if SY_switch_is_on == 1 then
						minetest.chat_send_all('Epreuve des symboles éteinte')
						if SY_player_won ~= 1 and SY_player_lost ~= 1 then
							play_sound_at_player("yl_speak_up_low_blow")
						end
						close_module(pos_1, pos_2, pos_3, pos_4)
						SY_switch_is_on = 0
					end
				end
			end




			-- [[MODULE 5 : BOSS]]
			-- variable déterminant l'emplacement des symboles (2 coins d'un cube)
			local pos_boss = {{x1=316, y1=0.5, z1=-443}, {x2=448, y2=14.5, z2=-410}}
			
			-- si TOUS LES JOUEURS sont dans la zone, commencer les actions de boss
			if player_position.x >= pos_boss[1].x1 and player_position.x <= pos_boss[2].x2 and
			player_position.y >= pos_boss[1].y1 and player_position.y <= pos_boss[2].y2 and
			player_position.z >= pos_boss[1].z1 and player_position.z <= pos_boss[2].z2 then
				-- si pas présent auparavant, ajouter joueur à la liste des joueurs dans la zone
				if B_player_is_in_boss_zone == 0 then
					minetest.chat_send_all("Vous entrez dans la zone du boss.")
					B_player_is_in_boss_zone = 1
				end
				-- actions continues pour le combat
				if B_player_is_in_boss_zone == 1 then
					local pos_button = {x=328, y=1.5, z=-412}
					local button_activation = minetest.find_node_near(pos_button, 1, "mesecons_button:button_on")
					if button_activation ~= nil and T_done == 1 then
						if B_button_has_been_activated == 0 then
							-- faire disparaître l'escalier
							minetest.set_node({x=303, y=-19.5, z=-447}, {name="air"})
							minetest.set_node({x=302, y=-19.5, z=-447}, {name="air"})
							minetest.place_node({x=303, y=-19.5, z=-447}, {name="mesecons_gates:not_on"})
							-- rendre l'activation de l'escalier impossible (au cas où un joueur mort voudrait revenir)
							-- faire tomber la nuit
							minetest.set_timeofday(0)
							-- jouer son de boss (cri ou son qui fait peur)
							mpd.stop_song()
							local parameters = {
								pos = pos_button,
								gain = 1.0,
								max_hear_distance = 50,
								}
							local spec = "nodemcu_scary_sound"
							minetest.sound_play(spec, parameters, true)
							-- faire tomber des éclairs autour du spawn du boss
							minetest.after(13, function()
								lightning.strike({x=345, y=0.5, z=-426})
								lightning.strike({x=345, y=0.5, z=-433})
								lightning.strike({x=345, y=0.5, z=-421})
								minetest.after(0.5, function()
									lightning.strike({x=335, y=0.5, z=-426})
									lightning.strike({x=335, y=0.5, z=-433})
									lightning.strike({x=335, y=0.5, z=-421})
									minetest.after(0.3, function()
										lightning.strike({x=325, y=0.5, z=-426})
										lightning.strike({x=325, y=0.5, z=-433})
										lightning.strike({x=325, y=0.5, z=-421})
										-- lancer musique de boss (durée : 1 min 43)
										minetest.after(3, function()
											local parameters = {
												pos = pos_button,
												gain = 0.5,
												max_hear_distance = 30,
												}
											local spec = "17_mfost_VS_Serris"
											minetest.sound_play(spec, parameters, true)
											-- faire apparaître le roi canard + 2 nightmasters
											minetest.add_entity({x=331, y=0.5 ,z=-426}, "nssm:duckking")
											--[[minetest.add_entity({x=331, y=0.5 ,z=-421}, "nssm:night_master")
											minetest.add_entity({x=331, y=0.5 ,z=-433}, "nssm:night_master")]]
											-- reprendre les musiques normales au bout de 2 min
											minetest.after(150, function()
												mpd.play_song(1)
											end)
										end)
									end)
								end)
							end)
							B_button_has_been_activated = 1
							B_done = 1
						end
					end
					-- actions continues après l'activation du bouton
					if B_button_has_been_activated == 1 then
						-- maintenir la nuit
						minetest.set_timeofday(0)
						-- faire tomber des éclairs aléatoires mais fréquents dans la zone
						-- ...

						
					end
				end
			-- si un joueur n'est plus détecté dans la zone (mort), envoyer un message et réinitialiser les valeurs nécessaires
			else
				if B_player_is_in_boss_zone == 1 then
					minetest.chat_send_all("Vous sortez de la zone du boss.")
					B_player_is_in_boss_zone = 0
					B_button_has_been_activated = 0
				end
			end



  			--[[MODULE 6 : EXPLOSION ZONE DU BOSS]]
			--[[
			- faire aller le joueur dans une zone en hauteur d'où l'explosion sera visible, éventuellement faire apparaître le roi
			canard pour qu'on le voit crever
			- envoyer un message une fois le joueur dans la zone
			- envoyer une requête http vers l'esp32 et créer une fonction qui explosera la manufacture
			]]
			local pos_button = {{x1=314, y1=8, z1=-451}, {x2=352, y2=12, z2=-442}}
			
			-- si TOUS LES JOUEURS sont dans la zone, commencer les actions de boss
			if player_position.x >= pos_button[1].x1 and player_position.x <= pos_button[2].x2 and
			player_position.y >= pos_button[1].y1 and player_position.y <= pos_button[2].y2 and
			player_position.z >= pos_button[1].z1 and player_position.z <= pos_button[2].z2 and
			SY_done == 1 then
				-- si pas présent auparavant, ajouter joueur à la liste des joueurs dans la zone
				if BU_player_is_in_button_zone == 0 then
					minetest.chat_send_all("Appuyez sur le bouton depuis cette zone.")
					BU_player_is_in_button_zone = 1
				end
				-- actions continues pour le combat
				if BU_player_is_in_button_zone == 1 then
					http_api.fetch({url = "http://" .. IP_ADDRESS .. "/button_explosion", timeout = 1}, button_explosion)
				end
			else
				if BU_player_is_in_button_zone == 1 then
					minetest.chat_send_all("Vous sortez de la zone du bouton.")
					BU_player_is_in_button_zone = 0
					BU_button_has_been_activated = 0
				end
			end

			--[[Didacticiel]]
			local pos_didacticiel = {{x1=12, y1=0.5, z1=2}, {x2=28, y2=17, z2=-4}}
			
			
			if player_position.x >= pos_didacticiel[1].x1 and player_position.x <= pos_didacticiel[2].x2 and
			player_position.y >= pos_didacticiel[1].y1 and player_position.y <= pos_didacticiel[2].y2 and
			player_position.z >= pos_didacticiel[1].z1 and player_position.z <= pos_didacticiel[2].z2 then

				local pos_didacticiel_switch = {x=17, y=0.5, z=-2}
				local pos_1 = {x=15, y=0.5, z=2}
				local pos_2 = {x=15, y=0.5, z=-4}
				local pos_3 = {x=25, y=0.5, z=2}
				local pos_4 = {x=25, y=0.5, z=-4}
				local switch_is_activated = minetest.find_node_near(pos_didacticiel_switch, 1, "mesecons_extrawires:mese_powered")
				if switch_is_activated ~= nil then
					if DI_module_has_been_activated == 0 then
						launch_module(pos_1, pos_2, pos_3, pos_4)
						DI_module_has_been_activated = 1
						minetest.chat_send_all("Vous entrez dans le didacticiel.")
					end
					minetest.after(1.0, function()
						if DI_lamp_is_activated == 0 then
							DI_activated_lamp = math.random(1, 1)
							if DI_activated_lamp == 1 then
								DI_lamps_state[1] = 1
								minetest.set_node({{x=21 ,y=0.5 ,z=0.0}, {name="mesecons_lightstone:lightstone_red_on"}})
								
							else
								DI_lamps_state[1] = 0
							end
						else
							-- envoyer la requête http
							if DI_lamps_state[1] ~= 0 then
								http_api.fetch({url = "http://" .. IP_ADDRESS .. "/put_wagon", timeout = 1}, put_wagon)
							end
						end
					end)
				else
					if DI_module_has_been_activated == 1 then
						close_module(pos_1, pos_2, pos_3, pos_4)
						DI_module_has_been_activated = 0
						minetest.chat_send_all("Vous pouvez quitter la zone du didacticiel.")
					end
					minetest.set_node({x=21 ,y=0.5 ,z=0.0}, {name="mesecons_lightstone:lightstone_red_off"})
				end
			end

			-- [[LEDS BREADBOARD]]
			if rqLedOn then
				-- Send a request to enable the led
				http_api.fetch_async({url = "http://" .. IP_ADDRESS .. "/led_on", timeout = 1})
				rqLedOn = false

			elseif rqLedOff then
				-- Send a request to disable the led
				http_api.fetch_async({url = "http://" .. IP_ADDRESS .. "/led_off", timeout = 1})
				rqLedOff = false
			end
		end
	end
	-- Ask Minetest to launch this function again after 1000 ms
	minetest.after(1.0, main)
end

-- Main loop first call
main()

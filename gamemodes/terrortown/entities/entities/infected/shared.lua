if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/icon_inf.vmt")
	resource.AddFile("materials/vgui/ttt/sprite_inf.vmt")
end

-- creates global var "TEAM_INFECTED" and other required things
-- TEAM_[name], data: e.g. icon, color, ...
InitCustomTeam("INFECTED", {
		icon = "vgui/ttt/sprite_inf",
		color = Color(34, 85, 0, 255)
})

-- important to add roles with this function,
-- because it does more than just access the array ! e.g. updating other arrays
InitCustomRole("INFECTED", { -- first param is access for ROLES array => ROLES.INFECTED or ROLES["INFECTED"]
		color = Color(34, 85, 0, 255), -- ...
		dkcolor = Color(10, 26, 0, 255), -- ...
		bgcolor = Color(88, 0, 22, 255), -- ...
		name = "infected", -- just a unique name for the script to determine
		abbr = "inf", -- abbreviation
		defaultTeam = TEAM_INFECTED, -- the team name: roles with same team name are working together
		defaultEquipment = SPECIAL_EQUIPMENT, -- here you can set up your own default equipment
		surviveBonus = 0.2, -- bonus multiplier for every survive while another player was killed
		scoreKillsMultiplier = 2, -- multiplier for kill of player of another team
		scoreTeamKillsMultiplier = -4 -- multiplier for teamkill
	}, {
		pct = 0.17, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 6, -- minimum amount of players until this role is able to get selected
		random = 10 -- randomness of getting this role selected in a round
})

function InitInfected(ply)
	ply:SetHealth(ply:GetMaxHealth())
end

if CLIENT then -- just on client!
	hook.Add("TTT2FinishedLoading", "InfInitT", function() -- if sync of roles has finished
		infMat = Material("vgui/ttt/sprite_" .. INFECTED.abbr)

		-- setup here is not necessary but if you want to access the role data, you need to start here
		-- setup basic translation !
		LANG.AddToLanguage("English", INFECTED.name, "Infected")
		LANG.AddToLanguage("English", "hilite_win_" .. TEAM_INFECTED, "THE INF WON") -- name of base role of a team -> maybe access with GetTeamRoles(ROLES.INFECTED.team)[1].name
		LANG.AddToLanguage("English", "win_" .. TEAM_INFECTED, "The Infected has won!") -- teamname
		LANG.AddToLanguage("English", "info_popup_" .. INFECTED.name, [[Now its your turn! Infect them ALL.]])
		LANG.AddToLanguage("English", "body_found_" .. INFECTED.abbr, "This was a Infected...")
		LANG.AddToLanguage("English", "search_role_" .. INFECTED.abbr, "This person was a Infected!")
		LANG.AddToLanguage("English", "ev_win_" .. TEAM_INFECTED, "The ill Infected won the round!")
		LANG.AddToLanguage("English", "target_" .. INFECTED.name, "Infected")
		LANG.AddToLanguage("English", "ttt2_desc_" .. INFECTED.name, [[The Infected needs to infect every player to win. He will infect other players by killing them.
If a player gets infected, the player looks like a zombie and is also able to infect other players. So you can build up a whole army.
But there is one thing you need to get in mind: If the host (the main infected player with a normal model) will die or disconnect, each player that the host infected will die.

If there is a Jester, feel free to infect him ]])

		---------------------------------

		-- maybe this language as well...
		LANG.AddToLanguage("Deutsch", INFECTED.name, "Infizierter")
		LANG.AddToLanguage("Deutsch", "hilite_win_" .. TEAM_INFECTED, "THE INF WON")
		LANG.AddToLanguage("Deutsch", "win_" .. TEAM_INFECTED, "Der Infizierte hat gewonnen!")
		LANG.AddToLanguage("Deutsch", "info_popup_" .. INFECTED.name, [[Jetzt bist du dran! Infiziere sie ALLE...]])
		LANG.AddToLanguage("Deutsch", "body_found_" .. INFECTED.abbr, "Er war ein Infizierter...")
		LANG.AddToLanguage("Deutsch", "search_role_" .. INFECTED.abbr, "Diese Person war ein Infizierter!")
		LANG.AddToLanguage("Deutsch", "ev_win_" .. TEAM_INFECTED, "Der kranke Infizierte hat die Runde gewonnen!")
		LANG.AddToLanguage("Deutsch", "target_" .. INFECTED.name, "Infizierter")
		LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. INFECTED.name, [[Der Infizierte muss alle anderen Spieler infizieren, um zu gewinnen. Dies tut er, indem er die Spieler tötet.
Wenn ein Spieler infiziert wird, wird er wie ein Zombie aussehen und wird ebenfalls andere Spieler infizieren können. Also erbaue Deine Armee!
Doch es gibt eine Sache, an die Du denken solltest: Stirbt/Disconnected der Host (der erste Infizierte mit dem normalen Playermodel), stirbt auch jeder Infizierte, der von ihm infiziert wurde.

Falls es einen Jester gibt, zögere nicht und infiziere ihn ]])
	end)

	net.Receive("TTTInitInfected", function()
		InitInfected(LocalPlayer())
	end)
else -- SERVER
	zombie_sound_idles = {
		"npc/zombie/zombie_voice_idle1.wav",
		"npc/zombie/zombie_voice_idle2.wav",
		"npc/zombie/zombie_voice_idle3.wav",
		"npc/zombie/zombie_voice_idle4.wav",
		"npc/zombie/zombie_voice_idle5.wav",
		"npc/zombie/zombie_voice_idle6.wav",
		"npc/zombie/zombie_voice_idle7.wav",
		"npc/zombie/zombie_voice_idle8.wav",
		"npc/zombie/zombie_voice_idle9.wav",
		"npc/zombie/zombie_voice_idle10.wav",
		"npc/zombie/zombie_voice_idle11.wav",
		"npc/zombie/zombie_voice_idle12.wav",
		"npc/zombie/zombie_voice_idle13.wav",
		"npc/zombie/zombie_voice_idle14.wav"
	}

	local zombie_sound_idles_len = #zombie_sound_idles

	util.AddNetworkString("TTTInitInfected")

	INFECTED = {}

	local plymeta = FindMetaTable("Player")
	if not plymeta then return end

	function plymeta:GetInfHost()
		if INFECTED[self] then
			return self
		end

		for host, infPly in pairs(INFECTED) do
			if table.HasValue(infPly, self) then
				return host
			end
		end
	end

	function StartZombieIdle(target, name)
		if not target or not IsValid(target) or not target:IsPlayer() or not target:IsActive() then
			timer.Stop(name)
			timer.Remove(name)
		else
			target:EmitSound(zombie_sound_idles[math.random(zombie_sound_idles_len)], SNDLVL_90dB, 100, 1, CHAN_VOICE)
		end
	end

	function AddInfected(target, attacker)
		local host = attacker:GetInfHost()
		if host then
			table.insert(INFECTED[host], target)
		end

		target:StripWeapons()

		target:Give("weapon_inf_knife")

		target:UpdateRole(ROLE_INFECTED)

		local name = "sound_idle_" .. target:EntIndex()

		timer.Create(name, 10, 0, function()
			StartZombieIdle(target, name)
		end)

		target:SetMaxHealth(30) -- just for new infected
		target:SetModel("models/player/corpse1.mdl") -- just for new infected

		SendFullStateUpdate()
	end

	function StopZombieIdle(ply)
		local str = "sound_idle_" .. ply:EntIndex()

		if timer.Exists(str) then
			timer.Stop(str)
		end
	end

	hook.Add("TTT2UpdateSubrole", "UpdateInfRoleSelect", function(ply, oldSubrole, newSubrole)
		if newSubrole == ROLE_INFECTED then
			if not ply:GetInfHost() then
				INFECTED[ply] = {}
			end
		elseif oldSubrole == ROLE_INFECTED then
			INFECTED[ply] = nil
		end
	end)

	hook.Add("TTTEndRound", "InfEndRound", function()
		for _, v in ipairs(player.GetAll()) do
			v:SetMaxHealth(100) -- reset

			StopZombieIdle(v)
		end

		INFECTED = {}
	end)

	hook.Add("TTTPrepareRound", "InfBeginRound", function()
		INFECTED = {}
	end)

	hook.Add("PlayerDeath", "InfectedDeath", function(victim, infl, attacker)
		if victim:GetSubRole() ~= ROLE_INFECTED and IsValid(attacker) and attacker:IsPlayer() and attacker:GetSubRole() == ROLE_INFECTED then
			victim.infectedKiller = attacker
		end

		local hostTbl = INFECTED[victim]
		if hostTbl then
			for _, inf in ipairs(hostTbl) do
				if IsValid(inf) and inf:IsActive() and inf:GetSubRole() == ROLE_INFECTED then
					inf:Kill()
				end
			end
		end
	end)

	hook.Add("PostPlayerDeath", "InfectedPostDeath", function(ply)
		if ply:GetSubRole() ~= ROLE_INFECTED and ply.infectedKiller then
			local killer = ply.infectedKiller

			ply.infectedKiller = nil

			if IsValid(killer) then

				-- revive after 3s
				ply:Revive(3, function(p)
					AddInfected(p, killer)
					InitInfected(p)

					-- do this clientside as well
					net.Start("TTTInitInfected")
					net.Send(p)
				end,
				function(p)
					return IsValid(p) and IsValid(killer) and killer:IsActive() and killer:GetSubRole() == ROLE_INFECTED
				end)
			end
		end
	end)

	hook.Add("PlayerDisconnected", "InfPlyDisconnected", function(discPly)
		local host = discPly:GetInfHost()

		if host == discPly then
			for _, inf in pairs(INFECTED[host]) do
				if inf:IsActive() and inf:GetSubRole() == ROLE_INFECTED then
					inf:Kill()
				end
			end

			INFECTED[host] = nil
		end
	end)

	hook.Add("PlayerCanPickupWeapon", "InfectedPickupWeapon", function(ply, wep)
		if IsValid(ply) and ply:IsActive() and ply:GetSubRole() == ROLE_INFECTED and not INFECTED[ply] and (not ply.IsGhost or ply.IsGhost and not ply:IsGhost()) then
			return false
		end
	end)

	-- tttc support
	hook.Add("TTTCClassDropNotPickupable", "InfectedPickupClassDrop", function(ply)
		if IsValid(ply) and ply:IsActive() and ply:GetSubRole() == ROLE_INFECTED and not INFECTED[ply] then
			return true
		end
	end)
end

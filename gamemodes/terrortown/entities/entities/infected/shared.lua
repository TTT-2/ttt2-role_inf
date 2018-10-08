local infMat
local indicator_inf_col

if SERVER then
	AddCSLuaFile()

	-- Bloody Knife
	resource.AddWorkshop("380972923")

	-- Zombie Perks
	resource.AddWorkshop("842302491")

	resource.AddFile("materials/vgui/ttt/icon_inf.vmt")
	resource.AddFile("materials/vgui/ttt/sprite_inf.vmt")
else
	local indicator_inf_col = Color(255, 255, 255, 130)
end

hook.Add("Initialize", "TTT2InitCRoleInf", function()
	-- important to add roles with this function,
	-- because it does more than just access the array ! e.g. updating other arrays
	AddCustomRole("INFECTED", { -- first param is access for ROLES array => ROLES.INFECTED or ROLES["INFECTED"]
			color = Color(34, 85, 0, 255), -- ...
			dkcolor = Color(44, 85, 0, 255), -- ...
			bgcolor = Color(24, 75, 0, 200), -- ...
			name = "infected", -- just a unique name for the script to determine
			abbr = "inf", -- abbreviation
			team = "infs", -- the team name: roles with same team name are working together
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
end)

-- if sync of roles has finished
hook.Add("TTT2_FinishedSync", "InfInitT", function(ply, first)
	if CLIENT and first then -- just on client and first init !
		infMat = Material("vgui/ttt/sprite_" .. ROLES.INFECTED.abbr)

		-- setup here is not necessary but if you want to access the role data, you need to start here
		-- setup basic translation !
		LANG.AddToLanguage("English", ROLES.INFECTED.name, "Infected")
		LANG.AddToLanguage("English", "hilite_win_" .. ROLES.INFECTED.name, "THE INF WON") -- name of base role of a team -> maybe access with GetTeamRoles(ROLES.INFECTED.team)[1].name
		LANG.AddToLanguage("English", "win_" .. ROLES.INFECTED.team, "The Infected has won!") -- teamname
		LANG.AddToLanguage("English", "info_popup_" .. ROLES.INFECTED.name, [[Now its your turn! Infect them ALL.]])
		LANG.AddToLanguage("English", "body_found_" .. ROLES.INFECTED.abbr, "This was a Infected...")
		LANG.AddToLanguage("English", "search_role_" .. ROLES.INFECTED.abbr, "This person was a Infected!")
		LANG.AddToLanguage("English", "ev_win_" .. ROLES.INFECTED.abbr, "The ill Infected won the round!")
		LANG.AddToLanguage("English", "target_" .. ROLES.INFECTED.name, "Infected")
		LANG.AddToLanguage("English", "ttt2_desc_" .. ROLES.INFECTED.name, [[The Infected needs to infect every player to win. He will infect other players by killing them.
If a player gets infected, the player looks like a zombie and is also able to infect other players. So you can build up a whole army.
But there is one thing you need to get in mind: If the host (the main infected player with a normal model) will die or disconnect, each player that the host infected will die.

If there is a Jester, feel free to infect him ]])

		---------------------------------

		-- maybe this language as well...
		LANG.AddToLanguage("Deutsch", ROLES.INFECTED.name, "Infizierter")
		LANG.AddToLanguage("Deutsch", "hilite_win_" .. ROLES.INFECTED.name, "THE INF WON")
		LANG.AddToLanguage("Deutsch", "win_" .. ROLES.INFECTED.team, "Der Infizierte hat gewonnen!")
		LANG.AddToLanguage("Deutsch", "info_popup_" .. ROLES.INFECTED.name, [[Jetzt bist du dran! Infiziere sie ALLE...]])
		LANG.AddToLanguage("Deutsch", "body_found_" .. ROLES.INFECTED.abbr, "Er war ein Infizierter...")
		LANG.AddToLanguage("Deutsch", "search_role_" .. ROLES.INFECTED.abbr, "Diese Person war ein Infizierter!")
		LANG.AddToLanguage("Deutsch", "ev_win_" .. ROLES.INFECTED.abbr, "Der kranke Infizierte hat die Runde gewonnen!")
		LANG.AddToLanguage("Deutsch", "target_" .. ROLES.INFECTED.name, "Infizierter")
		LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. ROLES.INFECTED.name, [[Der Infizierte muss alle anderen Spieler infizieren, um zu gewinnen. Dies tut er, indem er die Spieler tötet.
Wenn ein Spieler infiziert wird, wird er wie ein Zombie aussehen und wird ebenfalls andere Spieler infizieren können. Also erbaue Deine Armee!
Doch es gibt eine Sache, an die Du denken solltest: Stirbt/Disconnected der Host (der erste Infizierte mit dem normalen Playermodel), stirbt auch jeder Infizierte, der von ihm infiziert wurde.

Falls es einen Jester gibt, zögere nicht und infiziere ihn ]])
	end
end)

function InitInfected(ply)
	ply:SetHealth(ply:GetMaxHealth())
end

if SERVER then
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

	util.AddNetworkString("TTT_InitInfected")

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

		return
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

		target:Give("weapon_ttt_tigers")
		--target:Give("ttt_perk_speed") -- TODO buggy, replace

		target:UpdateRole(ROLES.INFECTED.index)

		local name = "sound_idle_" .. target:EntIndex()

		timer.Create(name, 10, 0, function()
			StartZombieIdle(target, name)
		end)

		SendFullStateUpdate()
	end

	function StopZombieIdle(ply)
		local str = "sound_idle_" .. ply:EntIndex()

		if timer.Exists(str) then
			timer.Stop(str)
		end
	end

	hook.Add("TTT2_SendFullStateUpdate", "InfFullStateUpdate", function()
		for host, v in pairs(INFECTED) do
			if IsValid(host) and host:IsPlayer() then
				local tmp = {}

				for _, inf in pairs(v) do
					table.insert(tmp, inf:EntIndex())

					SendRoleListMessage(ROLES.INFECTED.index, {host:EntIndex()}, inf)
				end

				SendRoleListMessage(ROLES.INFECTED.index, tmp, host)
			end
		end
	end)

	hook.Add("TTT2_RoleTypeSet", "UpdateInfRoleSelect", function(ply)
		if ply:GetRole() == ROLES.INFECTED.index and not ply:GetInfHost() then
			INFECTED[ply] = {}
		end
	end)

	hook.Add("TTTEndRound", "InfEndRound", function()
		for _, v in pairs(player.GetAll()) do
			v:SetMaxHealth(100) -- reset

			StopZombieIdle(v)
		end

		INFECTED = {}
	end)

	hook.Add("TTTPrepareRound", "InfBeginRound", function()
		INFECTED = {}
	end)

	hook.Add("EntityTakeDamage", "InfEntTakeDmg", function(target, dmginfo)
		local attacker = dmginfo:GetAttacker()

		if target:IsPlayer() and target:GetRole() ~= ROLES.INFECTED.index and IsValid(attacker) and attacker:IsPlayer() and attacker:GetRole() == ROLES.INFECTED.index then
			if (target:Health() - dmginfo:GetDamage()) <= 0 then
				dmginfo:ScaleDamage(0)

				target:Lock()

				timer.Create("FreezeNewInfForInit" .. target:EntIndex(), 3, 1, function()
					target:UnLock()
				end)

				AddInfected(target, attacker)

				target:SetMaxHealth(30) -- just for new infected
				target:SetModel("models/player/corpse1.mdl") -- just for new infected

				InitInfected(target)

				-- do this clientside as well
				net.Start("TTT_InitInfected")
				net.Send(target)
			end
		end

	end)

	hook.Add("PlayerDeath", "InfPlayerDeath", function(victim, infl, attacker)
		local host = INFECTED[victim]
		if host then
			for _, v in pairs(host) do
				if v:IsActive() and v:GetRole() == ROLES.INFECTED.index then
					v:Kill()
				end
			end

			INFECTED[victim] = nil
		end
	end)

	hook.Add("PlayerDisconnected", "SikiPlyDisconnected", function(discPly)
		local host = discPly:GetInfHost()

		if host == discPly then
			for _, inf in pairs(INFECTED[host]) do
				if inf:IsActive() and inf:GetRole() == ROLES.INFECTED.index then
					inf:Kill()
				end
			end

			INFECTED[host] = nil
		end
	end)

	hook.Add("PlayerCanPickupWeapon", "InfectedPickupWeapon", function(ply, wep)
		if IsValid(ply) ply:Alive() and ply:GetRole() == ROLES.INFECTED.index and not INFECTED[ply] then
			return false
		end
	end)

	-- tttc support
	hook.Add("TTTCClassDropNotPickupable", "InfectedPickupClassDrop", function(ply)
		if IsValid(ply) and ply:GetRole() == ROLES.INFECTED.index and not INFECTED[ply] then
			return true
		end
	end)
else -- CLIENT
	net.Receive("TTT_InitInfected", function()
		InitInfected(LocalPlayer())
	end)

	hook.Add("PostDrawTranslucentRenderables", "PostDrawInfTransRend", function()
		local client = LocalPlayer()

		if not client:IsActive() or client:GetRole() ~= ROLES.INFECTED.index then return end

		local dir, pos

		local trace = client:GetEyeTrace(MASK_SHOT)
		local ent = trace.Entity

		if not IsValid(ent) or ent.NoTarget or not ent:IsPlayer() then return end

		dir = (client:GetForward() * -1)

		pos = ent:GetPos()
		pos.z = pos.z + 74

		if ent ~= client then
			if ent.GetRole and ent:IsActive() then
				local role = ent:GetRole()

				if not role then return end -- sometimes strange things happens... -- gmod, u know

				if role <= 0 then
					role = ROLES.INNOCENT.index
				end

				if infMat then
					render.SetMaterial(infMat)
					render.DrawQuadEasy(pos, dir, 8, 8, indicator_inf_col, 180)
				end
			end
		end
	end)
end

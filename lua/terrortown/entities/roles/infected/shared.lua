if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_inf.vmt")
end

local maxhealth = CreateConVar("ttt2_inf_maxhealth_new_inf", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY})

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicInfCVars", function(tbl)
	tbl[ROLE_INFECTED] = tbl[ROLE_INFECTED] or {}

	table.insert(tbl[ROLE_INFECTED], {cvar = "ttt2_inf_maxhealth_new_inf", slider = true, min = 10, max = 100, desc = "Max Health for all new Infected (Def. 30)"})
end)

-- creates global var "TEAM_INFECTED" and other required things
-- TEAM_[name], data: e.g. icon, color, ...
roles.InitCustomTeam(ROLE.name, { -- this creates the var "TEAM_INFECTED"
		icon = "vgui/ttt/dynamic/roles/icon_inf",
		color = Color(131, 55, 85, 255)
})

ROLE.color = Color(131, 55, 85, 255) -- ...
ROLE.dkcolor = Color(73, 8, 33, 255) -- ...
ROLE.bgcolor = Color(100, 137, 58, 255) -- ...
ROLE.abbr = "inf" -- abbreviation
ROLE.defaultTeam = TEAM_INFECTED -- the team name: roles with same team name are working together
ROLE.defaultEquipment = SPECIAL_EQUIPMENT -- here you can set up your own default equipment
ROLE.surviveBonus = 0.2 -- bonus multiplier for every survive while another player was killed
ROLE.scoreKillsMultiplier = 2 -- multiplier for kill of player of another team
ROLE.scoreTeamKillsMultiplier = -4 -- multiplier for teamkill

ROLE.conVarData = {
	pct = 0.17, -- necessary: percentage of getting this role selected (per player)
	maximum = 1, -- maximum amount of roles in a round
	minPlayers = 6, -- minimum amount of players until this role is able to get selected
	random = 10 -- randomness of getting this role selected in a round
}

function InitInfected(ply)
	ply:SetHealth(ply:GetMaxHealth())
end

if CLIENT then -- just on client!
	hook.Add("TTT2FinishedLoading", "InfInitT", function() -- if sync of roles has finished
		infMat = Material("vgui/ttt/sprite_" .. INFECTED.abbr)

		-- setup here is not necessary but if you want to access the role data, you need to start here
		-- setup basic translation !
		LANG.AddToLanguage("English", INFECTED.name, "Infected")
		LANG.AddToLanguage("English", TEAM_INFECTED, "TEAM Infecteds")
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
		LANG.AddToLanguage("Deutsch", TEAM_INFECTED, "TEAM Infizierte")
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

	INFECTEDS = {}

	local plymeta = FindMetaTable("Player")
	if not plymeta then return end

	function plymeta:GetInfHost()
		if INFECTEDS[self] then
			return self
		end

		for host, infPly in pairs(INFECTEDS) do
			if table.HasValue(infPly, self) then
				return host
			end
		end
	end

	local minDelay, maxDelay = 5, 25

	local function CanIdle(ply)
		return IsValid(ply) and ply:IsPlayer() and ply:IsActive() and ply:GetSubRole() == ROLE_INFECTED and (not ply.IsGhost or not ply:IsGhost())
	end

	function StartZombieIdle(target, name, startDelay)
		startDelay = startDelay or 0

		if timer.Exists(name) then
			timer.Stop(name)
			timer.Remove(name)
		end

		if not CanIdle(target) then return end

		timer.Create(name, math.random(minDelay, maxDelay) + startDelay, 1, function()
			if CanIdle(target) then
				target:EmitSound(zombie_sound_idles[math.random(zombie_sound_idles_len)], SNDLVL_90dB, 100, 1, CHAN_VOICE)

				StartZombieIdle(target, name)
			end
		end)
	end

	function AddInfected(target, attacker)
		local host = attacker:GetInfHost()
		if host then
			table.insert(INFECTEDS[host], target)
		end

		target:StripWeapons()
		target:SetRole(ROLE_INFECTED)

		local name = "sound_idle_" .. target:EntIndex()

		timer.Create(name, 10, 1, function()
			StartZombieIdle(target, name)
		end)

		target:SetMaxHealth(maxhealth:GetInt()) -- just for new infected

		SendFullStateUpdate()
	end

	function StopZombieIdle(ply)
		local str = "sound_idle_" .. ply:EntIndex()

		if timer.Exists(str) then
			timer.Stop(str)
			timer.Remove(str)
		end
	end

	hook.Add("TTT2PreventJesterDeath", "JesterInfPreventDeath", function(ply)
		local killer = ply.jesterKiller

		if IsValid(killer) and killer:GetSubRole() == ROLE_INFECTED then
			return true
		end
	end)

	hook.Add("TTT2UpdateSubrole", "UpdateInfRoleSelect", function(ply, oldSubrole, newSubrole)
		if newSubrole == ROLE_INFECTED then
			if not ply:GetInfHost() then
				INFECTEDS[ply] = {}

				hook.Run("TTT2InfInitNewHost", ply)
			else
				ply:SetSubRoleModel("models/player/corpse1.mdl")
			end
		elseif oldSubrole == ROLE_INFECTED then
			if INFECTEDS[ply] then
				for _, inf in ipairs(INFECTEDS[ply]) do
					if IsValid(inf) and inf:IsActive() and inf:GetSubRole() == ROLE_INFECTED then
						inf:Kill()
					end
				end
			else
				ply:SetSubRoleModel(nil)
			end

			INFECTEDS[ply] = nil
		end
	end)

	hook.Add("PlayerCanPickupWeapon", "InfModifyPickupWeapon", function(ply, wep)
		if not IsValid(wep) or not IsValid(ply) then return end

		if ply:GetSubRole() == ROLE_INFECTED then
			if ply:IsSpec() and ply.IsGhost and ply:IsGhost() then return end

			local wepClass = WEPS.GetClass(wep)

			if not INFECTEDS[ply] and wepClass ~= "weapon_inf_knife" then
				return false
			end
		end
	end)

	hook.Add("TTTEndRound", "InfEndRound", function()
		for _, v in ipairs(player.GetAll()) do
			v:SetMaxHealth(100) -- reset

			StopZombieIdle(v)
		end

		INFECTEDS = {}
	end)

	hook.Add("TTTPrepareRound", "InfBeginRound", function()
		INFECTEDS = {}
	end)

	hook.Add("PlayerDeath", "InfectedDeath", function(victim, infl, attacker)
		if victim:GetSubRole() ~= ROLE_INFECTED and IsValid(attacker) and attacker:IsPlayer() and attacker:GetSubRole() == ROLE_INFECTED then
			victim.infectedKiller = attacker
		end

		local hostTbl = INFECTEDS[victim]
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

			if IsValid(killer) and killer:IsActive() and killer:GetSubRole() == ROLE_INFECTED then

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
			for _, inf in pairs(INFECTEDS[host]) do
				if IsValid(inf) and inf:IsActive() and inf:GetSubRole() == ROLE_INFECTED then
					inf:Kill()
				end
			end

			INFECTEDS[host] = nil
		end
	end)

	-- tttc support
	hook.Add("TTTCClassDropNotPickupable", "InfectedPickupClassDrop", function(ply)
		if IsValid(ply) and ply:IsActive() and ply:GetSubRole() == ROLE_INFECTED and not INFECTEDS[ply] then
			return true
		end
	end)

	-- default loadout is used if the player spawns
	hook.Add("TTT2ModifyDefaultLoadout", "ModifyInfLoadout", function(loadout_weapons, subrole)
		if subrole == ROLE_INFECTED then
			for k, v in ipairs(loadout_weapons[subrole]) do
				if v == "weapon_zm_improvised" or v == "weapon_zm_carry" or v == "weapon_ttt_unarmed" then
					table.remove(loadout_weapons[subrole], k)

					local tbl = weapons.GetStored(v)

					if tbl and tbl.InLoadoutFor then
						for k2, sr in ipairs(tbl.InLoadoutFor) do
							if sr == subrole then
								table.remove(tbl.InLoadoutFor, k2)
							end
						end
					end
				end
			end
		end
	end)

	hook.Add("TTT2InfInitNewHost", "TTT2AddInfDefWeapons", function(ply)
		ply:Give("weapon_zm_improvised")
		ply:Give("weapon_zm_carry")
		ply:Give("weapon_ttt_unarmed")
	end)
end

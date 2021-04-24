if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_inf.vmt")
	resource.AddFile("materials/vgui/ttt/vskin/events/infection.vmt")
end

local maxhealth = CreateConVar("ttt2_inf_maxhealth_new_inf", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY})

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicInfCVars", function(tbl)
	tbl[ROLE_INFECTED] = tbl[ROLE_INFECTED] or {}

	table.insert(tbl[ROLE_INFECTED], {cvar = "ttt2_inf_maxhealth_new_inf", slider = true, min = 10, max = 100, desc = "Max Health for all new Infected (def. 30)"})
end)

roles.InitCustomTeam(ROLE.name, {
	icon = "vgui/ttt/dynamic/roles/icon_inf",
	color = Color(131, 55, 85, 255)
})

function InitInfected(ply)
	ply:SetHealth(ply:GetMaxHealth())
end

function ROLE:PreInitialize()
	self.color = Color(131, 55, 85, 255)

	self.abbr = "inf"
	self.score.surviveBonusMultiplier = 0.2
	self.score.timelimitMultiplier = -0.5
	self.score.killsMultiplier = 2
	self.score.teamKillsMultiplier = -4
	self.score.bodyFoundMuliplier = 0

	self.defaultTeam = TEAM_INFECTED
	self.defaultEquipment = SPECIAL_EQUIPMENT

	self.conVarData = {
		pct = 0.17,
		maximum = 1,
		minPlayers = 6,
		random = 10
	}
end

if CLIENT then
	net.Receive("TTTInitInfected", function()
		InitInfected(LocalPlayer())
	end)
end

if SERVER then
	-- Give Loadout on respawn and rolechange
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		ply:GiveEquipmentWeapon("weapon_ttt_inf_fists")

		if INFECTEDS[ply] then return end

		ply:StripWeapon("weapon_zm_improvised")
		ply:StripWeapon("weapon_zm_carry")
		ply:StripWeapon("weapon_ttt_unarmed")
	end

	-- Remove Loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		ply:StripWeapon("weapon_ttt_inf_fists")

		if INFECTEDS[ply] then return end

		ply:Give("weapon_zm_improvised")
		ply:Give("weapon_zm_carry")
		ply:Give("weapon_ttt_unarmed")
	end

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

	function AddInfecteds(targets, attacker)
		local host = attacker:GetInfHost()
		if host then
			table.AddMissing(INFECTEDS[host], targets, true)
		end

		for _, target in ipairs(targets) do
			target:StripWeapons()
			target:SetRole(ROLE_INFECTED)

			local name = "sound_idle_" .. target:EntIndex()

			timer.Create(name, 10, 1, function()
				StartZombieIdle(target, name)
			end)

			target:SetMaxHealth(maxhealth:GetInt()) -- just for new infected
		end

		SendFullStateUpdate()
	end

	function StopZombieIdle(ply)
		local str = "sound_idle_" .. ply:EntIndex()

		if timer.Exists(str) then
			timer.Stop(str)
			timer.Remove(str)
		end
	end

	hook.Add("TTT2PreventJesterWinstate", "InfPreventJesterWinstate", function(killer)
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

			if not INFECTEDS[ply] and wepClass ~= "weapon_ttt_inf_fists" then
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
					local infectPlys = {p}

					hook.Run("TTT2ModifyInfecting", infectPlys)

					for i = 1, #infectPlys do
						events.Trigger(EVENT_INFECTION, killer, infectPlys[i])
					end

					AddInfecteds(infectPlys, killer)


					for _, infp in ipairs(infectPlys) do
						InitInfected(infp)
					end

					-- do this clientside as well
					net.Start("TTTInitInfected")
					net.Send(infectPlys)
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

	hook.Add("TTTPlayerSpeedModifier", "InfModifySpeed", function(ply, _, _, noLag)
		if IsValid(ply) and ply:GetSubRole() == ROLE_INFECTED and not INFECTEDS[ply] then
			noLag[1] = noLag[1] * 1.5
		end
	end)
end

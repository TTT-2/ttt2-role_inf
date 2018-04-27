AddCSLuaFile()

if SERVER then
   resource.AddFile("materials/vgui/ttt/icon_inf.vmt")
   resource.AddFile("materials/vgui/ttt/sprite_inf.vmt")
end

-- important to add roles with this function,
-- because it does more than just access the array ! e.g. updating other arrays
AddCustomRole("INFECTED", { -- first param is access for ROLES array => ROLES.INFECTED or ROLES["INFECTED"]
	color = Color(34, 85, 0, 255), -- ...
	dkcolor = Color(44, 85, 0, 255), -- ...
	bgcolor = Color(24, 75, 0, 200), -- ...
	name = "infected", -- just a unique name for the script to determine
	printName = "Infected", -- The text that is printed to the player, e.g. in role alert
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

-- if sync of roles has finished
hook.Add("TTT2_FinishedSync", "InfInitT", function(ply, first)
    if CLIENT and first then -- just on client and first init !

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
    end
end)

function InitInfected(ply)
    ply:SetHealth(ply:GetMaxHealth())
end

if SERVER then
    util.AddNetworkString("TTT_InitInfected")

    INFECTED = {}
    
    function AddInfected(target, attacker)
        local br = false
    
        if not INFECTED[attacker] then
            for k, v in pairs(INFECTED) do
                for _, i in pairs(v) do
                    if i == attacker then
                        attacker = k
                        br = true
                        
                        break
                    end
                end
                
                if br then break end
            end
        end
    
        table.insert(INFECTED[attacker], target)
        
        target:UpdateRole(ROLES.INFECTED.index)
        
        SendFullStateUpdate()
    end
    
    hook.Add("TTT2_SendFullStateUpdate", "InfFullStateUpdate", function()
        for host, v in pairs(INFECTED) do
            local tmp1 = {}
            
            if IsValid(host) and host:IsPlayer() then 
                for _, inf in pairs(v) do
                    table.insert(tmp1, inf:EntIndex())
                    
                    SendRoleListMessage(ROLES.INFECTED.index, {host:EntIndex()}, inf)
                end
                
                SendRoleListMessage(ROLES.INFECTED.index, tmp1, host)
            end
        end
    end)
    
    hook.Add("TTT2_RoleTypeSet", "UpdateInfRoleSelect", function(ply)
		if ply:GetRole() == ROLES.INFECTED.index then
			INFECTED[ply] = {}
		end
	end)
    
    hook.Add("TTTEndRound", "InfEndRound", function()
        for _, v in pairs(player.GetAll()) do
            v:SetMaxHealth(100) -- reset
        end
        
        INFECTED = {}
    end)
    
    hook.Add("TTTBeginRound", "InfBeginRound", function()
        INFECTED = {}
    end)
    
    hook.Add("EntityTakeDamage", "InfEntTakeDmg", function(target, dmginfo)
        local attacker = dmginfo:GetAttacker()
    
        if target:IsPlayer() and target:GetRole() ~= ROLES.INFECTED.index and IsValid(attacker) and attacker:IsPlayer() and attacker:GetRole() == ROLES.INFECTED.index then
            if (target:Health() - dmginfo:GetDamage()) <= 0 then
                dmginfo:ScaleDamage(0)
                
                target:Freeze(true)
                
                timer.Create("FreezeNewInfForInit", 1, 1, function() target:Freeze(false) end)
                
                AddInfected(target, attacker)
        
                target:SetMaxHealth(50) -- just for new infected
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
        local tmpHost
        local tmpInf
        
        for k, v in pairs(INFECTED) do
            if k == discPly then
                tmpHost = k
            end
                
            for i, ply in pairs(v) do
                if ply == discPly then
                    tmpInf = ply
                
                    table.remove(INFECTED[k], i)
                    
                    break
                end
            end
            
            if tmpHost or tmpInf then
                break
            end
        end
            
        if tmpHost then
            for _, inf in pairs(INFECTED[tmpHost]) do
                if inf:IsActive() and inf:GetRole() == ROLES.INFECTED.index then
                    inf:Kill()
                end
            end
        
            INFECTED[tmpHost] = nil
        end
    end)
else -- CLIENT
    net.Receive("TTT_InitInfected", function()
        InitInfected(LocalPlayer())
    end)
end

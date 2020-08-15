local L = LANG.GetLanguageTableReference("english")

-- GENERAL ROLE LANGUAGE STRINGS
L[INFECTED.name] = "Infected"
L[INFECTED.defaultTeam] = "TEAM Infecteds"
L["hilite_win_" .. INFECTED.defaultTeam] = "THE INFECTED WON"
L["win_" .. INFECTED.defaultTeam] = "The Infected has won!"
L["info_popup_" .. INFECTED.name] = [[Now its your turn! Infect them all by killing them.]]
L["body_found_" .. INFECTED.abbr] = "They were an Infected!"
L["search_role_" .. INFECTED.abbr] = "This person was a Infected!"
L["ev_win_" .. INFECTED.defaultTeam] = "The ill Infected won the round!"
L["target_" .. INFECTED.name] = "Infected"
L["ttt2_desc_" .. INFECTED.name] = [[The Infected needs to infect every player to win. He will infect other players by killing them.
If a player gets infected, the player looks like a zombie and is also able to infect other players. So you can build up a whole army.
But there is one thing you need to get in mind: If the host (the main infected player with a normal model) will die or disconnect, each player that the host infected will die.

If there is a Jester, feel free to infect him.]]

-- OTHER ROLE LANGUAGE STRINGS
L["infected_fists_name"] = "Infected Fists"

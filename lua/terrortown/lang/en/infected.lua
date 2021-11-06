local L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[INFECTED.name] = "Infected"
L[INFECTED.defaultTeam] = "Team Infected"
L["hilite_win_" .. INFECTED.defaultTeam] = "TEAM INFECTED WON"
L["win_" .. INFECTED.defaultTeam] = "The Infected has won!"
L["info_popup_" .. INFECTED.name] = [[Now it's your turn! Infect them all by killing them.]]
L["body_found_" .. INFECTED.abbr] = "They were an Infected!"
L["search_role_" .. INFECTED.abbr] = "This person was an Infected!"
L["ev_win_" .. INFECTED.defaultTeam] = "The ill Infected won the round!"
L["target_" .. INFECTED.name] = "Infected"
L["ttt2_desc_" .. INFECTED.name] = [[The Infected needs to infect every player to win. They infect other players by killing them.
If a player gets infected, they become a zombie and are able to infect other players. This allows the infected to build up a whole army.
However, there is one thing you need to keep in mind: If the host (the original, non-zombie infected player) dies or disconnects, all zombies will die.

If there is a Jester, feel free to infect them.]]

-- OTHER ROLE LANGUAGE STRINGS
L["infected_fists_name"] = "Infected Fists"
L["tooltip_infection_score"] = "Infection: {score}"
L["infection_score"] = "Infection:"
L["title_event_infection"] = "A player got infected"
L["desc_event_infection"] = "{host} has infected {infected} ({irole} / {iteam}) by killing them."

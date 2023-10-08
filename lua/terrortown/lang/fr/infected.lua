local L = LANG.GetLanguageTableReference("fr")

-- GENERAL ROLE LANGUAGE STRINGS
L[INFECTED.name] = "Infecté"
L[INFECTED.defaultTeam] = "Team Infectés"
L["hilite_win_" .. INFECTED.defaultTeam] = "LES INFECTÉS ONT GAGNÉ"
L["win_" .. INFECTED.defaultTeam] = "Les Infectés ont gagné!"
L["info_popup_" .. INFECTED.name] = [[C'est maintenant à votre tour ! Infectez-les tous en les tuant.]]
L["body_found_" .. INFECTED.abbr] = "C'était un Infecté!"
L["search_role_" .. INFECTED.abbr] = "Cette personne était un Infecté!"
L["ev_win_" .. INFECTED.defaultTeam] = "Les terroristes Infectés ont gagné la manche!"
L["target_" .. INFECTED.name] = "Infecté"
L["ttt2_desc_" .. INFECTED.name] = [[L'Infecté doit infecter tout les joueurs pour gagner. Il infecte les  joueurs en les tuant.
Si un joueur est infecté, il ressemble à un zombie et est également capable d'infecter d'autres joueurs. Vous pouvez donc constituer une armée entière.
Mais il y a une chose que vous devez garder à l'esprit : Si l'hôte (l'Infecté originel avec un modèle normal) meurt ou se déconnecte, chaque joueur que l'hôte a infecté meurt.

S'il y a un Bouffon, n'hésitez pas à l'infecter.]]

-- OTHER ROLE LANGUAGE STRINGS
L["infected_fists_name"] = "Poings infectés"
--L["tooltip_infection_score"] = "Infection: {score}"
--L["infection_score"] = "Infection:"
--L["title_event_infection"] = "A player got infected"
--L["desc_event_infection"] = "{host} has infected {infected} ({irole} / {iteam}) by killing them."

--L["label_inf_maxhealth_new_inf"] = "Max Health for new Infected zombies"

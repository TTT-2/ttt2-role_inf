local L = LANG.GetLanguageTableReference("es")

-- GENERAL ROLE LANGUAGE STRINGS
L[INFECTED.name] = "Infectado"
L[INFECTED.defaultTeam] = "Equipo Infectados"
L["hilite_win_" .. INFECTED.defaultTeam] = "EL INFECTADO GANA"
L["win_" .. INFECTED.defaultTeam] = "¡El Infectado ha ganado!"
L["info_popup_" .. INFECTED.name] = [[¡Ahora es tu turno! Infecta a todos matándolos.]]
L["body_found_" .. INFECTED.abbr] = "¡Era un Infectado!"
L["search_role_" .. INFECTED.abbr] = "Esta persona era un Infectado."
L["ev_win_" .. INFECTED.defaultTeam] = "¡Los infectados enfermos ganaron la ronda!"
L["target_" .. INFECTED.name] = "Infectado"
L["ttt2_desc_" .. INFECTED.name] = [[El Infectado necesita infectar a todos para ganar. Podrá hacer esto matándolos previamente.
Si un jugador es infectado, cambia su apariencia y obtiene la habilidad de infectar otros jugadores. De esta manera el equipo crece.
Hay un punto negativo a tener en cuenta: Si el principal (El Infectado Madre) muere o se desconecta, todos los jugadores infectados por este morirán.
Si hay Jester, podrá infectarlo de igual manera. Sin perder.]]

-- OTHER ROLE LANGUAGE STRINGS
L["infected_fists_name"] = "Garras"
--L["tooltip_infection_score"] = "Infection: {score}"
--L["infection_score"] = "Infection:"
--L["title_event_infection"] = "A player got infected"
--L["desc_event_infection"] = "{host} has infected {infected} ({irole} / {iteam}) by killing them."

--L["label_inf_maxhealth_new_inf"] = "Max Health for all new Infected"

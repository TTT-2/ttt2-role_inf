local L = LANG.GetLanguageTableReference("italiano")

-- GENERAL ROLE LANGUAGE STRINGS
L[INFECTED.name] = "Infetto"
L[INFECTED.defaultTeam] = "TEAM Infetti"
L["hilite_win_" .. INFECTED.defaultTeam] = "GLI INFETTI HANNO VINTO"
L["win_" .. INFECTED.defaultTeam] = "Gli infetti hanno vinto!"
L["info_popup_" .. INFECTED.name] = [[Ora è il tuo turno! Infetta tutti uccidendoli.]]
L["body_found_" .. INFECTED.abbr] = "Era un infetto!"
L["search_role_" .. INFECTED.abbr] = "Questa persona era un infetto!"
L["ev_win_" .. INFECTED.defaultTeam] = "Gli infettati hanno vinto il round!"
L["target_" .. INFECTED.name] = "Infetto"
L["ttt2_desc_" .. INFECTED.name] = [[L'infetto deve infettare ogni giocatore per vincere. Infetta gli altri giocatori uccidendoli.
Se un giocatore viene infettato, sembrerà un giocatore che potrà infettare gli altri giocatori. Quindi puoi costruire un esercito.
Ma c'è una cosa che devi ricordare: Se l'infetto principale (il primo) muore o si disconette, ogni giocatore infettato morirà.
Se c'è un Jester, infettalo tranquillamente.]]

-- OTHER ROLE LANGUAGE STRINGS
L["infected_fists_name"] = "Pugni Infetti"

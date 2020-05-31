L = LANG.GetLanguageTableReference("deutsch")

-- GENERAL ROLE LANGUAGE STRINGS
L[INFECTED.name] = "Infizierter"
L[INFECTED.defaultTeam] = "TEAM Infizierte"
L["hilite_win_" .. INFECTED.defaultTeam] = "THE INF WON"
L["win_" .. INFECTED.defaultTeam] = "Der Infizierte hat gewonnen!"
L["info_popup_" .. INFECTED.name] = [[Jetzt bist du dran! Infiziere sie alle, indem due sie tötest.]]
L["body_found_" .. INFECTED.abbr] = "Er war ein Infizierter."
L["search_role_" .. INFECTED.abbr] = "Diese Person war ein Infizierter!"
L["ev_win_" .. INFECTED.defaultTeam] = "Der kranke Infizierte hat die Runde gewonnen!"
L["target_" .. INFECTED.name] = "Infizierter"
L["ttt2_desc_" .. INFECTED.name] = [[Der Infizierte muss alle anderen Spieler infizieren, um zu gewinnen. Dies tut er, indem er die Spieler tötet.
Wenn ein Spieler infiziert wird, wird er wie ein Zombie aussehen und wird ebenfalls andere Spieler infizieren können. Also erbaue Deine Armee!
Doch es gibt eine Sache, an die Du denken solltest: Stirbt/Disconnected der Host (der erste Infizierte mit dem normalen Playermodel), stirbt auch jeder Infizierte, der von ihm infiziert wurde.

Falls es einen Jester gibt, zögere nicht und infiziere ihn.]]

-- OTHER ROLE LANGUAGE STRINGS
L["infected_fists_name"] = "Infizierte Fäuse"

local L = LANG.GetLanguageTableReference("ru")

-- GENERAL ROLE LANGUAGE STRINGS
L[INFECTED.name] = "Заражённый"
L[INFECTED.defaultTeam] = "Команда заражённых"
L["hilite_win_" .. INFECTED.defaultTeam] = "ПОБЕДА ЗАРАЖЁННЫХ"
L["win_" .. INFECTED.defaultTeam] = "Заражённые победили!"
L["info_popup_" .. INFECTED.name] = [[Теперь твоя очередь! Заразить их всех, убив их.]]
L["body_found_" .. INFECTED.abbr] = "Он был заражённым!"
L["search_role_" .. INFECTED.abbr] = "Этот человек был заражённым!"
L["ev_win_" .. INFECTED.defaultTeam] = "Больные заражённые выиграли раунд!"
L["target_" .. INFECTED.name] = "Заражённый"
L["ttt2_desc_" .. INFECTED.name] = [[Заражённый должен заразить каждого игрока, чтобы победить. Он заразит других игроков, убив их.
Если игрок заражается, он выглядит как зомби и может заразить других игроков. Так вы сможете собрать целую армию.
Но есть одна вещь, о которой вы должны помнить: если нулевой пациент (основной заражённый игрок с нормальной моделью) умрёт или выйдет из игры, каждый игрок, заражённый им, умрёт.

Если есть шут, смело заразите его.]]

-- OTHER ROLE LANGUAGE STRINGS
L["infected_fists_name"] = "Кулаки заражённого"
--L["tooltip_infection_score"] = "Infection: {score}"
--L["infection_score"] = "Infection:"
--L["title_event_infection"] = "A player got infected"
--L["desc_event_infection"] = "{host} has infected {infected} ({irole} / {iteam}) by killing them."

--L["label_inf_maxhealth_new_inf"] = "Max Health for new Infected zombies"

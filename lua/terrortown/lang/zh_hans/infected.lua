local L = LANG.GetLanguageTableReference("zh_hans")

-- GENERAL ROLE LANGUAGE STRINGS
L[INFECTED.name] = "感染者"
L[INFECTED.defaultTeam] = "感染者队伍"
L["hilite_win_" .. INFECTED.defaultTeam] = "感染者的队伍获胜"
L["win_" .. INFECTED.defaultTeam] = "感染者获胜!"
L["info_popup_" .. INFECTED.name] = [[现在轮到你了!通过击杀它们来感染它们.]]
L["body_found_" .. INFECTED.abbr] = "他们是感染者!"
L["search_role_" .. INFECTED.abbr] = "这个人是感染者!"
L["ev_win_" .. INFECTED.defaultTeam] = "感染者获胜!"
L["target_" .. INFECTED.name] = "感染者"
L["ttt2_desc_" .. INFECTED.name] = [[感染者需要感染每一位玩家才能获胜.他们通过杀死其他玩家来感染他们.

如果一个玩家被感染,他们就会变成僵尸,并能够感染其他玩家.这使得感染者能够组建一支完整的军队.

然而,有一件事你需要记住:如果主机(原始的,非僵尸感染的玩家)死亡或断开连接,所有僵尸都会死亡.

如果有小丑,请随意感染他们.]]

-- OTHER ROLE LANGUAGE STRINGS
L["infected_fists_name"] = "感染的拳头"
L["tooltip_infection_score"] = "传染: {score}"
L["infection_score"] = "传染:"
L["title_event_infection"] = "一个玩家被感染了"
L["desc_event_infection"] = "{host} 通过击杀 {infected} ({irole} / {iteam}) 而感染了它们."

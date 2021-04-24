if CLIENT then
	EVENT.icon = Material("vgui/ttt/vskin/events/infection")
	EVENT.title = "title_event_infection"

	function EVENT:GetText()
		return {
			{
				string = "desc_event_infection",
				params = {
					host = self.event.host.nick,
					infected = self.event.infected.nick,
					irole = roles.GetByIndex(self.event.infected.role).name,
					iteam = self.event.infected.team,
				},
				translateParams = true
			}
		}
	end
end

if SERVER then
	function EVENT:Trigger(host, infected)
		self:AddAffectedPlayers(
			{host:SteamID64(), infected:SteamID64()},
			{host:Nick(), infected:Nick()}
		)

		return self:Add({
			host = {
				nick = host:Nick(),
				sid64 = host:SteamID64()
			},
			infected = {
				nick = infected:Nick(),
				sid64 = infected:SteamID64(),
				role = infected:GetSubRole(),
				team = infected:GetTeam(),
			}
		})
	end

	function EVENT:CalculateScore()
		local event = self.event

		self:SetPlayerScore(event.host.sid64, {
			score = 1
		})
	end
end

function EVENT:Serialize()
	return self.event.host.nick .. " has infected " .. self.event.infected.nick .. '.'
end

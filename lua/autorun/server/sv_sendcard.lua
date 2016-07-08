util.AddNetworkString("CI_AskCardOfPlayer")
util.AddNetworkString("CI_SendCardOfPlayer")
util.AddNetworkString("CI_PrepareAcceptOrDenyRequest")
util.AddNetworkString("CI_ResponseAcceptOrDenyRequest")
util.AddNetworkString("CI_SendAcceptOrDenyRequest")
util.AddNetworkString("CI_SendAskCommand")

--[[local function SendCardInfo(cardid)
	query = "SELECT * FROM ci_card WHERE UniqueID = '"..cardid.."' "
	result = sql.Query(query)
	--if result == nil then return false,print("Erreur, carte invalide") end
		for k,v in ipairs(result) do
			return v
		end
end]]

--[[net.Receive("CI_AskCardInfo", function(len,ply)
	local cardid = net.ReadString()
	local citable = SendCardInfo(cardid)
	net.Start("CI_SendCardInfo")
	--if citable != false then
		net.WriteTable(citable)
	--end
	net.Send(ply)
end)]]

local function GetCardInfo(steamid)
	for k,v in ipairs(player.GetAll()) do
		if v:SteamID64() == steamid then
			for k,v in pairs(v:GetWeapons()) do
				if v:GetClass() == "ci_card" then
					return true, v:GetCardinfo(),v:GetGender()
				end
			end
		end
	end
	return false
	
end

--[[net.Receive("CI_AskCardOfPlayer", function(len,ply)
	local citable = net.ReadTable()
	for k,v in ipairs(player.GetAll()) do
		if v:SteamID64() == citable.steamid then
			for k,v in ipairs(v:GetWeapons()) do
				if v:GetClass() == "ci_card" then
					net.Start("CI_SendCardOfPlayer") 
					net.WriteBool(true)
					net.WriteString(v:GetCardinfo())
					net.Send(ply)
					return
				end
				net.Start("CI_SendCardOfPlayer")
				net.WriteBool(false)
				net.Send(ply)
				return
			end
		end
	end
end)]]

net.Receive("CI_PrepareAcceptOrDenyRequest", function(len,ply)
	ent = net.ReadEntity()
	net.Start("CI_SendAcceptOrDenyRequest")
	net.WriteEntity(ply)
	net.Send(ent)
end)

net.Receive("CI_ResponseAcceptOrDenyRequest", function(len,ply)
	local isaccept = net.ReadBool()
	local ent = net.ReadEntity()
	local havecard,cardinfo,gender = GetCardInfo(ent:SteamID64(),ent)
	if isaccept then

		net.Start("CI_SendCardOfPlayer")
		net.WriteEntity(ent)
		if havecard then
			net.WriteBool(true)
			net.WriteString(cardinfo)
			net.WriteInt(gender,3)
		else
			net.WriteBool(false)
			net.WriteEntity(ent)
		end
		net.Send(ply)
	end
end)

hook.Add("PlayerSay", "CI_AskCommand", function(ply, text)
	print(text)
	if string.len("/"..CI_CardTables.AskCardCommand) > 0 then
		if string.sub(text, 0, string.len("/"..CI_CardTables.AskCardCommand)) == "/"..CI_CardTables.AskCardCommand then
			net.Start("CI_SendAskCommand")
			net.WriteString("..")
			net.Send(ply)
			return
		end
	end
end)

hook.Add("OnPlayerChangedTeam","CI_GiveCardAfterChangingJob", function(ply,oldteam,newteam)
	local cardinfo;
	local gender;
	for k,v in ipairs(player.GetAll()) do
		if v == ply then
			for k,v in pairs(v:GetWeapons()) do
				if v:GetClass() == "ci_card" then
					cardinfo = v:GetCardinfo()
					gender = v:GetGender()
				end
			end	
		end
	end
	if oldteam != newteam then
		timer.Simple(1, function()
			ply:Give("ci_card")
			for k,v in ipairs(ply:GetWeapons()) do
				if v:GetClass()== "ci_card" then
					v:SetCardinfo(cardinfo)
					v:SetGender(gender)
				end
			end
		end)
	end
end)
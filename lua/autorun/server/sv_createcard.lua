util.AddNetworkString("CI_CreatePlayerCard")

--[[local function CreateCITables()
	if !sql.TableExists("ci_player") then
		sql.Query("CREATE TABLE ci_player (ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, UniqueID VARCHAR(255), HaveCard INT(1), IsFake INT(1))")
	end

	if !sql.TableExists("ci_card") then
		sql.Query("CREATE TABLE ci_card (ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, UniqueID VARCHAR(255), Model VARCHAR(255), Lastname VARCHAR(255), Firstname VARCHAR(255), Gender VARCHAR(255), Birthday VARCHAR(255), CardID VARCHAR(255), Expire VARCHAR(255),Gave VARCHAR(255),By VARCHAR(255), HasGave INT(1), HasStoled INT(1))")
	end

	if !sql.TableExists("ci_truecid") then

	end
end

CreateCITables()

local function CreatePlayerTable(player)
	local steamid = player:SteamID64()
	local result = sql.Query("SELECT * FROM ci_player WHERE UniqueID = '"..steamid.."' ")
	if result == nil then
		sql.Query("INSERT INTO ci_player VALUES (NULL, '"..steamid.."', 0, 0 )")
	else
		return
	end
end

local function CheckIDCard(id)
	local result = sql.Query("SELECT * FROM ci_card WHERE CardID = '"..id.."' ")
	if result == nil then 
		return true 

	else 
		return false 
	end
end

local PLAYER = FindMetaTable("Player")

-function PLAYER:CheckHaveCard()
	result = sql.Query("SELECT * FROM ci_card WHERE UniqueID = '"..self:SteamID64().."' ")
	if result == nil then
		return false
	else
		return true
	end
end]]

local function CreateCardID(fname,lname)
	local fid = "IDFRA"
	fid = (fid..fname)
	fid = (fid.."<<<<<<<<<<<<<<<<<<<<<<<<<<<")
	fid = (fid..math.random(100000,999999))
	fid = (fid..math.random(1000000,9999999))
	fid = (fid..lname)
	fid = (fid.."<<<<<<<<<<<<<<<")
	fid = (fid.."DarkRP"..math.random(10,99).."M"..math.random(1,9))
	return fid
end

local function CreateCard(citable,ply)
	local CardID = CreateCardID(citable.FName,citable.LName)
	--[[local query = "INSERT INTO ci_card VALUES (NULL, '"..citable.SteamID.."', '"..citable.Model.."', '"..citable.LName.."', '"..citable.FName.."', '"..citable.Gender.."', '"..citable.Birthday.."', '"..CardID.."', '28/06/2026', '28/06/2016', 'Z3k4', 0, 0)"
	sql.Query(query)]]
	if timer.Exists("CI_CreateCardCoolDown_"..ply:SteamID64()) then
		ply:ChatPrint("Vous devez attendre à nouveau avant de pouvoir créer une nouvelle carte")
	else
		ply:addMoney(-CI_CardTables.PriceOfCard)
		timer.Simple(math.random(CI_CardTables.MinCardDelivery,CI_CardTables.MaxCardDelivery),function()
			ply:Give("ci_card")

			timer.Simple(0.5,function()
				for k,v in ipairs(ply:GetWeapons()) do
					if v:GetClass()== "ci_card" then
						v:SetCardinfo("|Nom|"..citable.FName.."|Prénom|"..citable.LName.."|Modèle|"..citable.Model.."|CardID|"..CardID)
						--v:SetLastname(citable.LName)
						v:SetGender(citable.Gender)

						--print(v:GetCardinfo())
					end
				end
			end)

			timer.Create("CI_CreateCardCoolDown_"..ply:SteamID64(),CI_CardTables.Cooldown, 1, function() end)
		end)
	end
end

--hook.Add("PlayerInitialSpawn","CI_CreatePlayerTable",CreatePlayerTable)

net.Receive("CI_CreatePlayerCard", function(len,ply)
	local citable = net.ReadTable()
	--if !ply:CheckHaveCard() then
		CreateCard(citable,ply)
	--else
		--print("Vous avez déjà une carte")
	--end

end)

surface.CreateFont("ImpactCarte",{
	font = "Arial",
	size = 34,
})

surface.CreateFont("SmallImpactCarte",{
	font = "Impact",
	size = 22,
})

surface.CreateFont("SmallImpactCarte1",{
	font = "Impact",
	size = 26,
})

surface.CreateFont("SmallImpactCarte2",{
	font = "Impact",
	size = 22,
})

local function AskShowCard()
	local ent = LocalPlayer():GetEyeTrace().Entity
	if IsValid(ent) && ent:IsPlayer() && ent:Alive() then
		net.Start("CI_PrepareAcceptOrDenyRequest")
		--net.WriteString("...")
		net.WriteEntity(ent)
		net.SendToServer()
	else
		chat.AddText("Vous devez regarder une cible")
	end
end

net.Receive("CI_SendAskCommand", AskShowCard)

local ent;

local function FormatCardInfo(cardinfo)
	local cardstring = cardinfo
	if cardstring == "" then
		return "0","Exemple","Exemple","models/humans/group01/male_02.mdl"
	end

	local ign,fnom = string.find(cardstring,"|Nom|")
	local fname, ign1 = string.find(cardstring,"|Prénom|",fnom)
	local ign2,cmodel = string.find(cardstring,"|Modèle|",ign)
	local cid, ign3 = string.find(cardstring,"|CardID|",cmodel)


	local fname = string.sub(cardstring,fnom + 1,fname - 1)
	local lname = string.sub(cardstring,ign1 + 1, ign2 - 1)
	local model = string.sub(cardstring,cmodel + 1,cid - 1)
	local cid = string.sub(cardstring,ign3 + 1)
	
	--print(fname,lname,model,cid)

	return cid,fname,lname,model

end

local function DenyOrAccept()
	local CIFrame = vgui.Create("DFrame")
	CIFrame:SetSize(260,150)
	CIFrame:Center()
	CIFrame:MakePopup()
	CIFrame:SetTitle("")
	CIFrame:ShowCloseButton(false)
	CIFrame.Paint = function(self)
		local w,h = self:GetSize()
		surface.SetDrawColor(CI_CardTables.RequestBorderColor)
		surface.DrawOutlinedRect(0,0,w,h)
		surface.SetDrawColor(CI_CardTables.RequestInteriorColor)
		surface.DrawRect(2,2,w - 4,h - 4)
		draw.DrawText((ent:Name().." \ndemande votre carte"),"SmallImpactCarte1",130,30,Color(255,255,255), TEXT_ALIGN_CENTER)
	end

	local CICloseButton = vgui.Create("DButton",CIFrame)
	CICloseButton:SetSize(20,20)
	CICloseButton:SetPos(CIFrame:GetWide()-CICloseButton:GetWide()-1)
	CICloseButton:SetText("x")
	CICloseButton.DoClick = function()
		CIFrame:Close()
	end


	local CIAButton = vgui.Create("DButton",CIFrame)
	CIAButton:SetSize(100,40)
	CIAButton:SetText("Accepter")
	CIAButton:SetPos(15,CIFrame:GetTall()-CIAButton:GetTall()-20)
	CIAButton.DoClick = function()
		net.Start("CI_ResponseAcceptOrDenyRequest")
		net.WriteBool(true)
		net.WriteEntity(LocalPlayer())
		net.SendToServer()
		CIFrame:Close()
	end

	local CIRButton = vgui.Create("DButton",CIFrame)
	CIRButton:SetSize(100,40)
	CIRButton:SetText("Refuser")
	CIRButton:SetPos(CIFrame:GetWide()-CIRButton:GetWide()-15,CIFrame:GetTall()-CIRButton:GetTall()-20)
	CIRButton.DoClick = function()
		net.Start("CI_ResponseAcceptOrDenyRequest")
		net.WriteBool(false)
		net.WriteEntity(LocalPlayer())
		net.SendToServer()
		CIFrame:Close()
	end

end

local havecard = false
local cardinfo;
local gender;

local function ShowCardInfo()
	local CIFrame = vgui.Create("DFrame")
	local sizex,sizey = 470,475
	if not havecard then
		sizex,sizey = 300,130
	end

	CIFrame:SetSize(sizex,sizey)
	CIFrame:Center()
	CIFrame:MakePopup()
	CIFrame:SetTitle("Informations de la carte")

	if havecard then
		cardid,fname,lname,model = FormatCardInfo(cardinfo)
		local CIPanel = vgui.Create("DPanel",CIFrame)
		CIPanel:SetSize(CIFrame:GetWide()-20,300)
		CIPanel:SetPos(10,CIFrame:GetTall()-CIPanel:GetTall()-10)
		CIPanel.Paint = function(self)
			local w,h = self:GetSize()
			draw.RoundedBoxEx(20,0,0,w,50,CI_CardTables.TopCardColor,true,true,false,false)
			draw.RoundedBoxEx(20,0,h-60,w,50,CI_CardTables.BottomCardColor,false,false,true,true)

			local CI_DModelPanelFrame = vgui.Create("DModelPanel",CIPanel)
			CI_DModelPanelFrame:SetSize(150,150)
			CI_DModelPanelFrame:SetPos(20 ,70 )
			CI_DModelPanelFrame:SetModel(model)
			CI_DModelPanelFrame.LayoutEntity = function()
				return false
			end
			CI_DModelPanelFrame:SetFOV(50)
			CI_DModelPanelFrame:SetCamPos( Vector( 20, 0, 62 ) )
			CI_DModelPanelFrame:SetLookAt( Vector( 0, 0, 65 ) )

			if gender == 1  then
				gender = "Homme"
			elseif gender == 0 then
				gender = "Femme" 
			end
			
			surface.DrawRect(0,50,w,h-110)
			surface.SetMaterial(Material("ci_card/curves.png"))
			surface.SetDrawColor(255,255,255,230)
			surface.DrawTexturedRect(0,50,w,h-110)

			draw.DrawText("RÉPUBLIQUE   FRANÇAISE","ImpactCarte", 220,10,CI_CardTables.CardTextColor,TEXT_ALIGN_CENTER)

			local FCardID = string.sub(cardid,1,string.len(cardid) /2)
			local LCardID = string.sub(cardid,string.len(cardid) /2,string.len(cardid))
			draw.DrawText(FCardID.."\n"..LCardID,"SmallImpactCarte",225,h - 58,CI_CardTables.CardTextColor,TEXT_ALIGN_CENTER)

			draw.DrawText("Nom : "..fname,"SmallImpactCarte1",190,80,CI_CardTables.CardTextColor)
			draw.DrawText("Prénom : "..lname,"SmallImpactCarte1",190,110,CI_CardTables.CardTextColor)
			draw.DrawText("Genre : "..gender,"SmallImpactCarte1",190,140,CI_CardTables.CardTextColor)
		end
	end

	local CILabel = vgui.Create("DLabel",CIFrame)
	CILabel:SetSize(400,200)
	CILabel:SetPos(20,60)
	CILabel:SetText("")
	CILabel.Paint = function(self)
		if havecard then
			draw.DrawText((ent:Name().." \npossède une carte d'identité"), "SmallImpactCarte", 200,0,Color(255,255,255),TEXT_ALIGN_CENTER)
		else
			draw.DrawText((ent:Name().." \npossède pas de carte d'identité"), "SmallImpactCarte", 130,0,Color(255,255,255),TEXT_ALIGN_CENTER)
		end
	end
end

net.Receive("CI_SendAcceptOrDenyRequest", function()
	ent = net.ReadEntity()
	DenyOrAccept()
end)

net.Receive("CI_SendCardOfPlayer", function()
	ent = net.ReadEntity() 
	havecard = net.ReadBool()
	cardinfo = net.ReadString()
	gender = net.ReadInt(3)

	ShowCardInfo()
end)

concommand.Add("test_showc",ShowCardInfo)
concommand.Add("test_trace",PrintTrace)

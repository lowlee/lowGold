local L = setmetatable({}, {__index=function(t,i) return i end})

local playername = UnitName("player")
local realmname = GetRealmName()

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("lowGold", {icon = "Interface\\Icons\\INV_Misc_Coin_01", text = ""})

local f = CreateFrame("Frame")

f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

local function CreateGoldString(gold)
	local g = floor(gold / 10000)
	local s = floor(mod(gold / 100, 100))
	local c = mod(gold, 100)
	
	goldstring = ""
	goldstring = string.format("%s%s ", string.format("|cffffffff%d|r", g), string.format("|cffffd700%s|r", L["g"]))
	goldstring = goldstring..string.format("%s%s ", string.format("|cffffffff%.2d|r", s), string.format("|cffc7c7cf%s|r", L["s"]))
	goldstring = goldstring..string.format("%s%s", string.format("|cffffffff%.2d|r", c), string.format("|cffeda55f%s|r", L["c"]))
	
	return goldstring
end

local function UpdateGold()
	local gold = GetMoney()
	
	lowGoldDB.realm[realmname][playername] = gold
	dataobj.text = CreateGoldString(gold)
end

function f:PLAYER_LOGIN()
	self:RegisterEvent("PLAYER_MONEY")
	self:RegisterEvent("PLAYER_TRADE_MONEY")
	self:RegisterEvent("TRADE_MONEY_CHANGED")
	self:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
	self:RegisterEvent("SEND_MAIL_COD_CHANGED")

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil

	if not lowGoldDB or not lowGoldDB.realm then
		lowGoldDB = {
			realm = {},
		}
	end
	
	if not lowGoldDB.realm[realmname] then
		lowGoldDB.realm[realmname] = {}
	end

	UpdateGold()
end

f.PLAYER_MONEY = UpdateGold
f.PLAYER_TRADE_MONEY = UpdateGold
f.TRADE_MONEY_CHANGED = UpdateGold
f.SEND_MAIL_MONEY_CHANGED = UpdateGold
f.SEND_MAIL_COD_CHANGED = UpdateGold

local function GetTipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth() * 2 / 3) and "RIGHT" or (x < UIParent:GetWidth() / 3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight() / 2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

function dataobj.OnLeave() GameTooltip:Hide() end

function dataobj.OnEnter(self)
 	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(GetTipAnchor(self))
	GameTooltip:ClearLines()

	GameTooltip:AddLine("lowGold", 1, 1, 1)
	GameTooltip:AddLine(" ")

	local totalgold = 0
	
	for name,value in pairs(lowGoldDB.realm[realmname]) do
		GameTooltip:AddDoubleLine(name, CreateGoldString(value), 1, 1, 1, 1, 1, 1)
		totalgold = totalgold + value
	end

	GameTooltip:AddLine(" ")
	
	GameTooltip:AddDoubleLine(L["Total"], CreateGoldString(totalgold), 1, 1, 1, 1, 1, 1)

	GameTooltip:Show()
end

if IsLoggedIn() then f:PLAYER_LOGIN() else f:RegisterEvent("PLAYER_LOGIN") end

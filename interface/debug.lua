local DiesalTools = LibStub('DiesalTools-1.0')
local DiesalStyle = LibStub('DiesalStyle-1.0')
local DiesalGUI = LibStub('DiesalGUI-1.0')
local DiesalMenu = LibStub('DiesalMenu-1.0')
local SharedMedia = LibStub('LibSharedMedia-3.0')

local addonColor = '|cff'..NeP.Interface.addonColor

local enabled = false
local debugT = {}
local statusBars = {}
local statusBarsUsed = {}

local buttonStyleSheet = {
	['frame-color'] = {	
		type			= 'texture',
		layer			= 'BACKGROUND',								
		color			= '2f353b',			
		offset		= 0,	
	},
	['frame-highlight'] = {
		type			= 'texture',
		layer			= 'BORDER',
		gradient	= 'VERTICAL',							
		color			= 'FFFFFF',			
		alpha 		= 0,
		alphaEnd	= .1,
		offset		= -1,
	},	
	['frame-outline'] = {		
		type			= 'outline',
		layer			= 'BORDER',								
		color			= '000000',		
		offset		= 0,		
	},	
	['frame-inline'] = {		
		type			= 'outline',
		layer			= 'BORDER',
		gradient	= 'VERTICAL',
		color			= 'ffffff',
		alpha 		= .02,
		alphaEnd	= .09,
		offset		= -1,
	},	
	['frame-hover'] = {		
		type			= 'texture',
		layer			= 'HIGHLIGHT',	
		color			= 'ffffff',
		alpha			= .1,
		offset		= 0,	
	},
	['text-color'] = {
		type			= 'Font',
		color			= 'b8c2cc',
	},
}

function NeP.Core.Debug(prefix, text)
	if enabled then
		local prefix, text = tostring(prefix), tostring(text)
		local prefix = addonColor..prefix..'|r'
		debugT[#debugT+1] = '('..prefix..'): '..text
	end
end

NeP.Core.testDebug = DiesalGUI:Create('Window')
local debug = NeP.Core.testDebug
debug:SetWidth(300)
debug:SetHeight(400)
debug:SetTitle(addonColor..'Debug Mode')
debug.frame:SetClampedToScreen(true)
debug.frame:SetMinResize(300, 400)
debug:Hide()

local bt = DiesalGUI:Create("Button")
debug:AddChild(bt)
bt:SetParent(debug.content)
bt:SetPoint("TOP", debug.content, "TOP", 0, 0)
bt.frame:SetSize(debug.content:GetWidth(), 30)
bt:AddStyleSheet(buttonStyleSheet)
bt:SetEventListener("OnClick", function() enabled = not enabled end)

local ListWindow = DiesalGUI:Create('ScrollFrame')
debug:AddChild(ListWindow)
ListWindow:SetParent(debug.content)
ListWindow:SetPoint('TOP', debug.content, 0, -30)
ListWindow.frame:SetSize(debug.content:GetWidth(), debug.content:GetHeight()-50)
ListWindow.debug = debug

local bt2 = DiesalGUI:Create("Button")
debug:AddChild(bt2)
bt2:SetParent(debug.content)
bt2:SetPoint("BOTTOM", debug.content, "BOTTOM", 0, 0)
bt2.frame:SetSize(debug.content:GetWidth(), 20)
bt2:AddStyleSheet(buttonStyleSheet)
bt2:SetEventListener("OnClick", function() wipe(debugT) end)

-- FIXME: not working
debug.frame:SetScript('OnDragStop', function()
	bt:SetPoint("TOP", debug.content, "TOP", 0, 0)
	bt.frame:SetSize(debug.content:GetWidth(), 30)
	ListWindow:SetPoint('TOP', debug.content, 0, -30)
	ListWindow.frame:SetSize(debug.content:GetWidth(), debug.content:GetHeight()-50)
	bt2:SetPoint("BOTTOM", debug.content, "BOTTOM", 0, 0)
	bt2.frame:SetSize(debug.content:GetWidth(), 20)
end)

local function getStatusBar()
	local statusBar = tremove(statusBars)
	if not statusBar then
		statusBar = DiesalGUI:Create('FontString')
		statusBar:SetParent(ListWindow.content)
		debug:AddChild(statusBar)
	end
	statusBar:Show()
	table.insert(statusBarsUsed, statusBar)
	return statusBar
end

local function recycleStatusBars()
	for i = #statusBarsUsed, 1, -1 do
		statusBarsUsed[i]:Hide()
		tinsert(statusBars, tremove(statusBarsUsed))
	end
end

local function RefreshGUI()
	local offset = -5
	recycleStatusBars()
	for i=1,#debugT do
		local text = debugT[i]
		local statusBar = getStatusBar()
		statusBar.fontString:SetPoint('TOPLEFT', ListWindow.content, 'TOPLEFT', 2, offset )
		statusBar.fontString:SetText(text)
		offset = offset -17
	end
end

C_Timer.NewTicker(1, (function()
	if NeP.Core.testDebug:IsShown() then
		RefreshGUI()
		bt2:SetText('WIPE (|cffabd473'..#debugT..'|r)')
		if enabled then
			bt:SetText('|cffabd473ENABLED')
		else
			bt:SetText('|cffc41f3bDISABLED')
		end
	end
end), nil)
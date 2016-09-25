local config = {
	key = 'NePSettings',
	profiles = true,
	title = '|T'..NeP.Interface.Logo..':10:10|t'..' '..NeP.Info.Name,
	subtitle = 'NerdPack Settings',
	color = NeP.Interface.addonColor,
	width = 250,
	height = 350,
	config = {
		{type = 'header', text = 'Visual Settings:', align = 'center'},
		{type = 'spacer'},
		{type = 'spinner', text = 'Toggle Size', key = 'tSize', default = 40, min = 25, max = 100},
		{type = 'spinner', text = 'Toggle Padding', key = 'tPad', default = 2, max = 20, step = 1},
		{type = 'spacer'},
		{type = 'button', text = 'Apply', callback = function() NeP.Interface.RefreshToggles() end, width = 220, height = 20},

		{type = 'spacer'},{ type = 'rule' },
		{type = 'header', text = 'ObjectManager Settings:', align = 'center'},
		{type = 'spacer'},
		{type = 'spinner', text = 'Max Distance', key = 'OM_MaxDis', default = 100, max = 250},
		{type = 'checkbox', text = 'Force Generic OM', key = 'fOM_Generic', default = false},
		{type = 'spacer'},
		{type = 'button', text = 'Apply', callback = function() ReloadUI() end, width = 220, height = 20},
	}
}

NeP.Config.WhenLoaded(function()
	NeP.Interface.buildGUI(config)
end)
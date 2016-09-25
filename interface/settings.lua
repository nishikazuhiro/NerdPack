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
		{type = 'spinner', text = 'Toggle Size', key = 'tSize', default = 40, min = 25, max = 100},
		{type = 'button', text = 'Apply', callback = function() NeP.Interface.RefreshToggles() end, width = 220, height = 20},

		{type = 'spacer'},{ type = 'rule' },
		{type = 'header', text = 'ObjectManager Settings:', align = 'center'},
		{type = 'checkbox', text = 'Force OM Fallback', key = 'fOM_Fallback', default = false},
	}
}

NeP.Config.WhenLoaded(function()
	NeP.Interface.buildGUI(config)
end)
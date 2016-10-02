local dToggles = {
	{
		key = 'mastertoggle',
		name = 'MasterToggle',
		text = 'TEST',
		icon = 'Interface\\ICONS\\Ability_repair.png',
		func = function(self, button)
			if button == "RightButton" then
				if IsControlKeyDown() then
					NeP.Interface.MainFrame.drag:Show()
				else
					print('DropDown')
				end
			else
				print('test')
			end
		end
	},
	{
		key = 'interrupts',
		name = 'Interrupts',
		text = 'TEST',
		icon = 'Interface\\ICONS\\Ability_Kick.png',
		func = function(self) print('test') end
	},
	{
		key = 'cooldowns',
		name = 'Cooldowns',
		text = 'TEST',
		icon = 'Interface\\ICONS\\Achievement_BG_winAB_underXminutes.png',
		func = function(self) print('test') end
	},
	{
		key = 'aoe',
		name = 'Multitarget',
		text = 'TEST',
		icon = 'Interface\\ICONS\\Ability_Druid_Starfall.png',
		func = function(self) print('test') end
	}
}

function NeP.Interface:DefaultToggles()
	for i=1, #dToggles do
		self:AddToggle(dToggles[i])
	end
end

NeP.Interface:DefaultToggles()
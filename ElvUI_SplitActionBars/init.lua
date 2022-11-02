local E, L, _, P = unpack(ElvUI)
local AB = E.ActionBars
local ACH

-- Set Profile Defaults
for i = 1, 10 do
	P.actionbar['bar'..i].splitToggle = false
	P.actionbar['bar'..i].splitStart = 7
	P.actionbar['bar'..i].splitSpacing = 2
end

local function GetOptions()
	ACH = E.Libs.ACH
	local color = E:ClassColor(E.myclass)

	local splitButtonsGroup = ACH:Group(color:WrapTextInColorCode(L["Split Bar (ElvUI Plugin)"]), nil, 29, nil, function(info) return E.db.actionbar[info[#info-3]][info[#info]] end, function(info, value) E.db.actionbar[info[#info-3]][info[#info]] = value AB:PositionAndSizeBar(info[#info-3]) end)
	splitButtonsGroup.inline = true
	splitButtonsGroup.args.splitToggle = ACH:Toggle(L["Enable"], L["Split bar into two sections."], 0, nil, nil, nil, nil, nil, nil, false)
	splitButtonsGroup.args.splitStart = ACH:Range(L["Split Start"], L["Split bar from this button."], 1, { min = 2, max = _G.NUM_ACTIONBAR_BUTTONS, step = 1 }, nil, nil, nil, nil, function(info) return not E.db.actionbar[info[#info-3]].splitToggle end)
	splitButtonsGroup.args.splitSpacing = ACH:Range(L["Split Spacing"], L["Split bar with this spacing."], 2, { min = -3, max = 512, step = 1 }, nil, nil, nil, nil, function(info) return not E.db.actionbar[info[#info-3]].splitToggle end)

	local bar
	for i = 1, 10 do
		bar = E.Options.args.actionbar.args.playerBars.args['bar'..i]
		bar.args.barGroup.args.splitButtonsGroup = CopyTable(splitButtonsGroup)
	end
end

local function HandleButton(_, bar, button, index, lastButton, lastColumnButton)
	local db = bar.db
	if not db.splitToggle then return end

	local numButtons = db.buttons
	local buttonsPerRow = db.buttonsPerRow

	if bar.LastButton then
		if numButtons > bar.LastButton then numButtons = bar.LastButton end
		if buttonsPerRow > bar.LastButton then buttonsPerRow = bar.LastButton end
	end

	if numButtons < buttonsPerRow then buttonsPerRow = numButtons end

	-- Split Bars Modification
	local buttonSpacing = db.buttonSpacing
	if db.splitToggle and index == db.splitStart then
		buttonSpacing = db.splitSpacing
	end

	local _, _, anchorUp, anchorLeft = AB:GetGrowth(db.point)
	local point, relativeFrame, relativePoint, x, y
	if index == 1 then
		local firstButtonSpacing = db.backdrop and (E.Border + db.backdropSpacing) or E.Spacing
		if db.point == 'BOTTOMLEFT' then
			x, y = firstButtonSpacing, firstButtonSpacing
		elseif db.point == 'TOPRIGHT' then
			x, y = -firstButtonSpacing, -firstButtonSpacing
		elseif db.point == 'TOPLEFT' then
			x, y = firstButtonSpacing, -firstButtonSpacing
		else
			x, y = -firstButtonSpacing, firstButtonSpacing
		end

		point, relativeFrame, relativePoint = db.point, bar, db.point
	elseif (index - 1) % buttonsPerRow == 0 then
		-- Modified Original Line
		point, relativeFrame, relativePoint, x, y = 'TOP', lastColumnButton, 'BOTTOM', 0, -buttonSpacing
		if anchorUp then
			-- Modified Original Line
			point, relativePoint, y = 'BOTTOM', 'TOP', buttonSpacing
		end
	else
		-- Modified Original Line
		point, relativeFrame, relativePoint, x, y = 'LEFT', lastButton, 'RIGHT', buttonSpacing, 0
		if anchorLeft then
			-- Modified Original Line
			point, relativePoint, x = 'RIGHT', 'LEFT', -buttonSpacing
		end
	end

	button:ClearAllPoints()
	button:Point(point, relativeFrame, relativePoint, x, y)
end

local function Initialize()
	hooksecurefunc(AB, 'HandleButton', HandleButton)

	E.Libs.EP:RegisterPlugin('ElvUI_SplitActionBars', GetOptions)
end
hooksecurefunc(E, 'LoadAPI', Initialize)

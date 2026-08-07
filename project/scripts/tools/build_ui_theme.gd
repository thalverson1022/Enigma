@tool
extends SceneTree
## One-shot builder for project/assets/ui_theme.tres (P2:R7:T2). Run once
## via `godot --headless -s res://scripts/tools/build_ui_theme.gd` whenever
## the palette/font plan changes; the saved .tres is what actually ships
## and is registered via gui/theme/custom in project.godot. Not an autoload
## and not referenced anywhere else at runtime.

func _init() -> void:
	var theme := Theme.new()

	var vt323: FontFile = load("res://assets/fonts/VT323-Regular.ttf")
	var medieval_sharp: FontFile = load("res://assets/fonts/MedievalSharp-Regular.ttf")
	var press_start_2p: FontFile = load("res://assets/fonts/PressStart2P-Regular.ttf")
	var pirata_one: FontFile = load("res://assets/fonts/PirataOne-Regular.ttf")

	# -- Theme-wide default: VT323, body/data font (monospaced digits keep
	# stat columns stable) --
	theme.default_font = vt323
	theme.default_font_size = 18

	# -- Label --
	theme.set_font("font", "Label", vt323)
	theme.set_font_size("font_size", "Label", 18)
	theme.set_color("font_color", "Label", UIColors.TEXT_NORMAL)
	theme.set_color("font_disabled_color", "Label", UIColors.TEXT_DISABLED)

	# -- PanelHeader (Label type variation): MedievalSharp, panel/section
	# headers across the dashboard --
	theme.set_type_variation("PanelHeader", "Label")
	theme.set_font("font", "PanelHeader", medieval_sharp)
	theme.set_font_size("font_size", "PanelHeader", 22)
	theme.set_color("font_color", "PanelHeader", UIColors.ACCENT)

	# -- TitleHeading (Label type variation): Pirata One, title screen only --
	theme.set_type_variation("TitleHeading", "Label")
	theme.set_font("font", "TitleHeading", pirata_one)
	theme.set_font_size("font_size", "TitleHeading", 48)
	theme.set_color("font_color", "TitleHeading", UIColors.TEXT_NORMAL)

	# -- RichTextLabel: same body font as Label, so the combat log and the
	# poison-colored stat panels read consistently with the rest of the UI --
	theme.set_font("normal_font", "RichTextLabel", vt323)
	theme.set_font_size("normal_font_size", "RichTextLabel", 18)
	theme.set_color("default_color", "RichTextLabel", UIColors.TEXT_NORMAL)

	# -- Panel / PanelContainer: same bordered-card look as CardStyle, so
	# any bare Panel/PanelContainer that doesn't explicitly call
	# CardStyle.make_stylebox() still matches --
	var panel_style := CardStyle.make_stylebox()
	theme.set_stylebox("panel", "Panel", panel_style)
	theme.set_stylebox("panel", "PanelContainer", panel_style)

	# -- Button: Press Start 2P, short all-caps action labels. Wide glyphs
	# need generous content margins (style notes doc) so text isn't flush
	# against the border. --
	theme.set_font("font", "Button", press_start_2p)
	theme.set_font_size("font_size", "Button", 12)
	theme.set_color("font_color", "Button", UIColors.TEXT_NORMAL)
	theme.set_color("font_hover_color", "Button", UIColors.TEXT_NORMAL)
	theme.set_color("font_pressed_color", "Button", UIColors.TEXT_NORMAL)
	theme.set_color("font_disabled_color", "Button", UIColors.TEXT_DISABLED)
	# Use semantic action roles so palette experiments can retune button
	# states without chasing individual controls or native dialogs.
	theme.set_stylebox("normal", "Button", CardStyle.make_action_button_stylebox(UIColors.ACTION_DEFAULT, UIColors.PANEL_BORDER, "normal"))
	theme.set_stylebox("hover", "Button", CardStyle.make_action_button_stylebox(UIColors.ACTION_HOVER, UIColors.PANEL_BORDER, "hover"))
	theme.set_stylebox("pressed", "Button", CardStyle.make_action_button_stylebox(UIColors.ACTION_PRESSED, UIColors.PANEL_BORDER, "pressed"))
	theme.set_stylebox("disabled", "Button", CardStyle.make_action_button_stylebox(UIColors.ACTION_DISABLED, UIColors.TEXT_DISABLED, "disabled"))
	theme.set_stylebox("focus", "Button", CardStyle.make_action_button_stylebox(UIColors.ACTION_FOCUS, UIColors.ACCENT, "focus"))

	# -- CheckBox/OptionButton/LineEdit etc. are not used anywhere in the
	# current active flow (per the R7:T1 reachable-state audit); left on
	# engine defaults rather than themed speculatively. --

	var save_path := "res://assets/ui_theme.tres"
	var err := ResourceSaver.save(theme, save_path)
	if err != OK:
		push_error("Failed to save %s: %s" % [save_path, err])
		quit(1)
		return
	print("Saved %s" % save_path)
	quit(0)

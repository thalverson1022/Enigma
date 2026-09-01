extends Control
## Generated boss checklist for the Adventure top bar.
## Rows are backed by the same boss identity helper used by generated contract
## offer filtering, so the manual and the offer board stay in lockstep.

const CARD_TITLE_FONT_SIZE := 20
const BIOME_TITLE_FONT_SIZE := 19
const BOSS_ROW_FONT_SIZE := 18
const CLOSED_FONT_SIZE := 16
const MODAL_Z_INDEX := 930
const MANUAL_CONTENT_SIZE := Vector2(760, 600)
const MANUAL_SCROLL_SIZE := Vector2(760, 520)
const MANUAL_ICON := preload("res://assets/ui/icons/monster_manual.png")
const ContractOfferSourceScript := preload("res://scripts/systems/contract_offer_source.gd")

var _boss_grid: GridContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	z_index = MODAL_Z_INDEX

	var panel := CardStyle.build_modal_panel(self, true)
	panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox())

	var content := VBoxContainer.new()
	content.custom_minimum_size = MANUAL_CONTENT_SIZE
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	content.add_child(header)

	header.add_child(CardStyle.make_pixel_icon(MANUAL_ICON, Vector2(36, 36)))

	var title := Label.new()
	title.text = "Monster Manual"
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	title.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var close_button := Button.new()
	close_button.name = "MonsterManualCloseButton"
	close_button.text = "Close"
	close_button.pressed.connect(func(): visible = false)
	header.add_child(close_button)

	var scroll := ScrollContainer.new()
	scroll.name = "MonsterManualScroll"
	scroll.custom_minimum_size = MANUAL_SCROLL_SIZE
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)

	_boss_grid = GridContainer.new()
	_boss_grid.name = "MonsterManualBossGrid"
	_boss_grid.columns = 2
	_boss_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_boss_grid.add_theme_constant_override("h_separation", 14)
	_boss_grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(_boss_grid)

	_populate_boss_grid()
	if not BuildState.run_state_changed.is_connected(_populate_boss_grid):
		BuildState.run_state_changed.connect(_populate_boss_grid)


func show_manual() -> void:
	_populate_boss_grid()
	z_index = MODAL_Z_INDEX
	move_to_front()
	visible = true


func _populate_boss_grid() -> void:
	if _boss_grid == null:
		return
	for child in _boss_grid.get_children():
		child.queue_free()
	for biome in _biome_names():
		_boss_grid.add_child(_build_biome_section(String(biome)))


func _build_biome_section(biome: String) -> PanelContainer:
	var section := PanelContainer.new()
	section.name = "BiomeSection_%s" % _node_safe_name(biome)
	section.custom_minimum_size = Vector2(360, 0)
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := CardStyle.make_stylebox(6)
	style.bg_color = UIColors.PANEL_DEEP
	style.border_color = _biome_accent_color(biome)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 3
	style.border_width_bottom = 4
	section.add_theme_stylebox_override("panel", style)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 6)
	section.add_child(content)

	var title := Label.new()
	title.name = "BiomeTitle"
	title.text = "%s  %d/%d" % [biome, _defeated_count_for_biome(biome), _boss_names_for_biome(biome).size()]
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", BIOME_TITLE_FONT_SIZE)
	title.add_theme_color_override("font_color", _biome_accent_color(biome))
	content.add_child(title)

	for boss_name in _boss_names_for_biome(biome):
		content.add_child(_build_boss_row(String(boss_name), biome))
	return section


func _build_boss_row(boss_name: String, biome: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "BossRow_%s_%s" % [_node_safe_name(biome), _node_safe_name(boss_name)]
	row.add_theme_constant_override("separation", 8)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var boss_id := ContractOfferSourceScript.generated_boss_id(biome, boss_name)
	var defeated := BuildState.is_generated_boss_defeated(boss_id)

	var box := Label.new()
	box.name = "BossCheckBox"
	box.text = "[x]" if defeated else "[ ]"
	box.custom_minimum_size = Vector2(32, 0)
	box.add_theme_font_size_override("font_size", BOSS_ROW_FONT_SIZE)
	box.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR if defeated else UIColors.TEXT_DISABLED)
	row.add_child(box)

	var label := Label.new()
	label.name = "BossNameLabel"
	label.text = boss_name
	label.clip_text = true
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", BOSS_ROW_FONT_SIZE)
	label.add_theme_color_override("font_color", UIColors.TEXT_DISABLED if defeated else UIColors.TEXT_NORMAL)
	row.add_child(label)
	if defeated:
		var closed := Label.new()
		closed.name = "BossClosedLabel"
		closed.text = "CLOSED"
		closed.add_theme_font_size_override("font_size", CLOSED_FONT_SIZE)
		closed.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
		row.add_child(closed)
	return row


func _boss_names_for_biome(biome: String) -> Array:
	var bosses := []
	for entry in ContractOfferSourceScript.generated_boss_catalog():
		if String(entry.get("biome", "")) == biome:
			bosses.append(String(entry.get("boss_name", "")))
	return bosses


func _biome_names() -> Array[String]:
	var names: Array[String] = []
	for entry in ContractOfferSourceScript.generated_boss_catalog():
		var biome := String(entry.get("biome", ""))
		if biome != "" and not names.has(biome):
			names.append(biome)
	return names


func _defeated_count_for_biome(biome: String) -> int:
	var count := 0
	for entry in ContractOfferSourceScript.generated_boss_catalog():
		if String(entry.get("biome", "")) != biome:
			continue
		if BuildState.is_generated_boss_defeated(String(entry.get("id", ""))):
			count += 1
	return count


func _biome_accent_color(biome: String) -> Color:
	match biome:
		"Swamp":
			return Color(0.45, 0.78, 0.42)
		"Cave":
			return Color(0.58, 0.66, 0.82)
		"Graveyard":
			return Color(0.72, 0.72, 0.64)
		"Haunted Forest":
			return Color(0.36, 0.72, 0.57)
		"Ruined Keep":
			return Color(0.78, 0.55, 0.42)
		"Ancient Ruins":
			return Color(0.66, 0.54, 0.88)
		_:
			return CardStyle.ACCENT_COLOR


func _node_safe_name(value: String) -> String:
	var safe := value.strip_edges().to_lower()
	for ch in [" ", "-", "'", ",", ".", ":"]:
		safe = safe.replace(ch, "_")
	return safe

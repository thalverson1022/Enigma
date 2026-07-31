class_name GearCompareButton
extends Button
## P2:R7 second playtest-feedback pass (revises the first pass's rejected big
## comparison panel): hovering a shop/reward gear box shows the item's REGULAR
## small tooltip plus a second, identically tooltip-styled box labeled
## "Equipped" beside it -- two default-tooltip-sized boxes, no stat-diff text,
## no large card panels. Control's _make_custom_tooltip() is the only way to
## return an arbitrary Control for a tooltip, and that's a virtual method a
## plain Button.new() can't override -- this tiny subclass exists only to
## host the override, and delegates the actual Control-building back to
## `tooltip_builder` (set by whichever screen/overlay owns that gear item) so
## the gear data reads stay with the caller instead of being duplicated here.
##
## Promoted to its own global class (docs/Phase_3_Technical_Debt_Architecture_
## Cleanup.md Phase 3) so both combat_screen.gd (reward-choice) and
## shop_overlay.gd (shop) can use it without combat_screen.gd's former inner
## class being inaccessible outside that one file.

var tooltip_builder: Callable


func _make_custom_tooltip(_for_text: String) -> Object:
	if tooltip_builder.is_valid():
		return tooltip_builder.call()
	return null

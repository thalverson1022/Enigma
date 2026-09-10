class_name GearTooltipPanel
extends Panel
## Equipped gear slots need the same custom rich tooltip path as
## GearCompareButton, while preserving Panel styling for the paper doll.

var tooltip_builder: Callable


func _make_custom_tooltip(_for_text: String) -> Object:
	if tooltip_builder.is_valid():
		return tooltip_builder.call()
	return null

class_name RuntimeMonsterNotice
extends RefCounted

const SEVERITY_INFO := "info"
const SEVERITY_WARNING := "warning"
const SEVERITY_ERROR := "error"

var severity: String = SEVERITY_INFO
var code: String = ""
var message: String = ""
var context: Dictionary = {}


static func make(notice_severity: String, notice_code: String, notice_message: String, notice_context: Dictionary = {}) -> RuntimeMonsterNotice:
	var notice := RuntimeMonsterNotice.new()
	notice.severity = notice_severity
	notice.code = notice_code
	notice.message = notice_message
	notice.context = notice_context.duplicate(true)
	return notice


static func from_dictionary(source: Dictionary) -> RuntimeMonsterNotice:
	var data := RuntimeMonsterDataNormalizer.snake_keys(source)
	return make(
		String(data.get("severity", SEVERITY_INFO)),
		String(data.get("code", "")),
		String(data.get("message", "")),
		RuntimeMonsterDataNormalizer.preserve_dictionary(data.get("context", {}))
	)


func to_dictionary() -> Dictionary:
	return {
		"severity": severity,
		"code": code,
		"message": message,
		"context": context.duplicate(true),
	}

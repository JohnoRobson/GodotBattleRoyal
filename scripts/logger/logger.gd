class_name LoggerInterface
extends Node

# red, yellow, white, green
enum LoggingLevel {ERROR, WARN, INFO, TRACE}

var logging_level: LoggingLevel = LoggingLevel.INFO

func log(level: LoggingLevel, message: String) -> void:
	var msg: String = "[color=%s][%08d] %6s[/color] %s" % [_get_color_for_level(level), Engine.get_process_frames(), _get_level_name(level), message]
	if level <= logging_level:
		print_rich(msg)

func error(message: String) -> void:
	self.log(LoggingLevel.ERROR, message)

func warn(message: String) -> void:
	self.log(LoggingLevel.WARN, message)

func info(message: String) -> void:
	self.log(LoggingLevel.INFO, message)

func trace(message: String) -> void:
	self.log(LoggingLevel.TRACE, message)

func _get_color_for_level(level: LoggingLevel) -> String:
	match level:
		LoggingLevel.ERROR:
			return "red"
		LoggingLevel.WARN:
			return "yellow"
		LoggingLevel.INFO:
			return "white"
		LoggingLevel.TRACE:
			return "green"
		_:
			assert(false, "Invalid logging level %s" % [level])
			return "red" # will not execute due to the assert call

func _get_level_name(level: LoggingLevel) -> String:
	return LoggingLevel.keys()[level]

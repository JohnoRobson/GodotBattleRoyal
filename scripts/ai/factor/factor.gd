class_name Factor

# Should return a value between 0.0 and 1.0. This is what should be overriden
static func calculate(_factor_context: FactorContext) -> float:
	return 0.0

# Returns the calculate function clamped to between 0.0 and 1.0 inclusive
static func evaluate(_factor_context: FactorContext) -> float:
	return clampf(calculate(_factor_context), 0.0, 1.0)

extends ConfigEntry

## These two lists should have a 1-1 relationship.
const supported_countries = [
	"en", "pt"
]
const supported_locales = [
	"en", "pt_BR"
]

func get_key() -> String:
	return "language"

func get_option_name() -> String:
	return "Language"

func get_option_type() -> OptionType:
	return OptionType.LIST

func get_section() -> String:
	return "GAMEPLAY"

func get_possible_values():
	return supported_locales.duplicate()

func get_default_value():
	var lang = OS.get_locale_language()
	if lang not in supported_locales:
		lang = lang.get_slice("_", 0)
	if lang in supported_countries:
		lang = supported_locales[supported_countries.find(lang)]
	else:
		lang = "en"
	print_debug(lang)
	return lang

func on_changed(new_value):
	TranslationServer.set_locale(new_value)

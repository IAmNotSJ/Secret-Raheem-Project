class_name SaveGame extends Resource

const SAVE_PATH: String = "user://hyena.tres"

@export var hyenas: Big = Big.new(0)
@export var fuck:int = 7

func write_savegame() -> void:
	ResourceSaver.save(self, SAVE_PATH)

static func save_exists() -> bool:
	return ResourceLoader.exists(SAVE_PATH)

static func load_savegame() -> Resource:
	if not ResourceLoader.has_cached(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH, "", 0)
	return null


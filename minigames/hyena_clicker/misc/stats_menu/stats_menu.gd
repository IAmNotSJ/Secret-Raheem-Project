extends Control

const cookie_run = preload("res://fonts/CookieRun Bold.ttf")
@onready var hyena_clicker = get_parent()
var idleUpgrades:Dictionary = {
	"Hyena Snacks" : "HYENA SNACK",
	"Hyena Traps" : "HYENA TRAP",
	"Hyena Drones" : "HYENA DRONE",
	"Hyena Enclosures" : "HYENA ENCLOSURE",
	"Hyena Zoos" : "HYENA ZOO",
	"Hyena Parks" : "HYENA PARK",
	"Hyena Sanctuaries" : "HYENA SANCTUARY",
	"Hyena Spells" : "HYENA SPELL",
	"Hyena Rockets" : "HYENA ROCKET",
	"Hyena Colonies" : "HYENA COLONY",
	"Hyena Portals" : "HYENA PORTAL",
	"Hyena Vortexes" : "HYENA VORTEX",
	"Hyena Galaxies" : "HYENA GALAXY",
	"Hyena Duplicators" : "HYENA DUPLICATOR",
	"Hyena Dyson Spheres" : "HYENA DYSON SPHERE",
	"Hyena Black Holes" : "HYENA BLACK HOLE",
	"Hyena Afterlives" : "HYENA AFTERLIFE",
	"Hyena Singularities" : "HYENA SINGULARITY",
	"Hyena Univereses" : "HYENA UNIVERSE",
	"Hyena Multiverses" : "HYENA MULTIVERSE"
}

var clickUpgrades:Dictionary = {
	"Hyena Nets" : "HYENA NET",
	"Hyena Meat" : "HYENA MEAT",
	"Hyena Encyclopedias" : "HYENA ENCYCLOPEDIA",
	"Hyena Calls" : "HYENA CALL",
	"Hyena Tomes" : "HYENA TOME",
	"Hyena Time Machines" : "HYENA TIME MACHINE",
	"Hyena Armies" : "HYENA ARMY",
	"Hyena Dark Arts" : "HYENA DARK ARTS",
	"Hyena Prisms" : "HYENA PRISM",
	"Hyena Dark Matter" : "HYENA DARK MATTER",
	"Hyena Augmentors" : "HYENA AUGMENTOR",
	"Hyena M.Q.M's" : "HYENA MULTILEVEL QUANTUM MANIPULATOR",
	"Hyena Forces" : "HYENA FORCE",
	"Hyena Folders" : "HYENA FOLDER",
}

func generate_items():
	
	var shortNum
	if hyena_clicker.totalHyenas.isLargerThanOrEqualTo(1000):
		shortNum = hyena_clicker.totalHyenas.toPrefix()
		if shortNum.ends_with("000"):
			shortNum = shortNum.left(-3)
		elif shortNum.ends_with("00"):
			shortNum = shortNum.left(-2)
		elif shortNum.ends_with("0"):
			shortNum = shortNum.left(-1)
		if shortNum.ends_with("."):
			shortNum = shortNum.left(-1)
		shortNum = shortNum + hyena_clicker.totalHyenas.getMetricSymbol()
	else:
		shortNum = hyena_clicker.totalHyenas
	$Info/hyenas.text = "Total Hyenas Collected: " + shortNum
	$Info/clicks.text = "Times Clicked: " + str(hyena_clicker.clicks)
	$Info/cps_max.text = "Highest CPS: " + str(hyena_clicker.highest_cps)
	
	for item in idleUpgrades.keys():
		var label = Label.new()
		label.text = item + ": " + str(hyena_clicker.idleUpgrades[idleUpgrades[item]][0])
		label.add_theme_font_override("font", cookie_run)
		if hyena_clicker.idleUpgrades[idleUpgrades[item]][0] == 0:
			label.visible = false
		$Idle.add_child(label)
	for item in clickUpgrades.keys():
		var label = Label.new()
		label.text = item + ": " + str(hyena_clicker.clickUpgrades[clickUpgrades[item]][0])
		label.add_theme_font_override("font", cookie_run)
		if hyena_clicker.clickUpgrades[clickUpgrades[item]][0] == 0:
			label.visible = false
		$Click.add_child(label)

func clear():
	for child in $Idle.get_children():
		child.queue_free()
	for child in $Click.get_children():
		child.queue_free()

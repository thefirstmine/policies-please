extends Node2D

@export var signalBus: Node2D

var main_econ_GDP = 0.0
var main_econ_PopulationSatisfaction = 0.0

var tax_rate = 0.0
var unemployment = 0.0
var gov_debt  = 0.0
var ag_demand = 0.0
var ag_supply = 0.0
var net_exports = 0.0
var growth_multiplier = 0.0
var inflation_rate = 0.0
var currency_value = 0.0

func _init():
	pass

func _ready():
	await get_tree().create_timer(0.1).timeout
	defaultValues()
	updateEconomy()
func has_variable(var_name: String) -> bool:
	return var_name in self
func defaultValues():
	main_econ_GDP = 900.0
	tax_rate = 0.1
	unemployment = 0.09
	inflation_rate = -0.01
	gov_debt = 800.0
	currency_value = 0.85
	ag_demand = 800.0
	ag_supply = 1000.0
	net_exports = -50.0
	main_econ_PopulationSatisfaction = 0.5
	growth_multiplier = 0.9
	
func updateEconomy():
	print("updating economy...")
	signalBus.economyUpdated.emit(
		{	"GDP": main_econ_GDP,
			"PopulationSatisfaction": main_econ_PopulationSatisfaction,
			"taxRate": tax_rate,
			"unemployment": unemployment,
			"govDebt": gov_debt,
			"agDemand": ag_demand,
			"agSupply": ag_supply,
			"netExports": net_exports,
			"growthMultiplier": growth_multiplier,
			"inflation": inflation_rate,
			"currencyValue": currency_value})

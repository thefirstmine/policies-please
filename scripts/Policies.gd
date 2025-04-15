extends Node2D

@onready var econ = get_parent()

func passPolicy(policy_data: Array):
	var policy_stats:Dictionary = policy_data[0]	
	for key in policy_stats.keys():
		if econ.has_variable(key): 
			econ.set(key, econ.get(key) + policy_stats[key])
		else:
			push_warning("Policy key '" + str(key) + "' not found in econ.")
	interdependentEffects()
func interdependentEffects():
	var demand_gap = econ.ag_demand - econ.ag_supply
	econ.main_econ_GDP += demand_gap * 0.05

	# Unemployment reacts to GDP
	econ.unemployment -= (econ.main_econ_GDP - 1000.0) * 0.0001  # 1000 = potential GDP

	# Inflation reacts to ag_demand > ag_supply
	econ.inflation_rate += (econ.ag_demand / econ.ag_supply - 1.0) * 0.02

	# Currency value reacts to inflation
	econ.currency_value -= econ.inflation_rate * 0.1

	# Net exports react to currency
	econ.net_exports -= (econ.currency_value - 1.0) * 50.0
	econ.ag_demand += econ.net_exports * 0.01

	# Consumer happiness reacts to inflation & unemployment
	econ.main_econ_PopulationSatisfaction -= econ.inflation_rate * 0.5
	econ.main_econ_PopulationSatisfaction -= econ.unemployment * 0.3
	econ.main_econ_PopulationSatisfaction = clamp(econ.main_econ_PopulationSatisfaction, 0.0, 1.0)
	# Debt increases if GDP is low (less revenue)
	econ.tax_rate = 0.2
	var gov_revenue = econ.main_econ_GDP * econ.tax_rate
	var gov_spending = 250.0  # can vary by policy
	econ.gov_debt += gov_spending - gov_revenue
	
	# Growth multiplier adjusts based on confidence
	econ.growth_multiplier = 1.0 if econ.main_econ_PopulationSatisfaction > 0.7 else 0.95
	#chickeyn jockey
# Fiscal Policies
var policy1 = [{
		"ag_demand": 500,          
		"gov_debt": 150,          
		"net_exports": -30,       
		"main_econ_PopulationSatisfaction": 0.1,
		"inflation_rate": 0.01    

	},
	{"type": "FISCAL", 
	 "description": "A Fiscal expansionary policy that strongly increases aggregate demand and population satisfaction a bit, 
					but increases government debt and decreases exports"}
	]


func _ready():
	await get_tree().create_timer(2).timeout
	print("sigma")
	passPolicy(policy1)
	await get_tree().create_timer(1).timeout
	get_parent().updateEconomy()

extends Node2D

@onready var econ = get_parent()

func passPolicy(policy_data: Dictionary):
	var policy_stats:Dictionary = policy_data	
	for key in policy_stats.keys():
		if econ.has_variable(key): 
			econ.set(key, econ.get(key) + policy_stats[key])
		else:
			push_warning("Policy key '" + str(key) + "' not found in econ.")
	interdependentEffects()
	get_parent().updateEconomy()
func interdependentEffects():
	# Calculate potential GDP from Aggregate Supply
	var potential_gdp = econ.ag_supply
	#Demand-driven GDP (with growth multiplier)
	var demand_gdp = econ.ag_demand * econ.growth_multiplier

	# Real GDP is the lesser of the two, ag_supply acts as a ceiling for GDP basically.
	econ.main_econ_GDP = min(potential_gdp, demand_gdp)

	# Unemployment adjusts inversely to GDP (approximate)
	var potential_gdp_baseline = 1000.0
	econ.unemployment -= (econ.main_econ_GDP - potential_gdp_baseline) * 0.0001
	econ.unemployment = clamp(econ.unemployment, 0.02, 0.25)

	# Inflation rises if demand > supply
	econ.inflation_rate += (econ.ag_demand / econ.ag_supply - 1.0) * 0.02
	econ.inflation_rate = clamp(econ.inflation_rate, -0.05, 0.2)  # optional

	# currency weakens with inflation
	econ.currency_value -= econ.inflation_rate * 0.1
	econ.currency_value = clamp(econ.currency_value, 0.5, 1.5)

	# Net exports affected by currency value
	econ.net_exports -= (econ.currency_value - 1.0) * 50.0
	econ.ag_demand += econ.net_exports * 0.01

	# Consumer happiness affected by inflation & unemployment
	econ.main_econ_PopulationSatisfaction -= econ.inflation_rate * 0.5
	econ.main_econ_PopulationSatisfaction -= econ.unemployment * 0.3
	econ.main_econ_PopulationSatisfaction = clamp(econ.main_econ_PopulationSatisfaction, 0.0, 1.0)

	# govt debt = spending - tax revenue
	econ.tax_rate = 0.2
	var gov_revenue = econ.main_econ_GDP * econ.tax_rate
	var gov_spending = 250.0  # can be dynamic
	econ.gov_debt += gov_spending - gov_revenue
	if econ.gov_debt > 1000:
		# Lower investor confidence and raise inflation risk ior something
		econ.growth_multiplier -= 0.01
		econ.inflation_rate += 0.005
		econ.main_econ_PopulationSatisfaction -= 0.02
	# Growth multiplier reacts to happiness
	econ.growth_multiplier = 1.0 if econ.main_econ_PopulationSatisfaction > 0.7 else 0.95
# Fiscal Policies

var policies = []
var passedPoliciesIDs = []
var rolledPolicies = []

func getRandomPolicy():
	var rng
	var randomPolicyIndex
	while true:
		rng = RandomNumberGenerator.new()
		randomPolicyIndex = rng.randi_range(0, 9)
		if !rolledPolicies.has(randomPolicyIndex):
			rolledPolicies.append(randomPolicyIndex)
			break

	return policies[randomPolicyIndex]

func _ready():
	SignalBus.connect("requestEconomyData", deliverEconomicData)
	SignalBus.connect("newPolicy", newPolicy)
	SignalBus.connect("policyPassed", _on_PolicyPassed)
	SignalBus.connect("processPolicy", passPolicy)
	policies.resize(10)
	policies[0] = {
		"name": "Emergency Infrastructure & Stimulus Act (EISA)",
		"type": "Fiscal",
		"description": "The Emergency Infrastructure & Stimulus Act is a comprehensive fiscal expansionary policy designed to combat a national economic downturn. It includes a $500 billion federal infrastructure package, direct cash transfers to households, and temporary tax cuts for middle-income earners and small businesses. The policy aims to rapidly boost aggregate demand, create jobs, and restore economic confidence, particularly in depressed regions.",
		"data": {
			"ag_demand": 180,
			"gov_debt": 200,
			"net_exports": -25,
			"main_econ_PopulationSatisfaction": 0.1,
			"inflation_rate": 0.02,
			"tax_rate": -0.05
		}
	}

	policies[1] = {
		"name": "Quantitative Easing Program",
		"type": "Monetary",
		"description": "The central bank buys government securities to inject money into the economy, lower long-term interest rates, and stimulate both investment and consumption during periods of low growth or deflationary pressure.",
		"data": {
			"ag_demand": 100,
			"inflation_rate": 0.01,
			"currency_value": -0.05,
			"gov_debt": -100
		}
	}

	policies[2] = {
		"name": "National R&D Grant Initiative",
		"type": "Fiscal",
		"description": "A government-funded initiative to support research and development in technology and green energy sectors. Designed to increase productivity and long-term aggregate supply, while fostering innovation.",
		"data": {
			"ag_supply": 120,
			"gov_debt": 150,
			"main_econ_PopulationSatisfaction": 0.05
		}
	}

	policies[3] = {
		"name": "Tobacco & Sugar Price Controls",
		"type": "Market-Managing",
		"description": "Price floors are established on tobacco and sugary products to discourage unhealthy consumption, improve public health, and reduce long-term medical costs, albeit at the cost of lower supply and consumer freedom.",
		"data": {
			"ag_supply": -80,
			"inflation_rate": -0.03,
			"main_econ_PopulationSatisfaction": -0.1
		}
	}

	policies[4] = {
		"name": "Export Subsidy Reform Act",
		"type": "Trade Policy",
		"description": "This policy subsidizes domestic manufacturers' exports, making them more competitive internationally. It aims to reduce trade deficits and stimulate production.",
		"data": {
			"net_exports": 90,
			"ag_demand": 50,
			"inflation_rate": 0.01
		}
	}

	policies[5] = {
		"name": "Austerity Stabilization Bill",
		"type": "Fiscal",
		"description": "A conservative budget plan that includes cuts to public sector wages, welfare programs, and administrative spending to reduce national debt, at the cost of consumer demand and morale.",
		"data": {
			"ag_demand": -100,
			"gov_debt": -200,
			"main_econ_PopulationSatisfaction": -0.2
		}
	}

	policies[6] = {
		"name": "Interest Rate Hike Program",
		"type": "Monetary",
		"description": "Raises the national interest rate to combat inflation and strengthen the national currency. This policy slows down borrowing and consumer spending.",
		"data": {
			"inflation_rate": -0.02,
			"currency_value": 0.1,
			"ag_demand": -50
		}
	}

	policies[7] = {
		"name": "Streamlined Business Licensing Act",
		"type": "Market-Managing",
		"description": "Removes excessive licensing and regulation barriers for small and medium enterprises, encouraging entrepreneurship and boosting long-term productive capacity.",
		"data": {
			"ag_supply": 150,
			"growth_multiplier": 0.05
		}
	}

	policies[8] = {
		"name": "Free Trade Expansion Act",
		"type": "Trade Policy",
		"description": "Removes tariffs and quotas on imported goods, lowering consumer prices and promoting global trade partnerships, though it may reduce net exports.",
		"data": {
			"net_exports": -70,
			"currency_value": 0.05,
			"main_econ_PopulationSatisfaction": 0.02
		}
	}

	policies[9] = {
		"name": "Universal Basic Income Pilot",
		"type": "Fiscal",
		"description": "Implements a nationwide basic income for all citizens regardless of employment status. Intended to reduce poverty, boost consumer spending, and improve population well-being.",
		"data": {
			"ag_demand": 80,
			"main_econ_PopulationSatisfaction": 0.12,
			"gov_debt": 100
		}
	}
	await get_tree().create_timer(.01).timeout
	passPolicy(policies[2])
	#await get_tree().create_timer(1).timeout
	var policy = getRandomPolicy()
	SignalBus.emit_signal("displayPolicy", getRandomPolicy())
	SignalBus.emit_signal('broadcastCurrentPolicy', policy)

	get_parent().updateEconomy()

func newPolicy():
	var policy = getRandomPolicy()
	SignalBus.emit_signal("displayPolicy", policy)
	SignalBus.emit_signal('broadcastCurrentPolicy', policy)
func deliverEconomicData():
	SignalBus.deliverEconomyData.emit(
		{	"GDP": econ.main_econ_GDP,
			"PopulationSatisfaction": econ.main_econ_PopulationSatisfaction,
			"taxRate": econ.tax_rate,
			"unemployment": econ.unemployment,
			"govDebt": econ.gov_debt,
			"agDemand": econ.ag_demand,
			"agSupply": econ.ag_supply,
			"netExports": econ.net_exports,
			"growthMultiplier": econ.growth_multiplier,
			"inflation": econ.inflation_rate,
			"currencyValue": econ.currency_value})
func _on_PolicyPassed(policy):
		print("Passed Policy")
		print(policy)

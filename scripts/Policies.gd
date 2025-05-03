extends Node2D

@onready var econ = get_parent()
const POLICIES_COUNT = 31
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
		randomPolicyIndex = rng.randi_range(0, POLICIES_COUNT-1)
		if !rolledPolicies.has(randomPolicyIndex):
			rolledPolicies.append(randomPolicyIndex)
			break

	return policies[randomPolicyIndex]

func _ready():
	SignalBus.connect("requestEconomyData", deliverEconomicData)
	SignalBus.connect("newPolicy", newPolicy)
	SignalBus.connect("policyPassed", _on_PolicyPassed)
	SignalBus.connect("processPolicy", passPolicy)
	policies.resize(POLICIES_COUNT)
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
	

	policies [10] = {
		"name": "Carbon Tax & Dividend Act",
		"type": "Fiscal",
		"description": "Introduces a carbon tax on fossil fuel emissions, aiming to internalize environmental costs and reduce carbon output. Revenue is redistributed equally to citizens as a dividend, maintaining overall demand while incentivizing green energy adoption.",
		"data": {
			"ag_demand": 50,
			"ag_supply": -90,
			"inflation_rate": 0.02,
			"main_econ_PopulationSatisfaction": 0.05
		}
	}

	policies [11] = {
		"name": "National Workforce Retraining Act",
		"type": "Fiscal",
		"description": "Funds large-scale retraining and upskilling programs for workers displaced by automation and globalization. This long-term policy aims to reduce structural unemployment and improve labor productivity.",
		"data": {
			"ag_supply": 80,
			"unemployment": -0.04,
			"main_econ_PopulationSatisfaction": 0.07,
			"gov_debt": 75
		}    
	}

	policies [12] = {
		"name": "Financial Transaction Tax",
		"type": "Fiscal",
		"description": "Imposes a small tax on stock and derivatives trading to reduce speculative behavior and generate public revenue. Can slightly lower market liquidity but stabilize markets and raise funds for social spending.",
		"data": {
			"tax_rate": 0.04,
			"gov_debt": -50,
			"ag_demand": -10,
			"inflation_rate": -0.005
		}    
	}

	policies [13] = {
		"name": "Rural Connectivity Expansion Program",
		"type": "Fiscal",
		"description": "Aims to close the digital divide by investing in high-speed internet infrastructure in underserved rural areas, boosting economic activity and inclusion in those regions.",
		"data": {
			"ag_demand": 40,
			"ag_supply": 30,
			"gov_debt": 60,
			"main_econ_PopulationSatisfaction": 0.06
		}            
	}

	policies [14] = {
		"name": "National Housing Affordability Act",
		"type": "Fiscal",
		"description": "Funds the construction of affordable housing and introduces rent control in high-cost urban areas to alleviate housing crises, reduce homelessness, and increase disposable income for low-income households.",
		"data": {
			"ag_demand": 70,
			"inflation_rate": -0.02,
			"gov_debt": 90,
			"main_econ_PopulationSatisfaction": 0.09
		}        
	}

	policies [15] = {
		"name": "Unilateral Military Invasion",
		"type": "Fiscal",
		"description": "A large-scale military invasion without international support, leading to prolonged conflict, high military spending, and global condemnation. Civilian casualties and economic isolation follow.",
		"data": {
			"gov_debt": 250,
			"ag_demand": -100,
			"net_exports": -120,
			"main_econ_PopulationSatisfaction": -0.3,
			"inflation_rate": 0.03
		}        
	}

	policies [16] = {
		"name": "Nuclear Test Escalation",
		"type": "Protectionism",
		"description": "The country resumes underground nuclear weapons testing, violating international treaties. Global backlash results in sanctions, environmental damage, and plummeting diplomatic relations.",
		"data": {
			"net_exports": -90,
			"currency_value": -0.08,
			"main_econ_PopulationSatisfaction": -0.25,
			"ag_supply": -50
		}        
	}

	policies [17] = {
		"name": "Nuclear Reactor Meltdown",
		"type": "Market-Managing",
		"description": "A catastrophic failure at a nuclear power plant due to regulatory negligence causes a radioactive disaster, displacing communities and collapsing trust in government oversight.",
		"data": {
			"ag_supply": -100,
			"main_econ_PopulationSatisfaction": -0.4,
			"growth_multiplier": -0.1,
			"inflation_rate": 0.01
		}        
	}

	policies [18] = {
		"name": "Compulsory Military Draft",
		"type": "Fiscal",
		"description": "A national draft is enacted during wartime, forcing citizens into military service. It disrupts labor markets and sparks widespread civil unrest, especially among younger populations.",
		"data": {
			"ag_supply": -40,
			"main_econ_PopulationSatisfaction": -0.2,
			"growth_multiplier": -0.03
		}       
	}

	policies [19] = {
		"name": "Mismanagement of Nuclear Waste",
		"type": "Market-Managing",
		"description": "Improper disposal of nuclear waste leads to widespread contamination, health crises, and environmental lawsuits. Public trust erodes and cleanup costs spiral.",
		"data": {
			"ag_supply": -70,
			"main_econ_PopulationSatisfaction": -0.35,
			"gov_debt": 100
		}        
	}

	policies [20] = {
			"name": "Digital Economy Expansion Act",
			"type": "Fiscal",
			"description": "Invests heavily in nationwide digital infrastructure, tech education, and startup grants to foster a knowledge-based economy and digital job growth.",
			"data": {
				"ag_supply": 100,
				"growth_multiplier": 0.07,
				"gov_debt": 80
			}
		}

	policies [21] = {
		"name": "Sovereign Wealth Fund Initiative",
		"type": "Fiscal",
		"description": "Allocates surplus revenue from natural resources into a national investment fund, generating long-term passive income and insulating against commodity shocks.",
		"data": {
			"gov_debt": -50,
			"growth_multiplier": 0.03,
			"net_exports": 20
		}
	}

	policies [22] = {
		"name": "Urban Densification Incentives",
		"type": "Market-Managing",
		"description": "Provides tax breaks and subsidies for high-density housing developments near job centers to improve affordability and reduce urban sprawl.",
		"data": {
			"ag_demand": 30,
			"ag_supply": 60,
			"inflation_rate": -0.01
		}

	}

	policies [23] = {
		"name": "National Demographic Renewal Plan",
		"type": "Fiscal",
		"description": "Offers financial incentives for families to have children and improves childcare access to counter declining birthrates and future labor shortages.",
		"data": {
			"main_econ_PopulationSatisfaction": 0.1,
			"growth_multiplier": 0.02,
			"gov_debt": 60
		}

	}

	policies [24] = {
		"name": "Artificial Intelligence Integration Program",
		"type": "Fiscal",
		"description": "Supports business and government adoption of AI for productivity and automation. Includes job retraining funds to reduce displacement.",
		"data": {
			"ag_supply": 120,
			"main_econ_PopulationSatisfaction": -0.05,
			"gov_debt": 90
		}

	}

	policies [25] = {
	   	"name": "Luxury Goods Tax Expansion",
		"type": "Fiscal",
		"description": "Imposes higher taxes on luxury items and high-income earners to fund public programs and reduce income inequality.",
		"data": {
			"gov_debt": -70,
			"main_econ_PopulationSatisfaction": 0.03,
			"ag_demand": -20
		}

	}

	policies [26] = {
		"name": "Digital Economy Expansion Act",
		"type": "Fiscal",
		"description": "Invests heavily in nationwide digital infrastructure, tech education, and startup grants to foster a knowledge-based economy and digital job growth.",
		"data": {
			"ag_supply": 100,
			"growth_multiplier": 0.07,
			"gov_debt": 80
		}
	}

	policies [27] = {
		"name": "Luxury Goods Tax Expansion",
		"type": "Market-Managing",
		"description": "Imposes higher taxes on luxury items and high-income earners to fund public programs and reduce income inequality.",
		"data": {
			"gov_debt": -70,
			"main_econ_PopulationSatisfaction": 0.03,
			"ag_demand": -20
		}

	}

	policies [28] = {
		"name": "Gig Economy Rights Act",
		"type": "Market-Managing",
		"description": "Regulates the gig economy by guaranteeing minimum wages, benefits, and protections to freelancers and app-based workers.",
		"data": {
			"main_econ_PopulationSatisfaction": 0.1,
			"ag_supply": -20,
			"inflation_rate": 0.01
		}
	}
	policies [29] = {
		"name": "Foreign Investment Restriction Law",
		"type": "Protectionism",
		"description": "Imposes restrictions on foreign ownership in key industries to protect national security and domestic enterprises.",
		"data": {
			"net_exports": -30,
			"currency_value": 0.02,
			"ag_supply": -40
		}
	}
	policies[30] = {
		"name": "Nuclear Bomb Detonation at the Nation's Capital",
		"type": "Miscellaneous",
		"description": "Sets of a nuclear bomb at the nation's capital, not more needs to be said. We the Senate believe in lunacy.",
		"data": {
			"ag_supply": -300,
			"currency_value": -0.1,
			"net_exports": -100,
			"gov_debt": 400,
			"main_econ_PopulationSatisfaction": -0.4,
			"ag_demand": -40,
			"inflation_rate": .3
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

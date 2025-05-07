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
		"description": "The central bank buys government securities to inject money into the economy, lower long-term interest rates, and stimulate both investment and consumption during periods of low growth or deflationary pressure. This raises aggregate demand, lowers government debt, but slightly lowers your currency’s value. Also raises inflation, but very slightly.",
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
		"description": "A government-funded initiative to support research and development in technology and green energy sectors. Designed to increase productivity and long-term aggregate supply, while fostering innovation. Since you’re using government funds, this increases debt. It does seem to make the people happier, though.",
		"data": {
			"ag_supply": 120,
			"gov_debt": 150,
			"main_econ_PopulationSatisfaction": 0.05
		}
	}

	policies[3] = {
		"name": "Tobacco & Sugar Price Controls",
		"type": "Market-Managing",
		"description": "Price floors are established on tobacco and sugary products to discourage unhealthy consumption, improve public health, and reduce long-term medical costs, albeit at the cost of lower supply and consumer freedom. This aims to decrease inflation. The people’s reaction is still left to be seen, however.",
		"data": {
			"ag_supply": -80,
			"inflation_rate": -0.03,
			"main_econ_PopulationSatisfaction": -0.1
		}
	}

	policies[4] = {
		"name": "Export Subsidy Reform Act",
		"type": "Trade Policy",
		"description": "This policy subsidizes domestic manufacturers' exports, making them more competitive internationally. It aims to increase the country’s exports and stimulate production.",
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
		"description": "Implements a nationwide basic income for all citizens regardless of employment status. Intended to reduce poverty, boost consumer spending, and improve population well-being. Increases government debt, however.",
		"data": {
			"ag_demand": 80,
			"main_econ_PopulationSatisfaction": 0.12,
			"gov_debt": 100
		}
	}

	policies[10] = {
		"name": "Progressive Income Tax Reform",
		"type": "Fiscal",
		"description": "Adjusts income tax brackets to increase rates for high-income earners and decrease rates for low-income earners. Will make the upper class slightly unhappy while making the middle and lower classes much happier.",
		"data": {
			"tax_rate": -0.08,
			"ag_demand": 60,
			"main_econ_PopulationSatisfaction": 0.05
		}
	}

	policies[11] = {
		"name": "Central Bank Digital Currency (CBDC) Introduction",
		"type": "Monetary",
		"description": "Introduces a digital version of the national currency issued directly by the central bank to modernize the financial system and increase transaction efficiency. However, it may affect inflation and your currency’s value. People want to get a hold of the new cryptocurrency, though.",
		"data": {
			"currency_value": 0.03,
			"ag_demand": 40,
			"inflation_rate": 0.03
		}
	}

	policies[12] = {
		"name": "Deregulation of the Telecommunications Sector",
		"type": "Market-Managing",
		"description": "Removes regulations on pricing and market entry in the telecommunications industry to foster competition, create more jobs in the industry, reduce consumer costs, and stimulate innovation.",
		"data": {
			"growth_multiplier": 0.04,
			"main_econ_PopulationSatisfaction": 0.04,
			"unemployment": -0.02
		}
	}

	policies[13] = {
		"name": "Carbon Tax Implementation",
		"type": "Trade Policy",
		"description": "Imposes a tax on the emission of carbon dioxide and other greenhouse gases to discourage activities that contribute to climate change and promote investment in clean energy. However, a majority of industries still rely on fossil fuels and people aren’t too keen to switch to electric cars.",
		"data": {
			"ag_supply": -50,
			"net_exports": -10,
			"tax_rate": 0.05,
			"main_econ_PopulationSatisfaction": -0.05
		}
	}

	policies[14] = {
		"name": "Increased Minimum Wage",
		"type": "Fiscal",
		"description": "Mandates a higher minimum wage for workers, aiming to boost the income of low-wage earners.",
		"data": {
			"ag_demand": 70,
			"gov_debt": 200,
			"unemployment": 0.03,
			"ag_supply": -20,
		}
	}

	policies[15] = {
		"name": "Strategic Export Promotion Initiative",
		"type": "Trade Policy",
		"description": "The government invests in programs that support domestic industries in expanding their exports. This includes export financing, trade missions, and assistance with meeting international standards.",
		"data": {
			"net_exports": 70,
			"ag_supply": 40,
			"growth_multiplier": 0.03,
			"main_econ_PopulationSatisfaction": 0.03
		}
	}

	policies[16] = {
		"name": "Antitrust Regulation Enforcement",
		"type": "Market-Managing",
		"description": "There has been a noticeable increase in the number of monopolized industries in the country, leading to high prices. This policy aims to enforce antitrust laws to prevent monopolies and oligopolies, promoting competition and protecting consumers.",
		"data": {
			"ag_supply": 60,
			"growth_multiplier": 0.02,
			"main_econ_PopulationSatisfaction": 0.03
		}
	}

	policies[17] = {
		"name": "Tariffs on Imported Goods",
		"type": "Trade Policy",
		"description": "Imposes tariffs on every imported good to protect domestic producers from foreign competition. Glory to the republic!",
		"data": {
			"net_exports": -150,
			"ag_demand": -200,
			"ag_supply": -100,
			"inflation_rate": 0.20,
			"currency_value": -0.15, 
			"main_econ_PopulationSatisfaction": -0.4,
			"growth_multiplier": 0.7 
		}
	}

	policies[18] = {
		"name": "Increased Public Education Spending",
		"type": "Fiscal",
		"description": "Increases government spending on public education to improve human capital, productivity, and long-term economic growth.",
		"data": {
			"ag_supply": 80,
			"gov_debt": 90,
			"main_econ_PopulationSatisfaction": 0.05
		}
	}

	policies[19] = {
		"name": "Currency Devaluation",
		"type": "Monetary",
		"description": "Reduces the value of the national currency relative to other currencies to make exports more competitive and imports more expensive.",
		"data": {
			"net_exports": 50,
			"currency_value": -0.08,
			"inflation_rate": 0.05
		}
	}

	policies[20] = {
		"name": "Financial Deregulation",
		"type": "Market-Managing",
		"description": "Reduces regulations on the financial industry to promote innovation and risk-taking, potentially increasing investment and economic activity.",
		"data": {
			"ag_demand": 90,
			"growth_multiplier": 0.04
		}
	}

	policies[21] = {
		"name": "Subsidies for Renewable Energy",
		"type": "Trade Policy",
		"description": "Provides subsidies to renewable energy industries to encourage their growth and reduce reliance on fossil fuels.",
		"data": {
			"ag_supply": 40,
			"net_exports": -10,
			"main_econ_PopulationSatisfaction": 0.06,
"gov_debt": 50
		}
	}

	policies[22] = {
		"name": "Reduced Corporate Income Tax",
		"type": "Fiscal",
		"description": "Lowers the tax rate on corporate profits to stimulate investment. This decreases the government's revenue, but increases the performance of these corporations.",
		"data": {
			"ag_demand": 60,
			"ag_supply": 50,
			"tax_rate": -0.06,
			"unemployment": 0.02
		}
	}

	policies[23] = {
		"name": "Tight Monetary Policy",
		"type": "Monetary",
		"description": "Increases interest rates and reduces the money supply to combat inflation and stabilize the currency.",
		"data": {
			"inflation_rate": -0.05,
			"currency_value": 0.07,
			"ag_demand": -70
		}
	}

	policies[24] = {
		"name": "Price Ceilings on Essential Goods",
		"type": "Market-Managing",
		"description": "Sets maximum prices on essential goods like food and medicine to protect consumers from price gouging.",
		"data": {
			"ag_supply": -40,
			"main_econ_PopulationSatisfaction": 0.08,
			"inflation_rate": -0.03
		}
	}

	policies[25] = {
		"name": "Export Quotas",
		"type": "Trade Policy",
		"description": "Limits the quantity of specific goods that can be exported to ensure domestic supply. Though it decreases the nation’s exports, the supply of our country is fostered.",
		"data": {
			"net_exports": -60,
			"ag_supply": 60
		}
	}

	policies[26] = {
		"name": "Increased Unemployment Benefits",
		"type": "Fiscal",
		"description": "Increases the amount and duration of unemployment benefits to support unemployed workers and maintain consumer spending.",
		"data": {
			"ag_demand": 40,
			"gov_debt": 70,
			"main_econ_PopulationSatisfaction": 0.07,
			"unemployment": -0.03
		}
	}

	policies[27] = {
		"name": "Forward Guidance",
		"type": "Monetary",
		"description": "The central bank communicates its intentions about future monetary policy to influence market expectations and behavior. They are interested in a small expansionary monetary policy that increases the money in circulation.",
		"data": {
			"currency_value": 0.02,
			"ag_demand": 50,
			"inflation_rate": 0.01
		}
	}

	policies[28] = {
		"name": "Nationalization of Key Industries",
		"type": "Market-Managing",
		"description": "The government takes ownership and control of strategic industries like energy or transportation. This costs our government money and takes away from its citizens, but future potential growth is improved.",
		"data": {
			"ag_supply": -20,
			"gov_debt": 200,
			"main_econ_PopulationSatisfaction": -0.1,
			"growth_multiplier": 0.08
		}
	}

	policies[29] = {
		"name": "Trade Embargo",
		"type": "Trade Policy",
		"description": "We believe that our country is capable of being completely self-sufficient. Trading with other countries shows a lack of trust in our own domestic markets to sufficiently provide for our nation. This policy proposes a complete ban on trade with other countries. ",
		"data": {
			"net_exports": -80,
			"ag_demand": -30,
			"currency_value": -0.9,
			"inflation_rate": .5
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
	#passPolicy(policies[2])
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

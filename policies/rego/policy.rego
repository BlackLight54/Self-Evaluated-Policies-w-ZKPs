package gasSupport

import future.keywords.contains
import future.keywords.if
import future.keywords.in

default policyParameters := {
	"thresholds": {
		"rollingConsumption": {
			"mid": 3000,
			"high": 7000,
		},
		"currentSaving": {
			"low": 250,
			"mid": 500,
			"high": 1000,
		},
	},
	"supports": {
		#rows: rollingConsumption
		#cols: currentSaving
		"low": {"low": ["percent", 10], "mid": ["percent", 10], "high": ["percent", 10]},
		"mid": {"low": ["percent", 10], "mid": ["percent", 10], "high": ["percent", 10]},
		"high": {"low": ["percent", 10], "mid": ["percent", 10], "high": ["percent", 10]},
	},
	"socialSupports": {"ChangedWorkcapacity": {
		"credentialType": "ChangedWorkcapacityCredential",
		"support": ["nominal", 1000],
	}},
}

rollingConsumption := value if {
	pastConsumptionCreds := [pastConsumptionCred |
		some cred in input.credentialData.verifiableCredential
		cred.type[_] == "ProofOfActualGasConsumptionCredential"
		[currentYear, currentMonth, _] := time.date(time.now_ns())
		months := numbers.range(1, 12)
		month := months[x]
		((((currentYear * 12) + currentMonth) - 1) - 12) + month == (to_number(cred.year) * 12) + to_number(cred.month)
		pastConsumptionCred := cred
	]
	count(pastConsumptionCreds) == 12
	pastConsumptionValues := [value | value := pastConsumptionCreds[_].consumption]
	count(pastConsumptionValues) == 12
	value := sum(pastConsumptionValues) / count(pastConsumptionCreds)
}

classConsumption := "high" if rollingConsumption >= policyParameters.thresholds.rollingConsumption.high

classConsumption := "mid" if {
	rollingConsumption >= policyParameters.thresholds.rollingConsumption.mid
	rollingConsumption < policyParameters.thresholds.rollingConsumption.high
}

classConsumption := "low" if rollingConsumption < policyParameters.thresholds.rollingConsumption.mid

currentConsumption := input.parameter.consumption

classSaving := "high" if {
	policyParameters.thresholds.currentSaving.high < rollingConsumption - currentConsumption
}

else := "mid" if {
	policyParameters.thresholds.currentSaving.mid < rollingConsumption - currentConsumption
}

else := "low" if {
	policyParameters.thresholds.currentSaving.low < rollingConsumption - currentConsumption
}

applySupport(support, base) := base * multiplier if {
	[type, percent] := support
	type == "percent"
	multiplier := 1 - (0.01 * percent)
}

applySupport(support, base) := base - value if {
	[type, value] := support
	type == "nominal"
}

currentPrice := input.parameter.price

paymentBase := res if {
	currentPrice.unit == "HUF"
	res := currentConsumption * currentPrice.amount
}

paymentAfterSavings := applySupport(policyParameters.supports[classConsumption][classSaving], paymentBase)

applySupports(supports, Value) := result if {
	nominalSupports := [value |
		[type, value] := supports[_]
		type == "nominal"
	]
	percentSupports := [value |
		[type, value] := supports[_]
		type == "percent"
	]
	result := (Value - sum(nominalSupports)) - (Value * sum(percentSupports))
}


paymentAfterSupports := value if {
	socialSupports := [ support |
		cred := input.credentialData.verifiableCredential[_]
		cred.type[_] == policyParameters.socialSupports[x].credentialType
		support := policyParameters.socialSupports[x].support
	]
	value := applySupports(socialSupports, paymentAfterSavings)
}

supportAmount := paymentBase - paymentAfterSupports

default allow := false

allow if {
	supportAmount := paymentBase - paymentAfterSupports
	supportAmount == input.parameter.expectedSupportAmmount
}

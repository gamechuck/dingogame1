extends Control

onready var _cases_label := $HB/VB/PC/CasesLabel

func _process(_delta : float) -> void:
	var cases : Array = State.case_manager.cases
	var s := ""
	s += "[CASES]\n"
	for i in cases.size():
		var case : classCase = cases[i]
		s += str(i) + " - " + case.type + " - " + case.target.name + "\n"
		for j in case.investigations.size():
			# print investigations
			var investigation : classInvestigation = case.investigations[j]

			s += "    "
			if investigation.closed:
				s += "+ "
			else:
				s += "- "

			s += investigation.investigator_name + "\n"

	_cases_label.text = s

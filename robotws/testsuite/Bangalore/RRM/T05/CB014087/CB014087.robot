*** Settings ***
Documentation	Feature: CB014087
...				Author: Rakshith.b@nokia.com
Suite Setup		Run keywords	Setup CUS Env And Common Suite Setup	AND		Collect Snapshot
Test Setup		Case_Setup
Test Teardown	Run keywords	Case_Teardown	AND		Collect Snapshot
Force Tags		SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS    PY39

Resource		./resources/CB014087_keywords.robot

*** Variables ***
${config_path}	${CURDIR}/resources/config
${scfc}			${config_path}/CB014087.xml
${cus_yaml}		${config_path}/CB014087.yaml

*** Test Cases ***
[1]CB014087_eNB_successfully_completes_EN-DC_Cell_Activation_procedure_for_coordinated_NR_cell_upon_the_minimum_number_of_activated_LTE_cells
	[Tags]		QC_     QCD_MN_RAN      QCP_RAN_VRF		Non_DSS
	Wait Until Keyword Succeeds		180	30	Verify GNB cell available
	ENDC power saving for NR CELL	Enerysaving=0
	Verify GNB cell energy saving
	Block cell	2
	Wait Until Keyword Succeeds		180	30	Verify cell status	3	EnergySaving
	Wait For Next Full Pm Interval
	Verify no ENDC NR Cell activation after UE attach	UE=2
	Verify cell status	1	NotEnergySaving
	Verify cell status	3	NotEnergySaving
	Verify ENDC NR Cell activation after UE attach		UE=3
	Verify cell status	1	NotEnergySaving
	Verify cell status	3	NotEnergySaving
	Verify GNB cell available
	Check Counters CB014087		3
	[Teardown]	Run keywords	Unblock cell	2	AND		Case_Teardown	AND		Collect Snapshot

[1]CB014087_eNB_successfully_completes_EN-DC_Cell_Activation_procedure_the_minimum_number_of_activated_LTE_cells_and_the_paired_LTE_DSS_cell_status
	[Tags]		QC_     QCD_MN_RAN      QCP_RAN_VRF		DSS
	ta5g_commissioning.Send Delta Commissioning    ${config_path}/CB014087_DSS.json
	Configure NR DSS cell
	Wait Until Keyword Succeeds		180	30	Verify GNB cell available
	ENDC power saving for NR CELL	Enerysaving=0
	DSS power saving for NR CELL
	Verify GNB cell energy saving
	Wait Until Keyword Succeeds		180	30	Verify cell status	3	EnergySaving
	Block cell	2
	Wait For Next Full Pm Interval
	Verify no ENDC NR Cell activation after UE attach	UE=1
	Verify cell status	3	EnergySaving
	Verify cell status	1	NotEnergySaving
	Reset cell	3
	Wait Until Keyword Succeeds		60	10	Verify cell status	3	NotEnergySaving
	Verify ENDC NR Cell activation after UE attach		UE=1
	Verify cell status	3	NotEnergySaving
	Verify cell status	1	NotEnergySaving
	Verify GNB cell available
	Check Counters CB014087		1
	[Teardown]	Run keywords	Unblock cell	2	AND		Case_Teardown	AND		Collect Snapshot
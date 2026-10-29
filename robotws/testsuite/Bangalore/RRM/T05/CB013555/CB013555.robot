*** Settings ***
Documentation	Feature: CB013555
...				Author: Rakshith.b@nokia.com
Suite Setup		Setup CUS Env And Common Suite Setup
Suite Teardown	Collect Snapshot
Test Setup		Case_Setup
Test Teardown	Case_Teardown
Force Tags		SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LANO_CUS    PY39

Resource		./resources/CB013555_keywords.robot

*** Variables ***
${config_path}	${CURDIR}/resources/config
${scfc}			${config_path}/CB013555.xml
${cus_yaml}		${config_path}/CB013555.yaml

*** Test Cases ***
CB013555_SR_A_B101_Verification_of_B1_NR_measurements_activation_based_on_SPID_without_DL_UL_buffer_overflow_with_MODPR_and_MOPR
	[Tags]		QC_232201     QCD_MN_RAN      QCP_RAN_VRF	Split_A
	Wait For Next Full Pm Interval
	Attach UE and verify B1-NR configured								1	1
	Attach UE and verify B1-NR not configured							2	1
	Attach UE and verify B1-NR not configured							3	1
	Start data transfer and verify Scell addition						1	dl
	Start data transfer and verify B1-NR and Scell addition				3	dl
	Start data transfer and verify B1-NR not configured 				1	ul
	Start data transfer and verify B1-NR configured 					2	ul
	Start data transfer and verify B1-NR not configured 				3	ul
	Report B1-NR measurement and validate sgnb addition					1
	Report B1-NR measurement and validate no sgnb addition				2
	Report B1-NR measurement and validate no sgnb addition				3
	Start data transfer and validate sgnb addition and Scell addition	2	dl
	Start data transfer and validate sgnb addition						3	ul
	Check Counters CB013555-SR-A-B101

CB013555_SR_A_B102_UE_with_ERAB_with_QCI_not_present_on_bypassBuffTrigEnDcQciList_requires_DL_buffer_overflow_to_establish_ENDC
	[Tags]		QC_236069     QCD_MN_RAN      QCP_RAN_VRF	Split_B
	ta5g_commissioning.Send Delta Commissioning    ${config_path}/CB013555_QCI_7.json
	Wait For Next Full Pm Interval
	Attach UE and verify B1-NR configured								1	1
	Start data transfer and verify Scell addition						1	dl
	Report B1-NR measurement and validate no sgnb addition				1
	Start data transfer and validate sgnb addition						1	ul
	Attach UE and verify B1-NR configured								2	1
	Start data transfer and verify B1-NR not configured					2	ul
	Report B1-NR measurement and validate no sgnb addition				2
	Start data transfer and validate sgnb addition and Scell addition	2	dl
	Attach UE and verify B1-NR configured								3	1
	Start data transfer and verify B1-NR not configured					3	ul
	Add bearer and wait for UE IDLE										3	7	50
	Start data transfer and verify B1-NR configured						3	ul
	Report B1-NR measurement and validate sgnb addition					3
	Check Counters CB013555-SR-A-B102

CB013555_SR_A_B103_Buffer_based_mechanisms_remain_disabled_after_ERAB_Release_of_ERAB_with_QCI_present_on_bypassBuffTrigEnDcQciList
	[Tags]		QC_236078     QCD_MN_RAN      QCP_RAN_VRF	Split_C
	ta5g_commissioning.Send Delta Commissioning    ${config_path}/CB013555_QCI_7.json
	Wait For Next Full Pm Interval
	Attach UE and verify B1-NR configured								1	1
	Report B1-NR measurement and validate no sgnb addition				1
	Add bearer and wait for UE IDLE										1	7	50
	Start data transfer and verify B1-NR configured						1	ul
	Delete bearer														1	7
	Sleep	5
	Report B1-NR measurement and validate sgnb addition					1
	Check Counters CB013555-SR-A-B103
*** Settings ***
Documentation
...        [Procedure]        "SR001936_Verify_all_sfp_related_parameters_and_dynamic_data"
...        [Author]           "Meghana J"
...        [Feature_ID]       "SR001936"
...        [Maintenance]      "TRS I & V Tools Bangalore Team"
...        [Funtion_Hash_Tags] "SFP Testing"
...        [Validated_TestLine]     "10_2_T0401-ASIL01"
...        [Config_Comments]         "10G SFP"

Force Tags	CLOUD_R4P_IPSEC		CA_E2ET_BTSTRSPZ	SBTS00	SBTS22A	RAN_4G	RAN_4G_FDD	QCD_MN_RAN	QCP_RAN_VRF		CRT

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/SR001936_Common_keywords.robot

Suite Setup                     Pre-conditions for testsuite
Suite Teardown                   Post-conditions for testteardown

***Test Cases***
[1]SR001936_Verify_all_sfp_related_parameters_and_dynamic_data
	Perform BASIC Commisioning
	FOR    ${i}    IN RANGE    0    1
		Continue For Loop If    ${i} == 1
		${working_port}=    Set Variable    ${eifi_ports_2}[${i}]
		Set Suite Variable    ${working_port}    ${working_port}
		Sleep    60
		Verify Alarm    faultid=61029    should_exist=${false}
		Check EIFi link is up
		Vendor Details Advanced
		Checking Tx and Rx Power
		Checking Important Parameters
		Perform Recommissioning    type=param    param_path=${ethlk_mocs_2}[${i}]:speedAndDuplex    operation=update    value=${set_speed_10G}
		Verify Alarm    faultid=61029    should_exist=${false}
		Perform Recommissioning    type=param    param_path=${ethlk_mocs_2}[${i}]:speedAndDuplex    operation=update    value=${set_speed_25G}
		Verify Alarm    faultid=4679    should_exist=${true}
		Perform Recommissioning    type=param    param_path=${ethlk_mocs_2}[${i}]:speedAndDuplex    operation=update    value=${set_speed_1G}
		Verify Alarm    faultid=61029    should_exist=${true}
		Perform Recommissioning    type=param    param_path=${ethlk_mocs_2}[${i}]:speedAndDuplex    operation=update    value=${set_speed_Auto}
		Verify Alarm    faultid=61029    should_exist=${false}
		Check EIFi link is up
	END
*** Settings ***
Documentation
...		[Author]				"Nandini R"
...		[Procedure]				Verify IKE and SA Rekeying
...		[Requirement ID]		WBTS_SEC_50722
...		[Feature ID]			5GC002072-C
...		[Validated_TestLine]	7-2-UTE5GCLOUDIAVTL03(10.58.66.134)
...		[Config_Comments]		Basic Configuration
...		[Funtion_Hash_Tags]		Security_Hardening

Force Tags		SBTS00		QCD_MN_RAN		QCP_RAN_VRF	CRT

Resource		${CURDIR}/resources/common_HZ_keywords.robot

Suite Setup			Run Keywords	Setup Oamops        dut=vcu_cran12		alias=vcu		AND		Setup Oamops	dut=vdu_cran12		alias=vdu
Suite Teardown		Run Keywords	Collect Snapshot	dut=vcu_cran12		operation_timeout=300	alias=vcu	AND
...		Teardown Oamops		dut=vcu_cran12		alias=vcu		AND
...		Collect Snapshot	dut=vdu_cran12		operation_timeout=300	alias=vdu   AND
...		Teardown Oamops     dut=vcu_cran12		alias=vdu

*** Test Cases ***
[1][2.0] CB007962_D__SEC__enhanced_password_rule_for_username_webEM_vDU
	Setup Oamops        dut=vcu_cran12
	Perform Recommissioning	    dut=vcu_cran12	type=delta      delta_file=${Password_History_Length_1_vCU}		timeout=400
    Sleep   120
	Validation for BTS Security Administrator		vcu_cran12
	Validation for BTS Application User		vcu_cran12
	Check Nemuadmin password enhancement	vcu_cran12
	Validation for BTS Read only user		vcu_cran12
	Create new User		vcu_cran12
	Teardown Oamops     dut=vcu_cran12

	Setup Oamops        dut=vdu_cran12
	Perform Recommissioning	    dut=vdu_cran12	type=delta      delta_file=${Password_History_Length_1_vDU}		timeout=400
	Validation for BTS Security Administrator		vdu_cran12
	Validation for BTS Application User		vdu_cran12
	Validation for BTS Read only user		vdu_cran12
	Check Nemuadmin password enhancement	vdu_cran12
	Create new User		vdu_cran12
	Teardown Oamops     dut=vdu_cran12
	[Teardown]		Revert credentials at the End
*** Settings ***
Documentation
...		[Author]				"Nandini R"
...		[Procedure]				Verify IKE and SA Rekeying
...		[Requirement ID]		WBTS_SEC_50722
...		[Feature ID]			5GC002072-C
...		[Validated_TestLine]	7-2-UTE5GCLOUDIAVTL03(10.58.66.134)
...		[Config_Comments]		Basic Configuration
...		[Funtion_Hash_Tags]		Security_Hardening

Force Tags	SBTS00		QCD_MN_RAN	QCP_RAN_VRF	CRT

Resource        ${CURDIR}/resources/common_HZ_keywords.robot

Suite Setup			Run Keywords	Setup Oamops        dut=vcu_cran12		alias=vcu		AND		Setup Oamops	dut=vdu_cran12		alias=vdu
Suite Teardown		Run Keywords	Collect Snapshot	dut=vcu_cran12	operation_timeout=300	alias=vcu	AND
...		Teardown Oamops		dut=vcu_cran12		alias=vcu		AND
...		Collect Snapshot	dut=vdu_cran12		operation_timeout=300	alias=vdu   AND
...		Teardown Oamops     dut=vcu_cran12		alias=vdu

*** Test Cases ***
[1][2.0] 5GC002072_C__SEC__Log_Activity_From_WebEM_User
#Step1: vCU
	Setup Oamops        dut=vcu_cran12
	Collect initial Audit Log		vcu_cran12

	Perform Recommissioning	    dut=vcu_cran12		type=delta      delta_file=${Set_TLS_state_forced}     timeout=400
	Sleep	10
	Reset		operation=reset_bts		dut=vcu_cran12		wait_for=300
	Sleep	10
	Perform Recommissioning	    dut=vcu_cran12		type=delta      delta_file=${Set_TLS_state_off}     timeout=400
	Sleep	10
	Perform Recommissioning	    dut=vcu_cran12	type=delta      delta_file=${Set_BTS_LUAC_parameters}     timeout=400
	Sleep	10

	Lock Account and verify Alarm		vcu_cran12		Nemuadmin
	Update Local User Account	dut=vcu_cran12		username=BTSSecurity	new_password=${default_password}		active_status=active
	Sleep	10
	Lock Account and verify Alarm		vcu_cran12		BTSSecurity
	Update Local User Account	dut=vcu_cran12		username=BTSApplication	new_password=${default_password}		active_status=active
	Sleep	10
	Lock Account and verify Alarm		vcu_cran12		BTSApplication
	Update Local User Account	dut=vcu_cran12		username=BTSRead	new_password=${default_password}		active_status=active
	Sleep	10
	Lock Account and verify Alarm		vcu_cran12		BTSRead

	Collect Latest Audit Log		vcu_cran12
	Verify Audit Log Events     vcu
	Teardown Oamops     dut=vcu_cran12

#Step2: vDU
	Setup Oamops        dut=vdu_cran12
	Collect initial Audit Log		vdu_cran12

	Perform Recommissioning	    dut=vdu_cran12		type=delta      delta_file=${Set_TLS_state_forced}		timeout=400
	Sleep	10
	Perform Recommissioning	    dut=vdu_cran12		type=delta      delta_file=${Lock_delta}				timeout=400
	Sleep	10
	Perform Recommissioning	    dut=vdu_cran12		type=delta      delta_file=${Set_TLS_state_off}     	timeout=400
	Sleep	10
	Perform Recommissioning	    dut=vdu_cran12		type=delta      delta_file=${Unlock_delta}				timeout=400
	Sleep	10
	Perform Recommissioning	    dut=vdu_cran12		type=delta      delta_file=${Set_BTS_LUAC_parameters}	timeout=400
	Sleep	10

	Lock Account and verify Alarm		vdu_cran12		Nemuadmin
	Update Local User Account	dut=vdu_cran12		username=BTSSecurity	new_password=${default_password}		active_status=active
	Sleep	10
	Lock Account and verify Alarm		vdu_cran12		BTSSecurity
	Update Local User Account	dut=vdu_cran12		username=BTSApplication	new_password=${default_password}		active_status=active
	Sleep	10
	Lock Account and verify Alarm		vdu_cran12		BTSApplication
	Update Local User Account	dut=vdu_cran12		username=BTSRead	new_password=${default_password}		active_status=active
	Sleep	10
	Lock Account and verify Alarm		vdu_cran12		BTSRead

	Collect Latest Audit Log		vdu_cran12
	Verify Audit Log Events     vdu
	Teardown Oamops     dut=vdu_cran12
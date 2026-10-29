*** Settings ***
Documentation
	...	[Procedure]				"The test case is planned to Verification of Dual U plane and GTP failure alarm"
	...	[Date]					"7-9-2020"
	...	[Author]				"Manohar KR"
	...	[QC_Path]				"QC_Path in Test Plan"
	...	[QC_ID]					"QC_ID in Test Lab for reporting"
	...	[Funtion_Hash_Tags]		"IPSEC","RANSHARING"


Resource        ${CURDIR}/resources/common_keywords.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Variables ***
${Dual_U_Plane}	/home/ute/fw_user_path/config/2326/4G5G_onair_SMT_singleNTP-2326_WORKING.xml
${Configure_secondary_Uplane}		/home/ute/fw_user_path/config/2326/Update_2NTP_delta.xml
${Wrong_GTP}			/home/ute/fw_user_path/config/2326/v2_4G5G_onair_NETACT_SRS_add_GTP_.xml
${GTP_proper}			/home/ute/fw_user_path/config/2326/4G5G_onair_SMT_singleNTP-2326_WORKING.xml


*** Test Cases ***
[1][1.0] TRS_SBTS_Dual_User_Plane_IP_Address_GTP-u Path Failure and Recovery_1_RP000770
	[Documentation]		"The test case to verify GTP-u path alarm"

	Perform Commissioning       scf_file=${Dual_U_Plane}       verify_bts_status=False		timeout=900
 	Sleep	30
	Perform Recommissioning    type=delta	delta_file=${Configure_secondary_Uplane}     verify_bts_status=False		timeout=900
	Check the configuration for Dual U plane
	Perform Commissioning       scf_file=${Wrong_GTP}       verify_bts_status=False		timeout=900
	Sleep	190
	check for gtp alarm and verify
	Sleep	10
	Perform Recommissioning   type=delta	delta_file=${GTP_proper}    verify_bts_status=False	timeout=900
	check for No gtp alarm
	Sleep	10

***Keywords***
Check the configuration for Dual U plane
	Setup Remote Access	remote_device=bts	alias=default
	${output}=		Remote Command Execute	command=cat /ffs/run/config/NCF.xml | grep -i "10.171.8.5"  alias=default
   	Should Contain  ${Output}	10.171.8.5
	${output2}=		Remote Command Execute	command=cat /ffs/run/config/NCF.xml | grep -i "10.171.8.4"  alias=default
   	Should Contain  ${Output2}	10.171.8.4
	Teardown Remote Access      alias=default
	Sleep	10

check for gtp alarm and verify
	Verify Alarm      faultid=6150

check for No gtp alarm
	Verify Alarm      faultid=6150      occurrences=1       should_exist=${False}      alarm_type=active

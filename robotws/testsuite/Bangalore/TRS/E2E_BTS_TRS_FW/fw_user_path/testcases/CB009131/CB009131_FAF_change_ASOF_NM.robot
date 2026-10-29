*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to Verification of CB009131_FAF"
	...		[Date]					"7-10-2023"
	...		[Author]				"Manohar KR"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"Firewall"
	...   	[Feature_ID]         	"CB009131"
	...  	[Validation_status]  	"Validated and Passed"
	...   	[Validated_TestLine] 	"5G_2326"
	...   	[Config] 				"NRBTS-1 firewall configuation"

Resource        ${CURDIR}/resources/common_keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Variables ***
${Backup_Comm_file}		/home/ute/fw_user_path/config/2326/4G5G_ONAIR_SMT_ASOF_scf_MRBTS-2326_20250626.xml
${Online_X2_link_Modify}	/home/ute/fw_user_path/config/3933/delta_files/Online_Modify_FAF_x2.xml
${actdynamicfirewall_enable}	/home/ute/fw_user_path/config/2326/Activating_CB009131_firewall.xml
${actdynamicfirewall_disable}	/home/ute/fw_user_path/config/2326/Deactivating_CB009131_firewall.xml


*** Test Cases ***
[1][1.0] TRS_CB009131_To verify Feature_status_change_during_runtime
	[Documentation]		"The test case to verify cb009131 feature activation and deactivation without reboot"

	Perform Commissioning       scf_file=${Backup_Comm_file}       verify_bts_status=False		timeout=900
	Verify Bts Status   should_be_onair=${True}      req_rat=5g
  	Sleep	5
	Setup Ems  config_device=netact1   alias=lab1042
   	Cm Upload   config_device=netact1   alias=lab1042
	Configuration Manage    config_device=netact1   config=CB009131_enable.json  plan_name=9131_enable
	...	delete_plan=${True}     should_provision=True       alias=lab1042
	Teardown Ems  config_device=netact1  alias=lab1042
	Sleep	100
	Check for No reboot
	Setup Ems  config_device=netact1   alias=lab1042
   	Cm Upload   config_device=netact1   alias=lab1042
	Configuration Manage    config_device=netact1   config=CB009131_disable.json  plan_name=9131_disable
	...   delete_plan=${True}     should_provision=True       alias=lab1042
	Teardown Ems  config_device=netact1  alias=lab1042
	Check for No reboot
	Sleep	50
	Collect Snapshot
	Collect Im Snapshot
	Sleep	100
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_enable}    timeout=30
	Check for No reboot
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_disable}    timeout=30
	Check for No reboot
	Sleep	50
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_enable}    timeout=30
	Check for No reboot
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_disable}    timeout=30
	Check for No reboot
	Sleep	50
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_enable}    timeout=30
	Check for No reboot
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_disable}    timeout=30
	Check for No reboot
	Sleep	50
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_enable}    timeout=30
	Check for No reboot
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_disable}    timeout=30
	Check for No reboot
	Sleep	50
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_enable}    timeout=30
	Check for No reboot
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_disable}    timeout=30
	Check for No reboot
	Sleep	50
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_enable}    timeout=30
	Check for No reboot
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_disable}    timeout=30
	Check for No reboot
	Sleep	50
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_enable}    timeout=30
	Check for No reboot
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_disable}    timeout=30
	Check for No reboot
	Sleep	50
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_enable}    timeout=30
	Check for No reboot
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_disable}    timeout=30
	Check for No reboot
	Sleep	50
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_enable}    timeout=30
	Check for No reboot
	Perform Recommissioning     type=delta      delta_file=${actdynamicfirewall_disable}    timeout=30
	Check for No reboot
	Sleep	50
	Collect Snapshot
	Collect Im Snapshot
	[Teardown]		Keywords To Run At End

***Keywords***

Keywords To Run At End
	Perform Commissioning       scf_file=${Backup_Comm_file}       verify_bts_status=False		timeout=900

Check for No reboot
	${stdout}=      Run     ping -c 20 192.168.255.129
    Should contain  ${stdout}  20 packets transmitted

*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to Verification of CB007279"
	...		[Date]					"7-9-2023"
	...		[Author]				"Manohar KR"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"IPSEC","RANSHARING"
	...   	[Feature_ID]         	"CB007279"
	...  	[Validation_status]  	"Validated and Passed"
	...   	[Validated_TestLine] 	"5G_3931"
	...   	[Config] 				"NRBTS-1 need to configured with 6 x2clist"

Resource         ${CURDIR}/resources/common_keywords.robot


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Variables ***
${profile}		Trunk
${Customer_scf}		/home/ute/fw_user_path/config/2326/ASOF_MRBTS-2326_MASTER_SCF_NETACT_1042_integrated_5GOnair.xml
${activation_flag}	FEATCADM-1:actLoginCredPartitionSync
${SW_Build_name}    /home/ute/fw_user_path/config/2326/ASOF_MRBTS-2326_MASTER_SCF_NETACT_1042_integrated_5GOnair.xml


*** Test Cases ***
[1][1.0] CB007279_To check the Login synchronisation from Target sw to Target sw
	[Documentation]		"The test case to verify 7279 feature "

	Perform Commissioning       scf_file=${Customer_scf}  	verify_bts_status=False     timeout=900
    sleep   2
	Setup Ems  config_device=netact1   alias=lab1042
   	Cm Upload   config_device=netact1   alias=lab1042
	Configuration Manage    config_device=netact1   config=CB007279_enable.json  plan_name=netact_7279_enable
	...      delete_plan=${True}     should_provision=True       alias=lab1042
	Teardown Ems  config_device=netact1  alias=lab1042
	Check for No reboot
	Check flag status is enabled
	Update Local User Account with New credentials
	Sleep	40
	Verify the New credentails
	Run Keyword And Ignore Error	Rollback Software		timeout=900	alias=default
	Sleep	609
	Verify the New credentails
	Sleep	60
	Verify the New credentails
	Collect Snapshot
	Collect Im Snapshot

***Keywords***

Check for No reboot
	${stdout}=      Run     ping -c 20 192.168.255.129
    Should contain  ${stdout}  20 packets transmitted, 20 received


Enable CB007279 activation flag
	Perform Recommissioning        type=param      rat=5g     param_path=MRBTS-3745/MNL-1/MNLENT-1/FEATCADM-1:actLoginCredPartitionSync
	...   operation=update     value=true      timeout=300     alias=target

Disable CB007279 activation flag
    	Perform Recommissioning        type=param      rat=5g     param_path=MRBTS-3745/MNL-1/MNLENT-1/FEATCADM-1:actLoginCredPartitionSync
		...   operation=update     value=false      timeout=300     alias=target


Check flag status is enabled
	${activation_flag}=      Get Parameter      param_path=${activation_flag}
    Should Be True     '${activation_flag}'=='True'


Check flag status is disabled
	${activation_flag}=      Get Parameter      param_path=${activation_flag}
    Should Be True     '${activation_flag}'=='False'

#usable keywords
	Check snapshot collection and IM snapshot is successful
	Reboot BTS
	#check parameter is enabled or not
	${Preemption_status}=      Get Parameter      param_path=${Preemption_enable}
    Should Be True     '${Preemption_status}'=='True'

Update Local User Account with New credentials
	Run Keyword And Ignore Error	Update Local User Account	username=Nemuadmin		password=Test@123	alias=default

Verify the New credentails
	Setup Remote Access	remote_device=bts	alias=default
	Teardown Remote Access      alias=default
	Sleep	20

*** Settings ***

Documentation
... 	[Procedure]				"The test case  verifies cb007279 feature verification."
...	    [Date]					"26-10-2022"
...	    [Author]				"Manohar "
...	    [Feature_ID] 			"CB007279"
... 	[Maintenance]			"TRS I & V Tools Bangalore Team"
...	    [Funtion_Hash_Tags] 	"E2LINK_RIC"
...	    [Validated_TestLine] 	"ASIB "
...	    [Precondition] 			"BTS should be operational and configured state"
...	    [QC_Path]               "QC_Path in Test Plan"
...	    [QC_ID]					"QC_ID in Test Lab for reporting"

Resource         ${CURDIR}/resources/common_keywords.robot
Resource         ${CURDIR}/resources/7160.robot

Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops

*** Variables ***
${Master_2326_scf}	 /home/ute/fw_user_path/config/2326/ASOF_MRBTS-2326_MASTER_SCF_NETACT_1042_integrated_5GOnair.xml
${profile}     Trunk


*** Test Cases ***
[1][1.0] CB007279_To_check_the_Login_synchronisation_from_FDSW_sw_to_Target_sw_and_FDSW

	Perform Commissioning       scf_file=${Master_2326_scf}       verify_bts_status=False		timeout=900
	Update Local User Account with New credentials
	Sleep	40
	Verify the New credentails
	Run Keyword And Ignore Error	Rollback Software		timeout=900	alias=default
	Sleep	509
	Verify the New credentails
	Run Keyword And Ignore Error	Rollback Software		timeout=900	alias=default
	Sleep	509
	Verify the New credentails
	Collect Snapshot
	Collect Im Snapshot





***Keywords***

Check for No reboot
	${stdout}=      Run     ping -c 20 192.168.255.129
    Should contain  ${stdout}  20 packets transmitted, 20 received


Enable CB007279 activation flag
    Perform Recommissioning     type=param  param_path=${activation_flag}    operation=update
	...    value=true     skip_parameter_relation_errors=${False}       timeout=100

Disable CB007279 activation flag
    Perform Recommissioning     type=param  param_path=${activation_flag}    operation=update
	...    value=false     skip_parameter_relation_errors=${False}       timeout=100


Check flag status is enabled
	${activation_flag}=      Get Parameter      param_path=${activation_flag}
    Should Be True     '${activation_flag}'=='True'


Check flag status is disabled
	${activation_flag}=      Get Parameter      param_path=${activation_flag}
    Should Be True     '${activation_flag}'=='False'


Update Local User Account with New credentials
	Run Keyword And Ignore Error	Update Local User Account	username=Nemuadmin		password=Test@123	alias=default

Verify the New credentails
	Setup Remote Access	remote_device=bts	alias=default
	Teardown Remote Access      alias=default
	Sleep	20
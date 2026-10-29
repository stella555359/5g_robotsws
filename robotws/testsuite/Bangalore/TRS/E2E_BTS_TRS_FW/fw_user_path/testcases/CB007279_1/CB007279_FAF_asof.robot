***Settings ***
Documentation
    ...     [Procedure]             "The test case is planned to validate Activation of the feature CB007279 without reset"
    ...     [Date]                  "20-06-22"
    ...     [Author]                "Manohar KR/Mahish"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB007279"
    ...     [Validation_status]     "Validated"
    ...     [Validated_TestLine]    "ASIK"

#Force Tags     CLOUD_R4P    CA_E2ET_BTSTRSPZ        SBTS00        [SBTS22R4]     4G_FDD       QCD_MN_SRAN        QCP_SRAN_SBTS        CRT

Resource        ${CURDIR}/resources/common_keywords.robot


Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops

*** Variables ***
${profile}		Trunk
${Customer_scf}		/home/ute/fw_user_path/config/2326/ASOF_MRBTS-2326_MASTER_SCF_NETACT_1042_integrated_5GOnair.xml
${activation_flag}	FEATCADM-1:actLoginCredPartitionSync

*** Test Cases ***
[1][1.0] CB007279_To_check_the_actLoginCredPartitionSync_Enabled_and_Disabled_and_check_status_after_reboot


	Perform Commissioning       scf_file=${Customer_scf}   verify_bts_status=False     timeout=400     alias=default
	Sleep    250
    Setup Ems  config_device=netact1   alias=lab1042
   	Cm Upload   config_device=netact1   alias=lab1042
	Configuration Manage    config_device=netact1   config=CB007279_enable.json  plan_name=netact_7279_enable
	...      delete_plan=${True}     should_provision=True       alias=lab1042
	Teardown Ems  config_device=netact1  alias=lab1042
	Check for No reboot
    Reset     operation=reset_bts    should_be_onair=True
	Check flag status is enabled
    Setup Ems  config_device=netact1   alias=lab1042
   	Cm Upload   config_device=netact1   alias=lab1042
	Configuration Manage    config_device=netact1   config=CB007279_disble.json  plan_name=netact_7279_disble
	...      delete_plan=${True}     should_provision=True       alias=lab1042
	Teardown Ems  config_device=netact1  alias=lab1042
	Check for No reboot
    Reset     operation=reset_bts    should_be_onair=True
	Check flag status is disabled
	Sleep	100
	Perform Recommissioning     type=param      param_path=${activation_flag}       operation=update        value=true      timeout=100
	Check for No reboot
    Reset     operation=reset_bts    should_be_onair=True
	Check flag status is enabled
    Perform Recommissioning     type=param      param_path=${activation_flag}       operation=update        value=false      timeout=100
	Check for No reboot
    Reset     operation=reset_bts    should_be_onair=True
	Check flag status is disabled


***Keywords***

Check for No reboot
	${stdout}=      Run     ping -c 50 192.168.255.129
    Should contain  ${stdout}  50 packets transmitted, 50 received


Enable CB007279 activation flag
    Perform Recommissioning     type=param  param_path=${activation_flag}    operation=update    value=true
	...     skip_parameter_relation_errors=${False}       timeout=100

Disable CB007279 activation flag
    Perform Recommissioning     type=param  param_path=${activation_flag}    operation=update    value=false
	...     skip_parameter_relation_errors=${False}       timeout=100

Check flag status is enabled
	${activation_flag}=      Get Parameter      param_path=${activation_flag}
    Should Be True     '${activation_flag}'=='True'

Check flag status is disabled
	${activation_flag}=      Get Parameter      param_path=${activation_flag}
    Should Be True     '${activation_flag}'=='False'
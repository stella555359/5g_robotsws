*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_NL_10317_1ASOE_1AHHB_1AEHC_1AHFIG  STATE_COMMISSIONED
Library  XML  use_lxml=True
Resource    ../../WebEM/test_resources/WebEM__Show_BTS_Start-up_view_automatically.robot
Resource    ../../WebEM/test_resources/WebEM__Check_test_dedicated_state.robot
Resource    ../../WebEM/test_resources/WebEM__Mobile_Simplified_Site_View_for_ASOE.robot
Resource    ../../FM/test_resources/FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.robot
Resource    ../../FM/test_resources/FM__Primary_core_power_off_on.robot
Resource    ../../FM/test_resources/FM__VN_CCplane_LTE_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__SoC_Loki_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__SoC_reset_counter_cleared_after_one_hour.robot
Resource    ../../FM/test_resources/FM__FHNET_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__SoC_reset_not_allowed_allowBbPoolRecoveryReset_false.robot
Resource    ../../FM/test_resources/FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour.robot
Resource    ../../FM/test_resources/FM__SoC_reset_actForceUnitAutoReset_true_same_fault_in_one_hour.robot
Resource    ../../FM/test_resources/FM__eCPRI_Radio_autonomous_reset_FID_9102_counter_exceeded.robot


Suite Setup      Set Library Search Order  ute_admin   taf.sbts.oam.coam.admin   hran_frame_sbts_siso
...                                        hran_frame_sbts_taf   ca_swm_general   ca_CIT_general
...                                        ca_WebEM_general    ca_WebEM_mobile

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1317



*** Test Cases ***
[1]WebEM__Show_BTS_Start-up_view_automatically
    [Tags]  QC_178967
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    						600
    ...    AND    Set Test Variable    ${RECOVERY_AFTER_DECOMMISSIONING_TIMEOUT}    900
    ...    AND    Set Test Variable    ${AFTER_DECOMMISSIONING_TIMEOUT}    			900
    ...    AND    Set Test Variable    ${RECOVERY_MODULE_TIMEOUT}    				600
    ...    AND    Set Test Variable    ${AFTER_COMMISSIONING_TIMEOUT}   			600
	...    AND    Set Test Variable    ${BTS_RESCUE_CONSOLE_TIMEOUT}   				800
    
    ...    AND    WebEM__Show_BTS_Start-up_view_automatically.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Show_BTS_Start-up_view_automatically
    TC__WebEM__Show_BTS_Start-up_view_automatically
    [Teardown]    Run Keywords    WebEM__Show_BTS_Start-up_view_automatically.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Check_test_dedicated_state
    [Tags]  QC_195768
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    
    ...    AND    WebEM__Check_test_dedicated_state.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Check_test_dedicated_state
    TC__WebEM__Check_test_dedicated_state
    [Teardown]    Run Keywords    WebEM__Check_test_dedicated_state.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Mobile_Simplified_Site_View_for_ASOE
    [Tags]  QC_172802
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    
    ...    AND    WebEM__Mobile_Simplified_Site_View_for_ASOE.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Mobile_Simplified_Site_View_for_ASOE
    TC__WebEM__Mobile_Simplified_Site_View_for_ASOE
    [Teardown]    Run Keywords    WebEM__Mobile_Simplified_Site_View_for_ASOE.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Tags]  QC_454531
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELLS_FAILED_TIMEOUT}    		  180
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}   		  600
    ...    AND    Set Test Variable    ${MODULE_TYPE}   			      ASOE 
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}               4383
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}             Internal BTS processes autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_RAT_RESET}   RAT autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}               7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}             BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}                        Warning

   
    ...    AND    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Setup
    ...    AND    Modify Resource Search Order    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    TC__FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Teardown]    Run Keywords    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Primary_Core_power_off_on
    [Tags]  QC_452446
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}                 300
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}                120
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID_FIRST}       4590
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID_SECOND}      4592
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_FIRST}     Fault signature for crash or failure
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}    BTS Reset Cause
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}             7115
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}           BASE STATION INFORMATION
    ...    AND    Set Test Variable    ${SEVERITY}                      Warning
    ...    AND    Set Test Variable    ${EXPECTED_SCOPE}                Site
    ...    AND    Set Test Variable    ${EXPECTED_CATEGORY_1}           POWER_OFF
    ...    AND    Set Test Variable    ${EXPECTED_CATEGORY_2}           POWER_OFF
    ...    AND    Set Test Variable    ${EXPECTED_INFO_1}               
	...    Unknown power reset. Possible causes e.g. HW watchdog or external power off/on cycle
    ...    AND    Set Test Variable    ${EXPECTED_INFO_2}               Power off/on reset
	
    ...    AND    FM__Primary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Primary_core_power_off_on
    TC__FM__Primary_Core_power_off_on
    [Teardown]    Run Keywords    FM__Primary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order

	
[1]FM__VN_CCplane_LTE_reset_counter_exceeded
    [Tags]  QC_487221
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}   300
    
    ...    AND    FM__VN_CCplane_LTE_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__VN_CCplane_LTE_reset_counter_exceeded
    TC__FM_VN_CCplane_LTE_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__VN_CCplane_LTE_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order

	
[1]FM__SoC_Loki_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    	  ASOE
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}     600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    
    ...    AND    FM__SoC_Loki_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__SoC_Loki_reset_counter_exceeded
    TC__FM__SoC_Loki_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__SoC_Loki_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order

	
[1]FM__SoC_reset_counter_cleared_after_one_hour
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MODULE_TYPE}    		 ASOE
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    	 600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    	 900
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}          180
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}      2087
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    SoC autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}      7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}               Warning
	
    ...    AND    FM__SoC_reset_counter_cleared_after_one_hour.TC Setup
    ...    AND    Modify Resource Search Order    FM__SoC_reset_counter_cleared_after_one_hour
    FM__SoC_reset_counter_cleared_after_one_hour
    [Teardown]    Run Keywords    FM__SoC_reset_counter_cleared_after_one_hour.TC Teardown
    ...    AND    Restore Resource Search Order

	
[1]FM__FHNET_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}             900
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}            900
    ...    AND    Set Test Variable    ${FAILED_TIMEOUT}              600
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}           4383
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}         BTS site autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}  Virtual node not responding
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}           7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}         BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}                    Warning

    ...    AND    FM__FHNET_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__FHNET_reset_counter_exceeded
    TC__FM__FHNET_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__FHNET_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order

	
[1]FM__SoC_reset_not_allowed_allowBbPoolRecoveryReset_false
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    			   ASOE
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}   		   600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    		   900
    ...    AND    Set Test Variable    ${FAULT_ID_NETACT}              4019
    ...    AND    Set Test Variable    ${FAULT_NAME_ASOE_NETACT}       BTS site autonomous reset as recovery action
    ...    AND    Set Test Variable    ${FAULT_NAME_BBMOD_NETACT}      Baseband card autonomous reset as recovery action
    ...    AND    Set Test Variable    ${ALARM_ID_NETACT}              7101
    ...    AND    Set Test Variable    ${ALARM_NAME_NETACT}            BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY_NETACT}              Warning
	
    ...    AND    FM__SoC_reset_not_allowed_allowBbPoolRecoveryReset_false.TC Setup
    ...    AND    Modify Resource Search Order    FM__SoC_reset_not_allowed_allowBbPoolRecoveryReset_false
    TC__FM__SoC_reset_not_allowed_allowBbPoolRecoveryReset_false
    [Teardown]    Run Keywords    FM__SoC_reset_not_allowed_allowBbPoolRecoveryReset_false.TC Teardown
    ...    AND    Restore Resource Search Order

	
[1]FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable   ${SOC_TYPE}    				   ASOE
    ...    AND    Set Test Variable   ${STARTUP_TIMEOUT}               600
    ...    AND    Set Test Variable   ${HW_VARIANT}                    Loki
    ...    AND    Set Test Variable   ${EXPECTED_FAULT_ID}             4019
    ...    AND    Set Test Variable   ${EXPECTED_FAULT_NAME}           SoC autonomous reset as recovery action
    ...    AND    Set Test Variable   ${EXPECTED_ALARM_ID}             7101
    ...    AND    Set Test Variable   ${EXPECTED_ALARM_NAME}           BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable   ${SEVERITY}                      Warning
    ...    AND    Set Test Variable   ${EXPECTED_FAULT_NAME_RECOVERY}  Baseband card autonomous reset as recovery action
    ...    AND    Set Test Variable   ${EXPECTED_SECOND_FAULT_NAME}    Master unit has lost connection to the slave unit
    ...    AND    Set Test Variable   ${EXPECTED_SECOND_ALARM_ID}      7116
    ...    AND    Set Test Variable   ${EXPECTED_SECOND_ALARM_NAME}    BASE STATION SERVICE PROBLEM
    ...    AND    Set Test Variable   ${SEVERITY_SECOND}               Critical
    ...    AND    Set Test Variable   ${EXPECTED_THIRD_FAULT_ID}       10
    ...    AND    Set Test Variable   ${EXPECTED_THIRD_FAULT_NAME}     No connection to unit
    ...    AND    Set Test Variable   ${EXPECTED_FOURTH_FAULT_ID}      4714
    ...    AND    Set Test Variable   ${EXPECTED_SCOPE}                SoC   
    ...    AND    Set Test Variable   ${EXPECTED_FOURTH_FAULT_NAME}    FSP Reset Needed
	
    ...    AND    FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour.TC Setup
    ...    AND    Modify Resource Search Order    FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour
    TC__FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour
    [Teardown]    Run Keywords    FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour.TC Teardown
    ...    AND    Restore Resource Search Order

	
[1]FM__SoC_reset_actForceUnitAutoReset_true_same_fault_in_one_hour
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SOC_TYPE}    						 ASOE
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    				 900
    ...    AND    Set Test Variable    ${PING_TIMEOUT}                       600
    ...    AND    Set Test Variable    ${HW_VARIANT}                         Loki
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}                  4019
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}                SoC autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}                  7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}                BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}                           Warning
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_RECOVERY}       Baseband card autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_RECOVERY_ASOE}  BTS site autonomous reset as recovery action

    
    ...    AND    FM__SoC_reset_actForceUnitAutoReset_true_same_fault_in_one_hour.TC Setup
    ...    AND    Modify Resource Search Order    FM__SoC_reset_actForceUnitAutoReset_true_same_fault_in_one_hour
    TC__FM__SoC_reset_actForceUnitAutoReset_true_same_fault_in_one_hour
    [Teardown]    Run Keywords    FM__SoC_reset_actForceUnitAutoReset_true_same_fault_in_one_hour.TC Teardown
    ...    AND    Restore Resource Search Order
	

[1]FM__eCPRI_Radio_autonomous_reset_FID_9102_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MODULE_TYPE}    ASOE
    ...    AND    FM__eCPRI_Radio_autonomous_reset_FID_9102_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__eCPRI_Radio_autonomous_reset_FID_9102_counter_exceeded
    TC__FM__eCPRI_Radio_autonomous_reset_FID_9102_counter_exceeded
    [Teardown]    Run Keywords    FM__eCPRI_Radio_autonomous_reset_FID_9102_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order	
	
*** Keywords ***

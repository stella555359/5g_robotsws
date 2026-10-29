*** Settings ***
Documentation
...    Author: valentin.sorescu@nokia.com


Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_SRAN_NL_10364_1ASOF_1AHCE_2AHEJ  STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../WebEM/test_resources/WebEM__Navigation_Menu_Mirroring_Activation.robot
Resource    ../../WebEM/test_resources/WebEM__Navigation_Menu_Saving_BTS_Technical_Report_Mirroring.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_Get_RAD_SW_Domains.robot
Resource    ../../WebEM/test_resources/WebEM__Displaying_selected_RAD_debug_parameter_documentation.robot
Resource    ../../WebEM/test_resources/WebEM__RAD_debug_parameters.robot
Resource    ../../FM/test_resources/FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../WebEM/test_resources/WebEM__RBAC_enforcement_from_WebEM_Remote_Tool.robot
Resource    ../../FM/test_resources/FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.robot
Resource    ../../FM/test_resources/FM__SoC_Loki_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__B_5G_RAT_reset_counter_exceeded.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getHwInfo.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getCellList.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getSwVersionStatus.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults.robot
Resource    ../../WebEM/test_resources/WebEM__CLI_shall_support_command_getRadParam_with_DCC_user.robot
Resource    ../../WebEM/test_resources/WebEM__CLI_shall_support_command_startIPCaptureFile_with_DCC_user.robot
Resource    ../../WebEM/test_resources/WebEM__CLI_shall_support_command_checkAntennas_with_DCC_user.robot
Resource    ../../WebEM/test_resources/WebEM__CLI_shall_support_command_checkFans_with_DCC_user.robot
Resource    ../../WebEM/test_resources/WebEM__CLI_shall_support_command_checkHw_with_DCC_user.robot
Resource    ../../WebEM/test_resources/WebEM__CLI_shall_support_command_getRmodMeasurementsList_with_DCC_user.robot
Resource    ../../WebEM/test_resources/WebEM__CLI_shall_support_command_getSystemModuleList_with_DCC_user.robot
Resource    ../../WebEM/test_resources/WebEM__CLI_shall_support_command_softwareUpdate_with_DCC_user.robot
Resource    ../../WebEM/test_resources/WebEM__CLI_shall_support_command_getNmsState_with_DCC_user.robot
Resource    ../../WebEM/test_resources/WebEM__CLI_shall_support_command_getAllTroubleshootingScripts_DCC_user.robot
Resource    ../../WebEM/test_resources/WebEM__CLI_shall_support_command_getRADDebugParameters_with_DCC_user.robot
Resource    ../../WebEM/test_resources/WebEM__CLI_shall_support_command_resetAllRADDebugParameters_with_DCC_user.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Configuration_reset.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Planned_commissioning.robot


Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1364
${DISABLE_WATCHDOG}    ${TRUE}


*** Test Cases ***
[1]WebEM__Navigation_Menu_Mirroring_Activation
    [Tags]  QC_151550
    [Setup]    WebEM__Navigation_Menu_Mirroring_Activation.TC Setup
    [Teardown]    WebEM__Navigation_Menu_Mirroring_Activation.TC Teardown
    TC__WebEM__Navigation_Menu_Mirroring_Activation


[1]WebEM__Navigation_Menu_Saving_BTS_Technical_Report_Mirroring
    [Tags]  QC_151551
    [Setup]    WebEM__Navigation_Menu_Saving_BTS_Technical_Report_Mirroring.TC Setup
    [Teardown]    WebEM__Navigation_Menu_Saving_BTS_Technical_Report_Mirroring.TC Teardown
    TC__WebEM__Navigation_Menu_Saving_BTS_Technical_Report_Mirroring


[1]WebEM__Admin_CLI_Get_RAD_SW_Domains
    [Tags]  QC_151528
    [Setup]    WebEM__Admin_CLI_Get_RAD_SW_Domains.TC Setup
    [Teardown]    WebEM__Admin_CLI_Get_RAD_SW_Domains.TC Teardown
    TC__WebEM__Admin_CLI_Get_RAD_SW_Domains


[1]WebEM__Displaying_selected_RAD_debug_parameter_documentation
    [Tags]  QC_151531
    [Setup]    WebEM__Displaying_selected_RAD_debug_parameter_documentation.TC Setup
    [Teardown]    WebEM__Displaying_selected_RAD_debug_parameter_documentation.TC Teardown
    TC__WebEM__Displaying_selected_RAD_debug_parameter_documentation


[1]WebEM__RAD_debug_parameters
    [Tags]  QC_151527
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1800
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    600s

    ...    AND    WebEM__RAD_debug_parameters.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__RAD_debug_parameters
    TC__WebEM__RAD_debug_parameters
    [Teardown]    Run Keywords    WebEM__RAD_debug_parameters.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Tags]  QC_151552
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ASOF
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200

    ...    AND    FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order



[1]FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Tags]  QC_151521
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ASOF
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200

    ...    AND    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Tags]  QC_151529
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ASOF
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Tags]  QC_151526
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ASOF
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200

    ...    AND    FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_5G_RAT_reset_counter_exceeded
    [Tags]  QC_151548
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ASOF
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT}    180
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    300

    ...    AND    FM__B_5G_RAT_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_5G_RAT_reset_counter_exceeded
    TC__FM__B_5G_RAT_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__B_5G_RAT_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Tags]  QC_151549
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELLS_FAILED_TIMEOUT}    2400
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    2400
    ...    AND    Set Test Variable    ${MODULE_TYPE}    ASOF
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    4383
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Internal BTS processes autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_RAT_RESET}    RAT autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
    ...    AND    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Setup
    ...    AND    Modify Resource Search Order    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    TC__FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Teardown]    Run Keywords    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Teardown
    ...    AND    Restore Resource Search Order



[1]WebEM__RBAC_enforcement_from_WebEM_Remote_Tool
    [Tags]  QC_151547
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    WebEM__RBAC_enforcement_from_WebEM_Remote_Tool.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__RBAC_enforcement_from_WebEM_Remote_Tool
    TC__WebEM__RBAC_enforcement_from_WebEM_Remote_Tool
    [Teardown]    Run Keywords    WebEM__RBAC_enforcement_from_WebEM_Remote_Tool.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__CM__Commissioning__Configuration_reset
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Configuration Reset Timeout}    4000
    ...    AND    Set Test Variable    ${Conf_reset_by_AdminAPI}    ${TRUE}
    ...    AND    Set Test Variable    ${RM_DETECTION_TIMEOUT}    35 min
    ...    AND    Set Test Variable    ${SMOD2_CHECK_TIMEOUT}    25 min
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]

    ...    AND    Modify Resource Search Order    CM__Commissioning__Configuration_reset
    ...    AND    CM__Commissioning__Configuration_reset.TC Setup
    TC__CM__Commissioning__Configuration_reset
    [Teardown]    Run Keywords    CM__Commissioning__Configuration_reset.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset


[1]Automated__CM__Commissioning_planned_commissioning
    [Timeout]    20000
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    Set Test Variable    ${COMMISSIONING_TIMEOUT}    4000
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    120
    ...    AND    Set Test Variable    ${IPSEC_INSTALL}    ${FALSE}
    ...    AND    Set Test Variable    ${POST_CHECK_ONLY_ALARMS}    ${FALSE}
    ...    AND    Set Test Variable    ${POST_ALARMS_IGNORED_PATTERN}    ${EMPTY}
    ...    AND    Set Test Variable    ${ALT_SCF_PATH}    ${EMPTY}
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220']]

    ...    AND    Modify Resource Search Order    CM__Commissioning__Planned_commissioning
    ...    AND    CM__Commissioning__Planned_commissioning.TC Setup
    TC__CM__Commissioning__Planned_commissioning
    [Teardown]    Run Keywords    CM__Commissioning__Planned_commissioning.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  Run Keyword  CIT Recover Test Line By Power Reset



[1]FM__SoC_Loki_reset_counter_exceeded
    [Tags]  QC_151525
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ASOF
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    2000
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    2000

    ...    AND    FM__SoC_Loki_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__SoC_Loki_reset_counter_exceeded
    TC__FM__SoC_Loki_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__SoC_Loki_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order



[1]WebEM_Admin_CLI_getHwInfo
    [Tags]  QC_151543
    [Setup]    WebEM__Admin_CLI_getHwInfo.TC Setup
    [Teardown]    WebEM__Admin_CLI_getHwInfo.TC Teardown
    TC__WebEM__Admin_CLI_getHwInfo


[1]WebEM__Admin_CLI_getCellList
    [Tags]  QC_151544
    [Setup]    WebEM__Admin_CLI_getCellList.TC Setup
    [Teardown]    WebEM__Admin_CLI_getCellList.TC Teardown
    TC__WebEM__Admin_CLI_getCellList


[1]WebEM__Admin_CLI_getSwVersionStatus
    [Tags]  QC_151545
    [Setup]    WebEM__Admin_CLI_getSwVersionStatus.TC Setup
    [Teardown]    WebEM__Admin_CLI_getSwVersionStatus.TC Teardown
    TC__WebEM__Admin_CLI_getSwVersionStatus


[1]WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults
    [Tags]  QC_151546
    [Setup]    WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults.TC Setup
    [Teardown]    WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults.TC Teardown
    TC__WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults


[1]WebEM__CLI_shall_support_command_getRadParam_with_DCC_user
    [Tags]  QC_151535
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    WebEM__CLI_shall_support_command_getRadParam_with_DCC_user.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CLI_shall_support_command_getRadParam_with_DCC_user
    TC__WebEM__CLI_shall_support_command_getRadParam_with_DCC_user
    [Teardown]    Run Keywords    WebEM__CLI_shall_support_command_getRadParam_with_DCC_user.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CLI_shall_support_command_startIPCaptureFile_with_DCC_user
    [Tags]  QC_151536
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__CLI_shall_support_command_startIPCaptureFile_with_DCC_user.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CLI_shall_support_command_startIPCaptureFile_with_DCC_user
    TC__WebEM__CLI_shall_support_command_startIPCaptureFile_with_DCC_user
    [Teardown]    Run Keywords    WebEM__CLI_shall_support_command_startIPCaptureFile_with_DCC_user.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CLI_shall_support_command_checkAntennas_with_DCC_user
    [Tags]  QC_151541
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__CLI_shall_support_command_checkAntennas_with_DCC_user.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CLI_shall_support_command_checkAntennas_with_DCC_user
    TC__WebEM__CLI_shall_support_command_checkAntennas_with_DCC_user
    [Teardown]    Run Keywords    WebEM__CLI_shall_support_command_checkAntennas_with_DCC_user.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CLI_shall_support_command_checkFans_with_DCC_user
    [Tags]  QC_151540
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__CLI_shall_support_command_checkFans_with_DCC_user.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CLI_shall_support_command_checkFans_with_DCC_user
    TC__WebEM__CLI_shall_support_command_checkFans_with_DCC_user
    [Teardown]    Run Keywords    WebEM__CLI_shall_support_command_checkFans_with_DCC_user.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CLI_shall_support_command_checkHw_with_DCC_user
    [Tags]  QC_151542
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__CLI_shall_support_command_checkHw_with_DCC_user.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CLI_shall_support_command_checkHw_with_DCC_user
    TC__WebEM__CLI_shall_support_command_checkHw_with_DCC_user
    [Teardown]    Run Keywords    WebEM__CLI_shall_support_command_checkHw_with_DCC_user.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CLI_shall_support_command_getRmodMeasurementsList_with_DCC_user
    [Tags]  QC_151533
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__CLI_shall_support_command_getRmodMeasurementsList_with_DCC_user.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CLI_shall_support_command_getRmodMeasurementsList_with_DCC_user
    TC__WebEM__CLI_shall_support_command_getRmodMeasurementsList_with_DCC_user
    [Teardown]    Run Keywords    WebEM__CLI_shall_support_command_getRmodMeasurementsList_with_DCC_user.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CLI_shall_support_command_getSystemModuleList_with_DCC_user
    [Tags]  QC_151537
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__CLI_shall_support_command_getSystemModuleList_with_DCC_user.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CLI_shall_support_command_getSystemModuleList_with_DCC_user
    TC__WebEM__CLI_shall_support_command_getSystemModuleList_with_DCC_user
    [Teardown]    Run Keywords    WebEM__CLI_shall_support_command_getSystemModuleList_with_DCC_user.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CLI_shall_support_command_getNmsState_with_DCC_user
    [Tags]  QC_151532
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__CLI_shall_support_command_getNmsState_with_DCC_user.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CLI_shall_support_command_getNmsState_with_DCC_user
    TC__WebEM__CLI_shall_support_command_getNmsState_with_DCC_user
    [Teardown]    Run Keywords    WebEM__CLI_shall_support_command_getNmsState_with_DCC_user.TC Teardown
    ...    AND    Restore Resource Search Order



[1]WebEM__CLI_shall_support_command_getAllTroubleshootingScripts_DCC_user
    [Tags]  QC_151530
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__CLI_shall_support_command_getAllTroubleshootingScripts_DCC_user.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CLI_shall_support_command_getAllTroubleshootingScripts_DCC_user
    TC__WebEM__CLI_shall_support_command_getAllTroubleshootingScripts_DCC_user
    [Teardown]    Run Keywords    WebEM__CLI_shall_support_command_getAllTroubleshootingScripts_DCC_user.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CLI_shall_support_command_getRADDebugParameters_with_DCC_user
    [Tags]  QC_151534
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__CLI_shall_support_command_getRADDebugParameters_with_DCC_user.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CLI_shall_support_command_getRADDebugParameters_with_DCC_user
    TC__WebEM__CLI_shall_support_command_getRADDebugParameters_with_DCC_user
    [Teardown]    Run Keywords    WebEM__CLI_shall_support_command_getRADDebugParameters_with_DCC_user.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CLI_shall_support_command_resetAllRADDebugParameters_with_DCC_user
    [Tags]  QC_151539
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__CLI_shall_support_command_resetAllRADDebugParameters_with_DCC_user.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CLI_shall_support_command_resetAllRADDebugParameters_with_DCC_user
    TC__WebEM__CLI_shall_support_command_resetAllRADDebugParameters_with_DCC_user
    [Teardown]    Run Keywords    WebEM__CLI_shall_support_command_resetAllRADDebugParameters_with_DCC_user.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__CLI_shall_support_command_softwareUpdate_with_DCC_user
    [Tags]  QC_151538
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PATH_TO_SW}    /media/BuildShareTimi01/SBTS/Trunk/TA_WebEM/Trunk/
	...    AND    Modify Resource Search Order    WebEM__CLI_shall_support_command_softwareUpdate_with_DCC_user

    ...    AND    WebEM__CLI_shall_support_command_softwareUpdate_with_DCC_user.TC Setup
    run  sudo mkdir -p /media/BuildShareTimi01
    run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    run  ${sh_command}
    run  sudo mount -a
    TC__WebEM__CLI_shall_support_command_softwareUpdate_with_DCC_user
    [Teardown]    Run Keywords    WebEM__CLI_shall_support_command_softwareUpdate_with_DCC_user.TC Teardown
    ...    AND    Restore Resource Search Order


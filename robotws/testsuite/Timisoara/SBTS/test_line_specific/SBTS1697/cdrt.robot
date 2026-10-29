*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  CLOUD_SRAN_LWG_1ASIA_3ABIA_1ASIA_3ABIA_3FRIJ_1FRPA_2FXCB_2FXFC  STATE_COMMISSIONED
...    SBTS00
Library           XML  use_lxml=True


Resource    ../../FM/test_resources/FM__GSM_DSP_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__RAT_reset_counter_exceeded__multi_RAT.robot
Resource    ../../FM/test_resources/FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709.robot
Resource    ../../FM/test_resources/FM__SC_late_startup_actForceAutoReset_false.robot
Resource    ../../FM/test_resources/FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.robot
Resource    ../../FM/test_resources/FM__Primary_core_power_off_on.robot
Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot

*** Variables ***
${SCF_ID}    01
${Switch_IP}          10.255.10.109
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       1
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1767
${SKIP_RU_POWER_CHECK}    ${TRUE}
# ${DISABLE_WATCHDOG}    ${TRUE}


*** Test Cases ***
[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]    STOPONFAIL
    [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Ping stable timeout}    409
    ...    AND    Set Test Variable    ${Test Timeout}    120
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Run  wget files.ute.nsn-rdnet.net/builds/enb/base/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable.zip -P ${Target SW dir}
    [Timeout]    60 minutes
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order



[1]Automated__FM__GSM_DSP_crash_RAT_recovery_reset
    [Tags]  QC_37045
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    2700
    
    ...    AND    FM__GSM_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__GSM_DSP_crash_RAT_recovery_reset
    TC__FM__GSM_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__GSM_DSP_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order



[1]Automated__FM__RAT_reset_counter_exceeded__multi_RAT
    [Tags]  QC_37046
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    2700
    
    ...    AND    FM__RAT_reset_counter_exceeded__multi_RAT.TC Setup
    ...    AND    Modify Resource Search Order    FM__RAT_reset_counter_exceeded__multi_RAT
    TC__FM__RAT_reset_counter_exceeded_multi_RAT
    [Teardown]    Run Keywords    FM__RAT_reset_counter_exceeded__multi_RAT.TC Teardown
    ...    AND    Restore Resource Search Order



[1]FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709
    [Tags]  QC_37044
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    2700
    
    ...    AND    FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709
    TC__FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709
    [Teardown]    Run Keywords    FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709.TC Teardown
    ...    AND    Restore Resource Search Order



[1]FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    [Tags]  QC_37047
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    6710
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    BBPOOL autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
    
    ...    AND    FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.TC Setup
    ...    AND    Modify Resource Search Order    FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    TC__FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    [Teardown]    Run Keywords    FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.TC Teardown
    ...    AND    Restore Resource Search Order




[1]FM__SC_late_startup_actForceAutoReset_false
    [Tags]  QC_37043
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    2700
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    2700
    
    ...    AND    FM__SC_late_startup_actForceAutoReset_false.TC Setup
    ...    AND    Modify Resource Search Order    FM__SC_late_startup_actForceAutoReset_false
    TC__FM__SC_Late_Startup_actForce_False
    [Teardown]    Run Keywords    FM__SC_late_startup_actForceAutoReset_false.TC Teardown
    ...    AND    Restore Resource Search Order



[1]FM__Primary_Core_power_off_on
    [Tags]  QC_37042
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    4592
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    BTS Reset Cause
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7115
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    1800
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    720
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION INFORMATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
    
    ...    AND    FM__Primary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Primary_core_power_off_on
    TC__FM__Primary_Core_power_off_on
    [Teardown]    Run Keywords    FM__Primary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order

    

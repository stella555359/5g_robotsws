*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS24R1  SRAN  CLOUD_SRAN_NLWG_1489_2ASIB_2ABIA_1ABIO_1ABIN_2FXCB_1AHDB_1AHHB_1AHFIB STATE_SKIP_AGENT
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__Robustness_trigger_different_faults_RMOD.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904.robot
Resource    ../../FM/test_resources/FM__FSP_power_reset_counter_exceeded_FID1956_RMOD.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
@{GSMVlan}            ${251}  ${252}
${WCDMAVlan}          ${351}
${LTEVlan}            ${451}
${Switch_IP}          10.255.6.18
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       9
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1489


*** Test Cases ***
FM__Robustness_trigger_different_faults_RMOD
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10m
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    10m
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    10m
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    180
    ...    AND    Set Test Variable    ${FAULT_ID_1904}    1904
    ...    AND    Set Test Variable    ${FAULT_ID_1905}    1905
    ...    AND    Set Test Variable    ${FAULT_ID_1956}    1956
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Radio autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
    ...    AND    Set Test Variable    ${FAULT_ID_1955}    1955
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_1955}    Increased BER detected on the optical connection to Radio Module
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID_1955}    7116
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME_1955}    BASE STATION SERVICE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY_1955}    Major

    ...    AND    FM__Robustness_trigger_different_faults_RMOD.TC Setup
    ...    AND    Modify Resource Search Order    FM__Robustness_trigger_different_faults_RMOD
    TC__FM__Robustness_trigger_different_faults_RMOD
    [Teardown]    Run Keywords    FM__Robustness_trigger_different_faults_RMOD.TC Teardown
    ...    AND    Restore Resource Search Order


FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15m
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    10m
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    10m
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    180
    ...    AND    Set Test Variable    @{BBMOD_LIST}    ABIA  ABIN  ABIO
    ...    AND    Set Test Variable    @{ACCEPTED_CELLS_LIST}    NR  LTE
    ...    AND    Set Test Variable    ${RMOD_TYPE}    OBSAI
    ...    AND    Set Test Variable    ${FAULT_ID_1905}    1905
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_RADIO_AUTONOMOUS_RESET}    Radio autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_CARD_AUTONOMOUS_RESET}    Baseband card autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_CARD_POWER_RESET}    Baseband card power autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_BB_CONFIGURATION_ERROR}    RF BB bus configuration error
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID_BB_CONFIGURATION_ERROR}    7116
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME_BB_CONFIGURATION_ERROR}    BASE STATION SERVICE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY_WARNING}    Warning
    ...    AND    Set Test Variable    ${SEVERITY_CRITICAL}    Critical

    ...    AND    FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905
    TC__FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905
    [Teardown]    Run Keywords    FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905.TC Teardown
    ...    AND    Restore Resource Search Order


FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15m
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    10m
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    10m
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    180
    ...    AND    Set Test Variable    @{BBMOD_LIST}    ABIA  ABIN  ABIO
    ...    AND    Set Test Variable    @{ACCEPTED_CELLS_LIST}    NR  LTE
    ...    AND    Set Test Variable    ${RMOD_TYPE}    OBSAI
    ...    AND    Set Test Variable    ${FAULT_ID_1904}    1904
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_RADIO_AUTONOMOUS_RESET}    Radio autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_CARD_AUTONOMOUS_RESET}    Baseband card autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_CARD_POWER_RESET}    Baseband card power autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning

    ...    AND    FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904
    TC__FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904
    [Teardown]    Run Keywords    FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904.TC Teardown
    ...    AND    Restore Resource Search Order


FM__FSP_power_reset_counter_exceeded_FID1956_RMOD
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15m
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30m
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    10m
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    10m
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    180
    ...    AND    Set Test Variable    @{BBMOD_LIST}    ABIA  ABIN  ABIO
    ...    AND    Set Test Variable    @{ACCEPTED_CELLS_LIST}    NR  LTE
    ...    AND    Set Test Variable    ${RMOD_TYPE}    OBSAI
    ...    AND    Set Test Variable    ${FAULT_ID_1956}    1956
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_RADIO_AUTONOMOUS_RESET}    Radio autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_CARD_AUTONOMOUS_RESET}    Baseband card autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_CARD_POWER_RESET}    Baseband card power autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY_WARNING}    Warning

    ...    AND    FM__FSP_power_reset_counter_exceeded_FID1956_RMOD.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_power_reset_counter_exceeded_FID1956_RMOD
    TC__FM__FSP_power_reset_counter_exceeded_FID1956_RMOD
    [Teardown]    Run Keywords    FM__FSP_power_reset_counter_exceeded_FID1956_RMOD.TC Teardown
    ...    AND    Restore Resource Search Order


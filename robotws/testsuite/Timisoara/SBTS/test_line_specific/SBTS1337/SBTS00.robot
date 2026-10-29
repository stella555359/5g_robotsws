*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LWG_1ASIA_2ABIA_1ASIA_2ABIA_2FXCA_2FXDA_1FXFB_1FRGP_1FXED
Library     XML  use_lxml=True
Resource    ../../CIT/test_resources/CM__Commissioning__Configuration_reset.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Planned_commissioning.robot
Resource    ../../CIT/test_resources/STATE__LTE_RAT_reset_from_ADMIN.robot
Resource    ../../CIT/test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot


*** Variables ***
${SCF_ID}    01
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1337


*** Test Cases ***
[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]    STOPONFAIL    
    [Timeout]    ${Test Timeout} minutes
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    1200
    ...    AND    Set Test Variable    ${Ping loss timeout}    240
    ...    AND    Set Test Variable    ${Ping regain timeout}    600
    ...    AND    Set Test Variable    ${onAir Check Number}    60
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    15
    ...    AND    Set Test Variable    ${Test Timeout}    30
    ...    AND    Set Test Variable    ${Make Additional Checks}    ${FALSE}
    ...    AND    Set Test Variable    ${Additional Checks Number}    5
    ...    AND    Set Test Variable    ${Sleep interval}    1 min
    ...    AND    Set Test Variable    ${Pass If SW exists}    ${False}
    ...    AND    Set Test Variable    ${Log KPIs}    False
    ...    AND    Set Test Variable    ${EXPECTED_BTS_STATUS}    OnAir
    ...    AND    Set Test Variable    ${EXPECTED_BTS_STATUS_AFTER_SWDL}    OnAir
    ...    AND    Set Test Variable    ${HARDWARE_CHECK_AFTER_UPDATE}    10
    ...    AND    Set Test Variable    ${cells_LTE_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled,    availabilityStatus=Online, blockingState=Unblocked
    ...    AND    Set Test Variable    ${cells_WCDMA_expected_states_after_update}
    ...    operationalState=Enabled, availabilityStatus=Online,    blockingState=Unblocked, usageState=Active
    ...    AND    Set Test Variable    ${cells_GSM_expected_states_after_update}
    ...    administrativeState=Unlocked, operationalState=Enabled, availabilityStatus=Online,    blockingState=Unblocked, usageState=Active
    
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CM__Commissioning__Configuration_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Configuration Reset Timeout}    500
    ...    AND    Set Test Variable    ${Conf_reset_by_AdminAPI}    ${TRUE}
    ...    AND    Set Test Variable    ${RM_DETECTION_TIMEOUT}    10 min
    ...    AND    Set Test Variable    ${SMOD2_CHECK_TIMEOUT}    5 min
    
    ...    AND    CM__Commissioning__Configuration_reset.TC Setup
    ...    AND    Modify Resource Search Order    CM__Commissioning__Configuration_reset
    TC__CM__Commissioning__Configuration_reset
    [Teardown]    Run Keywords    CM__Commissioning__Configuration_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated__CM__Commissioning_planned_commissioning
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}    
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    ...    AND    Set Test Variable    ${COMMISSIONING_TIMEOUT}    600
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    15
    ...    AND    Set Test Variable    ${IPSEC_INSTALL}    ${FALSE}
    ...    AND    Set Test Variable    ${POST_CHECK_ONLY_ALARMS}    ${FALSE}
    ...    AND    Set Test Variable    ${POST_ALARMS_IGNORED_PATTERN}    ${EMPTY}
    ...    AND    Set Test Variable    ${ALT_SCF_PATH}    ${EMPTY}
    
    ...    AND    CM__Commissioning__Planned_commissioning.TC Setup
    ...    AND    Modify Resource Search Order    CM__Commissioning__Planned_commissioning
    TC__CM__Commissioning__Planned_commissioning
    [Teardown]    Run Keywords    CM__Commissioning__Planned_commissioning.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated__STATE__LTE_RAT_reset_from_ADMIN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    480
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    STATE__LTE_RAT_reset_from_ADMIN
    TC__STATE__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order



*** Keywords ***

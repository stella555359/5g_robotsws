*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  CLOUD_SRAN_LW_1ASIA_2ABIA_2FRGU
Library           XML  use_lxml=True
Resource    ../../CIT/test_resources/CM__Commissioning__Configuration_reset.robot
Resource    ../../CIT/test_resources/CM__Commissioning__Planned_commissioning.robot
Resource    ../../CIT/test_resources/STATE__Site_reset.robot


*** Variables ***
${SCF_ID}    01


*** Test Cases ***
CM__Commissioning__Configuration_reset
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


[1][1.0] Automated__STATE__Site_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    30
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    
    ...    AND    STATE__Site_reset.TC Setup
    ...    AND    Modify Resource Search Order    STATE__Site_reset
    TC__STATE__Site_reset
    [Teardown]    Run Keywords    STATE__Site_reset.TC Teardown
    ...    AND    Restore Resource Search Order



*** Keywords ***

*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    vendor_change_list=${VENDOR_CHANGE_LIST}
...               AND    Suite Setup Copy WTS Config Files From QT
...               AND    Suite Setup Start WTS And Check OnAir
Suite Teardown    Common Suite Teardown    debug
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown    debug
Force Tags        CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    master_classicalbts_all    STATE_CONFIGURED
...               FR1    Owner_yuema    CN1    PRI-High    CIT    5G_RAN_TDD
...               CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
Resource          ../common_setup_teardown.robot

*** Variables ***
${SCF_PATH}                ${CURDIR}/config
${DELTA_FILE}              Delta_Conf.json
${UE_ID}                   1
${PROFILE_ID}              1
${GNB_ID}                  2
${CELL_ID}                 1
${BEARER_ID}               2
@{LOG_NAME_LIST}           btslog
@{LOG_NAME_SUITE_SETUP}    btslog    cellsetup
${COUNT}                   0
&{XML_PARAMS_DICT1}        maxNumOfDRBL2Pool=38    maxNumOfGBRL2Pool=19    maxNumOfUserL2Pool=19
&{VENDOR_CHANGE_DICT1}     list_name=bbPoolCapacity
...                        ref_value=ABIO\\d+FDD    params_dict=${XML_PARAMS_DICT1}
&{XML_PARAMS_DICT2}        guaranteedResourceRatioPerCell=10
&{VENDOR_CHANGE_DICT2}     list_name=${EMPTY}
...                        ref_value=${EMPTY}    params_dict=${XML_PARAMS_DICT2}
@{VENDOR_CHANGE_LIST}      ${VENDOR_CHANGE_DICT1}    ${VENDOR_CHANGE_DICT2}

*** Test Cases ***
Case_Check_Cell_Setup_And_NSA_UE_Attach_Successfully
    ${UE_ID}=    Set Variable    11
    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA Verify If Attach Passed
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
    Sleep    5s    reason=Keep the traffic stable
    NSA Check Average Traffic Bigger Than Target    ${UE_ID}    ${BEARER_ID}    dl    25
    NSA Check Average Traffic Bigger Than Target    ${UE_ID}    ${BEARER_ID}    ul    25

Case_Check_Cell_Setup_And_SA_UE_Attach_Successfully
    ${UE_ID}=    Set Variable    1
    SA 5G Attach    ${UE_ID}
    SA 5G PDU Session Setup    ${UE_ID}
    SA Start DL Traffic    20    10
    SA Stop DL Traffic
    SA Check Average Traffic Bigger Than Target    dl    5
    SA Start UL Traffic    20    10
    SA Stop UL Traffic
    SA Check Average Traffic Bigger Than Target    ul    5
    SA Start DLUL Traffic    50    20    10
    SA Stop DLUL Traffic
    SA Check Average Traffic Bigger Than Target    dl    5
    SA Check Average Traffic Bigger Than Target    ul    5
    SA 5G Detach    ${UE_ID}

*** Keywords ***
SA 5G Detach
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate UE detach on 5GNR side.
    ...    Expected output is: " UE Context Release Complete " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G Detach | 1 |
    Log To Console    start 5G detach...
    ${command}    Set Variable    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}
    ...    pass_regexp=UE Context Release Complete    timeout=10s
    ${output1}    String.Get Lines Matching Regexp    ${output}    UE Context Release Complete
    ...    partial_match=${true}
    Log To Console    \n${output1}


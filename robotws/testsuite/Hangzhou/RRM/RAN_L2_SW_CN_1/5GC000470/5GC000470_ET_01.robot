*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    force_reboot=${True}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD    master_classicalbts_all    STATE_CONFIGURED    CRT
#...               RAN_5G_TDD    FR1    Owner_Andsun    RAN_5G    SBTS00    SBTS23R1    SBTS22R4
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${LOCAL_WTS_DIR}       ${CURDIR}/config
#${WTS_CFG}             basic_fullstack_nsa_call_tdd_cmwv.cfg
#${WTS_AP_XML}          AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${TRAFFIC_DURATION}    5 minutes
#@{LOG_NAME_LIST}       btslog
#
#
#*** Test Cases ***
#5GC000470-BA_L3_Call_Classical_gNB_NSA_TDD_cmW_IPv6_FS
#
#    ${UE_ID}=    Set Variable If    "${GNBCUTYPE}"=="SANSA"    11    ${UE_ID}
#    Set Suite Variable    ${UE_ID}    ${UE_ID}
#    NSA LTE Attach    ${UE_ID}    profile_id=1
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    5
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    5
#    Sleep    ${TRAFFIC_DURATION}    reason=wait data traffic to be stable
#    NSA Check Average Traffic Range 10 Percent On Target    ${UE_ID}    ${BEARER_ID}    dl    5
#    NSA Check Average Traffic Range 10 Percent On Target    ${UE_ID}    ${BEARER_ID}    ul    5
#    NSA LTE Detach    ${UE_ID}
#    UE Reattach
#
#*** Keywords ***
#UE Reattach
#    Log To Console    [WA]PR502846: Wait 20s before trying Reattach
#    Sleep    20sec    reason=Wait before trying Reattach
#    NSA LTE Attach    ${UE_ID}    profile_id=1
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#
#NSA LTE Attach
#    [Arguments]    ${ue_id}    ${profile_id}
#    [Documentation]    This keyword is used to simulate UE attach on LTE side during NSA L3 Call on eGate.
#    ...    Expected output is: "UE IS ACTIVE" on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | profile_id | Yes | profile id |
#    ...    Example:
#    ...    | NSA LTE Attach | 1 | 1 |
#    Log To Console    start LTE attach...
#    ${output}    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_attach id\=${ue_id}    pass_regexp=UE IS ACTIVE    timeout=300
#    Log To Console    lte_attach_is_ok
#    Sleep    3s    reason=wait LTE attach is stable
#    [Return]    ${output}

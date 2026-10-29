*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB
...               AND    Suite Setup Copy WTS Config Files From QT
...               AND    Suite Setup Start WTS And Check OnAir
Suite Teardown    Common Suite Teardown    debug
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown    debug
Force Tags        CLOUD_5G_KL_AP_NSA_FS_CMWV_TDD    CLOUD_5G_BL_AP_NSA_FS_CMWV_TDD    master_classicalbts_all    STATE_CONFIGURED
...               FR1    Owner_yuema    CN1_SQ    PRI-High    CIT    5G_RAN_TDD
Resource          ../common_setup_teardown.robot

*** Variables ***
${RD_PARAM}            0x58012B=1
${SCF_PATH}            ${CURDIR}/config
${DELTA_FILE}          Delta_Conf.json
${UE_ID}               1
${PROFILE_ID}          1
${GNB_ID}              2
${CELL_ID}             1
${BEARER_ID}           2
@{OLD_CFG_PARAMS}      plmn=[0-9]+:[0-9]+
@{NEW_CFG_PARAMS}      plmn=302:610
@{LOG_NAME_LIST}       btslog    snapshot
${COUNT}               0

*** Test Cases ***
Case_Check_Cell_Setup_And_UE_Attach_Successfully
    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA Verify If Attach Passed
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
    Sleep    5s    reason=Keep the traffic stable
    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    25
    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    25
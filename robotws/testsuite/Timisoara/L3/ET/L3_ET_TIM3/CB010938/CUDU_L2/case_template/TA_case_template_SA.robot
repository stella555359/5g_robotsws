*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB
...               AND    Suite Setup Copy WTS Config Files From QT
...               AND    Suite Setup Start WTS And Check OnAir
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_KL_AP_SA_L1B_CMWV_TDD    master_classicalbts_all    STATE_CONFIGURED
...               FR1    Owner_yuema    CN1_SQ    PRI-High    5G_RAN_TDD
Resource          ../common_setup_teardown.robot

*** Variables ***
${RD_PARAM}            0x58012B=1
${SCF_PATH}            ${CURDIR}/config
${DELTA_FILE}          Delta_Conf_SA.json
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
    SA 5G Attach    ${UE_ID}
    SA 5G PDU Session Setup    ${UE_ID}
    SA Start DL Traffic    20    10
    SA Stop DL Traffic
    SA Check Average Traffic Bigger Than Target    dl    5
    SA Start UL Traffic    20    10
    SA Stop UL Traffic
    SA Check Average Traffic Bigger Than Target    ul    5
    SA Start DLUL Traffic    50    20    10
    Log To Console    ***TTI Trace Begin***
    Catch Ttitrace Log    wait_time=15s
    Decode TTI Trace And Send To Control PC One By One    ${OUTPUT_DIR}/tti
    Log To Console    ***TTI Trace Stop***
    SA Stop DLUL Traffic
    SA Check Average Traffic Bigger Than Target    dl    5
    SA Check Average Traffic Bigger Than Target    ul    5
    SA 5G Detach    ${UE_ID}

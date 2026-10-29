*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Modify Text File    ${WTS_DIR}/${WTS_CFG}    ${OLD_CFG_PARAMS}    ${NEW_CFG_PARAMS}
...               AND    Suite Setup Start WTS And Check OnAir
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Resource          ../../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${RD_PARAM}          0x58012B=1
${RESOURCE_PATH}     ${CURDIR}/resources
${SCF_PATH}          ${CURDIR}/config
${DELTA_FILE}        Delta_Conf_5GC002504_ET_02.json
${UE_ID}             1
${PROFILE_ID}        1
${GNB_ID}            2
${CELL_ID}           1
${BEARER_ID}         2
#@{OLD_CFG_PARAMS}    plmn=[0-9]+:[0-9]+
#@{NEW_CFG_PARAMS}    plmn=302:610
@{LOG_NAME_LIST}     btslog    snapshot
${SLOT1}             DlData_CsiRsSendReq.CsiRsSendReq.slot == 0x0000000e
${SLOT2}             DlData_CsiRsSendReq.CsiRsSendReq.slot == 0x0000000f
@{BIP_LOG_FILTER}    ${SLOT1}    ${SLOT2}

*** Test Cases ***
FGCR2504_ET_05_Check_10ms_TRS_Location_With_2SSB_Configured
    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA Verify If Attach Passed
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    100    2
    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
    Start Gnb BIP Log
    Sleep    2s    reason=Capture BIP log
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
    Check Multi Msgs In BIP Pcap Log    filter_list=@{BIP_LOG_FILTER}
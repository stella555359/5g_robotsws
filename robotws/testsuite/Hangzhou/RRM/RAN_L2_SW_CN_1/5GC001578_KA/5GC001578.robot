*** Settings ***
Documentation    ...
#Resource    ./../CUDU_L2/common_setup_teardown.robot
##Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=0x580013=0
##...               AND    Suite Setup Copy WTS Config Files From QT
#Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=0x580013=0
#...               AND    Prepare QT LOLO Enviroment    TYPE=TDD_NSA
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD    SBTS00    SBTS23R1    SBTS22R4    CRT    RAN_5G    RAN_5G_TDD
#
#*** Variables ***
##${SCF_PATH}    ${CURDIR}/config/SBTS22R2
##${DELTA_FILE}          ${SCF_PATH}/delta.json
#
#${SCF_PATH}    ${CURDIR}/config
#${DELTA_FILE}          delta.json
#${UE_ID}               11
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#@{LOG_NAME_LIST}       btslog    snapshot
#
#*** Test Cases ***
#5GC000630_B_02_Verify_DL_data_transfer_to_UE_by_flow_control_during_air_interface_congestion
#    Suite Setup Start WTS And Check OnAir
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    Change CQI to number    ${UE_ID}    1
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    ${DL_average1}    NSA Start DL Traffic and get tput    100
#    Change CQI to number    ${UE_ID}    15
#    ${DL_average2}    NSA Start DL Traffic and get tput    150
#    Verify tput after CQI change    ${DL_average1}    ${DL_average2}
#
#*** Keywords ***
#NSA Start DL Traffic and get tput
#    [Arguments]    ${trf}
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    ${trf}    1
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    ${trf}    2
#    Sleep    10s    reason=wait for throughput stable
#    ${DL_average}    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    dl
#    Log To Console    ${DL_average}
#	[Return]    ${DL_average}
#
#NSA DL Stop Traffic and Detach
#    [Arguments]    ${ue_id}    ${bearer_id}
#    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} id\=${bearer_id} dir=dl
#    Sleep    3s    reason=wait command finish
#    NSA LTE Detach    ${ue_id}
#    Sleep    3s    reason=wait command finish
#
#Change CQI to number
#    [Arguments]    ${ue_id}    ${CQI_value}
#    Log To Console    Change CQI to ${CQI_value}...
#    ute_wtssim.Execute Egate Command    csi_override_testmode_nr profile_id\=${UE_ID} cqi_mode\=fixed cqi\=${CQI_value}
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=${UE_ID}
#    #ute_wtssim.Execute Egate Command    cmd=enb_endc_param id\=1 serving_cell_index_range_scg\=5:31
#    Sleep    5s    reason=wait command finish
#
#Verify tput after CQI change
#    [Arguments]    ${DL_average1}    ${DL_average2}
#    Log To Console    Compare DL_average...
#    Should Be True    ${DL_average2}>${DL_average1}
#
#Common Suite Setup
#    Suite Setup Update GNB    log=${False}
#    #Send All Config For Testline
#    Suite Setup Start WTS And Check OnAir
#
#Connect to WTS
#    SSH.connect to    hostname=${TLPC_IP}    username=${TLPC_SSH_UE}    password=${TLPC_SSH_PWD}    alias=WTS
#
#Suite Setup Start WTS And Check OnAir
#    [Arguments]        ${log}=${True}
#    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Start UTE WTS
##    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    NG Link Should Be UP
##    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    Address Distribution Should Be Successful
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
#    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
#    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection
#    Verify Cell Setup
#    [Teardown]    Run Keyword If    "${log}"=="${True}"    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}
#
#

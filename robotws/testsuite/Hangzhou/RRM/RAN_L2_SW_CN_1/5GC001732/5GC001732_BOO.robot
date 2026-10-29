*** Settings ***
Documentation    ...
#Resource    ./5GC001732_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Library           ./../CUDU_L2/scripts/python/ttitrace_data_parser.py
#Library           ./../CUDU_L2/scripts/python/get_csv_data.py
#Library           ./../CUDU_L2/scripts/python/streaming_ttitrace_analyzer.py
#Suite Setup        Common Suite Setup 2
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${SCF_PATH}          ${CURDIR}/config/SCF
#${SCF_B15}     ${SCF_PATH}/5GC001732_SCF_B.xml
#${SWCONFIG_PARAM_B15}    0x4B000F=1;0x4F011=1;0x58012D=4
#${LOCAL_WTS_DIR}      ${CURDIR}/config/WTS/
#${IPHY_B15}     ${CURDIR}/config/iphy_B15.xml
#${UE11_ID}     11
#${UE12_ID}     12
#${WTS_DIR}            /opt/iphy/latest
#${WTS_CFG_B15}       basic_setup_B15.cfg
#@{LOG_NAME_LIST}      btslog    snapshot
#${dl_tp_set}    175
#${ul_tp_set}    175
#${Egatelog_path}    ${CURDIR}
#${PDU_ID}                         1
#${TRF_ID}                         1
#@{COLUMN_NAME}      3gpp.sfn    3gpp.slot
#
#*** Test Cases ***
#5GC001732-ET-B015 Verify 8CC UE Capability Check and RRC Configuration of 2 Users when enable CA and beamforming
#    [Documentation]
#    ...    Precondition:
#    ...        TDD cell with NSA call with pucchF2MaxCodeRate=0.35
#    ...        UeCapaCsiReportWithoutPmi enabled and maxNumberNonGroupBeamReporting=n1 in UE capability
#    ...        csiReportPeriodicity =slots160 and basicBeamSet=beamSetAbf_32A
#    ...    Test Steps:
#    ...      Step1:Setup NSA call and send ULDL traffic.
#    ...    Check points:
#    ...      CP1:Check TPUT.
#    ...      CP2:Check no DTXCRC in TTITRACE.
#    ...      CP3:Check UCI bits bundled together as 20bits.
#    [Tags]     Owner_yalsun   case_B_15
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_B15}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_B15}     swconfig_param=${SWCONFIG_PARAM_B15}    iphy_file=${IPHY_B15}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    NSA UE attach and Send ULDL Traffic for 8CC
#    #CP1
#    Check CA Cell Sum Average Throughput   11    dl    50    15
#    Check CA Cell Sum Average Throughput   12    dl    50    15
#    Check ULCA Scell L1 Cell Tput On Target    11    15    10
#    Check ULCA Scell L1 Cell Tput On Target    12    15    10
#    #CP2
#    Collect TTITrace and check DTXCRC    1    1
#    #CP3
#    Check UCI bits right for Case B15 by A2A
#
#
#
#*** Keywords ***
#NSA UE attach and Send ULDL Traffic for 8CC
#    Suite Setup Start WTS And Check OnAir for 8CC
#    NSA LTE Attach    ue_id=${UE11_ID}    profile_id=1
#    Set TestMode for Csireport
#    Set Scells for CA UE
#    NSA 5G Attach    ue_id=${UE11_ID}   gnb_id=2    cell_id=1    bearer_id=2
#    Sleep   3s
#    NSA LTE Attach    ue_id=${UE12_ID}    profile_id=1
#    Set TestMode for Csireport
#    Set Scells for CA UE
#    Sleep    3s
#    NSA 5G Attach    ue_id=${UE12_ID}   gnb_id=2    cell_id=1    bearer_id=2
#    Sleep     3s
#    NSA Start DL Traffic    ue_id=${UE11_ID}    bearer_id=2    mbps=${dl_tp_set}    trf_id=1
#    NSA Start UL Traffic    ue_id=${UE11_ID}   bearer_id=2    mbps=${ul_tp_set}    trf_id=1
#    NSA Start DL Traffic    ue_id=${UE12_ID}    bearer_id=2    mbps=${dl_tp_set}    trf_id=1
#    NSA Start UL Traffic    ue_id=${UE12_ID}   bearer_id=2    mbps=${ul_tp_set}    trf_id=1
#
#Set TestMode for Csireport
#    Log To Console    Set TestMode for Csireport
#    ute_wtssim.Execute Egate Command
#    ...    cmd=uec_l2_testmode_params fixed_csi_report\=true
#
#Set Scells for CA UE
#    Log To Console    Set TestMode for Csireport
#    ute_wtssim.Execute Egate Command
#    ...    cmd=enb_endc_param id\=1 serving_cell_index_range_scg=\8:16
#
#Check UCI bits right for Case B15 by A2A
#    Log To Console    *********Begin to Get and Check UCI bits and CSI Report Period*********
#    Start Gnb BIP Log
#    Sleep    3s
#    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/1/
#    Get UCI bits in uldata_pucchreceiverespps    1    42
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/B15/UCIbits_B15.ini    ${TEST_LOG_DIRECTORY}/BIP/1/uciMultiPucch.csv
#        ...    ${TEST_LOG_DIRECTORY}/BIP/1/
#
#Suite Setup Start WTS And Check OnAir for 8CC
#    [Arguments]        ${log}=${True}    ${enb_id}=1    ${gnb_id}=2    ${wts_cfg_file}=${WTS_CFG}    ${gnb_num}=1
#    ${status}    Run Keyword And Return Status
#    ...    Suite Setup Start WTS And Check OnAir Without Workaround For 8CC    ${log}    ${enb_id}    ${gnb_id}    ${wts_cfg_file}    ${gnb_num}
#    Run Keyword If    '${status}'=='False'    Workaround For Check SIB2 Fail    ${log}    ${enb_id}    ${gnb_id}    ${wts_cfg_file}    ${gnb_num}
#
#Suite Setup Start WTS And Check OnAir Without Workaround For 8CC
#    [Arguments]    ${log}=${True}    ${enb_id}=1    ${gnb_id}=2    ${wts_cfg_file}=${WTS_CFG}    ${gnb_num}=1
#    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Start UTE WTS    ${wts_cfg_file}
#    Set TestMode for Csireport
#    Setup X2 Connection    ${enb_id}    ${gnb_id}
#    sleep    20s
#    Verify Cell Setup With eGate Log     gnb_num=${gnb_num}
#    [Teardown]    Run Keyword If    "${log}"=="${True}"    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}
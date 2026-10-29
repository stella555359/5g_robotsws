*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    OPTION_RELATED_ARTIFACTS_5G   SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00   CONFIGURED

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner

Resource         ./CB012261_AIC_resource.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          OperatingSystem
Library          taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library          taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Resource         ../resources/robot/AIC_Common_Keywords.robot
Resource         ../resources/robot/Common_Keywords.robot


Suite Setup             Run keywords     Test Suite Setup
...                     AND              AIC Software Build Info
...                     AND              Fetch Taf Library used in TL
#...                     AND              Fast Delta Commission vCU Using Delta XML File     ${delta_cu}
#...                     AND              sleep    300s
...                     AND              Log to console    vDU delta commissioning
...                     AND              Fast Delta Commission vDU With Delta XML File      ${delta_vdu}
...                     AND              sleep    600s
...                     AND              Run keyword and Ignore error   Verify RMODs Online Status   ${800}
...                     AND              log to console   loading cfg file
...                     AND              Configure UTE ETH3 IPs
...                     AND              Start WTS Using WTS_Runner      ${wts_cfg_file}



Suite Teardown         Run keywords        Kill WTS processes Using WTS_Runner

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      CB012261_CR_AB102_02_NSA_SA_Call_FR1_FDD.robot
...             TEST SET NAME:     CB012261_CR_AB102_02_NSA_SA_Call_FR1_FDD.robot
...             TESTING SPLIT:     See CB012261 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB012261 CFAM


*** Variables ***
${delta_vdu}        ${CURDIR}/config/SCF/AB_102_02_CR.xml
#${delta_cu}         ${CURDIR}/config/SBTS24R2/Plan_configuration_scf_MRBTS-1_CU_TL719_20240321-0800.xml
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_AIC.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${epc_log_path}    /tmp/
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
@{NR_cell3}     NRCELL-3
${pathloss_start_dB}        75
${pathloss_end_dB}      130
${epc_log_path}    /tmp/
${TEST_NAME}        test_case
${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_SCN1.csv
${BIP_CSV_NAME_PG}             BIP_L1L2.pcap_filter_PG.csv
${BIP_CSV_NAME_TP}             BIP_L1L2.pcap_filter_TP.csv
${FILTER_B003}                 (dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq) && (3gpp.subcellid == 0)
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_DciInfo.rachStatus    DlData_PdschGrant.startPrb
...                            DlData_PdschGrant.numOfPrb    nr-rrc.c1    DlData_PdschGrant.rachStatus
@{PM_counter}    M55306C00001  M55306C03001    M55306C06001

${duration}     120

#${pusch_BW}     102
#${prach_prb_off}       10
#${msg1fdm}      1


*** Test Cases ***
[1]CB012261_CR_AB102_02_NSA_SA_Call_FR1_FDD
    set test variable     ${LOG_PATH}
    log to console   UE attach trigerring now
    Start CPRT F1 Monitoring
    sleep     3s
    Stop and Collect CPRT F1 Monitoring
#    Start CPIF Monitoring
#    sleep     3
#    Stop and Collect CPIF Monitoring
#	Lock_cell and deactivate CB012261
#    Unlock_cell
    X2AP Link Should be UP
    ${crnti_list1}=      MultiUE Attach for NSA      151      151
    ${crnti_list1}=      MultiUE Register should be Successful    51      51
#    sleep     1s
#    Lock_cell and activate CB012261
#    Unlock_cell

#### CB012261-NSA_TDD

    X2AP Link Should be UP
    Log to console    NSA UE attach trigerring now...
#    Wait until the next Measurement Period starts  additional_time=${0}
    ${crnti_nsa}      MultiUE SgNB addtion for NSA     151    151    3
    ${crnti_nsa}      MultiUE Attach for NSA     152    152    4

#    Collect TTI trace
    Run Keyword and continue on failure     Start L2Ps TTI logs from vDU    ${NR_cell3}
    Trigger UL Traffic for NSA with duration    151    152    Traffic_rate=mbps    ul_rate=${75}     duration=${duration}
    sleep     5s
    ${nsa_tti}    Stop L2Ps TTI logs from vDU    test_scenario=SCN_NSA
    sleep     ${duration}s

    ${tp_cell1_nsa}      Validate NSA UL Traffic    ue_id=${151}    rate=${75}    call_dur=${duration}
    ${tp_cell2_nsa}      Validate NSA UL Traffic    ue_id=${152}    rate=${75}    call_dur=${duration}
    Compare UL Traffic      ${tp_cell1_nsa}     ${tp_cell2_nsa}      pucch=long

##### CB012261-SA_TDD
    Log to console   SA UE attach trigerring now...
    ${crnti_list1}=      MultiUE Register should be Successful    52      52

#    Collect TTI trace
    Run Keyword and continue on failure     Start L2Ps TTI logs from vDU    ${NR_cell3}
    MultiUE Trigger UL Traffic for SA with duration    51    52    Traffic_rate=mbps    ul_rate=${150}    duration=${duration}
    sleep     5s
    ${sa_tti}    Stop L2Ps TTI logs from vDU    test_scenario=SCN_SA
    sleep     ${duration}s

    ${tp_cell1_sa}      Validate SA UL Traffic    ue_id=${51}    rate=${150}    call_dur=${duration}
    ${tp_cell2_sa}      Validate SA UL Traffic    ue_id=${52}    rate=${150}    call_dur=${duration}
    Compare UL Traffic      ${tp_cell1_sa}     ${tp_cell2_sa}      pucch=long

#    set suite variable    ${cprt_log_1}
#    set suite variable   ${cprt_log_1}
#    Wait until the current Measurement Period stops  additional_time=${0}
#    Verify Counters        ${PM_counter}        exp-value=2


##### TTITRACE Verification
    Common TTI PCAP to CSV Converter    SCN_NSA    dir=ul
    Common TTI PCAP to CSV Converter    SCN_SA    dir=ul

#    ${pusch_BW}    ${prach_prb_off}      ${msg1fdm}      Read Cellsetup msg for uplink  ${TESTCASE_LOG_PATH}/cell_setup.pcap    50    51
#    Log to console    PUSCH_BW=${pusch_BW} prach_prb_offset=${prach_prb_off} msg1fdm=${msg1fdm}

    ${ret}    Verify_2prb_CB012261    ${nsa_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_12   ${52}     ${100}
    ...       ${10}    ${1}     Enabled
    Should Contain    ${ret}     Pass
#    ${ret}    Verify_2prb_CB012261    ${nsa_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_12   ${53}     ${102}
#    ...       ${10}    ${1}     Disabled
#    Should Contain    ${ret}     Pass

    ${ret}    Verify_2prb_CB012261    ${sa_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_12   ${52}     ${100}
    ...       ${10}    ${1}     Enabled
    Should Contain    ${ret}     Pass
#    ${ret}    Verify_2prb_CB012261    ${sa_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_12   ${53}     ${102}
#    ...       ${10}    ${1}     Disabled
#    Should Contain    ${ret}     Pass

#    ${path_syslog}    Stop log    btslog
#    ${search_string}        Create List      WRN/     ERR/
#    syslog_search      ${path_syslog}[btslog]/gnb_syslog.log         ${search_string}

    OperatingSystem.Run    cp ${WTS_DIR}/egate_console.log ${LOG_PATH}


*** Keywords ***
Collect TTI trace
    ${cells}  create list   NRCELL-1
    Log To Console    \nStartingTTICapture
    Start L2Ps TTI logs from vDU    ${cells}
    sleep  3s
#    ${tti}    Stop L2Ps TTI logs from vDU    test_scenario=Ue_DLUL_data
#    Decode TTI Trace    Ue_DLUL_data

Start CPRT F1 Monitoring
    [Arguments]
    Log to Console     \n-----> Start CPRT F1 Mon <-----
    AIC Start CPRT F1 Mon    ${vDU_NODE_HOST}    ${vDU_NODE_USER}    ${vDU_NODE_PASSWORD}    ${vDU_NAMESPACE}


Stop and Collect CPRT F1 Monitoring
    [Arguments]
    Log to Console     \n-----> Stop and Collect CPRT F1 Monitoring <-----
    ${fullTestName}=       replace string  ${TESTNAME}      ${SPACE}        _
    ${fullTestName1}=       replace string  ${fullTestName}      [           _
    ${fullTestName}=       replace string  ${fullTestName1}      ]           _
    set test variable    ${TESTCASE_LOG_PATH}    ${Suite_LOG_PATH}/${fullTestName}
    Create Folder        ${TESTCASE_LOG_PATH}/CPRT/
    AIC Stop Collect CPRT F1 Mon   ${TESTCASE_LOG_PATH}/CPRT/    ${vDU_NODE_HOST}    ${vDU_NODE_USER}
    ...   ${vDU_NODE_PASSWORD}    ${vDU_NAMESPACE}
    Move File    ${TESTCASE_LOG_PATH}/CPRT/CPRT.pcap    ${TESTCASE_LOG_PATH}/cell_setup.pcap


Start CPIF Monitoring
    [Arguments]
    Log to Console     \n-----> Start CPIF Mon <-----
#	run keyword if     ${Cloud_Evn_Type}     AIC Start CPIF x2 F1 Mon
    AIC Start CPIF Mon     ${vCU_NODE_HOST}    ${vCU_NODE_USER}    ${vCU_NODE_PASSWORD}    ${vCU_NAMESPACE}

Stop and Collect CPIF Monitoring
    [Arguments]
    Log to Console     \n-----> Stop and Collect CPIF_CPRT Mon <-----
    ${fullTestName}=       replace string  ${TESTNAME}      ${SPACE}        _
    ${fullTestName1}=       replace string  ${fullTestName}      [           _
    ${fullTestName}=       replace string  ${fullTestName1}      ]           _
    set test variable    ${TESTCASE_LOG_PATH}    ${Suite_LOG_PATH}/${fullTestName}
	Create Folder        ${TESTCASE_LOG_PATH}/CPIF_CPRT/
#	run keyword if     ${Cloud_Evn_Type}     AIC Stop Collect CPIF x2 F1 Mon     ${TESTCASE_LOG_PATH}/CPIF_CPRT/
    AIC Stop Collect CPIF Mon     ${TESTCASE_LOG_PATH}/CPIF_CPRT/      ${vCU_NODE_HOST}    ${vCU_NODE_USER}
    ...    ${vCU_NODE_PASSWORD}    ${vCU_NAMESPACE}
    Move File    ${TESTCASE_LOG_PATH}/CPIF_CPRT/CPRT_cpif.pcap    ${TESTCASE_LOG_PATH}/cell_setup.pcap

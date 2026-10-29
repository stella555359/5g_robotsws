*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD
...               RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT
Documentation
...             author:                 geetha.k_r@nokia.com
...             maintainer:             geetha.k_r@nokia.com
...
...             INTRODUCTION:      TC_1_CB008927-SR-EB2
...             TEST SET NAME:     CB008927_EB_2_1_Verification_of_SIB1_and_Msg2_4_with_RAT1-Allocation_with_Start
...                                PRB-Randomization_with_multiple_BWP.robot
...             TESTING SPLIT:     See CB008927 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008927 CFAM
...             REQUIREMENT ID     5G_RAN_USR_RRM_23512

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ta_a2a
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008927_resource.robot
Library          python/adaptive_retx.py

Suite Setup         Run keywords    Log To console  Suitesetup
...                 AND     Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     start log    btslog

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Stop log      btslog       snapshot       # sosreport
...                 AND     Kill WTS processes Using WTS_Runner


*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/EB2_1_scf.xml
${AP_XML}=      ${CURDIR}/config/SCF/EB2_1_iphy.xml

${wts_cfg_file}    ${CURDIR}/config/wts/basic_EB1.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
#randomization
@{small}  ${0}  ${79}
@{mediaum}   ${0}  ${133}
@{large}  ${0}   ${188}
&{dict1}     ${1}=${small}  ${3}=${mediaum}  ${2}=${large}



${epc_log_path}    /tmp/
${TEST_NAME}        test_case
${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_SCN1.csv
${BIP_CSV_NAME_PG}             BIP_L1L2.pcap_filter_PG.csv
${BIP_CSV_NAME_TP}             BIP_L1L2.pcap_filter_TP.csv
${FILTER_B003}                 (dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq) && (3gpp.subcellid == 0)
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_DciInfo.rachStatus    DlData_PdschGrant.startPrb
...                            DlData_PdschGrant.numOfPrb    nr-rrc.c1    DlData_PdschGrant.rachStatus

*** Test Cases ***
[1]CB008927_E_B_2_1_Verification_of_SIB1_Msg2_4_with_RAT1_Allocation_with_Start_PRB_Randomization_FDD_cells_with_35mHz_without_prbblanking
    log to console   UE attach trigerring now...
    X2AP Link Should be UP
    ${nsa_crnti_list1}  MultiUE NSA Attach should be Successful and Fetch CRNTI with RAT1   13   15     Trgt_Cell=1
    MultiUE DL Traffic Start for NSA      13     15     mbps    1    id=2    trf_id=1
    ${crnti_list1}=      WTS_Runner_Keywords.MultiUE Register should be Successful    1      2
    ${crnti_list1}=      WTS_Runner_Keywords.MultiUE Register should be Successful    5      6
    ${crnti_list1}=      WTS_Runner_Keywords.MultiUE Register should be Successful    9      10
    Start traffic for UE     1     2      10
    Start traffic for UE     5     6      10
    Start traffic for UE     9     10     10
    sleep      1s
    start log       ttitrace
    UEs with attach detach    2
    UEs with attach detach    6
    UEs with attach detach    10
    ${path_SCN_PA}    Stop Log      ttitrace     test_scenario=SCN_PA
    sleep     30s
    start log       ttitrace
    sleep      1s
    ${path_SCN_PA1}    Stop Log      ttitrace     test_scenario=SCN_PA1
    sleep     2s
    Common TTI PCAP to CSV Converter     SCN_PA
    sleep     5s
    Common TTI PCAP to CSV Converter     SCN_PA1
    sleep      5s
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${LOG_PATH}
    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}       Read Cellsetup msg  ${cprt_log_1}[cprt]   50
    Log to console      ${Initial_BWP}-${large_BWP}-${ssb_start_prb}
    Verify RAT1 Allocation and PSA Region    ${path_SCN_PA}[ttitrace]/output_dl_formated.csv    50    FDD
    ...    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}     prbrandom=True      prbblank=False
    ...    blankprblowedgedl=0     blankprbhighedgedl=0
    check_randomization_multi_bwp   ${path_SCN_PA1}[ttitrace]/output_dl_formated.csv    50    ${dict1}


*** Keywords ***
UEs with attach detach
    [Arguments]    ${ue_sa}

    wtsrunner.ue_deregister   id=${ue_sa}     ue_deregister_type=switch_off
    sleep     500ms
    wtsrunner.ue_register   id=${ue_sa}
    sleep     1s
    wtsrunner.ue_deregister   id=${ue_sa}     ue_deregister_type=switch_off
    sleep     500ms
    wtsrunner.ue_register   id=${ue_sa}
    sleep     1s
    wtsrunner.ue_deregister   id=${ue_sa}     ue_deregister_type=switch_off
    sleep     500ms
    wtsrunner.ue_register   id=${ue_sa}
    sleep    1s

Start traffic for UE
    [Arguments]    ${S_UE_id}     ${E_UE_id}    ${dl_rate}
    WTS_Runner_Keywords.MultiUE Trigger DL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps 
    ...   dl_rate=${dl_rate}   pdu_id=1      trf_id=1       qfi_id=1




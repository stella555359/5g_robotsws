*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED


Documentation
...             author:                 navin.kumar_ray@nokia.com
...             maintainer:             navin.kumar_ray@nokia.com
...
...             INTRODUCTION:      TC_1_CB008927-SR-D23
...             TEST SET NAME:     CB008927_D23_FDM_SIB1_Msg2_4_DCI_11-MultipleBWP-BottomAlligned.robot
...             TESTING SPLIT:     See CB008927 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008927 CFAM
...             REQUIREMENT ID     5G_RAN_USR_RRM_23118

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ta_a2a
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB008927_resource.robot

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
${SCFC}=        ${CURDIR}/config/SCF/SCF_20_30_35_Working_SIB1_Msg2_DCI11_Mbwp.xml
${AP_XML}=      ${CURDIR}/config/SCF/iphy_20_30_35_MHZ.xml

${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_20_30_35_MHZ.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
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

*** Test Cases ***
[1]CB008927-SR-D23-FDM_SIB1-Msg2orMsg4-DCI_11_RAT1UEsinDLslot_with_mult_bottom_aligned_ded_BWPs_configured_without-PRBblanking
    log to console   UE attach trigerring now...


    ${crnti_list1}=      MultiUE Register should be Successful    1      3
    ${crnti_list1}=      MultiUE Register should be Successful    6      8
    ${crnti_list1}=      MultiUE Register should be Successful    11      13
    Start traffic for UE    1     3      20
    Start traffic for UE    6     8      20
    Start traffic for UE    11     13    20


    start log       ttitrace
    UEs with attach detach    2
    UEs with attach detach    7
    UEs with attach detach    12

    ${path_SCN_PA}    Stop Log      ttitrace     test_scenario=SCN_PA
    sleep     60s
    Common TTI PCAP to CSV Converter     SCN_PA
    sleep     10s
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${LOG_PATH}

    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}       Read Cellsetup msg  ${cprt_log_1}[cprt]   50
    Log to console      ${Initial_BWP}-${large_BWP}-${ssb_start_prb}

    Verify RAT1 Allocation and PSA Region    ${path_SCN_PA}[ttitrace]/output_dl_formated.csv    50    FDD
    ...    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}

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
    MultiUE Trigger DL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   dl_rate=${dl_rate}   pdu_id=1      trf_id=1       qfi_id=1


Dettach and attach UEs multiple times
    MultiUE Deregister should be Successful   3     5
    ${crnti_list1}=      MultiUE Register should be Successful    6      9
    MultiUE Deregister should be Successful   6     9
    ${crnti_list1}=      MultiUE Register should be Successful    3      5

*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      TC_1_CB008927-AB4
...             TEST SET NAME:     TC_1_CB008927-AB4.robot
...             TESTING SPLIT:     See CB008927 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008927 CFAM


Resource         ./CB008927_resource.robot

Suite Setup         Run keywords    Log To console  Suitesetup
...                 AND     Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     start log    btslog

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop log    btslog
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/SCF_AB4-40MHZ-FDD-paging.xml
${AP_XML}=      ${CURDIR}/config/SCF/iphy_40MHZ-FDD-2Cell.xml

${wts_cfg_file}    ${CURDIR}/config/wts/AB4-40MHZ.cfg
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
[1]CB008927_A_B4_4_Scheduling_of_Paging_with_DCI_11_RAT1_FDD_SA_UES_20_MHz
    log to console   UE attach trigerring now...
    start log       biptaf
    ${crnti_list1}=      MultiUE Register should be Successful    1      5
    Start traffic for UE    1     2
    start log       ttitrace
    Paging of UEs with attach         NAS_normal_release
    ${path_SCN_PA}    Stop Log      ttitrace
    ${path_SCN_PA_1}    Stop Log      biptaf
    Convert BIP To CSV By MCShark    ${path_SCN_PA_1}[biptaf]/BIP_L1L2.pcap    ${path_SCN_PA_1}[biptaf]/${BIP_CSV_NAME}
    ...                              filter=${FILTER_B003}    csv_title_list=${COLUMN_NAME}
    sleep     5s
    Decode TTI Trace
    sleep     10s
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${LOG_PATH}
    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}       Read Cellsetup msg  ${cprt_log_1}[cprt]   50
    Log to console      ${Initial_BWP}-${large_BWP}-${ssb_start_prb}
    Rat1 Allocation Verification    ${path_SCN_PA}[ttitrace]/output_dl_formated.csv    ${50}
    Verify RAT1 Allocation and PSA Region    ${path_SCN_PA}[ttitrace]/output_dl_formated.csv    ${50}    FDD
    ...    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}

*** Keywords ***
Paging of UEs with attach
    [Arguments]    ${cause}
    wtsrunner.amf_paging_param    default_drx=128    id=1    max_paging_retries=10
    wtsrunner.ue_ng_ctx_release    id=3   cause=${cause}
    ${output1}    wtsrunner.read_wtsemu_output_until_re    expected=IS IDLE   timeout=10
    wtsrunner.ue_ng_ctx_release    id=4-5   cause=${cause}
    ${output2}    wtsrunner.read_wtsemu_output_until_re    expected=IS IDLE   timeout=10
    sleep     10ms
    wtsrunner.ue_nr_rrc_setup_param       id=3       pagingdelay=10
    wtsrunner.ue_nr_rrc_setup_param       id=4       pagingdelay=10
    wtsrunner.ue_nr_rrc_setup_param       id=5       pagingdelay=10
    wtsrunner.amf_paging_start    id=1    ueid=3
    sleep     10ms
    wtsrunner.amf_paging_start    id=1    ueid=4
    sleep     10ms
    wtsrunner.amf_paging_start    id=1    ueid=5
    sleep     10ms
    sleep    2s

Start traffic for UE
    [Arguments]    ${S_UE_id}     ${E_UE_id}
    MultiUE Trigger DL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   dl_rate=100   pdu_id=1      trf_id=1       qfi_id=1

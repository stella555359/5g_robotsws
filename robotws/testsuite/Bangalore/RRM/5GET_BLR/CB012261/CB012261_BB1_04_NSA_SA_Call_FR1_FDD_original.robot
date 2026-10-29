*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      TC_1_CB008927-B
...             TEST SET NAME:     CB012261_BB1_04_NSA_SA_Call_FR1_FDD.robot
...             TESTING SPLIT:     See CB008927 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008927 CFAM


Resource         ./CB012261_resource.robot

Suite Setup         Run keywords    Log To console  Suitesetup
...                 AND     Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Stop Log     snapshot     sosreport
...                 AND     Kill WTS processes Using WTS_Runner


*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/SCF_FDD_LO_LOKI_LongPUCCH_20M.xml
${AP_XML}=      ${CURDIR}/config/SCF/IPHY_FDD_LO_LOKI_20M.xml

${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_FDD_LO_LOKI_20M.cfg
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

${duration}         120

*** Test Cases ***
[1]CB012261_BB1_04_PRB_Available_for_PUSCH_when_CB012261_enabled_inCell1_Disabled_inCell2_with_LongPucch_FDD

    set test variable      ${LOG_PATH}
    Start log       btslog

    Lock_cell and deactivate CB012261
    Unlock_cell
    X2AP Link Should be UP
    ${crnti_list1}=      MultiUE Attach for NSA      11      11
    ${crnti_list1}=      MultiUE Register should be Successful    1      1
    sleep     1s
    Lock_cell and activate CB012261
    Unlock_cell

#####CB012261-NSA_FDD
    X2AP Link Should be UP
    Log to console    NSA UE attach trigerring now...
    ${crnti_nsa}      MultiUE sgNB addtion for NSA     11    11    1
    ${crnti_nsa}      MultiUE Attach for NSA     12    12    2

    Start log       ttitrace
    Trigger UL Traffic for NSA with duration    11    12    Traffic_rate=mbps    ul_rate=${100}     duration=${duration}
    sleep     5s
    ${nsa_tti}    Stop Log      ttitrace    test_scenario=SCN_NSA
    sleep     ${duration}s

    ${tp_cell1_nsa}      Validate NSA UL Traffic    ue_id=${11}    rate=${100}    call_dur=${duration}
    ${tp_cell2_nsa}      Validate NSA UL Traffic    ue_id=${12}    rate=${100}    call_dur=${duration}
    Compare UL Traffic      ${tp_cell1_nsa}     ${tp_cell2_nsa}      pucch=long

#####CB012261-SA_FDD
    Log to console   SA UE attach trigerring now...
    ${crnti_list1}=      MultiUE Register should be Successful    1      2

    Start log       ttitrace
    MultiUE Trigger UL Traffic for SA with duration    1    2    Traffic_rate=mbps    ul_rate=${100}    duration=${duration}
    sleep     5s
    ${sa_tti}    Stop Log      ttitrace    test_scenario=SCN_SA
    sleep     ${duration}s

    ${tp_cell1_sa}      Validate SA UL Traffic    ue_id=${1}    rate=${100}    call_dur=${duration}
    ${tp_cell2_sa}      Validate SA UL Traffic    ue_id=${2}    rate=${100}    call_dur=${duration}
    Compare UL Traffic      ${tp_cell1_sa}     ${tp_cell2_sa}      pucch=long

#####TTITRACE Verification
    Common TTI PCAP to CSV Converter    SCN_NSA    dir=ul
    Common TTI PCAP to CSV Converter    SCN_SA    dir=ul

    ${pusch_BW}    ${prach_prb_off}      ${msg1fdm}      Read Cellsetup msg for uplink  ${cprt_log_1}[cprt]    50    51
    Log to console    PUSCH_BW=${pusch_BW} prach_prb_offset=${prach_prb_off} msg1fdm=${msg1fdm}

    ${ret}    Verify_2prb_CB012261    ${nsa_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_12   ${50}     ${pusch_BW}
    ...       ${prach_prb_off}[50]    ${msg1fdm}     Enabled
    Should Contain    ${ret}     Pass
    ${ret}    Verify_2prb_CB012261    ${nsa_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    shortprach    0_12   ${51}     ${pusch_BW}
    ...       ${prach_prb_off}[51]    ${msg1fdm}     Disabled
    Should Contain    ${ret}     Pass

    ${ret}    Verify_2prb_CB012261    ${sa_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_12   ${50}     ${pusch_BW}
    ...       ${prach_prb_off}[50]    ${msg1fdm}     Enabled
    Should Contain    ${ret}     Pass
    ${ret}    Verify_2prb_CB012261    ${sa_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    shortprach    0_12   ${51}     ${pusch_BW}
    ...       ${prach_prb_off}[51]    ${msg1fdm}     Disabled
    Should Contain    ${ret}     Pass

    ${path_syslog}    Stop log    btslog
    ${search_string}        Create List      WRN/     ERR/
    syslog_search      ${path_syslog}[btslog]/gnb_syslog.log         ${search_string}

    OperatingSystem.Run    cp ${WTS_DIR}/egate_console.log ${LOG_PATH}
    [Teardown]       Link SCOUT SCF to Configuration ID for Reporting

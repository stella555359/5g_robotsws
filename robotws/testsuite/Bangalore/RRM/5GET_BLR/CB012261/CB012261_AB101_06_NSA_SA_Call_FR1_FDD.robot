*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      CB012261_AB101_06_NSA_SA_Call_FR1_FDD
...             TEST SET NAME:     CB012261_AB101_06_NSA_SA_Call_FR1_FDD
...             TESTING SPLIT:     See CB008927 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008927 CFAM


Resource         ./CB012261_resource.robot

Suite Setup         Run keywords    Log To console  Suitesetup
...                 AND     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta_configuration_FDD_20MHZ_RestPRACH.json
...                 AND     gnb.Perform gNB reboot
...                 AND     Sleep   400s    reason=wait for RMOD- to comeup
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
#...                 AND     start log    btslog

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
#...                 AND     Stop log    btslog
...                 AND     Stop Log     snapshot  #  sosreport
...                 AND     Kill WTS processes Using WTS_Runner


*** Variables ***

${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_FDD_restPRACH_20MHZ.cfg
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

${duration}         60

*** Test Cases ***
[1]CB012261_AB101_06_NSA_SA_Call_FR1_FDD

    set test variable      ${LOG_PATH}
    Start log       btslog

    Lock_cell and deactivate CB012261     paramDstName=MRBTS-1/NRBTS-1/NRCELL-3
    Unlock_cell     paramDstName=MRBTS-1/NRBTS-1/NRCELL-3
    X2AP Link Should be UP
    ${crnti_list1}=      MultiUE Attach for NSA      151      151     3
    ${crnti_list1}=      MultiUE Register should be Successful    51      51
    sleep     1s
    Lock_cell and activate CB012261     paramDstName=MRBTS-1/NRBTS-1/NRCELL-3
    Unlock_cell     paramDstName=MRBTS-1/NRBTS-1/NRCELL-3

 ##### CB012261-NSA_FDD
    X2AP Link Should be UP
    Log to console    NSA UE attach trigerring now...
    ${crnti_nsa}      MultiUE SgNB addtion for NSA     151    151    3
    ${crnti_nsa}      MultiUE Attach for NSA     152    152    4

    Start log       ttitrace
    Trigger UL Traffic for NSA with duration    151    152    Traffic_rate=mbps    ul_rate=${100}     duration=${duration}
    sleep     5s
    ${nsa_tti}    Stop Log      ttitrace    test_scenario=SCN_NSA
    sleep     ${duration}s

    ${tp_cell1_nsa}      Validate NSA UL Traffic    ue_id=${151}    rate=${100}    call_dur=${duration}
    ${tp_cell2_nsa}      Validate NSA UL Traffic    ue_id=${152}    rate=${100}    call_dur=${duration}
    Compare UL Traffic      ${tp_cell1_nsa}     ${tp_cell2_nsa}      pucch=long

##### CB012261-SA_FDD
    Log to console   SA UE attach trigerring now...
    ${crnti_list1}=      MultiUE Register should be Successful    51      52

    Start log       ttitrace
    MultiUE Trigger UL Traffic for SA with duration    51    52    Traffic_rate=mbps    ul_rate=${100}    duration=${duration}
    sleep     5s
    ${sa_tti}    Stop Log      ttitrace    test_scenario=SCN_SA
    sleep     ${duration}s

    ${tp_cell1_sa}      Validate SA UL Traffic    ue_id=${51}    rate=${100}    call_dur=${duration}
    ${tp_cell2_sa}      Validate SA UL Traffic    ue_id=${52}    rate=${100}    call_dur=${duration}
    Compare UL Traffic      ${tp_cell1_sa}     ${tp_cell2_sa}      pucch=long

##### TTITRACE Verification
    Common TTI PCAP to CSV Converter    SCN_NSA    dir=ul
    Common TTI PCAP to CSV Converter    SCN_SA    dir=ul

    ${pusch_BW}    ${prach_prb_off}      ${msg1fdm}      Read Cellsetup msg for uplink  ${cprt_log_1}[cprt]    52    53
    Log to console    PUSCH_BW=${pusch_BW} prach_prb_offset=${prach_prb_off} msg1fdm=${msg1fdm}

    ${ret}    Verify_2prb_CB012261    ${nsa_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_12   ${52}     ${pusch_BW}
    ...       ${prach_prb_off}[52]    ${msg1fdm}     Enabled
    Should Contain    ${ret}     Pass
    ${ret}    Verify_2prb_CB012261    ${nsa_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_12   ${53}     ${pusch_BW}
    ...       ${prach_prb_off}[53]    ${msg1fdm}     Disabled
    Should Contain    ${ret}     Pass

    ${ret}    Verify_2prb_CB012261    ${sa_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_12   ${52}     ${pusch_BW}
    ...       ${prach_prb_off}[52]    ${msg1fdm}     Enabled
    Should Contain    ${ret}     Pass
    ${ret}    Verify_2prb_CB012261    ${sa_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_12   ${53}     ${pusch_BW}
    ...       ${prach_prb_off}[53]    ${msg1fdm}     Disabled
    Should Contain    ${ret}     Pass

    ${path_syslog}    Stop log    btslog
    ${search_string}        Create List      WRN/     ERR/
    syslog_search      ${path_syslog}[btslog]/gnb_syslog.log         ${search_string}

    OperatingSystem.Run    cp ${WTS_DIR}/egate_console.log ${LOG_PATH}
    [Teardown]       Link SCOUT SCF to Configuration ID for Reporting

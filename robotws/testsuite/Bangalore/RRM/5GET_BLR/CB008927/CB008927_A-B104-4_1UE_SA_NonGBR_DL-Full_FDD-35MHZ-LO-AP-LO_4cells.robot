*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS25R1    CONFIGURED

Documentation
...             author:                 samik.sarkar@nokia.com
...             maintainer:             samik.sarkar@nokia.com
...
...             INTRODUCTION:      CB008927_A-B104-4
...             TEST SET NAME:     CB008927_A-B104-4_1UE_SA_NonGBR_DL-Full_FDD-35MHZ-LO-AP-LO_4cells.robot
...             TESTING SPLIT:     See CB008927 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008927 CFAM
...             REQUIREMENT ID:        5G_RAN_USR_RRM_22990

Resource         ./CB008927_resource.robot

Suite Setup         Run keywords            Log To console  Suitesetup
...                 AND     Suite setup from scratch
...                 AND     Change IPHY File Value LOAPLO 4cells FDD 35MHZ      AHFII       4900
...                 AND     Perform SCF Delta Commissioning with Delta-FDD-35MHZ-LO-AP-LO_3rd4thCell.json
...                 AND     sleep    180s
...                 AND     Perform SCF Delta Commissioning with Delta-FDD-35MHZ-LO-AP-LO_3rd4thCell_A-B1.json
...                 AND     sleep    180s
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport
...                 AND     Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_FDD_35MHZ_LO-AP-LO.cfg
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
${BIP_CSV_NAME}    BIP_L1L2.pcap_filter_ON.csv
${FILTER_B003}    (dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq || uldata_pucchreceiverespps) && (3gpp.subcellid == 0)
@{COLUMN_NAME}     3gpp.sfn    3gpp.slot      3gpp.rnti       DlData_DciInfo.rachStatus    DlData_PdschGrant.startPrb
...                DlData_PdschGrant.numOfPrb    nr-rrc.c1    DlData_PdschGrant.rachStatus      uci.an

${ul_ue_ip}    72.23.0.1
${dl_ue_ip_1}    1.2.4.2
${dl_ue_ip_2}    1.2.4.3
${dl_port_1}    7073
${dl_port_2}    7074
${duration}    -t 3600
${bytes}    -n 8000000
${ping_unit}    Kbps
${iperf_unit}    Mbps

*** Test Cases ***
[1]CB008927_A_B104_4_Single_SA_UE_with_Non-GBR_traffic_DL_traffic-Full_FDD_35MHZ
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
##   UE-51 to NRCELL-3, UE-52 to NRCELL-4

    start log       biptaf    cprt
    start log       ttitrace
    ${crnti_list1}      MultiUE Register should be Successful And Fetch RNTI with RAT1     51       51
    MultiUE Trigger DL Traffic for SA       51       51      Traffic_rate=mbps    dl_rate=100    pdu_id=1
    ...     trf_id=1       qfi_id=1
    sleep     5s
    ${path_SCN1}    Stop Log      ttitrace     test_scenario=SCN1
    ${path_SCN2}    Stop Log    cprt      biptaf      test_scenario=SCN2
    log to console      tti_path-${path_SCN1}
    log to console      cprt-${path_SCN2}
    Convert BIP To CSV By MCShark    ${path_SCN2}[biptaf]/BIP_L1L2.pcap    ${path_SCN2}[biptaf]/${BIP_CSV_NAME}
    ...                              filter=${FILTER_B003}    csv_title_list=${COLUMN_NAME}

    sleep     10s
#    Decode Large TTI PCAP     ${path_SCN1}[ttitrace]
    Common TTI PCAP to CSV Converter    SCN1
    sleep     10s
    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}       Read Cellsetup msg  ${cprt_log_1}[cprt]   52
    Log to console      ${Initial_BWP}-${large_BWP}-${ssb_start_prb}

    Rat1 Allocation Verification    ${path_SCN1}[ttitrace]/output_dl_formated.csv    ${52}

    Verify RAT1 Allocation and PSA Region    ${path_SCN1}[ttitrace]/output_dl_formated.csv    ${52}    FDD
    ...    ${Initial_BWP}   ${large_BWP}    ${ssb_start_prb}

    MultiUE Deregister should be Successful   51    51


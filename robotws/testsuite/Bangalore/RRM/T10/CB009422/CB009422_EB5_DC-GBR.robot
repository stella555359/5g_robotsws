*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      CB009422
...             TEST SET NAME:     CB009422
...             TESTING SPLIT:     See CB009422 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB009422 CFAM


Resource         ./CB009422_resource.robot
#
Suite Setup         Run keywords    Log To console  Suitesetup
...                 AND     Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     sleep   60s
...                 AND     Perform SCF Delta Commissioning with 8DL8UL_to_4DL4UL_conversion_TMO.json
...                 AND     sleep   10s
...                 AND     Perform SCF Delta Commissioning with DC-GBR.json
...                 AND     sleep   180s
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG and verify cell status with CPRT    ${wts_cfg_file}	 ${start_cell}	 ${end_cell}
#...                 AND     start log    btslog

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Stop log    btslog
...                 AND     Stop Log     snapshot   sosreport


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_EB5_GBR.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}     /tmp/

${st_sa_id}             ${3}
${en_sa_id}             ${4}

${nwslice_ID}           ${1}
${Pdu_session_ID}       ${1}
${eNB_ID}               ${1}
${eNB_target}           ${2}
${start_cell}           1
${end_cell}             2
${TEST_NAME}            CB009422_B#B21
${TRF_ID}               2

${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_SCN1.csv
${BIP_CSV_NAME_PG}             BIP_L1L2.pcap_filter_PG.csv
${BIP_CSV_NAME_TP}             BIP_L1L2.pcap_filter_TP.csv
${FILTER_B003}                 dldata_pdcchsendreql1sw
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_DciInfoL1sw.startSymbolNumber    DlData_DciInfoL1sw.startCce
...                            DlData_DciInfoL1sw.aggregationLevel    DlData_DciInfoL1sw.dciSize    DlData_DciInfoL1sw.numOfSymbols

${IPHY_FILE}=      ${CURDIR}/config/SCF/iphy_TMO.xml

*** Test Cases ***
[1]CB009422_EB5#IWK5_Interworking_with_DC-GBR

    NSA X2AP Link Should be UP     ${eNB_ID}		${eNB_target}
    ${crnti_list1}=      NSA Multi UE Attach should be Successful      101      101    1
    ${crnti_list1}=      NSA Multi UE Attach should be Successful      121      121    2
    Start TTI_TRACE custom     ${51}
    ${crnti_list}   MultiUE Register should be Successful    ${1}   ${2}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}
    ${path_SCN_RA}   Stop log    ttitrace    test_scenario=preamble_slot
    sleep   1s
    Start TTI_TRACE custom     ${51}
    ${crnti_list}   MultiUE Register should be Successful    ${3}   ${10}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}
    ${path_SCN_CELL1}   Stop log    ttitrace    test_scenario=cell1_ue_register
    sleep   1s
    MultiUE PDU Modfication should be Successful    3    10    pdu_id=1    qosflows_to_add=2

    MultiUE Trigger DL Traffic for NSA    101    101    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     101    101    Traffic_rate=mbps    ul_rate=${5}
    MultiUE Trigger DL Traffic for NSA    121    121    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     121    121    Traffic_rate=mbps    ul_rate=${5}

    MultiUE Trigger DL Traffic for SA        ${1}    ${2}    mbps    30   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${1}    ${2}    mbps   30    pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1

    MultiUE Trigger DL Traffic for SA    3    10    Traffic_rate=mbps     dl_rate=40     pdu_id=1    trf_id=1       qfi_id=2
    MultiUE Trigger UL Traffic for SA    3    10    Traffic_rate=mbps     ul_rate=20      pdu_id=1    trf_id=1       qfi_id=2
    sleep   5m
    Start TTI_TRACE custom     ${51}
    sleep   2s
    ${path_Cell1_DATA}   Stop log    ttitrace    test_scenario=cell1_traffic
    sleep   30s
    CB009422_Verification    16

    Common TTI PCAP to CSV Converter    preamble_slot   dir=dl
    Common TTI PCAP to CSV Converter    preamble_slot   dir=ul
    Common TTI PCAP to CSV Converter    cell1_traffic   dir=dl
    Common TTI PCAP to CSV Converter    cell1_traffic   dir=ul
#    Common TTI PCAP to CSV Converter    cell2_traffic   dir=dl
#    Common TTI PCAP to CSV Converter    cell2_traffic   dir=ul

#   Verification of RA slots from TTI trace
    Verify_RA_slots    ${path_SCN_RA}[ttitrace]/output_ul_formated.csv   98

#   Verification of multiple_UE_scheduling from TTI trace
    Verify_multiple_UE_scheduling    ${path_Cell1_DATA}[ttitrace]/output_dl_formated.csv

#    CB009422_Verification    16
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

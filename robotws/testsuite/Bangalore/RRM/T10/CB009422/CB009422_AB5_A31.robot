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
...                 AND     Perform SCF Delta Commissioning with AEQE_AB5_A31_new_TMO.json
...                 AND     sleep   180s
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG and verify cell status with CPRT    ${wts_cfg_file}	 ${start_cell}	 ${end_cell}
...                 AND     start log    btslog

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Stop log    btslog
...                 AND     Stop Log     snapshot   sosreport


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_TMO.cfg
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
${TEST_NAME}            CB009422_AB5
${TRF_ID}               2

${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_SCN1.csv
${BIP_CSV_NAME_PG}             BIP_L1L2.pcap_filter_PG.csv
${BIP_CSV_NAME_TP}             BIP_L1L2.pcap_filter_TP.csv
${FILTER_B003}                 dldata_pdcchsendreql1sw
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_DciInfoL1sw.startSymbolNumber    DlData_DciInfoL1sw.startCce
...                            DlData_DciInfoL1sw.aggregationLevel    DlData_DciInfoL1sw.dciSize    DlData_DciInfoL1sw.numOfSymbols

${IPHY_FILE}=      ${CURDIR}/config/SCF/iphy_TMO.xml

*** Test Cases ***
[1]CB009422_A#B31_A#B32_Successful_Intra_frequency_Intra_DU_Intra_gNB_handover_based_on_A5_measurements

    NSA X2AP Link Should be UP     ${eNB_ID}		${eNB_target}

    Start TTI_TRACE custom     ${51}
    MultiUE Register should be Successful     ${1}  ${1}
    sleep     2s
    ${path_SCN_RA}   Stop Log     ttitrace    test_scenario=preamble_slot
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps   ul_rate=75   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps   dl_rate=75   pdu_id=1   trf_id=1   qfi_id=1
    Common TTI PCAP to CSV Converter    preamble_slot   dir=dl
    Common TTI PCAP to CSV Converter    preamble_slot   dir=ul
#   Verification of RA slots from TTI trace
    Verify_RA_slots    ${path_SCN_RA}[ttitrace]/output_ul_formated.csv   98
    FOR    ${index}    IN RANGE    5
    Log to Console    Performing Intra GNB HO - Attempt ${index + 1}
    CB009422_Verification   1
    Trigger A5 IntraFreq HO from TDD cell-1 to cell-2      1    1   53
    sleep     5s
    Start TTI_TRACE custom     ${53}
    sleep   3s
    ${path_SCN_HO}   Stop log    ttitrace    test_scenario=good_condition_HO
    sleep   3s
    Common TTI PCAP to CSV Converter    good_condition_HO   dir=dl
    Common TTI PCAP to CSV Converter    good_condition_HO   dir=ul

    #   Verification of K2 against all DL_slots from TTI trace
    Verify_K2    ${path_SCN_HO}[ttitrace]/output_ul_formated.csv

    #   Verification of K1 against all DL_slots from TTI trace
    Verify_K1    ${path_SCN_HO}[ttitrace]/output_dl_formated.csv    actEnhancedPDSCHSchSplSlot=${0}    guardPeriodLength=${6}

#   Verification of HARQ slots from TTI trace
    Verify_HARQ_slots    ${path_SCN_HO}[ttitrace]/output_dl_formated.csv    actEnhancedPDSCHSchSplSlot=${0}    guardPeriodLength=${6}

    sleep     5s
    Trigger A5 IntraFreq HO from TDD cell-1 to cell-2      1    1   51
    END
    MultiUE Deregister should be Successful   1     1
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

[1]CB009422_AB5_multiple_UE_scheduling_with_TDLTECfg0

    NSA X2AP Link Should be UP     ${eNB_ID}		${eNB_target}
    ${crnti_list1}=      NSA Multi UE Attach should be Successful      101      101    1
    ${crnti_list1}=      NSA Multi UE Attach should be Successful      121      121    2
    Start TTI_TRACE custom     ${51}
    ${crnti_list}   MultiUE Register should be Successful    ${1}   ${2}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}
    ${path_SCN_RA}   Stop log    ttitrace    test_scenario=preamble_slot
    ${crnti_list}   MultiUE Register should be Successful    ${3}   ${10}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}
    ${crnti_list}   MultiUE Register should be Successful    ${21}   ${30}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}
    MultiUE Trigger DL Traffic for NSA    101    101    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     101    101    Traffic_rate=mbps    ul_rate=${5}
    MultiUE Trigger DL Traffic for NSA    121    121    Traffic_rate=mbps    dl_rate=${1}
    MultiUE Trigger UL Traffic for NSA     121    121    Traffic_rate=mbps    ul_rate=${5}
    MultiUE Trigger DL Traffic for SA        ${1}    ${7}    mbps    1   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${1}    ${7}    mbps   5    pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger DL Traffic for SA        ${21}    ${27}    mbps    1   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${21}    ${27}    mbps    5   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    sleep   8m
    Start TTI_TRACE custom     ${51}
    sleep   2s
    ${path_SCN_SRS}   Stop log    ttitrace    test_scenario=srs_beam
    Common TTI PCAP to CSV Converter    preamble_slot   dir=dl
    Common TTI PCAP to CSV Converter    preamble_slot   dir=ul
    Common TTI PCAP to CSV Converter    srs_beam   dir=dl
    Common TTI PCAP to CSV Converter    srs_beam   dir=ul

#   Verification of RA slots from TTI trace
    Verify_RA_slots    ${path_SCN_RA}[ttitrace]/output_ul_formated.csv   98

#   Verification of SRS beamType from TTI trace
    Verify_SRS_beam    ${path_SCN_SRS}[ttitrace]/output_dl_formated.csv

    CB009422_Verification    16
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

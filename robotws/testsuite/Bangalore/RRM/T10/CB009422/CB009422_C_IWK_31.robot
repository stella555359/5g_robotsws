*** Settings ***
Force Tags      CLOUD_5G_I_BOO_AP_LOO
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS25R3    CONFIGURED

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      CB009422
...             TEST SET NAME:     CB009422
...             TESTING SPLIT:     See CB009422 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB009422 CFAM

Library          ../../../resources/python/avg_dl_data.py
Resource         ./CB009422_resource.robot
Library          Dialogs

Test Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Stop log    btslog
...                 AND     Stop Log     snapshot    sosreport


*** Variables ***
${AP_XML}=      ${CURDIR}/config/SCF/iphy_3TDD.xml
${SCFC}=        ${CURDIR}/config/SCF/BOO_LOO_TTT_3CCDL_2CC_UL_40_40_20_MHZ-tdlteconfig.xml
${AP_XML1}=      ${CURDIR}/config/SCF/iphy_c42.xml
${SCFC1}=        ${CURDIR}/config/SCF/scfc_c_newbwpaligned.xml
${SCFC2}=        ${CURDIR}/config/SCF/scfc_c_newbwpaligned.xml
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_3TDD.cfg
${wts_cfg_file1}     ${CURDIR}/config/wts/basic_setup_c42.cfg


${SCFC3}=       ${CURDIR}/config/SCF/scfc_10mhz_splitd.xml
${AP_XML3}=      ${CURDIR}/config/SCF/iphy_10mhz_splitd.xml
${wts_cfg_file3}     ${CURDIR}/config/wts/basic_setup_10mhz.cfg

${WTS_DIR}          /opt/iphy/latest
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}     /tmp/

${st_sa_id}             ${3}
${en_sa_id}             ${4}

${nwslice_ID}           ${1}
${Pdu_session_ID}       ${1}
${eNB_ID}               ${1}
${eNB_target}           ${2}
${start_cell}           5
${end_cell}             7
${TEST_NAME}            CB009422-C-3
${TRF_ID}               2

${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_SCN1.csv
${BIP_CSV_NAME_PG}             BIP_L1L2.pcap_filter_PG.csv
${BIP_CSV_NAME_TP}             BIP_L1L2.pcap_filter_TP.csv
${FILTER_B003}                 dldata_pdcchsendreql1sw
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_DciInfoL1sw.startSymbolNumber    DlData_DciInfoL1sw.startCce
...                            DlData_DciInfoL1sw.aggregationLevel    DlData_DciInfoL1sw.dciSize    DlData_DciInfoL1sw.numOfSymbols

*** Test Cases ***
[1]CB009422_C_IWK_31
    [Setup]    Run keywords    Log To console  Suitesetup
     ...                 AND     Prepare TL with all config files        ${SCFC}        ${AP_XML}
    ...                 AND     Suite setup from scratch
     ...                 AND     sleep   120s
    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
    ...                 AND     Run Keyword and Ignore error        Load CFG and verify cell status with CPRT    ${wts_cfg_file}     5     6
    ...                 AND     Sleep   20s
    ...                 AND     start log    btslog
    NSA X2AP Link Should be UP     ${eNB_ID}		${eNB_target}
    Run Keyword and Ignore Error        Link SCOUT SCF to Configuration ID for Reporting
    ${crnti_list}   MultiUE Register should be Successful    ${1}   ${4}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}
    MultiUE Trigger DL Traffic for SA        ${1}    ${4}    mbps    125   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger DL Traffic for SA        ${1}    ${4}    mbps    125   pdu_id=${Pdu_session_ID}
    ...     trf_id=2    qfi_id=1
    MultiUE Trigger DL Traffic for SA        ${1}    ${4}    mbps    125   pdu_id=${Pdu_session_ID}
    ...     trf_id=3    qfi_id=1
    MultiUE Trigger DL Traffic for SA        ${1}    ${4}    mbps    125   pdu_id=${Pdu_session_ID}
    ...     trf_id=4    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${1}    ${4}    mbps    175   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${1}    ${4}    mbps    175   pdu_id=${Pdu_session_ID}
    ...     trf_id=2    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${1}    ${4}    mbps    175   pdu_id=${Pdu_session_ID}
    ...     trf_id=3    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${1}    ${4}    mbps    175   pdu_id=${Pdu_session_ID}
    ...     trf_id=4    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${1}    ${4}    mbps    175   pdu_id=${Pdu_session_ID}
    ...     trf_id=5    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${1}    ${4}    mbps    175   pdu_id=${Pdu_session_ID}
    ...     trf_id=6    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${1}    ${4}    mbps    175   pdu_id=${Pdu_session_ID}
    ...     trf_id=7    qfi_id=1

    Start log   ttitrace
    sleep   2s
    ${path_SCN_1}   Stop log    ttitrace    test_scenario=good_condition

    OperatingSystem.Run    cp ${WTS_DIR}/egate_console.log ${LOG_PATH}
    Run Keyword And Ignore Error  Link SCOUT SCF to Configuration ID for Reporting

    Common TTI PCAP to CSV Converter    good_condition   dir=dl
    Common TTI PCAP to CSV Converter    good_condition   dir=ul

    Verify_CA_Checks       ${path_SCN_1}[ttitrace]/output_dl_formated.csv    direction=dl
    Verify_CA_Checks       ${path_SCN_1}[ttitrace]/output_ul_formated.csv    direction=ul


CB009422_C_IWK_42
    [Setup]    Run keywords    Log To console  Suitesetup
     ...                 AND     Prepare TL with all config files        ${SCFC1}        ${AP_XML1}
    ...                 AND     Suite setup from scratch
     ...                 AND     sleep   120s
    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
    ...                 AND     Run Keyword and Ignore error        Load CFG and verify cell status with CPRT    ${wts_cfg_file1}     5     6
    ...                 AND     Sleep   20s
#    ...                 AND     start log    btslog
    NSA X2AP Link Should be UP     ${eNB_ID}        ${eNB_target}
    Run Keyword and Ignore Error        Link SCOUT SCF to Configuration ID for Reporting
    Wait until the next Measurement Period starts  additional_time=${0}
    ${crnti_list}   MultiUE Register should be Successful    ${3}   ${10}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}
    MultiUE Trigger DL Traffic for SA        ${3}    ${10}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger DL Traffic for SA        ${3}    ${10}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=2    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${3}    ${10}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${3}    ${10}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=2    qfi_id=1
    Execute Egate Command    cmd=ue_measurement_send_nr id=3 meas_id=1 event=A1 srsrp_nr=105 phycell_id=52       timeout=20s
    Sleep   10s
    MultiUE Trigger UL Traffic for SA         ${3}    ${10}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=3    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${3}    ${10}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=4    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${3}    ${10}    mbps    20   pdu_id=${Pdu_session_ID}
    ...     trf_id=5    qfi_id=1
    Wait until the current Measurement Period stops


    Collect ULTX Counters and verify

    Start log   ttitrace
    sleep   2s
    ${path_SCN_1}   Stop log    ttitrace    test_scenario=good_condition
    OperatingSystem.Run    cp ${WTS_DIR}/egate_console.log ${LOG_PATH}
    Run Keyword And Ignore Error  Link SCOUT SCF to Configuration ID for Reporting
    Validate Throughput     3       3

    Common TTI PCAP to CSV Converter    good_condition   dir=dl
    Common TTI PCAP to CSV Converter    good_condition   dir=ul

    Verify_CA_Checks       ${path_SCN_1}[ttitrace]/output_dl_formated.csv    direction=dl
    Verify_CA_Checks       ${path_SCN_1}[ttitrace]/output_ul_formated.csv    direction=ul

CB009422_Split_D_10mhz
    [Setup]    Run keywords    Log To console  Suitesetup
    ...                 AND     Prepare TL with all config files        ${SCFC3}        ${AP_XML3}
    ...                 AND     Suite setup from scratch
    ...                 AND     sleep   120s
    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
    ...                 AND     Run Keyword and Ignore error        Load CFG and verify cell status with CPRT    ${wts_cfg_file3}     1     2
    ...                 AND     Sleep   20s
#    ...                 AND     start log    btslog
    NSA X2AP Link Should be UP     ${eNB_ID}        ${eNB_target}
    Run Keyword and Ignore Error        Link SCOUT SCF to Configuration ID for Reporting
    Start log   ttitrace
    ${crnti_list}   MultiUE Register should be Successful    ${1}   ${3}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}
    ${path_SCN_RA}   Stop log    ttitrace    test_scenario=preamble_slot
    MultiUE Trigger DL Traffic for SA        ${1}    ${3}    mbps    100   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${1}    ${3}    mbps    100   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    CB009422_Verification_K1_K2_HARQ_SplitD
    Common TTI PCAP to CSV Converter    preamble_slot   dir=dl
    Common TTI PCAP to CSV Converter    preamble_slot   dir=ul
    Verify_RA_slots    ${path_SCN_RA}[ttitrace]/output_ul_formated.csv   93

*** Keywords ***
Collect ULTX Counters and verify
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${ACC_NUM_UL_TX_SW_OP1_UE_CONFG}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55181C00010    moc=MRBTS-1/NRBTS-1/NRCELL-3
    ${ACC_NUM_UL_TX_SW_OP1_UE_CAP}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55118C00053    moc=MRBTS-1/NRBTS-1/NRCELL-3
    Should be True      ${ACC_NUM_UL_TX_SW_OP1_UE_CONFG} > 0
    Should be True      ${ACC_NUM_UL_TX_SW_OP1_UE_CAP} > 0

Validate Throughput
    [Arguments]    ${st_ue_id}=1        ${en_ue_id}=1   ${scell_idx}=0
    FOR    ${id}    IN RANGE   ${st_ue_id}        ${en_ue_id}+1
    ${DATA_UL}    wts_sim_keywords.Get AVG UL DATA TRAFFIC For Given CC     ${id}    ${scell_idx}
    Should be True    ${DATA_UL} > 60
    END

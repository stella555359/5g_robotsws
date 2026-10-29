*** Settings ***
Force Tags      CLOUD_5G_I_BOO_AP_LOO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      CB012261_C_IWK1_03_InterBand_UL_CA_inFDD_CB005935_AAB9_Scell_LongPrachFromat0_inPcell_longPrachFormat1_inScell
...             TEST SET NAME:     CB012261_C_IWK1_03_InterBand_UL_CA_inFDD_CB005935_AAB9_Scell_LongPrachFromat0_inPcell_longPrachFormat1_inScell
...             TESTING SPLIT:     See CB012261 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB012261 CFAM


Resource         ./CB012261_resource.robot

Suite Setup         Run keywords    Log To console  Suitesetup
...                 AND     Prepare TL with all config files
...                 AND     Suite setup from scratch
#...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/CB005935_SCFC_BOO_AP_LOO.xml
${AP_XML}=      ${CURDIR}/config/SCF/CB005935_BOO_AP_LOO_iphy.xml

${wts_cfg_file}    ${CURDIR}/config/wts/wts_CB005935_BOO_AP_LOO.cfg
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

*** Test Cases ***
[1]CB012261_C_IWK1_03_InterBand_UL_CA_inFDD_CB005935_AAB9_Scell_LongPrachFromat0_inPcell_longPrachFormat1_inScell
    Start log       btslog
    log to console   Starting tti logs...
    start log       ttitrace
    log to console   UE1 attach trigerring now...
    ${crnti_list1}=      MultiUE Register should be Successful    1      1
    Start traffic for UE    1    1
    sleep     3s
    ${path_tti}    Stop Log      ttitrace    test_scenario=SCN1
    sleep     5s

##### TTITRACE Verification

    Common TTI PCAP to CSV Converter    SCN1    dir=ul
    sleep     10s
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${LOG_PATH}
    ${path_syslog}    Stop log    btslog
    ${search_string}        Create List      WRN/     ERR/
    syslog_search      ${path_syslog}[btslog]/gnb_syslog.log         ${search_string}

    ${pusch_BW}    ${prach_prb_off}      ${msg1fdm}      Read Cellsetup msg for uplink  ${cprt_log_1}[cprt]    53    51
    Log to console    PUSCH_BW=${pusch_BW} prach_prb_offset=${prach_prb_off} msg1fdm=${msg1fdm}

    ${ret}    Verify_2prb_CB012261    ${path_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    1_42   ${53}
    ...            ${pusch_BW}       ${prach_prb_off}[53]       ${msg1fdm}     Enabled
    Should Contain    ${ret}     Pass

    ${ret}    Verify_2prb_CB012261    ${path_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_13   ${51}
    ...            ${pusch_BW}       ${prach_prb_off}[51]       ${msg1fdm}     Disabled
    Should Contain    ${ret}     Pass
    [Teardown]       Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***

Start traffic for UE
    [Arguments]    ${S_UE_id}     ${E_UE_id}
    MultiUE Trigger UL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   ul_rate=100   pdu_id=1      trf_id=1       qfi_id=1

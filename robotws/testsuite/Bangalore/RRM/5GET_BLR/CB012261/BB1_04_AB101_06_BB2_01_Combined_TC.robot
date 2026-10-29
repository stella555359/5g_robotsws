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

#Suite Setup         Run keywords    Log To console  Suitesetup
#...                 AND     Suite setup from scratch
##...                 AND     Perform SCF Delta Commissioning with Delta_configuration_FDD_20MHZ_RestPRACH.json
#...                 AND     gnb.Perform gNB reboot
#...                 AND     Sleep   600s    reason=wait for RMOD- to comeup
#...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
##...                 AND     start log    btslog

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
#...                 AND     Stop log    btslog
...                 AND     Stop Log     snapshot  #  sosreport
...                 AND     Kill WTS processes Using WTS_Runner


*** Variables ***
${AP_XML}=      ${CURDIR}/config/SCF/IPHY.xml
${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup.cfg
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

[1]CB012261_BB1_04_PRB_Available_for_PUSCH_when_CB012261_enabled_inCell1_Disabled_inCell2_with_LongPucch_FDD

    [Tags]     TC_01
    [Setup]    Run keywords       Suite setup from scratch
    ...                 AND     Perform SCF Delta Commissioning with Delta_configuration_FDD_20MHZ_RestPRACH_tmo.json
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Sleep   500s    reason=wait for RMOD- to comeup
    ...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
    ...                 AND     Sleep   300s    reason=wait for RMOD- to comeup

    set test variable      ${LOG_PATH}
    Start log       btslog

#    Lock_cell and deactivate CB012261     paramDstName=MRBTS-1/NRBTS-1/NRCELL-10
#    Unlock_cell     paramDstName=MRBTS-1/NRBTS-1/NRCELL-10
#    X2AP Link Should be UP
#    ${crnti_list1}=      MultiUE Attach for NSA      151      151     10
#    ${crnti_list1}=      MultiUE Register should be Successful    81      81
#    sleep     1s
#    Lock_cell and activate CB012261     paramDstName=MRBTS-1/NRBTS-1/NRCELL-10
#    Unlock_cell     paramDstName=MRBTS-1/NRBTS-1/NRCELL-10

 ##### CB012261-NSA_FDD
    X2AP Link Should be UP
    Log to console    NSA UE attach trigerring now...
    ${crnti_nsa}      MultiUE Attach for NSA     151    151    10
    ${crnti_nsa}      MultiUE Attach for NSA     152    152    11

#    Start log       ttitrace
    Start TTI_TRACE custom     ${60}
    sleep     1s
    Trigger UL Traffic for NSA with duration    151    151    Traffic_rate=mbps    ul_rate=${100}     duration=${duration}
    sleep     5s
    ${nsa_tti_60}    Stop Log      ttitrace    test_scenario=SCN_NSA_60
    Start TTI_TRACE custom     ${61}
    sleep     1s
    Trigger UL Traffic for NSA with duration    152    152    Traffic_rate=mbps    ul_rate=${100}     duration=${duration}
    sleep     5s
    ${nsa_tti_61}    Stop Log      ttitrace    test_scenario=SCN_NSA_61
    sleep     ${duration}s

    ${tp_cell1_nsa}      Validate NSA UL Traffic    ue_id=${151}    rate=${100}    call_dur=${duration}
    ${tp_cell2_nsa}      Validate NSA UL Traffic    ue_id=${152}    rate=${100}    call_dur=${duration}
    Compare UL Traffic      ${tp_cell1_nsa}     ${tp_cell2_nsa}      pucch=long
    MultiUE Detach for NSA     151     152
#    MultiUE Deregister should be Successful    81    82

##### CB012261-SA_FDD
    Log to console   SA UE attach trigerring now...
    ${crnti_list1}=      MultiUE Register should be Successful    81      82

#    Start log       ttitrace
    Start TTI_TRACE custom     ${60}
    sleep     1s
    MultiUE Trigger UL Traffic for SA with duration    81    81    Traffic_rate=mbps    ul_rate=${100}    duration=${duration}
    sleep     5s
    ${sa_tti_60}    Stop Log      ttitrace    test_scenario=SCN_SA_60
    Start TTI_TRACE custom     ${61}
    sleep     1s
    MultiUE Trigger UL Traffic for SA with duration    82    82    Traffic_rate=mbps    ul_rate=${100}    duration=${duration}
    sleep     5s
    ${sa_tti_61}    Stop Log      ttitrace    test_scenario=SCN_SA_61
    sleep     ${duration}s

    ${tp_cell1_sa}      Validate SA UL Traffic    ue_id=${81}    rate=${100}    call_dur=${duration}
    ${tp_cell2_sa}      Validate SA UL Traffic    ue_id=${82}    rate=${100}    call_dur=${duration}
    Compare UL Traffic      ${tp_cell1_sa}     ${tp_cell2_sa}      pucch=long
    MultiUE Deregister should be Successful    81    82

#### TTITRACE Verification
    Common TTI PCAP to CSV Converter    SCN_NSA_60    dir=ul
    Common TTI PCAP to CSV Converter    SCN_NSA_61    dir=ul
    Common TTI PCAP to CSV Converter    SCN_SA_60    dir=ul
    Common TTI PCAP to CSV Converter    SCN_SA_61    dir=ul

    ${pusch_BW}    ${prach_prb_off}      ${msg1fdm}      Read Cellsetup msg for uplink  ${cprt_log_1}[cprt]    60    61
    Log to console    PUSCH_BW=${pusch_BW} prach_prb_offset=${prach_prb_off} msg1fdm=${msg1fdm}

    ${ret}    Verify_2prb_CB012261    ${nsa_tti_60}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_12   ${60}     ${pusch_BW}
    ...       ${prach_prb_off}[60]    ${msg1fdm}     Enabled
    Should Contain    ${ret}     Pass
    ${ret}    Verify_2prb_CB012261    ${nsa_tti_61}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_13   ${61}     ${pusch_BW}
    ...       ${prach_prb_off}[61]    ${msg1fdm}     Disabled
    Should Contain    ${ret}     Pass

    ${ret}    Verify_2prb_CB012261    ${sa_tti_60}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_12   ${60}     ${pusch_BW}
    ...       ${prach_prb_off}[60]    ${msg1fdm}     Enabled
    Should Contain    ${ret}     Pass
    ${ret}    Verify_2prb_CB012261    ${sa_tti_61}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_13   ${61}     ${pusch_BW}
    ...       ${prach_prb_off}[61]    ${msg1fdm}     Disabled
    Should Contain    ${ret}     Pass

    ${path_syslog}    Stop log    btslog
    Multiple Feature Activate Deactivate

        [Teardown]  Run Keywords   Log To console  TCTeardown
         ...         AND        Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
         ...         AND        Run Keyword and Ignore Error   Link SCOUT SCF to Configuration ID for Reporting


[1]CB012261_BB2_01_PRB_Available_for_PUSCH_when_CB012261_enabled_inCell1_Disabled_inCell2_with_ShortPucch_TDD

    [Tags]     TC_02
    [Setup]    Run keywords     Suite setup from scratch
    ...                 AND     Prepare TL with IPHY file change
    ...                 AND     Perform SCF Delta Commissioning with Delta_GMC_TDD_LO_ShortPUCCH_LongPRACH_10M_tmo.json
    ...                 AND     sleep   90s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Sleep   500s    reason=wait for RMOD- to comeup
    ...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
    ...                 AND     Sleep   300s    reason=wait for RMOD- to comeup

    set test variable      ${LOG_PATH}
#    Start log       btslog

#    sleep     3s

#    Lock_cell and deactivate CB012261
#    Unlock_cell
#    sleep     3s
#    X2AP Link Should be UP

#    ${crnti_list1}=      MultiUE Attach for NSA      101      101       1
#    ${crnti_list1}=      MultiUE Register should be Successful    1      1
#    sleep     1s
#    Lock_cell and activate CB012261
#    Unlock_cell
#    sleep     3s
#####CB012261-NSA_TDD
    X2AP Link Should be UP
    Log to console    NSA UE attach trigerring now...
    ${crnti_nsa}      MultiUE Attach for NSA     101    101    1
    ${crnti_nsa}      MultiUE Attach for NSA     102    102    2

#    Start log       ttitrace
    Start TTI_TRACE custom     ${51}
    sleep     1s

    Trigger UL Traffic for NSA with duration    101    102    Traffic_rate=mbps    ul_rate=${175}     duration=${duration}
    ...     id=${2}    trf_id=${1}
    Trigger UL Traffic for NSA with duration    101    102    Traffic_rate=mbps    ul_rate=${25}     duration=${duration}
    ...     id=${2}    trf_id=${2}
    sleep     5s
    ${nsa_tti}    Stop Log      ttitrace    test_scenario=SCN_NSA
    sleep     ${duration}s
    ${tp_cell1_nsa}      Validate NSA UL Traffic    ue_id=${101}    rate=${175}    call_dur=${duration}
    ${tp_cell2_nsa}      Validate NSA UL Traffic    ue_id=${102}    rate=${175}    call_dur=${duration}
    Compare UL Traffic      ${tp_cell1_nsa}     ${tp_cell2_nsa}      pucch=short
    MultiUE Detach for NSA     101     102

#####CB012261-SA_TDD
    Log to console   SA UE attach trigerring now...
    ${crnti_list1}=      MultiUE Register should be Successful    1      2

#    Start log       ttitrace
    Start TTI_TRACE custom     ${52}
    sleep     1s
    MultiUE Trigger UL Traffic for SA with duration    1    2    Traffic_rate=mbps    ul_rate=${175}    duration=${duration}
    ...    pdu_id=${1}    trf_id=${1}    qfi_id=${1}
    MultiUE Trigger UL Traffic for SA with duration    1    2    Traffic_rate=mbps    ul_rate=${25}    duration=${duration}
    ...    pdu_id=${1}    trf_id=${2}    qfi_id=${1}
    sleep     5s
    ${sa_tti}    Stop Log      ttitrace    test_scenario=SCN_SA
    sleep     ${duration}s
    ${tp_cell1_sa}      Validate SA UL Traffic    ue_id=${1}    rate=${175}    call_dur=${duration}
    ${tp_cell2_sa}      Validate SA UL Traffic    ue_id=${2}    rate=${175}    call_dur=${duration}
    Compare UL Traffic      ${tp_cell1_sa}     ${tp_cell2_sa}      pucch=short

#####TTITRACE Verification
    Common TTI PCAP to CSV Converter    SCN_NSA    dir=ul
    Common TTI PCAP to CSV Converter    SCN_SA    dir=ul

    ${pusch_BW}    ${prach_prb_off}      ${msg1fdm}      Read Cellsetup msg for uplink  ${cprt_log_1}[cprt]    51    52
    Log to console    PUSCH_BW=${pusch_BW} prach_prb_offset=${prach_prb_off} msg1fdm=${msg1fdm}

    ${ret}    Verify_2prb_CB012261    ${nsa_tti}[ttitrace]/output_ul_formated.csv    TDD    shortpucch    shortprach    semi_1_4   ${51}
    ...            ${pusch_BW}       ${prach_prb_off}[51]       ${msg1fdm}     Enabled
    ${ret}    Verify_2prb_CB012261    ${nsa_tti}[ttitrace]/output_ul_formated.csv    TDD    shortpucch    shortprach    semi_1_4   ${52}
    ...            ${pusch_BW}       ${prach_prb_off}[52]       ${msg1fdm}     Disable
    ${ret}    Verify_2prb_CB012261    ${sa_tti}[ttitrace]/output_ul_formated.csv    TDD    shortpucch    shortprach    semi_1_4    ${51}
    ...            ${pusch_BW}       ${prach_prb_off}[51]       ${msg1fdm}     Enabled
    ${ret}    Verify_2prb_CB012261    ${sa_tti}[ttitrace]/output_ul_formated.csv    TDD    shortpucch    shortprach    semi_1_4    ${52}
    ...            ${pusch_BW}       ${prach_prb_off}[52]       ${msg1fdm}     Disabled

#    ${path_syslog}    Stop log    btslog
    [Teardown]      Run Keywords   Log To console  TCTeardown
         ...         AND        Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
         ...         AND        Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Multiple Feature Activate Deactivate
    [Documentation]    Alternates NIDD feature enable and disable 3 times.
    Log To Console    \nChanging feature flag value
    taf.sbts.oam.coam.admin.Setup Admin
    @{values}    Create List    enabled_Level1    disabled    enabled_Level1    disabled    enabled_Level1    disabled
    FOR    ${val}    IN    @{values}
        Log To Console    Setting feature to ${val}
        Online NIDD parameter change Upd    paramName=actPrachMultiplexingLevel    paramValue=${val}    paramDst=MRBTS-1/NRBTS-1/NRCELL-3
        Sleep    10s
    END
    [Teardown]    taf.sbts.oam.coam.admin.Teardown Admin

Online NIDD parameter change Upd
     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
     ...                and returns the result
     ...        [Arguments]    parameter        :  Parameter names to parsed
     ...                       paramDst         :  Dist name should be parsed
     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
     ...                       skip_parameter_relation_errors : Default Value is True if you want to set this False
     ...                       then parse the parameter as False
     [Arguments]        ${paramName}='None'                 ${paramValue}='None'
     ...                ${paramDst}='None'                  ${operation}=update
     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
     taf.sbts.oam.coam.admin.perform_parameter_recommissioning          parameter=${paramName}
     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
     ...        should_activate=${should_activate}

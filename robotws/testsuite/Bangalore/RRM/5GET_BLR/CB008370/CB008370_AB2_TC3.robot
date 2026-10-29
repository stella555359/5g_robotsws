*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...               RAN_5G_TDD    SBTS00    CRT   TOOLS_PROFILE_TTI_LEGACY   CONFIGURED


Documentation
...
...  AUTHOR          :   sunil.t_kurian@nokia.com
...  MAINTAINER      :   sunil.t_kurian@nokia.com
...  INTRODUCTION    :   CB008370 PDSCH shared with PDCCH in first OFDM symbol
...  TEST SET NAME   :   CB008370-A#B2:Activation of the feature for single UE in mixed radio condition
...  REFERENCES      :   CB008370-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_24057

Resource         ../resources/robot/common_log_collection.robot
Resource         ./resources/CB008370_resources.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Library          ../CB008927/python/adaptive_retx.py
Library         ./resources/verify_ratematching.py
Library         ./resources/verify_dummyrnti.py

Suite Setup         Run keywords    Suite setup from scratch
...                 AND    5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_CB008370_FrameStructure_1116_3ms_AB2_TC3_LO.json
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD- to comeup
...                 AND    5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_8370_disable.json
...                 AND        Load CFG and verify cell status   ${wts_cfg_file}    1    4
...                 AND       Check gNB Bulid

Test Teardown    Run Keywords        wts_sim_keywords.Clean edaemon and egate
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Link SCOUT SCF to Configuration ID for Reporting
*** Variables ***
${wts_cfg_file}          ${CURDIR}/config/basic_setup_LO.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${UE_ID}       1
${start_ueid}   1
${end_ueid}     1
${QFI_ID1}     1
${TRF_ID1}     1
${SCFC}=        ${CURDIR}/config/SCF/SCF_CB008370_AB2_TC3.xml
${AP_XML}=      ${CURDIR}/config/SCF/iphy_CB008370_AB2_TC3.xml
@{PDSCH_SLIVs}=    ${98}   ${85}   ${57}   ${70}   ${56}   ${43}   ${27}   ${41}   ${55}   ${83}   ${97}
${FILTER_B003}                 dldata_pdschsendreql1sw&&3gpp.subcellid==0
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_PdschGrantL1sw.startSymbol    DlData_PdschGrantL1sw.numOfPdschSymbols
...                            DlData_PdschGrantL1sw.numOfPrb    DlData_PdschGrantL1sw.startPrb      DlData_PdschGrantL1sw.rateMatchingOption
...                            DlData_PdschGrantL1sw.numRateMatchingRes
${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_SCN1.csv
${RnD_flag}        0
${TDD_framestructure}      1116    #TDD_framestructure can be - 1208 , 1116
*** Test Cases ***
[1]CB008370_AB2_TC3_Activation_of_the_feature_for_single_UE_in_mixed_radio_conditions
    [Tags]   QC_27388   QCD_MN_RAN   QCP_RAN_VRF
    set test variable      ${LOG_PATH}
    log to console   Suite setup successful ...
    Test single UE full traffic with bler and verify Adaptive retransmission for feature flag disabled
    Perform SCF delta for enabling feature flag
    Test single UE full traffic with bler and validate new SLIV_Adaptive retransmission for feature flag enabled
    Compare throughput and Legacy Counters
    Checking new counters are pegging
    Deactivate BLER profile and verify throughput and legacy counter

*** Keywords ***
Test single UE full traffic with bler and verify Adaptive retransmission for feature flag disabled
    Start log   btslog   cprt
    Intiate Bler for Ues and activate with pktloss     startue=1   endue=1    pkt_loss=60
    ${crnti_list_1}   UE Register should be Successful And Fetch RNTI and TDRA list    ue_id=1     pdu_id=1    nw_id=1
    ...     gw_id=1    8370_flag=0
    Start Multi UE DL traffic with multiple trafficID   start_ue=1   end_ue=1   dl_trf_id=8   qfi_id=1
    Start Multi UE UL traffic with multiple trafficID   start_ue=1   end_ue=1   ul_trf_id=1   qfi_id=1
    Set Suite Variable   ${crnti_list_1}
    ${tput_stats_before_flag}    Wait Until Keyword Succeeds    5x  10sec    Get DL Throughput for Pcell    UE_ID=1    end_UE_ID=1    scell=0
          ...     expected_thp=550
    Run keyword and Continue on Failure    Get UL Throughput for Pcell    UE_ID=1    end_UE_ID=1    scell=0   expected_thp=105
    Set Suite Variable   ${tput_stats_before_flag}
    Stop log   btslog    cprt   test_scenario=DL_data_8370_disabled
    #Run Keyword And Continue On Failure    Collect BIP and decode    test_scenario=DL_data_8370_disabled
    Collect TTI and verify Adaptive retransmission  test_scenario=DL_data_8370_disabled
    ${Cell1M55308C03001_8370_disabled_C1}      ${Cell1M55308C03005_8370_disabled_C2}      Collect Legacy Counters
    Set Suite Variable   ${Cell1M55308C03001_8370_disabled_C1}
    Set Suite Variable   ${Cell1M55308C03005_8370_disabled_C2}
    Log To Console       ${Cell1M55308C03001_8370_disabled_C1}       ${Cell1M55308C03005_8370_disabled_C2}
    wts_sim_keywords.UE Deregister should be Successful    ue_id=1
Perform SCF delta for enabling feature flag
    Log To Console    Starting delta_commissioning CB008370_enable
    Perform SCF Delta Commissioning with Delta_CB008370_FlagEnabling_AB2_TC3_LO.json
    sleep  60s
    Log To Console    Done delta_commissioning CB008370_enabled.
Test single UE full traffic with bler and validate new SLIV_Adaptive retransmission for feature flag enabled
    Start log   btslog   cprt
    Intiate Bler for Ues and activate with pktloss     startue=1   endue=1    pkt_loss=60
    ${crnti_list_2}   UE Register should be Successful And Fetch RNTI and TDRA list    ue_id=1     pdu_id=1    nw_id=1
    ...     gw_id=1    8370_flag=1
    Start Multi UE DL traffic with multiple trafficID   start_ue=1   end_ue=1   dl_trf_id=8   qfi_id=1
    Start Multi UE UL traffic with multiple trafficID   start_ue=1   end_ue=1   ul_trf_id=1   qfi_id=1
    Set Suite Variable   ${crnti_list_2}
    ${tput_stats_after_flag}    Wait Until Keyword Succeeds    5x  10sec     Get DL Throughput for Pcell    UE_ID=1    end_UE_ID=1    scell=0
          ...    expected_thp=600
    Run keyword and Continue on Failure    Get UL Throughput for Pcell    UE_ID=1    end_UE_ID=1    scell=0   expected_thp=105
    Set Suite Variable   ${tput_stats_after_flag}
    Stop log   btslog    cprt    test_scenario=DL_data_8370_enabled

    Collect BIP and decode    test_scenario=DL_data_8370_enabled
    Validate BIP with BLER    test_scenario=DL_data_8370_enabled
    Collect TTI trace and check PDSCH SLIVs present    ${LOG_PATH}    ${PDSCH_SLIVs}
    Verify adaptive retransmission from existing tti      TTIpath=${LOG_PATH}/ttitrace_streaming/
    Log To Console    Collecting new and legacy counters....
    ${Cell1M55308C03001_8370_enabled_C1}    ${Cell1M55308C03005_8370_enabled_C2}       ${Cell1M55335C02019_8370_enabled_C3}
    ...    ${Cell1M55335C02020_8370_enabled_C4}    Collect Legacy and New Counters
    Set Suite Variable   ${Cell1M55308C03001_8370_enabled_C1}
    Set Suite Variable   ${Cell1M55308C03005_8370_enabled_C2}
    Set Suite Variable   ${Cell1M55335C02019_8370_enabled_C3}
    Set Suite Variable   ${Cell1M55335C02020_8370_enabled_C4}
    Log To Console      ${Cell1M55308C03001_8370_enabled_C1}      ${Cell1M55308C03005_8370_enabled_C2}
Compare throughput and Legacy Counters
    Log To Console      tput_stats_before_flag= ${tput_stats_before_flag}   tput_stats_after_flag=${tput_stats_after_flag}
    Log To Console      ${Cell1M55308C03001_8370_enabled_C1}    ${Cell1M55308C03001_8370_disabled_C1}
    Log To Console      ${Cell1M55308C03005_8370_enabled_C2}    ${Cell1M55308C03005_8370_disabled_C2}
    Should Be True     ${Cell1M55308C03001_8370_enabled_C1} > ${Cell1M55308C03001_8370_disabled_C1}
    Should Be True     ${Cell1M55308C03005_8370_enabled_C2} > ${Cell1M55308C03005_8370_disabled_C2}
    Should Be True     ${tput_stats_after_flag} > ${tput_stats_before_flag}
Checking new counters are pegging
     Log To Console      ${Cell1M55335C02019_8370_enabled_C3}     ${Cell1M55335C02020_8370_enabled_C4}
     Should Be True     ${Cell1M55335C02019_8370_enabled_C3} > 300000


Collect TTI and verify Adaptive retransmission
    [Arguments]     ${test_scenario}
    log to console     collecting TTI traces
    Start log   ttitrace
    sleep    1s
    ${path_SCN_1}   Stop log    ttitrace    test_scenario=${test_scenario}
    Dated Log        TTI collected at  ${path_SCN_1}
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${test_scenario}/
    Dated Log        converting ttitrace pcap to csv..........at ${tti_path}
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}
    Common Format Tti In Stream Mode       ${tti_path}/output_dl.csv     ${tti_path}/output_dl_formated.csv
    ${result}    check_adaptive_retrans    ${tti_path}/output_dl_formated.csv   CellId=50
    Run Keyword and continue on Failure    Run Keyword if    ${result}!=${True}   Fail   Adaptive retransmission is not matching

Verify adaptive retransmission from existing tti
    [Arguments]    ${TTIpath}
    log to console    checking adaprive retrasmission in ${TTIpath}
     ${result}    check_adaptive_retrans    ${TTIpath}/output_dl_formated.csv   CellId=50
    Run Keyword and continue on Failure    Run Keyword if    ${result}!=${True}   Fail   Adaptive retransmission is not matching
Deactivate BLER profile and verify throughput and legacy counter
     Deactivate Bler for Ues     startue=1    endue=1
     Start Multi UE DL traffic with multiple trafficID   start_ue=1   end_ue=1   dl_trf_id=10   qfi_id=1
     sleep      10s
     ${tput_stats_nobler_withflag}    Wait Until Keyword Succeeds    5x  10sec     Get DL Throughput for Pcell    UE_ID=1    end_UE_ID=1    scell=0
          ...     expected_thp=800
     Set Suite Variable    ${tput_stats_nobler_withflag}
     log to console    tput_stats_nobler_withflag=${tput_stats_nobler_withflag}     tput_stats_after_flag=${tput_stats_after_flag}
     Should Be True     ${tput_stats_nobler_withflag}>${tput_stats_after_flag}
     Run keyword and Continue on Failure    Get UL Throughput for Pcell    UE_ID=1    end_UE_ID=1    scell=0      expected_thp=105
     ${Cell1M55308C03001_8370_noBLER_C1}      ${Cell1M55308C03005_8370_noBLER_C2}      Collect Legacy Counters
     Set Suite Variable    ${Cell1M55308C03001_8370_noBLER_C1}
     Set Suite Variable    ${Cell1M55308C03005_8370_noBLER_C2}
     log to console    Cell1M55308C03001_8370_noBLER_C1=${Cell1M55308C03001_8370_noBLER_C1}
     log to console    Cell1M55308C03005_8370_noBLER_C2=${Cell1M55308C03005_8370_noBLER_C2}
     Should Be True     ${Cell1M55308C03001_8370_noBLER_C1} > ${Cell1M55308C03001_8370_disabled_C1}
     Should Be True     ${Cell1M55308C03005_8370_noBLER_C2} > ${Cell1M55308C03005_8370_disabled_C2}
     Collect BIP and decode    test_scenario=DL_data_8370_enabled
     Validate BIP without BLER   test_scenario=DL_data_8370_enabled

Validate BIP with BLER
    [Arguments]    ${test_scenario}
    ${slot_option}   create list      DLalone     DL_UL    First_DL_after_UL_slot
#   #IWKFeature can be - Empty list , ccesplit_K1opt , actEnhancedPDSCHSchSplSlot , adaptretx
    ${IWKFeature}   create list       adaptretx    actEnhancedPDSCHSchSplSlot
    ${result}    verify_ratematching.check_ratematching    ${LOG_PATH}/${TEST_NAME}/gNB/biptaf/${test_scenario}/${BIP_CSV_NAME}    ${crnti_list_2}
    ...    ${slot_option}   ${RnD_flag}      ${TDD_framestructure}      ${IWKFeature}
#    log to console   ${result}
    Run Keyword if   ${result} !=1   Fail   RateMatching check failed

Validate BIP without BLER
    [Arguments]    ${test_scenario}
    ${slot_option}   create list      DLalone     DL_UL    First_DL_after_UL_slot
#   #IWKFeature can be - Empty list , ccesplit_K1opt , actEnhancedPDSCHSchSplSlot , adaptretx
    ${IWKFeature}   create list       actEnhancedPDSCHSchSplSlot
    ${result}    verify_ratematching.check_ratematching    ${LOG_PATH}/${TEST_NAME}/gNB/biptaf/${test_scenario}/${BIP_CSV_NAME}    ${crnti_list_2}
    ...      ${slot_option}      ${RnD_flag}      ${TDD_framestructure}      ${IWKFeature}
#    log to console   ${result}
    Run Keyword if   ${result} !=1   Fail   RateMatching check failed


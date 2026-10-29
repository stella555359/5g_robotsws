*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED


Documentation
...
...  AUTHOR          :   Sowrabha.S.M
...  MAINTAINER      :   sowrabha.s_m@nokia.com
...  INTRODUCTION    :   CB008370 PDSCH shared with PDCCH in first OFDM symbol
...  TEST SET NAME   :   CB008370-A#B1_TC18_CB008370_IWK_features .Covered IWK with CB009426(RBGrandomization), CB008955(DLInterfernce avoidance)
...                      and CB010359(DLPAwarmup)
...  REFERENCES      :   CB008370-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_24057

Resource         ../../../resources/robot/common_log_collection.robot
Resource         resources/CB008370_resources.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource         ../CB009426/resource/resource_9426_8955.resource
Resource         ../CB008955_CRT/8955_new_resources.robot
Library         resources/verify_ratematching.py
Library         resources/verify_dummyrnti.py


#Suite Setup         Run keywords    Prepare TL with all config files
Suite Setup         Run keywords     Suite setup from scratch
...                 AND       5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_CB009426_CB010359_CB008955.json
...                 AND       Check gNB Bulid
...                 AND        Load CFG and verify cell status   ${wts_cfg_file}    1    4

Test Teardown        Run Keywords    wts_sim_keywords.Clean edaemon and egate
...                 AND     run keyword if test failed    Run Keyword and Ignore Error    Get Snapshot
...                 AND     run keyword if test failed    Run Keyword and Ignore Error    Get Sos Report


*** Variables ***
#${wts_cfg_file}          ${CURDIR}/config/basic_setup_LO.cfg
${wts_cfg_file}          ${CURDIR}/config/basic_ASOH.cfg
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
${SCFC}=        ${CURDIR}/config/SCF/scfc_IWK_8370_9426_8955_10359.xml
${AP_XML}=      ${CURDIR}/config/SCF/iphy_IWK_8370_9426_8955_10359.xml
@{PDSCH_SLIVs}=    ${98}   ${85}   ${57}   ${70}   ${56}   ${43}   ${27}   ${41}   ${55}   ${83}   ${97}
${FILTER_RATE_MATCHING}                 dldata_pdschsendreql1sw&&3gpp.subcellid==0
${FILTER_DUMMY_RNTI}                 dldata_pdcchsendreql1sw&&3gpp.subcellid==0
@{COLUMN_NAME_DUMMY_RNTI}                 3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_PdcchSendReqL1sw_t.startDciIndex
...                      DlData_DciInfoL1sw.startSymbolNumber
...                      DlData_DciInfoL1sw.numOfSymbols    DlData_DciInfoL1sw.aggregationLevel
@{COLUMN_NAME_RATE_MATCHING}                 3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_PdschGrantL1sw.startSymbol
...      DlData_PdschGrantL1sw.numOfPdschSymbols
...                            DlData_PdschGrantL1sw.numOfPrb    DlData_PdschGrantL1sw.startPrb      DlData_PdschGrantL1sw.rateMatchingOption
...                            DlData_PdschGrantL1sw.numRateMatchingRes
${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_SCN1.csv
${RnD_flag}        0
${TDD_framestructure}      1208    #TDD_framestructure can be - 1208 , 1116

*** Test Cases ***
[1][1.0] CB008370-A_#B1_TC18_CB008370_IWK_CB009426_CB010359_CB008955
    [Tags]    QC_27384      QCD_MN_RAN    QCP_RAN_VRF
    set test variable      ${LOG_PATH}
    log to console   Suite setup successful ...
    Attach single UE and start full Data transmission
    Run keyword and Continue on Failure    Verification of the expected thoughput
    Run keyword and Continue on Failure    Collect BIP log   8370_enabled
    Run keyword and Continue on Failure    Verify Dummy RNTI value received for PAWarmpUP feature
    Run keyword and Continue on Failure    Verify Rate Matching for shared PDCCH symbol
    Run keyword and Continue on Failure    Verify IWK features Counters
    Run keyword and Continue on Failure    Reduce Data traffic and verify RBG randomization
    [Teardown]   Run Keywords    wts_sim_keywords.MultiUE Deregister should be Successful    1     1
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting
    ...         AND        wts_sim_keywords.Clean edaemon and egate

*** Keywords ***
Attach single UE and start full Data transmission
    Start log   btslog   cprt
#    sleep     1s
#    Stop log     btslog    cprt   biptaf    ttitrace      test_scenario=DL_data_8370_enabled
    ${crnti_list_1}   UE Register should be Successful And Fetch RNTI and TDRA list    ue_id=1     pdu_id=1    nw_id=1
    ...     gw_id=1    8370_flag=1
    Start Multi UE DL traffic with multiple trafficID   start_ue=1   end_ue=1   dl_trf_id=11   qfi_id=1
    Start Multi UE UL traffic with multiple trafficID   start_ue=1   end_ue=1   ul_trf_id=2   qfi_id=1
    Set Suite Variable   ${crnti_list_1}

Verification of the expected thoughput
    ${tput_stats_before_flag}    Run keyword and Continue on Failure   Get DL Throughput for Pcell    UE_ID=1    end_UE_ID=1    scell=0
    ...      expected_thp=1490
    Run keyword and Continue on Failure    Get UL Throughput for Pcell    UE_ID=1    end_UE_ID=1    scell=0   expected_thp=189
    Stop log   btslog    cprt   test_scenario=DL_data_8370_enabled

Verify IWK features Counters
    Verify 8370 counters
    8955_new_resources.Collect PM Counters
    Get 8955 counters and validate  M55308C10008  M55308C00019

Verify 8370 counters
    ${Cell1M55308C03001_PDSCH_OFDM_SYMB}    ${Cell1M55308C03005_PDSCH_OFDM_SYMB_TIME}       ${Cell1M55335C02019_NUM_1_PDCCH_SYMB_SHARE}
    ...    ${Cell1M55335C02020_NUM_2_PDCCH_SYMB_SHARE}    Collect Legacy and New Counters
    Should Be True     ${Cell1M55335C02019_NUM_1_PDCCH_SYMB_SHARE} > 10000
    Should Be True     ${Cell1M55335C02020_NUM_2_PDCCH_SYMB_SHARE} > 0
    Should Be True     ${Cell1M55308C03001_PDSCH_OFDM_SYMB} > 300000
    Should Be True     ${Cell1M55308C03005_PDSCH_OFDM_SYMB_TIME} > 300000

Collect BIP log
    [Arguments]    ${test_scenario}
    log to console      ${SW_VERSION_TOTAL}
    ${SW_VERSION_TOTAL}     Set Variable      ${GNB_SW_VERSION}
    Set Suite Variable    ${SW_VERSION_TOTAL}
    Start log  biptaf   ttitrace
    sleep    100ms
    ${path_SCN_1}   Stop log   biptaf    ttitrace   test_scenario=${test_scenario}
    Set Suite Variable    ${path_SCN_1}

Verify Dummy RNTI value received for PAWarmpUP feature
    Convert BIP To CSV By MCShark    ${path_SCN_1}[biptaf]/BIP_L1L2.pcap    ${path_SCN_1}[biptaf]/${BIP_CSV_NAME}
    ...                              filter=${FILTER_DUMMY_RNTI}     csv_title_list=${COLUMN_NAME_DUMMY_RNTI}
    ${result}    verify_dummyrnti.check_dummy_rnti     ${path_SCN_1}[biptaf]/${BIP_CSV_NAME}    ${crnti_list_1}
    log to console   ${result}
    Run Keyword if   ${result} !=1   Fail   DUMMY_RNTI check failed     ${IWKFeature}

Verify Rate Matching for shared PDCCH symbol
    Convert BIP To CSV By MCShark    ${path_SCN_1}[biptaf]/BIP_L1L2.pcap    ${path_SCN_1}[biptaf]/${BIP_CSV_NAME}
    ...                              filter=${FILTER_RATE_MATCHING}     csv_title_list=${COLUMN_NAME_RATE_MATCHING}
    ${slot_option}   create list      DLalone     DL_UL     First_DL_after_UL_slot
    ${IWKFeature}   create list       actDlPaWarmUp     ccesplit_K1opt
    ${result}    verify_ratematching.check_ratematching   ${path_SCN_1}[biptaf]/${BIP_CSV_NAME}   ${crnti_list_1}    ${slot_option}   ${RnD_flag}
    ...     ${TDD_framestructure}      ${IWKFeature}
    Run Keyword if   ${result} !=1   Fail   RateMatching check failed     ${IWKFeature}

Reduce Data traffic and verify RBG randomization
    FOR   ${trf_id}   IN RANGE   1    11
    wts_sim_keywords.TRF Data Stop for SA    ue_id=1    pdu_id=1    dir=dl    trf_id=${trf_id}
    END
    Sleep    30s
    Run keyword and Continue on Failure   Get DL Throughput for Pcell    UE_ID=1    end_UE_ID=1    scell=0      expected_thp=170
    Run keyword and Continue on Failure   Capture TTI trace and verify RBG Randomization    ${LOG_PATH}   DL_data_8370_enabled    ${crnti_list_1}
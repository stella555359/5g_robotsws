*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED


Documentation
...
...  AUTHOR          :   prapulla.bt@nokia.com
...  MAINTAINER      :   prapulla.bt@nokia.com
...  INTRODUCTION    :   CB008370 PDSCH shared with PDCCH in first OFDM symbol
...  TEST SET NAME   :   CB008370_A_Feature activation for single UE
...  REFERENCES      :   CB008370-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_24057

Resource         ../resources/robot/common_log_collection.robot
Resource         ./resources/CB008370_resources.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Resource         ../CB011114/resources/CB011114_common_resources.robot
Library          ../CB008927/python/adaptive_retx.py
Library         ./resources/verify_ratematching.py
Library         ./resources/verify_dummyrnti.py

Suite Setup         Run keywords     Suite setup from scratch
...                 AND       5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_MRBTS_ASOH.json
...                 AND       Update GNB R&D Parameter
...                 AND       gnb.Perform gNB reboot
...                 AND       Sleep   500s    reason=wait for RMOD to comeup
...                 AND       Check gNB Bulid
...                 AND       Load CFG and verify cell status   ${wts_cfg_file}    1    4


Test Teardown    Run Keywords        wts_sim_keywords.Clean edaemon and egate
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Link SCOUT SCF to Configuration ID for Reporting



*** Variables ***
#${wts_cfg_file}        ${WTS_DIR}/basic_setup.cfg
${wts_cfg_file}          ${CURDIR}/config/basic_ASOH.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${r&d_parameter}       0x58085c=1
${nwslice_ID}   1
${pdu_id}     1
${UE_ID}     1
${nw_id}     1
${gw_id}       1
${Pdu_session_ID}       1
${QFI_ID}     1
${start_ueid}   1
${start_ue}   1
${end_ue}   1
${st_ue_id}   1
${en_ue_id}   1
${end_ueid}     1
${nsa_ue_id}    101
${nsa_trf_id}     1
${QFI_ID1}     1
${TRF_ID1}     1
${TRF_ID}     1
${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_SCN1.csv
@{PDSCH_SLIVs}=    ${98}   ${85}   ${57}   ${70}   ${56}   ${43}   ${27}   ${41}   ${55}   ${83}   ${97}
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_PdschGrantL1sw.startSymbol
...                            DlData_PdschGrantL1sw.numOfPdschSymbols
...                            DlData_PdschGrantL1sw.numOfPrb    DlData_PdschGrantL1sw.startPrb
...                            DlData_PdschGrantL1sw.rateMatchingOption    DlData_PdschGrantL1sw.numRateMatchingRes
@{COLUMN_NAME_DCI}             3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_PdcchSendReq_tL1sw.startDciIndex
...                            DlData_DciInfoL1sw.startSymbolNumber
...                            DlData_DciInfoL1sw.numOfSymbols    DlData_DciInfoL1sw.aggregationLevel
${FILTER_B003}                 dldata_pdschsendreql1sw&&3gpp.subcellid==0
${RnD_flag}        1
${TDD_framestructure}      1208    #TDD_framestructure can be - 1208 , 1116



*** Test Cases ***
[1]CB008370_A_B1_TC2_Activation_of_the_feature_for_single_UE_in_good_radio_conditions_rdUseDAfterUForPdcchSharingTdd
    set test variable      ${LOG_PATH}
    Make singleUE SA call and collect ttitrace
	CB011114_common_resources.Perform SCF Delta Commissioning with Delta_Configuration_scf_8370.json
    sleep  5s
	Make 8370_enable singleUE SA call and collect ttitrace
	Compare throughput and Legacy Counters
	Checking new counters are pegging

*** Keywords ***

Update GNB R&D Parameter
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

Make singleUE SA call and collect ttitrace
    Start log   btslog   cprt
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    ${crnti_list_1}   UE Register should be Successful And Fetch RNTI and TDRA list    ue_id=1     pdu_id=1    nw_id=1
    ...     gw_id=1    8370_flag=0
    Set Suite Variable   ${crnti_list_1}
    Sleep   2s
    Start Multi UE DL traffic with multiple trafficID    start_ue=${st_ue_id}   end_ue=${en_ue_id}    dl_trf_id=9    qfi_id=1
    sleep    30s
	wts_sim_keywords.MultiUE Trigger UL Traffic for SA    ${start_ue}   ${end_ue}  Traffic_rate=mbps     ul_rate=10    pdu_id=1
    ...    trf_id=${TRF_ID}    qfi_id=${qfi_id}
    sleep    2s
	${tput_stats_before_flag}     Get DL Throughput for Pcell    UE_ID=1    end_UE_ID=1    scell=0      expected_thp=1300
	Set Suite Variable   ${tput_stats_before_flag}
	Stop log   btslog    cprt   test_scenario=DL_data_8370_disabled
    #Collect TTI trace and check PDSCH SLIVs present
    Run Keyword And Continue On Failure    Collect BIP and decode     test_scenario=DL_data_8370_disabled
    #Counter check
    ${Cell1M55308C03001_8370_disabled_C1}      ${Cell1M55308C03005_8370_disabled_C2}      Collect Legacy Counters
    Set Suite Variable   ${Cell1M55308C03001_8370_disabled_C1}
    Set Suite Variable   ${Cell1M55308C03005_8370_disabled_C2}
    Log To Console      ${Cell1M55308C03001_8370_disabled_C1}       ${Cell1M55308C03005_8370_disabled_C2}
    wts_sim_keywords.Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    wts_sim_keywords.MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

Make 8370_enable singleUE SA call and collect ttitrace
	log to console   UE attach trigerring now...
	Start log   btslog   cprt
    Wait until the next Measurement Period starts  additional_time=${0}
    ${crnti_list_2}   UE Register should be Successful And Fetch RNTI and TDRA list    ue_id=1     pdu_id=1    nw_id=1
    ...     gw_id=1    8370_flag=1
    Set Suite Variable   ${crnti_list_2}
    Sleep   2s
	Start Multi UE DL traffic with multiple trafficID    start_ue=${st_ue_id}   end_ue=${en_ue_id}    dl_trf_id=9    qfi_id=1
    sleep    30s
	wts_sim_keywords.MultiUE Trigger UL Traffic for SA    ${start_ue}   ${end_ue}  Traffic_rate=mbps     ul_rate=10    pdu_id=1
    ...    trf_id=${TRF_ID}    qfi_id=${qfi_id}
    sleep    2s
	${tput_stats_after_flag}     Get DL Throughput for Pcell    UE_ID=1    end_UE_ID=1    scell=0      expected_thp=1300
	Set Suite Variable   ${tput_stats_after_flag}
    Stop log   btslog    cprt    test_scenario=DL_data_8370_enabled
    #Collect TTI trace and check PDSCH SLIVs present
    sleep      5s
    Run Keyword And Continue On Failure    Collect BIP and decode    test_scenario=DL_data_8370_enabled
    Run Keyword And Continue On Failure    Validate BIP     test_scenario=DL_data_8370_enabled
    Run keyword and Continue on Failure    Collect TTI trace and check PDSCH SLIVs present    ${LOG_PATH}    ${PDSCH_SLIVs}
	#Counter check
    Log To Console    Collecting new and legacy counters....
    ${Cell1M55308C03001_8370_enabled_C1}    ${Cell1M55308C03005_8370_enabled_C2}       ${Cell1M55335C02019_8370_enabled_C3}
    ...    ${Cell1M55335C02020_8370_enabled_C4}    Collect Legacy and New Counters
    Set Suite Variable   ${Cell1M55308C03001_8370_enabled_C1}
    Set Suite Variable   ${Cell1M55308C03005_8370_enabled_C2}
    Set Suite Variable   ${Cell1M55335C02019_8370_enabled_C3}
    Set Suite Variable   ${Cell1M55335C02020_8370_enabled_C4}
    Log To Console      ${Cell1M55308C03001_8370_enabled_C1}      ${Cell1M55308C03005_8370_enabled_C2}
    wts_sim_keywords.Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    wts_sim_keywords.MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

Validate BIP
    [Arguments]    ${test_scenario}
    ${slot_option}   create list      DLalone     DL_UL    First_DL_after_UL_slot
    ${IWKFeature}   create list       ccesplit_K1opt
    ${result}    verify_ratematching.check_ratematching    ${LOG_PATH}/${TEST_NAME}/gNB/biptaf/${test_scenario}/${BIP_CSV_NAME}    ${crnti_list_1}
    ...    ${slot_option}   ${RnD_flag}      ${TDD_framestructure}      ${IWKFeature}
    Run Keyword if   ${result} !=1   Fail   RateMatching check failed


Compare throughput and Legacy Counters
    Log To Console      tput_stats_before_flag= ${tput_stats_before_flag}   tput_stats_after_flag=${tput_stats_after_flag}
    Log To Console      ${Cell1M55308C03001_8370_enabled_C1}    ${Cell1M55308C03001_8370_disabled_C1}
    Log To Console      ${Cell1M55308C03005_8370_enabled_C2}    ${Cell1M55308C03005_8370_disabled_C2}
    Should Be True     ${Cell1M55308C03001_8370_enabled_C1} > ${Cell1M55308C03001_8370_disabled_C1}
    Should Be True     ${Cell1M55308C03005_8370_enabled_C2} > ${Cell1M55308C03005_8370_disabled_C2}
    Should Be True     ${tput_stats_after_flag} > ${tput_stats_before_flag}
Checking new counters are pegging
     Log To Console      ${Cell1M55335C02019_8370_enabled_C3}     ${Cell1M55335C02020_8370_enabled_C4}
     Should Be True     ${Cell1M55335C02019_8370_enabled_C3} > 200000


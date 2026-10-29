*** Settings ***
Force Tags        CLOUD_5G_E_H_AP_LO0    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED


Documentation
...
...  AUTHOR          :   mary.thomas@nokia.com
...  MAINTAINER      :   mary.thomas@nokia.com
...  INTRODUCTION    :   CB008370 PDSCH shared with PDCCH in first OFDM symbol
...  TEST SET NAME   :   [1]CB008370_A_Paging_Handover
...  REFERENCES      :   CB008370-CFAM

Suite Setup   Run Keywords        ADMIN Setup Admin
...                 AND      ADMIN Get Current SCF File    ${CURDIR}    default_scf.xml
...                 AND     ADMIN Teardown Admin

Resource         ./resources/CB008370_resources.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Resource         ../resources/robot/BBpooling_MuMIMO.robot
Library          ./resources/verify_srsSwitch.py
Library          ./resources/verify_aggregationlevel.py
Resource         ../resources/robot/common_log_collection.robot
Resource         ../CB009426/resource/resource_9426_8955.resource
Resource         ../CB008955_CRT/8955_new_resources.robot
Library          ./resources/verify_ratematching.py
Library          ./resources/verify_dummyrnti.py
Resource         testsuite/Bangalore/RRM/5GET_BLR/CB008225/resources/CB008225_resource.robot
Library         ute_wtssim

*** Variables ***
${wts_cfg_file}       ${CURDIR}/config/basic_ASOH.cfg
${wts_cfg_file1}      ${CURDIR}/../CB009842/config/ASOH_basic.cfg
${wts_cfg_file2}      ${CURDIR}/../CB009842/config/basic_setup_10784.cfg
${WTS_DIR}            /opt/iphy/latest
&{WTS}                Ip=127.0.0.1        Username=ute         Connection=Wts
${gw_ID}           1
${trf_id}          1
${QFI_ID}          1
${UE_ID}           1
${start_ueid}      1
${end_ueid}        1
${nsa_ue_id}       101
${nwslice_ID}      1
${Pdu_session_ID}  1
${RnD_flag}        0
${r&d_parameter}   0x58085c=1
@{PDSCH_SLIVs}=    ${41}    ${27}    ${83}    ${98}    ${97}    ${69}    ${55}
${BSR_SW_FILE}     BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001.zip
${AP_XML}=               ${CURDIR}/config/SCF/iphy_robust.xml
${FILTER_B005}           dldata_pdcchsendreql1sw&&3gpp.subcellid==0
${TDD_framestructure}    1208    #TDD_framestructure can be - 1208 , 1116
@{COLUMN_NAME_DCI}       3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_PdcchSendReqL1sw_t.startDciIndex   DlData_DciInfoL1sw.startSymbolNumber
...                      DlData_DciInfoL1sw.numOfSymbols    DlData_DciInfoL1sw.aggregationLevel
${BIP_CSV_NAME}          BIP_L1L2.pcap_filter_SCN1.csv
${BIP_CSV_NAME1}               BIP_L1L2.pcap_filter_SCN2.csv
@{PDSCH_SLIV2s}=    ${98}   ${85}   ${57}   ${70}   ${56}   ${43}   ${27}   ${41}   ${55}   ${83}   ${97}

@{QOS_Prof1}               1     #5QI 6
@{QOS_Prof1_speed_dl}      30
@{QOS_Prof1_speed_ul}      15
@{QOS_Prof1_unit}          mbps
${delta}       30
${inactivity_timer}      60
${BTS_ADDRESS}    192.168.255.1
${BTS_PORT}       443
${USE_SSL}        True
${SCF_Path}    SCF_DU_Setup.xml
${pysical_cell_ids}    50
${SCFC}=        ${CURDIR}/../CB009842/config/SCF/ASOH_Configuration_scf_MRBTS-1_2_16_UTE5GCLASSICAL1622_20240625-1317.xml
${UE_LIST}                 56    57    58    59    60
${EXPECTED_TA_LIST}        112    64    112   64    112
${CAPTURE_FOLDER}        [cprt]/NODECPRT_GNB.pcap
${Target_Cells}    3
${start_1ues_id}    51
${end_1ues_id}      55
${start_2ndue_id}    56
${end_2ndue_id}     60
${ul_rate}      15
${dl_rate}     30
${NSA_Start_ue}    151
${NSA_END_ue}       152

*** Test Cases ***
[1][1.0] CB008370-A_#B1_TC18_CB008370_IWK_CB009426_CB010359_CB008955
    [Setup]    Run keywords      Suite setup from scratch
    ...                 AND      5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_CB009426_CB010359_CB008955.json
    ...                 AND      Check gNB Bulid
    ...                 AND      Load CFG and verify cell status   ${wts_cfg_file}    1    4
    [Tags]    QC_27384      QCD_MN_RAN    QCP_RAN_VRF   TC01
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    log to console   Suite setup successful ...
    Attach single UE and start full Data transmission
    Run keyword and Continue on Failure    Verification of the expected thoughput
    Run keyword and Continue on Failure    Collect BIP log   8370_enabled
    Run keyword and Continue on Failure    Verify Dummy RNTI value received for PAWarmpUP feature
    Run keyword and Continue on Failure    Verify Rate Matching for shared PDCCH symbol
    Run keyword and Continue on Failure    Verify IWK features Counters
    Run keyword and Continue on Failure    Reduce Data traffic and verify RBG randomization
    wts_sim_keywords.MultiUE Deregister should be Successful    1     1
    5GC000937_Keywords.Perform SCF Delta Commissioning with TC18_delta_disable.json
    [Teardown]   Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...         AND        wts_sim_keywords.Clean edaemon and egate
    ...         AND        Run Keyword If Test Failed   Run Keyword and ignore error  Stop Log    btslog    cprt    biptaf

[1]CB008370_TC17_robustness_IWK_CB008322
    [Setup]    Run Keywords      Suite setup from scratch
    ...                 AND      Prepare TL with IPHY file change
    ...                 AND      5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_configuration_robust_8322.json
    ...                 AND      5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_configuration_BSR_Package.json
    ...                 AND      5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_configuration_scf_srs.json
    ...                 AND       Get and Update BSR SW via gitlab   ${BSR_SW_FILE}
    ...                 AND       Check gNB Bulid
    ...                 AND       Configure eth3 IP
    #...                 AND       gnb.Perform gNB reboot
    #...                 AND       Sleep   500s    reason=wait for RMOD- to comeup
    ...                 AND       Load CFG and verify cell status   ${wts_cfg_file}    1    4
    [Tags]      TC02
    [Documentation]      Cell#1 with CB008370 enabled and cell#2 with CB008370 disabled
    ...                  This script validates the below scenarios with 8370 enabled :
    ...                  UE Paging
    ...                  UE attach to 8370 enabled cell, here SLIV values, throughput and counters are validated
    ...                  HO is triggered to cell#2 (8370_disabled). Here throughput and counters are collected
    ...                  DL Cell throughput in Cell#1 should be higher compared to Cell#2
    ...                  Then Cell_lock and unlock is triggered for 5 times
    ...                  UE switching between SB and WB , IWK_8322
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Attach UE and wait for UE to move to IDLE      ${start_ueid}      ${end_ueid}
    Start Data for UE and validate Paging is successful and validate throughput and logs
    ${DL_THP_8370_disabled}      Trigger HO to neighbourcell and validate counters    start_ueid=${start_ueid}    end_UE_ID=${end_ueid}
    ...      cell_id=51      scell=0
    Set Suite Variable   ${DL_THP_8370_disabled}
    Compare counters and throughput between cell1 and cell2
    Log To Console      Triggering HO_back
    ${DL_THP_8370_enabled}      Trigger HO to neighbourcell and validate counters    start_ueid=${start_ueid}    end_UE_ID=${end_ueid}
    ...     cell_id=50      scell=0
    Should Be True    ${DL_THP_8370_enabled} > (${DL_THP_8370_disabled})
    Deregister ALL Ues   start_ue=${start_ueid}   end_ue=${end_ueid}
    Trigger UE atatch and Verify UE switch between SB and WB
    Trigger cell lock and unlock along with UE attach and start maximum data and validate ratematching from logs
    Simulate cqi reduction and validate the aggregation level selected      ${start_ueid}      ${end_ueid}
    BuiltIn.Set Test Variable    ${SCFC}    ${CURDIR}/default_scf.xml
    [Teardown]     Run Keywords        wts_sim_keywords.Clean edaemon and egate
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...                 AND     Run Keyword If Test Failed   Run Keyword and ignore error  Stop Log    btslog    cprt    biptaf
    ...                 AND     Prepare TL with SCF change

[1]CB008370_A_B1_TC2_Activation_of_the_feature_for_single_UE_in_good_radio_conditions_rdUseDAfterUForPdcchSharingTdd
    [Tags]     TC03
    [Setup]      Run Keywords     Suite setup from scratch
    ...                 AND       BuiltIn.Set Suite Variable   ${RnD_flag}        1
    ...                 AND       5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_MRBTS_ASOH.json
    ...                 AND       Update GNB R&D Parameter
    ...                 AND       gnb.Perform gNB reboot
    ...                 AND       Sleep   500s    reason=wait for RMOD to comeup
    ...                 AND       Check gNB Bulid
    ...                 AND       Load CFG and verify cell status   ${wts_cfg_file}    1    4
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    Make singleUE SA call and collect ttitrace
	5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_8370.json
    sleep  5s
	Make 8370_enable singleUE SA call and collect ttitrace
	Compare throughput and Legacy Counters
	Checking new counters are pegging
    [Teardown]     Run Keywords        wts_sim_keywords.Clean edaemon and egate
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...                 AND     Run Keyword and Ignore Error    Get Sos Report
    ...                 AND     Run Keyword If Test Failed   Run Keyword and ignore error  Stop Log    btslog    cprt    biptaf

[1][1.0] CB009842_10_Successful_E-CID_Meas_Rep_for_NR-TADV_Meas_Quan_after_UE_is_INACT_mode_&_moving_make_RLF_failure_in_the_FDD
    [Tags]    QC_349712      QCD_MN_RAN    QCP_RAN_ET  TC04
    [Setup]     Run keywords    BuiltIn.Set Suite Variable   ${AP_XML}    ${CURDIR}/../CB009842/config/SCF/ASOH_iphy.xml
    ...                 AND   Prepare TL with all config files
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     WTS_Runner_Keywords.Start WTS Using WTS_Runner      ${wts_cfg_file1}
    ...					AND		sleep	60s
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary    ${51}=${QOS_Prof1}     ${52}=${QOS_Prof1}      ${53}=${QOS_Prof1}
    ...   ${54}=${QOS_Prof1}     ${55}=${QOS_Prof1}   ${56}=${QOS_Prof1}     ${57}=${QOS_Prof1}    ${58}=${QOS_Prof1}
    ...   ${59}=${QOS_Prof1}     ${60}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${51}=${QOS_Prof1_speed_ul}      ${52}=${QOS_Prof1_speed_ul}
    ...    ${53}=${QOS_Prof1_speed_ul}     ${54}=${QOS_Prof1_speed_ul}     ${55}=${QOS_Prof1_speed_ul}
    ...    ${56}=${QOS_Prof1_speed_ul}     ${57}=${QOS_Prof1_speed_ul}
    ...    ${58}=${QOS_Prof1_speed_ul}     ${59}=${QOS_Prof1_speed_ul}     ${60}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${51}=${QOS_Prof1_speed_dl}      ${52}=${QOS_Prof1_speed_dl}
    ...    ${53}=${QOS_Prof1_speed_dl}     ${54}=${QOS_Prof1_speed_dl}    ${55}=${QOS_Prof1_speed_dl}
    ...    ${56}=${QOS_Prof1_speed_dl}     ${57}=${QOS_Prof1_speed_dl}
    ...    ${58}=${QOS_Prof1_speed_dl}     ${59}=${QOS_Prof1_speed_dl}    ${60}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${51}=${QOS_Prof1_unit}      ${52}=${QOS_Prof1_unit}
    ...    ${53}=${QOS_Prof1_unit}     ${54}=${QOS_Prof1_unit}     ${55}=${QOS_Prof1_unit}
    ...    ${56}=${QOS_Prof1_unit}      ${57}=${QOS_Prof1_unit}
    ...    ${58}=${QOS_Prof1_unit}     ${59}=${QOS_Prof1_unit}     ${60}=${QOS_Prof1_unit}
    ${cnai}        Create Dictionary          ${51}=on     ${52}=on     ${53}=on     ${54}=on     ${55}=on
    ...    ${56}=on     ${57}=on     ${58}=on     ${59}=on     ${60}=on
    ${state}       Create Dictionary          ${51}=inactive     ${52}=inactive    ${53}=inactive
    ...    ${54}=inactive     ${55}=inactive    ${56}=inactive     ${57}=inactive    ${58}=inactive
    ...    ${59}=inactive     ${60}=inactive
    ${state_NSA}       Create Dictionary          ${151}=inactive     ${152}=inactive    ${153}=inactive
    ...    ${154}=inactive
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}

    X2AP Link Should be UP
    Attach UE and start low data     ${NSA_Start_ue}     ${NSA_END_ue}
    Sleep    40s
    Validate DL Traffic For MultiUE for NSA    ${NSA_Start_ue}   ${NSA_END_ue}     ${dl_rate}    2
    Validate UL Traffic For MultiUE for NSA    ${NSA_Start_ue}   ${NSA_END_ue}     ${ul_rate}     2
    Sleep    30s
    Start Log    btslog    cprt    biptaf
    wtsrunner.ue_ta_nr  profile_id=51    ue_p_delay_initial=100
    wtsrunner.ue_testmode_set_nr    id=51    testmode=ta    action=activate    profile_id=51
    ${ue_to_bearer_list}=      MultiUE Register should be Successful with CNAI     ${51}    ${55}     cnai=${cnai}
    Start Data Transfer      ${51}     ${55}   1600   both   ${1}  ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=51    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
     sleep   ${delta}s
    Validate DL Traffic For MultiUE for SA     ${start_1ues_id}    ${end_1ues_id}     ${dl_rate}
    ...    ${Pdu_session_ID}      ${QFI_ID}
    Validate UL Traffic For MultiUE for SA    ${start_1ues_id}    ${end_1ues_id}     ${ul_rate}
    ...    ${Pdu_session_ID}      ${QFI_ID}
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${51}    ${55}     ${qos_profile}
    ...    state=${state}
    sleep   60s
    ${scen1}    Stop Log    btslog    cprt    biptaf    test_scenario=scen1
#
    log to console   checking for TA value...
    CheckTAValue    ${scen1}[cprt]/NODECPRT_GNB.pcap      112
    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State        ${51}     ${55}        state=${state}
    ${inactivity_timer_cal}        Verify Inactivity Timer         ${51}    ${55}           ${state}
         ...      ${inactivity_start}        ${inactivity_stop}        ${delta}        ${inactivity_timer}
    Start Log    cprt      biptaf
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=51    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
    sleep   60s
    ${attach}    Stop Log    btslog    cprt    biptaf    test_scenario=attach
    log to console   checking for TA value...
    CheckTAValue    ${attach}[cprt]/NODECPRT_GNB.pcap      112
    sleep    60s
    Start Data Transfer    ${51}    ${55}   1600   dl    ${1}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}

    Validate DL Traffic For MultiUE for NSA     ${NSA_Start_ue}    ${NSA_END_ue}     ${dl_rate}     2
    Validate UL Traffic For MultiUE for NSA     ${NSA_Start_ue}    ${NSA_END_ue}     ${ul_rate}      2

    ${ue_ids}=    Create List    56    57   58    59     60
    ${ta_delays}=    Create List    100     50     100    50    100
    ${expected_ta_vals}=    Create List    112    64    112    64    112

    &{qos_profile_multiue}=    Create Dictionary    56=1    57=1    58=1     59=1    60=1
    &{qos_profile_unit_multiue}=    Create Dictionary    56=mbps    57=mbps    58=mbps     59=mbps     60=mbps
    &{qos_profile_speed_ul_multiue}=    Create Dictionary    56=15    57=15    58=15    59=15    60=15
    &{qos_profile_speed_dl_multiue}=    Create Dictionary    56=30    57=30    58=30    59=30    60=30
#    ${state}=    Set Variable    RRC_INACTIVE
#    ${delta}=    Set Variable    5

    ECID TA Validation For Multiple UEs
    ...    ${ue_ids}    ${ta_delays}    ${expected_ta_vals}
    ...    ${qos_profile_multiue}    ${qos_profile_unit_multiue}    ${qos_profile_speed_ul_multiue}    ${qos_profile_speed_dl_multiue}
    ...    ${cnai}

    ${qos_profile}               Create Dictionary      ${56}=${QOS_Prof1}     ${57}=${QOS_Prof1}    ${58}=${QOS_Prof1}
    ...   ${59}=${QOS_Prof1}     ${60}=${QOS_Prof1}

    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${56}    ${60}     ${qos_profile}
    ...    state=${state}
    sleep   60s
    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State        ${56}     ${60}        state=${state}
    ${inactivity_timer_cal}        Verify Inactivity Timer         ${56}    ${60}           ${state}
         ...      ${inactivity_start}        ${inactivity_stop}        ${delta}        ${inactivity_timer}
    sleep   10s

    Start Log    cprt      biptaf
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=56    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
    sleep   60s
    ${56th_inactive_attach}    Stop Log    btslog    cprt    biptaf    test_scenario=56th_inactive_attach
    log to console   checking for TA value...
    CheckTAValue    ${56th_inactive_attach}[cprt]/NODECPRT_GNB.pcap      112
    sleep    60s

	Start Log    cprt      biptaf
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=57    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
    sleep   60s
    ${57th_inactive_attach}    Stop Log    btslog    cprt    biptaf    test_scenario=57th_inactive_attach
    log to console   checking for TA value...
    CheckTAValue    ${57th_inactive_attach}[cprt]/NODECPRT_GNB.pcap      64
    sleep    60s

	Start Log    cprt      biptaf
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=58    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
    sleep   60s
    ${58th_inactive_attach}    Stop Log    btslog    cprt    biptaf    test_scenario=58th_inactive_attach
    log to console   checking for TA value...
    CheckTAValue    ${58th_inactive_attach}[cprt]/NODECPRT_GNB.pcap      112
    sleep    60s

	Start Log    cprt      biptaf
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=59    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
    sleep   60s
    ${59th_inactive_attach}    Stop Log    btslog    cprt    biptaf    test_scenario=59th_inactive_attach
    log to console   checking for TA value...
    CheckTAValue    ${59th_inactive_attach}[cprt]/NODECPRT_GNB.pcap      64

    Start Log    cprt      biptaf
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=60    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
    sleep   60s
    ${60th_inactive_attach}    Stop Log    btslog    cprt    biptaf    test_scenario=60th_inactive_attach
    log to console   checking for TA value...
    CheckTAValue    ${60th_inactive_attach}[cprt]/NODECPRT_GNB.pcap      112

    WTS_Runner_Keywords.MultiUE Deregister should be Successful     55     60

    Start Log    cprt      biptaf
    sleep    10s
    wtsrunner.ue_ta_nr     profile_id=51     ue_p_delay_initial=50
    wtsrunner.ue_rrc_reestablish     id=51     gnb=2     cell=3     cause=reconfigurationFailure
    sleep    10s
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=51    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
    sleep    60s
    ${delay}    Stop Log    btslog    cprt    biptaf    test_scenario=delay
    log to console   checking for TA value...
    CheckTAValue    ${delay}[cprt]/NODECPRT_GNB.pcap     64
    sleep    30s
    Validate DL Traffic For MultiUE for SA     ${start_1ues_id}    ${end_1ues_id}     ${dl_rate}
    ...    ${Pdu_session_ID}      ${QFI_ID}
    Validate UL Traffic For MultiUE for SA    ${start_1ue_id}    ${end_1ue_id}     ${ul_rate}
    ...    ${Pdu_session_ID}      ${QFI_ID}
    sleep    20s
     WTS_Runner_Keywords.Stop Data Traffic for SA     ue_id=51
     WTS_Runner_Keywords.UE Deregister should be Successful    ue_id=51
    [Teardown]   Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND      Check resource hanging
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND     Run Keyword If Test Failed   Run Keyword and ignore error  Stop Log    btslog    cprt    biptaf
#
[1]CB009842_19_Successful_ECID_Measurement_Reporting_for_UEs_in_RingCelldeployment_without_any_3rdpartyDAS_with_addExtDelayCompensation_1
    [Tags]   TC05
    [Setup]    Run Keywords  BuiltIn.Set Suite Variable   ${SCFC}    ${CURDIR}/../CB009842/config/SCF/CB010784_prach_148_addExtDelay_1_4DL2UL.xml
    ...   AND  BuiltIn.Set Suite Variable    ${AP_XML}      ${CURDIR}/../CB009842/config/SCF/AQQL_iphy.xml
    ...   AND    Prepare TL with all config files
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     Verify NR of Downlink Symbols      ${wts_cfg_file2}
    ...                 AND     ADMIN Setup Admin       alias=admin
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log    btslog    cprt    biptaf
    Verify Guard Period Lengh    expected_value=2Symbols
    wtsrunner.ue_ta_nr  profile_id=1    ue_p_delay_initial=100
    wtsrunner.ue_testmode_set_nr    id=1    testmode=ta    action=activate    profile_id=1
    WTS_Runner_Keywords.UE Register should be Successful     ue_id=${UE_ID}
    WTS_Runner_Keywords.Trigger DL Data Traffic for SA    ue_id=1    Traffic_rate=mbps     dl_rate=100       trf_id=1
    WTS_Runner_Keywords.Trigger UL Data Traffic for SA    ue_id=1    Traffic_rate=mbps     ul_rate=100       trf_id=2
    Sleep    30s
    WTS_Runner_Keywords.Validate DL Traffic For SA   ue_id=1     dl_rate=100     qfi_id=1
    WTS_Runner_Keywords.Validate UL Traffic For SA   ue_id=1     ul_rate=100     qfi_id=1
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=1    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
    ${attach}    Stop Log    btslog    cprt    biptaf    test_scenario=attach
    log to console   checking for TA value...
    CheckTAValue    ${attach}[cprt]/NODECPRT_GNB.pcap      116
    Trigger RLF failure and Verify TAdv
    WTS_Runner_Keywords.Stop Data Traffic for SA     ue_id=1
    WTS_Runner_Keywords.UE Deregister should be Successful   ue_id=1
    [Teardown]   Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND     Run Keyword If Test Failed   Run Keyword and ignore error  Stop Log    btslog    cprt    biptaf


*** Keywords ***

Attach UE and start low data                    ###nsa
    [Arguments]   ${Start_ue}   ${End_ue}
    FOR   ${UE}   IN RANGE   ${Start_ue}   ${End_ue}+${1}
        LTE Attach should be Successful    NSA_UE_ID=${UE}
        UE Attach should be Successful_cell1   NSA_UE_ID=${UE}
        Sleep    2s
        WTS_Runner_Keywords.Trigger DL Traffic for NSA    ue_id=${UE}     Traffic_rate=mbps     dl_rate=30       trf_id=1
        WTS_Runner_Keywords.Trigger UL Traffic for NSA    ue_id=${UE}     Traffic_rate=mbps     ul_rate=15       trf_id=1
    END

Validate DL Traffic For MultiUE for NSA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${NSA_Start_ue}   ${NSA_END_ue}     ${dl_rate}    ${id}
    FOR     ${ue_idx}   IN RANGE    ${NSA_Start_ue}    ${NSA_END_ue}+1
    wtsrunner.bearer_stats  ue=${ue_idx}   id=${id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    WTS_Runner_Keywords.Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    WTS_Runner_Keywords.Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}
    END

Validate UL Traffic For MultiUE for NSA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${NSA_Start_ue}   ${NSA_END_ue}       ${ul_rate}    ${id}
    FOR     ${ue_idx}   IN RANGE    ${NSA_Start_ue}    ${NSA_END_ue}+1

    wtsrunner.bearer_stats  ue=${ue_idx}   id=${id}      dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    WTS_Runner_Keywords.Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    WTS_Runner_Keywords.Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}
    END

Validate UL Traffic For MultiUE for SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${start_ue_id}   ${end_ue_id}       ${ul_rate}    ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1

    wtsrunner.bearer_stats  ue=${ue_idx}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    WTS_Runner_Keywords.Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    WTS_Runner_Keywords.Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}
    END

Validate DL Traffic For MultiUE for SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${start_ue_id}   ${end_ue_id}     ${dl_rate}    ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.bearer_stats  ue=${ue_idx}   pdu=${pdu_id}   qfi=${qfi_id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    WTS_Runner_Keywords.Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    WTS_Runner_Keywords.Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}
   	END

UE Attach should be Successful_cell1
    [Arguments]    ${NSA_UE_ID}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${NSA_UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${Timeout_NSA}
    [Return]      ${output}


ECID TA Validation For Multiple UEs
    [Arguments]    ${ue_ids}    ${ta_delays}    ${expected_ta_vals}
    ...    ${qos_profile}    ${qos_profile_unit}    ${qos_profile_speed_ul}    ${qos_profile_speed_dl}
    ...    ${cnai}

    # Set TA and Activate Test Mode
    ${length}=    Get Length    ${ue_ids}
    FOR    ${i}    IN RANGE    ${length}
        ${ue}=    Get From List    ${ue_ids}    ${i}
        ${delay}=    Get From List    ${ta_delays}    ${i}
        wtsrunner.ue_ta_nr    profile_id=${ue}    ue_p_delay_initial=${delay}
        wtsrunner.ue_testmode_set_nr    id=${ue}    testmode=ta    action=activate    profile_id=${ue}
    END

    # Register UEs and Start Data Transfer
    ${start_id}=    Get From List    ${ue_ids}    0
    ${end_id}=    Get From List    ${ue_ids}    -1
    ${ue_to_bearer_list}=    MultiUE Register should be Successful with CNAI    ${start_id}    ${end_id}    cnai=${cnai}
    FOR    ${i}    IN RANGE    ${length}
        ${ue}=    Get From List    ${ue_ids}    ${i}
        ${unit}=    Get From Dictionary    ${qos_profile_unit}    ${ue}
        ${dl_speed}=    Get From Dictionary    ${qos_profile_speed_dl}    ${ue}
        ${ul_speed}=    Get From Dictionary    ${qos_profile_speed_ul}    ${ue}
        ${qfi}=    Get From Dictionary    ${qos_profile}    ${ue}
        ${trf_id}=    Set Variable    1
        @{qfi_list}=    Create List    ${qfi}
        CB008225_basic_keywords.UE Trigger Traffic for SA QFI Based    ${ue}    Traffic_rate=${unit}    data_rate=${dl_speed}
        ...    dir=dl    pdu_id=1    trf_id=${trf_id}    qfi_id=@{qfi_list}    sec=2100
    END

    # Attach Phase Logs and ECID Requests
    &{attach_results}=    Create Dictionary
    FOR    ${i}    IN RANGE    ${length}
        ${ue}=    Get From List    ${ue_ids}    ${i}
        ${expected_ta}=    Get From List    ${expected_ta_vals}    ${i}
        ${attach_key}=    Set Variable    ${ue}th_attach
#        Start Log    cprt    biptaf
        Sleep    30s
        wtsrunner.lmf_send_ecid_meas_req
        ...    id=1    ue=${ue}    nrppa_transaction_id=1    lmf_ue_measurement_id=1
        ...    report_characteristics=OnDemand    meas_qty=NR_Timing_Advance
        Sleep    60s
        ${log_result}=    Stop Log    btslog    cprt    biptaf    test_scenario=${attach_key}
        Set To Dictionary    ${attach_results}    ${attach_key}=${log_result}
        Log To Console    checking for TA value...
        CheckTAValue    ${log_result}[cprt]/NODECPRT_GNB.pcap    ${expected_ta}
        Sleep    20s
    END

Validate ECID TA For Multiple UEs
    [Arguments]    ${UE_LIST}    ${EXPECTED_TA_LIST}
    ${length}=    Get Length    ${UE_LIST}
    FOR    ${index}    IN RANGE    ${length}
        ${ue_id}=    Get From List    ${UE_LIST}    ${index}
        ${expected_ta}=    Get From List    ${EXPECTED_TA_LIST}    ${index}
        ${scenario}=    Set Variable    ${ue_id}th_inactive_attach

        Log To Console    Starting ECID for UE ${ue_id}
        Start Log    cprt    biptaf
        wtsrunner.lmf_send_ecid_meas_req
        ...    id=1
        ...    ue=${ue_id}
        ...    nrppa_transaction_id=1
        ...    lmf_ue_measurement_id=1
        ...    report_characteristics=OnDemand
        ...    meas_qty=NR_Timing_Advance
        Sleep    60s

       TADV =   Stop Log    cprt    biptaf    test_scenario=${scenario}
        Log To Console    Checking TA value for UE ${ue_id}...
        ${pcap_path}=    Set Variable    ${TADV}[cprt]/NODECPRT_GNB.pcap
        CheckTAValue    ${pcap_path}    ${expected_ta}
        Sleep    5s
    END





Attach UE and wait for UE to move to IDLE
    [Arguments]    ${start_ueid}    ${end_UE_ID}
    log to console   UE attach trigerring now...
    ${amf_cmd}	SET VARIABLE	amf_paging_param id=${start_ueid} max_paging_retries=10
    ute_wtssim.Execute Egate Command    cmd=${amf_cmd}
    ${crnti_list}   create list
    FOR  ${UE}  IN RANGE   ${start_ueid}   ${end_UE_ID}+1
            ${rnti}   UE Register should be Successful And Fetch RNTI and TDRA list  ${UE}   pdu_id=${Pdu_session_ID}   nw_id=${nwslice_ID}
            ...     gw_id=${gw_ID}    8370_flag=1
            Append To List   ${crnti_list}   ${rnti}
    END
    Log To Console     Waiting for UE to move to idle
    ${output}   ute_wtssim.Execute Egate Command And Wait For Data  cmd=ue_disp  pass_regexp=IS IDLE  timeout=30
    ${output}         Get Lines Matching Regexp    ${output}
    ...    Received UE Context Release Complete from GNB-2; NAS Context is retained for UE with RAN
    ...     partial_match=${TRUE}
    Log to Console    UE moved to idle
    Set Suite Variable   ${crnti_list}

Start DL data and get counters and validate SLIV and srsbeam
    ${SRS_BEAM} =   catenate  SEPARATOR=${SPACE}
    ...    ul_mimo_srs_beam_pos_nr profile_id=11 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 test_type=SRS
    ...    multi_path_config=true num_of_nlos_paths=1 azimuth=-14 zenith=0 srs_transmit_power_per_port=-250,-250,-250,-250
    ${SRS_BEAM_PROFILE_ACT} =   catenate  SEPARATOR=${SPACE}
    ...    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=11
    ute_wtssim.execute_egate_command    ${SRS_BEAM}
    Start Multi UE DL traffic with multiple trafficID   start_ue=${start_ueid}  end_ue=${end_ueid}  dl_trf_id=9  qfi_id=1
    sleep    10s
    ute_wtssim.execute_egate_command    ${SRS_BEAM_PROFILE_ACT}
    Get DL Throughput for Pcell      UE_ID=1    scell=0      expected_thp=1000
    Start Multi UE UL traffic with multiple trafficID  start_ue=${start_ueid}  end_ue=${end_ueid}  ul_trf_id=2  qfi_id=1
    sleep    10s
    Get UL Throughput for Pcell  UE_ID=1   scell=0
    sleep    10s
    Log To Console    Paging success_Waiting for DL check to succeed
    ${DL_THP_8370}      Wait Until Keyword Succeeds  5x  10sec  Get DL Throughput for Pcell  UE_ID=1  scell=0  expected_thp=1350
    Set Suite Variable   ${DL_THP_8370}
    Run Keyword And Continue On Failure    Collect TTI trace and check PDSCH SLIVs present    ${LOG_PATH}/8370_enabled        ${PDSCH_SLIVs}
#    log to console    checking ratematching in ${LOG_PATH}/8370_enabled
    ${result}    verify_srsSwitch.check_srsbeam_switch    ${LOG_PATH}/8370_enabled/ttitrace_streaming/output_dl_formated.csv
    ...      ${crnti_list}    SBToWB
    Collect counter and throughput in cell_1

Start Data for UE and validate Paging is successful and validate throughput and logs
    Start DL Data and validate Paging is successful
    Start DL data and get counters and validate SLIV and srsbeam

Trigger HO to neighbourcell and validate counters
    [Arguments]    ${start_ueid}=1    ${end_UE_ID}=1    ${cell_id}=51      ${scell}=1
    Log To Console      Triggering HO    ${end_UE_ID}
    ${HO_cmd}      SET VARIABLE
    ...    ue_measurement_send_nr id=${start_ueid} meas_id=1 event=A3 srsrp_nr=1 srsrq_nr=1 phycell_id=${cell_id} nrsrp_nr=30 nrsrq_nr=20
    ${output}=  ute_wtssim.Execute Egate Command And Wait For Data  cmd=${HO_cmd}    pass_regexp=rrcReconfigurationComplete  timeout=20
    ${output1}     Get Lines Matching Regexp    ${output}    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ...    partial_match=${TRUE}
    sleep    20s
    Get UL Throughput for Pcell      UE_ID=1    scell=${scell}
    ${DL_THP}  Wait Until Keyword Succeeds  5x  10sec  Get DL Throughput for Pcell  UE_ID=1  scell=${scell}  expected_thp=1290
    Run Keyword If    ${cell_id} == 51    Collect counter and throughput in cell_2
    [Return]    ${DL_THP}

Start maximum data and validate the throughput
    Start Multi UE DL traffic with multiple trafficID  start_ue=${start_ueid}  end_ue=${end_ueid}  dl_trf_id=9  qfi_id=1
    sleep    10s
    Start Multi UE UL traffic with multiple trafficID  start_ue=${start_ueid}  end_ue=${end_ueid}  ul_trf_id=2  qfi_id=1
    sleep    60s
    Get UL Throughput for Pcell  UE_ID=1  scell=0
    Log To Console    Cell lock and unlock success_Waiting for DL check to succeed
    Wait Until Keyword Succeeds  5x  10sec  Get DL Throughput for Pcell  UE_ID=1  scell=0  expected_thp=1250

Collect BIP log and TTI and validate the logs
    Collect BIP and decode      8370_enabled_run2
    # slot_option can be  - DLalone , DL_UL , First_DL_after_UL_slot
    ${slot_option}   create list      DLalone     DL_UL     First_DL_after_UL_slot
    # IWKFeature can be - Empty list , ccesplit_K1opt , actEnhancedPDSCHSchSplSlot , adaptretx
    ${IWKFeature}   create list      flag_8322    ccesplit_K1opt
    ${result}    verify_ratematching.check_ratematching    ${path_SCN_1}[biptaf]/${BIP_CSV_NAME}    ${crnti_list}
    ...      ${slot_option}      ${RnD_flag}      ${TDD_framestructure}      ${IWKFeature}
    log to console   ${result}
    Collect TTI trace and check PDSCH SLIVs present    ${LOG_PATH}/8370_enabled_2        ${PDSCH_SLIVs}
    Run Keyword And Continue On Failure    Run Keyword if   ${result} !=1   Fail   RateMatching check failed

Trigger cell lock and unlock and UE attach
    FOR  ${INDEX}  IN RANGE    1    3
        Log To Console    Starting delta_comm_locking_${INDEX}
        5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_lock.json
        Log To Console    Starting delta_comm Done_cell_locked
        sleep  5s
        5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_unlock.json
        Log To Console    Starting delta_comm Done_cell_unlocked
        sleep  5s
        ${crnti_list}   create list
        ${rnti}   UE Register should be Successful And Fetch RNTI and TDRA list  ${start_ueid}  pdu_id=${Pdu_session_ID}
        ...     nw_id=${nwslice_ID}  gw_id=${gw_ID}  8370_flag=1
        Append To List   ${crnti_list}   ${rnti}
        wts_sim_keywords.MultiUE Trigger DL Traffic for SA   ${start_ueid}  ${end_ueid}  Traffic_rate=mbps  dl_rate=10  pdu_id=1
            ...    trf_id=1  qfi_id=1
    END

Trigger cell lock and unlock along with UE attach and start maximum data and validate ratematching from logs
    Trigger cell lock and unlock and UE attach
    Start maximum data and validate the throughput
    Collect BIP log and TTI and validate the logs

Trigger UE atatch and Verify UE switch between SB and WB
    Log To Console    Triggering SB to WB switch
	${SRS_BEAM} =   catenate  SEPARATOR=${SPACE}
	...    ul_mimo_srs_beam_pos_nr profile_id=11 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 test_type=SRS
	...    multi_path_config=true num_of_nlos_paths=1 azimuth=-14 zenith=0 srs_transmit_power_per_port=-250,-250,-250,-250
	${SRS_BEAM_PROFILE_ACT} =   catenate  SEPARATOR=${SPACE}
	...    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=11
    ${crnti_list}   create list
    ${rnti}   UE Register should be Successful And Fetch RNTI and TDRA list    ${start_ueid}     pdu_id=${Pdu_session_ID}
    ...     nw_id=${nwslice_ID}     gw_id=${gw_ID}    8370_flag=1
    Append To List   ${crnti_list}   ${rnti}
    ute_wtssim.execute_egate_command    ${SRS_BEAM}
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    ${start_ueid}   ${end_ueid}  Traffic_rate=mbps     dl_rate=175    pdu_id=1
    ...    trf_id=1    qfi_id=1
    ute_wtssim.execute_egate_command    ${SRS_BEAM_PROFILE_ACT}
    Start Multi UE DL traffic with multiple trafficID      start_ue=${start_ueid}   end_ue=${end_ueid}    dl_trf_id=9    qfi_id=1
    sleep    10s
    Get DL Throughput for Pcell      UE_ID=1    scell=0      expected_thp=1100
    Stop data    ${start_ueid}    pdu_id=1    dir=dl    trf_id=2-9     qfi=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA  ${start_ueid}  ${end_ueid}  Traffic_rate=mbps  dl_rate=30  pdu_id=1
    ...    trf_id=1    qfi_id=1
    sleep    2s
    Run Keyword And Continue On Failure    Collect TTI and decode      ${LOG_PATH}/SB_SRS
    log to console    checking WBToSB switch
    ${result}    verify_srsSwitch.check_srsbeam_switch  ${LOG_PATH}/SB_SRS/ttitrace_streaming/output_dl_formated.csv  ${crnti_list}  WBToSB


Compare counters and throughput between cell1 and cell2
    Should Be True    ${DL_THP_8370} > (${DL_THP_8370_disabled})
    ${thp_gain}=  Evaluate    (((${DL_THP_8370} - ${DL_THP_8370_disabled})/${DL_THP_8370_disabled})*100)
    Log To Console    Throughput gain is ${thp_gain} %
    Should Be True    ${Cell1_M55308C03001_8370_enabled_C1} > ${Cell2_M55308C03001_8370disabled_C1}
    Should Be True    ${Cell1_M55308C03005_8370_enabled_C2} > ${Cell2_M55308C03005_8370disabled_C2}
    Should Be True    ${Cell2_M55335C02019_8370disabled_C1} == 0
    Should Be True    ${Cell2_M55335C02020_8370disabled_C2} == 0
    Should Be True    ${Cell1_M55335C02019_8370_enabled_C1} > 190000

Collect counter and throughput in cell_2
    Log To Console    Collecting legacy and new counters in cell_2
    ${Cell2_M55308C03001_8370disabled_C1}    ${Cell2_M55308C03005_8370disabled_C2}       ${Cell2_M55335C02019_8370disabled_C1}
    ...    ${Cell2_M55335C02020_8370disabled_C2}    Collect Legacy and New Counters      nrcell=NRCELL-2
    Set Suite Variable   ${Cell2_M55308C03001_8370disabled_C1}
    Set Suite Variable   ${Cell2_M55308C03005_8370disabled_C2}
    Set Suite Variable   ${Cell2_M55335C02019_8370disabled_C1}
    Set Suite Variable   ${Cell2_M55335C02020_8370disabled_C2}
    Log To Console      ${Cell2_M55308C03001_8370disabled_C1}    ${Cell2_M55308C03005_8370disabled_C2}
    Log To Console      ${Cell2_M55335C02019_8370disabled_C1}    ${Cell2_M55335C02020_8370disabled_C2}

Collect counter and throughput in cell_1
    Log To Console    Collecting legacy and new counters in cell_1
    ${Cell1_M55308C03001_8370_enabled_C1}    ${Cell1_M55308C03005_8370_enabled_C2}       ${Cell1_M55335C02019_8370_enabled_C1}
    ...    ${Cell1_M55335C02020_8370_enabled_C2}    Collect Legacy and New Counters      nrcell=NRCELL-1
    Set Suite Variable   ${Cell1_M55308C03001_8370_enabled_C1}
    Set Suite Variable   ${Cell1_M55308C03005_8370_enabled_C2}
    Set Suite Variable   ${Cell1_M55335C02019_8370_enabled_C1}
    Set Suite Variable   ${Cell1_M55335C02020_8370_enabled_C2}
    Log To Console      ${Cell1_M55308C03001_8370_enabled_C1}      ${Cell1_M55308C03005_8370_enabled_C2}
    Log To Console      ${Cell1_M55335C02019_8370_enabled_C1}     ${Cell1_M55335C02020_8370_enabled_C2}

Simulate cqi reduction and validate the aggregation level selected
    [Arguments]    ${start_ueid}    ${end_UE_ID}
    Log To Console    ${end_UE_ID}
    ${csi_override_profile_cmd}	SET VARIABLE    csi_override_testmode_nr profile_id=2 cqi=7 pmi=2 ri=0 cqi_mode=fixed
    ute_wtssim.Execute Egate Command    cmd=${csi_override_profile_cmd}
    ${csi_override_profile_activation}	SET VARIABLE  ue_testmode_set_nr id=${start_ueid} profile_id=2 action=activate testmode=csi_override scell=0
    ute_wtssim.Execute Egate Command    cmd=${csi_override_profile_activation}
    Collect BIP and decode      cqioverride    ${FILTER_B005}    ${COLUMN_NAME_DCI}
    ${result}    check_AL_rnti      ${path_SCN_1}[biptaf]/${BIP_CSV_NAME}      ${crnti_list}
    Run Keyword if   ${result} !=1   Fail   AL check failed
    Collect TTI trace and check PDSCH SLIVs present    ${LOG_PATH}/8370_enabled_cqichange        ${PDSCH_SLIVs}

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
    ...      expected_thp=1450
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
    Convert BIP To CSV By MCShark    ${path_SCN_1}[biptaf]/BIP_L1L2.pcap    ${path_SCN_1}[biptaf]/${BIP_CSV_NAME1}
    ...                              filter=${FILTER_B005}     csv_title_list=${COLUMN_NAME_DCI}
    ${result}    verify_dummyrnti.check_dummy_rnti     ${path_SCN_1}[biptaf]/${BIP_CSV_NAME1}    ${crnti_list_1}
    log to console   ${result}
    Run Keyword if   ${result} !=1   Fail   DUMMY_RNTI check failed     ${IWKFeature}

Verify Rate Matching for shared PDCCH symbol
    Convert BIP To CSV By MCShark    ${path_SCN_1}[biptaf]/BIP_L1L2.pcap    ${path_SCN_1}[biptaf]/${BIP_CSV_NAME1}
    ...                              filter=${FILTER_B003}     csv_title_list=${COLUMN_NAME}
    ${slot_option}   create list      DLalone     DL_UL     First_DL_after_UL_slot
    ${IWKFeature}   create list       actDlPaWarmUp     ccesplit_K1opt
    ${result}    verify_ratematching.check_ratematching   ${path_SCN_1}[biptaf]/${BIP_CSV_NAME1}   ${crnti_list_1}    ${slot_option}   ${RnD_flag}
    ...     ${TDD_framestructure}      ${IWKFeature}
    Run Keyword if   ${result} !=1   Fail   RateMatching check failed     ${IWKFeature}

Reduce Data traffic and verify RBG randomization
    FOR   ${trf_id}   IN RANGE   1    11
    wts_sim_keywords.TRF Data Stop for SA    ue_id=1    pdu_id=1    dir=dl    trf_id=${trf_id}
    END
    Sleep    30s
    Run keyword and Continue on Failure   Get DL Throughput for Pcell    UE_ID=1    end_UE_ID=1    scell=0      expected_thp=170
    Run keyword and Continue on Failure   Capture TTI trace and verify RBG Randomization    ${LOG_PATH}   DL_data_8370_enabled    ${crnti_list_1}

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
	Start Multi UE DL traffic with multiple trafficID    start_ue=1   end_ue=1   dl_trf_id=9    qfi_id=1
    sleep    30s
	wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    1   Traffic_rate=mbps     ul_rate=10    pdu_id=1
    ...    trf_id=1   qfi_id=1
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
    wts_sim_keywords.Stop MultiUE Data Traffic for SA     1    1
    wts_sim_keywords.MultiUE Deregister should be Successful   1   1

Make 8370_enable singleUE SA call and collect ttitrace
	log to console   UE attach trigerring now...
	Start log   btslog   cprt
    Wait until the next Measurement Period starts  additional_time=${0}
    ${crnti_list_2}   UE Register should be Successful And Fetch RNTI and TDRA list    ue_id=1     pdu_id=1    nw_id=1
    ...     gw_id=1    8370_flag=1
    Set Suite Variable   ${crnti_list_2}
    Sleep   2s
	Start Multi UE DL traffic with multiple trafficID    start_ue=1   end_ue=1   dl_trf_id=9    qfi_id=1
    sleep    30s
	wts_sim_keywords.MultiUE Trigger UL Traffic for SA   1   1   Traffic_rate=mbps     ul_rate=10    pdu_id=1
    ...    trf_id=1   qfi_id=1
    sleep    2s
	${tput_stats_after_flag}     Get DL Throughput for Pcell    UE_ID=1    end_UE_ID=1    scell=0      expected_thp=1300
	Set Suite Variable   ${tput_stats_after_flag}
    Stop log   btslog    cprt    test_scenario=DL_data_8370_enabled
    #Collect TTI trace and check PDSCH SLIVs present
    sleep      5s
    Run Keyword And Continue On Failure    Collect BIP and decode    test_scenario=DL_data_8370_enabled
    Run Keyword And Continue On Failure    Validate BIP     test_scenario=DL_data_8370_enabled
    Run keyword and Continue on Failure    Collect TTI trace and check PDSCH SLIVs present    ${LOG_PATH}    ${PDSCH_SLIV2s}
	#Counter check
    Log To Console    Collecting new and legacy counters....
    ${Cell1M55308C03001_8370_enabled_C1}    ${Cell1M55308C03005_8370_enabled_C2}       ${Cell1M55335C02019_8370_enabled_C3}
    ...    ${Cell1M55335C02020_8370_enabled_C4}    Collect Legacy and New Counters
    Set Suite Variable   ${Cell1M55308C03001_8370_enabled_C1}
    Set Suite Variable   ${Cell1M55308C03005_8370_enabled_C2}
    Set Suite Variable   ${Cell1M55335C02019_8370_enabled_C3}
    Set Suite Variable   ${Cell1M55335C02020_8370_enabled_C4}
    Log To Console      ${Cell1M55308C03001_8370_enabled_C1}      ${Cell1M55308C03005_8370_enabled_C2}
    wts_sim_keywords.Stop MultiUE Data Traffic for SA     1    1
    wts_sim_keywords.MultiUE Deregister should be Successful   1   1

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

CheckTAValue
    [Arguments]    ${file_path}    ${value}
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}    filterExp=nrppa.NR_TADV
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=nrppa.MeasuredResultsValue   attrib_name=show     attrib_value=5
    ${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nrppa.NR_TADV  attrib_name=showname
    should be equal    ${attrib_values}[0]    NR-TADV: ${value}

MultiUE Register should be Successful with CNAI
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}       ${cnai}=${EMPTY}
	...		${subscriber_trace}=False
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    ${ue_to_bearer_list}=    Create Dictionary
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Run Keyword If  '${cnai[${ue_idx}]}' == 'on'       Set Core Network Assistance info    ${ue_idx}
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File     ${OUTPUT_DIR}/regst.txt     ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    Run Keyword if		'${subscriber_trace}'=='True'			Start Subscriber Trace
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    ${output}=  Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    ${bearer_list}       Create List
    Create File     ${OUTPUT_DIR}/bearer.txt        ${output}
    ${bearer_id}=    Run     cat ${OUTPUT_DIR}/bearer.txt |grep -i "servedRadioBearer drb-Identity" |awk '{print $4}'|sed 's/,//g'
    Append To List     ${bearer_list}        ${bearer_id}
    Set To Dictionary   ${ue_to_bearer_list}    ${ue_idx}       ${bearer_list}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}         ${ue_to_bearer_list}


Set Core Network Assistance info
    [Arguments]    ${ue_idx}
    Log to Console     Setting Core Network Assistance Info
    wtsrunner.amf_ue_ics_param       id=1         ue=${ue_idx}
    ...     trace_activation=on    trace_plmn=311:489     trace_ref_id=1     trace_rec_session_ref_id=1
    ...     trace_depth=minimum     ifaces_to_trace=NG-C     tce_ip=10.0.1.1
    ...     core_network_assistance_info=on     ue_identity_index_value=1     ue_specific_drx=64
    ...     periodic_registration_update_timer=1:1min       plmn_id=311:489     tac_id=200

Stop MultiUE Data Traffic for SA with timestamp
    [Arguments]    ${start_ue_id}   ${end_ue_id}     ${qos_profile}      ${state}=${EMPTY}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
    ${data_stop_time}        Create Dictionary
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
	Run Keyword If  '${state[${ue_idx}]}' == 'active'       Continue For Loop
    Log to Console    \nStopping Data Traffic...
    ${idx}     Set Variable    ${qos_profile[${ue_idx}]}
    ${output}      ${time}        Stop Data Traffic QFIwise        ${ue_idx}       qfi_id=${idx}
    ...        pdu=${Pdu_session_ID}      trfid=${trf_id}
    Set To Dictionary       ${data_stop_time}     ${ue_idx}      ${time[${2}]}
    Log to Console    ${output}
    sleep   1s
	END
	[Return]    ${data_stop_time}

Trigger RLF failure and Verify TAdv
    Start Log    cprt      biptaf
    wtsrunner.ue_ta_nr  profile_id=1    ue_p_delay_initial=80
    wtsrunner.ue_rrc_reestablish     id=1    gnb=2    cell=1    cause=reconfigurationFailure
    sleep   15s
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=1    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
    ${delay}    Stop Log    cprt   biptaf      test_scenario=delay
    log to console   checking for TA value...
    CheckTAValue    ${delay}[cprt]/NODECPRT_GNB.pcap      96

Verify NR of Downlink Symbols
    [Arguments]             ${wts_cfg_file}
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                      file=${wts_cfg_file}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=cell 1: SystemInformationBlockType1\-NR updated   timeout=120
    should contain    ${output}    nrofDownlinkSymbols   10
    sleep    120s

Verify Guard Period Lengh
    [Arguments]    ${expected_value}
    ${out}    Check guardPeriodLength Value For Cell      cell_id=1
    Should Contain   ${out}    ${expected_value}

ADMIN Setup Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Setup Admin
    ...    alias=${alias}

ADMIN Teardown Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Teardown Admin
    ...    connection=${alias}

ADMIN Get Managed Objects With Parameters
    [Documentation]    Get managed objects with parameters
    ...    class_name example: SMOD, RMOD_R, GNSS_L, NRCELL_A, NRCELL_L, NRCELL_R ...
    [Arguments]    ${class_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_objects_parameters_dict}    taf.sbts.oam.coam.admin.get_managed_objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    [Return]    ${out_list_of_objects_parameters_dict}

ADMIN Get Object Distname And Id List
    [Documentation]    Get object dist name (im path) and separetly list of object's ids
    ...    usage example: for class_name=NRCELL_A keyword returns full distname without id (output example below):
    ...    out_object_distName: /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-15/SCF-1/MRBTS_A-50370/NRBTS_A-50370/NRCELL_A
    ...    and list of object's ids (output example below):
    ...    out_object_id_list: [u'2', u'1']
    ...    class_name example: SMOD, RMOD_R, GNSS_L, NRCELL_A, NRCELL_L, NRCELL_R ...
    [Arguments]    ${class_name}
    ...            ${alias}=${ADMIN_ALIAS}
    ${object_parameters}    ADMIN Get Managed Objects With Parameters
    ...    class_name=${class_name}
    ...    alias=${alias}
    ${out_object_id_list}    Create List
    FOR    ${element}    IN    @{object_parameters}
        ${distName}    Get From Dictionary    ${element}    distName
        ${out_object_distName}    ${id}    Split String From Right    ${distName}    -    1
        Append To List    ${out_object_id_list}    ${id}
    END
    [Return]    ${out_object_distName}    ${out_object_id_list}

ADMIN Get Parameter
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=10
    ...            ${connection}=${ADMIN_ALIAS}
    ${out_parameters}    taf.sbts.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=${parameter}
    ...    timeout=${timeout}
    ...    connection=${connection}
    [Return]    ${out_parameters}

Check guardPeriodLength Value For Cell
    [Arguments]    ${cell_id}
    ${nrcell_a_distname}    ${id_list}    ADMIN Get Object Distname And Id List
    ...    alias=admin
    ...    class_name=NRCELL_A
    ${parameter}    ADMIN Get Parameter
    ...    dist_name=${nrcell_a_distname}-${cell_id}
    ...    parameter=guardPeriodLength
    ...    connection=admin
    [Return]    ${parameter['tddFrameStructure']['guardPeriodLength']}


Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI

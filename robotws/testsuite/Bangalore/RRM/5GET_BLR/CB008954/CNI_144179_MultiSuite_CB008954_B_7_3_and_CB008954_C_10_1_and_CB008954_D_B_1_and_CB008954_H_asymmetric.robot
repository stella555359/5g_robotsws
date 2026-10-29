*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...             RF50    RAN_5G    PY39    5G_RAN

Documentation
...             Testcase_1:     [1]CB008954_B_IWK7_3_BWPs_with_PRB_blanking_interaction_CB010850
...             author:         neravati.dheeraj_nehru@nokia.com
...             maintainer:     neravati.dheeraj_nehru@nokia.com
...
...             Introduction : This Test scenario validates high edge PRB blanking with 3BWP's i.e 20Mhz,30Mhz and 40Mhz
...             Test Set Name: [1]CB008954_B_IWK7_3_BWPs_with_PRB_blanking_interaction_CB010850
...             Testing Split: CB008954 Split B testPlan
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             References   : CB008954 CFAM
...
...             Testcase_2:       [1]CB008954_H_asymmetric_fdd
...             author:           prasanta.kumar_nayak@nokia.com
...             maintainer:       vaibhav.3.tyagi@nokia.com

...             CB008954 feature testing scenarios
...             INTRODUCTION:     This user scenario describes the gNB behavior with regards to cell setup and SA UE
...             addition when UE supporting gNB's different BWPs eg large, Medium, Small dedicated BWP are configured.
...             TEST SET NAME:    CB008954_C_B_1_1_Initial_Context_Setup_UE_configured_with_small_BWP_profile_TDD
...             TESTING SPLIT:    Refer CB008954 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008954 CFAM
...             RequirementID:    5G_RAN_USR_RRM_21488

...             Testcase_3:        [1]CB008954_D_B_6_Multiple_Ues_served_with_different_dedicated_BWP_profiles_NSA_FDD
...             authors:          vaibhav.3.tyagi@nokia.com
...             maintainer:       vaibhav.3.tyagi@nokia.com
...             CB008954 feature testing scenarios

...             INTRODUCTION:     This user scenario describes the gNB behavior with regards to cell setup and NSA UE
...             SGNB addition when UE supporting gNB's different BWPs eg large, Medium, Small dedicated BWP configuration.
...             TEST SET NAME:    CB008954_D_B_6_Multiple_Ues_served_with_different_dedicated_BWP_profiles_NSA_TDD
...             TESTING SPLIT:    Refer CB008954 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008954 CFAM
...             RequirementID:    5G_RAN_USR_RRM_21488

...             Testcase_4:
...             author:
...             maintainer:

...             INTRODUCTION:
...             TEST SET NAME:
...             TESTING SPLIT:
...             CONTACTS:
...             REFERENCES:


Resource         ./CB008954_resource.robot

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library          ta5g_enb


*** Variables ***
#Suite_1
${wts_cfg_file_TC01}       ${CURDIR}/config/wts/basic_setup_FDD_highedge_prb_blanking_4cell.cfg
${AP_XML}=                 ${CURDIR}/config/wts/iphy_4cell_fdd_40Mhz_prb_blanking.xml
${WTS_DIR}          /opt/iphy/latest
${start_ue}        1
${end_ue}          3
${nwslice_ID}      1
${gw_ID}           1
${Pdu_session_ID}       1
${QFI_ID}          1
${TRF_ID}          1
${TRF_ID2}         2
${largebwp_id}     1
${secondbwp_id}    2
${smallbwp_id}     3
${epc_log_path}    /tmp/
${TEST_NAME}            Cell_setup
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts

#Suite_2
${SCFC_TC02}=        ${CURDIR}/config/SBTS24R2/asymmertric_fdd.xml
${wts_cfg_file_TC02}     ${CURDIR}/config/wts/basic_setup_Asymmetric.cfg
${AP_XML_TC02}    ${CURDIR}/config/wts/asymmetric_iphy.xml
#${IPHY_FILE_TC02}    ${CURDIR}/config/wts/asymmetric_iphy.xml
${UE_ID}        1
${psbwp_id}     3
${smallbwp_id_TC_2}   2

#Suite_3
${IPHY_FILE_TC03}                    ${CURDIR}/config/wts/iphy_2cell.xml
${wts_cfg_file_TC03}    ${CURDIR}/config/wts/basic_setup_APoABIO_32_UEs_80_90_100_nsa.cfg
${smallbwp_id_TC_3}   2
${nsa_st_ue_id}     101
${nsa_en_ue_id}     103

#Suite_4
${wts_cfg_file_TC04}     ${CURDIR}/config/wts/basic_setup_APoABIO_32_UEs_80_90_100.cfg
${IPHY_FILE_TC04}     ${CURDIR}/config/wts/iphy_2cell.xml

*** Test Cases ***
[1]CB008954_B_IWK7_3_BWPs_with_PRB_blanking_interaction_CB010850
    [Tags]  TC_01
    [Setup]    Run keywords   BuiltIn.Set Suite Variable     ${AP_XML}
    ...                 ${CURDIR}/config/wts/iphy_4cell_fdd_40Mhz_prb_blanking.xml
    ...                 AND    Suite setup from scratch
    ...					AND    Prepare TL with IPHY file change
    ...					AND    Sleep  60s
    ...                 AND    Perform SCF Delta Commissioning with B_IWK_7_3_PRB_Blanking_FDD.json
    ...                 AND    Add routes
    ...                 AND    gnb.Perform gNB reboot
    ...                 AND    Sleep   300s    reason=wait for RMOD to comeup
    ...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file_TC01}
    ...                 AND    sleep  65s   reason=wait for mib sib
    ...                 AND    Start_capture_testcase_default_logging

    [Documentation]  This Test scenario validates high edge PRB blanking with 3BWP's i.e 20Mhz,30Mhz and 40Mhz

     ${large_bwp_rnti}    MultiUE Register should be Successful     ${1}    ${1}
     MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
     MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
#    Start Log         ttitrace    btslog
#     sleep    5s
#     ${scen3}     Stop Log     ttitrace      btslog        test_scenario=mix1

#     Get Configured Measurements of UE${start_ue}
#     Start Log      btslog     cprt
#     ${houe_small_bwp_rnti}    Trigger A3 RsrpAndRsrq Measurement for intragnb HO Custom   51     52    1    53
#     Verify Counters incrementing as expected

#     ${scen1}     Stop Log      btslog     cprt
#     Verify locationAndBandwith for allocated BWP     ${scen1}[cprt]/NODECPRT_GNB.pcap     32174


#     Start Log         ttitrace
#     sleep    5s
#     ${scen4}     Stop Log     ttitrace         test_scenario=mix2
#     MultiUE Deregister should be Successful     ${51}      ${52}
     sleep   5s
     ${second_bwp_rnti}    MultiUE Register should be Successful     ${2}    ${2}
     MultiUE Trigger UL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
     MultiUE Trigger DL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
#     Verify 8954 counters cell3

#     Start Log         ttitrace
#     sleep    5s
#     ${scen5}     Stop Log     ttitrace         test_scenario=mix3
#     MultiUE Deregister should be Successful     ${54}      ${54}
     sleep   5s

     ${small_bwp_rnti}    MultiUE Register should be Successful     ${3}    ${3}
     MultiUE Trigger UL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
     MultiUE Trigger DL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
#    Verify 8954 counters cell4
     sleep    5s
     Start Log         ttitrace
     sleep    3s
     ${scen3}     Stop Log     ttitrace         test_scenario=Mix1


     Decode TTI Trace   Mix1
     ${small_bwp_id}    Set variable    ${1}
     ${second_bwp_id}   Set Variable    ${3}
     ${large_bwp_id}   Set Variable    ${2}
     ${small_bwp_size}    Set Variable    ${106}
     ${second_bwp_size}    Set Variable    ${160}
     ${large_bwp_num_prb}    Set Variable    ${208}
     ${Mix1}    validate_bwps    ${scen3}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}
     ...    ${second_bwp_id}    ${large_bwp_id}     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_num_prb}
     ...     large_bwp_ues=${large_bwp_rnti}     small_bwp_ues=${small_bwp_rnti}     second_bwp_ues=${second_bwp_rnti}
     should contain    ${Mix1}     pass

#     Decode TTI Trace   mix2
#     ${small_bwp_id}    Set variable    ${1}
#     ${second_bwp_id}   Set Variable    ${3}
#     ${large_bwp_id}   Set Variable    ${2}
#     ${small_bwp_size}    Set Variable    ${160}
#     ${second_bwp_size}    Set Variable    ${0}
#     ${large_bwp_num_prb}    Set Variable    ${216}
#     ${Mix2}     validate_bwps    ${scen4}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}   ${large_bwp_id}
#     ...     ${small_bwp_size}   ${second_bwp_size}    ${large_bwp_num_prb}    small_bwp_ues=${houe_small_bwp_rnti}
#     should contain    ${Mix2}     pass

#     Decode TTI Trace   mix3
#     ${small_bwp_id}    Set variable    ${1}
#     ${second_bwp_id}   Set Variable    ${3}
#     ${large_bwp_id}   Set Variable    ${2}
#     ${small_bwp_size}    Set Variable    ${106}
#     ${second_bwp_size}    Set Variable    ${0}
#     ${large_bwp_num_prb}    Set Variable    ${160}
#     ${Mix3}    validate_bwps    ${scen5}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
#    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_num_prb}    small_bwp_ues=${small_bwp_rnti}
#    should contain    ${Mix3}     pass

#     Decode TTI Trace   mix4
#     ${small_bwp_id}    Set variable    ${1}
#     ${second_bwp_id}   Set Variable    ${3}
#     ${large_bwp_id}   Set Variable    ${2}
#     ${small_bwp_size}    Set Variable    ${160}
#     ${second_bwp_size}    Set Variable    ${0}
#     ${large_bwp_num_prb}    Set Variable    ${216}
#     ${Mix4}     validate_bwps    ${scen6}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
#    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_num_prb}    large_bwp_ues=${large1_bwp_rnti}
#    should contain    ${Mix4}     pass

    [Teardown]  Run Keywords       Log To console   Teardown_started
    ...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
   #...                 AND     Dump RMOD BBMOD And Cell Status
    ...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting

[1]CB008954_H_asymmetric_fdd
    [Tags]    TC_02
    [Setup]    Run keywords   BuiltIn.Set Suite Variable     ${AP_XML}
    ...            ${CURDIR}/config/wts/asymmetric_iphy.xml
    ...            AND    BuiltIn.Set Suite Variable     ${SCFC}
    ...            ${CURDIR}/config/SBTS24R2/asymmertric_fdd.xml
    ...                 AND     Prepare TL with all config files
   #...                 AND     Modify IPHY File And Send to Airphone Custom     ${IPHY_FILE}
   #...                 AND     Find Scfc And Fix And Send Full Commissioning
   #...                         scfc_filename=asymmertric_fdd.xml
    ...                 AND     sleep    180s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    150s
    ...                 AND     Load CFG Config updated     ${wts_cfg_file_TC02}
    ...                 AND     sleep    60s
    ...                 AND     Check gNB Bulid

  [Documentation]   This scenario is to verify the cell setup with 3 dedicated BWPS 15,20,30 MHZ


    Log To console  TestCasestartedl
    Increase Buffer Size for VM and IPHY
    Wait until the next Measurement Period starts

    ${small_bwp_rnti}    MultiUE Register should be Successful     ${51}    ${52}
    MultiUE Trigger UL Traffic for SA    ${51}    ${52}  Traffic_rate=mbps     ul_rate=2   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${51}    ${52}  Traffic_rate=mbps     dl_rate=20   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    51  52     2
    Validate DL Traffic For MultiUE for SA    51  52     20


    ${second_bwp_rnti}    MultiUE Register should be Successful     ${53}    ${54}
    MultiUE Trigger UL Traffic for SA    ${53}  ${54}  Traffic_rate=mbps     ul_rate=2   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${53}  ${54}  Traffic_rate=mbps     dl_rate=20   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    53  54     2
    Validate DL Traffic For MultiUE for SA    53  54     20

    ${large_bwp_rnti}    MultiUE Register should be Successful     ${55}    ${56}
    MultiUE Trigger UL Traffic for SA    ${55}    ${56}  Traffic_rate=mbps     ul_rate=2   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${55}    ${56}  Traffic_rate=mbps     dl_rate=20   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    55  56     2
    Validate DL Traffic For MultiUE for SA    55  56     20
    Wait until the current Measurement Period stops
    Collect PM Counter


    ${Counters}    Create Dictionary     ${MAX_UE_UL_SCH_SLOT_BWP1}=${2}
    ...       ${MAX_UE_UL_SCH_SLOT_BWP3}=${2}     ${MAX_UE_UL_SCH_SLOT_BWP2}=${2}
    ...       ${MAX_UE_DL_SCH_SLOT_BWP1}=${2}     ${MAX_UE_DL_SCH_SLOT_BWP2}=${2}
    ...       ${MAX_UE_DL_SCH_SLOT_BWP3}=${2}

    Verify Counters    ${Counters}
    [Teardown]  Run Keywords   Log To console  TCTeardown
    ...         AND        Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting

[1]CB008954_D_B_6_Multiple_Ues_served_with_different_dedicated_BWP_profiles_NSA_FDD
    [Tags]  TC03
    [Setup]    Run keywords   Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE_TC03}
    ...                 AND     Find Scfc And Fix And Send Full Commissioning
    ...                         scfc_filename=80_90_100_MHZ_2cell.xml
    ...                 AND     sleep    30s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    100s
    ...                 AND     Load CFG Config     ${wts_cfg_file_TC03}
    ...                 AND     Check gNB Bulid
    ...                 AND     Start_capture_testcase_default_logging

   [Documentation]   This scenario is to verify the cell setup with 3 dedicated BWPS 80,90,100 MHZ


    Log To console  TestCasestartedl
    Increase Buffer Size for VM and IPHY
    start log     cprt
    X2AP Link Should be UP
    log to console   UE attach trigerring now...

    ${small_bwp_rnti}     MultiUE NSA Attach should be Successful and Fetch CRNTI    101    101
    ${second_bwp_rnti}     MultiUE NSA Attach should be Successful and Fetch CRNTI    102    102
    ${large_bwp_rnti}     MultiUE NSA Attach should be Successful and Fetch CRNTI    103    103
    MultiUE DL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    10    id=2    trf_id=1
    MultiUE UL Traffic Start for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    mbps    10    id=2    trf_id=1

    sleep    10s
    start log     ttitrace
    sleep     2s
    ${Titrace_UE}    Stop log      ttitrace   test_scenario=ttiTrace



    MultiUE DL Traffic Stop for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    2    1
    MultiUE UL Traffic Stop for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}    2    1
    MultiUE Detach for NSA    ${nsa_st_ue_id}    ${nsa_en_ue_id}
    ${path_traceCPRT_UE1}    Stop log      cprt    test_scenario=TraceCPRT1
    Decode TTI Trace    ttiTrace


    ${small_bwp_id}    Set variable    ${2}
    ${second_bwp_id}   Set Variable    ${3}
    ${large_bwp_id}   Set Variable    ${1}
    ${small_bwp_size}    Set Variable    ${217}
    ${second_bwp_size}    Set Variable    ${245}
    ${large_bwp_size}    Set Variable    ${273}

    ${Counters}    Create Dictionary     ${NRRC_RCFG_CMP_BWP1_RCVD}=${1}    ${NRRC_RRC_RECONF_BWP1_SENT}=${1}
    ...       ${SGNB_NSA_DU_ADM_SUCC_BWP1}=${1}     ${SGNB_NSA_DU_ADM_SUCC_BWP2}=${1}   ${SGNB_NSA_DU_ADM_SUCC_BWP3}=${1}
    ...       ${NRRC_RCFG_CMP_BWP2_RCVD}=${1}     ${NRRC_RRC_RECONF_BWP2_SENT}=${1}
    ...       ${NRRC_RCFG_CMP_BWP3_RCVD}=${1}     ${NRRC_RRC_RECONF_BWP3_SENT}=${1}
    ...       ${MAX_UE_DL_SCH_SLOT_BWP1}=${1}     ${MAX_UE_DL_SCH_SLOT_BWP2}=${1}
    ...       ${MAX_UE_DL_SCH_SLOT_BWP3}=${1}

    Verify Counters    ${Counters}

    validate_bwps    ${Titrace_UE}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_size}    small_bwp_ues=${small_bwp_rnti}   second_bwp_ues=${second_bwp_rnti}
    ...     large_bwp_ues=${large_bwp_rnti}

    validate_bwps    ${Titrace_UE}[ttitrace]/output_ul_formated.csv    ulFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_size}    small_bwp_ues=${small_bwp_rnti}   second_bwp_ues=${second_bwp_rnti}
    ...     large_bwp_ues=${large_bwp_rnti}

    [Teardown]  Run Keywords   Log To console  TCTeardown
    ...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting

[1]CB008954_C_10_1_Multiple_Ues_served_with_different_dedicated_BWPs
    [Tags]  TC04
    [Setup]    Run keywords   Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE_TC04}
    ...                 AND     Find Scfc And Fix And Send Full Commissioning
    ...                         scfc_filename=80_90_100_MHZ_2cell.xml
    ...                 AND     sleep    180s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    180s
    ...                 AND     Load CFG Config     ${wts_cfg_file_TC04}
    ...                 AND     Check gNB Bulid
    ...                 AND     Start_capture_testcase_default_logging

    [Documentation]   This scenario is to verify the cell setup with 3 dedicated BWPS 80,90,100 MHZ


    Log To console  TestCasestartedl
    Increase Buffer Size for VM and IPHY
    Wait until the next Measurement Period starts

    ${small_bwp_rnti}    MultiUE Register should be Successful     ${1}    ${4}
    MultiUE Trigger UL Traffic for SA    ${1}  ${4}  Traffic_rate=mbps     ul_rate=2   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${4}  Traffic_rate=mbps     dl_rate=20   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    1  4     2
    Validate DL Traffic For MultiUE for SA    1  4     20


    ${second_bwp_rnti}    MultiUE Register should be Successful     ${8}    ${15}
    MultiUE Trigger UL Traffic for SA    ${8}  ${15}  Traffic_rate=mbps     ul_rate=2   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${8}  ${15}  Traffic_rate=mbps     dl_rate=20   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    8  15     2
    Validate DL Traffic For MultiUE for SA    8  15     20

    ${large_bwp_rnti}    MultiUE Register should be Successful     ${16}    ${23}
    MultiUE Trigger UL Traffic for SA    ${16}  ${23}  Traffic_rate=mbps     ul_rate=2   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${16}  ${23}  Traffic_rate=mbps     dl_rate=20   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    16  23     2
    Validate DL Traffic For MultiUE for SA    16  23     20
    Wait until the current Measurement Period stops
    Collect PM Counter

    Start Log         ttitrace
    sleep    2s
    ${scen3}     Stop Log     ttitrace         test_scenario=mix
    Decode TTI Trace   mix


    ${small_bwp_id}    Set variable    ${2}
    ${second_bwp_id}   Set Variable    ${3}    # make it invalid
    ${large_bwp_id}   Set Variable    ${1}
    ${small_bwp_size}    Set Variable    ${217}
    ${second_bwp_size}    Set Variable    ${245}
    ${large_bwp_size}    Set Variable    ${273}



    ${Counters}    Create Dictionary     ${NRRC_RCFG_CMP_BWP1_RCVD}=${4}    ${NRRC_RRC_RECONF_BWP1_SENT}=${4}
    ...       ${GNB_SA_DU_ADM_SUCC_BWP3}=${8}     ${GNB_SA_DU_ADM_SUCC_BWP2}=${8}   ${GNB_SA_DU_ADM_SUCC_BWP1}=${4}
    ...       ${NRRC_RCFG_CMP_BWP2_RCVD}=${8}    ${NRRC_RRC_RECONF_BWP2_SENT}=${8}
    ...       ${NRRC_RCFG_CMP_BWP3_RCVD}=${8}     ${NRRC_RRC_RECONF_BWP3_SENT}=${8}

    Verify Counters    ${Counters}

    validate_bwps    ${scen3}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_size}    small_bwp_ues=${small_bwp_rnti}   second_bwp_ues=${second_bwp_rnti}
    ...     large_bwp_ues=${large_bwp_rnti}

    validate_bwps    ${scen3}[ttitrace]/output_ul_formated.csv    ulFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_size}    small_bwp_ues=${small_bwp_rnti}   second_bwp_ues=${second_bwp_rnti}
    ...     large_bwp_ues=${large_bwp_rnti}

    [Teardown]  Run Keywords   Log To console  TCTeardown
    ...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
#Keywords_of_TestCase_1
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

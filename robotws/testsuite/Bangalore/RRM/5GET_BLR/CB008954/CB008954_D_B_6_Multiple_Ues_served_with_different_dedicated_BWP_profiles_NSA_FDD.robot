*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CIT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS22R3    SBTS23R2    SBTS23R1    CONFIGURED

Documentation    :copyright: Nokia
...              :authors:vaibhav.3.tyagi@nokia.com
...             CB008954 feature testing scenarios
...             INTRODUCTION:     This user scenario describes the gNB behavior with regards to cell setup and NSA UE
...             SGNB addition when UE supporting gNB's different BWPs eg large, Medium, Small dedicated BWP configuration.
...             TEST SET NAME:    CB008954_D_B_6_Multiple_Ues_served_with_different_dedicated_BWP_profiles_NSA_TDD
...             TESTING SPLIT:    Refer CB008954 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008954 CFAM
...             RequirementID: 5G_RAN_USR_RRM_21488

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb


Resource         ./CB008954_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=80_90_100_MHZ_2cell.xml
...                 AND     sleep    1s
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    10s
...                 AND     Load CFG Config     ${wts_cfg_file}
...                 AND     Check gNB Bulid


Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Log To console   Teardown_started
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

*** Variables ***
${wts_cfg_file}      ${CURDIR}/config/wts/basic_setup_APoABIO_32_UEs_80_90_100_nsa.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${largebwp_id}   1
${smallbwp_id}   2
${psbwp_id}     3
${epc_log_path}    /tmp/
${TEST_NAME}            Cell_setup
${IPHY_FILE}                    ${CURDIR}/config/wts/iphy_2cell.xml
${nsa_st_ue_id}     101
${nsa_en_ue_id}     103
*** Test Cases ***
[1]CB008954_D_B_6_Multiple_Ues_served_with_different_dedicated_BWP_profiles_NSA_FDD
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
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


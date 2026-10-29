*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CIT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS22R3    SBTS23R2    SBTS23R1    CONFIGURED

Documentation    :copyright: Nokia
...              :authors:Prasanta
...             CB008954 feature testing scenarios
...             INTRODUCTION:     This user scenario describes the gNB behavior with regards to cell setup and SA UE
...             addition when UE supporting gNB's different BWPs eg large, Medium, Small dedicated BWP are configured.
...             TEST SET NAME:    CB008954_C_B_1_1_Initial_Context_Setup_UE_configured_with_small_BWP_profile_TDD
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
...                 AND     sleep    180s
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    180s
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
${wts_cfg_file}      ${CURDIR}/config/wts/basic_setup_APoABIO_32_UEs_80_90_100.cfg
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
*** Test Cases ***
[1]CB008954_C_10_1_Multiple_Ues_served_with_different_dedicated_BWPs
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

    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

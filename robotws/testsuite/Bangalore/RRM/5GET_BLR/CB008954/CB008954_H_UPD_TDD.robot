*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CIT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS22R3    SBTS23R2    SBTS23R1    CONFIGURED

Documentation    :copyright: Nokia
...              :authors:vaibhav.3.tyagi@nokia.com
...             CB008954 feature testing scenarios
...             INTRODUCTION:     This user scenario describes the gNB behavior with regards to cell setup and NSA UE
...             SGNB addition when UE supporting gNB's different BWPs eg large, Medium, Small dedicated BWP configuration.
...             TEST SET NAME:    2_CB008954_H_UPD001_IWK_CB008238_with_Multiple_UEs_served_with_Three_dedicated_BWPs_dedicated_
...             with_Micro_DTX_optimized_scheduler_for_FR1_TDD
...             TESTING SPLIT:    Refer CB008954 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008954 CFAM
...             RequirementID:   5G_RAN_USR_RRM_21343    5G_RAN_USR_RRM_15078


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb


Resource         ./CB008954_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=upd_tdd_100.xml
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

*** Variables ***
${wts_cfg_file}      ${CURDIR}/config/wts/basic_setup_APoABIO_32_UEs_80_90_100_upd.cfg
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
${IPHY_FILE}                    ${CURDIR}/config/wts/iphy_2cell_upd.xml
*** Test Cases ***
[1]CB008954_H_UPD001_IWK_CB008238_with_Multiple_UEs_served_with_Three_dedicated_BWPs_dedicated_with_Micro_DTX_optimized_scheduler_for_FR1_TDD
    [Documentation]   This scenario is to verify the DTX with 3 dedicated BWPS 20,80,100 MHZ

    Increase Buffer Size for VM and IPHY
    Wait until the next Measurement Period starts
    ${small_bwp_rnti}    MultiUE Register should be Successful     ${1}    ${1}
    ${second_bwp_rnti}    MultiUE Register should be Successful     ${2}    ${2}
    ${large_bwp_rnti}    MultiUE Register should be Successful     ${3}    ${3}
    MultiUE Trigger UL Traffic for SA    ${1}  ${3}  Traffic_rate=mbps     ul_rate=8   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${3}  Traffic_rate=mbps     dl_rate=30   pdu_id=1   trf_id=1   qfi_id=1

    Start Log         ttitrace
    sleep    2s
    ${scen3}     Stop Log     ttitrace         test_scenario=mix
    Decode TTI Trace   mix

    ${small_bwp_id}    Set variable    ${2}
    ${second_bwp_id}   Set Variable    ${3}    # make it invalid
    ${large_bwp_id}   Set Variable    ${1}
    ${small_bwp_size}    Set Variable    ${51}
    ${second_bwp_size}    Set Variable    ${245}
    ${large_bwp_size}    Set Variable    ${273}
    validate_bwps    ${scen3}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_size}    large_bwp_ues=${large_bwp_rnti}

    ${rnti_list}=    Combine Lists    ${second_bwp_rnti}    ${large_bwp_rnti}    ${small_bwp_rnti}

    verify_dtx    ${scen3}[ttitrace]/output_dl_formated.csv    ${rnti_list}
    sleep    600s
    ${Counters}    Create Dictionary     ${MAX_UE_UL_SCH_SLOT_BWP1}=${1}
    ...       ${MAX_UE_UL_SCH_SLOT_BWP3}=${1}     ${MAX_UE_UL_SCH_SLOT_BWP2}=${1}
    ...       ${MAX_UE_DL_SCH_SLOT_BWP1}=${1}     ${MAX_UE_DL_SCH_SLOT_BWP2}=${1}
    ...       ${MAX_UE_DL_SCH_SLOT_BWP3}=${1}


    Verify Counters    ${Counters}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting






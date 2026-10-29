*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00   CONFIGURED

Documentation    :copyright: Nokia
...              :authors:Prakhar
...         CB008954 feature testing scenarios

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb


Resource         ./CB008954_resource.robot

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Log To console   Teardown_started
#...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file1}      ${CURDIR}/config/wts/basic_setup_H_5.2.cfg
${wts_cfg_file2}      ${CURDIR}/config/wts/H_IWK_7.2_GMC.cfg
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
${IPHY_FILE}                    ${CURDIR}/config/wts/iphy_4cell.xml
*** Test Cases ***

[1]CB008954_H_IWK_7_2_Three_dedicated_BWPs_with_dynamic_PDCCH_symbol_usage_is_high_on_second_dedicated_BWP
    [Documentation]   Dynamic PDCCH allocation with 3 BWP

    [Setup]             Run keywords     Suite setup from scratch
    ...                 AND     update_gscn    ${IPHY_FILE}    50     7880
    ...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
    ...                 AND     Perform SCF Delta Commissioning with H_IWK_7.2.json
    ...                 AND     sleep    180s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Load CFG Config     ${wts_cfg_file2}
    ...                 AND     Check gNB Bulid

    Log To console  H_IWK_Dyn_PDCCH_SYM_mid_BWP
    Increase Buffer Size for VM and IPHY
    Wait until the next Measurement Period starts

    ${small_bwp_rnti}    MultiUE Register should be Successful     ${1}    ${3}
    MultiUE Trigger UL Traffic for SA    ${1}  ${3}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${3}  Traffic_rate=mbps     dl_rate=80   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    1  3     1
    Validate DL Traffic For MultiUE for SA    1  3     80

    ${second_bwp_rnti}    MultiUE Register should be Successful     ${4}    ${4}
    MultiUE Trigger UL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    4  4     1
    Validate DL Traffic For MultiUE for SA    4  4     50

    ${Counters}    Create Dictionary     ${PDCCH_SYMB_DIF_BWP1_BWP3}=${0}    ${PDCCH_SYMB_DIF_BWP2_BWP3}=${0}
    ...       ${PDCCH_SYMB_DIF_BWP1_BWP2}=${0}     ${PDCCH_SYMB_DIF_BWP1_PWS_BWP}=${0}   ${PDCCH_SYMB_DIF_BWP2_PWS_BWP}=${0}
    ...       ${PDCCH_SYMB_DIF_BWP3_PWS_BWP}=${0}
    Verify Counters    ${Counters}

    Wait until the next Measurement Period starts
    Modify NIDD parameters   MRBTS-1/NRBTS-1/NRCELL-1   update   actDynPdcchTdMode    perBWP
    sleep     300s

    ${Counters}    Create Dictionary     ${PDCCH_SYMB_DIF_BWP1_BWP3}=${-1}    ${PDCCH_SYMB_DIF_BWP2_BWP3}=${-1}
    ...       ${PDCCH_SYMB_DIF_BWP1_BWP2}=${-1}     ${PDCCH_SYMB_DIF_BWP1_PWS_BWP}=${0}   ${PDCCH_SYMB_DIF_BWP2_PWS_BWP}=${0}
    ...       ${PDCCH_SYMB_DIF_BWP3_PWS_BWP}=${0}
    Verify Counters    ${Counters}

    [Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     Kill WTS processes Using WTS_Runner
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

[1]CB008954H_IWK_5_2_SA_Initial_RRC_Setup_with_dedicated_config_initialDownlinkBWP_CNI78446_CNI81991_TDD
    [Documentation]   This test scenario is to verify gNB behavior when UE setup the RRC connection using dedicated
    ...               config in initialDownlinkBWP with regards to UE context setup when UE supporting small or
    ...               second or large dedicated BWP

    [Setup]             Run keywords     Suite setup from scratch
    ...                 AND     Change GSCN value in IPHY File      AEQE    7870
    ...                 AND     Perform SCF Delta Commissioning with H_IWK_5.2.json
    ...                 AND     sleep    180s
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Load CFG Config     ${wts_cfg_file1}
    ...                 AND     Check gNB Bulid

    Log To console  TestCasestartedl
    Increase Buffer Size for VM and IPHY

    ${small_bwp_rnti}    MultiUE Register should be Successful custom     ${1}    ${2}
    MultiUE Trigger UL Traffic for SA    ${1}  ${2}  Traffic_rate=mbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${2}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    1  2     10
    Validate DL Traffic For MultiUE for SA    1  2     50


    ${second_bwp_rnti}    MultiUE Register should be Successful custom     ${3}    ${4}
    MultiUE Trigger UL Traffic for SA    ${3}  ${4}  Traffic_rate=mbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${3}  ${4}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    3  4     10
    Validate DL Traffic For MultiUE for SA    3  4     50

    ${large_bwp_rnti}    MultiUE Register should be Successful custom     ${5}    ${6}
    MultiUE Trigger UL Traffic for SA    ${5}  ${6}  Traffic_rate=mbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${5}  ${6}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s
    Validate UL Traffic For MultiUE for SA    5  6     10
    Validate DL Traffic For MultiUE for SA    5  6     50

    Start Log         ttitrace
    sleep    2s
    ${scen3}     Stop Log     ttitrace       test_scenario=mix

    Decode TTI Trace    mix
    ${small_bwp_id}    Set variable    ${3}
    ${second_bwp_id}   Set Variable    ${2}    # make it invalid
    ${large_bwp_id}   Set Variable    ${1}
    ${small_bwp_size}    Set Variable    ${51}
    ${second_bwp_size}    Set Variable    ${78}
    ${large_bwp_size}    Set Variable    ${133}

    validate_bwps    ${scen3}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_size}    small_bwp_ues=${small_bwp_rnti}   second_bwp_ues=${second_bwp_rnti}
    ...     large_bwp_ues=${large_bwp_rnti}

    validate_bwps    ${scen3}[ttitrace]/output_ul_formated.csv    ulFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_size}    small_bwp_ues=${small_bwp_rnti}   second_bwp_ues=${second_bwp_rnti}
    ...     large_bwp_ues=${large_bwp_rnti}

    [Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     Kill WTS processes Using WTS_Runner
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
    Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

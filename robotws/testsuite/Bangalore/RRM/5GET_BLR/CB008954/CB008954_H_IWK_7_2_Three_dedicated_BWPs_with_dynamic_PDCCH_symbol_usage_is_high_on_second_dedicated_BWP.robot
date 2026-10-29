*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CIT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS22R3    SBTS23R2    SBTS23R1    CONFIGURED

Documentation    :copyright: Nokia
...              :authors:Prasanta
...         CB008954 feature testing scenarios

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb


Resource         ./CB008954_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     update_gscn    ${IPHY_FILE}    50     7880
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Perform SCF Delta Commissioning with H_IWK_7.2.json
#...                 AND     Find Scfc And Fix And Send Full Commissioning
#...                         scfc_filename=H.xml
...                 AND     sleep    180s
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config     ${wts_cfg_file}
...                 AND     Check gNB Bulid


Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Log To console   Teardown_started
#...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file}      ${CURDIR}/config/wts/H_IWK_7.2_GMC.cfg
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
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...             CONFIGS_Bangalore/RRM/ET/CB008541/CB008541_5G_B_B002_1_APoverABIO.yml
...             CIT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS22R3    SBTS23R2    SBTS23R1
...            CONFIGURED

Documentation    :copyright: Nokia
...              :authors:Prasanta kumar_nayak
...         CB008954 feature testing scenarios

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb


Resource         ./CB008954_resource.robot
#Resource        ../CB008941/CB008941_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}    frag=${1}
...                 AND     Add RD Parameters To GNB Swconfig File     ${RD_PARAM_8124}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=100_40_20_20_prb_blank_6878.xml
...                 AND     sleep    180s
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    180s
...                 AND     Load CFG Config      ${wts_cfg_file}
...                 AND     Check gNB Bulid


Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Link SCOUT SCF to Configuration ID for Reporting
#...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
#${wts_cfg_file}     ${WTS_DIR}/basic_setupl.cfg
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
${IPHY_FILE}                    ${CURDIR}/config/wts/8941_iphy.xml
*** Test Cases ***
[1][1.0] CB008954-A_B_3_ 2_Activation_of_3_BWPs_aligned_at_the_bottom_of_the_5G_cell_with_PRB_blanking_CB006878_5GC00937_CB008941_enabled
    [Documentation]   This scenario is to verify the cell setup with 3 dedicated BWPS 80,90,100 MHZ

    ${prbs}    Create List    217    217    245    273
    Read Cellsetup msg      ${cprt_log}[cprt]/NODECPRT_GNB.pcap    ${prbs}    ${4}
    set test variable      ${LOG_PATH}
    Log To console  TestCasestartedl


*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

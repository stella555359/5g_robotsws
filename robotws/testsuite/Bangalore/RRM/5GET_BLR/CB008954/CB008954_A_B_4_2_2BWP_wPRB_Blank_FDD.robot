*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CIT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

Documentation
...
...             author       : megha.dm@nokia.com
...             maintainer   : megha.dm@nokia.com
...             Introduction : This Test scenario validates the cell setup of 2BWP's i.e 10Mhz and 20Mhz BW which
...                               is alligned at the bottom of 5G cell when PRB is blanked in FDD
...             Test Set Name: [1]CB008954_A_B_4_ 2_Activation_of_2_BWPs_aligned_at_the_bottom_of_the_5G_cell_with_
...                               PRB_blanking_FDD
...             Testing Split: CB008954 Split A testPlan
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             References   : CB008954 CFAM
...             RequirementID: 5G_RAN_USR_RRM_21488

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb


Resource         ./CB008954_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Change IPHY File Value      AHLOA       1570
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=10_20Mhz_Prb_Blank_FDD.xml
...                 AND     sleep    180s
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    180s
...                 AND     Load CFG Config      ${wts_cfg_file}
...                 AND     Should Contain     ${sib1_output}   ${initial_location_bwp}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
#...                 AND     Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

Test Setup       Start_capture_testcase_default_logging

Test Teardown    Run Keywords       Log To console   Teardown_started
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_fdd.cfg
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
${initial_location_bwp}     14026

*** Test Cases ***
[1]CB008954_A_B_4_ 2_Activation_of_2_BWPs_aligned_at_the_bottom_of_the_5G_cell_with_PRB_blanking_FDD
    [Documentation]   This scenario is to verify the cell setup with 2 dedicated BWPS 10,& 20 MHZ
    ${prbs}=    Create List   52    106
    ${scs}   ${offset}      Read Cellsetup msg     file=${cprt_log}[cprt]/NODECPRT_GNB.pcap
    ${Result_15}    ${Result_30}    Check_and_validate_prb       ${scs}     ${offset}   ${prbs}
    Should Be True      ${Result_15} <= ${prbs}[0]
    Run Keyword If  ${Result_15} <= ${prbs}[0]   BuiltIn.Log     PRB ${Result_15} is inside the ${prbs}[0]
    ...      ELSE     BuiltIn.Log    PRB ${Result_15} is outside the ${prbs}[0]
    Log to console      PRB is ${Result_15}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

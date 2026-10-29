*** Settings ***

Documentation



#Force Tags   STATE_CONFIGURED  5G_RAN_TDD  5G_RAN  master_classicalbts_all
#...    CLOUD_5G_BL_AP_NSA_FS_CMWV
#...    CA_BTS_OAM_FMRECOV    QCP_BTS_OAM    QCD_MN_BTS_OAM

#Suite Setup       Suite Preconditions
#Suite Teardown    Suite Postconditions
#Test Setup        Test Preconditions
#Test Teardown     Test Postconditions

Library    BuiltIn
Library    String
#Library    ${CURDIR}/../../../resources/python_libs/TestCaseRequirement.py
#Library    taf.wts.runner                     WITH NAME      wtsrunner

Resource    ./resources/wtssim_resources.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot
Resource    ../resources/pretest_posttest.robot
#Resource    ../resources/AirPhone/resources/ute/sosReport.robot
#Resource    ${CURDIR}/../Wroclaw/resources/robot/sherpa_ute.robot
#Resource    ../resources/AirPhone/resources/ute/coam_ulm.robot

Suite Setup     Run Keywords     Reach OnAir Setup for LO
...             AND              Suite Preconditions
# Run Keywords
# Wait Coam Site to be Ready
#...                               AND    ute_wts_runner.Modify UTE SCTP Timeout
#...                               AND    ute_wts_runner.Start UTE WTS
#...                               AND    X2 Connection
#...                               AND    Start sosReport Tcpdump    init
Suite Teardown    Run Keywords    Reach OnAir Teardown
...               AND             Suite Postconditions
#Run Keyword and Ignore Error    ute_wts_runner.Teardown Edaemon and Egate process
#Run Keywords    Collect Logs For Run
#...                               AND

Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
#${SUITE_WTS_AP_XML}    AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml
#${SUITE_WTS_CFG}       basic_fullstack_nsa_call_tdd_cmwv.cfg
#${SUITE_CFG_DIR_tmp}   ../resources/AirPhone/resources/fs_tdd_nsa_ASIB_cmwv
#${EXCLUDE_LOGS}        0
#${apConfiguration}     fs_tdd_nsa_cmwv
#${gnb_sm_hardware}     ASIB
#${gnb_cp_hardware}     ABIL
#${duplexing}           TDD
#${RF_type}             CPRI
#${wavelength}          cmwv
#${deployment}          NSA
#${l1}                  FS
#${RU_type}             AEQA

*** Test Cases ***
WTSSIM_test
#    [Tags]   CIT
    [Documentation]
    ...
    WTSSIM_test

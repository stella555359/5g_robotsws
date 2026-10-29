*** Settings ***

Documentation
...    Author: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Maintainer: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000470-E-a_5GC001639-RA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC000470-E-a_5GC001639-RA/general.robot

Resource    ./resources/5GC000470-E-a_5GC001639-RA.robot

#Regression moved on ABIO Parity
#Force Tags   STATE_CONFIGURED  5G_RAN_TDD  5G_RAN  master_classicalbts_all
#...    CLOUD_5G_BL_AP_NSA_FS_CMWV
#...    CA_BTS_OAM_FMRECOV    QCP_BTS_OAM    QCD_MN_BTS_OAM

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions With Reset Site


*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***
[1.0] 5GC000470-E-a_5GC001639-RA_Check_that_the_WebEM_generate_a_list_file_with_the_snapshot_content
    [Tags]   CIT
    [Documentation]
    ...
    5GC000470-E-a_5GC001639-RA_Snapshot_collection_is_triggered_by_operator_from_WebEM

[1.0] 5GC000470-E-a_5GC001639-RA_Check_the_BTS_is_saving_technical_report
    [Tags]   CRT
    [Documentation]
    ...
    5GC000470-E-a_5GC001639-RA_Check_that_the_WebEM_generate_a_list_file_with_the_snapshot_content

[1.0] 5GC000470-E-a_5GC001639-RA_Snapshot_collection_is_triggered_by_operator_from_WebEM
    [Tags]   CRT
    [Documentation]
    ...
    5GC000470-E-a_5GC001639-RA_Check_the_BTS_is_saving_technical_report


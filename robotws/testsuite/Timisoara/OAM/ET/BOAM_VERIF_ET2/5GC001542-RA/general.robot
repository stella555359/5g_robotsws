*** Settings ***

Documentation
...    Author: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Maintainer: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC001542-RA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001542-RA/general.robot

Resource    ./resources/5GC001542-RA.robot

#Force Tags   STATE_CONFIGURED  5G_RAN_TDD  5G_RAN  master_classicalbts_all  20Bb1_classicalbts
#...    CLOUD_5G_KL_AP_NSA_FS_CMWV
#...    CA_BTS_OAM_FMRECOV    QCP_BTS_OAM    QCD_MN_BTS_OAM

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     5GC001542-RA-Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***
[1.0] 5GC001542_RA_Fault_triggered_automatic_snapshot_to_remote_LSS_via_sftp_when_fault_is_detected_in_BTS
    [Tags]   CRT
    [Documentation]
    ...
    5GC001542_RA_Fault_triggered_automatic_snapshot_to_remote_LSS_via_sftp_when_fault_is_detected_in_BTS



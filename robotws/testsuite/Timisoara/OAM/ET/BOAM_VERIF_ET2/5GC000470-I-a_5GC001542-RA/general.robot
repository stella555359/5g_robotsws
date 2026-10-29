*** Settings ***

Documentation
...    Author: Ioana-Andreea Sandu-Andrei (ioana.sandu-andrei@nokia.com)
...    Maintainer: Ioana-Andreea Sandu-Andrei (ioana.sandu-andrei@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000470-I-a_5GC001542-RA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC000470-I-a_5GC001542-RA/general.robot

Resource    ./resources/5GC000470-I-a_5GC001542-RA.robot

#Force Tags   STATE_CONFIGURED  5G_RAN_TDD  5G_RAN  master_classicalbts_all
#...    CLOUD_5G_BL_AP_NSA_FS_CMWV
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
5GC001542_RA_Fault_trigger_automatic_to_LSS_viaSFTP_when_fault_is_detected
#    [Tags]   CIT
    [Documentation]
    ...
    5GC001542_RA_Fault_trigger_automatic_to_LSS_viaSFTP_when_fault_is_detected

5GC001542_RA_Fault trigger_automatic_to_LSS_but_not_performed_when_fault_is_detected
#    [Tags]   CRT
    [Documentation]
    ...
    5GC001542_RA_Fault trigger_automatic_to_LSS_but_not_performed_when_fault_is_detected

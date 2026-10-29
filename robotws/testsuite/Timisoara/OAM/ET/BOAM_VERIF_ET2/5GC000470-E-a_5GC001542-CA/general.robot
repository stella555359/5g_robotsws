*** Settings ***

Documentation
...    Author: Alin Necula (alin.necula@nokia.com)
...    Maintainer: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000470-E-a_5GC001542-CA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC000470-E-a_5GC001542-CA/general.robot

Resource    ./resources/5GC000470-E-a_5GC001542-CA.robot

#Force Tags   STATE_CONFIGURED  5G_RAN_TDD  5G_RAN  master_classicalbts_all
#...    CLOUD_5G_BL_AP_NSA_FS_CMWV
#...    CA_BTS_OAM_FMRECOV    QCP_BTS_OAM    QCD_MN_BTS_OAM

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions


*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***
[1.0] 5GC000470-E-a_5GC001542-CA_Check_BTS_Counters_view
#    [Tags]   CRT
    [Documentation]
    ...
    5GC000470-E-a_5GC001542-CA_Check_BTS_Counters_view

[1.0] 5GC000470-E-a_5GC001542-CA_Check_BTS_Transport_Counters
#    [Tags]   CIT
    [Documentation]
    ...
    5GC000470-E-a_5GC001542-CA_Check_BTS_Transport_Counters

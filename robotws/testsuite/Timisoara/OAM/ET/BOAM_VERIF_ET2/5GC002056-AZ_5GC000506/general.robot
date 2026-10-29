*** Settings ***
Documentation
...    Author: Monika Szlovak
...    Maintainer: Monika Szlovak
...    Test Description: Remote Syslog for continous log storage
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d /opt/ute/logs/ testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC002056-AZ_5GC000506/general.robot
...    AC/REQ: LTE_OPR_AC_4546 / LTE_OPR_REQ_7994

Resource    ./resources/5GC002056-AZ_5GC000506.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN         SBTS22R3    master_classicalbts_all
#...    CLOUD_5G_I_BO_AP_KL_NSA_L1B_ECPRI_CMWV_TDD    CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
#...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CA_BTS_OAM_FMRECOV   #SBTS21B   SBTS22R1  SBTS22R2
#regression opt
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
#[1]ABION_Remote_syslog_transmission_using_UDP_with_remoteSyslogFormat=NSN
#    [Tags]   CRT                                                   # regression optimization
#    [Documentation]
#    ...
#    Romote_syslog_transmission_using_UDP_with_remoteSyslogFormat=NSN

[1]ABION_Remote_syslog_transmission_using_UDP_with_remoteSyslogFormat=RFC5424
    [Tags]   CRT
    [Documentation]
    ...
    Remote_syslog_transmission_using_UDP_with_remoteSyslogFormat=RFC5424


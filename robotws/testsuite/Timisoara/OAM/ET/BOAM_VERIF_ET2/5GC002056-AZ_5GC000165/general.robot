*** Settings ***
Documentation
...    Author: Alin Necula (alin.necula@nokia.com)
...    Maintainer: Roxana Craciun (roxana.craciun@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC001542-CA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5G002056-AZ_5GC000165/general.robot

Resource    ./resources/5GC001542-CA.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN     CRT  master_classicalbts_all   # regression optimization
#...    CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD   CA_BTS_OAM_FMRECOV
#  QCP_BTS_OAM    QCD_MN_BTS_OAM   #21A_classicalbts   SBTS21B  SBTS22R1  SBTS22R2

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
[1.0] Check_BTS_counter_view
#    [Tags]   CRT   SBTS22R3
    [Documentation]
    ...
    5GC001542-CA_Check_BTS_counter_view

[1.0] Check_BTS_transport_counters
#    [Tags]   CIT   SBTS22R3
    [Documentation]
    ...
    5GC001542-CA_Check_BTS_transport_counters

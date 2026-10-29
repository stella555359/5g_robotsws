*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB005750_5G_EB_ET_5GC000371
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d /home/ute/logs/
...    /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB005750_5G_EB_ET_5GC000371/general_4527.robot

Resource    ./resources/CB005750_5G_EB_ET_5GC000371.robot

#Force Tags   STATE_ON_AIR  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN    SBTS22R2   master_classicalbts_all
#...    CLOUD_5G_CLASSICAL_ASIL_ABIO_AEQN_eCPRI     #SBTS22R1   SBTS00
#...    CA_BTS_OAM_FMRECOV

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
[1.0] CB005750-5G-EB-ET_5GC000371-Fault_4527_RF_crash_logs_in_technical_log_collection
    [Tags]   CRT
    [Documentation]
    ...
    CB005750-5G-EB-ET_5GC000371-Fault_4527_RF_crash_logs_in_technical_log_collection

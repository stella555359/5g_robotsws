*** Settings ***
Documentation
...    Author: George Medesan (george.medesan@nokia.com)
...    Maintainer: George Medesan (george.medesan@nokia.com)
...    Group in charge: BTS_OAM_VERIF_ET1
...    References: doors
...    Feature Description:CB007326-5G-Z_CB007422-5G
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007326-5G-Z_CB007422/general.robot


Resource    ./resources/CB007422-5G.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
#...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   SBTS00    SBTS22R4  SBTS23R1
#...    CA_RAN_BOAM_VERIF


Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions

Test Setup        Test Preconditions for CB007422
Test Teardown     Test Postconditions for CB007422

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***
2_FAULT_4592_triggering
    [Tags]   CRT
    [Documentation]
    CB007326-5G-Z_CB007422-1_Fault_4592_triggering_with_actFaultSignature

#3_FAULT_52_triggering    #merged with FAULT_4592_triggering
#    [Tags]   CRT
#    [Documentation]
#    CB007326-5G-Z_CB007422-2_Fault_4383_triggering_with_actFaultSignature

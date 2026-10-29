*** Settings ***

Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB006615-5G-A
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d /opt/ute/logs/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB006615-5G-A/general_test7.robot
...    Dryrun: /opt/ute/python/bin/robot -t "Robustness_Testing_SC_Autonomous_Reset_on_fault_detection"
...    --dryrun --log NONE --report NONE --output NONE -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE
...    testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB006615-5G-A/general_test7.robot

Resource    ./resources/CB006615-5G-A.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00    SBTS23R1   CRT
...    CLOUD_5G_CLASSICAL_FULLRACK_ASIB_3xABIL_2xAZQG
...    CA_BTS_OAM_VERIF    master_classicalbts_all   #SBTS22R3  SBTS22R4

#Suite Setup       Suite Preconditions
Suite Setup       Run Keywords      CB006615-5G-A.UTE TL Preparation
...               AND               Suite Preconditions
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
[1.0] Robustness_Testing_SC_Autonomous_Reset_on_fault_detection
    [Tags]   CRT
    [Documentation]
    ...
    Robustness_Testing_SC_Autonomous_Reset_on_fault_detection


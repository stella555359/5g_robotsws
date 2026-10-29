*** Settings ***
Documentation
...    Author: Dan Moldovan (dan.moldovan@nokia.com)
...    Maintainer: Dan Moldovan (dan.moldovan@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB007876
...    Sample execution: /opt/ute/python3/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d
...    results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007876/general.robot

Resource    ./resources/CB007876.robot
#Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN     SBTS22R4  SBTS23R1   SBTS00 
...    CLOUD_5G_CLASSICAL_MULTIGNB_ASIB_ABIL_ABIO_4xAEUD      master_classicalbts_all
...    CA_RAN_BOAM_VERIF   #SBTS22R3

Suite Setup       Run Keywords      UTE TL Preparation Dual Core
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
[1.0] 7_ROBUSTNESS TESTING_SC_Autonomous_Reset_on_fault_detection
    [Tags]   CRT    
    [Documentation]
    ...  Generate 4x Fault 2080 and expect Site Reset
    ...  At the end the Fault remains  Active
    Robustness_SC_Autonomous_Reset_on_fault_detection

#[1.0] 8_SC_fault_detection
#    [Tags]   CRT      #  test already covered by ST
#    [Documentation]
#    ...  Preconditions:
#    ...  actforceunit = false
#    SC_fault_detection

#[1.0] 1_ SC_Autonomous_Reset_on_fault_detection
#    [Tags]   CRT        #  test already covered by ST
#    [Documentation]
#    ...  Generate Fault 2080 and expect Site Reset
#    SC_Autonomous_Reset_on_fault_detection

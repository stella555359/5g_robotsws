*** Settings ***
Documentation
...   author: Tomasz Siuta
...   contact: tomasz.siuta@nokia.com
...   maintainer: tomasz.siuta@nokia.com


Resource    ./resources/suite_specific_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup    Suite Setup

*** Variables ***
${RPI_IP_ADDRESS}=    10.83.176.20
${EAC_ALARM_TRIGGER_CMD}=    cd /home/pi/Desktop && python eactestS.py p2 z 75050
${EAC_ALARM_SWITCH_OFF_CMD}=    cd /home/pi/Desktop && python eactestS.py p2 r 75050

*** Test Cases ***
CNI_125230_Interaction_with_CB009176_RU_power_off_through_3rd_FPFH_PDU_port_FSEE_connected
    [Setup]    Run keywords
    ...        Common Preconditions
    ...        AND    Connect to
    Verify if FPFHs are detected
    Verify if FSEE is detected
    Verify if no alarms regarding wrong FPFH and FSEE configuration are raised
    Lock NRCELL-1
    Wait for radio module to reach POWEROFFBYES power state
    Check RU has been powered off for energy saving
    [Teardown]    run keywords
    ...           Log Action To Console    Test teardown
    ...           AND    Unlock NRCELL-1
    ...           AND    Wait Until Keyword Succeeds    5min    1min    Check if all RUs are online
    ...           AND    Wait Until Keyword Succeeds    3min    1min    gnbcell.Verify All Cells Are Onair
    ...           AND    Common Postconditions

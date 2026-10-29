*** Settings ***
Force Tags    PY36
Documentation
...  author:  Dawid Chuchnowski, dawid.chuchnowski@nokia.com
...  maintainer:  Tomasz Siuta, tomasz.siuta@nokia.com

Resource    ./resources/suite_specific_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup    Suite Setup

*** Variables ***
${RPI_IP_ADDRESS}=    10.83.176.20
${EAC_ALARM_TRIGGER_CMD}=    cd /home/pi/Desktop && python eactestS.py p1 z 75050
${EAC_ALARM_SWITCH_OFF_CMD}=    cd /home/pi/Desktop && python eactestS.py p1 r 75050

*** Test Cases ***
CNI_121082_08_Site_Commissioning_with_FPFH_FSEE_ASIA_ASIB_configuration_4
    [Setup]    Run keywords
    ...        Common Preconditions
    ...        AND    admin.Connect to
    Verify that FPFH is detected
    Verify that FSEE is detected
    Verify that no alarms regarding wrong FPFH and FSEE configuration are raised
    Block NRCELL-1
    Wait for radio module to reach POWEROFFBYES power state
    Check RU has been powered off for energy saving
    Trigger alarm via EAC controller    rpi_address=${RPI_IP_ADDRESS}    command=${EAC_ALARM_TRIGGER_CMD}
    Verify that external alarm is raised
    [Teardown]    run keywords
    ...           Log Action To Console    Test teardown
    ...           AND    Switch off alarm from EAC controller    rpi_address=${RPI_IP_ADDRESS}    command=${EAC_ALARM_SWITCH_OFF_CMD}
    ...           AND    Unblock NRCELL-1
    ...           AND    Wait Until Keyword Succeeds    5min    1min    Check that all RUs are online
    ...           AND    Wait Until Keyword Succeeds    3min    1min    gnbcell.Verify All Cells Are Onair
    ...           AND    Common Postconditions


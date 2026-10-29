*** Settings ***
Documentation
...    Testsuite for regression testing of feature CB007306
...    author: Szymon Skorupski, Aleksander Lagierski
...    maintainer: Aleksander Lagierski
...    contact: szymon.skorupski@nokia.com, aleksander.lagierski@nokia.com

Resource    ../../../procedures/SFP_Monitoring/procedure.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   ./resources/variables.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms


*** Test Cases ***
[1]CB007306-SR-A_4_CB007306 Initiate SFP Monitoring from WebEM for ASIx(dynamic data)
    [TIMEOUT]    20h
    Initiate Smod Sfp Monitoring

[1]CB007306-SR-A_20_CB007306 Initiate SFP Monitoring from WebEM for RU (dynamic data)
    Initiate Ru Sfp Monitoring    rmod_device=RMOD_R-2    devices_list=${cb7306_rmod_test_devices_list}

[1]CB007306-SR-A_21_CB007306 Dynamic SFP Parameters saved into PM counters for ABIL
    Check Dynamic SFP Parameters Saved Into PM Counters For ABIL

[1]CB007306-SR-A_11_CB007306 Dynamic SFP Parameters saved into PM counters for RU
    Check Dynamic SFP Parameters Saved Into PM Counters For RU

[1]CB007306-SR-A_12_CB007306 Retrieve periodic SFP QSFP Snapshot data
    Check Dynamic SFP Parameters Saved Into PM Counters For ABIL
    Check Dynamic SFP Parameters Saved Into PM Counters For RU

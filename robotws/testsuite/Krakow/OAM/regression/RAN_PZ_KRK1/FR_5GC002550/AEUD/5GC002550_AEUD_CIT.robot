*** Settings ***
Documentation
...    This test suite is to cover OAM CIT regression for FR 5GC002550 for 20B, 21A and trunk.
...    Current version of test suite:
...    Author: Szymon Skorupski
...    Contact: szymon.skorupski@nokia.com
...    Original version of test cases:
...    Authors: Kamil Ostrzolek, Kinga Starczan, Aleksandra Radziejewska
...    Contact: kamil.ostrzolek@nokia.com, kinga.starczan@nokia.com, aleksandra.radziejewska@nokia.com

Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    ../../../../procedures/SFP_Monitoring/procedure.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms


*** Test Cases ***
[1]5GC002181-D-a-Initiate_SFP_Monitoring_from_WemEM_for_ASIx(static_data-Temperature_parameters)
    Initiate Smod Sfp Monitoring For Static Parameters

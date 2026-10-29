*** Settings ***
Documentation
...    author/contact: Anna Gryglak/anna.gryglak@nokia.com
...    maintainer/contact: Anna Gryglak/anna.gryglak@nokia.com

Resource    ./resources/keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup    Common Suite Setup With OnAir Test Line Preparation
Suite Teardown    Common Suite Teardown



*** Test Cases ***
[1][1.0] Repeated_Pre-activate_plan_from_NMS
    [Timeout]    1h
    [Tags]    NMS
    [Setup]    Run Keywords    Test Setup    service_name=cmwas
    ...        AND             Upload ASI Configuration
    Pre-activate New Configuration Plan
    [Teardown]    Test Teardown    service_names=cmwas

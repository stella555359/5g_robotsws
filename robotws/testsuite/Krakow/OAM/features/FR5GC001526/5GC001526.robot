*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases 5GC001526

Library    ./Resources/BBSubUnit.py
Resource   taf/rfrl/bts/robot/gnb.robot
Resource   taf/rfrl/bts/robot/logs_collecting.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup         Preconditions
Suite Teardown      Postconditions
Test Setup          Common Preconditions
Test Teardown       Common Postconditions


*** Test Cases ***
5GC001526_BA_11_BB_sub-unit_reset
    Reset Capacity Unit From GUI
    Verify ASIK status
    Verify Ru Status After Restart
    Verify All Cell Status  cell_status=Disabled
    Verify ASIK status
    Wait For Ru
    Wait For Site To Be Onair

*** Keywords ***
Preconditions
    Setup Logs Collectors
    Wait For Site To Be Onair
Postconditions
    Teardown Logs Collectors

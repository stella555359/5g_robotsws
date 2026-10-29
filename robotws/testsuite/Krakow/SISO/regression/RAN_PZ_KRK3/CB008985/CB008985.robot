*** Settings ***
Documentation
...   Test suite for regression testing of feature CB008985 CRT
...   author: Szymon Laba
...   contact: szymon.laba@nokia.com
...   mainteiner: szymon.laba@nokia.com

Resource    ./resources/CB008985_keywords.robot

Suite Setup     Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
...                                                                  should_5G_neighbour_be_changed=${False}
...                                                                  swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                                                                  list_of_additional_allowed_alarms=@{CUSTOM_ALARMS}

Suite Teardown      Common Suite Teardown

Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Common Postconditions With Watching Alarms


*** Test Cases ***

[1]CB008985-SR-A_2_configuration_1_TDD_supercell
   [Documentation]
    ...    1.Configure one NR 100M supercell with 6 subcells;
    [Tags]   TC01_TC02
    Prepare Ue
    Perform L3 call on Cell-0 (supercell)
    Load Config1 for BTS and ASiR and wait for onair

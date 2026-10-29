*** Settings ***
Documentation
...    Author: Dominik Wieczorek
...    Maintainer: Patrycja Szmerek
...    Group in charge: MI_MN_RAN_RD_VRF_KRK_7
...    References: RDI-23860
...    Feature Description:EDA-04634384

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library     ./resources/leoni_switch.py

Suite Setup    Custom Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms

*** Variables ***
@{PREPARATION_ALARMS}       No connection to unit
...                         Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...                         Cell Activation timeout at gNB-DU
...                         Cell problem due to unavailability of associated links

@{CUSTOM_ALLOWED_ALARMS}    4589    4592    1815    1956    10

*** Test Cases ***
Link_breaks_for_at_least_8_minutes_in_0.5_second_interval_using_Leoni_switch
    [Tags]    leoni
    leoni_switch.Link Brake While
    Wait Until Keyword Succeeds    5min    10s    gnbcell.Verify All Cells Are Onair

*** Keywords ***
Custom Suite Setup
    Run Keywords    Run Keyword And Ignore Error    tl_prep.prepare_testline    should_LTE_neighbour_be_changed=${False}
    ...                                                              should_5G_neighbour_be_changed=${False}
    ...                                                              wait_for_on_air=${False}
    ...                                                              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...                                      AND    Common Suite Setup With OnAir Test Line Preparation
    ...                                                              should_LTE_neighbour_be_changed=${True}
    ...                                                              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...                                                              list_of_additional_allowed_alarms=${PREPARATION_ALARMS}

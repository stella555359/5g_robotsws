*** Settings ***
Documentation
...    author: Slawomir Szopinski, slawomir.szopinski@nokia.com
...    maintainer: Slawomir Szopinski, slawomir.szopinski@nokia.com

Resource    ./resources/keywords.robot
Resource    ./resources/UE_keywords.robot

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               increase_timeout_for_update_sw=1800
...               list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms

Test Teardown     Common Postconditions With Watching Alarms

*** Variables ***
@{CUSTOM_ALLOWED_ALARMS}    RAT Service Outage    Failure in connection between BTS and 3rd party tool

*** Test Cases ***
[1][1.0] CB013662-SR-A#3_NR_dedicated_mode_-NBF_4T4R_up_to_4_carriers
    Prepare Ue
    Perform L3Call on 15MHz Cell

[1][1.0] CB013662-SR-A#2_15MHz_CA_IntraBand_2CC_n41_15MHz_PCell_30MHz_SCell_configuration
    Prepare Ue
    Perform L3Call on 15MHz PCell and 30MHz SCell

[1][1.0] CB013662-SR-B#2_Mix_slim_carrier_with_normal_carrier_configuration_up_to_4_carriers_in_4T4R_mode_n41_CA_2CC_IntraBand_SA
    Prepare Ue
    Perform L3Call on 49.5MHz PCell and 15MHz SCell

[1][1.0] CB013662-SR-B_General_SiSo_Cell_Lock_Unlock
    Prepare Ue
    Perform L3Call with Cell Lock on 49.5MHz

[1][1.0] CB013662-SR-B-Random_Operation
    [Setup]    Common Preconditions    collect_syslog=${False}
    Random OAM Operations
    [Teardown]    Common Postconditions    collect_syslog=${False}

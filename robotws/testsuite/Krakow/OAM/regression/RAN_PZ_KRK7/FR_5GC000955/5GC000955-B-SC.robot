*** Settings ***
Documentation
...    Author: Lubomir Krzeminski (lubomir.krzeminski@nokia.com)
...    Maintainer: Lubomir Krzeminski (lubomir.krzeminski@nokia.com)
...    Group in charge: RAN_VRF_KRK_7
...    Feature Description: 5GC000955-B

Resource    resources/CommonKeywords_5GC000955.robot
Library     on_air_tl_preparation.testline_preparation_resources


Suite Setup    Run Keywords    Get SCF location    AND
...                            Common Suite Setup With OnAir Test Line Preparation
...                                                                   should_LTE_neighbour_be_changed=${False}
...                                                                   should_5G_neighbour_be_changed=${False}
...                                                                   increase_time_for_checking_bbmod=600
...                                                                   increase_timeout_for_update_sw=1800
...                                                                   increase_time_for_checking_radios=2100
...                                                                   increase_time_for_checking_cells=700
...                                                                   swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                                                                   scfs_path=${RELEASE}/5GC000955
...                                                                   list_of_additional_allowed_alarms=@{ADDITIONAL_ALLOWED_ALARMS}

Suite Teardown    Common Suite Teardown
Test Setup       Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Transmission path failure
...                                                                               User Account has Default Password
...                       AND    Common Preconditions With Watching Alarms
Test Teardown    Run Keywords    Common Postconditions With Watching Alarms
...                       AND    ADMIN CLI disconnection

*** Variables ***
@{ADDITIONAL_ALLOWED_ALARMS}    Failure detected on assigned antennas
...                             Antennas assignment not available
...                             User Account has Default Password

*** Keywords ***
Get SCF location
    ${RELEASE}=    Get Scf Path    ${ENB_BUILD}
    Set Suite Variable    ${RELEASE}


*** Test Cases ***
[1][1.0] 5GC000955_Lock_Unlock_Single_SFP_Check_Cell_Recalculation
    [Documentation]
    ...  Lock_Unlock_SFP_SMOD via WebEM (1 of 2 links)
    ADMIN CLI connection
    Set bts parameter    dist_name=MRBTS-85092/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1   param_name=administrativeState    param_value=Locked
    Sleep    2min
    Set bts parameter    dist_name=MRBTS-85092/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1   param_name=administrativeState    param_value=Unlocked
    Wait Until Keyword Succeeds    60 sec    5 sec   gnbcell.Verify All Cells Are Onair

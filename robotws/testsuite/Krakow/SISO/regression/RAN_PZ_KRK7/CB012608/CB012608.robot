*** Settings ***
Documentation
...    author:
...     - Michał Chrzanowski (michal.a.chrzanowski@nokia.com)
...    maintainers:
...     - Michał Chrzanowski
...    contact:
...     - Michał Chrzanowski
...     - Nelsadnro Sampaio (nelsandro.sampaio@nokia.com)
...
...    feature: CB012608
...
...    Introduction: This feature contains legacy content with features up to 25R2 release (including Long Lead Features).
...    Main legacy items in scope of the feature: NR FR2.
...    CB012608 feature:
...     - provides eCPRI 7.2a FR2 TDD L3 call to ASOG|H,
...     - introduces selected NR FR2 legacy features to ASOG|H.
...
...    Testing Scope: CB012608_D_1_opt_port_lock_unlock_with_additional_l3call

Library     taf.rfrl.utilities.logger.custom_logger    WITH NAME    logger
Resource    resources/keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation   should_LTE_neighbour_be_changed=${False}
...                                                                     should_5G_neighbour_be_changed=${False}
...                                                                     increase_time_for_checking_bbmod=600
...                                                                     increase_timeout_for_update_sw=1800
...                                                                     increase_time_for_checking_radios=2100
...                                                                     increase_time_for_checking_cells=700
...                                                                     list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREP}
...                                                                     swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                                                                     prefix_tag=25R3_N_CB012455_5b
...                                                                     should_LTE_neighbour_be_changed=${True}

Suite Teardown      Common Suite Teardown

Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Common Postconditions With Watching Alarms

*** Variables ***
${sfp_lanes}                                MRBTS-${tl.gnbs[0].global_bts_id}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1
${COLLECT_MANDATORY_LOGS}                   ${False}
@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREP}     7107  61673

*** Test Cases ***
[1][2.0] CB012608_D_1_opt_port_lock_unlock_with_additional_l3call
    Prepare Ue for L3 Call    alias=UE2    capabilities=COMMERCIAL_UE   reboot_ue=False
    Prepare Ue for L3 Call    alias=UE3    capabilities=COMMERCIAL_UE   reboot_ue=False
    Lock and unlock SFP LANE and check alarms    ${sfp_lanes}
    Attach UE3
    Start and Verify TCP DL and UL data transfer for UE    ue_alias=UE3    dl_tput=4200 Mbits/sec    ul_tput=550 Mbits/sec
    Perform reconfiguration parameter
    Attach UE3
    Start and Verify TCP DL and UL data transfer for UE    ue_alias=UE3    dl_tput=4200 Mbits/sec    ul_tput=550 Mbits/sec
    [Teardown]      Run Keywords
    ...             Detach UE3  AND
    ...             Common Postconditions

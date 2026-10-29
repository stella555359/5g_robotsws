*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010652-B
...   author:  Marek Szlapa
...   contact: marek.szlapa@nokia.com

Resource     taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_reset_from_WebUI.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     ./resources/CB010652_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/configuration_variables.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               prefix_tag=CB010652B
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms


*** Variables ***
${config}    configB
${ABIN_id}   1
@{odd_overlapping_cells}     1  3  11
@{even_overlapping_cells}    2  4  12

*** Test Cases ***
General_SiSo_Auto_RU_module_reset_from_GUI
    [Setup]     Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Antennas assignment not available
    ...         AND
    ...         Common Preconditions With Watching Alarms
    General SiSo Auto RF module reset from WebUI    runs=1
    Call to selected cells    cells_info=${configurations}[${config}]
    ...                       selected_cells_ids=${configurations}[${config}][selected_cells_per_TC][RU_Reset]

CB010652_ASiR_pRRH_Block_Unblock_with_ASiRWebEM
    [Setup]     Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Failure detected on assigned antennas
    ...         AND
    ...         Common Preconditions With Watching Alarms and cells set to barred    cells=${even_overlapping_cells}
    Block Unblock all pRRHs via ASIRWebEM
    Call to selected cells    cells_info=${configurations}[${config}]
    ...                       selected_cells_ids=${configurations}[${config}][selected_cells_per_TC][pRRH_Block_Unblock]
    [Teardown]    Common Postconditions With Watching Alarms and cells set to unbarred   cells=${even_overlapping_cells}

CB010652_ASiR_pRRH_Reset_with_ASiRWebEM
    [Setup]     Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Failure detected on assigned antennas
    ...                                                                         Transmission path failure
    ...         AND
    ...         Common Preconditions With Watching Alarms and cells set to barred    cells=${odd_overlapping_cells}
    Reset all pRRHs via ASIRWebEM
    Call to selected cells    cells_info=${configurations}[${config}]
    ...                       selected_cells_ids=${configurations}[${config}][selected_cells_per_TC][pRRH_Reset]
    [Teardown]    Common Postconditions With Watching Alarms and cells set to unbarred    cells=${odd_overlapping_cells}

CB010652_BBMOD_Lock_Unlock
    Lock Unlock BBMOD         bbmod_id=${ABIN_id}
    Call to selected cells    cells_info=${configurations}[${config}]
    ...                       selected_cells_ids=${configurations}[${config}][selected_cells_per_TC][BBMOD_Lock_Unlock]

CB010652_BBMOD_Reset
    [Setup]    Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    NgGnbInitFullReset
    ...        AND
    ...        Common Preconditions With Watching Alarms
    Reset BBMOD               bbmod_id=${ABIN_id}
    Call to selected cells    cells_info=${configurations}[${config}]
    ...                       selected_cells_ids=${configurations}[${config}][selected_cells_per_TC][BBMOD_Reset]

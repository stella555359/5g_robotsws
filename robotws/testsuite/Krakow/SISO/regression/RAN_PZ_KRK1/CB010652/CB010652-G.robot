*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010652-G
...   author:  Marek Szlapa
...   contact: marek.szlapa@nokia.com

Resource     taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Auto_gNB_Site_Reset_From_WebUI.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_reset_from_WebUI.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     ./resources/CB010652_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/configuration_variables.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               prefix_tag=CB010652G
...               list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms


*** Variables ***
${config}             configG
@{even_overlapping_cells}    7  9  11  13  15  17  19  21  23
@{odd_overlapping_cells}     8  10  12  14  16  18  20  22  24
${add_del_cell_id}    ${4}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  4479

*** Test Cases ***
[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Setup]    Common Preconditions With Watching Alarms and cells set to barred    cells=${odd_overlapping_cells}
    General SiSo E2E system setup with data transfer for configuration feature testing
    ...     config=${config}
    ...     UL_attenuation=28
    [Teardown]    Common Postconditions With Watching Alarms and cells set to unbarred    cells=${odd_overlapping_cells}

[1][3.0] General_SiSo_Cell_block_and_unblock
    [Setup]    Common Preconditions With Watching Alarms and cells set to barred    cells=${even_overlapping_cells}
    General SiSo Cell block and unblock
    Call to selected cells    cells_info=${configurations}[${config}]
    ...                       selected_cells_ids=${configurations}[${config}][selected_cells_per_TC][Cell_Bock_Unblock]
    [Teardown]    Common Postconditions With Watching Alarms and cells set to unbarred   cells=${even_overlapping_cells}

[1][1.0] General_SiSo_Auto_gNB_Site_Reset_From_WebUI
    General SiSo Auto gNB Site Reset From WebUI

[1]General_SiSo_Auto_RU_module_reset_from_GUI
    [Setup]     Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Antennas assignment not available
    ...         AND
    ...         Common Preconditions With Watching Alarms and cells set to barred    cells=${even_overlapping_cells}
    General SiSo Auto RF module reset from WebUI    runs=1
    Call to selected cells    cells_info=${configurations}[${config}]
    ...                       selected_cells_ids=${configurations}[${config}][selected_cells_per_TC][RU_Reset]
    [Teardown]    Common Postconditions With Watching Alarms and cells set to unbarred   cells=${even_overlapping_cells}

[1][1.0] CB010652_ASiR_pRRH_Block_Unblock_with_ASiRWebEM
    [Setup]     Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Failure detected on assigned antennas
    ...         AND
    ...         Common Preconditions With Watching Alarms and cells set to barred    cells=${even_overlapping_cells}
    Block Unblock all pRRHs via ASIRWebEM
    Call to selected cells    cells_info=${configurations}[${config}]
    ...                       selected_cells_ids=${configurations}[${config}][selected_cells_per_TC][pRRH_Block_Unblock]
    [Teardown]    Common Postconditions With Watching Alarms and cells set to unbarred   cells=${even_overlapping_cells}

[1][1.0] CB010652_ASiR_pRRH_Reset_with_ASiRWebEM
    [Setup]     Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Failure detected on assigned antennas
    ...                                                                         Transmission path failure
    ...         AND
    ...         Common Preconditions With Watching Alarms and cells set to barred    cells=${odd_overlapping_cells}
    Reset all pRRHs via ASIRWebEM
    Call to selected cells    cells_info=${configurations}[${config}]
    ...                       selected_cells_ids=${configurations}[${config}][selected_cells_per_TC][pRRH_Reset]
    [Teardown]    Common Postconditions With Watching Alarms and cells set to unbarred    cells=${odd_overlapping_cells}

[1][1.0] CB010652_BBMOD_Lock_Unlock
    [Setup]    Common Preconditions With Watching Alarms and cells set to barred    cells=${even_overlapping_cells}
    Lock Unlock BBMOD
    Call to selected cells    cells_info=${configurations}[${config}]
    ...                       selected_cells_ids=${configurations}[${config}][selected_cells_per_TC][BBMOD_Lock_Unlock]
    [Teardown]    Common Postconditions With Watching Alarms and cells set to unbarred   cells=${even_overlapping_cells}

[1][1.0] CB010652_BBMOD_Reset
    [Setup]    Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    NgGnbInitFullReset
    ...        AND
    ...        Common Preconditions With Watching Alarms and cells set to barred    cells=${odd_overlapping_cells}
    Reset BBMOD
    Call to selected cells    cells_info=${configurations}[${config}]
    ...                       selected_cells_ids=${configurations}[${config}][selected_cells_per_TC][BBMOD_Reset]
    [Teardown]    Common Postconditions With Watching Alarms and cells set to unbarred    cells=${odd_overlapping_cells}

[1][1.0] CB010652_General_SiSo_Online_Cell_Addition_Deletion
    [Setup]     Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Antennas assignment not available
    ...         AND
    ...         Common Preconditions With Watching Alarms and cells set to barred    cells=${odd_overlapping_cells}
    CB010652_General_SiSo_Online_Cell_Addition_Deletion    config=${config}    cell_id=${add_del_cell_id}
    [Teardown]    Common Postconditions With Watching Alarms and cells set to unbarred    cells=${odd_overlapping_cells}

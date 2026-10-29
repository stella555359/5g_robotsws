*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010652-D1
...   author:  Marek Szlapa
...   contact: marek.szlapa@nokia.com

Resource     taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Auto_gNB_Site_Reset_From_WebUI.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     ./resources/CB010652_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/configuration_variables.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               prefix_tag=CB010652D
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms


*** Variables ***
${config}             configD
${add_del_cell_id}    ${1}

*** Test Cases ***
[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    General SiSo E2E system setup with data transfer for configuration feature testing
    ...     config=${config}

[1][2.0] General_SiSo_Cell_block_and_unblock
    General SiSo Cell block and unblock
    Call to selected cells    cells_info=${configurations}[${config}]
    ...                       selected_cells_ids=${configurations}[${config}][selected_cells_per_TC][Cell_Bock_Unblock]

[1][1.0] General_SiSo_Auto_gNB_Site_Reset_From_WebUI
    General SiSo Auto gNB Site Reset From WebUI

[1]CB010652_General_SiSo_Online_Cell_Addition_Deletion
    [Setup]     Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Antennas assignment not available
    ...         AND
    ...         Common Preconditions With Watching Alarms
    CB010652_General_SiSo_Online_Cell_Addition_Deletion    config=${config}    cell_id=${add_del_cell_id}

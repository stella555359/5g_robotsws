*** Settings ***
Documentation
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com
...    description: CRT test suite of feature CB010348 - ABIP part

Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../resources/robot/Ethernet_mode_reconfiguration_during_BTS_runtime.robot

Library     ../resources/python/DataTransferOperations.py    WITH NAME    data_transfer

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/variables.py
Variables   ./resources/deltas.py

Suite Setup     Run Keywords
...             gnbbbu.upload_swconfig  sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt
...             AND    Common Suite Setup With Commissioning
Suite Teardown  Common Suite Teardown
Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms

*** Variables ***
${dt_duration}              600s

*** Test Cases ***
CB010348_ABIP_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    data_transfer.start_multi_sector_tcp_data_transfer_dl_and_ul
    ...    sectors_dt_info=${SECTORS_DATA_TRANSFER_INFO_TL137}
    ...    duration=${dt_duration}

CB010348_CB008502-SR-B_05_SFP56_AWKUC_Ethernet_mode_reconfiguration_during_BTS_runtime
    Ethernet_mode_reconfiguration_during_BTS_runtime
    ...    delta_reconfigure_ethernet_mode=${DELTA_ETHERNET_MODES}
    ...    online_cells_in_ethernet_mode=${ONLINE_CELLS_IN_ETHERNET_MODES}
    ...    delta_default_ethernet_mode=${DELTA_DEFAULT_ETHERNET_MODE['eCpri50']}

*** Settings ***
Documentation
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com
...    description: CRT test suite of feature CB010348 - ASOF part

Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_BTS_Site_Reset.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_Radio_Module_Lock_Unlock.robot
Resource    ../resources/robot/RF_Module_Reset_Check_Radio_Startup_Time.robot
Resource    ../resources/robot/NR_cell_lock_unlock_administrative_state_change.robot

Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library     ../resources/python/DataTransferOperations.py    WITH NAME    data_transfer

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/variables.py
Variables   ./resources/deltas.py

Suite Setup     Run Keywords
...             gnbbbu.upload_swconfig  sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt
...             AND    Common Suite Setup With Commissioning
Suite Teardown  Common Suite Teardown
Test Setup      Run Keywords
...             Common Preconditions
...             AND    Set Test Variable    ${logs_path}    ${LOG_PATH}
...             AND  Start alarms watchdog    on_enb=${False}
Test Teardown   Run Keywords
...             Check alarms and stop watchdog    on_enb=${False}    reset_allowed_alarms_gnb=${False}
...             AND  Common Postconditions


*** Test Cases ***
CB010348_CB009460_NonCooled-SFP_Common_SiSo_Recovery_RF module reset_Check_Radio_Startup_Time
    [Setup]     Common Preconditions With Watching Alarms
    RF_Module_Reset_Check_Radio_Startup_Time
    ...    target_startup_time=${130}
    [Teardown]  Common Postconditions With Watching Alarms

CB010348_ASOF_Manual_SiSo_SM_BTS_Site_Reset
    data_transfer.start_multi_sector_tcp_data_transfer_dl_and_ul
    ...    sectors_dt_info=${SECTORS_DATA_TRANSFER_INFO_TL025}
    General_SiSo_Auto_BTS_Site_Reset
    data_transfer.start_multi_sector_tcp_data_transfer_dl_and_ul
    ...    sectors_dt_info=${SECTORS_DATA_TRANSFER_INFO_TL025}

CB010348_ASOF_Manual_SiSo_SM_NR_cell_lock_unlock_administrative_state_change_from_GUI
    [Setup]     Common Preconditions With Watching Alarms
    NR_cell_lock_unlock_administrative_state_change
    ...    sectors_dt_info=${SECTORS_DATA_TRANSFER_INFO_TL025}
    [Teardown]  Run Keywords
    ...    Common Postconditions With Watching Alarms
    ...    AND    Run Keyword If Test Failed    gnbcell.unlock all cells    administrative_state=${True}

CB010348_ASOF_Manual_SiSo_SM_RF_Module_lock_unlock
    data_transfer.start_multi_sector_tcp_data_transfer_dl_and_ul
    ...    sectors_dt_info=${SECTORS_DATA_TRANSFER_INFO_TL025}
    General_SiSo_Auto_Radio_Module_Lock_Unlock
    data_transfer.start_multi_sector_tcp_data_transfer_dl_and_ul
    ...    sectors_dt_info=${SECTORS_DATA_TRANSFER_INFO_TL025}

*** Settings ***
Documentation
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com
...    description: CRT test suite of feature CB009251

Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
Resource    taf/rfrl/procedures/resources/robot/Alarms.robot
Resource    taf/rfrl/procedures/SISO/CB008990/CB008990_DDR_Memory_POST_test_failed_fast.robot
Resource    ../resources/robot/IQ_Data_Collect_by_L1high_Uplink_Suspicious_Event.robot
Resource    ../resources/robot/CB009275_Feature_Enable_with_Fault_1932_actived.robot

Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library    taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    gnbscf
Library    taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    gnbalarm
Library    ../resources/python/DataTransferOperations.py    WITH NAME    data_transfer
Library    ../resources/python/RadioOperations.py   WITH NAME    radio_keywords

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   resources/deltas.py
Variables   resources/variables.py

Suite Setup         Run Keywords
...                 gnbbbu.upload_swconfig  sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                 AND    Common Suite Setup With Commissioning
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Common Postconditions With Watching Alarms

*** Test Cases ***
CB009251_CB008004-SR-CE_TC06_eCPRI_feature_activation_in_runtime
    gnbalarm.Allow Alarm            alarm=No X2 link available
    gnbalarm.Allow Alarm            alarm=No X2 link available for a specific LTEENB
    gnbscf.Perform BTS Delta Commissioning    delta=${ACTIVATE_TIMING_OFFSET['GNB0']}    bts_id=${0}
    gnbcell.Wait For All Cells to be OnAir    timeout=300    interval=30
    data_transfer.start_multi_sector_tcp_data_transfer_dl_and_ul
    ...    sectors_dt_info=${SECTORS_DATA_TRANSFER_INFO_T01SK127}
    [Teardown]    Run Keywords
    ...           Common Postconditions With Watching Alarms
    ...           AND    gnbscf.Perform BTS Delta Commissioning  delta=${DEACTIVATE_TIMING_OFFSET['GNB0']}  bts_id=${0}
    ...           AND    gnbcell.Wait For All Cells to be OnAir    timeout=300    interval=30

CB009251_CB008990_DDR_Memory_POST_test_failed
    [Setup]   Run Keywords
    ...       Common Preconditions
    ...       AND  Prepare Logs Path
    ...       AND  Start alarms watchdog    on_enb=${False}
    ...       AND  Allow X2 Link Alarms
    CB008990_DDR_Memory_POST_test_failed_fast  rmod_id=${AWKUC_ID}
    [Teardown]   Run Keywords
    ...       Check alarms and stop watchdog    on_enb=${False}
    ...       AND  Common Postconditions

CB009251_02_CB009275_Feature_Enable_with_Fault_1932_actived
    CB009275_Feature_Enable_with_Fault_1932_actived

CB009251_CB005914-B_008_IQ_Data_Manually_Collect_by_L1high_Uplink_Suspicious_Event
    ${RU_SN}=    radio_keywords.get_radio_unit_serial_number    ru_id=${AWKUC_ID}
    IQ_Data_Collect_by_L1high_Uplink_Suspicious_Event
    ...    ul_nr_subcell_list=${IQ_DATA_UL_SUBCELL_LIST}
    ...    capture_ru_list=${IQ_DATA_CAPTURE_RU_LIST}
    ...    dt_info=${SECTORS_DATA_TRANSFER_INFO_T01SK127['SECTOR_0']}
    ...    regex_iq_data_file=${RU_SN}_RMOD_L_1.*fcpTriggeredCapture.*

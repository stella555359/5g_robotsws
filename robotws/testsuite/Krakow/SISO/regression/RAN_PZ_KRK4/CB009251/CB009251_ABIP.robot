*** Settings ***
Documentation
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com
...    description: CRT test suite of feature CB009251

Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/Alarms.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/resources/robot/LogCollection.robot
Resource    taf/rfrl/procedures/SISO/CB008990/CB008990_DDR_Memory_POST_test_failed_fast.robot
Resource    ../resources/robot/CB009275_Feature_Enable_with_Fault_1932_actived.robot

Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library    taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    gnbscf
Library    taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    gnbalarm
Library    ../resources/python/DataTransferOperations.py    WITH NAME    data_transfer

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   resources/deltas.py
Variables   resources/variables.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...                       increase_timeout_for_update_sw=${1800}
...                       list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
...                       swconfig_from_path=${SWCONFIG_PATH}
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms

*** Variables ***
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  ${None}
${SWCONFIG_PATH}

*** Test Cases ***
CB009251_CB008004-SR-CE_TC06_eCPRI_feature_activation_in_runtime
    gnbalarm.Allow Alarm            alarm=No X2 link available
    gnbalarm.Allow Alarm            alarm=No X2 link available for a specific LTEENB
    gnbscf.Perform BTS Delta Commissioning    delta=${ACTIVATE_TIMING_OFFSET['GNB0']}    bts_id=${0}
    gnbcell.Wait For All Cells to be OnAir    timeout=300    interval=30
    data_transfer.start_multi_sector_tcp_data_transfer_dl_and_ul
    ...    sectors_dt_info=${SECTORS_DATA_TRANSFER_INFO_T01SK137}
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

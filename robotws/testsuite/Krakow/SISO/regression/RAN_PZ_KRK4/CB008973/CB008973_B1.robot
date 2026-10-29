*** Settings ***
Documentation
...    author: Weronika Wojcik
...    contact: weronika.wojcik@nokia.com
...    description: Test Suite CB008973 B4

Library     taf.ue
Library     taf.rfrl.bts.commissioning
Resource    taf/rfrl/bts/robot/common/gnb_alarm.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB008973/resources/DataTransfer.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB008973/resources/SiSo_Auto_BTS_Site_Reset.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB008973/resources/SiSo_Cell_block_and_unblock.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB008973/resources/SiSo_Auto_Collect_RFSW_logs_from_RU.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB008973/resources/SiSo_Auto_CM_Recommissioning.robot

Suite Setup     Common Suite Setup With Commissioning    asir_hub=${True}
Suite Teardown  Common Suite Teardown
Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms

*** Variables ***
${GNB_ID}       ${tl.gnbs[0].global_bts_id}

*** Test Cases ***
CB008973-5G-B1_5_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    gnb_alarm.Allow Alarm  alarm=BTS Reset Cause
    ${RFSW_LOGS} =  generate_required_rfsw_log_names    unit_type=core_unit
    General SiSo Auto Collect RFSW logs from RU into BTS Snapshot  mandatory_logs=${RFSW_LOGS}

CB008973-5G-B1_1_Manual_SiSo_CM_Recommissioning
    gnb_alarm.Allow Alarm  alarm=BTS Reset Cause
    Parameter modification with autonomus BTS restart
    ...  dist_name=MRBTS-${GNB_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...  parameter=Time zone
    ...  value=(GMT+1) CET
    Parameter online modification
    ...  dist_name=MRBTS-${GNB_ID}/MNL-1/AMGR-1/LUAC-1
    ...  incorrect_value=13
    ...  correct_value=7
    ...  parameter=BTS maximum failed login attempts

CB008973-5G-B1_148_SiSo_Commissioning_BTS_Template_Commissioning
    gnb_alarm.Allow Alarm  alarm=BTS Reset Cause
    General SiSo Comissioning BTS Template Comissioning
    ...  dist_name=MRBTS-${GNB_ID}/MNL-1/MNLENT-1/SYNC-1
    ...  incorrect_value=100000
    ...  correct_value=5
    ...  parameter=Manual frame timing adjustment

CB008973-5G-B1_2_General_SiSo_Cell_block_and_unblock
    General SiSo Cell block and unblock
    Run TCP Data Transfer For NR Cells    deviation=40%

CB008973-5G-B1_7_Manual_SiSo_CALL_LTE_data_call
    Run TCP Data Transfer For LTE Cells    deviation=10%

CB008973-5G-B1_6_Manual_SiSo_SM_LTE Cell_block_unblock
    General SiSo Cell block and unblock
    Run TCP Data Transfer For LTE Cells     deviation=20%

CB008973-5G-B1_3_Manual_SiSo_SM_BTS_Site_Reset
    General SiSo Auto BTS Site Reset
    Run TCP Data Transfer For LTE Cells   deviation=20%
    Stop Using Ue    UE
    Run TCP Data Transfer For NR Cells     deviation=40%

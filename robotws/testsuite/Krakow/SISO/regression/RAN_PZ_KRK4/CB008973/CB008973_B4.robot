*** Settings ***
Documentation
...    author: Weronika Wojcik
...    contact: weronika.wojcik@nokia.com
...    description: Test Suite CB008973 B4

Library     taf.rfrl.bts.commissioning
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB008973/resources/SiSo_Auto_Collect_RFSW_logs_from_RU.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB008973/resources/SiSo_Auto_CM_Recommissioning.robot
Resource    taf/rfrl/bts/robot/common/gnb_alarm.robot

Suite Setup     Common Suite Setup With Commissioning    asir_hub=${True}
Suite Teardown  Common Suite Teardown
Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms

*** Variables ***
${GNB_ID}       ${tl.gnbs[0].global_bts_id}

*** Test Cases ***
CB008973-5G-D3_50_Manual_SiSo_CM_Recommissioning
    Parameter modification with autonomus BTS restart
    ...  dist_name=MRBTS-${GNB_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...  parameter=Time zone
    ...  value=(GMT+1) CET
    Parameter online modification
    ...  dist_name=MRBTS-${GNB_ID}/MNL-1/AMGR-1/LUAC-1
    ...  incorrect_value=15
    ...  correct_value=7
    ...  parameter=BTS maximum failed login attempts

CB008973-5G-D3_54_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    ${RFSW_LOGS} =  generate_required_rfsw_log_names    unit_type=common_unit
    General SiSo Auto Collect RFSW logs from RU into BTS Snapshot  mandatory_logs=${RFSW_LOGS}


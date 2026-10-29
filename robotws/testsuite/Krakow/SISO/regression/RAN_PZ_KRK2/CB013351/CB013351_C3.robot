*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB013351
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Resource          testsuite/Krakow/SISO/regression/RAN_PZ_KRK2/CB013351/CB013351_keywords.robot
Variables         variables/variables_C3.py

Suite Setup       Common suite setup with onAir Test Line preparation
...               swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT11SK100/default_swconfig.txt
...               list_of_additional_allowed_alarms=${additional_allowed_alarms}
...               prefix_tag=CB013351
Suite Teardown    Common suite teardown
Test Teardown     Common postconditions with watching alarms

*** Variables ***
${UE}                                     QC
${COLLECT_LOGS_DURING_DATA_TRANSFER}      ${False}
${ENABLE_RACH_OBSERVER}                   ${False}

*** Test Cases ***
[1][1.0] CB013351_Config3_Manual_SiSo_SM_Cell_Block_Unblock_border_NRARFCN
    [Setup]    CB013351 Common test setup    tc_cell_operation_list=@{c3_setup}
    Perform Android UE L3 call on all cells using qrxlevmin    cells_for_l3_call=&{c3_tc17_cells_tput}
    ...                                                        ue=${UE}
    ...                                                        bts_id=81100
    gnb_alarm.Allow alarm    Cell blocked
    Perform cell block unblock operations from list    cell_operation_list=@{c3_tc17}
    Verify gNB is onAir
    gnb_alarm.Disallow alarm    Cell blocked
    Perform Android UE L3 call on all cells using qrxlevmin    cells_for_l3_call=&{c3_tc17_cells_tput}
    ...                                                        ue=${UE}
    ...                                                        bts_id=81100
    ...                                                        prepare_ue=${False}

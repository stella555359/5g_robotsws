*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB013351
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Resource          testsuite/Krakow/SISO/regression/RAN_PZ_KRK2/CB013351/CB013351_keywords.robot
Variables         variables/variables_C1a.py
Variables         deltas/C1a/delta_delete_80_add_100.py
Variables         variables/variables_C2a.py
Variables         deltas/C2a/delta_delete_50_50_add_100.py

Suite Setup       CB013351 Suite setup
Suite Teardown    Common suite teardown
Test Teardown     Common postconditions with watching alarms

*** Variables ***
${UE_C1A}                                 ONEPLUS_AVHQA
${UE_C2A}                                 ONEPLUS_AVHA
${COLLECT_LOGS_DURING_DATA_TRANSFER}      ${False}
${ENABLE_RACH_OBSERVER}                   ${False}
${BTS_ID}                                 ${tl.gnbs[0].global_bts_id}
${SMA_UEPC_IP}                            ${tl.test_pcs[1].default_ssh_connection_details.addr}
${SMA_PASSWORD}                           ${tl.test_pcs[1].default_ssh_connection_details.password}

*** Test Cases ***
[1][1.0] CB013351_Config1a_General_SiSo_Online_Cell_Addition_Deletion_3CCNR_1CCLTE
    [Setup]    CB013351 Common test setup    tc_cell_operation_list=@{c1a_tc3_setup}
    Perform Smawave UE L3 call on all cells using qrxlevmin    cells_for_l3_call=&{c1a_tc3_setup_cells_tput_nr}
    ...                                                        bts_id=${BTS_ID}
    ...                                                        uepc_ip=${SMA_UEPC_IP}
    ...                                                        smawave_password=${SMA_PASSWORD}
    Perform Android UE L3 call on LTE cell using qrxlevmin    cells_for_l3_call=&{c1a_tc3_cells_tput_lte}
    ...                                                       ue=${UE_C1A}
    ...                                                       bts_id=${BTS_ID}
    Perform delta commissioning on gNB    delta=${delta_c1a}
    Wait until keyword succeeds    600 sec    15 sec    gnbcell.Verify all cells are onAir
    Perform Smawave UE L3 call on all cells using qrxlevmin    cells_for_l3_call=&{c1a_tc3_cells_tput_nr}
    ...                                                        bts_id=${BTS_ID}
    ...                                                        uepc_ip=${SMA_UEPC_IP}
    ...                                                        smawave_password=${SMA_PASSWORD}
    Perform Android UE L3 call on LTE cell using qrxlevmin    cells_for_l3_call=&{c1a_tc3_cells_tput_lte}
    ...                                                       ue=${UE_C1A}
    ...                                                       bts_id=${BTS_ID}
    ...                                                       prepare_ue=${False}

[1][1.0] CB013351_Config2a_General_SiSo_Online_Cell_Addition_Deletion_4CC_to_3CC
    [Setup]    CB013351 Common test setup    tc_cell_operation_list=@{c2a_tc14_setup}
    Perform Android UE L3 call on all cells using qrxlevmin    cells_for_l3_call=&{c2a_tc14_setup_cells_tput}
    ...                                                        ue=${UE_C2A}
    ...                                                        bts_id=${BTS_ID}
    Perform delta commissioning on gNB    delta=${delta_c2a}
    Wait until keyword succeeds    600 sec    15 sec    gnbcell.Verify all cells are onAir
    Perform Android UE L3 call on all cells using qrxlevmin    cells_for_l3_call=&{c2a_tc14_cells_tput}
    ...                                                        ue=${UE_C2A}
    ...                                                        bts_id=${BTS_ID}
    ...                                                        prepare_ue=${False}
    [Teardown]    CB013351 C2A test teardown

[1][1.0] CB013351_Config2a_Manual_SiSo_SM_Cell_Block_Unblock
    [Setup]    CB013351 C2A test setup    tc_cell_operation_list=@{c2a_tc15_setup}
    Perform Android UE L3 call on all cells using qrxlevmin    cells_for_l3_call=&{c2a_tc15_cells_tput}
    ...                                                        ue=${UE_C2A}
    ...                                                        bts_id=${BTS_ID}
    gnb_alarm.Allow alarm    Cell blocked
    Perform cell block unblock operations from list    cell_operation_list=@{c2a_tc15}
    Verify gNB is onAir
    gnb_alarm.Disallow alarm    Cell blocked
    Perform Android UE L3 call on all cells using qrxlevmin    cells_for_l3_call=&{c2a_tc15_cells_tput}
    ...                                                        ue=${UE_C2A}
    ...                                                        bts_id=${BTS_ID}
    ...                                                        prepare_ue=${False}

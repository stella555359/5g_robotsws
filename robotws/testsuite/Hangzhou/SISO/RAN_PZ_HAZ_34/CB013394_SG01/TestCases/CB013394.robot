*** Settings ***
Suite Setup          CB013394 Suite preparation
Suite Teardown       run keyword and ignore error    Common suite recovery

Resource   ./../Resources/CB013349_keywords.robot

Documentation
...   author: Dandan Fang
...   contact: dandan.fang@nokia-sbell.com
...   squad group: SG_01
...   Feature CB013394 in SBTS26R1 program

Force Tags            RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED   PY36Documentation

*** Variables ***
${CONNECTION_ALIAS}     GNB_OAM
${GNB_INDEX}             ${0}

*** Test Cases ***
CB013394-SR-B_04_B3_4CC_oBW_100Mhz_16DL8UL_L3Call_Without_MUZF_AVQA_D_F_FM1070_specific_PRACH_format_Baseband_reset
    [Documentation]
    ...    *****************
    ...    Owner_dandan.fang@nokia-sbell.com
    ...    Test Step:
    ...    1.Reset all baseband and check cellls normal.
    ...    2.Do UE attach , and DL+UL traffic test on each CCs, peak check
    ...    ******************
    [Tags]    CRT_TRUNK.
    [Setup]    CB013394 Case Setup
    [Timeout]  180 minutes
    Baseband_module_reset_via_WEBUI.Baseband_module_reset_via_WEBUI   with_call=${False}
    Baseband_module_lock_unlock_via_WEBUI.Baseband_module_lock_unlock_via_WEBUI
    ${ru_index_list}  Get All RU Index    connection=${CONNECTION_ALIAS}
    Do Attach With Or Without Traffic On Selected RU      ru_index_list=${ru_index_list}   need_traffic_test=${True}
    ...   test_with_single_cc=${False}     peak_check=${False}    data_transfer_direction=both
    [Teardown]     run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}

CB013394-SR-B_02_B3_2CC_20M_80M_16DL8UL_L3Call_Without_MUZF_AVQA_D_F_FM1116_3ms_RU_Lock_Unlock
    [Documentation]
    ...    *****************
    ...    Owner_dandan.fang@nokia-sbell.com
    ...    1.For each radio, lock and check status right or not.
    ...    2.For each radio, unlock and check status , do UE attach on each CC deploy on radio.
    ...    ******************
    [Tags]    CRT_TRUNK
    [Timeout]  120 minutes
    [Setup]    CB013394 Case Setup
    CB013394_General_SiSo_RU_lock_unlock
    CB013394_Online_CellTye_Change
    [Teardown]     run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}

CB013394-SR-B_08_B4_4CC_General_SiSo_locking_one_cell_not_impacting_ongoing_call_on_other_cell
    [Documentation]
    ...    *****************
    ...    Owner_dandan.fang@nokia-sbell.com
    ...    For each radio,
    ...    1. block and then unblock all CCS on the radio.
    ...    2. check CCs status right, do UE atatch and UL Traffic only test
    ...    ******************
    [Tags]    CRT_TRUNK
    [Timeout]  120 minutes
    [Setup]    CB013394 Case Setup
    #Fault ID 49 "Cell blocked"
    AlarmWatchdog.add_allow_alarms     fault_id=49
    CB013394 Block and UnBlock Cells and L3call With UL Traffic
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]     run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}

CB013394-SR-B_03_B3_3CC_50M_30M_20M_16DL8UL_L3Call_Without_MUZF_AVQA_D_F_FM1070_RU_Reset
    [Documentation]
    ...    *****************
    ...    Owner_dandan.fang@nokia-sbell.com
    ...    For each radio,
    ...    1. reset radio and check radio, cell status right or not.
    ...    2. choose one cell random and do ue attach , DL only traffic test
    ...    ******************
    [Tags]    CRT_TRUNK
    [Setup]    CB013394 Case Setup
    [Timeout]  120 minutes
    Update RMOD Cablink LinkSpeed Dynamically   rmod_index=${2}
    CB013394_General_SiSo_RU_module_reset_from_GUI
    [Teardown]     run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}

CB013394-SR-B_01_B2_1CC_100Mhz_16DL8UL_L3Call_Without_MUZF_AVQA_D_F_1116_0ms_RU_PowerReset
    [Documentation]
    ...    *****************
    ...    Owner_dandan.fang@nokia-sbell.com
    ...    For each radio,
    ...    Power off then On for all RUs; then check CCs Onair, do attach on each CCs. No traffic test.
    ...    ******************
    [Tags]     CRT_TRUNK
    [Timeout]  120 minutes
    [Setup]    CB013394 Case Setup
    ${ru_index_list}  Get All RU Index    connection=${CONNECTION_ALIAS}
    FOR    ${index}    IN RANGE    1
        General_SiSo_RF_module_power_reset.General_SiSo_RF_module_power_reset    with_call=${False}    ru_index=${ru_index_list}
    END
    Do Attach With Or Without Traffic On Selected RU    ru_index_list=${ru_index_list}   need_traffic_test=${False}
    ...   test_with_single_cc=${False}
    [Teardown]     run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}

CB013394-SR-B_05_B4_4CC_100M_60M_20M_20M_16DL8UL_L3Call_Without_MUZF_AVQA_D_CellAdd_Then_Del_Then_Add
    [Documentation]
    ...    *****************
    ...    Owner_dandan.fang@nokia-sbell.com
    ...  for all RUs, choose one CC to be delated and then added again, check CC OnAir normal and Attach Ok.
    ...  traffic test type: unidir_then_bidir
    ...    ******************
    [Tags]    CRT_TRUNK
    [Timeout]  120 minutes
    [Setup]    CB013394 Case Setup
    # cell_addition_deletion_online . Online Cell addition deletion common keyword need the variables
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    CB013394 Online Cell addition deletion
    [Teardown]     run keyword and ignore error    Cell Del and Add Case Tear Down

# FOllowing not CIT/CRT case, Just for common siso operation verification
CB013394_Online_Modify_tiltOffset_Check_Cell_OnAir
    [Tags]    CRT_TRUNK.
    [Setup]    CB013394 Case Setup
    ${ru_index_list}  Get All RU Index    connection=${CONNECTION_ALIAS}
    ${ru_index_list}  create list    ${2}
    CB013394_Online_Modify_tiltOffset_For_Specific_RU   ru_index_list=${ru_index_list}    connection=${CONNECTION_ALIAS}
    [Teardown]     run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}
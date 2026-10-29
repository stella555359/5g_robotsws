*** Settings ***
Suite Setup          9787 Suite preparation
Suite Teardown       run keyword and ignore error    Common suite recovery
Test Timeout         100 min

Resource   ./../Resources/CB009787_keywords.robot

Documentation
...    Author:Liu Zheng
...    contact:zheng.4.liu@nokia-sbell.com
...    squad group:mmw1
...    Feature CB009787 in SBTS24R2 program

Force Tags            RAN_5G    RAN_5G_FDD    STATE_SW_UPLOADED   PY36Documentation

*** Test Cases ***
[2.0]Manual_SiSo_SM_RF_Module_lock_unlock
    [Documentation]    Author: Liu Zheng
    ...    N25_B25    chbw_20_10
    ...    this case not check peak. default traffic, DL:300M, UL:20M, average_tolerance: 0.1, minimum_tolerance: 0.05.
    ...    check throughput for 100s, omit the first 60s.
    ...    1. check RU-1 type, lock RU-1, check RU-1 status and check SOAP message.
    ...    2. For TL2123 RU-2, same step as step1; for TL406, no this step.
    ...    3. unlock RU-1, check RU-1 status, check SOAP message, check cell status. l3call on cell-1.
    ...    4. For TL2123 RU-2, unkock RU-2, check RU-2 status, check SOAP message. no cell configured on RU-2,
    ...       no l3call in this step. For TL406, no this step.
    [Tags]    CRT_TRUNK
    [Setup]    9787 Case Setup   expect_band=n25    expect_chbw=20MHz    expect_multi_rat_config=${True}
    ...    scf_template_path=${SCF_PATH_RFS_N25_20M_B25_10M}
    General_SiSo_RU_lock_unlock     with_call=${True}    4G_check=${False}    ue_num=1    special_ru=AWMFIA
    [Teardown]     run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}


[2.1]General_SiSo_Cell_block_and_unblock
    [Documentation]    Author: Liu Zheng
    ...    N25_B25    chbw_20_10
    ...    this case not check peak. default traffic, DL:300M, UL:20M, average_tolerance: 0.1, minimum_tolerance: 0.05.
    ...    if ue_num=0, case will fail.
    ...    check throughput for 60s, omit the first 60s.
    ...    block and unblock cell-1 and l3call test.
    [Tags]    CRT_TRUNK
    [Setup]    9787 Case Setup    expect_band=n25    expect_chbw=20MHz    expect_multi_rat_config=${True}
    ...    scf_template_path=${SCF_PATH_RFS_N25_20M_B25_10M}
    AlarmWatchdog.add_allow_alarms     fault_id=49
    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${True}    check_ue=${True}
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]     run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}

[1][1.0]General_SiSo_RAT_Block_Unblock_with_L3call
    [Documentation]    Author: Liu Zheng
    ...    N25_B25    chbw_20_10
    ...    this case not check peak. default traffic, DL:300M, UL:20M, average_tolerance: 0.1, minimum_tolerance: 0.05.
    ...    check throughput for 60s, omit the first 60s.
    ...    block unblock RAT, l3call on cell-1.
    [Tags]    CRT_TRUNK
    [Setup]    9787 Case Setup    expect_band=n25    expect_chbw=20MHz    expect_multi_rat_config=${True}
    ...    scf_template_path=${SCF_PATH_RFS_N25_20M_B25_10M}
    General_SiSo_RAT_Block_Unblock_with_L3call    with_call=${True}    with_peak=${False}    duration=${60}    check_ue=${True}
    [Teardown]     run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}

[2.0]General_SiSo_RU_module_reset_from_GUI
    [Documentation]    Author: Liu Zheng
    ...    N25_B25    chbw_20_10
    ...    this case not check peak. default traffic, DL:400M, UL:100M, average_tolerance=0.5, minimum_tolerance=0.5
    ...    check throughput for 60s, omit the first 60s.
    ...    1. reset RU-1, RU-1 status should be offline.
    ...    2. For TL2123 RU-2, reset RU-2, RU-2 status should be offline. for TL406, no this step.
    ...    3. For TL2123, will l3call on cell-1 2 times due to loop by RU numbers, but there is no much impact,
    ...       will not update common case.  For TL406, will l3call on cell-1 one time.
    [Tags]    CRT_TRUNK
    [Setup]    9787 Case Setup    expect_band=n25    expect_chbw=20MHz    expect_multi_rat_config=${True}
    ...    scf_template_path=${SCF_PATH_RFS_N25_20M_B25_10M}
    General_SiSo_RF_module_reset_from_GUI_with_L3call    dl_tp=400M    ul_tp=100M   apn_address=wustatic    duration=600
    ...   log_duration=60s    ul_target=100    dl_target=400    check_source=Aasyslog
    [Teardown]     run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}

[2.0]Manual_SiSo_SM_NR_RAT_reset
    [Documentation]    Author: Liu Zheng
    ...    N25_B25    chbw_20_10
    ...    this case not check peak. default traffic, DL:300M, UL:20M, average_tolerance=0.1, minimum_tolerance=0.05
    ...    check throughput for 60s, omit the first 60s.
    ...    reset NR RAT(both cancel is True and False), l3call on cell-1
    [Tags]    CRT_TRUNK
    [Setup]    9787 Case Setup    expect_band=n25    expect_chbw=20MHz    expect_multi_rat_config=${True}
    ...    scf_template_path=${SCF_PATH_RFS_N25_20M_B25_10M}
    Manual_SiSo_SM_NR_RAT_reset     with_call=${true}    with_peak=${False}    duration=${60}
    ...    is_bb_reset_expected=${False}    check_ue=${True}
    [Teardown]     run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}

[1][1.0] Manual_SiSo_REC_Radio_Module_power_reset
    [Documentation]    Author: Liu Zheng
    ...    N66    10    NR
    ...    this case not check peak. default traffic, DL:200M, UL:45M, average_tolerance=0.1, minimum_tolerance=0.05
    ...    check throughput for 60s, omit the first 60s. check ue_num and if the ue_num=0 case will fail.
    ...    1. l3call on cell-1.
    ...    2. power off RU-1, RU should be power off. fault 10 need be report.
    ...    3. For TL2123 RU-2, power off RU-2, RU-2 status should be opower off, fault 10 need be report. for TL406, no this step.
    ...    4. power on RU-1, power on RU-2 if needed. cell on air, fault10 absent.
    ...    5. l3call on cell-1
    [Tags]    CRT_TRUNK.
    [Setup]    9787 Case Setup    if_commission_needed=${True}    scf_template_path=${SCF_PATH_NR_N66_10M}
    AlarmWatchdog.add_allow_alarms    fault_id=1815
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    General_SiSo_RF_module_power_reset  with_call=${True}  with_peak=${False}  duration=${60}    dl_tp=200M    ul_tp=45M  check_ue=${True}
    AlarmWatchdog.remove_allow_alarms    fault_id=1815
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    [Teardown]     run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}

[1][3.1]General_SiSo_Online_Cell_Addition_Deletion
    [Documentation]    Author: Liu Zheng
    ...    N66    10    NR
    ...    this case not check peak. default traffic, DL:200M, UL:45M, average_tolerance=0.1, minimum_tolerance=0.05
    ...    check throughput for 60s, omit the first 60s.
    ...    1. l3call on cell-1.
    ...    2. online delete cell-1.
    ...    3. online add cell-1.
    ...    4. l3call on cell-1.
    [Tags]    CRT_TRUNK
    [Setup]    9787 Case Setup    if_commission_needed=${True}    scf_template_path=${SCF_PATH_NR_N66_10M_2CC}
    General_SiSo_Online_Cell_addition_deletion    check_cell=1  suite_name=default  test_name=default  dl_tp=200M  ul_tp=45M  check_ue=${True}
    [Teardown]     run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}

General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Documentation]    Author: Cui Lingxue
    ...    N66_40M_B66_20M
    [Tags]    CRT_TRUNK
    [Setup]    9787 Case Setup    if_commission_needed=${True}    scf_template_path=${SCF_PATH_RFS_N66_40M_B66_20M}
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Teardown]     run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}

General_SiSo_E2E_system_setup_with_data_transfer_Concurrent
    [Documentation]    Author: Cui Lingxue
    ...    N66_40M_B66_20M
    [Tags]    CRT_TRUNK
    [Setup]    9787 Case Setup    if_commission_needed=${True}    scf_template_path=${SCF_PATH_RFS_N66_40M_B66_20M}
    Step 1: UE attach, start UL traffic and verify    customized_log_name=9787_RFS_E2E    exp_ul=236
    Step 2: Stop UL traffic, start DL traffic and verify    customized_log_name=9787_RFS_E2E    exp_dl=821
    Step 3: Start UL traffic and verify bi-direction traffic    customized_log_name=9787_RFS_E2E    exp_ul=236    exp_dl=821
    [Teardown]   run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}

General_SiSo_E2E_system_setup_with_data_transfer_NR
    [Documentation]    Author: Cui Lingxue
    ...    N25_20M
    [Tags]    CRT_TRUNK
    [Setup]    9787 Case Setup    if_commission_needed=${True}    scf_template_path=${SCF_PATH_NR_N25_20M}
    Step 1: UE attach, start UL traffic and verify    customized_log_name=9787_NR_Only_E2E    exp_ul=109
    Step 2: Stop UL traffic, start DL traffic and verify    customized_log_name=9787_NR_Only_E2E    exp_dl=402
    Step 3: Start UL traffic and verify bi-direction traffic    customized_log_name=9787_NR_Only_E2E    exp_ul=109    exp_dl=402
    [Teardown]   run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}

Manual_SiSo_CM_Reconfiguration_of_frequencies_outside_filter_range
    [Documentation]    Author: Cui Lingxue
    ...    N66_40M_B66_20M
    [Tags]    CRT
    [Setup]    9787 Case Setup    if_commission_needed=${True}    scf_template_path=${SCF_PATH_RFS_N66_40M_B66_20M}
    AlarmWatchdog.add_allow_alarms    fault_id=1900
    AlarmWatchdog.add_allow_alarms    fault_id=1807
    Log to console    Step 1 get original value of nrarfcn
    ${dict_original}    Backup original value of nrarfcn and earfcn

    Log to console    Step 2 Modify nrarfcn to be out of RF supported range(above DL range) and verify no PDL error
    ${update_status}    Online modify arfcn of NR FDD cell or LTE FDD cell    nrarfcnDl=439680
    Verify no PDL error for parameter update    parameter_update_result=${update_status}

    Log to console    Step 3 Check gnb status, and verify fault 1900
    sleep    2min
    Check SM and RF module status
    Verify fault 1900 appear

    Log to console    Step 4 Repeat step 2 and step 3 for nrarfcn below RF supported UL range
    ${update_status}    Online modify arfcn of NR FDD cell or LTE FDD cell    nrarfcnUl=342400
    Verify no PDL error for parameter update    parameter_update_result=${update_status}
    sleep    2min
    Check SM and RF module status
    Verify fault 1900 appear

    Log to console    Step 5 Modify nrarfcn to band n71 and verify PDL error
    ${update_status}    Online modify arfcn of NR FDD cell or LTE FDD cell    nrarfcnDl=125760    nrarfcnUl=134980
#    run keyword and continue on failure    Verify PDL error for NRARFCN out of band range    parameter_update_result=${update_status}

    Log to console    Step 6 Check gnb status, and verify fault 1900
    sleep    2min
    Check SM and RF module status
    Verify fault 1900 appear

    Log to console    Step 7 Restore nrarfcn back to initial value, and check cell on air
    Online modify arfcn of NR FDD cell or LTE FDD cell     nrarfcnDl=${dict_original['nrarfcnDl']}    nrarfcnUl=${dict_original['nrarfcnUl']}
    Wait cell onair classical cloud    timeout=${TIMEOUT_CELL_ONAIR}    du_timeout=${TIMEOUT_CELL_ONAIR}
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}

    Log to console    Step 8 Repeat above steps for LTE
    ${update_status}    Online modify arfcn of NR FDD cell or LTE FDD cell    earfcnDL=66506    earfcnUL=132042
#    Verify no PDL error for parameter update    parameter_update_result=${update_status}
    sleep    2min
    Check SM and RF module status
    Verify fault 1807 appear

    Log to console    Step 9 Resotre earfcn back to initial value, and check cell on air
    Online modify arfcn of NR FDD cell or LTE FDD cell     earfcnDL=${dict_original['earfcnDL']}    earfcnUL=${dict_original['earfcnUL']}
    Wait cell onair classical cloud    timeout=${TIMEOUT_CELL_ONAIR}    du_timeout=${TIMEOUT_CELL_ONAIR}
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
    AlarmWatchdog.remove_allow_alarms    fault_id=1900
    AlarmWatchdog.remove_allow_alarms    fault_id=1807
    [Teardown]     run keyword and ignore error    run keywords
    ...    Online modify arfcn of NR FDD cell or LTE FDD cell     earfcnDL=${dict_original['earfcnDL']}    earfcnUL=${dict_original['earfcnUL']}
    ...    nrarfcnDl=${dict_original['nrarfcnDl']}    nrarfcnUl=${dict_original['nrarfcnUl']}
    ...    AND    Common case teardown    detach_ue=${False}    is_btslog_required=${False}

General_SiSo_E2E_system_setup_with_data_transfer_LTE
    [Documentation]    Author: Cui Lingxue
    ...    B25_10M
    [Tags]    CRT_TRUNK
    [Setup]    LTE Case setup
    Simple UE L3 Call And Throughput    scf_path=${SCF_PATH_LTE_B25_10M}
    ...     dl_tp=184.51    ul_tp=32
    [Teardown]   run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${False}

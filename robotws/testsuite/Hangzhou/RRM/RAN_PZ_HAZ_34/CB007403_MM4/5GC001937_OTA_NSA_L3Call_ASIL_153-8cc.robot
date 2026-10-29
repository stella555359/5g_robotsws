*** Settings ***
Documentation
...    author: Wang Debbie
...    contact: debbie.wang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_4_SG

Suite Setup    All Case Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown


Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    ./Resource/CB007403_1937_resource.robot
Force Tags    SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE    CLOUD_5G_CLASSICAL_ANDROID_ASILL_ABIOB1_AEWB_ENB    STATE_SW_UPLOADED
...   PY36


*** Variables ***
${ultp}    230
${dltp}    4150
${ue_index}    0
${deviation}    0.98
${TS_CASE_LOG_PATH}    ${OUTPUT DIR}
${gnb750_cell1_dist_name}      /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-707/NRCELL_L-1
${gnb750_cell2_dist_name}      /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-707/NRCELL_L-2
${gnb750_cell3_dist_name}      /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-707/NRCELL_L-3
${gnb750_cell4_dist_name}      /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-707/NRCELL_L-4
${gnb_ip_750}      10.71.215.238
${MR_NR_BTS_NRCELL1}     /MRBTS-750/NRBTS-707/NRCELL-1
${MR_NR_BTS_NRCELL2}     /MRBTS-750/NRBTS-707/NRCELL-2
${MR_NR_BTS_NRCELL3}     /MRBTS-750/NRBTS-707/NRCELL-3
${MR_NR_BTS_NRCELL4}     /MRBTS-750/NRBTS-707/NRCELL-4

*** Test Cases ***
[1]CB007403_5GC001937_01_NSA_8ccCA_UDP_ULDL_L3Call_Contiguous
    [Tags]    CRT_TRUNK
    [Setup]    Case Suite Setup
    ${list1_of_cell_ids}    Create List    16385    16386    16387    16388    16389    16390    16391    16392
    step3: Prepare UE
    Step4: UE Attach
    Step5: Start traffic
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list1_of_cell_ids}
    ...    ultarget_throughput=${ultp}    dltarget_throughput=${dltp}    actCarrierAggregation=${True}
    ...    min_percent=0.85    target_avg_percent=0.98
    Set Test Variable    ${all_tp}    ${all_tp}
    sleep    300s
    [Teardown]    Case_Teardown    protocol=UDP

[1]CB007403_5GC001937_03_NSA_8ccCA_TCP_DL_L3Call_Contiguous
    [Documentation]
    ...    The purpose of this test is to verify basic configuration of RU RAU OAM configures RU,
    ...    configuration not related to synchronization, transport and U-plane.
    [Tags]    CRT_TRUNK
    [Setup]    Case Suite Setup
    ${list1_of_cell_ids}    Create List    16385    16386    16387    16388    16389    16390    16391    16392
#    Run keyword and continue on failure    step1: Check all cells status
    step3: Prepare UE    ue_index=${ue_index}
    Step4: UE Attach    ue_index=${ue_index}
    Step5: Start traffic DL    ue_index=${ue_index}
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m
#    ${cellid}    Get nrcellid from aasys log    log_name=/tmp/aasyslog_tput.txt
#    log    ${cell_id}
    ${all_tp}    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log}    cells=${list1_of_cell_ids}
    ...    target_throughput=${dltp}    actCarrierAggregation=${True}
    ...    min_percent=0.85    target_avg_percent=0.98
    Set Test Variable    ${all_tp}    ${all_tp}
    sleep    300s
    [Teardown]     Case_Teardown    if_ul=${False}

#[1]5GC001937_OTA_4115_NSA_L3_Call_DL_TCP_Classical_4CC_1DRB_AEWB_Contiguous
#    [Tags]    CRT_22R2    CRT_TRUNK
#    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS

[1]CB007403_5GC001937_03_NSA_8ccCA_TCP_UL_L3Call_Contiguous
    [Documentation]
    ...    The purpose of this test is to verify basic configuration of RU RAU OAM configures RU,
    ...    configuration not related to synchronization, transport and U-plane.
    [Tags]    CRT_TRUNK
    [Setup]    Case Suite Setup
      ${list_of_cell_ids}    Create List    16385    16386    16387    16388    16389    16390    16391    16392
    Run keyword and continue on failure    step1: Check all cells status
    sleep    300s
    step3: Prepare UE
    Step4: UE Attach
    Step5: Start traffic UL
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m
    ${all_tp}    power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${log}    cells=${list_of_cell_ids}
    ...    target_throughput=${ultp}    actCarrierAggregation=${True}
    ...    min_percent=0.85    target_avg_percent=0.98
    Set Test Variable    ${all_tp}    ${all_tp}
    sleep    300s
    [Teardown]     Case_Teardown    if_dl=${False}

#[1]5GC001937_OTA_4114_NSA_L3_Call_UL_TCP_Classical_4CC_1DRB_AEWB_Contiguous
#    [Tags]    CRT_22R2    CRT_TRUNK
#    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS

[1]CB007403_5GC001937_02_NSA_8ccCA_TCP_ULDL_L3Call_Contiguous
    [Documentation]
    ...    The purpose of this test is to verify basic configuration of RU RAU OAM configures RU,
    ...    configuration not related to synchronization, transport and U-plane.
    [Tags]    CRT_TRUNK
    [Setup]   Case Suite Setup
      ${list_of_cell_ids}    Create List    16385    16386    16387    16388    16389    16390    16391    16392
    Run keyword and continue on failure    step1: Check all cells status
    sleep    600s
    step3: Prepare UE
    Step4: UE Attach
    Step5: Start traffic    protocol=tcp
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
    ...    ultarget_throughput=${ultp}    dltarget_throughput=${dltp}    actCarrierAggregation=${True}
    ...    min_percent=0.85    target_avg_percent=0.98
    Set Test Variable    ${all_tp}    ${all_tp}
    sleep    300s
    [Teardown]    Case_Teardown

*** Keywords ***
Step4: UE147 Attach
    log to console      Step4: UE1 Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    
    ...    log_type=Aasyslog    attach_mode=5G_NSA    hwcheck_index=${5}    abil_index=${5}
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False    abil_index=${5}

upload tp to KPI
    [Arguments]  ${if_ul}    ${if_dl}    ${protocol}
    ${ul_tp_list}   set variable if    ${if_ul}   ${all_tp[0]}    ${None}
    ${dl_tp_list}   set variable if    ${if_dl}    ${all_tp[1]}    ${None}
    ${ul_tp_peak}    run keyword if     ${if_ul}    get from dictionary    ${ul_tp_list[0]}    peak     ELSE    set variable    ${None}
    ${ul_tp_average}    run keyword if     ${if_ul}    get from dictionary    ${ul_tp_list[0]}    average     ELSE    set variable    ${None}
    ${ul_tp_min}    run keyword if     ${if_ul}    get from dictionary    ${ul_tp_list[0]}    minimum     ELSE    set variable    ${None}

    ${dl_tp_peak}    run keyword if     ${if_dl}    get from dictionary    ${dl_tp_list[0]}    peak     ELSE    set variable    ${None}
    ${dl_tp_average}    run keyword if     ${if_dl}    get from dictionary    ${dl_tp_list[0]}    average     ELSE    set variable    ${None}
    ${dl_tp_min}    run keyword if     ${if_dl}    get from dictionary    ${dl_tp_list[0]}    minimum     ELSE    set variable    ${None}
    run keyword if    ${if_ul}    Run Keyword And Ignore Error    KpiReporter.add_ul_throughput_into_report_list    exp_ul=${ultp}Mbits/sec
    ...    ul_avg=${ul_tp_average}Mbits/sec    ul_max=${ul_tp_peak}Mbits/sec    ul_min=${ul_tp_min}Mbits/sec
    run keyword if    ${if_dl}    Run Keyword And Ignore Error    KpiReporter.add_dl_throughput_into_report_list    exp_dl=${dltp}Mbits/sec
    ...    dl_avg=${dl_tp_average}Mbits/sec    dl_max=${dl_tp_peak}Mbits/sec    dl_min=${dl_tp_min}Mbits/sec
    Run Keyword And Ignore Error     KpiReporter.report_tput_kpi    protocol=${protocol}    deviation=${deviation}    logs_dir=${TS_CASE_LOG_PATH}

Case_Teardown
    [Arguments]    ${if_ul}=${True}    ${if_dl}=${True}    ${protocol}=TCP     ${connection}=COAM
    Log To Console    \n *** Case teardown
    Run Keyword And Ignore Error    Step7: Stop traffic
    Run Keyword And Ignore Error    Step8: UE Detach
    Run Keyword And Ignore Error    admin_cli.teardown    connection=${connection}
    Run Keyword And Ignore Error    Teardown the Aasyslog save progress
    Run Keyword And Ignore Error    upload tp to KPI    if_ul=${if_ul}    if_dl=${if_dl}    protocol=${protocol}
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown

Case Suite Setup
#    Block Cell_750    dist_name=${gnb750_cell1_dist_name}    MR_NR_BTS_NRCELL=${MR_NR_BTS_NRCELL1}
#    Block Cell_750    dist_name=${gnb750_cell2_dist_name}    MR_NR_BTS_NRCELL=${MR_NR_BTS_NRCELL2}
#    Block Cell_750    dist_name=${gnb750_cell3_dist_name}    MR_NR_BTS_NRCELL=${MR_NR_BTS_NRCELL3}
#    Block Cell_750    dist_name=${gnb750_cell4_dist_name}    MR_NR_BTS_NRCELL=${MR_NR_BTS_NRCELL4}
    CI_interface.Common Suite Setup
    robot_common_operations.Common case Setup
#    step1: Check all cells status

Block Cell_750
    [Arguments]      ${dist_name}    ${MR_NR_BTS_NRCELL}    ${connection}=GNB_OAM
    log to console    Block Cell 750
    Connect to gnb coam via ssl     bts_host=${gnb_ip_750}
    ${info}      coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    ${blockingState}    set variable      ${info['stateInfo']['blockingState']}
    run keyword if    '${blockingState}'=="Unblocked"
    ...    coam.block_cell     dist_name=${MR_NR_BTS_NRCELL}        connection=${connection}
    sleep     5s
    ${info1}      coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    ${blockingState1}    set variable      ${info1['stateInfo']['blockingState']}
    should be true    '${blockingState1}'=="Blocked"
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

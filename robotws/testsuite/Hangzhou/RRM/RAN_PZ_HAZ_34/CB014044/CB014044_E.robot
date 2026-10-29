*** Settings ***
Documentation
...    author:  ming.shi@nokia-sbell.com
...    contact: ming.shi@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ4_03

Suite Setup    Common Suite Setup for CB014044
Suite Teardown    Common Suite Teardown for CB014044
Test Setup        Common Test Setup for CB014044 without AP
Test Teardown     Common Test Teardown for CB014044 without AP
#Test Teardown     Common Test Teardown for CB014044_E
Force Tags  CA_5G_RRM    PY36
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014044/Resources/CB014044_common_keywords.robot


*** Variables ***
${report_name_E_B1_01}    E_B1_01
@{kpi_name_E_B1_01}    NR_5088d    NR_5258a    NR_5114b
@{kpi_distnames_E_B1_01}    NRCELL-1    NRCELL-2


*** Test Cases ***
[1]CB014044_E#B1_001_Mix_CA_nonCA_UE_with_actTdPfMetricOpt_online_Scheduler_Behavior_for_Diverse_Traffic_with_diff_schedulWeight_DL_TDD_SA
    [Documentation]
    ...    1. DESCRIPTION
    ...    This scenario describes the activation of the DL TD Metric Optimization feature(actDlTdPfMetricOp)
    ...    in a system with active Carrier Aggregation (CA).
    ...    2. TEST ENVIRONMENT AND SETTINGS
    ...    - 1 X ASIL
    ...    - 1 X ABIP
    ...    - 1 X 5G RU(TDD:AEHC/AVHA)
    ...    - 1 X 5G RU(FDD:AHFIB)
    ...    - 8 X UEs: SPARK 8 UEs/Mutli UEs with airphone
    ...    -1UE support 6CC CA
    ...    2.1 Testing Tools
    ...    - Wireshark/Tcpdump/L1/L2 traces/btslog/snapshot
    ...    2.2 Test Automation
    ...    N/A
    ...    3. TEST CASE INFORMATION
    ...    3.1 Definitions from the Test Plan
    ...    NB configuration (SA, FR1,TDD/FDD, classicBTS,100Mhz/20Mhz)
    ...    NRCELL.actRat1Alloc = True
    ...    NRBTS.NRCELL.actDlSchLowBufferOpt=True
    ...    NRBTS.NRCELL.actTdPfMetricOpt=disabled
    ...    CA configuration is on.
    ...    PRB Pooling disabled (NRBTS/actSlowPrbPooling = True but no PRB pooling limitations)
    ...    Long PUCCH enabled (NRBTS/NRCELL/pucchModeSelect = long PUCCH)
    ...    DSS features deactivated (NRBTS/NRCELL/lteNrDssMode = 0)
    ...    actDlMuMimoEnh = False
    ...    actUlMuMimo = False
    ...    Slice-Aware Scheduler disabled (NRBTS.actSliceAwareScheduler = False)
    ...    Non-GBR Bearer Configuration:
    ...    9 UEs connected, evenly distributed across three traffic profiles:
    ...    3 UEs → Ping traffic (5QI = 7, small packets, regular intervals)
    ...    3 UEs → High buffer traffic (5QI = 6, large buffer, continuous throughput)
    ...    3 UEs → Burst traffic (5QI = 8, irregular large bursts)
    ...    Each UE has one DL Non-GBR bearer
    ...    Scheduling weights applied as same
    ...    5QI = 6/7/8 → schedulWeight = 40
    ...    3.2 Required Logs
    ...    -L1/L2 traces
    ...    -Syslog
    ...    -KPIs
    ...    -snapshot
    ...    4. TESTING INSTRUCTIONS
    ...    4.1 Preconditions
    ...    Golden RRM parameter set
    ...    4.2 Test Steps
    ...    Refer test step description
    ...    4.3 Postconditions
    ...    The new DL TD Metric Optimization feature(actDlTdPfMetricOpt/actUlTdPfMetricOpt) activates correctly.
    ...    CA remains active with optimized packet flow scheduling.
    ...    CA setup (PCell + multiple SCells) is stable.
    ...    Data transmission remains stable.
    ...    | Step Name       | Description           | Expected
    ...    | Step 1          | Attach With 8 UEs to the target 5G CELL, and each UE has create one of the non-GBR bear with
    ...    5QI6/7/8 UE1-2 2UE 5QI6 UE3-5 3UE 5QI7 UE6-8 3UE 5QI8 Attach With another 1 UE9 to the target 5G CELL and also with
    ...    Total 6CC CA addition scuucess, with non-GBR bear 5QI6
    ...    | All these UE attach normally and Bears are established success
    ...    | Step 2          | Start DL High buffer traffic on UE1-2 +UE9 Start Ping traffic on UE3-5 Start Burst traffic on UE6-8
    ...    | Scheduler successfully differentiates between traffic profiles and prioritizes accordingly.
    ...    | Step 3          | Online modify Pcell actTdPfMetricOpt from disabled to DL
    ...    | TD metric-based prioritization results in balanced PRB allocation across mixed traffic types.
    ...    on Pcell Ping UEs retain low latency even under burst load events. Throughput for high-buffer UEs remains stable.
    ...    Burst UEs observe rapid PRB scaling during active phases without starving others.
    ...    | Step 4          | Online modify ALL Scell actTdPfMetricOpt from disabled to DL
    ...    | The Scheduler for CA UE has no big diff as scell only has one sch UE
    ...    | Step 5          | Online modify actTdPfMetricOpt from DL to disabled
    ...    | The Scheduler fairness and responsiveness improve will fallback to legarcy again on Pcell
    [Timeout]    3 hours
    E#B1_001 Prerequisite
#    E#B1_001 Step 1 8UEs attach and CA addition scuucess
#    E#B1_001 Step 2 8UEs transfer data
#    E#B1_001 Step 3 Online modify Pcell actTdPfMetricOpt from disabled to DL
#    E#B1_001 Step 4 Online modify ALL Scell actTdPfMetricOpt from disabled to DL
#    E#B1_001 Step 5 Online modify actTdPfMetricOpt from DL to disabled


*** Keywords ***
E#B1_001 Prerequisite
    log to console    E#B1_001 Prerequisite
#    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_E_B1_001_01}    skip_parameter_relation_errors=False
#    check cell on-air status

E#B1_001 Step 1 8UEs attach and CA addition scuucess
    Log To Console    E#B1_001 Step 1 8UEs attach and CA addition scuucess
    8UEs attach

E#B1_001 Step 2 8UEs transfer data
    Log To Console    E#B1_001 Step 2 8UEs transfer data
    Set Test Variable    @{dl_diff_tput}    ${200}    ${200}    ${1}    ${1}    ${1}    ${1}    ${1}    ${1}
    Set Test Variable    @{check_dl_diff_tput}    200M    200M    1M    1M    1M    1M    1M    1M
    Set Test Variable    @{used_ues_index}    ${0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}
    Start multiUEs traffic with appserver for diff throughput    dl_tput_multiue=${dl_diff_tput}
    Check traffic with pioneer client with pioneer client for diff throughput
    ...    tput_target=${check_dl_diff_tput}    ues_index=${used_ues_index}    direction=dl
    ${start_time}=    record_time    label=start
    Set Test Variable    ${start_time}
    Prepare with PM counter time to caculate    period=start
    ${record1_time}=    get_required_record_time
    Set Test Variable    ${record1_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    Check traffic with pioneer client with pioneer client for diff throughput
    ...    tput_target=${check_dl_diff_tput}    ues_index=${used_ues_index}    direction=dl

E#B1_001 Step 3 Online modify Pcell actTdPfMetricOpt from disabled to DL
    log to console    E#B1_001 Step 3 Online modify Pcell actTdPfMetricOpt from disabled to DL
    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_E_B1_001_02}    skip_parameter_relation_errors=False
    Prepare with PM counter time to caculate    period=start
    ${record2_time}=    get_required_record_time
    Set Test Variable    ${record2_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    Check traffic with pioneer client with pioneer client for diff throughput
    ...    tput_target=${check_dl_diff_tput}    ues_index=${used_ues_index}    direction=dl

E#B1_001 Step 4 Online modify ALL Scell actTdPfMetricOpt from disabled to DL
    log to console    E#B1_001 Step 4 Online modify ALL Scell actTdPfMetricOpt from disabled to DL
    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_E_B1_001_03}    skip_parameter_relation_errors=False
    Prepare with PM counter time to caculate    period=start
    ${record3_time}=    get_required_record_time
    Set Test Variable    ${record3_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    Check traffic with pioneer client with pioneer client for diff throughput
    ...    tput_target=${check_dl_diff_tput}    ues_index=${used_ues_index}    direction=dl

E#B1_001 Step 5 Online modify actTdPfMetricOpt from DL to disabled
    log to console    E#B1_001 Step 5 Online modify actTdPfMetricOpt from DL to disabled
    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_E_B1_001_04}    skip_parameter_relation_errors=False
    Prepare with PM counter time to caculate    period=start
    ${record4_time}=    get_required_record_time
    Set Test Variable    ${record4_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    Check traffic with pioneer client with pioneer client for diff throughput
    ...    tput_target=${check_dl_diff_tput}    ues_index=${used_ues_index}    direction=dl

Common Test Teardown for CB014044_E
    IF    '${TEST STATUS}' == 'PASS'
        ${end_time}=    record_time    label=end
        ${package_version}=    Get bts package version
        sleep    16min
        ${rc}    ${output}=    Run And Return Rc And Output    mv ${excel_kpi_path}*.xlsx ${excel_kpi_path}bak
        ${tl_id}=    Evaluate    str(${gnb_instance})[:3]
        ${report_id}=    generate new report and get report id    file_path=${path}    report_name=${report_name_E_B1_01}
        ...    tl_id=${tl_id}     package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
        IF    '${report_id}' != 'None'
            download_kpi_file    report_id=${report_id}    path=${excel_kpi_path}
        END
        ${excel_file}=    List Files In Directory    path=${excel_kpi_path}    pattern=*.xlsx
        ${exceel_num}=    Get Length    ${excel_file}
        IF    ${exceel_num} != ${0}
            excel_sheet_to_json
            ...    excel_path=${excel_kpi_path}/${excel_file}[0]    sheet_name=Chart Data    json_path=${excel_kpi_path}/${excel_file}[0][:-5].json
            @{record_times}    Create List    ${record1_time}    ${record2_time}    ${record3_time}    ${record4_time}
            ${required_kpi_values}=    get_required_kpi_value
            ...    kpis=${kpi_name_E_B1_01}    times=${record_times}    distnames=${kpi_distnames_E_B1_01}
            ...    json_path=${excel_kpi_path}/${excel_file}[0][:-5].json
            ${kpi_01_values}=    Create List
            FOR    ${record_time}    IN    @{record_times}
                ${kpi_01_value}=    get_check_kpi_value    kpi_values=${required_kpi_values}    kpi_name=${kpi_name_E_B1_01}[0]
                ...    timestamp=${record_time}    distname=${kpi_distnames_E_B1_01}[0]
                append to list    ${kpi_01_values}    ${kpi_01_value}
            END
            should be true    ${kpi_01_values}[1] > ${kpi_01_values}[0]
            should be true    ${kpi_01_values}[1] > ${kpi_01_values}[3]
            should be true    ${kpi_01_values}[2] > ${kpi_01_values}[0]
            should be true    ${kpi_01_values}[2] > ${kpi_01_values}[3]
            ${kpi_02_values}=    Create List
            FOR    ${record_time}    IN    @{record_times}
                ${kpi_02_value}=    get_check_kpi_value    kpi_values=${required_kpi_values}    kpi_name=${kpi_name_K_B001}[0]
                ...    timestamp=${record_time}    distname=${kpi_distnames_K_B001}[1]
                append to list    ${kpi_02_values}    ${kpi_02_value}
            END
            should be true    ${kpi_02_values}[2] > ${kpi_02_values}[0]
            should be true    ${kpi_02_values}[2] > ${kpi_02_values}[3]
            ${kpi_11_values}=    Create List
            FOR    ${record_time}    IN    @{record_times}
                ${kpi_11_value}=    get_check_kpi_value    kpi_values=${required_kpi_values}    kpi_name=${kpi_name_E_B1_01}[1]
                ...    timestamp=${record_time}    distname=${kpi_distnames_K_B001}[0]
                append to list    ${kpi_11_values}    ${kpi_11_value}
            END
            should be true    ${kpi_11_values}[1] > ${kpi_11_values}[0]
            should be true    ${kpi_11_values}[1] > ${kpi_11_values}[3]
            should be true    ${kpi_11_values}[2] > ${kpi_11_values}[0]
            should be true    ${kpi_11_values}[2] > ${kpi_11_values}[3]
            ${kpi_12_values}=    Create List
            FOR    ${record_time}    IN    @{record_times}
                ${kpi_12_value}=    get_check_kpi_value    kpi_values=${required_kpi_values}    kpi_name=${kpi_name_K_B001}[1]
                ...    timestamp=${record_time}    distname=${kpi_distnames_K_B001}[1]
                append to list    ${kpi_12_values}    ${kpi_12_value}
            END
            should be true    ${kpi_12_values}[2] > ${kpi_12_values}[0]
            should be true    ${kpi_12_values}[2] > ${kpi_12_values}[3]
            ${kpi_21_values}=    Create List
            FOR    ${record_time}    IN    @{record_times}
                ${kpi_21_value}=    get_check_kpi_value    kpi_values=${required_kpi_values}    kpi_name=${kpi_name_K_B001}[2]
                ...    timestamp=${record_time}    distname=${kpi_distnames_K_B001}[0]
                append to list    ${kpi_21_values}    ${kpi_21_value}
            END
            should be true    ${kpi_21_values}[1] > ${kpi_21_values}[0]
            should be true    ${kpi_21_values}[1] > ${kpi_21_values}[3]
            should be true    ${kpi_21_values}[2] > ${kpi_21_values}[0]
            should be true    ${kpi_21_values}[2] > ${kpi_21_values}[3]
            ${kpi_22_values}=    Create List
            FOR    ${record_time}    IN    @{record_times}
                ${kpi_22_value}=    get_check_kpi_value    kpi_values=${required_kpi_values}    kpi_name=${kpi_name_K_B001}[2]
                ...    timestamp=${record_time}    distname=${kpi_distnames_K_B001}[1]
                append to list    ${kpi_22_values}    ${kpi_22_value}
            END
            should be true    ${kpi_22_values}[2] > ${kpi_22_values}[0]
            should be true    ${kpi_22_values}[2] > ${kpi_22_values}[3]
        END
    END
    Stop multiues traffic with appserver
    8UEs detach
    Common Test Teardown for CB014044 without AP
    Online modify parmeters     parameters_to_update=${PARAM_14044_recover_gnb1_E_B1_001_01}    skip_parameter_relation_errors=False
    check cell on-air status
    Online delete parmeters    parameters_to_update=${PARAM_14044_recover_delete_gnb1_E_B1_001_01}


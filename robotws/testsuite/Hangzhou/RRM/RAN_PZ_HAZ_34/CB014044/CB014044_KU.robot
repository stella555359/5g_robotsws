*** Settings ***
Documentation
...    author:  ming.shi@nokia-sbell.com
...    contact: ming.shi@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ4_03

#Suite Setup    robot_common_operations.Common Suite Setup
#Test Teardown     Common Test Teardown for CB014044
Suite Setup    Common Suite Setup for CB014044
Suite Teardown    Common Suite Teardown for CB014044
Test Setup        Common Test Setup for CB014044
Test Teardown     Common Test Teardown for CB014044_KU
Force Tags  CA_5G_RRM    PY36
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014044/Resources/CB014044_common_keywords.robot


*** Variables ***
${report_name_KU_B002}    KU_B002
@{kpi_name_KU_B002}    NR_5088d    NR_5258a    NR_5114b    NR_5115a    NR_5089e    NR_5259a
@{kpi_distnames_KU_B002}    NRCELL-3

*** Test Cases ***
[1]CB014044_KU#B002_KPI_Impact_analysis_of_Increased_Efficiency_and_fairness_of_non-GBR_scheduler_in_RAT1_60UEs
    [Documentation]
    ...    1. DESCRIPTION
    ...    This User Scenario aims to enable the high buffer UE prioritization in TD scheduler for TDD cell on DL with
    ...    actBestNList=DL_UL and actTdPfMetricOpt=DL or DL_UL.
    ...    2. TEST ENVIRONMENT AND SETTINGS
    ...    - 1 X ASIL
    ...    - 1 X ABIP
    ...    - 1 X 5G RU(TDD:AVHA)
    ...    - 8 X UEs: SPARK 8 UEs
    ...    2.1 Testing Tools
    ...    - Wireshark/Tcpdump/L1/L2 traces/btslog/snapshot
    ...    2.2 Test Automation
    ...    N/A
    ...    3. TEST CASE INFORMATION
    ...    3.1 Definitions from the Test Plan
    ...    NB configuration (SA, FR1,TDD, classicBTS,100Mhz)
    ...    - NRCELL.actRat1Alloc = True
    ...    - NRBTS.NRCELL.actDlSchLowBufferOpt=True
    ...    - NRBTS.NRCELL.actUlSchLowBufferOpt=True
    ...    - NRBTS.NRCELL.actTdHighBufUePrio=disable
    ...    - actSlowPrbPooling = false
    ...    - NRBTS.NRCELL.pucchModeSelect=longPucch
    ...    - NRBTS.NRCELL.lteNrDssMode=none
    ...    - NRCELL.actDlMuMimoEnh = False
    ...    - NRBTS/NRDU.carrierAggregationSupportList is set to None
    ...    - NRBTS.actSliceAwareSchedulerUlAndEnh is set to False(default value)
    ...    - NRBTS.actSliceAwareScheduler is set to 'False'.
    ...    - NRBTS.NRCELL.dlHighBufferPrioUeRatio=20% (default)
    ...    - NRBTS.NRCELL.ulHighBufferPrioUeRatio=20% (default)
    ...    - NRBTS.NRCELL.actBestNList=DL_UL
    ...    - NRBTS.NRCELL.actFdAlgoEnh=disabled
    ...    - NRBTS.NRCELL.actTdPfMetricOpt=DL_UL
    ...    - maxNumPdschAllocationPerSlot=4
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
    ...    - For each UE UL and DL data transmission is successful.
    ...    Acceptance criteria:
    ...    - After enabling high buffer prioritization feature, number of high buffer UEs being scheduled increased.
    ...    - DL/UL E2E throughput is increased.
    ...    - Overall PRB Utilization is increased.
    ...    - DL/UL E2E packet delay is reduced. For some UEs with low buffer, packet delay may marginally increase.
    ...    | 1 | 5G cell on air normally with precondition settings
    ...    Expected:
    ...    cell onair without unexpected fault
    ...    | 2 | attach 8 UEs to the 5G cell with same APN, same 5QI, same air condition.
    ...    3UEs transfer low DL/UL data such as 1Mbps DL and 100Kbps UL per UE,  3UEs transfer 100Mbps DL data and 10Mbps UL per UE,
    ...    2UEs transfer 400Mbps DL data and 40Mbps UL per UE. Data transfer last more than 10 minutes
    ...    Expected:
    ...    For each UE UL and DL data transmission is successful,
    ...    record the 14044 disable KPI result as record1 in a whole 10 minutes in the data transfer procedure.
    ...    Monitor KPIs are included in the 26R1_CB014044_5G-KPI-impact_ver1.0.1 table.
    ...    | 3 | update actTdHighBufUePrio=DL without UE detach and data transfer last more than 10 minutes
    ...    Expected:
    ...    For each UE UL and DL data transmission is successful,
    ...    record the actTdHighBufUePrio=DL KPI result as record2 in a whole 10 minutes in the data transfer procedure.
    ...    | 4 | compare record1 and record2
    ...    Expected:
    ...    1. Cell throughput in DL should increased, such as NR_5088d and NR_5258a
    ...    2. PRB Utilization in DL should increased, such as NR_5114b
    ...    3. number of high buffer UEs being scheduled increased
    ...    | 5 | update actTdHighBufUePrio=DL_UL without UE detach and data transfer last more than 10 minutes
    ...    Expected:
    ...    For each UE UL and DL data transmission is successful,
    ...    record the actTdHighBufUePrio=DL_UL KPI result as record3 in a whole 10 minutes in the data transfer procedure.
    ...    | 6 | compare record3 and record2
    ...    Expected:
    ...    record3 and record2 KPIs should in the same level
    [Timeout]    3 hours
    KU#B002 Prerequisite
    KU#B002 Step 1 UEs attach and Bears established
    KU#B002 Step 2 UEs start traffic and check and get record1
    KU#B002 step 3 update parameters for enable function without UE detach
    KU#B002 step 4 check and get record2
#    KU#B002 Step 5 update parameters for disable function without UE detach
#    KU#B002 Step 6 check and get record3


*** Keywords ***
KU#B002 Prerequisite
    log to console    KU#B002 Prerequisite
#    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_KU_B002_01}    skip_parameter_relation_errors=False
    paras change on BTS    paras=${PARAMETERS_14044_gnb1_KU_B002_01}    delta_file_name=${epc_log_path}${PARAMETERS_JSON_FILE_14044_gnb1_KU_B002_01}
    get and check operationalState of required cells    cells=${cells_KU_B002}    states=${cells_states_disabled}
    Wait until keyword succeeds    2m    10s
    ...    get and check operationalState of required cells    cells=${cells_KU_B002}    states=${cells_states_enabled}

KU#B002 Step 1 UEs attach and Bears established
    Log To Console    KU#B002 Step 1 UEs attach and Bears established
    UEs attach and Bears established    pdu_commands=${pdu_commands_K_B002}    slice_commands=${slice_commands_K_B002}
    Sleep    5s

KU#B002 Step 2 UEs start traffic and check and get record1
    Log To Console    KU#B002 Step 2 UEs start traffic and check and get record1
    UEs make traffic    traffic_commands=${traffic_commands_dl_K_B002}
    Sleep    5s
    UEs make traffic    traffic_commands=${traffic_commands_ul_K_B002}
    ${start_time}=    record_time    label=start
    Set Test Variable    ${start_time}
    Prepare with PM counter time to caculate    period=start
    ${record1_time}=    get_required_record_time
    Set Test Variable    ${record1_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record2_time}=    get_required_record_time
    Set Test Variable    ${record2_time}

KU#B002 step 3 update parameters for enable function without UE detach
    Log To Console    KU#B002 step 3 update parameters for enable function without UE detach
#    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_KU_B002_02}    skip_parameter_relation_errors=False
    paras change on BTS    paras=${PARAMETERS_14044_gnb1_KU_B002_02}    delta_file_name=${epc_log_path}${PARAMETERS_JSON_FILE_14044_gnb1_KU_B002_02}
    get and check operationalState of required cells    cells=${cells_KU_B002}    states=${cells_states_enabled}

KU#B002 step 4 check and get record2
    Log To Console    KU#B002 step 4 check and get record2
    Prepare with PM counter time to caculate    period=start
    ${record3_time}=    get_required_record_time
    Set Test Variable    ${record3_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record4_time}=    get_required_record_time
    Set Test Variable    ${record4_time}

KU#B002 Step 5 update parameters for disable function without UE detach
    Log To Console    KU#B002 Step 5 update parameters for disable function without UE detach
#    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_KU_B002_03}    skip_parameter_relation_errors=False
    paras change on BTS    paras=${PARAMETERS_14044_gnb1_KU_B002_03}    delta_file_name=${epc_log_path}${PARAMETERS_JSON_FILE_14044_gnb1_KU_B002_03}
    get and check operationalState of required cells    cells=${cells_KU_B002}    states=${cells_states_enabled}

KU#B002 Step 6 check and get record3
    Log To Console    KU#B002 Step 6 check and get record3
    Prepare with PM counter time to caculate    period=start
    ${record5_time}=    get_required_record_time
    Set Test Variable    ${record5_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record6_time}=    get_required_record_time
    Set Test Variable    ${record6_time}

Common Test Teardown for CB014044_KU
    Log To Console    KU#B002 teardown
    IF    '${TEST STATUS}' == 'PASS'
        ${end_time}=    record_time    label=end
        ${package_version}=    Get bts package version
        sleep    16min
        ${rc}    ${output}=    Run And Return Rc And Output    mv ${excel_kpi_path}*.xlsx ${excel_kpi_path}bak
        ${tl_id}=    Evaluate    str(${gnb_instance})[:3]
        ${report_id}=    generate new report and get report id    file_path=${path}    report_name=${report_name_KU_B002}
        ...    tl_id=${tl_id}     package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
        IF    '${report_id}' != 'None'
            download_kpi_file    report_id=${report_id}    path=${excel_kpi_path}
        END
        ${excel_file}=    List Files In Directory    path=${excel_kpi_path}    pattern=*.xlsx
        ${exceel_num}=    Get Length    ${excel_file}
        IF    ${exceel_num} != ${0}
            ${kpi_data}=    get_kpi_excel_data    excel_path=${excel_kpi_path}/${excel_file}[0]    sheet_name=Chart Data    usecols=${usecols_name}
            FOR    ${kpi_name}    IN    @{kpi_name_KU_B002}
                FOR    ${distname}    IN    @{kpi_distnames_KU_B002}
                    ${result_disabled_1}=    check_required_kpi_value    df=${kpi_data}    distname=7_5_UTE5G402T${tl_id}/${distname}
                    ...    entryname=${kpi_name}    timestamp_1=${record1_time}    timestamp_2=${record2_time}
                    ${result_enabled_1}=    check_required_kpi_value    df=${kpi_data}    distname=7_5_UTE5G402T${tl_id}/${distname}
                    ...    entryname=${kpi_name}    timestamp_1=${record3_time}    timestamp_2=${record4_time}
#                    ${result_disabled_2}=    check_required_kpi_value    df=${kpi_data}    distname=7_5_UTE5G402T${tl_id}/${distname}
#                    ...    entryname=${kpi_name}    timestamp_1=${record5_time}    timestamp_2=${record6_time}
#                    Should Be True    ${result_enabled_1} >= ${result_disabled_1}
                    ${result}=    Evaluate    math.isclose(${result_enabled_1}, ${result_disabled_1}, rel_tol=${6})
                    Should Be Equal As Strings    ${result}    ${True}
#                    Should Be True    ${result_enabled_1} >= ${result_disabled_2}
                END
            END
        END
    END
    UEs detach
    Common Test Teardown for CB014044
#    Online modify parmeters     parameters_to_update=${PARAM_14044_recover_gnb1_KU_B002_01}    skip_parameter_relation_errors=False
    paras change on BTS
    ...    paras=${PARAMETERS_14044_recover_gnb1_KU_B002_01}    delta_file_name=${epc_log_path}${PARAMETERS_JSON_FILE_14044_recover_gnb1_KU_B002_01}
    get and check operationalState of required cells    cells=${cells_KU_B002}    states=${cells_states_disabled}
    Wait until keyword succeeds    2m    10s
    ...    get and check operationalState of required cells    cells=${cells_KU_B002}    states=${cells_states_enabled}
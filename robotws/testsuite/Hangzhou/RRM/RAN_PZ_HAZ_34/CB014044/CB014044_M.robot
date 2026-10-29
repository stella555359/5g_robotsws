*** Settings ***
Documentation
...    author:  ming.shi@nokia-sbell.com
...    contact: ming.shi@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ4_03

Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    Common Suite Teardown for CB014044
Test Setup        Common Test Setup for CB014044
Test Teardown     Common Test Teardown for CB014044
Force Tags  CA_5G_RRM    PY36
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014044/Resources/CB014044_common_keywords.robot


*** Variables ***
${report_name}    Bb_B004
@{kpi_name}    NR_5088d    NR_5258a    NR_5114b
@{kpi_distname}    NRCELL    NRCELL    NRCELL

*** Test Cases ***
[1]CB014044_Mb#B1_003_Activation_of_Non_GBR_with_actTdPfMetricOpt_and_High_buffer_UE_prioritization_in_TD_scheduler_TDD_DL_and_UL
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
    log to console    Mb#B1_003 Prerequisite
#    Bb#B004 Prerequisite
#    Bb#B004 Step 1 UEs attach and Bears established
#    Bb#B004 Step 2 UEs start traffic and check and get record1
#    Bb#B004 step 3 update actTdHighBufUePrio=DL and get record2
#    Bb#B004 step 4 compare record1 and record2
#    Bb#B004 step 5 update actTdHighBufUePrio=DL_UL and get record3
#    Bb#B004 step 6 compare record3 and record2
#    Bb#B004 step 7 update actTdHighBufUePrio=UL and get record4
#    Bb#B004 step 8 compare record4 and record1


*** Keywords ***
Bb#B004 Prerequisite
    log to console    Bb#B004 Prerequisite
    Online delete parmeters    parameters_to_update=${PARAM_14044_delete_gnb1_Bb_004_01}
    Online modify parmeters    parameters_to_update=${PARAM_14044_gnb1_Bb_004_01}    skip_parameter_relation_errors=False
    check cell on-air status

Bb#B004 Step 1 UEs attach and Bears established
    Log To Console    Bb#B004 Step 1 UEs attach and Bears established
    cp bts_ini file
    Start capture syslog via btslog on ute
    UEs attach and Bears established    pdu_commands=${pdu_commands_Bb_B004}    slice_commands=${slice_commands_Bb_B004}
    [Teardown]    Run Keywords
    ...    Stop capture syslog via btslog on ute
#    ...    AND    Run Keyword And Continue On Failure    check syslog for err    syslog_file_name=Bb_004_err_01
    ...    AND    Run Keyword And Ignore Error    check syslog for err    syslog_file_name=Bb_004_err_01

Bb#B004 Step 2 UEs start traffic and check and get record1
    Log To Console    Bb#B004 Step 2 UEs start traffic and check and get record1
    UEs make traffic    traffic_commands=${traffic_commands_Bb_B004}
    ${start_time}=    record_time    label=start
    Set Test Variable    ${start_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record1_time}=    Evaluate    int(datetime.datetime.now().timestamp() * 1000)
    Set Test Variable    ${record1_time}

Bb#B004 step 3 update actTdHighBufUePrio=DL and get record2
    Log To Console    Bb#B004 step 3 update actTdHighBufUePrio=DL and get record2
    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_Bb_004_02}    skip_parameter_relation_errors=False

Bb#B004 step 4 compare record1 and record2
    Log To Console    Bb#B004 step 4 compare record1 and record2
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record2_time}=    Evaluate    int(datetime.datetime.now().timestamp() * 1000)
    Set Test Variable    ${record2_time}

Bb#B004 step 5 update actTdHighBufUePrio=DL_UL and get record3
    Log To Console    Bb#B004 step 5 update actTdHighBufUePrio=DL_UL and get record3
    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_Bb_004_03}    skip_parameter_relation_errors=False

Bb#B004 step 6 compare record3 and record2
    Log To Console    Bb#B004 step 6 compare record3 and record2
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record3_time}=    Evaluate    int(datetime.datetime.now().timestamp() * 1000)
    Set Test Variable    ${record3_time}

Bb#B004 step 7 update actTdHighBufUePrio=UL and get record4
    Log To Console    Bb#B004 step 7 update actTdHighBufUePrio=UL and get record4
    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_Bb_004_04}    skip_parameter_relation_errors=False

Bb#B004 step 8 compare record4 and record1
    Log To Console    Bb#B004 step 8 compare record4 and record1
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record4_time}=    Evaluate    int(datetime.datetime.now().timestamp() * 1000)
    Set Test Variable    ${record4_time}


*** Keywords ***
Common Test Teardown for CB014044_Bb
    IF    '${TEST STATUS}' == 'PASS'
        ${end_time}=    record_time    label=end
        ${package_version}=    Get bts package version
        sleep    16min
        ${rc}    ${output}=    Run And Return Rc And Output    mv ${excel_kpi_path}*.xlsx ${excel_kpi_path}bak
        ${tl_id}=    Evaluate    str(${gnb_instance})[:3]
        ${report_id}=    generate new report and get report id    file_path=${path}    report_name=${report_name}
        ...    tl_id=${tl_id}     package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
        IF    '${report_id}' != 'None'
            download_kpi_file    report_id=${report_id}    path=${excel_kpi_path}
        END
        ${excel_file}=    List Files In Directory    path=${excel_kpi_path}    pattern=*.xlsx
        ${exceel_num}=    Get Length    ${excel_file}
        IF    ${exceel_num} != ${0}
            excel_sheet_to_json
            ...    excel_path=${excel_kpi_path}/${excel_file}[0]    sheet_name=Chart Data    json_path=${excel_kpi_path}/${excel_file}[0][:-5].json
            ${check_kpi_record}    Create List
#            FOR    ${name}    ${dist}    IN ZIP    ${kpi_name}    ${kpi_distname}
#                ${record}=    get_related_kpis    kpi_name=${name}    dist_name=${dist}    json_path=${excel_kpi_path}/${excel_file}[0][:-5].json
#                ...    record1=${record1_time}    record2=${record2_time}    record3=${record3_time}    record4=${record4_time}
#                Append To List    ${check_kpi_record}    ${record}
#            END
        END
    END
#    Run Keyword And Ignore Error    UEs release pdu and detach    release_pdu_commands=${release_pdu_commands_Bb_B004}
    Run Keyword And Ignore Error    UEs detach
    Common Test Teardown for CB014044
    Online modify parmeters     parameters_to_update=${PARAM_14044_recover_gnb1_Bb_004_01}    skip_parameter_relation_errors=False
    check cell on-air status
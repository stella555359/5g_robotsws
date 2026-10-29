*** Settings ***
Documentation
...    author:  ming.shi@nokia-sbell.com
...    contact: ming.shi@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ4_03

Suite Setup    robot_common_operations.Common Suite Setup
#Suite Setup    Common Suite Setup for CB014044    wts_command=${set_wts_configuration_file_command_D_B011}
Suite Teardown    Common Suite Teardown for CB014044
Force Tags  CA_5G_RRM    PY36
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014044/Resources/CB014044_common_keywords.robot

*** Variables ***
${report_name_D_B009}    D_B009
${report_name_D_B011}    D_B011
@{kpi_name_D_B009}    NR_5088d    NR_5258a    NR_5114b
@{kpi_name_D_B011}    NR_5088d    NR_5258a    NR_5114b
@{kpi_distname}    NRCELL    NRCELL    NRCELL


*** Test Cases ***
[1]CB014044_D#B009_Dynamic_slice_aware_scheduler_in_SA_DL_TDD_all_14044_algo_update_with_Enhanced_slice_aware_scheduler_activated
    [Documentation]
    ...    1. DESCRIPTION
    ...    This User Scenario aims to check that with all 14044 algo change, the configured quotas are reflected in the PRB share
    ...    for each configured slice in SA mode with_Enhanced_slice_aware_scheduler_activated.
    ...    2. TEST ENVIRONMENT AND SETTINGS
    ...    - 1 X ASIL
    ...    - 1 X ABIP
    ...    - 1 X 5G RU(TDD:AVHA)
    ...    - 8 X UEs: SPARK 8 UEs, UE1/2/3/4 configured with slice1 and UE5/6/7/8 configured with slice2,
    ...    all UEs have 5QI=5 DRB which set as non-GBR not non-GBR signaling, UE1/5 have 5QI=6 DRB, UE2/6 have 5QI=7 DRB,
    ...    UE3/7 have 5QI=8 DRB, UE4/8 have 5QI=9 DRB
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
    ...    - NRCELL.actUlMuMimo= False
    ...    - NRBTS/NRDU.carrierAggregationSupportList is set to None
    ...    - NRBTS.actSliceAwareSchedulerUlAndEnh is set to False(default value)
    ...    - NRBTS.NRCELL.dlHighBufferPrioUeRatio=20% (default)
    ...    - NRBTS.NRCELL.ulHighBufferPrioUeRatio=20% (default)
    ...    - NRBTS.NRCELL.actBestNList=disabled
    ...    - NRBTS.NRCELL.actFdAlgoEnh=disabled
    ...    - NRBTS.NRCELL.actTdPfMetricOpt=disabled
    ...    - maxNumPdschAllocationPerSlot=6
    ...    - miNrCellUtilization=5min
    ...    - miNrCellUtilPerNrg=5min
    ...    - NRBTS.actSliceAwareScheduler=true and NRBTS.actDynamicTargetShareCalcForRg=True and at least two slices profile
    ...    (NRRESOURCEGROUP_PROFILE) exists
    ...    - NRBTS.actSliceAwareSchedulerUlAndEnh = True
    ...    - One/multiple PLMN with multiple slices and the min prioritized and max quota of each slice are configured.
    ...    SLICE1 profile schedulerParams of minQuota=15% and maxQuota=45%
    ...    SLICE2 profile schedulerParams of minQuota=10% and maxQuota=55%
    ...    MRBTS/NRBTS/NRDRB.schedulWeight has different scheduling weights for non-GBR bearers configured, e.g.:
    ...    5QI=5: NRBTS/NRDRB.schedulWeight = 40 (Only for non-GBR data, not for non-GBR signaling)
    ...    5QI=6: NRBTS/NRDRB.schedulWeight = 20
    ...    5QI=7: NRBTS/NRDRB.schedulWeight = 10
    ...    5QI=8: NRBTS/NRDRB.schedulWeight = 5
    ...    5QI=9: NRBTS/NRDRB.schedulWeight =1
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
    ...    The attached UEs are scheduled
    ...    The DL PRB share of each slice is counted over the duration of the test
    ...    From the configured quotas, a target share is calculated for each slice.
    ...    The slice target share is achieved by adjusting the slice-specific weight every slot based on PDSCH allocations
    ...    The slice weight is used in the different scheduling stages to affect the PRB share of each slice
    ...    Acceptance criteria:
    ...    The DL PRB share of a slice converges to a calculated target share which respects the configured slice quotas
    ...    (falls between the configured min & max quotas).
    ...    The convergence should be visible in 1000ms or less.
    ...    Convergence after enabling any enhanced algorithm(s) separately (in Presched/TD/FD) shall be same or faster than
    ...    when the same algorithm(s) is not applied.
    ...    The minimum prioritized quota is only respected if there is enough traffic in the slice
    ...    1	5G cell on air normally with precondition settings
    ...    Expected: cell onair without unexpected fault
    ...    2	"8UEs attach to 5G cell,
    ...    UE1/UE5  transfer data on 5QI5 with DL 1M/UL 100K;
    ...    UE2/UE6  transfer data on 5QI6 with DL 10M/UL 1M;
    ...    UE3/UE7  transfer data on 5QI7 with DL 100M/UL 10M;
    ...    UE4 transfer data on 5QI8 with DL 200M/UL 20M;
    ...    UE8 transfer data on 5QI9 with DL 200M/UL 20M;
    ...    Data transfer last more than 10 minutes"
    ...    Expected:
    ...    "all UEs can attach and transfer data successfully.
    ...    Below counters begin to update for NRRESOURCEGROUP1 link to slice1 and NRRESOURCEGROUP2 link to slice2:
    ...    DL_PRB_USED_DATA_NRG  ---  M55910C00001
    ...    DL_PRB_UTIL_SLOT_MAX_NRG  ---  M55910C00002
    ...    UL_PRB_USED_DATA_NRG  ---  M55910C00003
    ...    UL_PRB_UTIL_SLOT_MAX_NRG  ---  M55910C00004
    ...    UL_PRB_AVAIL_SAS   ---   M55308C10012
    ...    DL_PRB_AVAIL_SAS   ---  M55308C10013
    ...    check the slice1 used PRB between 15% to 45%
    ...    the slice2 used PRB between 10% to 55%
    ...    record the KPI result as record1 in a whole 10 minutes in the data transfer procedure.
    ...    Monitor KPIs are included in the 26R1_CB014044_5G-KPI-impact_ver1.0.1 table."
    ...    3	"update
    ...    actBestNList=DL_UL
    ...    actTdPfMetricOpt=DL_UL
    ...    actTdHighBufUePrio=DL_UL
    ...    actFdAlgoEnh=DL_UL
    ...    without UE detach and data transfer last more than 10 minutes"
    ...    Expected:For each UE UL and DL data transmission is successful,
    ...    record the 14044 all enabled KPI result as record2 in a whole 10 minutes in the data transfer procedure.
    ...    4	compare record1 and record2
    ...    Expected:
    ...    "1. Cell throughput in DL should increased, such as NR_5088d and NR_5258a
    ...    2. PRB Utilization in DL should increased, such as NR_5114b"
    ...    5	"update
    ...    actBestNList=disable
    ...    actTdPfMetricOpt=disable
    ...    actTdHighBufUePrio=disable
    ...    actFdAlgoEnh=disable
    ...    without UE detach"
    ...    Expected:For each UE UL and DL data transmission is successful,
    ...    6	stop all data transfer and detach all UEs
    ...    Expected: data stop transfer and Ues detach successfully without unexpected error log print
    [Timeout]    3 hours
    [Setup]    Common Test Setup for CB014044 without AP
    D#B009 Prerequisite
#    D#B009 Step 1 8UEs attach and transfer data
#    D#B009 Step 2 check and get record1
#    D#B009 Step 3 update parameters for enable function without UE detach
#    D#B009 Step 4 check and get record2
#    D#B009 Step 5 update parameters for disable function without UE detach
#    D#B009 Step 6 check and get record3
    [Teardown]    Common Test Teardown for CB014044 without AP
#    [Teardown]    D#B009 teardown


[1]CB014044_D#B011_Dynamic_slice_aware_scheduler_in_SA_DL_TDD_all_14044_algo_update_with_large_number_UEs
    [Documentation]
    ...    1. DESCRIPTION
    ...    This User Scenario aims to check that with all 14044 algo change, the configured quotas are reflected in the PRB
    ...    share for each configured slice in SA mode with large number UEs.
    ...    2. TEST ENVIRONMENT AND SETTINGS
    ...    - 1 X ASIL
    ...    - 1 X ABIP
    ...    - Airphone to simulate AVHA and 60UEs.
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
    ...    - NRCELL.actUlMuMimo= False
    ...    - NRBTS/NRDU.carrierAggregationSupportList is set to None
    ...    - NRBTS.actSliceAwareSchedulerUlAndEnh is set to True
    ...    - NRBTS.NRCELL.dlHighBufferPrioUeRatio=20% (default)
    ...    - NRBTS.NRCELL.ulHighBufferPrioUeRatio=20% (default)
    ...    - NRBTS.NRCELL.actBestNList=disabled
    ...    - NRBTS.NRCELL.actFdAlgoEnh=disabled
    ...    - NRBTS.NRCELL.actTdPfMetricOpt=disabled
    ...    - maxNumPdschAllocationPerSlot=16
    ...    - miNrCellUtilization=5min
    ...    - miNrCellUtilPerNrg=5min
    ...    - NRBTS.actSliceAwareScheduler=true and NRBTS.actDynamicTargetShareCalcForRg=True and at least two slices profile
    ...    (NRRESOURCEGROUP_PROFILE) exists
    ...    - One/multiple PLMN with multiple slices and the min prioritized and max quota of each slice are configured.
    ...    SLICE1 profile schedulerParams of minQuota=15% and maxQuota=45%
    ...    SLICE2 profile schedulerParams of minQuota=10% and maxQuota=55%
    ...    UE0-UE29 belong to SLICE1 and UE30-UE59 belong to SLICE2,
    ...    UE0-UE5 and UE30-UE35 have 5QI=5 DRB(set as non-GBR but not non-GBR signaling),
    ...    UE6-UE11 and UE36-UE41 have 5QI=6 DRB
    ...    UE12-UE17 and UE42-UE47 have 5QI=7 DRB
    ...    UE18-UE23 and UE48-UE53 have 5QI=8 DRB
    ...    UE24-UE29 and UE54-UE59 have 5QI=9 DRB
    ...    MRBTS/NRBTS/NRDRB.schedulWeight has different scheduling weights for non-GBR bearers configured, e.g.:
    ...    5QI=5: NRBTS/NRDRB.schedulWeight = 40 (Only for non-GBR data, not for non-GBR signaling)
    ...    5QI=6: NRBTS/NRDRB.schedulWeight = 20
    ...    5QI=7: NRBTS/NRDRB.schedulWeight = 10
    ...    5QI=8: NRBTS/NRDRB.schedulWeight = 5
    ...    5QI=9: NRBTS/NRDRB.schedulWeight =1
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
    ...    The attached UEs are scheduled
    ...    The DL PRB share of each slice is counted over the duration of the test
    ...    From the configured quotas, a target share is calculated for each slice.
    ...    The slice target share is achieved by adjusting the slice-specific weight every slot based on PDSCH allocations
    ...    The slice weight is used in the different scheduling stages to affect the PRB share of each slice
    ...    Acceptance criteria:
    ...    The DL PRB share of a slice converges to a calculated target share which respects the configured slice quotas
    ...    (falls between the configured min & max quotas).
    ...    The convergence should be visible in 1000ms or less.
    ...    Convergence after enabling any enhanced algorithm(s) separately (in Presched/TD/FD) shall be same or faster
    ...    than when the same algorithm(s) is not applied.
    ...    The minimum prioritized quota is only respected if there is enough traffic in the slice
    ...    | Step Name       | Description                                        | Expected
    ...    | 1               | 5G cell on air normally with precondition settings | cell onair without unexpected fault
    ...    | 2               | 60UEs attach to 5G cell,  transfer data on all 5QI5 DRBs with DL 1M/UL 100K;
    ...                        transfer data on all 5QI6 DRBs with DL 10M/UL 1M;
    ...                        transfer data on all 5QI7 DRBs with DL 100M/UL 10M;
    ...                        transfer data on all 5QI8/9 DRBs with DL 200M/UL 20M;
    ...                        Data transfer last more than 10 minutes
    ...    | all UEs can attach and transfer data successfully.
    ...    Below counters begin to update for NRRESOURCEGROUP1 link to slice1 and NRRESOURCEGROUP2 link to slice2:
    ...    DL_PRB_USED_DATA_NRG  ---  M55910C00001 DL_PRB_UTIL_SLOT_MAX_NRG  ---  M55910C00002 UL_PRB_USED_DATA_NRG
    ...    ---  M55910C00003 UL_PRB_UTIL_SLOT_MAX_NRG  ---  M55910C00004 UL_PRB_AVAIL_SAS   ---   M55308C10012 DL_PRB_AVAIL_SAS
    ...    ---  M55308C10013 check the slice1 used PRB between 15% to 45% the slice2 used PRB between 10% to 55% record the KPI
    ...    result as record1 in a whole 10 minutes in the data transfer procedure. Monitor KPIs are included in
    ...    the 26R1_CB014044_5G-KPI-impact_ver1.0.1 table.
    ...    | 3               | update actBestNList=DL_UL actTdPfMetricOpt=DL_UL actTdHighBufUePrio=DL_UL actFdAlgoEnh=DL_UL
    ...    without UE detach and data transfer last more than 10 minutes
    ...    | For each UE UL and DL data transmission is successful,
    ...    record the 14044 all enabled KPI result as record2 in a whole 10 minutes in the data transfer procedure.
    ...    | 4               | compare record1 and record2
    ...    | 1. Cell throughput in DL should increased, such as NR_5088d and NR_5258a 2. PRB Utilization in DL should increased, such as NR_5114b
    ...    | 5               | update  actBestNList=disable actTdPfMetricOpt=disable actTdHighBufUePrio=disable actFdAlgoEnh=disable
    ...    without UE detach
    ...    | For each UE UL and DL data transmission is successful,
    ...    | 6               | stop all data transfer and detach all UEs
    ...    | data stop transfer and Ues detach successfully without unexpected error log print
    [Timeout]    3 hours
    [Setup]    Common Test Setup for CB014044
    D#B011 Prerequisite
#    D#B011 Step 1 UEs attach and Bears established
#    D#B011 Step 2 UEs start traffic and check and get record1
#    D#B011 step 3 update parameters for enable function without UE detach
#    D#B011 step 4 check and get record2
#    D#B011 step 5 update parameters for disable function without UE detach
#    D#B011 step 6 check and get record3
#    [Teardown]    D#B011 teardown
    [Teardown]    Common Test Teardown for CB014044


*** Keywords ***
D#B009 Prerequisite
    Log To Console    D#B009 Prerequisite
#    Online delete parmeters    parameters_to_update=${PARAM_14044_delete_gnb1_D_B009_01}
#    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_D_B009_01}    skip_parameter_relation_errors=False
#    check cell on-air status

D#B009 Step 1 8UEs attach and transfer data
    Log To Console    D#B009 Step 1 8UEs attach and transfer data
    8UEs attach
    8UEs transfer data
    ${start_time}=    record_time    label=start
    Set Test Variable    ${start_time}

D#B009 Step 2 check and get record1
    Log To Console    D#B009 Step 2 check and get record1
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record1_time}=    Evaluate    int(datetime.datetime.now().timestamp() * 1000)
    Set Test Variable    ${record1_time}

D#B009 Step 3 update parameters for enable function without UE detach
    Log To Console    D#B009 Step 3 update parameters for enable function without UE detach
    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_D_B009_02}    skip_parameter_relation_errors=False

D#B009 Step 4 check and get record2
    Log To Console    D#B009 Step 4 check and get record2
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record2_time}=    Evaluate    int(datetime.datetime.now().timestamp() * 1000)
    Set Test Variable    ${record2_time}

D#B009 Step 5 update parameters for disable function without UE detach
    Log To Console    D#B009 Step 5 update parameters for disable function without UE detach
    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_D_B009_03}    skip_parameter_relation_errors=False

D#B009 Step 6 check and get record3
    Log To Console    D#B009 Step 6 check and get record3
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record3_time}=    Evaluate    int(datetime.datetime.now().timestamp() * 1000)
    Set Test Variable    ${record3_time}

D#B009 teardown
    Log To Console    D#B009 teardown
    IF    '${TEST STATUS}' == 'PASS'
        ${end_time}=    record_time    label=end
        ${package_version}=    Get bts package version
        sleep    16min
        ${rc}    ${output}=    Run And Return Rc And Output    mv ${excel_kpi_path}*.xlsx ${excel_kpi_path}bak
        ${tl_id}=    Evaluate    str(${gnb_instance})[:3]
        ${report_id}=    generate new report and get report id    file_path=${path}    report_name=${report_name_D_B009}
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
#            FOR    ${name}    ${dist}    IN ZIP    ${kpi_name_D_B009}    ${kpi_distname}
#                ${record}=    get_related_kpis    kpi_name=${name}    dist_name=${dist}    json_path=${excel_kpi_path}/${excel_file}[0][:-5].json
#                ...    record1=${record1_time}    record2=${record2_time}    record3=${record3_time}
#                Append To List    ${check_kpi_record}    ${record}
#            END
        END
    END
    8UEs stop transfer data
    8UEs detach
    Common Test Teardown for CB014044 without AP
    Online modify parmeters     parameters_to_update=${PARAM_14044_recover_gnb1_D_B009_01}    skip_parameter_relation_errors=False
    check cell on-air status







D#B011 Prerequisite
    Log To Console    D#B011 Prerequisite
#    Online delete parmeters    parameters_to_update=${PARAM_14044_delete_gnb1_D_B011_01}
#    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_D_B011_01}    skip_parameter_relation_errors=False
#    check cell on-air status

D#B011 Step 1 UEs attach and Bears established
    Log To Console    D#B011 Step 1 UEs attach and Bears established
    cp bts_ini file
    Start capture syslog via btslog on ute
    UEs attach and Bears established    pdu_commands=${pdu_commands_D_B011}    slice_commands=${slice_commands_D_B011}
    [Teardown]    Run Keywords
    ...    Stop capture syslog via btslog on ute
#    ...    AND    Run Keyword And Continue On Failure    check syslog for err    syslog_file_name=D_B011_err_01
    ...    AND    Run Keyword And Ignore Error    check syslog for err    syslog_file_name=D_B011_err_01

D#B011 Step 2 UEs start traffic and check and get record1
    Log To Console    D#B011 Step 2 UEs start traffic and check and get record1
    UEs make traffic    traffic_commands=${traffic_commands_D_B011}
    ${start_time}=    record_time    label=start
    Set Test Variable    ${start_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record1_time}=    Evaluate    int(datetime.datetime.now().timestamp() * 1000)
    Set Test Variable    ${record1_time}

D#B011 step 3 update parameters for enable function without UE detach
    Log To Console    D#B011 step 3 update parameters for enable function without UE detach
    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_D_B011_02}    skip_parameter_relation_errors=False

D#B011 step 4 check and get record2
    Log To Console    D#B011 step 4 check and get record2
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record2_time}=    Evaluate    int(datetime.datetime.now().timestamp() * 1000)
    Set Test Variable    ${record2_time}

D#B011 step 5 update parameters for disable function without UE detach
    Log To Console    D#B011 step 5 update parameters for disable function without UE detach
    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_D_B011_03}    skip_parameter_relation_errors=False

D#B011 step 6 check and get record3
    Log To Console    D#B011 step 6 check and get record3
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record3_time}=    Evaluate    int(datetime.datetime.now().timestamp() * 1000)
    Set Test Variable    ${record3_time}

D#B011 teardown
    Log To Console    D#B011 teardown
    IF    '${TEST STATUS}' == 'PASS'
        ${end_time}=    record_time    label=end
        ${package_version}=    Get bts package version
        sleep    16min
        ${rc}    ${output}=    Run And Return Rc And Output    mv ${excel_kpi_path}*.xlsx ${excel_kpi_path}bak
        ${tl_id}=    Evaluate    str(${gnb_instance})[:3]
        ${report_id}=    generate new report and get report id    file_path=${path}    report_name=${report_name_D_B011}
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
#            FOR    ${name}    ${dist}    IN ZIP    ${kpi_name_D_B011}    ${kpi_distname}
#                ${record}=    get_related_kpis    kpi_name=${name}    dist_name=${dist}    json_path=${excel_kpi_path}/${excel_file}[0][:-5].json
#                ...    record1=${record1_time}    record2=${record2_time}    record3=${record3_time}
#                Append To List    ${check_kpi_record}    ${record}
#            END
        END
    END
    UEs detach
    Common Test Teardown for CB014044
    Online modify parmeters     parameters_to_update=${PARAM_14044_recover_gnb1_D_B011_01}    skip_parameter_relation_errors=False
    check cell on-air status

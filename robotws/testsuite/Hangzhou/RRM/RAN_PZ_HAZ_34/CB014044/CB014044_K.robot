*** Settings ***
Documentation
...    author:  ming.shi@nokia-sbell.com
...    contact: ming.shi@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ4_03

Suite Setup    Common Suite Setup for CB014044
Suite Teardown    Common Suite Teardown for CB014044
Force Tags  CA_5G_RRM    PY36
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014044/Resources/CB014044_common_keywords.robot


*** Variables ***
${report_name_K_B001}    K_B001
${report_name_K_B002}    K_B002
@{kpi_name_K_B001}    NR_5088d    NR_5258a    NR_5114b
@{kpi_name_K_B002}    NR_5088d    NR_5258a    NR_5114b
@{kpi_distnames_K_B001}    NRCELL-1    NRCELL-2
@{kpi_distnames_K_B002}    NRCELL-3


*** Test Cases ***
[1]CB014044_K#B001_KPI_Impact_analysis_of_Increased_Efficiency_and_fairness_of_non-GBR_scheduler_in_RAT1_8UEs
    [Documentation]
    ...    1. DESCRIPTION
    ...    This user scenario intends to check the KPI impact of the increased efficiency and fairness of nonGBR scheduler
    ...    in RAT1 when 14044 feature enable and disable with 8UEs and limit maxNumPdschAllocationPerSlot=6.
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
    ...    - actSlowPrbPooling = True
    ...    - NRBTS.NRCELL.pucchModeSelect=longPucch
    ...    - NRBTS.NRCELL.lteNrDssMode=none
    ...    - NRCELL.actDlMuMimoEnh = True
    ...    - NRCELL.actUlMuMimo= True
    ...    - NRBTS/NRDU.carrierAggregationSupportList is set to None
    ...    - NRBTS.actSliceAwareSchedulerUlAndEnh is set to True(default value)
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
    ...    KPIs averaged over the observation period after feature activation follows the KPI pattern as specified in the KPI impact list
    ...    Acceptance criteria:
    ...    follow the KPI impact list, one way specific impact should be checked after
    ...    enable CB014044 flags with same data transfer compare with feature disable.
    ...    | Step Name       | Description             | Expected
    ...    | 1               | 5G cell on air normally with precondition settings     | cell onair without unexpected fault
    ...    | 2               | 8UEs attach to 5G cell,  UE1/UE5  transfer data on 5QI5 with DL 1M/UL 100K;
    ...    UE2/UE6  transfer data on 5QI6 with DL 10M/UL 1M;  UE3/UE7  transfer data on 5QI7 with DL 100M/UL 10M;
    ...    UE4 transfer data on 5QI8 with DL 200M/UL 20M; UE8 transfer data on 5QI9 with DL 200M/UL 20M;
    ...    Data transfer last more than 60 minutes
    ...    | all UEs can attach and transfer data successfully.
    ...    record the KPI result as record1 in a whole 60 minutes in the data transfer procedure.
    ...    Monitor KPIs are included in the 26R1_CB014044_5G-KPI-impact_ver1.0.1 table.
    ...    | 3               | update actBestNList=DL_UL actTdPfMetricOpt=DL_UL actTdHighBufUePrio=DL_UL actFdAlgoEnh=DL_UL
    ...    without UE detach and data transfer last more than 60 minutes
    ...    | For each UE UL and DL data transmission is successful, record the 14044 all enabled KPI result as record2
    ...    in a whole 60 minutes in the data transfer procedure.
    ...    | 4               | compare record1 and record2
    ...    | follow the KPI impact list, one way specific impact should be checked after enable CB014044 flags
    ...    with same data transfer compare with feature disable. Record2 should better than record1
    ...    | 5               | stop all data transfer and detach all UEs
    ...    | data stop transfer and Ues detach successfully without unexpected error log print
    [Timeout]    3 hours
    [Setup]    Common Test Setup for CB014044 without AP
    K#B001 Prerequisite
    K#B001 Step 1 8UEs attach and transfer data
    K#B001 Step 2 check and get record1
    K#B001 Step 3 update parameters for enable function without UE detach
    K#B001 Step 4 check and get record2
#    K#B001 Step 5 update parameters for disable function without UE detach
#    K#B001 Step 6 check and get record3
    [Teardown]    K#B001 teardown


[1]CB014044_K#B002_KPI_Impact_analysis_of_Increased_Efficiency_and_fairness_of_non-GBR_scheduler_in_RAT1_60UEs
    [Documentation]
    ...    1. DESCRIPTION
    ...    This user scenario intends to check the KPI impact of the increased efficiency and fairness of
    ...    nonGBR scheduler in RAT1 when 14044 feature enable and disable with 60UEs.
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
    ...    - NRBTS.actSliceAwareSchedulerUlAndEnh is set to False(default value)
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
    ...    KPIs averaged over the observation period after feature activation follows the KPI pattern as specified in the KPI impact list
    ...    Acceptance criteria:
    ...    follow the KPI impact list, one way specific impact should be checked after enable CB014044
    ...    flags with same data transfer compare with feature disable.
    ...    | Step Name       | Description                     | Expected
    ...    | 1               | 5G cell on air normally with precondition settings        | cell onair without unexpected fault
    ...    | 2               | 60UEs attach to 5G cell, transfer data on all 5QI5 DRBs with DL 1M/UL 100K;
    ...    transfer data on all 5QI6 DRBs with DL 10M/UL 1M;  transfer data on all 5QI7 DRBs with DL 100M/UL 10M;
    ...    transfer data on all 5QI8/9 DRBs with DL 200M/UL 20M; Data transfer last more than 60 minutes
    ...    | all UEs can attach and transfer data successfully.
    ...    record the KPI result as record1 in a whole 60 minutes in the data transfer procedure.
    ...    Monitor KPIs are included in the 26R1_CB014044_5G-KPI-impact_ver1.0.1 table.
    ...    | 3               | update actBestNList=DL_UL actTdPfMetricOpt=DL_UL actTdHighBufUePrio=DL_UL actFdAlgoEnh=DL_UL
    ...    without UE detach and data transfer last more than 60 minutes
    ...    | For each UE UL and DL data transmission is successful, record the 14044 all enabled KPI result as record2
    ...    in a whole 60 minutes in the data transfer procedure.
    ...    | 4               | compare record1 and record2
    ...    | follow the KPI impact list,  one way specific impact should be checked after enable CB014044 flags with same
    ...    data transfer compare with feature disable. Record2 should better than record1
    ...    | 5               | stop all data transfer and detach all UEs
    ...    | data stop transfer and Ues detach successfully without unexpected error log print
    [Timeout]    3 hours
    [Setup]    Common Test Setup for CB014044
    K#B002 Prerequisite
    K#B002 Step 1 UEs attach and Bears established
    K#B002 Step 2 UEs start traffic and check and get record1
    K#B002 step 3 update parameters for enable function without UE detach
    K#B002 step 4 check and get record2
#    K#B002 Step 5 update parameters for disable function without UE detach
#    K#B002 Step 6 check and get record3
    [Teardown]    K#B002 teardown


*** Keywords ***
K#B001 Prerequisite
    log to console    K#B001 Prerequisite
#    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_K_B001_01}    skip_parameter_relation_errors=False
    paras change on BTS    paras=${PARAMETERS_14044_gnb1_K_B001_01}    delta_file_name=${epc_log_path}${PARAMETERS_JSON_FILE_14044_gnb1_K_B001_01}
    get and check operationalState of required cells    cells=${cells_K_B001}    states=${cells_states_disabled}
    Wait until keyword succeeds    2m    10s
    ...    get and check operationalState of required cells    cells=${cells_K_B001}    states=${cells_states_enabled_disabled}

K#B001 Step 1 8UEs attach and transfer data
    Log To Console    K#B001 Step 1 8UEs attach and transfer data
    ${dl_diff_tput}    ${check_dl_diff_tput}    ${ul_diff_tput}    ${check_ul_diff_tput}=    set_diff_tput_variable
    ...    dl_tput=${1470}    ul_tput=${228}
    Set Test Variable    ${dl_diff_tput}
    Set Test Variable    ${check_dl_diff_tput}
    Set Test Variable    ${ul_diff_tput}
    Set Test Variable    ${check_ul_diff_tput}
    Set Test Variable    @{used_ues_index}    ${0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}
    8UEs attach
    8UEs transfer data
    ${start_time}=    record_time    label=start
    Set Test Variable    ${start_time}

K#B001 Step 2 check and get record1
    Log To Console    K#B001 Step 2 check and get record1
    Prepare with PM counter time to caculate    period=start
    ${record1_time}=    get_required_record_time
    Set Test Variable    ${record1_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record2_time}=    get_required_record_time
    Set Test Variable    ${record2_time}
#    #####pioneer part#####
#    Check traffic with pioneer client with pioneer client for diff throughput
#    ...    tput_target=${check_dl_diff_tput}    ues_index=${used_ues_index}    direction=dl
#    Check traffic with pioneer client with pioneer client for diff throughput
#    ...    tput_target=${check_ul_diff_tput}    ues_index=${used_ues_index}    direction=ul
#    #####pioneer part#####
    #####Spark part#####
    Check traffic with spark client with spark client for diff throughput
    ...    tput_target=${check_dl_diff_tput}    ues_index=${used_ues_index}    direction=MACDL
    Check traffic with spark client with spark client for diff throughput
    ...    tput_target=${check_ul_diff_tput}    ues_index=${used_ues_index}    direction=MACUL
    #####Spark part#####

K#B001 Step 3 update parameters for enable function without UE detach
    Log To Console    K#B001 Step 3 update parameters for enable function without UE detach
#    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_K_B001_02}    skip_parameter_relation_errors=False
    paras change on BTS    paras=${PARAMETERS_14044_gnb1_K_B001_02}    delta_file_name=${epc_log_path}${PARAMETERS_JSON_FILE_14044_gnb1_K_B001_02}
    get and check operationalState of required cells    cells=${cells_K_B001}    states=${cells_states_enabled_disabled}

K#B001 Step 4 check and get record2
    Log To Console    K#B001 Step 4 check and get record2
    Prepare with PM counter time to caculate    period=start
    ${record3_time}=    get_required_record_time
    Set Test Variable    ${record3_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record4_time}=    get_required_record_time
    Set Test Variable    ${record4_time}
#    #####pioneer part#####
#    Check traffic with pioneer client with pioneer client for diff throughput
#    ...    tput_target=${check_dl_diff_tput}    ues_index=${used_ues_index}    direction=dl
#    Check traffic with pioneer client with pioneer client for diff throughput
#    ...    tput_target=${check_ul_diff_tput}    ues_index=${used_ues_index}    direction=ul
#    #####pioneer part#####
    #####Spark part#####
    Check traffic with spark client with spark client for diff throughput
    ...    tput_target=${check_dl_diff_tput}    ues_index=${used_ues_index}    direction=MACDL
    Check traffic with spark client with spark client for diff throughput
    ...    tput_target=${check_ul_diff_tput}    ues_index=${used_ues_index}    direction=MACUL
    #####Spark part#####

K#B001 Step 5 update parameters for disable function without UE detach
    Log To Console    K#B001 Step 5 update parameters for disable function without UE detach
#    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_K_B001_03}    skip_parameter_relation_errors=False
    paras change on BTS    paras=${PARAMETERS_14044_gnb1_K_B001_03}    delta_file_name=${epc_log_path}${PARAMETERS_JSON_FILE_14044_gnb1_K_B001_03}
    get and check operationalState of required cells    cells=${cells_K_B001}    states=${cells_states_enabled_disabled}

K#B001 Step 6 check and get record3
    Log To Console    K#B001 Step 6 check and get record3
    Prepare with PM counter time to caculate    period=start
    ${record5_time}=    get_required_record_time
    Set Test Variable    ${record5_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record6_time}=    get_required_record_time
    Set Test Variable    ${record6_time}
#    #####pioneer part#####
#    Check traffic with pioneer client with pioneer client for diff throughput
#    ...    tput_target=${check_dl_diff_tput}    ues_index=${used_ues_index}    direction=dl
#    Check traffic with pioneer client with pioneer client for diff throughput
#    ...    tput_target=${check_ul_diff_tput}    ues_index=${used_ues_index}    direction=ul
#    #####pioneer part#####
    #####Spark part#####
    Check traffic with spark client with spark client for diff throughput
    ...    tput_target=${check_dl_diff_tput}    ues_index=${used_ues_index}    direction=MACDL
    Check traffic with spark client with spark client for diff throughput
    ...    tput_target=${check_ul_diff_tput}    ues_index=${used_ues_index}    direction=MACUL
    #####Spark part#####

K#B001 teardown
    Log To Console    K#B001 teardown
    IF    '${TEST STATUS}' == 'PASS'
        ${end_time}=    record_time    label=end
        ${package_version}=    Get bts package version
        sleep    16min
        ${rc}    ${output}=    Run And Return Rc And Output    mv ${excel_kpi_path}*.xlsx ${excel_kpi_path}bak
        ${tl_id}=    Evaluate    str(${tl.gnbs[0].global_bts_id})[:3]
        ${report_id}=    generate new report and get report id    file_path=${path}    report_name=${report_name_K_B001}
        ...    tl_id=${tl_id}     package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
        IF    '${report_id}' != 'None'
            download_kpi_file    report_id=${report_id}    path=${excel_kpi_path}
        END
        ${excel_file}=    List Files In Directory    path=${excel_kpi_path}    pattern=*.xlsx
        ${exceel_num}=    Get Length    ${excel_file}
        IF    ${exceel_num} != ${0}
            ${kpi_data}=    get_kpi_excel_data    excel_path=${excel_kpi_path}/${excel_file}[0]    sheet_name=Chart Data    usecols=${usecols_name}
            FOR    ${kpi_name}    IN    @{kpi_name_K_B001}
                FOR    ${distname}    IN    @{kpi_distnames_K_B001}
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
    8UEs stop transfer data
    8UEs detach
#    #####pioneer part#####
#    client.stoplog      service=pioneer
#    #####pioneer part#####
    #####Spark part#####
    Spark_multiUE.stop ue log
    #####Spark part#####
    Common Test Teardown for CB014044 without AP
#    Online modify parmeters     parameters_to_update=${PARAM_14044_recover_gnb1_K_B001_01}    skip_parameter_relation_errors=False
    paras change on BTS
    ...    paras=${PARAMETERS_14044_recover_gnb1_K_B001_01}    delta_file_name=${epc_log_path}${PARAMETERS_JSON_FILE_14044_recover_gnb1_K_B001_01}
    get and check operationalState of required cells    cells=${cells_K_B001}    states=${cells_states_disabled}
    Wait until keyword succeeds    2m    10s
    ...    get and check operationalState of required cells    cells=${cells_K_B001}    states=${cells_states_enabled}
    Online delete parmeters    parameters_to_update=${PARAM_14044_recover_delete_gnb1_K_B001_01}






K#B002 Prerequisite
    log to console    K#B002 Prerequisite
#    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_K_B002_01}    skip_parameter_relation_errors=False
    paras change on BTS    paras=${PARAMETERS_14044_gnb1_K_B002_01}    delta_file_name=${epc_log_path}${PARAMETERS_JSON_FILE_14044_gnb1_K_B002_01}
    get and check operationalState of required cells    cells=${cells_K_B002}    states=${cells_states_disabled}
    Wait until keyword succeeds    2m    10s
    ...    get and check operationalState of required cells    cells=${cells_K_B002}    states=${cells_states_enabled}

K#B002 Step 1 UEs attach and Bears established
    Log To Console    K#B002 Step 1 UEs attach and Bears established
    UEs attach and Bears established    pdu_commands=${pdu_commands_K_B002}    slice_commands=${slice_commands_K_B002}
    Sleep    5s

K#B002 Step 2 UEs start traffic and check and get record1
    Log To Console    K#B002 Step 2 UEs start traffic and check and get record1
    UEs make traffic    traffic_commands=${traffic_commands_dl_K_B002}
    ${start_time}=    record_time    label=start
    Set Test Variable    ${start_time}
    Prepare with PM counter time to caculate    period=start
    ${record1_time}=    get_required_record_time
    Set Test Variable    ${record1_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record2_time}=    get_required_record_time
    Set Test Variable    ${record2_time}

K#B002 step 3 update parameters for enable function without UE detach
    Log To Console    K#B002 step 3 update parameters for enable function without UE detach
#    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_K_B002_02}    skip_parameter_relation_errors=False
    paras change on BTS    paras=${PARAMETERS_14044_gnb1_K_B002_02}    delta_file_name=${epc_log_path}${PARAMETERS_JSON_FILE_14044_gnb1_K_B002_02}
    get and check operationalState of required cells    cells=${cells_K_B002}    states=${cells_states_enabled}

K#B002 step 4 check and get record2
    Log To Console    K#B002 step 4 check and get record2
    Prepare with PM counter time to caculate    period=start
    ${record3_time}=    get_required_record_time
    Set Test Variable    ${record3_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record4_time}=    get_required_record_time
    Set Test Variable    ${record4_time}

K#B002 Step 5 update parameters for disable function without UE detach
    Log To Console    K#B002 Step 5 update parameters for disable function without UE detach
#    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_K_B002_03}    skip_parameter_relation_errors=False
    paras change on BTS    paras=${PARAMETERS_14044_gnb1_K_B002_03}    delta_file_name=${epc_log_path}${PARAMETERS_JSON_FILE_14044_gnb1_K_B002_03}
    get and check operationalState of required cells    cells=${cells_K_B002}    states=${cells_states_enabled}

K#B002 Step 6 check and get record3
    Log To Console    K#B002 Step 6 check and get record3
    Prepare with PM counter time to caculate    period=start
    ${record5_time}=    get_required_record_time
    Set Test Variable    ${record5_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record6_time}=    get_required_record_time
    Set Test Variable    ${record6_time}

K#B002 teardown
    Log To Console    K#B002 teardown
    IF    '${TEST STATUS}' == 'PASS'
        ${end_time}=    record_time    label=end
        ${package_version}=    Get bts package version
        sleep    16min
        ${rc}    ${output}=    Run And Return Rc And Output    mv ${excel_kpi_path}*.xlsx ${excel_kpi_path}bak
        ${tl_id}=    Evaluate    str(${tl.gnbs[0].instance_id})[:3]
        ${report_id}=    generate new report and get report id    file_path=${path}    report_name=${report_name_K_B002}
        ...    tl_id=${tl_id}     package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
        IF    '${report_id}' != 'None'
            download_kpi_file    report_id=${report_id}    path=${excel_kpi_path}
        END
        ${excel_file}=    List Files In Directory    path=${excel_kpi_path}    pattern=*.xlsx
        ${exceel_num}=    Get Length    ${excel_file}
        IF    ${exceel_num} != ${0}
            ${kpi_data}=    get_kpi_excel_data    excel_path=${excel_kpi_path}/${excel_file}[0]    sheet_name=Chart Data    usecols=${usecols_name}
            FOR    ${kpi_name}    IN    @{kpi_name_K_B002}
                FOR    ${distname}    IN    @{kpi_distnames_K_B002}
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
#    Online modify parmeters     parameters_to_update=${PARAM_14044_recover_gnb1_K_B002_01}    skip_parameter_relation_errors=False
    paras change on BTS
    ...    paras=${PARAMETERS_14044_recover_gnb1_K_B002_01}    delta_file_name=${epc_log_path}${PARAMETERS_JSON_FILE_14044_recover_gnb1_K_B002_01}
    get and check operationalState of required cells    cells=${cells_K_B002}    states=${cells_states_disabled}
    Wait until keyword succeeds    2m    10s
    ...    get and check operationalState of required cells    cells=${cells_K_B002}    states=${cells_states_enabled}
*** Settings ***
Documentation
...    author:  ming.shi@nokia-sbell.com
...    contact: ming.shi@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ4_03

#Suite Setup    Common Suite Setup for CB014044
Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    Common Suite Teardown for CB014044
Test Setup        Common Test Setup for CB014044 without AP
Test Teardown     Common Test Teardown for CB014044 without AP
#Test Teardown     Common Test Teardown for CB014044_G
Force Tags  CA_5G_RRM    PY36
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014044/Resources/CB014044_common_keywords.robot


*** Variables ***
${report_name_G_B3_03}    G_B3_03
@{kpi_name_G_B3_03}    NR_5088d    NR_5258a    NR_5114b
@{kpi_distname}    NRCELL    NRCELL    NRCELL


*** Test Cases ***
[1]CB014044_G#B3_003_Mix_multiple_non_GBR_and_NBR_UEs_check_Scheduler_Behavior_with_DL_TDD_SA
    [Documentation]
    ...    1. DESCRIPTION
    ...    -Multiple NBR UEs are connected and should receive scheduling priority over non-GBR UEs.
    ...    2. TEST ENVIRONMENT AND SETTINGS
    ...    - 1 X ASIL
    ...    - 1 X ABIP
    ...    - 1 X 5G RU(TDD:AEHC/AVHA)
    ...    - 1 X 5G RU(FDD:AHFIB)
    ...    - 8 X UEs: SPARK 8 UEs/Mutli UEs with airphone
    ...    2.1 Testing Tools
    ...    - Wireshark/Tcpdump/L1/L2 traces/btslog/snapshot
    ...    2.2 Test Automation
    ...    N/A
    ...    3. TEST CASE INFORMATION
    ...    3.1 Definitions from the Test Plan
    ...    NB configuration (SA, FR1,TDD/FDD, classicBTS,100Mhz/20Mhz)
    ...    NRCELL.actRat1Alloc = True
    ...    NRBTS.NRCELL.actDlSchLowBufferOpt=True
    ...    NRBTS.NRCELL.actUlSchLowBufferOpt=True
    ...    5QI-82 discardTimer = 10ms
    ...    5QI-83 discardTimer = 10ms
    ...    5QI-84 discardTimer = 30ms
    ...    NRBTS/NRDRB/dlFlowControlAlgo = 3gppFlowControl
    ...    [Best N List]
    ...    NRBTS.NRCELL.actBestNList=DL
    ...    NRBTS.NRCELL.dlBestNListRatio= 20%. (Default)
    ...    NRBTS.NRCELL.actTdHighBufPrio=DL
    ...    NRBTS.NRCELL.actTdPfMetricOpt = DL
    ...    NRBTS.NRCELL.actFdAlgoEnh = DL
    ...    MRBTS/NRBTS/NRDRB.schedulWeight has different scheduling weights for non-GBR bearersconfigured,
    ...    5QI=5: NRBTS/NRDRB.schedulWeight = 40(Only for non-GBR data, not for non-GBR signaling)
    ...    5QI=6: NRBTS/NRDRB.schedulWeight = 20
    ...    5QI=7: NRBTS/NRDRB.schedulWeight = 10
    ...    5QI=8: NRBTS/NRDRB.schedulWeight = 5 also config as NBR bear and nbrDl = 5Mbit/s
    ...    5QI=9: NRBTS/NRDRB.schedulWeight =1 also config as NBR bear and nbrDl = 5Mbit/s
    ...    CA configuration is off.
    ...    actSliceAwareScheduler is set to True & at least one slice profile (NRRESOURCEGROUP_PROFILE)exists
    ...    One/multiple PLMN with multiple slices and the min prioritized and max quota of each slice areconfigured.
    ...    Multiple UEs are attached to the cell (with various radio conditions for real UEs).
    ...    Each UE is configured with one or multiple non-GBR DRBs (some of them are with full buffer).
    ...    All DRBs belong to one of the available slices.
    ...    MU-MIMO, CA, GBR DRBs (incl. VoNR) and PRB pooling are not expected for this test case.
    ...    5GC provided 5QI-65 DC-GBR-QosInformation:guaranteedFlowBitRateUL/DL = 200Kbps
    ...    5GC provided 5QI-66 DC-GBR-QosInformation:guaranteedFlowBitRateUL/DL = 1.1Mbps
    ...    5GC provided 5QI-67 DC-GBR-QosInformation:guaranteedFlowBitRateUL/DL = 370kps
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
    ...    DC-GBR UEs continue to send/receive data
    ...    DC-GBR+GBR UE continues to send / receive data
    ...    Full buffer non-GBR UEs continue to send / receive data
    ...    | Step Name       | Description           | Expected
    ...    | Step 1          | Attach With 8 UEs to the target 5G CELL UE1-6 creat with one Non-GBR bears from 5QI5/6/7,
    ...    2UE use same 5QI UE7 Connect with one MC-GBR 5QI-8 UE8 Connect with one MC-GBR 5QI-9
    ...    | All these UE attach normally and Bears are established success
    ...    | Step 2          | Start Full buffer DL Data on UE1-6 non-GBR bear Start 5Mbit/s DL data on UE5 on 5QI65
    ...    Start 5Mbit/s DL data on UE6 on 5QI66
    ...    | The non-GBR data transfers did not block the NBR data from being scheduled.
    ...    There shall be no NBR packets discarded the non-GBR cell throughput should decrease by the sum of the NBR data rates.
    ...    | Step 3          | Detach all UE         | UE detach successfully
    [Timeout]    3 hours
    G#B3_003 Prerequisite
#    G#B3_003 Step 1 8UEs attach
#    G#B3_003 Step 2 8UEs transfer data


*** Keywords ***
G#B3_003 Prerequisite
    log to console    G#B3_003 Prerequisite
#    Online delete parmeters    parameters_to_update=${PARAM_14044_delete_gnb1_G_B3_003_01}
#    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_G_B3_003_01}    skip_parameter_relation_errors=False
#    check cell on-air status

G#B3_003 Step 1 8UEs attach
    Log To Console    G#B3_003 Step 1 8UEs attach
    8UEs attach

G#B3_003 Step 2 8UEs transfer data
    Log To Console    G#B3_003 Step 2 8UEs transfer data
    8UEs transfer data
    ${start_time}=    record_time    label=start
    Set Test Variable    ${start_time}
    Sleep    10m    reason=data transfer last more than 10 minutes
    ${record1_time}=    Evaluate    int(datetime.datetime.now().timestamp() * 1000)
    Set Test Variable    ${record1_time}

Common Test Teardown for CB014044_G
    IF    '${TEST STATUS}' == 'PASS'
        ${end_time}=    record_time    label=end
        ${package_version}=    Get bts package version
        sleep    16min
        ${rc}    ${output}=    Run And Return Rc And Output    mv ${excel_kpi_path}*.xlsx ${excel_kpi_path}bak
        ${tl_id}=    Evaluate    str(${gnb_instance})[:3]
        ${report_id}=    generate new report and get report id    file_path=${path}    report_name=${report_name_G_B3_03}
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
#            FOR    ${name}    ${dist}    IN ZIP    ${kpi_name_G_B3_03}    ${kpi_distname}
#                ${record}=    get_related_kpis    kpi_name=${name}    dist_name=${dist}    json_path=${excel_kpi_path}/${excel_file}[0][:-5].json
#                ...    record1=${record1_time}
#                Append To List    ${check_kpi_record}    ${record}
#            END
        END
    END
    8UEs stop transfer data
    8UEs detach
    Common Test Teardown for CB014044 without AP
    Online modify parmeters     parameters_to_update=${PARAM_14044_recover_gnb1_G_B3_003_01}    skip_parameter_relation_errors=False
    check cell on-air status

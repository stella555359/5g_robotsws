*** Settings ***
Documentation
...    author:  ming.shi@nokia-sbell.com
...    contact: ming.shi@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ4_03

Suite Setup    robot_common_operations.Common Suite Setup
#Suite Setup    Common Suite Setup for CB014044
Suite Teardown    Common Suite Teardown for CB014044
Test Setup        Common Test Setup for CB014044
Test Teardown     Common Test Teardown for CB014044
#Test Teardown     Common Test Teardown for CB014044_Ba
Force Tags  CA_5G_RRM    PY36
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB014044/Resources/CB014044_common_keywords.robot

*** Test Cases ***
[1]CB014044_Ba#B1_001_Validation_of_aclTdPfMetricOpt_online_change_for_Non_GBR_Bearers_with_diff_schedulWeight_FDD_DL_SA
    [Documentation]
    ...    1. DESCRIPTION
    ...    This user scenario ensures that the actTdPfMetricOpt flags, functioncorrectly for Non-GBR bearers only.
    ...    The scenario validates that FAF-based metric improvementsinfluence DL scheduling decisions,
    ...    ensuring efficient Non-GBR traffic handling in RAT1.
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
    ...    NRBTS.NRCELL.actTdPfMetricOpt=disabled
    ...    Non-GBR bearers configured with different scheduling weights:
    ...    5QI = 6 → schedulWeight = 40
    ...    5QI = 7 → schedulWeight = 25
    ...    5QI = 8 → schedulWeight = 5
    ...    5QI = 9 → schedulWeight = 1
    ...    Carrier Aggregation (CA) disabled
    ...    PRB Pooling disabled (NRBTS/actSlowPrbPooling = True but no PRB pooling limitations)
    ...    Long PUCCH enabled (NRBTS/NRCELL/pucchModeSelect = long PUCCH)
    ...    DSS features deactivated (NRBTS/NRCELL/lteNrDssMode = 0)
    ...    actDlMuMimoEnh = False
    ...    actUlMuMimo = False
    ...    Slice-Aware Scheduler disabled (NRBTS.actSliceAwareScheduler = False)
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
    ...    TD metric (FAF improvement) is successfully activated and used in DL Non-GBRscheduling decisions.
    ...    UEs with higher TD metric values receive proportionally better scheduling opportunities.
    ...    DL data transmission for Non-GBR bearers remains stable, with improved balancebetween UEs.
    ...    | Step 1 |
    ...    Attach With 8 UEs to the target 5G CELL , and each 2 UE has create one of the non-GBR bear with 5QI6/7/8/9
    ...    Expected: All these UE attach normally and Bears are established success
    ...    | Step 2 |
    ...    Start DL E2E full buffer traffic on these 8 Ues, and record each UE avg TP and Trace log
    ...    Expected:
    ...    Each UE TP is stable and satisfy the default PF scheduling
    ...    | Step 3 |
    ...    Online modify actTdPfMetricOpt from disable to DL
    ...    Expected:
    ...    Each UE TP is still stable and UEs with higher TD metric values receive proportionally better scheduling on DL opportunities
    ...    | Step 4 |
    ...    Detach and reattach this 8UE again to the target 5G CELL, Still with 2 UE  has create one of the non-GBR bear with 5QI6/7/8/9
    ...    Expected:
    ...    All these UE attach normally and Bears are established success
    ...    | Step 5 |
    ...    Start Dl and UL E2E full buffer traffic on these 8 Ues, and record each UE avg TP and Trace log
    ...    Expected:
    ...    Each UE TP is still stable
    ...    UEs with higher TD metric values receive proportionally better scheduling on DL opportunities
    ...    For UL sch still using default PFscheduling without metric-based prioritization for Non-GBR bearers
    Ba#B1_001 Prerequisite
#    Ba#B1_001 Step 1 UEs attach and Bears established
#    Ba#B1_001 Step 2 UEs start traffic and check
#    Ba#B1_001 Step 3 Online modify actTdPfMetricOpt from disable to DL
#    Ba#B1_001 Step 4 Detach and reattach
#    Ba#B1_001 Step 5 Start Dl and UL E2E full buffer traffic and check


*** Keywords ***
Ba#B1_001 Prerequisite
    Log To Console    Ba#B1_001 Prerequisite
#    Online delete parmeters    parameters_to_update=${PARAM_14044_delete_gnb1_Ba_B1_001_01}
#    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_Ba_B1_001_01}    skip_parameter_relation_errors=False
#    check cell on-air status

Ba#B1_001 Step 1 UEs attach and Bears established
    Log To Console    Ba#B1_001 Step 1 UEs attach and Bears established
    cp bts_ini file
    Start capture syslog via btslog on ute
    UEs attach and Bears established on Ba#B1_001
    [Teardown]    Run Keywords
    ...    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Ignore Error    check syslog for err    syslog_file_name=Ba_B1_001_err_01

Ba#B1_001 Step 2 UEs start traffic and check
    Log To Console    Ba#B1_001 Step 2 UEs start traffic and check
    cp bts_ini file
    Start capture syslog via btslog on ute
    UEs make traffic on Ba#B1_001
    Sleep    5m    reason=keep traffic 5 mins
    [Teardown]    Run Keywords
    ...    Stop capture syslog via btslog on ute
    ...    AND    check Ba_B1_001_traffic_01
    ...    AND    Run Keyword And Ignore Error    check syslog for err    syslog_file_name=Ba_B1_001_err_02

Ba#B1_001 Step 3 Online modify actTdPfMetricOpt from disable to DL
    Log To Console    Ba#B1_001 Step 3 Online modify actTdPfMetricOpt from disable to DL
    Online modify parmeters     parameters_to_update=${PARAM_14044_gnb1_Ba_B1_001_02}    skip_parameter_relation_errors=False
    cp bts_ini file
    Start capture syslog via btslog on ute
    Sleep    5m    reason=keep traffic 5 mins
    [Teardown]    Run Keywords
    ...    Stop capture syslog via btslog on ute
    ...    AND    check Ba_B1_001_traffic_02
    ...    AND    Run Keyword And Ignore Error    check syslog for err    syslog_file_name=Ba_B1_001_err_03

Ba#B1_001 Step 4 Detach and reattach
    Log To Console    Ba#B1_001 Step 4 Detach and reattach
    cp bts_ini file
    Start capture syslog via btslog on ute
    UEs stop traffic on Ba#B1_001
    UEs release pdu and detach on Ba#B1_001
    UEs attach and Bears established on Ba#B1_001
    [Teardown]    Run Keywords
    ...    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Ignore Error    check syslog for err    syslog_file_name=Ba_B1_001_err_04

Ba#B1_001 Step 5 Start Dl and UL E2E full buffer traffic and check
    Log To Console    Ba#B1_001 Step 5 Start Dl and UL E2E full buffer traffic and check
    cp bts_ini file
    Start capture syslog via btslog on ute
    UEs make traffic on Ba#B1_001
    Sleep    5m    reason=keep traffic 5 mins
    [Teardown]    Run Keywords
    ...    Stop capture syslog via btslog on ute
    ...    AND    check Ba_B1_001_traffic_03
    ...    AND    Run Keyword And Ignore Error    check syslog for err    syslog_file_name=Ba_B1_001_err_05
    ...    AND    Should Be True    ${avg_traffic_02} >= ${avg_traffic_01}
    ...    AND    Should Be True    ${avg_traffic_03} >= ${avg_traffic_01}


check Ba_B1_001_traffic_01
    ${avg_traffic_01}=    check syslog for traffic    syslog_file_name=Ba_B1_001_traffic_01
    Set Test Variable    ${avg_traffic_01}

check Ba_B1_001_traffic_02
    ${avg_traffic_02}=    check syslog for traffic    syslog_file_name=Ba_B1_001_traffic_02
    Set Test Variable    ${avg_traffic_02}

check Ba_B1_001_traffic_03
    ${avg_traffic_03}=    check syslog for traffic    syslog_file_name=Ba_B1_001_traffic_03
    Set Test Variable    ${avg_traffic_03}

Common Test Teardown for CB014044_Ba
    Run Keyword And Ignore Error    UEs stop traffic on Ba#B1_001
    Run Keyword And Ignore Error    UEs release pdu and detach on Ba#B1_001
    Common Test Teardown for CB014044
    Online modify parmeters     parameters_to_update=${PARAM_14044_recover_gnb1_Ba_B1_001_01}    skip_parameter_relation_errors=False
    check cell on-air status

*** Settings ***
Documentation
...    author:  ming.shi@nokia-sbell.com
...    contact: ming.shi@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ4_03

Suite Setup    Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/4cells_2F2T_8pipes
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     H091_Teardown
Force Tags    tl-CLOUD_5G_I_BOO_AP_LOO    release-25R1
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

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
    No Operation


[1]CB014044_Ba#B2_002_Validation_of_TdPfMetricOpt_Scheduler_Behavior_for_Diverse_Traffic_Profiles_Ping_Highbuffer_Burst_with_diff_schedulWeight_DL_SA
    [Documentation]
    ...    1. DESCRIPTION
    ...    This user scenario validates the gNB's scheduling behavior and prioritization logic under various traffic profiles—ping
    ...    (low latency small packets),high-buffer (continuous large buffer), and burst traffic(sporadic traffic with high spikes).
    ...    The focus is to verify how the scheduler handles mixed traffictypes across Non-GBR bearers and ensures fair
    ...    and efficient resource allocation in DL.
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
    ...    NRBTS.NRCELL.actTdPfMetricOpt=disabled
    ...    Carrier Aggregation (CA) disabled
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
    ...    Scheduling weights applied as:
    ...    5QI = 6 → schedulWeight = 40
    ...    5QI = 7 → schedulWeight = 25
    ...    5QI = 8 → schedulWeight = 5
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
    ...    Scheduler successfully differentiates between traffic profiles and prioritizes accordingly.
    ...    Ping traffic maintains low latency.
    ...    High-buffer UEs maintain consistent throughput.
    ...    Burst UEs experience adaptive PRB allocation depending on active burst.
    ...    with PF metric re-initialization with higher weightage (2.5 times the average), the initialscheduling delay would reduce.
    ...    | Step 1 |
    ...    Attach With 9 UEs to the target NSA CELL , and each 3 UE has create one of the non-GBR bear with 5QI6/7/8
    ...    UE1-3 5QI6
    ...    UE4-6 5QI7
    ...    UE7-9 5QI8
    ...    Expected: All these UE attach normally and Bears are established success
    ...    | Step 2 |
    ...    Start DL High buffer traffic on UE1-3 Start Ping traffic on UE4-6 Start Burst traffic on UE7-9
    ...    Expected: Scheduler successfully differentiates between traffic profiles and prioritizes accordingly.
    ...    | Step 3 |
    ...    Online modify actTdPfMetricOpt from disabled to DL
    ...    Expected: TD metric-based prioritization results in balanced PRB allocation across mixed traffic types.
    ...    Ping UEs retain low latency even under burst load events. Throughput for high-buffer UEs remains stable.
    ...    Burst UEs observe rapid PRB scaling during active phases without starving others.
    ...    | Step 4 |
    ...    Online modify actTdPfMetricOpt from DL to disabled
    ...    Expected: The Scheduler fairness and responsiveness improve will fallback to legarcy again
    No Operation


*** Keywords ***
H091_Teardown
    Delta Commission Parameters    ${RGQuotaRecover}
    Common Test Teardown And Stop Capture Logs
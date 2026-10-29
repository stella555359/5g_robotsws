*** Settings ***
Documentation
...  Description:   Feature CB009235

Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB009235/resources/keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/multi_UE.robot

*** Variables ***
@{MULTI_UE}   UE_1  UE_2  UE_3  UE_4


*** Keywords ***
[1]TC09_CB009235-C-Verify_selected_Enhanced_PM_Counters_DL-MUMIMO
    [Documentation]  TC based on downlink tput and pair check. Following counters are verified after attach and l3call.
    ...              M55308C34013 - Num of PRBs for 2 UE pair tx for MU MIMO in DL | PRB_DL_MU_MIMO_2PAIR_UE
    ...              M55308C34034 - Number of unpaired DL MU-MIMO UEs per TTI due to a low CQI | MU_MIMO_PAIR_DL_FAIL_LOW_CQI
    ...              DL_NUM_UNPAIR_NO_CANDIDATE: TBD

    Deactivate feature
    Activate feature

    Set non pair phaseshifter config
    Perform commissioning CB009235
    Enable TTI Trace
    Detach UEs from cell  ${MULTI_UE}

    Attach UEs to cell  ${MULTI_UE}
    Start DL for UEs   ue_aliases=${MULTI_UE}  duration=5m  protocol=tcp
    Start Tcpdump Collector
    sleep  18s
    Stop tcpdump collector  CB009235
    Stop all datatransfers
    Detach UEs from cell  ${MULTI_UE}
    Log to console  __Wait for non pair counters
    sleep  5m
    Check Unpair Counters Value

    Set pair phaseshifter config
    Attach UEs to cell  ${MULTI_UE}
    Start DL for UEs   ue_aliases=${MULTI_UE}  duration=5m  protocol=tcp
    Start Tcpdump Collector
    sleep  18s
    Stop tcpdump collector  CB009235
    Stop all datatransfers
    Detach UEs from cell  ${MULTI_UE}
    Log to console  __Wait for pair counters
    sleep  5m
    Check Pair Counters Value
    Check EDA 03529075 counters

    Log to console  __Wait for counters value after call
    sleep  5m
    Check counters are zero after call
    Check EDA 03529075 counters after call

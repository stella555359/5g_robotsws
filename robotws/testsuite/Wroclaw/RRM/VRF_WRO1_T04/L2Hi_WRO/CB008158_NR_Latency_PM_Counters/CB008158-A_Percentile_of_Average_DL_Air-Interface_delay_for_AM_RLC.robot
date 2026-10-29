*** Settings ***
Library     ta5g_pm_counters
Library     keywords_CB008158.py
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator.py
Resource    keywords_CB008158.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R1

*** Variables ***
${TRAFFIC_DURATION}=   60s

*** Keywords ***
CB008158-A_3_Counter_For_Measuring_Percentile_Of_Average_Dl_Air-Interface_Delay_For_AM_RLC_SA_UE
    Set Dl Delay Threshold to 10ms
    Register Ue With Default Pdu Session
    Start 150Mbps In Dl And Activate Bler
    Sleep    ${TRAFFIC_DURATION}
    Display Qfi Stats
    Deregister Ue    ue_id=1    pass_regexp=UE1: detached
    Set Dl Delay Threshold to 60ms
    Execute Egate Command    cmd=ue_change_location id=1 cell=2
    Register Ue With Default Pdu Session
    Start 1Mbps In Dl And Deactivate Bler
    Sleep    ${TRAFFIC_DURATION}
    Display Qfi Stats
    Deregister Ue    ue_id=1
    Verify TH PMQAP Counters    cell_id=1
    Verify If TH PMQAP Counters Were Not Incremented    cell_id=2

CB008158-A_4_Counter_For_Measuring_Percentile_Of_Average_Dl_Air-Interface_Delay_For_AM_RLC_NSA_UE
    Set Dl Delay Threshold to 10ms
    Attach Ue With Sgnb
    Start 60Mbps In Dl And Activate Bler
    Sleep    ${TRAFFIC_DURATION}
    Check Traffic On Mcg And Scg Leg    dir=dl
    Detach Ue    ue_id=11
    Set Dl Delay Threshold to 60ms
    Execute Egate Command    cmd=ue_change_location id=11 cell=2
    Attach Ue With Sgnb
    Start 500kbps In Dl And Deactivate Bler
    Sleep    ${TRAFFIC_DURATION}
    Check Traffic On Mcg And Scg Leg    dir=dl
    Detach Ue    ue_id=11
    Verify TH PMQAP Counters    cell_id=1
    Verify If TH PMQAP Counters Were Not Incremented    cell_id=2

Start 150Mbps In Dl And Activate Bler
    Execute Egate Command    cmd=sim_debug_log level=6
    Activate Bler Testmode    ue_id=1    scell=0
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1

Start 1Mbps In Dl And Deactivate Bler
    Deactivate Bler Testmode    ue_id=1    scell=0
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=1

Start 500kbps In Dl And Deactivate Bler
    Deactivate Bler Testmode    ue_id=11    scell=8
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl kbps=500

Verify TH PMQAP Counters
    [Arguments]    ${cell_id}
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_RLC_AM_DLY_AIR_IF_TH_PMQAP}
    ...    value=150000    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_id}    filepath=${PM_COUNTERS}

Verify If TH PMQAP Counters Were Not Incremented
    [Arguments]    ${cell_id}
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Lower Than The Given Value    counter_id=${COUNTER_ID_DL_RLC_AM_DLY_AIR_IF_TH_PMQAP}
    ...    value=5    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_id}   filepath=${PM_COUNTERS}

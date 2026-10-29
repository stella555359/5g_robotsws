*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     keywords_ROHC.py
Documentation
...    author: Pawel Konieczny
...    maintainer: Marcin Kotuła (marcin.koptula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 22R3

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
${UE_ID_TDD}=    1
${UE_ID_FDD}=    20
${CELL_ID_FDD}=   3

*** Keywords ***
5GC000774-A-B1_Successful_Setup_Of_Voice_Over_Nr_Call_With_Rohc_Profile_0x0000_Ipv4_TDD
    Attach One 5g Ue Capable Of Supporting Rohc
    Start Dl And Ul Data Traffic For Tcp Packet Stream
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Check If Statistics For Compressed Pdus Were Incremented
    Check If Statistics For Rohc Profile 0 Were Incremented
    Check If Expected Throughout Is Reached And There Are No Packets Lost
    Verify If Rohc Dl And Ul Header Pm Counters Arent Incremented
    ta5g_ue_mobility.Deregister Ue    ${UE_ID_TDD}

5GC000774-A-B1_Successful_Setup_Of_Voice_Over_Nr_Call_With_Rohc_Profile_0x0000_Ipv4_FDD
    Attach One 5g Ue Capable Of Supporting Rohc    ${UE_ID_FDD}
    Start Dl And Ul Data Traffic For Tcp Packet Stream    ${UE_ID_FDD}
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics    ${UE_ID_FDD}    ${CELL_ID_FDD}
    Check If Statistics For Compressed Pdus Were Incremented    ${CELL_ID_FDD}
    Check If Statistics For Rohc Profile 0 Were Incremented    ${CELL_ID_FDD}
    Check If Expected Throughout Is Reached And There Are No Packets Lost    ${UE_ID_FDD}
    Verify If Rohc Dl And Ul Header Pm Counters Arent Incremented
    ta5g_ue_mobility.Deregister Ue    ${UE_ID_FDD}

Display Ue Statistics
    [Arguments]    ${UE_ID}=${1}    ${CELL_ID}=${1}
    Display Qfi stats    ue_id=${UE_ID}    qfi_id=3
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=${CELL_ID} format=long

Start Dl And Ul Data Traffic For Tcp Packet Stream
    [Arguments]    ${UE_ID}=${1}
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=dl trf_id=1 kbps=30 protocol=tcp
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=ul trf_id=2 kbps=30 protocol=tcp

Check If Statistics For Compressed Pdus Were Incremented
    [Arguments]    ${CELL_ID}=${1}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=0
    ...    enb_id=2    cell_id=${CELL_ID}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=size_of_compressed_pdus    mode=am    value=0
    ...    enb_id=2    cell_id=${CELL_ID}

Check If Statistics For Rohc Profile 0 Were Incremented
    [Arguments]    ${CELL_ID}=${1}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_0_pdus    mode=am    value=0
    ...    enb_id=2    cell_id=${CELL_ID}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_0_bytes    mode=am    value=0
    ...    enb_id=2    cell_id=${CELL_ID}

Check If Expected Throughout Is Reached And There Are No Packets Lost
    [Arguments]    ${UE_ID}=${1}
    Expected Throughput For Qfi Should Be Reached    ue_id=${UE_ID}    pdu_id=1    qfi_id=3
    ...    expected_throughput=30    unit=kbps    margin=1    direction=bi
    Check Number Of Total Packets Lost    ue_id=${UE_ID}    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=bi

Verify If Rohc Dl And Ul Header Pm Counters Arent Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_NUM_ROHC_COMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_VOL_ROHC_COMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_UL_NUM_ROHC_DECOMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_UL_VOL_ROHC_DECOMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

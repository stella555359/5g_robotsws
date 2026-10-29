*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library    ta5g_pm_counters
Library     keywords_ROHC.py

Documentation
...    author: Pawel Konieczny
...    maintainer: Bartlomiej Urbanowicz (bartlomiej.urbanowicz@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 22R3

Suite Setup     Run Keywords    Modify Config Addr To Ipv6
...            AND    Prepare Sa Test Environement And Reach Onair
...               perform_tl_reset=${RESET_TL}
...               cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
...               cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
...               cfg_filepath_tdd_fdd=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
...            AND    Enable Vonr And Rohc TDD FDD
...            AND    Enable Syslog Debug Prints For Rohc

Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

Test Teardown    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
${UE_ID_TDD}=    1
${UE_ID_FDD}=    20
${CELL_ID_FDD}=   3

*** Test Cases ***
5GC000774-A-B1_Successful_Setup_Of_Voice_Over_Nr_Call_With_Rohc_Profile_0x0000_Ipv6_TDD
    Attach One 5g Ue Capable Of Supporting Rohc    session_type=ipv6
    Start Dl And Ul Data Traffic For Tcp Packet Stream With Ipv6
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Check If Statistics For Compressed Pdus Were Incremented
    Check If Statistics For Rohc Profile 0 Were Incremented
    Check If Expected Throughout Is Reached And There Are No Packets Lost
    Verify If Rohc Dl And Ul Header Pm Counters Arent Incremented
    Deregister Ue    ${UE_ID_TDD}

5GC000774-A-B1_Successful_Setup_Of_Voice_Over_Nr_Call_With_Rohc_Profile_0x0000_Ipv6_FDD
    Attach One 5g Ue Capable Of Supporting Rohc    ${UE_ID_FDD}    session_type=ipv6
    Start Dl And Ul Data Traffic For Tcp Packet Stream With Ipv6    ${UE_ID_FDD}
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics    ${UE_ID_FDD}    ${CELL_ID_FDD}
    Check If Statistics For Compressed Pdus Were Incremented    ${CELL_ID_FDD}
    Check If Statistics For Rohc Profile 0 Were Incremented    ${CELL_ID_FDD}
    Check If Expected Throughout Is Reached And There Are No Packets Lost    ${UE_ID_FDD}
    Verify If Rohc Dl And Ul Header Pm Counters Arent Incremented
    Deregister Ue    ${UE_ID_FDD}

*** Keywords ***
Display Ue Statistics
    [Arguments]    ${UE_ID}=${1}    ${CELL_ID}=${1}
    Display Qfi stats    ue_id=${UE_ID}    qfi_id=3
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=${CELL_ID} format=long

Start Dl And Ul Data Traffic For Tcp Packet Stream With Ipv6
    [Arguments]    ${UE_ID}=${1}
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=dl trf_id=1 kbps=30 protocol=tcp ip_version=ipv6
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=ul trf_id=2 kbps=30 protocol=tcp ip_version=ipv6

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

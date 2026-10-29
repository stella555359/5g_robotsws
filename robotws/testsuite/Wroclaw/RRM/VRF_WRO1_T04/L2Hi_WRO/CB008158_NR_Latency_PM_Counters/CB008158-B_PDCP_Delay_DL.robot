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
${TRAFFIC_DURATION_SEC}=   240s

*** Keywords ***
CB008158-B_1_Average_DL_PDCP_SDU_delay_in_CU-UP_with_PMQAP_and_SA_UE
    Register Ue With Default Pdu Session
    Activate Bler Testmode    ue_id=1    scell=0
    Start 450Mbps In Dl For 240s
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Qfi Stats    qfi_id=1
    Deactivate Bler Testmode    ue_id=1    scell=0
    Check If Cell And Pmqap Dl Delay Has Expected Value    cell_id=1    expected_dl_delay=6000    margin=25%
    Start 450Mbps In Dl For 240s
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Qfi Stats    qfi_id=1
    Deregister Ue    ue_id=1
    Check If Cell And Pmqap Dl Delay Has Expected Value    cell_id=1    expected_dl_delay=0.038

CB008158-B_2_Average_GTP_packet_delay_over_F1-U_interface_with_PMQAP_and_SANSA_UE
    Register Ue With Default Pdu Session
    Start 450Mbps In Dl
    Attach Ue With Sgnb
    Start 10Mbps In Dl
    Check Dl GTP Delay Counters
    Deregister Ue    ue_id=1
    Detach Ue    ue_id=11

Start 450Mbps In Dl For 240s
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 seconds=${TRAFFIC_DURATION_SEC}
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2 seconds=${TRAFFIC_DURATION_SEC}
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3 seconds=${TRAFFIC_DURATION_SEC}

Start 10Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Activate Bler Testmode    ue_id=11    scell=8
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=10

Activate Aes Uplane Ciphering
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Ciphering/delta_enable_aes.json

Prepare MCS Bler Testmode In Dl
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 target_mcs=3 num_dl_pkts=1000

Check Dl GTP Delay Counters
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_GTP_PKT_F1_DLY}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_GTP_PKT_F1_DLY_PMQAP}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}

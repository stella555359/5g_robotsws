*** Settings ***
Resource     ../resources/common_keywords.robot
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/pm_counters_validator_vran.py
Library     keywords_CB008158_cloud.py
Resource     keywords_CB008158_cloud.robot

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...    release: 23R2

Suite Setup    Run Keywords    Configure SA VM interfaces AiC
    ...     AND    Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
    ...     AND    Prepare Bler Testmode In Dl
    ...     AND    Disable AiC Uplane Ciphering
    ...     AND    Enable Latency Pm Counters Cloud

Test Setup    Run Keywords    Set Internal Traffic Type To UEs
    ...     AND    Wait For Next PM counters Interval


*** Variables ***
${TRAFFIC_DURATION_SEC}=   200s
${COUNTER_ID_DL_GTP_PKT_F1_DLY}=   M55350C00025
${COUNTER_ID_DL_GTP_PKT_F1_DLY_PMQAP}=   M55159C00003

*** Test Cases ***
CB008158-B_1_Average_DL_PDCP_SDU_delay_in_CU-UP_with_PMQAP_and_SA_UE
    Register Ue With Default Pdu Session
    Acitvate Bler Testmode    ue_id=1    scell=0
    Start 450Mbps In Dl
    Sleep    250
    Display Qfi Stats    qfi_id=1
    Deacitvate Bler Testmode    ue_id=1    scell=0
    Wait For Next PM counters Interval
    Check vCU Cell And Pmqap Dl Delay Has Expected Value    cell_id=1    expected_dl_delay=7000    margin=25%
    Start 450Mbps In Dl
    Sleep    250
    Display Qfi Stats    qfi_id=1
    Deregister Ue    ue_id=1
    Wait For Next PM counters Interval
    Check vCU Cell And Pmqap Dl Delay Has Expected Value    cell_id=1    expected_dl_delay=0.025

CB008158-B_2_Average_GTP_packet_delay_over_F1-U_interface_with_PMQAP_and_SANSA_UE
    Register Ue With Default Pdu Session
    Start 450Mbps In Dl
    Attach Ue And Perform SgNBAdditionRequest
    Start 10Mbps In Dl
    Check Dl GTP Delay Counters
    Deregister Ue    ue_id=1
    Detach Ue    ue_id=11

*** Keywords ***
Prepare Bler Testmode In Dl
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 target_mcs=3 num_dl_pkts=1000

Start 450Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 seconds=${TRAFFIC_DURATION_SEC}
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2 seconds=${TRAFFIC_DURATION_SEC}
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3 seconds=${TRAFFIC_DURATION_SEC}

Start 10Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Acitvate Bler Testmode    ue_id=11    scell=8
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=10

Check Dl GTP Delay Counters
    Wait For Next PM counters Interval
    ${PM_VALUE}=    keywords_CB008158_cloud.get_cu_counter    counter_id=${COUNTER_ID_DL_GTP_PKT_F1_DLY}
    ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    compare_counter_value   value=0    counter_value=${PM_VALUE}
    ...    counter_id=${COUNTER_ID_DL_GTP_PKT_F1_DLY}    comparison_type=exact

    ${PMQAP_VALUE}=    keywords_CB008158_cloud.get_cu_counter    counter_id=${COUNTER_ID_DL_GTP_PKT_F1_DLY_PMQAP}
    ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1
    compare_counter_value   value=0    counter_value=${PMQAP_VALUE}
    ...    counter_id=${COUNTER_ID_DL_GTP_PKT_F1_DLY_PMQAP}    comparison_type=exact

*** Settings ***
Documentation
...   feature keywords

Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod     WITH NAME    Tcpdump

*** Variables ***
@{ART_LOAD_COUNTERS}    M55308C00043    M55308C00044    M55308C00045    M55308C00046

*** Keywords ***
Check Dummy Load Real Ue Tput First
    [Arguments]    ${ue_tput}    ${cell_id}    ${target_load}
    counters.Wait For Pm Counters Interval    offset=10
    Tcpdump.Start Tcpdump On Smod    filename=after_attach.pcap    smod_slave=${FALSE}
    Start DL Traffic For Ue    UE_1    ${ue_tput}Mbits/sec    duration=300s
#    Start UL Traffic For Ue    UE_1    20Mbits/sec    duration=300s
    Start Generate Dummy Load    cell_id=${cell_id}    target_load=${target_load}

    L1L2.Start GnbMirroring    capturing_time_seconds=60    filename=art_load_${target_load}p_ue_${ue_tput}Mb_ue_first.pcap
    BuiltIn.Sleep    10
    ${l1_l2_logs}=    L1L2.stop_gnbmirroring_and_download_logs
    BuiltIn.Sleep    60
    Stop Generate Dummy Load    cell_id=${cell_id}
    Stop Data Transfer    DT_UE_1_default
    Verify DL Tput For Ue    UE_1
    ${pcap_file}=    Tcpdump.Stop Tcpdump and download logs from SMOD

    Collect And Check Counter Values    cell_id=${cell_id}    target_load=${target_load}

    Run keyword and continue on failure    get_number_of_pdsch_for_real_ue    ${l1_l2_logs}
    Run keyword and continue on failure    get_number_of_pdsch_for_al   ${l1_l2_logs}


Check Dummy Load Artificial Load First
    [Arguments]    ${ue_tput}    ${cell_id}    ${target_load}
    counters.Wait For Pm Counters Interval    offset=10
    Start Generate Dummy Load    cell_id=${cell_id}    target_load=${target_load}
    Start DL Traffic For Ue    UE_1    ${ue_tput}Mbits/sec    duration=300s
#    Start UL Traffic For Ue    UE_1    20Mbits/sec    duration=300s
    L1L2.Start GnbMirroring    capturing_time_seconds=60    filename=art_load_${target_load}p_ue_${ue_tput}Mb_al_first.pcap
    BuiltIn.Sleep    10
    ${l1_l2_logs}=    L1L2.stop_gnbmirroring_and_download_logs
    BuiltIn.Sleep    60
    Stop Generate Dummy Load    cell_id=${cell_id}
    Stop Data Transfer    DT_UE_1_default
    Verify DL Tput For Ue    UE_1
#    Stop Data Transfer    DT_UE_1_defaultul
#    Verify UL Tput For Ue    UE_1
    Collect And Check Counter Values    cell_id=${cell_id}    target_load=${target_load}    al_first=${TRUE}

    Run keyword and continue on failure    get_number_of_pdsch_for_real_ue    ${l1_l2_logs}
    Run keyword and continue on failure    get_number_of_pdsch_for_al   ${l1_l2_logs}


Collect 8509 Counters
    counters.Wait For Pm Counters Interval    offset=40
    &{COUNTERS_8509}    get_counters_values_for_cell    ${ART_LOAD_COUNTERS}
    Set Suite Variable    &{COUNTERS_8509}    &{COUNTERS_8509}
    [Return]    &{COUNTERS_8509}


Collect And Check Counter Values
    [Arguments]    ${cell_id}    ${target_load}    ${al_first}=${FALSE}
    Collect 8509 Counters
    ${compare_operator}=    Set Variable If
    ...    ${al_first} == ${TRUE}    >=
    ...    ${target_load} == 100   >
    ...    ${target_load} != 100   >=

    Run keyword and continue on failure
    ...    Assert DL_SLOTS_BELOW_TGT_LOAD Has Correct Value    ${compare_operator}    0    cell_id=${cell_id}
    Run keyword and continue on failure
    ...    Assert DL_SLOTS_ARTIFICIAL_LOAD Has Correct Value    ${compare_operator}    0    cell_id=${cell_id}
    Run keyword and continue on failure
    ...    Assert DL_PRB_ARTIFICIAL_LOAD Has Correct Value    ${compare_operator}    0    cell_id=${cell_id}
    Run keyword and continue on failure
    ...    Assert TRS_SLOTS Has Correct Value    >    1000    cell_id=${cell_id}

Start Dummy Load And RF Diagnostic Test
    [Arguments]    ${cell}    ${target_load}
    Start Generate Dummy Load    cell_id=${cell}    target_load=${target_load}
    ${result_with_load}    Perform RF Diagnostic Test    cells=${cell}    load=${target_load}
    Stop Generate Dummy Load    cell_id=${cell}
    [Return]    ${result_with_load}

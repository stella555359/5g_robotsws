*** Settings ***
Documentation
...   author: Tomasz Mozola
...   responsible tester: Pawel Bicz
...   contact: tomasz.mozola@nokia.com pawel.bicz@nokia.com

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/counters.py                    WITH NAME   link_wro4_pm
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/tracing.py                     WITH NAME   link_wro4_tracing
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords_1167.py     WITH NAME    link_wro4_1167
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/pcap_verifiers.py    WITH NAME    link_wro4_pcap
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/color_log.py                   WITH NAME    line
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/multi_UE.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB013553/resources/keywords.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_messages_verify.py

*** Variables ***
@{PMs_CB013553}   M55118C10001   M55118C10002    M55118C10005    M55118C10006    M55138C00023    M55138C00024    M55147C00024
@{ue_alias}              UE_3
@{UE}                  UE_3
${tput_deviation}       10%
${tput_DL}          780 Mbits/sec
${tput_UL}           58 Mbits/sec
${tput_DL_D}          40000 Mbits/sec
${tput_UL_D}          20000 Mbits/sec

*** Keywords ***
CB013553-A-B7_TDD_FR1_FDD_UL_2TX_switching_peak_throughput_with_PUSCH_mapping_type_A_Real_HW
    [Documentation]
    ...    Subfeature -A pcell TDD_n41_nrcell-81 and scell FDD_n71_nrcell-50, scelladdition via A1 measurements.
    ...    Preconditions - all cells attenuated except pcell-81 with att=0dB equal signal -75dBm on UE, A1 meas performed and scell-50 activated.
    ...    Handover preparation, source pcell-81 degradation to att= 30dB (-100dBm on UE), A2 measuremets perform for pcell. Target cell increase
    ...    from 90dB to 0dB (ue signal -75dBm). Handover performed successfully via A3 measuremets.
    Prepare preconditions for T+F case
    Get UEs    ue_aliases=${UE}    ue_capabilities=REAL_ANDROID_MTK
    link_wro4_pm.sync_to_next_reporting_interval    offset=0     pm_interval=300
    ${pcap_file}=   link_wro4_tracing.Start Listening Tcpdump From Smod   filepath=scell_addition_and_HO.pcap
    attach ues to cell  ${UE}
    Start Max ULDL UDP  ue_alias=${UE}[0]  tput_duration=45s    tput_DL_bandwidth=${tput_DL}    tput_UL_bandwidth=${tput_UL}
    ...    dt_DL_name=DL_1     dt_UL_name=UL_1
    run keyword and ignore error     Stop ULDL    dt_UL_name=UL_1    dt_DL_name=DL_1
    prepare HO
    BuiltIn.Sleep    10
    link_wro4_tracing.Stop Listening Tcpdump From Smod
    line.write line                     \n __checking FDD scell for TDD Pcell and TX switching activation
    Run Keyword And Continue On Failure    link_wro4_pcap.Scells Added    ${pcap_file}    num_of_scells=1    scells_id=50
    Run Keyword And Continue On Failure    verify uplinkTxSwitching for Pcell and Scell     ${pcap_file}
    line.write line                     \n __verify HO to FDD Pcell with TDD Scell and TX switching activation
    Run Keyword And Continue On Failure    pcap_messages_verify.Ue Handovered     ${pcap_file}    target_cell=50
    Run Keyword And Continue On Failure    link_wro4_pcap.Scells Added            ${pcap_file}    num_of_scells=1    scells_id=81
    Run Keyword And Continue On Failure    verify uplinkTxSwitching for Pcell and Scell     ${pcap_file}
    line.write line                     \n __TX switching successfully active for both cells
    run keyword and ignore error           detach ues from cell  ${UE}
    &{counters_values}=     link_wro4_1167.Get Scell Add Counter Values    ${PMs_CB013553}
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.Counter Incremented Successfully    M55118C10001    cell_id=81    counter_dict=counters_values    operator=>     value=0
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.Counter Incremented Successfully    M55118C10002    cell_id=81    counter_dict=counters_values    operator=>     value=0
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.Counter Incremented Successfully    M55118C10005    cell_id=81    counter_dict=counters_values    operator=>     value=0
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.Counter Incremented Successfully    M55118C10006    cell_id=50    counter_dict=counters_values    operator=>     value=0
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.Counter Incremented Successfully    M55138C00023    cell_id=50    counter_dict=counters_values    operator=>     value=0
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.Counter Incremented Successfully    M55138C00024    cell_id=50    counter_dict=counters_values    operator=>     value=0
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.Counter Incremented Successfully    M55147C00024    cell_id=81    counter_dict=counters_values    operator=>     value=0
    [Teardown]    Attenuate all


CB013553-B-B2_FDD_TDD_FR1_UL_2TX_switching_SCell_addition_and_Release_Real_HW
    [Documentation]
    ...    Subfeature -B pcell FDD_n71_nrcell-50 and scell TDD_n41_nrcell-81, scelladdition via A1 measurements.
    ...    Preconditions - all cells attenuated, pcell-50 with att=30dB equal signal -105dBm on UE, A1 meas not performed yet.
    ...    pcell-50 increase from 30dB to 0dB (ue signal -75dBm), and scell-81 activated.
    ...    Scell release based A2 measuremets TDD_n41_nrcell-81. pcell degraded to -30dB and scell-81 increase to 40dB avoid ping-pong
    Prepare preconditions for F+T case
    Get UEs    ue_aliases=${UE}    ue_capabilities=REAL_ANDROID_MTK
    link_wro4_pm.sync_to_next_reporting_interval    offset=0     pm_interval=300
    attach ues to cell  ${UE}
    ${pcap_file}=   link_wro4_tracing.Start Listening Tcpdump From Smod   filepath=scell_addition_TDD_and_A2.pcap
    BuiltIn.Sleep    5
    Prepare attenuation for A1 measurements for TDD scell
    BuiltIn.Sleep    15
    Start Max ULDL UDP  ue_alias=${UE}[0]  tput_duration=60s    tput_DL_bandwidth=${tput_DL}    tput_UL_bandwidth=${tput_UL}
    ...    dt_DL_name=DL_1     dt_UL_name=UL_1
    run keyword and ignore error     Stop ULDL    dt_UL_name=UL_1    dt_DL_name=DL_1
    Prepare attenuation for A2 measurements for TDD scell
    BuiltIn.Sleep    20
    link_wro4_tracing.Stop Listening Tcpdump From Smod
    Run Keyword And Continue On Failure    link_wro4_pcap.Scells Added    ${pcap_file}    num_of_scells=1    scells_id=81
    Run Keyword And Continue On Failure    verify uplinkTxSwitching for FDD Pcell and TDD Scell     ${pcap_file}
    Run Keyword And Continue On Failure    link_wro4_pcap.scell released   ${pcap_file}    1
    run keyword and ignore error     detach ues from cell  ${UE}
    &{counters_values}=     link_wro4_1167.Get Scell Add Counter Values    ${PMs_CB013553}
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.Counter Incremented Successfully    M55118C10001    cell_id=50    counter_dict=counters_values    operator=>     value=0
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.Counter Incremented Successfully    M55118C10002    cell_id=50    counter_dict=counters_values    operator=>     value=0
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.Counter Incremented Successfully    M55118C10005    cell_id=50    counter_dict=counters_values    operator=>     value=0
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.Counter Incremented Successfully    M55118C10006    cell_id=81    counter_dict=counters_values    operator=>     value=0
    [Teardown]    Attenuate all


CB013553-D_IWK8_Stepwise_SCell_Addition_DL+UL_SCell_with_R17_UL_Tx_Switching_Option1
    [Documentation]
    ...    This user scenario demonstrates that the gNB adds a DL+UL SCell with R17 UL Tx switching option 1 during a stepwise
    ...    SCell Addition while previously UE was not configured with UL CA.

    line.write line                     \n _Activate pareameters for stepwise scell addition
    Perform delta precondition for subfeature D
    Verify If All Cells Are Onair
    Get UEs    ue_aliases=${UE}    ue_capabilities=REAL_ANDROID_MTK
    ${measurements_pcap}=   link_wro4_tracing.Start Listening Tcpdump From Smod   filepath=scell_A1_A2_stepwise.pcap
    attach ues to cell  ${UE}
    BuiltIn.Sleep    10
    Start Max ULDL UDP  ue_alias=${UE}[0]  tput_duration=180s    tput_DL_bandwidth=${tput_DL_D}    tput_UL_bandwidth=${tput_UL_D}
    ...    dt_DL_name=DL_1     dt_UL_name=UL_1
    line.write line                     \n _turn on scell allocation
    Perform delta for SCellAllocation
    line.write line                     \n _Perform A2 measurements for current scell
    BuiltIn.Sleep    5
    Adjust attenuation values for multiple ports      atteunator=${tl.attenuators[1]}    att_ports=${cell_81}    values=${step_5_values}
    BuiltIn.Sleep    5
    Adjust attenuation values for multiple ports      atteunator=${tl.attenuators[1]}    att_ports=${cell_81}    values=${step_2_values}
    BuiltIn.Sleep    20
    link_wro4_tracing.Stop Listening Tcpdump From Smod
    run keyword and ignore error     Stop ULDL    dt_UL_name=UL_1    dt_DL_name=DL_1
    Run Keyword And Continue On Failure    link_wro4_pcap.Scells Added    ${measurements_pcap}    num_of_scells=1    scells_id=50
    Run Keyword And Continue On Failure    link_wro4_pcap.Scells Added    ${measurements_pcap}    num_of_scells=2    scells_id=50,40
    Run Keyword And Continue On Failure    verify uplinkTxSwitching for FDD Stepwise Scell     ${measurements_pcap}
    run keyword and ignore error           detach ues from cell  ${UE}
    [Teardown]    Attenuate all

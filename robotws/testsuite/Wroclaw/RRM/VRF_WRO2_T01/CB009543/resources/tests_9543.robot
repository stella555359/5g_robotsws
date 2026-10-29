*** Settings ***
Documentation
...   author: Tomasz Mozola
...   feature responsible tester: Grzegorz Krukar
...   Contact:       tomasz.mozola@nokia.com, grzegorz.krukar@nokia.com

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/counters.py                    WITH NAME    link_wro4_pm
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/tracing.py                     WITH NAME    link_wro4_tracing
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords_1167.py     WITH NAME    link_wro4_1167
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/pcap_verifiers.py    WITH NAME    link_wro4_pcap
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/color_log.py                   WITH NAME    line
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/multi_UE.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB009543/resources/keywords_9543.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_messages_verify.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB007090/resources/keywords.robot

*** Variables ***
${tput_deviation}        10%
${tput_DL}          40000 Mbits/sec
${tput_UL}          20000 Mbits/sec
@{cell_31}       7    8
@{cell_41}       9    10

*** Keywords ***
CB009543_07_C03_FDDsuper_FDDsuper_intra_gNB_HO_via_ANR_triggered_by_grfl_SA
    [Documentation]
    ...    This test case verifies intra-gNB HO between 2 SA FDD supercells.
    ...    Relation is created via ANR and the HO itself is triggered by supercell graceful shutdown.
    ...    next with loops ping-pong HO via ANR with checking PM counters between cell-41 and cell-31.
    ...    __ATT_IF_GNB_INTRA_DU_HO_SLICE   -- M55149C00550
    ...    __SUCC_IF_GNB_INTRA_DU_HO_SLICE  -- M55149C00551
    ...    __SGNB_SA_CU_HO_ADMISSION_REQ    -- M55138C00023
    ...    __SGNB_SA_CU_HO_ADMISSION_SUCC   -- M55138C00024
    ...    __NMOCU_ANR_NRREL_ADD            -- M55147C01001
    ...    __UEs released due RLF initiated -- M55116C00012

    [Arguments]      ${NRcell_31}=31    ${NRcell_41}=41    ${exoected_loops}=6

    line.write line               \n __Step_0 setup original case with shutting down cell-${NRcell_41}
    Set attenuation and check  ${cell_31}  value=35
    Set attenuation and check  ${cell_41}  value=15
    Get UEs    ue_aliases=${UE}    ue_capabilities=UE_QM
    link_wro4_pm.sync_to_next_reporting_interval    offset=0     pm_interval=300
    ${pcap_file}=   link_wro4_tracing.Start Listening Tcpdump From Smod   filepath=Supercell_HO_via_ANR_shutting_down.pcap
    attach ues to cell  ${UE}
    Start Max ULDL UDP  ue_alias=${UE}[0]  tput_duration=50s    tput_DL_bandwidth=${tput_DL}    tput_UL_bandwidth=${tput_UL}
    ...    dt_DL_name=DL_1     dt_UL_name=UL_1
    perform Shutting Down for nrcell
    Check cell is Shutting Down Interval
    BuiltIn.Sleep    60s   reason= cell finished as locked
    link_wro4_tracing.Stop Listening Tcpdump From Smod
    run keyword and ignore error     Stop ULDL    dt_UL_name=UL_1    dt_DL_name=DL_1
    run keyword and ignore error           detach ues from cell  ${UE}
    line.write line               \n __Check PM counters
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.verify_counter_value    counter_id=M55149C00550    expected_value=1    wait_for_interval=True
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.verify_counter_value    counter_id=M55149C00551    expected_value=1
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.verify_counter_value    counter_id=M55116C00012    expected_value=0    cell_id=${NRcell_41}
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.verify_counter_value    counter_id=M55138C00023    expected_value=1    cell_id=${NRcell_31}
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.verify_counter_value    counter_id=M55138C00024    expected_value=1    cell_id=${NRcell_31}
    Run Keyword And Continue On Failure
    ...    link_wro4_1167.verify_counter_value    counter_id=M55147C01001    expected_value=1    cell_id=${NRcell_41}
    line.write line               \n __Delete relation ANR relation if exist for cell-${NRcell_41}
    Run Keyword And Ignore Error   remove_relation_object   cell_id=${NRcell_41}  instance_number=256
    line.write line               \n __administrative state for nrcell-${NRcell_41} should be locked, perform unlocking that cell
    Run Keyword And Continue On Failure    Unlock all locked cells
    line.write line               \n __Additional for test. Expected loops for test: ${exoected_loops}
    Set attenuation and check  ${cell_41}  value=5
    Set attenuation and check  ${cell_31}  value=90
    attach ues to cell  ${UE}
    FOR    ${loop}    IN RANGE    1    ${exoected_loops}
        line.write line               \n __Step_1 setup for cell-${NRcell_41} for loop ${loop}
        Set attenuation and check  ${cell_31}  value=35
        Set attenuation and check  ${cell_41}  value=5
        link_wro4_pm.sync_to_next_reporting_interval    offset=0     pm_interval=300
        ${pcap_f1}=   link_wro4_tracing.Start Listening Tcpdump From Smod   filepath=Supercell_HO_via_ANR_from_cell_${NRcell_41}_loop_${loop}.pcap
        Start Max ULDL UDP  ue_alias=${UE}[0]  tput_duration=50s    tput_DL_bandwidth=${tput_DL}    tput_UL_bandwidth=${tput_UL}
        ...    dt_DL_name=DL_loop_${loop}     dt_UL_name=UL_loop_${loop}
        line.write line               \n __Step2 perform HO from cell-${NRcell_41} to cell-${NRcell_31} for loop_${loop}
        Slow attenuate cell from min to max  ${cell_41}   min_value=5    max_value=40    step=5
        BuiltIn.Sleep    10s
        link_wro4_tracing.Stop Listening Tcpdump From Smod
        line.write line               \n __Step3 perform HO from cell-${NRcell_31} to cell-${NRcell_41} for loop_${loop}
        ${pcap_f2}=   link_wro4_tracing.Start Listening Tcpdump From Smod   filepath=Supercell_HO_via_ANR_from_cell_${NRcell_31}_loop_${loop}.pcap
        Set attenuation and check  ${cell_41}  value=17
        Slow attenuate cell from min to max  ${cell_31}   min_value=35    max_value=55    step=5
        BuiltIn.Sleep    5s
        link_wro4_tracing.Stop Listening Tcpdump From Smod
        run keyword and ignore error     Stop ULDL    dt_UL_name=UL_loop_${loop}    dt_DL_name=DL_loop_${loop}
        line.write line               \n __Check NRBTS PM counters loop_${loop}
        Run Keyword And Continue On Failure
        ...    link_wro4_1167.verify_counter_value    counter_id=M55149C00550    expected_value=2    wait_for_interval=True
        Run Keyword And Continue On Failure
        ...    link_wro4_1167.verify_counter_value    counter_id=M55149C00551    expected_value=2
        line.write line               \n __Check Cell counters for ANR HO from cell-${NRcell_41} to cell-${NRcell_31} loop_${loop}
        Run Keyword And Continue On Failure
        ...    link_wro4_1167.verify_counter_value    counter_id=M55116C00012    expected_value=0    cell_id=${NRcell_41}
        Run Keyword And Continue On Failure
        ...    link_wro4_1167.verify_counter_value    counter_id=M55147C01001    expected_value=1    cell_id=${NRcell_41}
        line.write line               \n __Check Cell counters for ANR HO from cell-${NRcell_31} to cell-${NRcell_41} loop_${loop}
        Run Keyword And Continue On Failure
        ...    link_wro4_1167.verify_counter_value    counter_id=M55116C00012    expected_value=0    cell_id=${NRcell_31}
        Run Keyword And Continue On Failure
        ...    link_wro4_1167.verify_counter_value    counter_id=M55147C01001    expected_value=1    cell_id=${NRcell_31}
        line.write line               \n __Delete ANR relations if exist for both cells
        Run Keyword And Ignore Error   remove_relation_object   cell_id=${NRcell_31}  instance_number=256
        Run Keyword And Ignore Error   remove_relation_object   cell_id=${NRcell_41}  instance_number=256
    END
    [Teardown]    run keyword and ignore error           detach ues from cell  ${UE}

*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com


Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009103/resources/keywords_9103.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009103/resources/specific_keywords_9103.py    WITH NAME    interdlca
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009103/resources/interdlca_pm_counters.py


*** Variables ***
${ue}                    UE_5
${pcell}                 211  # FDD
${scell}                 201  # FDD
${scell_2}               221  # FDD
${ext_scell_1}           50   # TDD
${ext_scell_2}           60   # FDD

${tput_duration}         500  # in seconds
${tput_deviation}        10
&{cell_vs_radio}         211=AHFIG_1  201=AHFIG_1  50=AZHL  60=AHFII  101=AHLOA_1

${pcell_rsrp}            -73
${scell_rsrp}            -80
${ext_scell_1_rsrp}      -75
${ext_scell_2_rsrp}      -72

${unused_scells_for_4cc}         221,222,301,311
${unused_scells_for_5cc}         222,301,311

${inactive_timer}        30s
@{pm_key}                MCC


*** Keywords ***
CB009103_Mixed_A1_and_A4_Based_SCell_addition_across_2_gNBs
    [Documentation]   This test case checks DL 4CC across two gNBs and verify counters related to pcell and scells.
    ...               Two local cells added via A1 meas, first ext-scell via A1 meas too and second one via A4 meas
    ...            TEST STEPS
    ...             0. Remove not used relation from NRREL, set up attenuation, attach UE to all used cells and write rsrp for each cell
    ...             1. Attach UE to PCell and two SCells, one intra and one external, start DL tput and verify scells addition
    ...             2. Clear atteuation on second ext-SCell, wait for A4 measurment and scell addition verifying in pcap file
    ...             3. Attenuate PCell below A1 threshold then attenuate first ext-SCell below A2 to release it and check msg in pcap file
    ...             4. Attenuate second ext-SCell below A2 threshold to release it and check msg in pcap file
    ...             5. Clear attenuation on ext-SCells, one ext-SCell added via A4 then
    ...                clear attenuation on PCell -> second ext-SCells added via A1 -> verify msg in pcap file
    ...             6. Collect PM counters from both sites and verify them
    # PRECONDITIONS
    Show Text on Console   Setup BTS for CB009103 testing
    remove_scell_addition_method   from_cell=${pcell}   to_cells=${unused_scells_for_4cc}
    add_scell_addition_method   from_cell=${pcell}   to_cell=${ext_scell_1}   add_method=covBasedA1
    add_scell_addition_method   from_cell=${pcell}   to_cell=${ext_scell_2}   add_method=covBasedA4
    ${nr_cells}   interdlca.prepare_startup_values
    Get BTSs settings
    set_preferred_cell   cell_id=${pcell}

    Set Test Variable   ${ue}   UE_5
    Require Ue   ${ue}  capabilities=${ue}

    Show Text on Console   Clear attenuation for ext-SCell PCI:${ext_scell_1}, second one PCI:${ext_scell_2} below A4 threshold
    Set Attenuation  0dB  ${ATTENUATOR['${cell_vs_radio}[${ext_scell_1}]']['ports']}  confirm=${TRUE}
    ...     attenuator_id=${ATTENUATOR['${cell_vs_radio}[${ext_scell_1}]']['att_id']}
    Attenuate Given Cell   cell_id=${ext_scell_2}  cell_rsrp=${ext_scell_2_rsrp}  threshold=${pcell_a4SCellAddRsrp}

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch

    # STEP 1
    Show Text on Console   Attach UE to PCell and two SCells intra and external via A1 measurements
    Set Test Variable   ${log_index}  _attach_pcell_2_scells
    logs.Start Tracing On SMOD   smod slave=False
    Attach Ue    ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    ${timer_1}   Get Time  epoch
    Start Data Transfer In Given Direction   ${ue}  direction=DL  duration=${tput_duration}s  offset=5s

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD
    scells_added   pcap_file=${logs_path}  num_of_scells=2  scells_id=${scell},${ext_scell_1}
    Log To Console   \n SCell PCI:${scell} and ext-SCell PCI:${ext_scell_1} added successfuly
    interdlca.increase_counters
    ...    A1_SCELL_ADDED_SA
    ...    multiplier=2
    ...    cell=${pcell}
    BuiltIn.Sleep   60s     run 3CC tput

    # STEP 2
    Show Text on Console   Clear attenuation to add second ext-SCell via A4 measurements
    Set Test Variable   ${log_index}  _add_third_scell
    logs.Start Tracing On SMOD   smod slave=False
    Set Attenuation  0dB  ${ATTENUATOR['${cell_vs_radio}[${ext_scell_2}]']['ports']}  confirm=${TRUE}
    ...     attenuator_id=${ATTENUATOR['${cell_vs_radio}[${ext_scell_2}]']['att_id']}

    Wait Until Keyword Succeeds   2min  3s   Check current scells added   num_of_scells=3  scells=${scell},${ext_scell_1},${ext_scell_2}
    Log To Console   \n ext-SCell PCI:${ext_scell_2} added successfuly
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD

    interdlca.increase_counters
    ...    A4_SCELL_ADDED_SA
    ...    cell=${pcell}
    ${timer_2}   Get Time  epoch
    BuiltIn.Sleep   60s     run 4CC tput

    # STEP 3
    Show Text on Console
    ...   Attenuate PCell below a1ThresholdSCellAddSsbRsrp (avoid A1/A2 ping-pong) then attenuate FDD ext-SCell below a2ThresholdSCellRelSsbRsrp
    Set Test Variable   ${log_index}  _rel_fdd_extscell
    logs.Start Tracing On SMOD   smod slave=False
    Attenuate Given Cell   cell_id=${pcell}  cell_rsrp=${pcell_rsrp}  threshold=${pcell_a1SCellAddRsrp}
    Attenuate Given Cell   cell_id=${ext_scell_2}  cell_rsrp=${ext_scell_2_rsrp}  threshold=${ext_scell_2_a2SCellRelRsrp}  att_offset=10

    Wait Until Keyword Succeeds   30s  2s   Check current scells added   num_of_scells=2  scells=${scell},${ext_scell_1}
    ${timer_3}   Get Time  epoch
    Log To Console   \n ext-SCell PCI:${ext_scell_2} released successfuly via A2 measurment
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD
    BuiltIn.Sleep   60s     run 3CC tput

    interdlca.increase_counters
    ...    A2MEAS_REL1DLSCELL_ATT_SA
    ...    A2MEAS_REL1DLSCELL_SUCC_SA
    ...    cell=${pcell}

    # STEP 4
    Show Text on Console   Attenuate TDD ext-SCell below a2ThresholdSCellRelSsbRsrp
    Set Test Variable   ${log_index}  _rel_tdd_extscell
    logs.Start Tracing On SMOD   smod slave=False
    Attenuate Given Cell   cell_id=${ext_scell_1}  cell_rsrp=${ext_scell_1_rsrp}  threshold=${ext_scell_1_a2SCellRelRsrp}

    Wait Until Keyword Succeeds   30s  2s   Check current scells added   num_of_scells=1  scells=${scell}
    ${timer_4}   Get Time  epoch
    Log To Console   \n ext-SCell PCI:${ext_scell_1} released successfuly via A2 measurment
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD
    BuiltIn.Sleep   120s     run 2CC tput

    interdlca.increase_counters
    ...    A2MEAS_REL1DLSCELL_ATT_SA
    ...    A2MEAS_REL1DLSCELL_SUCC_SA
    ...    cell=${pcell}

    # STEP 5
    Show Text on Console   Clear attenuation on ext-SCells and verify only one SCell via A4 added - PCell below a1ThresholdSCellAddSsbRsrp
    Set Test Variable   ${log_index}  _no_extscells_added
    logs.Start Tracing On SMOD   smod slave=False
    Set Attenuation  0dB  ${ATTENUATOR['AZHL']['ports']}  confirm=${TRUE}
    ...                   attenuator_id=${ATTENUATOR['AZHL']['att_id']}
    Set Attenuation  0dB  ${ATTENUATOR['AHFII']['ports']}  confirm=${TRUE}
    ...                   attenuator_id=${ATTENUATOR['AHFII']['att_id']}
    Wait Until Keyword Succeeds   2min  3s   Check current scells added   num_of_scells=2  scells=${scell},${ext_scell_2}
    ${timer_5}   Get Time  epoch
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD
    Log To Console   \n ext-SCells PCI:${ext_scell_2} added successfuly

    interdlca.increase_counters
    ...    A4_SCELL_ADDED_SA
    ...    cell=${pcell}

    Show Text on Console   Clear attenuation on PCell and verify second SCell via A1 added
    Set Test Variable   ${log_index}  _extscells_added
    logs.Start Tracing On SMOD   smod slave=False
    Set Attenuation  0dB  ${ATTENUATOR['AHFIG_1']['ports']}  confirm=${TRUE}
    ...                   attenuator_id=${ATTENUATOR['AHFIG_1']['att_id']}
    Wait Until Keyword Succeeds   60s  3s   Check current scells added   num_of_scells=3  scells=${scell},${ext_scell_1},${ext_scell_2}
    ${timer_6}   Get Time  epoch
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD
    Log To Console   \n ext-SCells PCI:${ext_scell_1} and PCI:${ext_scell_2} added successfuly

    interdlca.increase_counters
    ...    A1_SCELL_ADDED_SA
    ...    cell=${pcell}

    ${naa_avg_tput}   Wait Downlink CA Traffic Finish
    ${timer_end}   Get Time  epoch
    Detach Ue   ${ue}

    interdlca.increase_counters
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${pcell}

    ${ue_time_with_scells_across_two_gnbs}   Evaluate  (${timer_4} - ${timer_1}) + (${timer_end} - ${timer_5})
    ${counter}   Set Variable If   '${rel_name}' == 'SBTS26R1' or '${rel_name}' == 'SBTS26R2'
    ...              UE_SCELL_ACROSS_2_GNB_SA  UE_SCELL_ACROSS_MULT_GNB_SA
    interdlca.increase_counters
    ...    ${counter}
    ...    multiplier=${ue_time_with_scells_across_two_gnbs}
    ...    cell=${pcell}

    ${ue_time_with_1_scell}   Evaluate  ${timer_5} - ${timer_4}
    interdlca.increase_counters
    ...    UE_PCELL_1_CONF_SCELL_DL_SA
    ...    multiplier=${ue_time_with_1_scell}
    ...    cell=${pcell}

    ${ue_time_with_2_scells}   Evaluate  (${timer_2} - ${timer_1}) + (${timer_4} - ${timer_3}) + (${timer_6} - ${timer_5})
    interdlca.increase_counters
    ...    UE_PCELL_2_CONF_SCELL_DL_SA
    ...    multiplier=${ue_time_with_2_scells}
    ...    cell=${pcell}

    ${ue_time_with_3_scells}   Evaluate  (${timer_3} - ${timer_2}) + (${timer_end} - ${timer_6})
    interdlca.increase_counters
    ...    UE_PCELL_3_CONF_SCELL_DL_SA
    ...    multiplier=${ue_time_with_3_scells}
    ...    cell=${pcell}

    # STEP 6
    wro4_pm.sync_to_next_reporting_interval   offset=1
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch

    ${counter_values}   Collect Counters from Both BTSs    ${pm_start_time}  ${pm_stop_time}  INTERDLCA_PM_COUNTERS
    Verify Traffic from PM Counters vs NAA value   ${counter_values}  ${naa_avg_tput}
    Verification PM Counters   ${counter_values}  INTERDLCA_PM_COUNTERS  ${nr_cells}

    [Teardown]   Run Keywords
    ...         Stop data transfers for all ues
    ...   AND   Detach Ue   ${ue}
    ...   AND   logs.Stop Tracing On SMOD
    ...   AND   unset_preferred_cell
    ...   AND   remove_scell_addition_method   from_cell=${pcell}   to_cells=${ext_scell_1},${ext_scell_2}
    ...   AND   add_scell_addition_method   from_cell=${pcell}   to_cell=${unused_scells_for_4cc}   add_method=covBasedA1
    ...   AND   Set Attenuation  90dB  ${ATTENUATOR['AZHL']['ports']}  confirm=${TRUE}
    ...                   attenuator_id=${ATTENUATOR['AZHL']['att_id']}
    ...   AND   Set Attenuation  90dB  ${ATTENUATOR['AHFII']['ports']}  confirm=${TRUE}
    ...                   attenuator_id=${ATTENUATOR['AHFII']['att_id']}
    ...   AND   Set Attenuation  0dB  ${ATTENUATOR['AHFIG_1']['ports']}  confirm=${TRUE}
    ...                   attenuator_id=${ATTENUATOR['AHFIG_1']['att_id']}


CB009103_Successful_transition_from_RRC_CONNECTED_to_RRC_INACTIVE_state
    [Documentation]   This test case checks DL 5CC across two gNBs, check interaction with CB008225 feature and verify counters.
    ...            TEST STEPS
    ...             0. Remove not used relation from NRREL, set up attenuation
    ...             1. Attach UE to PCell and 4 SCells, two internal and two external
    ...             2. in LOOP start DL tput and verify scells addition, stop tput and wait UE moves to Inactive state -> verify msg in pcap file
    ...             3. Collect PM counters from both sites and verify them
    # PRECONDITIONS
    Show Text on Console   Setup BTS for CB009103 testing
    remove_scell_addition_method   from_cell=${pcell}   to_cells=${unused_scells_for_5cc}
    add_scell_addition_method   from_cell=${pcell}   to_cell=${ext_scell_1}   add_method=covBasedA1
    add_scell_addition_method   from_cell=${pcell}   to_cell=${ext_scell_2}   add_method=covBasedA4
    ${nr_cells}   interdlca.prepare_startup_values_for_inactive
    Get BTSs settings
    set_preferred_cell   cell_id=${pcell}

    Set Test Variable   ${ue}   UE_5
    Require Ue   ${ue}  capabilities=${ue}

    Show Text on Console   Clear attenuation for ext-SCells PCI:${ext_scell_1} and PCI:${ext_scell_2}
    Set Attenuation  0dB  ${ATTENUATOR['AZHL']['ports']}  confirm=${TRUE}
    ...    attenuator_id=${ATTENUATOR['AZHL']['att_id']}
    Set Attenuation  0dB  ${ATTENUATOR['AHFII']['ports']}  confirm=${TRUE}
    ...    attenuator_id=${ATTENUATOR['AHFII']['att_id']}

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch

    # STEP 1
    Show Text on Console   Attach UE to PCell and 4 SCells intra and external
    Set Test Variable   ${log_index}  _attach_pcell_4_scells
    logs.Start Tracing On SMOD   smod slave=False
    Attach Ue    ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    # STEP 2
    FOR  ${iteration}  IN RANGE  ${3}
        Show Text on Console   ${iteration+1}. iteration running     colour=${REDBG}  show_timestamp=no
        Start Data Transfer In Given Direction   ${ue}  direction=DL  duration=240s  offset=5s

        IF  ${iteration} != 0
        interdlca.increase_inactive_counters
        ...    NRPAG_RAN_PAGING_SUCC_SENT
        ...    NRRCC_RRC_RESUME_REQUEST1
        ...    NRRCC_RRC_RESUME_SUCC
        ...    cell=${pcell}
        END

        Wait Until Keyword Succeeds   2min  15s
        ...    Check current scells added   num_of_scells=4  scells=${scell},${scell_2},${ext_scell_1},${ext_scell_2}
        Log To Console   \n SCells PCI:${scell}, ${scell_2}, ${ext_scell_1}, ${ext_scell_2} added successfuly
        ${logs_path}   logs.Stop Tracing And Download Logs From SMOD

        interdlca.increase_inactive_counters
        ...    A1_SCELL_ADDED_SA
        ...    multiplier=3
        ...    cell=${pcell}
        interdlca.increase_inactive_counters
        ...    A4_SCELL_ADDED_SA
        ...    cell=${pcell}

        ${tput_check_}   Check Average Traffic from given time period
        Set Test Variable   ${tput_check_${iteration}}   ${tput_check_}
        Stop Data Transfer   dt_name=DT_DL_${ue}
        Show Text on Console   Traffic finished, wait ${inactive_timer} UE moves to INACTIVE state
        Set Test Variable   ${log_index}  _inactive_state_${iteration}
        logs.Start Tracing On SMOD   smod slave=False

        BuiltIn.Sleep   ${inactive_timer}
        ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   offset=10s
        is_ue_in_inactive_state   ${logs_path}

        interdlca.increase_inactive_counters
        ...    NRRCC_RRC_RELEASE_SENT
        ...    NRRCC_RRC_REL_WITH_SUSP_NRNAU
        ...    cell=${pcell}
        interdlca.increase_inactive_counters
        ...    NG_FLOW_SUSP_RRC_CONN_INACTIVE
        ...    multiplier=2   # for each pdu session, data and vonr
        ...    cell=${pcell}

        Set Test Variable   ${log_index}  _conn_state_${iteration}
        logs.Start Tracing On SMOD   smod slave=False
    END
    Detach Ue   ${ue}

    interdlca.increase_inactive_counters
    ...    NRRCC_RRC_RESUME_REQUEST1
    ...    NRRCC_RRC_RESUME_SUCC
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${pcell}

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD

    # STEP 3
    wro4_pm.sync_to_next_reporting_interval   offset=1
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch

    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  INTERDLCA_INACTIVE_PM_COUNTERS
    Verification PM Counters   ${counter_values}  INTERDLCA_INACTIVE_PM_COUNTERS  ${nr_cells}

    [Teardown]   Run Keywords
    ...         Stop data transfers for all ues
    ...   AND   Detach Ue   ${ue}
    ...   AND   logs.Stop Tracing On SMOD
    ...   AND   unset_preferred_cell
    ...   AND   remove_scell_addition_method   from_cell=${pcell}   to_cells=${ext_scell_1},${ext_scell_2}
    ...   AND   add_scell_addition_method   from_cell=${pcell}   to_cell=${unused_scells_for_5cc}   add_method=covBasedA1
    ...   AND   Set Attenuation  90dB  ${ATTENUATOR['AZHL']['ports']}  confirm=${TRUE}
    ...                   attenuator_id=${ATTENUATOR['AZHL']['att_id']}
    ...   AND   Set Attenuation  90dB  ${ATTENUATOR['AHFII']['ports']}  confirm=${TRUE}
    ...                   attenuator_id=${ATTENUATOR['AHFII']['att_id']}


CB009103_Succesful_A2_based_PCell_switch_to_intra_SCell_when_also_ext_cells_are_present
    [Documentation]   This test case checks PCell switch via A2 measurment and verify counters.
    ...            TEST STEPS
    ...             0. Remove not used relation from NRREL, set up attenuation
    ...             1. Attach UE to PCell and 3 SCells, two internal and one external (UE capabilities) and run DL tput
    ...             2. Attenuate PCell below a2ThresholdPCellSwitchSsbRsrp and verify HO
    ...             3. Collect PM counters and verify them
    # PRECONDITIONS
    Show Text on Console   Setup BTS for CB009103 testing
    Set Test Variable   ${pcell}   101
    Set Test Variable   ${next_pcell}   211
    ${a2PCellSwitchRsrp}   Get A2 PCell Switch Threshold
    remove_scell_addition_method   from_cell=${next_pcell}   to_cells=${unused_scells_for_4cc}
    add_scell_addition_method   from_cell=${next_pcell}   to_cell=${pcell},${ext_scell_1},${ext_scell_2}   add_method=covBasedA1
    ${nr_cells}   interdlca.prepare_startup_values_for_pcell_switch
    set_preferred_cell   cell_id=${pcell}

    Set Test Variable   ${ue}   UE_5
    Require Ue   ${ue}  capabilities=${ue}

    Show Text on Console   Clear attenuation for ext-SCells PCI:${ext_scell_1} and PCI:${ext_scell_2}
    Set Attenuation  0dB  ${ATTENUATOR['AZHL']['ports']}  confirm=${TRUE}
    ...    attenuator_id=${ATTENUATOR['AZHL']['att_id']}
    Set Attenuation  0dB  ${ATTENUATOR['AHFII']['ports']}  confirm=${TRUE}
    ...    attenuator_id=${ATTENUATOR['AHFII']['att_id']}

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch

    # STEP 1
    Show Text on Console   Attach UE to PCell and 3 SCells intra and external
    Set Test Variable   ${log_index}  _attach
    logs.Start Tracing On SMOD   smod slave=False
    Attach Ue    ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}
    ${CELL_INFO}   Get UE Info   ${ue}  CELL_INFO
    ${pcell_rsrp}   Set Variable   ${CELL_INFO}[dbm]

    Start Data Transfer In Given Direction   ${ue}  direction=DL  duration=${tput_duration}s  offset=5s
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD
    scells_added   pcap_file=${logs_path}  num_of_scells=3  scells_id=${scell},${next_pcell},${ext_scell_1}
    Log To Console   \n SCells PCI:${scell}, ${next_pcell} and ext-SCell PCI:${ext_scell_1} added successfuly

    interdlca.increase_pcellswitch_counters
    ...    A1_SCELL_ADDED_SA
    ...    multiplier=3
    ...    cell_or_mcc=${pcell}

    BuiltIn.Sleep   30s   wait few seconds before pcell switch

    # STEP 2
    Show Text on Console   Attenuate PCell below a2ThresholdPCellSwitchSsbRsrp
    Set Test Variable   ${log_index}  _pcell_switch
    logs.Start Tracing On SMOD   smod slave=False
    Attenuate Given Cell   cell_id=${pcell}  cell_rsrp=${pcell_rsrp}  threshold=${a2PCellSwitchRsrp}
    Wait Until Keyword Succeeds   1min  10s   Verify Attach to Given Cell   target_cell=${next_pcell}
    Check current scells added   num_of_scells=4  scells=${pcell},${scell},${ext_scell_1},${ext_scell_2}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD
    Log To Console   \n SCells PCI:${pcell}, ${scell}, and ext-SCells PCI:${ext_scell_1}, ${ext_scell_2} added successfuly

    interdlca.increase_pcellswitch_counters
    ...    A1_SCELL_ADDED_SA
    ...    multiplier=4
    ...    cell_or_mcc=${next_pcell}
    interdlca.increase_pcellswitch_counters
    ...    NRRCC_MEAS_A2_REC
    ...    cell_or_mcc=${pcell}
    interdlca.increase_pcellswitch_counters
    ...    ATT_A2_IF_INTRA_DU_HO_SLICE
    ...    SUCC_A2_IF_INTRA_DU_HO_SLICE
    ...    cell_or_mcc=310

    BuiltIn.Sleep   30s   wait few seconds before detach
    Stop data transfers for all ues
    Detach Ue   ${ue}

    # STEP 3
    wro4_pm.sync_to_next_reporting_interval   offset=1
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch

    ${counter_values}   Collect Counters from Given Time
    ...                     ${pm_start_time}  ${pm_stop_time}  INTERDLCA_PCELL_SWITCH_PM_COUNTERS   additional_dict_keys=${pm_key}
    Verification PM Counters   ${counter_values}  INTERDLCA_PCELL_SWITCH_PM_COUNTERS  ${nr_cells}
    Verification Additional PM Counters   ${counter_values}  INTERDLCA_PCELL_SWITCH_PM_COUNTERS

    [Teardown]   Run Keywords
    ...         Stop data transfers for all ues
    ...   AND   Detach Ue   ${ue}
    ...   AND   logs.Stop Tracing On SMOD
    ...   AND   unset_preferred_cell
    ...   AND   remove_scell_addition_method   from_cell=211   to_cells=${pcell},${ext_scell_1},${ext_scell_2}
    ...   AND   add_scell_addition_method   from_cell=211   to_cell=${unused_scells_for_4cc}   add_method=covBasedA1
    ...   AND   Set Attenuation  90dB  ${ATTENUATOR['AZHL']['ports']}  confirm=${TRUE}
    ...                   attenuator_id=${ATTENUATOR['AZHL']['att_id']}
    ...   AND   Set Attenuation  90dB  ${ATTENUATOR['AHFII']['ports']}  confirm=${TRUE}
    ...                   attenuator_id=${ATTENUATOR['AHFII']['att_id']}
    ...   AND   Set Attenuation  0dB  ${ATTENUATOR['AHLOA_1']['ports']}  confirm=${TRUE}
    ...                   attenuator_id=${ATTENUATOR['AHLOA_1']['att_id']}

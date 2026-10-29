*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for  CB005934_B_004_SCell_swap_4FDD_limit_on_SCell_swap_targets


Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB005934/resources/keywords.robot


*** Keywords ***
CB005934_B_004_SCell_swap_4FDD_limit_on_SCell_swap_targets
    Set Test Variable   ${pcell}   211
    Set Test Variable   ${scell_1}   101
    Set Test Variable   ${scell_2}   201
    Set Test Variable   ${scell_3}   221
    Set Test Variable   ${scell_3_new}   222
    Set Test Variable   ${ue}   UE_5
    set_preferred_cell   cell_id=${pcell}
    remove_scell_addition_method   from_cell=${pcell}   to_cells=301,311
    add_scell_addition_method   from_cell=${pcell}   to_cell=101   add_method=covBasedA1
    Require Ue    ${ue}     ${ue}

    counters.Wait For Pm Counters Interval    offset=0

    logs.Start Tracing On SMOD   filename=attach  smod slave=False
    Attach UE   ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    Start Data Transfer In Given Direction   ${ue}  direction=DL  duration=600s
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   filename=attach  offset=0s
    scells_added   pcap_file=${logs_path}  num_of_scells=3  scells_id=${scell_1},${scell_2},${scell_3}

    Perform SCell Swap   from_scell=${scell_3}   to_scell=${scell_3_new}

    Verify test counters
    [Teardown]    Run Keywords
    ...         Stop data transfers for all ues
    ...   AND   Detach Ue   UE_5
    ...   AND   logs.Stop Tracing On SMOD
    ...   AND   Set Attenuation  0dB  ${ATTENUATOR['AHFIG_1']['ports']}  confirm=${TRUE}
    ...             attenuator_id=${ATTENUATOR['AHFIG_1']['att_id']}
    ...   AND   Set Attenuation  90dB  ${ATTENUATOR['AHFIG_2']['ports']}  confirm=${TRUE}
    ...             attenuator_id=${ATTENUATOR['AHFIG_1']['att_id']}
    ...   AND   remove_scell_addition_method   from_cell=${pcell}   to_cells=101
    ...   AND   add_scell_addition_method   from_cell=${pcell}   to_cell=301,311   add_method=covBasedA1
    ...   AND   unset_preferred_cell

*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com

Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC000630/resources/keywords_630.robot


*** Keywords ***
FGCR-3464_Distribution_of_estimated_throughput_over_F1-U
    [Documentation]   The purpose of the TC is to check distribution of estimated throughput
    ...               over F1-U counters in different radio condition
    Show Text on Console   Attach UE
    Set Test Variable   ${pcell}  100
    Set Test Variable   ${ue}   SAMSUNG_5
    set_preferred_cell   cell_id=${pcell}
    Require Ue          ${ue}     capabilities=${ue}
    Attach Ue   ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${pcell}  ${pci}   ${ue} not attached to primary cell: ${pcell}

    Show Text on Console   5G Average estimated throughput over F1-U counters checking for given values (Mbit/s): ${tputs_in_mbits}
    ...                     colour=${BLUEBG}  show_timestamp=no
    wro4_pm.sync_to_next_reporting_interval

    FOR  ${value}  IN   @{tputs_in_mbits}
        Show Text on Console   EXECUTION FOR TPUT: ${value} Mbit/s   colour=${REDBG}  show_timestamp=no
        Start Data Transfer In Given Direction   ${ue}  direction=DL  protocol=UDP  dl_tput_in_mbits=${value}  duration=200s  wait_for_finish={True}
        ${avg_tput}   Check Average Tput From Last PM Interval   ue=${ue}

        Show Text on Console   [Wait for counters verifying for agverage tput: ${avg_tput} Mbit/s   colour=${GREEN}
        wro4_pm.sync_to_next_reporting_interval
        ${counter_values}   wro4_pm.get_sum_of_n_last_pm_counters_values   ${DIST_EST_TPUT_COUNTERS}
        Run Keyword And Continue On Failure   validate_counter_values   ${counter_values}  ${avg_tput}
    END

    [Teardown]    Run Keywords
    ...        Stop Data Transfer   DT_DL_${ue}
    ...   AND   Detach UE   ${ue}
    ...   AND   unset_preferred_cell

*** Settings ***
Documentation  Specific keywords for automated test cases from CB008009 feature.

Library  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/counter_helpers.py
Library  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/webem_operations.py

*** Variables ***
${NR_BTS_ID}     ${tl.gnbs[0].instance_id}
${test_cell}  31
${counters_interval}  5m

# Counters to get
${ul_volume_rlc}  M55349C03001
${ul_time_rlc}    M55349C04001
${ul_rls_qos9}    M55349C00009
${ul_rlc_1cc_sa}  M55349C00042
${ul_time_pmqap}  M55353C01001

*** Keywords ***
Prepare Test Line for CB008009
    [Documentation]  Locking LTE RAT is performed to be sure we will have SA call in the cell.

    log to console  Perform CB008009 commissioning...

    lock_all_cells_except  ${test_cell}
    perform_rat_block  LTE

    create delta
    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}
    ...  thpTimeCalc
    ...  disabled

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRPMRNL-1
    ...  miNrHighRlcCell
    ...  5min

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}

Activate CB008009 feature
    [Documentation]  Activating CB008009 feature by enabling thpTimeCalc.

    log to console  Activating CB008009 feature...
    create delta

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}
    ...  thpTimeCalc
    ...  enabled

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}

Wait for CB008009 counters
    log to console  Wait for ${counters_interval} counters.
    sleep  ${counters_interval}

Get M55349C04001 counter
    [Arguments]  ${target_cell}=${test_cell}
    log to console  Getting ${ul_time_rlc}
    ${res}  get counter values  ${ul_time_rlc}
    ${last}  get_last_counters_values
    ...  ${res['BTS']['MRBTS-${NR_BTS_ID}']['NRBTS-${NR_BTS_ID}']['NRCELL-${target_cell}']['NHRRC']}

    [Return]  ${last}

Get M55349C03001 counter
    [Arguments]  ${target_cell}=${test_cell}
    log to console  Getting ${ul_volume_rlc}
    ${res}  get counter values  ${ul_volume_rlc}
    ${last}  get_last_counters_values
    ...  ${res['BTS']['MRBTS-${NR_BTS_ID}']['NRBTS-${NR_BTS_ID}']['NRCELL-${target_cell}']['NHRRC']}

    [Return]  ${last}

Get M55349C00009 counter
    [Arguments]  ${target_cell}=${test_cell}
    log to console  Getting ${ul_rls_qos9}
    ${res}  get counter values  ${ul_rls_qos9}
    ${last}  get_last_counters_values
    ...  ${res['BTS']['MRBTS-${NR_BTS_ID}']['NRBTS-${NR_BTS_ID}']['NRCELL-${target_cell}']['NHRRC']}

    [Return]  ${last}

Get M55349C00042 counter
    [Arguments]  ${target_cell}=${test_cell}
    log to console  Getting ${ul_rlc_1cc_sa}
    ${res}  get counter values  ${ul_rlc_1cc_sa}
    ${last}  get_last_counters_values
    ...  ${res['BTS']['MRBTS-${NR_BTS_ID}']['NRBTS-${NR_BTS_ID}']['NRCELL-${target_cell}']['NHRRC']}

    [Return]  ${last}

Get M55353C01001 counter
    [Arguments]  ${target_cell}=${test_cell}
    log to console  Getting ${ul_time_pmqap}
    ${res}  get counter values  ${ul_time_pmqap}
    ${last}  get_last_counters_values
    ...  ${res['BTS']['MRBTS-${NR_BTS_ID}']['NRBTS-${NR_BTS_ID}']['NRCELL-${target_cell}']['NRPMQAP-1']['HRLCQ']}

    [Return]  ${last}

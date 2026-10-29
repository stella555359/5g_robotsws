*** Settings ***
Documentation  CB010986 test specific keywords.

Library  taf.sbts.oam.coam.admin
Library  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/counter_helpers.py
Library  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/webem_operations.py

*** Variables ***
${test_cell}  31
${location_counter}  M55113C00014

*** Keywords ***
Prepare TL for CB010986 test
     log to console    _Perform CB010986 commissioning

    create delta

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRPMRNL-1
    ...  actUlNrEcIdNgRanApPosition
    ...  true


    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${test_cell}
    ...  actUlNrEcIdAoa
    ...  true

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}

    lock_all_cells_except  ${test_cell}
    lock_all_cells_except  95    rat=lte
    wait until keyword succeeds  10m  5s
    ...  verify cell status  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${test_cell}


Do manual location trigger
    [Documentation]    This keyword should trigger location form LMF(NLS) controller. For now it just wait for user input.
    log to console    Trigger location manually...
    sleep    5m

Check cplane messages exists
    log to console   Check cplane messages exists


Verify location counter
    [Arguments]  ${target_cell}=${test_cell}
    log to console  Getting ${location_counter}
    ${res}  get counter values  ${counter2}
    ${last}  get_last_counters_values
    ...  ${res['BTS']['MRBTS-${NR_BTS_ID}']['NRBTS-${NR_BTS_ID}']['NRCELL-${target_cell}']['NCELA']}

    check_counters_are_greater_than_zero  ${last}

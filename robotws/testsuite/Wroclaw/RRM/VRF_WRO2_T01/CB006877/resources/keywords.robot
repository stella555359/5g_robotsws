*** Settings ***
Documentation  Robot resources for CB006877 specific test behavior.

Library  taf.sbts.oam.coam.admin
Library  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/counter_helpers.py
Library  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/webem_operations.py
Library  testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB006877/resources/keywords.py
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/logs_collection.robot


*** Variables ***
${NR_BTS_ID}     ${tl.gnbs[0].instance_id}
${TEST_CELL}  30
${TEST_CELL_CNI}  2

${counter1}    M55308C10004
${counter2}    M55308C10002

*** Keywords ***
Deactivate CB006877 and set counter interval
    create delta

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${TEST_CELL}
    ...  actDynUlResAlloc
    ...  false

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRPMRNL-1
    ...  miNrCellUtilization
    ...  5min
    ...

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}

Prepare Test Line for CB006877
    lock_all_cells_except  ${TEST_CELL}
    run keyword and ignore error  perform_rat_block  LTE
    wait until keyword succeeds  10m  5s
    ...  verify cell status  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${TEST_CELL}


Prepare Test Line for CNI-133487
    create delta

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${TEST_CELL_CNI}
    ...  actDynUlResAlloc
    ...  false

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRPMRNL-1
    ...  miNrCellUtilization
    ...  5min

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}

    lock_all_cells_except  ${TEST_CELL_CNI}
    wait until keyword succeeds  10m  5s
    ...  verify cell status  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${TEST_CELL_CNI}


Wait for M55308C10004 M55308C10002 counters
    log to console  Waiting 5mins for M55308C10004,M55308C10002
    sleep  5m


Get M55308C10004 counter
    [Arguments]  ${target_cell}=${TEST_CELL}
    log to console  Getting M55308C10004
    ${res}  get counter values  ${counter1}
    ${last}  get_last_counters_values
    ...  ${res['BTS']['MRBTS-${NR_BTS_ID}']['NRBTS-${NR_BTS_ID}']['NRCELL-${target_cell}']['NCELA']}

    [Return]  ${last}


Get M55308C10002 counter
    [Arguments]  ${target_cell}=${TEST_CELL}
    log to console  Getting M55308C10002
    ${res}  get counter values  ${counter2}
    ${last}  get_last_counters_values
    ...  ${res['BTS']['MRBTS-${NR_BTS_ID}']['NRBTS-${NR_BTS_ID}']['NRCELL-${target_cell}']['NCELA']}

    [Return]  ${last}


Feature CB006877 activation
    [Arguments]  ${target_cell}=${TEST_CELL}
    log to console  Activating CB006877 feature
    create delta

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${target_cell}
    ...  actDynUlResAlloc
    ...  true

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}


Feature CB006877 deactivation
    [Arguments]  ${target_cell}=${TEST_CELL}
    log to console  Deactivating CB006877 feature
    create delta

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${target_cell}
    ...  actDynUlResAlloc
    ...  false

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}


Back to default TL state
    log to console  Back to default TL state...
    unlock_all_cells
    run keyword and ignore error  perform_rat_unblock  LTE

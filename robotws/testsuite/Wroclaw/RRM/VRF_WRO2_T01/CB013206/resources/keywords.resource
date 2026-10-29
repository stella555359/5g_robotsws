*** Settings ***
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/webem_operations.py
Library    taf.sbts.oam.coam.admin
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/counter_helpers.py
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/logs_collection.robot

*** Variables ***
${TEST_CELL}  31
${TEST_CELL_LTE}    95
${NR_BTS_ID}     ${tl.gnbs[0].instance_id}
${counter_interval}    5min

${counter_1}        M55350C00038

*** Keywords ***
Perform commissioning CB013206
    log to console    _Perform CB0013206 commissioning

    create delta

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRPMRNL-1
    ...  miNrPDCPCell
    ...  ${counter_interval}

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${TEST_CELL}
    ...  cellDepType
    ...  NSA

    append parameter delete to delta
    ...    MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${TEST_CELL}
    ...    trackingAreaDN

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}

    lock_all_cells_except  ${TEST_CELL}
    lock_all_cells_except  95    rat=lte
    wait until keyword succeeds  10m  5s
    ...  verify cell status  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${TEST_CELL}


Wait for counter interval
    log to console    Waiting ${counter_interval} for counters
    sleep    ${counter_interval}


Get M55350C00038 counter
    log to console  Getting M55350C00038
    ${res}  get counter values  ${counter_1}
    ${last}  get_last_counters_values
    ...  ${res['BTS']['MRBTS-${NR_BTS_ID}']['NRBTS-${NR_BTS_ID}']['NRCELL-${TEST_CELL}']['PDCPC']}

    [Return]  ${last}


Back to default configuration
    log to console    _Perform default configuration commissioning
    create delta

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${TEST_CELL}
    ...  cellDepType
    ...  SA+NSA

    append parameter update to delta
    ...    MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${TEST_CELL}
    ...    trackingAreaDN
    ...    MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/TRACKINGAREA-7151

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}

    unlock_all_cells
    unlock_all_cells  rat=lte

    wait until keyword succeeds  10m  5s
    ...  verify cell status  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${TEST_CELL}

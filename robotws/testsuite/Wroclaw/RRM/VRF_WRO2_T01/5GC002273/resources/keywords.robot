*** Settings ***
Documentation  Specific keywords for automated test cases from 5GC002273 feature.

Library  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/webem_operations.py
Library  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/counter_helpers.py
Library  Collections
Library  taf.sbts.oam.coam.admin


*** Variables ***
${NR_BTS_ID}     ${tl.gnbs[0].instance_id}
${TEST_CELL}  91
${counter_400}    M55324C00400
${counter_101}    M55324C00101
${COUNTER_PATH}     MRBTS-50041/NRBTS-50041/NRCELL-1/NCELA/PRB_AVAIL_PUSCH
${counter_interval}  5min

*** Keywords ***
Perform 5GC002273 commissioning
    log to console  Performing 5GC002273 commissioning...
    create delta

    &{eirpControl}       Create dictionary  numOfSegmentAzimuthEdges=0
    ...                                     numOfSegmentElevationEdges=0
    ...                                     minSignificantNormalizedBeamGain=-20
    ...                                     minGuaranteedBudgetRatio=5
    ...                                     minGuaranteedBudgetRatioMode=actualEirpBudgetRatio
    ...                                     schedulWeightFactorEnabled=true


    ${powerReductionFactorList}    Create list    0

    append list items to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${TEST_CELL}
    ...  eirpControl
    ...  ${eirpControl}

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${TEST_CELL}
    ...  antennaMechanicalDowntilt
    ...  0

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${TEST_CELL}
    ...  eirpControlPowerReductionFactorList
    ...  ${powerReductionFactorList}

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRPMRNL-1
    ...  miNrEirp
    ...  ${counter_interval}

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${TEST_CELL}
    ...  actEirpControl
    ...  false

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}


Activate feature
    log to console  Activate feature...
    create delta

    append parameter update to delta
    ...  MRBTS-${NR_BTS_ID}/NRBTS-${NR_BTS_ID}/NRCELL-${TEST_CELL}
    ...  actEirpControl
    ...  true

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}


Wait for counter interval
    log to console  Waiting for counter interval ${counter_interval}...
    sleep  ${counter_interval}

Get M55324C00400 counter
    log to console  Getting M55324C00400...
    ${res}  get counter values  ${counter_400}
    ${last}  get_last_counters_values
    ...  ${res['BTS']['MRBTS-${NR_BTS_ID}']['NRBTS-${NR_BTS_ID}']['NRCELL-${TEST_CELL}']['NREIRP']}

    [Return]  ${last}


Get M55324C00101 counter
    log to console  Getting M55324C00101...
    ${res}  get counter values  ${counter_101}
    ${last}  get_last_counters_values
    ...  ${res['BTS']['MRBTS-${NR_BTS_ID}']['NRBTS-${NR_BTS_ID}']['NRCELL-${TEST_CELL}']['NREIRP']}

    [Return]  ${last}

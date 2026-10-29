*** Settings ***
Documentation
...  contact:       pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  description:   Keywords for 5GC002300 test cases.

Library         taf.sbts.oam.coam.admin
Library         Collections
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.5GC002300.resources.keywords.EirpTestVeryfication  ${bts_id}  ${cvr_test_cell}
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/webem_operations.py


*** Variables ***
${cvr_test_cell}    91
${counters_interval}    5min
${bts_id}    ${tl.gnbs[0].global_bts_id}


*** Keywords ***
Activate 5GC001329 feature
    Log to console    __Activating 5GC001329

    create delta
    append parameter update to delta
    ...  MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cvr_test_cell}
    ...  actEirpControl
    ...  true

    append parameter update to delta
    ...  MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cvr_test_cell}
    ...  antennaMechanicalDowntilt
    ...  0

    append parameter update to delta
    ...  MRBTS-${bts_id}/NRBTS-${bts_id}/NRPMRNL-1
    ...  miNrEirp
    ...  ${counters_interval}

    append parameter update to delta
    ...  MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cvr_test_cell}
    ...  eirpControlTimeAveragingWindowStepSize
    ...  100

    append parameter update to delta
    ...  MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cvr_test_cell}
    ...  eirpControlTimeAveragingWindow
    ...  6

    # Used default parameters provided by Parameter Editro WEBEM tool
    &{eirp_control_d}    create dictionary
#    ...    minGuaranteedBudgetRatio=0.50
    ...    minGuaranteedBudgetRatioMode=actualEirpBudgetRatio
    ...    minSignificantNormalizedBeamGain=-20
    ...    numOfSegmentAzimuthEdges=0
    ...    numOfSegmentElevationEdges=0
    ...    schedulWeightFactorEnabled=true


    # Set additional mandatory parameters for Trunk release
    ${res}  check if sw is trunk
    IF  ${res}
        Set To Dictionary    ${eirp_control_d}  actEpic  false
        Set To Dictionary    ${eirp_control_d}  epicMcsThreshold  5
    END

    append list items to delta
    ...    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cvr_test_cell}
    ...    eirpControl
    ...    ${eirp_control_d}

    # Used default parameters provided by Parameter Editro WEBEM tool
    @{eirp_control_power_reduction_l}    create list    0
     append list items to delta
    ...    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cvr_test_cell}
    ...    eirpControlPowerReductionFactorList
    ...    @{eirp_control_power_reduction_l}

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}

Activate 6dB power reduction
    Log to console    __Activating 6dB power reduction

    create delta

    # Used default parameters provided by Parameter Editro WEBEM tool
    @{eirp_control_power_reduction_l}    create list    -60
    append parameter update to delta
    ...    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cvr_test_cell}
    ...    eirpControlPowerReductionFactorList
    ...    ${eirp_control_power_reduction_l}

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}

Activate 5GC002300 feature
    Log to console    __Activating 5GC002300 feature...

    create delta

    append parameter update to delta
    ...    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cvr_test_cell}
    ...    eirpControlTimeAveragingWindowStepSize
    ...    100

    &{budget_ratio}  Create Dictionary
    ...    minGuaranteedBudgetRatioMode=actualEirpBudgetRatio
    ...    minGuaranteedBudgetRatio=50  # it gives 0.5 in WEBEM parameter editor
    ...    schedulWeightFactorEnabled=true

    append list items to delta
    ...    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cvr_test_cell}
    ...    eirpControl
    ...    ${budget_ratio}

    ${delta}  get delta
    activate_delta_recommissioning  ${delta}

Wait for eirp counters
    log to console    Waiting ${counters_interval} for eirp counters
    sleep    ${counters_interval}
    sleep    10s

Check 5GC001329 counters are present after activation
    find all erip counters

Check EIRP beamset_6 counter incrementation
    check_counters_incrementation_regarding_to_defined_beamset

Check Cell Power Counter with no power reduction
    check_cell_power_counter

Check 5GC001329 counters after power reduction
    check_and_compare_power_power_counters

Check 5GC001329 counters after 5GC002300 activation
    find all erip counters
    check_counters_incrementation_regarding_to_defined_beamset
    check_not_impacted_counters

Test Setup for 5GC002300
    [Documentation]    Isolate test cell from rest available on BTS.
    log to console    __Performing 5GC002300 test setup ...
    perform rat block    lte
    lock all cells except    ${cvr_test_cell}

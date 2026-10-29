*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    Maintainer:

Library        taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations                            WITH NAME    GnbCellOp
Library        taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                                WITH NAME    GnbDuOp
Library        testsuite.Krakow.SISO.regression.RAN_PZ_KRK2.CNI144608.resources.GnbCustomCounter    WITH NAME    GnbCounters

Resource       taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource       taf/rfrl/ue/robot/REAL_UE.robot

Variables      taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${PRIMARY_CELL_ID}                      ${0}
${NUMBER_OF_BEAMS}                      ${5}
${SELECTED_BEAMS}                       ${None}

${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${ENABLE_RACH_OBSERVER}                 ${False}

*** Keywords ***
Test Setup With UE
    Require Ue for L3 Call
    Run Keyword And Ignore Error    ue.Detach Ue     UE
    Reset BTS to Clear PM Counters Data
    Common Preconditions With Watching Alarms

Verify All Cells Are Operating Correctly
    GnbCellOp.verify_all_cells_are_onair

Wait For All Cells To Be Operating Correctly
    Wait Until Keyword Succeeds    8 min    15 sec    Verify All Cells Are Operating Correctly

Reset BTS to Clear PM Counters Data
    GnbDuOp.reset_bts
    Wait For All Cells To Be Operating Correctly

Perform UE Attach in Loop
    FOR    ${attempt}    IN RANGE    ${0}    ${NUMBER_OF_BEAMS}
        Log    Attach attempt ${attempt}
        ue.Attach Ue    UE    ${20}
        Sleep   2 sec    reason=Waiting for UE to attach
        ue.Detach Ue    UE
        Sleep    7 sec    reason=Waiting for UE to detach
    END

Validate Correct Values of PM Counters for SCell Additions
    GnbCounters.wait_for_next_pm_period    interval=5min
    GnbCounters.validate_pm_counters_for_scell_additions    expected_value=${NUMBER_OF_BEAMS}
    ...                                                     cell_id=${PRIMARY_CELL_ID}

Validate Beam Usage PM Counters
    FOR    ${beam}    IN    @{SELECTED_BEAMS}
        Log    Current beam: ${beam}
        GnbCounters.unmute_beam    beam=${beam}
        ...                        cell_id=${PRIMARY_CELL_ID}
        GnbCellOp.wait_for_cell_to_be_onair
        Run Keyword And Continue On Failure    Perform UE Attach in Loop
        Run Keyword And Ignore Error    GnbCounters.validate_pm_counters_for_beams
        ...                             expected_value=${NUMBER_OF_BEAMS}
        ...                             cell_id=${PRIMARY_CELL_ID}
        Sleep    60 sec    reason=Waiting for UE stabilization
    END
    GnbCounters.wait_for_next_pm_period    interval=5min
    GnbCounters.end_of_test_validate_pm_counters_for_beams    expected_value=${NUMBER_OF_BEAMS}
    ...                                                       cell_id=${PRIMARY_CELL_ID}

Select Beams For Test
    ${beams}    GnbCounters.select_set_of_beams_to_test
    Set Test Variable    ${SELECTED_BEAMS}    ${beams}

Custom Suite Teardown
    Perform Full Commissioning and Wait for onAir    prefix_tag=4CC
    Sleep    18 minutes    reason=Waiting till scout connect to BTS
    Common Suite Teardown

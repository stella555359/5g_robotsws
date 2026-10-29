*** Settings ***
Documentation
...   Test suite for regression testing of feature CB012649
...   author: Malgorzata Pietka
...   contact: malgorzata.pietka@nokia.com

Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                      WITH NAME    gnbbbu
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations                  WITH NAME    Cells
Library      taf.rfrl.utilities.logger.custom_logger                                    WITH NAME    Logger
Library      testsuite/Krakow/resources/delta/bts_delta_generator.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Keywords ***
Lock and Unlock Cells with Verifying Cell Status
    Cells.Lock All Cells                administrative_state={True}
    Wait Until Keyword Succeeds         5min    10s    gnb_cells.Verify All Cells Statuses
    ...                                 operational_state=Disabled
    ...                                 procedural_status=initialization required
    ...                                 availability_status=Offline
    ...                                 administrative_state=Locked

    Cells.Unlock All Cells              administrative_state={True}
    Wait Until Keyword Succeeds         5min    10s    gnb_cells.Verify All Cells Statuses
    ...                                 operational_state=enabled
    ...                                 procedural_status=configured
    ...                                 blocking_state=Unblocked
    ...                                 administrative_state=Unlocked

Common Preconditions With Watching Alarms and NR cells set to barred
    [Arguments]     @{cells_to_be_barred}
    Common Preconditions With Watching Alarms
    ${delta}  Generate Delta for barred NRCELLs        cells=${cells_to_be_barred}
    Perform BTS Delta Commissioning                    delta=${delta}

Set Cells To Barred and not Barred
    [Arguments]     ${cells_to_be_barred}     ${cells_to_be_not_barred}
    ${delta}  Generate Delta for barred NRCELLs        cells=${cells_to_be_barred}
    Perform Bts Delta Commissioning                    delta=${delta}
    ${delta}  Generate Delta for not barred NRCELLs    cells=${cells_to_be_not_barred}
    Perform Bts Delta Commissioning                    delta=${delta}

Common Postconditions With Watching Alarms and NR cells set to not barred
    [Arguments]     @{cells_to_be_not_barred}
    Common Postconditions With Watching Alarms
    ${delta}  Generate Delta for not barred NRCELLs     cells=${cells_to_be_not_barred}
    Perform Bts Delta Commissioning                     delta=${delta}

Verify L3 call
    [Arguments]    ${deviation}     ${duration}     ${tputUl}   ${tputDl}    ${protocol}
    ue.Attach Ue                                    UE
    Run Keyword And Continue On Failure             Start Data Transfer and Verify Troughput
    ...                                             direction=dl
    ...                                             duration=${duration}
    ...                                             protocol=${protocol}
    ...                                             tput=${tputDl}
    ...                                             deviation=${deviation}

    Run Keyword And Continue On Failure             Start Data Transfer and Verify Troughput
    ...                                             direction=ul
    ...                                             duration=${duration}
    ...                                             protocol=${protocol}
    ...                                             tput=${tputUl}
    ...                                             deviation=${deviation}
    ue.Detach UE                                    UE

Custom Test Teardown
    # In UUF4ALL swconfig is restored at the end of test case(without waiting to oan Air)
    # to delete when it will be implemented in UU4ALL
    Sleep    120    reason=Waiting for BTS to be up
    Wait Until Keyword Succeeds     300 sec     10 sec   gnbcell.Verify All Cells are OnAir
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

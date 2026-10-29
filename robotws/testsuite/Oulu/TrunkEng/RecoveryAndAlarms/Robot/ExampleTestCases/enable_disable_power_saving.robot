*** Settings ***
Documentation
...    Author:      Terhi Talvitie
...    Contact:     I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.ParameterChange

Suite Setup         Common Suite Setup
Suite Teardown      Common Suite Teardown

*** Variables ***
${POWER_SAVING_START_TIME}    15min
${POWER_SAVING_DURATION}      10
${SUSPEND_CELL_ENERGY_SAVING}    ${False}
${SELECTED_CELLS}    All
${SELECTED_RAT}      LTE


*** Test Cases ***
Enable_power_saving
    [Documentation]  Enable power savings mode by setting in LTE actLBPowerSaving to true in class NOKLTE:LNBTS
    ...              and in 5G actNrLBPowerSaving to true in class com.nokia.srbts.nrbts:NRBTS
    Print Text To Eventlog    Enabling power saving mode
    Run Keyword And Continue On Failure  Enable Or Disable Power Saving Mode   enable_power_saving=${True}

Modify_power_saving_window
    [Documentation]  Modify power saving window to start in ${POWER_SAVING_START_TIME} and last for ${POWER_SAVING_DURATION} minutes
    ...              Also suspend NR cell energy saving is set to ${SUSPEND_CELL_ENERGY_SAVING}
    Print Text To Eventlog    Modifying power saving window to start in ${POWER_SAVING_START_TIME} and last for ${POWER_SAVING_DURATION} minutes
    Run Keyword And Continue On Failure  Update Power Saving Window   when_to_start=${POWER_SAVING_START_TIME}
    ...                                  power_saving_duration=${POWER_SAVING_DURATION}  suspend_cell_energy_saving=${SUSPEND_CELL_ENERGY_SAVING}
    ...                                  admin_connection=default  affected_cells=${SELECTED_CELLS}   affected_rat=${SELECTED_RAT}

Disable_power_saving
    [Documentation]  Disable power savings mode by setting in LTE actLBPowerSaving to false in class NOKLTE:LNBTS
    ...              and in 5G actNrLBPowerSaving to false in class com.nokia.srbts.nrbts:NRBTS
    Print Text To Eventlog    Get new SCF file for parsing before disabling power saving mode
    Run Keyword And Continue On Failure  SCF.Get Scf
    Print Text To Eventlog    Disabling power saving mode
    Run Keyword And Continue On Failure  Enable Or Disable Power Saving Mode   enable_power_saving=${False}

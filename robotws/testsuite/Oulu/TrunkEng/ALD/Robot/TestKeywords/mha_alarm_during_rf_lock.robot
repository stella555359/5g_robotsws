*** Settings ***

Documentation
...  Author:   Jere Jacklin
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource   testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Library    testsuite.Oulu.TrunkEng.ALD.Python.Interfaces.CommonAldInterface
Library    testsuite.Oulu.TrunkEng.ALD.Python.Interfaces.AldEmulatorInterface


*** Keywords ***
Mha Alarm During Rf Lock
    [Arguments]  ${WAIT_BEFORE_ALARMS}  ${WAIT_AFTER_RF_LOCK}  ${WAIT_AFTER_CANCEL_ALARM}
    ...          ${LNA}  ${ALARM_TYPE}  ${EMULATOR_LINE}  ${ALARM}  ${ALARM_ANTL}  ${RADIO}  ${AFFECTED_ANTLS}
    ...          ${WANTED_STATE}  ${FAULT_NAME}

    Print Step Text                             1   Check Preconditions
    Run Keyword and Continue On Failure             Common Preconditions
    ${ENV}=                                         BTS.Find UTE TL name
    Print Step Text                             2   Add alarm
    Run Keyword and Continue On Failure             Add Emulator Alarm  antennaline=${ALARM_ANTL}  fault_id=${ALARM}
    ...                                                                 fault_name=${FAULT_NAME}
    ...                                                                 given_lna=${LNA}
    Print Step Text                             3   Check FEG values
    ${FEG_before}=                                  Calculate And Check Feg
    Print Step Text                             4   Raise selected ALD alarm
    Run Keyword and Continue On Failure             Raise Alarm  ${LNA}  ${ALARM_TYPE}
    ...                                                          ${EMULATOR_LINE}  environment=${ENV}
    Wait Time And Reason                            ${WAIT_BEFORE_ALARMS}  Wait after raising alarm
    Print Step Text                             5   Check RMOD states
    Run Keyword and Continue On Failure             Check Radio Statuses
    Print Step Text                             6   Check MHA states
    Run Keyword and Continue On Failure             Check Mha states  wanted_state=${WANTED_STATE}
    ...                                                               antennaline=${ALARM_ANTL}  lna=${LNA}
    Print Step Text                             7   Check expected alarms
    Run Keyword and Continue On Failure             ALARMS.Check Expected Alarms  get_active_alarms=${True}
    Print Step Text                             8   Check FEG values
    ${FEG_now}=                                     Calculate And Check Feg
    Run Keyword and Continue On Failure             Compare Feg Values  ${FEG_before}  ${FEG_now}
    ...                                                                 affected_antennalines=${AFFECTED_ANTLS}
    Print Step Text                             9   Lock Radio
    Run Keyword and Continue On Failure             Lock Radio  ${RADIO}
    Wait Time And Reason                            ${WAIT_AFTER_RF_LOCK}  Wait after locking radio
    Print Step Text                            10   Check MHA states
    Run Keyword and Continue On Failure             Check Mha states  wanted_state=dependency
    ...                                                               antennaline=${ALARM_ANTL}
    Print Step Text                            11   Raise selected ALD alarm
    Run Keyword and Continue On Failure             Raise Alarm  ${LNA}  ${ALARM_TYPE}
    ...                                                          ${EMULATOR_LINE}  environment=${ENV}
    Print Step Text                            12   Unlock Radio
    Run Keyword and Continue On Failure             Unlock Radio  ${RADIO}
    Print Step Text                            13   Check cell states
    Run Keyword and Continue On Failure             Wait For All Cells Up  time_limit=300  degraded_cells=All
    Print Step Text                            14   Wait before checks
    Wait Time And Reason                            ${WAIT_BEFORE_ALARMS}  Wait before checking alarms
    Print Step Text                            15   Check MHA states
    Run Keyword and Continue On Failure             Check Mha states  wanted_state=${WANTED_STATE}
    ...                                                               antennaline=${ALARM_ANTL}  lna=${LNA}
    Print Step Text                            16   Check expected alarms
    Run Keyword and Continue On Failure             ALARMS.Check Expected Alarms  get_active_alarms=${True}
    Print Step Text                            17   Check FEG values
    ${FEG_now}=                                     Calculate And Check Feg
    Run Keyword and Continue On Failure             Compare Feg Values  ${FEG_before}  ${FEG_now}
    ...                                                                 affected_antennalines=${AFFECTED_ANTLS}
    Print Step Text                            18   Cancel selected ALD alarm
    Run Keyword and Continue On Failure             Clear Alarm  ${LNA}  ${ALARM_TYPE}
    ...                                                          ${EMULATOR_LINE}  environment=${ENV}
    Wait Time And Reason                            ${WAIT_AFTER_CANCEL_ALARM}  Wait after cancelling alarm
    Print Step Text                            19   Check MHA states
    Run Keyword and Continue On Failure             Check Mha states  antennaline=${ALARM_ANTL}
    ...                                                               wanted_state=OK  lna=lna1
    Print Step Text                            20   Reset alarms and check active alarms
    Run Keyword and Continue On Failure             ALARMS.Reset Alarms
    Run Keyword and Continue On Failure             ALARMS.Check Active Alarms
    Print Step Text                            21   Check FEG values
    ${FEG_now}=                                     Calculate And Check Feg
    Run Keyword and Continue On Failure             Compare Feg Values  ${FEG_before}  ${FEG_now}
    Print Step Text                            22   Check alarm history
    Run Keyword and Continue On Failure             Add Emulator Alarm  antennaline=${ALARM_ANTL}  fault_id=${ALARM}
    ...                                                                 fault_name=${FAULT_NAME}
    ...                                                                 given_lna=${LNA}  add_to_allowed_alarms=${TRUE}
    Run Keyword and Continue On Failure             Common Postconditions

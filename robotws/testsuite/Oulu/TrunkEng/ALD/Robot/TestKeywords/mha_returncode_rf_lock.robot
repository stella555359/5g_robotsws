*** Settings ***

Documentation
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource   testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Library    testsuite.Oulu.TrunkEng.ALD.Python.Interfaces.CommonAldInterface
Library    testsuite.Oulu.TrunkEng.ALD.Python.Interfaces.AldEmulatorInterface


*** Keywords ***
Mha Returncode Rf Lock
    [Arguments]    ${ALARM_ANTL}  ${ALARM}  ${EMULATOR_LINE}  ${RETURN_CODE}  ${RADIO}  ${WAIT_AFTER_RF_LOCK}
    ...            ${WAIT_BEFORE_ALARMS}  ${WANTED_STATE}  ${AFFECTED_ANTLS}  ${FAULT_NAME}

    Print Step Text                             1   Check Preconditions
    Run Keyword and Continue On Failure             Common Preconditions
    ${ENV}=                                         BTS.Find UTE TL name
    Print Step Text                             2   Calculate FEG values
    ${FEG_before}=                                  Calculate And Check Feg
    Print Step Text                             3   Add alarm
    Run Keyword and Continue On Failure             Add Emulator Alarm  antennaline=${ALARM_ANTL}  fault_id=${ALARM}
    ...                                                                 fault_name=${FAULT_NAME}
    ...                                                                 given_lna=lna1  second_given_lna=lna2
    Print Step Text                             4   Set Return Codes
    Run Keyword and Continue On Failure             Return Code  lna=lna1  return_code_type=${RETURN_CODE}
    ...                                                          emulator_line=${EMULATOR_LINE}  environment=${ENV}
    Run Keyword and Continue On Failure             Return Code  lna=lna2  return_code_type=${RETURN_CODE}
    ...                                                          emulator_line=${EMULATOR_LINE}  environment=${ENV}
    Run Keyword and Continue On Failure             Get Return Code  lna=lna1  return_code_type=${RETURN_CODE}
    ...                                                              emulator_line=${EMULATOR_LINE}  environment=${ENV}
    Run Keyword and Continue On Failure             Get Return Code  lna=lna2  return_code_type=${RETURN_CODE}
    ...                                                              emulator_line=${EMULATOR_LINE}  environment=${ENV}
    Print Step Text                             5   Lock Radio
    Run Keyword and Continue On Failure             Lock Radio  ${RADIO}
    Wait Time And Reason                            ${WAIT_AFTER_RF_LOCK}  Wait after locking radio
    Print Step Text                             6   Check MHA states
    Run Keyword and Continue On Failure             Check Mha states  wanted_state=dependency
    ...                                                               antennaline=${ALARM_ANTL}  both_lnas=${TRUE}
    Print Step Text                             7   Unlock Radio
    Run Keyword and Continue On Failure             Unlock Radio  ${RADIO}
    Print Step Text                             8   Check cell states
    Run Keyword and Continue On Failure             Wait For All Cells Up  time_limit=300  degraded_cells=All
    Print Step Text                             9   Wait before checks
    Wait Time And Reason                            ${WAIT_BEFORE_ALARMS}  Wait before checking alarms
    Print Step Text                            10   Check MHA states
    Run Keyword and Continue On Failure             Check Mha states  wanted_state=${WANTED_STATE}
    ...                                                               antennaline=${ALARM_ANTL}  both_lnas=${TRUE}
    Print Step Text                            11   Check expected alarms
    Run Keyword and Continue On Failure             ALARMS.Check Expected Alarms  get_active_alarms=${True}
    Print Step Text                            12   Check FEG values
    ${FEG_now}=                                     Calculate And Check Feg
    Run Keyword and Continue On Failure             Compare Feg Values  ${FEG_before}  ${FEG_now}
    ...                                                                 affected_antennalines=${AFFECTED_ANTLS}
    Print Step Text                            13   Set OK return code
    Run Keyword and Continue On Failure             Return Code  lna=lna1  return_code_type=Ok
    ...                                                          emulator_line=${EMULATOR_LINE}  environment=${ENV}
    Run Keyword and Continue On Failure             Return Code  lna=lna2  return_code_type=Ok
    ...                                                          emulator_line=${EMULATOR_LINE}  environment=${ENV}
    Run Keyword and Continue On Failure             Get Return Code  lna=lna1  return_code_type=Ok
    ...                                                              emulator_line=${EMULATOR_LINE}  environment=${ENV}
    Run Keyword and Continue On Failure             Get Return Code  lna=lna2  return_code_type=Ok
    ...                                                              emulator_line=${EMULATOR_LINE}  environment=${ENV}
    Print Step Text                            14   Lock Radio
    Run Keyword and Continue On Failure             Lock Radio  ${RADIO}
    Wait Time And Reason                            ${WAIT_AFTER_RF_LOCK}  Wait after locking radio
    Print Step Text                            15   Check MHA states
    Run Keyword and Continue On Failure             Check Mha states  wanted_state=dependency
    ...                                                               antennaline=${ALARM_ANTL}  both_lnas=${TRUE}
    Print Step Text                            16   Unlock Radio
    Run Keyword and Continue On Failure             Unlock Radio  ${RADIO}
    Print Step Text                            17   Check cell states
    Run Keyword and Continue On Failure             Wait For All Cells Up  time_limit=300  degraded_cells=All
    Print Step Text                            18   Wait before checks
    Wait Time And Reason                            ${WAIT_BEFORE_ALARMS}  Wait before checking alarms
    Print Step Text                            19   Check MHA states
    Run Keyword and Continue On Failure             Check Mha states  wanted_state=OK
    ...                                                               antennaline=${ALARM_ANTL}  both_lnas=${TRUE}
    Print Step Text                            20   Check FEG values
    ${FEG_now}=                                     Calculate And Check Feg
    Run Keyword and Continue On Failure             Compare Feg Values  ${FEG_before}  ${FEG_now}
    Print Step Text                            21   Reset alarms and check active alarms
    Run Keyword and Continue On Failure             ALARMS.Reset Alarms
    Run Keyword and Continue On Failure             ALARMS.Check Active Alarms
    Print Step Text                            22   Check alarm history
    Run Keyword and Continue On Failure             Add Emulator Alarm  antennaline=${ALARM_ANTL}  fault_id=${ALARM}
    ...                                                                 fault_name=${FAULT_NAME}
    ...                                                                 given_lna=lna1  second_given_lna=lna2
    ...                                                                 add_to_allowed_alarms=${TRUE}
    Print Step Text                            23  Common Postconditions
    Run Keyword and Continue On Failure            Common Postconditions

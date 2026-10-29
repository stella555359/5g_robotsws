*** Settings ***

Documentation
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource   testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Library    testsuite.Oulu.TrunkEng.ALD.Python.Interfaces.CommonAldInterface
Library    testsuite.Oulu.TrunkEng.ALD.Python.Resources.Cleware
Library    testsuite.Oulu.TrunkEng.ALD.Python.Interfaces.ClewareCleaner
Library    testsuite.Oulu.TrunkEng.ALD.Python.Interfaces.VSWR
Library    String


*** Keywords ***
ALD 1834 Alarm With Site Reset
    [Arguments]    ${ALARM_ANTL}  ${WAIT_TIME_BEFORE_ALARM}
    ...            ${WAIT_TIME_AFTER_CANCELLING_ALARM}  ${AFFECTED_ANTLS}  ${ALARM}

    Print Step Text                             1  Check Preconditions
    Run Keyword and Continue On Failure            Common Preconditions
    ${antl_obj}=                                   Get Antenna Line Object  ${ALARM_ANTL}
    @{RMOD_FROM_ALARM_ANTL}=                       Split String  ${ALARM_ANTL}  /
    ${RADIO}=                                      Set Variable  ${RMOD_FROM_ALARM_ANTL}[0]
    ${rmod_obj}=                                   Get RMOD Object From User Given Values  ${RADIO}
    Print Text To Eventlog                         Antenna Line ${ALARM_ANTL} connected to cells ${ANTL_OBJ.connected_cells}
    ${tx_resource}=                                Get Tx Resource To Be Used  ${rmod_obj}  ${ANTL_OBJ.connected_cells}  ${ALARM_ANTL}
    ${affected_cells}=                             Get Cells Connected To Selected Tx  ${tx_resource}  ${rmod_obj}  ${ALARM_ANTL}
    ${mha_effect_on_affected_cells}=               Check If Tested Antennaline Has Cell Effects On Tested Cells
    ...                                            ${ALARM_ANTL}
    IF  ${mha_effect_on_affected_cells}
        Set Suite Variable  ${state}  cell_enabled_degraded
    ELSE
        Set Suite Variable  ${state}  ok_state
    END
    Run Keyword and Continue On Failure            Add 1834 Or 1835 Alarm For Ald
    ...                                            antennaline=${ALARM_ANTL}  fault_id=${ALARM}
    ...                                            fault_name=Mast Head Amplifier fault
    ${ENV}=                                        BTS.Find UTE TL name
    Print Step Text                             2  Calculate FEG values
    ${FEG_before}=                                 Calculate And Check Feg
    Print Step Text                             3  Switch Cleware pin on
    Run Keyword                                    Set Switch  status=ON  env=${ENV}  alarm=${ALARM}
    ...                                                        antennaline=${ALARM_ANTL}
    Wait Time and Reason                           ${WAIT_TIME_BEFORE_ALARM}  Waiting before alarms
    Print Step Text                             4  Check MHA States & Cell states
    Run Keyword and Continue On Failure            Check Mha States  wanted_state=degraded
    ...                                                              antennaline=${ALARM_ANTL}
    Run Keyword and Continue On Failure            Check Expected States  ${affected_cells}  ${rmod_obj}  state=${state}
    Print Step Text                             5  Check FEG values
    ${FEG_now}=                                    Calculate And Check Feg
    Run Keyword and Continue On Failure            Compare Feg Values  ${FEG_before}  ${FEG_now}  ${AFFECTED_ANTLS}
    Print Step Text                             6  Check expected alarms
    Run Keyword and Continue On Failure            ALARMS.Check Expected Alarms  wait_active_timeout=120  get_active_alarms=${True}
    Print Step Text                             7  Perform site reset
    Run Keyword and Continue On Failure            ADMIN.Reset Site  detailed_output=True
    Print Step Text                             8  Wait for cells
    Run Keyword and Continue On Failure            Wait For All Cells Up  time_limit=360  degraded_cells=All
    Wait Time and Reason                           ${WAIT_TIME_BEFORE_ALARM}  Waiting before alarms
    Print Step Text                             9  Check expected alarms
    Run Keyword and Continue On Failure            ALARMS.Check Expected Alarms  wait_active_timeout=120  get_active_alarms=${True}
    Print Step Text                            10  Check MHA states & Cell states
    Run Keyword and Continue On Failure            Check Mha States  wanted_state=degraded
    ...                                                              antennaline=${ALARM_ANTL}
    Run Keyword and Continue On Failure            Check Expected States  ${affected_cells}  ${rmod_obj}  state=${state}
    Print Step Text                            11  Check FEG values
    ${FEG_now}=                                    Calculate And Check Feg
    Run Keyword and Continue On Failure            Compare Feg Values  ${FEG_before}  ${FEG_now}  ${AFFECTED_ANTLS}
    Print Step Text                            12  Clear Cleware pin
    Run Keyword and Continue On Failure            Set Switch  status=OFF
    ...                                                        env=${ENV}  alarm=${ALARM}  antennaline=${ALARM_ANTL}
    Wait Time And Reason                           2  Waiting after switching pin off
    Run Keyword and Continue On Failure            Check Pins  env=${ENV}
    Wait Time and Reason                           ${WAIT_TIME_AFTER_CANCELLING_ALARM}  Waiting for cancelling alarms
    Print Step Text                            15  Reset alarms and check active alarms
    Run Keyword and Continue On Failure            ALARMS.Reset Alarms
    Run Keyword and Continue On Failure            ALARMS.Check Active Alarms
    Print Step Text                            16  Check MHA states & Cell states
    Run Keyword and Continue On Failure            Check Mha States  wanted_state=OK  antennaline=${ALARM_ANTL}
    Run Keyword and Continue On Failure            Check Expected States  ${affected_cells}  ${rmod_obj}  state=ok_state
    Print Step Text                            17  Check FEG values
    ${FEG_now}=                                    Calculate And Check Feg
    Run Keyword and Continue On Failure            Compare Feg Values  ${FEG_before}  ${FEG_now}
    Print Step Text                            18  Check alarm history
    Run Keyword and Continue On Failure            Common Postconditions

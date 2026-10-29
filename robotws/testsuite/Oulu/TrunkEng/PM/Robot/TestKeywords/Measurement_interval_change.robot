*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning


*** Keywords ***

Measurement Interval Change
    [Arguments]    ${UPLOAD_PERIOD}  ${MEAS_INTERVAL}  ${MEASUREMENT_INTERVALS}
    Print Step Text                      1   Check Preconditions  automatic=${True}
    Run Keyword and Continue On Failure      Common Preconditions
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${UPLOAD_PERIOD}  interval=${MEAS_INTERVAL}
    Print Step Text                      2   Wait for next ${UPLOAD_PERIOD}min interval to start test  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  interval=${UPLOAD_PERIOD}
    Print Step Text                      3   Wait for next ${UPLOAD_PERIOD}min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  interval=${UPLOAD_PERIOD}
    Print Step Text                      4   Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_PERIOD}
    Print Step Text                      5   Wait 20min past the hour  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  next_interval=${False}  delta=${1200}
    Print Step Text                      4   Time to change measurement intervals  automatic=${True}
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${UPLOAD_PERIOD}  interval=${MEAS_INTERVAL}
    ...                                      meas_intervals=${MEASUREMENT_INTERVALS}
    ${repeat}  ${end_time}=                  Run Keyword And Continue On Failure  PmCommon.Find Nearest End Time
    ${expiration_intervals}=                 Run Keyword And Continue On Failure  PmCommon.Find Expiration Times  ${end_time}
    ${expiration_tuple}=                     Run Keyword And Continue On Failure  PmCommon.Get Current Expiration Times
    ...                                      ${expiration_intervals}
    ${expired_meas_tuple}=                   Run Keyword And Continue On Failure  PmCommon.Find Expired Measurements
    ...                                      ${expiration_intervals}  ${MEASUREMENT_INTERVALS}
    ${interval_tuple}=                       python_helper.Choose Two Values From Tuple  ${expiration_tuple}  ${0}  ${expiration_intervals}  ${2}
    Print Step Text                      5   Wait for next ${UPLOAD_PERIOD}min interval  automatic=${True}
    ${time}=                                 Run Keyword And Continue On Failure  PmCommon.Wait For Interval  interval=${UPLOAD_PERIOD}
    Print Step Text                      6   Check PM File. Only 15min measurements should be complete  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${interval_tuple}  upload_interval=${UPLOAD_PERIOD}
    ...                                      expired_measurements=${expired_meas_tuple}  disabled_measurements=${expired_meas_tuple}
    ...                                      time=${time}
    Repeat Keyword  ${repeat} times          Run Keyword And Continue On Failure  Wait For Interval And Check PM File
    ...                                      ${UPLOAD_PERIOD}  ${MEASUREMENT_INTERVALS}  ${expiration_intervals}
    Print Step Text                      7   Update PM data back to 15min  automatic=${True}
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${15}  interval=${15}
    Print Step Text                      8   Wait for next ${UPLOAD_PERIOD}min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval  interval=${UPLOAD_PERIOD}
    Print Step Text                      9   Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${15}  upload_interval=${15}
    Print Step Text                      10  Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure      Common Postconditions

Wait For Interval And Check PM File
    [Arguments]    ${UPLOAD_PERIOD}  ${MEASUREMENT_INTERVALS}  ${expiration_intervals}
    Print Step Text                      3   Wait for next 60min interval  automatic=${True}
    ${time}=                                 Run Keyword And Continue On Failure  PmCommon.Wait For Interval  interval=${UPLOAD_PERIOD}
    Print Step Text                      4   Check PM File  automatic=${True}
    ${expiration_tuple}=                     Run Keyword And Continue On Failure  Get Current Expiration Times  ${expiration_intervals}
    ...                                      next_interval=${False}
    ${expired_meas_tuple}=                   Run Keyword And Continue On Failure  PmCommon.Find Expired Measurements
    ...                                      ${expiration_intervals}  ${MEASUREMENT_INTERVALS}  next_interval=${False}
    ${interval_tuple}=                       python_helper.Choose Two Values From Tuple  ${expiration_tuple}  ${0}  ${expiration_intervals}  ${2}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${interval_tuple}  upload_interval=${UPLOAD_PERIOD}
    ...                                      expired_measurements=${expired_meas_tuple}  disabled_measurements=${expired_meas_tuple}
    ...                                      time=${time}

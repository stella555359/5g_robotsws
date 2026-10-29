*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PMCommonInterface      WITH NAME  PmCommon
Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.PmCommissioningInterface      WITH NAME  PmCommissioning

*** Keywords ***

Time Synchronization NTP
    [Arguments]    ${INCORRECT_IP}  ${CORRECT_IP}  ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}  ${WAIT_CHECKS}
    Print Step Text                      1   Check Preconditions  automatic=${True}
    Run Keyword                              Common Preconditions
    Print Step Text                      2   Update PM measurement data via commissioning  automatic=${True}
    Run Keyword And Continue On Failure      PmCommissioning.Update PM Data  period=${MEAS_INTERVAL}  interval=${UPLOAD_INTERVAL}
    Run Keyword And Continue On Failure      ALARMS.Add Expected Alarm   fault_id=4405
    ...                                                                  fault_name=No usable time reference available
    ...                                                                  alarm_id=7115
    Run Keyword And Continue On Failure      ALARMS.Add Expected Alarm   fault_id=4297
    ...                                                                  fault_name=NTP Server ${INCORRECT_IP} unavailable
    ...                                                                  alarm_id=7115
    Print Step Text                      3   Change NTP address from ${CORRECT_IP} to ${INCORRECT_IP}  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Commission NTP IP   ${INCORRECT_IP}
    Print Step Text                      4   Check that NTP is disabled  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check NTP Availability  status=unavailable
    Print Step Text                      5   Make site reset  automatic=${True}
    Run Keyword and Continue On Failure      ADMIN.Reset Site    detailed_output=True
    Print Step Text                      6   Wait for all cells up max 300s  automatic=${True}
    Run Keyword And Continue On Failure      Wait For All Cells Up  300
    Print Step Text                      7   Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      8   Check that RD file exist on BTS  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check latest file existence   RD  exist=${True}
    Print Step Text                      9   Check PM file does not exist on BTS  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check latest file existence   PM  exist=${False}
    Print Step Text                      10  Check Alarms  automatic=${True}
    Run Keyword And Continue On Failure      ALARMS.Check Expected Alarms  wait_active_timeout=1200
    Print Step Text                      11  Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      12  Change NTP address from ${INCORRECT_IP} to ${CORRECT_IP}  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Commission NTP IP   ${CORRECT_IP}
    Wait Time And Reason                     ${WAIT_CHECKS}  after NTP address change
    Print Step Text                      13  Check Alarms  automatic=${True}
    Run Keyword And Continue On Failure      ALARMS.Check Active Alarms
    Print Step Text                      14  Check that NTP is enabled  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check NTP Availability
    Print Step Text                      15  Change NTP address from ${CORRECT_IP} to ${INCORRECT_IP}  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Commission NTP IP   ${INCORRECT_IP}
    Print Step Text                      16  Check that NTP is disabled  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check NTP Availability  status=unavailable
    Print Step Text                      17  Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      18  Check Alarms  automatic=${True}
    Run Keyword And Continue On Failure      ALARMS.Check Expected Alarms  wait_active_timeout=1200
    Print Step Text                      19  Check that RD file exist on BTS  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check latest file existence   RD  exist=${True}
    Print Step Text                      20  Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_INTERVAL}
    ...                                                              ntp_faulty=${True}
    Print Step Text                      21  Change NTP address from ${INCORRECT_IP} to ${CORRECT_IP}  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Commission NTP IP   ${CORRECT_IP}
    Wait Time And Reason                     ${WAIT_CHECKS}  after NTP address change
    Print Step Text                      22  Check Alarms  automatic=${True}
    Run Keyword And Continue On Failure      ALARMS.Check Active Alarms
    Print Step Text                      23  Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      24  Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_INTERVAL}
    Print Step Text                      25  Check that NTP is enabled  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check NTP Availability
    Print Step Text                      26  Change NTP address from ${CORRECT_IP} to ${INCORRECT_IP}  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Commission NTP IP   ${INCORRECT_IP}
    Print Step Text                      27  Check that NTP is disabled  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check NTP Availability  status=unavailable
    Print Step Text                      28  Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      29  Check Alarms  automatic=${True}
    Run Keyword And Continue On Failure      ALARMS.Check Expected Alarms  wait_active_timeout=1200
    Print Step Text                      30  Change NTP address from ${INCORRECT_IP} to ${CORRECT_IP}  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Commission NTP IP   ${CORRECT_IP}
    Wait Time And Reason                     ${WAIT_CHECKS}  after NTP address change
    Print Step Text                      31  Check Alarms  automatic=${True}
    Run Keyword And Continue On Failure      ALARMS.Check Active Alarms
    Print Step Text                      32  Check that NTP is enabled  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check NTP Availability
    Print Step Text                      33  Change NTP address from ${CORRECT_IP} to ${INCORRECT_IP}  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Commission NTP IP   ${INCORRECT_IP}
    Print Step Text                      34  Check that NTP is disabled  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check NTP Availability  status=unavailable
    Print Step Text                      35  Wait for next 15min interval  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Wait For Interval
    Print Step Text                      36  Check Alarms  automatic=${True}
    Run Keyword And Continue On Failure      ALARMS.Check Expected Alarms  wait_active_timeout=1200
    Print Step Text                      37  Change NTP address from ${INCORRECT_IP} to ${CORRECT_IP}  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Commission NTP IP   ${CORRECT_IP}
    Wait Time And Reason                     ${WAIT_CHECKS}  after NTP address change
    Print Step Text                      38  Check PM File  automatic=${True}
    Run Keyword And Continue On Failure      PmCommon.Check Pm File  interval=${MEAS_INTERVAL}  upload_interval=${UPLOAD_INTERVAL}
    Run Keyword And Continue On Failure      ALARMS.Add Expected Alarm To Allowed
    Print Step Text                      39  Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure      Common Postconditions

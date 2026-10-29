*** Settings ***
Documentation
  ...  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  This test case checking and verifies below SFP counters
  ...  - M40005 SFP temperature monitoring counters:
  ...    M40005C2  M40005C3  M40005C4  M40005C5  M40005C6
  ...  - M40013 Power SFP Power Monitoring counters:
  ...    M40013C0  M40013C1  M40013C2  M40013C3  M40013C4  M40013C5  M40013C6  M40013C7  M40013C8  M40013C9  M40013C11
  ...  - M40027 Combined SFP PM Counter for ORAN RMOD
  ...    M40027C1  M40027C2  M40027C3  M40027C4  M40027C5  M40027C6  M40027C7  M40027C8  M40027C9  M40027C10
  ...    M40027C11  M40027C12  M40027C13  M40027C14  M40027C15  M40027C16  M40027C17  M40027C18  M40027C19  M40027C20
  ...
  ...  To activate collectiong counters is needed set below parameters with choosen interval,
  ...  - M40005: mtSBTSSfpRMOD
  ...  - M40013: mtSbtsSfpRmodLane
  ...  - M40027: mtSBTSSfpSMOD
  ...  Interval can be set in Test Variable -> INTERVAL, default vaule is set to 5min
  ...  Available intervals: 5min,15min,30min,60min,360min,720min,1440min
  ...
  ...  If in configuration isn't ORAN RMOD counter M40027 will not be checked
  ...
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 20.08.2025 - Initial creation
  ...  - 30.10.2025 - additional waiting time https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-49387
  ...

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../Resources/Robot/PM.robot

*** Variables ***
${INTERVAL}  5min  # for counters gathering. Available intervals: 5min,15min,30min,60min,360min,720min,1440min


*** Keywords ***
TC__PM_SFP_Counter_Collection_and_Display
    Set Tags  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=PM_SFP_Counter_Collection_and_Display.robot will be executed
    ...  style=ONGOING
    Step 1: Preparing Variables For SFP Counter Collection and Display
    Step 2: Enable SFP Counters Monitoring
    Step 3: Collecting And Checking Counters
    Step 4: Disable SFP Counters Monitoring

    [Teardown]  Common Test Teardown

Step 1: Preparing Variables For SFP Counter Collection and Display
    [Documentation]
    ...  Description:
    ...  Preparing Variables to perform test.
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 1: Preparing Variables For SFP Counter Collection and Display
    ...  style=STEP
    ...  frame=${TRUE}
    Set Test Variable  ${BTS_ID}  ${CFG['primary_node_bts_id']}
    @{sfp_rmod_temp_counters}  Create List  M40005C2  M40005C3  M40005C4  M40005C5  M40005C6
    @{sfp_rmod_lane_counters}  Create List  M40013C0  M40013C1  M40013C2  M40013C3  M40013C4  M40013C5  M40013C6  M40013C7  M40013C8  M40013C9
    ...  M40013C11
    @{sfp_rmod_oran_counters}  Create List  M40027C1  M40027C2  M40027C3  M40027C4  M40027C5  M40027C6  M40027C7  M40027C8  M40027C9  M40027C10
    ...  M40027C11  M40027C12  M40027C13  M40027C14  M40027C15  M40027C16  M40027C17  M40027C18  M40027C19  M40027C20
    Set Test Variable  ${SFP_RMOD_TEMP_COUNTERS}  ${sfp_rmod_temp_counters}
    Set Test Variable  ${SFP_RMOD_LANE_COUNTERS}  ${sfp_rmod_lane_counters}
    Set Test Variable  ${SFP_RMOD_ORAN_COUNTERS}  ${sfp_rmod_oran_counters}
    Check Interval For SFP Counter  ${INTERVAL}
    Set Test Variable  ${SFP_OBJECT}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    Check If ORAN RMOD Is On BTS

Step 2: Enable SFP Counters Monitoring
    [Documentation]
    ...  Description:
    ...  Enable counter monitoring for M40005, M40013 and M40027
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 2: Enable SFP Counters Monitoring
    ...  style=STEP
    ...  frame=${TRUE}
    Parameters Recommissioning For SFP Monitoring  ${INTERVAL}
    ${status}  Run Keyword And Return Status  STATE Check If All Cells Are OnAir  bts_id=${BTS_ID}  timeout=10
    IF  '${status}'=='False'
      Fail  Cells are not onAir after recommissioning! Feature deactivated and set test failed !
    ELSE
      Logging With Timestamp  message=All cells are onAir !
    END

Step 3: Collecting And Checking Counters
    [Documentation]
    ...  Description:
    ...  Collect and verify if all the values of the counters are in the range
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 3: Collecting And Checking Counters
    ...  style=STEP
    ...  frame=${TRUE}
    ${interval_number}  Remove String  ${INTERVAL}  min
    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${interval_number}  2
    Logging With Timestamp
    ...  message=Waiting for ${time_to_sleep} minutes for next measurement interval ! \nVerdict will be released at *${time_to_verdict}* !
    ...  style=ONGOING
    Sleep  ${time_to_sleep} minutes
    Verify Counter And Return Length  counters_name=${SFP_RMOD_TEMP_COUNTERS}  min_range=-100  max_range=2000  bts_id=${BTS_ID}
    Verify Counter And Return Length  counters_name=${SFP_RMOD_LANE_COUNTERS}  min_range=-100  max_range=2000  bts_id=${BTS_ID}
    IF  ${ORAN_RMOD_EXIST}
      Verify Counter And Return Length  counters_name=${SFP_RMOD_ORAN_COUNTERS}  min_range=-100  max_range=4000  bts_id=${BTS_ID}
    END

Step 4: Disable SFP Counters Monitoring
    [Documentation]
    ...  Description:
    ...  Disable counter monitoring for M40005, M40013 and M40027
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 4: Disable SFP Counters Monitoring
    ...  style=STEP
    ...  frame=${TRUE}
    Parameters Recommissioning For SFP Monitoring  disabled
    ${status}  Run Keyword And Return Status  STATE Check If All Cells Are OnAir  bts_id=${BTS_ID}  timeout=10
    IF  '${status}'=='False'
      Fail  Cells are not onAir after recommissioning! Feature deactivated and set test failed !
    ELSE
      Logging With Timestamp  message=All cells are onAir !
    END

Check Interval For SFP Counter
    [Arguments]  ${int}
    @{available_intervals}=  Create List  5min  15min  30min  60min  360min  720min  1440min
    ${interval_status}=  Run Keyword And Return Status  List Should Contain Value  ${available_intervals}  ${int}
    Set Test Variable  ${interval_status_teardown}  ${interval_status}
    IF  ${interval_status}==False
      Fail  Given interval ${int} does't meet condition. Allowed values 5min 15min 30min 60min 360min 720min 1440min.
    ELSE
      Logging With Timestamp  message=Given interval ${int} is correct.
    END

Parameters Recommissioning For SFP Monitoring
    [Arguments]  ${interval}
    admin.Create Delta
    admin.Append Parameter Update To Delta  ${SFP_OBJECT}  mtSBTSSfpRMOD  ${interval}
    admin.Append Parameter Update To Delta  ${SFP_OBJECT}  mtSbtsSfpRmodLane  ${interval}
    IF  ${ORAN_RMOD_EXIST}  admin.Append Parameter Update To Delta  ${SFP_OBJECT}  mtSBTSSfpSMOD  ${interval}
    IF  ${ORAN_RMOD_EXIST}  admin.Append Parameter Update To Delta  ${SFP_OBJECT}  miOranTrxStats  ${interval}
    Logging With Timestamp  message=Updating parameters for SFP monitoring under ${SFP_OBJECT} to ${interval} ...
    ${delta}  admin.Get Delta
    admin.Perform Delta Recommissioning  ${delta}  skip_parameter_relation_errors=True  connection=${BTS_ID}
    admin.Remove Delta

Check If ORAN RMOD Is On BTS
    ${rf_sn_list}  Get From Dictionary  ${CFG['NODES']['${BTS_ID}']}  scf_hw_fr_list
    ${oran_rmod_exist}  Set Variable  ${EMPTY}
    FOR  ${rf_sn}  IN  @{rf_sn_list}
      ${oran_rmod_exist}  Set Variable If  '${CFG['RF_INFO']['${rf_sn}']['scf_release_code']}'=='RRH-ORAN'  ${TRUE}  ${FALSE}
      Exit For Loop If  '${CFG['RF_INFO']['${rf_sn}']['scf_release_code']}'=='RRH-ORAN'
    END
    Set Test Variable  ${ORAN_RMOD_EXIST}  ${oran_rmod_exist}
    IF  ${ORAN_RMOD_EXIST}
      Logging With Timestamp  message=ORAN RMOD Is On BTS. Counter M40027 will be collected.
    ELSE
      Logging With Timestamp  message=ORAN RMOD Is NOT On BTS. Counter M40027 will NOT be collected !!!
    END

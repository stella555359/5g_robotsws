*** Settings ***
Documentation
  ...  The purpose of this case is to verify the situation when the BTS received information about [Q]SFP Transceiver Temp Too Low
  ...  from Radio Unit and the operator is informed about [Q]SFP Transceiver Temp Too Low on Radio Unit by an alarm in Admin.
  ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-31002
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  The purpose of this case is to verify the situation when the BTS received information about [Q]SFP Transceiver Temp Too Low
  ...  from Radio Unit and the operator is informed about [Q]SFP Transceiver Temp Too Low on Radio Unit by an alarm in Admin.
  ...  TC raises fault 4658 with severity Critical or Major. ALarm should be visible in Active Alarms.
  ...
  ...  IMPORTANT:
  ...  If you use more than 1 cablink to connect Radio Unit,  data cablink must be useful. If an additional cablink will be configured as dummy
  ...  test case won't be work correctly!
  ...
  ...  TC works with RU families: 5.1, 6.2, 8 - tested on AHFB, AWHQN, AXEGHA.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 10.09.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-31002 - Initial creation
  ...  - 11.03.2026 - Add Major fault support

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  SFP_Monitoring.resource

*** Variables ***

${RMOD_SN}    #RU serial number

*** Keywords ***
TC__FM_SFP_Fault_4658_EFaultId_SfpWorkingTempTooLowAl

    Set Tags
    ...    OWNER-lukasz.wystup@nokia.com
    ...    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-lukasz.wystup@nokia.com
    ...    FEATURE-CB013212

    Common Test Setup
    Step1: Preconditions For SFP Monitoring
    Step2: Set actTransceiverAlarmMonitoring To Off
    Step3: Check Alarm SFP Transceiver Temperature Too Low
    [Teardown]  Teardown_FM_SFP_Fault_4658_EFaultId_SfpWorkingTempTooLowAl

Step3: Check Alarm SFP Transceiver Temperature Too Low
    Logging With Timestamp
    ...  message=Step3: Check Alarm SFP Transceiver Temperature Too Low
    ...  style=STEP
    ...  frame=${TRUE}

    ${sfp_linkmode_dict}  ${cablink_distname}  SFP_Monitoring.Get SFP Links Type By Radio Module  ${RMOD_SN}
    Logging With Timestamp  Check alarm SFP transceiver temperature to low
    Check alarm SFP Transceiver temperature too low  Critical  ${sfp_linkmode_dict}

Check alarm SFP Transceiver temperature too low
    [Arguments]  ${severity}  ${sfp_linkmode_dict}
    [Documentation]
    ...  Description:
    ...  Keyword simulates and verifies the activation and clearance of fault 4658 (SFP Transceiver temperature too low)
    ...  for each SFP in the provided dictionary.
    ...  It checks alarm status in both the system and IMS (if applicable), and ensures all cells return to OnAir state after fault recovery.
    ...
    ...  Arguments:
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument           | Man.  | Description                                                                                   |
    ...  +====================+=======+===============================================================================================+
    ...  | severity           | Yes   | Severity level of the fault to be simulated ('Minor' or 'Critical').                          |
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | sfp_linkmode_dict  | Yes   | Dictionary of SFP identifiers to link mode types.                                             |
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...  Usage:
    ...  Check alarm SFP Transceiver temperature too low    severity=Minor    sfp_linkmode_dict=${sfp_linkmode_dict}
    ...
    ...  Author: lukasz.wystup@nokia.com
    ...  Maintainer: lukasz.wystup@nokia.com

    FOR  ${sfp}  IN  @{sfp_linkmode_dict}
      Logging With Timestamp  Generate fault 4658 on SFP_R-${sfp}
      ${BTS_timestamp}  SSH Get BTS timestamp  bts_id=${BTS_ID}
      IF  "${severity}"=="Minor"  FM Set Start Timestamp In IMS For RD Fault
      radio.Generate Fault  fault_id=4658  sfp_id=${sfp}  severity=${severity}  ru_serial_number=${RMOD_SN}
      Sleep  10s

      IF  "${severity}"=="Minor"  FM Check Active Fault In IMS For RD Fault  fault_id=4658  severity=Minor  bts_id=${BTS_ID}
      ${severity}  SFP Low Temp Alarm Check  ${severity}  ${sfp}
      Logging With Timestamp  Checking FID 4658 SFP Transceiver temperature too low with severity ${severity} is active.
      ${4658_active}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4658  severity=${severity}  timeout=120  connection=${BTS_ID}
      IF  ${4658_active} and "${severity}"=="Critical" or "${PRECOND_FOR_CNI}"=="False"
        Logging With Timestamp  Active ${severity} SFP Transceiver Temperature Alarm.
      ELSE IF  ${4658_active}==False and "${severity}"=="Minor" and ${PRECOND_FOR_CNI}
        Logging With Timestamp  Active ${severity} SFP Transceiver Temperature Alarm in IMS.
      ELSE
        Run Keyword And Continue On Failure  Fail  Alarm SFP Transceiver temperature not active!
      END

      Logging With Timestamp  Clear fault 4658 on SFP_R-${sfp} with severity ${severity}
      IF  "${severity}"=="Minor"  FM Set Start Timestamp In IMS For RD Fault
      radio.Recover Fault  fault_id=4658  sfp_id=${sfp}  severity=${severity}  ru_serial_number=${RMOD_SN}
      Sleep  30s
      Logging With Timestamp  Waiting for clear of fault 4658!
      ${cells_status}  Run Keyword And Return Status  STATE Check If All Cells Are OnAir  ${BTS_ID}  timeout=120
      IF  '${cells_status}'=='True'
        Logging With Timestamp  All cells are onAir!
      ELSE
        Fail  Cells are not onAir!
        Logging With Timestamp
        ...  msg=Cells are not onAir!
        ...  style=FAIL
      END

      ${4658_inactive}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=4658  severity=${severity}  connection=${BTS_ID}
      IF  "${severity}"=="Minor"  FM Check Removed Active Fault In IMS For RD Fault  bts_id=${BTS_ID}
      IF  ${4658_inactive}==True
        Logging With Timestamp  InActive alarm 4658 SFP Transceiver temperature too low with severity ${severity}.
      ELSE
        Run Keyword And Continue On Failure  Fail  Fault 4658 is still active after reduce temperature around SFP.
        Logging With Timestamp
        ...  msg=Fault 4658 is still active after reduce temperature around SFP.
        ...  style=FAIL
      END

      ${fault_list}  Create List  faultId=4658, ${BTS_ID}
      FM Find History Fault And Add To Allowed
      ...  history_fault_list=${fault_list}
      ...  timeslot_start=${BTS_timestamp}
      ...  bts_id=${BTS_ID}
      Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=4003  connection=${BTS_ID}
    END

SFP Low Temp Alarm Check
    [Arguments]  ${severity}  ${sfp}
    [Documentation]
    ...  Description:
    ...  Keyword verifies that fault 4658 (SFP Transceiver temperature too low) is active on the correct SFP and checks the degraded cell status
    ...  based on severity.
    ...
    ...  Arguments:
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument           | Man.  | Description                                                                                   |
    ...  +====================+=======+===============================================================================================+
    ...  | severity           | Yes   | Severity level of the fault ('Minor' or 'Critical').                                          |
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | sfp               | Yes   | Identifier of the SFP to be checked.                                                          |
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Return:
    ...  +------------------------------------------+---------------------------------------------------------------------------------+
    ...  | Return Value                             | Description                                                                     |
    ...  +==========================================+=================================================================================+
    ...  | severity                                 | SFP fault severity.                                                             |
    ...  +------------------------------------------+---------------------------------------------------------------------------------+
    ...
    ...  Author: lukasz.wystup@nokia.com
    ...  Maintainer: lukasz.wystup@nokia.com

    @{alarms}  admin.Get Active Alarms  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{alarms}
      Continue For Loop If  '4658' not in '${alarm['additionalFaultID']}'
      ${alarmingObjectIds}  Set Variable  ${alarm['alarmingObjectIds']}
      ${degraded_cells}  Set Variable  ${alarm['degradedCells']}
      ${severity}  Set Variable  ${alarm['severity']}
    END
    ${alarming_object_sfp}  Set Variable  ${RMOD_DISTNAME_ID}/SFP_R-${sfp}
    IF  '${alarming_object_sfp}'=='${alarmingObjectIds[0]['internal']}'
      Logging With Timestamp  Active fault 4658 on proper SFP_R-${sfp}.
    ELSE
      Run Keyword And Continue On Failure  Fail  Fault 4658 is active on incorrect SPF: ${alarmingObjectIds[0]['internal']}
      Logging With Timestamp
      ...  msg=Fault 4658 is active on incorrect SPF: ${alarmingObjectIds[0]['internal']}
      ...  style=FAIL
    END

    IF  '${severity}'=='Critical' and 'Faulty' not in $degraded_cells
      Run Keyword And Continue On Failure  Fail  Fault 4658 with severity ${severity} is active, but no faulty cell on radio module, only degraded.
      Logging With Timestamp
      ...  msg=Fault 4658 with severity ${severity} is active, but no faulty cell on radio module, only degraded.
      ...  style=FAIL
    ELSE IF  '${severity}'=='Major' and 'Degraded' not in $degraded_cells
      Run Keyword And Continue On Failure  Fail  Fault 4658 with severity ${severity} is active, but no degraded cell on radio module.
      Logging With Timestamp
      ...  msg=Fault 4658 with severity ${severity} is active, but no degraded cell on radio module.
      ...  style=FAIL
    ELSE IF  '${severity}'=='Minor' and '${degraded_cells}'!='None'
      Run Keyword And Continue On Failure  Fail  Fault 4658 with severity ${severity} is active and some cell on radio module are degraded.
      Logging With Timestamp
      ...  msg=Fault 4658 with severity ${severity} is active and some cell on radio module are degraded.
      ...  style=FAIL
    END
    [Return]  ${severity}

Teardown_FM_SFP_Fault_4658_EFaultId_SfpWorkingTempTooLowAl
    IF  ${RESTORE_CONFIG}
      Run Keyword And Continue On Failure  SFP_Monitoring.Restore Reference Configuration  ${REFERENCE_DICT}  ${object_variable_acttransceiver}
    END
    Common Test Teardown

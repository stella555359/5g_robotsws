*** Settings ***
Documentation
  ...  The purpose of this case is to verify the situation when the BTS received information about [Q]SFP Transceiver Temp Too High
  ...  from Radio Unit and the operator is informed about [Q]SFP Transceiver Temp Too High on Radio Unit by an alarm in Admin.
  ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-44451
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  The purpose of this case is to verify the situation when the BTS received information about [Q]SFP Transceiver Temp Too High
  ...  from Radio Unit and the operator is informed about [Q]SFP Transceiver Temp Too High on Radio Unit by an alarm in Admin.
  ...  TC raises fault 4698 with severity Major or Minor. ALarm should be visible in Active Alarms.
  ...
  ...  IMPORTANT:
  ...  If you use more than 1 cablink to connect Radio Unit, data cablink must be useful. If an additional cablink will be configured as dummy
  ...  test case won't be work correctly!
  ...
  ...  TC works with RU families: 5.1, 6.2, 8 - tested on AHFB, AWHQN, AXEGHA.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 18.11.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-35083 - Initial creation
  ...  - 29.01.2026 - adding support for ORAN radios

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  SFP_Monitoring.resource

*** Variables ***

${RMOD_SN}    #RU serial number

*** Keywords ***
TC__FM_SFP_Fault_4698_SFP_transceiver_temperature_too_high_on_RU

    Set Tags
    ...    OWNER-lukasz.wystup@nokia.com
    ...    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-lukasz.wystup@nokia.com
    ...    FEATURE-CB009226

    Common Test Setup
    Step1: Preconditions For SFP Monitoring
    Step2: Set actTransceiverAlarmMonitoring To Transceiver Alarms And Warnings
    Step3: Check Alarm SFP Transceiver Temperature Too High
    [Teardown]  Teardown_FM_SFP_Fault_4698_SFP_transceiver_temperature_too_high_on_RU

Step3: Check Alarm SFP Transceiver Temperature Too High
    Logging With Timestamp
    ...  message=Step3: Check Alarm SFP Transceiver Temperature Too High
    ...  style=STEP
    ...  frame=${TRUE}

    ${sfp_linkmode_dict}  ${cablink_distname}  SFP_Monitoring.Get SFP Links Type By Radio Module  rmod_sn=${RMOD_SN}
    Logging With Timestamp  Check alarm SFP transceiver temperature with severity Major
    Check Alarm SFP Transceiver Temperature Too High  severity=Major  sfp_linkmode_dict=${sfp_linkmode_dict}
    Logging With Timestamp  Check alarm SFP transceiver temperature with severity Minor
    Check Alarm SFP Transceiver Temperature Too High  severity=Minor  sfp_linkmode_dict=${sfp_linkmode_dict}

Check Alarm SFP Transceiver Temperature Too High
    [Arguments]  ${severity}  ${sfp_linkmode_dict}
    [Documentation]
    ...  Description:
    ...  Keyword simulates and verifies the activation and clearance of fault 4698 (SFP Transceiver temperature too high)
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
    ...  Check Alarm SFP Transceiver Temperature Too High  severity=Minor  sfp_linkmode_dict=${sfp_linkmode_dict}
    ...
    ...  Author: lukasz.wystup@nokia.com
    ...  Maintainer: lukasz.wystup@nokia.com

    FOR  ${sfp}  IN  @{sfp_linkmode_dict}
      Logging With Timestamp  Generate fault 4698 on SFP_R-${sfp} with severity ${severity}
      ${BTS_timestamp}  SSH Get BTS timestamp  bts_id=${BTS_ID}
      IF  "${severity}"=="Minor"  FM Set Start Timestamp In IMS For RD Fault
      radio.Generate Fault  fault_id=4698  sfp_id=${sfp}  severity=${severity}  ru_serial_number=${RMOD_SN}
      Sleep    10s

      Logging With Timestamp  Checking FID 4698 SFP Transceiver temperature too high with severity ${severity} is active.
      ${4698_active}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4698  severity=${severity}  timeout=120  connection=${BTS_ID}
      IF  "${severity}"=="Minor"  FM Check Active Fault In IMS For RD Fault  fault_id=4698  severity=Minor  bts_id=${BTS_ID}
      IF  ${PRECOND_FOR_CNI} and "${severity}"=="Major"
        SFP High Temp Alarm Check  ${severity}  ${sfp}
      ELSE IF  "${PRECOND_FOR_CNI}"=="False"
        SFP High Temp Alarm Check  ${severity}  ${sfp}
      END
      IF  ${4698_active} and "${severity}"=="Major" or "${PRECOND_FOR_CNI}"=="False"
        Logging With Timestamp  Active ${severity} SFP Transceiver Temperature Alarm.
      ELSE IF  ${4698_active}==False and "${severity}"=="Minor" and ${PRECOND_FOR_CNI}
        Logging With Timestamp  Active ${severity} SFP Transceiver Temperature Alarm in IMS.
      ELSE
        Run Keyword And Continue On Failure  Fail  Alarm SFP Transceiver temperature not active!
      END

      Logging With Timestamp  Clear fault 4698 on SFP_R-${sfp} with severity ${severity}
      IF  "${severity}"=="Minor"  FM Set Start Timestamp In IMS For RD Fault
      radio.Recover Fault  fault_id=4698  sfp_id=${sfp}  severity=${severity}  ru_serial_number=${RMOD_SN}
      Sleep    30s
      Logging With Timestamp  Waiting for clear of fault 4698!
      ${cells_status}  Run Keyword And Return Status  STATE Check If All Cells Are OnAir  ${BTS_ID}  timeout=120
      IF  '${cells_status}'=='True'
        Logging With Timestamp  All cells are onAir!
      ELSE
        Fail  Cells are not onAir!
      END

      ${4698_active}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4698  severity=${severity}  timeout=120  connection=${BTS_ID}
      IF  ${PRECOND_FOR_CNI} or '${cfg.RF_INFO['${RMOD_SN}']['scf_release_code']}'=='RRH-ORAN'  Sleep  120s
      IF  "${severity}"=="Minor"  FM Check Removed Active Fault In IMS For RD Fault  bts_id=${BTS_ID}
      IF  ${4698_active}==False
        Logging With Timestamp  InActive alarm 4698 SFP Transceiver temperature too high with severity ${severity}.
      ELSE
        Run Keyword And Continue On Failure  Fail  Fault 4698 is still active after reduce temperature around SFP.
      END

      ${fault_list}  Create List  faultId=4698, ${BTS_ID}
      FM Find History Fault And Add To Allowed
      ...  ${fault_list}
      ...  ${BTS_timestamp}
      ...  ${BTS_ID}
    END

SFP High Temp Alarm Check
    [Arguments]  ${severity}  ${sfp}
    [Documentation]
    ...  Description:
    ...  Keyword verifies that fault 4698 (SFP Transceiver temperature too high) is active on the correct SFP and checks the degraded cell status
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
    ...
    ...  Author: lukasz.wystup@nokia.com
    ...  Maintainer: lukasz.wystup@nokia.com

    @{alarms}    admin.Get Active Alarms  severity=${severity}  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{alarms}
      Continue For Loop If  '4698' not in '${alarm['additionalFaultID']}'
      ${alarmingObjectIds}  Set Variable  ${alarm['alarmingObjectIds']}
      ${degraded_cells}  Set Variable  ${alarm['degradedCells']}
    END
    ${alarming_object_sfp}  Set Variable  ${RMOD_DISTNAME_ID}/SFP_R-${sfp}
    IF  '${alarming_object_sfp}'=='${alarmingObjectIds[0]['internal']}'
      Logging With Timestamp  Active fault 4698 on proper SFP_R-${sfp}.
    ELSE
      Run Keyword And Continue On Failure  Fail  Fault 4698 is active on incorrect SPF: ${alarmingObjectIds[0]['internal']}
    END
    IF  '${severity}'=='Critical' and '${degraded_cells}'=='None'
      Run Keyword And Continue On Failure  Fail  Fault 4698 with severity ${severity} is active but no degraded cells on radio module.
    ELSE IF  '${severity}'=='Minor' and '${degraded_cells}'!='None'
      Run Keyword And Continue On Failure  Fail  Fault 4698 with severity ${severity} is active and some cell on radio module are degraded.
    END

Teardown_FM_SFP_Fault_4698_SFP_transceiver_temperature_too_high_on_RU
    IF  ${RESTORE_CONFIG}
      Run Keyword And Continue On Failure  SFP_Monitoring.Restore Reference Configuration  ${REFERENCE_DICT}  ${object_variable_acttransceiver}
    END
    Common Test Teardown

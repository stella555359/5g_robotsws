*** Settings ***
Documentation
...  The purpose of this case is to verify the situation when the BTS received information about [Q]SFP Transceiver Temp Too High
...  from Radio Unit and the operator is informed about [Q]SFP Transceiver Temp Too High on Radio Unit by an alarm in Admin.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../resources/ca_BSRF_SFP_Monitoring.robot


*** Variables ***

${RMOD_SN}    #RU serial number
${node}    default

*** Keywords ***
TC__SiSo_FM_FID_4698_SFP_transceiver_temperature_too_high_on_RU
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-44451
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this case is to verify the situation when the BTS received information about [Q]SFP Transceiver Temp Too High
    ...  from Radio Unit and the operator is informed about [Q]SFP Transceiver Temp Too High on Radio Unit by an alarm in Admin.
    ...  TC raise fault 4698 with severity Major or Minor. ALarm should be visible in Active Alarms.
    ...
    ...  IMPORTANT:
    ...  If you use more than 1 cablink to connect Radio Unit,  data cablink must be useful. If additional cablink will be configure as dummy
    ...  test case won't be work correct!
    ...
    ...  TC works with RU families: 5.1*, tested on AHFB.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 01.02.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-44451 - Initial creation

    Set Tags
    ...    OWNER-lukasz.wystup@nokia.com
    ...    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-lukasz.wystup@nokia.com
    ...    FEATURE-CB009226

    step1: Preconditions
    step2: Set actTransceiverAlarmMonitoring to Transceiver alarms and warnings
    step3: Check alarm SFP transceiver temperature too high
    Restore Reference Configuration  ${REFERENCE_DICT}  ${object_variable_acttransceiver}

step1: Preconditions

    Log to console  --------------------
    Log to console  step1: Preconditions
    Log to console  --------------------${\n}

    Run Keyword If  '${RMOD_SN}'=='${EMPTY}'
    ...  Fail  Variable RMOD_SN cannot be empty !
    Verify Serial Number  ${RMOD_SN}
    Log To Console  RMOD with SN -> ${RMOD_SN} found in HW Configuration

    ${rmods_info}  admin.Get FRM  60  ${node}
    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${RMOD_SN}' not in '${rmod['serialNumber']}'
        Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['internal']}
    END
    Set Test Variable  ${RESTORE_CONFIG}  ${FALSE}
    ${bts_obj}  admin.Get parameters for all  BTS
    ${bts_id}  Convert to string  ${bts_obj[0].btsId}
    Set Test Variable  ${OBJECT_VARIABLE_ACTTRANSCEIVER}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${param_value_dict}  Get Value For ActTransceiverAlarmMonitoring Parameter  ${object_variable_acttransceiver}
    Set Test Variable   ${REFERENCE_DICT}  ${param_value_dict}
    Preconditions For CNI-127210

step2: Set actTransceiverAlarmMonitoring to Transceiver alarms and warnings
    Log to console  ${\n}---------------------------
    Log to console  step2: Set actTransceiverAlarmMonitoring to Transceiver alarms and warnings
    Log to console  ---------------------------${\n}

    Set Test Variable  ${RESTORE_CONFIG}  ${TRUE}
    Run Keyword If  '${REFERENCE_DICT['actTransceiverAlarmMonitoring'].lower()}' == 'transceiver alarms and warnings'
    ...  Log To Console  Transceiver alarms and warnings monitoring feature is already activated!\n
    ...  ELSE
    ...  Run Keywords  Log To Console  Transceiver alarms and warnings monitoring feature is not active, activating ongoing...\n
    ...  AND  admin.Perform Parameter Recommissioning
    ...  ${object_variable_acttransceiver}  actTransceiverAlarmMonitoring  update  Transceiver alarms and warnings
    ...  AND  Check If All Cells Are OnAir

step3: Check alarm SFP transceiver temperature too high
    Log to console  ${\n}---------------------------
    Log to console  step3: Check alarm SFP transceiver temperature too high
    Log to console  ---------------------------${\n}

    ${sfp_linkmode_dict}  ${cablink_distname}  ca_BSRF_SFP_Monitoring.Get SFP Links Type By Radio Module  ${RMOD_SN}
    Log to console  Check alarm SFP transceiver temperature with severity Major
    Check alarm SFP Transceiver temperature too high  Major  ${sfp_linkmode_dict}

    Log to console  Check alarm SFP transceiver temperature with severity Minor
    Check alarm SFP Transceiver temperature too high  Minor  ${sfp_linkmode_dict}

Check alarm SFP Transceiver temperature too high
    [Arguments]  ${severity}  ${sfp_linkmode_dict}
    FOR  ${sfp}  IN  @{sfp_linkmode_dict}
        Log To Console  Generate fault 4698 on SFP_R-${sfp} with severity ${severity}
        Run Keyword If  "${severity}"=="Minor"  Set Start Timestamp In IMS For CNI-127210
        radio.Generate Fault  fault_id=4698  sfp_id=${sfp}  severity=${severity}  ru_serial_number=${RMOD_SN}
        Sleep    10s

        Log to console  Checking FID 4698 SFP Transceiver temperature too high with severity ${severity} is active.
        ${4698_active}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4698  severity=${severity}  timeout=120
        Run Keyword If  "${severity}"=="Minor"  Check Active Fault In IMS For CNI-127210  fault_id=4698  severity=Minor
        Run Keyword If  ${PRECOND_FOR_CNI} and "${severity}"=="Major"  SFP alarm check  ${severity}  ${sfp}
        ...  ELSE IF  "${PRECOND_FOR_CNI}"=="False"  SFP alarm check  ${severity}  ${sfp}
        Run Keyword If  ${4698_active} and "${severity}"=="Major" or "${PRECOND_FOR_CNI}"=="False"
        ...  Log to console  ${\n}Active ${severity} SFP Transceiver Temperature Alarm.
        ...  ELSE IF  ${4698_active}==False and "${severity}"=="Minor" and ${PRECOND_FOR_CNI}
        ...  Log to console  ${\n}Active ${severity} SFP Transceiver Temperature Alarm in IMS.
        ...  ELSE  Run Keyword And Continue On Failure
        ...  Fail  Alarm SFP Transceiver temperature not active!

        Log To Console  Clear fault 4698 on SFP_R-${sfp} with severity ${severity}
        Run Keyword If  "${severity}"=="Minor"  Set Start Timestamp In IMS For CNI-127210
        radio.Recover Fault  fault_id=4698  sfp_id=${sfp}  severity=${severity}  ru_serial_number=${RMOD_SN}
        Sleep    30s
        Log to console  Waiting for clear of fault 4698!${\n}
        ${cells_status}  Run Keyword And Return Status  Check If All Cells And Modules Are OnAir  timeout=120
        Run Keyword If  '${cells_status}'=='True'
        ...  Log To Console  All cells are onAir!
        ...  ELSE  Fail  Cells are not onAir!

        ${4698_active}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4698  severity=${severity}  timeout=120
        Run Keyword If  ${PRECOND_FOR_CNI}  Sleep  120s
        Run Keyword If  "${severity}"=="Minor"  Check Removed Active Fault In IMS For CNI-127210
        Run Keyword If  ${4698_active}==False
        ...  Log to console  ${\n}InActive alarm 4698 SFP Transceiver temperature too high with severity ${severity}.
        ...  ELSE  Run Keyword And Continue On Failure
        ...  Fail  Fault 4698 is still active after reduce temperature around SFP.
    END

SFP alarm check
    [Arguments]  ${severity}  ${sfp}
    @{alarms}    admin.Get Active Alarms  severity=${severity}
    FOR  ${alarm}  IN  @{alarms}
        Continue For Loop If  '4698' not in '${alarm['additionalFaultID']}'
        ${alarmingObjectIds}  Set Variable  ${alarm['alarmingObjectIds']}
        ${degraded_cells}  Set Variable  ${alarm['degradedCells']}
    END
    ${alarming_object_sfp}  Set Variable  ${RMOD_DISTNAME_ID}/SFP_R-${sfp}
    Run Keyword If  '${alarming_object_sfp}'=='${alarmingObjectIds[0]['internal']}'
    ...  Log to console  ${\n}Active fault 4698 on proper SFP_R-${sfp}.
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault 4698 is active on incorrect SPF: ${alarmingObjectIds[0]['internal']}
    Run Keyword If  '${severity}'=='Major' and '${degraded_cells}'=='None'
    ...  Run Keyword And Continue On Failure
    ...  Fail  Fault 4698 with severity ${severity} is active but no degraded cells on radio module.
    ...  ELSE IF  '${severity}'=='Minor' and '${degraded_cells}'!='None'
    ...  Run Keyword And Continue On Failure
    ...  Fail  Fault 4698 with severity ${severity} is active and some cell on radio module are degraded.


TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Run Keyword If  ${RESTORE_CONFIG}  Restore Reference Configuration
    ...  ${REFERENCE_DICT}  ${object_variable_acttransceiver}
    Common Test Teardown

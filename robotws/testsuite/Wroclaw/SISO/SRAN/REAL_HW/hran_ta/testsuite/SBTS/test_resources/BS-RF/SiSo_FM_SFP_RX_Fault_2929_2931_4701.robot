*** Settings ***
Documentation
...  The purpose of this Test Case is to verify the situation when the BTS received information about [Q]SFP Transceiver RX LOS from Radio Unit

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../resources/ca_BSRF_SFP_Monitoring.robot
Library    taf.sbts.oam.coam.admin  WITH NAME  admin

*** Variables ***
${RMOD_SN}        # RU serial number
${node}  default
${FID2929_PRIMARY_RESET_TIMEOUT}  120
*** Keywords ***

TC__SiSo_FM_SFP_RX_Fault_2929_2931_4701
    [Documentation]
    ...  [CASE-LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-44452
    ...  *****************
    ...  Basic Information
    ...  *****************
    ...  The purpose of this case is:
    ...  1. To verify the situation when the BTS received information about [Q]SFP Transceiver RX LOS from Radio Unit and the operator
    ...     is informed about [Q]SFP Transceiver RX LOS on Radio Unit by an alarm in BTS Element Manager or NMS.
    ...     BTS reports FID 2929 in Info Model Viewer(/MRBTS-1/RAT-1/FRI-4/FAULT_NOTIF-):- FID_2929:EFaultId_RfSfpRxLosAl with severity
    ...     Major or Minor and in RU fault history EFaultId_LossOfSignalSecondary (1160)
    ...  2. To verify when the BTS received information about CPRI link Loss of sync from Radio Unit and the operator is informed
    ...     about CPRI RX Loss of sync on Radio Unit by an alarm in BTS Element Manager or NMS.
    ...     BTS reports FID 2931 in Info Model Viewer(/MRBTS-1/RAT-1/FRI-4/FAULT_NOTIF-):- FID_2931: EFaultId_RfCpriLossOfSyncAl with severity
    ...    Major or Minor
    ...     and in RU fault history EFaultId_LossOfSynchronizationSecondary (1161)
    ...  3. To verify the situation when the BTS received information about RX Power on [Q]SFP's LANE too low from Radio Unit
    ...     and the operator is informed about RX Power on [Q]SFP's LANE too low on Radio Unit by an alarm in BTS Element Manager or NMS.
    ...     BTS shall report Rx Power too low alarms to WebEM. FID:4701 RX power too low is visible in WebEM with Minor or Major severity
    ...  *****************
    ...  IMPORTANT:
    ...  You need to use 2 cablinks to connect Radio Unit and data cablink must be useful. If additional cablink will be configure as dummy
    ...  test case won't be working correctly!
    ...
    ...  TC works with RU families: 5.1*, tested on AHEGC.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.02.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-44452 - Initial creation

    ...    **Author:**      szymon.przybylak@nokia.com
    ...    **Maintainer:**  szymon.przybylak@nokia.com
    Set Tags
    ...    OWNER-szymon.przybylak@nokia.com
    ...    AUTHOR-szymon.przybylak@nokia.com
    ...    MAINTAINER-szymon.przybylak@nokia.com
    ...    FEATURE-CB009226

    step1: Preconditions
    step2: Generate And Recover Fault 2929 And 2931 On Secondary Link
    step3: Generate And Recover Fault 2929 And 2931 On Primary Link
    step4: Generate And Recover Fault 4701 Major On Primary Link
   # step5: Generate And Recover Fault 4701 Minor On Primary Link
    step6: Generate And Recover Fault 4701 Major On Secondary Link
   # step7: Generate Fault 4701 Minor On Secondary Link
    step8: Turn Off Monitoring And Recover Fault 4701
    Restore Reference Configuration  ${REFERENCE_DICT}  ${object_variable_acttransceiver}

step1: Preconditions
    Log To Console  --------------------
    Log To Console  step1: Preconditions
    Log To Console  --------------------${\n}

    Preconditions For CNI-127210
    Set Test Variable  ${RESTORE_CONFIG}  ${FALSE}
    Run Keyword If  '${RMOD_SN}'=='${EMPTY}'
    ...  Fail  Variable RMOD_SN cannot be empty !

    ${rmods_info}  admin.Get FRM  60  ${node}
    ${newer}  Check If Current Build Is Newer Than  SBTS25R2_ENB_9999_250116_000011  alias=${node}
    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SN}'
        Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['internal']}
        IF  ${newer}
            Set Test Variable  ${RMOD_RUNTIME_DISTNAME}  ${rmod['id']['runtime']}
            Set Test Variable  ${CABLE_DN_TYPE}  runtime
        ELSE
            Set Test Variable  ${RMOD_RUNTIME_DISTNAME}  ${rmod['id']['internal']}
            Set Test Variable  ${CABLE_DN_TYPE}  internal
        END
#        Set Test Variable  ${RMOD_RUNTIME_DISTNAME}  ${rmod['id']['runtime']}
    END

    ${cells_distnames}=  Get All Cells Mapping By RMOD Id  radio_id=${RMOD_DISTNAME_ID}
    Set Test Variable  ${CELLS_DISTNAME_FROM_TESTED_RM}  ${cells_distnames}

    Run Keyword If  '${RMOD_DISTNAME_ID}'=='${NONE}'
    ...  Fail  Serial Number ${RMOD_SN} not found in HW Configuration ! Test set to Fail !
    ...  ELSE  Log To Console  RMOD with SN ${RMOD_SN} found in configuration!${\n}

    ${bts_params} =  admin.Get parameters for all  BTS  alias=${node}
    ${bts_id}  Set Variable  ${bts_params[0].btsId}

#    Set Test Variable  ${FEATCADM_OBJECT}  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    Set Test Variable  ${OBJECT_VARIABLE_ACTTRANSCEIVER}  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ${param_value_dict}  Get Value For ActTransceiverAlarmMonitoring Parameter  ${object_variable_acttransceiver}
    Set Test Variable   ${REFERENCE_DICT}  ${param_value_dict}

    ${rmod_sfps_info_dict}  ${cablink_distname_to_sfp_linkmode_dict}  ca_BSRF_SFP_Monitoring.Get SFP Links Type By Radio Module
    ...  rmod_sn=${RMOD_SN}  cable_dn_type=${CABLE_DN_TYPE}
    ${rmod_sfp_primary}  Evaluate  next((key for key, val in ${rmod_sfps_info_dict}.items() if val == 'primary'))
    ${rmod_sfp_secondary}  Evaluate  next((key for key, val in ${rmod_sfps_info_dict}.items() if val == 'secondary'))
    ${cablink_distname_secondary}  Evaluate  next((key for key, val in ${cablink_distname_to_sfp_linkmode_dict}.items() if val == 'secondary'))

    Set Test Variable  ${RMOD_SFP_PRIMARY}  ${rmod_sfp_primary}
    Set Test Variable  ${RMOD_SFP_SECONDARY}  ${rmod_sfp_secondary}
    Set Test Variable  ${RMOD_CABLINK_SECONDARY_DISTNAME}  ${cablink_distname_secondary}

    Log To Console  Activate Transceiver alarms and warnings${\n}

    Run Keyword If  '${REFERENCE_DICT['actTransceiverAlarmMonitoring'].lower()}' != 'transceiver alarms and warnings'  Set Feature To Active
    ...  ELSE  Log To Console  Transceiver alarms and warnings already set${\n}

    Log To Console  Waiting for all cells onAir!${\n}
    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !
    ...  ELSE  Fail  Cells are not onAir !

Set Feature To Active
    admin.Perform Parameter Recommissioning  dist_name=${OBJECT_VARIABLE_ACTTRANSCEIVER}  parameter=actTransceiverAlarmMonitoring
    ...  operation=update  value=Transceiver alarms and warnings  should_activate=True  alias=${node}
    Log To Console  Perform recommissioning done, set:${\n}actTransceiverAlarmMonitoring -> Transceiver alarms and warnings${\n}

step2: Generate And Recover Fault 2929 And 2931 On Secondary Link
    Log To Console  --------------------
    Log To Console  step2: Generate And Recover Fault 2929 And 2931 On Secondary Link
    Log To Console  --------------------${\n}

    Set Test Variable  ${RESTORE_CONFIG}  ${TRUE}

    radio.Generate Fault  ru_serial_number=${RMOD_SN}  fault_id=2929  sfp_id=${RMOD_SFP_SECONDARY}
    Log To Console  Waiting for raise of FaultID 2929 and 2931 in R&D !${\n}
    Sleep  3
    Query infomodel  get list //FAULT_NOTIF-*

    ${alarm_2929_status}  Query Infomodel  //FAULT_NOTIF-* is [faultId=2929, faultyObject=${RMOD_RUNTIME_DISTNAME}/SFP_R-${RMOD_SFP_SECONDARY}]
    ...  allow_negative_result=True
    ${alarm_2931_status}  Query Infomodel  //FAULT_NOTIF-* is [faultId=2931, faultyObject=${RMOD_CABLINK_SECONDARY_DISTNAME}]
    ...  allow_negative_result=True

    Run Keyword If  '${alarm_2929_status}'=='True' and '${alarm_2931_status}'=='True'
    ...  Log To Console  FaultID 2929 and 2931 RAISED in R&D!${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 2929 or 2931 NOT raised !
    ...  AND  radio.Recover Fault  fault_id=2929  ru_serial_number=${RMOD_SN}  sfp_id=${RMOD_SFP_SECONDARY}
    ...  AND  Fail  Fault 2929 or 2931 NOT raised !

    Log To Console  Checking FID 2929 in fault_history_log.txt, please wait !
    ${1160_active}  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1160
    ...  severity=major
    Run Keyword If  '${1160_active}'=='True'
    ...  Log To Console  Found --> Active Major EFaultId_LossOfSignalSecondary (1160) in fault_history_log_for_fault_1160.txt !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault EFaultId_LossOfSignalSecondary (1160) not found, please check fault_history_log_for_fault_1160.txt !

    Log To Console  ${\n}Checking FID 2931 in fault_history_log.txt, please wait !
    ${1161_active}  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1161
    ...  severity=major
    Run Keyword If  '${1161_active}'=='True'
    ...  Log To Console  Found --> Active Minor EFaultId_LossOfSynchronizationSecondary (1161) in fault_history_log_for_fault_1161.txt !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault EFaultId_LossOfSynchronizationSecondary (1161) not found, please check fault_history_log_for_fault_1161.txt !

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !
    ...  ELSE  Run Keyword And Continue On Failure  Fail  Cells are not onAir !

    Log To Console  Recover Fault 2929 And 2931 On Secondary Link
    radio.Recover Fault  ru_serial_number=${RMOD_SN}  fault_id=2929  sfp_id=${RMOD_SFP_SECONDARY}
    Log To Console  Waiting for clear of FaultID 2929 !${\n}

    Sleep  10
    ${1160_inactive}  Run Keyword And Return Status  radio.Assert Inactive Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1160
    ...  severity=major

    ${1161_inactive}  Run Keyword And Return Status  radio.Assert Inactive Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1161
    ...  severity=major
    Run Keyword If  '${1160_inactive}'=='True'
    ...  Log To Console  Found --> Inactive Major EFaultId_LossOfSynchronizationSecondary (1160) in fault_history_log_for_fault_1160.txt !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Found --> Active Minor EFaultId_LossOfSynchronizationSecondary (1160) in fault_history_log_for_fault_1161.txt !
    Run Keyword If  '${1161_inactive}'=='True'
    ...  Log To Console  Found --> Inactive Major EFaultId_LossOfSynchronizationSecondary (1161) in fault_history_log_for_fault_1161.txt !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Found --> Active Minor EFaultId_LossOfSynchronizationSecondary (1161) in fault_history_log_for_fault_1161.txt !
    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=600  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !
    ...  ELSE  Fail  Cells are not onAir !


step3: Generate And Recover Fault 2929 And 2931 On Primary Link
    Log To Console  --------------------
    Log To Console  step3: Generate And Recover Fault 2929 And 2931 On Primary Link
    Log To Console  --------------------${\n}

    radio.Generate Fault  ru_serial_number=${RMOD_SN}  fault_id=2929  sfp_id=${RMOD_SFP_PRIMARY}
    Log To Console  Waiting for radio recovery reset${\n}

    ${10_active}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=10  timeout=300  severity=Critical

    Run Keyword If  '${10_active}'=='True'
    ...  Log To Console  FaultID 10 RAISED !${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 10 NOT raised !
    ...  AND  radio.Recover Fault  fault_id=2929  ru_serial_number=${RMOD_SN}
    ...  AND  Fail  Fault 10 NOT raised !
    Log To Console  Waiting for all cells onAir!
    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}  timeout=${FID2929_PRIMARY_RESET_TIMEOUT}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !
    ...  ELSE  Fail  Cells are not onAir !

step4: Generate And Recover Fault 4701 Major On Primary Link
    Log To Console  --------------------
    Log To Console  step4: Generate Fault 4701 Major on Primary Link
    Log To Console  --------------------${\n}

    Log To Console  Generate fault 4701 with severity Major on Primary Link
    radio.Generate Fault  ru_serial_number=${RMOD_SN}  fault_id=4701  severity=major  sfp_id=${RMOD_SFP_PRIMARY}
    Log To Console  Waiting for raise of FaultID 4701 Major on Primary Link!${\n}
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4701  timeout=300  severity=Major
    ${active_alarms}=  admin.Get Active Alarms
    Log To Console  Check if at least one of cells from given RMOD is degraded
    FOR  ${alarm}  IN  @{active_alarms}
        Continue For Loop If  '${alarm['faultId']}'!='4701'
        Run Keyword If  '${alarm['degradedCells']}' == 'None'  Fail  There are no degraded cells!
        ...  ELSE  Check Degraded Cells Exists In Tested RMOD  ${alarm}
    END

    Run Keyword If  '${alarm_status}'=='True'
    ...  Log To Console  FaultID 4701 Major on Primary Link RAISED !${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  FaultID 4701 Major on Primary Link NOT raised !
    ...  AND  radio.Recover Fault  fault_id=4701  ru_serial_number=${RMOD_SN}  sfp_id=${RMOD_SFP_PRIMARY}
    ...  AND  Fail  FaultID 4701 Major on Primary Link NOT raised !

    Log To Console  Recover Fault 4701 Major On Primary Link

    radio.Recover Fault  ru_serial_number=${RMOD_SN}  fault_id=4701  sfp_id=${RMOD_SFP_PRIMARY}
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=4701  timeout=300  severity=Major
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log To Console  FaultID 4701 Major On Primary Link cleared - OK!${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 4701 Major On Primary Link is raised. Not OK !
    ...  AND  radio.Recover Fault  fault_id=4701  ru_serial_number=${RMOD_SN}  sfp_id=${RMOD_SFP_PRIMARY}
    ...  AND  Fail  Fault 4701 Major On Primary Link is raised. Not OK !
    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !
    ...  ELSE  Fail  Cells are not onAir !

step5: Generate And Recover Fault 4701 Minor On Primary Link
    Log To Console  --------------------
    Log To Console  step5: Generate And Recover Fault 4701 Minor On Primary Link
    Log To Console  --------------------${\n}

    Log To Console  Generate fault 4701 with severity Minor on Primary Link
    Set Start Timestamp In IMS For CNI-127210
    radio.Generate Fault  ru_serial_number=${RMOD_SN}  fault_id=4701  severity=minor  sfp_id=${RMOD_SFP_PRIMARY}
    Log To Console  Waiting for raise of FaultID 4701 Minor on Primary Link!${\n}
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4701  timeout=300  severity=Minor
    Check Active Fault In IMS For CNI-127210  fault_id=4701  severity=Minor
    Run Keyword If  '${alarm_status}'=='True' and "${PRECOND_FOR_CNI}"=="False"
    ...  Log To Console  FaultID 4701 Minor on Primary Link RAISED !${\n}
    ...  ELSE IF  '${alarm_status}'=='False' and ${PRECOND_FOR_CNI}
    ...  Log To Console  FaultID 4701 Minor on Primary Link RAISED !${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 4701 Minor on Primary Link NOT raised !
    ...  AND  radio.Recover Fault  fault_id=4701  ru_serial_number=${RMOD_SN}  sfp_id=${RMOD_SFP_PRIMARY}
    ...  AND  Fail  Fault 4701 Minor on Primary Link NOT raised !
    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !
    ...  ELSE  Fail  Cells are not onAir !

    Log To Console  Recover Fault 4701 Minor On Primary Link

    Set Start Timestamp In IMS For CNI-127210
    radio.Recover Fault  ru_serial_number=${RMOD_SN}  fault_id=4701  sfp_id=${RMOD_SFP_PRIMARY}
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=4701  timeout=300  severity=Minor
    Run Keyword If  ${PRECOND_FOR_CNI}  Sleep  300s
    Check Removed Active Fault In IMS For CNI-127210
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log To Console  FaultID 4701 Minor on Primary Link cleared - OK!${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 4701 Minor on Primary Link is raised. Not OK !
    ...  AND  radio.Recover Fault  fault_id=4701  ru_serial_number=${RMOD_SN}  sfp_id=${RMOD_SFP_PRIMARY}
    ...  AND  Fail  Fault 4701 Minor on Primary Link is raised. Not OK !
    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=600  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !
    ...  ELSE  Fail  Cells are not onAir !

step6: Generate And Recover Fault 4701 Major On Secondary Link
    Log To Console  --------------------
    Log To Console  step6: Generate And Recover Fault 4701 Major On Secondary Link
    Log To Console  --------------------${\n}

    radio.Generate Fault  ru_serial_number=${RMOD_SN}  fault_id=4701  severity=major  sfp_id=${RMOD_SFP_SECONDARY}
    Log To Console  Waiting for raise of FaultID 4701 Major On Secondary Link!${\n}

    Log To Console  Waiting for cells degraded status${\n}
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4701  timeout=300  severity=Major
    ${active_alarms}=  admin.Get Active Alarms
    Log To Console  Check if there are degraded cells on tested radio${\n}
    FOR  ${alarm}  IN  @{active_alarms}
        Continue For Loop If  '${alarm['faultId']}'!='4701'
        Run Keyword If  '${alarm['degradedCells']}' == 'None'  Fail  There are no degraded cells!
        ...  ELSE  Check Degraded Cells Exists In Tested RMOD  ${alarm}
    END
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log To Console  FaultID 4701 Major On Secondary Link RAISED !${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 4701 Major On Secondary Link NOT raised !
    ...  AND  radio.Recover Fault  fault_id=4701  ru_serial_number=${RMOD_SN}  sfp_id=${RMOD_SFP_SECONDARY}
    ...  AND  Fail  Fault 4701 Major On Secondary Link NOT raised !

    Log To Console  Recover Fault 4701 Major On Secondary Link

    radio.Recover Fault  ru_serial_number=${RMOD_SN}  fault_id=4701  sfp_id=${RMOD_SFP_SECONDARY}
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=4701  timeout=300  severity=Major
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log To Console  FaultID 4701 Major On Secondary Link cleared - OK!${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 4701 Major On Secondary Link is raised. Not OK !
    ...  AND  radio.Recover Fault  fault_id=4701  ru_serial_number=${RMOD_SN}  sfp_id=${RMOD_SFP_SECONDARY}
    ...  AND  Fail  Fault 4701 Major On Secondary Link is raised. Not OK !

step7: Generate Fault 4701 Minor On Secondary Link
    Log To Console  --------------------
    Log To Console  step8: Generate Fault 4701 Minor On Secondary Link
    Log To Console  --------------------${\n}

    Set Start Timestamp In IMS For CNI-127210
    radio.Generate Fault  ru_serial_number=${RMOD_SN}  fault_id=4701  severity=minor  sfp_id=${RMOD_SFP_SECONDARY}
    Log To Console  Waiting for raise of FaultID 4701 Minor On Secondary Link !${\n}
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4701  timeout=300  severity=Minor
    Check Active Fault In IMS For CNI-127210  fault_id=4701  severity=Minor
    Run Keyword If  '${alarm_status}'=='True' and "${PRECOND_FOR_CNI}"=="False"
    ...  Log To Console  FaultID 4701 Minor On Secondary Link RAISED !${\n}
    ...  ELSE IF  '${alarm_status}'=='False' and ${PRECOND_FOR_CNI}
    ...  Log To Console  FaultID 4701 Minor On Secondary Link RAISED !${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 4701 Minor On Secondary Link NOT raised !
    ...  AND  radio.Recover Fault  fault_id=4701  ru_serial_number=${RMOD_SN}  sfp_id=${RMOD_SFP_SECONDARY}
    ...  AND  Fail  Fault 4701 Minor On Secondary Link NOT raised !

step8: Turn Off Monitoring And Recover Fault 4701
    Log To Console  --------------------
    Log To Console  step8: Turn off alarm monitoring
    Log To Console  --------------------${\n}

    Log To Console  Perform recommissioning, please wait !${\n}
    #Set Start Timestamp In IMS For CNI-127210
    # Trzeba przeniesc deaktywcje ficzera do KW na fault major
    admin.Perform Parameter Recommissioning  ${OBJECT_VARIABLE_ACTTRANSCEIVER}  actTransceiverAlarmMonitoring  update  Off  alias=${node}
    Sleep  120s
    #${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=4701  timeout=300  severity=Minor
    #Run Keyword If  ${PRECOND_FOR_CNI}  Sleep  300s
    #Run Keyword If  '${alarm_status}'=='True'
    #...  Log To Console  FaultID 4701 Minor On Secondary Link cleared - OK!${\n}
    #...  ELSE  Run Keywords
    #...  Log To Console  Fault 4701 Minor On Secondary Link is raised. Not OK !
    #...  AND  radio.Recover Fault  fault_id=4701  ru_serial_number=${RMOD_SN}  sfp_id=${RMOD_SFP_SECONDARY}
    #...  AND  Fail  Fault 4701 Minor On Secondary Link is raised. Not OK !
    #radio.Recover Fault  ru_serial_number=${RMOD_SN}  fault_id=4701  sfp_id=${RMOD_SFP_SECONDARY}
    #Check Removed Active Fault In IMS For CNI-127210

Check Degraded Cells Exists In Tested RMOD
    [Arguments]   ${alarm}
    Set Test Variable  ${degraded_cell_detected}  False
    FOR  ${cell}  IN  @{CELLS_DISTNAME_FROM_TESTED_RM}
        Run Keyword If  '${cell}' in ${alarm['impactedCellsList']}
        ...  Run Keywords  Set Test Variable  ${degraded_cell_detected}  True
        ...  AND  Log To Console  Degraded cell exist${\n}
        ...  AND  Exit For Loop
        ...  ELSE  Set Test Variable  ${degraded_cell_detected}  False
    END
    Run Keyword And Continue On Failure  Run Keyword If  '${degraded_cell_detected}'!='True'  Fail  Degraded cells are not from tested RMOD.

TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Run Keyword If  ${RESTORE_CONFIG}
    ...  Restore Reference Configuration  ${REFERENCE_DICT}  ${object_variable_acttransceiver}
    Common Test Teardown

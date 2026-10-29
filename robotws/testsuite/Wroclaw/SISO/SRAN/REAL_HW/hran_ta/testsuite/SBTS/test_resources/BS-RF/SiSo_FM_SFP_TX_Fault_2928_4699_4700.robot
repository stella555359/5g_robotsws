*** Settings ***
Documentation
...  The purpose of this Test Case is to verify the situation when the BTS received information about [Q]SFP Transceiver TX_FAULT from Radio Unit


Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../resources/ca_BSRF_SFP_Monitoring.robot
Library    taf.sbts.oam.coam.admin  WITH NAME  admin

*** Variables ***
${RMOD_SN}
${node}  default

*** Keywords ***

TC__SiSo_FM_SFP_TX_Fault_2928_4699_4700
  [Documentation]
  ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-44450
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  The purpose of this case is to verify the situation when the BTS received information about [Q]SFP Transceiver TX_FAULT
  ...  from Radio Unit and the operator is informed about [Q]SFP Transceiver TX fault on Radio Unit by an alarm in Admin.
  ...  The purpose of this case is to verify the situation when the BTS received information about TX Bias Current on [Q]SFP’s LANE too low
  ...  from Radio Unit and the operator is informed about TX Bias Current on [Q]SFP’s LANE too low on Radio Unit by an alarm in Admin.
  ...  The purpose of this case is to verify the situation when the BTS received information about TX Power on [Q]SFP’s LANE too low
  ...  from Radio Unit and the operator is informed about TX Power on [Q]SFP’s LANE too low on Radio Unit by an alarm in BTS Element Manager or NMS.
  ...
  ...  TC works with RU families: 5.1*, tested on AHFB.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 2024.02.09 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-44450 - Initial creation

  Set Tags
  ...  OWNER-dawid.bak@nokia.com
  ...  AUTHOR-dawid.bak@nokia.com
  ...  MAINTAINER-dawid.bak@nokia.com
  ...  FEATURE-CB009226


  Step1: Preconditions
  Step2: Generate FID 2928 on secondary link
  Step3: Recover FID 2928 on secondary link
  Step4: Generate FID 2928 on primary link
  Step5: Generate FID 4699 on secondary link
  Step6: Recover FID 4699 on secondary link
  Step7: Generate FID 4699 on primary link
  Step8: Recover FID 4699 on primary link
  # Step9: Generate FID 4700 on secondary link
  # Step10: Recover FID 4700 on secondary link
  Step11: Generate FID 4700 on primary link
  Step12: Turn off monitoring and recover FID 4700 on primary link
  Restore Reference Configuration  ${REFERENCE_DICT}  ${OBJECT_VARIABLE_ACTTRANSCEIVER}


Step1: Preconditions
  Log To Console  --------------------
  Log To Console  step1: Preconditions
  Log To Console  --------------------${\n}

  Preconditions For CNI-127210
  Set Test Variable  ${RESTORE_CONFIG}  ${FALSE}

  Run Keyword If  '${RMOD_SN}'=='${EMPTY}'
  ...  Fail  Variable RMOD_SN cannot be empty!

  ${rmods_info}  admin.Get FRM  60  ${node}
  ${newer}  Check If Current Build Is Newer Than  SBTS25R2_ENB_9999_250116_000011  alias=${node}
  FOR  ${rmod}  IN  @{rmods_info}
    Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SN}'
    IF  ${newer}
        Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['runtime']}
    ELSE
        Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['internal']}
    END
#    Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['runtime']}
  END

  Run Keyword If  '${RMOD_DISTNAME_ID}'=='${NONE}'
  ...  Fail  Serial Number ${RMOD_SN} not found in HW Configuration! Test set to Fail!
  ...  ELSE  Log To Console  RMOD with SN ${RMOD_SN} found in configuration!${\n}

  ${bts_params}  admin.Get parameters for all  BTS  alias=${node}
  Set Test Variable  ${BTS_ID}  ${bts_params[0].btsId}

  Set Test Variable  ${OBJECT_VARIABLE_ACTTRANSCEIVER}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
  ${param_value_dict}  Get Value For ActTransceiverAlarmMonitoring Parameter  ${object_variable_acttransceiver}
  Set Test Variable   ${REFERENCE_DICT}  ${param_value_dict}

  Change Parameter For Transceiver Alarm Monitoring  value=Transceiver alarms and warnings

  Set Test Variable  ${RESTORE_CONFIG}  ${TRUE}

  ${rmod_sfps_info}  ${rmod_cablink_distname_info}  Get SFP Links Type By Radio Module  rmod_sn=${RMOD_SN}
  ${rmod_sfp_primary}  Evaluate  next((key for key, val in ${rmod_sfps_info}.items() if val == 'primary'))
  ${rmod_sfp_secondary}  Evaluate  next((key for key, val in ${rmod_sfps_info}.items() if val == 'secondary'))

  Set Test Variable  ${RMOD_SFP_PRIMARY}  ${rmod_sfp_primary}
  Set Test Variable  ${RMOD_SFP_SECONDARY}  ${rmod_sfp_secondary}

Step2: Generate FID 2928 on secondary link
  Log To Console  ${\n}---------------------------
  Log To Console  step2: Generate FID 2928 on secondary link
  Log To Console  ---------------------------${\n}

  Log To Console  Generating FID 2928 on secondary link...${\n}
  radio.Generate Fault  ru_serial_number=${RMOD_SN}
  ...  fault_id=2928
  ...  sfp_id=${RMOD_SFP_SECONDARY}
  Log To Console  Waiting for FID 2928...${\n}
  Query Infomodel  get list //FAULT_NOTIF-*
  ${alarm_status}  Query Infomodel  //FAULT_NOTIF-* is [faultId=2928, faultyObject=${RMOD_DISTNAME_ID}/SFP_R-${RMOD_SFP_SECONDARY}]
  ...  allow_negative_result=True
  Run Keyword If  '${alarm_status}'=='True'
  ...  Log To Console  FaultID 2928 RAISED!${\n}
  ...  ELSE  Run Keywords
  ...  Log To Console  Fault 2928 NOT raised!
  ...  AND  radio.Recover Fault  ru_serial_number=${RMOD_SN}
            ...  fault_id=2928
            ...  sfp_id=${RMOD_SFP_SECONDARY}
  ...  AND  Fail  Fault 2928 NOT raised!

   ${alarm_status}  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File  ru_serial_number=${RMOD_SN}
  ...  fault_id=1160
  ...  severity=Major

  Run Keyword If  '${alarm_status}'=='True'
  ...  Log To Console  FaultID 1160 FOUND in history log file!${\n}
  ...  ELSE  Run Keywords
  ...  Log To Console  FaultID 1160 NOT FOUND in history log file!
  ...  AND  radio.Recover Fault  ru_serial_number=${RMOD_SN}
            ...  fault_id=2928
            ...  sfp_id=${RMOD_SFP_SECONDARY}
  ...  AND  Fail  FaultID 1160 NOT FOUND in history log file!

  ${cells_status}  Run Keyword And Return Status  Check If All Cells And Modules Are OnAir  timeout=240
  Run Keyword If  '${cells_status}'=='True'
  ...  Log To Console  All cells are onAir!
  ...  ELSE  Fail  Cells are not onAir!

Step3: Recover FID 2928 on secondary link
  Log To Console  ${\n}---------------------------
  Log To Console  step3: Recover FID 2928 on secondary link
  Log To Console  ---------------------------${\n}

  radio.Recover Fault  ru_serial_number=${RMOD_SN}
  ...  fault_id=2928
  ...  sfp_id=${RMOD_SFP_SECONDARY}

  radio.Assert Inactive Fault In Fault History Log File  ru_serial_number=${RMOD_SN}
  ...  fault_id=1160
  ...  severity=Major

Step4: Generate FID 2928 on primary link
  Log To Console  ${\n}---------------------------
  Log To Console  step4: Generate FID 2928 on primary link
  Log To Console  ---------------------------${\n}

  Log To Console  Generating FID 1912 on primary link...${\n}
  radio.Generate Fault  ru_serial_number=${RMOD_SN}
  ...  fault_id=2928
  ...  sfp_id=${RMOD_SFP_PRIMARY}
  Log To Console  Waiting for FID 1912...${\n}

  ${alarm_status}  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File  ru_serial_number=${RMOD_SN}
  ...  fault_id=1112
  ...  severity=Critical

  Run Keyword If  '${alarm_status}'=='True'
  ...  Log To Console  FaultID 1112 FOUND in history log file!${\n}
  ...  ELSE  Run Keywords
  ...  Log To Console  FaultID 1112 NOT FOUND in history log file!
  ...  AND  radio.Recover Fault  ru_serial_number=${RMOD_SN}
            ...  fault_id=2928
            ...  sfp_id=${RMOD_SFP_PRIMARY}
  ...  AND  Fail  FaultID 1112 NOT FOUND in history log file!

  ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=1912
  ...  severity=Warning
  ...  timeout=300
  Run Keyword If  '${alarm_status}'=='True'
  ...  Log To Console  FaultID 1912 RAISED!${\n}
  ...  ELSE  Run Keywords
  ...  Log To Console  Fault 1912 NOT raised!
  ...  AND  radio.Recover Fault  ru_serial_number=${RMOD_SN}
            ...  fault_id=2928
            ...  sfp_id=${RMOD_SFP_PRIMARY}
  ...  AND  Fail  Fault 1912 NOT raised!

  ${cells_status}  Run Keyword And Return Status  Check If All Cells And Modules Are OnAir  timeout=240
  Run Keyword If  '${cells_status}'=='True'
  ...  Log To Console  All cells are onAir!
  ...  ELSE  Fail  Cells are not onAir!

Step5: Generate FID 4699 on secondary link
  Log To Console  ${\n}---------------------------
  Log To Console  step5: Generate FID 4699 on secondary link
  Log To Console  ---------------------------${\n}

  Log To Console  Generating FID 4699 on secondary link with severity Minor...${\n}
  Set Start Timestamp In IMS For CNI-127210
  radio.Generate Fault  ru_serial_number=${RMOD_SN}
  ...  fault_id=4699
  ...  severity=Minor
  ...  sfp_id=${RMOD_SFP_SECONDARY}
  Log To Console  Waiting for FID 4699 on secondary link with severity Minor...${\n}
  ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4699
  ...  severity=Minor
  ...  timeout=300
  Check Active Fault In IMS For CNI-127210  fault_id=4699  severity=Minor
  Run Keyword If  '${alarm_status}'=='True' and "${PRECOND_FOR_CNI}"=="False"
  ...  Log To Console  FaultID 4699 RAISED on secondary link with severity Minor!${\n}
  ...  ELSE IF  '${alarm_status}'=='False' and ${PRECOND_FOR_CNI}
  ...  Log To Console  FaultID 4699 RAISED on secondary link with severity Minor!${\n}
  ...  ELSE  Run Keywords
  ...  Log To Console  Fault 4699 on secondary link with severity Minor NOT raised!
  ...  AND  Step6: Recover FID 4699 on secondary link
  ...  AND  Fail  Fault 4699 on secondary link with severity Minor NOT raised!

Step6: Recover FID 4699 on secondary link
  Log To Console  ${\n}---------------------------
  Log To Console  step6: Recover FID 4699 on secondary link
  Log To Console  ---------------------------${\n}

  Set Start Timestamp In IMS For CNI-127210
  radio.Recover Fault  ru_serial_number=${RMOD_SN}
  ...  fault_id=4699
  ...  sfp_id=${RMOD_SFP_SECONDARY}
  admin.Assert Alarm Inactive  faultId=4699
  ...  timeout=300
  Run Keyword If  ${PRECOND_FOR_CNI}  Sleep  300s
  Check Removed Active Fault In IMS For CNI-127210

Step7: Generate FID 4699 on primary link
  Log To Console  ${\n}---------------------------
  Log To Console  step7: Generate FID 4699 on primary link
  Log To Console  ---------------------------${\n}

  Log To Console  Generating FID 4699 on primary link with severity Major...${\n}
  radio.Generate Fault  ru_serial_number=${RMOD_SN}
  ...  fault_id=4699
  ...  severity=Major
  ...  sfp_id=${RMOD_SFP_PRIMARY}
  Log To Console  Waiting for FID 4699 on primary link with severity Major...${\n}
  ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4699
  ...  severity=Major
  ...  timeout=300
  Run Keyword If  '${alarm_status}'=='True'
  ...  Log To Console  FaultID 4699 on primary link with severity Major RAISED!${\n}
  ...  ELSE  Run Keywords
  ...  Log To Console  Fault 4699 on primary link with severity Major NOT raised!
  ...  AND  Step8: Recover FID 4699 on primary link
  ...  AND  Fail  Fault 4699 on primary link with severity Major NOT raised!

Step8: Recover FID 4699 on primary link
  Log To Console  ${\n}---------------------------
  Log To Console  step8: Recover FID 4699 on primary link
  Log To Console  ---------------------------${\n}

  radio.Recover Fault  ru_serial_number=${RMOD_SN}
  ...  fault_id=4699
  ...  sfp_id=${RMOD_SFP_PRIMARY}

  admin.Assert Alarm Inactive  faultId=4699
  ...  timeout=300

Step9: Generate FID 4700 on secondary link
  Log To Console  ${\n}---------------------------
  Log To Console  step9: Generate FID 4700 on secondary link
  Log To Console  ---------------------------${\n}

  Log To Console  Generating FID 4700 on secondary link with severity Minor...${\n}
  Set Start Timestamp In IMS For CNI-127210
  radio.Generate Fault  ru_serial_number=${RMOD_SN}
  ...  fault_id=4700
  ...  severity=Minor
  ...  sfp_id=${RMOD_SFP_SECONDARY}
  Log To Console  Waiting for FID 4700 on secondary link with severity Minor...${\n}
  ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4700
  ...  severity=Minor
  ...  timeout=300
  Check Active Fault In IMS For CNI-127210  fault_id=4700  severity=Minor
  Run Keyword If  '${alarm_status}'=='True' and "${PRECOND_FOR_CNI}"=="False"
  ...  Log To Console  FaultID 4700 on secondary link with severity Minor RAISED!${\n}
  ...  ELSE IF  '${alarm_status}'=='False' and ${PRECOND_FOR_CNI}
  ...  Log To Console  FaultID 4700 RAISED on primary link with severity Minor!${\n}
  ...  ELSE  Run Keywords
  ...  Log To Console  Fault 4700 on secondary link with severity Minor NOT raised!
  ...  AND  Step10: Recover FID 4700 on secondary link
  ...  AND  Fail  Fault 4700 on secondary link with severity Minor NOT raised!

Step10: Recover FID 4700 on secondary link
  Log To Console  ${\n}---------------------------
  Log To Console  step10: Recover FID 4700 on secondary link
  Log To Console  ---------------------------${\n}

  Set Start Timestamp In IMS For CNI-127210
  radio.Recover Fault  ru_serial_number=${RMOD_SN}
  ...  fault_id=4700
  ...  sfp_id=${RMOD_SFP_SECONDARY}

  admin.Assert Alarm Inactive  faultId=4700
  ...  timeout=300
  Run Keyword If  ${PRECOND_FOR_CNI}  Sleep  300s
  Check Removed Active Fault In IMS For CNI-127210

Step11: Generate FID 4700 on primary link
  Log To Console  ${\n}---------------------------
  Log To Console  step11: Generate FID 4700 on primary link
  Log To Console  ---------------------------${\n}

  Log To Console  Generating FID 4700 on primary link with severity Major...${\n}
  radio.Generate Fault  ru_serial_number=${RMOD_SN}
  ...  fault_id=4700
  ...  severity=Major
  ...  sfp_id=${RMOD_SFP_PRIMARY}
  Log To Console  Waiting for FID 4700 on primary link with severity Major...${\n}
  ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4700
  ...  severity=Major
  ...  timeout=300
  Run Keyword If  '${alarm_status}'=='True'
  ...  Log To Console  FaultID 4700 on primary link with severity Major RAISED!${\n}
  ...  ELSE  Run Keywords
  ...  Log To Console  Fault 4700 on primary link with severity Major NOT raised!
  ...  AND    radio.Recover Fault  ru_serial_number=${RMOD_SN}
              ...  fault_id=4700
              ...  sfp_id=${RMOD_SFP_PRIMARY}
  ...  AND  Fail  Fault 4700 on primary link with severity Major NOT raised!

Step12: Turn off monitoring and recover FID 4700 on primary link
  Log To Console  ${\n}---------------------------
  Log To Console  step12: Turn off alarm monitoring and recover FID 4700 on primary link
  Log To Console  ---------------------------${\n}

  Change Parameter For Transceiver Alarm Monitoring  value=Off

  ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=4700
  ...  timeout=300
  ...  severity=Major
  Run Keyword If  '${alarm_status}'=='True'
  ...  Log To Console  FaultID 4700 on primary link with severity Major cleared - OK!${\n}
  ...  ELSE  Run Keywords
  ...  Log To Console  Fault 4700 on primary link with severity Major is raised. Not OK !
  ...  AND    radio.Recover Fault  ru_serial_number=${RMOD_SN}
              ...  fault_id=4700
              ...  sfp_id=${RMOD_SFP_PRIMARY}
  ...  AND  Fail  Fault 4700 on primary link with severity Major is raised. Not OK !

  radio.Recover Fault  ru_serial_number=${RMOD_SN}
  ...  fault_id=4700
  ...  sfp_id=${RMOD_SFP_PRIMARY}

Change Parameter For Transceiver Alarm Monitoring
  [Arguments]  ${value}
  Log To Console  Updating parameter for activate transceiver alarm monitoring to "${value}"...${\n}
  admin.Perform Parameter Recommissioning  dist_name=${OBJECT_VARIABLE_ACTTRANSCEIVER}
  ...  parameter=actTransceiverAlarmMonitoring
  ...  value=${value}
  ...  operation=update
  ...  should_activate=True
  ...  alias=${node}
  Log To Console  Done updating parameter for transceiver alarm monitoring to "${value}"!${\n}

TC Setup
  Common Test Setup

TC Teardown
  Run Keyword If Test Failed  Run Keyword If  ${RESTORE_CONFIG}
  ...  Restore Reference Configuration  ${REFERENCE_DICT}  ${object_variable_acttransceiver}
  Common Test Teardown

*** Settings ***
Documentation
  ...  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  The purpose of this case is to verify the situation when the BTS received information about [Q]SFP Transceiver TX_FAULT
  ...  from Radio Unit and the operator is informed about [Q]SFP Transceiver TX fault on Radio Unit by an alarm in Admin.
  ...  The purpose of this case is to verify the situation when the BTS received information about TX Bias Current on [Q]SFP’s LANE too low
  ...  from Radio Unit and the operator is informed about TX Bias Current on [Q]SFP’s LANE too low on Radio Unit by an alarm in Admin.
  ...  The purpose of this case is to verify the situation when the BTS received information about TX Power on [Q]SFP’s LANE too low
  ...  from Radio Unit and the operator is informed about TX Power on [Q]SFP’s LANE too low on Radio Unit by an alarm in BTS Element Manager.
  ...  *****************
  ...  IMPORTANT:
  ...  You need to use 2 cablinks to connect Radio Unit and data cablink must be useful. If additional cablink will be configure as dummy
  ...  test case won't be working correctly!
  ...
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../TestCases/FM/SFP_Monitoring.resource


*** Variables ***
${RMOD_SN}                    # Serial number of the radio


*** Keywords ***
TC__FM_SFP_TX_Fault_2928_4699_4700
    Set Tags  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=FM_SFP_TX_Fault_2928_4699_4700 will be executed
    ...  style=ONGOING
    Step 1: Preparing Variables For SFP TX Fault 2928 4699 4700
    Step 2: Generate FID 2928 on secondary link
    Step 3: Recover FID 2928 on secondary link
    Step 4: Generate FID 2928 primary link
    Step 5: Recover FID 2928 on primary link
    Step 6: Generate FID 4699 on secondary link
    Step 7: Recover FID 4699 on secondary link
    Step 8: Generate FID 4699 on primary link
    Step 9: Recover FID 4699 on primary link
    Step 10: Generate FID 4700 on primary link
    Step 11: Recover FID 4700 on primary link and Turn off monitoring
    [Teardown]  Common Test Teardown

Step 1: Preparing Variables For SFP TX Fault 2928 4699 4700
    Logging With Timestamp
    ...  message=Step 1: Preparing Variables For SFP TX Fault 2928 4699 4700
    ...  style=STEP
    ...  frame=${TRUE}
    Set Test Variable  ${BTS_ID}  ${CFG['primary_node_bts_id']}
    ${remote_vm}  Set Variable If  "${CFG['NODES']['${BTS_ID}']['bts_alias_type']}"=="remote"
    ...  ${CFG['NODES']['${BTS_ID}']['vm_ip_LMP_address']}  None
    Set Test Variable  ${REMOTE_VM}  ${remote_vm}
    IF  '${RMOD_SN}'=='${EMPTY}'
      Logging With Timestamp
      ...  message=Variable RMOD_SN cannot be empty!
      ...  style=ERROR
      Fail  Variable RMOD_SN cannot be empty!
    ELSE IF  '${RMOD_SN}' in @{CFG['NODES']['${BTS_ID}']['scf_hw_fr_list']}
      IF  '${CFG['RF_INFO']['${RMOD_SN}']['scf_release_code']}'=='RRH-ORAN'
        Logging With Timestamp
        ...  message=RMOD -> ${RMOD_SN} is ORAN.
      ELSE
        Logging With Timestamp
        ...  message=RMOD -> ${RMOD_SN} is NOT ORAN!
        ...  style=ERROR
        Fail  RMOD -> ${RMOD_SN} is NOT ORAN!
      END
    ELSE
      Logging With Timestamp
      ...  message=RMOD -> ${RMOD_SN} is NOT on BTS. Please check correct SN !!!
      ...  style=ERROR
      Fail  RMOD -> ${RMOD_SN} is NOT on BTS. Please check correct SN !!!
    END
    ${featcadm_parameter}  admin.Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  connection=${BTS_ID}
    ${actTransceiverAlarmMonitoring_value}  Get From Dictionary  ${featcadm_parameter[0]['parameters']}  actTransceiverAlarmMonitoring
    IF  "${actTransceiverAlarmMonitoring_value}"!="Transceiver alarms and warnings"
      Logging With Timestamp
      ...  message=Updating parameter for activate transceiver alarm monitoring to Transceiver alarms and warnings
      ...  style=ONGOING
      ${recommissionig_status}  Run Keyword And Return Status  admin.Perform Parameter Recommissioning
      ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
      ...  parameter=actTransceiverAlarmMonitoring
      ...  value=Transceiver alarms and warnings
      ...  operation=update
      ...  should_activate=True
      ...  connection=${BTS_ID}
      IF  ${recommissionig_status}
        Logging With Timestamp
        ...  message=Updating parameter for transceiver alarm monitoring to Transceiver alarms and warnings nished succesfully !!!
        ...  style=DONE
      ELSE
        Logging With Timestamp
        ...  message=Change sfpOperatorMode Parameter Value to ${parameter_value} finished ERROR !!!
        ...  style=ERROR
        Run Keyword And Continue On Failure  Fail  Change sfpOperatorMode Parameter Value to ${parameter_value} finished ERROR !!!
      END
    ELSE IF  "${actTransceiverAlarmMonitoring_value}"=="Transceiver alarms and warnings"
      Logging With Timestamp  message=Parameter actTransceiverAlarmMonitoring has expected value -> Transceiver alarms and warnings
    END
    ${rmod_sfps_info_dict}  ${cablink_distname_to_sfp_linkmode_dict}  Get SFP Links Type By Radio Module  ${RMOD_SN}  cable_dn_type=internal
    ${rmod_sfp_primary}  Evaluate  next((key for key, val in ${rmod_sfps_info_dict}.items() if val == 'primary'))
    ${rmod_sfp_secondary}  Evaluate  next((key for key, val in ${rmod_sfps_info_dict}.items() if val == 'secondary'))
    ${cablink_distname_primary}  Evaluate  next((key for key, val in ${cablink_distname_to_sfp_linkmode_dict}.items() if val == 'primary'))
    ${cablink_distname_secondary}  Evaluate  next((key for key, val in ${cablink_distname_to_sfp_linkmode_dict}.items() if val == 'secondary'))
    Set Test Variable  ${RMOD_SFP_PRIMARY}  ${rmod_sfp_primary}
    Set Test Variable  ${RMOD_SFP_SECONDARY}  ${rmod_sfp_secondary}
    Set Test Variable  ${RMOD_CABLINK_PRIMARY_DISTNAME}  ${cablink_distname_primary}
    Set Test Variable  ${RMOD_CABLINK_SECONDARY_DISTNAME}  ${cablink_distname_secondary}
    ${links}  admin.Get SFP Links  connection=${BTS_ID}
    &{tested_sfps_rmod}  Create Dictionary
    FOR  ${link}  IN  @{links['connected']}
      IF  '${RMOD_CABLINK_PRIMARY_DISTNAME}'=='${link['link']['distName']}'
        Set Test Variable  ${RMOD_SFP_PRIMARY_DN}  ${link['source']}
      ELSE IF  '${RMOD_CABLINK_SECONDARY_DISTNAME}'=='${link['link']['distName']}'
        Set Test Variable  ${RMOD_SFP_SECONDARY_DN}  ${link['source']}
      END
    END

Step 2: Generate FID 2928 on secondary link
    Logging With Timestamp
    ...  message=Step 2: Generate FID 2928 on secondary link
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Triggering FID2928 for sfp_id=${RMOD_SFP_SECONDARY} started...
    Run Keyword And Continue On Failure  radio.Generate Fault
    ...  fault_id=2928
    ...  ru_serial_number=${RMOD_SN}
    ...  sfp_id=${RMOD_SFP_SECONDARY}
    ...  remote_host=${REMOTE_VM}
    Logging With Timestamp
    ...  message=Triggering FID2928 for sfp_id=${RMOD_SFP_SECONDARY} finished...
    Sleep  30  Wait for R&D faults
    FM Check Active Fault In IMS For RD Fault
    ...  bts_id=${BTS_ID}
    ...  fault_id=2928
    ...  severity=${NONE}
    ...  find_rd_fault=${TRUE}
    ${alarm_status}  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File  ru_serial_number=${RMOD_SN}
    ...  fault_id=1404
    ...  severity=warning
    ...  remote_host=${REMOTE_VM}
    IF  '${alarm_status}'=='True'
      Logging With Timestamp
      ...  message=FaultID 1404 FOUND in history log file!${\n}
    ELSE
      Logging With Timestamp
      ...  message=FaultID 1404 NOT FOUND in history log file!
      Run Keyword And Continue On Failure  Fail  FaultID 1404 NOT FOUND in history log file!
    END
    Run Keyword And Continue On Failure  STATE Verify BTS states  node_id=${BTS_ID}

Step 3: Recover FID 2928 on secondary link
    Logging With Timestamp
    ...  message=Step 3: Recover FID 2928 on secondary link
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Recovering FID2928...
    Run Keyword And Continue On Failure  radio.Recover Fault
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=2928
    ...  sfp_id=${RMOD_SFP_SECONDARY}
    ...  remote_host=${REMOTE_VM}
    Logging With Timestamp
    ...  message=Waiting for recover radio...
    Sleep  30  Wait for clear R&D faults
    FM Check Removed Active Fault In IMS For RD Fault  bts_id=${BTS_ID}  find_rd_fault=${TRUE}
    ${alarm_status}  Run Keyword And Return Status  radio.Assert Inactive Fault In Fault History Log File  ru_serial_number=${RMOD_SN}
    ...  fault_id=1404
    ...  severity=warning
    ...  remote_host=${REMOTE_VM}
    IF  '${alarm_status}'=='True'
      Logging With Timestamp
      ...  message=FaultID 1404 cleared in history log file!${\n}
    ELSE
      Logging With Timestamp
      ...  message=FaultID 1404 NOT cleared in history log file!
      Run Keyword And Continue On Failure  Fail  FaultID 1404 NOT cleared in history log file!
    END

Step 4: Generate FID 2928 primary link
    Logging With Timestamp
    ...  message=Step 4: Generate FID 2928 primary link
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Triggering FID2928 for sfp_id=${RMOD_SFP_PRIMARY} started...
    Run Keyword And Continue On Failure  radio.Generate Fault
    ...  fault_id=2928
    ...  ru_serial_number=${RMOD_SN}
    ...  sfp_id=${RMOD_SFP_PRIMARY}
    ...  remote_host=${REMOTE_VM}
    Logging With Timestamp
    ...  message=Triggering FID2928 for sfp_id=${RMOD_SFP_PRIMARY} finished...
    Sleep  30  Wait for R&D faults
    FM Check Active Fault In IMS For RD Fault
    ...  bts_id=${BTS_ID}
    ...  fault_id=2928
    ...  severity=${NONE}
    ...  find_rd_fault=${TRUE}
    ${alarm_status}  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File  ru_serial_number=${RMOD_SN}
    ...  fault_id=1404
    ...  severity=warning
    ...  remote_host=${REMOTE_VM}
    IF  '${alarm_status}'=='True'
      Logging With Timestamp
      ...  message=FaultID 1404 FOUND in history log file!${\n}
    ELSE
      Logging With Timestamp
      ...  message=FaultID 1404 NOT FOUND in history log file!
      Run Keyword And Continue On Failure  Fail  FaultID 1404 NOT FOUND in history log file!
    END
    Run Keyword And Continue On Failure  STATE Verify BTS states  node_id=${BTS_ID}

Step 5: Recover FID 2928 on primary link
    Logging With Timestamp
    ...  message=Step 5: Recover FID 2928 on primary link
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Recovering FID2928...
    Run Keyword And Continue On Failure  radio.Recover Fault
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=2928
    ...  sfp_id=${RMOD_SFP_PRIMARY}
    ...  remote_host=${REMOTE_VM}
    Logging With Timestamp
    ...  message=Waiting for recover radio...
    Sleep  30  Wait for clear R&D faults
    FM Check Removed Active Fault In IMS For RD Fault  bts_id=${BTS_ID}  find_rd_fault=${TRUE}
    radio.Assert Inactive Fault In Fault History Log File  ru_serial_number=${RMOD_SN}
    ...  fault_id=1404
    ...  severity=warning
    ...  remote_host=${REMOTE_VM}

Step 6: Generate FID 4699 on secondary link
    Logging With Timestamp
    ...  message=Step 6: Generate FID 4699 on secondary link
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Triggering FID4699 for sfp_id=${RMOD_SFP_SECONDARY} started...
    Run Keyword And Continue On Failure  radio.Generate Fault
    ...  fault_id=4699
    ...  severity=major
    ...  ru_serial_number=${RMOD_SN}
    ...  sfp_id=${RMOD_SFP_SECONDARY}
    ...  remote_host=${REMOTE_VM}
    Logging With Timestamp
    ...  message=Triggering FID4699 for sfp_id=${RMOD_SFP_SECONDARY} finished...
    ${fault_4699_status}  Run Keyword And Return Status  FM Await For Fault
    ...  fault_attr=faultId=4699, severity=regex"Major", alarmingObjectIds[0].internal=${RMOD_SFP_SECONDARY_DN}
    ...  node_id=${BTS_ID}
    ...  alarm_resource=${FAULT_4699}
    ...  timeout=180
    IF  ${fault_4699_status} == ${TRUE}
      Logging With Timestamp
      ...  message=Fault 4699 active in WebEM!!!
      ...  style=PASS
    ELSE IF  ${fault_4699_status} == ${FALSE}
      Logging With Timestamp
      ...  message=Fault 4699 NOT active !!!
      ...  style=ERROR
      Run Keyword And Continue On Failure  Fail  Fault 4699 NOT active !!!
    END
    Run Keyword And Continue On Failure  admin.Assert
    ...  class_name=SFP
    ...  id=${RMOD_SFP_SECONDARY_DN}
    ...  parameters=availabilityStatus=regex"(?i)Degraded"
    ...  timeout=60
    ...  connection=${BTS_ID}
    Checking Expected States After Fault 4699 4700 Active  ${RMOD_CABLINK_SECONDARY_DISTNAME}

Step 7: Recover FID 4699 on secondary link
    Logging With Timestamp
    ...  message=Step 7: Recover FID 4699 on secondary link
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Recovering FID4699...
    Run Keyword And Continue On Failure  radio.Recover Fault
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=4699
    ...  sfp_id=${RMOD_SFP_SECONDARY}
    ...  remote_host=${REMOTE_VM}
    Logging With Timestamp
    ...  message=Waiting for recover radio...
    FM Await For Fault Cleared
    ...  fault_attr=faultId=4699
    ...  timeout=120
    ...  node_id=${BTS_ID}
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  5x  60  STATE Verify BTS states  node_id=${BTS_ID}
    Run Keyword And Continue On Failure  admin.Assert
    ...  class_name=SFP
    ...  id=${RMOD_SFP_SECONDARY_DN}
    ...  parameters=operationalState=regex"(?i)Enabled"
    ...  timeout=30
    ...  connection=${BTS_ID}

Step 8: Generate FID 4699 on primary link
    Logging With Timestamp
    ...  message=Step 8: Generate FID 4699 on primary link
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Triggering FID4699 for sfp_id=${RMOD_SFP_PRIMARY} started...
    Run Keyword And Continue On Failure  radio.Generate Fault
    ...  fault_id=4699
    ...  severity=major
    ...  ru_serial_number=${RMOD_SN}
    ...  sfp_id=${RMOD_SFP_PRIMARY}
    ...  remote_host=${REMOTE_VM}
    Logging With Timestamp
    ...  message=Triggering FID4699 for sfp_id=${RMOD_SFP_PRIMARY} finished...
    ${fault_4699_status}  Run Keyword And Return Status  FM Await For Fault
    ...  fault_attr=faultId=4699, severity=regex"Major", alarmingObjectIds[0].internal=${RMOD_SFP_PRIMARY_DN}
    ...  node_id=${BTS_ID}
    ...  alarm_resource=${FAULT_4699}
    ...  timeout=180
    IF  ${fault_4699_status} == ${TRUE}
      Logging With Timestamp
      ...  message=Fault 4699 active in WebEM!!!
      ...  style=PASS
    ELSE IF  ${fault_4699_status} == ${FALSE}
      Logging With Timestamp
      ...  message=Fault 4699 NOT active !!!
      ...  style=ERROR
      Run Keyword And Continue On Failure  Fail  Fault 4699 NOT active !!!
    END
    Run Keyword And Continue On Failure  admin.Assert
    ...  class_name=SFP
    ...  id=${RMOD_SFP_PRIMARY_DN}
    ...  parameters=availabilityStatus=regex"(?i)Degraded"
    ...  timeout=60
    ...  connection=${BTS_ID}
    Checking Expected States After Fault 4699 4700 Active  ${RMOD_CABLINK_PRIMARY_DISTNAME}

Step 9: Recover FID 4699 on primary link
    Logging With Timestamp
    ...  message=Step 9: Recover FID 4699 on primary link
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Recovering FID4699...
    Run Keyword And Continue On Failure  radio.Recover Fault
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=4699
    ...  sfp_id=${RMOD_SFP_PRIMARY}
    ...  remote_host=${REMOTE_VM}
    Logging With Timestamp
    ...  message=Waiting for recover radio...
    FM Await For Fault Cleared
    ...  fault_attr=faultId=4699
    ...  timeout=120
    ...  node_id=${BTS_ID}
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  5x  60  STATE Verify BTS states  node_id=${BTS_ID}
    Run Keyword And Continue On Failure  admin.Assert
    ...  class_name=SFP
    ...  id=${RMOD_SFP_PRIMARY_DN}
    ...  parameters=operationalState=regex"(?i)Enabled"
    ...  timeout=30
    ...  connection=${BTS_ID}

Step 10: Generate FID 4700 on primary link
    Logging With Timestamp
    ...  message=Step 10: Generate FID 4700 on primary link
    ...  style=STEP
    ...  frame=${TRUE}
        Logging With Timestamp
    ...  message=Triggering FID4700 for sfp_id=${RMOD_SFP_PRIMARY} started...
    Run Keyword And Continue On Failure  radio.Generate Fault
    ...  fault_id=4700
    ...  severity=major
    ...  ru_serial_number=${RMOD_SN}
    ...  sfp_id=${RMOD_SFP_PRIMARY}
    ...  remote_host=${REMOTE_VM}
    Logging With Timestamp
    ...  message=Triggering FID4700 for sfp_id=${RMOD_SFP_PRIMARY} finished...
    ${fault_4700_status}  Run Keyword And Return Status  FM Await For Fault
    ...  fault_attr=faultId=4700, severity=regex"Major", alarmingObjectIds[0].internal=${RMOD_SFP_PRIMARY_DN}
    ...  node_id=${BTS_ID}
    ...  alarm_resource=${FAULT_4700}
    ...  timeout=180
    IF  ${fault_4700_status} == ${TRUE}
      Logging With Timestamp
      ...  message=Fault 4700 active in WebEM!!!
      ...  style=PASS
    ELSE IF  ${fault_4700_status} == ${FALSE}
      Logging With Timestamp
      ...  message=Fault 4700 NOT active !!!
      ...  style=ERROR
      Run Keyword And Continue On Failure  Fail  Fault 4700 NOT active !!!
    END
    Run Keyword And Continue On Failure  admin.Assert
    ...  class_name=SFP
    ...  id=${RMOD_SFP_PRIMARY_DN}
    ...  parameters=availabilityStatus=regex"(?i)Degraded"
    ...  timeout=60
    ...  connection=${BTS_ID}
    Checking Expected States After Fault 4699 4700 Active  ${RMOD_CABLINK_PRIMARY_DISTNAME}

Step 11: Recover FID 4700 on primary link and Turn off monitoring
    Logging With Timestamp
    ...  message=Step 11: Recover FID 4700 on primary link and Turn off monitoring
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Recovering FID4700...
    Run Keyword And Continue On Failure  radio.Recover Fault
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=4700
    ...  sfp_id=${RMOD_SFP_PRIMARY}
    ...  remote_host=${REMOTE_VM}
    Logging With Timestamp
    ...  message=Waiting for recover radio...
    FM Await For Fault Cleared
    ...  fault_attr=faultId=4700
    ...  timeout=120
    ...  node_id=${BTS_ID}
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  5x  60  STATE Verify BTS states  node_id=${BTS_ID}
    Run Keyword And Continue On Failure  admin.Assert
    ...  class_name=SFP
    ...  id=${RMOD_SFP_PRIMARY_DN}
    ...  parameters=operationalState=regex"(?i)Enabled"
    ...  timeout=30
    ...  connection=${BTS_ID}
    Logging With Timestamp
      ...  message=Updating parameter for activate transceiver alarm monitoring to Off
      ...  style=ONGOING
      ${recommissionig_status}  Run Keyword And Return Status  admin.Perform Parameter Recommissioning
      ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
      ...  parameter=actTransceiverAlarmMonitoring
      ...  value=Off
      ...  operation=update
      ...  should_activate=True
      ...  connection=${BTS_ID}
      IF  ${recommissionig_status}
        Logging With Timestamp
        ...  message=Updating parameter for transceiver alarm monitoring to Transceiver alarms and warnings nished succesfully !!!
        ...  style=DONE
      ELSE
        Logging With Timestamp
        ...  message=Change sfpOperatorMode Parameter Value to ${parameter_value} finished ERROR !!!
        ...  style=ERROR
        Run Keyword And Continue On Failure  Fail  Change sfpOperatorMode Parameter Value to ${parameter_value} finished ERROR !!!
      END


Checking Expected States After Fault 4699 4700 Active
    [Arguments]  ${cablink_distname}
    Logging With Timestamp
      ...  message=Checking Expected States After Fault 4699 4700 Active
    ${cablink_cell}  BTS_INFO Create Cablinks Dictionary With Affected Cells Lists
    ${affected_cells_list}  Get From Dictionary  ${cablink_cell}  ${cablink_distname}
    Set Test Variable  ${AFFECTED_CELLS_LIST}  ${affected_cells_list}
    ${all_cells_list}  Create List
    FOR  ${cablink_dn}  ${cells_list}  IN  &{cablink_cell}
        Append To List  ${all_cells_list}  @{cells_list}
    END
    @{not_affected_cells_list}  Create List  @{all_cells_list}
    Remove Values From List  ${not_affected_cells_list}  @{affected_cells_list}
    Set Test Variable  ${NOT_AFFECTED_CELLS_LIST}  ${not_affected_cells_list}
    FOR  ${cell}  IN  @{not_affected_cells_list}
      ${class}  Get Regexp Matches  ${cell}  (?i)LNCEL|NRCEL|WNCEL|GNCEL
      ${cell_status}  Run Keyword And Return Status  STATE Verify States For One
      ...  class=${class[0]}
      ...  object=${cell}
      ...  node_id=${BTS_ID}
      Run Keyword If  not ${cell_status}  Run Keyword And Continue On Failure  Fail  ${cell} is not onAir
    END
    FOR  ${cell}  IN  @{affected_cells_list}
      ${class}  Get Regexp Matches  ${cell}  (?i)LNCEL|NRCEL|WNCEL|GNCEL
      ${cell_status}  Run Keyword And Return Status  admin.Assert
      ...  class_name=${class[0]}
      ...  id=${cell}
      ...  parameters=availabilityStatus=regex"(?i)Degraded"
      ...  timeout=60
      ...  connection=${BTS_ID}
      IF  not ${cell_status}  Run Keyword And Continue On Failure  Fail  ${cell} is onAir but should degraded !!!
    END

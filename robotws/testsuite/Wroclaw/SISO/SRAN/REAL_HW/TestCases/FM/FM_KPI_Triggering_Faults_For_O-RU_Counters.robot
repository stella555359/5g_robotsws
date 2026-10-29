*** Settings ***
Documentation
  ...  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  Verify the behavior of triggering KPI faults.
  ...
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 05.02.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot

*** Variables ***
${BTS_ID}=  ${EMPTY}     # In case of multinode config test must be executed on one node at a time with specified 'BTS_ID'
                         # If single node config, 'BTS_ID' is not used.
*** Keywords ***
TC__FM_KPI_Triggering_Faults_For_O-RU_Counters
    Set Tags  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=FM_KPI_Triggering_Faults_For_O-RU_Counters.robot will be executed
    ...  style=ONGOING
    Precondition For KPI Triggering Faults
    Step 1 Create KPI Alarm Trigger
    Step 2 Change ActKpiAlarms Parameter To True
    Step 3 Check Visible Alarms And BTS Status
    Step 4 Change ActKpiAlarms Parameter To False
    Step 5 Check If Alarms Are Cleared And BTS Status Is As Expected
    [Teardown]  Run Keywords  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"
    ...  Recovery For KPI Triggering Faults  AND
    ...  Common Test Teardown

Precondition For KPI Triggering Faults
    Logging With Timestamp
    ...  message=Precondition For KPI Triggering Faults
    ...  style=STEP
    ...  frame=${TRUE}
    Run Keyword If  "${BTS_ID}"=="${EMPTY}" and len(${CFG['active_bts_list']})>1  Run Keywords
    ...  Logging With Timestamp
    ...  message=Multinode config detected. Please specify 'BTS_ID' for testing.
    ...  style=ERROR
    ...  AND  Fail  Multinode config detected. Please specify 'BTS_ID' for testing.
    ...  ELSE IF  "${BTS_ID}"=="${EMPTY}"  Set Test Variable  ${BTS_ID}  ${CFG['active_bts_list'][0]}
    ${featcadm_parameter}  admin.Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  connection=${BTS_ID}
    ${actKpiAlarms_value}  Get From Dictionary  ${featcadm_parameter[0]['parameters']}  actKpiAlarms
    Run Keyword If  "${actKpiAlarms_value}"=="False"
    ...  Logging With Timestamp  message=Parameter kpiAlarmTriggers deactivated.
    ...  ELSE
    ...  Logging With Timestamp  message=Parameter kpiAlarmTriggers Activated!!! Please change to False to perform test.
    ...  style=FAIL
    ${trblcadm_parameter}  admin.Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  connection=${BTS_ID}
    ${kpi_alarm_exist}  Run Keyword And Return Status  Variable Should Exist  ${trblcadm_parameter[0]['parameters']['kpiAlarmTriggers']}
    Set Test Variable  ${kpi_alarm_exist}  ${KPI_ALARM_EXIST}
    Run Keyword If  ${kpi_alarm_exist}  Remove All KPI Alarms From kpiAlarmTriggers List
    ${nrcel_ids}  Get Ids For All  NRCEL  connection=${BTS_ID}
    ${cells_dn_list}  Create List
    FOR  ${cell}  IN  @{nrcel_ids}
      ${cell_dn}  Remove String Using Regexp  ${cell}  .*VIEW-\\d/
      ${cell_dn}  Remove String Using Regexp  ${cell_dn}  _R
      ${cell_dn}  Replace String Using Regexp  ${cell_dn}  MRBTS-\\d  MRBTS-${BTS_ID}
      Append To List  ${cells_dn_list}  ${cell_dn}
    END
    Set Test Variable  ${NRCEL_SHORT_DN_LIST}  ${cells_dn_list}
    ${mrbts_parameter}  admin.Get Parameter By Distname  MRBTS-${BTS_ID}  connection=${BTS_ID}
    ${btsname_value}  Get From Dictionary  ${mrbts_parameter[0]['parameters']}  btsName
    Set Test Variable  ${BTSNAME_VALUE}  ${btsname_value}

Step 1 Create KPI Alarm Trigger
    Logging With Timestamp
    ...  message=Step 1 Create KPI Alarm Trigger
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp  message=Adding KPI alarms and performing delta commissioning ...
    ...  style=ONGOING
    &{true_formula}  Create Dictionary  faultID=4569  formulaDescription=error  timeToTrigger=2
    ...  triggeringFormula=(DL_DATA_SLOTS != 0) OR (UL_DATA_SLOTS != 0)
    &{false_formula}  Create Dictionary  faultID=4570  formulaDescription=error  timeToTrigger=2
    ...  triggeringFormula=(DL_DATA_SLOTS == 0) AND (UL_DATA_SLOTS == 0)
    @{fault_trigger}  Create List  ${true_formula}  ${false_formula}
    Set Test Variable  ${TRUE_FORMULA}  ${true_formula}
    Set Test Variable  ${FALSE_FORMULA}  ${false_formula}
    admin.Create Delta
    admin.Append Parameter Update To Delta
    ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...  parameter=kpiAlarmTriggers
    ...  value=${fault_trigger}
    admin.Save Delta  target_file_name=${CFG.test_logs_path}/BTSFiles/delta.json
    admin.Perform Delta Recommissioning
    ...  delta_file=${CFG.test_logs_path}/BTSFiles/delta.json
    ...  connection=${BTS_ID}
    admin.Remove Delta
    Logging With Timestamp  message=Adding KPI alarms and performing delta commissioning ...
    ...  style=DONE

Step 2 Change ActKpiAlarms Parameter To True
    Logging With Timestamp
    ...  message=Step 2 Change ActKpiAlarms Parameter To True
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp  message=Updating actKpiAlarms parameter to true ...
    ...  style=ONGOING
    admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...  parameter=actKpiAlarms
    ...  operation=update
    ...  value=true
    ...  connection=${BTS_ID}
    ${kpi_alarm_act_time}  Get Time
    Set Test Variable  ${KPI_ALARM_ACT_TIME}  ${kpi_alarm_act_time}
    Logging With Timestamp  message=Updating actKpiAlarms parameter to true ...
    ...  style=DONE

Step 3 Check Visible Alarms And BTS Status
    Logging With Timestamp
    ...  message=Step 3 Check Visible Alarms And SBTS Status
    ...  style=STEP
    ...  frame=${TRUE}
    ${timeout}  Evaluate  ${TRUE_FORMULA['timeToTrigger']}*60+60
    ${faultName}  Catenate  The following KPI formula ${TRUE_FORMULA['triggeringFormula']} has been evaluated to true:
    ...  ${TRUE_FORMULA['formulaDescription']}
    FOR  ${nrcel_dn}  IN  @{NRCEL_SHORT_DN_LIST}
      ${fault_details}  FM Await For Fault
      ...  fault_attr=faultId=${TRUE_FORMULA['faultID']}, severity=Minor, faultName="${faultName}", alarmingObjectIds[0].configuration=${nrcel_dn}
      ...  timeout=${timeout}
      ...  alarm_resource=${FAULT_4569_4588}
      ...  node_id=${BTS_ID}
      ${fault_attr_list}  Split String  ${fault_details}  ,${SPACE}
      ${btsObservationTime_key}  ${btsObservationTime_value}  Split String  ${fault_attr_list[-1]}  =  1
      ${btsObservationTime}  Fetch From Left  ${btsObservationTime_value}  +
      ${time}  Subtract Date From Date  ${btsObservationTime}  ${KPI_ALARM_ACT_TIME}
      ${min_time}  Evaluate  ${TRUE_FORMULA['timeToTrigger']}*57
      ${fault_apear_time_status}  Run Keyword And Return Status  Should Be True  ${min_time} <= ${time} <= ${timeout}
      Run Keyword If  ${fault_apear_time_status}
      ...  Logging With Timestamp
      ...  message=Fault for cell ${nrcel_dn} Appeared in correct time -> ${time}s <${min_time},${timeout}>
      ...  ELSE
      ...  Logging With Timestamp
      ...  message=Fault for cell ${nrcel_dn} Appeared in INCORRECT!!! time -> ${time}s <${min_time},${timeout}>
      ...  style=FAIL
    END
    FM Check Unexpected Active Faults  node_id=${BTS_ID}

Step 4 Change ActKpiAlarms Parameter To False
    Logging With Timestamp
    ...  message=Step 4 Change ActKpiAlarms Parameter To False
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp  message=Updating actKpiAlarms parameter to false ...
    ...  style=ONGOING
    admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...  parameter=actKpiAlarms
    ...  operation=update
    ...  value=false
    ...  connection=${BTS_ID}
    Logging With Timestamp  message=Updating actKpiAlarms parameter to false ...
    ...  style=DONE

Step 5 Check If Alarms Are Cleared And BTS Status Is As Expected
    Logging With Timestamp
    ...  message=Step 5 Check If Alarms Are Cleared And BTS Status Is As Expected
    ...  style=STEP
    ...  frame=${TRUE}
    STATE Verify BTS states  ${BTS_ID}
    FOR  ${nrcel_dn}  IN  @{NRCEL_SHORT_DN_LIST}
      FM Await For Fault Cleared
      ...  fault_attr=faultId=${TRUE_FORMULA['faultID']}, severity=Minor, alarmingObjectIds[0].configuration=${nrcel_dn}
      ...  node_id=${BTS_ID}
    END
    Remove All KPI Alarms From kpiAlarmTriggers List

Remove All KPI Alarms From kpiAlarmTriggers List
    Create Delta  delta_id=empty
    admin.Append Parameter Update To Delta
    ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...  parameter=kpiAlarmTriggers
    ...  value=@{EMPTY}
    ...  delta_id=empty
    admin.Save Delta
    ...  target_file_name=${CFG.test_logs_path}/BTSFiles/delta_empty.json
    ...  delta_id=empty
    Logging With Timestamp  message=Removing KPI Alarms From kpiAlarmTriggers List ...
    ...  style=ONGOING
    admin.Perform Delta Recommissioning
    ...  delta_file=${CFG.test_logs_path}/BTSFiles/delta_empty.json
    ...  delta_id=empty
    ...  connection=${BTS_ID}
    admin.Remove Delta  delta_id=empty
    Logging With Timestamp  message=Removing KPI Alarms From kpiAlarmTriggers List ...
    ...  style=DONE

Recovery For KPI Triggering Faults
    Run Keyword If  ${KPI_ALARM_EXIST}  Run Keywords  Run Keyword And Ignore Error
    ...  Logging With Timestamp  message=Perform Commissioning to restore configuration ...
    ...  style=ONGOING
    ...  AND
    ...  admin.Perform Commissioning  bts_id=${BTS_ID}
    ...  scf_file=${cfg['NODES']['${BTS_ID}']['scf_file_path']}
    ...  should_activate=True
    ...  connection=${BTS_ID}
    ...  AND
    ...  Logging With Timestamp  message=Perform Commissioning finish with success
    ...  style=DONE
    ...  AND
    ...  STATE Verify BTS states  ${BTS_ID}
    ...  ELSE  Run Keywords  Run Keyword And Ignore Error
    ...  Logging With Timestamp  message=Disable actKpiAlarms and removing kpiAlarmTriggers List ...
    ...  style=ONGOING
    ...  AND
    ...  admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...  parameter=actKpiAlarms
    ...  operation=update
    ...  value=false
    ...  connection=${BTS_ID}
    ...  AND
    ...  Remove All KPI Alarms From kpiAlarmTriggers List
    ...  AND
    ...  Logging With Timestamp  message=Disable actKpiAlarms and removing kpiAlarmTriggers List ...
    ...  style=DONE

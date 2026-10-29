*** Settings ***
Documentation
    ...  This TC is performing FMCADM and EAC objects recommissionings. FMCADM object will be updated by adding alToggSuppList with
    ...  alToggAmount=2 and alToggClearenceTime=180. Creation of EAC object will determine 1404 fault to appear.
    ...  EAC object will be created twice to cause 1404 toggling appearance according to alToggAmount value.
    ...  1404 toggling must be active 180 seconds from deleting EAC object for the second time. TC will wait 120 seconds from this
    ...  deletion and 1404 toggling must be still active.
    ...  Then, TC will wait 60 seconds and 1404 toggling must be inactive and present in alarm history list.
    ...  In the end, alToggSuppList from FMCADM object and EAC object will be removed.
    ...  After creating and deleting EAC object and alToggSuppList, all cells are verified and must be onAir.

Resource  ../../common_resources/ca_FM_general.robot


*** Keywords ***
TC__FM__Suppression_of_toggling_external_alarm
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21646
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21646 - Initial TAT creation
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  - 24.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28760 - alToggSuppList parameter not found
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS21

    Step1: Add AlToggSuppList To FMCADM Object With Delta Recommissioning
    Step2: Check All Cells And Alarms Status
    Step3: Create EAC Object With Delta Recommissioning
    Step4: Check All Cells, Alarms Status And 1404 Fault Active
    Step5: Delete EAC Object With Delta Recommissioning
    Step6: Check All Cells And Alarms Status
    Step7: Create EAC Object With Delta Recommissioning
    Step8: Check All Cells, Alarms Status And 1404 Toggling Active
    Step9: Delete EAC Object With Delta Recommissioning
    Step10: Check All Cells, Alarms Status And 1404 Toggling Active Within 120s From Deleting EAC Object
    Step11: Sleep 180s From Deleting EAC Object
    Step12: Check 1404 Toggling Inactive And Verify All Cells And Alarms Status
    Step13: Delete AlToggSuppList From FMCADM Object With Delta Recommissioning
    Step14: Check All Cells And Alarms Status


Step1: Add AlToggSuppList To FMCADM Object With Delta Recommissioning
    Log  \nStep1: Add alToggSuppList to FMCADM object with delta recommissioning  console=true
    Set ALTOGGSUPP Path
    Create Or Update ALTOGGSUPP Object  create  al_togg_amount=2  al_togg_clearence_time=180  al_togg_conditon_time=360  fault_id=1404  in_use=true


Step2: Check All Cells And Alarms Status
    Log  \nStep2: Check all cells and alarms status  console=true
    Check All Cells And Alarms Status


Step3: Create EAC Object With Delta Recommissioning
    Log  \nStep3: Create EAC object with delta recommissioning  console=true
    Create EAC Object


Step4: Check All Cells, Alarms Status And 1404 Fault Active
    Log  \nStep4: Check all cells, alarms status and 1404 fault active  console=true
    ${fault_id}  Convert To String  1404
    ${1404_fault}  Create Dictionary  faultId=${fault_id}  faultName=ext-Al-1
    Append To List  ${GLOBALLY_IGNORED_ALARMS}  ${1404_fault}
    Check All Cells And Alarms Status
    Remove Values From List  ${GLOBALLY_IGNORED_ALARMS}  ${1404_fault}
    Check Fault Active  fault_id=1404  alarm_id=7103  fault_name="ext-Al-1"  timeout=60


Step5: Delete EAC Object With Delta Recommissioning
    Log  \nStep5: Delete EAC object with delta recommissioning  console=true
    Delete EAC Object
    Check Fault Inactive  fault_id=1404  alarm_id=7103  fault_name="ext-Al-1"  timeout=60


Step6: Check All Cells And Alarms Status
    Log  \nStep6: Check all cells and alarms status  console=true
    Check All Cells And Alarms Status


Step7: Create EAC Object With Delta Recommissioning
    Log  \nStep7: Create EAC object with delta recommissioning  console=true
    Create EAC Object


Step8: Check All Cells, Alarms Status And 1404 Toggling Active
    Log  \nStep8: Check all cells, alarms status and 1404 toggling active  console=true
    ${fault_id}  Convert To String  4026
    ${1404_toggling}  Create Dictionary  faultId=${fault_id}  faultName=Toggling: ext-Al-1 (1404)
    Append To List  ${GLOBALLY_IGNORED_ALARMS}  ${1404_toggling}
    Check All Cells And Alarms Status
    Check Fault Active  fault_id=4026  alarm_id=7103  fault_name="Toggling: ext-Al-1 (1404)"  timeout=60


Step9: Delete EAC Object With Delta Recommissioning
    Log  \nStep9: Delete EAC object with delta recommissioning  console=true
    Delete EAC Object
    @{deleting_eac_obj_time}  Get Time  hour min sec
    Set Test Variable  ${DELETING_EAC_OBJ_TIME}


Step10: Check All Cells, Alarms Status And 1404 Toggling Active Within 120s From Deleting EAC Object
    Log  \nStep10: Check all cells, alarms status and 1404 toggling active within 120s from deleting EAC object  console=true
    Check All Cells And Alarms Status
    @{current_time}  Get Time  hour min sec
    ${time_diff}  Subtract Time From Time  ${current_time}[0]:${current_time}[1]:${current_time}[2]
    ...  ${DELETING_EAC_OBJ_TIME}[0]:${DELETING_EAC_OBJ_TIME}[1]:${DELETING_EAC_OBJ_TIME}[2]  timer  exclude_millis=yes
    ${minutes_for_sleeping}  Subtract Time From Time  00:02:00  ${time_diff}
    ${minutes_int_value}  Convert To Integer  ${minutes_for_sleeping}
    Log  Sleep for ${minutes_int_value}s.  console=true
    Sleep  ${minutes_int_value}s
    Check Fault Active  fault_id=4026  alarm_id=7103  fault_name="Toggling: ext-Al-1 (1404)"  timeout=60


Step11: Sleep 180s From Deleting EAC Object
    Log  \nStep11: Sleep 180s from deleting EAC object  console=true
    @{current_time}  Get Time  hour min sec
    ${time_diff}  Subtract Time From Time  ${current_time}[0]:${current_time}[1]:${current_time}[2]
    ...  ${DELETING_EAC_OBJ_TIME}[0]:${DELETING_EAC_OBJ_TIME}[1]:${DELETING_EAC_OBJ_TIME}[2]  timer  exclude_millis=yes
    ${minutes_for_sleeping}  Subtract Time From Time  00:03:00  ${time_diff}
    ${minutes_int_values}  Convert To Integer  ${minutes_for_sleeping}
    Log  Sleep for ${minutes_int_values}s.  console=true
    Sleep  ${minutes_int_values}s


Step12: Check 1404 Toggling Inactive And Verify All Cells And Alarms Status
    Log  \nStep12: Check 1404 toggling inactive and verify all cells and alarms status  console=true
    Check If Fault Is Present In Alarm History List  fault_id=4026  fault_name=Toggling: ext-Al-1 (1404)
    ${fault_id}  Convert To String  4026
    ${1404_toggling}  Create Dictionary  faultId=${fault_id}  faultName=Toggling: ext-Al-1 (1404)
    Remove Values From List  ${GLOBALLY_IGNORED_ALARMS}  ${1404_toggling}
    Check All Cells And Alarms Status


Step13: Delete AlToggSuppList From FMCADM Object With Delta Recommissioning
    Log  \nStep13: Delete alToggSuppList from FMCADM object with delta recommissioning  console=true
    Delete ALTOGGSUPP Object


Step14: Check All Cells And Alarms Status
    Log  \nStep14: Check all cells and alarms status  console=true
    Check All Cells And Alarms Status


Create EAC Object
    ${eac_path}  Set Variable  MRBTS-${bts_id}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-5
    ${new_values}  Create Dictionary  descr=ext-Al-1  inUse=true  polarity=Normally_closed  portId=5  severity=Major
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  ${eac_path}  create  ${delta_id}
    Append Parameter Update To Delta  ${eac_path}  descr  ${new_values}[descr]  ${delta_id}
    Append Parameter Update To Delta  ${eac_path}  inUse  ${new_values}[inUse]  ${delta_id}
    Append Parameter Update To Delta  ${eac_path}  polarity  ${new_values}[polarity]  ${delta_id}
    Append Parameter Update To Delta  ${eac_path}  portId  ${new_values}[portId]  ${delta_id}
    Append Parameter Update To Delta  ${eac_path}  severity  ${new_values}[severity]  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}
    Remove File  ${BTS_FILES}/delta.json


Delete EAC Object
    ${eac_path}  Set Variable  MRBTS-${bts_id}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-5
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  ${eac_path}  delete  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}
    Remove File  l${BTS_FILES}/delta.json


Check All Cells And Alarms Status
    ${status}  Run Keyword And Return Status
    ...  Check All Cells
    IF  ${status}
      Log  All cells are onAir [OK].  console=true
    ELSE
      Set Test Failed  All cells are not onAir [NOK].
    END
    Check If Unexpected Alarms Are Present


Check If Unexpected Alarms Are Present
    ${fault_list}  Create List
    ${active_alarms}  coam.Get Active Alarms
    FOR  ${alarm}  IN  @{active_alarms}
        ${fault_id}  Convert To String  ${alarm}[faultId]
        ${fault_dict}  Create Dictionary  faultId=${fault_id}  faultName=${alarm}[faultName]
        Append To List  ${fault_list}  ${fault_dict}
    END
    FOR  ${fault}  IN  @{fault_list}
        Check If Active Fault Is Present In Ignored Alarm List  ${GLOBALLY_IGNORED_ALARMS}  ${fault}
    END


Check If Active Fault Is Present In Ignored Alarm List
    [Arguments]  ${alarms_list}  ${fault}

    FOR  ${alarm}  IN  @{alarms_list}
        ${fault_id_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${fault}[faultId]  ${alarm}[faultId]
        ${fault_name_status}  Run Keyword And Return Status
        ...  Should Contain  ${fault}[faultName]  ${alarm}[faultName]
        IF  ${fault_id_status} and ${fault_name_status}  Return From Keyword
    END
    Set Test Restriction  Unexpected fault: ${fault}[faultId], ${fault}[faultName].


Check Fault Active
    [Arguments]  ${fault_id}  ${alarm_id}  ${fault_name}  ${timeout}

    Check Alarm In WebEM  fault_id=${fault_id}  alarm_id=${alarm_id}  fault_name=${fault_name}  timeout=${timeout}  fault_status=active


Check Fault Inactive
    [Arguments]  ${fault_id}  ${alarm_id}  ${fault_name}  ${timeout}

    Check Alarm In WebEM  fault_id=${fault_id}  alarm_id=${alarm_id}  fault_name=${fault_name}  timeout=${timeout}  fault_status=inactive


Check Alarm In WebEM
    [Arguments]  ${fault_id}  ${alarm_id}  ${fault_name}  ${timeout}  ${fault_status}

    ${web_em_fault_status}  Run Keyword And Return Status
    ...  Assert Alarm ${fault_status}  faultId=${fault_id}, alarmId=${alarm_id}, faultName=${fault_name}  timeout=${timeout}
    IF  ${web_em_fault_status}
      Log  Fault ${faultid}: ${fault_name} is ${fault_status} in WebEM [OK].  console=true
    ELSE
      Set Test Restriction  Fault ${fault_id}: ${fault_name} is not ${fault_status} in WebEM [NOK].
    END


Check If Fault Is Present In Alarm History List
    [Arguments]  ${fault_id}  ${fault_name}

    ${historical_alarms}  coam.Get_historic_alarms
    FOR  ${alarm}  IN  @{historical_alarms}
        ${fault_id_status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[faultId]  ${fault_id}
        ${fault_name_status}  Run Keyword And Return Status
        ...  Should Contain  ${alarm}[faultName]  ${fault_name}
        IF  ${fault_id_status} and ${fault_name_status}
          Log  Fault ${fault_id}: "${fault_name}" is inactive in WebEM [OK].  console=true
          Return From Keyword
        END
    END
    Set Test Restriction  Fault ${fault_id}: "${fault_name}" is not inactive in WebEM [NOK].


Perform Backup Recommissioning
    Log  Perform backup recommissioning.  console=true
    Delete ALTOGGSUPP Object
    Delete EAC Object


TC Setup
    Common Test Setup  tc_name=FM__Suppression_of_toggling_external_alarm


TC Teardown
    Run Keyword If Test Failed
    ...  Perform Backup Recommissioning
    Common Test Teardown

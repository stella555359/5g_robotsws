*** Settings ***
Documentation
    ...  This TC is performing 5 plans of delta recommissioning for GTPU and FMCADM objects. Those plans follow
    ...  the corresponding lists.
    ...  Plan 1 represents the backup plan and it updates the GTPU object with correct values and deletes
    ...  alToggSuppList from FMCADM object.
    ...  After provisioning plan 2 and plan 3, 4026 fault must appear and dissapear after 180s. After 4026, 6150 fault
    ...  will be active. Then plan 4 is performed and 6150 fault is cleared.
    ...  Next, plan 5, plan 3, plan 4 and plan 3 again are performed because the toggling amount is 2 in this case and
    ...  GTPU link must be broken twice for 4026 fault to appear.
    ...  Plan 4 is performed and after 180s 4026 fault is cleared.
    ...  In the end, backup plan (plan 1) is performed.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  360  # [in seconds] Timeout for alarm to be reported in WebEM.
${NETACT_TIMEOUT}  240  # [in seconds] Timeout for alarm to be reported in Netact.


*** Keywords ***
TC__FM__Suppression_of_toggling_transport_alarms
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21644
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21644 - Initial TAT creation
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 01.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22577 - ta_netact_* libary replacement with taf.nms.netact
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 25.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25417 - Use Admin Get LNBTS ID from sbts_admin
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  - 24.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28760 - alToggSuppList parameter not found
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS21

    Step0: Check If LTE Cells Exist
    Step1: Create GTPU Object And Check LTE Cells If Needed
    Step2: Perform Provisioning Of Plan_1
    Step3: Check LTE Cells And Alarms
    Step4: Perform Provisioning Of Plan_2 And Plan_3
    Step5: Check Toggling 4026
    Step6: Perform Provisioning Of Plan_4 And Fault 4026 Is Cleared
    Step7: Perform Provisioning Of Plan_5 And Plan_3
    Step8: Check Toggling 4026
    Step9: Clearing Alarm By Performing Provisioning Plan_4
    Step10: Perform Recovery By Provisioning Plan_1
    Step11: Check LTE Cells And Alarm Status


Step0: Check If LTE Cells Exist
    IF  ${SCF_COUNT_LTE} == 0  Fail  LTE cells don't exist and breaking GTPU link is not possible.


Step1: Create GTPU Object And Check LTE Cells If Needed
    Log  \nStep1: Create GTPU object and check LTE cells if needed  console=true
    ${status_gtpu}  Run Keyword And Return Status
    ...  Verify If GTPU Link Exists
    IF  ${status_gtpu}
      Log  GTPU object aready exists.  console=true
    ELSE
      Create GTPU Object
      Check LTE Cells And Alarms Status
    END
    Set ALTOGGSUPP Path


Step2: Perform Provisioning Of Plan_1
    Log  \nStep2: Perform provisioning of plan_1  console=true
    Set Test Variable  ${BACKUP_PLAN}  1
    Perform Plan_1 Recommissioning


Step3: Check LTE Cells And Alarms
    Log  \nStep3: Check LTE cells and alarms  console=true
    Check LTE Cells And Alarms Status


Step4: Perform Provisioning Of Plan_2 And Plan_3
    Log  \nStep4: Perform provisioning of plan_2 and plan_3  console=true
    ${date}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${date}
    Perform Plan_2 Recommissioning FMCADM
    Perform Plan_3 Recommissioning


Step5: Check Toggling 4026
    Log  \nStep5: Check toggling 4026  console=true

    ${FAULT_4026_OTHER_FAULT_NAME}  Copy Dictionary  ${FAULT_4026}
    Remove From Dictionary  ${FAULT_4026_OTHER_FAULT_NAME}  fault_name
    Set To Dictionary  ${FAULT_4026_OTHER_FAULT_NAME}  fault_name=Toggling: GTP-U Path Failure
    Set Test Variable  ${FAULT_4026_OTHER_FAULT_NAME}

    ${fault_4026_params}  Get String With Alarm Parameters  ${FAULT_4026}
    Assert Alarm Active  parameters=${fault_4026_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4026} is active in WebEM.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4026_OTHER_FAULT_NAME}  additional_fault_id=${FAULT_6150}[fault_id]
    ...  suppl_info=Transport network identifier: 0
    Log  Fault ${FAULT_4026} is active in Netact.  console=true

    Log  Wait for fault 4026 to be inactive.  console=true
    Assert Alarm Inactive  parameters=${fault_4026_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4026} is inactive in WebEM.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4026_OTHER_FAULT_NAME}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_6150}[fault_id]  suppl_info=Transport network identifier: 0
    Log  Fault ${FAULT_4026} is cleared in Netact.  console=true

    Log  Wait for fault 6150 to be active.  console=true
    ${fault_6150_params}  Get String With Alarm Parameters  ${FAULT_6150}
    Assert Alarm Active  parameters=${fault_6150_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_6150} is active in WebEM.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_6150}  additional_fault_id=${FAULT_6150}[fault_id]
    ...  suppl_info=Transport network identifier: 0
    Log  Fault ${FAULT_6150} is active in Netact.  console=true


Step6: Perform Provisioning Of Plan_4 And Fault 4026 Is Cleared
    Log  \nStep6: Perform provisioning of plan_4 and fault 4026 is cleared  console=true
    Perform Plan_4 Recommissioning

    Log  Wait for fault 6150 to be inactive.  console=true
    ${fault_6150_params}  Get String With Alarm Parameters  ${FAULT_6150}
    Assert Alarm Inactive  parameters=${fault_6150_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_6150} is inactive in WebEM.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_6150}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_6150}[fault_id]  suppl_info=Transport network identifier: 0
    Log  Fault ${FAULT_6150} is cleared in Netact.  console=true

    Check If Unexpected Alarms Are Present
    Check If Alarms From WebEM And NetAct Are The Same


Step7: Perform Provisioning Of Plan_5 And Plan_3
    Log  \nStep7: Perform provisioning of plan_5 and plan_3  console=true
    Perform Plan_5 Recommissioning FMCADM
    Perform Plan_3 Recommissioning
    Perform Plan_4 Recommissioning
    Perform Plan_3 Recommissioning


Step8: Check Toggling 4026
    Log  \nStep8: Check fault toggling 4026  console=true
    ${fault_4026_params}  Get String With Alarm Parameters  ${FAULT_4026}
    Assert Alarm Active  parameters=${fault_4026_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4026} is active in WebEM.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4026_OTHER_FAULT_NAME}  additional_fault_id=${FAULT_6150}[fault_id]
    ...  suppl_info=Transport network identifier: 0
    Log  Fault ${FAULT_4026} is active in Netact.  console=true


Step9: Clearing Alarm By Performing Provisioning Plan_4
    Log  \nStep9: Clearing alarm by performing provisioning plan_4  console=true
    Perform Plan_4 Recommissioning
    Log  Wait for fault 4026 to be inactive.  console=true
    ${fault_4026_params}  Get String With Alarm Parameters  ${FAULT_4026}
    Assert Alarm Inactive  parameters=${fault_4026_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4026} is inactive in WebEM.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4026_OTHER_FAULT_NAME}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_6150}[fault_id]  suppl_info=Transport network identifier: 0
    Log  Fault ${FAULT_4026} is cleared in Netact.  console=true
    Check If Unexpected Alarms Are Present
    Check If Alarms From WebEM And NetAct Are The Same


Step10: Perform Recovery By Provisioning Plan_1
    Log  \nStep10: Perform recovery by provisioning plan_1  console=true
    Perform Backup Plan  ${BACKUP_PLAN}


Step11: Check LTE Cells And Alarm Status
    Log  \nStep11: Check LTE cells and alarm status  console=true
    Check LTE Cells And Alarms Status


Check LTE Cells And Alarms Status
    ${status}  Run Keyword And Return Status
    ...  Check LTE Cells  ${UNBLOCKED}  ${ENABLED}
    IF  ${status}
      Log  4G cells are onAir [OK].  console=true
    ELSE
      Set Test Failed  4G cells are not onAir [NOK].  console=true
    END
    Check If Unexpected Alarms Are Present
    Check If Alarms From WebEM And NetAct Are The Same


Check LTE Cells
    [Arguments]  ${blocking_state}  ${operational_state}

    IF  ${SCF_COUNT_LTE}  Assert Every  LNCEL  blockingState=${blocking_state}, operationalState=${operational_state}  timeout=60


Check If Unexpected Alarms Are Present
    [Arguments]  ${expected_alarms}=@{EMPTY}  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}

    ${alarms_status}  ${alarms_msg}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  expected_patterns=${expected_alarms}  ignored_patterns=${ignored_alarms}
    ...  critical_patterns=${critical_alarms}
    IF  '${alarms_status}'=='FAIL'
      Log  Critical fail while checking alarms: ${alarms_msg}  console=true
    ELSE IF  ${alarms_msg}
      Set Test Restriction  Unexpected alarms are present: ${alarms_msg}
    END


Verify If GTPU Link Exists
    ${gtpu_obj_status}  Query Infomodel  check //GTPU_R-*  allow_negative_result=True
    Should Be Equal  ${gtpu_obj_status}  ${TRUE}


Create GTPU Object
    Log  GTPU object creation is performing.  console=true
    ${bts_id}  Admin Get BTS ID
    ${lnbts_id}  Admin Get LNBTS ID
    ${delta_id}  Set Variable  1
    ${new_values}  Create Dictionary  gtpuN3Reqs=5  gtpuPathSupint=60  gtpuT3Resp=2  sgwIpAddress=10.5.23.136  transportNwId=0
    ...  udpMaxDatagramSize=1395
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU  create  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU-1  gtpuN3Reqs  ${new_values}[gtpuN3Reqs]  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU-1  gtpuPathSupint  ${new_values}[gtpuPathSupint]  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU-1  gtpuT3Resp  ${new_values}[gtpuT3Resp]  ${delta_id}
    ${structure1}  Create Dictionary
    Set To Dictionary  ${structure1}  sgwIpAddress  ${new_values}[sgwIpAddress]
    Set To Dictionary  ${structure1}  transportNwId  ${new_values}[transportNwId]
    Append Complex Item To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU-1  list_name=sgwIpAddressList  &{structure1}  delta_id=${delta_id}
    Append Parameter Update To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU-1  udpMaxDatagramSize  ${new_values}[udpMaxDatagramSize]  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}
    Remove File  ${BTS_FILES}/delta.json


Perform Plan_${index} Recommissioning
    Log  Plan_${index}-GTPU object update is performing.  console=true
    ${bts_id}  Admin Get BTS ID
    ${lnbts_id}  Admin Get LNBTS ID
    ${gtpu_id}  Get GTPU ID
    ${delta_id}  Set Variable  1
    ${new_values_plan_1}  Create Dictionary  sgwIpAddress=10.5.23.136  transportNwId=0
    ${new_values_plan_3}  Create Dictionary  sgwIpAddress=111.111.111.111  transportNwId=0
    ${new_values_plan_4}  Create Dictionary  sgwIpAddress=10.5.23.136  transportNwId=0
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU-${gtpu_id}  update  ${delta_id}
    ${structure1}  Create Dictionary
    Set To Dictionary  ${structure1}  sgwIpAddress  ${NEW_VALUES_PLAN_${index}}[sgwIpAddress]
    Set To Dictionary  ${structure1}  transportNwId  ${NEW_VALUES_PLAN_${index}}[transportNwId]
    Append Complex Item To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/GTPU-${gtpu_id}  list_name=sgwIpAddressList  &{structure1}  delta_id=${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}
    IF  ${index}==1  Run Keyword And Ignore Error  Delete ALTOGGSUPP Object


Perform Plan_${index} Recommissioning FMCADM
    Log  Plan_${index}-FMCADM object update is performing.  console=true

    IF  ${index}==2
      Create Or Update ALTOGGSUPP Object  create  al_togg_amount=1  al_togg_clearence_time=180  al_togg_conditon_time=120  fault_id=6150
      ...  in_use=true
    END
    IF  ${index}==5
      Create Or Update ALTOGGSUPP Object  update  al_togg_amount=2  al_togg_clearence_time=180  al_togg_conditon_time=666  fault_id=6150
       ...  in_use=true
    END


Perform Backup Plan
    [Arguments]  ${backup_plan}

    Log  Perform backup plan.  console=true
    Perform Plan_${backup_plan} Recommissioning


TC Setup
    Common Test Setup  tc_name=FM__Suppression_of_toggling_transport_alarms
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed
    ...  Perform Backup Plan  ${BACKUP_PLAN}
    Teardown NetAct
    Common Test Teardown

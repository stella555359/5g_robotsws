*** Settings ***
Documentation
    ...    Author: cristinel.sava@nokia.com
Library    XML    use_lxml=${TRUE}
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  1200
${EXPECTED_ERROR}    *Request rejected as another snapshot collection is ongoing*


*** Keywords ***
TC__LOGS__Snapnshot_Collection_Triggered_By_Fault
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-14663
    ...  ******************
    ...  Author: Lukasz Targonski
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2019-03-01 - https://jira3.int.net.nokia.com/browse/TAT-12131 - Initial Creation
    ...  - 2020-04-16 - https://jira3.int.net.nokia.com/browse/TAT-17558
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2022-12-16 - https://jiradc.ext.net.nokia.com/browse/TAT-24325 - Added functionality of checking if only 1 snapshot can be collected
    ...                 at time, based on 2 tests transfered from BOAM ET:
    ...                 "Testability_LTE1099_Event-Triggered_Symptom_Data_Collection_SEM_Snapshot_fails" and
    ...                 "Testability_LTE1099_Event-Triggered_Symptom_Data_Collection_OMS_Snapshot_fails"
    ...  - 2023-10-03 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 2023-05-17 - TAT-25384 - list_name= param added to KW AppendComplexItemToDelta
    ...  - 2023-01-03 - change NetAct integration KW and variables
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if snapshot is automatically triggered when fault 49 is detected. Fault is
    ...  added to faultSnapshotTriggers list and reported after cell block operation. This test case check only if snapshot is
    ...  triggered but it is not checking if it is correctly saved in the remote location.
    ...  *******************
    ...  Test case flowchart: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Snapshot_Collection_Triggered_By_Fault.png
    ...  *******************


    Set Tags    CA-LOGS    OWNER-lukasz.targonski@nokia.com    AUTHOR-lukasz.targonski@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS17

    Step 0: Preconditions
    Step 1: Configure Fault Snapshot Trigger
    Step 2: Perform Cell Block To Trigger Snapshot
    Step 3: Check If Snapshot Is Collected
    Step 4: Check If Only One Snapshot Can Be Collected At Once - Reverse Scenario


Step 0: Preconditions
    Log  \nPreconditions  console=${True}
    ${bts_connection}=  coam.connect_to
    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}
    Check if NetAct is deintegrated
    Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${False}
    Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${False}
    Set Test Variable  ${CELL_ADDED}  ${False}
    Set Test Variable  ${BTS_CONNECTION}  ${bts_connection}
    Set Snapshot Destination To  NetAct

Step 1: Configure Fault Snapshot Trigger
    [Documentation]
    ...  In this test step faultSnapshotTriggers list for fault 49 is created and added to configuration.

    Log  \nStep 1: Configure Fault Snapshot Trigger  console=${True}
    coam.Get Current Scf File  ${BTS_Files}  scf.xml  export_type=configuration
    ${SCF}  Parse Xml  ${BTS_Files}/scf.xml
    Set Test Variable  ${SCF}
    ${trblcadm_element}  Evaluate Xpath  ${SCF}  //managedObject[contains(@class, 'TRBLCADM')]
    ${delta_id}  Set Variable  fault
    coam.Create Delta  ${delta_id}
    ${mnlent_element}  Evaluate Xpath  ${SCF}  //managedObject[contains(@class, 'MNLENT')]
    ${MNLENT_DISTNAME}  XML.Get Element Attribute  ${mnlent_element[0]}  distName
    Set Test Variable  ${MNLENT_DISTNAME}
    Run Keyword If  '${trblcadm_element}'=='[]'
    ...  Create Trblcadm Mo  ${delta_id}
    ...  ELSE  Create Fault Snapshot Triggers  ${delta_id}

Step 2: Perform Cell Block To Trigger Snapshot
    [Documentation]
    ...  In this test step cell block operation is performed to activate fault 49.
    ...  Activation of fault 49 will cause snapshot to automatically trigger.

    Log  \nStep 2: Perform Cell Block To Trigger Snapshot  console=${True}
    Check NetAct connection and reintegrate if needed   ${NETACT_LAB.cmwas}   ${enb_release}   600
    ${CELL_DISTNAME}  Get Cell Distname
    Set Test Variable  ${CELL_DISTNAME}
    Log  Cell with distname ${CELL_DISTNAME} will be blocked  console=${True}
    ${block_result}  Run Keyword And Ignore Error  coam.Block Cell  ${CELL_DISTNAME}
    Run Keyword If  '${block_result[0]}'=='FAIL'
    ...  verdicts.Set Test Failed  Cell block operation unsuccessful.  ${TRUE}
    ...  ELSE  Run Keywords  Log  Cell block operation successful.  console=${True}
    ...  AND  Set Test Variable  ${CELL_ADDED}  ${True}

Step 3: Check If Snapshot Is Collected
    [Documentation]
    ...  In this test step it is checked if snapshot is triggered by fault 49 and collection is finished.
    ...  When collection is in progress, second snapshot is requested using Admin API. BTS should reject second snapshot request.

    Log  \nStep 3: Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel
    ...  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"49:On fault detection",stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by fault.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered by fault.  ${TRUE}

    Log  \nChecking functionality that only 1 snapshot can be collected in given time.  console=${True}
    Log  \nSecond snapshot will be triggered using Admin Api.    console=${True}
    Run Keyword And Expect Error  ${EXPECTED_ERROR}  coam.Collect Snapshot  ${BTS Files}/LocalSnapshot.zip
    Log  \nSecond snapshot was rejected as expected  console=${True}

    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot triggered by fault 49 to collect.  console=${True}
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"49:On fault detection"]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}
    coam.Unblock Cell  ${CELL_DISTNAME}
    Set Test Variable  ${CELL_ADDED}  ${False}
    Sleep  30

Step 4: Check If Only One Snapshot Can Be Collected At Once - Reverse Scenario
    [Documentation]
    ...  In this test step it is checked if only one snapshot can be collected in given time.
    ...  First snapshot will be triggered by Admin Api, second snapshot by generating fault 49. BTS should reject second snapshot request.

    Log  \nStep 4: Check If Only 1 Snapshot Can Be Collected In Given Time - Reverse Scenario  console=${True}
    Log  \nTriggering Snapshot with Admin Api  console=${True}
    ${second_connection}  coam.Connect To  name=second_connection
    coam.Run_Keyword_In_Background  Collect Snapshot  ${BTS Files}/LocalSnapshot2.zip  connection=second_connection
    ${local_snapshot_status}  Query Infomodel  check /MRBTS-*/RAT-*/ASM-*/TECHREP_L-*/SNAPSHOT-* is [originator=ADMIN,stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${local_snapshot_status}
    ...  Log  Local Snapshot was triggered.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered.  ${TRUE}
    Log  Cell with distname ${CELL_DISTNAME} will be blocked to trigger second snapshot  console=${True}
    coam.Block Cell  ${CELL_DISTNAME}
    Set Test Variable  ${CELL_ADDED}  ${True}
    Wait Until Keyword Succeeds  2m  5s  coam.Assert Alarm Active  faultId=49
    Log  \nAlarm 49 is raised
    ${second_snapshot_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"49:On fault detection"]  timeout=60
    Run Keyword If  ${second_snapshot_status}
    ...  Log  \nSecond Snapshot, triggered by fault is not collecting - as expected.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Second Snapshot was triggered.  ${TRUE}

    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for local snapshot to collect.  console=${True}
    ${local_snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=ADMIN,stateInfo.usageState=Active]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${local_snapshot_collection_status}
    ...  Log  Local snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Local snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}
    OperatingSystem.File Should Exist  ${BTS Files}/LocalSnapshot2.zip

Create Trblcadm Mo
    [Arguments]  ${delta_id}
    Log  Adding TRBLCADM managed object to configuration  console=${True}
    coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  create  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actCoreDumpFileCollection  true  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actRemoteSyslogTransmission  false  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  snapshotUploadDelayForFault6450  0  ${delta_id}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${True}
    Create Fault Snapshot Triggers  ${delta_id}

Create Fault Snapshot Triggers
    [Arguments]  ${delta_id}
    ${fault_snapshot_triggers_dict}  Create Dictionary  faultNumber=49  triggerType=onFaultDetection
#    ${fault_snapshot_trigger}  Evaluate Xpath  ${SCF}  //p[@name='faultNumber' and text()='49']
#    Run Keyword If  '${fault_snapshot_trigger}'=='[]'  Run Keywords
     Log  Adding faultSnapshotTriggers list for fault 49 to configuration.  console=${True}
     coam.Append Complex Item To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  list_name=faultSnapshotTriggers    &{fault_snapshot_triggers_dict}
     ...  delta_id=${delta_id}
     coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actDefaultFaultSnapTriggers  false  ${delta_id}
     coam.Get Delta  ${delta_id}
     coam.Save Delta  ${BTS Files}/delta.json  ${delta_id}
     coam.Perform delta recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=${True}
     Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${True}

Get Cell Distname
    ${lncell_m_objects}  Query Infomodel  get list //LNCEL_R-*  allow_negative_result=True
    Run Keyword If  ${lncell_m_objects}
    ...  Return From Keyword  ${lncell_m_objects[0]['dist_name']}
    ${wncell_m_objects}  Query Infomodel  get list //WNCEL_R-*  allow_negative_result=True
    Run Keyword If  ${wncell_m_objects}
    ...  Return From Keyword  ${wncell_m_objects[0]['dist_name']}
    ${gncell_m_objects}  Query Infomodel  get list //GNCEL_R-*  allow_negative_result=True
    Run Keyword If  ${gncell_m_objects}
    ...  Return From Keyword  ${gncell_m_objects[0]['dist_name']}
    ${nrcell_m_objects}  Query Infomodel  get list //NRCELL_R-*  allow_negative_result=True
    Run Keyword If  ${nrcell_m_objects}
    ...  Return From Keyword  ${nrcell_m_objects[0]['dist_name']}

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}

    Run Keyword If  ${CELL_ADDED}  Run Keywords
    ...  Log  Cell with distname ${CELL_DISTNAME} will be unblocked  console=${True}
    ...  AND  coam.Unblock Cell  ${CELL_DISTNAME}

    ${delta_id}  Set Variable  teardown
    coam.Create Delta  ${delta_id}

    Run Keyword If  ${TRBLCADM_MO_ADDED} and ${FAULT_SNAPSHOT_TRIGGER_ADDED}  Run Keywords
    ...  Log  Removing TRBLCADM managed object from configuration  console=${True}
    ...  AND  coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  delete  ${delta_id}
    ...  AND  coam.Get Delta  ${delta_id}
    ...  AND  coam.Save Delta  ${BTS Files}/delta2.json  ${delta_id}
    ...  AND  coam.Perform Delta Recommissioning  ${BTS Files}/delta2.json  skip_parameter_relation_errors=${True}
    ...  ELSE IF  ${FAULT_SNAPSHOT_TRIGGER_ADDED} and not ${TRBLCADM_MO_ADDED}  Run Keywords
    ...  Log  Removing faultSnapshotTriggers list from configuration  console=${True}
    ...  AND  coam.Append Parameter Delete To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  faultSnapshotTriggers  ${delta_id}
    ...  AND  coam.Get Delta  ${delta_id}
    ...  AND  coam.Save Delta  ${BTS Files}/delta2.json  ${delta_id}
    ...  AND  coam.Perform Delta Recommissioning  ${BTS Files}/delta2.json  skip_parameter_relation_errors=${True}

    coam.Remove All Delta Id
    Deintegrate BTS from NetAct Lab   ${NETACT_LAB.cmwas}    ${enb_release}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown

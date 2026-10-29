*** Settings ***
Documentation
    ...  LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S
Library    XML    use_lxml=${TRUE}
Library    DateTime
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    ../resources/verdicts.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  2700


*** Keywords ***
TC__LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S


    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22587
    ...  ******************
    ...  Author: Jakub Kokoszka
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2022-02-09 - TAT-22587 - Initial Creation
    ...  - 2022-07-13 - TAT-22409 - add auto delete snapshot from NetAct after download to local driver
    ...  - 2022-07-19 - TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2023-01-25 - https://jiradc.ext.net.nokia.com/browse/TAT-24564 - add time counter between snapshot triggering
    ...  - 2023-02-27 - TAT-24825 - KW Set Snapshot Destination to NetAct added to TC Preconditions, KW moved to ca_pm_logs_general resource
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 17.05.2023 - TAT-25384 - list_name= param added to KW AppendComplexItemToDelta
    ...  - 29.05.2023 - TAT-25470 - Changed to new FOR loop syntax
    ...  - 03.01.2023- change NetAct integration KW and variables
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if snapshot is automatically triggered by fault and send max 5 time to NetAct
    ...  test validate snapshot from NetAct
    ...  *******************
    ...  Test case flowchart:
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/
    ...  LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S.png
    ...  *******************

    Set Tags   LOGS    OWNER-jakub.kokoszka@nokia.com    AUTHOR-jakub.kokoszka@nokia.com
    ...    MAINTAINER-jakub.kokoszka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS22R3

    Step 1: Preconditions
    Step 2: Configure Fault Snapshot Trigger
    Step 3: Perform Cell Block To Trigger Snapshot, Check If Snapshot is Collected and present on NetAct




Step 1: Preconditions
    [Documentation]
    ...  In this test step test check in NMS connection is active.
    ...  reset site is performed to reset the number of snapshot sent to NetAct
    ...  variable are created

    Log  \nStep 1 Preconditions  console=${True}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${False}
    Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${False}
    Set Test Variable  ${CELL_ADDED}  ${False}
    ${bts_connection}=  coam.connect_to
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Log  Reset ongoing    console=${True}
    coam.Reset Site  600
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
    Log    Reset site done    console=${TRUE}
    ${SW}  coam.Get Sw Version
    ${snapshot_name}  Set Variable  Snapshot_MRBTS-${BTS_ID}_*_${SW}_*
    Set Test Variable  ${snapshot_name}
    Set Snapshot Destination To  NetAct
    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}
    Check if NetAct is deintegrated
    Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}



Step 2: Configure Fault Snapshot Trigger
    [Documentation]
    ...  In this test step faultSnapshotTriggers list for foult 49 is created and added to configuration.

    Log  \nStep 1: Configure Fault Snapshot Trigger  console=${True}
    coam.Get Current Scf File   ${BTS_Files}  scf.xml  export_type=configuration
    ${SCF}  Parse Xml  ${BTS_Files}/scf.xml
    Set Test Variable  ${SCF}
    ${trblcadm_element}  Evaluate Xpath  ${SCF}  //managedObject[contains(@class, 'TRBLCADM')]
    ${delta_id}  Set Variable  fault
    coam.Create Delta  ${delta_id}
    ${mnlent_element}  Evaluate Xpath  ${SCF}  //managedObject[contains(@class, 'MNLENT')]
    ${MNLENT_DISTNAME}  XML.Get Element Attribute  ${mnlent_element[0]}  distName
    Set Test Variable  ${MNLENT_DISTNAME}
    Run Keyword If  '${trblcadm_element}'=='[]'
    ...  Create Trblcadm Mo  ${SCF}  ${delta_id}
    ...  ELSE  Create Fault Snapshot Triggers  ${SCF}  ${delta_id}




Step 3: Perform Cell Block To Trigger Snapshot, Check If Snapshot is Collected and present on NetAct
    [Documentation]
    ...  In this test step Perform Cell Block To Trigger Snapshot, test check if snapshot is collected
    ...  unblocked cell that has been blocked for triggering snapshot, Check If Snapshot is Collected and present on NetAct,
    ...  download snapshot from NetAct and check content.
    ...  step checks the maximum number of uploaded snapshot triggered by one fault

     Log  \nStep 3: Perform SSH Login To Trigger Snapshot, Check If Snapshot Is Collected and present on NetAct  console=${True}
     FOR  ${i}  IN RANGE  1  6
         Check NetAct connection and reintegrate if needed   ${NETACT_LAB.cmwas}   ${enb_release}   1200
         Perform Cell Block To Trigger Snapshot  ${i}
         Check If Snapshot Is Collected  ${i}
         Unblocket Cell
         Chceck if snapshot is on netact  ${i}
         Validate Snapshot from NetAct  ${i}
     END
     Run Keyword  Perform Cell Block To Trigger Snapshot  6
     Run Keyword  Check If Snapshot Collection Max Limit Reached
     Run Keyword  Unblocket Cell
     Log  Reset ongoing    console=${True}
     coam.Reset Site
     Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
     Log    Reset site done test end    console=${TRUE}




Perform Cell Block To Trigger Snapshot
    [Arguments]  ${i}
    [Documentation]
    ...  In this KW cell block operation is performed to activate fault 49.
    ...  Activation of fault 49 will cause snapshot to automatically trigger.

    Log  \nStep 3.1.${i}: Perform Cell Block To Trigger Snapshot  console=${True}
    ${CELL_DISTNAME}  Get Cell Distname
    Set Test Variable  ${CELL_DISTNAME}
    Log  Cell with distname ${CELL_DISTNAME} will be blocked  console=${True}
    ${block_result}  Run Keyword And Ignore Error  coam.Block Cell  ${CELL_DISTNAME}
    Run Keyword If  '${block_result[0]}'=='FAIL'
    ...  verdicts.Set Test Failed  Cell block operation unsuccessful.  ${TRUE}
    ...  ELSE  Run Keywords  Log  Cell block operation successful.  console=${True}
    ...  AND  Set Test Variable  ${CELL_ADDED}  ${True}




Check If Snapshot Collection Max Limit Reached
    [Documentation]
    ...  In this KW it is checked if snapshot wasnt triggered by fault 49 after 5 successful triggered snapshot.

    ${snapshot_triggering_status_2}  Query Infomodel
    ...  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"49:On fault detection",stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status_2}
    ...  verdicts.Set Test Failed  Snapshot was triggered by fault 49 after 5 successful triggered snapshot.  ${TRUE}
    ...  ELSE  Log  Snapshot wasnt triggered by fault 49 after 5 successful triggered snapshot.  console=${True}




Check If Snapshot Is Collected
    [Arguments]  ${i}
    [Documentation]
    ...  In this KW it is checked if snapshot is triggered by fault 49 and collection is finished.

    Log  \nStep 3.2.${i}: Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel
    ...  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"49:On fault detection",stateInfo.usageState=Active]
    ...  timeout=120  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by fault.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered by fault.  ${TRUE}
    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    ${time_0}=   Get Time
    ${conv_time_0}=   Convert Date    ${time_0}    epoch
    Set Test Variable  ${conv_time_0}
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"49:On fault detection"]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}




Unblocket Cell
    [Documentation]
    ...  This KW unblocket cell.

    Run Keyword If  ${CELL_ADDED}  Run Keywords
    ...  Log  Cell with distname ${CELL_DISTNAME} will be unblocked  console=${True}
    ...  AND  coam.Unblock Cell  ${CELL_DISTNAME}
    ...  AND  Set Test Variable  ${CELL_ADDED}  ${False}




Chceck if snapshot is on netact
   [Documentation]    Chceck if snapshot is on netact
   [Arguments]  ${i}

   Log  \nStep 3.3.${i}: Chceck if snapshot is on netact  console=${True}
   Sleep  180s
   ${na_node_ip}  Set Variable  ${NETACT_LAB.sn_node}
   ${NA_OMC_PASS}  Set Variable  Medsql!_1893
   ${NA_OMC_LOGIN}  Set Variable  omc
   ${cmd}  Set Variable  find /d/oss/global/diagsnap/ne3sws -name ${snapshot_name} -cmin -15 2>/dev/null
   ${cmd_rm}    Set Variable    rm -rf /d/oss/global/diagsnap/ne3sws/${snapshot_name}
   ssh_utils.Set Connection Parameters  ${na_node_ip}  ${NA_OMC_LOGIN}    ${NA_OMC_PASS}
   ${snapshot_name_with_path}  ssh_utils.Run Command  ${cmd}
   ${snapshot_name_with_path}  Convert To String  ${snapshot_name_with_path}
   ${snap_dest_on_netact}  Set Variable  ${snapshot_name_with_path.replace("\r\n", " ")}
   ${isEmpty}  Get length  ${snap_dest_on_netact}
   Run Keyword If  ${isEmpty}==0
    ...   verdicts.Set Test Failed  Snapshot NOT found on NetAct.  ${TRUE}
    ...   ELSE   Log   Snapshot found on NetAct   console=true
   Run  sshpass -p '${NA_OMC_PASS}' scp ${NA_OMC_LOGIN}@${na_node_ip}:${snap_dest_on_netact} "${BTS_Files}"
   Sleep  30s
   ${download_snapshot_name}  Fetch From Right  ${snap_dest_on_netact}  /
   ${download_snapshot_name}  Set Variable  ${download_snapshot_name.rstrip()}
   ${path_to_snapshot_from_NetAct}  Set Variable  ${BTS_Files}/${download_snapshot_name}
   OperatingSystem.File Should Exist  ${BTS_Files}/${download_snapshot_name}
   ssh_utils.Set Connection Parameters  ${na_node_ip}  ${NA_OMC_LOGIN}    ${NA_OMC_PASS}
   ssh_utils.Run Command  ${cmd_rm}
   Log  Snapshot "${download_snapshot_name}" was found on NetAct and downloaded to local disk  console=${true}
   Set Test Variable  ${path_to_snapshot_from_NetAct}




Validate Snapshot from NetAct
    [Arguments]  ${i}
    [Documentation]
    ...  KW check snapshot content

    Log    \nStep 3.4.${i}: Validate Snapshot from NetAct    console=${True}
    ${Found_file_dict}    snapshot.Get Data From Snapshot    ${path_to_snapshot_from_NetAct}
    ${path_to_xml_spec_file}  join path  ${CURDIR}  tc_variables  snapshot_spec.xml
    snapshot.Validate Snapshot    ${Found_file_dict}    ${path_to_xml_spec_file}
    ${time_1}=   Get Time
    ${conv_time_1}=   Convert Date    ${time_1}    epoch
    ${delta_t}=    Evaluate   ${conv_time_1}-${conv_time_0}
    Log    Current time between snapshot triggers = ${delta_t}s
    ${Time_to_trigger_next_snapshot}  Evaluate  900-int(${delta_t})
    Run Keyword If    ${delta_t}>900   Run Keyword
    ...  Log    time between snapshot triggers >15min
    ...  ELSE   Run Keywords
    ...  log  waiting ${Time_to_trigger_next_snapshot}s for next snapshot trigger....  console=${True}
    ...  AND  Sleep  ${Time_to_trigger_next_snapshot}s




Create Trblcadm Mo
    [Arguments]  ${SCF}  ${delta_id}

    Log  Adding TRBLCADM managed object to configuration  console=${True}
    coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  create  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actCoreDumpFileCollection  true  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actRemoteSyslogTransmission  false  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  snapshotUploadDelayForFault6450  0  ${delta_id}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${True}
    Create Fault Snapshot Triggers  ${SCF}  ${delta_id}

Create Fault Snapshot Triggers
    [Arguments]  ${SCF}  ${delta_id}

    ${fault_snapshot_triggers_dict}  Create Dictionary  faultNumber=49  triggerType=onFaultDetection
    ${fault_snapshot_trigger}  Evaluate Xpath  ${SCF}  //p[@name='faultNumber' and text()='49']
    Run Keyword If  '${fault_snapshot_trigger}'=='[]'  Run Keywords
    ...  Log  Adding faultSnapshotTriggers list for foult 49 to configuration.  console=${True}
    ...  AND  coam.Append Complex Item To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  list_name=faultSnapshotTriggers  &{fault_snapshot_triggers_dict}
    ...  delta_id=${delta_id}
    ...  AND  coam.Get Delta  ${delta_id}
    ...  AND  coam.Save Delta  ${BTS Files}/delta.json  ${delta_id}
    ...  AND  coam.Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=${True}
    ...  AND  Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${True}




Get Cell Distname
    [Documentation]
    ...  KW get cell distname

    ${lncell_m_objects}  Query Infomodel  get list //LNCEL_R-*  allow_negative_result=True
    Run Keyword If  ${lncell_m_objects}
    ...  Return From Keyword  ${lncell_m_objects[0]['dist_name']}
    ${wncell_m_objects}  Query Infomodel  get list //WNCEL_R-*  allow_negative_result=True
    Run Keyword If  ${wncell_m_objects}
    ...  Return From Keyword  ${wncell_m_objects[0]['dist_name']}
    ${gncell_m_objects}  Query Infomodel  get list //GNCEL_R-*  allow_negative_result=True
    Run Keyword If  ${gncell_m_objects}
    ...  Return From Keyword  ${gncell_m_objects[0]['dist_name']}




Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}
    Unblocket Cell
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

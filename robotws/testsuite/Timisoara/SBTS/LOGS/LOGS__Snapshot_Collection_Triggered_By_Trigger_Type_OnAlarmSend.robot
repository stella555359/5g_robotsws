*** Settings ***
Library    XML    use_lxml=${TRUE}
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    ../resources/verdicts.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_TIMEOUT}    2700

*** Keywords ***
TC__LOGS__Snapshot_Collection_Triggered_By_Trigger_Type_OnAlarmSend

    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24338
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case checks if snapshot is automatically triggered by trigger type OnAlarmSend in dual core
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 20.12.2022 - TAT-24338 - Test rewritten based on BOAM ET test
    ...   [1][1.0] OAM_LTE2866-A-n_Trigger_Snapshot_With_Trigger_Type_OnAlarmSend_In_Dual_Core
    ...  - 2023-02-27 - TAT-24825 - KW Set Snapshot Destination to NetAct added to TC Preconditions, KW moved to ca_pm_logs_general resource
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 2023-04-24 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...  - 17.05.2023 - TAT-25384 - list_name= param added to KW AppendComplexItemToDelta
    ...  - 03.01.23 - change NetAct integration KW and variables
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Snapshot_Collection_Triggered_By_Trigger_Type_OnAlarmSend.png
    ...
    Set Tags      CA-LOGS  OWNER-mateusz.majkusiak@nokia.com  AUTHOR-mateusz.majkusiak@nokia.com  MAINTAINER-mateusz.majkusiak@nokia.com
    ...           GROUP_IN_CHARGE-WRO_6_Vrf  PHASE-CRT  SW-SBTS23R1  FEATURE-LTE2866-A-n

    Step 0: Preconditions
    Step 1: Configure Alarm Snapshot Trigger
    Step 2: Perform Cell Block To Trigger Snapshot With Trigger Type OnAlarmSend
    Step 3: Check If Snapshot Is Collected
    Step 4: Chceck if snapshot is on netact, download and validate


Step 0: Preconditions
    Log  \nPreconditions  console=${True}
    ${bts_connection}=  coam.connect_to
    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Check if NetAct is deintegrated
    Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${False}
    Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${False}
    Set Test Variable  ${CELL_ADDED}  ${False}
    ${SW}  coam.Get Sw Version
    ${snapshot_name}  Set Variable  Snapshot_MRBTS-${BTS_ID}_*_${SW}_*
    Set Test Variable  ${snapshot_name}
    Set Snapshot Destination To  NetAct

Step 1: Configure Alarm Snapshot Trigger
    [Documentation]
    ...  In this test step faultSnapshotTriggers list for foult 49 is created and added to configuration.

    Log  \nStep 1: Configure Alarm Snapshot Trigger  console=${True}
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

Step 2: Perform Cell Block To Trigger Snapshot With Trigger Type OnAlarmSend
    [Documentation]
    ...  In this test step cell block operation is performed to activate fault 49.
    ...  Activation of fault 49 will cause snapshot to automatically trigger.

    Log  \nStep 2: Perform Cell Block To Trigger Snapshot With Trigger Type OnAlarmSend  console=${True}
    Check NetAct connection and reintegrate if needed   ${NETACT_LAB.cmwas}   ${enb_release}   1200
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
    ...  In this test step checks if snapshot is automatically triggered by trigger type OnAlarmSend and collection is finished.

    Log  \nStep 3: Check If Snapshot Is Collected  console=${True}
    ${infomodel_info}  Set Variable  originator=Internal,reason=regex"49:On alarm send"
    ${snapshot_triggering_status}  Query Infomodel
    ...  check //TECHREP_L-*/SNAPSHOT-* is [${infomodel_info},stateInfo.usageState=Active]  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by trigger type OnAlarmSend.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered by trigger type OnAlarmSend.  ${TRUE}

    Log  Wait max ${SNAPSHOT_TIMEOUT} seconds for snapshot to collect.  console=${True}
    ${snapshot_collection_status}  Query Infomodel
    ...  none //TECHREP_L-*/SNAPSHOT-* is [${infomodel_info}]  timeout=${SNAPSHOT_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_TIMEOUT} seconds.  ${TRUE}

Step 4: Chceck if snapshot is on netact, download and validate
   [Documentation]    Chceck if snapshot is on netact

   Log  \nStep 4: Chceck if snapshot is on netact  console=${True}
   Chceck if snapshot is on netact
   Validate Snapshot from NetAct


Create Trblcadm Mo
    [Arguments]  ${SCF}  ${delta_id}
    Log  Adding TRBLCADM managed object to configuration  console=${True}
    coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  create  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actCoreDumpFileCollection  true  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actRemoteSyslogTransmission  false  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  snapshotUploadDelayForFault6450  0  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  diagSnapDestination  netact  ${delta_id}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${True}
    Create Fault Snapshot Triggers  ${SCF}  ${delta_id}

Create Fault Snapshot Triggers
    [Arguments]  ${SCF}  ${delta_id}
    ${fault_snapshot_triggers_dict}  Create Dictionary  faultNumber=49  triggerType=onAlarmSend
    ${fault_snapshot_trigger}  Evaluate Xpath  ${SCF}  //p[@name='faultNumber' and text()='49']
    Run Keywords
    ...  Log  Adding faultSnapshotTriggers list for foult 49 to configuration.  console=${True}
    ...  AND  coam.Append Complex Item To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  list_name=faultSnapshotTriggers  &{fault_snapshot_triggers_dict}
    ...  delta_id=${delta_id}
    ...  AND  coam.Get Delta  ${delta_id}
    ...  AND  coam.Save Delta  ${BTS Files}/delta.json  ${delta_id}
    ...  AND  coam.Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=${True}
    ...  AND  Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${True}

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

Chceck if snapshot is on netact
   [Documentation]    Chceck if snapshot is on netact

   Log  Chceck if snapshot is on netact  console=${True}
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
   Run  sshpass -p '${NA_OMC_PASS}' scp ${NA_OMC_LOGIN}@${na_node_ip}:${snap_dest_on_netact} ${BTS_Files}
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
    [Documentation]
    ...  KW check snapshot content

    Log    Validate Snapshot from NetAct    console=${True}
    ${Found_file_dict}    snapshot.Get Data From Snapshot    ${path_to_snapshot_from_NetAct}
    ${path_to_xml_spec_file}  join path  ${CURDIR}  tc_variables  snapshot_spec.xml
    snapshot.Validate Snapshot    ${Found_file_dict}    ${path_to_xml_spec_file}
    Log    Validation success, test end!    console=${True}

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

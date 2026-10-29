*** Settings ***
Library     XML    use_lxml=${TRUE}
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  1200

*** Keywords ***
TC__LOGS__Snapshot_triggered_by_BTS_fault_raised_collected_to_LSS_destination
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24256
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2022-12-06 - Damian Kotula - Test rewritten based on BOAM ET test -
    ...  Automatic_snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 2023-04-24 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...  - 2023-05-17 - TAT-25384 - list_name= param added to KW AppendComplexItemToDelta
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if snapshot is automatically triggered when fault 49 is cancelled. Fault is
    ...  added to faultSnapshotTriggers list and reported after cell block.
    ...  *******************
    ...  Test case flowchart: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...                       LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination.png
    ...  *******************


    Set Tags    CA-LOGS    OWNER-iuliia.taupeka@nokia.com    MAINTAINER-damian.kotula@nokia.com
    ...    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R1    FEATURE-RP002771

    Step 0: Preconditions
    Step 1: Configure Fault Snapshot Trigger
    Step 2: Perform Cell Block To Trigger Snapshot
    Step 3: Check If Snapshot Is Collected
    Step 4: Check If Snapshot Is On LSS
    Step 5: Perform Cell Unblock


Step 0: Preconditions
    [Documentation]
    ...  In this step needed test variables are declared

    Log  \nPreconditions  console=${True}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${False}
    Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${False}
    Set Test Variable  ${CELL_BLOCKED}  ${False}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${SW}  coam.Get Sw Version
    ${snapshot_name}  Set Variable  Snapshot_MRBTS-${bts_id}_*_${SW}_*
    Set Test Variable  ${snapshot_name}
    Set Snapshot Destination To  LSS

Step 1: Configure Fault Snapshot Trigger
    [Documentation]
    ...  In this step faultSnapshotTriggers list for foult 49 is created and added to configuration.

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
    ...  ELSE  Create Fault Snapshot Triggers  ${SCF}  ${delta_id}    49    onFaultDetection

Step 2: Perform Cell Block To Trigger Snapshot
    [Documentation]
    ...  In this step cell block and unblock operations are performed to activate fault 49.
    ...  Cancellation of fault 49 will cause snapshot to automatically trigger.

    Log  \nStep 2: Perform Cell Block/Unblock  console=${True}
    ${CELL_DISTNAME}  Get Cell Distname
    Set Test Variable  ${CELL_DISTNAME}
    Log  Cell with distname ${CELL_DISTNAME} will be blocked  console=${True}
    ${block_result}  Run Keyword And Ignore Error  coam.Block Cell  ${CELL_DISTNAME}
    Run Keyword If  '${block_result[0]}'=='FAIL'
    ...  verdicts.Set Test Failed  Cell block operation unsuccessful.  ${TRUE}
    ...  ELSE  Run Keywords  Log  Cell block operation successful.  console=${True}
    ...  AND  Set Test Variable  ${CELL_BLOCKED}  ${True}
    Wait Until Keyword Succeeds  3m  10s  coam.Assert Alarm Active  faultId=49
#    Log  Cell with distname ${CELL_DISTNAME} will be unblocked  console=${True}
#    ${unblock_result}  Run Keyword And Ignore Error  coam.Unblock Cell  ${CELL_DISTNAME}
#    Run Keyword If  '${unblock_result[0]}'=='FAIL'
#    ...  verdicts.Set Test Failed  Cell unblock operation unsuccessful.  ${TRUE}
#    ...  ELSE  Run Keywords  Log  Cell unblock operation successful.  console=${True}
#    ...  AND  Set Test Variable  ${CELL_BLOCKED}  ${False}

Step 3: Check If Snapshot Is Collected
    [Documentation]
    ...  In this step it is checked if snapshot is triggered by fault 49 and collection is finished.

    Log  \nStep 3: Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by fault 49 cancellation.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered by fault 49 cancellation.  ${TRUE}

    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}

Step 4: Check If Snapshot Is On LSS
    [Documentation]
    ...  In KW test login to lss server and check if snapshot is present
    ...  if yes zip directory to snapshot.zip file after that download zip file to local disk
    Log  \nStep 4: Chceck if snapshot is on LSS  console=${True}

    ${lss_sever_ip}  Set Variable  10.5.20.200
    ${lss_server_pass}  Set Variable  zO&n1W*ktp7!
    ${lss_server_user}  Set Variable  coam

    Log  Open SSH Connection to lss server  console=${true}
    SSHLibrary.Open Connection                          ${lss_sever_ip}
    ${ssh_status}  Run Keyword And Return Status
    ...  SSHLibrary.Login                               ${lss_server_user}    ${lss_server_pass}
    Run Keyword If  ${ssh_status}
    ...  Log  Opening SSH session to lss server succeeded   console=${true}
    ...  ELSE
    ...  verdicts.Set Test Failed  TC failed - Open SSH connection to lss server failure.  ${TRUE}
    Sleep    3s

    ${snapshot_location_on_lss}  SSHLibrary.Execute Command  find / -type d -name "${snapshot_name}" -cmin -15 2>/dev/null
    ${snapshot_file_name_on_lss}    Fetch From Right    ${snapshot_location_on_lss}    /
    ${isEmpty}  Get length  ${snapshot_location_on_lss}
    Log  ${isEmpty}
    Run Keyword If  ${isEmpty}==0
    ...  verdicts.Set Test Failed  snapshot was`t found on lss server.  ${TRUE}
    ...  ELSE  Log  Snapshot was found on lss server.   console=${true}
    Sleep  3s
    SSHLibrary.Execute Command  zip -r ${snapshot_name}.zip ${snapshot_location_on_lss}
    Sleep  60s
    Run  sshpass -p '${lss_server_pass}' scp ${lss_server_user}@${lss_sever_ip}:/home/coam/${snapshot_name}.zip ${BTS_Files}
    Sleep  60s
    SSHLibrary.Execute Command  rm -r /home/coam/${snapshot_file_name_on_lss}
    Log  ${snapshot_file_name_on_lss} was removed from LSS server
    Sleep  1s
    SSHLibrary.Execute Command  rm /home/coam/${snapshot_name}.zip
    Log  ${snapshot_name}.zip was removed from LSS server
    ${path_to_snapshot_from_lss}  Set Variable  ${BTS_Files}/${snapshot_name}.zip
    OperatingSystem.File Should Exist  ${BTS_Files}/${snapshot_name}.zip
    Log  Snapshot was downloaded to local disk   console=${true}
    Set Test Variable  ${path_to_snapshot_from_lss}
    Validate Snapshot from LSS
    SSHLibrary.Close Connection

Step 5: Perform Cell Unblock
    Log  Cell with distname ${CELL_DISTNAME} will be unblocked  console=${True}
    ${unblock_result}  Run Keyword And Ignore Error  coam.Unblock Cell  ${CELL_DISTNAME}
    Run Keyword If  '${unblock_result[0]}'=='FAIL'
    ...  verdicts.Set Test Failed  Cell unblock operation unsuccessful.  ${TRUE}
    ...  ELSE  Run Keywords  Log  Cell unblock operation successful.  console=${True}
    ...  AND  Set Test Variable  ${CELL_BLOCKED}  ${False}

Create Trblcadm Mo
    [Arguments]  ${SCF}  ${delta_id}
    Log  Adding TRBLCADM managed object to configuration  console=${True}
    coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  create  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actCoreDumpFileCollection  true  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actRemoteSyslogTransmission  false  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  snapshotUploadDelayForFault6450  24  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  diagSnapDestination  lss  ${delta_id}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${True}
    Create Fault Snapshot Triggers  ${SCF}  ${delta_id}    49    onFaultDetection

Create Fault Snapshot Triggers
    [Arguments]  ${SCF}  ${delta_id}   ${faultNumber}   ${triggerType}
    ${fault_snapshot_triggers_dict}  Create Dictionary  faultNumber=${faultNumber}  triggerType=${triggerType}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actDefaultFaultSnapTriggers  false  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  snapshotUploadDelayForFault6450  24  ${delta_id}
    coam.Append Complex Item To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  list_name=faultSnapshotTriggers  &{fault_snapshot_triggers_dict}
    ...  delta_id=${delta_id}
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS Files}/delta.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=${True}
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

Validate Snapshot from LSS
    Log    \nValidate Snapshot from LSS    console=${True}
    ${Found_file_dict}    snapshot.Get Data From Snapshot    ${path_to_snapshot_from_lss}
    ${path_to_xml_spec_file}  join path  ${CURDIR}  tc_variables  snapshot_spec_from_lss.xml
    snapshot.Validate Snapshot    ${Found_file_dict}    ${path_to_xml_spec_file}
    Log    Validation success   console=${True}

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}
    Run Keyword If  ${CELL_BLOCKED}  Run Keywords
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

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown



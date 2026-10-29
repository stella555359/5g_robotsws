*** Settings ***
Library     XML    use_lxml=${TRUE}
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  2700


*** Keywords ***
TC__LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S

    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22488
    ...  ******************
    ...  Author: Jakub Kokoszka
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2022-01-12 - https://jira3.ext.net.nokia.com/browse/TAT-22488 - Initial Creation
    ...  - 2022-05-23 - https://jiradc.ext.net.nokia.com/browse/TAT-23164 - add auto file delete from LSS
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2023-01-25 - https://jiradc.ext.net.nokia.com/browse/TAT-24564 - add time counter between snapshot triggering
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 2023-04-24 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...  - 29.05.2023 - TAT-25470 - Changed to new FOR loop syntax
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if snapshot is automatically triggered after syslog substring is detected. Syslog substring
    ...  'session opened for user toor4nsn' is added to syslogSubstringTrigger and triggered after successful SSH session is opened for user toor4nsn.
    ...  Snapshot is sending to lss server
    ...  *******************
    ...  Test case flowchart:
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/tree/master/testsuite/SBTS/
    ...  LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to__external_server_LSS_via_NE3S.png
    ...  *******************


    Set Tags   LOGS    OWNER-jakub.kokoszka@nokia.com    AUTHOR-jakub.kokoszka@nokia.com
    ...    MAINTAINER-jakub.kokoszka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS22R3


    Step 1: Preconditions
    Step 2: Configure Syslog Substring Snapshot Trigger
    Step 3: Perform SSH Login To Trigger Snapshot, Check If Snapshot Is Collected and present on lss server, check snapshot content



Step 1: Preconditions
    [Documentation]
    ...  In this test step test reset bts, VM Ip is check, variables are created (snapshot name and VM ip)

    Log  \nStep 1 Preconditions  console=${True}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${False}
    Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${False}
    Log  Reset ongoing    console=${True}
    coam.Reset Site
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
    Log  Reset site done    console=${TRUE}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${SW}  coam.Get Sw Version
    ${snapshot_name}  Set Variable  Snapshot_MRBTS-${bts_id}_*_${SW}_*
    Set Test Variable  ${snapshot_name}
    ${vm_ip}  ssh_utils.Get VM Ip
    Set Test Variable  ${VM_ip}  ${vm_ip}
    Set Snapshot Destination To  LSS




Step 2: Configure Syslog Substring Snapshot Trigger
    [Documentation]
    ...  In this test step syslog substring 'session opened for user toor4nsn' is added to syslogSubstringTrigger.

    Log  \nStep 2: Configure Syslog Substring Snapshot Trigger  console=${True}
    coam.Get Current Scf File   ${BTS_Files}  scf.xml  export_type=configuration
    ${SCF}  Parse Xml  ${BTS_Files}/scf.xml
    Set Test Variable  ${SCF}
    ${trblcadm_element}  Evaluate Xpath  ${SCF}  //managedObject[contains(@class, 'TRBLCADM')]
    ${delta_id}  Set Variable  substring
    coam.Create Delta  ${delta_id}
    ${mnlent_element}  Evaluate Xpath  ${SCF}  //managedObject[contains(@class, 'MNLENT')]
    ${MNLENT_DISTNAME}  XML.Get Element Attribute  ${mnlent_element[0]}  distName
    Set Test Variable  ${MNLENT_DISTNAME}
    Run Keyword If  '${trblcadm_element}'=='[]'
    ...  Create Trblcadm Mo  ${SCF}  ${delta_id}
    ...  ELSE  Create Syslog Substring Snapshot Trigger  ${SCF}  ${delta_id}



Step 3: Perform SSH Login To Trigger Snapshot, Check If Snapshot Is Collected and present on lss server, check snapshot content
    [Documentation]
    ...  In this test step test perform SSH login to trigger snapshot
    ...  wait and check if snapshot was collected
    ...  log to lss server to check if snashot is present if yes zip it to snapshot.zip file
    ...  test download zip snapshot file to VM local disk and check snapshot content
    ...  test check if snapshot sent max 5 time to lss server

     FOR  ${i}  IN RANGE  1  6
         Perform SSH Login To Trigger Snapshot  ${i}
         Check If Snapshot Is Collected  ${i}
         Chceck if snapshot is on LSS  ${i}
         Validate Snapshot from LSS  ${i}
     END
    Run Keyword  Perform SSH Login To Trigger Snapshot  6
    Run Keyword  Check If Snapshot Collection Max Limit Reached
    Log  Reset ongoing    console=${True}
    coam.Reset Site
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
    Log    Reset site done test end    console=${TRUE}



Perform SSH Login To Trigger Snapshot
    [Arguments]  ${i}
    [Documentation]
    ...  In this KW SSH login operation is performed to activate snapshot collection.

    Log  \nStep 3.1.${i}: Perform SSH Login To Trigger Snapshot  console=${True}
    SSHLibrary.Open Connection  ${SMOD1['IP']}  encoding=unicode_escape
    ${login_status}  Run Keyword And Ignore Error  SSHLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    Run Keyword If  '${login_status[0]}'=='PASS'
    ...  Log  SSH session successfully opened for user ${SMOD1['USERNAME']}.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  SSH session not opened for user ${SMOD1['USERNAME']}.  ${TRUE}
    SSHLibrary.Close Connection
    Log  SSH session successfully closed for user ${SMOD1['USERNAME']}  console=${True}




Check If Snapshot Is Collected
    [Arguments]  ${i}
    [Documentation]
    ...  In this KW it is checked if snapshot is triggered by syslog substring and collection is finished.

    Log  \nStep 3.2.${i}: Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by syslog substring.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered by syslog substring.  ${TRUE}

    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    Sleep  60s
    ${time_0}=   Get Time
    ${conv_time_0}=   Convert Date    ${time_0}    epoch
    Set Test Variable  ${conv_time_0}
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}



Chceck if snapshot is on LSS
    [Arguments]  ${i}
    [Documentation]
    ...  In KW test login to lss server and check if snapshot is present
    ...  if yes zip directory to snapshot.zip file after that download zip file to local disk
    Log  \nStep 3.3.${i}: Chceck if snapshot is on LSS  console=${True}

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
    SSHLibrary.Execute Command  zip -r ${snapshot_name}_${i}.zip ${snapshot_location_on_lss}
    Sleep  60s
    Run  sshpass -p '${lss_server_pass}' scp ${lss_server_user}@${lss_sever_ip}:/home/coam/${snapshot_name}_${i}.zip "${BTS_Files}"
    Sleep  60s
    SSHLibrary.Execute Command  rm -r /home/coam/${snapshot_file_name_on_lss}
    Log  ${snapshot_file_name_on_lss} was removed from LSS server
    Sleep  1s
    SSHLibrary.Execute Command  rm /home/coam/${snapshot_name}_${i}.zip
    Log  ${snapshot_name}_${i}.zip was removed from LSS server
    ${path_to_snapshot_from_lss}  Set Variable  ${BTS_Files}/${snapshot_name}_${i}.zip
    OperatingSystem.File Should Exist  ${BTS_Files}/${snapshot_name}_${i}.zip
    Log  Snapshot was downloaded to local disk   console=${true}
    Set Test Variable  ${path_to_snapshot_from_lss}
    SSHLibrary.Close Connection



Validate Snapshot from LSS
    [Arguments]  ${i}
    [Documentation]
    ...  In KW test check snapshot content

    Log    \nStep 3.4.${i}: Validate Snapshot from LSS    console=${True}

    ${Found_file_dict}    snapshot.Get Data From Snapshot    ${path_to_snapshot_from_lss}
    ${path_to_xml_spec_file}  join path  ${CURDIR}  tc_variables  snapshot_spec_from_lss.xml
    snapshot.Validate Snapshot    ${Found_file_dict}    ${path_to_xml_spec_file}
    ${time_1}=   Get Time
    ${conv_time_1}=   Convert Date    ${time_1}    epoch
    ${delta_t}=    Evaluate   ${conv_time_1}-${conv_time_0}
    Log    Current time between snapshot triggers = ${delta_t}s
    ${Time_to_trigger_next_snapshot}  Evaluate  900-int(${delta_t})
    Run Keyword If    ${delta_t}>900   Run Keyword
    ...  Log    time between snapshot triggers >15min
    ...  ELSE   Run Keywords
    ...  log   waiting ${Time_to_trigger_next_snapshot}s for next snapshot trigger....  console=${True}
    ...  AND  Sleep  ${Time_to_trigger_next_snapshot}s


Check If Snapshot Collection Max Limit Reached
    ${snapshot_triggering_status2}  Query Infomodel  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status2}
    ...  verdicts.Set Test Failed  Snapshot was triggered by syslog substring.  ${TRUE}
    ...  ELSE  Log  \nSnapshot was not triggered by syslog substring  console=${True}



Create Trblcadm Mo
    [Arguments]  ${SCF}  ${delta_id}
    Log  Adding TRBLCADM managed object to configuration  console=${True}
    coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  create  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actCoreDumpFileCollection  true  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actRemoteSyslogTransmission  false  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  snapshotUploadDelayForFault6450  99  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  diagSnapDestination  lss  ${delta_id}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${True}
    Create Syslog Substring Snapshot Trigger  ${SCF}  ${delta_id}



Create Syslog Substring Snapshot Trigger
    [Arguments]  ${SCF}  ${delta_id}
    Set Test Variable  ${SYSLOG_SUBSTRING}  session opened for user toor4nsn
    Log  Adding syslogSubstringTrigger: '${SYSLOG_SUBSTRING}' to configuration.  console=${True}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  syslogSubstringTrigger  ${SYSLOG_SUBSTRING}  delta_id=${delta_id}
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS Files}/delta.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=${True}
    Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${True}



Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}

    ${delta_id}  Set Variable  teardown
    coam.Create Delta  ${delta_id}

    Run Keyword If  ${TRBLCADM_MO_ADDED} and ${FAULT_SNAPSHOT_TRIGGER_ADDED}  Run Keywords
    ...  Log  Removing TRBLCADM managed object from configuration  console=${True}
    ...  AND  coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  delete  ${delta_id}
    ...  AND  coam.Get Delta  ${delta_id}
    ...  AND  coam.Save Delta  ${BTS Files}/delta2.json  ${delta_id}
    ...  AND  coam.Perform Delta Recommissioning  ${BTS Files}/delta2.json  skip_parameter_relation_errors=${True}
    ...  ELSE IF  ${FAULT_SNAPSHOT_TRIGGER_ADDED} and not ${TRBLCADM_MO_ADDED}  Run Keywords
    ...  Log  Removing syslogSubstringTrigger: ${SYSLOG_SUBSTRING} from configuration  console=${True}
    ...  AND  coam.Append Parameter Delete To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  syslogSubstringTrigger  ${delta_id}
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

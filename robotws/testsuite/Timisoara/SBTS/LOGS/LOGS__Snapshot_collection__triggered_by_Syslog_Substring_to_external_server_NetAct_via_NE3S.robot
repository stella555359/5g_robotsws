*** Settings ***
Library    XML    use_lxml=${TRUE}
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Resource   ../resources/verdicts.robot
Resource   ../resources/ssh_utils.robot
Resource   ../resources/bts_states.robot
Resource   ../resources/pm_logs_frame.robot
Resource   ../resources/pm_logs_general.robot
Resource   taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  2700


*** Keywords ***
TC__LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_NetAct_via_NE3S

    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21610
    ...  ******************
    ...  Author: Jakub Kokoszka
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2021-07-19 - TAT-21610 - Initial Creation
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-13 - TAT-22409 - add auto delete snapshot from NetAct after download to local driver
    ...  - 2022-07-19 - TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2023-01-25 - https://jiradc.ext.net.nokia.com/browse/TAT-24564 - add time counter between snapshot triggering
    ...  - 2023-02-27 - TAT-24825 - KW Set Snapshot Destination to NetAct added to TC Preconditions, KW moved to ca_pm_logs_general resource
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 29.05.2023 - TAT-25470 - Changed to new FOR loop syntax
    ...  - 03.01.23 - change NetAct integration KW and variables
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if snapshot is automatically triggered after syslog substring is detected. Syslog substring
    ...  'session opened for user toor4nsn' is added to syslogSubstringTrigger and triggered after successful SSH session is opened for user toor4nsn.
    ...  Snapshot is sending to netact and check max 5 time send
    ...  *******************
    ...  Test case flowchart:
    ...  *******************


    Set Tags   LOGS    OWNER-jakub.kokoszka@nokia.com    AUTHOR-jakub.kokoszka@nokia.com
    ...    MAINTAINER-jakub.kokoszka@nokia.com    GROUP_IN_CHARGE-WRO_5_Vrf    PHASE-CRT    SW-SBTS21

    Step 1: Preconditions
    Step 2: Configure Syslog Substring Snapshot Trigger
    Step 3: Perform SSH Login To Trigger Snapshot, Check If Snapshot Is Collected and present on NetAct, Check Snapshot Content.



Step 1: Preconditions
    [Documentation]
    ...  In this test step test check in NMS connection is active.
    Log  \nStep 1 Preconditions  console=${True}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${False}
    Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${False}
    ${bts_connection}=  coam.connect_to
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    coam.Reset Site
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

Step 3: Perform SSH Login To Trigger Snapshot, Check If Snapshot Is Collected and present on NetAct, Check Snapshot Content.
     Log  \nStep 3: Perform SSH Login To Trigger Snapshot, Check If Snapshot Is Collected and present on NetAct  console=${True}

     FOR  ${i}  IN RANGE  1  6
         Check NetAct connection and reintegrate if needed   ${NETACT_LAB.cmwas}   ${enb_release}   1200
         Perform SSH Login To Trigger Snapshot  ${i}
         Check If Snapshot Is Collected  ${i}
         Chceck if snapshot is on netact  ${i}
         Validate Snapshot from NetAct  ${i}
     END
     Run Keyword  Perform SSH Login To Trigger Snapshot  6
     Run Keyword  Check If Snapshot Is Collected Max
     coam.Reset Site
     Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
     Log    Reset site done    console=${TRUE}



Perform SSH Login To Trigger Snapshot
    [Arguments]  ${i}
    [Documentation]
    ...  In this test step SSH login operation is performed to activate snapshot collection.

    Log  \nStep 3.1.${i}: Perform SSH Login To Trigger Snapshot  console=${True}
    SSHLibrary.Open Connection  ${SMOD1['IP']}  encoding=unicode_escape
    ${login_status}  Run Keyword And Ignore Error  SSHLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    Run Keyword If  '${login_status[0]}'=='PASS'
    ...  Log  SSH session successfully opened for user ${SMOD1['USERNAME']}.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  SSH session not opened for user ${SMOD1['USERNAME']}.  ${TRUE}
    SSHLibrary.Close Connection
    Log  SSH session successfully closed for user ${SMOD1['USERNAME']}  console=${True}

Check If Snapshot Is Collected Max
    ${snapshot_triggering_status2}  Query Infomodel  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status2}
    ...  verdicts.Set Test Failed  Snapshot was triggered by syslog substring.  ${TRUE}
    ...  ELSE  Log  Snapshot was not triggered by syslog substring  console=${True}

Check If Snapshot Is Collected
    [Arguments]  ${i}
    [Documentation]
    ...  In this test step it is checked if snapshot is triggered by syslog substring and collection is finished.

    Log  \nStep 3.2.${i}: Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by syslog substring.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered by syslog substring.  ${TRUE}
    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    ${time_0}=   Get Time
    ${conv_time_0}=   Convert Date    ${time_0}    epoch
    Set Test Variable  ${conv_time_0}
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}

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
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  diagSnapDestination  netact  ${delta_id}
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

    Deintegrate BTS from NetAct Lab   ${NETACT_LAB.cmwas}    ${enb_release}

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
    Common Test Setup    syslog_launch=${False}

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown

*** Settings ***
Documentation  Tests for AASYSINFO_FS_OVERLOAD_IND_MSG
Library    XML    use_lxml=${TRUE}
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library    SSHLibrary
Resource    ../resources/verdicts.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  2700
${ip_MSM}    192.168.255.129
${password_MSM}    oZPS0POrRieRtu
${user_name_MSM}    toor4nsn
${trigger_FID6506_MSM}    cd /ffs/run/logs/oam/asm/auditlog; fallocate -l 1.9G test.txt # create file test.txt
${check_trigger_FID6506}    ls -lah /ffs/run/logs/oam/asm/auditlog | grep test.txt #check if trigger file is created
${clear_FID6506}    rm -rf /ffs/run/logs/oam/asm/auditlog/test.txt

*** Keywords ***
TC__LOGS_CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25574
    ...  ******************
    ...  Author: Stepan Radysh
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.06.23 - TAT-25574 - TC created, version 1.0
    ...  - 03.01.23 - change NetAct integration KW and variables
    ...  ******************
    ...  Basic information
    ...  ******************
    ...  This Test Case check if R&D FID 6506 is available in RawAlarmHistory, after exceeding the quota under subfolder
    ...  /ffs/run/logs/oam/asm/auditlog
    ...  *******************
    ...  Test case flowchart:
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...  TAT-25574-Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct.png
    ...  *******************

    Set Tags    CA-LOGS    OWNER-stepan.radysh@okia.com    AUTHOR-stepan.radysh@okia.com
    ...    MAINTAINER-stepan.radysh@okia.com    GROUP_IN_CHARGE-WRO_6_Vrf
    ...    PHASE-CRT    SW-SBTS23R2    FEATURE-CB008390-C

      Step 1: Precondition
      Step 2: Configure Syslog Substring Snapshot Trigger
      Step 3: Exceed qouta in folder under /ffs/run/logs/oam/asm/auditlog
      Step 4: Check If Snapshot triggered by substring, collected and present on NetAct
      Step 5: Check Snapshot Content


Step 1: Precondition
    [Documentation]
    ...  In this test step test check if NMS connection is active, if no integrate BTS to NetAct
    ...  Create Snapshot name

    Log  \nStep 1 Precondition  console=${True}
    Set Test Variable  ${big_file_present}  ${False}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${False}
    Set Test Variable  ${SYSLOG_SNAPSHOT_TRIGGER_ADDED}  ${False}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}

    ${SW}  coam.Get Sw Version
    ${snapshot_name}  Set Variable  Snapshot_MRBTS-${BTS_ID}_*_${SW}_*
    Set Test Variable  ${snapshot_name}
    pm_logs_general.Set Snapshot Destination to  NetAct
    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}
    Check if NetAct is deintegrated
    pm_logs_general.Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}

Step 2: Configure Syslog Substring Snapshot Trigger
    [Documentation]
    ...  In this test step syslog substring 'AASYSINFO_FS_OVERLOAD_IND_MSG' is added to syslogSubstringTrigger.

    Log  \nStep 2: Configure Syslog Substring Snapshot Trigger  console=${True}
    coam.Get Current Scf File   ${BTS_Files}  scf.xml  export_type=configuration
    ${SCF}  Parse Xml  ${BTS_Files}/scf.xml
    Set Test Variable  ${SCF}
    ${trblcadm_element}  Evaluate Xpath  ${SCF}  //managedObject[contains(@class, 'TRBLCADM')]
    ${delta_id}  Set Variable  substring
    coam.Create Delta  ${delta_id}
    Set Test Variable    ${delta_id}
    ${mnlent_element}  Evaluate Xpath  ${SCF}  //managedObject[contains(@class, 'MNLENT')]
    ${MNLENT_DISTNAME}  XML.Get Element Attribute  ${mnlent_element[0]}  distName
    Set Test Variable  ${MNLENT_DISTNAME}
    Run Keyword If  '${trblcadm_element}'=='[]'
    ...  Create Trblcadm Mo    ${delta_id}
    ...  ELSE  Create Syslog Substring Snapshot Trigger   ${delta_id}

Step 3: Exceed qouta in folder under /ffs/run/logs/oam/asm/auditlog
    [Documentation]
    ...  In this test step connect via SSH to MSM
    ...  and create file for exceed the quota on folder ffs/run/logs/oam/asm/auditlog.

    Log  \nStep 3: Exceed qouta in folder under /ffs/run/logs/oam/asm/auditlog  console=${True}
    Check NetAct connection and reintegrate if needed   ${NETACT_LAB.cmwas}   ${enb_release}   1200
    SSHLibrary.Open Connection    ${ip_MSM}
    SSHLibrary.Login    ${user_name_MSM}    ${password_MSM}
    SSHLibrary.Execute Command    ${trigger_FID6506_MSM}
    Set Test Variable    ${big_file_present}    ${True}
    ${exceeded_quota}    SSHLibrary.Execute Command    ${check_trigger_FID6506}
    ${isEmpty}  Get length  ${exceeded_quota}
    Run Keyword If  ${isEmpty}==0
    ...  verdicts.Set Test Failed  File was not created.  ${TRUE}
    ...  ELSE  Log    file exist ${exceeded_quota}    console=${True}
    Sleep       1min

Step 4: Check If Snapshot triggered by substring, collected and present on NetAct
	[Documentation]
    ...  In this step check if Snapshot is triggered by substring
    ...  Check if Snapshot is present on NetAct successfully

    Log  \nStep 4: Check If Snapshot triggered by substring, collected and present on NetAct  console=${True}
    Check If Snapshot Is Collected
    Chceck if snapshot is on netact


Step 5: Check Snapshot Content
    [Documentation]
    ...    In this step check if file RawAlarmHistory.txt is available in Snapshot
    ...    File RawAlarmHistory.txt should include FID:6506

    ${SNAPSHOT_LOCATION}    set variable   ${BTS_Files}
    ${raw_file_name}  Set Variable  BTS${BTS_ID}_*011_RawAlarmHistory.txt.xz
    Set Test Variable    ${raw_file_name}
    ${zip_part}    ${raw_file_name_list}  PartCheck

    ${zip_part_number}  Fetch From Left  ${zip_part}  /
    ${raw_archive_xz}  Fetch From Right  ${zip_part}  /
    ${filename_row}  Fetch From Left  ${raw_archive_xz}   .xz
    Log    File ${filename_row} is available in ${zip_part_number}  console=${True}

    unpacking.Unpack Archive Content To Directory  ${path_to_snapshot_from_NetAct}   ${SNAPSHOT_LOCATION}/Unpack
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/Unpack/${zip_part_number}  ${SNAPSHOT_LOCATION}/Unpack/Raw_xz
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/Unpack/Raw_xz/${raw_archive_xz}  ${SNAPSHOT_LOCATION}/Unpack/Raw_xz/Raw_txt

    ${file_content}    OperatingSystem.Get File    ${SNAPSHOT_LOCATION}/Unpack/Raw_xz/Raw_txt/${filename_row}
    ${active_faults}    Fetch from left  ${file_content}    Inactive faults
    Should Contain    ${active_faults}    6506
    Log    File contain FID:6506    console=${True}
    Run    rm -rf ${SNAPSHOT_LOCATION}/Unpack


PartCheck
    ${found_file_dict}    snapshot.Get Data From Snapshot    ${path_to_snapshot_from_NetAct}
    ${temp}   Create List
    FOR  ${log_file}  IN  @{found_file_dict.keys()}
        Append to List   ${temp}    ${log_file}
        ${raw_zip_file}  Get Matches  ${temp}  ${raw_file_name}
        Remove From List   ${temp}   0
        ${raw_zip_file_len}   Get Length   ${raw_zip_file}
        Exit For Loop If  ${raw_zip_file_len}>0

    END
    [Return]  ${found_file_dict["${log_file}"][0]}    ${raw_zip_file}

Check If Snapshot Is Collected
    [Documentation]
    ...  In this KW it is checked if snapshot is triggered by syslog substring and collection is finished.

    Log  Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel
    ...  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,stateInfo.usageState=Active]  timeout=2900  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by syslog substring.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered by syslog substring.  ${TRUE}
    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    ${snapshot_collection_status}  Query Infomodel
    ...  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal]  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}

Chceck if snapshot is on netact
   [Documentation]
   ...    Chceck if snapshot is on netact

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
   ${snap_download}    Run  sshpass -p '${NA_OMC_PASS}' scp ${NA_OMC_LOGIN}@${na_node_ip}:${snap_dest_on_netact} ${BTS_Files}
   Sleep  30s
   Should contain    ${snap_download}    This system is for use of

   ${download_snapshot_name}  Fetch From Right  ${snap_dest_on_netact}  /
   ${download_snapshot_name}  Set Variable  ${download_snapshot_name.rstrip()}
   ${path_to_snapshot_from_NetAct}  Set Variable  ${BTS_Files}/${download_snapshot_name}
   OperatingSystem.File Should Exist  ${BTS_Files}/${download_snapshot_name}
   ssh_utils.Set Connection Parameters  ${na_node_ip}  ${NA_OMC_LOGIN}    ${NA_OMC_PASS}
   ssh_utils.Run Command  ${cmd_rm}
   Log  Snapshot "${download_snapshot_name}" was found on NetAct and downloaded to local disk  console=${true}
   Set Test Variable  ${path_to_snapshot_from_NetAct}


Create Trblcadm Mo
    [Arguments]    ${delta_id}
    Log  Adding TRBLCADM managed object to configuration  console=${True}
    coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  create  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actCoreDumpFileCollection  true  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actRemoteSyslogTransmission  false  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  snapshotUploadDelayForFault6450  0  ${delta_id}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${True}
    Create Syslog Substring Snapshot Trigger    ${delta_id}

Create Syslog Substring Snapshot Trigger
    [Arguments]  ${delta_id}
    Set Test Variable  ${SYSLOG_SUBSTRING}  AASYSINFO_FS_OVERLOAD_IND_MSG
    Log  Adding syslogSubstringTrigger: '${SYSLOG_SUBSTRING}' to configuration.  console=${True}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  syslogSubstringTrigger  ${SYSLOG_SUBSTRING}  delta_id=${delta_id}
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS Files}/delta.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=${True}
    Set Test Variable  ${SYSLOG_SNAPSHOT_TRIGGER_ADDED}  ${True}

Custom Test Teardown
    Run Keyword If  ${big_file_present}
    ...    SSHLibrary.Write    ${clear_FID6506}

    Log  Wait up to 15 min in order to check if alarm 6504 is canceled.  console=${True}
    log to console    Check if also 6504 is cleared
    Wait Until Keyword Succeeds    15min    10s    coam.Assert alarm inactive    faultId=6504, severity=Minor
    Run Keyword If  ${SYSLOG_SNAPSHOT_TRIGGER_ADDED}  Run Keywords
    ...  Log  Removing syslogSubstringTrigger: ${SYSLOG_SUBSTRING} from configuration  console=${True}
    ...  AND  coam.Append Parameter Delete To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  syslogSubstringTrigger  ${delta_id}
    ...  AND  coam.Get Delta  ${delta_id}
    ...  AND  coam.Save Delta  ${BTS Files}/delta2.json  ${delta_id}
    ...  AND  coam.Perform Delta Recommissioning  ${BTS Files}/delta2.json  skip_parameter_relation_errors=${True}
    SSHLibrary.Close Connection
    pm_logs_general.Deintegrate BTS from NetAct Lab   ${NETACT_LAB.cmwas}    ${enb_release}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown

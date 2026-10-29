*** Settings ***
Documentation
    ...  This test was designed to test feature CB014065.
Library    XML    use_lxml=${TRUE}
Library    DateTime
Library    SSHLibrary
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
${HOST}=    192.168.255.129
${USERNAME}=     toor4nsn
${PASSWORD}=    oZPS0POrRieRtu
${BTS_ip}           192.168.255.129
${BTS_login}        toor4nsn
${BTS_password}     oZPS0POrRieRtu
${FSP_ID}           fsp-1a
${SSH_COMMAND}      ssh -tt ${BTS_login}@${FSP_ID}
${KNOWN_WARNING}    Are you sure you want to continue connecting
${PASSWORD_PROMPT}  Password:

*** Keywords ***
TC__LOGS__Snapshot_triggered_by_Fault_SignatureKeyword_Match

    [Documentation]
    ...  ******************
    ...  Author: Radu Turcu
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2025-09-24 - Initial Creation
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if snapshot is automatically triggered by fault Signature Keyword and sent to NetAct
    ...  test validate snapshot from NetAct
    ...  *******************

    Set Tags   LOGS
    ...    PHASE-CRT

    Step 1: Preconditions
    Step 2: Configure Fault Snapshot Trigger 2087
    Step 3: Trigger Fault 2087 for ABIA
    Step 4: Check If Snapshot is Triggered
    Step 5: Check If Snapshot is present on NetAct

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
    ${SW}  coam.Get Sw Version
    ${snapshot_name}  Set Variable  *Snapshot_MRBTS-${BTS_ID}_*_${SW}_*
    Set Test Variable  ${snapshot_name}
    Set Snapshot Destination To  NetAct
    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}
    Check if NetAct is deintegrated
    Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}

Step 2: Configure Fault Snapshot Trigger 2087
    [Documentation]
    ...  In this test step faultSnapshotTriggers list for foult 2087 is created and added to configuration.
    Log  \nStep 2: Configure Fault Snapshot Trigger  console=${True}
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
    ...  ELSE  Create Fault Snapshot Triggers 2087    ${SCF}  ${delta_id}

Step 3: Trigger Fault 2087 for ABIA
    [Documentation]
    ...    In this step there is triggered the FID-2087 for BBMOD
    Log    Step 3: Trigger Fault 2087 for ABIA   console=${True}
    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login             ${BTS_login}    ${BTS_password}
    # Start SSH to FSP-id
    SSHLibrary.Write    ${SSH_COMMAND}
    ${output}=    Read Until Warning Or Password
    SSHLibrary.Read Until    ${PASSWORD_PROMPT}
    SSHLibrary.Write         ${BTS_password}
    SSHLibrary.Read              delay=3s
    SSHLibrary.Write             ps aux |grep -v grep |grep HWRLedSExe | awk '{print $2}'
    ${process_info}=    SSHLibrary.Read              delay=3s
    ${pid}=    Get Line  ${process_info}  0
    SSHLibrary.Write             kill -11 ${pid}
    SSHLibrary.Close Connection

Step 4: Check If Snapshot is Triggered
    [Documentation]
    ...  In this KW it is checked if snapshot is triggered by fault 4590 and collection is finished.

    Log  \nCheck If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel
    ...  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"2087:On alarm sending",stateInfo.usageState=Active]
    ...  timeout=120  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by fault.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered by fault.  ${TRUE}
    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    ${time_0}=   Get Time
    ${conv_time_0}=   Convert Date    ${time_0}    epoch
    Set Test Variable  ${conv_time_0}
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"2087:On alarm sending"]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}

Step 5: Check If Snapshot is present on NetAct
   [Documentation]    Check if snapshot is on netact

   Log  \nCheck if snapshot is on netact, wait 180s then check  console=${True}
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

Create Fault Snapshot Triggers 2087
    [Arguments]  ${SCF}  ${delta_id}

    ${get_smod_l}   coam.get_managed_objects  SMOD_L  timeout=600s
    ${SMOD1_SN}  Set Variable  ${get_smod_l[1]["parameters"]["serialNumber"]}
    Log  Selected SMOD serial number: ${get_Smod_l[1]["parameters"]["serialNumber"]}  console=true

    ${fault_snapshot_triggers_dict}  Create Dictionary  faultNumber=2087  triggerType=onAlarmSend    snapshotCoverageLevel=Minor
    ...    faultSignatureKeywords=ABIA
    ${fault_snapshot_trigger}  Evaluate Xpath  ${SCF}  //p[@name='faultNumber' and text()='2087']
    Run Keyword If  '${fault_snapshot_trigger}'=='[]'  Run Keywords
    ...  Log  Adding faultSnapshotTriggers list for foult 2087 to configuration.  console=${True}
    ...  AND  coam.Append Complex Item To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  list_name=faultSnapshotTriggers  &{fault_snapshot_triggers_dict}
    ...  delta_id=${delta_id}
    ...  AND  coam.Get Delta  ${delta_id}
    ...  AND  coam.Save Delta  ${BTS Files}/delta.json  ${delta_id}
    ...  AND  coam.Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=${True}
    ...  AND  Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${True}

Create Trblcadm Mo
    [Arguments]  ${SCF}  ${delta_id}

    Log  Adding TRBLCADM managed object to configuration  console=${True}
    coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  create  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actCoreDumpFileCollection  true  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actRemoteSyslogTransmission  false  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  snapshotUploadDelayForFault6450  0  ${delta_id}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${True}
    Create Fault Snapshot Triggers  ${SCF}  ${delta_id}

Read Until Warning Or Password
    ${output}=    SSHLibrary.Read Until    :
    Run Keyword If    """${KNOWN_WARNING} in ${output}"""    SSHLibrary.Write    yes
    [Return]    ${output}

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
    Log  Reset ongoing    console=${True}
    coam.Reset Site  600
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
    Log    Reset site done    console=${TRUE}
    Check Alarm 6450 and clear it

Check Alarm 6450 and clear it
    [Documentation]
    ...   This keyword verifies status of fault 6450

    Log   \nCheck If Alarm 6450 is present.   console=${True}
    ${fault_status}   Run Keyword And Return Status   Wait Until Keyword Succeeds   120   10
    ...   coam.Assert Alarm Active   parameters=alarmId=7115, faultId=6450   timeout=120
    Run Keyword If   ${fault_status}    Run Keywords
    ...   Log   Execute a local snapshot to clear 6450   console=${True}
    ...   AND    Wait Until Keyword Succeeds  20min  2min  Collect Snapshot  ${BTS_FILES}/snapshot6450.zip

    Log   \nCheck If Alarm 6450 is cleared.   console=${True}
    ${fault_status}   Run Keyword And Return Status   Wait Until Keyword Succeeds   120   10
    ...   coam.Assert Alarm Active   parameters=alarmId=7115, faultId=6450   timeout=120
    Run Keyword If   '${fault_status}' == 'False'
    ...   Log    Fault 6450 NOT present   console=${True}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown

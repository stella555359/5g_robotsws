*** Settings ***
Documentation
...    Tests for CB014065
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
Resource    ../resources/pdu.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  2700
${RMOD_RN}  NONE  # Product Name of RMOD that is to be tested (if left None, a random RMOD is chosen)
${RMOD_SN}  NONE  # Serial Number of RMOD that is to be tested (if left None, a random RMOD is chosen)

*** Keywords ***
TC__LOGS__CB014065_TC11_NMS_AlarmKeyword_Match

    [Documentation]
    ...  ******************
    ...  Author: Mihai Glesnea
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2025-10-15 - Initial Creation
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if snapshot is automatically triggered by alarm Keyword and sent to NetAct
    ...  test validate snapshot from NetAct
    ...  *******************

    Set Tags   LOGS
    ...    PHASE-CRT

    Step 1: Preconditions
    Step 2: Configure Fault Snapshot Trigger for a selected RMOD object
    Step 3: Trigger Fault 10 for RMOD
    Step 4: Check If Snapshot is Triggered
    Step 5: Check If Snapshot is present on NetAct


Step 1: Preconditions
    [Documentation]
    ...  In this test step test check in NMS connection is active.
    ...  reset site is performed to reset the number of snapshot sent to NetAct
    ...  variable are created

    Log  Step 1: Preconditions  console=${True}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${False}
    Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${False}
    Set Test Variable  ${CELL_ADDED}  ${False}
    ${bts_connection}=  coam.connect_to
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Log  Reset ongoing    console=${True}
    coam.Reset Site  900
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
    Log    Reset site done    console=${TRUE}
    ${SW}  coam.Get Sw Version
    ${snapshot_name}  Set Variable  *Snapshot_MRBTS-${BTS_ID}_*_${SW}_*
    Set Test Variable  ${snapshot_name}
    Set Snapshot Destination To  NetAct
    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}
    Check if NetAct is deintegrated
    Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}

Step 2: Configure Fault Snapshot Trigger for a selected RMOD object
    [Documentation]
    ...  Set Random RMOD SN and product name
    ...  In this test step faultSnapshotTriggers list for fault 10 is created (onAlarmSend and
    ...  alarm fault keywords = ${RMOD_PN})and added to configuration.

    Log  Configure Fault Snapshot Trigger  console=${True}
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
    ...  ELSE  Create Fault Snapshot Triggers    ${SCF}    ${delta_id}

Step 3: Trigger Fault 10 for RMOD
    [Documentation]
    ...   In this step RMOD will hard reset to generate FID:10

    Log    Step 3.1: Turn off RMOD_${RMOD_PN} RMOD_${RMOD_SN} to generate FID:10  console=${True}

    pdu.Pdu BTS Interface Off    RMOD_${RMOD_SN}
    Set Test Variable  ${RMOD_OFF}  ${True}

    ${fault_status}  Run keyword and return status  Wait until keyword succeeds  420  10
    ...  coam.Assert Alarm Active  parameters=alarmId=7116, faultId=10, faultName="No connection to unit", severity=Critical    timeout=120
    Run keyword if  ${fault_status}
    ...  Log  Fault 10 "No connection to unit" - severity=Critical - appeared  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Fault 10 "No connection to unit - did not not appear    ${True}

    Log    Step 3.2: Turn on RMOD_${RMOD_PN} RMOD_${RMOD_SN}    console=${True}

    pdu.Pdu BTS Interface On    RMOD_${RMOD_SN}
    Set Test Variable  ${RMOD_OFF}  ${False}
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States

Step 4: Check If Snapshot is Triggered
    Check If Snapshot Is Collected

Step 5: Check If Snapshot is present on NetAct
    Check if snapshot is on netact


Create Fault Snapshot Triggers
    [Arguments]  ${SCF}  ${delta_id}

    Log  Select random RMOD object  console=${True}
    ${rmod_param}    coam.Get Parameters For All    RMOD
     @{rmod_serial_number_list}=    Create List

     FOR  ${rmod}  IN  @{rmod_param}
         Append To List  ${rmod_serial_number_list}  RMOD_${rmod.serialNumber}    RMOD_${rmod.productName}
     END
     Set Test Variable    ${rmod_serial_number_list}

    Log  Choosing a random RMOD SN...  console=${True}
    ${rmods}  Query Infomodel  get list //RMOD_L-*
    ${rmod_count}  Get Length  ${rmods}
    ${random_rmod_number}  Evaluate  random.randint(0, ${rmod_count}-1)  modules=random
    Set Test Variable  ${RMOD_PN}  ${rmods}[${random_rmod_number}][productName]
    Set Test Variable  ${RMOD_SN}  ${rmods}[${random_rmod_number}][serialNumber]
    Log  Rmod ${RMOD_PN} with Serial Number ${RMOD_SN} will be used    console=${True}

    ${fault_snapshot_triggers_dict}  Create Dictionary  faultNumber=10  triggerType=onAlarmSend    alarmFaultKeywords=${RMOD_PN}
    ${fault_snapshot_trigger}  Evaluate Xpath  ${SCF}  //p[@name='faultNumber' and text()='10']
    Run Keyword If  '${fault_snapshot_trigger}'=='[]'  Run Keywords
    ...  Log  Adding faultSnapshotTriggers list for fault 10 to configuration.  console=${True}
    ...  AND  coam.Append Complex Item To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  list_name=faultSnapshotTriggers  &{fault_snapshot_triggers_dict}
    ...  delta_id=${delta_id}
    ...  AND  coam.Get Delta  ${delta_id}
    ...  AND  coam.Save Delta  ${BTS Files}/delta.json  ${delta_id}
    ...  AND  coam.Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=${True}
    ...  AND  Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${True}

Check If Snapshot Is Collected
    [Documentation]
    ...  In this KW it is checked if snapshot is triggered by fault 10 and collection is finished.

    Log  Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel
    ...  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"10:On alarm sending",stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by alarmKeyword ${RMOD_PN} for FID10:On alarm sending  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered by alarmKeyword ${RMOD_PN} for FID10:On alarm sending  ${TRUE}
    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    ${time_0}=   Get Time
    ${conv_time_0}=   Convert Date    ${time_0}    epoch
    Set Test Variable  ${conv_time_0}
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"10:On alarm sending"]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}

Check if snapshot is on netact
   [Documentation]    Check if snapshot is on netact

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

Create Trblcadm Mo
    [Arguments]  ${SCF}  ${delta_id}

    Log  Adding TRBLCADM managed object to configuration  console=${True}
    coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  create  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actCoreDumpFileCollection  true  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actRemoteSyslogTransmission  false  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  snapshotUploadDelayForFault6450  0  ${delta_id}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${True}
    Create Fault Snapshot Triggers  ${SCF}  ${delta_id}

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
    Log  Custom Test Teardown  console=${True}
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
#    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
#    ...    AND    Common Test Teardown

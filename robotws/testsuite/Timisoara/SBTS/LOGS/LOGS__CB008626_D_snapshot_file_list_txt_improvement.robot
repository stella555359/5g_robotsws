*** Settings ***
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    SeleniumLibrary
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Library    taf.selenium.sbts    WITH NAME    selenium_sbts

Library    DateTime


Resource   ../resources/verdicts.robot
Resource   ../resources/pm_logs_frame.robot
Resource   ../resources/pm_logs_general.robot
Resource   ../resources/bts_states.robot
Resource   ../resources/BTS_log_level.robot
Resource   ../resources/ssh_utils.robot
Resource   ../resources/pdu.robot
Resource   taf/rfrl/common_resources/common_step/interface.robot


*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}    2700


*** Keywords ***
TC__LOGS__CB008626_D_snapshot_file_list_txt_improvement
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26287
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Refactored from the test /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/cOAM/CB008626
    ...  The purpose of this Test Case is to check the procedure to include snapshot_file_list.txt into snapshot package.
    ...  Snapshot_file_list.txt should be in snapshot regardless of the trigger type and the local/remote destination.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25493 - Initial creation
    ...  - 13.07.2023 - https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/76058 - Merge request
    ...  - 06.10.2023 - Added NRBTS_ID variable, its not the same as MRBTS_ID
    ...  - 13.10.2023 - TAT-26287 - Test refactor
    ...  - 03.01.23 - change NetAct integration KW and variables

    Set Tags    CA-LOGS    AUTHOR-rafal.sytyk@nokia.com    MAINTAINER-jakub.kokoszka@nokia.com
    ...        GROUP_IN_CHARGE-WRO_6_Vrf    SW-SBTS23R4    FEATURE-CB008626


    Step 0: Precondition
    Step 1: Check Presence Of Snapshot File List Localy
    Step 2: Check Presence Of Snapshot File List from LSS
    Step 3: Check Presence Of Snapshot File List from NetAct
    Step 4: Close eth1 Connection While Snapshot Is Downloading And Check If Snapshot File List Not Present


Step 0: Precondition
    [Documentation]
    ...    In this step there are needed values defined

    Log    \nStep 0: Precondition   console=${True}

    Set Test Variable    ${SCF_upload_needed}    ${False}
    Set Test Variable    ${NetAct_connected}     ${False}
    Run    mkdir ${BTS Files}/uncomplete
    ${vm_ip}  ssh_utils.Get VM Ip
    Set Test Variable    ${vm_ip}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${SW}  coam.Get Sw Version
    ${snapshot_name}  Set Variable  Snapshot_MRBTS-${bts_id}_*_${SW}_*
    Set Test Variable  ${snapshot_name}
    ${bts_name}    bts_states.Get BTS Name
    Set Test Variable  ${BTS_NAME}  ${bts_name}
    Log to console    Check if NetAct is deintegrated
    Set Test Variable    ${RMOD_Off}  ${False}
    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}
    Check if NetAct is deintegrated
    ${rmod_param}    coam.Get Parameters For All    RMOD
    @{rmod_serial_number_list}=    Create List

    FOR  ${mod}  IN  @{rmod_param}
        Append To List  ${rmod_serial_number_list}  RMOD_${mod.serialNumber}
    END
    Set Test Variable    ${rmod_serial_number_list}

    coam.Get Current Scf File   ${BTS_Files}  scf.xml  export_type=configuration
    ${SCF}  Parse Xml  ${BTS_Files}/scf.xml
    Set Test Variable  ${SCF}
    ${mnlent_element}  Evaluate Xpath  ${SCF}  //managedObject[contains(@class, 'MNLENT')]
    ${MNLENT_DISTNAME}  XML.Get Element Attribute  ${mnlent_element[0]}  distName
    Set Test Variable  ${MNLENT_DISTNAME}


Step 1: Check Presence Of Snapshot File List Localy
    [Documentation]
    ...    In this step test check presence of snapshot file list localy

    Log    \nStep 1: Check Presence Of Snapshot File List Localy    console=${True}

    @{time}=    Get Time    year month day hour min
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot    ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}_local.zip  timeout=600
    Run Keyword If    ${snapshot_status}    Run Keywords
    ...    Log    Collecting snapshot via admin succeeded  console=${True}
    ...    AND    Set Test Variable    ${path_to_snapshot}    ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}_local.zip
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}

    ${Found_file_dict}    snapshot.Get Data From Snapshot    ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}_local.zip
    Should Contain     ${Found_file_dict}    snapshot_file_list.txt
    Log    \nsnapshot_file_list.txt was found in snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}_local.zip    console=${True}


Step 2: Check Presence Of Snapshot File List from LSS
    [Documentation]
    ...    In this step test check presence of snapshot file list in snapshot from LSS, snapshotCoverageLevel=L1Files
    ...    Snapshot will be triggered FID:10 - On alarm cancellation

    Log    \nStep 2: Check Presence Of Snapshot File List from LSS    console=${True}

    Log    Set Snapshot Destination To LSS    console=${True}
    Set Snapshot Destination To  LSS

    Log    Set Snapshot Coverage Level to L1Files   console=${True}
    ${delta_changes}    Set Variable    delta_changes
    coam.Create Delta    ${delta_changes}
    ${fault_snapshot_triggers_dict}  Create Dictionary  faultNumber=10  snapshotCoverageLevel=L1Files  triggerType=onAlarmCancellation
    coam.Append Complex Item To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  list_name=faultSnapshotTriggers  &{fault_snapshot_triggers_dict}
    ...  delta_id=${delta_changes}
    coam.Get Delta  ${delta_changes}
    coam.Save Delta  ${BTS Files}/changes.json  ${delta_changes}
    coam.Perform Delta Recommissioning    delta_file=${BTS Files}/changes.json    skip_parameter_relation_errors=${True}
    Set Test Variable  ${SCF_upload_needed}  ${True}

    Log    Power off first RU to trigger FID:10 and power on to trigger snapshot on alarm cancellation    console=${True}
    Power off first RU to trigger FID:10 and power on to trigger snapshot on alarm cancellation

    Log    Check If Snapshot Is Collected: 10:On alarm cancellation    console=${True}
    Check If Snapshot Is Collected

    Log    Chceck if snapshot is on LSS if yes zipped and download to local disc    console=${True}
    Chceck if snapshot is on LSS

    Log    Check if snapshot_file_list.txt exist in snapshot from LSS    console=${True}
    ${Found_file_dict}    snapshot.Get Data From Snapshot    ${path_to_snapshot_from_lss}
    Should Contain     ${Found_file_dict}    snapshot_file_list.txt
    Log    \nSnapshot_file_list.txt was found in snapshot downloaded from LSS    console=${True}
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States


Step 3: Check Presence Of Snapshot File List from NetAct
    [Documentation]
    ...    In this step test check presence of snapshot file list in snapshot from NetAct, snapshotCoverageLevel=FullWithoutRFLogs
    ...    Snapshot will be triggered FID:10 - On alarm cancellation
    ...    snapshot can be triggered by one FID every 15 minutes, the interval between these triggers is counted in these step
    ...    ${conv_time_0} firs trigger to LSS second trigger${conv_time_1} to Netact,
    ...    if the difference is less than 900s the test will sleep ${Time_to_trigger_next Snapshot}

    Log    \nStep 3: Check Presence Of Snapshot File List from NetAct    console=${True}

    Log    Set Snapshot Destination To NetAct    console=${True}
    Set Snapshot Destination To  NetAct

    Log    Set Snapshot Coverage Level to Full Without RF Logs   console=${True}
    ${delta_changes2}    Set Variable    delta_changes2
    coam.Create Delta    ${delta_changes2}
    ${fault_snapshot_triggers_dict}  Create Dictionary  faultNumber=10  snapshotCoverageLevel=FullWithoutRFLogs  triggerType=onAlarmCancellation
    coam.Append Complex Item To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  list_name=faultSnapshotTriggers  &{fault_snapshot_triggers_dict}
    ...  delta_id=${delta_changes2}
    coam.Get Delta  ${delta_changes2}
    coam.Save Delta  ${BTS Files}/changes2.json  ${delta_changes2}
    coam.Perform Delta Recommissioning    delta_file=${BTS Files}/changes2.json    skip_parameter_relation_errors=${True}

    Log    Integrate BTS with NetAct Lab    console=${True}
    Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}
    Set Test Variable    ${NetAct_connected}    ${True}
    Log    Get time to check time between snapshot triggers
    ${time_1}=   Get Time
    ${conv_time_1}=   Convert Date    ${time_1}    epoch
    ${delta_t}=    Evaluate   ${conv_time_1}-${conv_time_0}
    Log    Current time between snapshot triggers = ${delta_t}s
    ${Time_to_trigger_next_snapshot}  Evaluate  900-int(${delta_t})
    Run Keyword If    ${delta_t}>900   Run Keyword
    ...  Log    time between snapshot triggers >15min
    ...  ELSE   Run Keywords
    ...  Log  Waiting ${Time_to_trigger_next_snapshot}s for next snapshot trigger....  console=${True}
    ...  AND  Sleep  ${Time_to_trigger_next_snapshot}s

    Log    Power off first RU to trigger FID:10 and power on to trigger snapshot on alarm cancellation    console=${True}
    Power off first RU to trigger FID:10 and power on to trigger snapshot on alarm cancellation

    Log    Check If Snapshot Is Collected: 10:On alarm cancellation    console=${True}
    Check If Snapshot Is Collected

    Log to console    Check Presence Of Snapshot File List On NetAct

    Log    Chceck if snapshot is on NetAct if yes download to local disc    console=${True}
    Chceck if snapshot is on netact

    Log    Check if snapshot_file_list.txt exist in snapshot from NetAct    console=${True}
    ${Found_file_dict}    snapshot.Get Data From Snapshot    ${path_to_snapshot_from_NetAct}
    Should Contain     ${Found_file_dict}    snapshot_file_list.txt
    Log    \nSnapshot_file_list.txt was found in snapshot downloaded from NetAct    console=${True}
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States


Step 4: Close eth1 Connection While Snapshot Is Downloading And Check If Snapshot File List Not Present
    [Documentation]
    ...    In this step test check presence of snapshot file while snapshot downloaded was interrupted
    ...    Check if snapshot file list not present

    Log    \nStep 4: Close eth1 Connection While Snapshot Is Downloading And Check If Snapshot File List Not Present   console=${True}

    Log  Log to WebEM and start collect snapshot  console=${True}
    BTS_log_level.WebEM Login with the given path to download files    ${BTS Files}/uncomplete

    Wait Until Element Is Visible  //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[3]/a[6]/i
    ...    30s  WebElement is not fully loaded in 30s seconds.
    sleep    30s
    Capture Page Screenshot  1_WebEM_SBTS_initial_state.png
    Click Element  xpath://*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[3]/a[6]/i
    sleep    10s
    Capture Page Screenshot  2_WebEM_SBTS_clik_snapshot.png
    sleep    10s
    Click Element  xpath://*[@id="p-tabpanel-0"]/snapshot/div/div[2]/ui-button/button
    sleep    10s
    Capture Page Screenshot  3_WebEM_SBTS_clik_collect_snapshot.png
    sleep    30s
    Log  Close connection link set eth1 down  console=${True}
    Run    sudo ip link set eth1 down
    sleep   40s
    Log  Open connection sudo ip link set eth1 up  console=${True}
    Run    sudo ip link set eth1 up
    sleep   60s

    Log  Check if partial snapshot collected  console=${True}
    ${snapshot_name}    Run     ls ${BTS Files}/uncomplete
    Should Contain      ${snapshot_name}    Snapshot_MRBTS-${BTS_ID}_${BTS_NAME}
    Log  Check If Snapshot File List Not Present  console=${True}
    ${Found_file_dict}    snapshot.Get Data From Snapshot    ${BTS Files}/uncomplete/${snapshot_name}
    Should Not Contain     ${Found_file_dict}    snapshot_file_list.txt
    Log    snapshot_file_list.txt was not found in partial snapshot as expected    console=${True}


Chceck if snapshot is on netact
   [Documentation]    Chceck if snapshot is on netact

   Log  \nChceck if snapshot is on netact  console=${True}
   Sleep  180s
   ${na_node_ip}    Set Variable    ${NETACT_LAB.sn_node}
   ${NA_OMC_PASS}  Set Variable  Medsql!_1893
   ${NA_OMC_LOGIN}  Set Variable  omc
   ${cmd}  Set Variable  find /d/oss/global/diagsnap/ne3sws -name ${snapshot_name} -cmin -20 2>/dev/null
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
   ${download_snapshot_name_without_extension}    Fetch From Left  ${download_snapshot_name}    .zip
   ${download_snapshot_name}  Set Variable  ${download_snapshot_name.rstrip()}
   OperatingSystem.Run    mv ${BTS_Files}/${download_snapshot_name} ${BTS_Files}/${download_snapshot_name_without_extension}_NetAct.zip
   Sleep    30s
   ${path_to_snapshot_from_NetAct}  Set Variable  ${BTS_Files}/${download_snapshot_name_without_extension}_NetAct.zip
   OperatingSystem.File Should Exist  ${BTS_Files}/${download_snapshot_name_without_extension}_NetAct.zip
   ssh_utils.Set Connection Parameters  ${na_node_ip}  ${NA_OMC_LOGIN}    ${NA_OMC_PASS}
   ssh_utils.Run Command  ${cmd_rm}
   Log  Snapshot "${download_snapshot_name}" was found on NetAct and downloaded to local disk  console=${true}
   Set Test Variable  ${path_to_snapshot_from_NetAct}


Power off first RU to trigger FID:10 and power on to trigger snapshot on alarm cancellation
   [Documentation]    KW power off first RU to trigger FID:10 and power on to trigger snapshot on alarm cancellation

    Log    \nTurn off RMOD to generate FID:10    console=${True}

    pdu.Pdu BTS Interface Off    ${rmod_serial_number_list}[0]
    Log    \n${rmod_serial_number_list}[0]: power turn OFF    console=${True}
    Set Test Variable  ${RMOD_Off}  ${True}

    ${fault_status}  Run Keyword And Return Status  Wait until keyword succeeds  360  10
    ...  coam.Assert Alarm Active  parameters=alarmId=7116, faultId=10, faultName="No connection to unit"    timeout=120
    Run keyword if  ${fault_status}
    ...  Log  Fault 10 "No connection to unit" - appeared  console=${True}
    ...  ELSE  Set Test Failed  Fault 10 "No connection to unit - did not not appear    ${True}

    pdu.Pdu BTS Interface On    ${rmod_serial_number_list}[0]
    Log  \npower on ${rmod_serial_number_list}[0] was turned ON  console=${True}
    Set Test Variable  ${RMOD_Off}  ${False}

    ${inactive_fault_status}  Run keyword and return status  Wait until keyword succeeds  600  10
    ...  coam.Assert Alarm Inactive  parameters=alarmId=7116, faultId=10, faultName="No connection to unit"    timeout=120
    Run keyword if  ${inactive_fault_status}
    ...  Log  Fault 10 is inactive on BTS.    console=${True}
    ...  ELSE  Set test failed  Fault 10 is still active on BTS.


Chceck if snapshot is on LSS
    [Documentation]
    ...  In KW test login to lss server and check if snapshot is present
    ...  if yes zip directory to snapshot.zip file after that download zip file to local disk

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
    SSHLibrary.Execute Command    cd /home/coam/
    SSHLibrary.Execute Command  zip -r ${snapshot_file_name_on_lss}_LSS.zip ${snapshot_file_name_on_lss}
    Sleep  60s
    Run  sshpass -p '${lss_server_pass}' scp ${lss_server_user}@${lss_sever_ip}:/home/coam/${snapshot_file_name_on_lss}_LSS.zip ${BTS_Files}
    Sleep  60s
    SSHLibrary.Execute Command  rm -r /home/coam/${snapshot_file_name_on_lss}
    Log  ${snapshot_file_name_on_lss} was removed from LSS server
    Sleep  1s
    SSHLibrary.Execute Command  rm /home/coam/${snapshot_file_name_on_lss}_LSS.zip
    Log  ${snapshot_file_name_on_lss}_LSS.zip was removed from LSS server
    ${path_to_snapshot_from_lss}  Set Variable  ${BTS_Files}/${snapshot_file_name_on_lss}_LSS.zip
    OperatingSystem.File Should Exist  ${BTS_Files}/${snapshot_file_name_on_lss}_LSS.zip
    Log  Snapshot was downloaded to local disk   console=${true}
    Set Test Variable  ${path_to_snapshot_from_lss}
    SSHLibrary.Close Connection


Wait Element Visible And Click
    [Documentation]
    ...  In KW test Wait Element Visible And Click using Selenium Library

    [Arguments]    ${locator}   ${time_out}=20s
    Wait Until Element Is Visible   ${locator}  ${time_out}
    wait until keyword succeeds   20s  2s  click element   ${locator}


Check If Snapshot Is Collected
    [Documentation]
    ...  In this KW it is checked if snapshot is triggered by FID:10 - On alarm cancellation

    Log  \nCheck If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel
    ...  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"10:On alarm cancellation",stateInfo.usageState=Active]
    ...  timeout=120  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by: FID:10:On alarm cancellation.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered.  ${TRUE}
    Log    Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    Log    Get time to check time between snapshot triggers
    ${time_0}=   Get Time
    ${conv_time_0}=   Convert Date    ${time_0}    epoch
    Set Test Variable  ${conv_time_0}
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"10:On alarm cancellation"]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}


Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}

    Run Keyword If  ${RMOD_Off}  Run Keywords
    ...    pdu.Pdu BTS Interface On    ${rmod_serial_number_list}[0]
    ...    AND    Log  power on ${rmod_serial_number_list}[0] was turned ON  console=${True}
    ...    AND    Set Test Variable  ${RMOD_OFF}  ${False}
    ...    AND    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States

    Run Keyword If  ${NetAct_connected}  Run Keywords
    ...  Log    Deintegrate NetAct lab console=${True}
    ...  AND    Deintegrate BTS from NetAct Lab   ${NETACT_LAB.cmwas}    ${enb_release}
    ...  AND    Set Test Variable  ${NetAct_connected}  ${False}
    ...  AND    Log  Deintegrate done console=${True}

    Run Keyword If    ${SCF_upload_needed}    Run Keywords
    ...  Log  SCF will be upload  console=${True}
    ...  AND  coam.Perform Commissioning  ${BTS_ID}  ${BTS Files}/scf.xml  skip_parameter_relation_errors=True  timeout=900
    ...  AND  Wait Until Keyword Succeeds  20m  1m  Check All Modules And All Cells Working States
    ...  AND    Set Test Variable  ${SCF_upload_needed}  ${False}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown

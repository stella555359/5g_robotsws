*** Settings ***
Documentation  CB010788 and CNI-127210 specific keywords
Library     ../resources/extractor.py
Library     SSHLibrary
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     taf.transport.ssh  WITH NAME  ssh
Library     DateTime
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/unpacking.robot
Resource    ../resources/diagnostic_check.robot


*** Variables ***
${BTS_ip}           192.168.255.129
${BTS_login}        toor4nsn
${BTS_password}     oZPS0POrRieRtu

*** Keywords ***
Configure NOTE to unhide suppressed faults
    [Documentation]
    ...  Operator enables the hidden alarm reporting by configuring the structure
    ...  MNL/NOTES/NOTE.attribute.attribName=enableInformativeAlarmReport with value (MNL/NOTES/NOTE.attribute.attribValue)
    ...  to specify hidden fault for which informative alarm should start to be reported.
    ...  *AUTHOR*
    ...  andrei.maria@nokia.com
    [Arguments]    ${attribValue}

    Set Test Variable  ${attributeFid247_create}    ${False}

#    ${delta_changes}    Set Variable    delta_changes
#    coam.Create Delta    ${delta_changes}
#    coam.Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/NOTES-1  create  ${delta_changes}
#    coam.Get Delta  ${delta_changes}
#    coam.Save Delta  ${BTS Files}/changes.json  ${delta_changes}
#    Run Keyword And Ignore Error    coam.Perform Delta Recommissioning  delta_file=${BTS Files}/changes.json  skip_parameter_relation_errors=${True}

    ${delta_changes}    Set Variable    delta_changes
    coam.Create Delta    ${delta_changes}
    coam.Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/NOTES-1/NOTE-2  create  ${delta_changes}
    ${attributeFid247_dict}  Create Dictionary
    ...   attribName=enableInformativeAlarmReport
    ...   attribValue=${attribValue}
    coam.Append Complex Item To Delta
    ...  MRBTS-${BTS_ID}/MNL-1/NOTES-1/NOTE-2
    ...  list_name=attribute
    ...  &{attributeFid247_dict}
    ...  delta_id=${delta_changes}
    coam.Get Delta  ${delta_changes}
    coam.Save Delta  ${BTS Files}/changes.json  ${delta_changes}
    Run Keyword And Ignore Error  coam.Perform Delta Recommissioning  delta_file=${BTS Files}/changes.json  skip_parameter_relation_errors=${True}

#    ${delta_changes}    Set Variable    delta_changes
#    coam.Create Delta    ${delta_changes}
#    coam.Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/NOTES-1/NOTE-1  update  ${delta_changes}
#    ${attributeFid247_dict}  Create Dictionary
#    ...   attribName=enableInformativeAlarmReport
#    ...   attribValue=${attribValue}
#    coam.Append Complex Item To Delta
#    ...  MRBTS-${BTS_ID}/MNL-1/NOTES-1/NOTE-1
#    ...  list_name=attribute
#    ...  &{attributeFid247_dict}
#    ...  delta_id=${delta_changes}
#    coam.Get Delta  ${delta_changes}
#    coam.Save Delta  ${BTS Files}/changes.json  ${delta_changes}
#    Run Keyword And Ignore Error  coam.Perform Delta Recommissioning  delta_file=${BTS Files}/changes.json  skip_parameter_relation_errors=${True}

    Set Test Variable  ${attributeFid247_create}    ${True}

Revert Note Delta Changes
    ${delta_changes}    Set Variable    delta_changes
    coam.Create Delta    ${delta_changes}
    coam.Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/NOTES-1/NOTE-2  delete  ${delta_changes}
    coam.Get Delta  ${delta_changes}
    coam.Save Delta  ${BTS Files}/changes.json  ${delta_changes}
    Run Keyword And Ignore Error  coam.Perform Delta Recommissioning  delta_file=${BTS Files}/changes.json  skip_parameter_relation_errors=${True}

Configure ALARMSUPP to Suppress FID:247
    [Documentation]
    ...  Operator enables CB010788 functionality (alarm suppression functionality) by configuring the parameter
    ...  MNL/MNLENT/FMCADM/ALARMSUPP.actAlarmsSuppression with value suppressAlarms. Also, the Fault 247 is specified
    ...  to be suppressed by configuring the structure MNL/MNLENT/FMCADM/ALARMSUPP.suppressedFaultList with
    ...  MNL/MNLENT/FMCADM/ALARMSUPP.suppressedFaultList.alarmSeverity=MINOR and MNL/MNLENT/FMCADM/ALARMSUPP.suppressedFaultList.faultId=247
    ...  *AUTHOR*
    ...  andrei.maria@nokia.com

    ${delta_changes}    Set Variable    delta_changes
    coam.Create Delta    ${delta_changes}
    coam.Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  update  ${delta_changes}
    coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  suppressAlarms
    ...    ${delta_changes}
    ${suppressedFaultList_Fid247_dict}  Create Dictionary
    ...   alarmSeverity=MINOR
    ...   faultId=247
    coam.Append Complex Item To Delta
    ...  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1
    ...  list_name=suppressedFaultList
    ...  &{suppressedFaultList_Fid247_dict}
    ...  delta_id=${delta_changes}
    coam.Get Delta  ${delta_changes}
    coam.Save Delta  ${BTS Files}/changes.json  ${delta_changes}
    coam.Perform Delta Recommissioning  delta_file=${BTS Files}/changes.json  skip_parameter_relation_errors=${True}

Configure ALARMSUPP to Suppress FID:248
    [Documentation]
    ...  Operator enables CB010788 functionality (alarm suppression functionality) by configuring the parameter
    ...  MNL/MNLENT/FMCADM/ALARMSUPP.actAlarmsSuppression with value suppressAlarms. Also, the Fault 248
    ...  and Fault 250 are specified to be suppressed by configuring the structure MNL/MNLENT/FMCADM/ALARMSUPP.suppressAlarmsByMOCList with
    ...  MNL/MNLENT/FMCADM/ALARMSUPP.suppressAlarmsByMOCList.alarmSeverity=MINOR and MNL/MNLENT/FMCADM/ALARMSUPP.suppressAlarmsByMOCList.moc=EQM
    ...  *AUTHOR*
    ...  andrei.maria@nokia.com

    ${delta_changes}    Set Variable    delta_changes
    coam.Create Delta    ${delta_changes}
    coam.Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  update  ${delta_changes}
    coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  suppressAlarms
    ...    ${delta_changes}
    ${suppressAlarmsByMOCList_Fid248_250_dict}  Create Dictionary
    ...   alarmSeverity=MINOR
    ...   moc=EQM
    coam.Append Complex Item To Delta
    ...  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1
    ...  list_name=suppressAlarmsByMOCList
    ...  &{suppressAlarmsByMOCList_Fid248_250_dict}
    ...  delta_id=${delta_changes}
    coam.Get Delta  ${delta_changes}
    coam.Save Delta  ${BTS Files}/changes.json  ${delta_changes}
    coam.Perform Delta Recommissioning  delta_file=${BTS Files}/changes.json  skip_parameter_relation_errors=${True}

Get RawSuppressedAlarmHistory file
    [Documentation]
    ...    In this KW RawSuppressedAlarmHistory.txt file is downloaded to BTS files
    [Arguments]    ${RawSuppressedAlarmsFile}=RawSuppressedAlarmHistory.txt
    ${exit_code}    ${output}=    Run And Return Rc And Output
    ...    sshpass -p '${BTS_password}' scp -r ${BTS_login}@${BTS_ip}:/ram/RawSuppressedAlarmHistory.txt ${BTS Files}/${RawSuppressedAlarmsFile}
    Run Keyword If    ${exit_code}!=0
    ...    verdicts.Set Test Restriction  Could not get RawSuppressedAlarmHistory.txt file. File may not exist.

Get blackbox_RawSuppressedAlarmHistory file
    [Documentation]
    ...    In this KW blackbox_RawSuppressedAlarmHistory.txt file is downloaded to BTS files
    [Arguments]    ${blackbox_RawSuppressedAlarmsFile}
    ${cmd_part1}    Set Variable
    ...    sshpass -p '${BTS_password}' scp -r ${BTS_login}@${BTS_ip}:/ffs/run/logs/lifetimedata/blackbox_RawSuppressedAlarmHistory.txt
    ${cmd_part2}    Set Variable    ${BTS Files}/${blackbox_RawSuppressedAlarmsFile}
    ${exit_code}    ${output}=    Run And Return Rc And Output    ${cmd_part1} ${cmd_part2}
    Run Keyword If    ${exit_code}!=0
    ...    verdicts.Set Test Restriction  Could not get blackbox_RawSuppressedAlarmHistory.txt file. File may not exist.

Check if BBMOD Fault is Suppressed
    [Documentation]
    ...    Check if alarm from BBMOD appears as Active in RawSuppressedAlarmHistory.txt file
    [Arguments]    ${fid}    ${BBMOD_pos}    ${RawSuppressedAlarmsFile}=${BTS Files}/RawSuppressedAlarmHistory.txt

    ${RawSuppressedAlarms}=     OperatingSystem.get file  ${RawSuppressedAlarmsFile}  encoding_errors=ignore
    ${RawSuppressedAlarmsActive}=    Fetch From Left  ${RawSuppressedAlarms}  Cancelled alarms
    Should contain    ${RawSuppressedAlarmsActive}  (0${fid})
    Should Match Regexp   ${RawSuppressedAlarmsActive}    MRBTS-${BTS_ID}\/EQM_R-\\d+\/APEQM_R-\\d+\/CABINET_R-\\d+\/BBMOD_R-${BBMOD_pos}
    ${ActiveSuppressedAlarmTimestamp}    Get Suppressed Alarm Timestamp    ${RawSuppressedAlarmsActive}    ${fid}
    Set Test Variable  ${ActiveSuppressedAlarmTimestamp}
    ${delta}=    DateTime.Subtract Date From Date    ${ActiveSuppressedAlarmTimestamp}    ${BTS_timestamp}
    Run Keyword If  ${delta} > 0
    ...    Log  Suppression TimeStamp for Fault ${fid} is correct.   console=${True}
    ...  ELSE  verdicts.Set Test Failed  Wrong Suppression TimeStamp for Fault ${fid}!  ${TRUE}
    Log    Fault ${fid} is Active in RawSuppressedAlarmHistory.txt    console=${True}

Check if SMOD Fault is Suppressed
    [Documentation]
    ...    Check if alarm from SMOD appears as Active in RawSuppressedAlarmHistory.txt file
    [Arguments]    ${fid}    ${RawSuppressedAlarmsFile}=${BTS Files}/RawSuppressedAlarmHistory.txt

    ${RawSuppressedAlarms}=     OperatingSystem.get file  ${RawSuppressedAlarmsFile}  encoding_errors=ignore
    ${RawSuppressedAlarmsActive}=    Fetch From Left  ${RawSuppressedAlarms}  Cancelled alarms
    Should contain    ${RawSuppressedAlarmsActive}  (0${fid})
    Should Match Regexp   ${RawSuppressedAlarmsActive}    MRBTS-${BTS_ID}\/EQM_R-\\d+\/APEQM_R-\\d+\/CABINET_R-\\d+\/SMOD_R-1
    ${ActiveSuppressedAlarmTimestamp}    Get Suppressed Alarm Timestamp    ${RawSuppressedAlarmsActive}    ${fid}
    Set Test Variable  ${ActiveSuppressedAlarmTimestamp}
    ${delta}=    DateTime.Subtract Date From Date    ${ActiveSuppressedAlarmTimestamp}    ${BTS_timestamp}
    Run Keyword If  ${delta} > 0
    ...    Log  Suppression TimeStamp for Fault ${fid} is correct.   console=${True}
    ...  ELSE  verdicts.Set Test Failed  Wrong Suppression TimeStamp for Fault ${fid}!  ${TRUE}
    Log    Fault ${fid} is Active in RawSuppressedAlarmHistory.txt    console=${True}

Check if BBMOD Fault is NOT Suppressed
    [Documentation]
    ...    Check if alarm from BBMOD appears as Cancelled in RawSuppressedAlarmHistory.txt file
    [Arguments]    ${fid}    ${BBMOD_pos}    ${RawSuppressedAlarmsFile}=${BTS Files}/RawSuppressedAlarmHistory.txt

    ${RawSuppressedAlarms}=     OperatingSystem.get file  ${RawSuppressedAlarmsFile}  encoding_errors=ignore
    ${RawSuppressedAlarmsCancelled}=    Fetch From Right  ${RawSuppressedAlarms}  Cancelled alarms
    Should contain    ${RawSuppressedAlarmsCancelled}  (0${fid})
    Should Match Regexp   ${RawSuppressedAlarmsCancelled}    MRBTS-${BTS_ID}\/EQM_R-\\d+\/APEQM_R-\\d+\/CABINET_R-\\d+\/BBMOD_R-${BBMOD_pos}
    ${CancelledSuppressedAlarmTimestamp}    Get Suppressed Alarm Timestamp    ${RawSuppressedAlarmsCancelled}    ${fid}
    ${delta}=    DateTime.Subtract Date From Date    ${CancelledSuppressedAlarmTimestamp}    ${ActiveSuppressedAlarmTimestamp}
    Run Keyword If  ${delta} > 0
    ...    Log  TimeStamp for Fault ${fid} suppression cancellation is correct.   console=${True}
    ...  ELSE  verdicts.Set Test Failed  TimeStamp for Fault ${fid} suppression cancellation is WRONG!  ${TRUE}
    Log    Fault ${fid} is Cancelled in RawSuppressedAlarmHistory.txt    console=${True}

Check if SMOD Fault is NOT Suppressed
    [Documentation]
    ...    Check if alarm from SMOD appears as Cancelled in RawSuppressedAlarmHistory.txt file
    [Arguments]    ${fid}    ${RawSuppressedAlarmsFile}=${BTS Files}/RawSuppressedAlarmHistory.txt

    ${RawSuppressedAlarms}=     OperatingSystem.get file  ${RawSuppressedAlarmsFile}  encoding_errors=ignore
    ${RawSuppressedAlarmsCancelled}=    Fetch From Right  ${RawSuppressedAlarms}  Cancelled alarms
    Should contain    ${RawSuppressedAlarmsCancelled}  (0${fid})
    Should Match Regexp   ${RawSuppressedAlarmsCancelled}    MRBTS-${BTS_ID}\/EQM_R-\\d+\/APEQM_R-\\d+\/CABINET_R-\\d+\/SMOD_R-1
    ${CancelledSuppressedAlarmTimestamp}    Get Suppressed Alarm Timestamp    ${RawSuppressedAlarmsCancelled}    ${fid}
    ${delta}=    DateTime.Subtract Date From Date    ${CancelledSuppressedAlarmTimestamp}    ${ActiveSuppressedAlarmTimestamp}
    Run Keyword If  ${delta} > 0
    ...    Log  TimeStamp for Fault ${fid} suppression cancellation is correct.   console=${True}
    ...  ELSE  verdicts.Set Test Failed  TimeStamp for Fault ${fid} suppression cancellation is WRONG!  ${TRUE}
    Log    Fault ${fid} is Cancelled in RawSuppressedAlarmHistory.txt    console=${True}

Revert Allow Delta Changes for FID:247
    [Documentation]
    ...   This keyword prepares and recommissions delta that removes CB010788 functionality

    Log   \nRemoving ALARMSUPP settings for FID:247 suppression from configuration   console=${True}
    ${delta_changes}   Set Variable   remove_delta_changes
    coam.Create Delta    ${delta_changes}
    coam.Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  update  ${delta_changes}
    coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  suppressAlarms  ${delta_changes}
    coam.Append Parameter Delete To Delta   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1   allowedAlarmList   ${delta_changes}
    coam.Get Delta  ${delta_changes}
    coam.Save Delta  ${BTS Files}/remove_delta_changes.json  ${delta_changes}
    coam.Perform Delta Recommissioning  delta_file=${BTS Files}/remove_delta_changes.json  skip_parameter_relation_errors=${True}

Revert Allow Delta Changes for FID:248
    [Documentation]
    ...   This keyword prepares and recommissions delta that removes CB010788 functionality

    Log   \nRemoving ALARMSUPP settings for FID:248 and 250 suppression from configuration   console=${True}
    ${delta_changes}   Set Variable   remove_delta_changes
    coam.Create Delta    ${delta_changes}
    coam.Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  update  ${delta_changes}
    coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  suppressAlarms  ${delta_changes}
    coam.Append Parameter Delete To Delta   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1   allowedFaultList   ${delta_changes}
    coam.Get Delta  ${delta_changes}
    coam.Save Delta  ${BTS Files}/remove_delta_changes.json  ${delta_changes}
    coam.Perform Delta Recommissioning  delta_file=${BTS Files}/remove_delta_changes.json  skip_parameter_relation_errors=${True}

Revert Suppress Delta Changes for FID:247
    [Documentation]
    ...   This keyword prepares and recommissions delta that removes CB010788 functionality

    Log   \nRemoving ALARMSUPP settings for FID:247 suppression from configuration   console=${True}
    ${delta_changes}   Set Variable   remove_delta_changes
    coam.Create Delta    ${delta_changes}
    coam.Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  update  ${delta_changes}
    coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  disabled  ${delta_changes}
    coam.Append Parameter Delete To Delta   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1   suppressedFaultList   ${delta_changes}
    coam.Get Delta  ${delta_changes}
    coam.Save Delta  ${BTS Files}/remove_delta_changes.json  ${delta_changes}
    coam.Perform Delta Recommissioning  delta_file=${BTS Files}/remove_delta_changes.json  skip_parameter_relation_errors=${True}

Revert Suppress Delta Changes for FID:248
    [Documentation]
    ...   This keyword prepares and recommissions delta that removes CB010788 functionality

    Log   \nRemoving ALARMSUPP settings for FID:248 and 250 suppression from configuration   console=${True}
    ${delta_changes}   Set Variable   remove_delta_changes
    coam.Create Delta    ${delta_changes}
    coam.Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  update  ${delta_changes}
    coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  disabled  ${delta_changes}
    coam.Append Parameter Delete To Delta   MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1   suppressAlarmsByMOCList   ${delta_changes}
    coam.Get Delta  ${delta_changes}
    coam.Save Delta  ${BTS Files}/remove_delta_changes.json  ${delta_changes}
    coam.Perform Delta Recommissioning  delta_file=${BTS Files}/remove_delta_changes.json  skip_parameter_relation_errors=${True}

Get Suppressed Alarm Timestamp
    [Arguments]    ${RawSuppressedAlarmsActive}    ${fid}
    ${RawSuppressedAlarmsTimestamps}=    Fetch From Left  ${RawSuppressedAlarmsActive}  ${fid}
    ${ExtractedSuppressedAlarmsTimestamps}    Get Regexp Matches    ${RawSuppressedAlarmsTimestamps}
    ...    \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}
    ${SuppressedAlarmTimestamp}    Get From List    ${ExtractedSuppressedAlarmsTimestamps}    -1
    [Return]  ${SuppressedAlarmTimestamp}

Extract RawSuppressedAlarmHistory file from Snapshot
    [Documentation]    In this step the RawSuppressedAlarmHistory.txt file is found and extracted from the snapshot

    Log    \nExtract RawSuppressedAlarmHistory.txt file from Snapshot    console=${TRUE}
    Locate RawSuppressedAlarmHistory File In Snapshot And Extract It    ${path_to_snap_1}

Locate RawSuppressedAlarmHistory File In Snapshot And Extract It
   [Documentation]    Find the RawSuppressedAlarmHistory.txt file in snapshot and extracts it. Takes the path to snapshot as argument and returns
   ...    the path to the extracted RawSuppressedAlarmHistory.txt file.

   [Arguments]    ${snapshot_path}
   Log  Looking for RawSuppressedAlarmHistory.txt file in snapshot  console=${True}
   ${snapshot_dict}   snapshot.Get Data From Snapshot  ${snapshot_path}

   FOR    ${key}    IN    @{snapshot_dict.keys()}
       ${SuppressedAlarm_file}    get regexp matches    ${snapshot_dict["${key}"][0]}    \.+BTS${BTS_ID}_(1|2)011_RawSuppressedAlarmHistory\.txt\.xz
       Exit For Loop If    ${SuppressedAlarm_file}
   END

   Run Keyword If    ${SuppressedAlarm_file}    suppress.Extract RawSuppressedAlarmHistory file    ${snapshot_path}    ${SuppressedAlarm_file[0]}
   ...    ELSE    Fail    RawSuppressedAlarmHistory.txt file not found

Extract RawSuppressedAlarmHistory file
    [Documentation]    Extracts the desired file from snapshot and sets the variable path_to_log_file.

    [Arguments]    ${path_to_snapshot}    ${file_to_extract}
    unpacking.Unpack Archive Content To Directory    ${path_to_snapshot}    ${BTS_Files}/snapshot_${timestamp}
    ${zip_from_extract}    Get Regexp Matches    ${file_to_extract}    [\\w.]+
    ${log_to_extract}    Replace String Using Regexp    ${zip_from_extract[0]}    (.xz)    ${EMPTY}
    unpacking.Unpack Archive Content To Directory
    ...  ${BTS_Files}/snapshot_${timestamp}/${zip_from_extract[0]}    ${BTS_Files}/snapshot_${timestamp}${log_to_extract}
    unpacking.Unpack Archive Content To Directory
    ...  ${BTS_Files}/snapshot_${timestamp}${log_to_extract}/${zip_from_extract[1]}    ${BTS_Files}/RawSuppressedAlarmHistory/${timestamp}

    Set Test Variable  ${path_to_SuppAlarm_file_from_Snapshot}  ${BTS_Files}/RawSuppressedAlarmHistory/${timestamp}

Extract blackbox_RawSuppressedAlarmHistory file from Snapshot
    [Documentation]    In this step the blackbox_RawSuppressedAlarmHistory.txt file is found and extracted from the snapshot

    Log    \nExtract blackbox_RawSuppressedAlarmHistory.txt file from Snapshot    console=${TRUE}
    Locate blackbox_RawSuppressedAlarmHistory File In Snapshot And Extract It    ${path_to_snap_1}

Locate blackbox_RawSuppressedAlarmHistory File In Snapshot And Extract It
   [Documentation]    Find the blackbox_RawSuppressedAlarmHistory.txt file in snapshot and extracts it.
   ...    Takes the path to snapshot as argument and returns the path to the extracted blackbox_RawSuppressedAlarmHistory.txt file.

   [Arguments]    ${snapshot_path}
   Log  Looking for blackbox_RawSuppressedAlarmHistory.txt file in snapshot  console=${True}
   ${snapshot_dict}   snapshot.Get Data From Snapshot  ${snapshot_path}

   FOR    ${key}    IN    @{snapshot_dict.keys()}
       ${SuppressedAlarm_file}    get regexp matches    ${snapshot_dict["${key}"][0]}
       ...    \.+BTS${BTS_ID}_(1|2)011_blackbox_RawSuppressedAlarmHistory\.txt\.xz
       Exit For Loop If    ${SuppressedAlarm_file}
   END

   Run Keyword If    ${SuppressedAlarm_file}   suppress.Extract blackbox_RawSuppressedAlarmHistory file  ${snapshot_path}  ${SuppressedAlarm_file[0]}
   ...    ELSE    Fail    blackbox_RawSuppressedAlarmHistory.txt file not found

Extract blackbox_RawSuppressedAlarmHistory file
    [Documentation]    Extracts the desired file from snapshot and sets the variable path_to_log_file.

    [Arguments]    ${path_to_snapshot}    ${file_to_extract}
    unpacking.Unpack Archive Content To Directory    ${path_to_snapshot}    ${BTS_Files}/snapshot_${timestamp}
    ${zip_from_extract}    Get Regexp Matches    ${file_to_extract}    [\\w.]+
    ${log_to_extract}    Replace String Using Regexp    ${zip_from_extract[0]}    (.xz)    ${EMPTY}
    unpacking.Unpack Archive Content To Directory
    ...  ${BTS_Files}/snapshot_${timestamp}/${zip_from_extract[0]}    ${BTS_Files}/snapshot_${timestamp}${log_to_extract}
    unpacking.Unpack Archive Content To Directory
    ...  ${BTS_Files}/snapshot_${timestamp}${log_to_extract}/${zip_from_extract[1]}    ${BTS_Files}/blackbox_RawSuppressedAlarmHistory/${timestamp}

    Set Test Variable  ${path_to_blackbox_SuppAlarm_file_from_Snapshot}  ${BTS_Files}/blackbox_RawSuppressedAlarmHistory/${timestamp}

Configure ALARMSUPP to Allow FID:247
    [Documentation]
    ...  Operator enables CB010788 functionality (alarm unsuppression functionality) by configuring the parameter
    ...  MNL/MNLENT/FMCADM/ALARMSUPP.actAlarmsSuppression with value allowAlarms. Also, the Fault 247 is specified
    ...  to be allowed by configuring the structure MNL/MNLENT/FMCADM/ALARMSUPP.allowedAlarmList with
    ...  MNL/MNLENT/FMCADM/ALARMSUPP.allowedAlarmList.alarmSeverity=MINOR and MNL/MNLENT/FMCADM/ALARMSUPP.allowedAlarmList.alarmId=7115
    ...  *AUTHOR*
    ...  andrei.maria@nokia.com

    ${delta_changes}    Set Variable    delta_changes
    coam.Create Delta    ${delta_changes}
    coam.Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  update  ${delta_changes}
    coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  allowAlarms
    ...    ${delta_changes}
    ${allowedFaultList_Fid247_dict}  Create Dictionary
    ...   alarmSeverity=MINOR
    ...   alarmId=7115
    coam.Append Complex Item To Delta
    ...  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1
    ...  list_name=allowedAlarmList
    ...  &{allowedFaultList_Fid247_dict}
    ...  delta_id=${delta_changes}
    coam.Get Delta  ${delta_changes}
    coam.Save Delta  ${BTS Files}/changes.json  ${delta_changes}
    coam.Perform Delta Recommissioning  delta_file=${BTS Files}/changes.json  skip_parameter_relation_errors=${True}

Configure ALARMSUPP to Allow FID:248
    [Documentation]
    ...  Operator enables CB010788 functionality (alarm unsuppression functionality) by configuring the parameter
    ...  MNL/MNLENT/FMCADM/ALARMSUPP.actAlarmsSuppression with value allowAlarms. Also, the Faults 248 and Fault 250 are specified to be allowed by
    ...  configuring the structure MNL/MNLENT/FMCADM/ALARMSUPP.allowedFaultList with MNL/MNLENT/FMCADM/ALARMSUPP.allowedFaultList.alarmSeverity=MINOR
    ...  and MNL/MNLENT/FMCADM/ALARMSUPP.allowedFaultList.faultId=248,250,4681
    ...  *AUTHOR*
    ...  andrei.maria@nokia.com

    ${delta_changes}    Set Variable    delta_changes
    coam.Create Delta    ${delta_changes}
    coam.Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  update  ${delta_changes}
    coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1  actAlarmsSuppression  allowAlarms
    ...    ${delta_changes}
    ${allowedFaultList_Fid248_250_dict}  Create Dictionary
    ...   alarmSeverity=MINOR
    ...   faultId=248,250,4681
    coam.Append Complex Item To Delta
    ...  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1
    ...  list_name=allowedFaultList
    ...  &{allowedFaultList_Fid248_250_dict}
    ...  delta_id=${delta_changes}
    coam.Get Delta  ${delta_changes}
    coam.Save Delta  ${BTS Files}/changes.json  ${delta_changes}
    coam.Perform Delta Recommissioning  delta_file=${BTS Files}/changes.json  skip_parameter_relation_errors=${True}

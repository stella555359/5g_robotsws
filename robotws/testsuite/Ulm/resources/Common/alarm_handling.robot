*** Settings ***
Documentation     Robot keywords related to alarm handling.
...               There are also python keywords providing filtering of alarm list.
...               See python/alarm_handling.py!

#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    Collections
Library    taf.sbts.oam.coam.admin       WITH NAME   admin
Library    python/robot_json_helper.py   WITH NAME   json_helper_py
Library    python/AlarmSorter.py

Resource   connect.robot

*** Variables ***
${P_console}    ${False}

*** Keywords ***

Get All Alarms From Node
   [Documentation]
   ...     Get and return active and historical alarm lists via admin interface.
   ...     Argument ``node_type`` if it is done for either gnb or enb.
   ...
   ...     Hint: This may return large data especially with historical alarms and
   ...     increases the log file size accordingly!
   ...     Alternatively fetch only one of both alarm list using direct TAF keyword
   ...     and check this list with the python based filterering keywords in alarm_handling.py.
   ...
   ...     | node_id       | Id/Number of Node |
   ...     | node_type     | Node type; possible values: (gnb|enb) |
   ...     | time_sort     | Flag to force sorting by observation time, default is False |
   ...     | with_historic | boolean to include or exclude historical alarms |
   ...     | targetfile    | optional: save all alarms to given file in json format |
   ...     | log_level     | optional: wanted logging level, default NONE to reduce log size |
   ...
   ...     *Returns*   Single list containing all active and historical alarms.
   ...
   [Arguments]   ${node_id}=${0}  ${node_type}=gnb  ${time_sort}=${False}   ${targetfile}=${None}
   ...   ${with_historic}=${True}
   ...   ${log_level}=NONE
   ${old_log_level}  Set Log Level  ${log_level}

   ${oam_alias}   connect.Setup OAM HTTP Session  node_id=${node_id}  node_type=${node_type}

   ${active_alarms}     admin.Get Active Alarms   connection=${oam_alias}
   ${nbr_active}        Get Length  ${active_alarms}

   IF   ${with_historic}
      ${historic_alarms}   admin.Get Historic Alarms   timeout=60  load_history=true  connection=${oam_alias}
   ELSE
      ${historic_alarms}   Create List
   END

   ${nbr_historic}   Get Length  ${historic_alarms}
   ${all_alarms}     Collections.Combine Lists  ${active_alarms}  ${historic_alarms}
   ${nbr_all}        Get Length  ${all_alarms}

   IF   ${time_sort}
      ${all_alarms}   AlarmSorter.Sort Alarm List By Observation Time   ${all_alarms}
   END

   Log   ${\n}Retrieved ${nbr_all} alarm(s): ${nbr_active} active and ${nbr_historic} historical.   console=${P_console}

   IF   '${targetfile}'!='${None}'   json_helper_py.Dump Json To File   ${all_alarms}   ${targetfile}

   RETURN  ${all_alarms}
   [Teardown]  Set Log Level  ${old_log_level}


Log Alarm List
   [Documentation]
   ...     Logs with given `level` the content of a list of alarms.
   ...     You may find the alarm logs in 'Test Execution Errors' section of log.html dependent on the log level.
   ...
   ...     If level is ERROR it checks if alarm list is empty and fails otherwise the KW!
   ...     It can be used after 'Check For New Alarms' to evaluate one of the returned lists.
   ...
   ...     | alarm_list   | list of alarm dictionaries |
   ...     | level        | any of robot supported log levels |
   ...
   [Arguments]   ${alarm_list}  ${level}=WARN

   IF   $level not in ['ERROR', 'WARN', 'INFO', 'DEBUG', 'TRACE']
   ...    FAIL   Invalid log level '${level}', must be one of 'ERROR', 'WARN', 'INFO', 'DEBUG', 'TRACE'

   FOR   ${alarm}   IN   @{alarm_list}
      ${cleared_info}   Set Variable If   '${alarm.get('clearedTime')}'!='${None}'   "cleared:${alarm.get('clearedTime')}"   ${EMPTY}
      ${log_line}   Catenate
      ...   ALARM: ${alarm.get('btsObservationTime')} faultId:${alarm.get('faultId')} ${alarm.get('faultName')} ${cleared_info}
      Log   ${log_line}   ${level}   console=${P_console}
   END
   IF   '${level}'=='ERROR' and len(${alarm_list})!=${0}
   ...   FAIL   Unexpected new/cleared alarm(s) detected!

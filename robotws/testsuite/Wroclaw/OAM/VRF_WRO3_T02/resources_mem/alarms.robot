*** Settings ***
Library         ute_pdu
Library         taf.sbts.oam.coam.admin  WITH NAME  admin
Library         taf.ul.alarms_watchdog   WITH NAME  watchdog
Library         ../resources_mem/python_lib/utilities.py

Documentation
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  11.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-135 - add variable ${SKIP_FAULT} in KW "Check If Unexpected Alarms Are Raised"
...  08.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-265 - add possibility to defined more that one SKIP_FAULT variable and
...                                                                 print unexpected alarms in KW "Check If Unexpected Alarms Are Raised"
...  23.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-294 - add KWs: "Start Watchdog", "Allow Fault In Watchdog" and
...                                                                 "Stop Watchdog And Check Alarms"
...  03.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-313 - add iteration through all critical faults
...  08.01.2023 - add faults 24, 4268 and 6351 to allowed list for memory suite.
...  30.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-576 - Adapt KW "Start Watchdog" to work during Suite Setup/Teardown.
...  29.08.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-25235- Remove Critical FID procedure and create new solution
...  21.11.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-30810 - Add KWs: "Allow CBRS Faults For Site Reset"
...                                                                           and "Disallow CBRS Faults For Site Reset"
...  26.11.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-22855 - Modify KWs "Allow Fault In Watchdog" and "Disallow Fault In Watchdog"
...                                                                           to support unit_path parameter.
...  27.11.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-30663 - Update KW "Start Watchdog" to retry watching alarms in case of fail
...  xx.xx.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${SKIP_FAULT}=  ${EMPTY}
@{CRITICAL_FAULTS}=  16  243  1806  1868  3030  4341  4352  4383    10

*** Keywords ***
Check If Unexpected Alarms Are Raised
    [Documentation]  Check for unallowed alarms
    ...  **Author:** tomasz.marchewka@nokia.com
    ...  There is possibility to set input variable, example: -v SKIP_FAULT:1837,1784
    ...
    ...  **Example of simple usage:**
    ...  Check If Unexpected Alarms Are Raised  ${SKIP_FAULT}
    ...
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | alarmID | faultID | Description                                                        |
    ...  +=========+=========+====================================================================+
    ...  | 7115    | 4590    | Fault signature for crash or failure                               |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7115    | 4592    | BTS Reset Cause                                                    |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7115    | 4639    | Problem sending VES event to ONAP VES Endpoint                     |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7220    | 4654    | Ethernet port security is disabled                                 |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7220    | 4655    | Service account root access is enabled	                          |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  |         | 4681    | Sanity Check Error                                                 |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7220    | 61524   | SSH enabled                                                        |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7220    | 61649   | LMP access via port 443                                            |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7220    | 61652   | R&D Service Port enabled                                           |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7115    | 6351    | System information broadcast parameters overflow                   |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...
    [Arguments]  ${SKIP_FAULT}=${EMPTY}
    admin.clear allowed alarms list
    Log  Adding allowed alarms
    @{allowed_faults}=  Create List  4590  4592  4639  4654  4655  4681  61524  61649  61652  6351  6823
    ${skip_faults}=  Split String  ${SKIP_FAULT}  separator=,
    @{combined_faults}=  Run Keyword If  '${SKIP_FAULT}'!='${EMPTY}'  Combine Lists  ${allowed_faults}  ${skip_faults}
    ...  ELSE IF  '${SKIP_FAULT}'=='${EMPTY}'  Set Variable  ${allowed_faults}
    ${ignore_faults}=  Remove Duplicates  ${combined_faults}
    FOR  ${fault}  IN  @{ignore_faults}
        admin.add allowed alarm  faultId=${fault}
    END
    ${fault_mapping}=  Get Alarm Mapping
    ${unexpected_faults}=  Create List
    FOR  ${faultid}  IN  @{fault_mapping}
        ${fault}=  Convert To String  ${faultid}[faultId]
        ${verdict}  Run Keyword And Return Status  List Should Contain Value  ${ignore_faults}  ${fault}
        Run Keyword If  not ${verdict}  Append To List  ${unexpected_faults}  faultId:${faultid}[faultId] faultName:${faultid}[faultName]
        ${if_critical}=  Run Keyword And Return Status  List Should Contain Value  ${CRITICAL_FAULTS}  ${fault}
        Run Keyword If  ${if_critical}  Run  sudo touch /etc/ute/disable_ecolab
    END
    ${status}  ${output}=  Run Keyword And Ignore Error  admin.assert no unexpected active alarms
    Run Keyword If  '${status}'=='PASS'
    ...  Log  There is no visible unexpected alarms  console=${true}
    ...  ELSE
    ...  Fail  msg=Unexpected alarm(s) raised: ${unexpected_faults}
    admin.clear allowed alarms list

Get Active FaultIDs
    [Documentation]  Keyword returns list of active faultIds visible on BTS.
    ${alarm_parameters}=  admin.get active alarms
    ${present_faultIds}=  Create List
    FOR  ${item}  IN  @{alarm_parameters}
        Append To List  ${present_faultIds}  ${item['faultId']}
    END
    [Return]  ${present_faultIds}

Get Alarm Mapping
    [Documentation]  Keyword returns list of active faultId, faultName and severity of fault reported on BTS.
    ${alarm_parameters}=  admin.get active alarms
    ${fault_mapping}  Create List
    FOR  ${alarm}  IN  @{alarm_parameters}
        ${fault_info}=  Create Dictionary  faultId=${alarm}[faultId]  faultName=${alarm}[faultName]  severity=${alarm}[severity]
        Append To List  ${fault_mapping}  ${fault_info}
    END
    [Return]  ${fault_mapping}

Trigger GPS Fault 4011
    [Documentation]  This keyword trigger faultId 4011 - "GPS Receiver alarm: control interface not available".
    SSHLibrary.Open Connection  ${MSM_IP}
    SSHLibrary.Login  ${ENB_ROOT_USER}  ${ENB_ROOT_PASS}
    FOR  ${send}  IN RANGE  60
        SSHLibrary.Execute Command  echo 1 >/sys/class/gpio/gps_volt_on/value  return_stdout=False
        Sleep  5s
    END
    [Teardown]  SSHLibrary.Close Connection

Start Watchdog
    [Documentation]  This keyword starts watching active alarms on BTS for disallowed alarms.
    ...
    ...  There is possibility to set input variable, example: -v SKIP_FAULT:4681,4592
    ...
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | alarmID | faultID | Description                                                        |
    ...  +=========+=========+====================================================================+
    ...  | 7115    | 4590    | Fault signature for crash or failure                               |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7115    | 4592    | BTS Reset Cause                                                    |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7115    | 4639    | Problem sending VES event to ONAP VES Endpoint                     |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7220    | 4654    | Ethernet port security is disabled                                 |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7220    | 4655    | Service account root access is enabled	                          |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  |         | 4681    | Sanity Check Error                                                 |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7220    | 61524   | SSH enabled                                                        |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7220    | 61649   | LMP access via port 443                                            |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7220    | 61652   | R&D Service Port enabled                                           |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  |         | 24      | Obsolete SW version detected                                       |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  |         | 4268    | Unsigned software release has been successfully downloaded         |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...  | 7115    | 6351    | System information broadcast parameters overflow                   |
    ...  +---------+---------+--------------------------------------------------------------------+
    ...
    [Arguments]  ${SKIP_FAULT}=${EMPTY}
    Log To Console  Starting watchdog...
    ${update_node_command}  Set Variable  sudo apt update && sudo apt install ute-node
    ${interval}=  Set Variable  2 sec
    ${is_in_test}  Run Keyword And Return Status  Variable Should Exist  ${RESULTS}
    ${RESULTS}  Set Variable If  ${is_in_test}  ${RESULTS}  ${SUITE_RESULTS}
    ${log_dir}=  Set Variable  ${RESULTS}/watchdog_logs
    @{allowed_faults}=  Create List  4590  4592  4639  4654  4655  4681  61524  61649  61652  24  4268  6351  6823
    ${skip_faults}=  Split String  ${SKIP_FAULT}  separator=,
    @{combined_faults}=  Run Keyword If  '${SKIP_FAULT}'!='${EMPTY}'  Combine Lists  ${allowed_faults}  ${skip_faults}
    ...  ELSE IF  '${SKIP_FAULT}'=='${EMPTY}'  Set Variable  ${allowed_faults}
    ${ignore_faults}=  Remove Duplicates  ${combined_faults}
    FOR  ${fault}  IN  @{ignore_faults}
        watchdog.allow alarm  fault_id=${fault}
    END
    Check Admin Readiness
    ${watchdog_started}  ${watchdog_message}  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  3x  60s
    ...                                                                     watchdog.watch_alarms  interval=${interval}
    ...                                                                                            bts_config=${tl.enbs[0]}
    ...                                                                                            log_dir=${log_dir}
    ...                                                                                            timeout=60
    IF  'FAIL' in $watchdog_started and '_wait_for_ws_connection' in $watchdog_message  Run Keywords  Run  ${update_node_command}
    ...                                                                                          AND  Wait Until Keyword Succeeds  3x  60s
    ...                                                                                               watchdog.watch_alarms  interval=${interval}
    ...                                                                                                                      bts_config=${tl.enbs[0]}
    ...                                                                                                                      log_dir=${log_dir}
    ...                                                                                                                      timeout=60
    ...  ELSE IF  'FAIL' in $watchdog_started  Fail  msg=${watchdog_message}

Stop Watchdog And Check Alarms
    [Documentation]  This keyword checks whether watch history contains any detected disallowed alarm.
    Log To Console  Checking alarms and stopping watchdog...
    ${bts_faults}  Create List
    ${detected_faults}  Get All Detected Faults
    ${warn}  Run Keyword And Return Status  Should Be Empty  ${detected_faults}
    ${DetectedAlarm_Parsered}  Run Keyword If  not ${warn}  Detected Alarms Parser  ${detected_faults}
    Run Keyword If  not ${warn}  Run Keywords  Log  Unexpected fault(s) detected    WARN
    ...                                 AND    Log To Console  \n${DetectedAlarm_Parsered}
    FOR  ${fault}  IN  @{CRITICAL_FAULTS}
        ${CRITICAL_FAULT_DETECTED}=  watchdog.was alarm detected  fault_id=${fault}
        Run Keyword If  ${CRITICAL_FAULT_DETECTED}  Run Keywords
        ...  Append To List  ${bts_faults}  ${fault}
        ...  AND  Log  Critical fault id ${fault} detected  WARN
    END
    ${verdict}  Run Keyword And Return Status  Should Be Empty  ${bts_faults}
    ${critical_qty}  Get Length  ${bts_faults}
    Run Keyword If  not ${verdict}  Run Keywords
    ...  Set Global Variable  ${CRITICAL_FAULT_DETECTED}
    ...  AND  Run  sudo touch /etc/ute/disable_ecolab
    ...  AND  Log To Console  [ALERT] ${critical_qty} critical fault(s) detected - ecolab disabled!
    Run Keyword And Ignore Error  Set Test Variable  ${verdict}
    watchdog.check_detected_alarms
    [Teardown]  watchdog.stop_watching_alarms

Allow Fault In Watchdog
    [Documentation]  This keyword adds new alarm into list of alarms which will be skipped during active alarms check.
    [Arguments]  ${faultID}  ${unit_path}=None
    Run Keyword If  '${unit_path}'=='None'  Log To Console  Adding fault id ${faultID} into watchdog allowed fault list.
    ...                               ELSE  Log To Console  Adding fault id ${faultID} on ${unit_path} into watchdog allowed fault list.
    watchdog.allow alarm  fault_id=${faultID}  unit_path=${unit_path}

Disallow Fault In Watchdog
    [Documentation]  This keyword removes alarm from list of alarms which will be skipped during active alarms check.
    [Arguments]  ${faultID}  ${unit_path}=None
    Run Keyword If  '${unit_path}'=='None'  Log To Console  Removing fault id ${faultID} from watchdog allowed fault list.
    ...                               ELSE  Log To Console  Removing fault id ${faultID} on ${unit_path} from watchdog allowed fault list.
    watchdog.disallow alarm  fault_id=${faultID}  unit_path=${unit_path}

Check If Fault Is Active
    [Documentation]  Keyword checks whether fault is currently active on BTS.
    [Arguments]  ${faultID}
    ${if_active}=  watchdog.is alarm active  fault_id=${faultID}
    Run Keyword If  ${if_active}  Log To Console  Fault id ${faultID} is active

Wait For Active Fault
    [Documentation]  Keyword waits for fault to become active on BTS.
    ...  **Example of simple usage:**
    ...
    ...  Wait For Active Fault  faultID=49  unit_path=[Zarco] MRBTS-5003/GNBTS-1/GNBCF-1/GNCEL-3  timeout=1min
    ...
    [Arguments]  ${faultID}  ${unit_path}=None  ${timeout}=1min
    ${if_active}=  watchdog.wait for active alarm  fault_id=${faultID}  unit_path=${unit_path}  timeout=${timeout}
    Run Keyword If  ${if_active}  Log To Console  Fault id ${faultID} is active

Wait For Inactive Fault
    [Documentation]  Keyword waits for fault to become inactive on BTS.
    ...  **Example of simple usage:**
    ...
    ...  Wait For Inactive Fault  faultID=49  unit_path=[Zarco] MRBTS-5003/GNBTS-1/GNBCF-1/GNCEL-3  timeout=1min
    ...
    [Arguments]  ${faultID}  ${unit_path}=None  ${timeout}=1min
    ${if_inactive}=  watchdog.wait for inactive alarm  fault_id=${faultID}  unit_path=${unit_path}  timeout=${timeout}
    Run Keyword If  ${if_inactive}  Log To Console  Fault id ${faultID} is inactive

Get All Detected Faults
    [Documentation]  Keyword returns list of alarms which were detected during active alarms check.
    ${detected_faults}=  watchdog.get detected alarms
    [Return]  ${detected_faults}

Allow CBRS Faults For Site Reset
    Allow Fault In Watchdog  faultID=6825  #SAS Grant Suspension Failure
    Allow Fault In Watchdog  faultID=6823  #SAS Grant Termination Revocation Failure

Disallow CBRS Faults For Site Reset
    Disallow Fault In Watchdog  faultID=6825  #SAS Grant Suspension Failure
    Disallow Fault In Watchdog  faultID=6823  #SAS Grant Termination Revocation Failure

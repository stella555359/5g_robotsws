*** Settings ***
Documentation    Common Robot keywords for Cloud and RealHW

Library    BuiltIn
Library    DateTime
Library    ./truck_roll.py

Variables    ./variables.py

*** Keywords ***
Time To Sleep
    [Arguments]  ${interval}  ${additional_offset}=${0}
    [Documentation]  KW checks how much time has been left to collect PM Counters.
    ...  This was introduced to shorten the waiting time for collecting PM Counters.
    ...  It's possible due to the fact that the PM Counters are collected at predeterminated times.
    ...  For example: For 15 minutes measurement interval the reports are scheduled at 00:15h, 00:30h, 00:45h, 01:00h, etc.
    ...  For example: For 720 minutes measurement interval the reports are scheduled at 12:00h and 24:00h.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                                      |
    ...  +==================+======+==================================================================+
    ...  | interval         | Yes  | Measurement interval in minutes.                                 |
    ...  +------------------+------+------------------------------------------------------------------+
    ...  | additional_offset| No   | Additional offset in minutes to the calculated time to sleep.    |
    ...  +------------------+------+------------------------------------------------------------------+

    ${interval}  Convert To Integer  ${interval}
    @{allowed_intervals}=  Create List  5  15  30  60  360  720  1440
    IF  '${interval}' not in ${allowed_intervals}
        Fail  Interval ${interval} is not allowed. Allowed intervals: ${allowed_intervals}
    END
    ${minutes}=  Get Time  minutes
    ${hours}=  Get Time  hours

    ${minutes}=  Convert To Integer  ${minutes}
    ${hours}=  Convert To Integer  ${hours}
    ${hours_to_minutes}=  Evaluate  int(${hours} * 60 + ${minutes})

    # Calculate time to sleep based on the interval
    IF  ${interval} in [360, 720, 1440]
        ${time}  Evaluate  int(${interval} - (${hours_to_minutes} % ${interval}) + ${additional_offset} + 2)
    ELSE
        ${time}  Evaluate  int(${interval} - (${minutes} % ${interval}) + ${additional_offset} + 2)
    END

    # Check if we are 1 minute before the full interval
    IF  ${interval} in [360, 720, 1440]
       ${remainder}  Evaluate  (${hours_to_minutes} % ${interval})
    ELSE
        ${remainder}  Evaluate  (${minutes} % ${interval})
    END

    IF  ${remainder} == ${interval - 1}
        ${time}  Evaluate  ${time} + ${interval}
    END

    ${time}=  Evaluate  max(${time}, 1)

    ${date}=  Get Current Date
    ${time_to_verdict}=  Add Time To Date  ${date}  ${time} minutes  result_format=%H:%M  exclude_millis=True

    [Return]  ${time}  ${time_to_verdict}

Truck Roll Checking
    [Arguments]  ${host_ip_addr}  ${bts_id_list}  ${smod_list}  ${bbmod_list}  ${rmod_list}
    ...  ${truck_roll_alarms}=${TRUCK_ROLL_FID_LIST}  ${truck_roll_recipents}=${TRUCK_ROLL_RECIPIENTS_LIST}
    ...  ${truck_roll_maintainers}=${TRUCK_ROLL_CM_MAINTAINERS_LIST}  ${alias}=default  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword implements a notification mechanism so that STOP and FIX could be peformed
    ...  on the testlines that were paused during execution.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | host_ip_addr           | Yes  | IP address of the host to which the BTS is connected.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_id_list            | Yes  | BTS id list.                                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | smod_list              | Yes  | List of serial numbers of system modules connected to the BTS              |
    ...  |                        |      | with the given id.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bbmod_list             | Yes  | List of serial numbers of baseband modules connected to the BTS            |
    ...  |                        |      | with the given id.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_list              | Yes  | List of serial numbers of radio modules connected to the BTS               |
    ...  |                        |      | with the given id.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | truck_roll_alarms      |  No  | List of alarms.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | truck_roll_maintainers |  No  | List of CM Maintainers.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Name of execution alias.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  log_to_console        |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    # Truck Roll kill switch - FOR DEVELOPMENT ONLY!
    ${skip_tr_variable}=  Run Keyword And Return Status
    ...  Variable Should Exist  ${SKIP_TRUCK_ROLL}
#    ${is_cm_exec_based_on_file}=  Run Keyword And Return Status
#    ...  File Should Exist  path=/opt/ute/execution.context.json
#    Run Keyword And Return If  ${skip_tr_variable} and not ${is_cm_exec_based_on_file}
#    ...  Log  Skiping Truck Roll analysis due to flag set by the user  level=warn
    Run Keyword And Return If  ${skip_tr_variable}
    ...  Log  Skiping Truck Roll analysis due to flag set by the user  level=warn
    # Truck Roll checking for all nodes
    FOR  ${bts_id}  IN  @{bts_id_list}
      Log  ${info_prefix}Truck Roll analysis for BTS id=${bts_id} begins...  console=${log_to_console}
      # Truck Roll LMP connectivity check
      ${trigger_lmp_connectivity}  ${mplane_ip}=  Run Keyword And Continue On Failure
      ...  Analyze Truck Roll LMP Connectivity
      ...  lmp_addr=${host_ip_addr}
      ...  log_path=${SUITE_LOGS_DIR_PATH}
      Run Keyword If  ${trigger_lmp_connectivity}
      ...  Log  ${info_prefix}Truck Roll LMP connectivity check on BTS id=${bts_id} passed
      ...  console=${log_to_console}
      Run Keyword If  '${trigger_lmp_connectivity}'=='False'
      ...  Log  ${info_prefix}Truck Roll LMP connectivity check on BTS id=${bts_id} FAILED!
      ...  console=${log_to_console}
      # Truck Roll M-Plane connectivity check
      ${trigger_mplane_connectivity}=  Run Keyword If  ${trigger_lmp_connectivity}
      ...  Run Keyword And Continue On Failure
      ...  Analyze Truck Roll MPlane Connectivity
      ...  mplane_addr=${mplane_ip}
      ...  log_path=${SUITE_LOGS_DIR_PATH}
      Run Keyword If  ${trigger_lmp_connectivity}
      ...  Log  ${info_prefix}Truck Roll M-Plane connectivity check on BTS id=${bts_id} passed
      ...  console=${log_to_console}
      Run Keyword If  '${trigger_lmp_connectivity}'=='False'
      ...  Log  ${info_prefix}Truck Roll M-Plane connectivity check on BTS id=${bts_id} FAILED!
      ...  console=${log_to_console}
      # Truck Roll HW detection check
      ${trigger_hw_detection}=  Run Keyword And Continue On Failure
      ...  Analyze Truck Roll HW Detection
      ...  alias=${alias}
      ...  smod_list=${smod_list}
      ...  bbmod_list=${bbmod_list}
      ...  rmod_list=${rmod_list}
      Run Keyword If  ${trigger_hw_detection}
      ...  Log  ${info_prefix}Truck Roll HW detection check on BTS id=${bts_id} passed
      ...  console=${log_to_console}
      Run Keyword If  '${trigger_hw_detection}'=='False'
      ...  Log  ${info_prefix}Truck Roll HW detection check on BTS id=${bts_id} FAILED!
      ...  console=${log_to_console}
      # Truck Roll alarms check
      ${trigger_alarms}=  Run Keyword And Continue On Failure
      ...  Analyze Truck Roll Alarms
      ...  alias=${alias}
      ...  truck_roll_alarms=${truck_roll_alarms}
      Run Keyword If  ${trigger_alarms}
      ...  Log  ${info_prefix}Truck Roll alarms check on BTS id=${bts_id} passed
      ...  console=${log_to_console}
      Run Keyword If  '${trigger_alarms}'=='False'
      ...  Log  ${info_prefix}Truck Roll alarms check on BTS id=${bts_id} FAILED!
      ...  console=${log_to_console}
      # Truck Roll result overall - True if Truck Roll failed, False otherwise
      ${alarms}=  Set Variable  not ${trigger_alarms}
      ${hw}=  Set Variable  not ${trigger_hw_detection}
      ${lmp}=  Set Variable  not ${trigger_lmp_connectivity}
      ${mplane}=  Set Variable  not ${trigger_mplane_connectivity}
      ${truck_roll_result}=  Set Variable
        ...  ${alarms} or ${hw} or ${lmp} or ${mplane}
      # Reason building for Stop&Fix email notification
      ${truck_roll_email_reason}=  Evaluate  dict(alarms=${alarms}, hw=${hw}, lmp=${lmp}, mplane=${mplane})
      # Executing Stop&Fix action if Truck Roll any check failed
      Run Keyword If  ${truck_roll_result}  Exec Stop And Fix Action
      ...  recipients_list=${truck_roll_recipents}  reply_list=${truck_roll_maintainers}  reason_dict=${truck_roll_email_reason}
      Run Keyword If  '${truck_roll_result}'=='False'
      ...  Log  ${info_prefix}All steps of Truck Roll analysis for BTS id=${bts_id} passed
      ...  console=${log_to_console}
    END

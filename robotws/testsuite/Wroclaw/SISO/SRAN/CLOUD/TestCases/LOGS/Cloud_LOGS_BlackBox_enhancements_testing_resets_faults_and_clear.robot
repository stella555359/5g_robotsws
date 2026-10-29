*** Settings ***
Documentation   TBD.
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    Szymon Przybylak

Library     DateTime
Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    Cloud_LOGS_BlackBox_resource.resource

*** Variables ***
&{timeBetweenSaveOnNVM}    timeBetweenSaveOnNVM=30

@{VDU_BLACK_BOX_ALLOWED_HIST_ALARMS}=  faultId=1937, severity=critical
@{VCU_BLACK_BOX_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_LOGS_BlackBox_enhancements_testing_resets_faults_and_clear
    [Arguments]  ${scfc_file_path}  ${rmod_ids}=@{EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword black box .
    ...
    ...  Step 1: Collect blackbox files from RU and snapshot to VM and check if there are the same.
    ...  Step 2: Reset RU and check if blackbox file has increased value for reset counter part.
    ...  Step 3: Check record number of occurences for different triggers
    ...  Step 4: Generate and recover faults and check if blackbox has updated records for them.
    ...  Step 5: Clear blackbox file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${start_prefix_green}Test Case: Black Box Combo  console=${log_to_console}
    ${logs_dir_path}=  Set Variable  ${SUITE_LOGS_DIR_PATH}/${TEST_NAME}
    Set Test Variable  ${LOGS_DIR_PATH}  ${logs_dir_path}
    Bbox Precondition For Resets Faults and Clear  rmod_ids=${rmod_ids}  scfc_file_path=${scfc_file_path}  logs_dir_path=${logs_dir_path}
    ${step_1st_folder}  step1: Collect BBox Both From Webem and RU
    step2: Check Reset Counters  dst_folder=${step_1st_folder}
    Step3: Check Record Number Of Occurences For Every Trigger  previous_step_folder=${step_1st_folder}
    step4: Generate Fault And Check BBox
    step5: Check Clear Black Box Data
    radio.Close SSH Connection
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout

Bbox Precondition For Resets Faults and Clear
    [Arguments]  ${rmod_ids}  ${scfc_file_path}  ${logs_dir_path}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Precondition keyword prepares variables for Automated_AIC_RU_BlackBox_enhancements_testing
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_ids               | Yes  | List of serial number of tested RU                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    Log  ${dots_prefix_green}Black Box Precondition Start  console=
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_BLACK_BOX_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_BLACK_BOX_ALLOWED_HIST_ALARMS}
    Black Box Common Preconditions  rmod_ids=${rmod_ids}  scfc_file_path=${scfc_file_path}  logs_dir_path=${logs_dir_path}
#    ${running_build}    vDU Get Running Software Version    vdu_login=False
#    Set Test Variable    ${RUNNING_BUILD}    ${running_build}
#    ${release}=  Fetch From Left  string=${RUNNING_BUILD}
#    ...  marker=_
#    ${release}=  Set Variable If  '${release}' == '${trunk_value}'  vDUCNF00  ${release}
#    Set Test Variable  ${RELEASE}  ${release}
#    ${trunk_build}  Run Keyword If  '${trunk_value}' in '${running_build}'  Replace String Using Regexp	 ${running_build}  ${trunk_value}
#    ...    vDUCNF00
#    Run Keyword If  '${trunk_value}' in '${running_build}'  Set Test Variable  ${PREVIOUS_BUILD}  ${trunk_build}
#    Set Test Variable  ${PREVIOUS_BUILD}  ${running_build}
#    Log  ${PREVIOUS_BUILD}
    Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${ru_sn}
    ...  cloud_server_ip=${cloud_server_ip}
    ${binary_file_dict}  radio.Get Decoded Binary File
    ...  ru_serial_number=${ru_sn}
    ...  filename=black_box_logger
    ...  cloud_server_ip=${cloud_server_ip}
    Set Test Variable    ${BINARY}    ${binary_file_dict}
    ${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT}  Create Dictionary
    Run Keyword If  '${BINARY['timeBetweenSaveOnNVM']}'=='30'  Fail
    ...  msg=Value of timeBetweenSaveOnNVM is not the default value! Override it manualy to 86400 and retest.
    Set Test Variable  ${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT}
    Set To Dictionary  ${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT}  timeBetweenSaveOnNVM  ${BINARY['timeBetweenSaveOnNVM']}
    FOR  ${ru_sn}  IN  @{rf_list}
        RMOD Unit Reset  rmod_sn=${ru_sn}
    END
    Wait Until All Cells Are OnAir  cells_count=${cells_count}  timeout=600
    Log  ${ok_prefix_green}Black Box Precondition Finished  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout

step1: Collect BBox Both From Webem and RU
    [Arguments]  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Step 1 in Automated_AIC_RU_BlackBox_enhancements_testing test that downloads black box files to VM from snapshot and RU
    ...  and checks if there are identical.
    ...  Files are later used in next steps that do not require more actions before checking files.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${dots_prefix_green}step 1: Collect BBox From Webem and RU started  console=${log_to_console}
    ${destination_folder_path}  Collect Both BBox Files For Radio  destination_folder_path=${logs_dir_path}/${ru_sn}/step_1
    Log  ${ok_prefix_green}step 1: Collect BBox From Webem and RU started finised  console=${log_to_console}
    [Return]  ${destination_folder_path}

step2: Check Reset Counters
    [Arguments]  ${dst_folder}  ${log_to_console}=True
    [Documentation]  CB010655_I_1_enhancement_of_reset_counter
    ...  Description:
    ...  CB010655_A_1_parity_legacy_black_box_5_function_of_CB006622_CB007833
    ...  KW Takes number of resets from already provided bbox file and compares it to values from BBOX file after RU reset.
    ...  Check is done if the reset counter value is bigger (+1), if the records moved correctly and if
    ...  the time of newly done site reset is noted properly.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dst_folder             |  Yes |  Path to the blackbox file.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${dots_prefix_green}step 2: Check Reset Counters  console=${log_to_console}
    vDU Rest Login
    FOR   ${ru_sn}  IN  @{rf_list}
        ${reset_counter_ru}  Get Part Of Bbox List
        ...  file_path=${dst_folder}/BBOX5_snap
        ...  start_string=Item type: resets
        ...  end_string=---
        ${reset_counter_value_before_reset}  ${write_value_before_reset}  Get Reset Counter Value And Write Value From Bbox
        ...  reset_counter_values_list=${reset_counter_ru}
        ...  index=0
        ${reset_start_date}  Get Current Date  UTC
        Log  ${info_prefix}Performing Reset of RMOD ${ru_sn}  console=${log_to_console}
        RMOD Unit Reset  rmod_sn=${ru_sn}
        ${reset_end_date}  Get Current Date  UTC
        Wait Until All Cells Are OnAir  cells_count=${cells_count}
        ${reset_counter_folder}  Collect Both BBox Files For Radio  destination_folder_path=${logs_dir_path}/${ru_sn}/step_2_reset_counters
        ${after_reset_counter_ru_list}  Get Part Of Bbox List
        ...  file_path=${reset_counter_folder}/BBOX5_snap
        ...  start_string=Item type: resets
        ...  end_string=---
    END

    ${reset_counter_value_after_reset}  ${write_value_after_reset}  Get Reset Counter Value And Write Value From Bbox
    ...  reset_counter_values_list=${after_reset_counter_ru_list}
    ...  index=1
    ${alarm_check}  Evaluate  '${write_value_after_reset}'=='${write_value_before_reset}'
    ${result}    Evaluate    ${reset_counter_value_before_reset}+1 == ${reset_counter_value_after_reset}
    Should Be True  '${alarm_check}'=='True' and '${result}'=='True'
    ${bbox_reset_time_raw}  Set Variable  ${after_reset_counter_ru_list[2]}
    ${bbox_reset_time_fetched}  Fetch From Right  ${bbox_reset_time_raw}  Write:
    ${bbox_reset_time}  Evaluate  '${bbox_reset_time_fetched}'.replace(' ','')
    ${bbox_reset_time}  Evaluate  '${bbox_reset_time}'.replace('T',' ')
    ${time_start_end_diff}  DateTime.Subtract Date From Date  ${reset_end_date}  ${reset_start_date}
    ${diff}  DateTime.Subtract Date From Date  ${bbox_reset_time}  ${reset_start_date}
    Should Be True  ${diff}<${time_start_end_diff}
    Check Reset Tree  reset_part_list=${after_reset_counter_ru_list}
    Log  ${ok_prefix_green}Step 2: Check Reset Counters  console=${log_to_console}

step3: Check Record Number Of Occurences For Every Trigger
    [Arguments]    ${previous_step_folder}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  CB010655_D_1_support_to_record_number_of_occurrences_for_every_trigger
    ...  Checks if records update correctly. First it ovverrides value of timeBetweenSaveOnNVM in black_box_logger on RU and performs 2 resets.
    ...  After that checks if black box is updated in records for Periodical trigger occur times and Reset trigger occur times.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | previous_step_folder   |  Yes |  Path to the blackbox file from previous steps                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${dots_prefix_green}Step 3: Check Record Number Of Occurences For Every Trigger  console=${log_to_console}
    ${should_execute_recovery}    Set Variable    True
    ${nvm_flushcounter_only_keys}  ${nvm_flushcounter_dict}  Prepare Keys For Black Box Functions Check
    ...  dst_folder=${previous_step_folder}
    ...  start_string=Item type: NvmFlushCounter
    FOR  ${item}  IN  @{flush_counter_template}
        Should Contain  ${nvm_flushcounter_only_keys}  ${item}
    END
    Log  ${info_prefix}Getting and Overriding timeBetweenSaveOnNVM to ${timeBetweenSaveOnNVM['timeBetweenSaveOnNVM']}  console=${log_to_console}
    FOR  ${ru_sn}  IN  @{rf_list}
        RMOD Wait For Online  rmod_sn=${ru_sn}
        Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module
        ...  ru_serial_number=${ru_sn}
        ...  cloud_server_ip=${cloud_server_ip}
        radio.Override Values In Binary File
        ...  ru_serial_number=${ru_sn}
        ...  filename=black_box_logger
        ...  values_dict=${timeBetweenSaveOnNVM}
        ...  reset_ru=False
        ...  cloud_server_ip=${cloud_server_ip}
        radio.close ssh connection
        Log  ${info_prefix}Performing first RMOD ${ru_sn} reset  console=${log_to_console}
        RMOD Unit Reset  rmod_sn=${ru_sn}
        #86400
        Wait Until All Cells Are OnAir  cells_count=${cells_count}
        radio.Close SSH Connection
        Log  ${info_prefix}Performing second RMOD ${ru_sn} reset  console=${log_to_console}
        RMOD Unit Reset  rmod_sn=${ru_sn}
        Wait Until All Cells Are OnAir  cells_count=${cells_count}
    END
    ${step3_folder_name}  Collect Both BBox Files For Radio  destination_folder_path=${logs_dir_path}/${ru_sn}/step_3_after_resets
    ${nvm_flushcounter_after_reset_only_keys}  ${nvm_flushcounter_after_reset_dict}  Prepare Keys For Black Box Functions Check
    ...  dst_folder=${step3_folder_name}
    ...  start_string=Item type: NvmFlushCounter
    FOR  ${item}  IN  @{flush_counter_template}
        Should Contain  ${nvm_flushcounter_after_reset_only_keys}  ${item}
    END
    ${periodical_increment}  Evaluate
    ...  int(${nvm_flushcounter_dict['Periodical trigger occur times']})<int(${nvm_flushcounter_after_reset_dict['Periodical trigger occur times']})
    ${reset_increment}  Evaluate
    ...  int(${nvm_flushcounter_dict['Reset trigger occur times']})+3 == int(${nvm_flushcounter_after_reset_dict['Reset trigger occur times']})
    Should Be True  '${periodical_increment}' == 'True' and '${reset_increment}' == 'True'
    Log  ${info_prefix}Values for trigger occcurs are correct  console=${log_to_console}
    Log  ${info_prefix}Restoring defaut value ${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT['timeBetweenSaveOnNVM']} to timeBetweenSaveOnNVM
    ...  console=${log_to_console}
    FOR  ${ru_sn}  IN  @{rf_list}
        RMOD Wait For Online  rmod_sn=${ru_sn}
    END
    radio.Override Values In Binary File
    ...  ru_serial_number=${ru_sn}
    ...  filename=black_box_logger
    ...  values_dict=${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT}
    ...  reset_ru=False
    ...  cloud_server_ip=${cloud_server_ip}
    radio.close ssh connection
    RMOD Unit Reset  rmod_sn=${ru_sn}
    radio.Close SSH Connection
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    ${should_execute_recovery}    Set Variable    False
    Log  ${ok_prefix_green}Step 3: Check Record Number Of Occurences For Every Trigger finished  console=${log_to_console}
    [Teardown]  Run Keyword If  ${should_execute_recovery}  Restore Binary File

step4: Generate Fault And Check BBox
    [Arguments]  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword that generates and recovers faults 1937. After that checks if correct values are seen in blackbox file
    ...  (severity, time of appearance, time of clearance).
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${dots_prefix_green}Step 4: Generate Faults started  console=${log_to_console}
    vDU Rest Login
    ${should_execute_FID1937_recovery}    Set Variable    True
    FOR  ${ru_sn}  IN  @{rf_list}
        Wait Until Keyword Succeeds  10min  10sec  radio.Generate Fault
        ...  fault_id=1937
        ...  ru_serial_number=${ru_sn}
        ...  cloud_server_ip=${cloud_server_ip}
        Log  ${info_prefix}Generate FID:1937 on ${ru_sn}  console=${log_to_console}
        Log  ${info_prefix}Waiting for FID:1937 to appear on ${ru_sn}  console=${log_to_console}
        ${FID_1937_present}=  Run Keyword And Return Status  vDU Assert Alarm Active  fault_id=1937  vdu_login=False  timeout=240 sec
        Should Be True  ${FID_1937_present}
        ${vcu_alarms}  ${vdu_1937_alarms}=  Get All Active Alarms  vdu_login=False
        Setting FID1937 Start Time  ${vdu_1937_alarms}
        ${alarm_date}  Get Current Date  UTC
        Log  ${vdu_1937_alarms}
        Log  ${info_prefix}Alarm FID:1937 on ${ru_sn} appeared console=${log_to_console}
        Log  ${info_prefix}Recover FID:1937 on ${ru_sn}  console=${log_to_console}
        Wait Until Keyword Succeeds  10min  10sec  radio.Recover Fault
        ...  ru_serial_number=${ru_sn}
        ...  fault_id=1937
        ...  cloud_server_ip=${cloud_server_ip}
        ${FID_1937_not_present}  Run Keyword And Return Status  vDU Assert Alarm Inactive  fault_id=1937  vdu_login=False  timeout=400 sec
        ${should_execute_FID1937_recovery}    Set Variable    False
        Should Be True  ${FID_1937_not_present}
        Wait Until All Cells Are OnAir  cells_count=${cells_count}
        Log  ${info_prefix}Reseting RMOD ${ru_sn}  console=${log_to_console}
        RMOD Unit Reset  rmod_sn=${ru_sn}
        Wait Until All Cells Are OnAir  cells_count=${cells_count}
        ${generate_fault_folder}  Collect Both BBox Files For Radio  destination_folder_path=${logs_dir_path}/${ru_sn}/step_4_generate_faults
        ${bbox_btsalarm_history}  Get Part Of Bbox List
        ...  file_path=${generate_fault_folder}/BBOX5_snap
        ...  start_string=Item type: BtsAlarmHistory
        ...  end_string=---
        Log  ${bbox_btsalarm_history}
        ${PATTERN}  Set Variable  \\.\\d+(?=\\+)
        Check Alarms  ${bbox_btsalarm_history}
        Exit For Loop
    END
    Log  ${ok_prefix_green}Step 4: Generate Faults finished  console=${log_to_console}
    [Teardown]  Run Keyword If    ${should_execute_FID1937_recovery}  Run Keywords
        ...  radio.Recover Fault
        ...  ru_serial_number=${ru_sn}
        ...  fault_id=1937
        ...  cloud_server_ip=${cloud_server_ip}
        ...  AND  Run Keyword And Return Status  vDU Assert Alarm Inactive  fault_id=1937  vdu_login=True  timeout=400 sec

step5: Check Clear Black Box Data
    [Arguments]  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  CB010655_J_1_support_interface_clear_black_box_data
    ...  Perform frmonShellCLient commands to delete Black box file. After reset RMOD, new file should be created.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         |  No  | Show orl not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${dots_prefix_green}step 5: Clear Black Box Data  console=${log_to_console}
    vDU Rest Login
    FOR  ${ru_sn}  IN  @{rf_list}
        Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module
        ...  ru_serial_number=${ru_sn}
        ...  cloud_server_ip=${cloud_server_ip}
        Log  ${info_prefix}Deleting Black Box file from RMOD  console=${log_to_console}
        radio.Send Command  frmonShellClient localhost 2000  delay=1
        radio.Send Command  / action create BlackBox /bb /module  delay=1
        radio.Send Command  /bb action stop_and_clear  delay=1
        radio.Close SSH Connection
        Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${ru_sn}
        ...  cloud_server_ip=${cloud_server_ip}
        radio.Send Command  [ -f /mnt/runtime/BBOX5 ]; echo $?  delay=1
        ${bbox_not_present}  radio.Read Output  delay=1
        Should Contain  ${bbox_not_present}  1
        Log  ${info_prefix}BBox File deleted  console=${log_to_console}
        Log  ${info_prefix}Performing RMOD ${ru_sn} reset  console=${log_to_console}
        radio.Close SSH Connection
        RMOD Unit Reset  rmod_sn=${ru_sn}
        Wait Until All Cells Are OnAir  cells_count=${cells_count}
        Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${ru_sn}
        ...  cloud_server_ip=${cloud_server_ip}
        radio.Send Command  [ -f /mnt/runtime/BBOX5 ]; echo $?  delay=1
        ${bbox_present}  radio.Read Output  delay=1
        Should Contain  ${bbox_present}  0
        Log To Console  BBox File was created after radio reset
        radio.Close SSH Connection
        ${step5_clear_bb_folder}  Collect Both BBox Files For Radio  destination_folder_path=${logs_dir_path}/${ru_sn}/step_5_clear_black_box
        Run Keyword And Continue On Failure  Check Histograms For Single File  dst_folder=${step5_clear_bb_folder}  file_name=BBOX5  number=2
        ${bts_alarm_history}  Get Part Of Bbox List
        ...  file_path=${step5_clear_bb_folder}/BBOX5
        ...  start_string=Item type: BtsAlarmHistory
        ...  end_string=---
        Length Should Be  ${bts_alarm_history}  2  msg=Check Bbox file if alarm history was cleared
        Exit For Loop
    END

Setting FID1937 Start Time
    [Arguments]  ${alarm_list}
    [Documentation]
    ...  Description:
    ...  Keyword to set globa lvariables for appearence time for FID 1937 and 1938
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | alarm_list             |  Yes | Alarm list provided from KW Get All Active Alarms                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    FOR  ${alarm}  IN  @{alarm_list}
        Log    ${alarm}
        Run Keyword If  ${alarm}[faultId]==1937  Set Test Variable  ${1937s_t}  ${alarm}[appearTime]
    END

Check Alarms
    [Arguments]  ${bbox_bts_history}
    [Documentation]
    ...  Description:
    ...  Keyword to check if blackbox part with Item type: BtsAlarmHistory has correct values for
    ...  alarm start, alarm clearence and severity. Works with FID 1937 and 1938
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bbox_bts_history       |  Yes | Part of bbox list taken from KW Get Part Of Bbox List                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${alarm_history}  Vdu Get Historical Alarms
    FOR  ${alarm}  IN  @{alarm_history['alarms']}
        Log  ${alarm}
        Run Keyword If  '${alarm['fault_id']}'=='1937' and '${alarm['appear_time']}'=='${1937s_t}'  Run Keywords
        ...  Set Test Variable  ${1937c_t}  ${alarm['cleared_time']}
        ...  AND  Set Test Variable  ${1937_s}  ${alarm['severity']}
    END
    ${1937s_cmd}=  Catenate  SEPARATOR=  __import__("datetime").datetime.strptime("${1937s_t}".split(".")[0],
    ...  "%Y-%m-%dT%H:%M:%S").replace(tzinfo=__import__("datetime").timezone.utc).timestamp()
    ${1937s_t}=  Evaluate  ${1937s_cmd}
    ${1937c_cmd}  Catenate  SEPARATOR=  __import__("datetime").datetime.strptime("${1937c_t}".split(".")[0],
    ...  "%Y-%m-%dT%H:%M:%S").replace(tzinfo=__import__("datetime").timezone.utc).timestamp()
    ${1937c_t}=  Evaluate  ${1937c_cmd}
    ${1937s_f}  Set Variable  False
    ${1937c_f}  Set Variable  False

    Remove From List  ${bbox_bts_history}  0
    FOR  ${line}  IN  @{bbox_bts_history}
        ${spl}  Split String  ${line}  ,
        IF  '1937' not in ${spl}
            Continue For Loop
        END
        Remove From List  ${spl}  -1

        ${date_string}  Set Variable  ${spl[4]}
        ${pds}  Evaluate  "${date_string}"[1:-1] if "${date_string}".startswith("<") and "${date_string}".endswith(">") else "${date_string}"
        Log To Console    Processed string: ${pds}
        ${eva_object_2}  Set Variable  __import__("datetime").datetime.strptime("${pds}
        ${eva_object_3}  Set Variable  ", "%Y-%m-%dT%H:%M:%S.%fZ" if "." in "${pds}" else "
        ${eva_object_4}  Set Variable  %Y-%m-%dT%H:%M:%SZ").replace(tzinfo=__import__("datetime").timezone.utc).timestamp()
        ${t_conv}    Evaluate    ${eva_object2}${eva_object3}${eva_object4}


        Run Keyword If  '1937' in ${spl} and '1' in ${spl} and '${1937_s.lower()}' in ${spl} and not ${1937s_f} and abs(${1937s_t}-${t_conv})<40
        ...  Run Keywords  Set Test Variable  ${1937s_f}  True
        ...  AND  Continue For Loop
        Run Keyword If  '1937' in ${spl} and '0' in ${spl} and '${1937_s.lower()}' in ${spl} and not ${1937c_f} and abs(${1937c_t}-${t_conv})<40
        ...  Run Keywords  Set Test Variable  ${1937c_f}  True
        ...  AND  Continue For Loop
    END
    Should Be True  ${1937s_f}
    Should Be True  ${1937c_f}

Restore Binary File
    [Arguments]  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  KW that restores default binary value of 'timeBetweenSaveOnNVM' in black_box_logger file on tested RU.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${dots_prefix_green}Teardown Step 7 - Restoring default value to timeBetweenSaveOnNVM  console=${log_to_console}
    RMOD Wait For Online  rmod_sn=${ru_sn}
    Wait Until Keyword Succeeds   60  5  radio.Open Connection To Radio Module  ru_serial_number=${ru_sn}
    ...  cloud_server_ip=${cloud_server_ip}
    ${binary_file_dict}  radio.Get Decoded Binary File
    ...    ru_serial_number=${ru_sn}
    ...    filename=black_box_logger
    ...  cloud_server_ip=${cloud_server_ip}
    Set Test Variable    ${BINARY}    ${binary_file_dict}
    Run Keyword If  '${BINARY['timeBetweenSaveOnNVM']}'!='${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT['timeBetweenSaveOnNVM']}'
    ...  Run Keywords
    ...  Log  ${info_prefix}Val. ${BINARY['timeBetweenSaveOnNVM']} will be replaced with ${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT['timeBetweenSaveOnNVM']}
    ...  console=True
    ...  AND  Wait Until Keyword Succeeds   120  5  radio.Override Values In Binary File
    ...  ru_serial_number=${ru_sn}
    ...  filename=black_box_logger
    ...  values_dict=${TIME_BETWEEN_SAVE_ON_NVM_DEFAULT}
    ...  reset_ru=False
    ...  cloud_server_ip=${cloud_server_ip}
    ...  AND  radio.close ssh connection
    ...  AND  RMOD Unit Reset  rmod_sn=${ru_sn}
    ...  AND  Wait Until All Cells Are OnAir  cells_count=${cells_count}
    ...  ELSE  Log  ${info_prefix}Value ${BINARY['timeBetweenSaveOnNVM']} is the same as default value  console=${log_to_console}
    radio.Close SSH Connection
    Log  ${ok_prefix_green}Teardown Step 7 - Restoring default value to timeBetweenSaveOnNVM  console=${log_to_console}

Check Reset Tree
    [Arguments]  ${reset_part_list}
    [Documentation]
    ...  Description:
    ...  Keyword for check if structure for Reset Counter part in bbox is correct. Checks if each reset contains
    ...  Reset[x] Write:, Reset[x] ISTI:, Reset[x] Reset Reason:,  [x] Reset Cause: and Reset[x] Failed Service:
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | reset_part_list        |  Yes | List with values from reset counter part from black box                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+

    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Remove From List  ${reset_part_list}  0
    Remove From List  ${reset_part_list}  0
    Log  ${reset_part_list}
    ${elements_in_list}  Get Length  ${reset_part_list}
    FOR  ${index}  IN RANGE  ${elements_in_list}
        ${i}  Evaluate  int(${index}/5)
        Run Keyword If  ${index}%5==0  Run Keywords
        ...  Should Contain  ${reset_part_list[${index}]}  Reset[${i}] Write:
        ...  AND  Continue For Loop
        Run Keyword If  ${index}%5==1  Run Keywords
        ...  Should Contain  ${reset_part_list[${index}]}  Reset[${i}] ISTI:
        ...  AND  Continue For Loop
        Run Keyword If  ${index}%5==2  Run Keywords
        ...  Should Contain  ${reset_part_list[${index}]}  Reset[${i}] Reset Reason:
        ...  AND  Continue For Loop
        Run Keyword If  ${index}%5==3  Run Keywords
        ...    Should Contain  ${reset_part_list[${index}]}  Reset[${i}] Reset Cause:
        ...  AND  Continue For Loop
        Run Keyword If  ${index}%5==4  Run Keywords
        ...  Should Contain  ${reset_part_list[${index}]}  Reset[${i}] Failed Service:
        ...  AND  Continue For Loop
    END

Get Reset Counter Value And Write Value From Bbox
    [Arguments]  ${reset_counter_values_list}  ${index}
    [Documentation]
    ...  Description:
    ...  KW takes values for Reset Counter (number) and for the time of the reset from ${index} position in BBOX file
    ...  Arguments:
    ...  +===========================+======+=========================================================================+
    ...  | Argument                  | Man. | Description                                                             |
    ...  +===========================+======+=========================================================================+
    ...  | reset_counter_values_list |  Yes | Part of black box file                                                  |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...  | index                     |  No  | index for position in black box file                                    |
    ...  +---------------------------+------+-------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    FOR  ${value}  IN  @{reset_counter_values_list}
        ${contains}=  Evaluate  "Reset Counter:" in "${value}"
        Continue For Loop If  '${contains}'=='False'
        ${reset_counter_value}  Fetch From Right  ${value}  ${SPACE}
        ${reset_counter_value}  Evaluate  int(${reset_counter_value})
        Exit For Loop
    END
    FOR  ${value}  IN  @{reset_counter_values_list}
        ${contains}=  Evaluate  "Reset[${index}] Write" in "${value}"
        Continue For Loop If  '${contains}'=='False'
        ${write_value}  Fetch From Right  ${value}  Write:
        ${write_value}  Evaluate    '${write_value}'.replace(' ','')
        Exit For Loop
    END
    [Return]  ${reset_counter_value}  ${write_value}

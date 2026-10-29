*** Settings ***
Documentation   TBD.
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    Szymon Przybylak

Library     DateTime
Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library     taf.transport.ssh  WITH NAME  tafssh
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.hw.fhgw.cli    WITH NAME    issh
Resource  Cloud_LOGS_BlackBox_resource.resource

*** Variables ***
${temp_folder_name}  temp
@{post_results_template}  Item type: POST_results  Item id  Last write  POST[0] result  POST[0] type  POST[0] timestamp
...  POST[1] result  POST[1] type  POST[1] timestamp
...  POST[2] result  POST[2] type  POST[2] timestamp
@{VDU_BLACK_BOX_POST_ALLOWED_HIST_ALARMS}=  faultId=4592, severity=warning
...                                         faultId=4592, severity=minor
@{VCU_BLACK_BOX_POST_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_LOGS_BlackBox_enhancements_testing_for_POST_data
    [Arguments]  ${scfc_file_path}  ${rmod_ids}=@{EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Black Box test that checks if POST results are correct in black box file after POST process.
    ...  gates https://gates.nsn-net.net/view/000272df#o=308
    ...  Step 1: Preconditions
    ...  Step 2: Collect blackbox files from RU and snapshot to VM.
    ...  Step 3: Reset tested RU to trigger POST, collect blackbox files and check POST data after RU reset.
    ...  Step 4: Reset vDU to trigger POST, collect blackbox files and check POST data after vDU reset.
    ...
    ...  Download bbox files from RMOD, located in /mnt/runtime/BBOX5
    ...  In snapshot, file is located inside BTS_partX.zip - BTS_xxxxxxx_RMOD_L_x_BBOX5_all.zip
    ...
    ...  For Structure of POST_results check variable @{post_results_template} - list of possible rows in this part of
    ...  blackbox.
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
    Set Test Variable  ${logs_dir_path}  ${SUITE_LOGS_DIR_PATH}/${TEST_NAME}
    step1: POST Preconditions
    ...  scfc_file_path=${scfc_file_path}
    ...  logs_dir_path=${logs_dir_path}
    ...  rmod_ids=${rmod_ids}
    ...  log_to_console=${log_to_console}
    ${step2_folder_path}  step2: Collect BBox
    ${step3_folder_path}  step3: Reset Radio And Check Post Results  step2_folder_path=${step2_folder_path}
    step4: Reset Vdu And Check Post Results  step3_folder_path=${step3_folder_path}

step1: POST Preconditions
    [Arguments]   ${scfc_file_path}  ${logs_dir_path}  ${rmod_ids}=@{EMPTY}  ${log_to_console}=True
    Log  ${start_prefix_green}Test Case: Black Box for POST data  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_BLACK_BOX_POST_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_BLACK_BOX_POST_ALLOWED_HIST_ALARMS}
    Black Box Common Preconditions  rmod_ids=${rmod_ids}  scfc_file_path=${scfc_file_path}  logs_dir_path=${logs_dir_path}
    FOR  ${ru_sn}  IN  @{rf_list}
        RMOD Unit Reset  rmod_sn=${ru_sn}
    END
    Wait Until All Cells Are OnAir  cells_count=${cells_count}  timeout=600
    Log  ${ok_prefix_green}POST Preconditions Finished  console=${log_to_console}

step2: Collect BBox
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

    Log  ${dots_prefix_green}step 2: Collect BBox  console=${log_to_console}
    ${step2_folder_path}  Collect Both BBox Files For Radio  destination_folder_path=${logs_dir_path}/${ru_sn}/step2_collect_bbox
    Log  ${ok_prefix_green}step 2: Collect BBox  console=${log_to_console}
    [Return]  ${step2_folder_path}

step3: Reset Radio And Check Post Results
    [Arguments]  ${step2_folder_path}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Step2 of testcase. Resets RU and checks: structure of POST_results and if records are moved correctly inside
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | step2_folder_path      |  Yes | Folder Path to the location of black box file from step2                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${dots_prefix_green}step3: Reset Radio And Check Post Results  console=${log_to_console}
    FOR  ${ru_sn}  IN  @{rf_list}
        ${reset_start_date}  Get Current Date  UTC
        @{reset_date_split}  Split String  ${reset_start_date}
        RMOD Unit Reset  rmod_sn=${ru_sn}
    END
    Wait Until All Cells Are OnAir  cells_count=${cells_count}  timeout=600
    Check Post Result Structure  folder_path=${step2_folder_path}
    ${step3_folder_path}  Collect Both BBox Files For Radio  destination_folder_path=${logs_dir_path}/${ru_sn}/step3_reset_radio_and_check_POST
    Check Post Result Moved Records  previous_folder_path=${step2_folder_path}  current_folder_path=${step3_folder_path}
    Check Post Result Structure  folder_path=${step2_folder_path}
#    Check Post Resuls Correct Reset Time    current_folder_path=${step2_folder_path}    reset_time=${reset_start_date}
    Log  ${ok_prefix_green}step3: Reset Radio And Check Post Results  console=${log_to_console}
    [Return]  ${step3_folder_path}

step4: Reset Vdu And Check Post Results
    [Arguments]  ${step3_folder_path}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Step3 of testcase. Resets vDU and checks: structure of POST_results and if records are moved correctly inside
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | step3_folder_path      |  Yes | Folder Path to the location of black box file from step3                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${dots_prefix_green}Step 4: Reset Vdu And Check Post Results  console=${log_to_console}
    ${vdu_reset_start_date}  Get Current Date  UTC
    vDU Perform Reset
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir  cells_count=${cells_count}  timeout=600
    ${step4_folder_path}  Collect Both BBox Files For Radio  destination_folder_path=${logs_dir_path}/${ru_sn}/step4_reset_vdu_and_check_POST
    Check Post Result Structure  folder_path=${step3_folder_path}
    Check Post Result Moved Records  previous_folder_path=${step_3_folder_path}  current_folder_path=${step4_folder_path}
#    Check Post Resuls Correct Reset Time    current_folder_path=${step3_folder_path}    reset_time=${vdu_reset_start_date}
    Log  ${ok_prefix_green}Step 4: Reset Vdu And Check Post Results  console=${log_to_console}

#Check Post Resuls Correct Reset Time
#    [Arguments]  ${current_folder_path}  ${reset_time}  ${log_to_console}=True
#    [Documentation]
#    ...  Description:
#    ...  NOT USED due to time difference that CAN happen in reset time (up to 2 hours).
#    ...  Keyword for checking if time of reset is correctly inserted into black box POST_results structure.
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | current_folder_path    |  Yes | Folder Path to the location of black box file after reset                  |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | reset_time             |  Yes | RU Reset Time in UTC format (eg. Get Current Date, 2024-10-01 10:55:48.574)|
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: szymon.przybylak@nokia.com
#    ...  Maintainer: szymon.przybylak@nokia.com
#
#    ${current_post_result_part_list}  Get Part Of Bbox List
#    ...  file_path=${current_folder_path}/BBOX5_snap
#    ...  start_string=Item type: POST_results
#    ...  end_string=---
#    @{bbox_reset_time_split}  Split String  ${current_post_result_part_list[5]}
#    ${evaluate_bbox_time_command}  Catenate  SEPARATOR=  __import__("datetime").datetime.strptime("${bbox_reset_time_split[2]}".split("+")[0],
#    ...  "%Y-%m-%dT%H:%M:%S").astimezone(__import__("datetime").timezone.utc).timestamp()
#    ${bbox_time}  Evaluate  ${evaluate_bbox_time_command}
#    ${evaluate_reset_time_command}  Catenate  SEPARATOR=  __import__("datetime").datetime.strptime("${reset_time}".split(".")[0],
#    ...  "%Y-%m-%d %H:%M:%S").astimezone(__import__("datetime").timezone.utc).timestamp()
#    ${reset_ru_time}  Evaluate  ${evaluate_reset_time_command}
#    Run Keyword If  ${bbox_time} < ${reset_ru_time}  Fail
#    ...  msg=Incorrect time of reset in black box in POST_results.\nTime of RU reset ~${reset_time}". Time in black box ${bbox_reset_time_split[2]}
#    ELSE  Log  ${info_prefix}Time of reset in black box POST_result is OK  console=${log_to_console}

Check Post Result Moved Records
    [Arguments]  ${previous_folder_path}  ${current_folder_path}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword for checking if records from POST_results moved correctly after reset.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | previous_folder_path   |  Yes | Folder Path to the location of black box file from before reset            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | current_folder_path    |  Yes | Folder Path to the location of black box file after current reset          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${info_prefix}Check Post Results Moved Records  console=${log_to_console}
     ${previous_post_result_part_list}  Get Part Of Bbox List
    ...  file_path=${previous_folder_path}/BBOX5_snap
    ...  start_string=Item type: POST_results
    ...  end_string=---
    ${current_post_result_part_list}  Get Part Of Bbox List
    ...  file_path=${current_folder_path}/BBOX5_snap
    ...  start_string=Item type: POST_results
    ...  end_string=---
    FOR  ${index}  IN RANGE  9
        Continue For Loop If  ${index}<3
        ${current_temp}  Fetch From Right  ${current_post_result_part_list[${index}]}  :
        ${previous_temp}  Fetch From Right  ${previous_post_result_part_list[${index+3}]}  :
        Should Match  ${previous_temp}  ${current_temp}
    END

Check Post Result Structure
    [Arguments]  ${folder_path}  ${post_results_template}=${post_results_template}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword for checking if structure of POST_results part is correct.
    ...  Values that should be in structure are given in ${post_results_template} global variable. Structure format
    ...  taken from https://gates.nsn-net.net/view/000272df#o=300
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | folder_path            |  Yes | Folder Path to the location of black box file                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | post_results_template  |  No  | List with structure of POST_results                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${info_prefix}Check Post Result Structure  console=${log_to_console}
    ${post_results_keys}  ${part_bbox_keys}  Prepare Keys For Black Box Functions Check
    ...  dst_folder=${folder_path}
    ...  start_string=Item type: POST_results
    FOR  ${item}  IN  @{post_results_keys}
        Should Contain  ${post_results_template}  ${item}
    END

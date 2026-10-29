*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__LOGS__SBTS_snapshot_from_WEBEM
Variables    tc_variables/sbts_sbts_sbts_sbts__logs__sbts_snapshot_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}             1       # Number of on demand Snapshot collection operations. Default value: 1
${SNAPSHOT_BTS}              ALL     # Technology for on demand Snapshot collection. Possible values: BTS1, BTS2, BTS3, BTS4, ALL;
                                      # default value: ALL
${SNAPSHOT_DIR_PATH}                  # Folder path for requested Snapshot collection.
                                      # If empty, default Snapshot collection folder:
                                      # /home/ute/test_results_directory/<date_time>_TestName/Snapshot/<date_time>,
                                      # If valued, create new folder for Snapshot collection on your Virtual Machine with the input value.
                                      # ex: /home/ute/Snapshot
${DELAY_BETWEEN_SNAPSHOTS}    30      # Delay time between Snapshot collections measured in seconds. Default value: 30
${RMOD_SN_list}                       # List of RMODs serial numbers to be verified separated by comma. Example: L1181711696, L1181711681. If empty,
                                      # all configured RMODs will be verfied. In snpashot, only RMODs present on that BTS will be checked

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__LOGS__SBTS_snapshot_from_WEBEM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-22879
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS_SBTS test case for SBTS Snapshot collection, - x times sequence.
    ...
    ...  SNAPSHOT_TECH - variable value related to technology on which Snapshot collection is performed as below:
    ...   - BTS1: Snapshot collection only on SBTS Master
    ...   - BTS2: Snapshot collection only on SBTS Slave
    ...   - BOTH: Snapshot collection on both SBTSs
    ...
    ...  SNAPSHOT_DIR_PATH - variable value related to Snapshot collection folder. Use as below:
    ...   - if empty, default Snapshot collection folder for SBTS Master:
    ...  /home/ute/test_results_directory/<date_time>_TestName/Snapshot/<date_time>/Master_SBTS_snapshot.zip
    ...   - if empty, default Snapshot collection folder for SBTS Slave:
    ...  /home/ute/test_results_directory/<date_time>_TestName/Snapshot/<date_time>/Slave_SBTS_snapshot.zip
    ...   - if valued, create new folder for Snapshot collection with input value: ex: /home/ute/Snapshot
    ...
    ...  DELAY_BETWEEN_SNAPSHOTS - variable value related to the delay time between Snapshot collections. Delay time is measured in seconds.
    ...
    ...  The main steps performed for the test are:
    ...
    ...  - check initial state and alarms for both SBTSs
    ...  - perform Snapshot collection on demand based on SNAPSHOT_TECH value
    ...  - Snapshot sanity check related to RMOD file presence (runtime.zip and startup.zip files). Test fails in case at least one mandatory file
    ...  wasn't found or when at least size of one file is equal zero.
    ...  - check final state and alarms for both SBTSs
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22879 - [5G] [SBTS_SBTS] TC_LOG: Repeated Snapshot saving
    ...  - 06.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23778 - [5G] TC: Repeated Snapshot saving 2 Include mechanism in 2 remaining TCs
    ...  - 23.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27403 - [5G] Snapshot is not collected when test is failing
    ...  - 15.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28294 - [5G]Update SBTS_SBTS_SBTS_SBTS__LOGS__SBTS_snapshot_from_WEBEM for to
    ...  match with all RMOD nomenclatures and do not stop analysis at first failed snapshot check
    ...  - 10.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28557 - Automated tc for snapshot_from_WEBEM gives wrong verdict and also
    ...  expects wrong nr of digits
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-22879_SBTS__LOGS__SBTS_snapshot_from_WEBEM.png

    Set Tags    CA-LOGS    OWNER-valentin.marian@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT


    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info
    Step 4: Get all RMODs
    FOR  ${iteration}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${iteration} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 6: On Demand Snapshot collection
        Step 7: Snapshot sanity check
    END
    Step 8: Check final all BTS state
    Step 10: Check final all BTS alarms

Step ${index}: Get all BTS info
    Log  Step ${index}: Get all BTS info  console=True

    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${SNAPSHOT_BTS}' != 'ALL'  Check BTS list  ${BTS_label_alias_dict}  ${BTS_label_list}
    Log  ====================================================  console=True
    Log  BTS label list selected for BTS Snapshot: ${BTS_label_list}  console=True
    Log  BTS alias list selected for BTS Snapshot: ${BTS_alias_list}  console=True
    Log  ====================================================  console=True

Check BTS list
    [Arguments]  ${BTS_label_alias_dict}  ${BTS_label_list}

    ${SNAPSHOT_BTS_strip}=  Replace String  ${SNAPSHOT_BTS}  ${SPACE}  ${EMPTY}
    ${SNAPSHOT_BTS}=  Split String  ${SNAPSHOT_BTS_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{SNAPSHOT_BTS}
        ${BTS_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_check}
        Run Keyword If  '${item}' not in ${BTS_label_list}
        ...  Append To List  ${BTS_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_request_label_list}  ${item}
    END

    Run Keyword If  '${BTS_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}. Please select values for test argument \${BTS_LIST} from
    ...  configured BTS: ${BTS_label_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_request_label_list}
        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}
    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}


Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    ${wait_for_alarm_clear}=  Set Variable If  '${when}' == 'final'  15 min  5 min
    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}  wait_for_alarm_clear=${wait_for_alarm_clear}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get all RMODs
    Log  Step ${index}: Get all RMODs  console=True
    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=
    ...  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Run Keyword If  '${RMOD_SN_list} '==' '
    ...  Construct RMOD_SN_list If Empty

Construct RMOD_SN_list if empty
    ${intermediate_all_sn_list}=  Create List
    FOR  ${alias}  IN  @{BTS_alias_list}
        Append to list  ${intermediate_all_sn_list}  @{BTS_alias_RMOD_sn_dict['${alias}']}
        ${intermediate_all_sn_list}=  Remove Duplicates  ${intermediate_all_sn_list}
    END
    ${intermediate_all_sn_list}=  Evaluate  ",".join(${intermediate_all_sn_list})
    Set Test Variable  ${RMOD_SN_list}  ${intermediate_all_sn_list}

Step ${index}: On Demand Snapshot collection
    [Documentation]
    ...  On Demand Snapshot collection based on requested technology

    [Timeout]    30 min
    Log  Step ${index}: On Demand Snapshot collection  console=True

    ${path}=  Run Keyword If  '${SNAPSHOT_DIR_PATH}' == ''  Set Variable  ${Test Results Dir}/Snapshot
    ...  ELSE  Set Variable  ${SNAPSHOT_DIR_PATH}
    ${timestamp}=  Get Current Date  result_format=%Y-%m-%d_%H:%M:%S
    Set Test Variable  ${path}
    Set Test Variable  ${timestamp}

    FOR  ${alias}  IN  @{BTS_alias_list}
         Log  BTS for Snapshot collection: ${alias}  console=True
         Save Snapshot file  ${alias}
         Run Keyword If  '${alias}'!='${BTS_alias_list}[-1]'
         ...  Run Keywords
         ...  Log  Wait static time of ${DELAY_BETWEEN_SNAPSHOTS} seconds between Snapshot collections  console=True
         ...  AND  Sleep  ${DELAY_BETWEEN_SNAPSHOTS}s
    END

Step ${index}: Snapshot sanity check
    Log  Step ${index}: Snapshot sanity check  console=True
    FOR  ${alias}  IN  @{BTS_alias_list}
        Initialize Log File  alias=${alias}
        Log  =====================================  console=True
        Log  BTS for Snapshot check: ${alias}  console=True
        Log  =====================================  console=True
        Log  For more details check: ${log_file}  console=True
        Verify Snapshot  ${alias}
    END

Initialize log file
    [Arguments]  ${alias}
    ${log_file}=  Calculate Snapshot Check Report File Name
    ...  Snapshot_path_and_file_name=${folder_path}/${${alias}_Snapshot_filename}
    Create File  ${log_file}
    Set Test Variable  ${log_file}

Log to console and file
    [Arguments]  ${message}  ${level}=${Empty}  ${console}=True
    ${log_warn}=  Create Dictionary  level=${level}
    ${log_info}=  Create Dictionary  console=${console}
    ${log_argument}=  Set Variable If  '${level} '!='${Empty} '
    ...  ${log_warn}  ${log_info}
    Run Keyword  Log  ${message}  &{log_argument}
    Append to file  ${log_file}  ${message}\n

Save Snapshot file
    [Arguments]  ${alias}

    Log  Snapshot file collection on SBTS ${alias} started  console=True
    ${folder_path}  ${Snapshot_filename}=  Snapshot collection on demand SOAM  ${alias}  ${path}/${timestamp}
    Set Test Variable  ${folder_path}
    Set Test Variable  ${${alias}_Snapshot_filename}  ${Snapshot_filename}

Verify Snapshot
    [Arguments]  ${alias}

    Log  Snapshot sanity check for RMODs mapped on SBTS ${alias} from RMOD list: ${RMOD_SN_list}  console=True
    FOR  ${RMOD_sn}  IN  @{BTS_alias_RMOD_sn_dict['${alias}']}
        Run Keyword If  '${RMOD_sn}' not in '${RMOD_SN_list} '
        ...  Continue For Loop
        ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_SN_ID_dict}  ${RMOD_sn}
        Log To Console And File  ===============================================================
        Log To Console And File  Check mandatory and optional files for RMOD with SN: ${RMOD_sn}
        Log To Console And File  ===============================================================
        ${RMOD_sw_identifier}=  Get RMOD sw identifier  ${RMOD_id}  ${alias}
        Snapshot Sanity Check  RMOD_sn=${RMOD_sn}  RMOD_sw_identifier=${RMOD_sw_identifier}
        ...  snapshot_path=${folder_path}/${${alias}_Snapshot_filename}
    END

Get RMOD SW identifier
    [Arguments]  ${RMOD_dn}  ${alias}
    ${possible_identifier_list}=  Get Dictionary Keys  ${RMOD_snapshot_rules}
    ${RM_param_list}=  Set Variable  &{Empty}
    ${RM_param_list}=  coam.Get Parameters For  class_name=RMOD  id_num=${RMOD_dn}  connection=${alias}
    Run Keyword If  ${RM_param_list} == &{Empty}  Fail  RMOD parameters for ${RMOD_dn} could not be read
    ${regexp}=  Set Variable  (([a-zA-Z]+[0-9]+)|([0-9]+[a-zA-Z]+))
    ${fields_from_sw_name}=  Get Regexp Matches  ${RM_param_list['buildVersion']}  ${regexp}
    ${fields_from_sw_name_lower}=  Create List
    FOR  ${field}  IN  @{fields_from_sw_name}
        Append to list  ${fields_from_sw_name_lower}  ${field.lower()}
    END
    Append to file  ${log_file}  RMOD SW identifier in BTS:\n
    Append to file  ${log_file}  ${fields_from_sw_name_lower}[0]\n
    FOR  ${possible_sw_identifier}  IN  @{possible_identifier_list}
        Exit For Loop If  '${possible_sw_identifier}' in @{fields_from_sw_name_lower}
        ${possible_sw_identifier}=  Set Variable If  '${possible_sw_identifier}'=='${possible_identifier_list}[-1]'
        ...  default  ${None}
    END
    Log  Using ${possible sw_identifier} rule  console=True
    [Return]  ${possible_sw_identifier}

Calculate snapshot check report file name
     [Arguments]  ${Snapshot_path_and_file_name}=${None}
     Run Keyword If  '${Snapshot_path_and_file_name}'=='${None}'
     ...  Return From Keyword  ${None}
     ${snapshot_name_array}=  Split String  ${Snapshot_path_and_file_name}  separator=.
     ${snapshot_name_1st_part}=  Evaluate  ".".join(${snapshot_name_array[:-1:]})
     ${snapshot_check_report_file_name}=  Catenate  ${snapshot_name_1st_part}  _snapshot_check_report.txt
     [Return]  ${snapshot_check_report_file_name}

Snapshot Sanity Check
    [Arguments]  ${RMOD_sn}  ${RMOD_sw_identifier}  ${snapshot_path}
    ${snapshot_dict}=  snapshot.Get Data From Snapshot  ${snapshot_path}
    ${exception_present}=  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${RMOD_snapshot_rules}  ${RMOD_sw_identifier}
    ${RMOD_sw_identifier}=  Set Variable If  ${exception_present}  ${RMOD_sw_identifier}  default
    ${file_name_list}=  Get From Dictionary  ${RMOD_snapshot_rules}  ${RMOD_sw_identifier}
    ${file_name_list}=  Update File Names  ${file_name_list}  ${RMOD_sn}
    ${file_name_list_optional}=  Get From Dictionary  ${RMOD_snapshot_rules}  ${RMOD_sw_identifier}_optional
    ${file_name_list_optional}=  Update File Names  ${file_name_list_optional}  ${RMOD_sn}
    ${json_spec_dict}=  Create Dictionary  mandatory_file=@{file_name_list}  not_mandatory_file=@{file_name_list_optional}

    ${status}  ${msg}=  Run Keyword And Ignore Error  snapshot.validate_snapshot_using_custom_data  ${snapshot_dict}  ${json_spec_dict}
    Run Keyword If  '${status}' != 'PASS'  Run Keywords
    ...  Log  Failed to perform snapshot sanity check for RMOD with SN ${RMOD_sn}  level=ERROR
    ...  AND  Append to file  ${log_file}  Failed the Snapshot Sanity check for RMOD with SN: ${RMOD_sn}\n
    ...  AND  Run Keyword And Continue On Failure  Fail  Failed to perform snapshot sanity check for RMOD with SN ${RMOD_sn}
    Return From Keyword If  '${status}' != 'PASS'
    ${validate_custom}=  Set Variable  ${msg}
    ${list_size_mandatory}=  Get Length  ${file_name_list}
    ${list_size_optional}=  Get Length  ${file_name_list_optional}
    Append to file  ${log_file}  Rule used for RMOD: ${RMOD_sw_identifier}\n
    Append to file  ${log_file}  Mandatory/Optional File - File Rule - File location - File size :\n
    FOR  ${index}  IN RANGE  0  ${list_size_mandatory}
      ${file_list}  Get From List  ${validate_custom}  ${index}
      ${file_rule}  Get From List  ${file_list}  -3
      ${file_location}  Get From List  ${file_list}  -2
      ${file_size}  Get From List  ${file_list}  -1
      Append to file  ${log_file}  Mandatory - ${file_rule} - ${file_location} - ${file_size} Bytes\n
    END
    FOR  ${index}  IN RANGE  0  ${list_size_optional}
      ${optional_index}=  Evaluate  ${index} + ${list_size_mandatory}
      ${file_list}  Get From List  ${validate_custom}  ${optional_index}
      ${file_rule}  Get From List  ${file_list}  -3
      ${file_location}  Get From List  ${file_list}  -2
      ${file_size}  Get From List  ${file_list}  -1
      Run Keyword If  '-' in '${file_size}'
      ...  Log To Console And File  Optional - ${file_rule} - File not found !!!  level=WARN
      ...  ELSE
      ...  Append to file  ${log_file}  Optional - ${file_rule} - ${file_location} - ${file_size} Bytes\n
    END
    Log To Console And File  All mandatory files were found!

Update File Names
    [Arguments]  ${file_name_list}  ${RMOD_sn}
    ${new_list}=  Create List
    FOR  ${item}  IN  @{file_name_list}
        ${item}=  Replace String  ${item}  \$\{RMOD_sn\}  ${RMOD_sn}
        Append To List  ${new_list}  ${item}
    END
    [Return]  ${new_list}

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown  NO

*** Settings ***
Documentation  TODO
...  Author: szymon.przybylak@nokia.com
...  Maintainer: szymon.przybylak@nokia.com

Library    ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.ul.vdu.helm.interface.helm   WITH NAME    helm
Library    taf.transport.ssh  WITH NAME  tafssh
Resource   Cloud_LOGS_Fail_Safe_Mode_resource.resource
*** Variables ***
${TRUNK}    vDUCNF26R1
@{VDU_FAILSAFE_SNAP_ALLOWED_ALARMS}=  faultId=2934, severity=critical
...                               faultId=4590, severity=warning
...                               faultId=10, severity=critical
...                               faultId=4523, severity=warning
@{VCU_FAILSAFE_SNAP_ALLOWED_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__LOGS_Snapshot_Collection_During_Fail_Safe_Mode
  [Arguments]  ${rmod_ids}  ${scfc_file_path}  ${log_to_console}=True
  [Documentation]
  ...  Testcase for collecting snapshots from radio module and webem during fail safe mode and checking if
  ...  all files are present in both snapshots.
  ...
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | rmod_ids               | Yes  | RM serial numbers separated by '|'                                         |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | scfc_file_path         | Yes  | path to SCFC file                                                          |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | log_to_console         | No   | if True, logs will be printed to console                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: szymon.przybylak@nokia.com
  ...  Maintainer: szymon.przybylak@nokia.com

  # Preconditions start
  Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_FAILSAFE_SNAP_ALLOWED_ALARMS}
  Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_FAILSAFE_SNAP_ALLOWED_ALARMS}
  ${logs_dir_path}=  Set Variable  ${SUITE_LOGS_DIR_PATH}/${TEST_NAME}/test_run
  vDU Rest Login
  ${mrbts_id}  vDU Get MRBTS Id    vdu_login=False
  Set Test Variable    ${MRBTS_ID}    ${mrbts_id}
  Set Test Variable  ${log_to_console}  True
  ${rmod_id_list}=  vDU SCFC Get RMOD Id List  scfc_file_path=${scfc_file_path}
  ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
  ${vdu_k8s_connection_params}  Get vDU K8s Master Node Connection Parameters From Init File
  ${cloud_server_ip}  Set Variable  ${vdu_k8s_connection_params['ip_addr']}
  ${running_build}    vDU Get Running Software Version    vdu_login=False
  ${RF_status}=   Run Keyword And Return Status    Variable Should Exist    ${rmod_ids}
  ${rf_list}=  Run Keyword If  ${RF_status}  Split String  string=${rmod_ids}  separator=|
  Set Test Variable  ${RF_LIST}  ${rf_list}
  Wait Until All Cells Are OnAir  cells_count=${cells_count}
  Log  ${ok_prefix_green}All cells are OnAir  console=${log_to_console}
  # Preconditions end
  FOR  ${rmod_id}  IN  @{rmod_id_list}
    ${rmod_name}=  Set Variable  RMOD-${rmod_id}
    ${rmods_sn_id}=  vDU RMODs Get Serial Number And Id
    ${rmod_sn}=  Set Variable  ${rmods_sn_id['${rmod_id}']}
    Continue For Loop If  '${rmod_sn}' not in ${RF_LIST}
    Create Directory  ${logs_dir_path}/${rmod_sn}
    Log  ${info_prefix}Reseting RM to clear fault history file  console=${log_to_console}
    Reset Radio Module And Wait For OnAir  ru_serial_number=${rmod_sn}
    ...  cloud_server_ip=${cloud_server_ip}
    ...  cells_count=${cells_count}
    # Enable safe mode with  RM reset, wait for FID 2934
    Enable Fail Safe Mode On RM  ru_serial_number=${rmod_sn}
    ...  cloud_server_ip=${cloud_server_ip}
    ...  cells_count=${cells_count}
    Log  ${info_prefix}Waiting for FID2934  console=${log_to_console}
    ${alarm_severity_list}=  Create List  Critical
    vDU Assert Alarm Active  fault_id=2934
    ...  vdu_login=False
    ...  timeout=10min
    ...  alarm_severity_list=${alarm_severity_list}
    Log  ${info_prefix}Waiting for fault 1462 with severity Warning in fault history log file on RM  console=${log_to_console}
    radio.Assert Active Fault In Fault History Log File  ru_serial_number=${rmod_sn}
    ...  fault_id=1462
    ...  severity=Warning
    ...  cloud_server_ip=${cloud_server_ip}
    Create Directory   ${logs_dir_path}/${rmod_sn}/snapshot_webem_full
    Create Directory   ${logs_dir_path}/${rmod_sn}/snapshot_rmod_full
    Create Directory   ${logs_dir_path}/${rmod_sn}/snapshot_webem_minor
    Create Directory   ${logs_dir_path}/${rmod_sn}/snapshot_rmod_minor
    # Download snapshots Full and most important
    Log  ${info_prefix}Downloading full snapshot from WebEM  console=${log_to_console}
    ${snap_webem_full_download_status}  ${snap_webem_full_path}=  Run Keyword And Ignore Error
    ...  vdu.Get Local Snapshot  directory=${logs_dir_path}/${rmod_sn}/snapshot_webem_full
    ...  compressed_or_not=True
    ...  coverage=full
    Log  ${info_prefix}Downloading minor snapshot from WebEM  console=${log_to_console}
    ${snap_webem_minor_download_status}  ${snap_webem_minor_path}=  Run Keyword And Ignore Error
    ...  vdu.Get Local Snapshot  directory=${logs_dir_path}/${rmod_sn}/snapshot_webem_minor
    ...  compressed_or_not=True
    ...  coverage=minor
    Log  ${info_prefix}Downloading full snapshot from RM  console=${log_to_console}
    ${snap_rmod_full_download_status}  ${snap_rmod_full_path}=  Run Keyword And Ignore Error
    ...  Get Radio Module Snapshot  directory=${logs_dir_path}/${rmod_sn}/snapshot_rmod_full
    ...  ru_serial_number=${rmod_sn}
    ...  cloud_server_ip=${cloud_server_ip}
    ...  coverage=Full
    Log  ${info_prefix}Downloading minor snapshot from RM  console=${log_to_console}
    ${snap_rmod_minor_download_status}  ${snap_rmod_minor_path}=  Run Keyword And Ignore Error
    ...  Get Radio Module Snapshot  directory=${logs_dir_path}/${rmod_sn}/snapshot_rmod_minor
    ...  ru_serial_number=${rmod_sn}
    ...  cloud_server_ip=${cloud_server_ip}
    ...  coverage=Minor
    # Disable fail safe
    Disable Fail Safe Mode On RM  ru_serial_number=${rmod_sn}
    ...  cloud_server_ip=${cloud_server_ip}
    ...  cells_count=${cells_count}
    vDU Assert Alarm Inactive  fault_id=2934
    ...  vdu_login=False
    ...  timeout=10min
    Log  ${info_prefix}Fault 2934 cleared  console=${log_to_console}
    # Analyse snapshots
    Run Keyword If  '${snap_webem_full_download_status}'=='FAIL'  Fail
    ...  msg=Full WebEM snapshot was not collected
    Run Keyword If  '${snap_webem_minor_download_status}'=='FAIL'  Fail
    ...  msg=Most Important Files WebEM snapshot was not collected
    Run Keyword If  '${snap_rmod_full_download_status}'=='FAIL'  Fail
    ...  msg=Full radio module snapshot was not collected
    Run Keyword If  '${snap_rmod_minor_download_status}'=='FAIL'  Fail
    ...  msg=Most Important Files radio module snapshot was not collected
    Log  ${ok_prefix_blue}vDU snapshots have been collected  console=${log_to_console}
    ${snapshot_file_list_path}=  Download Snapshot File List  build_name=${running_build}
    ...  local_path=${logs_dir_path}/${rmod_sn}
    ${ru_hw_family}  ${ru_name}=  Get RMOD HW Family  ru_serial_number=${rmod_sn}
    ...  cloud_server_ip=${cloud_server_ip}
    Compare Snapshots  snap_webem_path=${snap_webem_full_path}
    ...  snap_rmod_path=${snap_rmod_full_path}
    ...  coverage=full
    ...  snap_file_list_path=${snapshot_file_list_path}
    ...  ru_serial_number=${rmod_sn}
    ...  ru_hw_family=${ru_hw_family}
    ...  ru_name=${ru_name}
    Compare Snapshots  snap_webem_path=${snap_webem_minor_path}
    ...  snap_rmod_path=${snap_rmod_minor_path}
    ...  coverage=minor
    ...  snap_file_list_path=${snapshot_file_list_path}
    ...  ru_serial_number=${rmod_sn}
    ...  ru_hw_family=${ru_hw_family}
    ...  ru_name=${ru_name}
  END
  Wait Until All Cells Are OnAir  cells_count=${cells_count}

Get Radio Module Snapshot
  [Arguments]  ${directory}  ${ru_serial_number}  ${cloud_server_ip}  ${coverage}
  [Documentation]
  ...  Collects snapshot from radio module and downloads it to VM
  ...
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | directory              | Yes  | path for destination directory for downloading the snapshot                |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | ru_serial_number       | Yes  | RM serial number                                                           |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | cloud_server_ip        | Yes  | IP of the cloud server                                                     |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | coverage               | Yes  | typ of snapshot to collect (minor|full)                                    |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: dawid.bak@nokia.com
  ...  Maintainer: dawid.bak@nokia.com

  IF  '${RELEASE}'=='VDUCNF00'
    ${tmp_namespace}=  Set Variable  ${EMPTY}
  ELSE
    ${tmp_namespace}=  Set Variable  cran-1-
  END
  Log  ${start_prefix_blue}Collecting ${coverage} snapshot on radio module ${ru_serial_number} started  console=${log_to_console}
  ${pod_name}=  Get Pod Name  namespace=cran1  pod_name=oamfh-0
  ${file_name}=  radio.Collect Radio Module Snapshot  ru_serial_number=${ru_serial_number}
  ...  cloud_server_ip=${cloud_server_ip}
  ...  coverage=${coverage}
  Log  ${info_prefix}Copying ${file_name} from RM to SMOD  console=${log_to_console}
  Wait Until Keyword Succeeds   60  5  radio.Send File Via SCP
  ...  ru_serial_number=${ru_serial_number}
  ...  direction=to_container
  ...  file_path=/ram/${file_name}
  ...  destination_directory=/tmp
  ...  cloud_server_ip=${cloud_server_ip}
  Log  ${info_prefix}Downloading ${file_name} from SMOD to VM  console=${log_to_console}
  tafssh.Connect To  hostname=${cloud_server_ip}
  ...  username=core
  ...  password=system123
  ...  alias=primary
  tafssh.Send Command  kubectl cp -n cran1 ${pod_name}:"/tmp/${file_name}" -c ctr-${tmp_namespace}oamfh "/tmp/${file_name}"
  ...  connection=primary
  tafssh.Read Output  connection=primary
  tafssh.Download File  remote_path=/tmp/${file_name}
  ...  local_path=${directory}/${file_name}
  ...  connection=primary
  tafssh.Send Command  rm /tmp/${file_name}  connection=primary
  radio.Close SSH Connection
  Log  ${done_prefix_blue}Collecting ${coverage} snapshot on radio module ${ru_serial_number} done  console=${log_to_console}
  [Return]  ${directory}/${file_name}

Download Snapshot File List
  [Arguments]  ${build_name}  ${local_path}
  [Documentation]
  ...  Downloads snapshot documentation for given software build and extracts snapshot file list from it
  ...
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | build_name             | Yes  | name of current SW build on vDU                                            |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | local_path             | Yes  | path for destination directory for downloading the snapshot file list      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Return:
  ...  Full path with file name for snapshot file list
  ...
  ...  Author: dawid.bak@nokia.com
  ...  Maintainer: dawid.bak@nokia.com

  Log  ${start_prefix_blue}Downloading snapshot documentation started  console=${log_to_console}
  ${release}=  Fetch From Left  string=${build_name}
  ...  marker=_
  ${release}=  Set Variable If  '${release}' == '${TRUNK}'  vDUCNF00  ${release}
  Set Test Variable  ${RELEASE}    ${release}
  ${build_version}=  Fetch From Right  string=${build_name}
  ...  marker=_
  ${url}=  Catenate  SEPARATOR=
  ...  https://artifactory-mn-espoo3.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
  ...  ${release}/${release}_${build_version}/snapshot_documentation-${build_version}.tgz
  ${download_path}=  Set Variable  ${local_path}/snapshot_documentation
  Create Directory  ${download_path}
#  ${return_code}=  Run And Return Rc
#  ...  command= curl --create-dirs -O --output-dir "${download_path}" ${url}
  ${return_code}    Run And Return Rc
  ...  command=timeout 30 wget -P '${download_path}' ${url}
  Run Keyword If  ${return_code} != 0
    ...  Fail  Downloading file failed with error code ${return_code}
  ...  ELSE
    ...  Log  Downloading file package successful
  ${return_code}=  Run And Return Rc
  ...  command= tar xvfz "${download_path}/snapshot_documentation-${build_version}.tgz" -C "${download_path}"
  Run Keyword If  ${return_code} != 0
    ...  Fail  Extracting archive failed with error code ${return_code}
  ...  ELSE
    ...  Log  Extracting archive successful
  Log  ${done_prefix_blue}Downloading snapshot documentation done  console=${log_to_console}
  [Return]  ${download_path}/${build_version}_trbl_log_list.csv

Get RMOD HW Family
  [Arguments]  ${ru_serial_number}  ${cloud_server_ip}
  [Documentation]
  ...  Gets hardware family name of the radio module for filtering snapshot documentation.
  ...  Utilizes global wariable ${RMOD_HW_FAMILY_DICT} from variables.robot.
  ...
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | ru_serial_number       | Yes  | RM serial number                                                           |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | cloud_server_ip        | Yes  | IP of the cloud server                                                     |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: dawid.bak@nokia.com
  ...  Maintainer: dawid.bak@nokia.com

  ${ru_name}  ${ru_ip}=  radio.Open Connection To Radio Module  ru_serial_number=${ru_serial_number}
  ...  cloud_server_ip=${cloud_server_ip}
  ${ru_hw_family}=  Get From Dictionary  dictionary=${RMOD_HW_FAMILY_DICT}
  ...  key=${ru_name}
  [Return]  ${ru_hw_family}  ${ru_name}
  [Teardown]  radio.Close SSH Connection

Compare Snapshots
  [Arguments]  ${snap_webem_path}  ${snap_rmod_path}  ${coverage}  ${snap_file_list_path}  ${ru_serial_number}  ${ru_hw_family}  ${ru_name}
  [Documentation]
  ...  Compares webem snapshot and radio module snapshot to snapshot documentation
  ...
  ...  Arguments:
  ...  +========================+======+===============================================================================+
  ...  | Argument               | Man. | Description                                                                   |
  ...  +========================+======+===============================================================================+
  ...  | snap_webem_path        | Yes  | path for webem snapshot file                                                  |
  ...  +------------------------+------+-------------------------------------------------------------------------------+
  ...  | snap_rmod_path         | Yes  | path for radio module snapshot file                                           |
  ...  +------------------------+------+-------------------------------------------------------------------------------+
  ...  | coverage               | Yes  | typ of snapshot to analyse (minor|full)                                       |
  ...  +------------------------+------+-------------------------------------------------------------------------------+
  ...  | snap_file_list_path    | Yes  | path for target snapshot file list .csv file                                  |
  ...  +------------------------+------+-------------------------------------------------------------------------------+
  ...  | ru_serial_number       | Yes  | RM serial number                                                              |
  ...  +------------------------+------+-------------------------------------------------------------------------------+
  ...  | ru_hw_family           | Yes  | hardware family name of the radio module for filtering snapshot documentation |
  ...  +------------------------+------+-------------------------------------------------------------------------------+
  ...  | ru_name                | Yes  | name of the RU e.g. AHFII                                                     |
  ...  +------------------------+------+-------------------------------------------------------------------------------+

  ...
  ...  Author: dawid.bak@nokia.com
  ...  Maintainer: dawid.bak@nokia.com


  Log  ${start_prefix_blue}Analysing snapshots started. Coverage: ${coverage}  console=${log_to_console}
  # Parse target file list CSV into list
  Log  ${dots_prefix_blue}Parsing snapshot documentation...  console=${log_to_console}
  ${csv}=  Get File  ${snap_file_list_path}
  @{csv_list}=  Split To Lines  string=${csv}  start=1
  @{deploy_list}  Create List
  @{target_files_list}=  Create List
  FOR  ${line}  IN  @{csv_list}
    ${line_list}=  Split String  ${line}  separator=;
    ${radio_family}=  Get From List  ${line_list}  0
    Continue For Loop If  '/${ru_hw_family}/' not in '${radio_family}'
    ${coverage_type}=  Get From List  ${line_list}  8
    Run Keyword If  '${coverage}' == 'full'
    ...  Continue For Loop If  '${coverage_type}' != 'F' and '${coverage_type}' != 'M'
    ...  ELSE IF  '${coverage}' == 'minor'
    ...  Continue For Loop If  '${coverage_type}' != 'M'
    ...  ELSE  Fail
    ${conteiner}=  Get From List  ${line_list}  1
    ${file_name}=  Get From List  ${line_list}  2
    ${mandatory_flag}=  Get From List  ${line_list}  6
    ${deployment}=  Get From List  ${line_list}  3
    ${lower_ru_hw_family}=    Evaluate    '${ru_hw_family}'.lower()
    ${lower_deployment}=    Evaluate    '${deployment}'.lower()
    ${rmod_deploy}=  Evaluate  '${ru_name}' in '${deployment}'
    IF  '${lower_ru_hw_family}' in '${lower_deployment}' or 'fsmr4' in '${lower_deployment}'
        Log  All good
    ELSE IF  '${rmod_deploy}' == True
        Log  All good
    ELSE
        Continue For Loop
    END
    IF  '${file_name}' == 'swman_history(\.1)?.log' or '${file_name}' == 'swman_history(\\.1)?.log'
        &{line_dict}=  Create Dictionary  radio_family=${radio_family}
        ...  coverage_type=${coverage_type}
        ...  conteiner=${conteiner}
        ...  file_name=swman_history.log
        ...  mandatory_flag=${mandatory_flag}
        Append To List  ${target_files_list}  ${line_dict}
        &{line_dict2}=  Create Dictionary  radio_family=${radio_family}
        ...  coverage_type=${coverage_type}
        ...  conteiner=${conteiner}
        ...  file_name=swman_history.1.log
        ...  mandatory_flag=${mandatory_flag}
        Append To List  ${target_files_list}  ${line_dict2}
    ELSE
        &{line_dict}=  Create Dictionary  radio_family=${radio_family}
        ...  coverage_type=${coverage_type}
        ...  conteiner=${conteiner}
        ...  file_name=${file_name}
        ...  mandatory_flag=${mandatory_flag}
        Append To List  ${target_files_list}  ${line_dict}
    END
  END

  # Get snapshot_file_list.txt from webem snapshot
  Log  ${dots_prefix_blue}Extracting file list from WebEM snapshot...  console=${log_to_console}
  ${snap_webem_directory}=  Split String From Right  string=${snap_webem_path}
  ...  separator=/
  ...  max_split=1
  ${snap_webem_directory}=  Get From List  ${snap_webem_directory}  0

  ${return_code}=  Run And Return Rc
  ...  command= unzip -o "${snap_webem_path}" -d "${snap_webem_directory}" snapshot_file_list.txt
  Run Keyword If  ${return_code} != 0
    ...  Fail  Extracting archive failed with error code ${return_code}
  ...  ELSE
    ...  Log  Extracting archive successful

  # Parse snapshot_file_list.txt
  Log  ${dots_prefix_blue}Parsing WebEM snapshot file list...  console=${log_to_console}
  ${webem_snapshot_files}=  Get File  ${snap_webem_directory}/snapshot_file_list.txt
  ${matches}=  Get Regexp Matches  ${webem_snapshot_files}
  ...  RU_\\d+\\.zip:\\n((?:\\s{4}BTS${MRBTS_ID}_${ru_serial_number}.+\\n)+)
  ...  1
  Length Should Be  item=${matches}
  ...  length=1
  ...  msg=None

  @{webem_snapshot_file_list}=  Split To Lines  string=${matches}[0]
  ...  start=0
  ...  end=None

  # Get file list from rmod snapshot
  Log  ${dots_prefix_blue}Creating file list for radio module snapshot...  console=${log_to_console}
  ${return_code}  ${output}=  Run And Return Rc And Output
  ...  command= unzip -Z1 "${snap_rmod_path}"
  Run Keyword If  ${return_code} != 0
  ...  Fail  Listing files in the archive failed with error code ${return_code}
  ...  ELSE
  ...  Log  Listing files in the archive successful

  @{rmod_snapshot_file_list}=  Split To Lines  string=${output}
  ...  start=0
  ...  end=None

  # Compare file lists against target files list
  Log  ${dots_prefix_blue}Comparing snapshot file lists with documentation...  console=${log_to_console}
  ${webem_matched_files}=  Create List
  ${webem_unmatched_mandatory_files}=  Create List
  ${webem_unmatched_nonmandatory_files}=  Create List
  ${webem_multiple_matches_files}=  Create List

  ${rmod_matched_files}=  Create List
  ${rmod_unmatched_mandatory_files}=  Create List
  ${rmod_unmatched_nonmandatory_files}=  Create List
  ${rmod_multiple_matches_files}=  Create List
  ${length}  Get Length  ${target_files_list}
  Log  ${length}
  FOR  ${target_file}  IN  @{target_files_list}
    ${target_file_name}=  Get From Dictionary  dictionary=${target_file}
    ...  key=conteiner
    ${target_file_name}=  Run Keyword If  '${target_file_name}' == ''
    ...  Get From Dictionary  dictionary=${target_file}
    ...  key=file_name
    ...  ELSE  Set Variable  ${target_file_name}
    ${mandatory_flag}=  Get From Dictionary  dictionary=${target_file}
    ...  key=mandatory_flag
    ${target_file_name}=  Remove String  ${target_file_name}  __NODE_ID__
    ${target_file_name}=  Remove String  ${target_file_name}  (1011|2011)__
    ${target_file_name}=  Remove String  ${target_file_name}  (1011|2011)_
    ${webem_match_count}=  Get Match Count  list=${webem_snapshot_file_list}
    ...  pattern=regexp=[\\s]*BTS${MRBTS_ID}_${ru_serial_number}_RMOD_.*_${target_file_name}
    ${webem_matches}=  Get Matches  list=${webem_snapshot_file_list}
    ...  pattern=regexp=[\\s]*BTS${MRBTS_ID}_${ru_serial_number}_RMOD_.*_${target_file_name}

    Run Keyword If  ${webem_match_count} == 0 and '${mandatory_flag}' == '1'
    ...  Append To List  ${webem_unmatched_mandatory_files}  ${target_file_name}
    ...  ELSE IF  ${webem_match_count} == 0 and '${mandatory_flag}' == '0'
    ...  Append To List  ${webem_unmatched_nonmandatory_files}  ${target_file_name}
    ...  ELSE IF  ${webem_match_count} == 1
    ...  Append To List  ${webem_matched_files}  ${webem_matches}
    ...  ELSE
    ...  Append To List  ${webem_multiple_matches_files}  ${target_file_name}

    ${rmod_match_count}=  Get Match Count  list=${rmod_snapshot_file_list}
    ...  pattern=regexp=\\d*_(?:${target_file_name})$
    ${target_file_name}=  Run Keyword If  ${rmod_match_count} == 0
    ...  Get From Dictionary  dictionary=${target_file}
    ...  key=file_name
    ...  ELSE  Set Variable  ${target_file_name}
    ${target_file_name}=  Run Keyword If  ${rmod_match_count} == 0
    ...  Remove String  ${target_file_name}  __NODE_ID__
    ...  ELSE  Set Variable  ${target_file_name}
    ${target_file_name}=  Run Keyword If  ${rmod_match_count} == 0
    ...  Remove String  ${target_file_name}  (1011|2011)__
    ...  ELSE  Set Variable  ${target_file_name}
    ${target_file_name}=  Run Keyword If  ${rmod_match_count} == 0
    ...  Remove String  ${target_file_name}  (1011|2011)_
    ...  ELSE  Set Variable  ${target_file_name}
    ${rmod_match_count}=  Run Keyword If  ${rmod_match_count} == 0
    ...  Get Match Count  list=${rmod_snapshot_file_list}
    ...  pattern=regexp=\\d*_(?:${target_file_name})$
    ...  ELSE  Set Variable  ${rmod_match_count}
    # special exception for swman_history.log
    ${target_file_name}=  Run Keyword If  ${rmod_match_count} == 0 and '${target_file_name}' == 'swman_history.log'
    ...  Set Variable  swman_history.zip
    ...  ELSE  Set Variable  ${target_file_name}
    ${target_file_name}=  Run Keyword If  ${rmod_match_count} == 0 and '${target_file_name}' == 'swman_history.1.log'
    ...  Set Variable  swman_history.zip
    ...  ELSE  Set Variable  ${target_file_name}
    ${rmod_match_count}=  Run Keyword If  ${rmod_match_count} == 0
    ...  Get Match Count  list=${rmod_snapshot_file_list}
    ...  pattern=regexp=\\d*_(?:${target_file_name})$
    ...  ELSE  Set Variable  ${rmod_match_count}
    # end of special exception for swman_history.log
    ${rmod_matches}=  Get Matches  list=${rmod_snapshot_file_list}
    ...  pattern=regexp=\\d*_(?:${target_file_name})$

    Run Keyword If  ${rmod_match_count} == 0 and '${mandatory_flag}' == '1'
    ...  Append To List  ${rmod_unmatched_mandatory_files}  ${target_file_name}
    ...  ELSE IF  ${rmod_match_count} == 0 and '${mandatory_flag}' == '0'
    ...  Append To List  ${rmod_unmatched_nonmandatory_files}  ${target_file_name}
    ...  ELSE IF  ${rmod_match_count} == 1
    ...  Append To List  ${rmod_matched_files}  ${rmod_matches}
    ...  ELSE
    ...  Append To List  ${rmod_multiple_matches_files}  ${target_file_name}
  END

  Log  ${webem_unmatched_mandatory_files}
  Log  ${webem_unmatched_nonmandatory_files}
  Log  ${webem_matched_files}
  Log  ${webem_multiple_matches_files}

  Log  ${rmod_unmatched_mandatory_files}
  Log  ${rmod_unmatched_nonmandatory_files}
  Log  ${rmod_matched_files}
  Log  ${rmod_multiple_matches_files}

  Length Should Be  item=${webem_unmatched_mandatory_files}
  ...  length=0
  ...  msg=Some mandatory files were not found in webem snapshot

  Length Should Be  item=${rmod_unmatched_mandatory_files}
  ...  length=0
  ...  msg=Some mandatory files were not found in rmod snapshot

  Log  ${done_prefix_blue}Analysing snapshots done. Coverage: ${coverage}  console=${log_to_console}

*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource    ../Resources/Setup/setup_and_teardown.robot
Resource  ./common_setup.robot
Resource  ./site_operations.robot
Resource  ./site_verifications.robot
Resource  ./variables.robot


Library  BuiltIn
Library  Collections
Library  String
Library  robot.libraries.DateTime
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ute_admin_infomodel    WITH NAME    admin_im


*** Keywords ***
BOAM Memory Consumption
  [Documentation]
  ...  Measures memory consumption of system modules using PerfShot script
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=Measures memory consumption of system modules using PerfShot script will be executed
  ...  style=ONGOING
  Preconditions For CNI-127210
  Download Perfshot from repository
  Gather Memory Usage Data Using Perfshot
  Analyze Memory Usage
  Alarm 6502 Should Not Be Present
  [Teardown]    Common Test Teardown


Download Perfshot from repository
  [Documentation]
  ...  Downloads PerfShot archive from given address to test log directory
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  |  **Full description:**
  ...  |  Curl command used for downloading the file must to be provided
  ...  |  with gitlab private token for authentication

  Create Directory  ${TEST_LOGS_PATH}/PerfShot/
  ${perfshot_download_path}=  Set Variable
  ...  https://gitlabe1.ext.net.nokia.com/api/v4/projects/68475/repository/files/perfshot.tgz/raw?ref=main
  Log  Downloading PerfShot from remote repository started
  ${perfshot_download_return_code}=  Run And Return Rc
  ...  command= curl --header "PRIVATE-TOKEN: ${GIT_ACCESS_TOKEN}" ${perfshot_download_path} -o ${TEST_LOGS_PATH}/PerfShot/perfshot.tgz
  Run Keyword If  ${perfshot_download_return_code} != 0
  ...  Fail  Downloading PerfShot package failed with error code ${perfshot_download_return_code}
  ...  ELSE
  ...  Log  Downloading PerfShot package successful

Gather Memory Usage Data Using Perfshot
  [Documentation]
  ...  Collects memory usage information on each system module
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  |  **Full description:**
  ...  |
  ...  |  Test connects to the system module using ssh. If system under test is dualcore configuration
  ...  |  connection to the slave system module is done using master system module as a proxy
  ...  |  If there are any old perfshot logs on system module they are deleted before execution of the Perfshot
  ...  |  script. Perfshot execution logs are downloaded to test log directory

  Log  Connecting to master system module
  ssh.Connect To  hostname=192.168.255.1
  ...  username=toor4nsn
  ...  password=oZPS0POrRieRtu
  ...  alias=master
  Delete Old Perfshot Logs on SMOD  alias=master
  Execute Perfshot on SMOD  perfshot_tgz_path=${TEST_LOGS_PATH}/PerfShot/perfshot.tgz  alias=master
  ${local_perfshot_logs_path}=  Set Variable  ${TEST_LOGS_PATH}/PerfShot/logs/
  Create Directory  path=${local_perfshot_logs_path}
  Retrieve Perfshot Logs  destination_path=${local_perfshot_logs_path}  alias=master
  ${number_of_SMODs}=  Get Length  ${CFG.scf_hw_all_sm_list}
  Run Keyword If  ${number_of_SMODs}==2  Run Keywords
  ...  Log  Connecting to slave system module
  ...  AND  ssh.Connect To  hostname=fct-4a
  ...  username=toor4nsn
  ...  password=oZPS0POrRieRtu
  ...  proxy=master
  ...  alias=slave
  ...  AND  Delete Old Perfshot Logs on SMOD  alias=slave
  ...  AND  Execute Perfshot on SMOD  perfshot_tgz_path=${TEST_LOGS_PATH}/PerfShot/perfshot.tgz  alias=slave
  ...  AND  Retrieve Perfshot Logs  destination_path=${local_perfshot_logs_path}  alias=slave
  [Teardown]  Run Keywords  ssh.Disconnect  connection=slave
  ...  AND  ssh.Disconnect  connection=master

Delete Old Perfshot Logs on SMOD
  [Documentation]
  ...  Looks for old PerfShot logs on system module and deletes them if there are any
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +--------------+------+--------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +==============+======+==================================================+
  ...  | alias  | Yes  | alias for active ssh connection to SMOD  |
  ...  +--------------+------+--------------------------------------------------+
  [Arguments]  ${alias}

  Log  Looking for old log files
  @{old_log_dir_list}=  Get Files Matching Regexp  path=/var/fct_tmp/
  ...  pattern=perfshot_\\d{6}_\\d{4}
  ...  alias=${alias}
  Run Keyword If  @{old_log_dir_list}==@{EMPTY}
  ...  Log  No old log files detected
  ...  ELSE
  ...  Log  Deleting old log files
  FOR  ${log_directory}  IN  @{old_log_dir_list}
    ssh.Send Command  command=rm -R /var/fct_tmp/${log_directory}  connection=${alias}
    ssh.Assert Exit Status  expected_exit_code=0  connection=${alias}
  END

Execute Perfshot on SMOD
  [Documentation]
  ...  Uploads, prepares and executes PerfShot script on system module
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-------------------+------+---------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +===================+======+=============================================+
  ...  | perfshot_tgz_path | Yes  | local path to PerfShot script archive  |
  ...  +-------------------+------+---------------------------------------------+
  ...  | alias  | Yes  | alias for active ssh connection to SMOD  |
  ...  +-------------------+------+---------------------------------------------+
  [Arguments]  ${perfshot_tgz_path}  ${alias}

  Log  Uploading PerfShot to system module
  ssh.Upload File  local_path=${perfshot_tgz_path}
  ...  remote_path=/var/fct_tmp/perfshot.tgz
  ...  connection=${alias}
  Log  Extracting PerfShot on system module
  ssh.Send Command  command=tar xvfz /var/fct_tmp/perfshot.tgz -C /var/fct_tmp/
  ...  connection=${alias}
  ssh.Assert Exit Status  expected_exit_code=0  connection=${alias}
  ssh.Send Command  command=chmod a+x /var/fct_tmp/perfshot.sh /var/fct_tmp/smem
  ...  connection=${alias}
  ssh.Assert Exit Status  expected_exit_code=0  connection=${alias}
  Log  Executing PerfShot
  ssh.Send Command  command=/var/fct_tmp/perfshot.sh --all --noemperf --btslevel
  ...  connection=${alias}
  ssh.Assert Exit Status  expected_exit_code=0  connection=${alias}

Retrieve Perfshot Logs
  [Documentation]
  ...  Downloads PerfShot logs from system module to local destination
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +------------------+------+----------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +==================+======+==============================================+
  ...  | destination_path | Yes  | local path for saving PerfShot logs  |
  ...  +------------------+------+----------------------------------------------+
  ...  | alias  | Yes  | alias for active ssh connection to SMOD  |
  ...  +------------------+------+----------------------------------------------+
  [Arguments]  ${destination_path}  ${alias}

  Log  Retrieving PerfShot logs
  @{perfshot_log_dir_list}=  Get Files Matching Regexp  path=/var/fct_tmp/
  ...  pattern=perfshot_\\d{6}_\\d{4}
  ...  alias=${alias}
  Length Should Be  item=@{perfshot_log_dir_list}  length=1
  @{perfshot_log_files_list}=  Get Files Matching Regexp  path=/var/fct_tmp/${perfshot_log_dir_list[0]}
  ...  pattern=.+
  ...  alias=${alias}
  @{perfshot_log_files_list}=  Add prefix to elemnts of the list  input_list=@{perfshot_log_files_list}
  ...  prefix=/var/fct_tmp/${perfshot_log_dir_list[0]}/
  ssh.Download File  remote_path=@{perfshot_log_files_list}
  ...  local_path=${destination_path}
  ...  connection=${alias}

Analyze Memory Usage
  [Documentation]
  ...  Checks if measured system module memory usage doesn't exceeds limits
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  |  **Full description:**
  ...  |  Unpacks Perfshot output files for system modules and searches for lines containing
  ...  |  memory usage value and system module name and serial number. Memory usage is then
  ...  |  compared to maximum value for given system module model

  @{SMOD_logs_list}=  OperatingSystem.List Files In Directory  path=${TEST_LOGS_PATH}/PerfShot/logs/
  ...  pattern=perfCapture_*_[04]_*_*

  FOR  ${SMOD_log}  IN  @{SMOD_logs_list}
    ${SMOD_output_log_path}=  Replace String  string=${SMOD_log}
    ...  search_for=perfCapture
    ...  replace_with=perfdir
    ...  count=1
    ${SMOD_output_log_path}=  Fetch From Left  string=${SMOD_output_log_path}
    ...  marker=.tgz
    Run Process  tar  -zxvf  ${TEST_LOGS_PATH}/PerfShot/logs/${SMOD_log}
    ...  -C  ${TEST_LOGS_PATH}/PerfShot/logs/
    ...  tmp/${SMOD_output_log_path}/output.log
    ${memory_usage}=  Grep File  path=${TEST_LOGS_PATH}/PerfShot/logs/tmp/${SMOD_output_log_path}/output.log
    ...  pattern=mem_usage
    ${memory_usage}=  Get Regexp Matches  string=${memory_usage}
    ...  pattern=[0-9]+[.]?[0-9]*
    ${SMOD_identity_grep}=  Grep File  path=${TEST_LOGS_PATH}/PerfShot/logs/tmp/${SMOD_output_log_path}/output.log
    ...  pattern=module serial-number
    ${SMOD_model}=  Remove String Using Regexp  ${SMOD_identity_grep}
    ...  module serial-number.*
    ${SMOD_model}=  Remove String Using Regexp  ${SMOD_model}
    ...  [- ]
    ${SMOD_sn}=  Remove String Using Regexp  ${SMOD_identity_grep}
    ...  .*module serial-number = *
    ${SMOD_sn}=  Remove String Using Regexp  ${SMOD_sn}
    ...  [ ]*[.]*[ ].*
    ${memory_setpoint}=  Get From Dictionary  dictionary=${MAX_MEMORY_CONSUMPTION_DICT}
    ...  key=${SMOD_model}
    Log  Memory usage for ${SMOD_model} ${SMOD_sn} is ${memory_usage[0]}%. Expected <${memory_setpoint}%
    Log
    ...  In case of exceeding memory consumption send PerfShot and aaSysInfo logs to I_MN_FS1TA_RD_SW_DOMAIN_PERF_SUPERVISORS_GMS!
    Should Be True  ${memory_usage[0]}<${memory_setpoint}
  END

Alarm 6502 Should Not Be Present
  [Documentation]
  ...  Checks if alarm for excessive memory consumption is present
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com

  FOR  ${bts_id}  IN  @{cfg.active_bts_list}
    Set Start Timestamp In IMS For CNI-127210
    ${alarm_state_status}=  Run Keyword And Return Status
    ...  admin.Assert Alarm Inactive  faultId=6502, severity=Minor  connection=${bts_id}
    admin.Assert No Unexpected Historical Alarms  connection=${bts_id}
    ${alarm_ims_status}  Run Keyword And Return Status
    ...  Check Active Fault In IMS For CNI-127210  fault_id=6502  severity=Minor
    Run Keyword If
    ...  not ${alarm_state_status} and ${alarm_ims_status}
    ...  Fail
    ...  msg=Fault ID:6502 active! Send PerfShot and aaSysInfo logs to I_MN_FS1TA_RD_SW_DOMAIN_PERF_SUPERVISORS_GMS!
#    admin.Assert No Unexpected Historical Alarms  connection=${bts_id}
  END

Get Files Matching Regexp
  [Documentation]
  ...  Searches for files with names matching regex pattern in given folder on system module
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +--------------+------+--------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +==============+======+==================================================+
  ...  | path  | Yes  | path to folder to be searched through  |
  ...  +--------------+------+--------------------------------------------------+
  ...  | pattern  | Yes  | regex pattern for file names to be searched  |
  ...  +--------------+------+--------------------------------------------------+
  ...  | alias  | Yes  | alias for active ssh connection to SMOD  |
  ...  +--------------+------+--------------------------------------------------+
  ...
  ...  **Return parameters**
  ...
  ...  +---------------------+--------------------------------------------------+
  ...  | Parameter  | Description  |
  ...  +=====================+==================================================+
  ...  | matching_files_list | list containing files with names matching regexp |
  ...  +---------------------+--------------------------------------------------+
  [Arguments]  ${path}  ${pattern}  ${alias}

  ssh.Send Command  command=ls ${path}
  ...  connection=${alias}
  ssh.Assert Exit Status  expected_exit_code=0  connection=${alias}
  ${files_at_path}=  ssh.Read Output  connection=${alias}
  ${files_at_path}=  Split String  ${files_at_path}  \n
  @{matching_files_list}=  Get Matches  list=${files_at_path}
  ...  pattern=regexp=${pattern}

  [Return]  @{matching_files_list}

Add prefix to elemnts of the list
  [Documentation]
  ...  Adds given prefix to each element of the list
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +--------------+------+--------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +==============+======+==================================================+
  ...  | input_list  | Yes  | list to be modified  |
  ...  +--------------+------+--------------------------------------------------+
  ...  | prefix  | Yes  | prefix to be added to each element of the list  |
  ...  +--------------+------+--------------------------------------------------+
  ...
  ...  **Return parameters**
  ...
  ...  +--------------+---------------------------------------------------------+
  ...  | Parameter  | Description  |
  ...  +==============+=========================================================+
  ...  | output_list  | modified list  |
  ...  +--------------+---------------------------------------------------------+
  [Arguments]  ${input_list}  ${prefix}

  @{output_list}=  Create List
  FOR  ${element}  IN  @{input_list}
    Append To List  ${output_list}  ${prefix}${element}
  END

  [Return]  @{output_list}

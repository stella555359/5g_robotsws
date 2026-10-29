*** Settings ***
Documentation    TC__LOGS__Move_Delete_Files_fromVM_to_LogServer
Variables    tc_variables/LOGS__Move_Delete_Files_fromVM_to_LogServer.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${older_than_min}   2400     # Select files/directories older than specified value; Default value 2400 minutes (40 hours)
${Handling_option}  move      # Testcase option on VM; Possible values: move, delete. Default value: move
${Target_trace_dir}  /home/logs1/CRT_logs/TESTLINE_NAME  # Target location for move the traces. E.q. /home/logs1/CRT_logs/RFS_20029_WL02v1
${server_available_space}  100000  # Treshold limit for available space on remote log sever 100000 MB(100 Gb). Default value: 100000


*** Keywords ***
TC__LOGS__Move_Delete_Files_fromVM_to_LogServer
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-6353
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Perform move/delete logs from VM to LogServer
    ...
    ...  The main steps for the test are:
    ...
    ...   - check if variables(older_than_min, Handling_option, Target_trace_dir) are not EMPTY
    ...   - check if logs are present under /home/ute/btsauto/AutoTest older than "older_than_min" variable value
    ...   - check available space from log server (available space > 100GB (100000 MB))
    ...   - move the traces to Log Server (if Handling_option = move and vailable space > 100GB)
    ...   - delete the logs from VM (if Handling_option = delete)
    ...
    ...    Pass criteria:
    ...    - Variables are define as expected;
    ...    - Logs older_than_min are present under AutoTest directory
    ...    - Available space from server > 100 GB.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 12.01.2017 - https://jiradc.ext.net.nokia.com/browse/TAT-6353 - Test delivered
    ...  - 21.09.2017 - https://jiradc.ext.net.nokia.com/browse/TAT-7699 - Update documentation part for some testcases
    ...  - 01.11.2017 - https://jiradc.ext.net.nokia.com/browse/TAT-8204 - Update the precondition for the existing robots of all technologies peer
    ...  - 26.01.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-7841 - Unified test format: Run Cycle, indentation and repeat
    ...  variable REPEAT_COUNTER
    ...  - 19.04.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-9644 - Slight improvement to Basic information label on RFDoc
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...
    ...  - 02.05.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-9859 - [RFS_SOAM] [P4.11] New TC,
    ...  LOGS__Move_Delete_Files_fromVM_to_LogServer.robot
    ...  - 03.08.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-11171 - Prefix all Test Cases inside all robots with [1] to match
    ...  the QC instances names
    ...  - 29.10.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-12890 - [daily_acceptance] RRM, LOGS and PM tests also need variable files
    ...  - 03.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27196 - [5G] Include SCF validation with hardware check in common test setup
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-6353_LOGS__Move_Delete_Files_fromVM_to_LogServer.png


    Set Tags    CA-LOGS    OWNER-oana.bonchis@nokia.com    AUTHOR-ana.tugui@nokia.com    PHASE-QT    SW-WBTS18, BTS18,
    ...    SBTS18    CABLING-RFS_01_UE

    Run Keyword If  '${older_than_min}' != '' and '${Handling_option}' == 'move'
    ...  Run Keywords
    ...  Step 1: Find logs for selected older_than_min variable
    ...  AND  Step 2: Check available space from log server
    ...  AND  Step 3: Move the traces
    ...  ELSE IF  '${older_than_min}' != '' and '${Handling_option}' == 'delete'
    ...  Run Keywords
    ...  Step 1: Find logs for selected older_than_min variable
    ...  AND  Step 2: Delete traces from VM Master
    ...  ELSE  Run Keywords
    ...  Log  older_than_min ${older_than_min}== EMPTY and Handling_option ${Handling_option}!= move or ${Handling_option}!= delete  level=ERROR
    ...  console=True
    ...  AND  Fail  older_than_min ${older_than_min}== EMPTY and Handling_option ${Handling_option}!= move or ${Handling_option}!= delete


Step ${index}: Find logs for selected older_than_min variable
    Log  Step ${index}: Find logs for selected older_than_min variable  console=True
    Set Test Variable  ${Local_trace_dir}  /home/ute/btsauto/AutoTest
    Create local logs directory
    Check local logs directory dimension  ${dir_logs}
    Create local archive  ${dir_logs}
    Check local files number from archive
    Run Keyword If  ${local_dir_logs_dimension} == 4  Run Keywords  OperatingSystem.Run  rm -rf ${dir_logs}/
    ...  AND  OperatingSystem.Run  rm -rf ${Local_trace_dir}/${logs_dir_name}.tar.gz
    ...  AND  Log  No logs present under AutoTest directory older than ${older_than_min} minutes  console=True  level=ERROR
    ...  AND  Fail  No logs present under AutoTest directory older than ${older_than_min} minutes

Step ${index}: Check available space from log server
    Log  Step ${index}: Check available space from log server  console=True
    SSHLibrary.Open Connection  ${FTP_SERVER['ip']}
    SSHLibrary.Login  ${FTP_SERVER['user']}  ${FTP_SERVER['password']}
    ${remote_server_space}=  SSHLibrary.Execute Command  df -P ${FTP_SERVER['download_path']} \| tail -1 \| awk \'\{print $4\}\'
    ${result}=  Get Regexp Matches  '${remote_server_space}'  \\d+
    Log  Available remote_server_space is ${result[0]} MB  console=True
    Set Test Variable  ${server_space}  ${result[0]}
    SSHLibrary.Close Connection

Step ${index}: Move the traces
    [Documentation]
    ...  IF available space from server ${server_space} < ${server_available_space} (100 GB) -> test is FAILED
    ...  and all logs are moved back to /home/ute/btsauto/AutoTest/ and Logs_to_be_${Handling_option}__${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}
    ...  directory is deleted
    ...  IF moved_remote_file == TRUE  and ${local_files_number} == ${remote_files_number} -> delete the local_logs_directory
    ...  ELSE  -> TC Failed - directory not moved

    Log  Step ${index}: Move the traces  console=True
    Run Keyword If  ${server_space} < ${server_available_space}  Run Keywords
    ...  Restore logs to AutoTest
    ...  AND  Log  Available space on remote log sever is less then 100 Gb(available space in mega is: ${server_space});  console=True  level=ERROR
    ...  AND  Fail  Available space on remote log sever is less then 100 Gb(available space in mega is: ${server_space});
    SSHLibrary.Open Connection  ${FTP_SERVER['ip']}
    SSHLibrary.Login  ${FTP_SERVER['user']}  ${FTP_SERVER['password']}
    ${remote_dir_exist}=  Run Keyword And Return Status  SSHLibrary.Directory Should Exist   ${Target_trace_dir}
    ${tl_name}=  Fetch From Right  ${Target_trace_dir}  /
    Run Keyword If  not ${remote_dir_exist}
    ...  Run Keywords  Log  Remote directory ${tl_name} not present on logs1 server; Create the directory  console=True
    ...  AND
    ...  SSHLibrary.Execute Command  mkdir /home/logs1/CRT_logs/${tl_name}
    SSHLibrary.Put File  ${Local_trace_dir}/${logs_dir_name}.tar.gz  ${Target_trace_dir}
    ${moved_remote_file}=  Run Keyword And Return Status  SSHLibrary.File Should Exist  ${Target_trace_dir}/${logs_dir_name}.tar.gz
    Check remote files number from archive
    ${del_local_archive}=  Set Variable  rm -rf ${Local_trace_dir}/${logs_dir_name}.tar.gz
    ${del_local_log_dir}=  Set Variable  rm -rf ${dir_logs}/
    Run Keyword If  ${moved_remote_file} and (${local_files_number} == ${remote_files_number})   Run Keywords
    ...  OperatingSystem.Run  ${del_local_archive}
    ...  AND  OperatingSystem.Run  ${del_local_log_dir}
    ...  AND  Log  Archive ${logs_dir_name}.tar.gz successfully moved to log server  console=True
    ...  ELSE  Run Keywords  Restore logs to AutoTest
    ...  AND  Log  Archive ${logs_dir_name}.tar.gz not moved!  console=True  level=ERROR
    ...  AND  Fail  Archive ${logs_dir_name}.tar.gz not moved!

Step ${index}: Delete traces from VM Master
    [Documentation]
    ...  Delete traces from VM Master older_than_min

    Log   Step ${index}: Delete traces from VM Master  console=True
    Clean up directory  ${dir_logs}  ${older_than_min}
    Log  Clear local created directory ${dir_logs}  console=True
    Restore logs to AutoTest

Create local logs directory
    [Documentation]
    ...  Create a local directory on VM and save logs which are older_than_min value
    ...  /home/ute/btsauto/AutoTest/Logs_to_be_${Handling_option}__${yyyy}-${mm}-${dd}__${hh}-${min}-${ss})

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    Set Test Variable  ${dir_logs}  ${Local_trace_dir}/Logs_to_be_${Handling_option}__${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}
    ${logs_dir_name}=  Catenate  SEPARATOR=  Logs_to_be_  ${Handling_option}  __  ${yyyy}  -   ${mm}  -  ${dd}  __  ${hh}  -  ${min}  -  ${ss}
    Set Test Variable  ${logs_dir_name}
    Run And Return Rc  mkdir ${dir_logs}
    ${mv_command}=  Set Variable  find ${Local_trace_dir}/automated\* -maxdepth 0 -mmin +${older_than_min} -exec mv {} ${dir_logs} \\;
    Run And Return Rc  ${mv_command}

Check local logs directory dimension
    [Arguments]  ${log_directory}
    ${dir_logs_dimension}=  OperatingSystem.Run  du -c ${log_directory} \| grep total \| awk '{print\$1}'
    ${result}=  Get Regexp Matches  '${dir_logs_dimension}'  \\d+
    Set Test Variable  ${local_dir_logs_dimension}  ${result[0]}
    Log  Local directory logs dimension is ${local_dir_logs_dimension} MB  console=True
    ${local_files_number}=  OperatingSystem.Run  ls -lR ${log_directory} | grep \^\- | wc -l
    ${result}=  Get Regexp Matches  '${local_files_number}'  \\d+
    Set Test Variable  ${local_files_number}  ${result[0]}
    Log  Local directory logs contain ${local_files_number} files  console=True

Create local archive
    [Arguments]  ${log_directory}
    ${archive_cmd}=  Set Variable  tar -czvf ${Local_trace_dir}/${logs_dir_name}.tar.gz ${log_directory}
    ${logs_archive}=  OperatingSystem.Run  ${archive_cmd}

Check local files number from archive
    ${archive_files_number}=  OperatingSystem.Run  tar -vtf ${Local_trace_dir}/${logs_dir_name}.tar.gz | grep \^\- | wc -l
    ${result}=  Get Regexp Matches  '${archive_files_number}'  \\d+
    Set Test Variable  ${local_files_number}  ${result[0]}
    Log  Local archive ${logs_dir_name}.tar.gz contain ${local_files_number} files  console=True

Check remote files number from archive
    SSHLibrary.Open Connection  ${FTP_SERVER['ip']}
    SSHLibrary.Login  ${FTP_SERVER['user']}  ${FTP_SERVER['password']}
    ${remote_files_number}=  SSHLibrary.Execute Command  tar -vtf ${Target_trace_dir}/${logs_dir_name}.tar.gz | grep \^\- | wc -l
    ${result}=  Get Regexp Matches  '${remote_files_number}'  \\d+
    Set Test Variable  ${remote_files_number}  ${result[0]}
    Log  Remote archive ${logs_dir_name}.tar.gz contain ${remote_files_number} files  console=True

Restore logs to AutoTest
    Run Keyword If  '${Handling_option}' == 'move'  Run Keywords
    ...  OperatingSystem.Run  mv -v ${dir_logs}/\* ${Local_trace_dir}
    ...  AND  OperatingSystem.Run  rm -rf ${dir_logs}/
    ...  AND  OperatingSystem.Run  rm -rf ${Local_trace_dir}/${logs_dir_name}.tar.gz
    ...  ELSE IF  '${Handling_option}' == 'delete'  Run Keywords
    ...  OperatingSystem.Run  rm -rf ${dir_logs}/
    ...  AND  OperatingSystem.Run  rm -rf ${Local_trace_dir}/${logs_dir_name}.tar.gz


TC Setup
    Common Test Setup    PrecheckConf=${FALSE}    PrecheckCells=${FALSE}    PrecheckModules=${FALSE}    PrecheckSCF=${FALSE}
    ...  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown    Snapshot on failure=NO



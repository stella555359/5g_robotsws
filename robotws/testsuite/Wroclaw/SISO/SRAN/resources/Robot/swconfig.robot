*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    OperatingSystem

Resource    ./tl_init.robot

*** Keywords ***
Put Swconfig File From Remote Host
    [Arguments]  ${swconfig_file_path}  ${remote_host_number}=2  ${ip_addr}=192.168.255.7
    [Documentation]
    ...  Description:
    ...  Keyword puts swconfig.txt file from remote host given by host number (${remote_host_number})
    ...  defined in testline config init file.
    ...  Usage:
    ...  Keyword can be used to put swconfig.txt file to second enb of full rack configuration.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | swconfig_file_path     | Yes  | Path to the swconfig file located on the remote host.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | remote_host_number     | Yes  | Number of remote host.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ip_addr                | Yes  | IP address reachable from the remote host (e.g eNB LMP address).           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${remote_host_parameters}=  Get Host Parameters From Init File  host_index=${remote_host_number}
    ${rc}  ${cmd_result}=  Run and Return RC and Output
    ...  command=scp ${swconfig_file_path} ${remote_host_parameters['ip_addr']}:/home/ute/swconfig.txt
    ${ssh_command}=  Set Variable  sshpass -p oZPS0POrRieRtu scp /home/ute/swconfig.txt toor4nsn@${ip_addr}:/rom/swconfig.txt
    ${rc}  ${cmd_result}=  Run and Return RC and Output
    ...  command=ssh ${remote_host_parameters['ip_addr']} ${ssh_command}

Add Flags To Swconfig File
    [Arguments]  ${swconfig_file}=${SWCONFIG_FILE_PATH}  ${swconfig_flag_list}=@{EMPTY}
    ...  ${log_to_console}=True  ${log_prefix}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword append flags to swconfig file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | swconfig_flag_list     | Yes  | List of flags to add.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | swconfig_file          | Yes  | Path to the swconfig file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${swconfig_flag_list}==@{EMPTY}  Run Keywords
    ...  Log  ${log_prefix}No additional flags have been added to the ENB swconfig.txt file
    ...  console=${log_to_console}
    ...  AND
    ...  Return From Keyword
    FOR  ${swconfig_flag}  IN  @{swconfig_flag_list}
      Append To File  path=${swconfig_file}  content=${swconfig_flag}\n
    END
    Log  ${log_prefix}Additional flags have been added to the ENB swconfig.txt file
    ...  console=${log_to_console}

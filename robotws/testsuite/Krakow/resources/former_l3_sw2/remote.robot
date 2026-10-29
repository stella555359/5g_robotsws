*** Settings ***
Documentation
...            Keywords for low-level operations with remote hosts
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Library    Process
Library    taf.transport.ssh    WITH NAME    ssh

Resource    utilities.robot

*** Keywords ***
Ping using ICMP
    [Documentation]    Pings to specified host once using ICMP Echo and fails on no response.
    ...                - ``host``: Host/IP address to ping to
    ...                - ``desc``: Optional description for the host
    [Arguments]    ${host}    ${desc}=${Empty}
    ${result}    Run Process And Expect Success    ping    -c    1    ${host}
    ...    msg=No connection to ${desc} (${host})

Download File from Remote
    [Documentation]    Downloads remote file to local path using scp.
    ...                - ``remote_path``: Path to existing file in remote host
    ...                - ``local_path``: Path to new file in local host
    ...                - ``hostname``: ssh hostname
    ...                - ``username``: ssh username
    ...                - ``params``: extra parameters for KW ``connect_to``
    ...                Example:
    ...                | Download File from Remote | remote_path=/tmp/file.txt | local_path=/home/ute/file.txt |
    ...                |  | hostname=192.168.255.129 | username=toor4nsn | password=oZPS0POrRieRtu |
    [Arguments]    ${remote_path}    ${local_path}    ${hostname}    ${username}    &{params}
    ssh.connect_to    hostname=${hostname}    username=${username}    alias=temp_download    &{params}
    ssh.download_file    remote_path=${remote_path}    local_path=${local_path}    connection=temp_download
    [Teardown]    ssh.disconnect    connection=temp_download

Upload File to Remote
    [Documentation]    Uploads local file to remote path using scp.
    ...                - ``remote_path``: Path to new file in remote host
    ...                - ``local_path``: Path to existing file in local host
    ...                - ``hostname``: ssh hostname
    ...                - ``username``: ssh username
    ...                - ``params``: extra parameters for KW ``connect_to``
    ...                Example:
    ...                | Upload File to Remote | remote_path=/tmp/file.txt | local_path=/home/ute/file.txt |
    ...                |  | hostname=192.168.255.129 | username=toor4nsn | password=oZPS0POrRieRtu |
    [Arguments]    ${remote_path}    ${local_path}    ${hostname}    ${username}    &{params}
    ssh.connect_to    hostname=${hostname}    username=${username}    alias=temp_upload    &{params}
    ssh.upload_file    remote_path=${remote_path}    local_path=${local_path}    connection=temp_upload
    [Teardown]    ssh.disconnect    connection=temp_upload

Execute Command on Remote
    [Documentation]    Executes shell command on remote host using ssh and fails on unexpected exit code. Returns command output.
    ...                - ``command``: Shell command to execute
    ...                - ``hostname``: ssh hostname
    ...                - ``username``: ssh username
    ...                - ``expected_exit_code``: Expected exit code, Default: 0 (Success)
    ...                - ``params``: extra parameters for KW ``connect_to``
    [Arguments]    ${command}    ${hostname}    ${username}    ${expected_exit_code}=0    &{params}
    ssh.connect_to    hostname=${hostname}    username=${username}    alias=temp_execute    &{params}
    ${output}    ssh.execute    command=${command}    connection=temp_execute
    ssh.assert_exit_status    expected_exit_code=${expected_exit_code}    connection=temp_execute
    ...    msg=Unexpected exit code ({last}) on ssh connection ${username}@${hostname} from command: ${command}\n${output}
    [Teardown]    ssh.disconnect    connection=temp_execute
    [Return]    ${output}

Download File with WGET
    [Documentation]    Downloads a file from specified link using ``wget`` program. Overwrites exisitng file.
    ...                - ``link``: HTTP link to file
    ...                - ``local_path``: Path to new file in local host
    ...                - ``exec``: Set permission to make file executable, Default: no
    ...                - ``params``: Extra wget parameters
    [Arguments]    @{params}    ${link}    ${local_path}    ${exec}=no
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${exec}' in ('yes','no')    msg=Invalid KW parameter: exec
    #---------------------------------------------------------------------------------------------------------------
    Log to Console    Downloading ${link}
    Run Process And Expect Success    wget    -O    ${local_path}    @{params}    ${link}
    OperatingSystem.File Should Exist    ${local_path}
    Run Keyword If    '${exec}' == 'yes'    Run Process And Expect Success    chmod    u+x    ${local_path}

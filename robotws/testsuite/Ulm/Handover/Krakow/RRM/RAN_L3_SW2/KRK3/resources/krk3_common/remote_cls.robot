*** Settings ***
Documentation
...            Keywords for low-level operations with remote hosts on Classical deployment
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Library     DateTime
Resource    remote.robot

*** Keywords ***
Execute Command on GNB
    [Documentation]    Executes shell command on GNB. Returns command output.
    ...                - ``command``: Shell command to execute
    ...                - ``params``: Extra parameters for KW ``Execute Command on Remote`
    [Arguments]    ${command}    &{params}
    ${output}    Execute Command on Remote
    ...    command=${command}
    ...    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...    &{params}
    RETURN    ${output}

Download File from GNB
    [Documentation]    Downloads file located in GNB to local host.
    ...                - ``remote_path``: Path to existing file in GNB
    ...                - ``local_path``: Path to filename to save file as in local host
    [Arguments]    ${remote_path}    ${local_path}
    Download File from Remote
    ...    remote_path=${remote_path}
    ...    local_path=${local_path}
    ...    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}

Upload File to GNB
    [Documentation]    Uploads file located in local host to GNB.
    ...                - ``remote_path``: Path to filename to save file as in GNB
    ...                - ``local_path``: Path to existing file in local host
    [Arguments]    ${remote_path}    ${local_path}
    Upload File to Remote
    ...    remote_path=${remote_path}
    ...    local_path=${local_path}
    ...    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}

Wait Until Next Round Time on GNB
    [Documentation]    Waits until next round time increment on GNB.
    ...                - ``increment``: Increment to round time to in Robot time format, Default: 5m
    ...                - ``delay``: Delay to apply after reaching round time, Default: 0
    [Arguments]    ${increment}=5m    ${delay}=0
    ${current_epoch}    Execute Command on GNB    date +%s
    ${current_epoch}    Convert To Integer    ${current_epoch}
    ${inc_in_sec}    Convert Time    ${increment}
    ${sec_to_wait}    Evaluate    int(${inc_in_sec}) - ${current_epoch} % int(${inc_in_sec})
    ${target_epoch}    Evaluate    ${current_epoch} + ${sec_to_wait}
    ${target_time}    Convert Date    ${target_epoch}    result_format=%H:%M:%S
    Log to console    Waiting until ${target_time} on GNB...
    Sleep    ${sec_to_wait}    Waiting until round time
    Sleep    ${delay}    Delay after round time

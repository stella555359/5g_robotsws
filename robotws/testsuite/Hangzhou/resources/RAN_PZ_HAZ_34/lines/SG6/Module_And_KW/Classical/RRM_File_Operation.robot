*** Settings ***
Documentation
...    author: winnie he
...    contact: winnie.he@nokia-sbell.com
...    file operation

Resource    RRM_Common_Resource.robot



*** Keywords ***
Get TestLine Faults From File
    [Arguments]    ${file_path}
    [Documentation]    This KW is used for Attach UE and verify attach
    ...    Author: He winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | file_path | no | define the log name |
    ...
    ...    | Return Value | Description |
    ...    | ${json_content}| the json content |
    ...
    ...    Example
    ...    | Get TestLine Faults From File | file_path=${file_path} |
    ...
    ${json_content}    get_content_from_yml    ${file_path}
    ${tl_faults}    Create List
    ${param_check}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${json_content}    ALLOWED_FAULTS
    Return From Keyword If    ${param_check}==${False}    ${tl_faults}
    ${faults}    Get Dictionary Values    ${json_content}[ALLOWED_FAULTS]
    FOR    ${fault_id}    IN    @{faults}
        ${fault_info}    Create Dictionary    faultId=${fault_id}
        Append To List    ${tl_faults}    ${fault_info}
    END
    [Return]    ${tl_faults}

Replace String In One File
    [Arguments]    ${file_path}    ${pattern}    ${replace_with}
    [Documentation]    This KW is used for change some info in one file
    ...    Author: He winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | file_path | no | the file need be chage |
    ...    | pattern | no | the pattern(or string) used to find the string |
    ...    | replace_with | no | replace with which string |
    ...
    ...    Example
    ...    | Get TestLine Faults From File | file_path=${file_path} |
    ...
    ${context}    OperatingSystem.Get File    ${file_path}
    ${str}    Replace String Using Regexp    string=${context}    pattern=${pattern}
    ...    replace_with=${replace_with}
    OperatingSystem.Remove File    ${file_path}
    OperatingSystem.Create File    ${file_path}    ${str}

Run Cmd Of File In Remote Server
    [Arguments]    ${host}    ${username}    ${password}    ${file_path}
    [Documentation]    get a file from the operating system, connect to a remote server,
    ...    execute a command, and verify the result.
    ...    Author: He winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | file_path | no | cmd need to be execute |
    ...    | host | no | host ip of remote server |
    ...    | username | no | username of remote server |
    ...    | password | no | password of remote server |
    ...    | Return Value | Description |
    ...    | ${json_content}| the json content |
    ...
    ...    Example
    ...    | Get TestLine Faults From File | file_path=${file_path} |
    Set Library Search Order    OperatingSystem    SSHLibrary
    ${context}    OperatingSystem.Get File    ${file_path}
    csn.connect_to     hostname=${host}
    ...     username=${username}    password=${password}    alias=remote_server_${host}
    ${ret}    csn.execute    command=${context}    connection=remote_server_${host}
    Should Contain    ${ret}    result\="success"
    [Teardown]    ssh.disconnect    connection=remote_server_${host}
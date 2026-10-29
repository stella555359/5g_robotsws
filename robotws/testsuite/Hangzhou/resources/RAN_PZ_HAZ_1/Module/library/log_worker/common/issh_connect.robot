*** Settings ***
Documentation
...    Author: Liu, Renhui
...    Contact: renhui-david.liu@nokia-sbell.com


Library    taf.hw.fhgw.cli    WITH NAME    issh



*** Keywords ***
issh_connector.Send ENTER Interactively
    [Arguments]  ${connection}=default
    [Documentation]    This kw is used to send ENTER key within current active ssh connection.
    ...
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | connection | yes |  |
    ...
    ...    | Return Value | Description |
    ...    | vdu_info | a dict |
    ...
    ...    Example
    ...   | product_config.Get vDU Http Connection Info |
    ...
    ${enter}    Evaluate    chr(int(13))
    ${output}   issh.Execute_Bare   command=${enter}     alias=${connection}
    Sleep    1.3s
    [Return]  ${output}

issh_connector.Send CTRL_C Interactively
    [Arguments]  ${connection}=default
    [Documentation]    This kw is used to send CTRL+C to interrupt current running command
    ...    within current active ssh connection. It should be used via issh library.
    ...
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | connection | yes |  |
    ...
    ...    | Return Value | Description |
    ...    | vdu_info | a dict |
    ...
    ...    Example
    ...   | product_config.Get vDU Http Connection Info |
    ...
    ${crtl_c}    Evaluate    chr(int(3))
    ${output}   issh.Execute_Bare   command=${crtl_c}     alias=${connection}
    Sleep    3s
    [Return]  ${output}

issh_connector.Connect To CloudRan Host
    [Arguments]    ${connection}
    ...            ${product_type}=vdu
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    [Documentation]
    ...    This kw is used to connect to the DU or CU host.
    ...
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | bts_index | yes |  |
    ...    | vdu_index | yes |  |
    ...
    ...    Example
    ...   | issh_connector.Connect To DU |
    ...
    ${connection_params}=    product_config.Get BTS SSH Connection Info    product_type=${product_type}
    ...    bts_index=${bts_index}    cudu_index=${cudu_index}
    ${prompt}    set variable
    ...    \\[cloudadmin@\\S+\\s\\S+\\]\\$|\\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt}    set variable    ${prompt}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt}    set variable    ${prompt}|\\[core@\\S+\\s\\S+\\]\\$
    ${prompt}    set variable    ${prompt}|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$
    issh.Connect_To    ip=${connection_params["hostname"]}    username=${connection_params["username"]}
    ...    password=${connection_params["password"]}
    ...    prompt=${prompt}
    ...    alias=${connection}
    ...    width=200
    ...    timeout=150

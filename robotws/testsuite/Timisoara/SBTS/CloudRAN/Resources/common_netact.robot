*** Settings ***

Documentation    Description:  Cloud Library with commonly used keywords

Library         taf.nms.netact
Library         SSHLibrary

Variables    netacts.yaml

*** Keywords ***
Setup NMS
    [Documentation]  Description:           Setup NetAct Flat. Check netacts.yaml for available NA${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     15-03-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${Netact_flat}

    Set Suite Variable  ${Netact_flat}  ${Netact_flat}

Get and Set NMS Parameters
    [Documentation]  Description:           x ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     15-03-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]

    Get Appropriate Pass And Node Ip By Name
    Log    > NetAct password: ${na_pass}    console=True
    Log    > Using FLAT SOAM    console=True
    Get And Set Specific NetAct Parameters    ${na_pass}    ${na_node_ip}

Get Appropriate Pass And Node Ip By Name
    [Documentation]  Description:           Returns apropriate na_pass and na_node for given NetAct name ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     15-03-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]

    ${status_Netact_flat}     run keyword and return status  Variable Should Exist    ${Netact_flat}
    ${choosen_netact_dictionary}=       Get Netact By Name     ${Netact_flat}
    ${na_pass}=    Get From Dictionary    ${choosen_netact_dictionary}    password
    ${na_node_ip}=    Get From Dictionary    ${choosen_netact_dictionary}    node_ip
    ${netact_name}=    Get From Dictionary    ${choosen_netact_dictionary}    netact_name
    ${na_root_login}=    Get From Dictionary    ${choosen_netact_dictionary}    na_root_login
    ${na_root_password}=    Get From Dictionary    ${choosen_netact_dictionary}    na_root_password
    ${CLS_API_HOST_EXIST}=    Run keyword and return status    Get From Dictionary
    ...    ${choosen_netact_dictionary}    CLS_API_HOST
    ${CLS_DATABASE_HOST_EXIST}=    Run keyword and return status   Get From Dictionary
    ...    ${choosen_netact_dictionary}    CLS_DATABASE_HOST
    ${CLS_API_HOST}    Run keyword if    '${CLS_API_HOST_EXIST}'=='True'    Get From Dictionary
    ...    ${choosen_netact_dictionary}    CLS_API_HOST
    ${CLS_DATABASE_HOST}    Run keyword if    '${CLS_DATABASE_HOST_EXIST}'=='True'   Get From Dictionary
    ...    ${choosen_netact_dictionary}    CLS_DATABASE_HOST
    ${web_gui_username_exist}=    Run keyword and return status    Get From Dictionary
    ...    ${choosen_netact_dictionary}    web_gui_username
    ${web_gui_password_exist}=    Run keyword and return status   Get From Dictionary
    ...    ${choosen_netact_dictionary}    web_gui_password
    ${web_gui_username}    Run keyword if    '${web_gui_username_exist}'=='True'    Get From Dictionary
    ...    ${choosen_netact_dictionary}    web_gui_username
    ${web_gui_password}    Run keyword if    '${web_gui_password_exist}'=='True'   Get From Dictionary
    ...    ${choosen_netact_dictionary}    web_gui_password
    ${regex}=    Get Regexp Matches    ${netact_name}    srn
    ${status}=    Run keyword and return status    Should not be empty    ${regex}
    Run keyword if    ${status}      Set Suite Variable    ${WEB_URL}    https://${netact_name}lbwas.srnblr.nsn-rdnet.net
    ...   ELSE    Set Suite Variable    ${WEB_URL}    https://${netact_name}lbwas.netact.nsn-rdnet.net
    Set Suite Variable    ${WEB_URL}
    Set Suite Variable    ${netact_name}
    Set Suite Variable    ${na_pass}
    Set Suite Variable    ${na_node_ip}
    Set Suite Variable    ${na_root_login}
    Set Suite Variable    ${na_root_password}
    Run keyword if    '${CLS_API_HOST_EXIST}'=='True'    Set Suite Variable    ${CLS_API_HOST}
    Run keyword if    '${CLS_DATABASE_HOST_EXIST}'=='True'   Set Suite Variable    ${CLS_DATABASE_HOST}
    Run keyword if    '${web_gui_username_exist}'=='True'    Set Suite Variable    ${web_gui_username}
    Run keyword if    '${web_gui_password_exist}'=='True'    Set Suite Variable    ${web_gui_password}

Get Netact By Name
    [Documentation]  Description:           Returns NetAct information from netact.yaml file ${\n}
    ...              Return:                NetAct Dictionary from netact.yaml ${\n}
    ...              Output:                &{netact_dict} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     15-03-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${Netact_flat}

    : FOR    ${single_netact}    IN    @{NetAct}
    \    &{netact_dict}=  Set Variable If  '${single_netact["netact_name"]}' == '${Netact_flat}'  ${single_netact}
    END
    [Return]  &{netact_dict}

NMS Node and Web Setup
    [Documentation]  Description:           Setup NetAct and CLS nodes if True ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     15-03-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]    ${setup_cls}=False

    Add web url  ${WEB_URL}  ${NA_USER}  ${NA_PASS}
    Add Node    cmwas  ${NA_WAS}  ${NA_USER}  ${NA_PASS}
    Run keyword if    ${setup_cls}  Run Keywords  Add Node  cls-services  ${CLS_API_HOST}  ${na_root_login}  ${na_root_password}  AND
    ...    Add Node  cls-db  ${CLS_DATABASE_HOST}  ${na_root_login}  ${na_root_password}

NMS Node and Web Teardown
    [Documentation]  Description:           Teardown NetAct and CLS nodes ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     15-03-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]

    Delete Node  cls-db
    Delete Node  cls-services
    Delete Node  cmwas
    Clean All

Get And Set Specific NetAct Parameters
    [Documentation]  Description:           Teardown NetAct and CLS nodes ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     15-03-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${na_pass}    ${na_node_ip}

    ${node_number}=    Get Node Number    ${na_node_ip}
    Log    > NetAct name: ${netact_name}    console=True
    Log    > NetAct node ${node_number} IP address: ${na_node_ip}    console=True
    ${status}=    Run Keyword And Return Status    Get And Set NA Services IP
    Run Keyword Unless    ${status}    Wait Until Keyword Succeeds    5x    1min    Legacy Get And Set NA Service IP    ${na_node_ip}
    Set Suite Variable    ${NA_USER}    omc

Get Node Number
    [Documentation]  Description:           Teardown NetAct and CLS nodes ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     15-03-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]    ${node_ip}

    Open SSH Connection  ${node_ip}  omc  ${na_pass}
    ${ssh_output}=  SSH Execute Command  hostname
    ${node_number_regex}=  Get Regexp Matches  ${ssh_output}  [0-9]+   #regex
    ${node_number}=  Convert To Integer  ${node_number_regex[-1]}    #parse int
    Close SSH Connection
    [Return]  ${node_number}

Open SSH Connection
    [Documentation]  Description:           Open SSH connection and log in ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     15-03-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${ip_addr}  ${username}  ${password}

    SSHLibrary.Open Connection  ${ip_addr}
    SSHLibrary.Login  ${username}  ${password}

Close SSH Connection
    [Documentation]  Description:           Close SSH connection ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     15-03-2024 made by szymon.romanowski@nokia.com ${\n}

    SSHLibrary.Close Connection

SSH Execute Command
    [Documentation]  Description:           Execute ssh command and return output ${\n}
    ...              Return:                Ssh command output ${\n}
    ...              Output:                ${output} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     15-03-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${command}

    ${output}=  SSHLibrary.Execute Command  ${command}
    [Return]  ${output}

Get And Set NA Services IP
    [Documentation]  Description:           Login to NA node and set services ip ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     15-03-2024 made by szymon.romanowski@nokia.com ${\n}

    Open SSH Connection    ${na_node_ip}    ${na_root_login}    ${na_root_password}
    ${ip_db_node}=    Get NA Service IP    db    ${na_node_ip}
    ${ip_was_node}=    Get NA Service IP    was    ${na_node_ip}
    ${ip_fm_pipe_node}=    Get NA Service IP    fm_pipe    ${na_node_ip}
    Set Suite Variable    ${NA_DB}    ${ip_db_node}
    Set Suite Variable    ${NA_WAS}    ${ip_was_node}
    Set Suite Variable    ${NA_FM_PIPE}    ${ip_fm_pipe_node}

Get NA Service IP
    [Documentation]  Description:           Returns ip of node with required service ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     15-03-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]    ${service}    ${na_node_ip}

    Log    Getting IP address of ${service.upper()} node:    console=True
    Open SSH Connection     ${na_node_ip}    ${na_root_login}  ${na_root_password}
    ${host_output}=    SSH Execute Command    smanager.pl status service ${service} | head -1 | cut -d ':' -f2 | xargs host
    ${regex_matches}=    Get Regexp Matches    ${host_output}    [0-9]+.[0-9]+.[0-9]+.[0-9]+\n
    ${ip_address_match}=    Split String    ${regex_matches[0]}    \n
    ${ip_address}=    Get From List     ${ip_address_match}    0
    ${node_number}=    Get Node Number    ${ip_address}
    Log    > NetAct ${service.upper()} node ${node_number} IP address: ${ip_address}    console=True
    [Return]    ${ip_address}

SWEM Reports Generation
    [Documentation]  Description:           This keyword generates SWEM reports based on specific module. ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     15-03-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]    @{modules_list}

    : FOR  ${swem_module}  IN  @{modules_list}
    \    ${module}=    get_modules    moduleName=${swem_module}
    \    ${status}=    Generate Reports    ${module[0]}

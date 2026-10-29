*** Settings ***
Documentation
...    Author:          Bartlomiej Lebda | Jakub Klein
...    Maintainer:      Bartlomiej Lebda | Jakub Klein
...    Contact:         bartlomiej.lebda@nokia.com jakub.klein@nokia.com
...    Team in charge:  I_EXT_PZ_1_WRO_6_GMS
...    Description:     The following keywords are responsible for perform basic RUs operations

Library     taf.transport.ssh          WITH NAME    ssh
Resource    ../Component_states/BasicKeywords.robot
Resource    SMOD_operation.robot
Resource    ../Connections/Connectivity_keywords.robot
Resource    ../Admin_CLI/Basic_WebEM_operation.robot

*** Variables ***
${read RU faults}    cd ../../ram ; cat fault_history_log.txt

*** Keywords ***

Check if fault is active on RU in History log
    [Documentation]
    ...     -----------------------------------------------------------------------------------------
    ...     Checking if the indicated fault is visible as active in fault_history_log.txt on the indicated RU.
    ...     As arguments it takes:
    ...                            - fault_name - Fault name in string format
    ...                            - ru_id - RU ID from info_model view(object _L). By default is '1'
    ...                            - ru_login - by default is 'root'
    ...                            - ru_password - by default is 'umniedziala'
    ...                            - smod_connection - by default alias is 'asik'
    ...                            - connection - by default alias is 'default'
    ...     -----------------------------------------------------------------------------------------
    [Arguments]  ${fault}    ${ru_id}=1    ${ru_login}=root    ${ru_password}=umniedziala
    ...          ${smod_connection}=asik    ${connection}=default
    Connect to RU via address from info model    ${ru_id}   ${ru_login}   ${ru_password}    ${smod_connection}
    ...                                          ru    ${connection}
    ${terminal}    ssh.Execute            ${read RU faults}    connection=ru
    ${active}      Fetch From Left        string=${terminal}   marker=InActive faults:
    Log to console      ${active}
    Should contain      ${active}    ${fault}
    [Teardown]  run_keywords    Disconnect from RU  AND
    ...                         Disconnect Ssh From Asix    ${smod_connection}

Check if fault is not active on RU in History log
    [Documentation]
    ...     -----------------------------------------------------------------------------------------
    ...     Checking if the indicated fault is not visible in fault_history_log.txt on the indicated RU.
    ...     As arguments it takes:
    ...                            - fault_name - Fault name in string format
    ...                            - ru_id - RU ID from info_model view(object _L). By default is '1'
    ...                            - ru_login - by default is 'root'
    ...                            - ru_password - by default is 'umniedziala'
    ...                            - smod_connection - by default alias is 'asik'
    ...                            - connection - by default alias is 'default'
    ...     -----------------------------------------------------------------------------------------
    [Arguments]  ${fault}    ${ru_id}=1    ${ru_login}=root    ${ru_password}=umniedziala
    ...          ${smod_connection}=asik    ${connection}=default
    Connect to RU via address from info model    ${ru_id}   ${ru_login}   ${ru_password}    ${smod_connection}
    ...                                          ru    ${connection}
    ${terminal}=    ssh.Execute      ${read RU faults}   connection=ru
    ${active}=    Fetch From Left    string=${terminal}   marker=InActive faults:
    Log to console      ${active}
    Should not contain  ${active}    ${fault}
    [Teardown]  run_keywords    Disconnect from RU  AND
    ...                         Disconnect Ssh From Asix    ${smod_connection}

Check if fault is visible as inactive on RU in History log
    [Documentation]
    ...     -----------------------------------------------------------------------------------------
    ...     Checking if the indicated fault is visible as inactive in fault_history_log.txt on the indicated RU.
    ...     As arguments it takes:
    ...                            - fault_name - Fault name in string format
    ...                            - ru_id - RU ID from info_model view(object _L). By default is '1'
    ...                            - ru_login - by default is 'root'
    ...                            - ru_password - by default is 'umniedziala'
    ...                            - smod_connection - by default alias is 'asik'
    ...                            - connection - by default alias is 'default'
    ...     -----------------------------------------------------------------------------------------
    [Arguments]  ${fault}    ${ru_id}=1    ${ru_login}=root    ${ru_password}=umniedziala
    ...          ${smod_connection}=asik    ${connection}=default
    Connect to RU via address from info model    ${ru_id}   ${ru_login}   ${ru_password}    ${smod_connection}
    ...                                          ru    ${connection}
    ${terminal}=    ssh.Execute      ${read RU faults}   connection=ru
    ${active}=    evaluate  $terminal[$terminal.find("InActive faults"):$terminal.find("Fault events")]
    Log to console      ${active}
    Should contain      ${active}    ${fault}
    [Teardown]  run_keywords    Disconnect from RU  AND
    ...                         Disconnect Ssh From Asix    ${smod_connection}

Reset Radio Unit from SSH
    [Documentation]
    ...     -----------------------------------------------------------------------------------------
    ...     Sending a reboot signal to the indicated RMOD.
    ...     As arguments it takes:
    ...                            - ru_id - RU ID from info_model view(object _L). By default is '1'
    ...                            - ru_login - by default is 'root'
    ...                            - ru_password - by default is 'umniedziala'
    ...                            - smod_connection - by default alias is 'asik'
    ...                            - connection - by default alias is 'default'
    ...     -----------------------------------------------------------------------------------------
    [Arguments]    ${ru_id}=1    ${ru_login}=root    ${ru_password}=umniedziala    ${smod_connection}=asik
    ...            ${connection}=default
    Connect to RU via address from info model    ${ru_id}   ${ru_login}   ${ru_password}    ${smod_connection}
    ...                                          ru    ${connection}
    ssh.execute     rfsw-reboot    connection=ru
    [Teardown]  run_keywords    Disconnect from RU  AND
    ...                         Disconnect Ssh From Asix    ${smod_connection}




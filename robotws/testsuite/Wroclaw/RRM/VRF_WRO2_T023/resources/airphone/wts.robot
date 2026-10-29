*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Palina Krasnova
...              :contact: palina.krasnova@nokia.com
...              This resources contains keywords related to wts environment configuration

Library    Process
Library    ta5g_egate


*** Variables ***
${WTS_DIR}=    /opt/iphy/latest


*** Keywords ***
Setup Edaemon And Egate
    [Documentation]
    ...    Setups and starts Edaemon and Egate processes
    ...
    ...    | **Author:** palina.krasnova@nokia.com

    [Arguments]    ${edaemon_port}
    Setup Edaemon    edaemon_port=${edaemon_port}    tool_dir=${WTS_DIR}    alias=edaemon_dl
    Start Edaemon Process    alias=edaemon_dl
    Setup Edaemon    edaemon_port=30000    tool_dir=${WTS_DIR}    alias=edaemon_ul
    Start Edaemon Process    alias=edaemon_ul
    Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}
    Start Egate Process

Stop Edaemon And Egate Processes
    [Documentation]
    ...    Stops Edaemon and Egate processes, if they exist
    ...
    ...    | **Author:** palina.krasnova@nokia.com

    ${pid}=    Run    pgrep edaemon
    Run Keyword If    '${pid}'!='${EMPTY}'    Run    sudo kill -9 ${pid}
    ${pid}=    Run    pgrep egate
    Run Keyword If    '${pid}'!='${EMPTY}'    Run    sudo kill -9 ${pid}

Wait For Wts Is Ready To Use
    [Documentation]
    ...    Waits for WTS is ready to use - SimMode is ready; there are SIB1 for all configured cells
    ...
    ...    | **Author:** palina.krasnova@nokia.com
    ...
    ...    **Input Parameters:**
    ...
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | Parameter              | Man.  | Description                                                          |
    ...    +========================+======+=======================================================================+
    ...    | lua_cfg                | Yes   | Link to lua_cfgwith entry point specified (lua script).              |
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | cell_list              | Yes   | List of cells to be onAir after WTS configuration and activation.    |
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | sib1_timeout           | No    | Waiting time for Sib1 reception.                                     |
    ...    |                        |       | Default value: 600s.                                                 |
    ...    +------------------------+------+-----------------------------------------------------------------------+

    [Arguments]    ${lua_cfg}    ${cell_list}    ${sib1_timeout}=600
    Execute Egate Command And Wait For Data    cfg_sim file\=${lua_cfg} entry\=run_configuration()
    ...                                        pass_regexp=(SimMode is ready now|UEC-1 is active)
    ...                                        timeout=300
    Wait For Sib1 Reception    timeout=${sib1_timeout}    cell_list=${cell_list}
    Wait Until Keyword Succeeds    120sec    15sec
    ...                            Execute Egate Command    state_sim_disp    pass_regexp=The state is ACTIVE

Setup X2 Connection
    [Documentation]
    ...    Established X2 link
    ...
    ...    | **Author:** palina.krasnova@nokia.com

    ${pattern}=    Set Variable    ENB-1: X2AP Link with GNB-2 .* is up
    ${output}=    Execute Egate Command And Wait For Data    enb_x2_link_up enb\=1 target\=2
    ...           pass_regexp=${pattern}    timeout=60
    ${output}=    Get Lines Matching Regexp    string=${output}    pattern=${pattern}    partial_match=${True}
    Log To Console    \n${output}
    Log    x2_established

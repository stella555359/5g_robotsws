*** Settings ***
Documentation   Suite description

# Library         OperatingSystem
# Library         Process
Library         Collections
# Library         DateTime
Library         String
Library         taf.transport.ssh                           WITH NAME   ssh

Library         ${CURDIR}/py/FestoClient.py      WITH NAME    vert_axis
Library         ${CURDIR}/py/FestoClient.py      WITH NAME    rota_axis


*** Keywords ***
Festo Automatons Setup
    [Documentation]     loads of festo automaton device (vertical axis and rotatif)
    ...            Run forward server on Ue PC and load loads of festo automaton device (vertical axis and rotatif)
    [Arguments]    ${festo_debug}=False


    # Load configuration
    vert_axis.load_config
    ...    config_fn=vertical_axis.yaml
    ...    debug=${festo_Debug}

    rota_axis.load_config
    ...    config_fn=rotation_axis.yaml
    ...    debug=${festo_Debug}

    # Prepar and Run Servers Redirection
    ${PC_IP}      vert_axis.get_festo_PC_IP
    ${PC_USR}     vert_axis.get_festo_PC_user
    ${PC_PWD}     vert_axis.get_festo_PC_pswd
    log    ${PC_IP} ${PC_USR} ${PC_PWD}

    wait until keyword succeeds    3 min     10 sec     ssh.connect to
    ...     ${PC_IP}    ${PC_USR}    ${PC_PWD}      alias=festoPcCnx

    # Start port Redirect for vertical ans rotation axis:
    ${V_PORT}     vert_axis.get_server_port
    ${VR_PORT}    vert_axis.get_festo_PC_Port
    ${V_HOST}     vert_axis.get_server_host
    ${R_PORT}     rota_axis.get_server_port
    ${RR_PORT}    rota_axis.get_festo_PC_Port
    ${R_HOST}     rota_axis.get_server_host
    Start Port Redirect    ${V_PORT}    ${V_HOST}    ${VR_PORT}
    Start Port Redirect    ${R_PORT}    ${R_HOST}    ${RR_PORT}

    # Start Homing
    log    **************** Start Vertical and Rotatif homing ****************
    vert_axis.start_homing
    rota_axis.start_homing

Festo Teardown
    [Documentation]
    # Stop Port Redirect
    Stop Port Redirect    connection=festoPcCnx
    Run Keyword and Ignore Error    ssh.disconnect    festoPcCnx

Start Port Redirect
    [Documentation]
    [Arguments]       ${port_forward}    ${festo_host}     ${festo_port}   ${connection}=festoPcCnx
    ${cmd}=    catenate    SEPARATOR=     cygstart --action=runas netsh interface portproxy add v4tov4 listenport=${port_forward} connectport=
    ...                                  ${festo_port} connectaddress=${festo_host} protocol=tcp
    ${result}=    ssh.execute     command=${cmd}    connection=${connection}
    log    ${result}

    # Check if port forward is runing
    ${cmd}=    catenate    SEPARATOR=     netsh interface portproxy show all |grep ${festo_port}
    ...                                   |grep ${festo_host}|grep ${festo_port}
    ${result}=    ssh.execute     command=${cmd}    connection=${connection}
    Should Not Be Empty    ${result}

Stop Port Redirect
    [Documentation]
    [Arguments]       ${connection}=festoPcCnx

    # Reset alls port redirect
    ${cmd}    Set variable     cygstart --action=runas netsh interface portproxy reset
    ${result}=    ssh.execute     command=${cmd}    connection=festoPcCnx
    log    ${result}

Festo Move To Postion
    [Documentation]     Move to position vert_xx and rota_xx
    [Arguments]    ${vert_pos}    ${rota_pos}
    log    Move to vert: ${vert_pos}mm and rota: ${rota_pos}°

    ${err}    ${vposition}    vert_axis.move_to_Position
    ...            setpoint_pos=${vert_pos}
    ${match}    ${value}    Run Keyword And Ignore Error    Should Contain     ${err}     warning
    Run Keyword If    '${match}' != 'PASS' and '${ERR}' != '${EMPTY}'
    ...    Fail     ${ERR}

    ${err}    ${rposition}    rota_axis.move_to_Position
    ...            setpoint_pos=${rota_pos}
    ${match}    ${value}    Run Keyword And Ignore Error    Should Contain     ${err}     warning
    Run Keyword If    '${match}' != 'PASS' and '${ERR}' != '${EMPTY}'
    ...    Fail     ${ERR}

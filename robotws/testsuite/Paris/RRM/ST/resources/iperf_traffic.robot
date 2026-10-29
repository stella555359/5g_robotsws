*** Variables ***
#dl alias
${iperfCore_cnx}                     iperf_core_cnx
#ul_alias
${iperfUe_cnx}                       iperf_ue_cnx


*** Keywords ***
Start Traffic
    [Documentation]  Launch traffic with iperf command (UDP).
    ...              This keyword take as argument:
    ...              . ${distantip}
    ...              . ${tput} by default 100M     DL Tput
    ...              . ${duration} by default 10   duration of traffic
    ...              . ${ueid} by default 0        number to compute used port
    ...               The DLserver is : iperf CORE side
    ...               The ULServer is : iperf UE Side
    ...        Author:  Annie Wong
    [Arguments]        ${direction}      ${distantip}     ${tput}=100M     ${duration}=10     ${ueid}=0

    ${server_ip}=      run keyword if      '${direction}' == 'DL'     set variable     ${DLserver_ip}
    ...                       ELSE IF      '${direction}' == 'UL'     set variable     ${ULserver_ip}
    ...                       ELSE          fail   msg=unexpected traffic direction=${direction}

    ${server_login}=    run keyword if      '${direction}' == 'DL'     set variable     ${DLserver_login}
    ...                           ELSE       set variable      ${ULserver_login}

    ${server_pwd}=      run keyword if      '${direction}' == 'DL'     set variable     ${DLserver_pwd}
    ...                           ELSE       set variable      ${ULserver_pwd}

    ${alias_cnx_send}=       run keyword if      '${direction}' == 'DL'     set variable     ${iperfCore_cnx}
    ...                              ELSE         set variable     ${iperfUe_cnx}

    ${alias_cnx_recv}=       run keyword if      '${direction}' == 'DL'     set variable     ${iperfUe_cnx}
    ...                              ELSE         set variable     ${iperfCore_cnx}

    ${port}             Get traffic port      ${direction}     ${ueid}
    ssh.Connect To      ${server_ip}        ${server_login}      ${server_pwd}      alias=${alias_cnx_send}

    #Launch iPerf receiver case UL (iperf -s)
    run keyword if      '${direction}' == 'UL'
    ...      ssh.Connect To      ${DLserver_ip}        ${DLserver_login}     ${DLserver_pwd}     alias=${alias_cnx_recv}
    run keyword if      '${direction}' == 'UL'
    ...       log                 iPerf send command = iperf -p ${port} -s -u -i2
    run keyword if      '${direction}' == 'UL'
    ...      ssh.send command      iperf -p ${port} -s -u -i2        connection=${alias_cnx_recv}
    run keyword if      '${direction}' == 'UL'
    ...      ssh.disconnect      ${alias_cnx_recv}

    #Launch iPerf on client sender (iperf -c)
    ${send_cmd}=        run keyword if      '${direction}' == 'DL'
    ...                 set variable      iperf -p ${port} -c ${distantip} -u -i 1 -l 1350 -b ${tput} -t ${duration}
    ...    ELSE         set variable      iperf -p ${port} -c ${distantip} -u -i 1 -l 1350 -b ${tput} -t ${duration}
    log                 iPerf send command = ${send_cmd}
    ssh.send command    ${send_cmd}        connection=${alias_cnx_send}
    ssh.disconnect      ${alias_cnx_send}


Get traffic port
    [Documentation]  Retrieve iperf port from UEid.
    ...              and values that should contain.
    ...              Author: Denis
    ...                      Sandrine Faujour:  change port
    ...                      Annie Wong : distinguish port case UL and case DL
    [Arguments]      ${direction}    ${ueid}=0
    #${port}       Evaluate         34000 + ${ueid}
    ${index}=     Run keyword if      '${direction}' == 'UL'       set variable    2
    ...                                               ELSE         set variable    1
    ${port}          Evaluate         34000 + ${ueid} + ${index}
    Log           ${port}
    #Run Keyword If   ${direction}=='DL'    ${port}       Evaluate         4200 + ${ueid}
    #...              ELSE                  ${port}       Evaluate         5100 + ${ueid}
    Return from Keyword           ${port}


Stop traffic
    [Documentation]  Stop traffic by killing Iperf process on port numbered based on ueid.
    ...              This keyword take as argument:
    ...            . ${ueid} by default 0
    ...              Author: Annie Wong
    [Arguments]       ${direction}     ${ueid}=0

    ${server_ip}=      run keyword if      '${direction}' == 'DL'     set variable     ${DLserver_ip}
    ...                       ELSE IF      '${direction}' == 'UL'     set variable     ${ULserver_ip}
    ...                        ELSE         fail       msg=unexpected traffic direction=${direction}
    ${server_login}=    run keyword if     '${direction}' == 'DL'     set variable     ${DLserver_login}
    ...                        ELSE         set variable      ${ULserver_login}
    ${server_pwd}=      run keyword if      '${direction}' == 'DL'     set variable     ${DLserver_pwd}
    ...                        ELSE         set variable      ${ULserver_pwd}
    ${alias_cnx_send}=       run keyword if      '${direction}' == 'DL'     set variable     ${iperfCore_cnx}
    ...                        ELSE         set variable        ${iperfUe_cnx}

    ${port}             Get traffic port      ${direction}     ${ueid}
    ssh.Connect To      ${server_ip}        ${server_login}      ${server_pwd}      alias=${alias_cnx_send}

    # command to retrieve directly pid from combination iperf and port. and kill signal of process
    ${pid}         ssh.execute    pgrep -f 'iperf -p ${port}'       connection=${alias_cnx_send}
    ${pid}         Strip String    ${pid}      characters=\\r\\n\\0xA0\\0xD0
    Log            ${pid}
    ssh.execute        kill -9 ${pid}     connection=${alias_cnx_send}
    ssh.disconnect     ${alias_cnx_send}


Check Applicative Tput
    [Documentation]  Launch iperf -s command (UDP)
    ...              This keyword take as argument:
    ...                    . ${direction}  UL or DL
    ...                    . ${condition}
    ...                    . ${ueid} by default 0, number to compute used port for mobile
    ...              Issue when 2 iperf on sam eport is launched !!!
    ...              Author: Annie Wong
    [Arguments]          ${direction}           ${condition}           ${ueid}=0

    ${server_ip}=        run keyword if      '${direction}' == 'DL'     set variable     ${ULserver_ip}
    ...    ELSE IF       '${direction}' == 'UL'     set variable      ${DLserver_ip}
    ...    ELSE           fail           msg=unexpected traffic direction=${direction}

    ${server_login}=      run keyword if      '${direction}' == 'DL'     set variable     ${ULserver_login}
    ...    ELSE           set variable        ${DLserver_login}

    ${server_pwd}=        run keyword if      '${direction}' == 'DL'     set variable     ${ULserver_pwd}
    ...    ELSE           set variable        ${DLserver_pwd}

    ${alias_cnx_recv}=         run keyword if      '${direction}' == 'DL'     set variable     ${iperfUe_cnx}
    ...    ELSE           set variable        ${iperfCore_cnx}

    ${port}             Get traffic port      ${direction}     ${ueid}
    ssh.Connect To      ${server_ip}      ${server_login}      ${server_pwd}      alias=${alias_cnx_recv}

    ${resp}       ssh.execute         iperf -p ${port} -s -u -i 1 -t 10       connection=${alias_cnx_recv}
    Log           ${resp}
    ${t}          Get Regexp Matches		${resp}   \\s(\\d*.\\d*) Mbits  1
    run keyword and continue on failure     should not be empty   ${t}      msg=No Mbits Info Found
    : FOR   ${rate}    IN    @{t}
    \       ${check}   Convert To Number    ${rate}
    \       Should be True       ${check}${condition}
    ssh.disconnect      ${alias_cnx_recv}


Stop UL receiver
    [Documentation]  Stop UL receiver by killing Iperf process on port numbered based on ueid.
    ...              This keyword take as argument:
    ...                    . ${ueid} by default 0, number to compute port
    ...              Author: Sandrine
    ...                      Annie Wong
    [Arguments]         ${ueid}=0

    ${port}             Get traffic port        UL       ${ueid}
    ssh.Connect To		${DLserver_ip}		${DLserver_login}		${DLserver_pwd}		alias=${iperfCore_cnx}
    ${pid}              ssh.execute    pgrep -f 'iperf -p ${port}'       connection=${iperfCore_cnx}
    Log                 ${pid}
    ${pid}              Replace String  ${pid}     \r\n        ${SPACE}
    Log                 ${pid}
    ssh.execute        kill -9 ${pid}  connection=${iperfCore_cnx}
    ssh.disconnect     ${iperfCore_cnx}


Stop iPerf Receiver Pid
    [Documentation]  Stop iperf receiver by killing Iperf process on port numbered based on ueid.
    ...              This keyword replaces "Stop UL receiver", take as arguments:
    ...                    ${ueid} and ${traffic_direction}
    ...              Author: Annie Wong
    [Arguments]         ${traffic_direction}       ${ueid}=0
    ${server_ip}=        run keyword if      '${traffic_direction}' == 'DL'     set variable     ${ULserver_ip}
    ...    ELSE IF       '${traffic_direction}' == 'UL'     set variable      ${DLserver_ip}
    ...    ELSE           fail           msg=unexpected traffic traffic_direction=${traffic_direction}

    ${server_login}=      run keyword if      '${traffic_direction}' == 'DL'     set variable     ${ULserver_login}
    ...    ELSE           set variable        ${DLserver_login}

    ${server_pwd}=        run keyword if      '${traffic_direction}' == 'DL'     set variable     ${ULserver_pwd}
    ...    ELSE           set variable        ${DLserver_pwd}

    ${alias_cnx_recv}=         run keyword if      '${traffic_direction}' == 'DL'     set variable     ${iperfUe_cnx}
    ...    ELSE           set variable        ${iperfCore_cnx}

    ${port}             Get traffic port        UL       ${ueid}
    ssh.Connect To		${server_ip}		${server_login}		${server_pwd}		alias=${alias_cnx_recv}
    ${pid}              ssh.execute    pgrep -f 'iperf -p ${port}'       connection=${alias_cnx_recv}
    Log                 ${pid}
    ${pid}              Replace String  ${pid}     \r\n        ${SPACE}
    Log                 ${pid}
    ssh.execute        kill -9 ${pid}  connection=${alias_cnx_recv}
    ssh.disconnect     ${alias_cnx_recv}


Stop UL traffic process
    [Documentation]  Stop UL traffic process iperf.exe.
    ...              Author: Sandrine
    ...                      Annie Wong

    ssh.Connect To		${ULserver_ip}		${ULserver_login}		${ULserver_pwd}		alias=${iperfUe_cnx}

    ${cmd_kill_iperf}=        Set Variable       taskkill /f /im iperf.exe
    ssh.execute         ${cmd_kill_iperf}        connection=${iperfUe_cnx}
    ssh.disconnect      ${iperfUe_cnx}


Taskkill iperf exe
    [Documentation]  Stop process iperf.exe on server
    ...              This keyword replaces "Stop UL traffic process", takes as argument :
    ...                   ${direction}
    [Arguments]          ${direction}

    ${server_ip}=      run keyword if      '${direction}' == 'DL'     set variable     ${DLserver_ip}
    ...                       ELSE IF      '${direction}' == 'UL'     set variable     ${ULserver_ip}
    ...                       ELSE          fail   msg=unexpected traffic direction=${direction}

    ${server_login}=    run keyword if      '${direction}' == 'DL'     set variable     ${DLserver_login}
    ...                           ELSE       set variable      ${ULserver_login}

    ${server_pwd}=      run keyword if      '${direction}' == 'DL'     set variable     ${DLserver_pwd}
    ...                           ELSE       set variable      ${ULserver_pwd}

    ${alias_cnx}=       run keyword if      '${direction}' == 'DL'     set variable     ${iperfCore_cnx}
    ...                              ELSE         set variable     ${iperfUe_cnx}
    ${cmd_kill_iperf}=      Set Variable       taskkill /f /im iperf.exe

    ssh.Connect To		${server_ip}		${server_login}		${server_pwd}		alias=${alias_cnx}
    ssh.execute         ${cmd_kill_iperf}        connection=${alias_cnx}
    ssh.disconnect      ${alias_cnx}


Stop PPPoE process obsolete
    [Documentation]  Stop PPPoE processes on Viavi PC after UE detach.
    ...              Server info are valued in __init__.py and var_test_suite_taf_classical_iPerf.robot files.
    ...              Author: Sandrine
    ...                      Annie Wong
    ssh.Connect To		${ULserver_ip}		${ULserver_login}		${ULserver_pwd}		alias=${iperfUe_cnx}

    ${cmd_kill_pppoe}=        Set Variable       taskkill /f /im rasautou.exe
    ssh.execute         ${cmd_kill_pppoe}        connection=${iperfUe_cnx}
    ssh.disconnect      ${iperfUe_cnx}


Check Prisma DL Tput
    [Documentation]  Launch DL traffic with iperf command (UDP). Server info are valued in tlconfig.py (config file)
    ...              This keyword take as argument:
    ...                    . ${distantip}
    ...                    . ${tput} by default 100M     DL Tput
    ...                    . ${duration} by default 10   duration of DL traffic
    ...                    . ${ueid} by default 0        number to compute used port, discriminating each mobile of the test on same server.
    ...              Issue when 2 iperf on sam eport is launched !!!
    ...              Author: Denis
    [Arguments]     ${tputcondition}    ${blercondition}=5    ${duration}=60
    prisma.get scenario logger      ${logs_path}/checkDLtraffic1.log
    sleep   ${duration}
    prisma.get scenario logger      ${logs_path}/checkDLtraffic2.log
    ${resp}     Run      cat ${logs_path}/checkDLtraffic1.log | sed 's/]//'
    log     ${resp}
    ${used}     Run      cat ${logs_path}/checkDLtraffic2.log
    log     ${used}
    ${toanalyze}     Remove String   ${used}     ${resp}
    log     ${toanalyze}

    #${resp}             Run     cat ${analyzedfile}
    log     ${tputcondition}
    ${t}  	        Get Regexp Matches		${toanalyze}   TP=(?P<var>\\d*)kbs    var
    : FOR   ${rate}    IN    @{t}
    \       ${check}   Convert To Number    ${rate}
    \       Should be True       ${check}${tputcondition}

    ${ack}  set variable    0
    ${nack}  set variable    0


    ${t}  	        Get Regexp Matches		${toanalyze}   PDSCH crc\\s(?P<var>\\d*)    var
    : FOR   ${rate}    IN    @{t}
    \       ${check}   Convert To Number    ${rate}
    \       ${ack}     Evaluate     ${ack} + ${check}

    ${t}  	        Get Regexp Matches		${toanalyze}   PDSCH crc\\s\\d*/(?P<var>\\d*)    var
    : FOR   ${rate}    IN    @{t}
    \       ${check}   Convert To Number    ${rate}
    \       ${nack}     Evaluate     ${nack} + ${check}

    ${bler}     Run keyword if     $nack > 0      Evaluate     100 * ${nack} / (${ack} + ${nack})
    ...                             ELSE          set variable    0
    Should be True   ${bler}${blercondition}
    Should be True   ${ack} > 1000


Print Applicative Tput
    [Documentation]  Launch iperf -s command (UDP)
    ...              This keyword take as argument:
    ...                    . ${direction}  UL or DL
    ...                    . ${condition}
    ...                    . ${ueid} by default 0, number to compute used port for mobile
    ...              Issue when 2 iperf on sam eport is launched !!!
    ...              Author: Annie Wong
    [Arguments]          ${direction}           ${ueid}=0
    ${server_ip}=        run keyword if      '${direction}' == 'DL'     set variable     ${ULserver_ip}
    ...    ELSE IF       '${direction}' == 'UL'     set variable      ${DLserver_ip}
    ...    ELSE           fail           msg=unexpected traffic direction=${direction}

    ${server_login}=      run keyword if      '${direction}' == 'DL'     set variable     ${ULserver_login}
    ...    ELSE           set variable        ${DLserver_login}

    ${server_pwd}=        run keyword if      '${direction}' == 'DL'     set variable     ${ULserver_pwd}
    ...    ELSE           set variable        ${DLserver_pwd}

    ${alias_cnx_recv}=         run keyword if      '${direction}' == 'DL'     set variable     ${iperfUe_cnx}
    ...    ELSE           set variable        ${iperfCore_cnx}

    ${port}             Get traffic port      ${direction}     ${ueid}
    ssh.Connect To      ${server_ip}      ${server_login}      ${server_pwd}      alias=${alias_cnx_recv}

    ${resp}       ssh.execute         iperf -p ${port} -s -u -i 1 -t 10       connection=${alias_cnx_recv}
    Log           ${resp}
    ${t}          Get Regexp Matches		${resp}   \\s(\\d*.\\d*) Mbits  1
    : FOR   ${rate}    IN    @{t}
    \       ${check}   Convert To Number    ${rate}
    \       log        rate is ${check}
    ssh.disconnect      ${alias_cnx_recv}

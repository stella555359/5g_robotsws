*** Settings ***

Documentation     Keywords using ute_wtssim library

Library     String
Library     OperatingSystem
Library     ute_wtssim


*** Keywords ***

Kill WTS services
    [Documentation]
    ...    Terminate dedicated WTS service
    ...    :param egate_port: used egate port    (default ${tl.core.egate_port})
    ...    :param edaemon_port: used edaemon port    (default ${tl.core.edaemon_port})
    ...    :param wts_alias: used ute_wtssim alias for egate console    (default in common keyword ap_egate)
    ...    :param edaemon_alias: used ute_wtssim alias for edaemon    (default in common keyword ap_edaemon)
    ...
    ...    **Example:**
    ...    | wts_ue.Kill WTS services    egate_port=10000    edaemon_port=22222    wts_alias=wts1    edaemon_alias=edaemon1
    ...

    [Arguments]    ${egate_port}=${tl.core.egate_port}    ${edaemon_port}=${tl.core.edaemon_port}
    ...            ${wts_alias}=ap_egate    ${edaemon_alias}=ap_edaemon

    Dated Log    Kill WTS services with egate port: ${egate_port}, edaemon port: ${edaemon_port}

    ${alias}    SSH Connect     ${HOST_EPCSIM}

    ${output}    SSH Exec    sudo pkill -9 -f './egate.* --port ${egate_port}'    alias=${alias}

    ${output}    SSH Exec    sudo pkill -9 -f ./edaemon.* --port ${edaemon_port}'    alias=${alias}

    Teardown Egate Connection for Airphone    wts_alias=${wts_alias}

    Teardown Edaemon Connection for Airphone    edaemon_alias=${edaemon_alias}

    Dated Log    WTS services have been killed !


Reset Wts Cfg
    [Documentation]
    ...    Reset Cfg of WTS egate controller

    Send Egate Command and Verify Output    cmd=re


Teardown Egate Connection for Airphone
    [Documentation]
    ...    Used for Postcondition: GNB and Airphone, at Suite Teardown or Testcase teardown
    ...    used as teardown keyword for Start WTS for Airphone
    ...    :param wts_alias:     alias name to handle egate for ute_wtssim    default=ap_egate
    ...
    ...    **Example:**
    ...    | wts_ue.Start WTS for Airphone
    ...    | wts_ue.Teardown Egate Connection for Airphone
    ...

    [Arguments]    ${wts_alias}=ap_egate

    Run Keyword and Ignore Error    ute_wtssim.teardown_egate    alias=${wts_alias}


Teardown Edaemon Connection for Airphone
    [Documentation]
    ...    Used for Postcondition: GNB and Airphone, at Suite Teardown or Testcase teardown
    ...    used as teardown keyword for Start WTS for Airphone
    ...    :param edaemon_alias:     alias name to handle edaemon for ute_wtssim    default=ap_edaemon
    ...
    ...    **Example:**
    ...    | wts_ue.Start WTS for Airphone
    ...    | wts_ue.Teardown Edaemon Connection for Airphone
    ...

    [Arguments]    ${edaemon_alias}=ap_edaemon

    Run Keyword and Ignore Error    ute_wtssim.teardown_edaemon    alias=${edaemon_alias}


Start WTS for Airphone
    [Documentation]
    ...    Used for Precondition: GNB and Airphone, at Suite Setup or Testcase setup
    ...    Will setup egate alias ap_egate for keyword "Send Egate Command and verify output"
    ...    previous WTS processes should be killed at earlier step, before TL reboot
    ...    :param wts_alias:     alias name to handle egate for ute_wtssim    default=ap_egate
    ...    :param edaemon_alias: alias name to handle edaemon for ute_wtssim    default=ap_edaemon
    ...    :param remove_logs:   remove existing wts logs    default=${False}
    ...    :param egate_port: used egate port    (default ${tl.core.egate_port})
    ...    :param edaemon_port: used edaemon port    (default ${tl.core.edaemon_port})
    ...
    ...    **Example:**
    ...    | core.Kill previous WTS services
    ...    | wts_ue.Start WTS for Airphone    wts_alias=ap_egate
    ...

    [Arguments]    ${wts_alias}=ap_egate    ${edaemon_alias}=ap_edaemon    ${remove_logs}=${False}
    ...    ${egate_port}=${tl.core.egate_port}    ${edaemon_port}=${tl.core.edaemon_port}

    Teardown Egate Connection for Airphone    wts_alias=${wts_alias}
    Teardown Edaemon Connection for Airphone    edaemon_alias=${edaemon_alias}

    ${alias}    SSH Connect     ${HOST_EPCSIM}

    Run keyword if    ${remove_logs}    SSH Exec    cd ${tl.core.dir_path} && sudo rm *log*    alias=${alias}

    ${output}    SSH Exec    cd ${tl.core.dir_path} && sudo .\\/edaemon --port ${edaemon_port}    alias=${alias}

    Dated Log    ${output}

    ${output}    SSH Exec    cd ${tl.core.dir_path} && .\\/egate --port ${egate_port}    alias=${alias}

    Dated Log    ${output}

    Sleep    5s    reason=Wait for WTS startup

    # ute_wtssim.setup_egate    egate_port=${egate_port}    tool_dir=${tl.core.dir_path}    alias=${wts_alias}

    # ute_wtssim.setup_edaemon    edaemon_port=${edaemon_port}    tool_dir=${tl.core.dir_path}    alias=${edaemon_alias}


    Dated Log    isUTE=${TLConfig.isUTE}
    Run Keyword if         ${TLConfig.isUTE}==${True}           Setup egate edaemon TL ute    ${wts_alias}
    ...         ${edaemon_alias}    ${egate_port}    ${edaemon_port}
    ...         ELSE       Setup egate edaemon TL standalone    ${wts_alias}
    ...         ${edaemon_alias}    ${egate_port}    ${edaemon_port}


Setup egate edaemon TL ute
   [Arguments]    ${wts_alias}=ap_egate    ${edaemon_alias}=ap_edaemon
    ...    ${egate_port}=${tl.core.egate_port}    ${edaemon_port}=${tl.core.edaemon_port}
    ute_wtssim.setup_egate    egate_port=${egate_port}    tool_dir=${tl.core.dir_path}    alias=${wts_alias}
    ute_wtssim.setup_edaemon    edaemon_port=${edaemon_port}    tool_dir=${tl.core.dir_path}    alias=${edaemon_alias}


Setup egate edaemon TL standalone
   [Arguments]    ${wts_alias}=ap_egate    ${edaemon_alias}=ap_edaemon
    ...    ${egate_port}=${tl.core.egate_port}    ${edaemon_port}=${tl.core.edaemon_port}
    ute_wtssim.Configure Ssh Connection For Wts    host_ip=${tl.core.default_ssh_connection_details.addr}
    ...    ssh_username=${tl.core.default_ssh_connection_details.username}
    ...    ssh_password=${tl.core.default_ssh_connection_details.password}
    ute_wtssim.setup_egate    ssh_user=${tl.core.default_ssh_connection_details.username}
    ...     ssh_pass=${tl.core.default_ssh_connection_details.password}    host_ip=${tl.core.default_ssh_connection_details.addr}
    ...     egate_port=${egate_port}    tool_dir=${tl.core.dir_path}    alias=${wts_alias}

    ute_wtssim.Configure Ssh Connection For Wts    host_ip=${tl.core.default_ssh_connection_details.addr}
    ...    ssh_username=${tl.core.default_ssh_connection_details.username}
    ...    ssh_password=${tl.core.default_ssh_connection_details.password}
    ute_wtssim.setup_edaemon    host_ip=${tl.core.default_ssh_connection_details.addr}
    ...     ssh_username=${tl.core.default_ssh_connection_details.username}
    ...     ssh_pass=${tl.core.default_ssh_connection_details.password}
    ...     edaemon_port=${edaemon_port}    tool_dir=${tl.core.dir_path}    alias=${edaemon_alias}


Send Egate Command
    [Documentation]    :Author: Jing Liang
    ...    same as keyword ute_wtssim.execute egate command and wait for data
    ...    http://doc.ute.nsn-rdnet.net/packages/ute_wtssim/interfaces/ute_wtssim.html#execute-egate-command-and-wait-for-data
    ...    :param cmd: (string) – Command to execute.
    ...    :param timeout: Timeout for this operation. Default is 10 seconds
    ...    :param return_output: (${False} or ${Ture} boolean) - Flag indicating whether egate log should be printed out. Default is True.
    ...    :param wts_alias:     alias name to handle egate for ute_wtssim    default=ap_egate
    ...    :return output: egate console output
    ...
    ...    **Example:**
    ...    | wts_ue.Start WTS for Airphone
    ...    | wts_ue.Config WTS for Airphone
    ...    | wts_ue.Send Egate Command  cmd=sim_state_disp
    ...

    [Arguments]    ${cmd}    ${timeout}=10    ${return_output}=${True}    ${wts_alias}=ap_egate
    ...            ${display_output}=${True}
    ute_wtssim.Configure Ssh Connection For Wts    host_ip=${tl.core.default_ssh_connection_details.addr}
    ...    ssh_username=${tl.core.default_ssh_connection_details.username}
    ...    ssh_password=${tl.core.default_ssh_connection_details.password}

    ${output}=    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    timeout=${timeout}    return_output=${return_output}    alias=${wts_alias}

    Run Keyword If    ${display_output}==${True}    Dated Log     output = ${output}

    [Return]    ${output}


Send Egate Command and Verify Output
    [Documentation]
    ...    same as keyword ute_wtssim.execute egate command and wait for data
    ...    http://doc.ute.nsn-rdnet.net/packages/ute_wtssim/interfaces/ute_wtssim.html#execute-egate-command-and-wait-for-data
    ...    :param cmd: (string) – Command to execute.
    ...    :param timeout: Timeout for this operation. Default is 10 seconds
    ...    :param return_output: (${False} or ${Ture} boolean) - Flag indicating whether egate log should be printed out. Default is True.
    ...    :param pass_regexp: (string) - Regexp indicating that the command passed.
    ...    :param wts_alias:     alias name to handle egate for ute_wtssim    default=ap_egate
    ...    :return output: egate console output
    ...
    ...    **Example:**
    ...    | wts_ue.Start WTS for Airphone
    ...    | wts_ue.Config WTS for Airphone
    ...    | wts_ue.Send Egate Command and verify output    cmd=sim_state_disp    pass_regexp=The state is ACTIVE
    ...

    [Arguments]    ${cmd}    ${timeout}=10    ${return_output}=${True}    ${pass_regexp}=${None}
    ...            ${wts_alias}=ap_egate    ${display_output}=${True}

    ${output}=    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=${pass_regexp}    timeout=${timeout}    return_output=${return_output}    alias=${wts_alias}

    Run Keyword If    ${display_output}==${True}    Dated Log     output = ${output}

    [Return]    ${output}


Config WTS for Airphone
    [Documentation]
    ...    used for UTE Workaround keyword,
    ...    Configure WTS with default config file in __init__.py
    ...    :param wts_alias:     alias name to handle egate for ute_wtssim    default=ap_egate
    ...    :param cfg_file:      path of wts config file to be used           default=${tl.core.cfg_filename}
    ...
    ...    **Example:**
    ...    NSA TL
    ...    | wts_ue.Start WTS for Airphone
    ...    | wts_ue.Config WTS for Airphone    pass_regexp=SystemInformationBlockType2 updated
    ...    SA TL
    ...    | wts_ue.Start WTS for Airphone
    ...    | wts_ue.Config WTS for Airphone    pass_regexp=SystemInformationBlockType1-NR updated    timeout=600
    ...

    [Arguments]    ${pass_regexp}=${None}    ${timeout}=10    ${wts_alias}=ap_egate    ${cfg_file}=${tl.core.cfg_filename}

    ute_wtssim.execute egate command and wait for data
    ...    cmd=cfg file=${cfg_file}    pass_regexp=${pass_regexp}
    ...    timeout=${timeout}    alias=${wts_alias}


Setup Wts Environment
    [Documentation]
    ...    (Re)start WTS service, load the basic.cfg file then wait for the TL to be ready
    ...    timeout : max time (in seconds) waiting for the TL to be ready

    [Arguments]         ${timeout}=300

    UteWts.Kill WTS services

    UteWts.Start WTS for Airphone

    UteWts.Reset Wts Cfg

    UteWts.Config WTS for Airphone    pass_regexp=SystemInformationBlockType1-NR updated     timeout=${timeout}


UE Register
    [Documentation]
    ...
    ...    :param ue:      Specified UE ID
    ...    :param args:    id of the Network Slice containing the requested NSSAI
    ...
    [Arguments]    ${ue}=1    ${nwslice}=1    ${args}=${EMPTY}

    ${output}=    Send Egate Command and verify output
    ...    cmd=ue_register id=${ue} nwslice=${nwslice} ${args}
    #...    pass_regexp=UE now in NG RM Registered
    ...    pass_regexp=crnti

    [Return]      ${output}


UE PDU Set Param
    [Documentation]
    ...    Set PDU parameters - to be done before "UE PDU Session Setup"
    ...
    ...    :param ue:         Specified UE ID
    ...    :param pdu:        PDU Session ID
    ...
    [Arguments]    ${ue}=1    ${pdu}=1

    ${output}=     Send Egate Command and verify output
    ...    cmd=set_pdu_param ue=${ue} pdu=${pdu} trf_type=internal
    ...    pass_regexp=${None}


UE PDU Session Setup
    [Documentation]
    ...    Setup PDU session
    ...    :param pdu:        PDU Session ID
    ...    :param ue:         Specified UE ID
    ...    :param nwslice:    Requested Network Slice for the PDU Session
    ...    :param gw:         PDU Gateway ID. Specifies gateway to use for this PDU session OPTIONAl --> TBRM
    ...

    [Arguments]    ${ue}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1

    ${output}=     Send Egate Command and verify output
    ...                 cmd=ue_pdu_session_setup pdu=${pdu} ue=${ue} nwslice=${nwslice} gw=${gw}
    ...                 pass_regexp=Initial Context Setup Successful

    ${pattern}=    Catenate    Allocated PduSessionFsm with PDU session ID:${pdu} .*
    ...                        UE IP address:([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})

    ${ue_ip}=      Get Regexp Matches    ${output}    ${pattern}    1

    [Return]      ${ue_ip[0]}


Start Data Traffic In Egate
    [Documentation]
    ...    Start data traffic
    ...
    ...    :param ue:           UE id configured in WTS configuration
    ...    :param pdu:          PDU id configured in WTS configuration
    ...    :param qfi:          ???
    ...    :param trf_id:       traffic identifier (1 to 20)
    ...    :param dir:          traffic direction : ul or dl
    ...    :param duration:     duration (in seconds) for generating data traffic
    ...    :param rate:         rate in Mbits per seconds by default
    ...    :param rateUnit:     rate unit, mb for megabits per second or kb for for kilobits per second

    [Arguments]    ${ue}    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl    ${duration}=10    ${rate}=5    ${rateUnit}=mb

    Dated Log    Start ${dir.upper()} data traffic for UE ${ue} during ${duration} seconds

    ${protocol}    Set Variable    udp

    ${rateWithUnit}   Run Keyword If        '${rateUnit}' == 'mb'
    ...                                     set variable            mbps=${rate}
    ...                ELSE
    ...                                     set variable            kbps=${rate}
    Dated Log    rateUnit ${rateUnit}
    Dated Log    rateWithUnit ${rateWithUnit}
    ${command}=    Catenate
    ...    trf_data_start ue=${ue} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=${dir} seconds=${duration}
    ...    ${SPACE}protocol=${protocol} ${rateWithUnit}

    Send Egate Command and verify output
    ...    cmd=${command}
    ...    pass_regexp=UE ${ue}: ${protocol.upper()} ${dir.upper()} TRF:


Stop Traffic Message From Egate
    [Documentation]
    ...    Return the message generated by egate when stopping the traffic
    ...    The message seems not the same for UL and DL traffic --> TO BE CHECKED for DL

    [Arguments]    ${dir}=dl

    Return From Keyword If    '${dir}' == 'dl'   Traffic was stopped

    Return From Keyword If    '${dir}' == 'ul'   Stopping Uplink Internal traffic


Stop Data Traffic In Egate
    [Documentation]
    ...    Stop data traffic on a bearer(s)
    ...
    ...    :param ue:    ue configured in WTS configuration
    ...    :param dir:   dl or ul traffic dir
    ...

    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl

    Dated Log    ADT - Start "Stop data traffic in egate"
    Dated Log    ADT - ue=${ue}, pdu=${pdu}, qfi=${qfi}, dir=${dir}

    ${command}=    Catenate
    ...    trf_data_stop ue=${ue} pdu=${pdu} qfi=${qfi} trf_id=${trf_id}
    ...    ${SPACE}dir=${dir}

    # The message is not the same in case of dl and ul --> to be checked

    ${pass_regexp}=   Stop Traffic Message From Egate    dir=${dir}

    ${output}=    Send Egate Command and verify output
    ...    cmd=${command}
    ...    pass_regexp=${pass_regexp}

    # Dated Log    ${output}
    # Dated Log    ${dir.upper()} data for UE${ue} is stopped


Get Bearer Stats In Egate
    [Documentation]
    ...    Get bearer statistics or per-traffic(s) statistics of the bearer.
    ...
    ...    :param ue:         ue configured in WTS configuration
    ...    :param dir:     dir (default=bi)
    ...

    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl

    Dated Log     Start "Get bearer stats"

    ${str}=    Catenate
    ...    bearer_stats ue=${ue} pdu=${pdu} qfi=${qfi} trf_id=${trf_id}
    ...    ${SPACE} dir=${dir}

    ${output}=    Send Egate Command and verify output
    ...    cmd=${str}
    ...    pass_regexp=Average data rate

    Sleep    1s    reason=Waiting command to be executed

    # Dated Log    Bearer  stats for UE${ue}
    # Dated Log    ${output}

    [Return]    ${output}


Get Average Traffic Rate From Bearer Stats
    [Documentation]
    ...   Get average data rate from Egate output

    [Arguments]    ${output}
    ${output}=    Get Lines Containing String    ${output}    Average data rate
    ${output}=    Replace String    ${output}    Average data rate    ${EMPTY}
    @{words}=    Split String    ${output}    (
    ${data_rate}=    Strip String    ${words[0]}
    [Return]    ${data_rate}


Start Traffic
    [Documentation]
    ...    Start data traffic using EGATE internal traffic simulator

    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl    ${duration}=10    ${rate}=5    ${rateUnit}=mb

    Dated Log    ADT - Start "Start Traffic"
    Dated Log    ADT - ue=${ue}, pdu=${pdu}, qfi=${qfi}, dir=${dir}, duration=${duration}, rate=${rate}, rateUnit=${rateUnit}

    Start Data Traffic In Egate    ue=${ue}    pdu=${pdu}    qfi=${qfi}    trf_id=${trf_id}    dir=${dir}
    ...                            duration=${duration}    rate=${rate}    rateUnit=${rateUnit}


Get Average Traffic Rate
    [Documentation]
    ...    Get average traffic rate from Egate output

    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl

    ${output}=    Get Bearer Stats In Egate    ue=${ue}    pdu=${pdu}    qfi=${qfi}    trf_id=${trf_id}    dir=${dir}

    ${average_rate}=    Get Average Traffic Rate From Bearer Stats    output=${output}

    Dated Log    Average traffic rate = ${average_rate}

    [Return]    ${average_rate}


Start Traffic And Return Average Throughput
    [Documentation]
    ...    Start data traffic using EGATE internal traffic simulator and return the average rate atr the end

    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl    ${duration}=10    ${rate}=5    ${rateUnit}=mb

    Dated Log    ADT - Start "Start Traffic And Return Average Throughput"
    Dated Log    ADT - ue=${ue}, pdu=${pdu}, qfi=${qfi}, dir=${dir}, duration=${duration}, rate=${rate},  rateUnit=${rateUnit}

    Start Data Traffic In Egate    ue=${ue}    pdu=${pdu}    qfi=${qfi}    trf_id=${trf_id}    dir=${dir}
    ...                            duration=${duration}    rate=${rate}    rateUnit=${rateUnit}

    sleep  ${duration}s    reason=Waiting for ${duration} seconds before stopping data traffic ...

    # no neeed to stop as the "seconds" parameter in the above command should limit the traffic for this duration
    # Stop Data Traffic In Egate    ue=${ue}    pdu=${pdu}    qfi=${qfi}    trf_id=${trf_id}    dir=${dir}

    ${average_rate}=    UteWts.Get Average Traffic Rate    ue=${ue}    pdu=${pdu}    qfi=${qfi}    trf_id=${trf_id}    dir=${dir}

    Dated Log    ADT - End "Start Traffic And Return Average Throughput"

    [Return]    ${average_rate}


Stop Traffic
    [Documentation]
    ...    Stop data traffic

    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl

    Dated Log    ADT - Start "Stop Traffic"
    Dated Log    ADT - ue=${ue}, pdu=${pdu}, qfi=${qfi}, trf_id=${trf_id}, dir=${dir}

    Stop Data Traffic In Egate    ue=${ue}    pdu=${pdu}    qfi=${qfi}    trf_id=${trf_id}    dir=${dir}


Setup X2 Link
    [Documentation]
    ...    Activate the X2 link and check that the link is OK

    [Arguments]    ${enb}=1    ${target}=1    ${expected_str}=${EMPTY}


    ${pass_regexp}=    set variable if    '${expected_str}'=='${EMPTY}'
    ...                    ENB-1: X2AP Link with GNB-2 .* is up
    ...                    ${expected_str}

    # enb_x2_link_up enb=1 target=2
    ${cmd}=    Set Variable    enb_x2_link_up enb=${enb} target=${target}

    ${output}=    Send Egate Command and verify output
    ...    cmd=${cmd}
    ...    pass_regexp=${pass_regexp}

    [Return]    ${output}


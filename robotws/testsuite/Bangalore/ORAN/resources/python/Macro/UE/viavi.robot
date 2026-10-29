*** Settings ***

Documentation     Keywords related to viavi handling
...               :Author: Vasileios Papoutsis
...               email: vasileios.papoutsis@nokia.com
...


Library    String
Library    OperatingSystem
Library    ../../sites/Ulm/Common/python/core.py   WITH NAME    corepy
Library    ../../sites/Ulm/Common/python/pdml_file.py
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.ue.tm500.asc    WITH NAME    asc
Library    taf.ue.tm500.rci    WITH NAME    rci

Resource    ../../sites/Ulm/Common/connect.robot
Resource    ../../sites/Ulm/Common/testline.robot
Resource    ../../sites/Ulm/Common/enb.robot
Resource    ../../sites/Ulm/Common/tcpdump.robot
Resource    ../../sites/Ulm/Common/util.robot

*** Variables ***
${P_console}         ${False}

*** Keywords ***

Initialize Viavi UE
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param path_to_hw_connect_script: HW connection script used to initialize Viavi
    ...    :param path_to_cell_search_script: Cell search script used to initialize Viavi
    ...    :param path_to_ues_config_script: UEs configuration script used to initialize Viavi
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param number_of_ues: (default=1) Number of Viavi UEs
    ...    :param gNBType: (default=NSA)  gNB type i.e NSA or SA
    ...
    [Arguments]    ${path_to_hw_connect_script}    ${path_to_cell_search_script}    ${path_to_ues_config_script}    ${ue_id}=${0}
    ...    ${number_of_ues}=${1}   ${gNBType}=NSA
    ${ue_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    BuiltIn.Log     Start ${ue_alias} Initialization    console=${P_console}
    Kill TMA application    ue_id=${ue_id}    ssh_alias=viavi_ssh
    Start TMA application    ue_id=${ue_id}    ssh_alias=viavi_ssh
    Setup Viavi UE    path_to_hw_connect_script=${path_to_hw_connect_script}
    ...    path_to_cell_search_script=${path_to_cell_search_script}
    ...    ue_id=${ue_id}
    Configure UEs    number_of_ues=${number_of_ues}    ue_id=${ue_id}
    ...    path_to_ues_config_script=${path_to_ues_config_script}    gNBType=${gNBType}
    BuiltIn.Log     ${ue_alias} is initialized!      console=${P_console}


Kill TMA application
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param ssh_alias: ssh alias
    ...
    [Arguments]    ${ue_id}=${0}    ${ssh_alias}=viavi_ssh
    connect.Connect to TMA Pc    ue_id=${ue_id}    alias=${ssh_alias}
    ssh.send_command    command=taskkill /F /IM "TmaApplication.exe"    connection=${ssh_alias}
    Sleep    10s
    ssh.disconnect    connection=${ssh_alias}


Start TMA application
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param ssh_alias: ssh alias
    ...
    [Arguments]    ${ue_id}=${0}    ${ssh_alias}=viavi_ssh
    connect.Connect to TMA Pc    ue_id=${ue_id}    alias=${ssh_alias}
    ${cmdStr}=    Set variable    "${tl.ues[${ue_id}].tma_path}" /u "Default User" /p ${tl.ues[${ue_id}].tma_command_port} /c y /a y
    ssh.send_command    command=${cmdStr}    connection=${ssh_alias}
    Sleep    20s
    ssh.disconnect    connection=${ssh_alias}


Setup Viavi UE
    [Documentation]    :Author: Srihari Janardhan
    ...  Sends HW connect script and cell search script to the Viavi
    ...
    ...    :param path_to_hw_connect_script: HW connection script used to initialize Viavi
    ...    :param path_to_cell_search_script: Cell search script used to initialize Viavi
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...
    [Arguments]    ${path_to_hw_connect_script}    ${path_to_cell_search_script}    ${ue_id}=${0}
    ${ue_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    Wait Until Keyword Succeeds    5min    10sec
    ...  rci.Connect to    ip=${tl.ues[${ue_id}].tma_host.addr}    command_port=${tl.ues[${ue_id}].tma_command_port}
    ...  alias=${ue_alias}
    Sleep  10s
    BuiltIn.Log     Sending HW connect script to ${ue_alias}    console=${P_console}
    ${response}=    rci.send script    filename=${path_to_hw_connect_script}    alias=${ue_alias}  timeout=5min
    Should Not Contain Any    ${response}    failure    Failure
    BuiltIn.Log     Sending Cell search script to ${ue_alias}   console=${P_console}
    ${response}=    rci.send script    filename=${path_to_cell_search_script}    alias=${ue_alias}    timeout=5min
    Should Not Contain Any    ${response}    failure    Failure


Configure UEs
    [Documentation]    :Author:  Srihari Janardhan
    ...
    ...    :param path_to_ues_config_script: UEs configuration script used to initialize Viavi
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param number_of_ues: (default=1) Number of Viavi UEs
    ...    :param gNBType: (default=NSA)  gNB type i.e NSA or SA
    ...
    [Arguments]    ${path_to_ues_config_script}    ${ue_id}=${0}    ${number_of_ues}=${1}    ${gNBType}=NSA
    ${ue_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    FOR    ${mue_id}    IN RANGE    ${number_of_ues}
        BuiltIn.Log        Sending configuration script to ${ue_alias} UE${mue_id}     console=${P_console}
        ${response}=    rci.send_command    command=forw mte SetUEContext ${mue_id}    alias=${ue_alias}    timeout=1min
        Should contain    ${response}    C: FORW 0x00 Ok MTE SETUECONTEXT RETURN CODE:0 SUCCEEDED [Ue Context Id: ${mue_id}]
        ${usim_config_command}=    Usim_config    ue_id=${ue_id}    mue_id=${mue_id}     gNBType=${gNBType}
        ${response}=    rci.send_command    command=${usim_config_command}    alias=${ue_alias}    timeout=1min
        Should contain    ${response}    C: FORW 0x00 Ok MTE USIMCONFIG: RETURN CODE:0 SUCCEEDED
        ${response}=    rci.send_command    command=forw mte Activate -1    alias=${ue_alias}    timeout=1min
        Should contain    ${response}    C: FORW 0x00 Ok MTE ACTIVATE CNF: RETURN CODE:0
        ${response}=    rci.send script    filename=${path_to_ues_config_script}    alias=${ue_alias}    timeout=5min
        Activate config    ue_id=${ue_id}
    END

Usim_config
    [Documentation]    :Author: Vasileios Papoutsis, [PRIVATE]
    ...    Configure Viavi Usim command
    ...
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param mue_id: (default=0) MUE Id
    ...    :param enb_id: (default=0) eNB Id
    ...    :param gNBType: (default=NSA)  gNB type i.e NSA or SA
    ...
    [Arguments]    ${ue_id}=${0}    ${mue_id}=${0}    ${enb_id}=${0}    ${gNBType}=NSA
    ${imsi}=    Evaluate    int(${tl.ues[${ue_id}].imsi})+${mue_id}
    ${coreType}=    Get Core type
    ${op_key}=    Run keyword if    '${coreType}'=='epcsim'    Get op key from epcsim    cfg_file_path=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...    ELSE    Set variable    0ED47545168EAFE2C39C075829A7B61F
    ${opc_value}=    Run keyword if    '${coreType}'=='epcsim'    Set Variable    ${EMPTY}
    ...    ELSE    Set Variable    ${1}
    ${mnc_length}=    Get mnc length from core    mnc=${tl.core.mnc}
    ${usim_config_command_NSA}=    Catenate    FORW MTE UsimConfig 1([${imsi} ${mnc_length}] [] [] [] []) [] [] [${tl.ues[${ue_id}].sec_key}]
    ...    [${op_key} 00000000000000000000000000000000 00000000000000000000000000000001 00000000000000000000000000000002
    ...    00000000000000000000000000000004 00000000000000000000000000000008 64 0  32 64 96 [${opc_value}]] [] []
    ${usim_config_command_SA}=    Catenate    FORW MTE UsimConfig 1([${imsi} ${mnc_length}] [] [] [] []) [] [] [${tl.ues[${ue_id}].sec_key}]
    ...    [01020304050607080910111213141516 00000000000000000000000000000000 00000000000000000000000000000001 00000000000000000000000000000002
    ...    00000000000000000000000000000004 00000000000000000000000000000008 64 0  32 64 96 []] [] [] []
    ${usim_config_command}   set variable if  '${gNBType}'=='NSA'    ${usim_config_command_NSA}    ${usim_config_command_SA}
    [Return]    ${usim_config_command}


Get mnc length from core
    [Documentation]    :Author: Vasileios Papoutsis, [PRIVATE]
    [Arguments]    ${mnc}
    ${mnc_length}=    corepy.read_mnc_and_return_mnc_length    mnc=${mnc}
    [Return]    ${mnc_length}


Get op key from epcsim
    [Documentation]    :Author: Vasileios Papoutsis, [PRIVATE]
    ...
    ...    :param cfg_file_path: epcsim configuration file path
    ...
    [Arguments]    ${cfg_file_path}
    ${op_key}=    corepy.read_epcsim_cfg_and_return_op_key    cfg_file_path=${cfg_file_path}
    [Return]    ${op_key}


Reset Viavi via ASC
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${ue_id}=${0}    ${group}=5G 4CC    ${ssh_alias}=viavi_ssh    ${asc_alias}=asc_ssh
    connect.Connect to TMA Pc    ue_id=${ue_id}    alias=${ssh_alias}
    ssh.connect_to    hostname=192.168.10.9
    ...    username=switch
    ...    password=switch
    ...    proxy=${ssh_alias}
    ...    alias=${asc_alias}
    asc.set_power_off    group_name=${group}    connection=${asc_alias}
    Sleep    10s
    asc.set_power_on    group_name=${group}    connection=${asc_alias}
    Sleep    10s
    Ping Viavi ASC IP    asc_ip=192.168.10.70    ssh_alias=${ssh_alias}
    Sleep    10s
    ssh.disconnect    connection=${asc_alias}
    ssh.disconnect    connection=${ssh_alias}


Ping Viavi ASC IP
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${ue_id}=${0}    ${asc_ip}=192.168.10.70    ${ssh_alias}=viavi_ssh    ${timeout}=${120}
    connect.Connect to TMA Pc    ue_id=${ue_id}    alias=${ssh_alias}
    ${response}= ssh.execute    command=ping ${asc_ip}    connection=${ssh_alias}
    :FOR    ${i}    IN RANGE    ${timeout}
    \    Exit for loop if    ('Reply from %s: bytes=32' in '${response}')
    \    ${response}=    ssh.execute    command=ping ${asc_ip}    connection=${ssh_alias}
    Run keyword if    ('Reply from %s: bytes=32' not in '${response}')    Fail    Viavi is not pingable!!!
    ssh.disconnect    connection=${ssh_alias}


Start logging for Viavi
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param ue_id: (default 0) the ID of UE in __init__.py, Integer or String
    ...
    [Arguments]    ${ue_id}=${0}
    ${rci_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    ${response}=    rci.send_command    command=#$$START_LOGGING    alias=${rci_alias}
    ${response}=    rci.send_command    command=GBLK 0    alias=${rci_alias}
    ${response}=    rci.send_command    command=SMUG 0 0-9    alias=${rci_alias}
    ${cmdStr}=    Catenate
    ...    LCFG 0 hlc all 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0x00060000 0 0 0 0 0 0x00011400 0 0x00004400 0x00000020
    ...    0 0 0 0 0x000002A0 0 0x00000100 0 0 0 0x00000520 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    ...    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    ...    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    ${response}=    rci.send_command    command=${cmdStr}    alias=${rci_alias}
    ${response}=    rci.send_command    command=SMLI LTE_L1_MAC_TTI MUG0    alias=${rci_alias}
    ${cmdStr}=    Catenate
    ...    SDLI LTE_CELL_MODEL 0x00000001 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000
    ...    0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000
    ${response}=    rci.send_command    command=${cmdStr}    alias=${rci_alias}
    ${cmdStr}=    Catenate
    ...    SDLI NR_LA_L1_CELL_WATCH 0x00000001 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000
    ...    0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000
    ${response}=    rci.send_command    command=${cmdStr}    alias=${rci_alias}
    ${response}=    rci.send_command    command=SLOG    alias=${rci_alias}


Stop logging for Viavi
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param ue_id: (default 0) the ID of UE in __init__.py, Integer or String
    ...
    [Arguments]    ${ue_id}=${0}
    ${rci_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    ${response}=    rci.send_command    command=#$$STOP_LOGGING    alias=${rci_alias}  timeout=1min
    ${response}=    rci.send_command    command=ELOG    alias=${rci_alias}  timeout=1min
    ${cmdStr}=    Catenate
    ...    LCFG 0 hlc all 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    ...    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    ...    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    ${response}=    rci.send_command    command=${cmdStr}    alias=${rci_alias}  timeout=1min
    ${cmdStr}=     Catenate
    ...    SDLI LTE_L1_MAC_TTI 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000
    ...    0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000
    ${response}=    rci.send_command    command=${cmdStr}    alias=${rci_alias}  timeout=1min
    ${cmdStr}=    Catenate
    ...    SDLI LTE_CELL_MODEL 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000
    ...    0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000
    ${response}=    rci.send_command    command=${cmdStr}    alias=${rci_alias}  timeout=1min
    ${cmdStr}=    Catenate
    ...    SDLI NR_LA_L1_CELL_WATCH 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000
    ...    0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000
    ${response}=    rci.send_command    command=${cmdStr}    alias=${rci_alias}  timeout=1min


Convert and get Viavi tti traces
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param tma_session_logs: Path to Viavi logs in tmapc
    ...    :param ssh_alias: Alias of tmapc ssh connect
    ...    :param ue_id: (default 0) the ID of UE in __init__.py, Integer or String
    ...    :param target_dir: Logs target directory
    ...
    [Arguments]    ${tma_session_logs}=D:\\E500\\E500logs\\    ${ssh_alias}=tm500ssh    ${ue_id}=${0}    ${target_dir}=None

    ${rci_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    ${response}=    rci.send_command   \#$$CONVERT_OPTIONS 1 1 1 65535 1 1  alias=${rci_alias}

    connect.Connect to TMA Pc    ue_id=${0}    alias=${ssh_alias}
    ssh.send_command    command=dir ${tma_session_logs} /A:D /B /O:-D    connection=${ssh_alias}
    ${sessions}=    ssh.read_output    connection=${ssh_alias}
    ${last_session}=    Get Line	${sessions}  0
    ssh.send_command    dir ${tma_session_logs}\\${last_session} /A:D /B /O:-D    connection=${ssh_alias}
    ${traces}=    ssh.read_output   connection=${ssh_alias}
    ${last_trace}=    Get lines matching pattern    ${traces}    ??????_??????

    ${response}=    rci.send_command    command=\#$$CONVERT_TO_TEXT 2 ${tma_session_logs}\\${last_session}\\${last_trace}
    ...    timeout=15min
    ...    alias=${rci_alias}
    Wait until keyword succeeds  20min  20s  Check if log conversion is complete

    ${resultTestDir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get testcase log directory
    ...    ELSE    Set variable    ${target_dir}
    Create directory    ${resultTestDir}/${last_session}/${last_trace}
    ssh.send_command    command=dir ${tma_session_logs}\\${last_session}\\${last_trace} /B /O:-D    connection=${ssh_alias}
    ${trace_log_files}=    ssh.read_output    connection=${ssh_alias}
    ${trace_csv_logs}=    Get lines containing string    ${trace_log_files}    .csv
    @{trace_logs}=    Split String	   ${trace_csv_logs}    separator=\n
    FOR    ${file}    IN    @{trace_logs}
        Run keyword if    '${file}'!=''
        ...    Run keyword and continue on failure    ssh.download file
        ...    ${tma_session_logs}\\${last_session}\\${last_trace}\\${file}
        ...    ${resultTestDir}/${last_session}/${last_trace}/${file}
        ...    connection=${ssh_alias}
    END
    Create directory    ${resultTestDir}/${last_session}/SessionHistory
    ssh.send_command    command=dir ${tma_session_logs}\\${last_session}\\SessionHistory /B /O:-D    connection=${ssh_alias}
    ${xml_files}=    ssh.read_output    connection=${ssh_alias}
    @{xml_logs}=    Split String	   ${xml_files}    separator=\r\n
    FOR    ${file}    IN    @{xml_logs}
        Run keyword if    '${file}'!=''
        ...    Run keyword and continue on failure    ssh.download file
        ...    ${tma_session_logs}\\${last_session}\\SessionHistory\\${file}
        ...    ${resultTestDir}/${last_session}/SessionHistory/${file}
        ...    connection=${ssh_alias}
    END
    ssh.disconnect    connection=${ssh_alias}


Get Viavi command log
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param tma_session_logs: Path to Viavi logs in tmapc
    ...    :param ssh_alias: Alias of tmapc ssh connect
    ...    :param ue_id: (default 0) the ID of UE in __init__.py, Integer or String
    ...    :param target_dir: Logs target directory
    ...
    [Arguments]    ${tma_session_logs}=D:\\E500\\E500logs\\    ${ssh_alias}=tm500ssh    ${ue_id}=${0}    ${target_dir}=None

    connect.Connect to TMA Pc    ue_id=${0}    alias=${ssh_alias}
    ssh.send_command    command=dir ${tma_session_logs} /A:D /B /O:-D    connection=${ssh_alias}
    ${sessions}=    ssh.read_output    connection=${ssh_alias}
    ${last_session}=    Get Line	${sessions}  0

    ${resultTestDir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get testcase log directory
    ...    ELSE    Set variable    ${target_dir}

    Create directory    ${resultTestDir}/${last_session}

    ssh.send_command    dir ${tma_session_logs}\\${last_session} /B /O:-D    connection=${ssh_alias}
    ${traces}=    ssh.read_output   connection=${ssh_alias}
    ${command_log_file}=    Get lines matching pattern    ${traces}    ??????_??????_Command_Log???.txt
    Run keyword and continue on failure    ssh.download file
    ...    ${tma_session_logs}\\${last_session}\\${command_log_file}
    ...    ${resultTestDir}/${last_session}/${command_log_file}
    ...    connection=${ssh_alias}

    ssh.disconnect    connection=${ssh_alias}


Check if log conversion is complete
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param ue_id: (default 0) the ID of UE in __init__.py, Integer or String
    ...
    [Arguments]    ${ue_id}=${0}
    ${rci_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    ${response}=    rci.read_responses    alias=${rci_alias}
    Should contain    ${response}    CONVERT_TO_TEXT Succeeded


Get Viavi stats
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param  ue_id: (default 0) the ID of UE in __init__.py, Integer or String
    ...
    [Arguments]    ${ue_id}=${0}
    ${rci_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    ${stats}=    rci.send_command    command=forw mte Getstats [0] [0] [1]    alias=${rci_alias}
    [Return]    ${stats}


Clear Viavi stats
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param ue_id: (default 0) the ID of UE in __init__.py, Integer or String
    ...
    [Arguments]    ${ue_id}=${0}
    ${rci_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    ${response}=    rci.send_command    command=forw mte clearstats    alias=${rci_alias}


Attach Viavi UE
    [Documentation]    :Author:  Vasileios Papoutsis
    ...    Attach UE
    ...
    ...    :param ue_id: (default 0) the ID of UE in __init__.py, Integer or String
    ...    :param mue_id: (default 0) the ID of UE for multiple UEs, Integer or String
    ...    :param gNBType: (default=NSA)  gNB type i.e NSA or SA
    ...    :param NasEmmRegCmd_NSA: default=forw mte NasConfigEmmRegister 0(0 [0] [] [] [] [] [] [] [] [])
    ...    :param NasEmmRegCmd_SA: default=forw mte NrNasConfigRegistration
    ...                            [0] [1{0xD143A501}] [1(1 0 [wap1..nokia.com])] [] [5G:mnc099.mcc404.3gppnetwork.org]
    [Arguments]    ${ue_id}=${0}    ${mue_id}=${0}     ${gNBType}=NSA
    ...  ${NasEmmRegCmd_NSA}=forw mte NasConfigEmmRegister 0(0 [0] [] [] [] [] [] [] [] [])
    ...  ${NasEmmRegCmd_SA}=forw mte NrNasConfigRegistration [0] [1{0xD143A501}] [1(1 0 [wap1..nokia.com])] [] [5G:mnc099.mcc404.3gppnetwork.org]
    ${ue_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    BuiltIn.Log     Attach [${ue_alias}] UE${mue_id}    console=${P_console}
    run keyword and ignore error  Stop pppoe    ue_id=${ue_id}    mue_id=${mue_id}    ue_appserv_alias=ue-appserv
    rci.send_command    command=forw mte SetUEContext ${mue_id}    alias=${ue_alias}    timeout=1min
    ${nas_Emm_reg_cmd}    set variable if  '${gNBType}'=='NSA'    ${NasEmmRegCmd_NSA}
    ...   ${NasEmmRegCmd_SA}
    rci.send_command    command=${nas_Emm_reg_cmd}    alias=${ue_alias}    timeout=1min
    rci.send_command    command=forw mte Activate -1    alias=${ue_alias}    timeout=1min
    ${response}=    rci.send_command    command=WAIT FOR "ACTIVATE" TIMEOUT 5    alias=${ue_alias}    timeout=1min
    Should contain    ${response}    CMPI L2 Random Access Complete :UE Id:${mue_id}    # [LTE]attach complete
    run keyword if    '${gNBType}'=='SA'        Should contain    ${response}     Result: 3GPP Access Only    # SA Attach
    Should not contain    ${response}    failure    msg=[LTE]attach failure!
    Sleep    3s
    run keyword and ignore error   Start pppoe    ue_id=${ue_id}    mue_id=${mue_id}    ue_appserv_alias=ue-appserv
    run keyword and ignore error   Check for pppoe interface in ue appserv    ue_id=${ue_id}    mue_id=${mue_id}    ue_appserv_alias=ue-appserv
    BuiltIn.Log     [${ue_alias}] UE${mue_id} is attached!     console=${P_console}


SA Attach using Viavi UE
    [Documentation]    :Author: Rajesh Venkata
    ...
    ...    :param path_to_hw_connect_script: HW connection script used to initialize Viavi
    ...    :param path_to_cell_search_script: Cell search script used to initialize Viavi
    ...    :param path_to_ues_config_script: UEs configuration script used to initialize Viavi
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param mue_id: (default 0) the ID of UE for multiple UEs, Integer or String
    ...    :param number_of_ues: (default=1) Number of Viavi UEs
    ...    :param gNBType: (default=NSA)  gNB type i.e NSA or SA
    ...
    [Arguments]    ${path_to_hw_connect_script}    ${path_to_cell_search_script}    ${path_to_ues_config_script}    ${ue_id}=${0}
    ...    ${number_of_ues}=${1}   ${mue_id}=${0}
    Initialize Viavi UE     path_to_hw_connect_script=${path_to_hw_connect_script}     path_to_cell_search_script=${path_to_cell_search_script}
    ...     path_to_ues_config_script=${path_to_ues_config_script}     ue_id=${ue_id}   number_of_ues=${number_of_ues}
    ...    gNBType=SA
    Attach Viavi UE    ue_id=${ue_id}     mue_id=${mue_id}     gNBType=SA


Detach Viavi UE
    [Documentation]    :Author:  Vasileios Papoutsis
    ...    Detach UE
    ...
    ...    :param ue_id: (default 0) the ID of UE in __init__.py, Integer or String
    ...    :param mue_id: (default 0) the ID of UE for multiple UEs, Integer or String
    ...
    [Arguments]    ${ue_id}=${0}    ${mue_id}=${0}
    ${ue_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    BuiltIn.Log     Detach [${ue_alias}] UE${mue_id}    console=${P_console}
    rci.send_command    command=forw mte SetUEContext ${mue_id}    alias=${ue_alias}    timeout=1min
    ${response}=    rci.send_command    command=forw mte NasConfigEmmDeregister ${mue_id}    alias=${ue_alias}    timeout=1min
    Should contain    ${response}    C: FORW 0x00 Ok MTE NASCONFIGEMMDEREGISTER: RETURN CODE:0 SUCCEEDED
    Activate config    ue_id=${ue_id}
    run keyword and ignore error   Stop pppoe    ue_id=${ue_id}    mue_id=${mue_id}    ue_appserv_alias=ue-appserv
    BuiltIn.Log     [${ue_alias}] UE${mue_id} is detached!  console=${P_console}


Activate config
    [Documentation]    :Author:  Vasileios Papoutsis
    ...
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...
    [Arguments]    ${ue_id}=${0}
    ${ue_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    Sleep    1s
    ${response}=    rci.send_command    command=forw mte Activate -1    alias=${ue_alias}    timeout=1min
    Should contain    ${response}    C: FORW 0x00 Ok MTE ACTIVATE CNF: RETURN CODE:0
    ${response}=    rci.send_command    command=WAIT FOR "ACTIVATE" TIMEOUT 5    alias=${ue_alias}    timeout=1min
    Should contain    ${response}    C: WAIT FOR 0x00 OK


Check for pppoe interface in ue appserv
    [Documentation]    :Author:  Vasileios Papoutsis
    [Arguments]    ${ue_id}=${0}    ${mue_id}=${0}    ${ue_appserv_alias}=ue-appserv    ${timeout}=120s
    connect.Connect to UE application server    ue_id=${0}    alias=${ue_appserv_alias}
    ssh.send_command    command=sudo ifconfig ppp${mue_id}    connection=${ue_appserv_alias}
    ${output_match}=     Set Variable    ppp${mue_id}
    ${output}=    ssh.read output until    ${output_match}    timeout=${timeout}    connection=${ue_appserv_alias}
    Wait until keyword succeeds    2min  10s    Check for pppoe connection message    ue_id=${ue_id}    mue_id=${mue_id}
    ssh.disconnect    connection=${ue_appserv_alias}



Check for pppoe connection message
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${ue_id}=${0}    ${mue_id}=${0}
    ${rci_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    ${responses}=    rci.read_responses    alias=${rci_alias}
    Should match regexp    string=${responses}    pattern=CMPI DTE PPPOE CONNECTION IND\: UE Id\: ${mue_id}


Start pppoe
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${ue_id}=${0}    ${mue_id}=${0}    ${ue_appserv_alias}=ue-appserv
    connect.Connect to UE application server    ue_id=${ue_id}    alias=${ue_appserv_alias}
    ${pppoe_script}=    Get pppoe script    ue_id=${ue_id}    mue_id=${mue_id}    ue_appserv_alias=${ue_appserv_alias}
    ssh.send_command    command=sudo pon ${pppoe_script}    connection=${ue_appserv_alias}
    ${output_match}=     Set Variable    Plugin rp-pppoe.so loaded
    ${error out}=    ssh.read output until    ${output_match}    timeout=5s    connection=${ue_appserv_alias}
    ssh.disconnect    connection=${ue_appserv_alias}


Stop all pppoe
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${ue_id}=${0}    ${ue_appserv_alias}=ue-appserv
    connect.Connect to UE application server    ue_id=${ue_id}    alias=${ue_appserv_alias}
    ${response}=    ssh.execute    command=sudo pkill -9 pppd    connection=${ue_appserv_alias}
    ssh.disconnect    connection=${ue_appserv_alias}


Stop pppoe
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${ue_id}=${0}    ${mue_id}=${0}    ${ue_appserv_alias}=ue-appserv
    connect.Connect to UE application server    ue_id=${ue_id}    alias=${ue_appserv_alias}
    ${pppoe_script}=    Get pppoe script    ue_id=${ue_id}    mue_id=${mue_id}    ue_appserv_alias=${ue_appserv_alias}
    Wait until keyword succeeds    5 min    3 sec    Check that pppoe is stopped
    ...    pppoe_script=${pppoe_script}    ue_appserv_alias=${ue_appserv_alias}
    ssh.disconnect    connection=${ue_appserv_alias}


Check that pppoe is stopped
    [Documentation]    :Author: Vasileios Papoutsis, [PRIVATE]
    [Arguments]    ${pppoe_script}    ${ue_appserv_alias}
    ssh.send_command    command=sudo poff ${pppoe_script}    connection=${ue_appserv_alias}
    ${output}=    ssh.read_output    connection=${ue_appserv_alias}
    Should contain    ${output}    None stopped.


Trigger measurement event to enable sgNB addition
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Trigger measuremet event to enable the sgNB addition after Ue is attached to LTE cell
    ...
    ...    :param target_cell: gNB cell in which sgNB additon happens
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param rsrp: (default=110) RSRP vaqlue in dB
    ...
    [Arguments]    ${target_cell}    ${ue_id}=${0}    ${rsrp}=${110}  ${measurement_id}=${17}

    BuiltIn.Log     Start sgNB addition process to cell ${target_cell}  console=${P_console}
    ${rci_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    ${cmdStr}=    Set variable    forw mte RrcAptTriggerMeasEvent 1 ${measurement_id} 0 [61] [26] [5(1{${target_cell} [${rsrp}] [] [] []})]
    ${response}=    rci.send_command    command=${cmdStr}    alias=${rci_alias}
    Should contain    ${response}    C: FORW 0x00 Ok MTE RRCAPTTRIGGERMEASEVENT: RETURN CODE:0 SUCCEEDED
    ${response}=    rci.send_command    command=forw mte Activate -1    alias=${rci_alias}
    Should contain    ${response}    C: FORW 0x00 Ok MTE ACTIVATE CNF: RETURN CODE:0
    Wait until keyword succeeds    1min  10s    Check for random access complete message    ${rci_alias}
    BuiltIn.Log     sgNB addition process to cell ${target_cell} is completed!  console=${P_console}


Trigger measurement report to perform handover
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param source_cell: Source cell for handover
    ...    :param source_gnb: (default=0) Source gNB for handover
    ...    :param target_cell:  Target cell for handover
    ...    :param path_to_cell_search_script: Cell search script used to initialize Viavi
    ...    :param a2_meas_id: Id of A2 measurement configuration inside RRC message
    ...    :param a3_meas_id: Id of A3 measurement configuration inside RRC message
    ...    :param number_of_handovers: (default=1) Number of handovers to run
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param source_cell_rsrp: SS-RSRP results as defined in TS 38.215 [9], per NR source cell
    ...    :param source_cell_rsrq: SS-RSRQ results as defined in TS 38.215 [9], per NR source cell
    ...    :param source_cell_sinr: SS-SINR results as defined in TS 38.215 [9], per NR source cell
    ...    :param target_cell_rsrp: SS-RSRP results as defined in TS 38.215 [9], per NR target cell
    ...    :param target_cell_rsrq: SS-RSRQ results as defined in TS 38.215 [9], per NR target cell
    ...    :param target_cell_sinr: SS-SINR results as defined in TS 38.215 [9], per NR target cell
    ...    :param report_interval: (default=0 - 120ms) Indicates the interval between periodical reports
    ...
    [Arguments]    ${source_cell}    ${target_cell}    ${path_to_cell_search_script}    ${a2_meas_id}=${EMPTY}    ${a3_meas_id}=${EMPTY}
    ...    ${source_gnb}=${0}    ${num_of_handovers}=${1}    ${ue_id}=${0}    ${source_cell_rsrp}=${60}    ${source_cell_rsrq}=${53}
    ...    ${source_cell_sinr}=${35}    ${target_cell_rsrp}=${66}    ${target_cell_rsrq}=${57}    ${target_cell_sinr}=${44}
    ...    ${report_interval}=${0}
    ${rci_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    ${result}=    Is inter frequency handover    source_cell=${source_cell}    target_cell=${target_cell}
    ...    path_to_cell_search_script=${path_to_cell_search_script}
    FOR    ${handover_idx}    IN RANGE    ${num_of_handovers}
        BuiltIn.Log    Start handover from source cell ${source_cell} to target cell ${target_cell}    console=${P_console}
        ${a3_measurement_id}=    Run keyword if    ${result}    Trigger a2 measurement report    source_cell=${source_cell}
        ...    a2_meas_id=${a2_meas_id}    ue_id=${ue_id}    source_gnb=${source_gnb}
        ${a3_meas_id}=    Set variable if    "${a3_meas_id}"!="${EMPTY}"    ${a3_meas_id}    ${a3_measurement_id}
        ${cmdStr}=    Catenate
        ...    forw mte NrRrcAptTriggerMeasReport ${a3_meas_id} 0 0 ${report_interval} 1{0 [${source_cell}] [[60] [53] [35]] [] [[1{0[[60]
        ...    [] []]}] []] [] []} [0(1{[${target_cell}] [[${target_cell_rsrp}] [${target_cell_rsrq}] [${target_cell_sinr}]]
        ...    [][ [1{0[[62] [] []]}] [] ] })]
        ${response}=    rci.send_command    command=${cmdStr}    alias=${rci_alias}
        Should contain    ${response}    C: FORW 0x00 Ok MTE NRRRCAPTTRIGGERMEASREPORT: RETURN CODE:0 SUCCEEDED
        ${response}=    rci.send_command    command=forw mte Activate -1    alias=${rci_alias}
        Should contain    ${response}    C: FORW 0x00 Ok MTE ACTIVATE CNF: RETURN CODE:0
        Wait until keyword succeeds    1min  10s    Check for random access complete message    ${rci_alias}
        BuiltIn.Log    Handover from source cell ${source_cell} to target cell ${target_cell} is successful!   console=${P_console}
        ${tmp_source_cell}=    Set variable    ${source_cell}
        ${source_cell}=    Set variable    ${target_cell}
        ${target_cell}=    Set variable    ${tmp_source_cell}
        Sleep    5s    reason=Wait for handover
    END

Trigger a2 measurement report
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param source_cell: Source cell to trigger the A2 measurement report
    ...    :param a2_meas_id: Id of A2 measurement configuration inside RRC message
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param source_gnb: (default=0) Source gNB for handover
    ...
    [Arguments]    ${source_cell}    ${a2_meas_id}=${1}    ${ue_id}=${0}    ${source_gnb}=${0}
    ${collector}=    tcpdump.Start Tcpdump on gNB Common Unit    interface=fp0    option=-s0 sctp    collector=common_unit-fp0-tcpdump-a3
    ...    gnb_id=${source_gnb}    du_id=${0}    comu_id=${0}
    Sleep    5s
    ${rci_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    ${cmdStr}=    Catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 0 1{8 [${source_cell}] [[60]
    ...    [53] [35]] [] [[1{4[[60] [] []]}] []] [] []} []
    ${response}=    rci.send_command    command=${cmdStr}    alias=${rci_alias}
    Should contain    ${response}    C: FORW 0x00 Ok MTE NRRRCAPTTRIGGERMEASREPORT: RETURN CODE:0 SUCCEEDED
    ${response}=    rci.send_command    command=forw mte Activate -1    alias=${rci_alias}
    Should contain    ${response}    C: FORW 0x00 Ok MTE ACTIVATE CNF: RETURN CODE:0
    Sleep    20s
    ${tc_log_dir}=    testline.Get testcase log directory
    tcpdump.Stop Tcpdump on gNB Common Unit    collector=${collector}    target_dir=${tc_log_dir}
    util.Convert PCAP to PDML    source=${tc_log_dir}/common_unit-fp0-tcpdump-a3.pcap
    ...    target=${tc_log_dir}/common_unit-fp0-tcpdump-a3.pdml
    ${a3_measurement_id}=    pdml_file.Find a3 measurement id    pdml_file_path=${tc_log_dir}/common_unit-fp0-tcpdump-a3.pdml
    [Return]    ${a3_measurement_id}


Is inter frequency handover
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param source_cell: Source cell for handover
    ...    :param target_cell:  Target cell for handover
    ...    :param path_to_cell_search_script: Cell search script used to initialize Viavi
    ...
    [Arguments]    ${source_cell}    ${target_cell}    ${path_to_cell_search_script}
    ${cell_search_script_contents}=    Get file    ${path_to_cell_search_script}
    ${source_cell_frequency_list}=    Get regexp matches    ${cell_search_script_contents}
    ...    forw mte NrSetMueRadioContextCell \\d ${source_cell} (\\d+\\.?\\d+)    1
    ${source_cell_frequency}=    Get from list    ${source_cell_frequency_list}    0
    ${target_cell_frequency_list}=    Get regexp matches    ${cell_search_script_contents}
    ...    forw mte NrSetMueRadioContextCell \\d ${target_cell} (\\d+\\.?\\d+)    1
    ${target_cell_frequency}=    Get from list    ${target_cell_frequency_list}    0
    ${result}=    Set variable if    '${source_cell_frequency}'!='${target_cell_frequency}'    ${True}    ${False}
    [Return]    ${result}


Check for random access complete message
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${rci_alias}
    ${responses}=    rci.read_responses    alias=${rci_alias}
    Should match regexp    string=${responses}    pattern=Random Access Complete


Override CSI Report
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${cqi1}=8   ${rank_indicator}=1   ${pmi}=${EMPTY}  ${ue_id}=${0}    ${mue_id}=${0}  ${cqi2}=${EMPTY}

    ${rci_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    ${csioverride}=    Set variable
    ...    forw mte NrConfigCsiOverride [] [1{0 [] [] [] [${rank_indicator}] [] [[${cqi1}] [${cqi2}]] [] [[${pmi}] [] [] [] []] [] }] [0]
    ${response}=    rci.send_command    command=forw mte SetUEContext ${mue_id}    alias=${rci_alias}    timeout=5min
    ${response}=    rci.send_command    command=${csioverride}    alias=${rci_alias}    timeout=5min
    Sleep    1s  # Sleep to allow changes on Viavi


Set pathloss
    [Documentation]    :Author: Vasileios Papoutsis
    ...    set pathloss, range: 10..180; default:10
    [Arguments]    ${pathloss}    ${ue_id}=${0}    ${mue_id}=${0}

    ${rci_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    ${pathlosscommand}=    Set variable    forw mte NrPhyConfigPathLoss 1{${mue_id} -1(${pathloss})}
    ${response}=    rci.send_command    command=${pathlosscommand}    alias=${rci_alias}


Set UL Interference for all UEs
    [Documentation]    :Author: Vasileios Papoutsis
    ...    enable and set Uplink Interference Generator level , range -43 .. -27, default -37
    ...    per Radio card, absolute level depends on card configuration (dedicated or combined)
    [Arguments]    ${noiselevel}    ${ue_id}=${0}    ${mue_id}=${0}

    ${rci_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    ${noiselevelcommand}=    Set variable    forw mte NrPhyConfigUlInterference 1 (${noiseLevel}) [1]
    ${response}=    rci.send_command    command=${noiselevelcommand}    alias=${rci_alias}


Simultate DL BLER rate
    [Documentation]    :Author: Vasileios Papoutsis
    ...    set DL BLER on all HARQ in %   set to NACK mode, CRC corruption, all HARQIDs, all radio context
    ...    range 0..100 % ,
    [Arguments]    ${dlbler}    ${ue_id}=${0}    ${mue_id}=${0}

    ${rci_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    rci.send_command    command=forw mte SetUEContext ${mue_id}    alias=${rci_alias}
    ${dlblercommand}=    Set variable    forw mte NrHarqConfigDlSchForceErrors 1(1 -1 ${dlbler})
    ${response}=    rci.send_command    command=${dlblercommand}    alias=${rci_alias}


Get Viavi Ue Alias
    [Documentation]    :Author: Vasileios Papoutsis
    ...    :param  ue_id: (default 0) the ID of Viavi UE, Integer or String
    ...    :return: ue alias for ute_ue
    [Arguments]    ${ue_id}=${0}
    ${ue_alias}=    Set Variable    Viavi_${ue_id}
    [Return]    ${ue_alias}


Get pppoe script
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${ue_id}=${0}    ${mue_id}=${0}    ${ue_appserv_alias}=ue-appserv
    ssh.send_command    command=sudo ls /etc/ppp/peers/    connection=${ue_appserv_alias}
    ${output}=    ssh.read_output    connection=${ue_appserv_alias}
    @{files}=    Split String	   ${output}    separator=\n
    ${core_ip}=    testline.increment_ip    ${tl.ues[${ue_id}].iperf_details.network_interface_address}    ${mue_id}
    FOR    ${file}    IN    @{files}
        ssh.send_command    command=sudo cat /etc/ppp/peers/${file}    connection=${ue_appserv_alias}
        ${output}=    ssh.read_output    connection=${ue_appserv_alias}
        ${pppoe_script}=    Set Variable If    "${core_ip}" in """${output}"""    ${file}
        Exit for loop if    "${core_ip}" in """${output}"""
    END
    Run keyword if    '${pppoe_script}'=='None'    Fail    msg=PPPoE script could not be found!
    [Return]    ${pppoe_script}


Terminate Viavi UE
    [Documentation]    :Author: Srihari Janardhan
    ...  This keyword disconnects the rci connection to the TM500 and kills the TMA application
    ...  :param ue_id: (default=0) UE Id in __init__.py
    [Arguments]     ${ue_id}=0
    ${ue_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    BuiltIn.Log    Start ${ue_alias} termination    console=${P_console}
    rci.disconnect    alias=${ue_alias}
    Kill TMA application
    BuiltIn.Log    ${ue_alias} is terminated!    console=${P_console}


Trigger NSA attach using Viavi UE
    [Documentation]    :Author: Srihari Janardhan
    ...  This keyword triggers an LTE attach and subsequently an Sgnb addition to the desired 5G target cell
    [Arguments]  ${ue_id}=0  ${mue_id}=0  ${nr_target_cell}=50  ${measurement_id}=17
    Attach Viavi UE  ue_id=${ue_id}  mue_id=${mue_id}
    # ${measurement_id}= TODO: Determine measurement ID based on target cell
    Trigger measurement event to enable sgNB addition  target_cell=${nr_target_cell}  measurement_id=${measurement_id}
    Sleep  10s    reason=Give sometime for the sgNB addition to be completed


Detach All UEs
    [Documentation]    :Author: Srihari Janardhan
    ...    Detaches all simulated UEs
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param number_of_ues: (default=1) Number of Viavi UEs
    ...
    [Arguments]    ${ue_id}=${0}    ${number_of_ues}=${1}
    FOR  ${P_mue}  IN RANGE  ${number_of_ues}
        Detach Viavi UE    ue_id=${ue_id}    mue_id=${P_mue}
    END

Send Viavi common UEs post configuration
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param path_to_common_ues_config_script: Common UEs configuration script
    ...    :param ue_id: (default 0) the ID of UE in __init__.py, Integer or String
    ...
    [Arguments]    ${path_to_common_ues_config_script}    ${ue_id}=${0}
    ${ue_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    BuiltIn.Log     Send ${ue_alias} common configuration script for UEs    console=${P_console}
    ${response}=    rci.send script    filename=${path_to_common_ues_config_script}
    ...    alias=${ue_alias}    timeout=2min
    Should Not Contain Any    ${response}    failure    Failure
    BuiltIn.Log    ${ue_alias} common configuration script for UEs is sent!    console=${P_console}


Send Viavi Script
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param viavi_script_path: Path to Viavi script
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...
    [Arguments]    ${viavi_script_path}    ${ue_id}=${0}
    ${ue_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    ${response}=    rci.send script    filename=${viavi_script_path}    alias=${ue_alias}    timeout=5min
    BuiltIn.Log    ${response}


Send Viavi Command
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param viavi_command: Viavi command
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...
    [Arguments]    ${viavi_command}    ${ue_id}=${0}
    ${ue_alias}=    Get Viavi Ue Alias    ue_id=${ue_id}
    ${response}=    rci.send_command    command=${viavi_command}    alias=${ue_alias}    timeout=5min
    BuiltIn.Log    ${response}


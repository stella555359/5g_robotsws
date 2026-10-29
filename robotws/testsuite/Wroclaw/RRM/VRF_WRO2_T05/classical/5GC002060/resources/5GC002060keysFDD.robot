*** Settings ***
Documentation
...             Usefull keywords for 5GC002060 management

Library         BuiltIn
Library         OperatingSystem
Library         Process
Library         Collections
Library         String
Library         XML
Library         ArchiveLibrary
Library         SSHLibrary                              WITH NAME       robssh
Library         taf.transport.ssh                       WITH NAME       ssh
Library         taf.sbts.oam.coam.admin                  WITH NAME       coam
#Library         taf.selenium.gnb.oam.coam.classical     WITH NAME       selenium_coam
Library         taf.selenium.sbts                       WITH NAME       selenium_coam
Library         taf.collectors.core                     WITH NAME       core
Library         taf.collectors.tcpdump                  WITH NAME       tcpdump
Library         taf.config.scf                          WITH NAME       scf
Library         list_gNodeB_alarms.py
Library         ute_ue


*** Variables ***
${pcap_file} =  logs.pcap

*** Keywords ***
Do Attach UE
    Run Keyword if  '${uetype}'=='smartphone'   Attach Ue   UE_1
    ...             ELSE                    Attach CPE
    sleep       5s
    Log         UE Attached

Do Detach UE
    Run Keyword if  '${uetype}'=='smartphone'   Detach Ue   UE_1
    ...             ELSE                    Detach CPE
    Log         UE Detached

Do Require UE
    [Arguments]     ${capabilities}=REAL_QUALCOMM_UE
    Require Ue      UE_1    capabilities=${capabilities}
    Log             UE available

Check if gNB is OnAir GUI
    ${BTSSTATUS}        selenium_coam.get bts status
    Log                 \nBTS Status : ${BTSSTATUS}
    Should Be Equal     ${BTSSTATUS}    On air    ignore_case=True

check value in scf by dist_name
  [Arguments]           ${Dist_Name}      ${Parameter_Name}      ${Parameter_Value}
  Log
  ...   \nChecking feature parameter dist_name=${Dist_Name}, ${Parameter_Name} is equal to ${Parameter_Value}
  ${val}=               scf.get_value_from_scf      dist_name=${Dist_Name}     p_name=${Parameter_Name}
  Log                   ${Parameter_Name} = ${val}
  Should be equal       ${val}                      ${Parameter_Value}

get and validate scf file
  [Arguments]           ${SCF_Filename}
  coam.Connect to                 name=cOAM
  Log                   \nGet scf file ${SCF_Filename} and copy it to ${Log_directory}
  coam.get_current_scf_file    ${Log_directory}     ${SCF_Filename}     connection=cOAM
  scf.load_scf          ${Log_directory}/${SCF_Filename}
  ${result}=            coam.validate_scf                ${Log_directory}/${SCF_Filename}    connection=cOAM
  Log                   Validation result = ${result}
  coam.Teardown                   connection=cOAM
  [return]              ${result}

get value in scf by dist_name
  [Arguments]           ${Dist_Name}      ${Parameter_Name}
  Log                   \nGet initial feature parameter value of dist_name=${Dist_Name}, p_name=${Parameter_Name}
  ${val}=               scf.get_value_from_scf      dist_name=${Dist_Name}            p_name=${Parameter_Name}
  Log                   ${Parameter_Name}=${val}

list active alarms
    [Tags]                alarms
    coam.Connect to                 name=cOAM
    ${alarm_result}=      coam.get_active_alarms
    Log                   List of alarms=${alarm_result}
    ${faulty_result}=     list_alarms           ${alarm_result}
    Run keyword if        ${faulty_result}==${True}        Log       Major or critical alarm present
    Should not be True    ${faulty_result}      ${False}
    coam.Teardown                   connection=cOAM

Set Board Name
    coam.Connect to                 name=cOAM
    ${hrdinfo}                              coam.get detected hw info     connection=cOAM
    ${sysmod}       Get From Dictionary         ${hrdinfo}          systemModules
    ${boardname}    Get From Dictionary         ${sysmod[0]}        productName
    ${boardname}    Get Substring               ${boardname}        0   4
    Log                                     \nBoardName ${boardname}     formatter=repr
    Set Suite Variable
    ...             ${boardname}            ${boardname}
    coam.Teardown                   connection=cOAM

modify value in scf by dist_name
  [Arguments]           ${Dist_Name}      ${Parameter_Name}      ${Parameter_Value}
  scf.modify_scf_element    value=${Parameter_Value}             dist_name=${Dist_Name}        p_name=${Parameter_Name}

scf uploading and commissioning
    [Tags]                          commissioning
    [Arguments]                     ${SCF_Filename}     ${tcpdumpguard}=${false}
    coam.Connect to                 name=cOAM
    Log                             \nCommissioning gNodeB with ${Log_directory}/${SCF_Filename}
    ${time}=                        Get Time
    Log                             \nStart commissioning at ${time} => allowed time 15'\n
    coam.perform_commissioning      scf_file=${Log_directory}/${SCF_Filename}    timeout=900    connection=cOAM
    ${time}=                        Get Time
    Log                             \nCommissioning end at ${time}\n
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             ssh.connect_to    hostname=${ip_addr}   username=toor4nsn  password=oZPS0POrRieRtu
    ...                             alias=OAM-conn
    ${time}=                        Get Time
    Log                             \nssh connection succeeded at at ${time}
    Wait Until Keyword Succeeds     60 s    5 s    coam.connect to   bts_host=${ip_addr}
    ${time}=                        Get Time
    Sleep                           5 min
    Log                             \ncoam connection succeeded at at ${time}
    ${BRWSRVW}=                     Get Variable Value      ${BRWSRVW}
    Run Keyword if                  $BRWSRVW is None
    ...                             selenium_coam.enable_virtual_display
    Wait Until Keyword Succeeds     12x     30s    selenium_coam.Login
    ...                             url=https://${ip_addr}    username=Nemuadmin    password=nemuuser
    ${time}=                        Get Time
    Log                             \nWebEM connection succeeded at at ${time}
    Wait Until Keyword Succeeds     15x     60s    Check if gNB is OnAir GUI
    ${startview}                    selenium_coam.start up view window exists
    Run keyword if                  ${startview}        selenium_coam.close start up view window
    Wait Until Keyword Succeeds     12x     30s    selenium_coam.logout         click_timeout=20
    Run Keyword if                  ${tcpdumpguard}
    ...                             Log     wait 5 mn (otherwise can get issues with tcpdump)
    Run Keyword if                  ${tcpdumpguard}
    ...                             Sleep   5 min
    coam.Teardown                   connection=cOAM
    [Teardown]                      Run Keyword if      $BRWSRVW is None
    ...                             selenium_coam.disable_virtual_display

validate modified values
  [Arguments]           ${SCF_Filename}
  Log                   \nSaving to ${Log_directory}/${SCF_Filename} and validating
  coam.Connect to                 name=cOAM
  scf.save_scf          ${Log_directory}/${SCF_Filename}    connection=cOAM
  ${result}=            coam.validate_scf                ${Log_directory}/${SCF_Filename}    connection=cOAM
  Log                   Validation result = ${result}
  coam.Teardown                   connection=cOAM
  [return]              ${result}

validate modified values with pdl error
  [Arguments]           ${SCF_Filename}
  Log                   \nSaving to ${Log_directory}/${SCF_Filename} and validating
  coam.Connect to                 name=cOAM
  scf.save_scf          ${Log_directory}/${SCF_Filename}    connection=cOAM
  ##### 20b branch ######
#  ${result}=            Run Keyword And Expect Error      *pdlValidationResult': {'logs': {'relationErrors'*
#  ...                   coam.validate_scf        ${Log_directory}/${SCF_Filename}     connection=cOAM

  ##### trunk branch #####
#  ${result}=            Run Keyword And Expect Error      *pdlValidationResult': {u'status': u'FAIL'*
#  ...                   coam.validate_scf        ${Log_directory}/${SCF_Filename}     connection=cOAM

  ##### all branches ######
  ${result}=            Run Keyword And Expect Error      *pdlValidationResult*
  ...                   coam.validate_scf        ${Log_directory}/${SCF_Filename}     connection=cOAM

  Log                   Validation result = ${result}
  coam.Teardown                   connection=cOAM
  [return]              ${result}



Get list of all cells
    coam.Connect to                 name=cOAM
    ${cells}    coam.Get parameters for all    NRCEL   connection=cOAM
    ${cells_id}    Create List
    #${cell}        Set Variable     ${EMPTY}
    FOR    ${cell}    IN    @{cells}
        ${cell_id}    Get From Dictionary    ${cell}    configurationId
        Append To List   ${cells_id}    NRCELL-${cell_id}
    END
    coam.Teardown                   connection=cOAM
    [Return]    ${cells_id}

Get list of all cellsgroup
    coam.Connect to                 name=cOAM
    ${cellgrps}    coam.Get parameters for all    NRCELLGRP   connection=cOAM
    ${cellgrps_id}    Create List
    FOR    ${cellgrp}    IN    @{cellgrps}
         ${cellgrp_id}    Get From Dictionary    ${cellgrp}    name
         Append To List   ${cellgrps_id}    ${cellgrp_id}
    END
    coam.Teardown                   connection=cOAM
    [Return]    ${cellgrps_id}

Set edrx parameters
    [Arguments]     ${EDRXCONFIG}=DLC160        ${cells_id}=${empty}    ${cellgrps_id}=${empty}
    ${edrxcfg}      Get From Dictionary         ${params5GC002060}      ${EDRXCONFIG}
    #log             ${edrxcfg}\n                formatter=repr

    Set branches params     ${edrxcfg}          cells_id=@{cells_id}    cellgrps_id=@{cellgrps_id}

Attach UE and Verify DRx parameters
    [Arguments]         ${EDRXCONFIG}=DLC160
    ${edrxcfgfull}      Get From Dictionary         ${params5GC002060}      ${EDRXCONFIG}
    log                 ${edrxcfgfull}\n            formatter=repr
    ${edrxf1apcfg}      Get From Dictionary         ${edrxcfgfull}          F1APSETUP
    log                 ${edrxf1apcfg}\n            formatter=repr
    ${edrxf1apval}      Get From Dictionary         ${edrxf1apcfg}          setupvalue
    log                 ${edrxf1apval}\n            formatter=repr
    Run Keyword If          '${boardname}' == 'ASIK'        Pcap collection 2
    sleep  5s
    sleep  5s
    Attach Ue   UE_1
    sleep  5s
    Run Keyword If          '${boardname}' == 'ASIK'        Pcap log downlad 2
    sleep  5s
    wait until keyword succeeds     2 min       5 s     cap.read_cap
    ...                             cap_file=${OUTPUT DIR}/${SUITE NAME}/${TEST_NAME}/pcap_logs2.pcap
    ...                             tshark_path=/usr/bin/tshark
    ...                             X=lua_script:/opt/luashark/
    ...                             display_filter=f1ap
    ${ReadValues}=                  cap.get_element_value   nr-rrc.drx_Config
#    ${ReadValues_Str}=              Convert To String    ${ReadValues}[0]
#    ${CuttedReadValues_str}=    Get Substring  ${ReadValues_Str}    start=0   end=-2
#    ${CuttedReadValues}=        Create List   ${CuttedReadValues_str}
#    log                             \nConfiguration value ${CuttedReadValues}
#    should be equal                 ${CuttedReadValues}[0]    ${edrxf1apval}

Pcap collection
    [Arguments]         ${alias}=ASIB       ${filename}=pcap_logs.pcap
    Connect to SMOD     alias=${alias}
    ssh.send command    command=nohup tcpdump -i any -w /tmp/${filename} &  connection=${alias}

Pcap log downlad
    [Arguments]          ${alias}=ASIB      ${filename}=pcap_logs.pcap
                  ...    ${dir}=${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/${filename}
    ssh.execute          command=killall tcpdump   connection=${alias}
    sleep  2s
    Create Directory     ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}
    sleep  2s
    ssh.download_file    /tmp/${filename}   ${dir}    connection=${alias}

Pcap collection 2
    [Arguments]         ${alias}=ASIB       ${filename}=pcap_logs2.pcap
    Connect to SMOD     alias=${alias}
    ssh.send command    command=nohup tcpdump -U -i any proto 0x84 -w /tmp/${filename} &  connection=${alias}


Pcap log downlad 2
    [Arguments]          ${alias}=ASIB      ${filename}=pcap_logs2.pcap
                  ...    ${dir}=${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/${filename}
    ssh.execute          command=killall tcpdump   connection=${alias}
    sleep  2s
    Create Directory     ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}
    sleep  2s
    ssh.download_file    /tmp/${filename}   ${dir}    connection=${alias}

Start SCTP Dump
    ssh.connect_to      hostname=${ip_addr}       username=toor4nsn    password=oZPS0POrRieRtu
    ...                 alias=OAM-conn
    ssh.send_command    command=tcpdump -U -i any proto 0x84 -w /tmp/SCTP_Dump.pcap &    connection=OAM-conn
    ssh.send_command    command=exit        connection=OAM-conn

Get SCTP Dump
    ssh.connect_to      hostname=${ip_addr}       username=toor4nsn    password=oZPS0POrRieRtu
    ...                 alias=OAM-conn
    ${file_presence}=   ssh.file_exists     /tmp/SCTP_Dump.pcap       connection=OAM-conn
    should be equal     ${file_presence}    ${True}
    ssh.download_file   remote_path=/tmp/SCTP_Dump.pcap    local_path=${OUTPUT DIR}/SCTP_Dump.pcap
    ...                 connection=OAM-conn
    ssh.execute         command=sudo rm -rf /tmp/SCTP_Dump.pcap  timeout=30    connection=OAM-conn
    ssh.send_command    command=exit    connection=OAM-conn

Stop SCTP Dump
    ssh.connect_to      hostname=${ip_addr}       username=toor4nsn    password=oZPS0POrRieRtu
    ...                 alias=OAM-conn
    ssh.send command    command=pkill tcpdump    timeout=30    connection=OAM-conn
    ssh.send_command    command=exit    connection=OAM-conn

Start Slv SCTP Dump
    ssh.connect_to      hostname=${ip_addr}       username=toor4nsn    password=oZPS0POrRieRtu
    ...                 alias=OAM-conn
    ssh.connect_to      hostname=192.168.253.2    username=toor4nsn    password=oZPS0POrRieRtu
    ...                 proxy=OAM-conn            alias=SLV-conn
    ssh.send_command    command=tcpdump -U -i any proto 0x84 -w /tmp/SCTP_Dump.pcap &    connection=SLV-conn
    ssh.send_command    command=exit        connection=SLV-conn
    ssh.send_command    command=exit        connection=OAM-conn

Get Slv SCTP Dump
    ssh.connect_to      hostname=${ip_addr}       username=toor4nsn    password=oZPS0POrRieRtu
    ...                 alias=OAM-conn
    ssh.connect_to      hostname=192.168.253.2    username=toor4nsn    password=oZPS0POrRieRtu
    ...                 proxy=OAM-conn            alias=SLV-conn
    ${file_presence}=   ssh.file_exists     /tmp/SCTP_Dump.pcap       connection=SLV-conn
    should be equal     ${file_presence}    ${True}
    ssh.download_file   remote_path=/tmp/SCTP_Dump.pcap    local_path=${OUTPUT DIR}/SCTP_Dump.pcap
    ...                 connection=SLV-conn
    ssh.execute         command=sudo rm -rf /tmp/SCTP_Dump.pcap  timeout=30    connection=SLV-conn
    ssh.send_command    command=exit    connection=SLV-conn
    ssh.send_command    command=exit    connection=OAM-conn

Stop Slv SCTP Dump
    ssh.connect_to      hostname=${ip_addr}       username=toor4nsn    password=oZPS0POrRieRtu
    ...                 alias=OAM-conn
    ssh.connect_to      hostname=192.168.253.2    username=toor4nsn    password=oZPS0POrRieRtu
    ...                 proxy=OAM-conn            alias=SLV-conn
    ssh.send command    command=pkill tcpdump    timeout=30    connection=SLV-conn
    ssh.send_command    command=exit    connection=SLV-conn
    ssh.send_command    command=exit    connection=OAM-conn

Gathering pcap
    [Arguments]         ${alias}=ASIB       ${filename}=pcaplog.pcap
    Connect to SMOD     alias=${alias}
    ssh.send command    command=tcpdump sctp -i any -w /tmp/${filename}     connection=${alias}

Pcap download
    [Arguments]          ${alias}=ASIB      ${filename}=pcaplog.pcap
                  ...    ${dir}=${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/${filename}
    ssh.execute          command=killall tcpdump   connection=${alias}
    sleep  2s
    Create Directory     ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}
    sleep  2s
    ssh.download_file    /tmp/${filename}   ${dir}    connection=${alias}

Get UE IP address from PCAP
    ${IP_UE}    check ue ip address  ${dir}
    return    ${IP_UE}

Get UE IP address from 157
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Open Connection      10.42.61.155
    ...                             escape_ansi=True            newline=CRLF
    ...                             alias=uepc
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Login
    ...                             username=wro5grrm      password=5gpass!1
    ${UE_IP}=    robssh.Execute Command  adb -s MTK_NSA shell ip a s |grep 192|awk '{print $2}'|awk -F "/" '{print $1}'
    robssh.Close Connection
    Log to console    ${UE_IP}
    [return]          ${UE_IP.replace("\r", " ")}

Get UE IP address from 154
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Open Connection      10.42.22.76
    ...                             escape_ansi=True            newline=CRLF
    ...                             alias=uepc
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Login
    ...                             username=wro5grrm      password=5gpass!1
    ${UE_IP}=    robssh.Execute Command    ipconfig |grep -i -A 4 "Ethernet 3"|grep IPv4|awk -F ": " '{print $2}'
    robssh.Close Connection
    Log to console    ${UE_IP}
    [return]          ${UE_IP.replace("\r", " ")}



Do DL ping
    [Arguments]     ${toipaddr}
    ...             ${intervalofpings}=5
    ...             ${numberofping}=25
    ${timeouttoused}=               Evaluate        ${numberofping} * ${intervalofpings} + 10
    # * remove bold in editor
    Log                             \ntimeout : ${timeouttoused}
    ${commandtolaunch}=
    ...   Set variable        ping -c ${numberofping} -i ${intervalofpings} ${toipaddr} | grep -E 'loss|rtt'
    Log                             \nCommand to launch : ${commandtolaunch}
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             ssh.connect_to              hostname=10.42.61.65
    ...                             username=5g    password=2019H@slo
    ...                             alias=Serv-conn
    ${output_from_remote}=
    ...  ssh.execute    command=${commandtolaunch}    connection=Serv-conn    timeout=${timeouttoused} s
    Log                             \n${output_from_remote}
    [return]                        ${output_from_remote}

Do UL ping
    [Arguments]     ${toipaddr}
    ...             ${intervalofpings}=5
    ...             ${numberofping}=25
    ${timeouttoused}=               Evaluate        ${numberofping} * ${intervalofpings} + 10
    # * remove bold in editor
    Log                             \ntimeout : ${timeouttoused}
    ${commandtolaunch}=             Set variable
    ...     adb shell "ping -c ${numberofping} -i ${intervalofpings} ${toipaddr} | grep -E 'loss|rtt'"
    Log                             \nCommand to launch : ${commandtolaunch}
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Open Connection      ${ip_addr_pcue}
    ...                             escape_ansi=True            newline=CRLF
    ...                             alias=PCUE-conn
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Login
    ...                             username=${pcue_uname}      password=${pcue_pswd}
    sleep                           2 s
    ${topurge}=                     robssh.Read
    robssh.Set client Configuration     prompt=${prompt_pc_ue}
    ${output_from_remote}=          robssh.Execute Command      adb root                timeout=30 s
    ${output_from_remote}=          robssh.Execute Command      ${commandtolaunch}      timeout=${timeouttoused} s
    Log                             \n${output_from_remote}
    robssh.Close Connection

    [return]                        ${output_from_remote}

Get average rtt
    [Arguments]         ${pingreport}
    log                 \String to scan : ${pingreport}
    ${averagertt}       Get Regexp Matches      ${pingreport}   [0123456789]{1,4}\.[0123456789]{1,3}
    log                 \n${averagertt}         formatter=repr
    [return]            ${averagertt[1]}

Verify no ping lost
    [arguments]         ${pingreport}
    ${pinglost}=        Get Regexp Matches      ${pingreport}   [0123456789]{1,3}%
    should be equal as strings      ${pinglost[0]}    0%

Verify latency
    [arguments]         ${reflatency}           ${checklalency}     ${EDRXCONFIG}=DLC160
    Log                 \nRef latency : ${reflatency}\nCheck latency : ${checklalency}      formatter=repr
    ${edrxcfg}          Get From Dictionary         ${params5GC002060}      ${EDRXCONFIG}
    log                 ${edrxcfg}\n                formatter=repr
    ${latency}          Get From Dictionary         ${edrxcfg}              LATENCY
    log                 ${latency}\n                formatter=repr
    ${maxlatency}       Get From Dictionary         ${latency}              maxlatency
    ${inducedlatency}   Evaluate                    "%.2f" % (${checklalency}*1.0 - ${reflatency}*1.0)
    Log                 \nInduced latency : ${inducedlatency}
    Should be true      ${inducedlatency} <= ${maxlatency}

Initialize UE params
    Set Suite Variable
    ...     ${uetype}       smartphone
    ${Dict_Keys}    Get Dictionary Keys  ${UE_POOLS}
    ${IsIn}         Run Keyword and Return Status
    ...             List Should Contain Value  ${Dict_Keys}  androidUePool
    Run Keyword if  ${IsIn}
    ...             Initalize UE Type android
    ${IsIn}         Run Keyword and Return Status
    ...             List Should Contain Value  ${Dict_Keys}  QualcommUePool
    Run Keyword if  ${IsIn}
    ...             Initalize UE Type Qualcomm

Initalize UE Type Qualcomm
    ${Dict_Keys}
    ...   Get Dictionary Keys  ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration}
    ${IsIn}         Run Keyword and Return Status
    ...             List Should Contain Value  ${Dict_Keys}     UE_Type
    Run Keyword if  ${IsIn}     Initalize CPE
    ...             ELSE        Do Require UE      capabilities=REAL_QUALCOMM_UE
    ${ser_typ}=
    ...   Set Variable     ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.ssh_type}
    ${type_windows}=            Set variable if     '${ser_typ}'=='windows'
    ...                         ${true}
    ...                         ${false}
    Set Suite Variable          ${winssh}           ${type_windows}
    Set Suite Variable
    ...     ${ip_addr_pcue}     ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.ue_pc_ip}
    Set Suite Variable
    ...     ${prompt_pc_ue}     ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.ue_pc_prompt}
    Set Suite Variable
    ...     ${pcue_uname}       ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.login}
    Set Suite Variable
    ...     ${pcue_pswd}        ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.password}
    Set Suite Variable
    ...     ${ip_addr_ue}       ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.data_transfer.ue_static_ip}
    Set Suite Variable
    ...     ${ip_wlan_server}   ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.data_transfer.iperf_interface_ip}
    Set Suite Variable
    ...     ${ip_addr_server}   ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.data_transfer.ssh.host}
    Set Suite Variable
    ...     ${server_uname}     ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.data_transfer.ssh.user}
    Set Suite Variable
    ...     ${server_pswd}      ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.data_transfer.ssh.password}

Initalize CPE
    ${Dict_Keys}    Get Dictionary Keys  ${UE_POOLS}
    ${imei}=
    ...   Set Variable    ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.IMEI}
    ${imsi}=
    ...   Set Variable    ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.IMSI}
    ${ip_addr_pcue}=
    ...   Set Variable    ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.ue_pc_ip}
    ${prompt_pc_ue}=
    ...  Set Variable    ${POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.ue_pc_prompt}
    ${pcue_uname}=
    ...   Set Variable    ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.login}
    ${pcue_pswd}=
    ...  Set Variable    ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.password}
    ${ip_addr_ue}=      Set Variable
    ...  ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.data_transfer.ue_static_ip}
    Set Suite Variable
    ...  ${uetype}   ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.UE_Type}
    Set Suite Variable
    ...  ${Ppython3}  ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.server_python3}
    Set Suite Variable
    ...     ${AT_port}       ${UE_POOLS.QualcommUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.AT_port}
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Open Connection      ${ip_addr_pcue}
    ...                             escape_ansi=True            newline=CRLF
    ...                             alias=PCUE-conn
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Login
    ...                             username=${pcue_uname}      password=${pcue_pswd}
    sleep                           2 s
    ${topurge}=                     robssh.Read
    robssh.Set client Configuration     prompt=${prompt_pc_ue}
    robssh.Put File                 ${CURDIR}/Require_UE.py      ./Mng_UE/Require_UE.py
    robssh.Put File                 ${CURDIR}/AttachUE.py        ./Mng_UE/AttachUE.py
    robssh.Put File                 ${CURDIR}/DettachUE.py       ./Mng_UE/DettachUE.py
    ${rc}=                          Execute Command
    ...         ${Ppython3} ./Mng_UE/Require_UE.py -p ${AT_port} -i ${imsi} -e ${imei}   return_stdout=False    return_rc=True
    Should Be Equal    ${rc}            ${0}
    robssh.Close Connection

Initalize UE Type android
    Do Require UE               capabilities=REAL_andROID_UE
    ${ser_typ}=
    ...   Set Variable        ${UE_POOLS.androidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.ssh_type}
    ${type_windows}=            Set variable if     '${ser_typ}'=='windows'
    ...                         ${true}
    ...                         ${false}
    Set Suite Variable          ${winssh}           ${type_windows}
    Set Suite Variable
    ...    ${ip_addr_pcue}   ${UE_POOLS.androidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.ue_pc_ip}
    Set Suite Variable     ${prompt_pc_ue}
    ...   ${UE_POOLS.androidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.ue_pc_prompt}
    Set Suite Variable
    ...     ${pcue_uname}       ${UE_POOLS.androidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.login}
    Set Suite Variable     ${pcue_pswd}
    ...        ${UE_POOLS.androidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.password}
    Set Suite Variable     ${ip_addr_ue}
    ...   ${UE_POOLS.androidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.data_transfer.ue_static_ip}
    Set Suite Variable   ${ip_wlan_server}   ${UE_POOLS.androidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.
    ...  configuration.data_transfer.iperf_interface_ip}
    Set Suite Variable    ${ip_addr_server}
    ...  ${UE_POOLS.androidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.data_transfer.ssh.host}
    Set Suite Variable     ${server_uname}
    ...   ${UE_POOLS.androidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.data_transfer.ssh.user}
    Set Suite Variable    ${server_pswd}
    ...   ${UE_POOLS.androidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.data_transfer.ssh.password}

Attach CPE
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Open Connection      ${ip_addr_pcue}
    ...                             escape_ansi=True            newline=CRLF
    ...                             alias=PCUE-conn
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Login
    ...                             username=${pcue_uname}      password=${pcue_pswd}
    sleep                           2 s
    ${topurge}=                     robssh.Read
    robssh.Set client Configuration     prompt=${prompt_pc_ue}
    ${rc}=                          Execute Command
    ...         ${Ppython3} ./Mng_UE/AttachUE.py -p ${AT_port} -i ${ip_addr_ue}   return_stdout=False    return_rc=True
    Should Be Equal    ${rc}            ${0}
    robssh.Close Connection

Detach CPE
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Open Connection      ${ip_addr_pcue}
    ...                             escape_ansi=True            newline=CRLF
    ...                             alias=PCUE-conn
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Login
    ...                             username=${pcue_uname}      password=${pcue_pswd}
    sleep                           2 s
    ${topurge}=                     robssh.Read
    robssh.Set client Configuration     prompt=${prompt_pc_ue}
    ${rc}=                          Execute Command
    ...         ${Ppython3} ./Mng_UE/DettachUE.py -p ${AT_port}     return_stdout=False    return_rc=True
    Should Be Equal    ${rc}            ${0}
    robssh.Close Connection

Get average Tput
    [arguments]     ${UL}=${false}
    ${cmdtosend}=   Set variable if     ${UL}
    ...     wsl /usr/bin/iperf3 -u -i 12 -t 252 -f k -p 34201 -l 1330 -b 200M -c ${ip_wlan_server} -B
    ...  ${ip_addr_ue} > ./Mng_UE/iperf_UL.txt
    ...     wsl /usr/bin/iperf3 -u -i 12 -R -t 252 -f k -p 34201 -l 1330 -b 800M -c ${ip_wlan_server} -B
    ...  ${ip_addr_ue} > ./Mng_UE/iperf_DL.txt
    ${filetoget}=   Set variable if     ${UL}       ./Mng_UE/iperf_UL.txt      ./Mng_UE/iperf_DL.txt
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Open Connection      ${ip_addr_pcue}
    ...                             escape_ansi=True            newline=CRLF
    ...                             alias=PCUE-conn
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Login
    ...                             username=${pcue_uname}      password=${pcue_pswd}
    sleep                           2 s
    ${topurge}=                     robssh.Read
    robssh.Set client Configuration     prompt=${prompt_pc_ue}
    ${rc}=                          Execute Command     wsl ping -c 10 -i 1 -I ${ip_addr_ue} ${ip_wlan_server}
    ...                             timeout=60 s    return_stdout=False    return_rc=True
    Should Be Equal                 ${rc}               ${0}
    ${rc}=
    ...   Execute Command     ${cmdtosend}        timeout=300 s    return_stdout=False    return_rc=True
    Should Be Equal                 ${rc}               ${0}
    robssh.Get File                 ${filetoget}        ./iperf_log.txt
    ${iperffile}=                   Grep File           ./iperf_log.txt     Kbits
    ${tputlist}=
    ...  Get Regexp Matches          ${iperffile}   MBytes +(?P<TPUT>[0123456789]+) Kbits       TPUT
    ${numbervalues}=                Get Length                  ${tputlist}
    Should be true                  ${numbervalues} > 15
    ${AvgTput}=                     Evaluate                    "%.2f" % 0.00
    FOR     ${idx}                  IN RANGE                    ${numbervalues}-15                  ${numbervalues}-5
        ${AvgTput}=                 Evaluate                    "%.2f" % (${AvgTput} + ${tputlist[${idx}]} * 1.0)
    # * remove bold in editor
    END
    ${AvgTput}=             Evaluate                    "%.2f" % (${AvgTput} / 10.0)
    Log                     \n${AvgTput}                formatter=repr
    robssh.Close Connection
    [return]                ${AvgTput}

Check value with uncertainty
    [arguments]     ${reference}    ${tocheck}      ${uncertainty}=10.00
    ${minvalue}=    Evaluate    "%.2f" % (${reference} * (1-${uncertainty}/100.0))
    ${maxvalue}=    Evaluate    "%.2f" % (${reference} * (1+${uncertainty}/100.0))
    Log to console      \nMin value : ${minvalue} Max value : ${maxvalue}
    Should be true      (${tocheck} <= ${maxvalue}) and (${tocheck} >= ${minvalue})

Wait for next pm period
    [Documentation]     This keyword first get the time in second from gNB. It
    ...                 then calculate how long time to wait to be some seconds before or after
    ...                 the next pm period (15 mn based). It then sleeps for this value
    ...                 Author : Philippe Maron   philippe.maron@nokia.com
    [Arguments]     ${guardtime}=30     ${before}=${true}
    #Connect to OAM
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             ssh.connect_to              hostname=${ip_addr}
    ...                             username=toor4nsn           password=oZPS0POrRieRtu
    ...                             alias=OAM-conn
    ${stdout}=                      ssh.execute                 command=date -u +"%s"
    ...                             connection=OAM-conn

    ${basetime}=                    Run Keyword if          ${before}
    ...                             Evaluate                (${stdout} + ${guardtime})
    ...                             ELSE
    ...                             Evaluate                (${stdout} - ${guardtime})
    ${timetowait}=                  Evaluate            900 - (${basetime} % 900)
    log                             time to wait : ${timetowait}
    sleep    ${timetowait}

Get last pm counter file and expand it
    Remove Directory                ${Log_directory}/Counters            recursive=${true}
    Create Directory                ${Log_directory}/Counters
    #Connect to OAM
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             ssh.connect_to              hostname=${ip_addr}
    ...                             username=toor4nsn           password=oZPS0POrRieRtu
    ...                             alias=OAM-conn
    ${stdout}=                      ssh.execute
    ...                             command=cd /tmp;ls -dr1 *PM*.xml.gz |head -1
    ...                             connection=OAM-conn
    ${stdout}=                      Strip string    ${stdout}   mode=right      characters=\r\n
    Log                             \nPM Gzipped file : ${stdout}
    ssh.download_file               remote_path=/tmp/${stdout}
    ...                             local_path=${Log_directory}/Counters/counters.xml.gz
    ...                             connection=OAM-conn
    Run and Return RC               gunzip ${Log_directory}/Counters/counters.xml.gz
    Log                             \nFile to analyze : ${Log_directory}/Counters/counters.xml

#/OMeS/PMSetup/PMMOResult/NE-WBTS_1.0/M55308C11001
Check 2060 PM counters
    [Arguments]         ${EDRXCONFIG}=DLC160
    ${edrxcfg}          Get From Dictionary         ${params5GC002060}      ${EDRXCONFIG}
    log                 ${edrxcfg}\n                formatter=repr
    ${refratio}         Get From Dictionary         ${edrxcfg}              SLOTRATIO
    log                 ${refratio}\n               formatter=repr
    ${minratio}         Get From Dictionary         ${refratio}             min
    ${maxratio}         Get From Dictionary         ${refratio}             max
    ${root} =           Parse XML                   ${Log_directory}/Counters/counters.xml
    @{DRxC11001}=       Get Elements Texts          ${root}     PMSetup/PMMOResult/NE-WBTS_1.0/M55308C11001
    @{DRxC11002}=       Get Elements Texts          ${root}     PMSetup/PMMOResult/NE-WBTS_1.0/M55308C11002
    ${numbercells}=     Get Length                  ${DRxC11001}
    ${nbunusedcells}=   Count Values In List        ${DRxC11001}        0
    #Should Not Be Equal As Integers                 ${numbercells}      ${nbunusedcells}
#    Length Should be    ${DRxC11002}                ${numbercells}
#    FOR     ${idx}      IN RANGE                    0                       ${numbercells}
#        ${ratio}=       Run Keyword if              '${DRxC11001[${idx}]}' != '0'
#        ...             Evaluate                    "%.2f" % (${DRxC11002[${idx}]}*1.0 / ${DRxC11001[${idx}]}*1.0)
#        Log             \n${ratio}
#        Run Keyword if  '${DRxC11001[${idx}]}' == '0'
#        ...     Should be Equal     ${DRxC11002[${idx}]}    ${DRxC11001[${idx}]}
#        ...     ELSE
#        ...     Should be true      (${ratio} <= ${maxratio}) and (${ratio} >= ${minratio})
#        log             \n${DRxC11001[${idx}]}\t${DRxC11002[${idx}]}        formatter=repr
#    END

Do FGCR8144 UL ping sequence
    ...              ${numberofping}=20
    ${timeouttoused}=               Evaluate    ${numberofping} + 10
    Log                             \ntimeout : ${timeouttoused}
    ${ue_sn}    common_kw.Get Ue Sn   capabilities=REAL_ANDROID_UE_NSA
    ${uepc_ip}  common_kw.Get Uepc Ip
    ${commandtolaunch}=             catenate
    ...  adb -s ${ue_sn} shell "ping -c ${numberofping}
    ...  10.42.197.170" |awk '/time=/ {gsub (/time=/,"",$7); print $7}'
    Log                             \nCommand to launch : ${commandtolaunch}

    #${commandtolaunch}=             Set Variable If     ${Iswindow}
    #...         wsl awk '/time=/ {gsub("time=","",$7); print $7}' PingRes${${toipaddr}}.txt
    #...         awk '/time=/ {gsub("time=","",$7); print $7}' PingRes${${toipaddr}}.txt
    #Log                             \nCommand to launch : ${commandtolaunch}
    Wait Until Keyword Succeeds  120 s    5 s
    ...  robssh.Open Connection    ${uepc_ip}
    ...  escape_ansi=True
    ...  newline=CRLF
    ...  alias=uepc

    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Login    username=wro5grrm
    ...                             password=5gpass!1
    Sleep   2s
    robssh.Read
    ${output_from_remote}=          robssh.Execute Command      ${commandtolaunch}
    Log                             \n${output_from_remote}
    robssh.Close Connection
    ${pingseq}=     Split To Lines      ${output_from_remote}
    Remove Values From List     ${pingseq}      ${empty}
    Log     ${pingseq}      formatter=repr
    Log List    ${pingseq}
    [return]                        ${pingseq}

Analyse FGCR8144 ping sequence
    [Arguments]         ${pingseq}
    ...                 ${WaitLatency}=160
    ${brpingseq}=       Get Slice From List     ${pingseq}      1
    Log List            ${brpingseq}
    ${rpingseq}         Create List
    FOR    ${val}    IN    @{brpingseq}
        ${valnum}                   Evaluate                    "% 10.2f" % ${val}
        Append To List   ${rpingseq}    ${valnum}
    END
    Sort List           ${rpingseq}
    Log List            ${rpingseq}
    ${seqlen}=          Get Length      ${rpingseq}
    Log                 ${seqlen}
    ${mdiff}=           Evaluate        ${rpingseq[${seqlen}-2]} - ${rpingseq[0]}
    Log                 ${mdiff}
    Should be true      ${mdiff} <= 160
    ${pdiff}=   Evaluate        ${pingseq[0]} - ${rpingseq[${seqlen} - 1]}
    # We allow that a drxon time is miss
    Should be true      ${pdiff} <= ${WaitLatency}
    # * Return the greatest "normal" ping latency and the latency of the first one
    [return]    ${rpingseq[${seqlen}-1]}    ${pingseq[0]}

manage element
    [Documentation]     This keyword will modify values in scf
    ...             It needs in input a dictionary with as key the name of the parameter and as value the value to set
    ...             A list with the key in the dictionary that have to be modified
    ...             The path where the values have to be set
    [Arguments]     ${distname_grp}     ${valtomod}     ${state}    ${value}
    Log to console  ${distname_grp}     ${valtomod}
    ${IsIn}     is element in object    ${distname_grp}     ${valtomod}
    Run keyword If      ${IsIn} and '${state}'=='existing'
    ...         modify value in scf by dist_name            ${distname_grp}     ${valtomod}     ${value}
    Run keyword If      not ${IsIn} and '${state}'=='existing'
    ...         scf.add_element_to_scf                          ${distname_grp}     ${valtomod}     ${value}
    Run keyword If      ${IsIn} and '${state}'=='missing'
    ...         scf.remove element from scf                     dist_name=${distname_grp}           p_name=${valtomod}


manage list
    [Documentation]     This keyword will modify values in scf
    ...             It needs in input a dictionary with as key the name of the parameter and as value the value to set
    ...             A list with the key in the dictionary that have to be modified
    ...             The path where the values have to be set
    [Arguments]     ${distname_grp}     ${valtomod}     ${state}    ${value}

    ${IsIn}     is list in object       ${distname_grp}     ${valtomod}
    Run keyword If      not ${IsIn} and '${state}'=='existing'
    ...          scf.add list to scf     dist_name=${distname_grp}   list_name=${valtomod}
    Run keyword If      '${state}'=='existing'
    ...             manage list elements    ${distname_grp}     ${valtomod}     ${value}
    Run keyword If      ${IsIn} and '${state}'=='missing'
    ...         scf.remove list from scf        dist_name=${distname_grp}       list_name=${valtomod}

manage list elements
    [Documentation]     This keyword will modify values in scf
    ...             It needs in input a dictionary with as key the name of the parameter and as value the value to set
    ...             A list with the key in the dictionary that have to be modified
    ...             The path where the values have to be set
    [Arguments]     ${distname_grp}     ${listtomod}     ${dictvalues}

    ${listkeys}=    Run keyword If          ${dictvalues}==None
    ...             Create List
    ...             ELSE
    ...             Get Dictionary Keys     ${dictvalues}
    log             \n${listkeys}           formatter=repr
    FOR     ${valtomod}     IN      @{listkeys}
        ${value}        Get From Dictionary         ${dictvalues}           ${valtomod}
        &{dictval}      Create Dictionary           ${valtomod}             ${value}
        ${listval}
        ...  scf.Get all values from scf     dist_name=${distname_grp}   list_name=${listtomod}   p_name=${valtomod}
        Run Keyword if      @{listval}==@{EMPTY}
        ...         Log     \nThe element ${valtomod} is not in list
        ...         ELSE
        ...         Log     \nThe element ${valtomod} is in list
        Run Keyword if      @{listval}==@{EMPTY}
        ...         scf.add item to list        ${distname_grp}     ${listtomod}        ${dictval}
        ...         ELSE
        ...         scf.modify scf element      dist_name=${distname_grp}   list_name=${listtomod}   p_name=${valtomod}
        ...  value=${value}
    END


Set branch params
    [Documentation]     This keyword will modify values in scf
    ...             It needs in input a dictionary with as key the name of the parameter and as value the value to set
    ...             A list with the key in the dictionary that have to be modified
    ...             The path where the values have to be set
    [Arguments]     ${branchdict}   ${dictkeys}     ${distname_grp}

    FOR     ${valtomod}     IN      @{dictkeys}
        ${descval}          Get From Dictionary     ${branchdict}        ${valtomod}
        # Log to console      \n${valtomod} with description ${paramval} in branch ${distname_grp}
        Log       \n${valtomod} in branch ${distname_grp} with description ${descval}
        ${type}             Get From Dictionary     ${descval}          Type
        ${state}            Get From Dictionary     ${descval}          State
        ${value}            Get From Dictionary     ${descval}          Value
        Run keyword If      '${type}'=='element'
        ...         manage element                  ${distname_grp}     ${valtomod}     ${state}    ${value}
        Run keyword If      '${type}'=='list'
        ...         manage list                     ${distname_grp}     ${valtomod}     ${state}    ${value}
        # modify value in scf by dist_name    ${distname_grp}     ${valtomod}    ${paramval}
    END

Set branches params
    [Documentation]     This keyword will modify values in scf
    ...             It needs in input a dictionary of dictionaries with as key the names NRCELL, NRCELLGRP and NRBTS.
    ...             Each dictionary Should have as key the name of the parameter to modify and as value the value to set
    ...             As second parameter, a list of the cell name to apply
    ...             As third parameter, a list of the cellgrp name to apply
    [Arguments]     ${cfgdict}   ${cells_id}=@{empty}    ${cellgrps_id}=@{empty}
    ...             ${BTS_Path}=MRBTS-${bts_id}/NRBTS-${bts_id}
    Log to console  ${BTS_Path}
    log             \nSetting configuration\n${cfgdict}                formatter=repr

    ${edrxnrcellcfg}    Get From Dictionary     ${cfgdict}              NRCELL
    log             ${edrxnrcellcfg}\n          formatter=repr
    ${edrxnrcellkey}=   Run keyword If          ${edrxnrcellcfg}==None
    ...         Create List
    ...         ELSE    Get Dictionary Keys     ${edrxnrcellcfg}
    log             ${edrxnrcellkey}\n          formatter=repr

    ${edrxnrcgrpcfg}    Get From Dictionary     ${cfgdict}              NRCELLGRP
    log             \n${edrxnrcgrpcfg}          formatter=repr
    ${edrxnrcgrpkey}=   Run keyword If          ${edrxnrcgrpcfg}==None
    ...         Create List
    ...         ELSE    Get Dictionary Keys     ${edrxnrcgrpcfg}
    log             \n${edrxnrcgrpkey}          formatter=repr

    ${edrxnrbtscfg}    Get From Dictionary      ${cfgdict}              NRBTS
    log             ${edrxnrbtscfg}\n           formatter=repr
    ${edrxnrbtskey}=   Run keyword If           ${edrxnrbtscfg}==None
    ...         Create List
    ...         ELSE    Get Dictionary Keys             ${edrxnrbtscfg}
    Log               \nNRBTS param : ${edrxnrbtskey}

    Set branch params       ${edrxnrbtscfg}     ${edrxnrbtskey}     ${BTS_Path}

    FOR     ${CGRP}     IN      @{cellgrps_id}
         Log to console  ${CGRP}
         ${distname_grp}=    catenate     SEPARATOR=/    ${BTS_Path}        ${CGRP}


        Set branch params       ${edrxnrcgrpcfg}     ${edrxnrcgrpkey}     ${distname_grp}
    END
    FOR     ${CELL}     IN      @{cells_id}
        ${distname_grp}=    catenate     SEPARATOR=/    ${BTS_Path}        ${CELL}
        Set branch params       ${edrxnrcellcfg}     ${edrxnrcellkey}     ${distname_grp}
    END

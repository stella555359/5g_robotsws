*** Settings ***
Documentation    Author: leo.y.wang@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/
Library          Telnet
Library          String
Library          OperatingSystem
Library          taf.transport.ssh    WITH NAME    SSH

*** Variables ***
&{GNB}               ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu
&{AP}                ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu
&{AP_ASIK}           ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
&{AP_ABIL_1}         ip=192.168.253.85    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAbil_1
&{AP_ABIL_0}         ip=192.168.253.84    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAbil_0
&{GNB_ASIK}          ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{GNB_ASIK_SLAVE}    ip=192.168.253.17    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsikSlave
&{GNB_ASP}           ip=192.168.253.21    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsp
@{LOG_NAME_LIST}     btslog    ap_syslog    gnb_snapshot    sosreport    egatelog
@{TOOLS_LIST}     luashark    ttitrace_decode    bip_script    common_config_golden    common_config_private    mcshark
${SW_BRANCH}             ${EMPTY}    # 5G20B
${SW_VERSION}            ${EMPTY}    # 0.800
${SW_VERSION_TOTAL}      ${EMPTY}    # 0.800.829
${FCT_BOARD_TYPE}        ${EMPTY}    # ASIK/ASIB/ASIL
${ASP_BOARD_TYPE}        ${EMPTY}    # [ABIL]/[ABIO]
${RF_TYPE}               ${EMPTY}    # CPRI/eCPRI
${L1_TYPE}               ${EMPTY}    # FS/L1b
${GNBCUTYPE}             ${EMPTY}    # SA/NSA
${WTS_VERSION}           ${EMPTY}    # 4.0.13303
${WTS_CFG_FULL_PATH}     ${EMPTY}    # /opt/wts/basic.cfg
&{GNBMIRRORINGCONFIGS}    &{EMPTY}    # BB_SLOT_2='false'    SYSCOM_MIRRORING='false'


*** Keywords ***
Execute Command On AaShell
    [Arguments]    ${host}    ${command}    ${expect_str}=""    ${port}=15007    ${prompt}=AaShell>
    ...            ${timeout}=300 seconds
    [Documentation]    This keyword is to execute command on aashell by telnet ap 15007.
    ...    | Input Parameters | Man. | Description |
    ...    | ${host} | Yes | host ip, need GND OR Airphone  |
    ...    | ${command} | Yes | command which aashell support |
    ...    | ${expect_str} | No | command result expect output string |
    ...    | ${port} | No | default 15007 |
    ...    | ${prompt} | No | AaShell> |
    ...    | ${timeout} | No | command executed timeout,default 300 seconds |

    Telnet.Open Connection    host=${host}    port=15007
    Telnet.Set Prompt    ${prompt}
    Telnet.Set Timeout    ${timeout}
    Telnet.Write    ${command}
    Telnet.Read Until    ${expect_str}
    Telnet.Close Connection

Modify File Parameter
    [Arguments]    ${file_path}    ${old_value}    ${new_value}
    [Documentation]    This keyword is to replace string for file
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | YES | the file path which need to modify |
    ...    | ${old_value} | YES | the value need to be replaced |
    ...    | ${new_value} | YES | the new value |
    ...    Examples:
    ...    | ${delta_path} | OperatingSystem.Join Path | ${scf_path} | ${SW_BRANCH} | SCF | Delta_Conf_5GC002504.json |
    ...    | Modify File Parameter | ${delta_path} | MRBTS-[0-9]+/NRBTS-[0-9]+ | ${NRBTS_DISTNAME} |
    ${content}=    OperatingSystem.Get File    path=${file_path}
    ${content}=    String.Replace String Using Regexp    string=${content}    pattern=${old_value}    replace_with=${new_value}
    OperatingSystem.Create File    path=${file_path}    content=${content}

Verify Process Start Success
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    [Documentation]    This keyword is to verify if log process start success
    ...    Notice: just available in keywords:Start X2 Pcap Log; Start Gnb BIP Log
    ...    | Input Parameters | Man. | Description |
    ...    | ${part_proc_msg} | Yes | process part content |
    ...    | ${process_msg} | Yes | A string for the whole command |
    ...    | ${connection} | Yes | the connection to execute the command |
    ...    Examples:
    ...    | ${cmd} | Set Variable | tcpdump -i etha01 -C 50 -W 2 -w /tmp/5GBipL2L1_filtering_off.pcap |
    ...    | Verify BIP Start Success | 5GBipL2L1_filtering_off.pcap || ${cmd} | ${GNB_ASIK_CONNECTION} |
    ${process}    SSH.Execute    command=ps aux|grep '${part_proc_msg}'    connection=${connection}
    Should Contain    ${process}    ${process_msg}

Kill And Verify Process Stop Success
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    [Documentation]    This keyword is to verify if log capture process end success
    ...    Notice: just available in keywords: Stop X2 Pcap Log; Stop Gnb BIP Log
    ...    | Input Parameters | Man. | Description |
    ...    | ${process_msg} | Yes | A string for the whole command |
    ...    | ${connection} | Yes | the connection to execute the command |
    ...    Examples:
    ...    | ${cmd} | Set Variable | tcpdump -i etha01 -C 50 -W 2 -w /tmp/5GBipL2L1_filtering_off.pcap |
    ...    | Kill And Verify Process Stop Success | 5GBipL2L1_filtering_off.pcap | ${cmd} | ${GNB_ASIK_CONNECTION} |
    Kill Process If Existed    ${part_proc_msg}    ${process_msg}    ${connection}
    ${process}    SSH.Execute    command=ps aux|grep '${part_proc_msg}'    connection=${connection}
    Should Not Contain    ${process}    ${process_msg}

Kill Process If Existed
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    [Documentation]    This keyword is to kill the process with the ${process_msg} if it exist.
    ...    | Input Parameters | Man. | Description |
    ...    | ${process_msg} | Yes | the msg to filter the related process |
    ...    | ${connection} | Yes | the SSH connection to kill process |
    ...    Examples:
    ...    | ${cmd} | Set Variable | tcpdump -i etha01 -C 50 -W 2 -w /tmp/5GBipL2L1_filtering_off.pcap |
    ...    | Kill Process If Existed | 5GBipL2L1_filtering_off.pcap || ${cmd} | ${GNB_ASIK_CONNECTION} |
    ${process}    SSH.Execute    command=ps aux|grep '${part_proc_msg}'    connection=${connection}
    ${status}    Run Keyword And Return Status    Should Contain    ${process}    ${process_msg}
    Run Keyword If    '${status}'=='True'    SSH.Execute
    ...    command=ps aux|grep '${process_msg}'|awk '{print $2}'|xargs kill -2    connection=${connection}
*** Settings ***
Documentation    author: Hongyan Yuan
...              Group: HGZ_SG1
...              contact: hongyan.1.yuan@nokia-sbell.com
...              Provide common kws for L3 call on Classical gNB NSA and SA with tm500

Library  Collections
Library  taf.ue.tm500.rci       WITH NAME    tm500_remote
Library  taf.transport.ssh      WITH NAME    csn
Resource  taf/rfrl/common_resources/robot/connections.robot

*** Variables ***
${LOCAL_SWCONFIG_PATH}   ${CURDIR}/../bb2_files/swconfig.txt
${TM500_IP}          ${tl.ues[0].tma_host.addr}
${TM500_PORT}        ${tl.ues[0].tma_command_port}
${TM500_USER}        ${tl.ues[0].tma_host.username}
${TM500_PW}          ${tl.ues[0].tma_host.password}


*** Keywords ***
TM500 Detach
    [Documentation]  Detach TM500. Allows to provide custom scripts for detach
    ...  and it this case user is responsible for setting proper variables
    ...  in script. If detach_script_path was not provided default value is used.
    [Arguments]  ${tm500_alias}
    ...  ${detach_script_path}=${CURDIR}/../tm500_scripts_templates/detach.txt
    tm500_remote.send script  ${detach_script_path}  alias=${tm500_alias}  timeout=5 minutes

Set attenuation     [Arguments]    ${connection}
    ${set attenuation command}=   Set Variable       /sbin/devmem 0xa000b088 32 0x00000020; /sbin/devmem 0xa000b08c 32 0x00000020
    ${get attenuation command}=   Set Variable       /sbin/devmem 0xa000b088 32; /sbin/devmem 0xa000b08c 32
    csn.Send Command   ${set attenuation command}       connection=${connection}
    csn.Send Command   ${get attenuation command}       connection=${connection}
    csn.Read Output                                     connection=${connection}

Precondition
    [Documentation]  [Deprecated] Connect to cobham control PC via telnet, and start TMA application.
    ...    Arguments:
    ...    TMA_PATH -  the installation path of TMA, in Windows form.
    ...    eg. C:\\Program Files (x86)\\Aeroflex\\TM500\\5G NR - NLA 4.5.0\\Test Mobile Application\\TmaApplication.exe
    ...    tma_alias - telnet connecton to tm500 control PC.
    [Arguments]      ${TMA_PATH}    ${tma_alias}=tma
    tm500_remote.create telnet runner       ${TM500_IP}    ${TM500_USER}    ${TM500_PW}    alias=${tma_alias}
    sleep  5s
    tm500_remote.run tma app        path=${TMA_PATH}    proxy_port=${TM500_PORT}   alias=${tma_alias}
    sleep  10s
    tm500_remote.tma app is running    imagename=TmaApplication.exe     alias=${tma_alias}
    sleep  5s

Precondition_SSH
    [Documentation]  Connect to cobham control PC via SSH, and start TMA application.
    ...    TMA_PATH -  the installation path of TMA, in Linux form.
    ...    eg. /cygdrive/c/Program Files (x86)/Aeroflex/TM500/5G NR - NLA 4.8.0/Test Mobile Application/TmaApplication.exe
    ...    tma_alias - ssh connecton to tm500 control PC.
    [Arguments]    ${TMA_PATH}    ${tma_alias}=tma
    ${TM500_PORT}=  Convert To Integer  ${TM500_PORT}
    Wait Until Keyword Succeeds    3x    30sec     csn.Connect to    ${TM500_IP}    ${TM500_USER}    ${TM500_PW}    alias=${tma_alias}
    ${tma_PID}  csn.Execute  command=ps -Wef |grep TmaApplication|awk '{{print $2}}'|head -n 1  connection=${tma_alias}
    csn.Execute  command=/bin/kill -f ${tma_PID.strip()}  connection=${tma_alias}
    sleep  3s
    csn.send_command   command="${TMA_PATH}" /u "Default User" /p ${TM500_PORT} /c y /a y &    connection=${tma_alias}
    sleep  60s
    ${tma_PID}  csn.Execute  command=ps -Wef |grep TmaApplication|awk '{{print $2}}'|head -n 1  connection=${tma_alias}
    Log    TMA is running with PID ${tma_PID}.
    Should not be empty    ${tma_PID.strip()}    msg=TMA app is not started
    sleep  10s
    csn.disconnect    connection=${tma_alias}
    [Return]    ${tma_PID}

Postcodition
    [Documentation]  [Deprecated]  Kill TMA application via Telnet.
    [Arguments]     ${tma_alias}=tma
    sleep  5s
    tm500_remote.kill tma app       imagename=TmaApplication.exe    alias=${tma_alias}

Postcondition_SSH
    [Documentation]  Kill TMA application via SSH.
    [Arguments]     ${tma_alias}=tma
    sleep  5s
    Wait Until Keyword Succeeds    3x    30sec    csn.Connect to    ${TM500_IP}    ${TM500_USER}    ${TM500_PW}    alias=${tma_alias}
    ${tma_PID}  csn.Execute  command=ps -Wef|grep TmaApplication|awk '{{print $2}}'|head -n 1  connection=${tma_alias}
    csn.force_reconnect    connection=${tma_alias}
    csn.execute  command=/bin/kill -f ${tma_PID.strip()}  connection=${tma_alias}
    ${tma_PID}  csn.Execute  command=ps -Wef|grep TmaApplication|awk '{{print $2}}'|head -n 1  connection=${tma_alias}
    ${tma_PID}  strip_string    string=${tma_PID}
    csn.disconnect    connection=${tma_alias}
    [Return]    ${tma_PID}

Connect
    [Documentation]  Connect to cobham from control PC.
    [Arguments]     ${tm500_alias}=tm500
    tm500_remote.Connect to  ip=${TM500_IP}  command_port=${TM500_PORT}  alias=${tm500_alias}

Disconnect
    [Arguments]     ${tm500_alias}=tm500
    tm500_remote.disconnect  alias=${tm500_alias}

Connect HW and Initialize
    [Documentation]  Connect and initialize cobham.
    [Arguments]   ${hw_connect_script_path}=${template_dir}/Init_Config.txt      ${tm500_alias}=tm500
    [Timeout]    5 minutes

    log    Sending hw_connect_script from ${hw_connect_script_path}
    ${response}=  tm500_remote.send script  ${hw_connect_script_path}  alias=${tm500_alias}  timeout=5 minutes
    Should Not Contain    ${response}    Failure
    sleep   30s

Perform Cell Search
    [Arguments]   ${cell_search_script_path}=${template_dir}/Cell_Search.txt      ${tm500_alias}=tm500
    [Timeout]    5 minutes

    log    Sending cell_search_script from ${cell_search_script_path}
    ${response}=  tm500_remote.send script  ${cell_search_script_path}  alias=${tm500_alias}
    Should Not Contain    ${response}    Failure



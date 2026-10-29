*** Settings ***
Documentation
...    VRF HAZ 1 Common Resources.

Resource          common_resource.robot
Library           taf.sbts.oam.coam.admin    WITH NAME    admin
*** Variables ***
${LANIP}    192.168.255.126
${CALIBRATE_WAIT}    10

*** Keywords ***
Download Package
    [Documentation]    Author: He Winnie
    ...    :param  package,software name
    ...    :param  download_server_type,if is SWcache
    ...            http://sw1.tc.china.nsn-net.net/build/[package]/[package].zip
    ...    :param if is wft:
    [Arguments]    ${package}    ${download_server_type}=${None}   ${alias}=Ctrl_VM
    Connect To CTRL VM
    Run Keyword And Ignore Error    Create Download SW Save Path    alias=${alias}
    ${download_server_type}    Run Keyword If    '${download_server_type}'=='${None}'
    ...    Choose Download Server    package=${package}
    ...    ELSE    Set Variable    ${download_server_type}
    ${file_path}    run keyword if    '${download_server_type}'=='SWCache'
    ...    join path    ${SW_Download_Path}    ${package}.zip
    ...    ELSE
    ...    join path    ${SW_Download_Path}    ${package}_release_BTSSM_downloadable_${SRAN_Postfix}.zip
    ${exist}    csn.file_exists    ${file_path}    connection=${alias}
    run keyword if    ${exist}==${True}    csn.send_command    command=rm ${file_path}    connection=${alias}
    ${download_tool}    Choose Download Tools
    ${download_link}    run keyword if    '${download_server_type}'=='SWCache'
    ...    catenate  ${SW_SERVER_LINK}/${package}/${package}.zip
    ...    ELSE
    ...    Get Wft Download Link    ${package}
    run keyword if    '${download_tool}'=='aria2c'
    ...    csn.execute
    ...    command=/home/ute/Project/${Aria2c_Command} ${download_link} -d ${SW_Download_Path} -o ${package}.zip > /dev/null 2>&1
    ...    connection=${alias}
    run keyword if    '${download_tool}'=='wget'
    ...    csn.execute    command=wget ${download_link} -nv -P ${SW_Download_Path}
    ...    connection=${alias}
    ${exist}    csn.file_exists    ${file_path}    connection=${alias}
    Should be True    ${exist}
    [Return]    ${file_path}

Connect To CTRL VM
    [Documentation]    Author: He Winnie
    [Arguments]    ${alias}=Ctrl_VM
    csn.connect_to    hostname=${BTS0_PC_INFO.Host}    username=${CTRL_VM_USERNAME}    password=${CTRL_VM_PASSWORD}    alias=${alias}

Choose Download Tools
    [Documentation]    Author: He Winnie
    [Arguments]    ${alias}=Ctrl_VM
    Log To Console    ${alias}
    ${exist}    csn.File Exists    ${Aria2c_Default_Path}    connection=Ctrl_VM
    set test variable    ${download_tool}    wget
    run keyword if    ${exist}
    ...    set test variable     ${download_tool}    aria2c
    [Return]    ${download_tool}

Get Wft Download Link
    [Documentation]    Author: He Winnie
    [Arguments]    ${sw_name}    ${sran_postfix}=${SRAN_Postfix}
    ${sw_list}    split string    ${sw_name}    separator=_
    # ${download_link}    run keyword if    '${sw_list[0]}'=='${5G_PRE}'
    # ...    catenate ${5G_Download_link}/${sw_list[1]}/AirScale-${sw_list[1]}.zip
    ${is_sbts}    Run Keyword And Return Status    Should Contain    ${sw_list[0]}    SBTS
    ${release}    Get Release By Sw Version    sw=${sw_name}
    ${download_link}    run keyword if    ${is_sbts}
    ...    catenate    ${SRAN_Download_Link}/${release}/${sw_name}/${sw_name}_release_BTSSM_downloadable_${sran_postfix}.zip
    [return]    ${download_link}

Create Download SW Save Path
    [Arguments]    ${alias}=Ctrl_VM
    csn.Execute    rm -rf ${SW_Download_Path}    connection=${alias}
    csn.Execute    mkdir ${SW_Download_Path}    connection=${alias}

_Server Link Available
    [Arguments]    ${link}    ${alias}=Ctrl_VM
    ${ret}    csn.execute    ${link}    connection=${alias}
    ${exist}    Run Keyword And Return Status    Should Not Contain    ${ret}    404 Not Found
    [Return]    ${exist}

Choose Download Server
    [Arguments]    ${package}    ${alias}=Ctrl_VM
    ${wft_link}    Get Wft Download Link    ${package}
    ${exist}    _Server Link Available    ${wft_link}    alias=${alias}
    Return From Keyword If    ${exist}    WFT
    ${swcache_link}    catenate  curl -v ${SW_SERVER_LINK}/${package}/${package}.zip
    ${exist}    _Server Link Available    ${wft_link}
    Return From Keyword If    ${exist}    SWCache
    Fail    Can't find available download link of ${package}

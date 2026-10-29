*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    DateTime
Library    taf.transport.ssh    WITH NAME    csn

*** Variables ***

*** Keywords ***
clear vm pid before run case
    log to console    clear vm pid before run case
    csn.connect to    hostname=${vm_addr}    username=${vm_username}    password=${vm_password}   alias=test_pc
    sleep    2s
    csn.Send command    command=sudo ps -ef|grep firefox|grep -v grep|awk '{print "kill -9 " $2}' |sh    connection=test_pc
    sleep    2s
    csn.Send command    command=sudo ps -ef|grep firefox|grep -v grep|awk '{print "kill -9 " $3}' |sh    connection=test_pc
    sleep    2s
    csn.Send command    command=sudo ps -ef|grep btslog|grep -v grep|awk '{print "kill -9 " $2}' |sh    connection=test_pc
    sleep    2s
    [Teardown]   csn.disconnect    connection=test_pc

Create file in BBMOD
    [Arguments]  ${log_name}=123.txt
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}   alias=alias_bbmod
    sleep  2
    csn.execute     touch ${log_name}    connection=alias_bbmod
    sleep  2
    ${output}    csn.execute    command=ls -l ${log_name}    connection=alias_bbmod
    sleep  2
    Should Not Contain      ${output}      No such file or directory
    [Teardown]   csn.disconnect    connection=alias_bbmod

Check and Delete file Exist in BBMOD
    [Arguments]  ${log_name}=123.txt
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}   alias=alias_bbmod
    sleep  2
    ${output}    csn.execute    command=ls -l ${log_name}    connection=alias_bbmod
    sleep  2
    Should Not Contain      ${output}      No such file or directory
    sleep  2
    csn.execute     rm ${log_name}    connection=alias_bbmod
    sleep  2
    ${output}    csn.execute    command=ls -l ${log_name}    connection=alias_bbmod
    sleep  2
    Should Contain      ${output}      No such file or directory
    [Teardown]   csn.disconnect    connection=alias_bbmod

ssh to switch and operation interface
    [Documentation]     This keyword applies only to NOKIA 1830 TPS switch
    [Arguments]    ${switch_ip}=10.101.51.171    ${operation}=down    ${sw_name}=t24ps1    ${sw_interface}=1/3/c2
    log to console    \n ssh to switch and ${operation} interface ${sw_interface}
    csn.connect to    hostname=${vm_addr}    username=${vm_username}    password=${vm_password}   alias=test_pc
    ${connection}    csn.get_connection_by_alias    alias=test_pc
    ${channel}    Call Method    ${connection}    invoke_shell
    Sleep  2
    Call Method    ${channel}    send    ssh cli@${switch_ip}\n
    Sleep  2
    Call Method    ${channel}    recv    ${65535}
    Sleep  2
    Call Method    ${channel}    send    admin\n
    Sleep  2
    Call Method    ${channel}    recv    ${65535}
    Sleep  2
    Call Method    ${channel}    send    Admin@1830\n
    Sleep  2
    Call Method    ${channel}    recv    ${65535}
    Sleep  2
    Call Method    ${channel}    send    Y\n
    Sleep  2
    Call Method    ${channel}    recv    ${65535}
    Sleep  2
    Call Method    ${channel}    send    config interface ${sw_name} ${sw_interface} state ${operation}\n
    Sleep  2
    Call Method    ${channel}    recv    ${65535}
    Sleep  2
    Call Method    ${channel}    send    show int ${sw_name} ${sw_interface}\n
    Sleep  2
    Call Method    ${channel}    recv    ${65535}
    Sleep  2
    Call Method    ${channel}    close
    [Teardown]   csn.disconnect    connection=test_pc

Download software to VM
    [Arguments]        ${sw_name}    ${sw_full_url}     ${package_store_path}=${SAVE LOG DIRECTORY}
    ${status}          run keyword and return status    file should exist  ${package_store_path}/${sw_name}
    run keyword if      ${status}    remove file    ${package_store_path}/${sw_name}
    ${sw_url}          Catenate    sudo wget ${sw_full_url} -nv -P ${package_store_path}
    ${res}             Run         ${sw_url}
    ${status}          run keyword and return status    file should exist  ${package_store_path}/${sw_name}
    should be true    ${status}
    [Return]    ${sw_name}

*** Settings ***

Documentation     Keywords related to IPSL handling
...               :Author: Uli Schöffel
...               email: ulrich.schoeffel@nokia.com
...
...     Following files are needed for IPSL:
...     - CCA_server.scr
...     - CEA_server.scr
...     - DPA_Server.SCR
...     - DWA_Server.scr
...     - IPS.CFG
...     - server.ctl
...     these files are copied to ipsl machine, compiled and the ips is restarted
...     to parametrize these files  you can use variables and put these in an file called _include.h
...     if _include.h exists variables are replaced (or KW fails if variable is not known)
...     following variables are set from KW as test variable:
...        ${IPSL_HOST_IP} : ip related to core connection
...        ${IPSL_NAME}:  ipsl identifier for core
...        ${IPSL_REALM}: realm for core, at the moment fix to "ipsl.nsn.com"
...	library taf.config.testline > 8.96.0 is needed

Library    taf.transport.ssh              WITH NAME    ssh
Library    OperatingSystem
Library    String

*** Variables ***
${ipsl_compiler_flags}         /pDIA04IGX /its /b
${tmp_dir}                     /tmp/IPSL/  #local tmp dir on robot machine
${windows_ipsl_path}           c:/IpslTools/
${linux_ipsl_path}             WINEPREFIX\=/opt/ute/ipsl-wine-01/
${windows_path_to_ipsl_files}  c:/Users/deul5g/robot_tmp/
${linux_path_to_ipsl_files}    /home/ute/robot_tmp/

*** Keywords ***
start IPSL
    [Arguments]    ${ipsl_ip}=${tl.core.ips.ssh_connection_details.addr}  ${path_to_ipsl_files}=${windows_path_to_ipsl_files}
    [Documentation]
    ...
    ...     complete sequence, user KW
    ...
    ...    Input Parameters:
    ...    :param  ${ipsl_ip}: address of ipsl simulator, default is entry from init file
    ...    :param  ${path_to_ipsl_files}: where ipsl config files are stored (normally inside the TC folder)
    ${ipsl}  ${os}    open IPSL connection  ipsl_ip=${ipsl_ip}
    set ipsl parameter  ${ipsl}  ${os}
    stop IPSL  ${ipsl}  ${os}
    replace variables and copy files to ipsl  ${ipsl}  ${path_to_ipsl_files}  ${os}
    sleep  5s  #to make sure old ipsl is really terminated
    compile files and start IPSL     ${ipsl}  ${os}
    close IPSL connection    ${ipsl}

copy log file from IPSL
    [Arguments]      ${ipsl_ip}=${tl.core.ips.ssh_connection_details.addr}  ${dst_dir}=/tmp/
    [Documentation]
    ...   Copies log file from IPSL to Robot, user KW
    ...
    ...   Input Parameters:
    ...   :param  ${ipsl_ip}: address of ipsl simulator, default is entry from init file
    ...   :param ${dst_dir}: where to store log file (default: /tmp/ dir)
    ${ipsl}  ${os}  open IPSL connection   ipsl_ip=${ipsl_ip}
    ${result}  run keyword if  '${os}'=='linux'
    ...        download log files  ${linux_path_to_ipsl_files}  ${dst_dir}  ${ipsl}
    ...        ELSE IF  '${os}'=='win'
    ...        download log files  ${windows_path_to_ipsl_files}  ${dst_dir}  ${ipsl}
    close IPSL connection    ${ipsl}
    [Return]    ${result}    # any return value from copy

#
# INTERNAL KW
#

download log files
    [Arguments]  ${src_dir}  ${dst_dir}  ${alias}
    [Documentation]      [PRIVAT]
    ...     Internal funtion to copy several files from ipsl
    ssh.Download file  ${src_dir}/ips32.trc  ${dst_dir}/ips32.trc  connection=${alias}
    ssh.Download file  ${src_dir}/CCA_server.scr  ${dst_dir}/CCA_server.scr  connection=${alias}
    
open IPSL connection
    [Arguments]    ${ipsl_ip}=${tl.core.ips.ssh_connection_details.addr}  ${alias}=ipsl
    [Documentation]      [PRIVAT]
    ...     Internal funtion:
    ...     Create and open SSH connection to IPS machine
    ...     check and return used operating system for IPS
    ssh.Connect to     hostname=${ipsl_ip}
    ...                username=${tl.core.ips.ssh_connection_details.username}
    ...                password=${tl.core.ips.ssh_connection_details.password}
    ...                alias=${alias}
   ssh.Send command  uname  connection=${alias}
   ${text}  ssh.Read output  connection=${alias}
   ${text}  string.get substring  ${text}  0  3
   ${text}  string.convert to lowercase  ${text}
   ${error}  ssh.Read error  connection=${alias}
   ${OS}  run keyword if  '${text}' == 'lin'  set variable  linux
   ...           ELSE IF  '${text}' == 'win'  set variable  win
   ...           ELSE  set variable  unknown
   [Return]    ${alias}   ${OS}  # ssh handler + operating system for ipsl

close IPSL connection
    [Arguments]    ${alias}
    [Documentation]      [PRIVAT]
    ...     Internal funtion:
    ...     Close and delete SSH connection to IPSL machine
    ssh.Disconnect  connection=${alias}

set ipsl parameter
    [Arguments]    ${alias}  ${os}
    [Documentation]  [PRIVAT]
    ...     set following ipsl parameter as test variable:
    ...		${IPSL_HOST_IP} : ip related to core connection
    ...		${IPSL_NAME}:  ipsl identifier for core
    ...		${IPSL_REALM}: realm for core, at the moment fix to "ipsl.nsn.com"
    ${ipsl_core_ip}  get ipsl core ip  ${alias}  ${os}
    ${pre}  ${sub_ip}  split string from right  ${ipsl_core_ip}  .  1
    ${sub_ip}  convert to integer  ${sub_ip}
    ${name}  Run keyword if  ${sub_ip} < 10  catenate  SEPARATOR=-0  deul-ipsl-gx  ${sub_ip}
    ...		 ELSE  catenate  SEPARATOR=-  deul-ipsl-gx  ${sub_ip}
    set test variable  ${IPSL_HOST_IP}  ${ipsl_core_ip}
    set test variable  ${IPSL_name}  ${name}
    set test variable  ${IPSL_REALM}  ipsl.nsn.com
    [Return]  ${IPSL_HOST_IP}  ${IPSL_NAME}  ${IPSL_REALM}

get ipsl core ip
    [Arguments]    ${alias}  ${os}
    [Documentation]  [PRIVAT]
    ...     wrapper for different OS versions
    ${ipsl_core_ip}  run keyword if  '${os}'=='linux'  get linux core ip  ${alias}  ELSE IF  '${os}'=='win'  get win core ip  ${alias}
    [Return]  ${ipsl_core_ip}

get win core ip
    [Arguments]    ${alias}
    [Documentation]  [PRIVAT]
    ...     get core related ip address from win-ipsl machine
    ssh.Send command  ipconfig| grep 10.44.35  connection=${alias}
    ${text}  ssh.Read output  connection=${alias}
    ${error}  ssh.Read error  connection=${alias}
    ${pre}  ${ip}  split string  ${text}  :
    ${ip}  strip string  ${ip}
    [Return]  ${ip}

get linux core ip
    [Arguments]    ${alias}
    [Documentation]  [PRIVAT]
    ...     get core related ip address from linux-ipsl machine
    ssh.Send command  ip a | grep 10.44.35  connection=${alias}
    ${text}  ssh.Read output  connection=${alias}
    ${error}  ssh.Read error  connection=${alias}
    @{words}  split string  ${text}
    ${ip}  string.get substring  ${words[1]}  0  -3
    [Return]  ${ip}

stop IPSL
    [Arguments]    ${alias}  ${os}
    [Documentation]  [PRIVAT]
    ...     wrapper for different OS versions
    run keyword if  '${os}'=='linux'  stop linux IPSL  ${alias}  ELSE IF  '${os}'=='win'  stop win IPSL  ${alias}

stop win IPSL
    [Arguments]    ${alias}
    [Documentation]      [PRIVAT]
    ...     Internal funtion:
    ...     stop any already running IPSL processes on Windows IPSL machine
    Run Keyword and ignore error    ssh.Execute    taskkill /IM ips32.exe /F /T    connection=${alias}

stop linux IPSL
    [Arguments]    ${alias}
    [Documentation]      [PRIVAT]
    ...     Internal funtion:
    ...     stop any already running IPSL processes on linux IPSL machine
    Run Keyword and ignore error    ssh.Execute    killall -I ips32.exe    connection=${alias}


copy files to tmp folder
    [Arguments]     ${path_to_ipsl_files}
    [Documentation]      [PRIVAT]
    ...     Internal funtion:
    ...     copy ipsl config files from TC folder to $tmp_dir; preparation for variable replacement
    Remove Directory    ${tmp_dir}    recursive=true
    OperatingSystem.Copy files     ${path_to_ipsl_files}/*.*    ${tmp_dir}

replace variables in include file
    [Documentation]      [PRIVAT]
    ...     Internal funtion:
    ...     variables in __include.h are changed/replaced
    ${in_file_temp}=    OperatingSystem.Get File    ${tmp_dir}/_include.h
    ${out_file}=    Replace Variables    ${in_file_temp}
    Create File    ${tmp_dir}/_include.h    ${out_file}

copy files to linux ipsl
    [Arguments]    ${alias}    # ssh handler to IPSL
    [Documentation]      [PRIVAT]
    ...     Internal funtion:
    ...     Copies script files from /tmp/IPSL to linux IPSL machine
    @{files}=    OperatingSystem.List Files In Directory    ${tmp_dir}
    FOR    ${src_file}    IN    @{files}
           ssh.Upload File  ${tmp_dir}/${src_file}  ${linux_path_to_ipsl_files}/${src_file}  connection=${alias}
    END

copy files to windows ipsl
    [Arguments]    ${alias}    # ssh handler to IPSL
    [Documentation]      [PRIVAT]
    ...     Internal funtion:
    ...     Copies script files from /tmp/IPSL to windows IPSL machine
    @{files}=    OperatingSystem.List Files In Directory    ${tmp_dir}
    FOR    ${src_file}    IN    @{files}
           ssh.Upload File  ${tmp_dir}/${src_file}  ${windows_path_to_ipsl_files}/${src_file}  connection=${alias}
    END

replace variables and copy files to ipsl
    [Arguments]     ${alias}  ${path_to_ipsl_files}  ${os}
    [Documentation]      [PRIVAT]
    ...     Internal funtion:
    ...     combination of KW "copy files to tmp folder", "replace variables in include file", "copy files to ipsl"
    ...     replace variables is only executed if file exists...
    copy files to tmp folder  ${path_to_ipsl_files}
    ${include_present}  run keyword and return status   file should exist   ${tmp_dir}/_include.h
    Run keyword if  ${include_present}  replace variables in include file
    run keyword if  '${os}'=='linux'
    ...        copy files to linux ipsl  ${alias}
    ...        ELSE IF  '${os}'=='win'
    ...        copy files to windows ipsl  ${alias}

compile files and start IPSL
    [Arguments]    ${alias}  ${os}
    [Documentation]  [PRIVAT]
    ...     wrapper for different OS versions
    run keyword if  '${os}'=='linux'  compile files and start linux IPSL  ${alias}
    ...    ELSE IF  '${os}'=='win'  compile files and start win IPSL  ${alias}

compile files and start win IPSL
    [Arguments]    ${alias}    # ssh handler for IPSL
    [Documentation]      [PRIVAT]
    ...     Internal funtion:
    ...     compiles IPSL script and starts it
     ${result}=    ssh.Execute
     ...    ${windows_ipsl_path}/ipslc.exe ${ipsl_compiler_flags} ${windows_path_to_ipsl_files}/server.ctl
     ...    connection=${alias}
     ${result}=    ssh.Send Command
     ...    cd ${windows_path_to_ipsl_files} & ${windows_ipsl_path}/ips32.exe IPS.CFG  connection=${alias}

compile files and start linux IPSL
    [Arguments]    ${alias}    # ssh handler for IPSL
    [Documentation]      [PRIVAT]
    ...     Internal funtion:
    ...     compiles IPSL script and starts it
    ${result}=    ssh.Execute
    ...     cd ${linux_path_to_ipsl_files}; ${linux_ipsl_path} wine ipslc.exe ${ipsl_compiler_flags} server.ctl
    ...     connection=${alias}
    ${result}=    ssh.Execute    Xvfb :10 -screen 10 1024x768x16  connection=${alias}
    ${result}=    ssh.send command
    ...     export DISPLAY\=:10; cd ${linux_path_to_ipsl_files}; ${linux_ipsl_path} wine ips32.exe IPS.CFG
    ...     connection=${alias}
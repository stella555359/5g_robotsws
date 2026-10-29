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
...
...     these files are copied to ipsl machine, compiled and the ips is restarted
...     to parametrize these files  you can use variables and put these in an file called _include.h
...     if _include.h exists variables are replaced (or KW fails if variable is not known)
...     following variables are set from KW as test variable:
...
...     |  IPSL_HOST_IP | ip related to core connection |
...     |  IPSL_NAME    | ipsl identifier for core |
...     |  IPSL_REALM   | realm for core, at the moment fix to "ipsl.nsn.com" |
...
...	    library taf.config.testline > 8.96.0 is needed

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
Start IPSL
    [Arguments]    ${ipsl_ip}=${tl.core.ips.ssh_connection_details.addr}  ${path_to_ipsl_files}=${windows_path_to_ipsl_files}
    [Documentation]
    ...
    ...     complete sequence, user KW
    ...
    ...    |  ipsl_ip            | address of ipsl simulator, default is entry from init file |
    ...    |  path_to_ipsl_files | where ipsl config files are stored (normally inside the TC folder) |

    ${ipsl}  ${os}    open IPSL connection  ipsl_ip=${ipsl_ip}
    set ipsl parameter  ${ipsl}  ${os}
    stop IPSL  ${ipsl}  ${os}
    replace variables and copy files to ipsl  ${ipsl}  ${path_to_ipsl_files}  ${os}
    sleep  5s  #to make sure old ipsl is really terminated
    compile files and start IPSL     ${ipsl}  ${os}
    wait until ipsl connected
    close IPSL connection    ${ipsl}


Copy Log File From IPSL
    [Arguments]      ${ipsl_ip}=${tl.core.ips.ssh_connection_details.addr}  ${dst_dir}=/tmp/
    [Documentation]
    ...   Copies log file from IPSL to Robot
    ...
    ...   | ipsl_ip | address of ipsl simulator, default is entry from init file |
    ...   | dst_dir | where to store log file (default: /tmp/ dir) |
    ...

    ${ipsl}  ${os}  open IPSL connection   ipsl_ip=${ipsl_ip}
    IF  '${os}'=='linux'
    ...        download log files  ${linux_path_to_ipsl_files}  ${dst_dir}  ${ipsl}
    ...        ELSE IF  '${os}'=='win'
    ...        download log files  ${windows_path_to_ipsl_files}  ${dst_dir}  ${ipsl}
    close IPSL connection    ${ipsl}


Find Ipsl Interface
    [Documentation]
    ...     *Scope*   Internal
    ...
    ...     Determine interface number for IPSL connection
    ...
    ...     *Returns* The interface id of the ipsl interface for tshark

    ${cmd}  Set Variable  tshark.exe -D| grep -i IPSL
    ssh.Send Command  ${cmd}   connection=ipsl
    ${output}  ssh.Read output  connection=ipsl
    ${interface_id}    Fetch From Left    ${output}    .
    RETURN    ${interface_id}

Wait Until Ipsl Connected
    [Documentation]
    ...     Waits until connection message to core appears in tshark
    ...     Max wait time: 120s
    ...
    ${id}    find ipsl interface
    ${tshark}  set variable  tshark -i${id} -f \\"src host ${IPSL_HOST_IP} && port 3868 && tcp[70:4] & 0x00010100 !=0\\" -c 1 -a duration:120
    ${output}  ssh.Execute  ${tshark}   connection=ipsl
    Should not contain  ${output}  0 packets captured

Download Log Files
    [Arguments]  ${src_dir}  ${dst_dir}  ${alias}
    [Documentation]
    ...     *Scope* Internal
    ...
    ...     Funtion loading several files from ipsl (ips32.trc, CCA_server.scr)
    ...
    ...     | src_dir | the source directory to copy the files from |
    ...     | dst_dir | the destination directory where to place the downloaded files |
    ...     | alias   | the connection alias for a built up ssh connection to the ipsl |
    ...
    ssh.Download file  ${src_dir}/ips32.trc  ${dst_dir}/ips32.trc  connection=${alias}
    ssh.Download file  ${src_dir}/CCA_server.scr  ${dst_dir}/CCA_server.scr  connection=${alias}


Open IPSL Connection
    [Arguments]    ${ipsl_ip}=${tl.core.ips.ssh_connection_details.addr}  ${alias}=ipsl
    [Documentation]
    ...     Create and open SSH connection to IPS machine
    ...     check and return used operating system for IPS
    ...     | ipsl_ip | the ip address of the ipsl machine |
    ...     | alias   | the alias to use for the ssh connection |
    ...
    ...     *Returns* Tuple of alias and operating system.
    ...
    ssh.Connect to     hostname=${ipsl_ip}
    ...                username=${tl.core.ips.ssh_connection_details.username}
    ...                password=${tl.core.ips.ssh_connection_details.password}
    ...                alias=${alias}
   ssh.Send command  uname  connection=${alias}
   ${text}  ssh.Read output  connection=${alias}
   ${text}  string.get substring  ${text}  0  3
   ${text}  string.convert to lowercase  ${text}
   ssh.Read error  connection=${alias}
   ${OS}  Set Variable If
   ...      '${text}' == 'lin'    linux
   ...      '${text}' == 'win'    win
   ...      ${True}               unknown
   RETURN    ${alias}   ${OS}  # ssh handler + operating system for ipsl


Close IPSL Connection
    [Arguments]    ${alias}
    [Documentation]
    ...     Closes and deletes the SSH connection to IPSL machine
    ...
    # robocop: disable=too-few-calls-in-keyword
    ssh.Disconnect  connection=${alias}


Set Ipsl Parameter
    [Arguments]    ${alias}  ${os}
    [Documentation]
    ...     *Scope* Internal
    ...
    ...     set following ipsl parameter as test variable:
    ...
    ...    ${IPSL_HOST_IP} : ip related to core connection
    ...
    ...    ${IPSL_NAME}:  ipsl identifier for core
    ...
    ...    ${IPSL_REALM}: realm for core, at the moment fix to "ipsl.nsn.com"
    ...
    ...     *Returns* Tuple: IPSL Host IP, IPSL Name, IPSL Realm

    ${ipsl_core_ip}  get ipsl core ip  ${alias}  ${os}
    ${_}  ${sub_ip}  split string from right  ${ipsl_core_ip}  .  1
    ${sub_ip}  convert to integer  ${sub_ip}
    ${name}  IF  ${sub_ip} < 10  Catenate  SEPARATOR=-0  deul-ipsl-gx  ${sub_ip}
    ...    ELSE  catenate  SEPARATOR=-  deul-ipsl-gx  ${sub_ip}
    set test variable  ${IPSL_HOST_IP}  ${ipsl_core_ip}
    set test variable  ${IPSL_name}  ${name}
    set test variable  ${IPSL_REALM}  ipsl.nsn.com
    RETURN  ${IPSL_HOST_IP}  ${IPSL_NAME}  ${IPSL_REALM}


Get Ipsl Core ip
    [Arguments]    ${alias}  ${os}
    [Documentation]
    ...     Wrapper for different OS versions to retrieve the IPSL core ip address
    ...
    ...     | alias | the ssh connection alias to the ipsl |
    ...     | os    | the operating system core |
    ...
    ...     *Returns* the ipsl core ip address

    ${ipsl_core_ip}  IF  '${os}'=='linux'  get linux core ip  ${alias}  ELSE IF  '${os}'=='win'  get win core ip  ${alias}
    RETURN  ${ipsl_core_ip}


Get Win Core IP
    [Arguments]    ${alias}
    [Documentation]
    ...     Get core related ip address from win-ipsl machine
    ...
    ...     | alias | the alias of the ssh connection to the core |
    ...
    ...     *Returns* ip address of windows core

    ssh.Send command  ipconfig| grep 10.44.35  connection=${alias}
    ${text}  ssh.Read output  connection=${alias}
    ssh.Read error  connection=${alias}
    ${_}  ${ip}  split string  ${text}  :
    ${ip}  strip string  ${ip}
    RETURN  ${ip}


Get Linux Core IP
    [Arguments]    ${alias}
    [Documentation]
    ...     Get core related ip address from linux-ipsl machine
    ...
    ...     | alias | the alias of the ssh connection to the core |
    ...
    ...     *Returns* ip address of linux core

    ssh.Send command  ip a | grep 10.44.35  connection=${alias}
    ${text}  ssh.Read output  connection=${alias}
    ssh.Read error  connection=${alias}
    @{words}  split string  ${text}
    ${ip}  string.get substring  ${words[1]}  0  -3
    RETURN  ${ip}


Stop IPSL
    [Arguments]    ${alias}  ${os}
    [Documentation]
    ...     Stop the running IPSL
    ...     | alias | the alias of the ssh connection to the core |
    ...     | os    | the operating system of the core |
    ...
    # robocop: disable=too-few-calls-in-keyword
    IF  '${os}'=='linux'  stop linux IPSL  ${alias}  ELSE IF  '${os}'=='win'  stop win IPSL  ${alias}


Stop Win IPSL
    [Arguments]    ${alias}
    [Documentation]
    ...     Stop the running IPSL on windows IPSL machine
    ...     | alias | the alias of the ssh connection to the core |
    ...
    # robocop: disable=too-few-calls-in-keyword
    Run Keyword and ignore error    ssh.Execute    taskkill /IM ips32.exe /F /T    connection=${alias}


Stop Linux IPSL
    [Arguments]    ${alias}
    [Documentation]
    ...     Stop the running IPSL on windows IPSL machine
    ...     | alias | the alias of the ssh connection to the core |
    # robocop: disable=too-few-calls-in-keyword
    Run Keyword and ignore error    ssh.Execute    killall -I ips32.exe    connection=${alias}


Copy Files To Tmp Folder
    [Arguments]     ${path_to_ipsl_files}
    [Documentation]
    ...     *Scope* Internal
    ...
    ...     Copy ipsl config files from TC folder to $tmp_dir; preparation for variable replacement
    ...

    Remove Directory    ${tmp_dir}    recursive=true
    OperatingSystem.Copy files     ${path_to_ipsl_files}/*.*    ${tmp_dir}


Replace Variables In Include File
    [Documentation]
    ...     variables in __include.h are changed/replaced

    ${in_file_temp}=    OperatingSystem.Get File    ${tmp_dir}/_include.h
    ${out_file}=    Replace Variables    ${in_file_temp}
    Create File    ${tmp_dir}/_include.h    ${out_file}


Copy Files To linux ipsl
    [Arguments]    ${alias}    # ssh handler to IPSL
    [Documentation]
    ...     *Scope* Internal
    ...
    ...     Copies script files from /tmp/IPSL to linux IPSL machine
    ...     | alias | the alias of the ssh connection to the linux ipsl machine |
    ...
    @{files}=    OperatingSystem.List Files In Directory    ${tmp_dir}
    FOR    ${src_file}    IN    @{files}
           ssh.Upload File  ${tmp_dir}/${src_file}  ${linux_path_to_ipsl_files}/${src_file}  connection=${alias}
    END


Copy Files To Windows Ipsl
    [Arguments]    ${alias}    # ssh handler to IPSL
    [Documentation]
    ...     *Scope* Internal
    ...
    ...     Copies script files from /tmp/IPSL to windows IPSL machine
    ...     | alias | the alias of the ssh connection to the window ipsl machine |
    ...
    @{files}=    OperatingSystem.List Files In Directory    ${tmp_dir}
    FOR    ${src_file}    IN    @{files}
           ssh.Upload File  ${tmp_dir}/${src_file}  ${windows_path_to_ipsl_files}/${src_file}  connection=${alias}
    END


Replace Variables And Copy Files To Ipsl
    [Arguments]     ${alias}  ${path_to_ipsl_files}  ${os}
    [Documentation]
    ...     *Scope* Internal
    ...
    ...     combination of KW "copy files to tmp folder", "replace variables in include file", "copy files to ipsl"
    ...     replace variables is only executed if file exists...
    ...
    ...     | alias              | the alias of the ssh connection to the ipsl machine |
    ...     | path_to_ipsl_files | path to there the ipsl files are stored |
    ...     | os                 | operating system of the ipsl machine |

    copy files to tmp folder  ${path_to_ipsl_files}
    ${include_present}  run keyword and return status   file should exist   ${tmp_dir}/_include.h
    IF  ${include_present}  replace variables in include file
    IF  '${os}'=='linux'
    ...        copy files to linux ipsl  ${alias}
    ...        ELSE IF  '${os}'=='win'
    ...        copy files to windows ipsl  ${alias}


Compile Files And Start IPSL
    [Arguments]    ${alias}  ${os}
    [Documentation]
    ...     Compiles and starts the IPSL on the IPSL machine
    ...
    ...     | alias | ssh connection alias to the ipsl machine |
    ...     | os    | operating system of the ipsl machine |
    ...
    # robocop: disable=too-few-calls-in-keyword
    IF  '${os}'=='linux'  compile files and start linux IPSL  ${alias}
    ...    ELSE IF  '${os}'=='win'  compile files and start win IPSL  ${alias}


Compile Files And Start Win IPSL
    [Arguments]    ${alias}    # ssh handler for IPSL
    [Documentation]
    ...     *Scope* Internal
    ...
    ...     Compiles and starts the IPSL on the windows IPSL machine
    ...
    ...     | alias | ssh connection alias to the windows ipsl machine |

     ssh.Execute
     ...    ${windows_ipsl_path}/ipslc.exe ${ipsl_compiler_flags} ${windows_path_to_ipsl_files}/server.ctl
     ...    connection=${alias}
     ssh.Send Command
     ...    cd ${windows_path_to_ipsl_files} & ${windows_ipsl_path}/ips32.exe IPS.CFG  connection=${alias}


Compile Files And Start Linux IPSL
    [Arguments]    ${alias}    # ssh handler for IPSL
    [Documentation]
    ...     *Scope* Internal
    ...
    ...     Compiles and starts the IPSL on the linux IPSL machine
    ...
    ...     | alias | ssh connection alias to the linux ipsl machine |
    ...

    ssh.Execute
    ...     cd ${linux_path_to_ipsl_files}; ${linux_ipsl_path} wine ipslc.exe ${ipsl_compiler_flags} server.ctl
    ...     connection=${alias}
    ssh.Execute    Xvfb :10 -screen 10 1024x768x16  connection=${alias}
    ssh.send command
    ...     export DISPLAY\=:10; cd ${linux_path_to_ipsl_files}; ${linux_ipsl_path} wine ips32.exe IPS.CFG
    ...     connection=${alias}

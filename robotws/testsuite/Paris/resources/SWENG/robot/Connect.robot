*** Settings ***
Documentation
...             == Purpose ==
...             Library to manage connection to any host on a TL
...
...             == Description ==
...             *Concepts:*.
...
...             Thanks to dynamic discovery mechanism, all hosts from CU AND DU parts of TL (GNB and Airphone)
...             are identified and associated instances of host are defined and ranged in pertinent structure
...             4 global variables are filled in Suite setup : GNB_DU, GNB_CU, AP_DU and AP_CU
...             Each variable is an entity (airscale, airframe, ...) that contain upon its type a particular
...             structure. For instance, airscale have a list of system cards (sys[]) and baseband cards (bb[])
...             and each card may have a Master host (M), a Salve host (S) and a Loner host (L1)
...             THen, to access to the master host of the first system card of the DU of GNB,you just have to use
...             GNB_DU.sys[0].M host.
...             To access to slave host of the second baseband card of the CU of GNB, use GNB_CU.bb[1].S
...
...             *Mecanism:*
...
...             Then, most keywords for connection are based on host class, and will use attributes or this class
...             to define which action need to be done.
...             For instance, each host has a proxy, which can be set to None or to another host.
...             When attempting to connect to a host, it will first establish a connection to the proxy if required.
...             Once a connection is established, an alias is associated to it (string). and this association (host<->alias)
...             is saved in a cache (managed by taf.transport.ssh library).
...             From this point, once the connection is established, to execute some commands, only alias is required.
...             The alias will be retrieved in cache to execute command on desired host.
...

Library                             taf.transport.ssh                 WITH NAME    csn
Variables                           ../python/Connect.py
Library                             ../python/Hosts.py

*** Variables ***
# Classical remote paths on TL, from where to download files
${CAPTURE_ROOT_PATH_COMMON}         /ffs/run/logs
${CAPTURE_ROOT_PATH_LOCAL}          /tmp
# Path to scripts
${PathToScripts}                    ${CURDIR}/../shell

*** Keywords ***
#===================================
# SSH Connection
#===================================
SSH Wait For Connect
    [Documentation]                 Service to loop and attempt to establish a connection to a host until success
    ...                             Attempt is executed every <every> seconds and until success or a timeout (<timeout>) expires
    [Arguments]                     ${host}
    ...                             ${timeout}=5 min                        ${every}=20s
    wait until keyword succeeds     ${timeout}                              ${every}
    ...                             SSH Connect                             host=${host}
    [Return]                        ${host.alias}


SSH Connect
    [Documentation]                 Generic service to establish a connection to a host
    ...                             input : host should be a dictonary, containing alias, connection, hasProxy
    ...                                     and optionally proxy and ip
    ...                             Example : SSH Connect                   ${GNB_DU.sys[0].M}
    [Arguments]                     ${host}
    call method                     ${host}                                 connect
    [Return]                        ${host.alias}

SSH Check Connect
    [Documentation]                 Check that a host a available for connection
    [Arguments]                     ${host}
    ${status}                       run keyword and return status
    ...                             SSH Connect                             ${host}
    Dated log                       \tSSH ${host.alias}:status=${status}
    Should be equal                 ${status}                               ${True}

#===================================
# SSH execute
#===================================
SSH Wait For Connect and Cmd
    [Documentation]                 Wait for connection to a host to be establish, then execute on it a command
    ...                             attempt to connect is done every 20 seconds, until 5 min
    [Arguments]                     ${command}
    ...                             ${host}
    ...                             ${timeout}=10
	...                             ${readOuput}=True
    ${alias}                        SSH Wait For Connect                    host=${host}
    ${output}                       SSH Cmd                                 command=${command}
    ...                             alias=${alias}                          timeout=${timeout}
	...                             readOuput=${readOuput}
    [Return]                        ${output}

SSH Wait For Connect and Exec
    [Documentation]                 Wait for connection to a host to be establish, then execute on it a command
    ...                             attempt to connect is done every 20 seconds, until 5 min
    ...                             Here, we use csn.execute command instead of csn.send_command
    [Arguments]                     ${command}
    ...                             ${host}
    ...                             ${timeout}=10
    Dated Log                       Connecting to Controller host: ${host}
    ${alias}                        SSH Wait For Connect                    host=${host}
    ${output}                       SSH Exec                                command=${command}
    ...                             alias=${alias}                          timeout=${timeout}
    [Return]                        ${output}

SSH Connect and Exec
    [Documentation]                 Connect to a host to be establish, then execute on it a command
    ...                             Here, we use csn.execute command instead of csn.send_command
    [Arguments]                     ${command}
    ...                             ${host}
    ...                             ${timeout}=10
    ${alias}                        SSH Connect                             host=${host}
    ${output}                       SSH Exec                                command=${command}
    ...                             alias=${alias}                          timeout=${timeout}
    [Return]                        ${output}

SSH Connect and Cmd
    [Documentation]                 Establish a connection to a host, then execute on it a command
    ...                             If first connection try is faliing, no other attempt is performed
    [Arguments]                     ${command}
    ...                             ${host}
    ...                             ${timeout}=10
    ...                             ${readOuput}=True
    ${alias}                        SSH Connect                             host=${host}
    ${output}                       SSH Cmd                                 command=${command}
    ...                             alias=${alias}                          timeout=${timeout}
    ...                             readOuput=${readOuput}
    [Return]                        ${output}

SSH Cmd
    [Documentation]                 Send a command on a host, knowing its alias (csn.send_command)
    ...                             Connection is supposed to be previously establish
    [Arguments]                     ${command}
    ...                             ${alias}
    ...                             ${timeout}=10
    ...                             ${readOuput}=True
    csn.Send Command                ${command}      timeout=${timeout}      connection=${alias}
    ${output}                       run keyword if                          ${readOuput}==True
    ...                             csn.Read Output                         connection=${alias}
    [Return]                        ${output}

SSH Exec
    [Documentation]                 Execute a command on a host, knowing its alias (csn.execute)
    ...                             Connection is supposed to be previously establish
    [Arguments]                     ${command}
    ...                             ${alias}
    ...                             ${timeout}=10
    ...                             ${debug}=${False}
    run keyword if                  ${debug}
    ...                             Dated Log                               \t\tCMD:[${command}]
    ${output}                       csn.Execute                             ${command}
    ...                             timeout=${timeout}      connection=${alias}
    [Return]                        ${output}

SSH Run Script
    [Documentation]                 Download and execute a script on a host
    [Arguments]                     ${host}
    ...                             ${scriptFile}
    ...                             ${complement}=
    ...                             ${localPath}=${PathToScripts}
    ...                             ${remotePath}=.
    ${cmd}                          Set variable                            ${remotePath}/${script_file} ${complement}
    ${alias}                        SSH Connect                             host=${host}
    Dated Log                       Running script on ${alias}:[${cmd}]
    SSH Upload Script               alias=${alias}                          scriptFile=${scriptFile}
    ...                             localPath=${localPath}                  remotePath=${remotePath}
    ${outExe}                       csn.execute                             ${cmd}
    ...                                 connection=${alias}                 timeout=120s
    [Return]                        ${outExe}

SSH Upload Script
    [Documentation]                 Upload a script on a host knowing its alias and prepare for execution (chmod +x)
    ...                             So, connection should have been previously established
    [Arguments]                     ${alias}
    ...                             ${scriptFile}
    ...                             ${localPath}=${PathToScripts}
    ...                             ${remotePath}=.
    Dated log                       \tDownload [${localPath}/${scriptFile}] to [${alias}:${remotePath}]
    ${outMkdir}                     csn.execute                             mkdir -p ${remotePath}
    ...                                 connection=${alias}
    ${outUpload}                    csn.upload_file
    ...                                 remote_path=${remotePath}/${scriptFile}
    ...                                 local_path=${localPath}/${scriptFile}
    ...                                 connection=${alias}
    ${outChmod}                     csn.execute                             chmod +x ${remotePath}/${scriptFile}
    ...                                 connection=${alias}

SSH Download File
    [Documentation]                 Download a file from remote host
    ...                             if shouldBeRemoved is set to True, original file is removed from remote host
    [Arguments]                     ${host}
    ...                             ${remotePath}
    ...                             ${localPath}
    ...                             ${shouldBeRemoved}=${False}
    ${alias}                        SSH Connect                             host=${host}
    # Download from remote to VM
    Dated log                       Download file [${host.alias}]:${remotePath} to ${localPath}
    csn.download_file               remote_path=${remotePath}
    ...                             local_path=${localPath}
    ...                             connection=${host.alias}
    # Remove file from source if required
    run keyword if                  ${shouldBeRemoved}==${True}
    ...                             SSH Cmd                                 rm ${remotePath}
    ...                             alias=${host.alias}

#===================================
# Ping
#===================================
SSH Was OAM Rebooted
    [Documentation]                 Wait during max <timeout> to detect if the OAM of an <airscale> was rebooted
    ...                             or not (after a SCF modification for instance)
    [Arguments]                     ${airscale}
    ...                             ${timeout}=60s
    Dated log                       Pinging OAM : ${airscale.oam.sshConnection.addr}
    ${status}                       Run Keyword and Return status
    ...                             wait until keyword succeeds             ${timeout}              10s
    ...                                 SSH Check Ping Status               ${airscale.oam}         isPingable=False
    Dated log                       SSH Was OAM Rebooted : ${status}
    [Return]                        ${status}

SSH Check Ping Status
    [Documentation]                 Check if a host is pingable or not pingable
    [Arguments]                     ${host}
    ...                             ${isPingable}=True
    ${packetRec}                    Run                                     ping ${host.sshConnection.addr} -c 1 | grep "received" | cut -d "," -f2
    Dated Log                       Host=${host.sshConnection.addr}, Check pingable=${isPingable}, Packet=${packetRec}
    ${status}                       Run Keyword if                          ${isPingable}
    ...                             Should contain                          ${packetRec}    1
    ...     ELSE                    Should contain                          ${packetRec}    0

#===================================
# Misc
#===================================
Sudo Prefix
    [Documentation]                 Compute sudo prefix to be added before a linux command, upon host
    ...                             On a VM or OAM (cloud case), we add "sudo ", otherwise nothing
    [Arguments]                     ${host}
    # If GNB classical, all hosts required no sudo
    return from keyword if          ${TLConfig.isGnbCloud}==${False}        ${EMPTY}
    # If GNB cloud, all hosts required no sudo
    ${sudoPrefix}                   call method                             ${host}             getSudoPrefix
    [Return]                        ${sudoPrefix}

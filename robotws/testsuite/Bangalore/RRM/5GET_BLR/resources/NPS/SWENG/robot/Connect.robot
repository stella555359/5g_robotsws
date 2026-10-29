*** Settings ***
Library                             taf.transport.ssh                 WITH NAME    csn
Variables                           ../python/Connect.py

*** Variables ***
# Classical remote paths on TL, from where to download files
${CAPTURE_ROOT_PATH_COMMON}         /ffs/run/logs
${CAPTURE_ROOT_PATH_LOCAL}          /tmp

# Path to scripts
${PathToScripts}                    ${CURDIR}/../config/script

#&{HOST_GNB_SYS0_M}                  sshConnection=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection}
#...                                 alias=GNB_SYS0_M
#...                                 boardType=ASIK                  # Dynamically updated by Get Board Type
#...                                 hasProxy=${False}
#...                                 ip=                             # N/A : Only for slave and company
#...                                 sshId=fct-0a                    # N/A :
#...                                 slot=0                          # N/A : only for BSH from master
#...                                 proc=0                          # N/A : only for BSH from master
#...                                 nodeId=0x1011                   # for ADET : only for SS
#...                                 isIPv6=${True}                  # Updated dynamically

#&{HOST_GNB_SYS0_S}                  sshConnection=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection}
#...                                 alias=GNB_SYS0_S
#...                                 boardType=ASIK                  # Propagated from master
#...                                 hasProxy=${True}
#...                                 proxy=${HOST_GNB_SYS0_M}
#                                   For SSH IPv4  :
#...                                 ip=192.168.253.17               # for direct SSH connexion from Master
#                                   For SSH IPv6  :
#...                                 sshId=fct-0b                    # for SSH connexion from Master if IPV6
#                                   For BSH       :
#...                                 slot=0                          # for BSH:Slot in rack, hard coded for the moment
#...                                 proc=1                          # for BSH:Processor id for bsh command
#                                   For ADET
#...                                 nodeId=${None}                  # N/A : only for master
#...                                 isIPv6=${True}                  # N/A : only for master


#&{HOST_GNB_BB0_M}                   sshConnection=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection}
#...                                 alias=GNB_BB0_M
#...                                 boardType=ABIL                  # Dynamically updated by Get Board Type
#...                                 hasProxy=${True}
#...                                 proxy=${HOST_GNB_SYS0_M}
#                                   For SSH IPv4  :
#...                                 ip=192.168.253.20               # for direct SSH connexion from Master
#                                   For SSH IPv6  :
#...                                 sshId=fsp-1a                    # for SSH connexion from Master if IPV6
#...                                 sshId=fsp-1-1a                    # for SSH connexion from Master if IPV6
#                                   For BSH       :
#...                                 slot=1                          # for BSH:Slot in rack, hard coded for the moment
#...                                 proc=0                          # for BSH:Processor id for bsh command

#&{HOST_GNB_BB0_S}                   sshConnection=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection}
#...                                 alias=GNB_BB0_S
#...                                 boardType=ABIL                  # Propagated from master
#...                                 hasProxy=${True}
#...                                 proxy=${HOST_GNB_SYS0_M}
#                                   For SSH IPv4  :
#...                                 ip=192.168.253.21               # for direct SSH connexion from Master
#                                   For SSH IPv6  :
#...                                 sshId=fsp-1b                    # for SSH connexion from Master if IPV6
#                                   For BSH       :
#...                                 slot=1                          # for BSH:Slot in rack, hard coded for the moment
#...                                 proc=1                          # for BSH:Processor id for bsh command

#&{HOST_GNB_BB0_L1}                  sshConnection=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection}
#...                                 alias=GNB_BB0_L1
#...                                 boardType=ABIL                  # Propagated from master
#...                                 hasProxy=${True}
#...                                 proxy=${HOST_GNB_SYS0_M}
#                                   For SSH IPv4  :
#...                                 ip=192.168.253.22               # for direct SSH connexion from Master
#                                   For SSH IPv6  :
#...                                 sshId=fsp-1c                    # for SSH connexion from Master if IPV6
#                                   For BSH       :
#...                                 slot=1                          # for BSH:Slot in rack, hard coded for the moment
#...                                 proc=2                          # for BSH:Processor id for bsh command


#&{HOST_AP_SYS0_M}                   sshConnection=${tl.ues[0].l1.common_units[0].lmp_connection}
#...                                 alias=AP_SYS0_M
#...                                 boardType=ASIK                  # Dynamically updated by Get Board Type
#...                                 hasProxy=${False}
#...                                 ip=                             # N/A : Only for slave and company
#...                                 sshId=fct-0a                    # N/A :
#...                                 slot=0                          # N/A : only for BSH from master
#...                                 proc=0                          # N/A : only for BSH from master
#...                                 nodeId=0x5011                   # for ADET : only for SS
#...                                 isIPv6=${True}                  # Updated dynamically

#&{HOST_AP_SYS0_S}                   sshConnection=${tl.ues[0].l1.common_units[0].lmp_connection}
#...                                 alias=AP_SYS0_S
#...                                 boardType=ASIK                  # Propagated from master
#...                                 hasProxy=${True}
#...                                 proxy=${HOST_AP_SYS0_M}
#                                   For SSH IPv4  :
#...                                 ip=192.168.253.81               # for direct SSH connexion from Master
#                                   For SSH IPv6  :
#...                                 sshId=fct-5-0b                  # for SSH connexion from Master if IPV6
#                                   For BSH       :
#...                                 slot=0                          # for BSH:Slot in rack, hard coded for the moment
#...                                 proc=1                          # for BSH:Processor id for bsh command

#&{HOST_AP_BB0_M}                    sshConnection=${tl.ues[0].l1.common_units[0].lmp_connection}
#...                                 alias=AP_BB0_M
#...                                 boardType=ABIL                  # Dynamically updated by Get Board Type
#...                                 hasProxy=${True}
#...                                 proxy=${HOST_AP_SYS0_M}
#                                   For SSH IPv4  :
#...                                 ip=192.168.253.84               # for direct SSH connexion from Master
#                                   For SSH IPv6  :
#...                                 sshId=fsp-5-1a                  # for SSH connexion from Master if IPV6
#                                   For BSH       :
#...                                 slot=1                          # for BSH:Slot in rack, hard coded for the moment
#...                                 proc=0                          # for BSH:Processor id for bsh command

#&{HOST_AP_BB0_S}                    sshConnection=${tl.ues[0].l1.common_units[0].lmp_connection}
#...                                 alias=AP_BB0_S
#...                                 boardType=ABIL                  # Propagated from master
#...                                 hasProxy=${True}
#...                                 proxy=${HOST_AP_SYS0_M}
#                                   For SSH IPv4  :
#...                                 ip=192.168.253.85               # for direct SSH connexion from Master
#                                   For SSH IPv6  :
#...                                 sshId=fsp-5-1b                  # for SSH connexion from Master if IPV6
#                                   For BSH       :
#...                                 slot=1                          # for BSH:Slot in rack, hard coded for the moment
#...                                 proc=1                          # for BSH:Processor id for bsh command

#&{HOST_AP_BB0_L1}                   sshConnection=${tl.ues[0].l1.common_units[0].lmp_connection}
#...                                 alias=AP_BB0_L1
#...                                 boardType=ABIL                  # Propagated from master
#...                                 hasProxy=${True}
#...                                 proxy=${HOST_AP_SYS0_M}
#                                   For SSH IPv4  :
#...                                 ip=192.168.253.86               # for direct SSH connexion from Master
#                                   For SSH IPv6  :
#...                                 sshId=fsp-5-1c                  # for SSH connexion from Master if IPV6
#                                   For BSH       :
#...                                 slot=1                          # for BSH:Slot in rack, hard coded for the moment
#...                                 proc=2                          # for BSH:Processor id for bsh command

# List of knows hosts on a TL, and their associated dictionary
# ============================================================
#   sshConnection  : connection information for SSH
#   alias          : alias for SSH
#   hasProxy       : indicates if conection need to use a proxy or not
#   proxy          : reference to host proxy
#   ip             : IP @ for proxy
#   httpConnection : connection information for HTTP
#   url            : URL link for http
#   httpAlias      : alias for http
#   isCloud        : indicates if host is in cloud or not
# GNB : OAM and its VMs
# ======================
# OAM for GNB : http information are dynamically built in Setup
#&{HOST_GNB_OAM}                     sshConnection=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection}
#...                                 alias=GNB_OAM                                       hasProxy=False
#...                                 httpConnection=None
#...                                 url=None
#...                                 httpAlias=HTTP_GNB_OAM                              isCloud=${False}

#&{HOST_GNB_OAM_CU}                  sshConnection=${tl.gnbs[0].cu.oam_ssh_connection_details}
#...                                 alias=GNB_OAM_CU                                    hasProxy=False
#...                                 httpConnection=${tl.gnbs[0].cu.oam_http_connection_details}
#...                                 url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
#...                                 httpAlias=HTTP_GNB_OAM_CU                           isCloud=${True}

# AIRPHONE : OAM
#&{HOST_AP_OAM}                      sshConnection=${TLConfig.ues[0].oam_ssh_connection_details}
#...                                 alias=AP_OAM                                        hasProxy=False
#...                                 httpConnection=${TLConfig.ues[0].oam_http_connection_details}
#...                                 url=https://${TLConfig.ues[0].oam_http_connection_details.addr}
#...                                 httpAlias=HTTP_AP_OAM                               isCloud=${TLConfig.ues[0].isCloud}

#&{HOST_GNB_CPIF}                    sshConnection=${tl.gnbs[0].cu.oam_ssh_connection_details}
#...                                 alias=GNB_CPIF                                      hasProxy=True
#...                                 proxy=${HOST_GNB_OAM_CU}                            sshId=cpif-0.local
#&{HOST_GNB_CPCL}                    sshConnection=${tl.gnbs[0].cu.oam_ssh_connection_details}
#...                                 alias=GNB_CPCL                                      hasProxy=True
#...                                 proxy=${HOST_GNB_OAM_CU}                            sshId=cpcl-0.local
#&{HOST_GNB_CPNB}                    sshConnection=${tl.gnbs[0].cu.oam_ssh_connection_details}
#...                                 alias=GNB_CPNB                                      hasProxy=True
#...                                 proxy=${HOST_GNB_OAM_CU}                            sshId=cpnb-0.local
#&{HOST_GNB_CPUE}                    sshConnection=${tl.gnbs[0].cu.oam_ssh_connection_details}
#...                                 alias=GNB_CPUE                                      hasProxy=True
#...                                 proxy=${HOST_GNB_OAM_CU}                            sshId=cpue-0.local
#&{HOST_GNB_UPUE}                    sshConnection=${tl.gnbs[0].cu.oam_ssh_connection_details}
#...                                 alias=GNB_UPUE                                      hasProxy=True
#...                                 proxy=${HOST_GNB_OAM_CU}                            sshId=upue-0.local

# Airphone : ePCSIM : sshConnection is first set to None. Will be updated in Test Setup upon we are in UTE or not
#&{HOST_EPCSIM}                      sshConnection=None
#...                                 alias=EPCSIM                                        hasProxy=False


# List of hosts for which a sudo prefix is required for a linux command (tcpdump for instance)
#@{HOST_SUDO_REQUIRED}               ${HOST_GNB_CPIF.alias}       ${HOST_GNB_CPCL.alias}       ${HOST_GNB_CPNB.alias}
#...                                 ${HOST_GNB_CPUE.alias}       ${HOST_GNB_UPUE.alias}       ${HOST_GNB_OAM_CU.alias}
#...                                 ${HOST_GNB_OAM.alias}        ${HOST_EPCSIM.alias}

# Airscale : GNB and AP (AirPhone)
#==================================
#   name        : Name (for display)
#   sys         : list of system cards
#   bb          : list of broad band cards
#  for backward compatibility
#   asik        : reference to ASIK host
#   oam         : reference to OAM host
#   listNodeId  : list of NODE IDs on ASIK
# GNB : Card SYS number 0 : 1 master and 1 slave
#&{GNB_SYS0}                         M=${HOST_GNB_SYS0_M}
#...                                 S=${HOST_GNB_SYS0_S}
# GNB : Card BB number 0 : 1 master, 1 slave and 1 L1
#&{GNB_BB0}                          M=${HOST_GNB_BB0_M}
#...                                 S=${HOST_GNB_BB0_S}
#...                                 L1=${HOST_GNB_BB0_L1}
# Same for AP
#&{AP_SYS0}                          M=${HOST_AP_SYS0_M}
#...                                 S=${HOST_AP_SYS0_S}
#&{AP_BB0}                           M=${HOST_AP_BB0_M}
#...                                 S=${HOST_AP_BB0_S}
#...                                 L1=${HOST_AP_BB0_L1}

# GNB and AP lists of SYS card and BB cards
#@{GNB_SYS_LIST}                     ${GNB_SYS0}
#@{GNB_BB_LIST}                      ${GNB_BB0}
#@{AP_SYS_LIST}                      ${AP_SYS0}
#@{AP_BB_LIST}                       ${AP_BB0}

# Airscale for GNB : OAM is dynamically set in Setup.robot
#&{AIRSCALE_GNB}                     name=GNB
#...                                 oam=None
#...                                 sys=${GNB_SYS_LIST}
#...                                 bb=${GNB_BB_LIST}
#                                   For backward compatibilty
#...                                 asik=${HOST_GNB_SYS0_M}
#...                                 listNodeId=@{airscaleNodeID}

#&{AIRFRAME_GNB_CU}                  name=GNB_CU
#...                                 oam=None

#&{AIRSCALE_AP}                      name=AP
#...                                 oam=${HOST_AP_OAM}
#...                                 sys=${AP_SYS_LIST}
#...                                 bb=${AP_BB_LIST}
#                                   For backward compatibilty
#...                                 asik=${HOST_AP_SYS0_M}
#...                                 listNodeId=@{AIRPHONE_airscaleNodeID}


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
    ...                             Example : SSH Connect                   ${GNB_ASIK_M}
    [Arguments]                     ${host}
    ${alias}                        run keyword if                          ${host.hasProxy}
    ...                             SSH Connect by proxy                    ${host}   ${host.proxy}
    ...                             ELSE
    ...                             SSH Connect directly                    ${host}
    [Return]                        ${alias}


SSH Connect directly
    [Documentation]                 Establish a connection to a host when host has directly a public adress
    [Arguments]                     ${host}
    csn.Connect to                  hostname=${host.sshConnection.addr}
    ...                             username=${host.sshConnection.username}
    ...                             password=${host.sshConnection.password}
    ...                             alias=${host.alias}
    [Return]                        ${host.alias}

SSH Connect by proxy
    [Documentation]                 Establish a connection to a host when host has a private adress
    ...                             A first connection is then established on its proxy
    ...                             Then, a connection using proxy mechanism is used to reach final target
    [Arguments]                     ${host}
    ...                             ${proxy}
    csn.Connect to                  hostname=${proxy.sshConnection.addr}
    ...                             username=${proxy.sshConnection.username}
    ...                             password=${proxy.sshConnection.password}
    ...                             alias=${proxy.alias}
    csn.Connect to                  hostname=${host.sshId}
    ...                             username=${host.sshConnection.username}
    ...                             password=${host.sshConnection.password}
    ...                             proxy=${proxy.alias}
    ...                             alias=${host.alias}
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
    #${output}                       csn.Read Output                         connection=${alias}
    [Return]                        ${output}

SSH Exec
    [Documentation]                 Execute a command on a host, konwing its alias (csn.execute)
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
    return from keyword if          ${TLConfig.isGnbCloud}==${False}        ${SPACE}
    # If GNB cloud, all hosts required no sudo
    FOR  ${h}  IN  @{HOST_SUDO_REQUIRED}
       return from keyword if       '${h}'=='${host.alias}'                 sudo${SPACE}
    END
    [Return]                        ${SPACE}


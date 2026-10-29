*** Settings ***
Documentation  Keyword allows ssh connection to remote machine.
...            IP addresses are available in common variables files or can be overwritten in every TL config.

Library  taf.transport.ssh		WITH NAME	csn
Library  testsuite/Krakow/TRS/features/FR5GC001250_JA_5GC000269/resources/mzoam_common_resources/trs_resources.py
Library  taf.ul.oam.selenium_megazone
Library  testsuite/Krakow/TRS/features/FR5GC001250_JA_5GC000269/resources/mzoam_common_resources/ssh_keys.py
Library  testsuite/Krakow/TRS/features/FR5GC001250_JA_5GC000269/resources/mzoam_common_resources/check_IP.py
Resource  testsuite/Krakow/TRS/features/FR5GC001250_JA_5GC000269/resources/mzoam_common_resources/gather_logs_for_test_analysis.robot
Library   DateTime
Library   OperatingSystem
Library   testsuite/Krakow/TRS/features/FR5GC001250_JA_5GC000269/resources/mzoam_common_resources/coam_bts_operations.py

*** Variables ***
${BB2_IP}=           192.168.2.62
${BB2_IP_LOCAL}      192.168.255.31
${BB2_LOGIN}=        _rcpadmin
${BB2_PASSWORD}=     RCP_owner

${BB1_IP_LOCAL_CLASSICAL}      192.168.255.129
${BB1_IP_LOCAL}      192.168.255.1
${BB1_LOGIN}=        toor4nsn
${BB1_PASSWORD}=     oZPS0POrRieRtu

${RADIO_N0_IP}=      172.16.1.5
${RADIO_USERNAME}=   root
${RADIO_PASSWORD}=   umniedziala

${serviceuser_password}=    Pl(FzaYj5~c5;q

${webui_username}=          Nemuadmin
${webui_password}=          nemuuser


*** Keywords ***
Connect to OAM
    [Arguments]    ${oam_addr}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...            ${oam_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...            ${oam_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...            ${alias}=OAM
    csn.Connect to     ${oam_addr}     ${oam_username}     ${oam_password}    alias=${alias}

Connect to AUTH
    [Arguments]    ${oam_addr}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...            ${oam_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...            ${oam_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...            ${alias}=AUTH
    csn.Connect to     ${oam_addr}     ${oam_username}     ${oam_password}    alias=${alias}

Connect via root if passed username fails
    [Arguments]     ${hostname}     ${username}    ${password}    ${alias}     ${proxy}
    # If the connection with given credentials fails, try to connect with 'root' / discovered key
    ${connected via robot account}=    Run keyword and return status
    ...    csn.Connect to    hostname=${hostname}    username=${username}    password=${password}    alias=${alias}
    ...    proxy=${proxy}
    Run keyword unless    ${connected via robot account}
    ...    csn.Connect to    hostname=${hostname}    username=root    alias=${alias}    proxy=${proxy}

Connect to CPCL
    [Arguments]     ${hostname}=cpcl-0.local
    ...             ${cpcl_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...             ${cpcl_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...             ${alias}=CPCL    ${proxy}=OAM
    Connect via root if passed username fails    hostname=${hostname}    username=${cpcl_username}    password=${cpcl_password}
    ...     alias=${alias}    proxy=${proxy}

Connect to CPIF
    [Arguments]     ${hostname}=cpif-0.local
    ...             ${cpif_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...             ${cpif_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...             ${alias}=CPIF    ${proxy}=OAM
    Connect via root if passed username fails    hostname=${hostname}    username=${cpif_username}    password=${cpif_password}
    ...     alias=${alias}    proxy=${proxy}

Connect to CPNB
    [Arguments]     ${hostname}=cpnb-0.local
    ...             ${cpnb_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...             ${cpnb_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...             ${alias}=CPNB    ${proxy}=OAM
    Connect via root if passed username fails    hostname=${hostname}    username=${cpnb_username}    password=${cpnb_password}
    ...     alias=${alias}    proxy=${proxy}

Connect to CPUE
    [Arguments]     ${hostname}=cpue-0.local
    ...             ${cpue_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...             ${cpue_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...             ${alias}=CPUE    ${proxy}=OAM
    Connect via root if passed username fails    hostname=${hostname}    username=${cpue_username}    password=${cpue_password}
    ...     alias=${alias}    proxy=${proxy}

Connect to UPUE
    [Arguments]     ${hostname}=upue-0.local
    ...             ${upue_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...             ${upue_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...             ${alias}=UPUE    ${proxy}=OAM
    Connect via root if passed username fails     hostname=${hostname}    username=${upue_username}    password=${upue_password}
    ...     alias=${alias}    proxy=${proxy}

Connect to DBVM
    [Arguments]     ${hostname}=ci-tl1-1-db-0.local    ${alias}=DBVM    ${proxy}=OAM
    Connect via root if passed username fails    hostname=${hostname}   username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                                          password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...     alias=${alias}    proxy=${proxy}

Connect LteEmulator
    [Arguments]       ${alias}=LTEemu    ${enb_id}=0
    csn.Connect to     hostname=${tl.enbs[${enb_id}].default_ssh_connection_details.addr}
    ...                username=${tl.enbs[${enb_id}].default_ssh_connection_details.username}
    ...                password=${tl.enbs[${enb_id}].default_ssh_connection_details.password}
	...                alias=${alias}

Connect to L2L3
    [Arguments]        ${alias}=l2l3    ${id}=0
    csn.Connect to     hostname=${tl.ues[${id}].l3_ssh_connection_details.addr}
    ...                username=${tl.ues[${id}].l3_ssh_connection_details.username}
    ...                password=${tl.ues[${id}].l3_ssh_connection_details.password}
    ...                alias=${alias}

Create megazone session with alias
    [Arguments]   ${gnb_id}=0        ${alias}=megazone_oam
     Wait Until Keyword Succeeds     3min    10s    megazone_client.create_session
     ...    base_url=https://${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}    alias=${alias}


# CNCP, UEUP and UECP will be deprecated
Connect to CNCP
    [Arguments]     ${hostname}=cncp-0.local
    ...             ${cncp_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...             ${cncp_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...             ${alias}=CNCP    ${proxy}=OAM
    Connect via root if passed username fails    hostname=${hostname}    username=${cncp_username}    password=${cncp_password}
    ...     alias=${alias}    proxy=${proxy}

Connect to UEUP
    [Arguments]     ${hostname}=ueup-0.local
    ...             ${ueup_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...             ${ueup_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...             ${alias}=UEUP    ${proxy}=OAM
    Connect via root if passed username fails    hostname=${hostname}    username=${ueup_username}    password=${ueup_password}
    ...     alias=${alias}    proxy=${proxy}

Connect to UECP
    [Arguments]     ${hostname}=uecp-0.local
    ...             ${uecp_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...             ${uecp_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...             ${alias}=UECP    ${proxy}=OAM
    Connect via root if passed username fails    hostname=${hostname}    username=${uecp_username}    password=${uecp_password}
    ...     alias=${alias}    proxy=${proxy}

Connect to CPNRT
    [Arguments]     ${hostname}=cpnrt-0.local
    ...             ${cpnrt_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...             ${cpnrt_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...             ${alias}=CPNRT    ${proxy}=OAM
    Connect via root if passed username fails    hostname=${hostname}    username=${cpnrt_username}    password=${cpnrt_password}
    ...     alias=${alias}    proxy=${proxy}

Connect to BB2
    [Arguments]     ${alias}=BB2    ${proxy}=OAM
    csn.Connect to    hostname=${BB2_IP}    username=${BB2_LOGIN}     password=${BB2_PASSWORD}    alias=${alias}     proxy=${proxy}

Connect to BB1
    [Arguments]     ${alias}=BB1    ${proxy}=OAM
    ${BB1_IP}=    get_tnl_4_ipv6_3_address
    csn.Connect to    hostname=${BB1_IP}    username=${BB1_LOGIN}     password=${BB1_PASSWORD}    proxy=${proxy}  alias=${alias}

Connect to BB1 local
    [Arguments]     ${alias}=BB1    ${hostname}=${BB1_IP_LOCAL}    ${username}=${BB1_LOGIN}    ${password}=${BB1_PASSWORD}
    csn.Connect to    hostname=${hostname}    username=${username}     password=${password}    alias=${alias}

Connect to BB2 local
    [Arguments]     ${alias}=BB2
    csn.Connect to    hostname=${BB2_IP_LOCAL}    username=${BB2_LOGIN}     password=${BB2_PASSWORD}    alias=${alias}

Connect to RF
    [Arguments]   ${alias}=RF   ${proxy}=BB1
    csn.Connect to    hostname=${RADIO_N0_IP}    username=${RADIO_USERNAME}    password=${RADIO_PASSWORD}    alias=${alias}    proxy=${proxy}

Connect to RPI
    csn.connect to    hostname=${tl.hardware_controllers[0].default_ssh_connection_details.addr}
    ...               username=${tl.hardware_controllers[0].default_ssh_connection_details.username}
    ...               password=${tl.hardware_controllers[0].default_ssh_connection_details.password}
    ...               timeout=30   alias=RPI

Create And Setup SSH Connection
    [Arguments]    ${host}    ${user}=toor4nsn    ${password}=oZPS0POrRieRtu    ${timeout}=20   ${alias}=Default
    ${ssh_connection}=    csn.Connect to    hostname=${host}    username=${user}    password=${password}    timeout=${timeout}   alias=${alias}
    [Return]    ${ssh_connection}

Execute Command Via SSH On Remote Node
    [Arguments]    ${ssh_conn_obj}    ${cmd}
    csn.Send Command    connection=${ssh_conn_obj}    command=${cmd}
    ${stdout}=    csn.Read Output    connection=${ssh_conn_obj}
    ${stderr}=    csn.Read Error     connection=${ssh_conn_obj}
    ${command_output}=    Catenate    ${stdout}    ${stderr}
    [Return]    ${command_output}

Log into WebUI
    [Arguments]             ${webui_hostname}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Log to console          \nLogging into WebUI
    ${webui_ip}=            check_IP.format_ip_address_if_ipv6
    ...                     https://${webui_hostname}/login.html
    enable virtual display
    Login                   ${webui_ip}
    ...                     ${webui_username}
    ...                     ${webui_password}


Log out from WebUI
    Log to console          \nLogging out from WebUI
    Logout
    disable virtual display

Connect to OAM as serviceuser
    ${connection}=  csn.Connect to  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                             serviceuser
    ...                             ${serviceuser_password}
    ...                             alias=OAM_serviceuser
    [Return]  ${connection}

Connect to DU as serviceuser
    ${BB1_IP}=    get_tnl_4_ipv6_3_address
    csn.Connect to  ${BB1_IP}
    ...             serviceuser
    ...             ${serviceuser_password}
    ...             proxy=OAM
    ...             alias=DU_serviceuser

Connect to DU as toor4nsn
    ${BB1_IP}=    get_tnl_4_ipv6_3_address
    csn.Connect to  ${BB1_IP}
    ...             ${BB1_LOGIN}
    ...             ${BB1_PASSWORD}
    ...             proxy=OAM
    ...             alias=DU_toor4nsn

Connect via LMP as serviceuser
    csn.Connect to  ${BB1_IP_LOCAL}
    ...             serviceuser
    ...             ${serviceuser_password}
    ...             alias=LMP_serviceuser

Connect to DU toor4nsn with SSH key and execute command
    [Arguments]  ${command}
    ${answer}=  connect to DU as toor4nsn and execute command  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                                                        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                                                        ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                                                        ${command}
    [Return]  ${answer}

Create SSH keys
    create ssh keypair for  ${BB1_LOGIN}
    ...                     serviceuser

Set keys permissions on CU
    csn.Connect to  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...             ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...             ${robot_password}
    ...             alias=key_perms
    csn.execute     sudo chmod 400 *.key
    ...             connection=key_perms

Set keys permissions on DU
    csn.Connect to  ${BB1_IP_LOCAL}
    ...             serviceuser
    ...             ${serviceuser_password}
    ...             alias=key_perms
    csn.execute     chmod 400 /user/serviceuser/*.key
    ...             connection=key_perms

Delete private keys from CU
    Connect to OAM
    csn.execute  sudo rm *.key
    ...          connection=OAM

Delete private keys from DU
    Connect via LMP as serviceuser
    csn.execute  chmod 777 *.key
    ...          connection=LMP_serviceuser
    csn.execute  rm *.key
    ...          connection=LMP_serviceuser

Send private keys to CU and DU
    [Arguments]  ${private_keys_paths}
    send private keys to     CU
    ...                      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                      ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                      ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                      ${private_keys_paths}
    send private keys to     DU
    ...                      ${BB1_IP_LOCAL}
    ...                      serviceuser
    ...                      ${serviceuser_password}
    ...                      ${private_keys_paths}

Connection to admin
    [Arguments]  ${ip_address}        ${alias}=cOAM_admin
    ...          ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...          ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ${date}=	Get Current Date
    Create directory  /home/ute/test_results/admin
    Create directory  /home/ute/test_results/admin/${date}
    ${connection}=  create_connection  ip_address=${ip_address}
    ...                                                    alias=${alias}
    ...                                                    username=${username}
    ...                                                    password=${password}
    ...                                                    date=/home/ute/test_results/admin/${date}
    [Return]  ${connection}

Disconnection from admin
    [Arguments]  ${alias}=cOAM_admin
    teardown_connection  ${alias}

Connect to Cloud cOAM as toor4nsn
    [Arguments]  ${ip_address}=${BB1_IP_LOCAL_CLASSICAL}  ${alias}=cOAM_toor4nsn  ${password}=${BB1_PASSWORD}
    ${connection}=  ssh.Connect to  ${ip_address}
    ...                             ${BB1_LOGIN}
    ...                             ${password}
    ...                             alias=${alias}
    [Return]  ${connection}

Reboot Cloud BTS and wait until available
    Connect to Cloud cOAM as toor4nsn
    log to console  Rebooting BTS...
    ssh.send command  command=ddal -s ddal_reboot_graceful  connection=cOAM_toor4nsn
    log to console  Shutting down BTS...
    sleep  30s
    log to console  Waiting until BTS is up...
    Wait until keyword succeeds  15 min  20sec  Connect to Cloud cOAM as toor4nsn
    [Teardown]  Disconnect from cOAM

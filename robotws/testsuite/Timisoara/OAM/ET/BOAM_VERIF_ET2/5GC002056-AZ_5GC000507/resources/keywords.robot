*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Library    taf.transport.ssh
Library    taf.sbts.oam.coam.admin
Library    taf.ul.oam.selenium_coam

Resource    ../../resources/admin.robot
Resource    ../../resources/fault_trigger.robot
Resource    ../../resources/selenium.robot

*** Variables ***
# ${SMOD_SW_Update_directory_planned}    /ffs/stb/planned/
# ${SMOD_SW_Update_file_SWDLreport}    /tmp/SWDLreport.txt
${SMOD_com_reboot}    ddal -s ddal_reboot_graceful
${SMOD_com_reboot_blackbox}    export PYTHONPATH=/opt/hwmt/python; python /opt/hwmt/python/hwapi/MIT_reset_5G.py --i 192.168.255.1 -n 0x1011 -b 0x10
...                            -c 0x11 -s 1 -e 6 -p 15004

${SW_DESTINATION}     /home/ute
${URL_5G}=    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release

*** Keywords ***
# BuiltIn
Get Status Should Be Equal
    [Documentation]    Returns Boolean. True or False.
    [Arguments]        ${first}
    ...                ${second}
    ${status}    Run Keyword And Return Status    Should Be Equal    ${first}    ${second}
    [Return]     ${status}

Get Status List Should Contain Value
    [Documentation]    Returns Boolean. True or False.
    [Arguments]        ${list}
    ...                ${value}
    ${status}    Run Keyword And Return Status    collections.List Should Contain Value    list_=${list}    value=${value}
    [Return]     ${status}

# SYSTEM Test PC
PC BTS Should Be Connected
    Log To Console    PC BTS Should Be Connected
    ${output}         OperatingSystem.Run    command=ping -c 1 -W 10 192.168.255.1
    Should Contain    ${output}              1 packets transmitted, 1 received    timeout=5

PC BTS Should Be Disconnected
    Log To Console        PC BTS Should Be Disconnected
    ${output}             OperatingSystem.Run    command=ping -c 1 -W 10 192.168.255.1
    Should Not Contain    ${output}              1 packets transmitted, 1 received    timeout=5

PC Wait Until BTS Should Be Connected
    [Arguments]    ${retry}=5 min
    ...            ${retry_interval}=30 sec
    Log To Console                 PC Wait Until BTS Should Be Connected \${retry}=${retry} \${retry_interval}=${retry_interval}
    Wait Until Keyword Succeeds    ${retry}
    ...                            ${retry_interval}
    ...                            PC BTS Should Be Connected

PC Wait Until BTS Should Be Disconnected
    [Arguments]    ${retry}=1 min
    ...            ${retry_interval}=10 sec
    Log To Console                 PC Wait Until BTS Should Be Disconnected \${retry}=${retry} \${retry_interval}=${retry_interval}
    Wait Until Keyword Succeeds    ${retry}
    ...                            ${retry_interval}
    ...                            PC BTS Should Be Disconnected

PC Wait Until BTS Disconnected And Connected
    Log To Console    PC Wait Until BTS Disconnected And Connected
    [Arguments]    ${retry_dis}=5 min
    ...            ${retry_interval_dis}=10 sec
    ...            ${retry_con}=15 min
    ...            ${retry_interval_con}=30 sec
    PC Wait Until BTS Should Be Disconnected    retry=${retry_con}    retry_interval=${retry_interval_con}
    PC Wait Until BTS Should Be Connected       retry=${retry_dis}    retry_interval=${retry_interval_dis}

# TODO: PC Get Fault In File Active Alarm Indicator
# TODO: PC Fault Should Be In File Active Alarm
# TODO: PC Fault Should Not Be In File Active Alarm
# TODO: PC Get Amount Of Fault In File Active Alarm

PC Get Fault In File Alarm History Indicator
    [Documentation]    Assuming file is in SYSTEM PC.
    ...    File can contain spaces, so grep expression is quoted in ' characters.
    ...    Returns integer 1 or 0.
    [Arguments]    ${fault_id}
    ...            ${path_full}
    Log To Console    Indicator - Fault In File - Alarm History
    ${fault_id}    Convert To String    ${fault_id}
    ${fault_indicator}    OperatingSystem.Run
    ...    command=cat '${path_full}' | grep -c '"${faultId}"'
    Log To Console    \${fault_indicator}=${fault_indicator}
    [Return]    ${fault_indicator}

PC Fault Should Be In File Alarm History
    [Documentation]    Assuming file is in SYSTEM PC.
    ...    File can contain spaces, so grep expression is quoted in ' characters.
    [Arguments]    ${fault_id}
    ...            ${path_full}
    Log To Console    Fault Should Be In File
    ${fault_indicator}    PC Get Fault In File Alarm History Indicator    fault_id=${fault_id}    path_full=${path_full}
    Should Be True    ${fault_indicator}

PC Fault Should Not Be In File Alarm History
    [Documentation]    Assuming file is in SYSTEM PC.
    ...    File can contain spaces, so grep expression is quoted in ' characters.
    [Arguments]    ${fault_id}
    ...            ${path_full}
    Log To Console    Fault Should Not Be In File
    ${fault_indicator}    PC Get Fault In File Alarm History Indicator    fault_id=${fault_id}    path_full=${path_full}
    Should Not Be True    ${fault_indicator}

# TODO: PC Get Amount Of Fault In File Alarm History

# TODO: PC Fault Should Be In File Blackbox Alarm    // assuming file is in SYSTEM PC
# TODO: PC Fault Should Not Be In File Blackbox Alarm    // assuming file is in SYSTEM PC

PC Create Batch File - RMOD Fault 1937 Trigger
    Log To Console    PC Create Batch File - RMOD Fault 1937 Trigger
    Run Keyword If    '${out_rmods_productnames_list[0]}' == 'AHPD'
    ...    PC Create Batch File - RMOD Fault 1937 Trigger - AHPD
    ...    ELSE IF    '${out_rmods_productnames_list[0]}' == 'AHLOA'
    ...    PC Create Batch File - RMOD Fault 1937 Trigger - AHLOA
    ...    ELSE IF    '${out_rmods_productnames_list[0]}' == 'AEQN'
    ...    PC Create Batch File - RMOD Fault 1937 Trigger - AEQN
    ...    ELSE IF    '${out_rmods_productnames_list[0]}' == 'AEUA'
    ...    PC Create Batch File - RMOD Fault 1937 Trigger - AEUA
    ...        # ELSE IF    '${out_rmods_productnames_list[0]}' == 'AEUB'
    ...        # PC Create Batch File - RMOD Fault 1937 Trigger - AEUB
    ...    ELSE
    ...    Fail    msg=Trigger fault 1937 batch file - Unsupported RMOD.

PC Create Batch File - RMOD Fault 1937 Trigger - AHPD
    PC Create Batch File - RMOD Fault 1937 Trigger - version 1

PC Create Batch File - RMOD Fault 1937 Trigger - AHLOA
    PC Create Batch File - RMOD Fault 1937 Trigger - version 1

PC Create Batch File - RMOD Fault 1937 Trigger - AEQN
    PC Create Batch File - RMOD Fault 1937 Trigger - version 3

PC Create Batch File - RMOD Fault 1937 Trigger - AEUA
    PC Create Batch File - RMOD Fault 1937 Trigger - version 2

PC Create Batch File - RMOD Fault 1937 Trigger - AEUB
    PC Create Batch File - RMOD Fault 1937 Trigger - version 2

PC Create Batch File - RMOD Fault 1937 Trigger - version 1
    create file     /tmp/batch_1  / action create ConfigAccess /CI/ConfigAccess_Module /module\n
    append to file  /tmp/batch_1  /CI/ConfigAccess_Module action fetch DECODED "tempest_inst1.bin" "/var/tmp/tempest_inst1_default.json"\n
    append to file  /tmp/batch_1  /CI/ConfigAccess_Module action fetch DECODED "tcs.bin" "/var/tmp/tcs_default.json"\n

    create file     /tmp/batch_2p1  /CI/ConfigAccess_Module action store TEMPORARY DECODED
    append to file  /tmp/batch_2p1  ${SPACE}"tempest_inst1.bin" "/var/tmp/tempest_inst1_default.json"\n
    append to file  /tmp/batch_2p1  /CI/ConfigAccess_Module action update\n
    create file     /tmp/batch_2p2  / action create ThermometerDevice /rf /rf/tx1\n
    append to file  /tmp/batch_2p2  /rf action override TEMPERATURE 85\n

PC Create Batch File - RMOD Fault 1937 Trigger - version 2
    create file     /tmp/batch_1  / action create ConfigAccess /CI/ConfigAccess_Module /module\n
    append to file  /tmp/batch_1  /CI/ConfigAccess_Module action fetch DECODED "tempest_inst1.bin" "/var/tmp/tempest_inst1_default.json"\n
    append to file  /tmp/batch_1  /CI/ConfigAccess_Module action fetch DECODED "tcs.bin" "/var/tmp/tcs_default.json"\n

    create file     /tmp/batch_2p1  /CI/ConfigAccess_Module action store TEMPORARY DECODED
    append to file  /tmp/batch_2p1  ${SPACE}"tempest_inst1.bin" "/var/tmp/tempest_inst1_default.json"\n
    create file     /tmp/batch_2p2  / action create ThermometerDevice /trx /rf/trx\n
    append to file  /tmp/batch_2p2  /trx action override TEMPERATURE 65\n

PC Create Batch File - RMOD Fault 1937 Trigger - version 3
    create file     /tmp/batch_1  / action create ConfigAccess /CI/ConfigAccess_Module /module\n
    append to file  /tmp/batch_1  /CI/ConfigAccess_Module action fetch DECODED "tempest_inst3.bin" "/var/tmp/tempest_inst3_default.json"\n
    append to file  /tmp/batch_1  /CI/ConfigAccess_Module action fetch DECODED "tcs.bin" "/var/tmp/tcs_default.json"\n

    create file     /tmp/batch_2p1  /CI/ConfigAccess_Module action store TEMPORARY DECODED
    append to file  /tmp/batch_2p1  ${SPACE}"tempest_inst3.bin" "/var/tmp/tempest_inst3_default.json"\n
    append to file  /tmp/batch_2p1  /CI/ConfigAccess_Module action update\n
    create file     /tmp/batch_2p2  / action create ThermometerDevice /module/ASC0_internal /module/ASC0_internal\n
    append to file  /tmp/batch_2p2  /module/ASC0_internal action override TEMPERATURE 80\n

PC Create Batch File - RMOD Fault 1937 Canceller
    Run Keyword If    '${out_rmods_productnames_list[0]}' == 'AHPD'
    ...    PC Create Batch File - RMOD Fault 1937 Canceller - AHPD
    ...    ELSE IF    '${out_rmods_productnames_list[0]}' == 'AHLOA'
    ...    PC Create Batch File - RMOD Fault 1937 Canceller - AHLOA
    ...    ELSE IF    '${out_rmods_productnames_list[0]}' == 'AEQN'
    ...    PC Create Batch File - RMOD Fault 1937 Canceller - AEQN
    ...    ELSE IF    '${out_rmods_productnames_list[0]}' == 'AEUA'
    ...    PC Create Batch File - RMOD Fault 1937 Canceller - AEUA
    ...        # ELSE IF    '${out_rmods_productnames_list[0]}' == 'AEUB'
    ...        # PC Create Batch File - RMOD Fault 1937 Canceller - AEUB
    ...    ELSE
    ...    Fail    msg=Canceller fault 1937 batch file - Unsupported RMOD.

PC Create Batch File - RMOD Fault 1937 Canceller - AHPD
    PC Create Batch File - RMOD Fault 1937 Canceller - version 1

PC Create Batch File - RMOD Fault 1937 Canceller - AHLOA
    PC Create Batch File - RMOD Fault 1937 Canceller - version 1

PC Create Batch File - RMOD Fault 1937 Canceller - AEQN
    PC Create Batch File - RMOD Fault 1937 Canceller - version 3

PC Create Batch File - RMOD Fault 1937 Canceller - AEUA
    PC Create Batch File - RMOD Fault 1937 Canceller - version 2

PC Create Batch File - RMOD Fault 1937 Canceller - AEUB
    PC Create Batch File - RMOD Fault 1937 Canceller - version 2

PC Create Batch File - RMOD Fault 1937 Canceller - version 1
    create file     /tmp/batch_1  / action create ConfigAccess /CI/ConfigAccess_Module /module \n
    append to file  /tmp/batch_1  /CI/ConfigAccess_Module action fetch DECODED "tempest_inst1.bin" "/var/tmp/tempest_inst1_default.json"\n
    append to file  /tmp/batch_1  /CI/ConfigAccess_Module action fetch DECODED "tcs.bin" "/var/tmp/tcs_default.json"\n

    create file     /tmp/batch_3p1  /CI/ConfigAccess_Module action store TEMPORARY DECODED
    append to file  /tmp/batch_3p1  ${SPACE}"tempest_inst1.bin" "/var/tmp/tempest_inst1_default.json"\n
    append to file  /tmp/batch_3p1  /CI/ConfigAccess_Module action update\n
    create file     /tmp/batch_3p2  / action create ThermometerDevice /rf /rf/tx1\n
    append to file  /tmp/batch_3p2  /rf action override OFF\n

PC Create Batch File - RMOD Fault 1937 Canceller - version 2
    create file     /tmp/batch_1  / action create ConfigAccess /CI/ConfigAccess_Module /module\n
    append to file  /tmp/batch_1  /CI/ConfigAccess_Module action fetch DECODED "tempest_inst1.bin" "/var/tmp/tempest_inst1_default.json"\n
    append to file  /tmp/batch_1  /CI/ConfigAccess_Module action fetch DECODED "tcs.bin" "/var/tmp/tcs_default.json"\n

    create file     /tmp/batch_3p1  /CI/ConfigAccess_Module action store TEMPORARY DECODED
    append to file  /tmp/batch_3p1  ${SPACE}"tempest_inst1.bin" "/var/tmp/tempest_inst1_default.json"\n
    append to file  /tmp/batch_3p1  /CI/ConfigAccess_Module action update\n
    create file     /tmp/batch_3p2  / action create ThermometerDevice /trx /rf/trx\n
    append to file  /tmp/batch_3p2  /trx action override OFF\n

PC Create Batch File - RMOD Fault 1937 Canceller - version 3
    create file     /tmp/batch_1  / action create ConfigAccess /CI/ConfigAccess_Module /module \n
    append to file  /tmp/batch_1  /CI/ConfigAccess_Module action fetch DECODED "tempest_inst3.bin" "/var/tmp/tempest_inst3_default.json"\n
    append to file  /tmp/batch_1  /CI/ConfigAccess_Module action fetch DECODED "tcs.bin" "/var/tmp/tcs_default.json"\n

    create file     /tmp/batch_3p1  /CI/ConfigAccess_Module action store TEMPORARY DECODED
    append to file  /tmp/batch_3p1  ${SPACE}"tempest_inst3.bin" "/var/tmp/tempest_inst1_default.json"\n
    append to file  /tmp/batch_3p1  /CI/ConfigAccess_Module action update\n
    create file     /tmp/batch_3p2  / action create ThermometerDevice /module/ASC0_internal /module/ASC0_internal\n
    append to file  /tmp/batch_3p2  /module/ASC0_internal action override OFF\n

# SSH-TAF
SSH SMOD Connect To
    [Arguments]    ${hostname}=192.168.255.1
    ...            ${username}=toor4nsn
    ...            ${password}=oZPS0POrRieRtu
    ...            ${ssh_alias}=default
    Log To Console                  SSH SMOD Connect To \${ssh_alias}=${ssh_alias}
    taf.transport.ssh.connect_to    hostname=${hostname}
    ...                             username=${username}
    ...                             password=${password}
    ...                             alias=${ssh_alias}

SSH RMOD Connect To - proxy SMOD
    [Arguments]    ${hostname_RMOD}=${SYSTEM_RMOD_LOCAL_IP}
    ...            ${hostname_BTS}=192.168.255.1
    ...            ${username_RMOD}=${SYSTEM_RMOD_SSH_USERNAME}
    ...            ${username_BTS}=toor4nsn
    ...            ${password_RMOD}=${SYSTEM_RMOD_SSH_PASSWORD}
    ...            ${password_BTS}=oZPS0POrRieRtu
    ...            ${ssh_alias}=SSH_RMOD
    ...            ${proxy}=SSH_SMOD_proxy
    Log To Console                  SSH RMOD Connect To - proxy SMOD \${ssh_alias}=${ssh_alias} \${proxy}=${proxy}
    taf.transport.ssh.connect_to    hostname=${hostname_BTS}
    ...                             username=${username_BTS}
    ...                             password=${password_BTS}
    ...                             alias=${proxy}

    Run Keyword If                  '${out_rmods_productnames_list[0]}' == 'AEQN'
    ...                             Set Test Variable    ${password_RMOD}    root
    taf.transport.ssh.Connect To    hostname=${hostname_RMOD}
    ...                             username=${username_RMOD}
    ...                             password=${password_RMOD}
    ...                             proxy=${proxy}
    ...                             alias=${ssh_alias}

SSH SMOD Disconnect
    [Arguments]    ${ssh_alias}=default
    ...            ${timeout}=1 sec
    [Timeout]      ${timeout}
    Log To Console                  SSH SMOD Disconnect \${ssh_alias}=${ssh_alias}
    taf.transport.ssh.Disconnect    connection=${ssh_alias}

SSH SMOD Disconnect - TEARDOWN
    [Documentation]
    ...            Use as second disconnection of the same alias.
    ...            TAF SSH Disconnect is by default no allowed to fail.
    ...            This version allow to fail in recognizing alias (that is already down).
    [Arguments]    ${ssh_alias}=default
    ...            ${timeout}=1 sec
    [Timeout]      ${timeout}

    Log To Console                  SSH SMOD Disconnect - TEARDOWN \${ssh_alias}=${ssh_alias}
    Run Keyword And Ignore Error    taf.transport.ssh.Disconnect    connection=${ssh_alias}

SSH RMOD Disconnect - proxy SMOD
    [Arguments]    ${ssh_alias}=SSH_RMOD
    ...            ${proxy}=SSH_SMOD_proxy
    ...            ${timeout}=1 sec
    [Timeout]      ${timeout}
    Log To Console                  SSH RMOD Disconnect - proxy SMOD \${ssh_alias}=${ssh_alias} \${proxy}=${proxy}
    taf.transport.ssh.Disconnect    connection=${ssh_alias}
    [Teardown]    taf.transport.ssh.Disconnect    connection=${proxy}

SSH RMOD Disconnect - proxy SMOD - TEARDOWN
    [Documentation]
    ...            Use as second disconnection of the same alias.
    ...            TAF SSH Disconnect is by default no allowed to fail.
    ...            This version allow to fail in recognizing alias (that is already down).
    [Arguments]    ${ssh_alias}=SSH_RMOD
    ...            ${proxy}=SSH_SMOD_proxy
    ...            ${timeout}=1 sec
    [Timeout]      ${timeout}

    Log To Console                  SSH RMOD Disconnect - proxy SMOD - TEARDOWN \${ssh_alias}=${ssh_alias} \${proxy}=${proxy}
    Run Keyword And Ignore Error    taf.transport.ssh.Disconnect    connection=${ssh_alias}
    [Teardown]    Run Keyword And Ignore Error    taf.transport.ssh.Disconnect    connection=${proxy}

SSH SMOD Send Command And Collect Output - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${command}
    ...                ${ssh_alias}
    Log To Console                    SSH SMOD Send Command And Collect Output - Slave \${command}=${command} \${ssh_alias}=${ssh_alias}
    taf.transport.ssh.Send Command    command=${command}               connection=${ssh_alias}
    ${output}                         taf.transport.ssh.Read Output    connection=${ssh_alias}
    Log To Console                    [Return] ${output}
    [Return]    ${output}

SSH SMOD Send Command And Collect Output
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${command}
    ...                ${ssh_alias}=SSH_SMOD_com
    Log To Console                 SSH SMOD Send Command And Collect Output \${command}=${command} \${ssh_alias}=${ssh_alias}
    keyword.SSH SMOD Connect To    ssh_alias=${ssh_alias}
    ${output}                      SSH SMOD Send Command And Collect Output - Slave    command=${command}    ssh_alias=${ssh_alias}
    [Teardown]    keyword.SSH SMOD Disconnect - TEARDOWN    ssh_alias=${ssh_alias}
    [Return]      ${output}

SSH SMOD Directory Should Exist - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${path_dir}
    ...                ${ssh_alias}
    Log To Console                    SSH SMOD Directory Should Exist - Slave \${path_dir}=${path_dir} \${ssh_alias}=${ssh_alias}
    taf.transport.ssh.Send Command    command=test -d "${path_dir}" && echo "True" || echo "False"    connection=${ssh_alias}
    ${output}    taf.transport.ssh.Read Output    connection=${ssh_alias}
    Log To Console                    \${output}=${output}
    Should Be Equal                   ${output}    True\n

SSH SMOD Directory Should Exist
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${path_dir}
    ...                ${ssh_alias}=SSH_SMOD_check
    Log To Console                             SSH SMOD Directory Should Exist \${path_dir}=${path_dir} \${ssh_alias}=${ssh_alias}
    keyword.SSH SMOD Connect To                ssh_alias=${ssh_alias}
    SSH SMOD Directory Should Exist - Slave    path_dir=${path_dir}    ssh_alias=${ssh_alias}
    [Teardown]    keyword.SSH SMOD Disconnect    ssh_alias=${ssh_alias}

SSH SMOD Get active_partition - Slave
    [Documentation]    Slave - use existing connection.
    ...                Returns string.
    [Arguments]        ${ssh_alias}
    Log To Console                    SSH SMOD Get active_partition - Slave \${ssh_alias}=${ssh_alias}
    taf.transport.ssh.Send Command    command=uboot_env get active_partition    connection=${ssh_alias}
    ${output}                         taf.transport.ssh.Read Output             connection=${ssh_alias}
    Log To Console                    \${output}=${output}
    ${active_partition_id}            string.Fetch From Right                   string=${output}                 marker==
    ${active_partition_id}            string.Fetch From Left                    string=${active_partition_id}    marker=\n
    Log To Console                    [Return] ${active_partition_id}
    [Return]    ${active_partition_id}

SSH SMOD Get active_partition
    [Documentation]    It will eventually make it's own ADMIN connection.
    ...                Returns string.
    [Arguments]        ${ssh_alias}=SSH_active_partition
    Log To Console                 SSH SMOD Get Active_partition \${ssh_alias}=${ssh_alias}
    keyword.SSH SMOD Connect To    ssh_alias=${ssh_alias}
    ${output}                      SSH SMOD Get active_partition - Slave    ssh_alias=${ssh_alias}
    [Teardown]    keyword.SSH SMOD Disconnect    ssh_alias=${ssh_alias}
    [Return]      ${output}

SSH SMOD Get List File In Directory - Slave
    [Documentation]    Slave - use existing connection.
    ...                Returns string.
    [Arguments]        ${path_dir}
    ...                ${ssh_alias}
    Log To Console                             SSH SMOD Get List File In Directory - Slave \${path_dir}=${path_dir} \${ssh_alias}=${ssh_alias}
    SSH SMOD Directory Should Exist - Slave    path_dir=${path_dir}             ssh_alias=${ssh_alias}
    taf.transport.ssh.Send Command             command=ls ${path_dir}           connection=${ssh_alias}
    ${ls}                                      taf.transport.ssh.Read Output    connection=${ssh_alias}
    Log To Console                             [Return] \\n\${ls}=\n${ls}
    [Return]    ${ls}

SSH SMOD Get List File In Directory
    [Documentation]    It will eventually make it's own ADMIN connection.
    ...                Returns string.
    [Arguments]        ${path_dir}
    ...                ${ssh_alias}=SSH_SMOD_ls
    Log To Console                 SSH SMOD Get List File In Directory - Slave \${path_dir}=${path_dir} \${ssh_alias}=${ssh_alias}
    keyword.SSH SMOD Connect To    ssh_alias=${ssh_alias}
    ${ls}                          SSH SMOD Get List File In Directory - Slave    path_dir=${path_dir}    ssh_alias=${ssh_alias}
    Log To Console                 [Return] \\n\${ls}=\n${ls}
    [Teardown]    keyword.SSH SMOD Disconnect    ssh_alias=${ssh_alias}
    [Return]      ${ls}

SSH SMOD Get List File In Directory SW Update Planned - Slave
    [Documentation]    Slave - use existing connection.
    ...                SMOD SW Update planned directory is `/ffs/stb/planned/`
    ...                Returns string.
    [Arguments]        ${ssh_alias}
    Log To Console    SSH SMOD Get List File In Directory SW Update Planned - Slave \${ssh_alias}=${ssh_alias}
    ${ls}             SSH SMOD Get List File In Directory - Slave    path_dir=/ffs/stb/planned/    ssh_alias=${ssh_alias}
    Log To Console    [Return] \\n\${ls}=\n${ls}
    [Return]    ${ls}

SSH SMOD Get List File In Directory SW Update Planned
    [Documentation]    It will eventually make it's own ADMIN connection.
    ...                SMOD SW Update planned directory is `/ffs/stb/planned/`
    ...                Returns string.
    [Arguments]        ${ssh_alias}=SSH_SMOD_get
    Log To Console                 SSH SMOD Get List File In Directory SW Update Planned - Slave \${ssh_alias}=${ssh_alias}
    keyword.SSH SMOD Connect To    ssh_alias=${ssh_alias}
    ${ls}                          SSH SMOD Get List File In Directory - Slave    path_dir=/ffs/stb/planned/    ssh_alias=${ssh_alias}
    Log To Console                 [Return] \\n\${ls}=\n${ls}
    [Teardown]    keyword.SSH SMOD Disconnect    ssh_alias=${ssh_alias}
    [Return]      ${ls}

SSH SMOD Get List VN ID - Slave
    [Documentation]    Slave - use existing connection.
    ...                Returns string.
    [Arguments]        ${ssh_alias}
    Log To Console                    SSH SMOD Get List VN ID - Slave \${ssh_alias}=${ssh_alias}
    taf.transport.ssh.Send Command    command=lxc-ls                   connection=${ssh_alias}
    ${string_vn_id}                   taf.transport.ssh.Read Output    connection=${ssh_alias}
    ${list_vn_id}                     string.Split To Lines            ${string_vn_id}
    Log To Console                    [Return] \${list_vn_id}=${list_vn_id}
    [Return]    ${list_vn_id}

SSH SMOD Get List VN ID
    [Documentation]    It will eventually make it's own ADMIN connection.
    ...                Returns string.
    [Arguments]        ${ssh_alias}=SSH_SMOD_VN
    Log To Console                 SSH SMOD Get List VN ID \${ssh_alias}=${ssh_alias}
    keyword.SSH SMOD Connect To    ssh_alias=${ssh_alias}
    ${list_vn_id}                  SSH SMOD Get List VN ID - Slave    ssh_alias=${ssh_alias}
    Log To Console                 [Return] \${list_vn_id}=${list_vn_id}
    [Teardown]    keyword.SSH SMOD Disconnect    ssh_alias=${ssh_alias}
    [Return]      ${list_vn_id}

SSH SMOD Get VN ID - Slave
    [Documentation]    Slave - use existing connection.
    ...                Returns string.
    [Arguments]        ${ssh_alias}
    Log To Console    SSH SMOD Get VN ID - Slave \${ssh_alias}=${ssh_alias}
    ${list_vn_id}     SSH SMOD Get List VN ID - Slave    ssh_alias=${ssh_alias}
    ${vn_id}          Get Variable Value                 ${list_vn_id[0]}
    Log To Console    [Return] \${vn_id}=${vn_id}
    [Return]    ${vn_id}

SSH SMOD Get VN ID
    [Documentation]    It will eventually make it's own ADMIN connection.
    ...                Returns string.
    [Arguments]        ${ssh_alias}=SSH_SMOD_VN
    Log To Console                 SSH SMOD Get VN ID \${ssh_alias}=${ssh_alias}
    keyword.SSH SMOD Connect To    ssh_alias=${ssh_alias}
    ${vn_id}                       SSH SMOD Get VN ID - Slave    ssh_alias=${ssh_alias}
    Log To Console                 [Return] \${vn_id}=${vn_id}
    [Teardown]    keyword.SSH SMOD Disconnect    ssh_alias=${ssh_alias}
    [Return]      ${vn_id}

SSH SMOD Get SWDLreport - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${ssh_alias}
    Log To Console                    SSH SMOD Get SWDLreport - Slave \${ssh_alias}=${ssh_alias}
    taf.transport.ssh.Send Command    command=cat /tmp/SWDLreport.txt    connection=${ssh_alias}
    ${SWDLreport}                     taf.transport.ssh.Read Output      connection=${ssh_alias}
    [Return]    ${SWDLreport}

SSH SMOD Get SWDLreport
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${ssh_alias}=SSH_SWDLreport
    Log To Console                 SSH SMOD Get SWDLreport \${ssh_alias}=${ssh_alias}
    keyword.SSH SMOD Connect To    ssh_alias=${ssh_alias}
    ${SWDLreport}                  SSH SMOD Get SWDLreport - Slave     ssh_alias=${ssh_alias}
    [Teardown]                     keyword.SSH SMOD Disconnect         ssh_alias=${ssh_alias}
    [Return]      ${SWDLreport}

SSH SMOD Set active_partition - Slave
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${value}
    ...                ${ssh_alias}
    Log To Console                    SSH SMOD Set active_partition - Slave
    ${value}                          Convert To String                                  ${value}
    taf.transport.ssh.Send Command    command=uboot_env set active_partition=${value}    connection=${ssh_alias}
    ${output}                         taf.transport.ssh.Read Output                      connection=${ssh_alias}
    Should Be Equal                   ${output}                                          Added 1 variables\n
    ${output}                         SSH SMOD Get active_partition - Slave              ssh_alias=${ssh_alias}
    Should Be Equal                   ${output}                                          ${value}

SSH SMOD Set active_partition
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${value}
    ...                ${ssh_alias}=SSH_uboot_env
    Log To Console                           SSH Set active_partition
    keyword.SSH SMOD Connect To              ssh_alias=${ssh_alias}
    SSH SMOD Set active_partition - Slave    value=${value}    ssh_alias=${ssh_alias}
    [Teardown]    keyword.SSH SMOD Disconnect    ssh_alias=${ssh_alias}

SSH SMOD Reboot
    [Arguments]    ${SMOD_com}=${SMOD_com_reboot}
    Log To Console    SSH SMOD Reboot
    keyword.SSH SMOD Send Command And Collect Output    command=${SMOD_com}
    PC Wait Until BTS Disconnected And Connected
    ADMIN Wait Until Connect To Should Be Successful

SSH SMOD Reboot And Wait For OnAir
    [Arguments]    ${SMOD_com}=${SMOD_com_reboot}
    Log To Console    SSH SMOD Reboot And Wait For OnAir
    keyword.SSH SMOD Send Command And Collect Output    command=${SMOD_com}
    PC Wait Until BTS Disconnected And Connected
    ADMIN Wait Until Connect To Should Be Successful
    IM Wait Until BTS Should Be OnAir

SSH SMOD SWDLreport Should Be Empty - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${ssh_alias}
    Log To Console     SSH SMOD SWDLreport Should Be Empty - Slave \${ssh_alias}=${ssh_alias}
    ${SWDLreport}      SSH SMOD Get SWDLreport - Slave    ssh_alias=${ssh_alias}
    Should Be Empty    ${SWDLreport}

SSH SMOD SWDLreport Should Be Empty
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${ssh_alias}=SSH_SWDLreport
    Log To Console     SSH SWDLreport Should Be Empty \${ssh_alias}=${ssh_alias}
    ${SWDLreport}      SSH SMOD Get SWDLreport    ssh_alias=${ssh_alias}
    Should Be Empty    ${SWDLreport}

SSH SMOD SWDLreport Should Not Be Empty - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${ssh_alias}
    Log To Console         SSH SMOD SWDLreport Should Not Be Empty - Slave \${ssh_alias}=${ssh_alias}
    ${SWDLreport}          SSH SMOD Get SWDLreport - Slave    ssh_alias=${ssh_alias}
    Should Not Be Empty    ${SWDLreport}

SSH SMOD SWDLreport Should Not Be Empty
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${ssh_alias}=SSH_SWDLreport
    Log To Console         SSH SWDLreport Should Not Be Empty \${ssh_alias}=${ssh_alias}
    ${SWDLreport}          SSH SMOD Get SWDLreport    ssh_alias=${ssh_alias}
    Should Not Be Empty    ${SWDLreport}

SSH SMOD Wait Until SWDLreport Should Be Empty
    [Arguments]    ${retry}=2 min
    ...            ${retry_interval}=0 sec
    ...            ${ssh_alias}=SSH_SWDLreport
    Log To Console                 SSH SMOD Wait Until SWDLreport Should Be Empty
    Log To Console                 ${SPACE * 4}\${ssh_alias}=${ssh_alias} \${retry}=${retry} \${retry_interval}=${retry_interval}
    keyword.SSH SMOD Connect To    ssh_alias=${ssh_alias}
    Wait Until Keyword Succeeds    ${retry}
    ...                            ${retry_interval}
    ...                            SSH SMOD SWDLreport Should Be Empty - Slave
    ...                            ssh_alias=${ssh_alias}
    [Teardown]    keyword.SSH SMOD Disconnect    ssh_alias=${ssh_alias}

SSH SMOD Wait Until SWDLreport Should Not Be Empty
    [Arguments]    ${retry}=2 min
    ...            ${retry_interval}=10 sec
    ...            ${ssh_alias}=SSH_SWDLreport
    Log To Console                 SSH SMOD Wait Until SWDLreport Should Not Be Empty
    Log To Console                 ${SPACE * 4}\${ssh_alias}=${ssh_alias} \${retry}=${retry} \${retry_interval}=${retry_interval}
    keyword.SSH SMOD Connect To    ssh_alias=${ssh_alias}
    Wait Until Keyword Succeeds    ${retry}
    ...                            ${retry_interval}
    ...                            SSH SMOD SWDLreport Should Not Be Empty - Slave
    ...                            ssh_alias=${ssh_alias}
    [Teardown]    keyword.SSH SMOD Disconnect    ssh_alias=${ssh_alias}

SSH SMOD SW Update Directory Planned Should Be Empty - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${ssh_alias}
    Log To Console     SSH SMOD SW Update Directory Planned Should Be Empty - Slave \${ssh_alias}=${ssh_alias}
    ${ls}              SSH SMOD Get List File In Directory SW Update Planned - Slave    ssh_alias=${ssh_alias}
    Should Be Empty    ${ls}

SSH SMOD SW Update Directory Planned Should Be Empty
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${ssh_alias}
    Log To Console                                                  SSH SMOD SW Update Directory Planned Should Be Empty \${ssh_alias}=${ssh_alias}
    keyword.SSH SMOD Connect To                                     ssh_alias=${ssh_alias}
    SSH SMOD SW Update Directory Planned Should Be Empty - Slave    ssh_alias=${ssh_alias}
    [Teardown]    keyword.SSH SMOD Disconnect    ssh_alias=${ssh_alias}

SSH SMOD Wait Until SMOD SW Update Directory Planned Is Empty
    [Arguments]    ${retry}=2 min
    ...            ${retry_interval}=10 sec
    ...            ${ssh_alias}=SSH_SMOD_Update_directory
    Log To Console                 SSH SMOD Wait Until SMOD SW Update Directory Planned Is Empty
    Log To Console                 ${SPACE * 4}\${ssh_alias}=${ssh_alias} \${retry}=${retry} \${retry_interval}=${retry_interval}
    keyword.SSH SMOD Connect To    ssh_alias=${ssh_alias}
    Wait Until Keyword Succeeds    ${retry}
    ...                            ${retry_interval}
    ...                            SSH SMOD SW Update Directory Planned Should Be Empty - Slave
    ...                            ssh_alias=${ssh_alias}
    [Teardown]    keyword.SSH SMOD Disconnect    ssh_alias=${ssh_alias}

SSH SMOD SW Update Directory Planned - Delete Files - Slave
    [Documentation]    Slave - use existing connection.
    ...                During SW Update, directory `/ffs/stb/planned/` is a temporary location of planned files.
    [Arguments]        ${ssh_alias}
    Log To Console                    SSH SMOD SW Update Directory Planned - Delete Files - Slave \${ssh_alias}=${ssh_alias}
    taf.transport.ssh.Send Command    command=rm -rf /ffs/stb/planned/*    connection=${ssh_alias}
    ${output}                         taf.transport.ssh.Read Output        connection=${ssh_alias}
    # Should Be Empty    ${output}
    SSH SMOD Wait Until SMOD SW Update Directory Planned Is Empty

SSH SMOD SW Update Directory Planned - Delete Files
    [Documentation]    It will eventually make it's own ADMIN connection.
    ...                During SW Update, directory `/ffs/stb/planned/` is a temporary location of planned files.
    [Arguments]    ${ssh_alias}=SSH_SMOD_SW_Update_dir
    Log To Console                    SSH SMOD SW Update Directory Planned - Delete Files \${ssh_alias}=${ssh_alias}
    keyword.SSH SMOD Connect To       ssh_alias=${ssh_alias}
    taf.transport.ssh.Send Command    command=rm -rf /ffs/stb/planned/*    connection=${ssh_alias}
    ${output}                         taf.transport.ssh.Read Output        connection=${ssh_alias}
    # Should Be Equal    ${output}    Added 1 variables\n
    SSH SMOD Wait Until SMOD SW Update Directory Planned Is Empty
    [Teardown]    keyword.SSH SMOD Disconnect    ssh_alias=${ssh_alias}

SSH RMOD Send Command And Collect Output - Slave
    [Documentation]    Slave - use existing connection.
    #                  Implementation correctness to be verified.
    [Arguments]        ${command}
    ...                ${ssh_alias}
    Log To Console                    SSH RMOD Send Command And Collect Output - Slave \${command}=${command} \${ssh_alias}=${ssh_alias}
    taf.transport.ssh.Send Command    command=${command}               connection=${ssh_alias}
    ${output}                         taf.transport.ssh.Read Output    connection=${ssh_alias}
    Log To Console                    [Return] ${output}
    [Return]    ${output}

SSH RMOD Send Command And Collect Output
    [Documentation]    It will eventually make it's own ADMIN connection.
    #                  Implementation correctness to be verified.
    [Arguments]        ${command}
    ...                ${ssh_alias}=SSH_RMOD_com
    ...                ${proxy}=SSH_SMOD_proxy_com
    Log To Console                              SSH RMOD Send Command And Collect Output \${command}=${command} \${ssh_alias}=${ssh_alias}
    keyword.SSH RMOD Connect To - proxy SMOD    ssh_alias=${ssh_alias}                              proxy=${proxy}
    ${output}                                   SSH SMOD Send Command And Collect Output - Slave    command=${command}    ssh_alias=${ssh_alias}
    [Teardown]    keyword.SSH RMOD Disconnect - proxy SMOD - TEARDOWN    ssh_alias=${ssh_alias}    proxy=${proxy}
    [Return]      ${output}

SSH RMOD Upload Batch File - RMOD Fault 1937 Trigger
    Log To Console    SSH RMOD Upload Batch File - RMOD Fault 1937 Trigger
    SSH RMOD Connect To - proxy SMOD    ssh_alias=SSH_RMOD_1937    proxy=SSH_RMOD_proxy_1937
    taf.transport.ssh.upload_file  /tmp/batch_1      /tmp    connection=SSH_RMOD_1937
    taf.transport.ssh.upload_file  /tmp/batch_2p1    /tmp    connection=SSH_RMOD_1937
    taf.transport.ssh.upload_file  /tmp/batch_2p2    /tmp    connection=SSH_RMOD_1937
    [Teardown]    SSH RMOD Disconnect - proxy SMOD    ssh_alias=SSH_RMOD_1937    proxy=SSH_RMOD_proxy_1937

SSH RMOD Upload Batch File - RMOD Fault 1937 Canceller
    Log To Console    SSH RMOD Upload Batch File - RMOD Fault 1937 Canceller
    SSH RMOD Connect To - proxy SMOD    ssh_alias=SSH_RMOD_1937    proxy=SSH_RMOD_proxy_1937
    taf.transport.ssh.upload_file  /tmp/batch_1      /tmp    connection=SSH_RMOD_1937
    taf.transport.ssh.upload_file  /tmp/batch_3p1    /tmp    connection=SSH_RMOD_1937
    taf.transport.ssh.upload_file  /tmp/batch_3p2    /tmp    connection=SSH_RMOD_1937
    [Teardown]    SSH RMOD Disconnect - proxy SMOD    ssh_alias=SSH_RMOD_1937    proxy=SSH_RMOD_proxy_1937

SSH RMOD Execute Batch File - RMOD Fault 1937 Trigger
    [Documentation]    ! Some commands depend on which RMOD version is used in environment.
    Log To Console    SSH RMOD Execute Batch File - RMOD Fault 1937 Trigger
    ${param}    Run Keyword If    '${out_rmods_productnames_list[0]}' == 'AHPD'
    ...    Convert To String    1
    ...    ELSE IF    '${out_rmods_productnames_list[0]}' == 'AHLOA'
    ...    Convert To String    1
    ...    ELSE IF    '${out_rmods_productnames_list[0]}' == 'AEQN'
    ...    Convert To String    3
    ...    ELSE IF    '${out_rmods_productnames_list[0]}' == 'AEUA'
    ...    Convert To String    1
    ...        # ELSE IF    '${out_rmods_productnames_list[0]}' == 'AEUB'
    ...        # Convert To String    1
    ...    ELSE
    ...    Fail    msg=Execute Batch File - Unsupported RMOD.

    SSH RMOD Connect To - proxy SMOD    ssh_alias=SSH_RMOD_1937    proxy=SSH_RMOD_proxy_1937
    ${output}    taf.transport.ssh.execute    command=frmonShellClient 127.0.0.1 2000 /tmp/batch_1    connection=SSH_RMOD_1937
    Log To Console    batch_1 \${output}=${output}
    ${output}    taf.transport.ssh.execute    command=cat /var/tmp/tempest_inst${param}_default.json|grep tempOffset    connection=SSH_RMOD_1937
        # `inst<number>` differ depending on RMOD
    Log To Console    cat \${output}=${output}
    ${output}    taf.transport.ssh.execute
    ...    command=sed -i 's/"tempOffset": [0-9]*[.0]*,/"tempOffset": 65,/g' /var/tmp/tempest_inst${param}_default.json
    ...    connection=SSH_RMOD_1937
    Log To Console    sed 0 --> 65 \${output}=${output}
    ${output}    taf.transport.ssh.execute    command=cat /var/tmp/tempest_inst${param}_default.json|grep tempOffset    connection=SSH_RMOD_1937
    Log To Console    cat \${output}=${output}
    ${output}    taf.transport.ssh.execute    command=frmonShellClient 127.0.0.1 2000 /tmp/batch_2p1    connection=SSH_RMOD_1937
    Log To Console    batch_2p1 \${output}=${output}
    Sleep    1 sec
    ${output}    taf.transport.ssh.execute    command=frmonShellClient 127.0.0.1 2000 /tmp/batch_2p2    connection=SSH_RMOD_1937
    Log To Console    batch_2p2 \${output}=${output}
    [Teardown]    SSH RMOD Disconnect - proxy SMOD    ssh_alias=SSH_RMOD_1937    proxy=SSH_RMOD_proxy_1937

SSH RMOD Execute Batch File - RMOD Fault 1937 Canceller
    [Documentation]    ! Some commands depend on which RMOD version is used in environment.
    Log To Console    SSH RMOD Execute Batch File - RMOD Fault 1937 Canceller
    ${param}    Run Keyword If    '${out_rmods_productnames_list[0]}' == 'AHPD'
    ...    Convert To String    1
    ...    ELSE IF    '${out_rmods_productnames_list[0]}' == 'AHLOA'
    ...    Convert To String    1
    ...    ELSE IF    '${out_rmods_productnames_list[0]}' == 'AEQN'
    ...    Convert To String    3
    ...    ELSE IF    '${out_rmods_productnames_list[0]}' == 'AEUA'
    ...    Convert To String    1
    ...        # ELSE IF    '${out_rmods_productnames_list[0]}' == 'AEUB'
    ...        # Convert To String    1
    ...    ELSE
    ...    Fail    msg=Execute Batch File - Unsupported RMOD.

    SSH RMOD Connect To - proxy SMOD    ssh_alias=SSH_RMOD_1937    proxy=SSH_RMOD_proxy_1937
    ${output}    taf.transport.ssh.execute    command=frmonShellClient 127.0.0.1 2000 /tmp/batch_1    connection=SSH_RMOD_1937
    Log To Console    batch_1 \${output}=${output}
    ${output}    taf.transport.ssh.execute    command=cat /var/tmp/tempest_inst${param}_default.json|grep tempOffset    connection=SSH_RMOD_1937
        # `inst<number>` differ depending on RMOD
    Log To Console    cat \${output}=${output}
    ${output}    taf.transport.ssh.execute
    ...    command=sed -i 's/"tempOffset": 65.0,/"tempOffset": 0,/g' /var/tmp/tempest_inst${param}_default.json
    ...    connection=SSH_RMOD_1937
    Log To Console    sed 65.0 --> 0 \${output}=${output}
    ${output}    taf.transport.ssh.execute    command=cat /var/tmp/tempest_inst${param}_default.json|grep tempOffset    connection=SSH_RMOD_1937
    Log To Console    cat \${output}=${output}
    ${output}    taf.transport.ssh.execute
    ...    command=sed -i 's/"tempOffset": 65,/"tempOffset": 0,/g' /var/tmp/tempest_inst1_default.json
    ...    connection=SSH_RMOD_proxy_1937
    Log To Console    sed 65 --> 0 \${output}=${output}
    ${output}    taf.transport.ssh.execute    command=cat /var/tmp/tempest_inst${param}_default.json|grep tempOffset    connection=SSH_RMOD_1937
    Log To Console    cat \${output}=${output}
    ${output}    taf.transport.ssh.execute    command=frmonShellClient 127.0.0.1 2000 /tmp/batch_3p1    connection=SSH_RMOD_1937
    Log To Console    batch_3p1 \${output}=${output}
    Sleep    1 sec
    ${output}    taf.transport.ssh.execute    command=frmonShellClient 127.0.0.1 2000 /tmp/batch_3p2    connection=SSH_RMOD_1937
    Log To Console    batch_3p2 \${output}=${output}
    [Teardown]    SSH RMOD Disconnect - proxy SMOD    ssh_alias=SSH_RMOD_1937    proxy=SSH_RMOD_proxy_1937

# ADMIN
ADMIN Connect To Should Be Successful
    [Arguments]    ${test_admin_alias}=test_ADMIN_alias
    Log To Console    ADMIN Connect To Should Be Successful \${test_admin_alias}=${test_admin_alias}
    keyword.ADMIN Connect To    admin_alias=${test_admin_alias}
    [Teardown]    keyword.ADMIN Teardown    admin_alias=${test_admin_alias}

ADMIN Connect To Should Not Be Successful
    [Arguments]    ${test_admin_alias}=test_ADMIN_alias
    Log To Console    ADMIN Connect To Should Not Be Successful \${test_admin_alias}=${test_admin_alias}
    ${status}    run keyword and ignore error    keyword.ADMIN Connect To    admin_alias=${test_admin_alias}
    run keyword and ignore error    keyword.ADMIN Teardown    admin_alias=${test_admin_alias}
    Should Be Equal    ${status[0]}    FAIL

ADMIN Wait Until Connect To Should Be Successful
    [Arguments]    ${retry}=5 min
    ...            ${retry_interval}=30 sec
    ...            ${admin_alias}=test_ADMIN_alias
    Log To Console                 ADMIN Wait Until Connect To Should Be Successful
    Log To Console                 ${SPACE * 4}\${admin_alias}=${admin_alias} \${retry}=${retry} \${retry_interval}=${retry_interval}
    Wait Until Keyword Succeeds    ${retry}
    ...                            ${retry_interval}
    ...                            ADMIN Connect To Should Be Successful
    ...                            test_admin_alias=${admin_alias}

ADMIN Wait Until Connect To Should Not Be Successful
    [Arguments]    ${retry}=2 min
    ...            ${retry_interval}=30 sec
    ...            ${admin_alias}=test_ADMIN_alias
    Log To Console                 ADMIN Wait Until Connect To Should Not Be Successful
    Log To Console                 ${SPACE * 4}\${admin_alias}=${admin_alias} \${retry}=${retry} \${retry_interval}=${retry_interval}
    Wait Until Keyword Succeeds    ${retry}
    ...                            ${retry_interval}
    ...                            ADMIN Connect To Should Not Be Successful
    ...                            test_admin_alias=${admin_alias}

ADMIN Connect To
    [Arguments]    ${admin_alias}=default
    Log To Console                       ADMIN Connect To \${admin_alias}=${admin_alias}
    taf.sbts.oam.coam.admin.Connect To    name=${admin_alias}

ADMIN Teardown
    [Arguments]    ${admin_alias}=default
    Log To Console                     Admin Teardown \${admin_alias}=${admin_alias}
    taf.sbts.oam.coam.admin.Teardown    connection=${admin_alias}

ADMIN Reset Site - Slave
    [Documentation]    Slave - use existing connection.
    ...                Reset site and doesn't wait for start up.
    [Arguments]        ${admin_alias}
    ...                ${timeout}=300 sec
    Log To Console    ADMIN Reset Site - Slave \${admin_alias}=${admin_alias}
    taf.sbts.oam.coam.admin.Reset Site    timeout=${timeout}    wait_for_reconnection=${False}    connection=${admin_alias}

ADMIN Reset Site
    [Documentation]    It will eventually make it's own ADMIN connection.
    ...                Reset site and doesn't wait for start up.
    [Arguments]        ${timeout}=300 sec
    ...                ${admin_alias}=ADMIN_reset
    Log To Console    ADMIN Reset Site \${admin_alias}=${admin_alias}
    keyword.ADMIN Connect To    admin_alias=${admin_alias}
    taf.sbts.oam.coam.admin.Reset Site    timeout=${timeout}    wait_for_reconnection=${False}    connection=${admin_alias}
    [Teardown]    keyword.ADMIN Teardown    admin_alias=${admin_alias}

ADMIN Reset Site And Wait For Startup - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${admin_alias}
    ...                ${timeout}=300 sec
    Log To Console    ADMIN Reset Site And Wait For Startup - Slave \${admin_alias}=${admin_alias}
    taf.sbts.oam.coam.admin.Reset Site    timeout=${timeout}    wait_for_reconnection=${True}    connection=${admin_alias}

ADMIN Reset Site And Wait For Startup
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${timeout}=300 sec
    ...                ${admin_alias}=ADMIN_reset
    Log To Console    ADMIN Reset Site And Wait For Startup \${admin_alias}=${admin_alias}
    keyword.ADMIN Connect To    admin_alias=${admin_alias}
    taf.sbts.oam.coam.admin.Reset Site    timeout=${timeout}    wait_for_reconnection=${True}    connection=${admin_alias}
    [Teardown]    keyword.ADMIN Teardown    admin_alias=${admin_alias}

# TODO: ADMIN IM Download
# TODO: ADMIN Snaphot Download

ADMIN Get List Fault Active ID - Slave
    [Documentation]    Slave - use existing connection.
    ...                Returns list of integers    # strings.
    [Arguments]        ${admin_alias}
    Log To Console        ADMIN Get List Fault Active ID - Slave \${admin_alias}=${admin_alias}
    @{list_fault_dict}    taf.sbts.oam.coam.admin.get_active_alarms    connection=${admin_alias}
    @{list_fault_id}      Create List
    :FOR    ${fault_dict}    In    @{list_fault_dict}
    \       collections.Append To List    ${list_fault_id}    ${fault_dict['faultId']}
    Log To Console        [Return] \@{list_fault_id}=@{list_fault_id}
    [Return]    @{list_fault_id}

ADMIN Get List Fault Active ID
    [Documentation]    It will eventually make it's own ADMIN connection.
    ...                Returns list of integers.    # strings.
    [Arguments]        ${admin_alias}=ADMIN_fault
    Log To Console      ADMIN Get List Fault Active ID \${admin_alias}=${admin_alias}
    ADMIN Connect To    admin_alias=${admin_alias}
    @{list_fault_id}    ADMIN Get List Fault Active ID - Slave    admin_alias=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}
    [Return]      @{list_fault_id}

ADMIN Get List Fault Active Indicator - Slave
    [Documentation]    Slave - use existing connection.
    ...                Keyword provide indicators of activity of given faults.
    ...                Returns list of booleans.
    [Arguments]        ${list_fault_to_be_checked_id}
    ...                ${admin_alias}
    Log To Console    ADMIN Get List Fault Active Indicator - Slave
    Log To Console    ${SPACE * 4}\${list_fault_to_be_checked_id}=${list_fault_to_be_checked_id} \${admin_alias}=${admin_alias}
    @{list_fault_active_id}    ADMIN Get List Fault Active ID - slave    admin_alias=${admin_alias}
    @{list_fault_checked_indicator}    Create List
    :FOR    ${fault_checked_id}    In    @{list_fault_to_be_checked_id}
    # \    ${fault_checked_id}    Convert To String    ${fault_checked_id}
    \       ${fault_checked_id}           Convert To Integer                      ${fault_checked_id}
    \       ${status}                     Get Status List Should Contain Value    list=@{list_fault_active_id}    value=${fault_checked_id}
    \       collections.Append To List    ${list_fault_checked_indicator}         ${status}
    Log To Console    [Return] \@{list_fault_checked_indicator}=@{list_fault_checked_indicator}
    [Return]    @{list_fault_checked_indicator}

ADMIN Get List Fault Active Indicator
    [Documentation]    It will eventually make it's own ADMIN connection.
    ...                Keyword provide indicators of activity of given faults.
    ...                Returns list of booleans.
    [Arguments]        ${list_fault_to_be_checked_id}
    ...                ${admin_alias}=ADMIN_fault
    Log To Console                     ADMIN Get List Fault Active Indicator
    Log To Console                     ${SPACE * 4}\${list_fault_to_be_checked_id}=${list_fault_to_be_checked_id} \${admin_alias}=${admin_alias}
    ADMIN Connect To                   admin_alias=${admin_alias}
    @{list_fault_checked_indicator}    ADMIN Get List Fault Active Indicator - Slave
    ...                                list_fault_to_be_checked_id=@{list_fault_to_be_checked_id}    admin_alias=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}
    [Return]      @{list_fault_checked_indicator}

ADMIN Any Fault From List Should Be Raised - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${list_fault_desirable_id}
    ...                ${admin_alias}
    Log To Console                           ADMIN Any Fault From List Should Be Raised - Slave
    Log To Console                           ${SPACE * 4}\${list_fault_desirable_id}=${list_fault_desirable_id} \${admin_alias}=${admin_alias}
    @{list_fault_active_indicator}           ADMIN Get List Fault Active Indicator - Slave
    ...                                      list_fault_to_be_checked_id=@{list_fault_desirable_id}    admin_alias=${admin_alias}
    collections.List Should Contain Value    list_=@{list_fault_active_indicator}                      value=${True}

ADMIN Any Fault From List Should Be Raised
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${list_fault_desirable_id}
    ...                ${admin_alias}=ADMIN_fault
    Log To Console      ADMIN Any Fault From List Should Be Raised - Slave
    Log To Console      ${SPACE * 4}\${list_fault_desirable_id}=${list_fault_desirable_id} \${admin_alias}=${admin_alias}
    ADMIN Connect To    admin_alias=${admin_alias}
    ADMIN Any Fault From List Should Be Raised - Slave
    ...                 list_fault_desirable_id=@{list_fault_desirable_id}    admin_alias=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}

ADMIN Every Fault From List Should Be Raised - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${list_fault_desirable_id}
    ...                ${admin_alias}
    Log To Console                               ADMIN Every Fault From List Should Be Raised - Slave
    Log To Console                               ${SPACE * 4}\${list_fault_desirable_id}=${list_fault_desirable_id} \${admin_alias}=${admin_alias}
    @{list_fault_active_indicator}               ADMIN Get List Fault Active Indicator - Slave
    ...                                          list_fault_to_be_checked_id=@{list_fault_desirable_id}    admin_alias=${admin_alias}
    collections.List Should Not Contain Value    list_=@{list_fault_active_indicator}                      value=${False}

ADMIN Every Fault From List Should Be Raised
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${list_fault_desirable_id}
    ...                ${admin_alias}=ADMIN_fault
    Log To Console      ADMIN Every Fault From List Should Be Raised
    Log To Console      ${SPACE * 4}\${list_fault_desirable_id}=${list_fault_desirable_id} \${admin_alias}=${admin_alias}
    ADMIN Connect To    admin_alias=${admin_alias}
    ADMIN Every Fault From List Should Be Raised - Slave
    ...                 list_fault_desirable_id=@{list_fault_desirable_id}    admin_alias=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}

ADMIN None Fault From List Should Be Raised - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${list_fault_undesirable_id}
    ...                ${admin_alias}
    Log To Console                             ADMIN None Fault From List Should Be Raised - Slave
    Log To Console                             ${SPACE * 4}\${list_fault_undesirable_id}=${list_fault_undesirable_id} \${admin_alias}=${admin_alias}
    @{list_fault_active_indicator}             ADMIN Get List Fault Active Indicator - Slave
    ...                                        list_fault_to_be_checked_id=@{list_fault_undesirable_id}    admin_alias=${admin_alias}
    collections.List Should Not Contain Value    list_=@{list_fault_active_indicator}    value=${True}

ADMIN None Fault From List Should Be Raised
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${list_fault_undesirable_id}
    ...                ${admin_alias}=ADMIN_fault
    Log To Console      ADMIN None Fault From List Should Be Raised
    Log To Console      ${SPACE * 4}\${list_fault_undesirable_id}=${list_fault_undesirable_id} \${admin_alias}=${admin_alias}
    ADMIN Connect To    admin_alias=${admin_alias}
    ADMIN None Fault From List Should Be Raised - Slave
    ...                 list_fault_undesirable_id=@{list_fault_undesirable_id}    admin_alias=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}

ADMIN Fault Should Be Raised - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${fault_id}
    ...                ${admin_alias}
    Log To Console                                ADMIN Fault Should Be Raised - Slave \${fault_id}=${fault_id} \${admin_alias}=${admin_alias}
    ${fault_id}                                   Convert To String                 ${fault_id}
    taf.sbts.oam.coam.admin.assert_alarm_active    parameters=faultId=${fault_id}    timeout=1    connection=${admin_alias}

ADMIN Fault Should Be Raised
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${fault_id}
    ...                ${admin_alias}=ADMIN_fault
    Log To Console                          ADMIN Fault Should Be Raised \${fault_id}=${fault_id} \${admin_alias}=${admin_alias}
    ADMIN Connect To                        admin_alias=${admin_alias}
    ADMIN Fault Should Be Raised - Slave    fault_id=${fault_id}    admin_alias=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}

ADMIN Fault Should Not Be Raised - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${fault_id}
    ...                ${admin_alias}
    Log To Console                                  ADMIN Fault Should Not Be Raised - Slave \${fault_id}=${fault_id} \${admin_alias}=${admin_alias}
    ${fault_id}                                     Convert To String                 ${fault_id}
    taf.sbts.oam.coam.admin.assert_alarm_inactive    parameters=faultId=${fault_id}    timeout=1    connection=${admin_alias}

ADMIN Fault Should Not Be Raised
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${fault_id}
    ...                ${admin_alias}=ADMIN_fault
    Log To Console                              ADMIN Fault Should Not Be Raised \${fault_id}=${fault_id} \${admin_alias}=${admin_alias}
    ADMIN Connect To                            admin_alias=${admin_alias}
    ADMIN Fault Should Not Be Raised - Slave    fault_id=${fault_id}    admin_alias=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}

ADMIN Wait Until Fault Should Be Raised
    [Arguments]    ${fault_id}
    ...            ${retry}=2 min
    ...            ${retry_interval}=10 sec
    ...            ${admin_alias}=ADMIN_fault
    Log To Console    ADMIN Wait Until Fault Should Be Raised
    Log To Console    ${SPACE * 4}\${fault_id}=${fault_id} \${admin_alias}=${admin_alias} \${retry}=${retry} \${retry_interval}=${retry_interval}
    ADMIN Connect To               admin_alias=${admin_alias}
    Wait Until Keyword Succeeds    ${retry}
    ...                            ${retry_interval}
    ...                            ADMIN Fault Should Be Raised - Slave
    ...                            fault_id=${fault_id}
    ...                            admin_alias=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}

ADMIN Wait Until Fault Should Not Be Raised
    [Arguments]    ${fault_id}
    ...            ${retry}=2 min
    ...            ${retry_interval}=10 sec
    ...            ${admin_alias}=ADMIN_fault
    Log To Console    ADMIN Wait Until Fault Should Not Be Raised
    Log To Console    ${SPACE * 4}\${fault_id}=${fault_id} \${admin_alias}=${admin_alias} \${retry}=${retry} \${retry_interval}=${retry_interval}
    ADMIN Connect To               admin_alias=${admin_alias}
    Wait Until Keyword Succeeds    ${retry}
    ...                            ${retry_interval}
    ...                            ADMIN Fault Should Not Be Raised - Slave
    ...                            fault_id=${fault_id}
    ...                            admin_alias=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}

ADMIN Wait Until Any Fault From List Should Be Raised
    [Arguments]    ${list_fault_desirable_id}
    ...            ${retry}=2 min
    ...            ${retry_interval}=10 sec
    ...            ${admin_alias}=ADMIN_fault
    Log To Console    ADMIN Wait Until Any Fault From List Should Be Raised
    Log To Console    ${SPACE * 4}\${list_fault_desirable_id}=${list_fault_desirable_id} \${admin_alias}=${admin_alias} \${retry}=${retry}
    Log To Console    ${SPACE * 4}\${retry_interval}=${retry_interval}
    ADMIN Connect To               admin_alias=${admin_alias}
    Wait Until Keyword Succeeds    ${retry}
    ...                            ${retry_interval}
    ...                            ADMIN Any Fault From List Should Be Raised - Slave
    ...                            list_fault_desirable_id=${list_fault_desirable_id}
    ...                            admin_alias=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}

ADMIN Wait Until Every Fault From List Should Be Raised
    [Arguments]    ${list_fault_desirable_id}
    ...            ${retry}=2 min
    ...            ${retry_interval}=10 sec
    ...            ${admin_alias}=ADMIN_fault
    Log To Console    ADMIN Wait Until Every Fault From List Should Be Raised
    Log To Console    ${SPACE * 4}\${list_fault_desirable_id}=${list_fault_desirable_id} \${admin_alias}=${admin_alias} \${retry}=${retry}
    Log To Console    ${SPACE * 4}\${retry_interval}=${retry_interval}
    ADMIN Connect To               admin_alias=${admin_alias}
    Wait Until Keyword Succeeds    ${retry}
    ...                            ${retry_interval}
    ...                            ADMIN Every Fault From List Should Be Raised - Slave
    ...                            list_fault_desirable_id=${list_fault_desirable_id}
    ...                            admin_alias=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}

ADMIN Wait Until None Fault From List Should Be Raised
    [Arguments]    ${list_fault_undesirable_id}
    ...            ${retry}=2 min
    ...            ${retry_interval}=10 sec
    ...            ${admin_alias}=ADMIN_fault
    Log To Console    ADMIN Wait Until None Fault From List Should Be Raised
    Log To Console    ${SPACE * 4}\${list_fault_undesirable_id}=${list_fault_undesirable_id} \${admin_alias}=${admin_alias} \${retry}=${retry}
    Log To Console    ${SPACE * 4}\${retry_interval}=${retry_interval}
    ADMIN Connect To               admin_alias=${admin_alias}
    Wait Until Keyword Succeeds    ${retry}
    ...                            ${retry_interval}
    ...                            ADMIN None Fault From List Should Be Raised - Slave
    ...                            list_fault_undesirable_id=${list_fault_undesirable_id}
    ...                            admin_alias=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}

ADMIN SW Update Abort - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${admin_alias}
    Log To Console    ADMIN SW Update Abort - Slave \${admin_alias}=${admin_alias}
    taf.sbts.oam.coam.admin.Abort Software Update
    ...               connection=${admin_alias}

ADMIN SW Update Abort
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${admin_alias}=ADMIN_update_abort
    Log To Console      ADMIN SW Update Abort \${admin_alias}=${admin_alias}
    ADMIN Connect To    admin_alias=${admin_alias}
    taf.sbts.oam.coam.admin.Abort Software Update
    ...                 connection=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}


# INFOMODEL
IM Get BTS Info - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${admin_alias}
    Log To Console    IM Get BTS Info - Slave \${admin_alias}=${admin_alias}
    ${dict_info}      taf.sbts.oam.coam.admin.Get Bts Info    connection=${admin_alias}
    ${state}          Get From Dictionary                    dictionary=${dict_info['status']}    key=proceduralState
    Log To Console    [Return] ${state}
    [Return]    ${state}

IM Get BTS Info
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${admin_alias}=ADMIN_IM_bts
    Log To Console              IM Get BTS Info \${admin_alias}=${admin_alias}
    keyword.ADMIN Connect To    admin_alias=${admin_alias}
    ${state}                    IM Get BTS Info - Slave    admin_alias=${admin_alias}
    [Teardown]    keyword.ADMIN Teardown    admin_alias=${admin_alias}
    [Return]      ${state}

IM CELL Get Specific Info - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]    ${admin_alias}
    ...            ${IM_path}=${suite_setup_cell_path}
    Log To Console    IM CELL Get Specific Info - Slave \${IM_path}=${IM_path} \${admin_alias}=${admin_alias}
    ${cell_info}    taf.sbts.oam.coam.admin.get_cell_specific_info    cell_id=${IM_path}    connection=${admin_alias}
    Log To Console    [Return] ${cell_info}
    [Return]    ${cell_info}

IM CELL Get Specific Info
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]    ${IM_path}=${suite_setup_cell_path}
    ...            ${admin_alias}=ADMIN_IM_CELL
    Log To Console    IM CELL Get Specific Info \${IM_path}=${IM_path} \${admin_alias}=${admin_alias}
    keyword.ADMIN Connect To    admin_alias=${admin_alias}
    ${cell_info}    taf.sbts.oam.coam.admin.get_cell_specific_info    cell_id=${IM_path}    connection=${admin_alias}
    Log To Console    [Return] ${cell_info}
    [Teardown]    keyword.ADMIN Teardown    admin_alias=${admin_alias}
    [Return]    ${cell_info}

IM CELL Get Availability Status - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]    ${admin_alias}
    ...            ${IM_path}=${suite_setup_cell_path}
    Log To Console    IM CELL Get Availability Status - Slave \${IM_path}=${IM_path} \${admin_alias}=${admin_alias}
    ${cell_info}    IM CELL Get Specific Info - Slave    IM_path=${IM_path}    admin_alias=${admin_alias}
    ${cell_availability_status}    Get Variable Value    ${cell_info['status']['availabilityStatus']}
    Log To Console    [Return] ${cell_availability_status}
    [Return]    ${cell_availability_status}

IM CELL Get Availability Status
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]    ${IM_path}=${suite_setup_cell_path}
    ...            ${admin_alias}=ADMIN_IM_CELL
    Log To Console    IM CELL Get Availability Status \${IM_path}=${IM_path} \${admin_alias}=${admin_alias}
    ${cell_info}    IM CELL Get Specific Info    IM_path=${IM_path}    admin_alias=${admin_alias}
    ${cell_availability_status}    Get Variable Value    ${cell_info['status']['availabilityStatus']}
    Log To Console    [Return] ${cell_availability_status}
    [Return]    ${cell_availability_status}

IM SWM Get usageState - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${admin_alias}=ADMIN_IM
    Log To Console            IM SWM Get usageState - Slave
    ${dict_SWM}               Run Keyword If                           '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...                       taf.sbts.oam.coam.admin.get_parameters    /MRBTS-1/RAT-1/SWM-1      usageState    connection=${admin_alias}
    ...                       ELSE IF                                  '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...                       taf.sbts.oam.coam.admin.get_parameters    /MRBTS-1/RAT-1/SWM-4      usageState    connection=${admin_alias}
    ...                       ELSE
    ...                       Fail                                     msg=Unknown BTS side.
    Log To Console            \${dict_SWM}=${dict_SWM}
    ${dict_SWM_state_info}    collections.Get From Dictionary          ${dict_SWM}               stateInfo
    Log To Console            \${dict_SWM_state_info}=${dict_SWM_state_info}
    ${SWM_usage_state}        collections.Get From Dictionary          ${dict_SWM_state_info}    usageState
    Log To Console            \${SWM_usage_state}=${SWM_usage_state}
    [Return]    ${SWM_usage_state}

IM SWM Get usageState
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${admin_alias}=ADMIN_IM
    Log To Console        IM SWM Get usageState
    ADMIN Connect To      admin_alias=${admin_alias}
    ${SWM_usage_state}    IM SWM Get usageState - Slave
    [Teardown]            ADMIN TEARDOWN    admin_alias=${admin_alias}
    [Return]    ${SWM_usage_state}

IM BTS Should Be OnAir - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]    ${admin_alias}
    Log To Console    IM BTS Should Be OnAir - Slave \${admin_alias}=${admin_alias}
    ${state}    IM Get BTS Info - Slave    admin_alias=${admin_alias}
    Should Be Equal    ${state}    OnAir

IM BTS Should Be OnAir
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]    ${admin_alias}=ADMIN_IM_bts
    Log To Console    IM BTS Should Be OnAir \${admin_alias}=${admin_alias}
    ${state}    IM Get BTS Info    admin_alias=${admin_alias}
    Should Be Equal    ${state}    OnAir

IM BTS Should Not Be OnAir - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]    ${admin_alias}
    Log To Console    IM BTS Should Not Be OnAir - Slave \${admin_alias}=${admin_alias}
    ${state}    IM Get BTS Info - Slave    admin_alias=${admin_alias}
    Should Not Be Equal    ${state}    OnAir

IM BTS Should Not Be OnAir
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]    ${admin_alias}=ADMIN_IM_bts
    Log To Console    IM BTS Should Not Be OnAir \${admin_alias}=${admin_alias}
    ${state}    IM Get BTS Info    admin_alias=${admin_alias}
    Should Not Be Equal    ${state}    OnAir

IM Wait Until BTS Should Be OnAir
    [Arguments]    ${retry}=15 min
    ...            ${retry_interval}=30 sec
    ...            ${admin_alias}=ADMIN_IM_bts
    Log To Console    IM Wait Until BTS Should Be OnAir    \${retry}=${retry} \${retry_interval}=${retry_interval} \${admin_alias}=${admin_alias}
    keyword.ADMIN Connect To    admin_alias=${admin_alias}
    Wait Until Keyword Succeeds
    ...    ${retry}
    ...    ${retry_interval}
    ...    IM BTS Should Be OnAir - Slave
    ...    admin_alias=${admin_alias}
    [Teardown]    keyword.ADMIN Teardown    admin_alias=${admin_alias}

IM Wait Until BTS Should Not Be OnAir
    [Arguments]    ${retry}=15 min
    ...            ${retry_interval}=30 sec
    ...            ${admin_alias}=ADMIN_IM_bts
    Log To Console    IM Wait Until BTS Should Not Be OnAir    \${retry}=${retry} \${retry_interval}=${retry_interval} \${admin_alias}=${admin_alias}
    keyword.ADMIN Connect To    admin_alias=${admin_alias}
    Wait Until Keyword Succeeds
    ...    ${retry}
    ...    ${retry_interval}
    ...    IM BTS Should Not Be OnAir - Slave
    ...    admin_alias=${admin_alias}
    [Teardown]    keyword.ADMIN Teardown    admin_alias=${admin_alias}

IM CELL Should Be Online - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]    ${admin_alias}
    ...            ${IM_path}=${suite_setup_cell_path}
    Log To Console    IM CELL Should Be Online - Slave \${IM_path}=${IM_path} \${admin_alias}=${admin_alias}
    ${cell_availability_status}    IM CELL Get Availability Status - Slave    IM_path=${IM_path}    admin_alias=${admin_alias}
    Should Be Equal    ${cell_availability_status}    Online

IM CELL Should Be Online
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]    ${IM_path}=${suite_setup_cell_path}
    ...            ${admin_alias}=ADMIN_IM_CELL
    Log To Console    IM CELL Should Be Online \${IM_path}=${IM_path} \${admin_alias}=${admin_alias}
    ${cell_availability_status}    IM CELL Get Availability Status    IM_path=${IM_path}    admin_alias=${admin_alias}
    Should Be Equal    ${cell_availability_status}    Online

IM CELL Should Not Be Online - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]    ${admin_alias}
    ...            ${IM_path}=${suite_setup_cell_path}
    Log To Console    IM CELL Should Not Be Online - Slave \${IM_path}=${IM_path} \${admin_alias}=${admin_alias}
    ${cell_availability_status}    IM CELL Get Availability Status - Slave    IM_path=${IM_path}    admin_alias=${admin_alias}
    Should Not Be Equal    ${cell_availability_status}    Online

IM CELL Should Not Be Online
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]    ${IM_path}=${suite_setup_cell_path}
    ...            ${admin_alias}=ADMIN_IM_CELL
    Log To Console    IM CELL Should Not Be Online \${IM_path}=${IM_path} \${admin_alias}=${admin_alias}
    ${cell_availability_status}    IM CELL Get Availability Status    IM_path=${IM_path}    admin_alias=${admin_alias}
    Should Not Be Equal    ${cell_availability_status}    Online

IM CELL Wait Until Should Be Online
    [Arguments]    ${IM_path}=${suite_setup_cell_path}
    ...            ${retry}=15 min
    ...            ${retry_interval}=30 sec
    ...            ${admin_alias}=ADMIN_IM_CELL
    Log To Console    IM CELL Wait Until Should Be Online
    Log To Console    ${SPACE * 4}\${IM_path}=${IM_path} \${retry}=${retry} \${retry_interval}=${retry_interval} \${admin_alias}=${admin_alias}
    keyword.ADMIN Connect To    admin_alias=${admin_alias}
    Wait Until Keyword Succeeds
    ...    ${retry}
    ...    ${retry_interval}
    ...    IM CELL Should Be Online - Slave
    ...    IM_path=${IM_path}
    ...    admin_alias=${admin_alias}
    [Teardown]    keyword.ADMIN Teardown    admin_alias=${admin_alias}

IM CELL Wait Until Should Not Be Online
    [Arguments]    ${IM_path}=${suite_setup_cell_path}
    ...            ${retry}=15 min
    ...            ${retry_interval}=30 sec
    ...            ${admin_alias}=ADMIN_IM_CELL
    Log To Console    IM CELL Wait Until Should Not Be Online
    Log To Console    ${SPACE * 4}\${IM_path}=${IM_path} \${retry}=${retry} \${retry_interval}=${retry_interval} \${admin_alias}=${admin_alias}
    keyword.ADMIN Connect To    admin_alias=${admin_alias}
    Wait Until Keyword Succeeds
    ...    ${retry}
    ...    ${retry_interval}
    ...    IM CELL Should Not Be Online - Slave
    ...    IM_path=${IM_path}
    ...    admin_alias=${admin_alias}
    [Teardown]    keyword.ADMIN Teardown    admin_alias=${admin_alias}

IM SWM usageState Should Be Idle - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${admin_alias}=ADMIN_IM
    Log To Console        IM SWM usageState Should Be Idle
    ${SWM_usage_state}    IM SWM Get usageState - Slave    admin_alias=${admin_alias}
    Should Be Equal       ${SWM_usage_state}               Idle

IM SWM usageState Should Be Idle
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${admin_alias}=ADMIN_IM
    Log To Console        IM SWM usageState Should Be Idle
    ${SWM_usage_state}    IM SWM Get usageState    admin_alias=${admin_alias}
    Should Be Equal       ${SWM_usage_state}       Idle

IM SWM usageState Should Be Busy - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]        ${admin_alias}=ADMIN_IM
    Log To Console        IM SWM usageState Should Be Busy
    ${SWM_usage_state}    IM SWM Get usageState    admin_alias=${admin_alias}
    Should Be Equal       ${SWM_usage_state}       Busy

IM SWM usageState Should Be Busy
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]        ${admin_alias}=ADMIN_IM
    Log To Console        IM SWM usageState Should Be Busy
    ${SWM_usage_state}    IM SWM Get usageState
    Should Be Equal       ${SWM_usage_state}    Busy

IM Wait Until SWM usageState Should Be Idle
    [Arguments]    ${retry}=2 min
    ...            ${retry_interval}=10 sec
    ...            ${admin_alias}=ADMIN_IM
    Log To Console                 IM Wait Until SWM usageState Should Be Idle
    Log To Console                 ${SPACE * 4}\${admin_alias}=${admin_alias} \${retry}=${retry} \${retry_interval}=${retry_interval}
    ADMIN Connect To               admin_alias=${admin_alias}
    Wait Until Keyword Succeeds    ${retry}
    ...                            ${retry_interval}
    ...                            keyword.IM SWM usageState Should Be Idle - Slave
    ...                            admin_alias=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}

IM Wait Until SWM usageState Should Be Busy
    [Arguments]    ${retry}=2 min
    ...            ${retry_interval}=10 sec
    ...            ${admin_alias}=ADMIN_IM
    Log To Console                 IM Wait Until SWM usageState Should Be Busy
    Log To Console                 ${SPACE * 4}\${admin_alias}=${admin_alias} \${retry}=${retry} \${retry_interval}=${retry_interval}
    ADMIN Connect To               admin_alias=${admin_alias}
    Wait Until Keyword Succeeds    ${retry}
    ...                            ${retry_interval}
    ...                            keyword.IM SWM usageState Should Be Busy - Slave
    ...                            admin_alias=${admin_alias}
    [Teardown]    ADMIN Teardown    admin_alias=${admin_alias}

# SELENIUM-TAF
# possible SELENIUM requirement: some general setup - maximize window, don't display, timeout of browser session
SELENIUM-TAF Connect To
    Log To Console    SELENIUM Connect To
    taf.ul.oam.selenium_coam.login    url=https://192.168.255.1/    username=Nemuadmin    password=nemuuser

SELENIUM-TAF Teardown
    Log To Console    SELENIUM Teardown
    taf.ul.oam.selenium_coam.logout

# TODO: SELENIUM-TAF Detail Site View RMOD Should Be OnAir
# TODO: SELENIUM-TAF Detail Site View RMOD Should Be Failed
# TODO: SELENIUM-TAF Detail Site View CELL Should Be OnAir
# TODO: SELENIUM-TAF Detail Site View CELL Should Be Degraded

# TODO: SELENIUM-TAF Active Alarm - Fault Should Be Raised
# TODO: SELENIUM-TAF Active Alarm - Fault Should Not Be Raised
# TODO: SELENIUM-TAF Wait Until Active Alarm - Fault Should Be Raised
# TODO: SELENIUM-TAF Wait Until Active Alarm - Fault Should Not Be Raised
# TODO: SELENIUM-TAF Active Alarm - Download File
# TODO: SELENIUM-TAF Get Active Alarm ID
# TODO: SELENIUM-TAF Get Active Alarm Parent Object

SELENIUM-TAF Alarm History - Fault Should Be Present
    [Documentation]    Argument ${fault_id} as string or integer, without char ' or ".
    [Arguments]    ${fault_id}
    Log To Console    SELENIUM-TAF Alarm History - Fault Should Be Present
    ${fault_id}    Convert To String    ${fault_id}
    ${output}    taf.ul.oam.selenium_coam.get_history_alarm_info    alarm_filter=${fault_id}
    Log To Console    \\n\${output}=\n${output}
    Should Not Be Empty    ${output}
    # Collections.Dictionary Should Contain Item    dictionary=${output[i]}    key=Fault ID    value=10    # in loop version is possible
    ${output}    Convert To String    ${output}
    Should Contain    ${output}    u'Fault ID': u'${fault_id}'

# TODO: SELENIUM-SELENIUM-TAF Alarm History - Fault Should Not Be Present

SELENIUM-TAF Alarm History - Download File
    [Arguments]    ${dir_sub}=${EMPTY}
    Log To Console    SELENIUM-TAF Alarm History - Download File
    ${path_full}    taf.ul.oam.selenium_coam.save_historical_alarms
    Log To Console    \${path_full}=${path_full}
    Create Directory    ${OUTPUT_DIR}/${TEST_NAME}/${dir_sub}
    ${list_split}    OperatingSystem.Split Path    ${path_full}
    OperatingSystem.Move File    ${path_full}    ${OUTPUT_DIR}/${TEST_NAME}/${dir_sub}/${list_split[1]}
    Log To Console    [Return] ${OUTPUT_DIR}/${TEST_NAME}/${dir_sub}/${list_split[1]}
    [Return]    ${OUTPUT_DIR}/${TEST_NAME}/${dir_sub}/${list_split[1]}

# TODO: SELENIUM-TAF Wait Until Alarm History - Fault Should Be Present
# TODO: SELENIUM-TAF Wait Until Alarm History - Fault Should Not Be Present

# TODO: SELENIUM-TAF Toggling History - Download File

# SELENIUM common
SELENIUM Setup
    Log To Console    SELENIUM Setup
    SELENIUM Prepare Enviroment
    SELENIUM Login To Web Element Manager

SELENIUM Teardown
    Log To Console    SELENIUM Teardown
    SELENIUM Teardown Enviroment

# SUITE SETUP
SUITE SETUP Get mrbts_id - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]    ${admin_alias}
    Log To Console    SUITE SETUP Get mrbts_id - Slave \${admin_alias}=${admin_alias}
    ${bts_info}    taf.sbts.oam.coam.admin.get_bts_info    connection=${admin_alias}    timeout=1
    ${mrbts_id}    Get Variable Value    ${bts_info['mrbtsID']}
    Log To Console    [Return] ${mrbts_id}
    [Return]    ${mrbts_id}

SUITE SETUP Get mrbts_id
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]    ${admin_alias}=ADMIN_SUITE_SETUP_mrbts_id
    Log To Console    SUITE SETUP Get mrbts_id \${admin_alias}=${admin_alias}
    keyword.ADMIN Connect To    admin_alias=${admin_alias}
    ${mrbts_id}    SUITE SETUP Get mrbts_id - Slave    admin_alias=${admin_alias}
    Log To Console    [Return] ${mrbts_id}
    [Teardown]    keyword.ADMIN Teardown    admin_alias=${admin_alias}
    [Return]    ${mrbts_id}

SUITE SETUP Set Variable mrbts_id - Slave
    [Documentation]    Slave - use existing connection.
    [Arguments]    ${admin_alias}
    Log To Console    SUITE SETUP Set Variable mrbts_id - Slave \${admin_alias}=${admin_alias}
    ${mrbts_id}    SUITE SETUP Get mrbts_id - Slave    admin_alias=${admin_alias}
    Set Suite Variable    ${suite_setup_mrbts_id}    ${mrbts_id}
    Log To Console    Suite Variable \${suite_setup_mrbts_id}=${suite_setup_mrbts_id}

SUITE SETUP Set Variable mrbts_id
    [Documentation]    It will eventually make it's own ADMIN connection.
    [Arguments]    ${admin_alias}=ADMIN_SUITE_SETUP_mrbts_id
    Log To Console    SUITE SETUP Set Variable mrbts_id \${admin_alias}=${admin_alias}
    ${mrbts_id}    SUITE SETUP Get mrbts_id    admin_alias=${admin_alias}
    Set Suite Variable    ${suite_setup_mrbts_id}    ${mrbts_id}
    Log To Console    Suite Variable \${suite_setup_mrbts_id}=${suite_setup_mrbts_id}

SUITE SETUP Set Variable nrbts_id
    [Documentation]
    ...    Must be used only after `suite_setup_set_variable_mrbts_id`
    Log To Console    SUITE SETUP Set Variable nrbts_id
    Set Suite Variable    ${suite_setup_nrbts_id}    ${suite_setup_mrbts_id}
    Log To Console    Suite Variable \${suite_setup_nrbts_id}=${suite_setup_nrbts_id}

SUITE SETUP Set Variable cell_path
    [Documentation]
    ...    Must be used only after `suite_setup_set_variable_mrbts_id` and `suite_setup_set_variable_nrbts_id`.
    Log To Console    SUITE SETUP Set Variable cell_path - Slave
    Set Suite Variable    ${suite_setup_cell_path}    MRBTS-${suite_setup_mrbts_id}/NRBTS-${suite_setup_nrbts_id}/NRCELL-1
    Log To Console    Suite Variable \${suite_setup_cell_path}=${suite_setup_cell_path}

# Usages
Fault SW Update Should Not Be Raised
    [Timeout]    20 min    # TL 021: 20
    Log To Console                                 Fault SW Update Should Not Be Raised
    @{list_fault_SW_Update}                        Create List    27    28    29    30
    ADMIN None Fault From List Should Be Raised    list_fault_undesirable_id=@{list_fault_SW_Update}

Fault 10 RMOD Canceller - Reboot
    Log To Console    Fault 10 RMOD Canceller - Reboot
    ADMIN Wait Until Fault Should Not Be Raised    fault_id=10    retry=6 min    retry_interval=5 sec    admin_alias=ADMIN_fault_10

Fault 28 Test Setup
    [Documentation]    Assert fault 28 is not raised.
    ...                Download predecessor software. One version leave as valid and corrupt second version, both in separate special directories.
    [Timeout]          34 min    # TL 021: 34
    Log To Console        Fault 28 Test Setup
    keyword.ADMIN Reset Site
    PC Wait Until BTS Disconnected And Connected
    ADMIN Wait Until Connect To Should Be Successful
    IM Wait Until BTS Should Be OnAir

    Run                   mkdir /home/ute/BTS_SW_corrupted
    ${path}               ADMIN Download Predecessor Software And Corrupt    /home/ute/BTS_SW_corrupted
    Set Suite Variable    ${path_predecessor_sw_package_corrupted}           ${path}
    Run                   mkdir /home/ute/BTS_SW_valid
    ${path}               ADMIN Download Predecessor Software                /home/ute/BTS_SW_valid
    Set Suite Variable    ${path_predecessor_sw_package}                     ${path}

Fault 28 Trigger
    [Timeout]    25 min    # TL 021: 25
    Log To Console                                      Fault 28 Trigger
    ${CLI_INTERFACE}                                    Get Library Instance                 taf.sbts.oam.coam.admin
    ADMIN Connect To                                    admin_alias=ADMIN_SW_Update_in_background
    keyword.IM SWM usageState Should Be Idle - Slave    admin_alias=ADMIN_SW_Update_in_background
    ${output_task_abort_in_background}   taf.sbts.oam.coam.admin.run_keyword_in_background    interface=${CLI_INTERFACE}
    ...                                                                                      name=update_software
    ...                                                                                      sw_package=${path_predecessor_sw_package_corrupted}
    ...                                                                                      should_activate=${TRUE}
    ...                                                                                      connection=ADMIN_SW_Update_in_background

    # process: download
    IM Wait Until SWM usageState Should Be Busy         retry=5 min                          retry_interval=10 sec    # TL 021: 15 sec
    IM Wait Until SWM usageState Should Be Idle         retry=15 min                         retry_interval=10 sec    # TL 021: 5 min 20 sec
    [Teardown]    ADMIN Teardown    admin_alias=ADMIN_SW_Update_in_background

Fault 28 Trigger And Should Be Raised
    [Timeout]    25 min    # TL 021: 25
    Log To Console                             Fault 28 Trigger And Should Be Raised
    Fault 28 Trigger
    # IM SWM Failure Reason SHould Be StorageFileCRC_Failure
    ADMIN Wait Until Fault Should Be Raised    fault_id=28

Fault 29 Trigger
    [Documentation]
    ...    Accept only system with active partition equal to 1 or 2.
    ...    Makes change in file system of BTS - set invalid active_partition variable.

    [Timeout]    26 min    # TL 021: 26
    Log To Console                                      Fault 29 Trigger
    ${CLI_INTERFACE}                                    Get Library Instance                     taf.sbts.oam.coam.admin
    keyword.SSH SMOD Connect To                         ssh_alias=SSH_SMOD_fault
    ${str_active_partition_id}                          SSH SMOD Get active_partition - Slave    ssh_alias=SSH_SMOD_fault
    Should Match Regexp                                 ${str_active_partition_id}               (1|2)
    ADMIN Connect To                                    admin_alias=ADMIN_SW_Update
    keyword.IM SWM usageState Should Be Idle - Slave    admin_alias=ADMIN_SW_Update
    Sleep  5
    ADMIN Update Software Without Activation
    ...            sw_package=${SW_DESTINATION}/${T1_package}
    ...            timeout=900
    IM Wait Until SWM usageState Should Be Idle         retry=15 min    retry_interval=2 sec    # TL 021: 5 min 10 sec
    SSH SMOD Set active_partition - Slave               value=5         ssh_alias=SSH_SMOD_fault
    log to console   SW Activation start
    run keyword and expect error  *AdminApiProcedureFailureException:*  ADMIN Update Software With Activation
    ...            sw_package=${SW_DESTINATION}/${T1_package}
    ...            timeout=900
    Sleep  10

    [Teardown]    Run Keywords    SSH SMOD Set active_partition - Slave     value=${str_active_partition_id}    ssh_alias=SSH_SMOD_fault
    ...                           AND
    ...                           keyword.SSH SMOD Disconnect - TEARDOWN    ssh_alias=SSH_SMOD_fault
    ...                           AND
    ...                           ADMIN Teardown                            admin_alias=ADMIN_SW_Update

#Download Trunk Load
#    Run   mkdir ${SW_DESTINATION}
#	Set suite variable  ${download_url}  ${URL_5G}/0.800.1300/AirScale-0.800.1300_ASIK_ABIL.zip
#    run  wget ${download_url} -P ${SW_DESTINATION}/
#    OperatingSystem.File should exist   path=${SW_DESTINATION}/AirScale-0.800.1300_ASIK_ABIL.zip
#    Log to console  Download completed

Download SW
#    Run    sudo rm -R ${SW_DESTINATION}/*
    ${ACTIVE_SOFTWARE}=    Replace String Using Regexp    ${OUT_ACTIVE_SW}    ^5G20[A-Za-z0-9]*\_?    5G20_
    ${ACTIVE_SOFTWARE}=    Get Substring    ${ACTIVE_SOFTWARE}    0    28
    ${ACTIVE_SOFTWARE_NUMBER}=    Get Substring    ${ACTIVE_SOFTWARE}    23    28
    ${sw_package_T1}=    Convert To String    ${SW_DESTINATION}/AirScale-0.800.${ACTIVE_SOFTWARE_NUMBER}T1_edit_HC.zip
    ${sw_package}=    Convert To String    ${SW_DESTINATION}/AirScale-0.800.${ACTIVE_SOFTWARE_NUMBER}_edit_HC.zip
    Set Suite Variable    ${main_package}    AirScale-0.800.${ACTIVE_SOFTWARE_NUMBER}_ASIK_ABIL.zip
    Set Suite Variable    ${T1_package}    AirScale-0.800.${ACTIVE_SOFTWARE_NUMBER}T1_ASIK_ABIL.zip
    Set Suite Variable    ${T2_package}    AirScale-0.800.${ACTIVE_SOFTWARE_NUMBER}T2_ASIK_ABIL.zip
    Log    \nDownload SW packages    console=yes
    Run    wget ${URL_5G}/0.800.${ACTIVE_SOFTWARE_NUMBER}/${T1_package} -P ${SW_DESTINATION}
	Run    wget ${URL_5G}/0.800.${ACTIVE_SOFTWARE_NUMBER}/${main_package} -P ${SW_DESTINATION}
    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${T1_package}
	OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${main_package}
    Log    Download completed    console=yes
    [Return]    ${sw_package}    ${ACTIVE_SOFTWARE}   ${T1_package}


Fault 30 Trigger
    [Timeout]    25 min    # TL 021: 25
    Log To Console                                 Fault 30 Trigger
    ${CLI_INTERFACE}                               Get Library Instance    taf.sbts.oam.coam.admin
    ADMIN Connect To                               admin_alias=ADMIN_SW_Update
    keyword.IM SWM usageState Should Be Idle - Slave    admin_alias=ADMIN_SW_Update
    Sleep  5
#    ADMIN Update Software Without Activation
#    ...            sw_package=${SW_DESTINATION}/${T1_package}
#    ...            timeout=900
    ${output_task_abort_in_background}   taf.sbts.oam.coam.admin.run_keyword_in_background    interface=${CLI_INTERFACE}
    ...                                                                                      name=update_software
    ...                                                                                      sw_package=${SW_DESTINATION}/${T1_package}
    ...                                                                                      should_activate=${TRUE}
    ...                                                                                      connection=ADMIN_SW_Update
#
#    # process: download
    IM Wait Until SWM usageState Should Be Busy    retry=5 min    retry_interval=10 sec    # TL 021: 12 sec
#    # SSH SMOD SW Update Directory Planned - Delete Files    ssh_alias=SSH_SMOD_fault    # TL 021: 0.36 sec
#    # IM Wait Until SWM usageState Should Be Idle    retry=15 min    retry_interval=1 sec    # TL 021: 5 min
    SSH SMOD Wait Until SWDLreport Should Not Be Empty
    SSH SMOD Wait Until SWDLreport Should Be Empty    retry=15 min    retry_interval=2 sec
    # SSH SMOD SW Update Directory Planned - Delete Files - Slave    ssh_alias=SSH_SMOD_fault    # TL 021: ---
    run keyword and continue on failure   SSH SMOD SW Update Directory Planned - Delete Files    # TL 021: ---
#    log to console   SW Activation start
#    run keyword and expect error  *AdminApiProcedureFailureException:*  ADMIN Update Software With Activation
#    ...            sw_package=${SW_DESTINATION}/${T1_package}
#    ...            timeout=900
#    Sleep  10

    [Teardown]    ADMIN Teardown    admin_alias=ADMIN_SW_Update

Fault 30 Trigger And Should Be Raised
    [Timeout]    27 min    # TL 021: 27
    Log To Console                             Fault 30 Trigger And Should Be Raised
    Fault 30 Trigger
    # IM SWM Failure Reason SHould Be SwActivationFailure
    ADMIN Wait Until Fault Should Be Raised    fault_id=30

Fault 4383 Trigger
    [Timeout]    2 min    # TL 021: 0.525 sec
    Log To Console                    Fault 4383 Trigger
    keyword.SSH SMOD Connect To       ssh_alias=SSH_SMOD_fault
    ${VN_id}                          keyword.SSH SMOD Get VN ID - Slave    ssh_alias=SSH_SMOD_fault
    taf.transport.ssh.Send Command    command=lxc-attach -n ${VN_id} -- kill -9 -1    connection=SSH_SMOD_fault
    ${output}                         taf.transport.ssh.Read Output    connection=SSH_SMOD_fault
    # Should Be Empty    ${output}
    [Teardown]    keyword.SSH SMOD Disconnect - TEARDOWN    ssh_alias=SSH_SMOD_fault

Fault 4383 Trigger And Should Have Been Raised
    [Documentation]    Triggering fault 4383 cause autonomous BTS reset. Therefore checking if it was raised is possible only after next start up.
    [Timeout]          23 min    # TL 021: 23
    Log To Console    Fault 4383 Trigger And Should Be Raised
    Fault 4383 Trigger
    # ADMIN Wait Until Fault Should Be Raised    fault_id=4383    retry_interval=0
    fault_trigger.Mark Date And Time
    fault_trigger.Check If Recovery Action Is Performed
    Wait Until Keyword Succeeds
    ...               5 min
    ...               5 sec
    ...               fault_trigger.Check If BTS Is Not In Uncommissioned State
    fault_trigger.Check If Fault 4383 Was Raised


Fault SW Update Canceller
    [Timeout]    20 min    # TL 021: 20
    Log To Console                                 Fault SW Update Canceller
    # SW Package Valid Should Be Under Path    path_full=${path_predecessor_sw_package}    # TODO
    ${CLI_INTERFACE}                               Get Library Instance    taf.sbts.oam.coam.admin

    ADMIN Connect To                               admin_alias=ADMIN_SW_Update_in_background
    ADMIN Connect To                               admin_alias=ADMIN_SW_Update_Abort
    ${output_task_abort_in_background}   taf.sbts.oam.coam.admin.run_keyword_in_background    interface=${CLI_INTERFACE}
    ...                                                                                      name=update_software
    ...                                                                                      sw_package=${path_predecessor_sw_package}
    ...                                                                                      should_activate=${TRUE}
    ...                                                                                      connection=ADMIN_SW_Update_in_background

    IM Wait Until SWM usageState Should Be Busy    retry=5 min    retry_interval=10 sec
    ADMIN SW Update Abort - Slave                  admin_alias=ADMIN_SW_Update_Abort
    IM Wait Until SWM usageState Should Be Idle    retry=2 min    retry_interval=10 sec
    # IM SWM result Should Be Aborted

    [Teardown]    Run Keywords    ADMIN Teardown    admin_alias=ADMIN_SW_Update_Abort
    ...                           AND
    ...                           ADMIN Teardown    admin_alias=ADMIN_SW_Update_in_background

Fault SW Update Canceller And Should Not Be Raised
    [Timeout]    20 min    # TL 021: 20
    Log To Console    Fault SW Update Canceller And Should Not Be Raised
    Fault SW Update Canceller
    Fault SW Update Should Not Be Raised

RMOD Fault 1937 Trigger
    Log To Console    RMOD Fault 1937 Trigger
    PC Create Batch File - RMOD Fault 1937 Trigger
    SSH RMOD Upload Batch File - RMOD Fault 1937 Trigger
    SSH RMOD Execute Batch File - RMOD Fault 1937 Trigger

RMOD Fault 1937 Trigger And Should Be Raised
    Log To Console    RMOD Fault 1937 Trigger And Should Be Raised
    RMOD Fault 1937 Trigger
    ADMIN Wait Until Fault Should Be Raised    fault_id=1937
    ...                                        retry=10 min
    ...                                        retry_interval=10 sec
    ...                                        admin_alias=ADMIN_fault_1937

RMOD Fault 1937 Canceller
    PC Create Batch File - RMOD Fault 1937 Canceller
    SSH RMOD Upload Batch File - RMOD Fault 1937 Canceller
    SSH RMOD Execute Batch File - RMOD Fault 1937 Canceller
    Log To Console    Fault 1937 is cancelled.

RMOD Fault 1937 Canceller And Should Not Be Raised
    Log To Console    RMOD Fault 1937 Canceller And Should Not Be Raised
    RMOD Fault 1937 Canceller
    ADMIN Wait Until Fault Should Not Be Raised    fault_id=1937    retry=7 min    retry_interval=10 sec    admin_alias=ADMIN_fault_1937


# archive
Parse SW Version Into Package Name
    [Arguments]
    ...    ${bts_sw_version}

    @{list_software_version}    string.split_string    string=${bts_sw_version}    separator=_
    ${SW_name_part_3}    convert_to_integer    @{list_software_version}[-1]
    ${SW_name_part_2}    convert_to_integer    @{list_software_version}[-2]
    ${SW_name_part_1}    convert_to_integer    @{list_software_version}[-3]
    ${sw_package_name}    set_variable    AirScale-${SW_name_part_1}.${SW_name_part_2}.${SW_name_part_3}.zip
    [Return]    ${sw_package_name}

Get Processes From Virtual Node
    [Documentation]
    ...    Display in console processes from selected virtual node.
    ...    OBSOLETE
    [Arguments]
    ...    ${vn_address}=0xe002
    ...    ${connection_ssh}=default

    taf.transport.ssh.Send Command    command=lxc-attach -n ${vn_address} -- ps aux    connection=${connection_ssh}
    ${VN_processes}    taf.transport.ssh.Read Output    connection=${connection_ssh}
    [Return]    ${VN_processes}

Process On Virtual Node Should Be Running
    # OBSOLETE
    [Arguments]
    ...    ${process_command}
    ...    ${vn_address}=0xe002
    ...    ${connection_ssh}=default

    ${VN_processes}    Get Processes From Virtual Node    vn_address=${vn_address}    connection_ssh=${connection_ssh}
    ${searched_lines}    string.Get Lines Matching Pattern    ${VN_processes}    *${process_command}*
    Should Not Be Empty    ${searched_lines}

Kill Process On Virtual Node
    # OBSOLETE
    [Arguments]
    ...    ${vn_address}=0xe002
    ...    ${connection_ssh}=default
    taf.transport.ssh.Send Command    command=lxc-attach -n ${vn_address} -- kill -9 20    connection=${connection_ssh}

Get Active Fault Time Of Appearance
    # OBSOLETE
    [Arguments]
    ...    ${fault_id_expected}
    ...    ${connection_cli}=default

    ${searched_fault_time}    Set Variable    placeholder before loop
    # Refresh CLI Connection    connection=${connection_cli}
    ${dict_active_alarms}    taf.sbts.oam.coam.admin.get_active_alarms    timeout=60    connection=${connection_cli}
    ${len}    Get Length    ${dict_active_alarms}
    ${list_active_alarm_id}    Create List
    :FOR    ${i}    IN RANGE    ${len}
    \    ${dict_fault_id}    collections.Get From Dictionary    ${dict_active_alarms[${i}]}    faultId
    \    Append To List    ${list_active_alarm_id}    ${dict_fault_id}
    \    ${dict_fault_time}    collections.Get From Dictionary    ${dict_active_alarms[${i}]}    btsObservationTime
    \    ${is_searched_fault}    Set Variable If    ${dict_fault_id} == ${fault_id_expected}    ${TRUE}    ${FALSE}
    \    ${searched_fault_time}    Set Variable If    ${is_searched_fault}    ${dict_fault_time}    ${searched_fault_time}
    Log To Console    Active alarms: alarm_id_list=${list_active_alarm_id}
    collections.List Should Contain Value    ${list_active_alarm_id}    ${fault_id_expected}
    Log To Console    Fault ${fault_id_expected} is raised with time=${searched_fault_time}
    [Return]    ${searched_fault_time}

Fault Should Be In History With Time
    # OBSOLETE
    [Arguments]
    ...    ${fault_id}
    ...    ${fault_time}
    ...    ${connection_cli}=default
    Set Test Variable    ${fault_is_in_history}    ${FALSE}
    ${searched_fault_time}    Set Variable    placeholder before loop
    ${dict_alarm_history}    taf.sbts.oam.coam.admin.get_historic_alarms    timeout=60    connection=${connection_cli}
    ${len}    Get Length    ${dict_alarm_history}
    :FOR    ${i}    IN RANGE    ${len}
    \    ${dict_fault_id}    collections.Get From Dictionary    ${dict_alarm_history[${i}]}    faultId
    \    ${dict_fault_time}    collections.Get From Dictionary    ${dict_alarm_history[${i}]}    btsObservationTime
    \    Log To Console    [${i}] [fault ${dict_fault_id}] fault_historical_time=${dict_fault_time}
    \    ${is_searched_fault}    Set Variable If    ${dict_fault_id} == ${fault_id}    ${TRUE}    ${FALSE}
    \    Run Keyword If    ${is_searched_fault}    Set Test Variable    ${fault_is_in_history}    ${TRUE}
    \    ${searched_fault_time}    Set Variable If    ${is_searched_fault}    ${dict_fault_time}    ${searched_fault_time}
    Should Be True    ${fault_is_in_history}
    Should Be Equal    ${searched_fault_time}    ${fault_time}
    Log To Console    Last fault ${fault_id} is in alarm history with time=${searched_fault_time}

Fault 10 RMOD Trigger - Reboot
    [Arguments]    ${timeout}=3 min
    [Timeout]    ${timeout}

    Log To Console    Fault 10 RMOD Trigger - Reboot
    Log To Console    \${SYSTEM_RMOD_LOCAL_IP}=${SYSTEM_RMOD_LOCAL_IP}
    SSH RMOD Connect To - proxy SMOD    ssh_alias=SSH_RMOD_fault_10    proxy=SSH_RMOD_proxy_fault_10
    ${output}    Run Keyword If    '${out_rmods_productnames_list[0]}' == 'AHPD'
    ...    taf.transport.ssh.Send Command    command=pssreboot hw    connection=SSH_RMOD_fault_10
    ...    ELSE IF                 '${out_rmods_productnames_list[0]}' == 'AHLOA'
    ...    taf.transport.ssh.Send Command    command=pssreboot hw    connection=SSH_RMOD_fault_10
    ...    ELSE IF                 '${out_rmods_productnames_list[0]}' == 'AEQN'
    ...    taf.transport.ssh.Send Command    command=rfsw-reboot    connection=SSH_RMOD_fault_10
               # for some reason `Execute` is lagging with `command=rfsw-reboot`, wich is not a case for other RMODs using that reboot command
    ...    ELSE IF                 '${out_rmods_productnames_list[0]}' == 'AEUA'
    ...    taf.transport.ssh.Execute    command=rfsw-reboot    connection=SSH_RMOD_fault_10
    ...    ELSE
    ...    Fail    msg=Trigger fault 10 - Unsupported RMOD.
    Log To Console    RMOD command reboot \${output}=${output}
    SSH RMOD Disconnect - proxy SMOD    ssh_alias=SSH_RMOD_fault_10    proxy=SSH_RMOD_proxy_fault_10

    ADMIN Wait Until Fault Should Be Raised    fault_id=10    retry=2 min    retry_interval=5 sec    admin_alias=ADMIN_fault_10
    Log To Console    Fault 10 is raised (RMOD reboot) in ADMIN CLI.

    [Teardown]    SSH RMOD Disconnect - proxy SMOD - TEARDOWN    ssh_alias=SSH_RMOD_fault_10    proxy=SSH_RMOD_proxy_fault_10

#File Should Contain Fault
#    [Documentation]
#    ...    Insert `id_fault` as string without " characters.
#    ...    OBSOLETE
#    [Arguments]
#    ...    ${path_file}
#    ...    ${fault_id}
#
#    ${content_of_file_active_alarms}    Get File    ${path_file}
#    ${list_content_of_file}    string.Split String    ${content_of_file_active_alarms}    ,
#    List Should Contain Value    ${list_content_of_file}    "${fault_id}"
#
#File Should Not Contain Fault
#    [Documentation]
#    ...    Insert `id_fault` as string without " characters.
#    ...    OBSOLETE
#    [Arguments]
#    ...    ${path_file}
#    ...    ${fault_id}
#
#    ${content_of_file_active_alarms}    Get File    ${path_file}
#    ${list_content_of_file}    string.Split String    ${content_of_file_active_alarms}    ,
#    List Should Not Contain Value    ${list_content_of_file}    "${fault_id}"

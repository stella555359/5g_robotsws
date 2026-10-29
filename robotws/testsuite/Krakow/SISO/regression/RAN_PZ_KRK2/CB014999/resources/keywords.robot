*** Settings ***
Documentation
...    Author: Lukasz Wlosowicz, lukasz.wlosowicz@nokia.com
...    CB014999

Library      SSHLibrary
Library      Collections
Library      taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME    RuOp
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    CellOp
Library      ./python_keywords.py

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./variables.py


*** Keywords ***
Get RTWP histograms from RUs via SSH
    &{rtwp_histograms}=    Create dictionary
    FOR    ${rmod_id}    IN    @{RUS_INFO.keys()}
        ${ru}=    Set variable    ${RUS_INFO}[${rmod_id}]
        ${rmod_id_the_number}=    Set variable    ${rmod_id.split("-")[1]}
        Gather IP set variables    ${rmod_id_the_number}    ${ru}[sn]    ${ru}[password]    ${ru}[user]
        Log to console    IP address of ${rmod_id} (${ru}[name]): ${RU_IP}    console=${True}
        ${rtwp_dict}=    Get RTWP histogram from RU via SSH    ru_prompt=${ru}[console_prompt]
        Set to dictionary    ${rtwp_histograms}    ${rmod_id}    ${rtwp_dict}
    END
    SSHLibrary.Close all connections
    [Return]    ${rtwp_histograms}

Get RTWP histogram from RU via SSH
    [Arguments]    ${command}=${COMMAND_RTWP_HIST}    ${ru_prompt}=#
    Log to RU    ${ru_prompt}
    ${write_output}=    SSHLibrary.Write    ${command}
    ${output}=    SSHLibrary.Read until    ${ru_prompt}
    Log    awk output: ${output}
    ${rtwp_dict}=    python_keywords.Parse RTWP dict from awk output    ${output}
    Log    rtwp_dict: ${rtwp_dict}
    [Return]    ${rtwp_dict}

Wait for cells to be OnAir with timeout
    [Arguments]    ${timeout}=15min
    [Timeout]    ${timeout}
    python_keywords.Wait for radio units to be online
    python_keywords.Wait for cells to be OnAir

Reset RUs and wait for cells to be OnAir
    python_keywords.Reset radio units
    python_keywords.Wait for radio units to be online
    python_keywords.Wait for cells to be OnAir

Gather all RUs IP addresses
    [Arguments]    ${serial_number}
    ${found_ip}=    RuOp.Get RMOD IP address       serial_number=${serial_number}
    Set test variable    ${ru_ip}  ${found_ip}
    [Return]    ${found_ip}

Gather IP set variables
    [Arguments]    ${id_ru}    ${sn_ru}    ${password_ru}    ${user_ru}
    RuOp.Wait for radio unit to be online    ru_id=${id_ru}
    Set test variable    ${serial_number}    ${sn_ru}
    Set test variable    ${password}    ${password_ru}
    Set test variable    ${user}    ${user_ru}
    ${ru_ip}=    Gather all RUs IP addresses    ${serial_number}

Log to RU
    [Arguments]    ${ru_prompt}=#
    Connect to BTS
    Connect to RU    ru_prompt=${ru_prompt}

Connect to BTS
    SSHLibrary.Open connection    timeout=30s    width=175    host=${gnb_ip}
    SSHLibrary.Login    username=${user_gnb}    password=${password_gnb}

Connect to RU
    [Arguments]
    ...              ${user}=${user}
    ...              ${password}=${password}
    ...              ${ru_ip}=${ru_ip}
    ...              ${ru_prompt}=#
    SSHLibrary.Write    text=lxc-attach -n 0x1018
    SSHLibrary.Read until    expected=root@FHNET00:~ >
    SSHLibrary.Write    text=ssh-keygen -f /user/toor4nsn/.ssh/known_hosts -R "${ru_ip}"
    SSHLibrary.Write    text=ssh ${user}@${ru_ip}
    ${continue}=    Run keyword and return status    SSHLibrary.Read until    expected=(yes/no/[fingerprint])?
    IF    '${user}' == 'serviceuser'
        Run keyword if    ${continue}    SSHLibrary.Write    text=yes
        ...    ELSE    SSHLibrary.Write    text=wrong_password
        SSHLibrary.Read until    expected=password:
        SSHLibrary.Write    text=${password}
    ELSE IF     '${user}' == 'root'
        Run keyword if    ${continue}    SSHLibrary.Write    text=yes
    END
    SSHLibrary.Read until    expected=${ru_prompt}

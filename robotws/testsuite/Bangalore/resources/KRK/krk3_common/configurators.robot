*** Settings ***
Documentation
...            Keywords for modifying and uploading configuration files
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Library    OperatingSystem
Library    Process
Library    String
Library    DateTime
Library    os
Library    ute_fsmaccess
Library    ta5g_iphy
Library    ta5g_commissioning
Library    taf.transport.ssh           WITH NAME    ssh
Library    taf.config.wts              WITH NAME    wtscfg

Resource    remote.robot

*** Keywords ***
Import TL Variables
    [Documentation]    Imports TL configuration file from testline_configuration directory.
    ${uname}    os.Uname
    ${tl_name}    Replace String    ${uname.nodename}    -    _
    ${filepath}    Set Variable    /home/ute/testline_configuration/${tl_name}/__init__.py
    Log to Console    Importing TL config file for ${tl_name}
    File Should Exist    ${filepath}
    Import Variables    ${filepath}
    Variable Should Exist    ${tl}

Check If Egate Is Running
    [Documentation]    Checks if egate is running and returns bool.
    ${result}    Run Process    pgrep    'egate'    shell=${True}
    ${running}    Set Variable If    ${result.rc} == 0    ${True}    ${False}
    [Return]    ${running}

Check If MCShark Is Installed
    [Documentation]    Prints warning if MCShark plugin is not installed on TL and returns bool status.
    ${result}    Run Process    tshark    -G    plugins    |    grep    mcshark    shell=${True}
    ${pass}    Evaluate    not bool(${result.rc})
#    Run Keyword Unless    ${pass}
    ...    Log    MCShark plugin is not installed on TL. Decoding of SYSCOM/BIP messages is not possible.
    ...    level=WARN
    [Return]    ${pass}

Fix and Upload iphy
    [Documentation]    Aligns IPHY file with GNB build and uploads it to AP.
    ...                Reboot is required to apply new IPHY config.
    ...                - ``iphy``: Pathfile to iphy.xml
    [Arguments]    ${iphy}
    File Should Exist    ${iphy}
    Log to Console    Uploading new iphy config: ${iphy}
    ta5g_iphy.update_and_put_iphy_xml    input_filepath=${iphy}

Reboot AP Via Ssh
    ssh.connect to
    ...    hostname=${tl.ues[0].l1.common_units[0].lmp_connection.addr}
    ...    username=${tl.ues[0].l1.common_units[0].lmp_connection.username}
    ...    password=${tl.ues[0].l1.common_units[0].lmp_connection.password}
    ...    alias=Airphone
    ssh.send_command    system-module-reboot    connection=Airphone
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=Airphone

Add IP Addresses To Local Interfaces
    [Documentation]    Adds IPv4 addresses on specified local interfaces
    ...                - ``addr_list``: List of addresses with format interface:address/mask
    ...                - ``ignore_existing``: Flag to ignore error from already exisitng address, Default: yes
    ...                - ``silent``: Flag to omit console logs, Default: no
    ...                Example:
    ...                | Add IP Addresses To Local Interfaces | eth3:10.0.1.3/24 | eth3:10.0.1.4/24 |
    [Arguments]    @{addr_list}    ${ignore_existing}=yes    ${silent}=no
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${ignore_existing}' in ('yes','no')    msg=Invalid KW parameter: ignore_existing
    Should Be True    '${silent}' in ('yes','no')    msg=Invalid KW parameter: silent
    #---------------------------------------------------------------------------------------------------------------
    FOR    ${item}    IN    @{addr_list}
      ${match}    ${dev}    ${addr}    @{others}    ${mask}    Should Match Regexp
      ...    ${item}    ^(\\w+):(((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4})/(3[0-2]|[12][0-9]|[1-9])$
      ...    msg=Invalid Interface or IP Address: ${item}
      Run Keyword If    '${silent}' == 'no'    Log to Console    Adding IP address ${addr}/${mask} on ${dev}
      ${result}    Run Process    sudo    ip    addr    add    ${addr}/${mask}    dev    ${dev}
      ${msg}    Set Variable    Error adding IP address.${\n}stdout: ${result.stdout}${\n}stderr: ${result.stderr}
      ${expected_rc}    Set Variable If    '${ignore_existing}' == 'yes'    [0,2]    [0]
      Run Keyword If    ${result.rc} not in ${expected_rc}    Log    ${msg}    level=ERROR
    END

Add Simulated GNB to WTS Config
    [Documentation]    Creates a new WTS config file in specified path by adding Simulated GNB from delta file
    ...                and setting External GNB RAN ID to 0x01 and Xn-Link address.
    ...                Delta is inserted after set_uec command in input WTS config.
    ...                - ``wts_delta``: Filepath to WTS config delta with Sim GNB
    ...                - ``wts_out``: Filepath to new WTS config that will be created
    ...                - ``wts_in``: Filepath to input WTS config, Default: basic_setup.cfg
    [Arguments]    ${wts_delta}    ${wts_out}    ${wts_in}=/opt/wts/latest/basic_setup.cfg
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${wts_in}
    File Should Exist    ${wts_delta}
    #---------------------------------------------------------------------------------------------------------------
    ${delta_content}    Get File    ${wts_delta}
    @{lines}    Split To Lines    ${delta_content}
    wtscfg.load_wts_cfg    ${wts_in}
    ${previous_line}    Set Variable    set_uec id=1
    FOR    ${line}    IN    @{lines}
      wtscfg.insert    ${line}    after    ${previous_line}
      ${previous_line}    Set Variable    ${line}
    END
    wtscfg.modify    command=set_gnb id=2    modification=gnb_id=0x01 xn=$GNB_NG_ADDR
    Create File    ${wts_out}    ${Empty}
    wtscfg.save_wts_cfg    ${wts_out}

Get VM External IP
    [Documentation]    Returns external IP address of TL VM.
    ${result}    Run Process And Expect Success    ip    address    show    dev    eth0
    ${match}    ${ip}    Should Match Regexp    ${result.stdout}    (\\d+\\.\\d+\\.\\d+\\.\\d+)/\\d+
    ...    msg=Failed to read VM external IP address.
    [Return]    ${ip}

Install nsetapx Plugin
    [Documentation]    OBSOLETE. Will be removed in the future.
    [Arguments]    ${version}=1.7.2
    ${installer_file}    Set Variable    install_wslte_plugins.bash
    ${installer_path}    Set Variable    /home/ute/${installer_file}
    ${installer_link}    Catenate    SEPARATOR=
    ...    http://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/tools/
    ...    ${installer_file}
    ${result}    Run Process    tshark    -G    plugins    |    grep    nsetapx    shell=True
    Run Keyword If    ${result.rc} == 0    Run Keywords
    ...    Log to Console    NSETAP-X plugin already installed. Skipping installation.
    ...    AND    Return From Keyword
    Download File with WGET    link=${installer_link}    local_path=${installer_path}    exec=yes
    Log to Console    Installing NSETAP-X ${version} plugin...    no_newline=${True}
    ${result}    Run Process And Expect Success    ${installer_path}    --nsetapx    ${version}
    ...    msg=Error installing NSETAP-X plugin
    Should Contain    ${result.stdout}    INSTALL SUCCESS    msg=Unsuccessful NSETAP-X plugin installation.
    Log to Console    Done

Install DCAP
    [Documentation]    OBSOLETE. Will be removed in the future.
    [Arguments]    ${version}=FB2302.2
    ${installer_file}    Set Variable    dcap_basic_installer.${version}.sh
    ${installer_path}    Set Variable    /home/ute/${installer_file}
    ${installer_link}    Catenate    SEPARATOR=
    ...    https://artifactory-espoo2.int.net.nokia.com/artifactory/dcap-lite-binaries-local/dcap-basic/releases/
    ...    ${version}/${installer_file}
    ${result}    Run Process    which    DCAP_Basic_controller    shell=True
    Run Keyword And Return If    ${result.rc} == 0
    ...    Log to Console    DCAP Basic already installed. Skipping installation.
    Download File with WGET    link=${installer_link}    local_path=${installer_path}
    Run Process And Expect Success    sudo    rm    -rf    /var/lib/docker
    ...    &&    sudo    ln    -s    /home/docker/    /var/lib/docker
    ...    msg=Error configuring symbolic link
    ${ip}    Get VM External IP
    Log To Console    Installing DCAP ${version}...    no_newline=${True}
    ${result}    Run Process And Expect Success    sudo    UTE_CLOUD\=1    bash    ${installer_path}    ${ip}
    ...    msg=Error installing DCAP
    Should Match    ${result.stdout}    *SUCCESS: DCAP Basic*installed*    msg=Unsuccessful DCAP installation.
    Log to Console    Done

DCAP Basic Control
    [Documentation]    Controls DCAP Basic service.
    ...                - ``action``: start / stop / restart
    [Arguments]    ${action}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${action}' in ('start','stop','restart')    msg=Invalid KW parameter: action
    Run Process And Expect Success    which    DCAP_Basic_controller    msg=DCAP Basic is not installed on VM.
    #---------------------------------------------------------------------------------------------------------------
    ${result}    Run Process    bash    -c    echo > /dev/tcp/localhost/9443    shell=True
    ${dcap_running}    Set Variable If    ${result.rc} == 0    ${True}    ${False}
    Run Keyword And Return If    '${action}' == 'start' and ${dcap_running}
    ...    Log to Console    DCAP Basic already running. Skipping start.
    Run Keyword And Return If    '${action}' == 'stop' and not ${dcap_running}
    ...    Log to Console    DCAP Basic already stopped. Skipping stop.
    ${params}    Create List
    Run Keyword If    '${action}' in ('start','restart')    Append To List    ${params}    --wait
    ${msg}    Create Dictionary    start=Starting    stop=Stopping    restart=Restarting
    Log To Console    ${msg}[${action}] DCAP Basic...    no_newline=${True}
    Run Process And Expect Success    sudo    DCAP_Basic_controller    ${action}    @{params}
    Log To Console    OK

Calculate Config Files Checksum
    [Documentation]    Calculates the checksums of UTE config files so they can be compared between test runs.
    ...                - ``log_dir``: Path to directory for output file with checksums. Name of the file\
    ...                contains the total checksum of its content. Default: $/{OUTPUT DIR/}
    [Arguments]    ${log_dir}=${OUTPUT DIR}
    ${temp}    Set Variable    /tmp/ute_config_checksums.txt
    ${dir_agent_sim}    Set Variable    /home/ute/testline_init_results/configs/common/
    ${dir_ute_ca}       Set Variable    /home/ute/testline_init_results/execution/configs/topology_configs/
    ${is_agent_sim}    Run Keyword And Return Status    Directory Should Exist    ${dir_agent_sim}
    ${is_ute_ca}       Run Keyword And Return Status    Directory Should Exist    ${dir_ute_ca}
    Run Keyword If    ${is_agent_sim}
    ...    Run Process And Expect Success    find    ${dir_agent_sim}    -type    f    -exec    sha1sum    {}    \\;
    ...    stdout=${temp}
    ...    ELSE IF    ${is_ute_ca}
    ...    Run Process And Expect Success    find    ${dir_ute_ca}    -type    f    -name    *.bck
    ...    -exec    sha1sum    {}    \\;    stdout=${temp}
    ...    ELSE    Run Keyword And Return
    ...    Log    Unknown UTE agent, unable to find UTE config files.    level=WARN
    ${result}    Run Process And Expect Success    sha1sum    ${temp}    |    cut    -d    ${SPACE}    -f    1
    Copy File    ${temp}    ${log_dir}/ute_config_checksums_${result.stdout}.txt
    Log to Console    UTE Config files checksum: ${result.stdout}

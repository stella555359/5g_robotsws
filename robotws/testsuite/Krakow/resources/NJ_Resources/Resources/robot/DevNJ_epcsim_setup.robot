*** Settings ***
Documentation      This file contains keywords related to setup of EPCSim.

Library    OperatingSystem
Library    String
Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.epcsim                   WITH NAME    epc
Library    ../python/EPCSimCfg.py    WITH NAME    EPCSimCfg

*** Variables ***
${EPCSIM SETUP CONFIRMATION}   SimMode is ready now

*** Keywords ***
Setup EPCSim
    ${sgw_status}  Set Variable  null
    ${pgw_status}  Set Variable  null
    ${sa}=    Run Keyword And Return Status    Should Contain    ${tl.tl_cloud_topology}    _SA
    Return From Keyword If    ${sa}==True

    Log To Console    NSA testline, preparing epcsim...
    ${epcsim host ip}=          Set Variable     ${tl.core.default_ssh_connection_details.addr}
    ${epcsim host username}=    Set Variable     ${tl.core.default_ssh_connection_details.username}
    ${epcsim host password}=    Set Variable     ${tl.core.default_ssh_connection_details.password}
    ${egate port}=              Set Variable     ${tl.core.egate_port}
    ${epcsim directory}=        Set Variable     /opt/core

    ${sgw_status}  ${pgw_status}  Check Epcsim Status
    ...                 ${epcsim host ip}
    ...                 ${epcsim host username}
    ...                 ${epcsim host password}
    ...                 ${egate port}
    ...                 ${epcsim directory}

    Return From Keyword If  'ACTIVE' in '${sgw_status}' and 'ACTIVE' in '${sgw_status}'

    # generate epcsim config file
    ${epcsim config filename}=    EPCSimCfg.Generate Cfg     ${epcsim directory}

    Kill Edaemon And Egate
    ...                 ${epcsim host ip}
    ...                 ${epcsim host username}
    ...                 ${epcsim host password}
    ...                 egate port=${tl.core.egate_port}
    ...                 edaemon port=${tl.core.edaemon_port}
    Start EPCSim        ${epcsim host ip}
    ...                 ${epcsim host username}
    ...                 ${epcsim host password}
    ...                 ${epcsim directory}
    ...                 ${epcsim config filename}
    ...                 ${tl.core.egate_port}
    ...                 ${tl.core.edaemon_port}

Start EPCSim
    [Arguments]         ${hostname}=${tl.core.default_ssh_connection_details.addr}
    ...                 ${username}=${tl.core.default_ssh_connection_details.username}
    ...                 ${password}=${tl.core.default_ssh_connection_details.password}
    ...                 ${epcsim directory}=${tl.core.dir_path}
    ...                 ${epcsim config filename}=${tl.core.cfg_filename}
    ...                 ${egate port}=${tl.core.egate_port}
    ...                 ${edaemon port}=${tl.core.edaemon_port}
    ...                 ${ssh port}=22
    ...                 ${timeout}=500
    Log To Console    preparing epcsim
    ${epcsim_cfg_file}=    Set Variable    ${epcsim directory}/${epcsim config filename}
    Log To Console    epcsim cfg file: ${epcsim_cfg_file}

    epc.Setup Egate     ${egate port}
    ...                 ${hostname}
    ...                 tool_dir=${epcsim directory}
    ...                 ssh_user=${username}
    ...                 ssh_pass=${password}
    ...                 ssh_port=${ssh port}
    ...                 ssh_prompt=\$
    ...                 alias=egate
    epc.Setup Edaemon   edaemon_port=${edaemon port}
    ...                 host_ip=${hostname}
    ...                 tool_dir=${epcsim directory}
    ...                 ssh_user=${username}
    ...                 ssh_pass=${password}
    ...                 ssh_port=${ssh port}
    ...                 ssh_prompt=\$
    ...                 alias=edaemon
    epc.Link Edaemons To Egate
    ...                 edaemon
    ...                 alias=egate
    epc.Start Egate Process
    ...                 cfg_file=${epcsim_cfg_file}
    ...                 timeout=${timeout}
    ...                 alias=egate
    epc.Execute Egate Command And Wait For Data
    ...                 cmd=start
    ...                 pass_regexp=${EPCSIM SETUP CONFIRMATION}
    ...                 timeout=${TIMEOUT}
    ...                 alias=egate

Kill Edaemon And Egate
    [Arguments]         ${hostname}
    ...                 ${username}
    ...                 ${password}
    ssh.Connect To      hostname=${hostname}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=epcsim
    ssh.Execute         sudo pkill edaemon
    ...                 connection=epcsim
    ssh.Execute         pkill egate
    ...                 connection=epcsim

Check Epcsim Status
    [Arguments]         ${hostname}
    ...                 ${username}
    ...                 ${password}
    ...                 ${egate port}
    ...                 ${dir_path}

    ssh.Connect To      hostname=${hostname}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=egate_20000
    ${egate_status}  ssh.Execute   ps -ef|grep egate|grep port|grep ${egate port}  connection=egate_20000
    ssh.Disconnect   connection=egate_20000

    ${egate_status}  Get Regexp Matches  ${egate_status}  egate --port ${egate port}
    ${length}  Get Length  ${egate_status}
    Return From Keyword If  ${length}==${0}


    epc.setup_egate      egate_port=${egate port}
    ...                  host_ip=${hostname}
    ...                  tool_dir=${dir_path}
    ...                  alias=egate

    ${psgw_status}  epc.execute egate command and wait for data  cmd=disp_state  alias=egate
    epc.teardown_egate  alias=egate
    Log to console      ${psgw_status}
    ${sgw_status}   Get Regexp Matches  ${psgw_status}  SGW.+\\s+(?P<status>[A-Za-z]+\\s)  status
    ${pgw_status}   Get Regexp Matches  ${psgw_status}  PGW.+\\s+(?P<status>[A-Za-z]+\\s)  status
    [return]  ${sgw_status[0]}  ${pgw_status[0]}

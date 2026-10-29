*** Settings ***
Documentation      This file contains keywords related to setup of EPCSim.

Library    taf.transport.ssh   WITH NAME    ssh
Library    taf.epcsim          WITH NAME    epc


*** Variables ***
${EPCSIM SETUP CONFIRMATION}   S1 link is Up

*** Keywords ***
Setup EPCsim
    [Arguments]         ${epcsim host ip}=${tl.core.default_ssh_connection_details.addr}
    ...                 ${epcsim host username}=${tl.core.default_ssh_connection_details.username}
    ...                 ${epcsim host password}=${tl.core.default_ssh_connection_details.password}
    ...                 ${epcsim directory}=${tl.core.dir_path}
    ...                 ${epcsim config filename}=${tl.core.cfg_filename}
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
    ...                 cfg_file=${epcsim directory}/${epcsim config filename}
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
    ...                 ${egate port}
    ...                 ${edaemon port}
    ssh.Connect To      hostname=${hostname}
    ...                 username=${username}
    ...                 password=${password}
    ...                 alias=epcsim
    ssh.Execute         fuser -k ${edaemon port}/tcp
    ...                 connection=epcsim
    ssh.Execute         fuser -k ${egate port}/tcp
    ...                 connection=epcsim

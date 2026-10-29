*** Settings ***
Documentation
...    author: xiaodan.li
...    contact: xiaodan.li@nokia-sbell.com
...    squad group: SG_03
...    this kw using for epc_sim testing


Library           taf.epcsim    WITH NAME    epc
Library           taf.transport.ssh    WITH NAME    csn

*** Variables ***


*** Keywords ***
restart process and send cfg cmd on telnet port
    [Arguments]    ${alias}=UEC
    Restart UEC Edaemon
    Start Edaemon
    Start Egate
   [Teardown]     csn.disconnect    connection=${alias}

Start Edaemon
    [Arguments]    ${edaemon_host}=${tl.core.default_ssh_connection_details.addr}
	...            ${edaemon_path}=${tl.core.dir_path}
	...            ${egate_pass}=${tl.core.default_ssh_connection_details.password}
    epc.setup_edaemon    edaemon_port=22222    host_ip=${edaemon_host}    tool_dir=${edaemon_path}
    ...                  alias=EDAEMON    ssh_pass=${egate_pass}
    epc.start_edaemon_process    alias=EDAEMON

Start Egate
    [Arguments]    ${egate_host}=${tl.core.default_ssh_connection_details.addr}
	...            ${egate_path}=${tl.core.dir_path}
    ...	           ${cfg_file}=${tl.core.cfg_filename}
    ...            ${egate_pass}=${tl.core.default_ssh_connection_details.password}
    epc.setup egate    egate_port=20000    host_ip=${egate_host}    tool_dir=${egate_path}    alias=EGATE
    ...     ssh_pass=${egate_pass}
    #epc.Execute egate command    cmd=reset    timeout=30    alias=EGATE
    epc.start egate process    cfg_file=${egate_path}${cfg_file}    timeout=10    alias=EGATE
    sleep    5s
    Log to console    Edeamon and egate starting!\nWait for "S1 link is Up " \nWait for max 600
    epc.Execute egate command                cmd=start
    ...                                      timeout=30
    ...                                      alias=EGATE

send ASI cmd
    [Arguments]    ${egate_host}=${tl.core.default_ssh_connection_details.addr}
	...            ${egate_path}=${tl.core.dir_path}
    ...	           ${cfg_file}=${tl.core.cfg_filename}
    ...            ${egate_pass}=${tl.core.default_ssh_connection_details.password}
    #epc.setup egate    egate_port=20000    host_ip=${egate_host}    tool_dir=${egate_path}    alias=EGATE
    #...     ssh_pass=${egate_pass}
    epc.Execute egate command    cmd=send_amf_status_indication id=1 guami_index=1 backup_amf_index=0 timer_guami_removal=off
    ...                                      timeout=30
    ...                                      alias=EGATE
    epc.Teardown Egate    alias=EGATE
    epc.Teardown Edaemon    alias=EDAEMON

Restart UEC Edaemon
     wait until keyword succeeds    10 min    5 sec    Connect to UEC    alias=UEC
     csn.execute    command=sudo killall edaemon    connection=UEC
     csn.execute    command=killall egate    connection=UEC
     #csn.execute    command=sudo iptables -F    connection=UEC    #delete iptables

Connect to UEC
    [Arguments]    ${alias}=UEC
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=${alias}
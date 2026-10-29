*** Settings ***
Documentation   Keywords for LTEemu

Library         String
Library         Collections
Library         taf.wts.runner        WITH NAME   lteemu
Library         taf.transport.ssh     WITH NAME   ssh
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/utilities.py     WITH NAME   util
Variables       ./x2_variables.py


*** Variables ***
${lteemu_vm_user}      ute
${lteemu_vm_pass}      ute
${edaemon_port}        22222
${egate_port}          10000
${dir_path}            /home/ute/lteemu
@{binaries}            egate  edaemon  sim_enb  sim_mme  sim_pgw  sim_sgw  sim_uec
@{lteemu_ips}          10.35.166.81  10.35.166.82  10.35.166.83  10.35.166.112  10.35.166.116  10.35.166.63
@{lteemu_cfgs}         cfg_lteemu_basic  #cfg_lteemu_enb_id_duplicated  cfg_lteemu_error_indication_from_gnb  cfg_lteemu_home_enb_id
${lteemu_vm_ip}        ${tl.test_pcs[0].default_ssh_connection_details.addr}


*** Keywords ***
Copy binaries and cfg files
    ${short_tl_name}  ${tl_name}   util.get_testline_name
    Run   command=mkdir /home/ute/lteemu/
    FOR  ${b}  IN  @{binaries}
        Run   command=cp /opt/iphy/latest/${b} /home/ute/lteemu/
    END
    FOR  ${ip}  IN  @{lteemu_ips}
        Run   command=sudo ip addr add ${ip}/24 dev eth0
    END
    FOR  ${cfg}  IN  @{lteemu_cfgs}
        Run   command=cp /home/ute/testline_configuration/${tl_name}/lteemu/${cfg}.env /home/ute/lteemu/
        Run   command=mv /home/ute/lteemu/${cfg}.env /home/ute/lteemu/${cfg}.cfg
        Run   command=chmod +x /home/ute/lteemu/${cfg}.cfg
    END


Connect to LTEemu
    [Arguments]    ${address}=${lteemu_vm_ip}
    ...            ${username}=ute
    ...            ${password}=ute
    ...            ${alias}=lteemu
     ssh.Connect To   ${address}  ${username}  ${password}  alias=${alias}


Kill LTEemu edaemon and egate processes
    [Documentation]     This keyword kills existing LTEemu egate and edaemon processes
    [Arguments]    ${connection}=lteemu
    lteemu.kill_wtsemu_edaemon   edaemon_port=${edaemon_port}
    ...                          connection=${connection}
    lteemu.kill_wtsemu_egate     egate_port=${egate_port}
    ...                          connection=${connection}
    ssh.send command   command=rm -rf ${dir_path}/*.log*    connection=${connection}


Start LTEemu edaemon and egate processes
    [Documentation]     This keyword starts LTEemu egate and edaemon processes
    [Arguments]     ${connection}=lteemu

    lteemu.configure_wtsemu_edaemon     edaemon_ssh_alias=${connection}
    ...                                 directory_path=${dir_path}
    ...                                 port=${edaemon_port}

    lteemu.configure_wtsemu_egate       egate_ssh_alias=${connection}
    ...                                 directory_path=${dir_path}
    ...                                 port=${egate_port}

    lteemu.start_wtsemu   egate_console_ip=${lteemu_vm_ip}    egate_port=${egate_port}
    Log To Console   \n <LTEemu edaemon and egate started>


Start LTEemu and load config file
    [Documentation]     This keyword starts LTEemu  and load cfg file in egate cosole
    [Arguments]    ${cfg_file}=cfg_lteemu_basic.cfg
    BuiltIn.Sleep   5s   wait before next session started after previous closed
    lteemu.start_wtsemu   egate_console_ip=${lteemu_vm_ip}  egate_port=${egate_port}
    lteemu.configure      file=${cfg_file}
    lteemu.read_wtsemu_output_until    expected=CHANGE STATE: ACTIVE   timeout=30
    Log To Console   \n <LTEemu is running>


Setup LTEemu environment
    [Documentation]     This keyword will setup the LTEemu environment
    Copy binaries and cfg files
    Connect to LTEemu
    Kill LTEemu edaemon and egate processes
    Start LTEemu edaemon and egate processes


Stop LTEemu processes
    [Documentation]   This keyword stops every software component of Lteemu
    lteemu.reset_wtsemu_cfg
    lteemu.read_wtsemu_output_until    expected=CHANGE STATE: INIT   timeout=30
    Log To Console   \n <LTEemu stopped>
    BuiltIn.Sleep   5s   wait for alarm activation


Setup X2AP Link successfully
    [Documentation]    Setup X2 link
    [Arguments]    ${enb_id}=1  ${gnb_id}=2
    lteemu.enb_x2_link_up    enb=${enb_id}  target=${gnb_id}
    lteemu.read_wtsemu_output_until_re    expected=X2AP Link with GNB-${gnb_id}.* is up   timeout=10
    Log To Console   \n <x2 link is up>


Setup X2AP Link Failure
    [Arguments]    ${enb_id}=1  ${gnb_id}=4
    lteemu.enb_x2_link_up    enb=${enb_id}  target=${gnb_id}
    lteemu.read_wtsemu_output_until_re    expected=EN-DC X2 Setup Failure recvd from GNB-4.*   timeout=10
    Log To Console   X2 link setup failure!


Set response with error for EN-DC Configuration Update
    [Arguments]    ${error_message}  ${enb_id}=1  ${gnb_id}=4
    lteemu.link_x2_management_abnormal_cases   id=${enb_id}  partner=${gnb_id}  endc_cfg_update_rsp=${error_message}


Setup X2AP Link Error Indication
    [Arguments]    ${enb_id}=1  ${gnb_id}=4
    lteemu.enb_x2_link_up    enb=${enb_id}  target=${gnb_id}
    lteemu.read_wtsemu_output_until_re    expected=Unexpected x2ap::ErrorIndication message.*   timeout=30
    Log To Console   X2 link setup failed - error indication received from gnb!


Setup SCTP Connection Only
    [Arguments]    ${enb_id}=1  ${gnb_id}=4
    lteemu.enb_param    id=${enb_id}  send_x2_setup=off
    lteemu.enb_x2_link_up    enb=${enb_id}  target=${gnb_id}
    BuiltIn.Sleep   5s


Setup X2AP Links Simultaneously
    [Arguments]    ${enbs_number}=2  ${gnb_id}=4
    FOR  ${enb_id}  IN RANGE  ${enbs_number}
        lteemu.enb_x2_link_up    enb=${enb_id+1}  target=${gnb_id}
    END


Setup X2AP After Time
    [Arguments]    ${enb_id}=1  ${gnb_id}=4
    lteemu.enb_param    id=${enb_id}  send_x2_setup=on
    lteemu.read_wtsemu_output_until_re    expected=X2AP Link with GNB-${gnb_id}.* is up   timeout=10
    Log To Console   X2 link is up!

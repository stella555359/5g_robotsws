*** Settings ***
Library           taf.transport.ssh    WITH NAME    ssh
Library           taf.gnb.oam.coam.admin    WITH NAME    admin
Library           ute_wtssim
Library           taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library           Collections
Library           DateTime
Library           OperatingSystem
Library           Telnet
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           taf.lteemu           WITH NAME    lteemu

*** Variables ***
${ABIL_MASTER}    192.168.253.20
${ABIL_SLAVE}     192.168.253.21
${AP_HOST}        ${tl.ues[0].airphone_cloud.oam_ssh_connection_details.addr}
${AP_USER}        ${tl.ues[0].airphone_cloud.oam_ssh_connection_details.username}
${AP_PWD}         ${tl.ues[0].airphone_cloud.oam_ssh_connection_details.password}
${DL_PORT}        7070
${UL_PORT}        7071
${DU_HOST}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${DU_USER}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_PWD}         ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${HW_STATUS_CHECK}    export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s -p 15004
${LTE_HOST}       ${tl.core.default_ssh_connection_details.addr}
${LTE_USER}       ${tl.core.default_ssh_connection_details.username}
${LTE_PWD}        ${tl.core.default_ssh_connection_details.password}
${PDU_SESSION_UP}    ue_pdu_session_setup pdu=1 ue=${UE_ID} nwslice=1 gw=1
${PDU_UP_SUCCESS}    Initial Context Setup Successful
${PING_MATCH}     from\\s+[0-9,\.\:]+\\s+[a-z,\_\=]+\\d+\\s+[a-z,\=,0-9]+
${SIB_UPDATED}    SystemInformationBlockType1-NR updated
${UE_REGISTERED}    UE now in NG RM Registered state
${WEBUI_ADDR}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${EPCSIM_CFG}     ${tl.core.cfg_filename}
${UE_ID}          1
${multi_UE_ID}    1,2
${GNB_ID}         2
${CELL_ID}        2
${BEARER_ID}      2
${PROFILE_ID}     1
${iperf_egrep}    egrep -o '[[:digit:]]*.?[[:digit:]]*[[:space:]]Mbits/sec'
${WTS_AVG_INTERVAL}    Average packet interval
${NSA_SIB_UPDATED}    SystemInformationBlockType1 updated
${NSA_X2_UPDATED}    MasterInformationBlock-NR Updated
${basic_wts_dir_path}    ${tl.core.dir_path}
${drx_value}     128

*** Keywords ***
Configure Epcsim to cell onair on SA
    Start Epcsim on WTS
    setup_egate    egate_port=20000    host_ip=${LTE_HOST}
    Execute Egate Command    cmd=cfg file\=${EPCSIM_CFG}    pass_regexp=${SIB_UPDATED}    timeout=450
    sleep    10sec
    [Teardown]    Disconnect WTS And Egate Session

Configure Epcsim to cell onair on NSA
    Start Epcsim on WTS
    ute_wtssim.setup_egate    egate_port=20000    host_ip=${LTE_HOST}
    ute_wtssim.Execute Egate Command    cmd=cfg file\=${EPCSIM_CFG}    pass_regexp=${NSA_SIB_UPDATED}    timeout=450
    sleep    10sec
    Establish X2 Link on NSA
    [Teardown]    Disconnect WTS And Egate Session
    
Configure Epcsim to cell onair on NSA with multi UE
    Start Epcsim on WTS
    ute_wtssim.setup_egate    egate_port=20000    host_ip=${LTE_HOST}
    ute_wtssim.Execute Egate Command    cmd=cfg file\=multi_ue_nsa_call_tdd_above6GHz.lua    timeout=450
    sleep    10sec
    Establish X2 Link on NSA
    [Teardown]    Disconnect WTS And Egate Session

L3 Attach and Traffic on SA
    Connect to WTS
    ute_wtssim.setup_egate    egate_port=20000    host_ip=${LTE_HOST}
    ute_wtssim.Execute Egate Command    cmd=ue_register id\=${UE_ID}    pass_regexp=${UE_REGISTERED}    timeout=150
    BuiltIn.Log    \n UE Attach is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=${PDU_SESSION_UP}    pass_regexp=${PDU_UP_SUCCESS}    timeout=150
    Start DL Traffic within 10sec on SA
    Start UL Traffic within 10sec on SA
    Sleep    10s
    Check Traffic Throughput on iperf Server    DL    5
    BuiltIn.Log    \n DL Traffic is OK \n    console=yes
    Check Traffic Throughput on iperf Server    UL    2
    BuiltIn.Log    \n UL Traffic is OK \n    console=yes
    Stop Traffic in WTS on SA
    BuiltIn.Log    \n UE Traffic is stopped \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_release ue=1 pdu=1    pass_regexp=Successfully released PDU Session
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${UE_ID} ue_deregister_type=switch_off    pass_regexp=detached
    BuiltIn.Log    \n UE Detach is OK \n    console=yes
    Sleep    5s
    [Teardown]    Disconnect WTS And Egate Session

L3 Attach and Traffic on SA with 5GC001808-T002
    Connect to WTS
    ute_wtssim.setup_egate    egate_port=20000    host_ip=${LTE_HOST}
    ute_wtssim.Execute Egate Command    cmd=ue_register id\=${UE_ID}    pass_regexp=${UE_REGISTERED}    timeout=150
    BuiltIn.Log    \n UE Attach is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=${PDU_SESSION_UP}    pass_regexp=${PDU_UP_SUCCESS}    timeout=150
    Start DL Traffic within 10sec on SA with 5GC001808-T002
    Start UL Traffic within 10sec on SA with 5GC001808-T002
    Sleep    5s
    Check Traffic Throughput on iperf Server    DL    5
    BuiltIn.Log    \n DL Traffic is OK \n    console=yes
    Run Keyword And Ignore Error    Check Traffic Throughput on iperf Server    UL    6
    BuiltIn.Log    \n UL Traffic is OK \n    console=yes
    Stop Traffic in WTS on SA
    BuiltIn.Log    \n UE Traffic is stopped \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_release ue=1 pdu=1    pass_regexp=Successfully released PDU Session
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${UE_ID} ue_deregister_type=switch_off    pass_regexp=detached
    BuiltIn.Log    \n UE Detach is OK \n    console=yes
    Sleep    2s
    [Teardown]    Disconnect WTS And Egate Session

L3 Attach and Traffic on SA with paging
    Connect to WTS
    ute_wtssim.setup_egate    egate_port=20000    host_ip=${LTE_HOST}
    Trigger paging from AMF
    ute_wtssim.Execute Egate Command    cmd=ue_register id\=${UE_ID}    pass_regexp=${UE_REGISTERED}    timeout=150
    BuiltIn.Log    \n UE Attach is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=${PDU_SESSION_UP}    pass_regexp=${PDU_UP_SUCCESS}    timeout=150
    Make UE to idle    drx_value=${drx_value}
    Paging from AMF
    Sleep    5s
    [Teardown]    Disconnect WTS And Egate Session

L3 Attach and Traffic on NSA
    ute_wtssim.setup_egate    egate_port=20000    host_ip=${LTE_HOST}
    ute_wtssim.Execute Egate Command    cmd=ue_attach id\=${UE_ID} profile\=${PROFILE_ID}    pass_regexp=UE IS ACTIVE    timeout=300
    BuiltIn.Log    \n UE Attach is OK \n    console=yes
    ${traffic_cmd}    Set Variable    ue_dc_enb_start ue=${UE_ID} target_gnb=${GNB_ID} target_cells=${CELL_ID} bearer=${BEARER_ID} type=split_scg
    ute_wtssim.Execute Egate Command    cmd=${traffic_cmd}    pass_regexp=reported successful RA    timeout=300
    ute_wtssim.Execute Egate Command    cmd=trf_data_start id\=${BEARER_ID} ue\=${UE_ID} trf_id\=1 dir\=dl mbps\=5 seconds\=60
    ute_wtssim.Execute Egate Command    cmd=trf_data_start id\=${BEARER_ID} ue\=${UE_ID} trf_id\=2 dir\=ul mbps\=5 seconds\=60
    Sleep    10s
    Check Traffic on NSA in WTS    dl    5
    Check Traffic on NSA in WTS    ul    5
    BuiltIn.Log    \n UE Traffic is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=ue_detach id\=${UE_ID}    pass_regexp=detached
    BuiltIn.Log    \n UE Detach is OK \n    console=yes

L3 Attach and Traffic on NSA with MAC_PDU TBsize modify
    ute_wtssim.setup_egate    egate_port=20000    host_ip=${LTE_HOST}
    ute_wtssim.Execute Egate Command    cmd=ue_attach id\=${UE_ID} profile\=${PROFILE_ID}    pass_regexp=UE IS ACTIVE    timeout=300
    BuiltIn.Log    \n UE Attach to LTE is OK \n    console=yes
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_dc_enb_start ue\=${UE_ID} target_gnb\=${GNB_ID} target_cells\=${CELL_ID} bearer\=${BEARER_ID} type\=split_scg
    ...    pass_regexp=reported successful RA    timeout=300     
    sleep    3s
    BuiltIn.Log    \n UE Attach to 5g is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=trf_data_start id\=${BEARER_ID} ue\=${UE_ID} trf_id\=1 dir\=dl mbps\=5 seconds\=60
    #ute_wtssim.Execute Egate Command    cmd=trf_data_start id\=${BEARER_ID} ue\=${UE_ID} trf_id\=2 dir\=ul size\=100\:100 mbps\=5 seconds\=60
    ute_wtssim.Execute Egate Command    cmd=trf_data_start id\=${BEARER_ID} ue\=${UE_ID} trf_id\=2 dir\=ul size\=42\:42 mbps\=5 seconds\=60
    Sleep     5s
    Check Traffic on NSA in WTS    dl    5
    Check Traffic on NSA in WTS    ul    5
    BuiltIn.Log    \n UE Traffic is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=ue_detach id\=${UE_ID}    pass_regexp=detached
    BuiltIn.Log    \n UE Detach is OK \n    console=yes

L3 Attach and Traffic on NSA with 7Drbs
    ute_wtssim.setup_egate    egate_port=20000    host_ip=${LTE_HOST}
    ute_wtssim.Execute Egate Command    cmd=ue_eutra_capabilities id\=1 extended_drbs\=on elcid\=on    timeout=300
    ute_wtssim.Execute Egate Command    cmd=ue_attach id\=${UE_ID} profile\=${PROFILE_ID}    pass_regexp=UE IS ACTIVE    timeout=300
    BuiltIn.Log    \n UE Attach to LTE is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=ue_pdn_connect ue\=1 pdn\=2    timeout=300    
    sleep    3s    
    ute_wtssim.Execute Egate Command    
    ...    cmd=ue_dc_enb_start ue\=${UE_ID} target_gnb\=${GNB_ID} target_cells\=${CELL_ID} bearer\=1,2,3,4,5,6,7 type\=split_scg
    ...    pass_regexp=reported successful RA    timeout=200
    BuiltIn.Log    \n UE Attach to 5g is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=trf_data_start id\=1,2,3,4,5,6,7 ue\=${UE_ID} trf_id\=1 dir\=dl mbps\=10 seconds\=60
    ute_wtssim.Execute Egate Command    cmd=trf_data_start id\=${BEARER_ID} ue\=${UE_ID} trf_id\=2 dir\=ul mbps\=5 seconds\=60
    Sleep     5s
    Check Traffic on NSA in WTS for 7 drbs    dl    10
    Check Traffic on NSA in WTS    ul    5
    BuiltIn.Log    \n UE Traffic is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=ue_detach id\=${UE_ID}    pass_regexp=detached
    BuiltIn.Log    \n UE Detach is OK \n    console=yes

L3 Attach and Traffic on NSA with multi UE
    ute_wtssim.setup_egate    egate_port=20000    host_ip=${LTE_HOST}   
    ute_wtssim.Execute Egate Command    cmd=ue_attach id\=${multi_UE_ID} profile\=${PROFILE_ID}    pass_regexp=UE IS ACTIVE    timeout=300
    BuiltIn.Log    \n UE Attach to LTE is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=script file\=${basic_wts_dir_path}multi_ue_script.lua entry\=sgnb_addition_multi_ue\(2,2,2,2\)
    ...    pass_regexp=reported successful RA    timeout=200
    BuiltIn.Log    \n UE Attach to 5g is OK \n    console=yes
    sleep    10s
    ute_wtssim.Execute Egate Command    
    ...    cmd=script file=${basic_wts_dir_path}multi_ue_script.lua entry\=start_ul_dl_traffic_multi_ue\(2,2,5000000,150000000,5000000,150000000\)
    Sleep    10s    
    Check DL Traffic on NSA in WTS for multi UE    dl    5
    Check UL Traffic on NSA in WTS for multi UE    ul    5
    BuiltIn.Log    \n UE Traffic is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=ue_detach id\=${UE_ID}    pass_regexp=detached
    BuiltIn.Log    \n UE Detach is OK \n    console=yes

Trigger paging from AMF
    BuiltIn.Log    begin to trigger paging from AMF

Get Current SCF file
    [Arguments]    ${dir}    ${file_name}=old_scf.xml    ${timeout}=600s    ${connection}=cOAM
    ${file}    coam.get_current_scf_file    local_dir_path=${dir}    file_name=${file_name}    timeout=${timeout}    connection=${connection}
    [Return]    ${file}

Make UE to idle
    [Arguments]    ${amf_id}=1    ${drx_value}=128
    BuiltIn.Log    NAS normal release in progress
    ute_wtssim.Execute Egate Command    cmd=amf_paging_param id\=1 default_drx=${drx_value} max_paging_retries\=1
    BuiltIn.Sleep   2s
    ute_wtssim.Execute Egate Command    cmd=ue_ng_ctx_release id\=1 cause\=NAS_normal_release    pass_regexp=UE Context Release Complete

Paging from AMF
    BuiltIn.Log    Start to paging
    ute_wtssim.Execute Egate Command    cmd=amf_paging_start id\=1 ue\=1
#   pass_regexp=Bearer-type change from MCG to SCG-split is successful
    BuiltIn.Sleep   10s

Start Epcsim on WTS
    Connect to WTS
    ${execute_info}    ssh.execute    cd ${tl.core.dir_path}; sudo ./edaemon --port ${tl.core.edaemon_port}    connection=WTS
    sleep    1s
    FOR    ${var}    IN RANGE    10
        ${execute_info}    ssh.execute    cd ${tl.core.dir_path}; ./egate --port ${tl.core.egate_port}    connection=WTS
        sleep    1s
        ${ps_egate_info}    ssh.execute    ps -ef | grep egate | grep -v grep    connection=WTS
        ${run_result}    ${error}    run keyword and ignore error    should contain    ${ps_egate_info}    egate
        exit for loop if    '${run_result}'=='PASS'
    END
    should contain    ${run_result}    PASS
    [Teardown]    Disconnect WTS And Egate Session

Check gNB State is Onair
    Connect to gnb coam via ssl
    COAM Check GNB cell on air

Get gNB Cell Status
    Connect to gnb coam via ssl
    ${bts_status}    coam.get_bts_statuses    connection=GNB_OAM
    ${result}    Set variable    ${bts_status['proceduralState']}
    [Return]    ${result}

Check gNB F1 State is Successfully
    ssh.connect to    hostname=${DU_HOST}    username=${DU_USER}    password=${DU_PWD}    alias=gNB_ASIK
    FOR    ${var}    IN RANGE    40
        ssh.send_command    rm startup_cp_rt.log    connection=gNB_ASIK
        ssh.send_command    bget 0\:1 /tmp/node_CPRT00/tmp/startup_cp_rt.log /tmp/    connection=gNB_ASIK
        ${match_f1_info}    ssh.execute    command=cat /tmp/startup_cp_rt.log | grep "F1 setup"    connection=gNB_ASIK
        ${matchh_result}    ${error}    run keyword and ignore error    should contain    ${match_f1_info}    successfully
        exit for loop if    '${matchh_result}'=='PASS'
        sleep    10sec
    END
    should contain    ${match_f1_info}    successfully    F1 link is not up
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=gNB_ASIK

Check gNB HW Status is up
    ssh.connect to    hostname=${DU_HOST}    username=${DU_USER}    password=${DU_PWD}    alias=gNB_ASIK
    FOR    ${var}    IN RANGE    45
        ${result_list}    create list
        ${match_HW_info}    ssh.execute    ${HW_STATUS_CHECK}    connection=gNB_ASIK
        ${match_result}    ${match_info}    run keyword and ignore error    should match regexp    ${match_HW_info}    FSM1\_FCT\\s+([a-z]+)
        ${contain_result}    ${error}    run keyword and ignore error    should contain    ${match_info[-1]}    ready
        Append To List    ${result_list}    ${contain_result}
        ${match_result}    ${match_info}    run keyword and ignore error    should match regexp    ${match_HW_info}    FSM1\_FSP1\\s+([a-z]+)
        ${contain_result}    ${error}    run keyword and ignore error    should contain    ${match_info[-1]}    ready
        Append To List    ${result_list}    ${contain_result}
        ${HW_state_result}    ${error}    run keyword and ignore error    should not contain    ${result_list}    FAIL
        exit for loop if    '${HW_state_result}'=='PASS'
        sleep    10
    END
    should not contain    ${result_list}    FAIL
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=gNB_ASIK

Check Traffic in gNB ABIL Master
    ssh.connect to    hostname=${DU_HOST}    username=${DU_USER}    password=${DU_PWD}    alias=gNB_ASIK
    ssh.connect to    hostname=${ABIL_MASTER}    username=${DU_USER}    password=${DU_PWD}    proxy=gNB_ASIK    alias=ABIL_Matser
    ${date_info}    ssh.execute    date    connection=ABIL_Matser
    ${time_info}    should match regexp    ${date_info}    [0-9,\\:]{8}
    sleep    5s
    ${journalctl_info}    ssh.execute    journalctl --since ${time_info} | grep -i TBS    connection=ABIL_Matser
    ${match_result}    ${DL_data_info}    should match regexp    ${journalctl_info}    DataPdu\:\\s+\\S+\\|(\\d+)\]
    ${match_result}    ${UL_data_info}    should match regexp    ${journalctl_info}    UL\:\\s+(\\d+)\\s+Bytes\\s+received
    ${compare_result}    run keyword if    ${DL_data_info}>300000 and ${UL_data_info}>300000    set variable    PASS
    ...    ELSE    set variable    FAIL
    should contain    ${compare_result}    PASS
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=ABIL_Master

Connect to WTS
    ssh.connect to    hostname=${LTE_HOST}    username=${LTE_USER}    password=${LTE_PWD}    alias=WTS

Disconnect WTS And Egate Session
    Run Keyword And Ignore Error    teardown_egate
    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Login Page Via WebUI
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${WEBUI_ADDR}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Reboot gNB Via WebUI
    Login Page Via WebUI
    selenium_coam.reset_site
    [Teardown]    selenium_coam.logout

Reboot gNB Via Ssh
    ssh.connect to    hostname=${DU_HOST}    username=${DU_USER}    password=${DU_PWD}    alias=gNB_ASIK
    ssh.send_command    reboot    connection=gNB_ASIK
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=gNB_ASIK

Reboot WTS Via Ssh
    Connect to WTS
    ssh.send_command    sudo reboot    connection=WTS
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Reboot AP Via Ssh
    ssh.connect to    hostname=${AP_HOST}    username=${AP_USER}    password=${AP_PWD}    alias=Airphone
    ssh.send_command    reboot    connection=Airphone
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=Airphone

Reboot Testline And Make Sure HW is up
    Reboot gNB Via WebUI
    Reboot AP Via Ssh
    Reboot WTS Via Ssh
    sleep    150sec
    Run Keyword And Ignore Error    ssh.disconnect    connection=gNB_ASIK
    FOR    ${var}    IN RANGE    40
        ${ping_info}    run    ping -c 5 ${DU_HOST}
        ${run_result}    ${error}    run keyword and ignore error    should match regexp    ${ping_info}    ${PING_MATCH}
        exit for loop if    '${run_result}'=='PASS'
        sleep    10
    END
    Check gNB HW Status is up

Save Snapshot
    [Arguments]    ${alias}=cOAM    ${timeout}=15 min
    Create cOAM session with alias
    ${sw_id}=    Get Software Version    alias=cOAM
    ${snapshot_path}=    set variable    ${OUTPUT_DIR}/Snapshot_${sw_id}.zip
    admin.get_snapshot    target_file_name=${snapshot_path}    timeout=${timeout}    connection=cOAM
    [Teardown]    Teardown cOAM session

Sctp Connect Setting in WTS And Airphone
    [Arguments]    ${sack_timer}
    ssh.connect to    hostname=${AP_HOST}    username=${AP_USER}    password=${AP_PWD}    alias=Airphone
    ssh.execute    command=sysctl -w net.sctp.sack_timeout=${sack_timer};sysctl -w net.sctp.rto_min=200    connection=Airphone
    sleep    1s
    ssh.execute    command=sysctl -w sysctl -w net.sctp.rto_initial=200;sysctl -w net.sctp.rto_max=800    connection=Airphone
    Run Keyword And Ignore Error    ssh.Disconnect    connection=Airphone
    Connect to WTS
    ${info_tmp}    ssh.execute    command=sudo sysctl -w net.sctp.sack_timeout=${sack_timer};sudo sysctl -w net.sctp.rto_min=200    connection=WTS
    sleep    1s
    ${info_tmp}    ssh.execute    command=sudo sysctl -w sysctl -w net.sctp.rto_initial=200;sudo sysctl -w net.sctp.rto_max=800    connection=WTS
    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Start DL Traffic within 10sec on SA
    Connect to WTS
    ${cfg_info}    ssh.execute    command=cat ${tl.core.dir_path}/${tl.core.cfg_filename} \| grep \"UPF_ADDR\=\"    connection=WTS
    ${upf_match_list}    ${upf_match_info}    should match regexp    ${cfg_info}    ([0-9,\.]+)\.\\d
    ssh.send_command    nohup iperf -s -u -p ${DL_PORT} -i 1 -B 192.168.6.121 > \ /tmp/iperf_DL.txt    connection=WTS
    ssh.send_command    nohup iperf -c ${upf_match_info}.2 -u -p ${DL_PORT} -l 1400 -b 5M -i 1 -t 10 2>&1 &    connection=WTS
    BuiltIn.Log    Running DL Traffic for 10sec    console=yes
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Start DL Traffic within 10sec on SA with 5GC001808-T002
    Connect to WTS
    ${cfg_info}    ssh.execute    command=cat ${tl.core.dir_path}/${tl.core.cfg_filename} \| grep \"UPF_ADDR\=\"    connection=WTS
    ${upf_match_list}    ${upf_match_info}    should match regexp    ${cfg_info}    ([0-9,\.]+)\.\\d
    ssh.send_command    nohup iperf -s -u -p ${DL_PORT} -i 1 -B 192.168.6.121 > \ /tmp/iperf_DL.txt    connection=WTS
    ssh.send_command    nohup iperf -c ${upf_match_info}.2 -u -p ${DL_PORT} -l 100 -b 5M -i 1 -t 10 2>&1 &    connection=WTS
    BuiltIn.Log    Running DL Traffic for 10sec    console=yes
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Start UL Traffic within 10sec on SA
    Connect to WTS
    ${cfg_info}    ssh.execute    command=cat ${tl.core.dir_path}/${tl.core.cfg_filename} \| grep \"ue_nat_ip\=\"    connection=WTS
    ${upf_match_list}    ${upf_match_info}    should match regexp    ${cfg_info}    ue\_nat\_ip\=([0-9,\.]+)\\s+
    ssh.send_command    nohup iperf -s -u -p ${UL_PORT} -i 1 -B 192.168.6.121 > /tmp/iperf_UL.txt    connection=WTS
    ssh.send_command    nohup iperf -c ${upf_match_info} -u -p ${UL_PORT} -l 1400 -b 2M -i 1 -t 10 2>&1 &    connection=WTS
    BuiltIn.Log    Running UL Traffic for 10sec    console=yes
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS
Start UL Traffic within 10sec on SA with 5GC001808-T002
    Connect to WTS
    ${cfg_info}    ssh.execute    command=cat ${tl.core.dir_path}/${tl.core.cfg_filename} \| grep \"ue_nat_ip\=\"    connection=WTS
    ${upf_match_list}    ${upf_match_info}    should match regexp    ${cfg_info}    ue\_nat\_ip\=([0-9,\.]+)\\s+
    ssh.send_command    nohup iperf -s -u -p ${UL_PORT} -i 1 -B 192.168.6.121 > /tmp/iperf_UL.txt    connection=WTS
    ssh.send_command    nohup iperf -c ${upf_match_info} -u -p ${UL_PORT} -l 100 -b 50M -i 1 -t 10 2>&1 &    connection=WTS
    BuiltIn.Log    Running UL Traffic for 10sec    console=yes
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Stop Traffic in WTS on SA
    Connect to WTS
    ssh.send_command    ps -ef|grep iperf|grep -v grep|grep ${UL_PORT}| awk '{print $2}' |xargs sudo kill -9    connection=WTS
    ssh.send_command    ps -ef|grep iperf|grep -v grep|grep ${DL_PORT}| awk '{print $2}' |xargs sudo kill -9    connection=WTS
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Establish X2 Link on NSA
    ute_wtssim.Execute Egate Command    cmd=enb_x2_link_up enb\=1 target\=2    pass_regexp=${NSA_X2_UPDATED}    timeout=300
    Sleep    15sec

Set PDU Error on SA
    [Arguments]    ${ue}=${UE_ID}
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_upf_param id=1 ue=${ue} pdu=1 modify_gtpu_header=invalid_teid    timeout=300
    Sleep    2s

Check Traffic Throughput on iperf Server
    [Arguments]    ${dir}    ${throughput}
    Connect to WTS
    ssh.download_file    /tmp/iperf_${dir}.txt    ${LOCAL_LOG_DIR}/iperf_${dir}.txt    connection=WTS
    OperatingSystem.Run    ${iperf_egrep} ${LOCAL_LOG_DIR}/iperf_${dir}.txt | awk '{print $(1)}' > ${LOCAL_LOG_DIR}/iperf_${dir}_parsed.txt
    ${output}    OperatingSystem.Run    cat ${LOCAL_LOG_DIR}/iperf_${dir}_parsed.txt
    ${add_tmp}    Set Variable    0
    ${packet_number}    Set Variable    0
    ${list}    Split String    ${output}    \n
    FOR    ${var}    IN    @{list}
        ${add_tmp}    Evaluate    ${var}+${add_tmp}
        ${packet_number}    Evaluate    ${packet_number}+1
    END
    ${avg}    Evaluate    ${add_tmp}/${packet_number}
    ${throughput_delta}    Evaluate    abs(${throughput}-${avg})
    ${throughput_threshold}    Evaluate    ${throughput}*0.2
    Should Be True    ${throughput_delta}<${throughput_threshold}

Check Traffic on NSA in WTS
    [Arguments]    ${dir}    ${throughput}
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats id\=2 ue\=${UE_ID} dir\=${dir}    pass_regexp=${WTS_AVG_INTERVAL}
    ...    timeout=150
    Create File    /tmp/${dir}.txt    ${output}
    ${avg}    Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${throughput_delta}    Evaluate    abs(${throughput}-${avg}*0.000001)
    ${throughput_threshold}    Evaluate    ${throughput}*0.1
    Should Be True    ${throughput_delta}<${throughput_threshold}

Reset wts and reconfig cell onair on NSA
    ute_wtssim.setup_egate    egate_port=20000    host_ip=${LTE_HOST}
    ute_wtssim.Execute Egate Command    cmd=re    timeout=100
    ute_wtssim.Execute Egate Command    cmd=cfg file\=${EPCSIM_CFG}    timeout=450
    sleep    10sec
    Establish X2 Link on NSA
    [Teardown]    Disconnect WTS And Egate Session

Check Traffic on NSA in WTS for 7 drbs
    [Arguments]    ${dir}    ${throughput}
    ${output}    ute_wtssim.Execute Egate Command    
    ...    cmd=bearer_stats id\=1,2,3,4,5,6,7 ue\=${UE_ID} dir\=${dir} trf_id\=2 type\=l3 dc_cell_group\=scg
    ...    pass_regexp=${WTS_AVG_INTERVAL}    timeout=300
    sleep    5s
    Create File    /tmp/${dir}.txt    ${output}
    ${avg}    Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${throughput_delta}    Evaluate    abs(${throughput}-${avg}*0.000001)
    ${throughput_threshold}    Evaluate    ${throughput}*0.5
    Should Be True    ${throughput_delta}<${throughput_threshold}
    
Check DL Traffic on NSA in WTS for multi UE
    [Arguments]    ${dir}    ${throughput}
    ${output}    ute_wtssim.Execute Egate Command    
    ...    cmd=script file\=${basic_wts_dir_path}multi_ue_script.lua entry=check_dl_traffic_multi_ue(2,2,150000000,1)
    ...    pass_regexp=${WTS_AVG_INTERVAL}    timeout=300
    sleep    5s
    Create File    /tmp/${dir}.txt    ${output}
    ${avg}    Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${throughput_delta}    Evaluate    abs(${throughput}-${avg}*0.000001)
    ${throughput_threshold}    Evaluate    ${throughput}*0.5
    Should Be True    ${throughput_delta}<${throughput_threshold}
    
Check UL Traffic on NSA in WTS for multi UE
    [Arguments]    ${dir}    ${throughput}
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats id\=2 ue\=${UE_ID} dir\=${dir}    pass_regexp=${WTS_AVG_INTERVAL}
    ...    timeout=150
    Create File    /tmp/${dir}.txt    ${output}
    ${avg}    Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${throughput_delta}    Evaluate    abs(${throughput}-${avg}*0.000001)
    ${throughput_threshold}    Evaluate    ${throughput}*0.5
    Should Be True    ${throughput_delta}<${throughput_threshold}
    
L3 Attach and Traffic with PDU Error on SA
    Connect to WTS
    ute_wtssim.setup_egate    egate_port=20000    host_ip=${LTE_HOST}
    ute_wtssim.Execute Egate Command    cmd=ue_register id\=${UE_ID}    pass_regexp=${UE_REGISTERED}    timeout=150
    BuiltIn.Log    \n UE Attach is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=${PDU_SESSION_UP}    pass_regexp=${PDU_UP_SUCCESS}    timeout=150
    Start DL Traffic within 10sec on SA
    Start UL Traffic within 10sec on SA
    Sleep    5s
    Set PDU Error on SA
    Stop Traffic in WTS on SA
    BuiltIn.Log    \n UE Traffic is stopped \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_release ue=1 pdu=1    pass_regexp=Successfully released PDU Session
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${UE_ID} ue_deregister_type=switch_off    pass_regexp=detached
    BuiltIn.Log    \n UE Detach is OK \n    console=yes
    Sleep    5s
    [Teardown]    Disconnect WTS And Egate Session

    
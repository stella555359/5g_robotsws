*** Settings ***
Library           Collections
Library           DateTime
Library           OperatingSystem
Library           Telnet
Library           ./Resource/python/SherpaCsvReader.py

*** Variables ***
&{AP}              hostname=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu
&{GNB}             hostname=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu
${TLPC_IP}        ${tl.test_pc.default_ssh_connection_details.addr}
${TLPC_SSH_UE}    ${tl.test_pc.default_ssh_connection_details.username}
${TLPC_SSH_PWD}    ${tl.test_pc.default_ssh_connection_details.password}
${PDU_SESSION_UP}    ue_pdu_session_setup pdu=1 ue=${UE_ID} nwslice=1 gw=1
${PDU_SESSION_UP2}    ue_pdu_session_setup pdu=2 ue=${UE_ID} nwslice=1 gw=2
${PDU_UP_SUCCESS}    Initial Context Setup Successful
${PDU_UP_SUCCESS2}    handled successfully
${PING_MATCH}     from\\s+[0-9,\.\:]+\\s+[a-z,\_\=]+\\d+\\s+[a-z,\=,0-9]+
${SIB_UPDATED}    SystemInformationBlockType1-NR updated
${UE_REGISTERED}    REGISTRATION COMPLETE
${WEBUI_ADDR}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UE_ID}          11
${GNB_ID}         2
${CELL_ID}        1
${BEARER_ID}      2
${PROFILE_ID}     1
${DL_PORT}        7070
${DL_PORT2}       7072
${UL_PORT}        7071
${UL_PORT2}       7073
${upf_match_info2}    72.24.0.1
${iperf_egrep}    egrep -o '[[:digit:]]*.?[[:digit:]]*[[:space:]]Mbits/sec'
${WTS_AVG_INTERVAL}    Average packet interval
${NSA_X2_UPDATED}    MasterInformationBlock-NR Updated
${egate_run_path}    /opt/iphy/latest/
${EPCSIM_CFG_NSA}    ${egate_run_path}${basic_cfg_NSA}
${EPCSIM_CFG_SA}    ${egate_run_path}${basic_cfg_SA}
${EPCSIM_CFG_NSA_multi_DRBs}    ${egate_run_path}${basic_cfg_multi_DRBs_NSA}
${EPCSIM_CFG_SA_multi_DRBs}    ${egate_run_path}${basic_cfg_multi_DRBs_SA}
${basic_cfg_multi_DRBs_NSA}    basic_wts_multi_bears.cfg
${basic_cfg_NSA}    basic_fullstack_nsa_call_tdd_cmwv.cfg
${basic_cfg_SA}     basic_l1bypass_sa_call_tdd_cmwv.cfg
${basic_cfg_multi_DRBs_SA}    basic_wts_multi_bears.cfg
${L2RT_NODEID}    4682    # ipv4: 4666; ipv6: 4682
${L2HI_NODEID}    5946    # ipv6: 5946; ipv4: 57354
#${UTE_SHERPA_FILE_DIR}    ${SUITE_LOG_DIRECTORY}/l2stream3/tcpdump
${CSV_LOG_DIR}    /tmp
${edaemon_port}    22222
${egate_port}    20000
${CONTAINER_IP}    10.0.2.1
${drx_value}    256

*** Keywords ***
Connect to WTS
    SSH.connect to    hostname=${TLPC_IP}    username=${TLPC_SSH_UE}    password=${TLPC_SSH_PWD}    alias=WTS

Add ip to WTS eth3
    Connect to WTS
    SSH.execute    sudo ip addr add 10.0.1.131/24 dev eth3; sudo ip addr add 10.0.1.132/24 dev eth3     connection=WTS
    SSH.execute    sudo ip addr add 10.0.1.133/24 dev eth3; sudo ip addr add 10.0.1.134/24 dev eth3     connection=WTS
    SSH.execute    sudo ip addr add 10.0.1.135/24 dev eth3; sudo ip addr add 10.0.1.136/24 dev eth3     connection=WTS
    SSH.execute    sudo ip addr add 10.0.1.99/24 dev eth3; sudo ip addr add 10.0.1.121/24 dev eth3      connection=WTS
    [Teardown]    Disconnect WTS And Egate Session

Start Epcsim on WTS
    Connect to WTS
    ${execute_info}    SSH.execute    cd ${egate_run_path}; sudo ./edaemon --port ${edaemon_port}    connection=WTS
    sleep    1s
    FOR    ${var}    IN RANGE    10
         ${execute_info}    SSH.execute    cd ${egate_run_path}; ./egate --port ${egate_port}    connection=WTS
         sleep    1s
         ${ps_egate_info}    SSH.execute    ps -ef | grep egate | grep -v grep    connection=WTS
         ${run_result}    ${error}    run keyword and ignore error    should contain    ${ps_egate_info}    egate
         exit for loop if    '${run_result}'=='PASS'
    END
    should contain    ${run_result}    PASS
    [Teardown]    Disconnect WTS And Egate Session

Disconnect WTS And Egate Session
    Run Keyword And Ignore Error    teardown_egate
    Run Keyword And Ignore Error    SSH.Disconnect    connection=WTS

Establish X2 Link on NSA
    ute_wtssim.Execute Egate Command    cmd=enb_x2_link_up enb\=1 target\=2    pass_regexp=${NSA_X2_UPDATED}    timeout=300
    Sleep    15sec

Trigger paging from AMF
    BuiltIn.Log    begin to trigger paging from AMF

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

Set PDU Error on SA
    [Arguments]    ${ue}=${UE_ID}
#    ute_wtssim.Execute Egate Command    cmd=ue_pdu_upf_param id=1 ue=${ue} pdu=1 modify_gtpu_header=invalid_teid    timeout=300
    ute_wtssim.Execute Egate Command    cmd=upf_ue_pdu_inject_error_ind id=1 ue=${ue} pdu=1 abnormal_scenario=none    timeout=300
    Sleep    2s

L3 Attach and Traffic on SA
    SA 5G Attach    ${UE_ID}
    SA 5G PDU Session Setup    ${UE_ID}
    Make UE to idle    drx_value=${drx_value}
    Paging from AMF      
    SA Start DLUL Traffic    10    10    10
    BuiltIn.Sleep    2s
    SA Stop DLUL Traffic
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_release ue=1 pdu=1    pass_regexp=Successfully released PDU Session    
    SA 5G Detach    ${UE_ID}    
    SA 5G Attach    ${UE_ID}
    SA 5G PDU Session Setup    ${UE_ID}
    SA Start DLUL Traffic    10    10    10
    BuiltIn.Sleep    2s    
    Set PDU Error on SA                   
    SA Stop DLUL Traffic
    #ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_release ue=1 pdu=1    pass_regexp=Successfully released PDU Session
    #SA 5G Detach    ${UE_ID}

L3 Attach and Traffic on SA with multi Drbs
    ute_wtssim.Execute Egate Command    cmd=ue_register id\=${UE_ID}    pass_regexp=${UE_REGISTERED}    timeout=150
    BuiltIn.Log    \n UE Attach is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=${PDU_SESSION_UP}    pass_regexp=${PDU_UP_SUCCESS}    timeout=150
    ute_wtssim.Execute Egate Command    cmd=${PDU_SESSION_UP2}    pass_regexp=${PDU_UP_SUCCESS2}    timeout=150
    Start DL Traffic within 10sec on SA with multi DRBs
    Start UL Traffic within 10sec on SA with multi DRBs
    Sleep    10s
    Check Traffic Throughput on iperf Server    DL    5
    BuiltIn.Log    \n DL Traffic is OK \n    console=yes
    Check Traffic Throughput on iperf Server    UL    2
    BuiltIn.Log    \n UL Traffic is OK \n    console=yes
    Stop Traffic in WTS on SA
    BuiltIn.Log    \n UE Traffic is stopped \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_release ue=1 pdu=1    pass_regexp=Successfully released PDU Session
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_release ue=1 pdu=2    pass_regexp=Successfully released PDU Session
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${UE_ID} ue_deregister_type=switch_off    pass_regexp=detached
    BuiltIn.Log    \n UE Detach is OK \n    console=yes
    Sleep    5s
    [Teardown]    Disconnect WTS And Egate Session

L3 Attach and Traffic on SA with paging
    Trigger paging from AMF
    ute_wtssim.Execute Egate Command    cmd=ue_register id\=${UE_ID}    pass_regexp=${UE_REGISTERED}    timeout=150
    BuiltIn.Log    \n UE Attach is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=${PDU_SESSION_UP}    pass_regexp=${PDU_UP_SUCCESS}    timeout=150
    Make UE to idle    drx_value=${drx_value}
    Paging from AMF
    Sleep    5s
    [Teardown]    Disconnect WTS And Egate Session

L3 Attach and Traffic on SA with 5GC001808-T002
    SA 5G Attach    1
    SA Set Traffic Type To Internal    1
    SA 5G PDU Session Setup    1
    SA Start DL Traffic Internal    1    1    10
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=5 size=42:42 trf_id=1
    Sleep    10s
    SA Stop Data Traffic Internal    1    1
    BuiltIn.Log    \n UE Traffic is stopped \n    console=yes
    SA 5G Detach    1
    BuiltIn.Log    \n UE Detach is OK \n    console=yes
    Sleep    5s
    [Teardown]    Disconnect WTS And Egate Session

L3 Attach and Traffic with PDU Error on SA
    SA 5G Attach    ${UE_ID}
    SA 5G PDU Session Setup    ${UE_ID}
    SA Start DLUL Traffic    10    10    10
    Sleep    2s
    Set PDU Error on SA
    SA Stop DLUL Traffic
    # ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_release ue=1 pdu=1    pass_regexp=Successfully released PDU Session
    # SA 5G Detach    ${UE_ID}
    [Teardown]    Disconnect WTS And Egate Session

Start DL Traffic within 10sec on SA
    Connect to WTS
    SSH.send_command    nohup iperf -s -u -p ${DL_PORT} -i 1 -B ${CONTAINER_IP} > \ /tmp/iperf_DL.txt    connection=WTS
    SSH.send_command    nohup iperf -c 1.2.4.2 -u -p ${DL_PORT} -l 1400 -b 5M -i 1 -t 10 2>&1 &    connection=WTS
    BuiltIn.Log    Running DL Traffic for 10sec    console=yes
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    connection=WTS

Start DL Traffic within 10sec on SA with multi DRBs
    Connect to WTS
    SSH.send_command    nohup iperf -s -u -p ${DL_PORT} -i 1 -B ${CONTAINER_IP} > \ /tmp/iperf_DL.txt    connection=WTS
    SSH.send_command    nohup iperf -c 1.2.4.2 -u -p ${DL_PORT} -l 1400 -b 5M -i 1 -t 10 2>&1 &    connection=WTS
    Sleep    10s
    SSH.send_command    nohup iperf -c 1.2.4.3 -u -p ${DL_PORT} -l 1400 -b 5M -i 1 -t 10 2>&1 &    connection=WTS
    BuiltIn.Log    Running DL Traffic for 10sec    console=yes
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    connection=WTS

Start UL Traffic within 10sec on SA
    Connect to WTS
    SSH.send_command    nohup iperf -s -u -p ${UL_PORT} -i 1 -B ${CONTAINER_IP} > /tmp/iperf_UL.txt    connection=WTS
    SSH.send_command    nohup iperf -c 72.23.0.1 -u -p ${UL_PORT} -l 1400 -b 2M -i 1 -t 10 2>&1 &    connection=WTS
    BuiltIn.Log    Running UL Traffic for 10sec    console=yes
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    connection=WTS

Start UL Traffic within 10sec on SA with multi DRBs
    Connect to WTS
    SSH.send_command    nohup iperf -s -u -p ${UL_PORT} -i 1 -B ${CONTAINER_IP} > /tmp/iperf_UL.txt    connection=WTS
    SSH.send_command    nohup iperf -c 72.23.0.1 -u -p ${UL_PORT} -l 1400 -b 2M -i 1 -t 10 2>&1 &    connection=WTS
    Sleep    10s
    SSH.send_command    nohup iperf -c ${upf_match_info2} -u -p ${UL_PORT} -l 1400 -b 2M -i 1 -t 10 2>&1 &    connection=WTS
    BuiltIn.Log    Running UL Traffic for 10sec    console=yes
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    connection=WTS

Start DL Traffic within 10sec on SA with 5GC001808-T002
    Connect to WTS
    SSH.send_command    nohup iperf -s -u -p ${DL_PORT} -i 1 -B ${CONTAINER_IP} > \ /tmp/iperf_DL.txt    connection=WTS
    SSH.send_command    nohup iperf -c 1.2.4.2 -u -p ${DL_PORT} -l 100 -b 5M -i 1 -t 10 2>&1 &    connection=WTS
    BuiltIn.Log    Running DL Traffic for 10sec    console=yes
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    connection=WTS

Start UL Traffic within 10sec on SA with 5GC001808-T002
    Connect to WTS
    SSH.send_command    nohup iperf -s -u -p ${UL_PORT} -i 1 -B ${CONTAINER_IP} > /tmp/iperf_UL.txt    connection=WTS
    SSH.send_command    nohup iperf -c 72.23.0.1 -u -p ${UL_PORT} -l 100 -b 50M -i 1 -t 10 2>&1 &    connection=WTS
    BuiltIn.Log    Running UL Traffic for 10sec    console=yes
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    connection=WTS

Stop Traffic in WTS on SA
    Connect to WTS
    SSH.send_command    ps -ef|grep iperf|grep -v grep|grep ${UL_PORT}| awk '{print $2}' |xargs sudo kill -9    connection=WTS
    SSH.send_command    ps -ef|grep iperf|grep -v grep|grep ${DL_PORT}| awk '{print $2}' |xargs sudo kill -9    connection=WTS
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    connection=WTS

Check Traffic Throughput on iperf Server
    [Arguments]    ${dir}    ${throughput}
    Connect to WTS
    # SSH.download_file    /tmp/iperf_${dir}.txt    ${CSV_LOG_DIR}/iperf_${dir}.txt    connection=WTS
    OperatingSystem.Run    ${iperf_egrep} ${CSV_LOG_DIR}/iperf_${dir}.txt | awk '{print $(1)}' > ${CSV_LOG_DIR}/iperf_${dir}_parsed.txt
    ${output}    OperatingSystem.Run    cat ${CSV_LOG_DIR}/iperf_${dir}_parsed.txt
    ${add_tmp}    Set Variable    0
    ${packet_number}    Set Variable    0
    ${list}    Split String    ${output}    \n
    FOR    ${var}    IN    @{list}
         ${add_tmp}    Evaluate    ${var}+${add_tmp}
         ${packet_number}    Evaluate    ${packet_number}+1
    END
    ${avg}    Evaluate    ${add_tmp}/${packet_number}
    ${throughput_delta}    Evaluate    abs(${throughput}-${avg})
    ${throughput_threshold}    Evaluate    ${throughput}*0.1
    Should Be True    ${throughput_delta}<${throughput_threshold}
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    connection=WTS

L3 Attach and Traffic on NSA
    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA Verify If Attach Passed
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    10    1
    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    10    1
    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    5
    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    5
    NSA LTE Detach    ${UE_ID}

L3 Attach and Traffic on NSA with MAC_PDU TBsize modify
    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA Verify If Attach Passed
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    10    1
    ute_wtssim.Execute Egate Command    cmd=trf_data_start id\=${BEARER_ID} ue\=${UE_ID} trf_id\=2 dir\=ul size\=42\:42 mbps\=5 seconds\=60
    Sleep     5s
    # NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    5
    # NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    5
    NSA LTE Detach    ${UE_ID}

L3 Attach and Traffic on NSA with 7Drbs
    ute_wtssim.Execute Egate Command    cmd=ue_eutra_capabilities id\=${UE_ID} extended_drbs\=on elcid\=on    timeout=300
    ute_wtssim.Execute Egate Command    cmd=ue_attach id\=${UE_ID}    pass_regexp=UE IS ACTIVE    timeout=300
    BuiltIn.Log    \n UE Attach to LTE is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=ue_pdn_connect ue\=${UE_ID} pdn\=2    timeout=300
    sleep    3s
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_dc_enb_start ue\=${UE_ID} target_gnb\=${GNB_ID} target_cells\=${CELL_ID} bearer\=1,2,3,4,5,6,7 type\=split_scg
    ...    pass_regexp=reported successful RA    timeout=200
    BuiltIn.Log    \n UE Attach to 5g is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=trf_data_start id\=1,2,3,4,5,6,7 ue\=${UE_ID} trf_id\=1 dir\=dl mbps\=10 seconds\=60
    ute_wtssim.Execute Egate Command    cmd=trf_data_start id\=${BEARER_ID} ue\=${UE_ID} trf_id\=2 dir\=ul mbps\=5 seconds\=60
    Sleep     5s
    Check Traffic on NSA in WTS for 7 drbs    dl    10
    #Check Traffic on NSA in WTS    ul    5
    BuiltIn.Log    \n UE Traffic is OK \n    console=yes
    ute_wtssim.Execute Egate Command    cmd=ue_detach id\=${UE_ID}    pass_regexp=detached
    BuiltIn.Log    \n UE Detach is OK \n    console=yes

L3 Attach and Traffic on NSA with multi UEs
    NSA LTE Attach    ue_id=12    profile_id=1
    NSA 5G Attach    ue_id=12    gnb_id=2    cell_id=1    bearer_id=2
    NSA LTE Attach    ue_id=13    profile_id=1
    NSA 5G Attach    ue_id=13    gnb_id=2    cell_id=1    bearer_id=2
    Sleep    5s
    NSA LTE Detach    ue_id=12
    NSA LTE Detach    ue_id=13

Check Traffic on NSA in WTS
    [Arguments]    ${dir}    ${throughput}
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats id\=2 ue\=${UE_ID} dir\=${dir}    pass_regexp=${WTS_AVG_INTERVAL}
    ...    timeout=150
    Create File    /tmp/${dir}.txt    ${output}
    ${avg}    Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${throughput_delta}    Evaluate    abs(${throughput}-${avg}*0.000001)
    ${throughput_threshold}    Evaluate    ${throughput}*0.1
    Should Be True    ${throughput_delta}<${throughput_threshold}

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

Config and get All L2stream logs including attach and traffic
    [Arguments]    ${L3_CALL_TYPE_for_various_case}
    Start Sherpa L2stream Log
    Different L3CALL for various case    ${L3_CALL_TYPE_for_various_case}    #//starting different L3CALL for various case
    sleep    10s
    Stop Sherpa L2stream Log    ${SUITE_LOG_DIRECTORY}
    BuiltIn.Log    \n collect all L2 Sherpa streams are OK \n    console=yes

Different L3CALL for various case
    [Arguments]    ${L3_CALL_TYPE}
    run keyword if    ${L3_CALL_TYPE} == "NSA_basic_L3CALL"    L3 Attach and Traffic on NSA
    run keyword if    ${L3_CALL_TYPE} == "NSA_MODIFY_TBSIZE"    L3 Attach and Traffic on NSA with MAC_PDU TBsize modify
    run keyword if    ${L3_CALL_TYPE} == "NSA_multi_DRBs"    L3 Attach and Traffic on NSA with 7Drbs
    run keyword if    ${L3_CALL_TYPE} == "NSA_multi_UEs"    L3 Attach and Traffic on NSA with multi UEs
    run keyword if    ${L3_CALL_TYPE} == "SA_basic_L3CALL"    L3 Attach and Traffic on SA
    run keyword if    ${L3_CALL_TYPE} == "SA_multi_DRBs"    L3 Attach and Traffic on SA with multi Drbs
    run keyword if    ${L3_CALL_TYPE} == "SA_paging"    L3 Attach and Traffic on SA with paging
    run keyword if    ${L3_CALL_TYPE} == "SA_T002"    L3 Attach and Traffic on SA with 5GC001808-T002
    run keyword if    ${L3_CALL_TYPE} == "SA_PDU_error"    L3 Attach and Traffic with PDU Error on SA

Read csv file
    [Arguments]    ${CSV_type}
    ${CSV_file_path}    Get CSV file path
    #SSH.connect to    ${TLPC_IP}    ${TLPC_SSH_UE}    ${TLPC_SSH_PWD}
    Connect to WTS
    ${ls_output}    SSH.execute    cd ${CSV_file_path};ls *${CSV_type}.csv    connection=WTS
    ${CSV_name}    ${last} =    Split String From Right    ${ls_output}    .    1
    ${CSV_file}    Set Variable    ${CSV_file_path}/${CSV_name}.csv
    SherpaCsvReader.setup_reader    ${CSV_file}
    SherpaCsvReader.print all
    Run Keyword And Ignore Error    SSH.Disconnect    connection=WTS

Get CSV file path
    #SSH.connect to    ${TLPC_IP}    ${TLPC_SSH_UE}    ${TLPC_SSH_PWD}
    Connect to WTS
    ${ls_output}    SSH.execute    cd ${SUITE_LOG_DIRECTORY}/l2stream3_sherpa/tcpdump_sherpa;ls *.pcap    connection=WTS
    ${pcap_name}    ${last} =    Split String From Right    ${ls_output}    .    1
    ${CSV_file_path}    Catenate    SEPARATOR=/    ${SUITE_LOG_DIRECTORY}/l2stream3_sherpa/tcpdump_sherpa    ${pcap_name}
    Run Keyword And Ignore Error    SSH.Disconnect    connection=WTS
    [Return]    ${CSV_file_path}


*** Settings ***
Documentation
...               author: Steven Liu
...               contact: steven.liu@nokia-sbell.com
...               squad group: MMW_SG_04

Library           taf.config.scf    WITH NAME    cscf
Library           ute_syslog
Resource          ../../CB007608_B_575/Resources/5GC000575_comm_keyword.robot
Library           ../../CB007608_B_575/Resources/5GC000575_comm_keyword.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot

*** Variables ***
${MRBTS_ID_gnb1}                  MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID_gnb1}                  NRBTS-${tl.gnbs[0].global_bts_id}
${MRBTS_ID_gnb2}                  MRBTS-${tl.gnbs[1].instance_id}
${NRBTS_ID_gnb2}                  NRBTS-${tl.gnbs[1].global_bts_id}
${port1}                     51000
${port2}                     51003
${gnb1_ip}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB2_ip}                ${tl.gnbs[1].dus[0].f1_m_ip_addr}
${eNB_ip}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${gNB_username}           ${tl.gnbs[1].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[1].cu.oam_http_connection_details.password}
${gNB1_ssh_user}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gNB1_ssh_pass}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
${gnb1_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/7564_gnb1_22R3.xml
${gnb2_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/7564_gnb2_22R3.xml
${dist_cbraPreamblesPerSsb_gnb1}    ${MRBTS_ID_gnb1}/${NRBTS_ID_gnb1}/NRCELL-1
${dist_cbraPreamblesPerSsb_gnb2}    ${MRBTS_ID_gnb2}/${NRBTS_ID_gnb2}/NRCELL-1

*** Keywords ***
Check BTS Should Be Normal R
    [Timeout]  15min
    [Arguments]    ${host_ip}=${gNB_ip}    ${connection}=GNB_OAM
    Log To Console  Check BTS Should Be Normal R
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until BTS Should Be Normal R    connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=${connection}

Wait Until BTS Should Be Normal R
    [Arguments]   ${retry}=800s    ${retry_interval}=10s    ${connection}=default
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair R    alias=${connection}
    log to console    BTS status is normal

Gnb Cell Should Be Onair R
    [Arguments]    ${alias}=default    ${cell_type}=nr
    [Documentation]    Gnb Cell Should Be Onair, check method is via REST
    log to console    waiting for BTS onair
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal as strings    ${proceduralState}    OnAir

modify BTS1 to CFRA
    [Arguments]    ${host_ip}=${gNB1_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    coam.Perform Parameter Recommissioning    dist_name=${dist_cbraPreamblesPerSsb_gnb1}   parameter=cbraPreamblesPerSsb   value=n48
    ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    Wait Until Keyword Succeeds   20min     1min    Check BTS Should Be Normal R    host_ip=${gNB1_ip}    connection=GNB1
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=${connection}

modify BTS2 to CFRA
    [Arguments]    ${host_ip}=${gNB2_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    coam.Perform Parameter Recommissioning    dist_name=${dist_cbraPreamblesPerSsb_gnb2}   parameter=cbraPreamblesPerSsb   value=n48
    ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    Wait Until Keyword Succeeds   20min     1min    Check BTS Should Be Normal R    host_ip=${gNB2_ip}    connection=GNB2
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=${connection}

modify BTS1 to CBRA
    [Arguments]    ${host_ip}=${gNB1_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    coam.Perform Parameter Recommissioning    dist_name=${dist_cbraPreamblesPerSsb_gnb1}   parameter=cbraPreamblesPerSsb   value=n64
    ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    Wait Until Keyword Succeeds   20min     1min    Check BTS Should Be Normal R    host_ip=${gNB1_ip}    connection=GNB1
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=${connection}

modify BTS2 to CBRA
    [Arguments]    ${host_ip}=${gNB2_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    coam.Perform Parameter Recommissioning    dist_name=${dist_cbraPreamblesPerSsb_gnb2}   parameter=cbraPreamblesPerSsb   value=n64
        ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    Wait Until Keyword Succeeds   20min     1min    Check BTS Should Be Normal R    host_ip=${gNB2_ip}    connection=GNB2
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=${connection}

Start Capture BIP log
    [Arguments]    ${gnb_num}=bip_for_gnb1
    ${connection}       ssh.Connect to    hostname=${gnb1_ip}    username=${gNB1_ssh_user}
    ...    password=${gNB1_ssh_pass}    alias=DU
    ${PID}    Get PID    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep | grep tcpdump_L2L1 | tail -n 1 |awk '{print $2}'
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    run keyword and continue on failure    ssh.send_command    command=cd /tmp && rm -rf tcpdump_L2L1_bip*    connection=${connection}
    Precondition for bip capture with gnbMirroring scripts     connection=${connection}
    _replace_gnbMirroringConfig    connection=${connection}    gnb_num=${gnb_num}
    Log To Console    Capture BIP Logs
    ssh.send_command   command=sh /ffs/run/config/scripts/gnbMirroring.sh > /dev/null    connection=${connection}
    [Return]     ${connection}

Stop Capture BIP log and download file
    [Arguments]    ${connection}=ASIK Master
    ${PID}    Get PID    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep | grep tcpdump_L2L1 | tail -n 1 |awk '{print $2}'
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    ${output}    ssh.read_output    connection=${connection}
    run keyword and continue on failure    should be empty    ${output}
    sleep    5s
    ssh.send_command    command=ls /tmp/*tcpdump_L2L1_bip* | wc -l    connection=${connection}
    ${num}    ssh.read_output    connection=${connection}
    Log To Console    Copy BIP Logs To Test PC
    ${biplog_list}    create list
    FOR    ${item}    IN RANGE    int(${num})
       ssh.download_file    remote_path=/tmp/tcpdump_L2L1_bip_filtering_off.pcap${item}
       ...    local_path=${output_dir}/bip_log_file_${item}.pcap    connection=${connection}
       append to list    ${biplog_list}    bip_log_file_${item}.pcap
    END
    set suite variable    ${biplog_list}
    [Return]    ${biplog_list}
    [Teardown]    ssh.Disconnect    connection=${connection}

_replace_gnbMirroringConfig
    [Arguments]    ${connection}    ${gnb_num}
    ssh.upload_file     local_path=${CURDIR}/${gnb_num}/gnbMirroringConfig.sh
    ...    remote_path=/ffs/run/config/scripts/gnbMirroringConfig.sh    connection=${connection}

Get PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ssh.send_command    command=${command}   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    [Return]    ${PID}

start btslog capture on ute
    [Arguments]      ${connection}=ute     ${btslog_name}=btslog.log
    log to console    start syslog...
    ${list}    Create list     ${port1}    ${port2}
    ute_syslog.Start Syslog    log_dir=${OUTPUT_DIR}      log_name=${btslog_name}
    ...      host_ip=${TEST_PC_IP}    ssh_username=${TEST_PC_USERNAME}    ssh_password=${TEST_PC_PASSWORD}    ports=${list}    alias=${connection}

Start Collect Tcpdump
    [Arguments]  ${host_ip}    ${host_name}    ${host_pass}    ${log_name}=X2.pcap    ${interface}=any    ${conn}=GNB_CON
    ssh.Connect to    hostname=${host_ip}     username=${host_name}    password=${host_pass}    alias=${conn}
    ssh.send_command    command=ps -ef | grep tcpdump | awk '{print $2}' | xargs kill -9    connection=${conn}
    sleep    2s
    ssh.send command    command=nohup tcpdump -i ${interface} -w /tmp/${log_name} &>/dev/null &   connection=${conn}
    sleep    30s
    [Teardown]    run keyword and ignore error    ssh.Disconnect    connection=${conn}

Stop Collect Tcpdump R
    [Arguments]  ${host_ip}    ${host_name}    ${host_pass}    ${log_name}=X2.pcap    ${conn}=Tcpdump
    ssh.Connect to    hostname=${host_ip}     username=${host_name}    password=${host_pass}    alias=${conn}
    ssh.send_command    command=ps -ef | grep tcpdump | awk '{print $2}' | xargs kill -9    connection=${conn}
    ssh.download_file   remote_path=/tmp/${log_name}   local_path=${LOG_PATH}/${log_name}   connection=${conn}
    Sleep    60s
    ssh.execute    command=rm /tmp/${log_name}    connection=${conn}
    [Teardown]    run keyword and ignore error    ssh.Disconnect    connection=${conn}

#Save Snapshot
#    [Arguments]    ${host_ip}    ${connection}=cOAM    ${timeout}=10min
#    run keyword and ignore error     coam.teardown    connection=${connection}
#    coam.connect_to    bts_host=${host_ip}   name=${connection}
#    ${snapshot_path}    Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
#    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
#    [Return]    ${snapshot_path}

start UL and DL traffic
    run keyword and continue on failure     Iperf send UL traffic VIAVI
    sleep     5s
    run keyword and continue on failure     Iperf send DL traffic with real epc     throughput=${100}    traffic_time=${300}    port=${dl_port}
    sleep     5s

A3 measurement trigger R
    [Arguments]    ${message1}    ${message2}    ${tm500_alias}=e500
    log to console  Start to trigger A3 measurement report
    ${cmd_a3_mr}    catenate    forw mte NrRrcAptTriggerMeasReport ${message1} ${message2}
    log to console    ${cmd_a3_mr}
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response1}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    15s

get numofsymbols_format from Bip log
    [Arguments]      ${filter}    ${condition_expression}   ${biplog_list}
    csn.connect_to    hostname=${host}    username=${ute_name}    password=${ute_password}
    ...    alias=connection_ute
    FOR   ${i}   IN   @{biplog_list}
        csn.send command
        ...    command=/usr/bin/tshark -r ${output_dir}/${i} -X ${lua_path} -Y "${filter}" -T fields -e ${condition_expression}
        ...    connection=connection_ute
        sleep   5s
        ${return_value}  csn.Read Output   connection=connection_ute
        ${return_value}    remove duplicates     ${return_value.split('\n')[:-1]}
        log to console     ${return_value}
    END
    sleep   3s
    [Teardown]   csn.Disconnect    connection=${connection}
    [Return]    ${return_value}

Read bip log for case1
    [Arguments]    ${connection}=TestPc
    log to console    \n\tRead Log and check
    ssh.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=${connection}
    FOR    ${i}    IN    @{biplog_list}
        Convert pcap to text    source=${output_dir}/${i}    target=${output_dir}/PrachPreambles.txt
        ...   filter='UlData_detectedPrachPreambles_t.prachPreambleIndex == 48'    connection=${connection}
        ${PrachPreamblesContent}    Get File    ${output_dir}/PrachPreambles.txt
        ${status}     run keyword and return status    should not be empty    ${PrachPreamblesContent}
        run keyword if     ${status}==${True}    Exit for loop
    END
    FOR    ${i}    IN    @{biplog_list}
        Convert pcap to text    source=${output_dir}/${i}    target=${output_dir}/crcOK.txt
        ...   filter='UlData_UePuschReceiveRespHarqU_t.crc == 0'    connection=${connection}
        ${crcOKContent}    Get File    ${output_dir}/crcOK.txt
        ${status}     run keyword and return status    should not be empty    ${crcOKContent}
        run keyword if     ${status}==${True}    Exit for loop
    END

Read bip log for case3
    [Arguments]    ${connection}=TestPc
    log to console    \n\tRead Log and check
    ssh.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=${connection}
    FOR    ${i}    IN    @{biplog_list}
        Convert pcap to text    source=${output_dir}/${i}    target=${output_dir}/PrachPreambles.txt
        ...   filter='UlData_detectedPrachPreambles_t.prachPreambleIndex == 48'    connection=${connection}
        ${PrachPreamblesContent}    Get File    ${output_dir}/PrachPreambles.txt
        ${status}     run keyword and return status    should not be empty    ${PrachPreamblesContent}
        run keyword if     ${status}==${True}    Exit for loop
    END
    FOR    ${i}    IN    @{biplog_list}
        Convert pcap to text    source=${output_dir}/${i}    target=${output_dir}/crcOK.txt
        ...   filter='UlData_pucchReceiveRespPsPucchResource_t.crc == 0'    connection=${connection}
        ${crcOKContent}    Get File    ${output_dir}/crcOK.txt
        ${status}     run keyword and return status    should not be empty    ${crcOKContent}
        run keyword if     ${status}==${True}    Exit for loop
    END
    FOR    ${i}    IN    @{biplog_list}
        Convert pcap to text    source=${output_dir}/${i}    target=${output_dir}/NONDTX.txt
        ...   filter='UlData_UePuschReceiveRespHarqU_t.dtx == 0'    connection=${connection}
        ${NONDTXContent}    Get File    ${output_dir}/NONDTX.txt
        ${status}     run keyword and return status    should not be empty    ${NONDTXContent}
        run keyword if     ${status}==${True}    Exit for loop
    END

Read bip log for case4
    [Arguments]    ${connection}=TestPc
    log to console    \n\tRead Log and check
    ssh.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=${connection}
    FOR    ${i}    IN    @{biplog_list}
        Convert pcap to text    source=${output_dir}/${i}    target=${output_dir}/crcOK.txt
        ...   filter='UlData_pucchReceiveRespPsPucchResource_t.crc == 0'    connection=${connection}
        ${crcOKContent}    Get File    ${output_dir}/crcOK.txt
        should not be empty    ${crcOKContent}
    END
    FOR    ${i}    IN    @{biplog_list}
        Convert pcap to text    source=${output_dir}/${i}    target=${output_dir}/NONDTX.txt
        ...   filter='UlData_UePuschReceiveRespHarqU_t.dtx == 0'    connection=${connection}
        ${NONDTXContent}    Get File    ${output_dir}/NONDTX.txt
        should not be empty    ${NONDTXContent}
    END

Read Wireshark Log for case1
    [Arguments]      ${tcpdump_log}    ${connection}=TestPc
    log to console    \n\tRead Log and check
    ssh.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=${connection}
    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/SgNB.txt
    ...   filter='x2ap.SgNBAdditionRequest_element'    connection=${connection}
    ${SgNBContent}    Get File    ${output_dir}/SgNB.txt
    should not be empty    ${SgNBContent}
    should not contain    ${SgNBContent}    'SGNB Addition Trigger Indication'
    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Ack.txt
    ...   filter='x2ap.SgNBAdditionRequestAcknowledge_element'    connection=${connection}
    ${AckContent}    Get File    ${output_dir}/Ack.txt
    should not be empty    ${AckContent}
    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/UEcTX.txt
    ...   filter='f1ap.UEContextSetupRequest_element'    connection=${connection}
    ${UEcTXContent}    Get File    ${output_dir}/UEcTX.txt
    should not be empty    ${UEcTXContent}
    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Ack1.txt
    ...   filter='x2ap.SgNBAdditionRequestAcknowledge_element && nr-rrc.newUE_Identity'    connection=${connection}
    ${AckContent1}    Get File    ${output_dir}/Ack1.txt
    should not be empty    ${AckContent1}
    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Ack2.txt
    ...   filter='x2ap.SgNBAdditionRequestAcknowledge_element && nr-rrc.rach_ConfigDedicated == 0'    connection=${connection}
    ${AckContent2}    Get File    ${output_dir}/Ack2.txt
    should not be empty    ${AckContent2}
    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Ack3.txt
    ...   filter='x2ap.SgNBAdditionRequestAcknowledge_element && nr-rrc.ra_PreambleIndex == 48'    connection=${connection}
    ${AckContent3}    Get File    ${output_dir}/Ack3.txt
    should not be empty    ${AckContent3}
    [Teardown]    Run keyword and ignore error    ssh.Disconnect	  connection=${connection}

Read Wireshark Log for case2
    [Arguments]      ${tcpdump_log}    ${connection}=TestPc
    log to console    \n\tRead Log and check
    ssh.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=${connection}
    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/SgNB.txt
    ...   filter='x2ap.SgNBAdditionRequest_element'    connection=${connection}
    ${SgNBContent}    Get File    ${output_dir}/SgNB.txt
    should not be empty    ${SgNBContent}
    should not contain    ${SgNBContent}    'SGNB Addition Trigger Indication'
    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Ack.txt
    ...   filter='x2ap.SgNBAdditionRequestAcknowledge_element && nr-rrc.physCellId == 50'    connection=${connection}
    ${AckContent}    Get File    ${output_dir}/Ack.txt
    should not be empty    ${AckContent}
    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Mreport.txt
    ...   filter='nr-rrc.measurementReport_element'    connection=${connection}
    ${UEcTXContent}    Get File    ${output_dir}/Mreport.txt
    should not be empty    ${UEcTXContent}
    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Ack1.txt
    ...   filter='x2ap.SgNBChangeRequired_element && nr-rrc.physCellId == 50 && nr-rrc.physCellId == 52'    connection=${connection}
    ${AckContent1}    Get File    ${output_dir}/Ack1.txt
    should not be empty    ${AckContent1}
    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Ack2.txt
    ...   filter='x2ap.SgNBAdditionRequestAcknowledge_element && nr-rrc.rach_ConfigDedicated == 0'    connection=${connection}
    ${AckContent2}    Get File    ${output_dir}/Ack2.txt
    should not be empty    ${AckContent2}
    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Ack3.txt
    ...   filter='x2ap.SgNBAdditionRequestAcknowledge_element && nr-rrc.newUE_Identity && nr-rrc.ra_PreambleIndex == 48'    connection=${connection}
    ${AckContent3}    Get File    ${output_dir}/Ack3.txt
    should not be empty    ${AckContent3}
    [Teardown]    Run keyword and ignore error    ssh.Disconnect	  connection=${connection}

Read Wireshark Log for case3
    [Arguments]      ${tcpdump_log}    ${connection}=TestPc
    log to console    \n\tRead Log and check
    ssh.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=${connection}
    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Ack.txt
    ...   filter='x2ap.SgNBAdditionRequestAcknowledge_element && nr-rrc.physCellId == 50'    connection=${connection}
    ${AckContent}    Get File    ${output_dir}/Ack.txt
    should not be empty    ${AckContent}
    [Teardown]    Run keyword and ignore error    ssh.Disconnect	  connection=${connection}

Read Wireshark Log for case4
    [Arguments]      ${tcpdump_log}    ${connection}=TestPc
    log to console    \n\tRead Log and check
    ssh.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=${connection}
    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Ack.txt
    ...   filter='x2ap.SgNBAdditionRequestAcknowledge_element && nr-rrc.physCellId == 50'    connection=${connection}
    ${AckContent}    Get File    ${output_dir}/Ack.txt
    should not be empty    ${AckContent}
    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Mreport.txt
    ...   filter='nr-rrc.measurementReport_element'    connection=${connection}
    ${UEcTXContent}    Get File    ${output_dir}/Mreport.txt
    should not be empty    ${UEcTXContent}

    Convert pcap to text    source=${output_dir}/${tcpdump_log}    target=${output_dir}/Ack2.txt
    ...   filter='x2ap.SgNBAdditionRequestAcknowledge_element && nr-rrc.physCellId == 52'    connection=${connection}
    ${AckContent2}    Get File    ${output_dir}/Ack2.txt
    should not be empty    ${AckContent2}

    [Teardown]    Run keyword and ignore error    ssh.Disconnect	  connection=${connection}

Download Viavi Log R
    [Documentation]
    [Arguments]  ${logs_path}    ${retry}=2min    ${time}=40s    ${connect}=Control_PC
    log to console    ${logs_path}
    ssh.Connect to    hostname=${E500_IP}    username=${E500_USER}    password=${E500_PW}    alias=${connect}
    ${new_path}    set variable    /cygdrive/c/Users/nokia5G/Documents/CSV/${logs_path}[1]
    ssh.send command    command=mkdir ${new_path}    connection=${connect}
    ssh.send command    command=chmod 777 ${new_path}    connection=${connect}
    Wait Until Keyword Succeeds   ${retry}    10s    Check CSV file is exsit    csv_path='${logs_path}[0]'    connection=${connect}
    FOR    ${range}    IN RANGE    0    10
        ssh.send command    command=cd '${logs_path}[0]' && cp *.csv ${new_path}     connection=${connect}
    END
    ${output}=    ssh.Read Output    connection=${connect}
    sleep    ${time}
    Copy Viavi Log    logs_path=${new_path}
#    ssh.send command    command=rm -rf ${new_path}    connection=${connect}
    ${ute_path}    set variable    ${output_dir}/${logs_path}[1]
    [Return]  ${ute_path}
    [Teardown]    Run Keyword And Ignore error    ssh.disconnect    connection=${connect}

Check btslog for case1
    [Arguments]    ${target}=${OUTPUT_DIR}/btslog.log    ${connection}=ute
    log to console    Check btslog meassage...
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.Send Command    command=cat ${target} | grep 'Sent to L2PS itf::l2::ps::user::UserSetupReq_t'
    ...    connection=${connection}
    ${free1}  csn.Read Output    connection=${connection}
    should not be empty    ${free1}
    csn.Send Command
    ...    command=cat ${target} | egrep '(cp_rt)*(Sent to L2PS itf::l2::ps::user::UserSetupReq_t)*("ueAddCause":"INITIALACCESSSGNBADDITION")'
    ...    connection=${connection}
    ${free2}  csn.Read Output    connection=${connection}
    should not be empty    ${free2}
    csn.Send Command    command=cat ${target} | grep 'Received itf::l2::ps::user::UserSetupResp - OK'
    ...    connection=${connection}
    ${free3}  csn.Read Output    connection=${connection}
    should not be empty    ${free3}
    csn.Send Command    command=cat ${target} | grep 'Received from L2PS itf::l2::ps::user::UserSetupResp_t'
    ...    connection=${connection}
    ${free4}  csn.Read Output    connection=${connection}
    should not be empty    ${free4}
    log to console    Check btslog meassage successful
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Check btslog for case2
    [Arguments]    ${target}=${OUTPUT_DIR}/btslog.log    ${connection}=ute
    log to console    Check btslog meassage...
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.Send Command    command=cat ${target} | grep 'Sent to L2PS itf::l2::ps::user::UserSetupReq_t'
    ...    connection=${connection}
    ${free1}  csn.Read Output    connection=${connection}
    should not be empty    ${free1}
    csn.Send Command    command=cat ${target} | grep '"ueAddCause":"SGNBADDITION"'
    ...    connection=${connection}
    ${free2}  csn.Read Output    connection=${connection}
    should not be empty    ${free2}
    csn.Send Command    command=cat ${target} | grep 'Received itf::l2::ps::user::UserSetupResp - OK'
    ...    connection=${connection}
    ${free3}  csn.Read Output    connection=${connection}
    should not be empty    ${free3}
    csn.Send Command    command=cat ${target} | egrep '(Received from L2PS itf::l2::ps::user::UserSetupResp_t)*("cRnti":)'
    ...    connection=${connection}
    ${free4}  csn.Read Output    connection=${connection}
    should not be empty    ${free4}
    log to console    Check btslog meassage successful
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Check btslog for case3
    [Arguments]    ${target}=${OUTPUT_DIR}/btslog.log    ${connection}=ute
    log to console    Check btslog meassage...
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.Send Command    command=cat ${target} | grep 'Sent to L2PS itf::l2::ps::user::UserSetupReq_t'
    ...    connection=${connection}
    ${free1}  csn.Read Output    connection=${connection}
    should not be empty    ${free1}
    csn.Send Command
    ...    command=cat ${target} | egrep '(cp_rt)*(Sent to L2PS itf::l2::ps::user::UserSetupReq_t)*("ueAddCause":"INITIALACCESSSGNBADDITION")'
    ...    connection=${connection}
    ${free2}  csn.Read Output    connection=${connection}
    should not be empty    ${free2}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Check btslog for case4
    [Arguments]    ${target}=${OUTPUT_DIR}/btslog.log    ${connection}=ute
    log to console    Check btslog meassage...
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.Send Command    command=cat ${target} | grep 'Sent to L2PS itf::l2::ps::user::UserSetupReq_t'
    ...    connection=${connection}
    ${free1}  csn.Read Output    connection=${connection}
    should not be empty    ${free1}
    csn.Send Command
    ...    command=cat ${target} | egrep '(cp_rt)*(Sent to L2PS itf::l2::ps::user::UserSetupReq_t)*("ueAddCause":"SGNBADDITION")'
    ...    connection=${connection}
    ${free2}  csn.Read Output    connection=${connection}
    should not be empty    ${free2}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Check PM counter result
    [Arguments]    ${counter_object}    ${counter_id}    ${index}=${0}    ${enb}=${False}    ${BTS}=BTS    ${CELLS}=CELLS
    ...    ${NRCELL}=NRCELL-1
    ${connection}    Rest Login DU    index=${index}    enb=${enb}
    ${counter_values}=    coam.get pm counters   couter_ids=${counter_id}    connection=${connection}
    ${result}    Get Dictionary Values   ${counter_values['${BTS}']['${CELLS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
    [Return]    ${result}
    [Teardown]    Run Keyword And Ignore Error   Rest Logout DU    alias=${connection}

Get length and Check sum counter value
    [Arguments]     ${list_input}
    ${length}      Get Length       ${list_input}
    ${counter_value_sum}       Set Variable          0
    FOR   ${i}    IN RANGE    ${0}    ${length}     1
        ${counter_value_sum}     Evaluate    ${counter_value_sum}+${list_input}[${i}]
    END
    [Return]    ${counter_value_sum}

Rest Login DU
    [Arguments]    ${index}=${0}        ${alias}=default    ${enb}=${False}
    [Documentation]   Rest Login DU
    ${btsip}=    Set Variable If    ${enb}==${False}
    ...  ${tl.gnbs[${index}].dus[0].f1_m_ip_addr}    ${tl.enbs[${index}].airscale.common_units[0].lmp_connection.addr}
    Run Keyword And Ignore Error    Rest Logout DU   alias=${alias}
#    ${connection}   coam.Connect To  bts_host=${btsip}    bts_port=443
#    ...                              name=${alias}
#    ...                              username=${tl.gnbs[0].cu.oam_http_connection_details.username}
#    ...                              password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    Connect to gnb coam via ssl    bts_host=${btsip}
    ...                              username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                              password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                              connection=${alias}
    ${connection}    set variable    ${alias}
    [Return]  ${connection}

Rest Logout DU
    [Arguments]  ${alias}=default
    [Documentation]   Rest Logout DU
    coam.Teardown  connection=${alias}

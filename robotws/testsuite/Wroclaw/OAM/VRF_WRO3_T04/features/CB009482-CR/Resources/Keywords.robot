*** Settings ***
Documentation
...  author:     Szymon Romanowski
...  contact:    szymon.romanowski@nokia.com

Resource    taf/rfrl/cbts/robot/webem_operations.robot

*** Variables ***
# ipRmDropPcktsRtLimArp [M51328C17] test settings
${M51328C17_BURST}=                               16
${M51328C17_LIMIT}=                               300
${M51328C17_PPS}=                                 2000
${M51328C17_LOOP}=                                1
${M51328C17_PACKETS_LIMIT}=                       (${M51328C17_LIMIT} * ${M51328C17_LOOP} + ${M51328C17_BURST})
${M51328C17_PACKETS}=                             (${M51328C17_PPS} * ${M51328C17_LOOP})
${M51328C17_ERROR}=                               0.1
${M51328C17_VALUE}=                              (${M51328C17_PACKETS} - ${M51328C17_PACKETS_LIMIT})

*** Keywords ***
Send Packets For M51328C17 Counter To CBTS
    [Arguments]  ${dst_mac_address}  ${pps_number}  ${pps_loop}  ${testPC_interface}
    ssh.connect to    ${IP_TEST_PC}    ${LOGIN_TEST_PC}    ${PASS_TEST_PC}    alias=conn_m51328c17_test_pc
    ${python_path}=  ssh.execute  which python3  connection=conn_m51328c17_test_pc
    ${python_path_stripped}=  Strip String  ${python_path}
    ${command}=  Catenate  'import scapy.all as scapy; scapy.sendpfast((scapy.Ether(dst="${dst_mac_address}") / scapy.ARP(pdst="${LMP_VDU_IP}")),
    ...                     pps=${pps_number}, iface="${testPC_interface}", count=${pps_loop}, parse_results=1)'
    ${scapy_command_status}=  ssh.execute  echo ${PASS_TEST_PC} | sudo -S ${python_path_stripped} -c ${command}  connection=conn_m51328c17_test_pc
    [Teardown]  ssh.disconnect  connection=conn_m51328c17_test_pc
    [Return]  ${scapy_command_status}

Wait For New Interval Start vDU
    [Arguments]  ${counter_name}  ${counter_object}
    ${start_value}=  Get Counters Time From WebEM on BTS  ${counter_name}  ${counter_object}  vDU
    wait until keyword succeeds     10min
    ...                             15s
    ...                             Compare Counter Values vDU  ${start_value}  ${counter_name}  ${counter_object}

Compare Counter Values vDU
    [Arguments]  ${start_value}  ${counter_name}  ${counter_object}
    ${value}=   Get Counters Time From WebEM on BTS  ${counter_name}  ${counter_object}  vDU
    log to console  waiting for new ipFilteringInterval start, previous time is ${value}
    should not be equal  ${start_value}  ${value}

Start Tcpdump For M51328C17 Counter vDU
    [Arguments]    ${pc_interface}
    ssh.connect to    ${IP_TEST_PC}    ${LOGIN_TEST_PC}    ${PASS_TEST_PC}    alias=conn_m51328c17_tcpdump
    ${start_command}=  Catenate  echo ${PASS_TEST_PC} | sudo -S tcpdump -i ${pc_interface} -w 9482-A.cap
    ${tcpdump_pid}=  ssh.send command  ${start_command}  connection=conn_m51328c17_tcpdump

Kill Tcpdump For M51328C17 Counter vDU
    ${tcpdump_pid_command}=  Catenate  ps aux | grep '-w 9482-A.cap' | grep -wv 'grep' | awk '{print $2}'
    ${tcpdump_pid}=  ssh.execute  ${tcpdump_pid_command}  connection=conn_m51328c17_tcpdump
    ${tcpdump_pid_stripped}=  Strip String  ${tcpdump_pid}
    ${kill_comand}=  Catenate  kill -9 ${tcpdump_pid_stripped}
    ssh.execute  ${kill_comand}  connection=conn_m51328c17_tcpdump
    ssh.disconnect  connection=conn_m51328c17_tcpdump

Get Number Of Packets After Packets Flood For M51328C17 vDU
    ssh.connect to    ${IP_TEST_PC}    ${LOGIN_TEST_PC}    ${PASS_TEST_PC}    alias=conn_m51328c17_tcpdump_read
    ${info_about_packets}=  ssh.execute  tcpdump -r 9482-A.cap | wc -l  connection=conn_m51328c17_tcpdump_read
    ${number_of_packets}=  Get Line  ${info_about_packets}  -1
    ssh.execute  echo ${PASS_TEST_PC} | sudo -S rm 9482-A.cap  connection=conn_m51328c17_tcpdump_read
    ssh.disconnect  connection=conn_m51328c17_tcpdump_read
    [Return]  ${number_of_packets}

Get Counter List From NetAct For OAM TNL
    [Documentation]    Get counters list from netact for given counter
    [Arguments]    ${counter_name}
    nms.Add Web URL      ${LAB_NAME}lbwas.srnblr.nsn-rdnet.net    ${NMS_USERNAME}  ${NMS_PASSWORD}
    @{nms_counters}=    nms.Get Pm Counters
    ...    technology=SBTS-Nokia Multi Radio Transceiver Station
    ...    measurement=IP filtering Statistics
    ...    counters=${counter_name}
    ...    filter_by=TNL
    ...    mo_names=PLMN-PLMN/MRBTS-${MRBTS}/TNLSVC-1/TNL-${TNL-ID}
    ...    object_aggregation=PLMN/MRBTS/TNLSVC/TNL
    ...    time_aggregation=RAW
    ...    time_filter=relative
    ...    time_from=NOW
    ...    time_amount=70
    ...    time_period=MIN
    [Teardown]    nms.Delete Node    web_url
    [Return]  ${nms_counters}[0][${counter_name}]

Wait Until PM Counters Are Available
    ${counter_WebEm_C17}=  Get Counters Value From WebEM on BTS  M51328C17  MRBTS-${MRBTS}/TNLSVC-1/TNL-${TNL-ID}/IPNO-1  vDU
    ${value_check}=  Catenate  (${counter_WebEm_C17} > ${M51328C17_SHOULD_BE_COLLECTED} -
    ...  (${M51328C17_SHOULD_BE_COLLECTED} * ${M51328C17_TCPDUMP_STATISTICAL_ERROR}))
    Run Keyword If   not ${value_check}    log    Waiting unitl Counters are available    console=yes
    Run Keyword If   not ${value_check}    Wait For New Interval Start vDU  M51328C17  MRBTS-${MRBTS}/TNLSVC-1/TNL-${TNL-ID}/IPNO-1
    Should Be True  ${value_check}

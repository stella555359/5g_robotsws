*** Keywords ***
SA 5G Attach
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate UE attach on 5GNR side during NSA L3 Call on eGate.
    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 2 ) reported successful RA" on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G Attach | 1 |
    Log To Console    start 5G attach...
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ue_register id\=${ue_id}    pass_regexp=REGISTRATION COMPLETE|No response to RRCSetupRequest    timeout=3minutes
    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    REGISTRATION COMPLETE
    Run Keyword If    "${ret}"=="${False}"    Fail    SA 5G Attach fails!!!
    Should Be True    ${ret}
    ${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    Log To Console    \n${output1}
    Should Match Regexp    ${output}    Initial UE Message .*Success
    Sleep    3s    reason=wait 5G attach is stable

SA 5G PDU Session Setup
    [Arguments]    ${ue_id}    ${pdu_id}=1
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

SA Set Traffic Type To Internal
    [Arguments]    ${ue_id}    ${pdu_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=set_pdu_param ue\=${ue_id} pdu\=${pdu_id} trf_type=internal

SA Single UE Attach
    [Arguments]    ${ue_id}    ${pdu_id}=1
    [Documentation]    This keyword is to 5G UE attach for SA CA.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | YES | id of ue |
    ...    | pdu_id | No | id of pdu ，the default value is 1 |
    ...    This keyword return the output of the egate command to use for other checking.
    ...
    ...    | Examples: |
    ...    | ${output} | SA Single UE Attach | 1 | 1 |
    ...
    Log To Console    UE${ue_id} Start Attach...
    Set UEC Reordering Timer
    SA 5G Attach    ue_id=${ue_id}
    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${pdu_id}
    ${output}    SA 5G PDU Session Setup    ${ue_id}    pdu_id=${pdu_id}
    [Return]    ${output}

SA 5G Detach
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate UE detach on 5GNR side.
    ...    Expected output is: " UE Context Release Complete " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G Detach | 1 |
    Log To Console    start 5G detach...
    ${command}    Set Variable    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}
    ...    pass_regexp=UE Context Release Complete    timeout=3minutes
    ${output1}    String.Get Lines Matching Regexp    ${output}    UE Context Release Complete
    ...    partial_match=${true}
    Log To Console    \n${output1}

SA Non GBR Call For Multi UE
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate Non GBR call for different UEs on 5GNR side.
    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 2 ) reported successful RA" on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA Non GBR call for multi UE | 1 |
    SA 5G Attach    ${ue_id}
    SA 5G PDU Session Setup For Multi UE    ${ue_id}

SA 5G PDU Session Setup For Multi UE
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup for different UEs on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G PDU Session Setup for multi UE | 1 |
    Log To Console    start 5G PDU Session Setup for UE${ue_id}..
    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

SA Start UDP UL Traffic For Multi UE
    [Arguments]    ${ue_id}   ${UL_PORT}=7071    ${len}=40    ${bps}=16000    ${duration}=3600
    [Documentation]    This keyword is to start UL traffic by iperf.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | UL_PORT | Yes | UL PORT, default is 7071 |
    ...    | len | Yes | traffic length, default is 40 |
    ...    | bps | Yes | bps, default is 16000 |
    ...    | duration | Yes | duration, default is 3s |
    ...    Example:
    ...    | SA Start UDP UL Traffic for multi UE | 1 | 7071 | 40 | 16000 | 3600 |
    Log To Console                     start UDP UL traffic for UE${ue_id}...
    Execute Iperf In Linux             args=-c 72.23.${${ue_id}+1}.1 -u -p ${UL_PORT} -l ${len} -b ${bps} -i 1 -t ${duration}
    Sleep                              3s
    Execute Iperf In Linux             args=-s -u -p ${UL_PORT} -i 1 -B 10.0.2.1
    ...                                pipe_args=| tee /tmp/iperf_ul_UE${ue_id}.txt
    Log To Console                     Running UL Traffic ${bps}M for ${duration}s
    Sleep                              3s

SA Start UDP DL Traffic For Multi UE
    [Arguments]    ${ue_id}   ${DL_PORT}=7070    ${len}=40    ${bps}=16000    ${duration}=3600
    [Documentation]    This keyword is to start DL traffic by iperf.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | DL_PORT | Yes | DL PORT, default is 7070 |
    ...    | len | Yes | traffic length, default is 40 |
    ...    | bps | Yes | bps, default is 16000 |
    ...    | duration | Yes | duration, default is 3s |
    ...    Example:
    ...    | SA Start UDP DL Traffic for multi UE | 1 | 7070 | 40 | 16000 | 3600 |
    Log To Console                     start UDP DL traffic for UE${ue_id}...
    Execute Iperf In Linux             args=-c 1.2.4.${${ue_id}+1} -u -p ${DL_PORT} -l ${len} -b ${bps} -i 1 -t ${duration}
    Sleep                              3s
    Execute Iperf In Linux             args=-s -u -p ${DL_PORT} -i 1 -B 10.0.2.1
    ...                                pipe_args=| tee /tmp/iperf_dl_UE${ue_id}.txt
    Log To Console                     Running DL Traffic ${bps}M for ${duration}s
    Sleep                              3s

SA Start TCP UL Traffic For Multi UE
    [Arguments]    ${ue_id}   ${UL_PORT}=8071    ${len}=40    ${duration}=3600
    [Documentation]    This keyword is to start UL TCP traffic by iperf.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | UL_PORT | Yes | UL PORT, default is 8071 |
    ...    | len | Yes | traffic length, default is 40 |
    ...    | duration | Yes | duration, default is 3s |
    ...    Example:
    ...    | SA Start TCP UL Traffic for multi UE | 1 | 8071 | 40 | 3600 |
    Log To Console                     start TCP UL traffic for UE${ue_id}...
    Execute Iperf In Linux             args=-c 72.23.${${ue_id}+1}.1 -p ${UL_PORT} -l ${len} -i 1 -t ${duration} -B 10.0.2.1
    Sleep                              3s
    Execute Iperf In Linux             args=-s -p ${UL_PORT} -i 1 -B 10.0.2.1
    ...                                pipe_args=| tee /tmp/iperf_tcp_ul_UE${ue_id}.txt
    Log To Console                     Running TCP UL Traffic for ${duration}s
    Sleep                              3s

SA Start TCP DL Traffic For Multi UE
    [Arguments]    ${ue_id}   ${DL_PORT}=8070    ${len}=40    ${duration}=3600
    [Documentation]    This keyword is to start DL TCP traffic by iperf.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | DL_PORT | Yes | DL PORT, default is 8070 |
    ...    | len | Yes | traffic length, default is 40 |
    ...    | duration | Yes | duration, default is 3s |
    ...    Example:
    ...    | SA Start TCP DL Traffic for multi UE | 1 | 8070 | 40 | 3600 |
    Log To Console                     start TCP DL traffic for UE${ue_id}...
    Execute Iperf In Linux             args=-c 1.2.4.${${ue_id}+1} -p ${DL_PORT} -l ${len} -i 1 -t ${duration} -B 10.0.2.1
    Sleep                              3s
    Execute Iperf In Linux             args=-s -p ${DL_PORT} -i 1 -B 10.0.2.1
    ...                                pipe_args=| tee /tmp/iperf_tcp_dl_UE${ue_id}.txt
    Log To Console                     Running TCP DL Traffic for ${duration}s
    Sleep                              3s

SA Stop Traffic For Multi UE
    [Arguments]    ${DL_PORT}=7070    ${UL_PORT}=7071
    [Documentation]    This keyword is to stop traffic by iperf.
    ...    | Input Parameters | Man. | Description |
    ...    | DL_PORT | Yes | DL PORT |
    ...    | UL_PORT | Yes | UL PORT |
    ...    Example:
    ...    | SA Stop Traffic for multi UE | 7070 | 7071 |
    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep|grep ${DL_PORT}| awk '{print $2}' |xargs sudo kill -9
    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep|grep ${UL_PORT}| awk '{print $2}' |xargs sudo kill -9

Execute Iperf In Linux
    [Arguments]    ${args}=${EMPTY}    ${pipe_args}=${EMPTY}
    ${result}    Run Keyword    Process.Start Process    iperf ${args} ${pipe_args}    shell=${TRUE}
    [Return]    ${result}

SA Start DL Traffic
    [Arguments]    ${mbps}=5    ${duration}=10    ${len}=1300
    [Documentation]    This keyword is to start DL traffic by iperf.
    ...    | Input Parameters | Man. | Description |
    ...    | mbps | Yes | mbps, default is 10M |
    ...    | duration | Yes | duration, default is 10s |
    ...    | len  | Yes | traffic length, default is 1300 Byte |
    ...    Example:
    ...    | SA Start DL Traffic | 10 | 10 | 1300 |
    Log To Console                     start DL traffic...
    Execute Iperf In Linux             args=-c 1.2.4.2 -u -p ${DL_PORT} -l ${len} -b ${mbps}M -i 1 -t ${duration}
    Execute Iperf In Linux             args=-s -u -p ${DL_PORT} -i 1 -B 10.0.2.1
    ...                                pipe_args=| tee /tmp/iperf_dl.txt
    Log To Console                     Running DL Traffic ${mbps}M for ${duration}s
    Sleep                              ${duration}s
    Sleep                              3s

SA Start UL Traffic
    [Arguments]    ${mbps}=5    ${duration}=10    ${len}=1300
    [Documentation]    This keyword is to start UL traffic by iperf.
    ...    | Input Parameters | Man. | Description |
    ...    | mbps | Yes | mbps, default is 10M |
    ...    | duration | Yes | duration, default is 10s |
    ...    | len  | Yes | traffic length, default is 1300 Byte |
    ...    Example:
    ...    | SA Start UL Traffic | 10 | 10 | 1300 |
    Log To Console                     start UL traffic...
    Execute Iperf In Linux             args=-c 72.23.0.1 -u -p ${UL_PORT} -l ${len} -b ${mbps}M -i 1 -t ${duration}
    Execute Iperf In Linux             args=-s -u -p ${UL_PORT} -i 1 -B 10.0.2.1
    ...                                pipe_args=| tee /tmp/iperf_ul.txt
    Log To Console                     Running UL Traffic ${mbps}M for ${duration}s
    Sleep                              ${duration}s
    Sleep                              3s

SA Start DLUL Traffic
    [Arguments]    ${dlmbps}=5    ${ulmbps}=5    ${duration}=10    ${len}=1300
    [Documentation]    This keyword is to start DL and UL traffic by iperf at the same time.
    ...    | Input Parameters | Man. | Description |
    ...    | dlmbps | Yes | mbps, default is 5M |
    ...    | ulmbps | Yes | mbps, default is 5M |
    ...    | duration | Yes | duration, default is 10s |
    ...    | len  | Yes | traffic length, default is 1300 Byte |
    ...    Example:
    ...    | SA Start DLUL Traffic | 20 | 10 | 10 | 1300 |
    Log To Console                     ready to start DL and UL traffic at the same time...
    Log To Console                     start DL traffic...
    Execute Iperf In Linux             args=-c 1.2.4.2 -u -p ${DL_PORT} -l ${len} -b ${dlmbps}M -i 1 -t ${duration}
    Execute Iperf In Linux             args=-s -u -p ${DL_PORT} -i 1 -B 10.0.2.1
    ...                                pipe_args=| tee /tmp/iperf_dl.txt
    Log To Console                     Running DL Traffic ${dlmbps}M for ${duration}s
    Log To Console                     start UL traffic...
    Execute Iperf In Linux             args=-c 72.23.0.1 -u -p ${UL_PORT} -l ${len} -b ${ulmbps}M -i 1 -t ${duration}
    Execute Iperf In Linux             args=-s -u -p ${UL_PORT} -i 1 -B 10.0.2.1
    ...                                pipe_args=| tee /tmp/iperf_ul.txt
    Log To Console                     Running UL Traffic ${ulmbps}M for ${duration}s
    Sleep                              ${duration}s
    Sleep                              3s

SA Start DLUL Traffic Iperf VoNR
    [Arguments]    ${dlbps}=12200    ${ulbps}=12200    ${duration}=600    ${len}=30    ${dl_port}=7070    ${ul_port}=7070
    ...    ${host_addr}=10.12.2.2    ${nat_ip}=72.25.0.1
    [Documentation]    This keyword is to start DL and UL VoNR traffic by iperf at the same time.
    ...    | Input Parameters | Man. | Description |
    ...    | dlbps | Yes | bps, default is 12.2k |
    ...    | ulbps | Yes | bps, default is 12.2k |
    ...    | duration | Yes | duration, default is 600s |
    ...    | len  | Yes | traffic length, default is 30 Byte |
    Log To Console                     ready to start DL and UL traffic at the same time...
    Log To Console                     start DL traffic...
    Execute Iperf In Linux             args=-c ${host_addr} -u -p ${dl_port} -l ${len} -b ${dlbps} -i 1 -t ${duration}
    Execute Iperf In Linux             args=-s -u -p ${dl_port} -i 1 -B 10.0.2.1
    ...                                pipe_args=| tee /tmp/iperf_dl.txt
    Log To Console                     Running DL Traffic ${dlbps} for ${duration}s
    Log To Console                     start UL traffic...
    Execute Iperf In Linux             args=-c ${nat_ip} -u -p ${ul_port} -l ${len} -b ${ulbps} -i 1 -t ${duration}
    Execute Iperf In Linux             args=-s -u -p ${ul_port} -i 1 -B 10.0.2.1
    ...                                pipe_args=| tee /tmp/iperf_ul.txt
    Log To Console                     Running UL Traffic ${ulbps} for ${duration}s
    Sleep                              10s

SA Stop DL Traffic
    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep|grep ${DL_PORT}| awk '{print $2}' |xargs sudo kill -9

SA Stop UL Traffic
    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep|grep ${UL_PORT}| awk '{print $2}' |xargs sudo kill -9

SA Stop DLUL Traffic
    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep|grep ${DL_PORT}| awk '{print $2}' |xargs sudo kill -9
    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep|grep ${UL_PORT}| awk '{print $2}' |xargs sudo kill -9

SA Get UE Average Traffic
    [Arguments]    ${dir}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | dir | Yes | Direction of Traffic |
    ...    Example:
    ...    | SA Get UE Average Traffic | ul |
    ...    | SA Get UE Average Traffic | dl |
    OperatingSystem.Run    ${IPERF_EGREP} /tmp/iperf_${dir}.txt | awk '{print $(1)}' > ${OUTPUT DIR}/iperf_${dir}_parsed.txt
    ${output}    OperatingSystem.Run    cat ${OUTPUT DIR}/iperf_${dir}_parsed.txt
    ${add_tmp}    Set Variable    0
    ${packet_number}    Set Variable    0
    ${list}    Split String    ${output}    \n
    FOR    ${var}    IN    @{list}
         ${add_tmp}    Evaluate    ${var}+${add_tmp}
         ${packet_number}    Evaluate    ${packet_number}+1
    END
    ${avg}    Evaluate    ${add_tmp}/${packet_number}
    Log    The ${dir} Troughput is ${avg}M    console=True
    [Return]    ${avg}

SA Get UE Average Traffic Iperf VoNR
    [Arguments]    ${dir}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | dir | Yes | Direction of Traffic |
    ...    Example:
    ...    | SA Get UE Average Traffic | ul |
    ...    | SA Get UE Average Traffic | dl |
    ${IPERF_EGREP_VONR}    Set Variable    egrep -o '[[:digit:]]*.?[[:digit:]]*[[:space:]]Kbits/sec'
    OperatingSystem.Run    ${IPERF_EGREP_VONR} /tmp/iperf_${dir}.txt | awk '{print $(1)}' > ${OUTPUT DIR}/iperf_${dir}_parsed.txt
    ${output}    OperatingSystem.Run    cat ${OUTPUT DIR}/iperf_${dir}_parsed.txt
    ${add_tmp}    Set Variable    0
    ${packet_number}    Set Variable    0
    ${list}    Split String    ${output}    \n
    FOR    ${var}    IN    @{list}
         ${add_tmp}    Evaluate    ${var}+${add_tmp}
         ${packet_number}    Evaluate    ${packet_number}+1
    END
    ${avg}    Evaluate    ${add_tmp}/${packet_number}
    Log    The ${dir} Troughput is ${avg}Kbps    console=True
    [Return]    ${avg}

SA Check Average Traffic Bigger Than Target
    [Arguments]    ${dir}    ${tp_rate}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | dir | Yes | Direction of Traffic |
    ...    | tp_rate | Yes | Throughput Rate for traffic |
    ...    Example:
    ...    | SA Check Average Traffic bigger than target | ul | 10 |
    ...    | SA Check Average Traffic bigger than target | dl | 10 |
    ${tput_avg}=    SA Get UE Average Traffic    ${dir}
    ${tp_delta}    Evaluate    ${tput_avg}-${tp_rate}
    Log To Console    Actual ${dir} TPUT=${tput_avg}M, Expected ${dir} TPUT=${tp_rate}M
    Should Be True    ${tp_delta}>=0    Throughtput is not bigger than the expected value!

SA Check Average Traffic Smaller Than Target
    [Arguments]    ${dir}    ${tp_rate}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | dir | Yes | Direction of Traffic |
    ...    | tp_rate | Yes | Throughput Rate for traffic |
    ...    Example:
    ...    | SA Check Average Traffic smaller than target | ul | 10 |
    ...    | SA Check Average Traffic smaller than target | dl | 10 |
    ${tput_avg}=    SA Get UE Average Traffic    ${dir}
    ${tp_delta}    Evaluate    ${tput_avg}-${tp_rate}
    Log To Console    Actual ${dir} TPUT=${tput_avg}M, Expected ${dir} TPUT=${tp_rate}M
    Should Be True    ${tp_delta}<=0    Throughtput is not smaller than the expected value!

Start SA UE Big DL Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${pdu_id}=1    ${trf_id}=1    ${qfi_id}=1
    [Documentation]    This keyword is to start single UE big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
        ${tmp_trf_id}    Evaluate    ${trf_id}+${t_time}-1
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id} dir=dl mbps\=175 trf_id\=${tmp_trf_id}
        Log To Console    \nUE${ue_id} Start DL 175M Traffic for trf_id=${tmp_trf_id}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
    ${last_trf_id}    Evaluate    ${trf_id}+${dl_times}
    Run Keyword If    '${last_mbps}'!='0'    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id} dir=dl mbps\=${last_mbps} trf_id\=${last_trf_id}
    Run Keyword If    '${last_mbps}'!='0'    Log To Console    \nUE${ue_id} Start DL ${last_mbps}M Traffic for trf_id=${last_trf_id}

Start SA UE Big UL Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${pdu_id}=1    ${trf_id}=1    ${qfi_id}=1
    [Documentation]    This keyword is to start single UE big dl udp traffic which more than 175.
    ${ul_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${ul_times}+1
        ${tmp_trf_id}    Evaluate    ${trf_id}+${t_time}-1
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id} dir=ul mbps\=175 trf_id\=${tmp_trf_id}
        Log To Console    \nUE${ue_id} Start UL 175M Traffic for trf_id=${tmp_trf_id}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${ul_times}
    ${last_trf_id}    Evaluate    ${trf_id}+${ul_times}
    Run Keyword If    '${last_mbps}'!='0'    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id} dir=ul mbps\=${last_mbps} trf_id\=${last_trf_id}
    Run Keyword If    '${last_mbps}'!='0'    Log To Console    \nUE${ue_id} Start UL ${last_mbps}M Traffic for trf_id=${last_trf_id}

Calculate PDU Id
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is to calculate PDU ID with multi UE.PDU number is only from 1 to 16
    ${num}    set Variable    15
    ${pdu_id}    Evaluate    ${ue_id}%${num}
    ${pdu_id}    Run Keyword If    '${pdu_id}'=='0'    Evaluate    ${num}
    ...                        ELSE    Evaluate    ${pdu_id}+0
    [Return]    ${pdu_id}

SA Start DL Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}=1    ${sleep_time}=2s    ${qfi_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | pdu_id | Yes | bearer_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Start DL Traffic | 1 | 2 | 10 |
    Log To Console    UE${ue_id} start DL ${mbps}M traffic...
    ${times}    Evaluate    int(${mbps}/${175})
    Run Keyword If    ${times}==${0} or '${mbps}'=='175'     ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id} dir=dl mbps\=${mbps} trf_id\=${trf_id}
    ...    ELSE    Start SA UE Big DL Traffic Internal    ${ue_id}    ${mbps}    ${pdu_id}    ${trf_id}    ${qfi_id}
    Sleep    ${sleep_time}    reason=wait DL traffic is stable

SA Start UL Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}=1    ${qfi_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Start UL Traffic | 1 | 2 | 10 |
    Log To Console    \nStart UE${ue_id} UL ${mbps}M traffic...
    ${times}    Evaluate    int(${mbps}/${175})
    Run Keyword If    ${times}==${0} or '${mbps}'=='175'     ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id} dir=ul mbps\=${mbps} trf_id\=${trf_id}
    ...    ELSE    Start SA UE Big UL Traffic Internal    ${ue_id}    ${mbps}    ${pdu_id}    ${trf_id}    ${qfi_id}
    Sleep    2s    reason=wait UL traffic is stable

SA Get UE Average Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${qfi}=1
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | pdu_id | Yes | bearer_id |
    ...    | dir | Yes | Direction of Traffic |
    ...    Example:
    ...    | NSA Get UE Average Traffic | 1 | 2 | ul |
    ...    | NSA Get UE Average Traffic | 1 | 2 | dl |
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} pdu\=${pdu_id} qfi=${qfi} dir\=${dir} dc_cell_group=all
    ...    pass_regexp=Average data rate    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${tp_delta}    Evaluate    ${avg}*0.000001
    [Return]    ${tp_delta}

SA Check UE Cell TPut On Target
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${target_tput}    ${qfi}=1
        ${act_tp}    SA Get UE Average Traffic Internal    ${ue_id}    ${pdu_id}    ${dir}    ${qfi}
        ${tp_delta}    Evaluate    ${act_tp}-${target_tput}
        Should Be True    ${tp_delta}>=0    UE${ue_id} ${dir}tput is ${act_tp}, not on target ${target_tput}
        Log To Console    UE${ue_id} ${dir}tput is on target: ${target_tput}Mb \n

SA Check UE L3 TPut In Target Range
    [Arguments]    ${ue_id}    ${dir}    ${target_tput}    ${rate}    ${pdu_id}=1    ${qfi}=1
        ${act_tp}    SA Get UE Average Traffic Internal    ${ue_id}    ${pdu_id}    ${dir}    ${qfi}
        ${target_low_tput}    Evaluate   ${target_tput}*(1-${rate})
        ${target_high_tput}    Evaluate   ${target_tput}*(1+${rate})
        Should Be True    ${target_high_tput}>=${act_tp}>=${target_low_tput}
        ...    UE${ue_id} ${dir}tput is ${act_tp}, not between ${target_low_tput} and ${target_high_tput}
        Log To Console    UE${ue_id} ${dir}tput is between ${target_low_tput} and ${target_high_tput} \n

SA Stop Data Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${dir}=bi
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir\=${dir}

SA Stop Data Traffic Internal With Dedicated Trf
    [Arguments]    ${ue_id}    ${trf_id}    ${pdu_id}=1    ${dir}=bi    ${qfi_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id} dir\=${dir} trf_id\=${trf_id}

Attach SA UE and Get Throughput
    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=100    ${ul_tp_set}=50    ${dl_tp_threshold}=5    ${ul_tp_threshold}=5
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
    ${dl_tp}    ${ul_tp}=    Wait Until Keyword Succeeds    3min    5s    SA UE Check Throughput    ${UE_ID}
    ...    ${dl_tp_threshold}    ${ul_tp_threshold}
    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
    [Teardown]    SA 5G Detach    ue_id=${UE_ID}
    [Return]    ${dl_tp}    ${ul_tp}

SA UE Check Throughput
    [Arguments]    ${UE_ID}=11    ${dl_tp_threshold}=5    ${ul_tp_threshold}=5    ${qfi}=1
    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl    qfi=${qfi}
    ${ul_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=ul    qfi=${qfi}
    log    DL Troughput is ${dl_tp}    console=True
    log    UL Troughput is ${ul_tp}    console=True
    ${tp_delta}    Evaluate    ${dl_tp}-${dl_tp_threshold}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${dl_tp_threshold}M \n
    ${tp_delta}    Evaluate    ${ul_tp}-${ul_tp_threshold}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${ul_tp_threshold}M \n
    [Return]    ${dl_tp}    ${ul_tp}


Start Multi SA UE Big DL Traffic Internal
    [Arguments]    ${ue_list}    ${mbps}
    [Documentation]    This keyword is to start multi UE big dl udp traffic which more than 175.
    FOR    ${ue_id}    IN    @{ue_list}
        Start SA UE Big DL Traffic Internal    ${ue_id}    ${mbps}
    END

SA Get Multi UE Average Traffic
    [Arguments]    ${dir}    ${ue_id}    ${tcpudp}=udp
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | dir | Yes | Direction of Traffic |
    ...    Example:
    ...    | SA Get Multi UE Average Traffic | ul | 1 | udp |
    ...    | SA Get Multi UE Average Traffic | dl | 3 | tcp |
    Run Keyword If    '${tcpudp}' == 'udp'    OperatingSystem.Run
    ...    ${IPERF_EGREP} /tmp/iperf_${dir}_UE${ue_id}.txt | awk '{print $(1)}' > ${OUTPUT DIR}/iperf_${dir}_parsed.txt
    Run Keyword If    '${tcpudp}' == 'tcp'    OperatingSystem.Run
    ...    ${IPERF_EGREP} /tmp/iperf_tcp_${dir}_UE${ue_id}.txt | awk '{print $(1)}' > ${OUTPUT DIR}/iperf_${dir}_parsed.txt
    ${output}    OperatingSystem.Run    cat ${OUTPUT DIR}/iperf_${dir}_parsed.txt
    ${add_tmp}    Set Variable    0
    ${packet_number}    Set Variable    0
    ${list}    Split String    ${output}    \n
    FOR    ${var}    IN    @{list}
         ${add_tmp}    Evaluate    ${var}+${add_tmp}
         ${packet_number}    Evaluate    ${packet_number}+1
    END
    ${avg}    Evaluate    ${add_tmp}/${packet_number}
    Log    The UE${ue_id}'s ${tcpudp} ${dir} Troughput is ${avg}M    console=True
    [Return]    ${avg}

CUDU L2 Send Action To GNB
    [Arguments]    ${ue_id}    ${testmode}    ${action}    ${profile_id}    ${scell}=${EMPTY}
    [Documentation]    This keyword is to
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${testmode} |  | bler/srs_uplink_beamforming/phr_override/csi_override... |
    ...    | ${action} |  | activate/deactivate |
    ...
    ...    Examples:
    ...    | CUDU L2 Send Action To GNB    ue_id=2    testmode=csi_override    action=activate    profile_id=11    scell=2 |
    ...    | CUDU L2 Send Action To GNB    ue_id=2    testmode=srs_uplink_beamforming    action=activate    profile_id=3 |
    Log To Console    set action=${testmode} ${action} to gnb...
    ${cmd_scell}    Catenate    ue_testmode_set_nr id=${ue_id} testmode=${testmode} action=${action}
    ...    profile_id=${profile_id} scell=${scell}
    ${cmd_noscell}    Catenate    ue_testmode_set_nr id=${ue_id} testmode=${testmode} action=${action}
    ...    profile_id=${profile_id}
    ${cmd}    Set Variable If    '${scell}'=='${EMPTY}'    ${cmd_noscell}    ${cmd_scell}
    ute_wtssim.Execute Egate Command    ${cmd}

Send OAI To GNB
    [Arguments]    ${ue_id}    ${operation}=on    ${reducedCCsDL}=31    ${reducedCCsUL}=31
    [Documentation]    This keyword is to send Overheating Assistance Information to GNB
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | YES | id for UE |
    ...    | ${operation} | No | on/off |
    ...    | ${reducedCCsDL} | No | 0..31 |
    ...    | ${reducedCCsUL} | No | 0..31 |
    ...
    ...    Examples:
    ...    | Send OAI To GNB     ue_id=2    operation=on    reducedCCsDL=31    reducedCCsUL=31 |
    Log To Console    start send Overheating Assistance Information to gnb...
    ${cmd}    Catenate    ue_assistance_send_nr ue_id=${ue_id} forOverheating=${operation} reducedCCsDL=${reducedCCsDL}
    ...    reducedCCsUL=${reducedCCsUL}
    ute_wtssim.Execute Egate Command    ${cmd}
    Sleep    1s

Triger UE Reestablishment
    [Arguments]    ${ue_id}=1    ${gnb_id}=2    ${cell_id}=1    ${cause}=otherFailure
    [Documentation]    This keyword is to Triger UE Reestablishment
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cause} |  | reconfigurationFailure/handoverFailure/otherFailure/spare1 |
    ${output}    Execute Egate Command And Wait For Data    cmd=ue_rrc_reestablish id=${ue_id} gnb=${gnb_id} cell=${cell_id} cause=${cause}
    ...    pass_regexp=rrcReconfigurationComplete
    [Return]    ${output}

Set BLER Testmode
    [Arguments]    ${profile_id}    ${ul_bler}=${EMPTY}    ${dl_bler}=${EMPTY}
    [Documentation]    This keyword is to set bler testmode
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${profile_id} | YES | profile_id |
    ...    | ${ul_bler} | No | value for ul bler, the default value is EMPTY |
    ...    | ${dl_bler} | No | value for dl bler, the default value is EMPTY |
    ...
    ...    Examples:
    ...    | Set BLER Testmode | profile_id=30 | ul_bler=950,950,950,950,950,950,950,950 |
    Log To Console    Set Value For BLER Testmode...
    ${cmd_ul_bler}    Set Variable    bler_testmode_nr profile_id=${profile_id} ul_bler=${ul_bler}
    ${cmd_dl_bler}    Set Variable    bler_testmode_nr profile_id=${profile_id} dl_bler=${dl_bler}
    ${cmd}    Set Variable If    '${ul_bler}'!='${EMPTY}'    ${cmd_ul_bler}    ${cmd_dl_bler}
    ute_wtssim.Execute Egate Command    ${cmd}

Set SRS Testmode
    [Arguments]    ${profile_id}=3    ${srsMode}=fixed    ${init_pos}=0
    [Documentation]    This keyword is to Set SRS Testmode
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${srsMode} |  | fixed/single/oneway/oscillating |
    ...    | ${init_pos} |  | 0..3 |
    Log To Console    Set UE SRS Testmode...
    ${cmd}    Catenate    ue_srs_beam_pos_nr profile_id=${profile_id} init_pos=${init_pos} srsMode=${srsMode}
    ute_wtssim.Execute Egate Command    ${cmd}

Set PHR Testmode
    [Arguments]    ${profile_id}=1    ${phr_mode}=Fixed    ${phr_start}=0    ${phr_min}=-23    ${phr_max}=40    ${phr_step_size}=0
    ...        ${phr_period}=1    ${pc_max}=0
    [Documentation]    This keyword is to Set PHR Testmode
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${phr_mode} |  | Fixed|Oneway|Oscillating |
    ...    | ${phr_start} |  | -33..40 |
    ...    | ${phr_min} |  | -33..40 |
    ...    | ${phr_max} |  | -33..40 |
    ...    | ${phr_step_size} |  | -63..63 |
    ...
    ...    Examples:
    ...    | Set PHR Testmode    profile_id=2    phr_mode=Fixed    phr_start=30    phr_max=23 |
    Log To Console    Set Value For PHR Testmode...
    ${cmd}    Catenate    phr_override_testmode_nr profile_id=${profile_id} phr_mode=${phr_mode} phr_start=${phr_start}
    ...    phr_min=${phr_min} phr_max=${phr_max} phr_step_size=${phr_step_size} phr_period=${phr_period} pc_max=${pc_max}
    ute_wtssim.Execute Egate Command    ${cmd}

Set CQI Testmode
    [Arguments]    ${profile_id}=3    ${cqi}=15    ${cqi_mode}=fixed    ${cqi_min}=1    ${cqi_max}=15    ${ri}=1
    [Documentation]    This keyword is to Set CQI Testmode
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cqi} |  | 0..15+ |
    ...    | ${cqi_mode} |  | real/fixed/varying/oneway/oscillating/overheating |
    ...    | ${cqi_min} |  | 0..15 |
    ...    | ${cqi_max} |  | 0..15 |
    ...    | ${ri} |  | 0..3+ |
    Log To Console    Set Value For CQI Testmode...
    ${cmd}    Catenate    csi_override_testmode_nr profile_id=${profile_id} cqi=${cqi} cqi_mode=${cqi_mode}
    ...    cqi_min=${cqi_min} cqi_max=${cqi_max} ri=${ri}
    ute_wtssim.Execute Egate Command    ${cmd}

UE Beamforming Profile For 6 Beams
    [Arguments]    ${ue_id}=3    ${scell_id}=2
    ${CMD_BC_PRF_1}    Set Variable
    ...    beam_control_testmode_nr profile_id=22 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ${CMD_BC_PRF_1_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=22
    ${CMD_BC_PRF_2}    Set Variable
    ...    beam_control_testmode_nr profile_id=23 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-70
    ${CMD_BC_PRF_2_DSP}    Set Variable
    ...    beam_control_testmode_nr profile_id=23
    ${CMD_TESTMODE_ATTACH}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=22 beamaction=attach scell=${scell_id}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_1}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_2}
    Log To Console    ******The BC profiles are set******
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_1_DSP}
    Log To Console    ******Beam Control Profile 1 Display: ******
    Log To Console    ${output}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${CMD_BC_PRF_2_DSP}
    Log To Console    ******Beam Control Profile 2 Display: ******
    Log To Console    ${output}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH}

Beam Switch For UE
    [Arguments]    ${ue_id}=3    ${profile_id}=23    ${scell_id}=2   
    ${CMD_TESTMODE_SWITCH}    Set Variable
    ...   ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${profile_id} beamaction=switch scell=${scell_id}
    Log To Console    ******Beam Control UE${ue_id} Switch to Profile ${profile_id} ******
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_SWITCH}

SA Check CA UE TPut Equal To Target
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}    ${target_tp}
    ${tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
    Should Be True    ${tput}==${target_tp}
    ...    msg=UE${ue_id} ${cell_type}${scell_index} tput is '${tput}'' not on target'${target_tp}'Mb
    Log To Console    \nUE${ue_id} ${cell_type} ${scell_index} ${dir} tput ${tput}Mb is on target: ${target_tp}Mb

SA Check Single CA UE DL TP Equal To Target
    [Arguments]    ${ue_id}    ${exp_dl_tput_list}    ${cc_num}
    [Documentation]    This keyword is to check all dl Pcell Scell TP of single ue once.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | YES |    id of ue |
    ...    | ${exp_dl_tput_list} | yes | the list for DL expected tput of ue pcell ,scell |
    ...    | ${cc_num} | yes | the num for how many cc |
    ...
    ...    Examples:
    ...    | ${ue_id} |    | 1 |
    ...    | @{exp_dl_tput_list} |    | 200 | 100 | 100 |
    ...    | Check UE DL All Pcell Scell TP On Target For Single UE | ${ue_id} | ${exp_dl_tput_list} | 3 |
    ...
    FOR    ${id}    IN RANGE    ${cc_num}
    Run Keyword If    ${id}==${0}    SA Check CA UE TPut Equal To Target
    ...    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${exp_dl_tput_list[0]}
    ...    ELSE    SA Check CA UE TPut Equal To Target
    ...    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=${id}    target_tp=${exp_dl_tput_list[${id}]}
    END

SA Check UE Cell TPut Equal To Target
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${target_tput}    ${qfi}=1
    ${act_tp}    SA Get UE Average Traffic Internal    ${ue_id}    ${pdu_id}    ${dir}    ${qfi}
    ${tp_delta}    Evaluate    ${act_tp}-${target_tput}
    Should Be True    ${tp_delta}==0    UE${ue_id} ${dir}tput is ${act_tp}, not on target ${target_tput}
    Log To Console    UE${ue_id} ${dir}tput is on target: ${target_tput}Mb \n

SA Check CA Multi UE Cell Average DL Tput Equal To Target
    [Arguments]    ${ue_id_list}    ${exp_dl_tput_list}    ${cc_num}
    FOR    ${ue_id}    IN    @{ue_id_list}
        SA Check Single CA UE DL TP Equal To Target    ${ue_id}    ${exp_dl_tput_list}    ${cc_num}
    END

SA Check Single CA UE UL TP Equal To Target
    [Arguments]    ${ue_id}    ${exp_ul_tput_list}    ${cc_num}
    [Documentation]    This keyword is to check all Ul Pcell Scell TP of single ue once.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | YES |    id of ue |
    ...    | ${exp_dl_tput_list} | yes | the list for UL expected tput of ue pcell ,scell |
    ...    | ${cc_num} | yes | the num for how many cc |
    ...
    ...    Examples:
    ...    | ${ue_id} |    | 1 |
    ...    | @{exp_dl_tput_list} |    | 200 | 100 | 100 |
    ...    | SA Check Single CA UE UL TP Equal To Target | ${ue_id} | ${exp_dl_tput_list} | 3 |
    ...
    FOR    ${id}    IN RANGE    ${cc_num}
    Run Keyword If    ${id}==${0}    SA Check CA UE TPut Equal To Target
    ...    ue_id=${ue_id}    dir=ul    cell_type=pcell    scell_index=0    target_tp=${exp_ul_tput_list[0]}
    ...    ELSE    SA Check CA UE TPut Equal To Target
    ...    ue_id=${ue_id}    dir=ul    cell_type=scell    scell_index=${id}    target_tp=${exp_ul_tput_list[${id}]}
    END

SA Check CA Multi UE Cell Average UL Tput Equal To Target
    [Arguments]    ${ue_id_list}    ${exp_ul_tput_list}    ${cc_num}
    FOR    ${ue_id}    IN    @{ue_id_list}
        SA Check Single CA UE UL TP Equal To Target    ${ue_id}    ${exp_ul_tput_list}    ${cc_num}
    END

SA Check NonCA Multi UE Cell Dl TPut Equal To Target
    [Arguments]    ${ue_id_list}    ${target_tput_list}    ${qfi}=1
    FOR    ${ue_id}    ${target_tput}    IN ZIP    ${ue_id_list}    ${target_tput_list}
        SA Check UE Cell TPut Equal To Target    ${ue_id}    1    dl    ${target_tput}    ${qfi}
    END

SA Check NonCA Multi UE Cell Dl Tput On Target
    [Arguments]    ${ue_id_list}    ${target_tput_list}
    FOR    ${ue_id}    ${targer_tput}    IN ZIP    ${ue_id_list}    ${target_tput_list}
        SA Check UE Cell TPut On Target    ${ue_id}    1    dl    ${targer_tput}
    END
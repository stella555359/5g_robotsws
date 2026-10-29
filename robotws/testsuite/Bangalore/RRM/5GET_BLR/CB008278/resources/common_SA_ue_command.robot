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
    [Arguments]    ${ue_id}    ${mbps}    ${pdu_id}=1    ${trf_id}=1
    [Documentation]    This keyword is to start single UE big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
        ${tmp_trf_id}    Evaluate    ${trf_id}+${t_time}-1
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=dl mbps\=175 trf_id\=${tmp_trf_id}
        Log To Console    \nUE${ue_id} Start DL 175M Traffic for trf_id=${tmp_trf_id}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
    ${last_trf_id}    Evaluate    ${trf_id}+${dl_times}
    Run Keyword If    '${last_mbps}'!='0'    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=dl mbps\=${last_mbps} trf_id\=${last_trf_id}
    Run Keyword If    '${last_mbps}'!='0'    Log To Console    \nUE${ue_id} Start DL ${last_mbps}M Traffic for trf_id=${last_trf_id}

Start SA UE Big UL Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${pdu_id}=1    ${trf_id}=1
    [Documentation]    This keyword is to start single UE big dl udp traffic which more than 175.
    ${ul_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${ul_times}+1
        ${tmp_trf_id}    Evaluate    ${trf_id}+${t_time}-1
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=ul mbps\=175 trf_id\=${tmp_trf_id}
        Log To Console    \nUE${ue_id} Start UL 175M Traffic for trf_id=${tmp_trf_id}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${ul_times}
    ${last_trf_id}    Evaluate    ${trf_id}+${ul_times}
    Run Keyword If    '${last_mbps}'!='0'    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=ul mbps\=${last_mbps} trf_id\=${last_trf_id}
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
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}=1
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
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=dl mbps\=${mbps} trf_id\=${trf_id}
    ...    ELSE    Start SA UE Big DL Traffic Internal    ${ue_id}    ${mbps}    ${pdu_id}    ${trf_id}
    Sleep    2s    reason=wait DL traffic is stable

SA Start UL Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}=1
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
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=ul mbps\=${mbps} trf_id\=${trf_id}
    ...    ELSE    Start SA UE Big UL Traffic Internal    ${ue_id}    ${mbps}    ${pdu_id}    ${trf_id}
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
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${tp_delta}    Evaluate    ${avg}*0.000001
    [Return]    ${tp_delta}

SA Check UE Cell TPut On Target
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${target_tput}    ${qfi}=1
        ${act_tp}    SA Get UE Average Traffic Internal    ${ue_id}    ${pdu_id}    ${dir}
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
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}=bi
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir=${dir}

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


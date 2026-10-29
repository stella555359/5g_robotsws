*** Keywords ***
NSA LTE Attach
    [Arguments]    ${ue_id}    ${profile_id}=1
    [Documentation]    This keyword is used to simulate UE attach on LTE side during NSA L3 Call on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | profile_id | Yes | profile id |
    ...    Example:
    ...    | NSA LTE Attach | 1 | 1 |
    Log To Console    start LTE attach...
    ${output}    ute_wtssim.Execute Egate Command
    ...    cmd=ue_attach id\=${ue_id}    pass_regexp=UE IS ACTIVE    timeout=300
    Log To Console    lte_attach_is_ok
    Sleep    3s    reason=wait LTE attach is stable
    [Return]    ${output}

NSA 5G Attach
    [Arguments]    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}
    [Documentation]    This keyword is used to simulate UE attach on 5GNR side during NSA L3 Call on eGate.
    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 2 ) reported successful RA" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | gnb_id | Yes | gnb id |
    ...    | cell_id | Yes | cell id |
    ...    | bearer_id | Yes | bearer id |
    ...    Example:
    ...    | NSA 5G Attach | 1 | 2 | 2 | 2 |
    Log To Console    start 5G attach...
    ${output}=    ute_wtssim.Execute Egate Command
    ...    cmd=ue_dc_enb_start ue\=${ue_id} target_gnb\=${gnb_id} target_cells\=${cell_id} bearer\=${bearer_id} type\=split_scg
    ...    pass_regexp=reported successful RA|Proxy reported failure    timeout=300
    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    reported successful RA
    Run Keyword If    "${ret}"=="${False}"    Fail    NSA 5G Attach fails!!!
    Should Be True    ${ret}
    Log To Console    UE_attach_is_ok
    Sleep    3s    reason=wait 5G attach is stable
    [Return]    ${output}

NSA 5G Attach 2
    [Arguments]    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}    ${timeout}=8    ${bip}=yes
    [Documentation]    This keyword is used to simulate UE attach on 5GNR side during NSA L3 Call on eGate.
    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 2 ) reported successful RA" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | gnb_id | Yes | gnb id |
    ...    | cell_id | Yes | cell id |
    ...    | bearer_id | Yes | bearer id |
    ...    Example:
    ...    | NSA 5G Attach | 1 | 2 | 2 | 2 |
    Log To Console    start 5G attach...
    Run Keyword And Ignore Error    Run Keyword If    "${bip}"=="yes"    Start Gnb BIP Log
    ${output}=    ute_wtssim.Execute Egate Command
    ...    cmd=ue_dc_enb_start ue\=${ue_id} target_gnb\=${gnb_id} target_cells\=${cell_id} bearer\=${bearer_id} type\=split_scg
    ...    pass_regexp=reported successful RA|Proxy reported failure    timeout=${timeout}
    Run Keyword And Ignore Error    Run Keyword If    "${bip}"=="yes"    Stop Gnb BIP Log    ${OUTPUT_DIR}/bip_attach/
    Run Keyword And Ignore Error    Run Keyword If    "${bip}"=="yes"    Check Msg1 To Msg4 In BIP Log
    Should Match Regexp     ${output}    reported successful RA
    Log To Console    UE_attach_is_ok
    Sleep    3s    reason=wait 5G attach is stable
    [Return]    ${output}

Check Msg1 To Msg4 In BIP Log
    ${lua_shark}=    Set Variable    /opt/luashark/generated_luashark/luashark.lua
    ${pcap_fie}=    Set Variable    5GBipL2L1_filtering_off.pcap0
    ${msg1-msg4}=    Catenate    uldata_prachreceiveind || dldata_pdcchsendreq || dldata_pdschsendreq ||
    ...    dldata_pdschpayloadtbsendreq ||uldata_puschreceivereq
    ...    || uldata_puschreceiverespps || uldata_puschreceiveresplo || uldata_puschreceiverespharqu
    OperatingSystem.Run    cd ${OUTPUT_DIR}/bip_attach/;tshark -r "${pcap_fie}" -X lua_script:${lua_shark} -Y "${msg1-msg4}" -w small.pcap
    OperatingSystem.Run    cd ${OUTPUT_DIR}/bip_attach/;tshark -r "${pcap_fie}" -X lua_script:${lua_shark} -Y "${msg1-msg4}" > test.txt
    OperatingSystem.Run    cd ${OUTPUT_DIR}/bip_attach/;tshark -r "${pcap_fie}" -X lua_script:${lua_shark} -Y "${msg1-msg4}" -T json> test4.json
    ${ret}=    ATTACH_ISSUE_ANALYZER.analyze_file    ${OUTPUT_DIR}/bip_attach/test.txt
    Set Test Message    ${ret}
    OperatingSystem.Run    grep "UlData_PuschReceiveRespHarqU.grants_item_15.dtx" ${OUTPUT_DIR}/bip_attach/test4.json

NSA Verify If Attach Passed
    [Documentation]    varify if 5G attach is passed in APL3.Log
    Log To Console    varify if 5G attach is passed in APL3.Log...
    ${succ_msg}     Set Variable    Sm User Ue Connection Established Ind message status OK
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh toor4nsn@${AP_ASIK.ip} 'cat /tmp/APL3.log |grep "${succ_msg}"'
    Should Contain    ${output}    ${succ_msg}

NSA LTE Detach
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to detach ue.
    ute_wtssim.Execute Egate Command    cmd=ue_detach id\=${ue_id}    pass_regexp=detached

NSA Start DL Traffic
    [Arguments]    ${ue_id}    ${bearer_id}    ${mbps}    ${trf_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Start DL Traffic | 1 | 2 | 10 |
    Log To Console    start DL traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir=dl mbps\=${mbps} trf_id\=${trf_id}
    Sleep    5s    reason=wait DL traffic is stable

NSA Start UL Traffic
    [Arguments]    ${ue_id}    ${bearer_id}    ${mbps}    ${trf_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Start UL Traffic | 1 | 2 | 10 |
    Log To Console    start UL traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir=ul mbps\=${mbps} trf_id\=${trf_id}
    Sleep    5s    reason=wait UL traffic is stable

NSA Start DL Small Traffic
    [Arguments]    ${ue_id}    ${bearer_id}    ${kbps}    ${trf_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | kbps | Yes | kbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Start DL Traffic | 1 | 2 | 10 |
    Log To Console    start DL Small traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir=dl kbps\=${kbps} trf_id\=${trf_id}
    Sleep    3s    reason=wait DL traffic is stable

NSA Start UL Small Traffic
    [Arguments]    ${ue_id}    ${bearer_id}    ${kbps}    ${trf_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | kbps | Yes | kbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Start UL Traffic | 1 | 2 | 10 |
    Log To Console    start UL Small traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir=ul kbps\=${kbps} trf_id\=${trf_id}
    Sleep    3s    reason=wait UL traffic is stable

NSA Stop Traffic
    [Arguments]    ${ue_id}    ${bearer_id}    ${dir}    ${trf_id}=1
    [Documentation]    This keyword is to stop traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | dir | Yes | ul or dl |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Stop Traffic | 1 | 2 | dl |
    Log To Console    stop ${dir} traffic...\n
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} id\=${bearer_id} dir\=${dir} trf_id\=${trf_id}

NSA Get Average Throughput
    [Arguments]    ${ue_id}    ${bearer_id}    ${dir}
    [Documentation]    This keyword is to get the average tput from egate
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue id |
    ...    | ${bearer_id} | Yes | bearer id for the UE |
    ...    | ${dir} | Yes | dl/ul |
    ...
    ...    Examples:
    ...    | NSA Get Avg Tput | 1 | 2 | dl |
    ...
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} id\=${bearer_id} dir\=${dir}
    ...    pass_regexp=Average packet interval    timeout=150
    ${arg_tput_list}    String.Get Regexp Matches    ${output}    Average data rate\\s+\\d+\\s+\\((?P<tput>\\d+\\.\\d+)\\s+M\\)    tput
    [Return]    @{arg_tput_list}[0]

NSA Check Average Traffic Range 10 Percent On Target
    [Arguments]    ${ue_id}    ${bearer_id}    ${dir}    ${tp_rate}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | dir | Yes | Direction of Traffic |
    ...    | tp_rate | Yes | Throughput Rate for traffic |
    ...    Example:
    ...    | NSA Check Average Traffic range 10 percent on target | 1 | 2 | ul | 10 |
    ...    | NSA Check Average Traffic range 10 percent on target | 1 | 2 | dl | 10 |
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} id\=2 dir\=${dir}
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${tp_delta}    Evaluate    abs(${tp_rate}-${avg}*0.000001)
    ${tp_threshold}    Evaluate    ${tp_rate}*0.1
    Should Be True    ${tp_delta}<${tp_threshold}    Throughtput is not in the accetable range

NSA Check Average Traffic Bigger Than Target
    [Arguments]    ${ue_id}    ${bearer_id}    ${dir}    ${tp_rate}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | dir | Yes | Direction of Traffic |
    ...    | tp_rate | Yes | Throughput Rate for traffic |
    ...    Example:
    ...    | NSA Check Average Traffic bigger than target | 1 | 2 | ul | 10 |
    ...    | NSA Check Average Traffic bigger than target | 1 | 2 | dl | 10 |
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} id\=2 dir\=${dir}
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${mavg}    Evaluate    ${avg}*0.000001
    Log To Console    \n The average ${dir} tput is: ${mavg}M \n
    ${tp_delta}    Evaluate    ${avg}*0.000001-${tp_rate}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${tp_rate}M \n

NSA Check Average Traffic Smaller Than Target
    [Arguments]    ${ue_id}    ${bearer_id}    ${dir}    ${tp_rate}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | dir | Yes | Direction of Traffic |
    ...    | tp_rate | Yes | Throughput Rate for traffic |
    ...    Example:
    ...    | NSA Check Average Traffic smaller than target | 1 | 2 | ul | 10 |
    ...    | NSA Check Average Traffic smaller than target | 1 | 2 | dl | 10 |
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} id\=2 dir\=${dir}
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${tp_delta}    Evaluate    ${avg}*0.000001-${tp_rate}
    Should Be True    ${tp_delta}<=0    Throughtput is not in the accetable range

NSA Get UE Average Traffic
    [Arguments]    ${ue_id}    ${bearer_id}    ${dir}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | dir | Yes | Direction of Traffic |
    ...    Example:
    ...    | NSA Get UE Average Traffic | 1 | 2 | ul |
    ...    | NSA Get UE Average Traffic | 1 | 2 | dl |
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} id\=2 dir\=${dir}
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${tp_delta}    Evaluate    ${avg}*0.000001
    [Return]    ${tp_delta}

NSA MultiUE Attach And Do Traffic
    [Arguments]    ${max_ue_num}    ${ue_info}
    [Documentation]    This keyword is to do NSA multi UE attach and do DL/UL traffic
    ...              for NSA, UE_id from 101 to 200
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${max_ue_num} | Yes | the number of multi UE |
    ...    | ${ue_info} | Yes | the directory for setting UE info. |
    ...
    ...    Examples:
    ...    1. both UL and DL --- kbps
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | Create Dictionary | profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=100M | ul_traffic=10m |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ...
    ...    2. both UL and DL --- mbps
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | \ Create Dictionary | profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=100k | ul_traffic=10k |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ...
    ...    3. only UL or DL
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | Create Dictionary | profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=0 | ul_traffic=10k |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ...    or
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | Create Dictionary | \ profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=10m | ul_traffic=0 |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ${ul_traffic_type}    Run Keyword If    '${ue_info.ul_traffic}'!='0'    Evaluate    '${ue_info.ul_traffic}'[-1]
    ${dl_traffic_type}    Run Keyword If    '${ue_info.dl_traffic}'!='0'    Evaluate    '${ue_info.dl_traffic}'[-1]
    ${dl_type}    Run Keyword If    '${dl_traffic_type}'!='None'    String.Convert To Lowercase    ${dl_traffic_type}
    ${ul_type}    Run Keyword If    '${ul_traffic_type}'!='None'    String.Convert To Lowercase    ${ul_traffic_type}
    ${ul_traffic_value}    Run Keyword If    '${ul_type}'!='None'    Evaluate    '${ue_info.ul_traffic}'[0:-1]
    ${dl_traffic_value}    Run Keyword If    '${dl_type}'!='None'    Evaluate    '${ue_info.dl_traffic}'[0:-1]
    : FOR    ${ue_id}    IN RANGE    101    ${max_ue_num}+101
    \    NSA LTE Attach    ${ue_id}    ${ue_info.profile_id}
    \    NSA 5G Attach    ${ue_id}    ${ue_info.gnb_id}    ${ue_info.cell_id}    ${ue_info.bearer_id}
    \    NSA Verify If Attach Passed
    \    Run Keyword If    '${ul_type}'=='m'    NSA Start UL Traffic    ${ue_id}    ${ue_info.bearer_id}    ${ul_traffic_value}
    ...    ELSE IF    '${ul_type}'=='k'    NSA Start UL Small Traffic    ${ue_id}    ${ue_info.bearer_id}    ${ul_traffic_value}
    \    Run Keyword If    '${dl_type}'=='m'    NSA Start DL Traffic    ${ue_id}    ${ue_info.bearer_id}    ${dl_traffic_value}
    ...    ELSE IF    '${dl_type}'=='k'    NSA Start DL Small Traffic    ${ue_id}    ${ue_info.bearer_id}    ${dl_traffic_value}

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
    ...    ue_register id\=${ue_id}    pass_regexp=REGISTRATION COMPLETE    timeout=3minutes
    ${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    Log To Console    \n${output1}
    Should Match Regexp    ${output}    Initial UE Message .*Success
    Sleep    3s    reason=wait 5G attach is stable

SA 5G PDU Session Setup
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

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

SA Set Traffic Type To Internal
    [Arguments]    ${ue_id}    ${pdu_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=set_pdu_param ue\=${ue_id} pdu\=${pdu_id} trf_type=internal

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
    Log To Console    start DL traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=dl mbps\=${mbps} trf_id\=${trf_id}
    Sleep    5s    reason=wait DL traffic is stable

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
    Log To Console    start UL traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=ul mbps\=${mbps} trf_id\=${trf_id}
    Sleep    5s    reason=wait UL traffic is stable

SA Get UE Average Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | pdu_id | Yes | bearer_id |
    ...    | dir | Yes | Direction of Traffic |
    ...    Example:
    ...    | NSA Get UE Average Traffic | 1 | 2 | ul |
    ...    | NSA Get UE Average Traffic | 1 | 2 | dl |
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir\=${dir}
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${tp_delta}    Evaluate    ${avg}*0.000001
    [Return]    ${tp_delta}

SA Stop Data Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir=bi

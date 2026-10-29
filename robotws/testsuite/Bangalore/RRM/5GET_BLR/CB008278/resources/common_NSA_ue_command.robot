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
    Start Gnb BIP Log
    ${output}=    ute_wtssim.Execute Egate Command
    ...    cmd=ue_dc_enb_start ue\=${ue_id} target_gnb\=${gnb_id} target_cells\=${cell_id} bearer\=${bearer_id} type\=split_scg
    ...    pass_regexp=reported successful RA|Proxy reported failure    timeout=${timeout}
    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    reported successful RA
    Run Keyword If    "${ret}"=="${False}"    Fail    NSA 5G Attach fails!!!
    Should Be True    ${ret}
    Log To Console    UE_attach_is_ok
    Sleep    3s    reason=wait 5G attach is stable
    [Teardown]    Run Keywords    Stop Gnb BIP Log    ${OUTPUT_DIR}/bip_attach/
    ...    AND    Check Msg1 To Msg4 In BIP Log
    [Return]    ${output}

Check Msg1 To Msg4 In BIP Log By MCShark
    ${pcap_fie}=    Set Variable    5GBipL2L1_filtering_off.pcap0
    ${msg1-msg4}=    Catenate    uldata_prachreceiveind || dldata_pdcchsendreq || dldata_pdschsendreq ||
    ...    dldata_pdschpayloadtbsendreq ||uldata_puschreceivereq
    ...    || uldata_puschreceiverespps || uldata_puschreceiveresplo || uldata_puschreceiverespharqu
    OperatingSystem.Run
    ...    cd ${OUTPUT_DIR}/bip_attach/;tshark -r "${pcap_fie}" -Y "${msg1-msg4}" -w small_gnb.pcap
    OperatingSystem.Run
    ...    cd ${OUTPUT_DIR}/bip_attach/;tshark -r "${pcap_fie}" -Y "${msg1-msg4}" > test_gnb.txt
    OperatingSystem.Run
    ...    cd ${OUTPUT_DIR}/bip_attach/;tshark -r "${pcap_fie}" -Y "${msg1-msg4}" -T json> test_gnb.json
    ${ret}=    ATTACH_ISSUE_ANALYZER.analyze_file    ${OUTPUT_DIR}/bip_attach/test_gnb.txt
    Set Test Message    ${ret}

Check Msg1 To Msg4 In BIP Log
    ${lua_shark_gnb}=    Set Variable    /opt/luashark/generated_luashark/luashark.lua
    ${lua_shark_ap}=    Set Variable    /opt/luashark_ap/l1_REL_LOKI_UE/luashark.lua
    ${pcap_fie}=    Set Variable    5GBipL2L1_filtering_off.pcap0
    ${msg1-msg4}=    Catenate    uldata_prachreceiveind || dldata_pdcchsendreq || dldata_pdschsendreq ||
    ...    dldata_pdschpayloadtbsendreq ||uldata_puschreceivereq
    ...    || uldata_puschreceiverespps || uldata_puschreceiveresplo || uldata_puschreceiverespharqu
    OperatingSystem.Run
    ...    cd ${OUTPUT_DIR}/bip_attach/;tshark -r "${pcap_fie}" -X lua_script:${lua_shark_gnb} -Y "${msg1-msg4}" -w small_gnb.pcap
    OperatingSystem.Run
    ...    cd ${OUTPUT_DIR}/bip_attach/;tshark -r "${pcap_fie}" -X lua_script:${lua_shark_gnb} -Y "${msg1-msg4}" > test_gnb.txt
    OperatingSystem.Run
    ...    cd ${OUTPUT_DIR}/bip_attach/;tshark -r "${pcap_fie}" -X lua_script:${lua_shark_gnb} -Y "${msg1-msg4}" -T json> test_gnb.json
    ${ret}=    ATTACH_ISSUE_ANALYZER.analyze_file    ${OUTPUT_DIR}/bip_attach/test_gnb.txt
    Set Test Message    ${ret}

Check Msg1 To Msg4 In Airphone BIP Log
    ${msg1_ap}=    Set Variable    sw_uldataue_prachsendreq
    OperatingSystem.Run
    ...    cd ${OUTPUT_DIR}/bip_attach/ap_bip/;tshark -r "${pcap_fie}" -X lua_script:${lua_shark_ap} -Y "${msg1_ap}" -w small_ap.pcap
    OperatingSystem.Run    grep "UlData_PuschReceiveRespHarqU.grants_item_15.dtx" ${OUTPUT_DIR}/bip_attach/test4.json
    OperatingSystem.Run
    ...    cd ${OUTPUT_DIR}/bip_attach/ap_bip/;tshark -r "${pcap_fie}" -X lua_script:${lua_shark_ap} -Y "${msg1_ap}" > test_ap.txt
    OperatingSystem.Run
    ...    cd ${OUTPUT_DIR}/bip_attach/ap_bip/;tshark -r "${pcap_fie}" -X lua_script:${lua_shark_ap} -Y "${msg1_ap}" -T json> test_ap.json

NSA Verify If Attach Passed
    [Documentation]    varify if 5G attach is passed in APL3.Log
    Log To Console    varify if 5G attach is passed in APL3.Log...
    ${succ_msg}     Set Variable    Sm User Ue Connection Established Ind message status OK
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh toor4nsn@${AP_ASIK.ip} 'cat /tmp/APL3.log |grep "${succ_msg}"'
#    Should Contain    ${output}    ${succ_msg}

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
    ...    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir=dl mbps\=${mbps} trf_id\=${trf_id} seconds=9999
    Sleep    5s    reason=wait DL traffic is stable

NSA Start DL Traffic Mmwave
    [Arguments]    ${ue_id}    ${bearer_id}    ${mbps}    ${trf_id}=1    ${size}=4000
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
    ...    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir=dl mbps\=${mbps} trf_id\=${trf_id} size\=${size}
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
    ...    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir=ul mbps\=${mbps} trf_id\=${trf_id} seconds=9999
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
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} id\=${bearer_id} dir\=${dir} dc_cell_group=all
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
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} id\=2 dir\=${dir} dc_cell_group=all
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
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} id\=2 dir\=${dir} dc_cell_group=all
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
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} id\=2 dir\=${dir} dc_cell_group=all
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
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} id\=2 dir\=${dir} dc_cell_group=all
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

Attach NSA UE and Get Throughput
    [Arguments]    ${UE_ID}=11    ${dl_tp_set}=100    ${ul_tp_set}=50    ${dl_tp_threshold}=5    ${ul_tp_threshold}=5
    NSA LTE Attach    ue_id=${UE_ID}    profile_id=1
    NSA 5G Attach    ue_id=${UE_ID}    gnb_id=2    cell_id=1    bearer_id=2
    NSA Start DL Traffic    ue_id=${UE_ID}    bearer_id=2    mbps=${dl_tp_set}    trf_id=1
    NSA Start UL Traffic    ue_id=${UE_ID}    bearer_id=2    mbps=${ul_tp_set}    trf_id=1
    Wait Until Keyword Succeeds    3min    5s    NSA UE Check Throughput    ${UE_ID}    ${dl_tp_threshold}    ${ul_tp_threshold}
    [Teardown]    NSA LTE Detach    ue_id=${UE_ID}

NSA UE Check Throughput
    [Arguments]    ${UE_ID}=11    ${dl_tp_threshold}=5    ${ul_tp_threshold}=5
    ${dl_tp}=    NSA Get UE Average Traffic    ue_id=${UE_ID}    bearer_id=2    dir=dl
    ${ul_tp}=    NSA Get UE Average Traffic    ue_id=${UE_ID}    bearer_id=2    dir=ul
    log    DL Troughput is ${dl_tp}    console=True
    log    UL Troughput is ${ul_tp}    console=True
    ${tp_delta}    Evaluate    ${dl_tp}-${dl_tp_threshold}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${dl_tp_threshold}M \n
    ${tp_delta}    Evaluate    ${ul_tp}-${ul_tp_threshold}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${ul_tp_threshold}M \n

NSA Start DL Big Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
    [Documentation]    this keyword is to start big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${175})
    : FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
    \    NSA Start DL Traffic    ${ue_id}    ${BEAR_ID}    mbps=175    trf_id=${t_time}
    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
    NSA Start DL Traffic    ${ue_id}    ${BEAR_ID}    mbps=${last_mbps}    trf_id=${dl_times+1}
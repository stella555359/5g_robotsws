*** Settings ***

*** Keywords ***
Start Edaemon Egate And Load Cfg
    [Documentation]    This keyword is to kill Running WTS Binaries If Any, Configure ETH3, Retrieve Files And Configure WTS
    Log To Console    Starting WTS...
    Run Keyword And Ignore Error    Stop Edaemon Egate
    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}     save_egate=${True}
    ute_wtssim.Start Egate Process
    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${WTS_CFG}
    ...    pass_regexp=(SimMode is ready now|UEC-1 is active)      timeout=3minutes

Clean Edaemon And Egate
    ute_wtssim.Teardown Edaemon    alias=edaemon
    ute_wtssim.Teardown Egate

Stop Edaemon Egate
    Run Keyword And Ignore Error    Clean Edaemon And Egate
    OperatingSystem.Run    sudo pkill edaemon
    OperatingSystem.Run    sudo pkill egate
    OperatingSystem.Run    sudo pkill 22222
    OperatingSystem.Run    sudo pkill 20000

Setup X2 Connection
    [Arguments]    ${enb_id}=1    ${gnb_id}=2
    [Documentation]    This keyword is to setup X2 connection and check x2 is ok
    Log To Console    setup X2 connection...
    ${pattern}    Set Variable    ENB-${enb_id}: X2AP Link with GNB-${gnb_id} .* is up
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_x2_link_up enb\=${enb_id} target\=${gnb_id}
    ...    pass_regexp=${pattern}    timeout=5min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    x2_is_ok

Check AP Board All Ready
    Log To Console    --> Check AP Board All Ready
    ute_fsmaccess.setup_wts_fsm_access    host=192.168.200.129    user=toor4nsn    password=oZPS0POrRieRtu    port=22    alias=sshap
    ${cmd}    Set Variable    export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s -n 0x5011 -p 15004
    ${AP_Board_Status}=    ute_fsmaccess.execute_command_on_wts    cmd=${cmd}    alias=sshap
    ute_fsmaccess.teardown_wts_fsm_access    alias=sshap
    should_contain_x_times    item1=${AP_Board_Status}    item2=ready    count=10

Check All Cells Received SIB2
    ${cell_num_cfg}=    Get Cell Number From Cfg
    ${cell_num_vcu}=    VCU Get Cell Numbers
    ${cell_num}=    Set Variable If    ${cell_num_cfg}<${cell_num_vcu}    ${cell_num_cfg}    ${cell_num_vcu}
    ${egate_file}    Set Variable    /opt/iphy/latest/egate_console.log
    Wait Until Keyword Succeeds    120s    10s    Check Egate Log With Message    ${egate_file}
    ...    SystemInformationBlockType2-NR updated    ${cell_num}

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
    ...    ue_register id\=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE from UE with RAN UE NGAP ID    timeout=3minutes
    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    REGISTRATION COMPLETE
    Run Keyword If    "${ret}"=="${False}"    Fail    SA 5G Attach fails!!!
    Should Be True    ${ret}
    ${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    Log To Console    \n${output1}
    Should Match Regexp    ${output}    Initial UE Message .*Success
    Sleep    3s    reason=wait 5G attach is stable

SA Set Traffic Type To Internal
    [Arguments]    ${ue_id}    ${pdu_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=set_pdu_param ue\=${ue_id} pdu\=${pdu_id} trf_type=internal

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

SA Start DL Traffic Internal
    [Arguments]    ${ue_id}     ${mbps}   ${pdu_id}=1    ${trf_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    Log To Console    start DL traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=dl mbps\=${mbps} trf_id\=${trf_id}
    Sleep    5s    reason=wait DL traffic is stable

SA Start UL Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${pdu_id}=1    ${trf_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    Log To Console    start UL traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=ul mbps\=${mbps} trf_id\=${trf_id}
    Sleep    5s    reason=wait UL traffic is stable

SA Get UE Average Traffic Internal
    [Arguments]    ${ue_id}    ${dir}    ${pdu_id}=1
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | pdu_id | Yes | bearer_id |
    ...    | dir | Yes | Direction of Traffic |
    ...    Example:
    ...    | NSA Get UE Average Traffic | 1 | 2 | ul |
    ...    | NSA Get UE Average Traffic | 1 | 2 | dl |
    ${output}    ute_wtssim.Execute Egate Command    cmd=qfi_stats ue\=${ue_id} pdu\=${pdu_id} qfi\=1 dir\=${dir}
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${tp_delta}    Evaluate    ${avg}*0.000001
    [Return]    ${tp_delta}

SA Get Average Throughput_bearer_stats
    [Arguments]    ${ue_id}   ${pdu}    ${qfi}    ${dir}
    [Documentation]    This keyword is to get the average tput from egate
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue id |
    ...    | ${pdu} | Yes | pdu id for the UE |
    ...    | ${qfi} | Yes | qfi |
    ...    | ${dir} | Yes | dl/ul |
    ...
    ...    Examples:
    ...    | SA Get Average Throughput_bearer_stats | 1 | 2 | dl |
    ...
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} pdu\=${pdu} qfi\=${qfi} dir\=${dir}
    ...    pass_regexp=Average packet interval    timeout=150
    ${arg_tput_list}    String.Get Regexp Matches    ${output}    Average data rate\\s+\\d+\\s+\\((?P<tput>\\d+\\.\\d+)\\s+M\\)    tput
    [Return]    @{arg_tput_list}[0]

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


Get CA Cell Average Throughput
    [Arguments]    ${ue_id}    ${dir}    ${scell_index}
    [Documentation]    This keyword is to get Pcell/Scell Average throughput,1Mbps=1000Kbps
    ...    The unit of return throughput is Mbps.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id |
    ...    | ${dir} | Yes | dl/ul |
    ...    | ${scell_index} | Yes | 1/2/3...|
    ...
    ...    | Examples: |
    ...    | ${pcell_tput} | Get CA Cell Average Throughput | 1 | dl  | 0 |
    ...    | ${scell1_tput} | Get CA Cell Average Throughput | 1 | dl | 1 |
    ...    | ${scell2_tput} | Get CA Cell Average Throughput | 1 | ul | 2 |
    ...
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=${type} scell\=${scell_index}
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    ${cell_tp}=    Evaluate    sum(map(float,${avg_tp_list}))
    ${cell_tp}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
    ${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
    ${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
    Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
    ${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
    ${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
    ...                                     '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
    ...                                     ${cell_tp}
    [Return]    ${cell_tput_Mbps}

Check CA UE Pcell Scell Cell TPut On Target
    [Arguments]    ${ue_id}    ${dir}    ${scell_index}    ${target_tp}
    ${tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    ${scell_index}
    Should Be True    ${tput}>=${target_tp}
    ...    msg=UE${ue_id} scell${scell_index} tput is '${tput}'' not on target'${target_tp}'Mb
    Log To Console    \nUE${ue_id} scell${scell_index} ${dir} tput ${tput}Mb is on target: ${target_tp}Mb

*** Keywords ***
_keywords_all
    SA 5G Attach bj
    SA 5G Attach For Multi UE bj
    SA Set Traffic Type To Internal bj
    SA Set Traffic Type To Internal For Multi UE bj
    SA 5G PDU Session Setup bj
    SA 5G PDU Session Setup For Multi UE bj
    SA Start DL Traffic Internal bj
    SA Start UL Traffic Internal bj
    SA Stop DL Traffic Internal bj
    SA Stop UL Traffic Internal bj
    SA UE Stats NR bj
    SA Get UE Average Traffic Internal bj
    SA UE Check Throughput bj



SA 5G Attach bj
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate UE attach on 5GNR side during NSA L3 Call on eGate.
    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 2 ) reported successful RA" on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G Attach bj | 1 |
    Log To Console    start 5G attach ue id:${ue_id}...
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ue_register id\=${ue_id}    pass_regexp=REGISTRATION COMPLETE|No response to RRCSetupRequest    timeout=3minutes
    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    REGISTRATION COMPLETE
    Run Keyword If    "${ret}"=="${False}"    Fail    SA 5G Attach fails!!!
    Should Be True    ${ret}
    ${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    Log To Console    \n${output1}
    Should Match Regexp    ${output}    Initial UE Message .*Success
    Sleep    2s    reason=wait 5G attach is stable

SA 5G Attach For Multi UE bj
    [Arguments]    ${ue_id_lst}
    [Documentation]    This keyword is used to simulate UE attach on 5GNR side during NSA L3 Call on eGate.
    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 2 ) reported successful RA" on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id list |
    ...    Example:
    ...    | SA 5G Attach For Multi UE bj | [1, 2] |
    FOR    ${ue_id}    IN    @{ue_id_lst}
        SA 5G Attach bj    ${ue_id}
    END

SA Set Traffic Type To Internal bj
    [Documentation]    This keyword is used to set traffic type 5GNR side.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA Set Traffic Type To Internal | 1 |
    [Arguments]    ${ue_id}
    Log To Console    set traffic type to internal ue id: ${ue_id} ...
    ute_wtssim.Execute Egate Command
    ...    cmd=set_pdu_param ue\=${ue_id} pdu\=${ue_id} trf_type=internal

SA Set Traffic Type To Internal For Multi UE bj
    [Documentation]    This keyword is used to set traffic type 5GNR side.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id list |
    ...    Example:
    ...    | SA Set Traffic Type To Internal | [1, 2] |
    [Arguments]    ${ue_id_lst}
    FOR    ${ue_id}    IN    @{ue_id_lst}
        SA Set Traffic Type To Internal bj    ${ue_id}
    END

SA 5G PDU Session Setup bj
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup ue id: ${ue_id} ...
    ${command}    Set Variable    ue_pdu_session_setup pdu=${ue_id} ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

SA 5G PDU Session Setup For Multi UE bj
    [Arguments]    ${ue_id_lst}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G PDU Session Setup | 1 |
    FOR    ${ue_id}    IN    @{ue_id_lst}
        SA 5G PDU Session Setup bj    ${ue_id}
    END

SA Start DL Traffic Internal bj
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi}=1    ${trf_id}=1    ${mbps}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id, default is 1  |
    ...    | pdu_id | Yes | pdu id, default is 1  |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    | mbps | Yes | mbps, default is 1  |
    ...    | dir | No | ul |
    ...    Example:
    ...    | SA Start DL Traffic Internal bj | 1 | 1 | 1 | 1 | 2 |
    Log To Console    start DL traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi} trf_id\=${trf_id} mbps\=${mbps} dir=dl
    Sleep    2s    reason=wait DL traffic is stable

SA Start UL Traffic Internal bj
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi}=1    ${trf_id}=1    ${mbps}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | No | ue id, default is 1  |
    ...    | pdu_id | No | pdu id, default is 1  |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    | mbps | No | mbps, default is 1 |
    ...    | dir | No | ul, |

    ...    Example:
    ...    | SA Start UL Traffic Internal bj | 1 | 1 | 1 | 1 | 2 |
    Log To Console    start UL traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi} trf_id\=${trf_id} mbps\=${mbps} dir=ul
    Sleep    2s    reason=wait UL traffic is stable

SA Stop DL Traffic Internal bj
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi}=1
    Log To Console      trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir=dl

SA Stop UL Traffic Internal bj
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi}=1
    Log To Console      trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=ul
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi} dir=ul

SA UE Stats NR bj
    [Arguments]    ${ue_id}=1
    [Documentation]    This keyword is to Check traffic of pdsch and pusch.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id, default=1 |
    ...    Example:
    ...    | Keyword | ue_id |
    ...    | SA UE Stats NR bj | 1 |
    Log To Console    ue_stats_nr di=${ue_id} type=pdsch
    ${output_dl}=     ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=${UE_ID} type=pdsch
    Log To Console    ${output_dl}
    Log To Console    ue_stats_nr di=${ue_id} type=pusch
    ${output_ul}=     ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=${UE_ID} type=pusch
    Log To Console    ${output_ul}

SA Get UE Average Traffic Internal bj
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${qfi}=1
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | pdu_id | Yes | bearer_id |
    ...    | dir | Yes | Direction of Traffic |
    ...    Example:
    ...    | Keyword | ue_id | pdu_id | dir | qfi |
    ...    | SA Get UE Average Traffic Internal bj | 1 | 1 | dl | 1 |
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} pdu\=${pdu_id} qfi=${qfi} dir\=${dir}
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${tp_delta}    Evaluate    ${avg}*0.000001
    [Return]    ${tp_delta}

SA UE Check Throughput bj
    [Arguments]    ${UE_ID}=1    ${pdu_id}=1    ${dl_tp_threshold}=5    ${ul_tp_threshold}=5    ${qfi}=1
    [Documentation]    This keyword is to Check traffic reach the target or not.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id, default=1 |
    ...    | pdu_id | Yes | pdu_id, default=1 |
    ...    | dl_tp_threshold | Yes | threshold, default=5 |
    ...    | ul_tp_threshold | Yes | ul threshold,  default=5 |
    ...    | qfi | No | qfi, default=1 |
    ...    Example:
    ...    | SA UE Check Throughput bj | 1 | 1 | 5 | 2 | 1 |

    ${dl_tp}=    SA Get UE Average Traffic Internal bj    ue_id=${UE_ID}    pdu_id=${pdu_id}    dir=dl    qfi=${qfi}
    ${ul_tp}=    SA Get UE Average Traffic Internal bj    ue_id=${UE_ID}    pdu_id=${pdu_id}    dir=ul    qfi=${qfi}
    log    DL Troughput is ${dl_tp}    console=True
    log    UL Troughput is ${ul_tp}    console=True
    ${tp_delta}    Evaluate    ${dl_tp}-${dl_tp_threshold}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${dl_tp_threshold}M \n
    ${tp_delta}    Evaluate    ${ul_tp}-${ul_tp_threshold}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${ul_tp_threshold}

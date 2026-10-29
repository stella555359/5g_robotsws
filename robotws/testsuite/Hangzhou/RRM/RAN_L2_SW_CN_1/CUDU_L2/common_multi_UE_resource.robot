*** Keywords ***
Get CA Cell Average Throughput For MUE
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${dir}    ${scell_index}
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
    ${cmd}    Set Variable    ue_stats_nr id\=${start_ue_id}-${end_ue_id} type\=${type} scell\=${scell_index}
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=EGATE> UE-${end_ue_id}
    Sleep    10s
    ${regexp_cell}    Set Variable    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?\\s+){3}(?P<AvgTput>\\d+.?\\d*)
    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    ${all_cell_tp}=    EVALUATE    sum(map(float,${avg_tp_list}))
    [Return]    ${all_cell_tp}

SA Multi NonCA UE Attach
    [Arguments]    ${ue_id_list}    ${pdu_id}=1
    [Documentation]    This keyword is to multi SA UE attach
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id_list} | YES | a list of ue id, such as [1,2,3] |
    ...
    ...    Examples:
    ...    | @{ue_id_list} |  | 1 | 3 | 5 |
    ...    | SA Multi NonCA UE Attach | ${ue_id_list} |
    ...
    FOR    ${ue_id}    IN    @{ue_id_list}
        SA Single UE Attach    ${ue_id}    ${pdu_id}
    END

SA Multi Continuous NonCA UE Attach
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${pdu_id}=1
    [Documentation]    This keyword is to multi SA continuous UE attach
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${start_ue_num} | YES | ue id of the min UE |
    ...    | ${stop_ue_num} | YES | ue id of the max UE |
    ...
    ...    Examples:
    ...    | ${start_ue_num} |  | 1 |
    ...    | ${stop_ue_num} |  | 10 |
    ...    | SA Multi Continuous NonCA UE Attach | ${start_ue_num} | ${stop_ue_num} |
    ...
    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
        SA Single UE Attach    ${ue_id}    ${pdu_id}
    END

SA Multi UE Attach With Scell Blind Addition
    [Arguments]    ${ca_ue_list}    ${scell_physicalid_list}    ${cc_num}    ${pdu_id}=1
    [Documentation]    This keyword is to multi CA UE attach and check scell added with blind
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ca_ue_list} | yes | a list for UE id |
    ...    | ${scell_physicalid_list} | yes | a list for scell physicalid for each ue, the element also is a list |
    ...    | ${cc_num} | yes | a number. such as 2 for 2CC, 3 for 3CC, 4 for 4CC and so on |
    ...
    ...    Examples:
    ...    | @{4CC_UE_LIST} |  | 3 | 4 |
    ...    | @{4CC_SCELL_PHYSICALID_1} |  | 50 | 51 | 53 |
    ...    | @{4CC_SCELL_PHYSICALID_2} |  | 50 | 51 | 55 |
    ...    | @{4CC_SCELL_PHYSICALID_LIST} |  | @{4CC_SCELL_PHYSICALID_1} | @{4CC_SCELL_PHYSICALID_2} |
    ...    | Multi CA UE Attach With Blind | ${4CC_UE_LIST} | ${4CC_SCELL_PHYSICALID_LIST} | 4 |
    ...
    FOR    ${ue_id}    ${scell_physicalid}    IN ZIP    ${ca_ue_list}    ${scell_physicalid_list}
        SA 5G CA Attach    ${ue_id}    ${pdu_id}
        Sleep    1s
        Check SA All Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}    ${cc_num}
    END

Check SA Scell PhysicalID With UE ID
    [Arguments]    ${ue_id}    ${scell_physicalid}    ${scell_index}    ${log_path}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to check scell physicallid as the same as the expected one which
    ...         got from egate log with scell index
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | yes | the id of ue |
    ...    | ${scell_physicalid} | yes | the expected physicalid |
    ...    | ${scell_index} | yes | the scell index of ue need to check |
    ...    | ${log_path} | No | the path saved egate log |
    ...
    ...    Examples:
    ...    | Check SA Scell PhysicalID With UE ID | 1 | 51 | 1 |
    ...
    Save Egate Log    log_path=${log_path}
    ${t_scell_id}    Get PhysCellId With UE Id From Egate Log    ${ue_id}    ${scell_index}    ${log_path}/egate_console.log
    Should Be True    "${scell_physicalid}"=="${t_scell_id}"
    ...    msg=the PhysicalID of ScellId${scell_index} for UE${ue_id} is ${t_scell_id}, not as the expected one ${scell_physicalid}.

Check SA All Scell PhysicalID With UE ID
    [Arguments]    ${ue_id}    ${scell_physicalid_list}    ${cc_num}
    [Documentation]    This keyword is to check all scell physicall id of single ue once.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | YES |  id of ue |
    ...    | ${scell_physicalid_list} | yes | the list for scell physicall id of ue |
    ...    | ${cc_num} | yes | the num for how many cc |
    ...
    ...    Examples:
    ...    | ${ue_id} |  | 1 |
    ...    | @{scell_physicalid_list} |  | 51 | 52 |
    ...    | Check SA All Scell PhysicalID With UE ID | ${ue_id} | ${scell_physicalid_list} | 3 |
    ...
    ${for_num}    Evaluate    ${cc_num}-1
    FOR    ${id}    IN RANGE    ${for_num}
        ${index}    Evaluate    ${id}+1
        Check SA Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid_list[${id}]}    ${index}
    END

SA Multi UE Attach With Scell A1 Addition
    [Arguments]    ${ca_ue_list}    ${pcell_id_list}    ${scell_physicalid_list}    ${a1Threshold}    ${cc_num}    ${pdu_id}=1
    [Documentation]    This keyword is to multi CA UE attach and check scell added with A1 trigger
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ca_ue_list} | yes | a list for UE id |
    ...    | ${scell_physicalid_list} | yes | a list for scell physicalid for each ue, the element also is a list |
    ...    | ${cc_num} | yes | a number. such as 2 for 2CC, 3 for 3CC, 4 for 4CC and so on |
    ...
    ...    Examples:
    ...    | @{3CC_UE_LIST} |  | 3 | 4 |
    ...    | @{3CC_PCELLID_LIST} |  | 50 | 51 |
    ...    | @{3CC_SCELL_PHYSICALID_1} |  | 51 | 53 |
    ...    | @{3CC_SCELL_PHYSICALID_2} |  | 50 | 55 |
    ...    | @{3CC_SCELL_PHYSICALID_LIST} |  | @{3CC_SCELL_PHYSICALID_1} | @{3CC_SCELL_PHYSICALID_2} |
    ...    | Multi CA UE Attach With A1 | ${3CC_UE_LIST} | ${3CC_PCELLID_LIST} |
    ...    | ... | ${3CC_SCELL_PHYSICALID_LIST} | a1Threshold=105 | cc_num=3 |
    ...
    FOR    ${ue_id}    ${pcell_id}    ${scell_physicalid}    IN ZIP    ${ca_ue_list}    ${pcell_id_list}    ${scell_physicalid_list}
        SA 5G CA Attach    ${ue_id}    ${pdu_id}
        Trigger A1 Scell Addition    ${ue_id}    ${a1Threshold}    ${pcell_id}
        Check SA All Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}    ${cc_num}
    END

SA Multi UE Detach
    [Arguments]    ${ue_id_list}
    [Documentation]    This keyword is to multi UEs detach
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_list} | yes | a list for UE id |
    ...
    ...    Examples:
    ...    | @{ue_id_list} |  | 1 | 3 | 5 |
    ...    | SA Multi UE Detach | ${ue_id_list} |
    ...
    FOR    ${ue_id}    IN    @{ue_id_list}
        SA 5G Detach    ${ue_id}
    END

SA Multi Continuous UE Detach
    [Arguments]    ${start_ue_num}    ${stop_ue_num}
    [Documentation]    This keyword is to multi SA continuous UE detach
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${start_ue_num} | YES | ue id of the min UE |
    ...    | ${stop_ue_num} | YES | ue id of the max UE |
    ...
    ...    Examples:
    ...    | ${start_ue_num} |  | 1 |
    ...    | ${stop_ue_num} |  | 10 |
    ...    | SA Multi Continuous UE Detach | ${start_ue_num} | ${stop_ue_num} |
    ...
    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
        SA 5G Detach    ${ue_id}
    END

SA Multi UE Start DL Traffic
    [Arguments]    ${ue_id_list}    ${mbps}    ${pdu_id}=1
    [Documentation]    This keyword is to start dl traffic for multi UE, support big traffic and not big.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_list} | Yes | a list for UE id |
    ...    | ${mbps} | Yes | package which want to traffic, the unit is mbps  |
    ...
    ...    Examples:
    ...    | @{ue_id_list} |  | 1 | 3 | 5 |
    ...    | ${mbps} | 300 |
    ...    | SA Multi UE Start DL Traffic | ${ue_id_list} | ${mbps} |
    ...
    ${dl_times}    Evaluate    int(${mbps}/${175})
    FOR    ${ue_id}    IN    @{ue_id_list}
        SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps}    trf_id=1
    END

SA Multi UE Start UL Traffic
    [Arguments]    ${ue_id_list}    ${mbps}    ${pdu_id}=1
    [Documentation]    This keyword is to start ul traffic for multi UE
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_list} | Yes | a list for UE id |
    ...    | ${mbps} | Yes | package which want to traffic, the unit is mbps  |
    ...
    ...    Examples:
    ...    | @{ue_id_list} |  | 1 | 3 | 5 |
    ...    | ${mbps} | 50 |
    ...    | SA Multi UE Start UL Traffic | ${ue_id_list} | ${mbps} |
    ...
    FOR    ${ue_id}    IN    @{ue_id_list}
        SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps}    trf_id=1
    END

SA Multi UE Start DL And UL Traffic
    [Arguments]    ${ue_id_list}    ${dl_mbps}    ${ul_mbps}    ${pdu_id}=1
    [Documentation]    This keyword is to start dl and ul traffic for multi UE, support big traffic and not big.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_list} | Yes | a list for UE id |
    ...    | ${dl_mbps} | Yes | package which want to dl traffic, the unit is mbps |
    ...    | ${ul_mbps} | Yes | package which want to ul traffic, the unit is mbps |
    ...
    ...    Examples:
    ...    | @{ue_id_list} |  | 1 | 3 | 5 |
    ...    | ${dl_mbps} | 300 |
    ...    | ${ul_mbps} | 50 |
    ...    | SA Multi UE Start DL And UL Traffic | ${ue_id_list} | ${dl_mbps} | ${ul_mbps} |
    ...
    FOR    ${ue_id}    IN    @{ue_id_list}
        SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    ${dl_mbps}    trf_id=1
        SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    ${ul_mbps}    trf_id=1
    END

SA Multi Continuous UE Start DL Traffic
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${mbps}    ${pdu_id}=1
    [Documentation]    This keyword is to start dl traffic for multi continuous UE, support big traffic and not big.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${start_ue_num} | YES | ue id of the min UE |
    ...    | ${stop_ue_num} | YES | ue id of the max UE |
    ...    | ${mbps} | Yes | package which want to traffic, the unit is mbps  |
    ...
    ...    Examples:
    ...    | ${start_ue_num} |  | 1 |
    ...    | ${stop_ue_num} |  | 10 |
    ...    | ${mbps} | 300 |
    ...    | SA Multi Continuous UE Start DL Traffic | ${start_ue_num} | ${stop_ue_num} | ${mbps} |
    ...
    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
        SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps}    trf_id=1
    END

SA Multi Continuous UE Start UL Traffic
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${mbps}    ${pdu_id}=1
    [Documentation]    This keyword is to start ul traffic for multi continuous UE
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${start_ue_num} | YES | ue id of the min UE |
    ...    | ${stop_ue_num} | YES | ue id of the max UE |
    ...    | ${mbps} | Yes | package which want to traffic, the unit is mbps  |
    ...
    ...    Examples:
    ...    | ${start_ue_num} |  | 1 |
    ...    | ${stop_ue_num} |  | 10 |
    ...    | ${mbps} | 300 |
    ...    | SA Multi Continuous UE Start UL Traffic | ${start_ue_num} | ${stop_ue_num} | ${mbps} |
    ...
    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
        SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps}    trf_id=1
    END

SA Multi Continuous UE Start DL And UL Traffic
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${dl_mbps}    ${ul_mbps}    ${pdu_id}=1
    [Documentation]    This keyword is to start ul traffic for multi continuous UE
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${start_ue_num} | YES | ue id of the min UE |
    ...    | ${stop_ue_num} | YES | ue id of the max UE |
    ...    | ${dl_mbps} | Yes | package which want to dl traffic, the unit is mbps |
    ...    | ${ul_mbps} | Yes | package which want to ul traffic, the unit is mbps |
    ...
    ...    Examples:
    ...    | ${start_ue_num} |  | 1 |
    ...    | ${stop_ue_num} |  | 10 |
    ...    | ${dl_mbps} | 300 |
    ...    | ${ul_mbps} | 50 |
    ...    | SA Multi Continuous UE Start DL And UL Traffic | ${start_ue_num} | ${stop_ue_num} | ${dl_mbps} | ${ul_mbps} |
    ...
    ${dl_times}    Evaluate    int(${dl_mbps}/${175})
    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
        SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    ${dl_mbps}    trf_id=1
        SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    ${ul_mbps}    trf_id=1
    END

SA Multi UE Stop DL Traffic
    [Arguments]    ${ue_id_list}    ${pdu_id}=1
    [Documentation]    This keyword is to stop dl traffic for multi UE\
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id_list} | Yes | a list for UE id |
    ...
    ...    Examples:
    ...    | @{ue_id_list} |  | 1 | 3 | 5 |
    ...    | SA Multi UE Stop DL Traffic | ${ue_id_list} |
    FOR    ${ue_id}    IN    @{ue_id_list}
        ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir=dl
        Log To Console    \nStop UE${ue_id} DL Traffic
    END

SA Multi UE Stop UL Traffic
    [Arguments]    ${ue_id_list}    ${pdu_id}=1
    [Documentation]    This keyword is to stop ul traffic for multi UE\
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id_list} | Yes | a list for UE id |
    ...
    ...    Examples:
    ...    | @{ue_id_list} |  | 1 | 3 | 5 |
    ...    | SA Multi UE Stop UL Traffic | ${ue_id_list} |
    FOR    ${ue_id}    IN    @{ue_id_list}
        ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir=ul
        Log To Console    \nStop UE${ue_id} UL Traffic
    END

SA Multi UE Stop DL And UL Traffic
    [Arguments]    ${ue_id_list}    ${pdu_id}=1
    [Documentation]    This keyword is to stop dl and ul traffic for multi UE\
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id_list} | Yes | a list for UE id |
    ...
    ...    Examples:
    ...    | @{ue_id_list} |  | 1 | 3 | 5 |
    ...    | SA Multi UE Stop DL And UL Traffic | ${ue_id_list} |
    ...
    FOR    ${ue_id}    IN    @{ue_id_list}
        ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir=bi
        Log To Console    \nStop UE${ue_id} DL and UL Traffic
    END

SA Multi Continuous UE Stop DL Traffic
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${pdu_id}=1
    [Documentation]    This keyword is to start dl traffic for multi continuous UE
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${start_ue_num} | YES | ue id of the min UE |
    ...    | ${stop_ue_num} | YES | ue id of the max UE |
    ...
    ...    Examples:
    ...    | ${start_ue_num} |  | 1 |
    ...    | ${stop_ue_num} |  | 10 |
    ...    | SA Multi Continuous UE Stop DL Traffic | ${start_ue_num} | ${stop_ue_num} |
    ...
    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
        ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir=dl
        Log To Console    \nStop UE${ue_id} DL Traffic
    END

SA Multi Continuous UE Stop UL Traffic
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${pdu_id}=1
    [Documentation]    This keyword is to start ul traffic for multi continuous UE
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${start_ue_num} | YES | ue id of the min UE |
    ...    | ${stop_ue_num} | YES | ue id of the max UE |
    ...
    ...    Examples:
    ...    | ${start_ue_num} |  | 1 |
    ...    | ${stop_ue_num} |  | 10 |
    ...    | SA Multi Continuous UE Stop UL Traffic | ${start_ue_num} | ${stop_ue_num} |
    ...
    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
        ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir=ul
        Log To Console    \nStop UE${ue_id} UL Traffic
    END

SA Multi Continuous UE Stop DL And UL Traffic
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${pdu_id}=1
    [Documentation]    This keyword is to start ul traffic for multi continuous UE
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${start_ue_num} | YES | ue id of the min UE |
    ...    | ${stop_ue_num} | YES | ue id of the max UE |
    ...
    ...    Examples:
    ...    | ${start_ue_num} |  | 1 |
    ...    | ${stop_ue_num} |  | 10 |
    ...    | SA Multi Continuous UE Stop DL And UL Traffic | ${start_ue_num} | ${stop_ue_num} |
    ...
    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
        ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir=bi
        Log To Console    \nStop UE${ue_id} DL and UL Traffic
    END

Display Multi UE Throughput
    [Arguments]    ${ue_ids}
    [Documentation]    This keyword is to display ues tput for pcell and scell
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_ids} | yes | if ue id Continuous, such as 1-2, 10-20. if not, a list [1,3,5] |
    ...
    ...    Examples:
    ...    | Display Multi UE Throughput | 1-2 |  |
    ${is_list}    Evaluate    isinstance(${ue_ids},list)
    ${ue_id_str}    Run Keyword If    '${is_list}'=='True'    Evaluate    ','.join(${ue_ids})
    ${ue_ids}    Set Variable If    '${is_list}'=='True'    ${ue_id_str}    ${ue_ids}
    Log To Console    \nDisplay the tput of pcell and scell for UE${ue_ids}
    ${output}    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=${ue_ids} type=pusch,pdsch scell=0-31    pass_regexp=EGATE>
    Log To Console    \n${output}

Check UE DL All Pcell Scell TP On Target For Single UE
    [Arguments]    ${ue_id}    ${exp_dl_tput_list}    ${cc_num}
    [Documentation]    This keyword is to check all dl Pcell Scell TP of single ue once.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | YES |  id of ue |
    ...    | ${exp_dl_tput_list} | yes | the list for DL expected tput of ue pcell ,scell |
    ...    | ${cc_num} | yes | the num for how many cc |
    ...
    ...    Examples:
    ...    | ${ue_id} |  | 1 |
    ...    | @{exp_dl_tput_list} |  | 200 | 100 | 100 |
    ...    | Check UE DL All Pcell Scell TP On Target For Single UE | ${ue_id} | ${exp_dl_tput_list} | 3 |
    ...
    FOR    ${id}    IN RANGE    ${cc_num}
        Run Keyword If    ${id}==${0}    Check CA UE Pcell Scell Cell TPut On Target
        ...    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${exp_dl_tput_list[0]}
        ...    ELSE    Check CA UE Pcell Scell Cell TPut On Target
        ...    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=${id}    target_tp=${exp_dl_tput_list[${id}]}
    END

Check UE 2CCUL Pcell Scell TP On Target For Single UE
    [Arguments]    ${ue_id}    ${exp_ul_tput_list}    ${dl_cc_num}
    [Documentation]    This keyword is to check all ul Pcell Scell TP of single ue once.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | YES |  id of ue |
    ...    | ${exp_ul_tput_list} | yes | the list for UL expected tput of ue pcell ,scell |
    ...    | ${dl_cc_num} | yes | the num for how many cc for dl CA |
    ...
    ...    Examples:
    ...    | ${ue_id} |  | 1 |
    ...    | @{exp_ul_tput_list} |  | 20 | 10 |
    ...    | Check UE 2CCUL Pcell Scell TP On Target For Single UE | ${ue_id} | ${exp_dl_tput_list} | 3 |
    ...
    FOR    ${id}    IN RANGE    2
        Run Keyword If    ${id}==${0}    Check CA UE Pcell Scell Cell TPut On Target
        ...    ue_id=${ue_id}    dir=ul    cell_type=pcell    scell_index=0    target_tp=${exp_ul_tput_list[0]}
        ...    ELSE    Check ULCA Scell L1 Cell Tput On Target
        ...    ue_id=${ue_id}    dl_cc_num=${dl_cc_num}    target_tp=${exp_ul_tput_list[1]}
    END

Check Multi UE ULCA Cell L1 tput
    [Arguments]    ${ue_id_list}    ${exp_ul_tput_list}   ${dl_cc_num}
    [Documentation]    This keyword is to check all dl Pcell Scell TP of multi ue once.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id_list} | YES | the list of ue id |
    ...    | ${exp_ul_tput_list} | yes | the list for DL expected tput of ue pcell ,scell |
    ...    | ${dl_cc_num} | yes | the num for how many cc for dl CA |
    ...
    ...    Examples:
    ...    | @{ue_id} |  | 1 | 2 | 4 |
    ...    | @{exp_ul_tput_list} |  | 200 | 100 | 100 |
    ...    | Check Multi UE ULCA Cell L1 tput | ${ue_id} | ${exp_dl_tput_list} | 3 |
    FOR    ${ue_id}    IN    @{ue_id_list}
        Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${ue_id}    ${exp_ul_tput_list}    ${dl_cc_num}
    END

Check Multi UE DLCA Cell L1 tput
    [Arguments]    ${ue_id_list}    ${exp_dl_tput_list}   ${cc_num}
    [Documentation]    This keyword is to check all dl Pcell Scell TP of multi ue at the same time.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id_list} | YES | the list of ue id |
    ...    | ${exp_dl_tput_list} | yes | the list for DL expected tput of ue pcell ,scell |
    ...    | ${dl_cc_num} | yes | the num for how many cc for dl CA |
    ...
    ...    Examples:
    ...    | @{ue_id} |  | 1 | 2 | 4 |
    ...    | @{exp_dl_tput_list} |  | 200 | 100 | 100 |
    ...    | Check Multi UE DLCA Cell L1 tput | ${ue_id} | ${exp_dl_tput_list} | 3 |
    ...
    FOR    ${ue_id}    IN    @{ue_id_list}
        Check UE DL All Pcell Scell TP On Target For Single UE    ${ue_id}    ${exp_dl_tput_list}    ${cc_num}
    END

Check Multi UE DLCA And ULnonCA L1 Cell tput
    [Arguments]    ${ue_id_list}    ${exp_ul_tput}    ${exp_dl_tput_list}   ${cc_num}
    [Documentation]    This keyword is to check all dl Pcell Scell TP of multi ue at the same time.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id_list} | YES | the list of ue id |
    ...    | ${exp_ul_tput} | yes | UL expected tput of ue |
    ...    | ${exp_dl_tput_list} | yes | the list for DL expected tput of ue pcell ,scell |
    ...    | ${cc_num} | yes | the num for how many cc for dl CA |
    ...
    ...    Examples:
    ...    | @{ue_id} |  | 1 | 2 | 4 |
    ...    | ${exp_ul_tput} |  | 5 |  |  |
    ...    | @{exp_dl_tput_list} |  | 200 | 100 | 100 |
    ...    | Check Multi UE DLCA Cell L1 tput | ${ue_id} | ${exp_ul_tput} | ${exp_dl_tput_list} | 3 |
    ...
    FOR    ${ue_id}    IN    @{ue_id_list}
        Check UE DL All Pcell Scell TP On Target For Single UE    ${ue_id}    ${exp_dl_tput_list}    ${cc_num}
        Check CA UE Pcell Scell Cell TPut On Target    ${ue_id}    ul    pcell    0    ${exp_ul_tput}
    END

Check Multi UE DLCA And 2CCULCA L1 Cell tput
    [Arguments]    ${ue_id_list}    ${exp_ul_tput_list}    ${exp_dl_tput_list}   ${dl_cc_num}
    [Documentation]    This keyword is to check all dl Pcell Scell TP of multi ue at the same time.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id_list} | YES | the list of ue id |
    ...    | ${exp_ul_tput_list} | yes | the list for UL expected tput of ue pcell ,scell |
    ...    | ${exp_dl_tput_list} | yes | the list for DL expected tput of ue pcell ,scell |
    ...    | ${cc_num} | yes | the num for how many cc for dl CA |
    ...
    ...    Examples:
    ...    | @{ue_id} |  | 1 | 2 | 4 |
    ...    | @{exp_ul_tput_list} |  | 5 | 5 |
    ...    | @{exp_dl_tput_list} |  | 200 | 100 | 100 |
    ...    | Check Multi UE DLCA Cell L1 tput | ${ue_id} | ${exp_ul_tput_list} | ${exp_dl_tput_list} | 3 |
    ...
    FOR    ${ue_id}    IN    @{ue_id_list}
        Check UE DL All Pcell Scell TP On Target For Single UE    ${ue_id}    ${exp_dl_tput_list}    ${dl_cc_num}
        Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${ue_id}    ${exp_ul_tput_list}    ${dl_cc_num}
    END

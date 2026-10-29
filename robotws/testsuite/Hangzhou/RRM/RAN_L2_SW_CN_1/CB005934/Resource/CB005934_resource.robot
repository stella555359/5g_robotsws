*** Settings ***
Resource    ./../../CUDU_L2/common_setup_teardown.robot

*** Keywords ***
Get CA Cell Current Throughput
    [Arguments]    ${ue_id}    ${dir}    ${scell_index}
    [Documentation]    This keyword is to get Pcell/Scell Current throughput,1Mbps=1000Kbps
    ...    The unit of return throughput is Mbps.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id |
    ...    | ${dir} | Yes | dl/ul |
    ...    | ${scell_index} | Yes | 1/2/3...|
    ...
    ...    | Examples: |
    ...    | ${pcell_tput} | Get CA Cell Current Throughput | 1 | dl | 0 |
    ...    | ${scell1_tput} | Get CA Cell Current Throughput | 1 | dl | 1 |
    ...    | ${scell2_tput} | Get CA Cell Current Throughput | 1 | ul | | 2 |
    ...
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=${type} scell\=${scell_index}
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-${scell_index}\\s+(?P<CurTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
    ${cur_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    CurTput
    ${cell_tp}=    Evaluate    sum(map(float,${cur_tp_list}))
    ${cell_tp}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
    ${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
    ${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
    Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
    ${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
    ${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
    ...    '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
    ...    ${cell_tp}
    [Return]    ${cell_tput_Mbps}

Check CA UE Pcell Scell Cell Current TPut With Range
    [Arguments]    ${ue_id}    ${dir}    ${scell_index}    ${min_target_tp}    ${max_target_tp}
    ${tput}    Get CA Cell Current Throughput    ${ue_id}    ${dir}    ${scell_index}
    Should Be True    ${max_target_tp}>${tput}>=${min_target_tp}
    ...    msg=UE${ue_id} ${scell_index} tput is '${tput}'' not in range between '${min_target_tp}' and '${max_target_tp}'Mb
    Log To Console    \nUE${ue_id} ${scell_index} ${dir} tput ${tput}Mb is between ${min_target_tp} and ${max_target_tp}

Check Single UE DL All Pcell Scell Current TPut With Range
    [Arguments]    ${ue_id}    ${exp_min_tput_list}    ${exp_max_tput_list}    ${cc_num}
    [Documentation]    This keyword is to check all dl Pcell Scell TP of single ue once.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | YES |    id of ue |
    ...    | ${exp_min_tput_list} | yes | the list for DL min expected tput of ue pcell ,scell |
    ...    | ${exp_max_tput_list} | yes | the list for DL max expected tput of ue pcell ,scell |
    ...    | ${cc_num} | yes | the num for how many cc |
    ...
    ...    Examples:
    ...    | ${ue_id} |    | 1 |
    ...    | @{exp_min_tput_list} |    | 190 | 90 | 90 |
    ...    | @{exp_max_tput_list} |    | 200 | 100 | 100 |
    ...    | Check Single UE DL All Pcell Scell Current TPut With Range | ${ue_id} | ${exp_min_tput_list} | ${exp_max_tput_list} | 3 |
    ...
    ${scell_index}    Evaluate    ','.join([str(x) for x in range(${cc_num})])
    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=pdsch scell\=${scell_index}
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    FOR    ${id}    IN RANGE    ${cc_num}
    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-${id}\\s+(?P<CurTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
    ${cur_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    CurTput
    ${cell_tp}=    Evaluate    sum(map(float,${cur_tp_list}))
    ${cell_tp}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
    ${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
    ${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
    Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
    ${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
    ${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
    ...    '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
    ...    ${cell_tp}
    ${logout}=    Catenate    UE${ue_id} ${scell_index} tput is '${cell_tput_Mbps}'' not in range between '${exp_min_tput_list[${id}]}'
    ...    and '${exp_max_tput_list[${id}]}'Mb
    Should Be True    ${exp_max_tput_list[${id}]}>${cell_tput_Mbps}>=${exp_min_tput_list[${id}]}    msg=${logout}
    Log To Console    \nUE${ue_id} ${id} dl tput ${cell_tput_Mbps}Mb is between ${exp_min_tput_list[${id}]} and ${exp_max_tput_list[${id}]}
    END

Check Multi UE DL All Pcell Scell Current TPut With Range
    [Arguments]    ${ue_info_dict_list}
    [Documentation]    This keyword is to check all dl Pcell Scell TP of multi ue once.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_info_dict} | YES | should inculde key: ue_id,exp_min_tput_list,exp_max_tput_list,cc_num    |
    ...
    ...    Examples:
    ...    | @{exp_min_tput_list_1} |    | 190 | 90 | 90 |
    ...    | @{exp_max_tput_list_1} |    | 200 | 100 | 100 |
    ...    | @{exp_min_tput_list_2} |    | 190 | 90 | 90 |
    ...    | @{exp_max_tput_list_2} |    | 200 | 100 | 100 |
    ...    | &{ue_info_dict_1} |    | ue_id=1 | min_target_tp=${exp_min_tput_list_1} | max_target_tp=${exp_max_tput_list_1} | cc_num=4 |
    ...    | &{ue_info_dict_2} |    | ue_id=2 | min_target_tp=${exp_min_tput_list_2} | max_target_tp=${exp_max_tput_list_2} | cc_num=4 |
    ...    | @{ue_info_list} |    | ${ue_info_dict_1} | ${ue_info_dict_2} |
    ...    | Check Multi UE ULCA Cell L1 tput | ${ue_info_list} |
    FOR    ${ue_info}    IN    @{ue_info_list}
    Check Single UE DL All Pcell Scell Current TPut With Range    ${ue_info.ue_id}    ${ue_info.exp_min_tput_list}
    ...    ${ue_info.exp_max_tput_list}    ${ue_info.cc_num}
    END

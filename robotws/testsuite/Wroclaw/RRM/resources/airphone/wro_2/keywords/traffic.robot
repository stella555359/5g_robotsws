*** Settings ***
Documentation    Keywords for traffic handling during testing with AP simulated enviroment

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Library     taf.ul.ettf.throughput.ue
Library     ute_wtssim
Library     ta5g_throughput

*** Keywords ***
Display DL Traffic Scheduling On All SCells
    [Arguments]    ${ue_id}=1    ${scell}=0-3
    Execute Egate Command And Wait For Data
        ...          cmd=ue_stats_nr id=${ue_id} scell=${scell}
        ...          pass_regexp=UE-1: NR PDSCH Throughput

Wait for Traffic to Stabilize
    [Arguments]    ${inactive_timer}=30
    BuiltIn.Sleep    ${inactive_timer}s

Stop DL and UL traffic on PDU for UE
    [Arguments]    ${ue_id}    ${pdu_id}=1
    Execute egate command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id}
    Sleep  2s

Verify That Traffic Is Scheduled On All SCells
    [Arguments]    ${ue_id}=1    ${num_of_scells}=3
    ${num_of_cells}=    Evaluate    int(${num_of_scells}) + int(1)
    Execute Egate Command And Wait For Data
        ...          cmd=ue_stats_nr id=${ue_id} scell=0-${num_of_scells}
        ...          pass_regexp=(CellIndex-[0-${num_of_scells}][\\s][\\s][1-9].*\\n){${num_of_cells}}

Verify That Traffic Is Scheduled On All SCells In Group
    [Arguments]    ${ue_id}=1    ${cell_index_min}=0    ${cell_index_max}=3    ${cell_group}=MCG    ${type}=pdsch
    ${num_of_cells_on_MN_and_SN}=    Evaluate        int(${cell_index_max}) + int(1)
    ${num_of_cells_if_only_SN}=      Set variable    ${cell_index_max}
    ${num_of_cells}=                 Set variable if
    ...     '${cell_index_min}' == '0'    ${num_of_cells_on_MN_and_SN}    ${num_of_cells_if_only_SN}
    Execute Egate Command And Wait For Data
        ...          cmd=ue_stats_nr id=${ue_id} cell_group=${cell_group} type=${type} scell=${cell_index_min}-${cell_index_max}
        ...          pass_regexp=(CellIndex-[${cell_index_min}-${cell_index_max}][\\s][\\s][1-9].*\\n){${num_of_cells}}

Verify That Throughput Is Reached On All SCells
    [Arguments]    ${ue_id}    ${num_of_scells}    ${expected_throughput}    ${direction}=dl
    ${num_of_cells}=    Evaluate    int(${num_of_scells}) + int(1)
    Assert That UE Throughput    ue_id=${ue_id}
            With Direction    ${direction}
            With Layer        physical
            With SCell        0-${num_of_scells}
        FOR    ${cell_index}    IN RANGE    0    ${num_of_cells}
            Is Reached            parameter=CellIndex-${cell_index}    expected_throughput=${expected_throughput}
        END
    Finalize

Verify That Throughput Is Reached On Specific Cells
    [Arguments]    ${ue_id}    ${cells_list}    ${expected_throughput}    ${direction}=dl    ${margin}=.0    ${selection_type}=Average
    ${max_cell_index}=    Evaluate    max($cells_list)
    Assert That UE Throughput    ue_id=${ue_id}
            With Direction    ${direction}
            With Layer        physical
            With SCell        0-${max_cell_index}
        FOR    ${cell_index}    IN    @{cells_list}
            Is Reached            parameter=CellIndex-${cell_index}    expected_throughput=${expected_throughput}
                ...               margin=${margin}    selection_type=${selection_type}
        END
    Finalize

Verify That Throughput Is Reached On Cell Group
    [Arguments]    ${ue_id}    ${expected_throughput}    ${cell_index_min}=0    ${cell_index_max}=0    ${direction}=dl
        ...        ${cell_group}=MCG    ${selection_type}=minimum    ${margin}=5%
    FOR    ${cell_index}    IN RANGE    ${cell_index_min}    ${cell_index_max}+1
        Expected Throughput For UE Should Be Reached
        ...    ue_id=${ue_id}
        ...    throughput=${expected_throughput}
        ...    margin=${margin}
        ...    direction=${direction}
        ...    selection_type=${selection_type}
        ...    scells=${cell_index}
        ...    cell_group=${cell_group}
    END



Send Data Traffic
    [Arguments]    ${ue_id}=1   ${pdu_id}=1    ${qfi}=1    ${mbps}=150    ${size}=1350    ${inactive_timer}=30
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl mbps=${mbps} size=${size}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl mbps=${mbps} size=${size}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=2 dir=dl mbps=${mbps} size=${size}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=3 dir=dl mbps=${mbps} size=${size}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=ul mbps=60 size=${size}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=1 dir=ul mbps=60 size=${size}
    Wait for Traffic to Stabilize    inactive_timer=${inactive_timer}

Start traffic for number of traffic ids
    [Arguments]    ${ue_id}=1   ${pdu_id}=1    ${qfi}=1    ${mbps}=150    ${size}=1350    ${inactive_timer}=30    ${dir}=dl    ${starting_index}=1
    ...            ${num_of_traffic_ids}=1
    FOR    ${i}   IN RANGE  ${starting_index}   ${num_of_traffic_ids}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=${i} dir=${dir} mbps=${mbps} size=${size}
    ...                          pass_regexp=Started (?:Uplink|Downlink) Internal traffic over
    END
    Wait for Traffic to Stabilize    inactive_timer=${inactive_timer}

Send Data Traffic In Direction
    [Arguments]    ${ue_id}=1   ${pdu_id}=1    ${qfi}=1    ${dir}=dl    ${mbps}=160    ${wait}=30s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=${dir} mbps=${mbps}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=1 dir=${dir} mbps=${mbps}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=2 dir=${dir} mbps=${mbps}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=3 dir=${dir} mbps=${mbps}
    Sleep    ${wait}

Set Scg UL Dist Percent
    [Arguments]    ${id}=1    ${scg_ul_dist_percent}=50    ${wait}=1s
    Execute Egate Command    cmd=uec_param id=${id} scg_ul_dist_percent=${scg_ul_dist_percent}
    Sleep    ${wait}

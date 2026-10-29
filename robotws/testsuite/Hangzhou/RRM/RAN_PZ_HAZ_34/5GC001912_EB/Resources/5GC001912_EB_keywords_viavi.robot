*** Settings ***
Documentation
...   This is for 1912-EB TA keywords related to viavi operation
...   author: Cui Lingxue
...   contact: lingxue.cui@nokia-sbell.com
...   squad group: MMW_SG1

Resource    ../../5GC000517/Resources/Cobham_Pre.robot

*** Keywords ***
Trigger A2 measurement report
    [Arguments]    ${a2_meas_id}=${A2_MEAS_ID}    ${report_interval}=0    ${serving_cell_pci}=416    ${serving_cell_rsrp}=80
    ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=415    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
    ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500    ${is_srb3}=${False}
    log to console  Start to trigger A2 measurement report
    ${cmd_a2_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
    ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[60] [] []]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [] []]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a2_mr}    alias=${tm500_alias}
    ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}

    ${complete_str_of_a2_mr}    set variable if    ${is_srb3}    NR-UL-DCCH-Message 0A00    NR-RRCReconfigurationComplete
    Wait until keyword succeeds    10s    200ms    match pattern in response    pattern=${complete_str_of_a2_mr}    response=${response}
    ...    e500_alias=${tm500_alias}

Trigger A3 measurement report
    [Arguments]    ${a3_meas_id}=${A3_MEAS_ID}    ${report_interval}=4    ${serving_cell_pci}=416    ${serving_cell_rsrp}=80
    ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=415    ${neigh_cell_rsrp}=120    ${neigh_cell_rsrq}=57
    ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
    log to console  Start to trigger A3 measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a3_meas_id} 0 0 ${report_interval} 1
    ...    {0 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[60] [] []]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [] []]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    Wait until keyword succeeds    10s    200ms    match pattern in response    response=${response}
    ...    e500_alias=${tm500_alias}    pattern=Random Access Complete

match pattern in response
    [Arguments]    ${pattern}    ${response}    ${e500_alias}=${TMA_APP_ALIAS}
    ${response_extra}    tm500_remote.read_responses    alias=${e500_alias}
    ${response}    Catenate    ${response}    ${response_extra}
    Should contain    ${response}    ${pattern}    msg=String "${pattern}" is not found

Trigger A1 measurement report
    [Arguments]    ${a1_meas_id}=${A1_MEAS_ID}    ${report_interval}=0    ${serving_cell_pci}=416    ${serving_cell_rsrp}=110
    ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=415    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
    ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500    ${is_srb3}=${False}
    log to console  Start to trigger A1 measurement report
    ${cmd_a1_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a1_meas_id} 0 0 ${report_interval} 1
    ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[60] [] []]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [] []]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a1_mr}    alias=${tm500_alias}
    ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}

    ${complete_str_of_a1_mr}    set variable if    ${is_srb3}    NR-UL-DCCH-Message 0C00    NR-RRCReconfigurationComplete
    Wait until keyword succeeds    10s    200ms    match pattern in response    pattern=${complete_str_of_a1_mr}    response=${response}
    ...    e500_alias=${tm500_alias}


Wait for pscell change initiated
    [Arguments]    ${tm500_alias}=${TMA_APP_ALIAS}    ${timeout}=1min
    ${is_pscell_change_triggered}    Run keyword and return status
    ...    wait until keyword succeeds    ${timeout}    1 s    match pattern in response    response=${EMPTY}    e500_alias=${tm500_alias}
    ...    pattern=Random Access Initiated :UE Id:0 (SCG Change: Cell Id 415
    [Return]    ${is_pscell_change_triggered}

Trigger A3 meas report if not triggered auto
    ${is_pscell_change_triggered}    Wait for pscell change initiated
    run keyword if    ${is_pscell_change_triggered}==${False}    Trigger A3 measurement report



# [OBSOLETE]

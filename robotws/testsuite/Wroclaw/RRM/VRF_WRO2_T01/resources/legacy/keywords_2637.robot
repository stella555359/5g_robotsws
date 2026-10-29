*** Settings ***
Documentation
...  contact:       pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  description:   Keywords for 5GC002273
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/multi_UE.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/math.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py
Library         taf.ue

*** Variables ***
${ENB_M_PLANE}=  ${tl.enbs[0].m.v4}
${MRBTS_5G_ID}=  ${tl.gnbs[0].instance_id}
${SCF_2637}=          /home/ute/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/SCFs/${MRBTS_5G_ID}

*** Keywords ***
Bar LTE cells
    Log to console     Barring LTE cells to enable SA calls
    Bar all eNB cells  ${ENB_ALIAS}

Unbar LTE cells
    Log to console       Unbarring LTE cells to enable default NSA calls
    Unbar all eNB cells  ${ENB_ALIAS}

Perform carrier aggregation gNB commissioning
    Log to console  Performing gNB commissioning with carrier aggregation SCF
    coam.perform commissioning  ${MRBTS_5G_ID}  ${SCF_2637}/CA_gNB_${MRBTS_5G_ID}.xml  ${True}  ${True}  600  ${GNB_ALIAS}
    Wait until keyword succeeds   10min   1min   Verify all cells are onair with admin

Perform consecutive calls to trigger DRX state
    [Arguments]     ${calls_quantity}=5  ${drx_timer}=31s
    Reset UEs       ${SINGLE_UE}
    FOR  ${call}  IN RANGE         ${calls_quantity}
        Attach UEs and start tput  ${SINGLE_UE}  udp  both  ${DATA_TRANSFER_SHORT}  off
        Wait for tput finish 2637       ${SINGLE_UE}
        log to console             Wait for ${drx_timer} to enable DRX-sleep state
        Sleep                      ${drx_timer}
    END

Wait for tput finish 2637
    [Arguments]   ${ue_alias}
    ${av_tputs}   Await datatransfers finish
    ${max_tputs}  Get max tputs from data transfer statistics
    Detach UEs from cell  ${ue_alias}
    Delete pyro_server UEPC
    [Return]  ${av_tputs}  ${max_tputs}

Wait for counter interval 2637
    [Arguments]     ${time}=300s
    Log to console  Wait for next counter interval for ${time}.
    sleep           ${time}

Verify base throughput counters
    [Arguments]  ${counters}  ${av_tputs}
    ${counters_value}  Get counters value  ${counters}
    ${counters_value[1]}  Evaluate  ${counters_value[1]}/300
    Log to console  Average ${counters[1]} equals ${counters_value[1]}
    Log to console  Verify ${counters[0]} based on ${counters[1]}
    Should be true  ${counters_value[0]} >= ${counters_value[1]}  msg=${counters[0]} lower than average ${counters[1]}
    Log to console  Test passed based on ${counters[1]} value
    Log to console  Verify ${counters[0]} based on IPERF tput
    ${iperf_tput}   Evaluate  (int(${av_tputs[0]})+int(${av_tputs[1]}))/125
    Should be true  ${counters_value[0]} >= ${iperf_tput}  msg=${counters[0]} lower than average IPERF tput
    Log to console  Test passed based on IPERF tput

Verify time and volume counters
    [Arguments]  ${dl_counters}  ${ul_counters}  ${av_tputs}
    ${dl_values}  Get counters value  ${dl_counters}
    ${ul_values}  Get counters value  ${ul_counters}
    Should be true  ${dl_values[0]} > int(0) and ${dl_values[0]} <= int(300500)
    ...             msg=${dl_counters[0]} out of range
    log to console  ${dl_counters[0]} in the margin.
    Should be true  ${ul_values[0]} > int(0) and ${ul_values[0]} <= int(300500)
    ...             msg=${ul_counters[0]} out of range
    log to console  ${ul_counters[0]} in the margin.
    ${iperf_dl}     Evaluate  int(${av_tputs[0]})
    ${iperf_ul}     Evaluate  int(${av_tputs[1]})
    Log to console  Verify ${dl_counters[1]} based on IPERF tput
    Should be true  ${dl_counters[1]} >= int(0.95)*${iperf_dl} and ${dl_counters[1]} <= (1.05)*${iperf_dl}
    ...             msg=${dl_counters[1]} does not allign with IPERF tput.
    Log to console  ${dl_counters[1]} value allign with IPERF tput
    Log to console  Verify ${ul_counters[1]} based on IPERF tput
    Should be true  ${ul_counters[1]} >= int(0.95)*${iperf_ul} and ${ul_counters[1]} <= int(1.05)*${iperf_ul}
    ...             msg=${ul_counters[1]} does not allign with IPERF tput.
    Log to console  ${ul_counters[1]} value allign with IPERF tput

Verify CA average tput counters
    [Arguments]  ${av_values}  ${av_counters}  ${av_tputs}
    Log to console  Average ${av_counters[0]} equals ${av_values[0]}
    Log to console  Verify ${av_counters[0]} based on IPERF tput
    Should be true  ${av_values[0]} >= ${av_tputs[0]}  msg=${av_counters[0]} does not align with IPERF tput.
    Should be true  ${av_values[0]} >= ${av_tputs[1]}  msg=${av_counters[0]} does not align with IPERF tput.
    log to console  ${av_counters[0]} value allign with IPERF tput.
    Log to console  Average ${av_counters[1]} equals ${av_values[1]}
    Log to console  Verify ${av_counters[1]} based on IPERF tput
    Should be true  ${av_values[1]} >= ${av_tputs[2]}  msg=${av_counters[1]} does not align with IPERF tput.
    Should be true  ${av_values[1]} >= ${av_tputs[3]}  msg=${av_counters[1]} does not align with IPERF tput.
    log to console  ${av_counters[1]} value allign with IPERF tput.

Verify CA data tput counters
    [Arguments]     ${data_values}  ${data_counters}  ${max_tputs}
    ${max_tputs[0]}  Evaluate  int(${max_tputs[0]})*60
    ${max_tputs[1]}  Evaluate  int(${max_tputs[1]})*60
    ${max_tputs[2]}  Evaluate  int(${max_tputs[2]})*60
    ${max_tputs[3]}  Evaluate  int(${max_tputs[3]})*60
    Log to console  Verify ${data_counters[2]} based on IPERF tput
    Run keyword if  '${max_tputs[0]}' > '${max_tputs[1]}'
    ...  Should be true  ${data_values[2]} >= ${0.75}*${max_tputs[0]} and ${data_values[2]} <= ${1.25}*${max_tputs[0]}
    ...  msg=${data_counters[2]} does not allign with IPERF tput.
    ...  ELSE
    ...  Should be true  ${data_values[2]} >= ${0.75}*${max_tputs[1]} and ${data_values[2]} <= ${1.25}*${max_tputs[1]}
    ...  msg=${data_counters[2]} does not allign with IPERF tput.
    Log to console  ${data_counters[2]} value allign with IPERF tput
    Log to console  Verify ${data_counters[3]} based on IPERF tput
    Run keyword if  '${max_tputs[2]}' > '${max_tputs[3]}'
    ...  Should be true  ${data_values[3]} >= ${0.65}*${max_tputs[2]} and ${data_values[3]} <= ${1.35}*${max_tputs[2]}
    ...  msg=${data_counters[3]} does not allign with IPERF tput.
    ...  ELSE
    ...  Should be true  ${data_values[3]} >= ${0.65}*${max_tputs[3]} and ${data_values[3]} <= ${1.35}*${max_tputs[3]}
    ...  msg=${data_counters[3]} does not allign with IPERF tput.
    Log to console  ${data_counters[3]} value allign with IPERF tput

Verify CA time tput counters
    [Arguments]     ${time_values}  ${time_counters}
    Should be true  ${time_values[4]} > int(0) and ${time_values[4]} <= int(61000)
    ...             msg=${time_counters[4]} out of range
    log to console  ${time_counters[4]} in the margin.
    Should be true  ${time_values[5]} > int(0) and ${time_values[5]} <= int(61000)
    ...             msg=${time_counters[5]} out of range
    log to console  ${time_counters[5]} in the margin.

Get counters value for sCell
    [Arguments]  ${counters}
    @{counters_value}  Create List
    FOR  ${counter}  IN  @{counters}
        ${var_name}  Catenate  SEPARATOR=_  ${counter}  value
        ${value}  Get counter value for sCell  ${counter}
        Set Test Variable  ${${var_name}}  ${value}
        Append To List  ${counters_value}  ${${var_name}}
    END
    [Return]  ${counters_value}

Get counter value for sCell
    [Arguments]  ${counter}
    Get sCell ID
    ${counter_value}     Get last counter values  ${counter}
    ${val_on_cells}      Get from dictionary      ${counter_value}  ${counter}
    ${values_for_sCell}  Evaluate  str(${val_on_cells[${sCell_ID}]})
    [Return]  ${values_for_sCell}

Get sCell ID
    ${cells_info}  coam.get cells info  nr  60  ${GNB_ALIAS}
    FOR  ${cell}  IN  @{cells_info}
        Check if sCell  ${cell}
    END

Check if sCell
    [Arguments]     ${cell}
    Run keyword if  '${cell['technology']}' == 'TDD'
    ...  Parse ID   ${cell}

Parse ID
    [Arguments]        ${cell}
    ${sCell_ID}        Set Variable  str(${cell['globalCellId']})
    Set Test Variable  ${sCell_ID}

Check if sCell counters value equal zero
    [Arguments]  ${vals}  ${names}
    ${length}  Get length  ${names}
    Log to console  Checking sCell counters values
    FOR  ${counter}  IN RANGE  ${length}
        Should be true  ${vals[${counter}]} == int(0)  msg=${names[${counter}]} != 0
        Log to console  ${names[${counter}]} = 0
    END
    Log to console  sCell counters values OK

Check if counters values differ from zero 2637
    [Arguments]  ${vals}  ${names}
    ${length}  Get length  ${names}
    Log to console  Checking counters values
    FOR  ${counter}  IN RANGE  ${length}
        Should be true  ${vals[${counter}]} != int(0)  msg=${names[${counter}]} = 0
        Log to console  ${names[${counter}]} != 0
    END
    Log to console  Counters values increased.

Verify DRX-sleep counters
    [Arguments]  ${drx_counters}
    ${drx_counters_value}  Get counters value  ${drx_counters}
    ${length}  Get length  ${drx_counters}
    FOR  ${counter}  IN RANGE  ${length}
        Should be true  ${drx_counters_value[0]} > int(0) and ${drx_counters_value[0]} <= int(900500)
        ...    msg=${drx_counters[0]} is not in acceptable range - FAIL
    END
    Log to console     ${\n}Counters M55308C26001, M55308C26002, M55308C27001 are in acceptable range.
    Log to console     Test passed

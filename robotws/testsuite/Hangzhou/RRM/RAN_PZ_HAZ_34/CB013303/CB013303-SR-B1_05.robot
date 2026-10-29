*** Settings ***
Documentation
...    author: Sun Chengmao
...    contact: chengmao.sun@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
Suite Setup       Common Suite Setup And Setup BTS env    scf=SCFC_1_TMO_nonSrsBm.xml
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS24R3    tl-7_5_UTE5G402T2404
Resource          ./resources/CB013303_resource.robot

*** Variables ***
${EMIL_FLAG}    False

*** Test Cases ***
CB013303-SR-B1_05_Check NRPDSCHBRLA and NRPUSCHBRLA counters for DL and UL transmissions using service aware BLER target during VONR is active
    clear counter files    wait=False
    Block NRCell2
    Block NRCell11
    Block NRCell12
    Block NRCell13
    adjust pa all ports max value

    log    step: additional step to check vonr interwork with this feature and CB008409 then check UL LA   console=True
    # Ajust MCS Att    value=30    ue_id=1
    adjust_pa_for_cell    cell_id=1    value=30
    prepare and attach UE with CGACT    ue_id=1    get_spark_license=${True}
    add 5qi bearer    5qi=8
    add 5qi bearer    5qi=9
    Start UL Traffic
    Make VONR call
    # Ajust MCS Att Stepwise    start_value=30    end_value=70    ue_id=1
    adjust pa stepwise for cell    cell_id=1    start_value=30    end_value=80    interval=5
    ${ttitrace_log_path}    capture gnb ttitrace for a while    cell_id=1    tag=additional    decode_flag=True
    # check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
    # ...                      targetbler=0.02
    # ...                      stepdown=0.25
    # ...                      mcstable=QAM64
    Stop UL Traffic
    Detach UE

    log    step: attach with 5qi5 5qi6 5qi7 then add 5qi8 5qi9+ dlul traffic, make bler then check BRLA-1 and no BRLA-2 counters    console=True
    # Ajust MCS Att    value=90    ue_id=1
    adjust_pa_for_cell    cell_id=1    value=127
    adjust_pa_for_cell    cell_id=10    value=10
    prepare and attach UE with CGACT    get_spark_license=${True}
    add 5qi bearer    5qi=8
    add 5qi bearer    5qi=9
    Start UL And DL traffic    send_traffic_ul=100M    send_traffic_dl=200M
    adjust pa back and forth then get this ttitrace    tag=1_attach_nonvonr    cell_id=10
    ${counters}    combine lists
    ...    ${CELL10_PDSCH_PRFL1_INCREASE}    ${CELL10_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL10_PUSCH_PRFL1_INCREASE}    ${CELL10_PUSCH_PRFL2_NOT_INCREASE}
    check counters    ${counters}
    check ibler based on counters    cell_id=10    phy_prfl=PDSCH_PRFL1    target_bler=5
    check ibler based on counters    cell_id=10    phy_prfl=PUSCH_PRFL1    target_bler=5

    log    step: make vonr call, use vonr level la then check no BRLA-1 and BRLA-2 counters    console=True
    Make VONR call
    adjust pa stepwise for cell    cell_id=10    start_value=10    end_value=60
    ${ttitrace_log_path}    capture gnb ttitrace for a while    cell_id=10    tag=2_vonr    decode_flag=True
    # check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
    # ...                      targetbler=0.02
    # ...                      stepdown=0.25
    # ...                      mcstable=QAM64
    # check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
    # ...                      targetbler=0.02
    # ...                      stepdown=0.25
    # ...                      mcstable=QAM64
    ${counters}    combine lists
    ...    ${CELL10_PDSCH_PRFL2_NOT_INCREASE}    # ${CELL10_PDSCH_PRFL1_NOT_INCREASE}
    ...    ${CELL10_PUSCH_PRFL2_NOT_INCREASE}    # ${CELL10_PUSCH_PRFL1_NOT_INCREASE}
    check counters    ${counters}

    log    step: hangup vonr, fall back to step1 use br level la check as step1 also check legacy counters    console=True
    Hang Up VoNR Call
    adjust pa back and forth then get this ttitrace    tag=3_nonvonr    cell_id=10
    ${counters}    combine lists
    ...    ${CELL10_PDSCH_PRFL1_INCREASE}    ${CELL10_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL10_PUSCH_PRFL1_INCREASE}    ${CELL10_PUSCH_PRFL2_NOT_INCREASE}
    check counters    ${counters}
    check ibler for legacy counters    cell_id=10    measurement_type_ini=PDSCH_INITX    measurement_type_suc=PDSCH_SUCC_INI
    check ibler for legacy counters    cell_id=10    measurement_type_ini=PUSCH_CP_INI    measurement_type_suc=PUSCH_CP_SUCC_INI

    [Teardown]    Run Keywords    Stop UL And DL traffic
    ...                           Detach UE
    ...                           Unblock NRCell2
    ...                           Unblock NRCell11
    ...                           Unblock NRCell12
    ...                           Unblock NRCell13
    ...                           Common Test Teardown And Stop Capture Logs

*** Keywords ***
adjust pa back and forth then get this ttitrace
    [Arguments]    ${cell_id}    ${tag}    ${start_value}=10    ${end_value}=60
    start to capture gnb ttitrace    tag=${tag}    cell_id=${cell_id}
    adjust pa stepwise for cell    cell_id=${cell_id}    start_value=${start_value}    end_value=${end_value}    interval=1
    adjust pa stepwise for cell    cell_id=${cell_id}    start_value=${end_value}    end_value=${start_value}    step=-2    interval=1
    stop capture gnb ttitrace    tag=${tag}

check ibler based on counters
    [Arguments]    ${cell_id}    ${phy_prfl}    ${target_bler}
    ${phy_type}    ${prfl}    Split String    ${phy_prfl}    _
    ${counters_value}    create list
    ...    last NRCELL-${cell_id}:${${phy_type}_INI_TX_BRD_${prfl}}
    ...    last NRCELL-${cell_id}:${${phy_type}_SUCC_INI_TX_BRD_${prfl}}
    ${int_tx}    ${succ_int_tx}    get counters value     ${counters_value}    wait=False
    ${iber}    Run Keyword If    ${int_tx} > 0    evaluate    ${${int_tx}-${succ_int_tx}}/${int_tx}*100
    ...    ELSE    Set Variable    0
    Run Keyword And Ignore Error    should be true    ${${target_bler}-2}<${iber}<${${target_bler}+2}
    ${bler_res}    Catenate    Expected ${phy_prfl} iBLER is within ${${target_bler}-2} ~ ${${target_bler}+2},
    ...    Actual iBLER is ${iber}
    Log    ${bler_res}    console=True

check ibler for legacy counters
    [Arguments]    ${cell_id}    ${measurement_type_ini}    ${measurement_type_suc}    ${target_bler}=5    ${mcs_table}=64TBL
    ${total_int_tx}    Set Variable    0
    ${total_succ_int_tx}    Set Variable    0
    FOR    ${mcs}    IN RANGE    0    29
        ${mcs_id}    Set Variable If    ${mcs} < 10    0${mcs}    ${mcs}
        ${counters_value}    create list
        ...    last NRCELL-${cell_id}:${${measurement_type_ini}_${mcs_table}_MCS${mcs_id}}
        ...    last NRCELL-${cell_id}:${${measurement_type_suc}_${mcs_table}_MCS${mcs_id}}
        ${int_tx}    ${succ_int_tx}    get counters value     ${counters_value}    wait=False
        ${total_int_tx}    evaluate    ${total_int_tx} + ${int_tx}
        ${total_succ_int_tx}    evaluate    ${total_succ_int_tx} + ${succ_int_tx}
    END
    ${iber}    Run Keyword If    ${total_int_tx} > 0    evaluate    ${${total_int_tx}-${total_succ_int_tx}}/${total_int_tx}*100
    ...    ELSE    Set Variable    0
    Run Keyword And Ignore Error    should be true    ${${target_bler}-2}<${iber}<${${target_bler}+2}
    ${bler_res}    Catenate    Expected ${measurement_type_ini}_${mcs_table} iBLER is within ${${target_bler}-2} ~ ${${target_bler}+2},
    ...    Actual iBLER is ${iber}
    Log    ${bler_res}    console=True

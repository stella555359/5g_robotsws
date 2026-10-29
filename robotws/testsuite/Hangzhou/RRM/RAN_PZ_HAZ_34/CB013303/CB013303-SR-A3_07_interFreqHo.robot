*** Settings ***
Documentation
...    author: Li Zhiguo
...    contact: zhiguo.li@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
Suite Setup        Common Suite Setup And Setup BTS env    scf=SCFC_1_TMO_GMC_IWK.xml
Suite Teardown     Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup         Common Test Setup And Start To Capture Logs
Test Teardown      Common Test Teardown And Stop Capture Logs
Force Tags         release-SBTS24R3    tl-7_5_UTE5G402T2404
Resource           ./resources/CB013303_resource.robot

*** Variables ***
${EMIL_FLAG}    False
@{FAULTS_EXCLUDED_CHECKING}    8000    62003    62001    7306    7308    7107    7311    7307
${max_loop}    60

*** Test Cases ***
CB013303-SR-inter frequency handover KPI
    clear counter files    wait=False
    adjust pa all ports max value

    log    step: attach with associated 5qi-6 DRB, start dl/ul traffic and make bler then check BRLA-1 counters    console=True
    adjust_pa_for_cell    cell_id=1    value=30
    Prepare UEs    ue_ids=1,2    get_spark_license=${True}
    Attach UE with CGACT without Prepare    ue_id=1
    Attach UE with CGACT without Prepare    ue_id=2
    start ul and dl traffic    ue_id=1    send_traffic_ul=50M    send_traffic_dl=100M
    start ul and dl traffic    ue_id=2    send_traffic_ul=50M    send_traffic_dl=100M

    log    step: trigger interFreqHo between TDD and FDD cells    console=True
    FOR    ${cur_loop}    IN RANGE    0    ${max_loop}
        adjust pa stepwise for cell    cell_id=1    start_value=30    end_value=60    step=3    interval=2
        adjust pa stepwise for cell    cell_id=10    start_value=50    end_value=20    step=-3    interval=2
        Sleep    10
        adjust pa stepwise for cell    cell_id=10    start_value=20    end_value=50    step=3    interval=2
        adjust pa stepwise for cell    cell_id=1    start_value=60    end_value=30    step=-3    interval=2
        Sleep    10
    END

    log    step: check Tput and PM Counter and KPI    console=True
    Run Keyword And Ignore Error    Collect And Check Tput    cells=1    ue_id=1    dl_target_tp=1M    ul_target_tp=1M
    Run Keyword And Ignore Error    Collect And Check Tput    cells=1    ue_id=2    dl_target_tp=1M    ul_target_tp=1M
    ${counters}    combine lists
    ...    ${CELL_PDSCH_PRFL1_INCREASE}    ${CELL_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL_PUSCH_PRFL1_INCREASE}    ${CELL_PUSCH_PRFL2_NOT_INCREASE}
    check counters    ${counters}
    check ibler based on counters    cell_id=1    phy_prfl=PDSCH_PRFL1    target_bler=5
    check ibler based on counters    cell_id=1    phy_prfl=PUSCH_PRFL1    target_bler=5
    check ibler based on counters    cell_id=2    phy_prfl=PDSCH_PRFL1    target_bler=5
    check ibler based on counters    cell_id=2    phy_prfl=PUSCH_PRFL1    target_bler=5
    # check ibler for legacy counters    cell_id=1    measurement_type=PDSCH
    # check ibler for legacy counters    cell_id=1    measurement_type=PUSCH_CP
    # check ibler for legacy counters    cell_id=2    measurement_type=PDSCH
    # check ibler for legacy counters    cell_id=2    measurement_type=PUSCH_CP
    Report KPI Report To Scout    template_id=2800

    [Teardown]    Run Keywords    Stop UL And DL traffic
    ...                           Detach All UEs
    ...                           Common Test Teardown And Stop Capture Logs

*** Keywords ***
check ibler based on counters
    [Arguments]    ${cell_id}    ${phy_prfl}    ${target_bler}
    ${phy_type}    ${prfl}    Split String    ${phy_prfl}    _
    ${counters_value}    create list
    ...    NRCELL-${cell_id}:${${phy_type}_INI_TX_BRD_${prfl}}
    ...    NRCELL-${cell_id}:${${phy_type}_SUCC_INI_TX_BRD_${prfl}}
    ${int_tx}    ${succ_int_tx}    get counters value     ${counters_value}    wait=False
    ${iber}    Run Keyword If    ${int_tx} > 0    evaluate    ${${int_tx}-${succ_int_tx}}/${int_tx}*100
    ...    ELSE    Set Variable    0
    Run Keyword And Ignore Error    should be true    ${${target_bler}-2}<${iber}<${${target_bler}+2}
    ${bler_res}    Catenate    Expected ${phy_prfl} iBLER is within ${${target_bler}-2} ~ ${${target_bler}+2},
    ...    Actual iBLER is ${iber}
    Log    ${bler_res}    console=True

check ibler for legacy counters
    [Arguments]    ${cell_id}    ${measurement_type}    ${target_bler}=5    ${mcs_table}=256TBL
	${total_int_tx}    Set Variable    0
	${total_succ_int_tx}    Set Variable    0
    FOR    ${mcs}    IN RANGE    0    28
        ${mcs_id}    Set Variable If    ${mcs} < 10    0${mcs}    ${mcs}
        ${counters_value}    create list
        ...    NRCELL-${cell_id}:${${measurement_type}_INI_${mcs_table}_MCS${mcs_id}}
        ...    NRCELL-${cell_id}:${${measurement_type}_SUCC_INI_${mcs_table}_MCS${mcs_id}}
        ${int_tx}    ${succ_int_tx}    get counters value     ${counters_value}    wait=False
        ${total_int_tx}    evaluate    ${total_int_tx} + ${int_tx}
        ${total_succ_int_tx}    evaluate    ${total_succ_int_tx} + ${succ_int_tx}
    END
    ${iber}    Run Keyword If    ${total_int_tx} > 0    evaluate    ${${total_int_tx}-${total_succ_int_tx}}/${total_int_tx}*100
    ...    ELSE    Set Variable    0
    Run Keyword And Ignore Error    should be true    ${${target_bler}-2}<${iber}<${${target_bler}+2}
    ${bler_res}    Catenate    Expected ${measurement_type}_${mcs_table} iBLER is within ${${target_bler}-2} ~ ${${target_bler}+2},
    ...    Actual iBLER is ${iber}
    Log    ${bler_res}    console=True

Detach All UEs
    Run Keyword And Ignore Error    Detach UE    ue_id=2
    Run Keyword And Ignore Error    Detach UE    ue_id=1

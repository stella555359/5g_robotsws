*** Settings ***
Documentation
...    author: Li Zhiguo
...    contact: zhiguo.li@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
Suite Setup       Common Suite Setup And Setup BTS env    scf=SCFC_1_GMC_IWK.xml
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS24R3    tl-7_5_UTE5G402T2404
Resource          ./resources/CB013303_resource.robot

*** Variables ***
${EMIL_FLAG}    False
@{FAULTS_EXCLUDED_CHECKING}    8000    62003    62001    7306    7308    7107    7311    7307
${PCELL_MAX_PA_VALUE}    75
${SCELL_MAX_PA_VALUE}    60

*** Test Cases ***
CB013303-SR-C5_31_Check NRPDSCHBRLA and NRPUSCHBRLA counters on PCell and NRPDSCHBRLA on SCells during NSA 3x DL CA is active
    clear counter files    wait=Fals
    Block NRCell2
    # Ajust MCS Att    value=30
    adjust_pa_for_cell    cell_id=1    value=30
    adjust_pa_for_cell    cell_id=12    value=20

    ${step_1_info}    Catenate    step: attach to LTE and setup ENDC without associated DRB, start dl/ul traffic and make bler
    ...     then check PM counter of NRPDSCHBRLA-1 and NRPUSCHBRLA-1 not increase on PSCell and SCell
	log   ${step_1_info}    console=True
    prepare and attach UE with CGACT    attach_mode=5G_NSA    get_spark_license=${True}
    start ul and dl traffic    send_traffic_ul=200M    send_traffic_dl=600M    ue_mode=NSA
    # Ajust MCS Att Stepwise    start_value=30    end_value=${PCELL_MAX_PA_VALUE}
    adjust pa stepwise for cell    cell_id=1    start_value=30    end_value=${PCELL_MAX_PA_VALUE}
    adjust pa stepwise for cell    cell_id=12    start_value=20    end_value=${SCELL_MAX_PA_VALUE}
    ${counters}    combine lists
    ...    ${CELL1_PDSCH_PRFL1_NOT_INCREASE}    ${CELL1_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL1_PUSCH_PRFL1_NOT_INCREASE}    ${CELL1_PUSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL12_PDSCH_PRFL1_NOT_INCREASE}    ${CELL12_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL12_PUSCH_PRFL1_NOT_INCREASE}    ${CELL12_PUSCH_PRFL2_NOT_INCREASE}
    check counters    ${counters}

    log    step: add QCI-9, la from NRPDSCHBRLA-1 and NRPUSCHBRLA-1    console=True
    clear counter files    wait=False
    add 5qi bearer    5qi=9
    ${counters}    combine lists
    ...    ${CELL1_PDSCH_PRFL1_INCREASE}    ${CELL1_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL1_PUSCH_PRFL1_INCREASE}    ${CELL1_PUSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL12_PDSCH_PRFL1_INCREASE}    ${CELL12_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL12_PUSCH_PRFL1_NOT_INCREASE}    ${CELL12_PUSCH_PRFL2_NOT_INCREASE}
    check counters    ${counters}
    check ibler based on counters    cell_id=1    phy_prfl=PDSCH_PRFL1    target_bler=5
    check ibler based on counters    cell_id=12    phy_prfl=PDSCH_PRFL1    target_bler=5
    check ibler based on counters    cell_id=1    phy_prfl=PUSCH_PRFL1    target_bler=5
    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=add_5qi9    cell_id=1,12    decode_flag=True
    ${dl_tti_file}=    Get Dl Tti Decoded File    ${ttitrace_log_path}
    Check Link Adaptation    ${dl_tti_file}    # ${ttitrace_log_path}/tcpdump_ttitrace.TTI_combined.1-1.dl__all.csv
    ...                      targetbler=0.05
    ...                      stepdown=0.5
    ...                      cell_ids=1
    ...                      mcstable=QAM64
    # Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
    # ...                      targetbler=0.05
    # ...                      stepdown=0.8
    # ...                      cell_ids=1
    # ...                      mcstable=QAM64

    log    step: add QCI-8, la from NRPDSCHBRLA-2 and NRPUSCHBRLA-2    console=True
    clear counter files    wait=False
    add 5qi bearer    5qi=8
    ${counters}    combine lists
    ...    ${CELL1_PDSCH_PRFL2_INCREASE}    ${CELL1_PDSCH_PRFL1_NOT_INCREASE}
    ...    ${CELL1_PUSCH_PRFL2_INCREASE}    ${CELL1_PUSCH_PRFL1_NOT_INCREASE}
    ...    ${CELL12_PDSCH_PRFL2_INCREASE}    ${CELL12_PDSCH_PRFL1_NOT_INCREASE}
    ...    ${CELL12_PUSCH_PRFL2_NOT_INCREASE}    ${CELL12_PUSCH_PRFL1_NOT_INCREASE}
    check counters    ${counters}
    check ibler based on counters    cell_id=1    phy_prfl=PDSCH_PRFL2    target_bler=8
    check ibler based on counters    cell_id=12    phy_prfl=PDSCH_PRFL2    target_bler=8
    check ibler based on counters    cell_id=1    phy_prfl=PUSCH_PRFL2    target_bler=8

    log    step: release QCI-8 and QCI-9, la from cell level configuration    console=True
    clear counter files    wait=False
    del 5qi bearer    5qi=8
    del 5qi bearer    5qi=9
    ${counters}    combine lists
    ...    ${CELL1_PDSCH_PRFL1_NOT_INCREASE}    ${CELL1_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL1_PUSCH_PRFL1_NOT_INCREASE}    ${CELL1_PUSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL12_PDSCH_PRFL1_NOT_INCREASE}    ${CELL12_PDSCH_PRFL2_NOT_INCREASE}
    ...    ${CELL12_PUSCH_PRFL1_NOT_INCREASE}    ${CELL12_PUSCH_PRFL2_NOT_INCREASE}
    check counters    ${counters}
    check ibler for legacy counters    cell_id=1    measurement_type=PDSCH
    check ibler for legacy counters    cell_id=12    measurement_type=PDSCH
    check ibler for legacy counters    cell_id=1    measurement_type=PUSCH_CP

    [Teardown]    Run Keywords    Stop UL And DL traffic
    ...                           Detach UE
    ...                           Unblock NRCell2
    ...                           Common Test Teardown And Stop Capture Logs

*** Keywords ***
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
    ${bler_res}    Catenate    Expected CELL-${cell_id}:${phy_prfl} iBLER is within
    ...    ${${target_bler}-2} ~ ${${target_bler}+2}, Actual iBLER is ${iber}
    Log    ${bler_res}    console=True

check ibler for legacy counters
    [Arguments]    ${cell_id}    ${measurement_type}    ${target_bler}=10    ${mcs_table}=64TBL
	${total_int_tx}    Set Variable    0
	${total_succ_int_tx}    Set Variable    0
    FOR    ${mcs}    IN RANGE    0    29
        ${mcs_id}    Set Variable If    ${mcs} < 10    0${mcs}    ${mcs}
        ${counters_value}    create list
        ...    last NRCELL-${cell_id}:${${measurement_type}_INI_${mcs_table}_MCS${mcs_id}}
        ...    last NRCELL-${cell_id}:${${measurement_type}_SUCC_INI_${mcs_table}_MCS${mcs_id}}
        ${int_tx}    ${succ_int_tx}    get counters value     ${counters_value}    wait=False
        ${total_int_tx}    evaluate    ${total_int_tx} + ${int_tx}
        ${total_succ_int_tx}    evaluate    ${total_succ_int_tx} + ${succ_int_tx}
    END
    ${iber}    Run Keyword If    ${total_int_tx} > 0    evaluate    ${${total_int_tx}-${total_succ_int_tx}}/${total_int_tx}*100
    ...    ELSE    Set Variable    0
    Run Keyword And Ignore Error    should be true    ${${target_bler}-2}<${iber}<${${target_bler}+2}
    ${bler_res}    Catenate    Expected CELL-${cell_id}:${measurement_type}_${mcs_table} iBLER is within
    ...    ${${target_bler}-2} ~ ${${target_bler}+2}, Actual iBLER is ${iber}
    Log    ${bler_res}    console=True

Get Dl Tti Decoded File
    [Arguments]    ${ttitrace_log_folder}
    @{tti_decoded_list}=    Create List
    ...    ttiTrace_dl.csv
    ...    tcpdump_ttitrace.TTI_combined.1-1.dl__all.csv
    ...    tcpdump_ttitrace.TTI_combined.1.dl__all.csv
    # ...    2-2/2-1/2/1-2.dl__all.csv
    FOR    ${i}    IN    @{tti_decoded_list}
        ${ret}=     Run Keyword And Return Status    File Should Exist    ${ttitrace_log_folder}/${i}
        # Return From Keyword If    ${ret}    ${ttitrace_log_folder}/${i}
        Run Keyword If    ${ret} and '${ttitrace_log_folder}/${i}' != 'ttiTrace_dl.csv'
        ...    Move File    ${ttitrace_log_folder}/${i}    ${ttitrace_log_folder}/ttiTrace_dl.csv
        Return From Keyword If    ${ret}    ${ttitrace_log_folder}/ttiTrace_dl.csv
    END
    FAIL    [Errno 2] No such file or directory: '${ttitrace_log_folder}/ttiTrace_dl.csv'    FileNotFoundError

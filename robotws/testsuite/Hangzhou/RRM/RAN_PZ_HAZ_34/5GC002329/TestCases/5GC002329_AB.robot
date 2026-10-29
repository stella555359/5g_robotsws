*** Settings ***
Resource    ./../Resources/5GC002329_keywords.robot

Documentation    Suite description
...    author: Fang Dandan
...    contact: dandan.fang@nokia-sbell.com
...    squad group: MMW_SG1
...    Feature 5GC002329-AB

Force Tags    5G_RRM
...    PY36    RF50
Suite Setup  2329 Suite preparation
Suite Teardown  run keyword and ignore error    CA Suite teardown

*** Test Cases ***
5GC002329-AB_002_B2_Single_UE_connection_setup_and_DL_UL_data_scheduling_in_SA_option2_with_beamforming_A1_Scell_addition_RLQ-based_deactivation
    [Tags]             CRT_TRUNK    CIT_22R1    CIT_22R2    CRT_22R1    CRT_22R3    CDRT_22R2    CRT_22R4    CRT_23R1
    [Documentation]    author: dandan.fang@nokia-sbell.coms \n\n
    ...   *Manual Guide https://confluence.ext.net.nokia.com/display/5GRANHZ/5GC002329-AB_002_B2_Single_UE_connection_setup_and_
    ...    DL_UL_data_scheduling_in_SA_option2_with_beamforming_A1_Scell_addition_RLQ-based_deactivation*
    ...    *Precondition    covBasedA1 configured for Pcell, Radio link parameter configured for Scell.*
    ...      | 1 | ue attach and scell addition, activated with big data. |
    ...      | 2 | Scell RLQ changed from good to bad, scell data suspened;|
    ...      | 3 | Scell RLQ bad to good, data resume. |
    ...      | 4 | Scell RLQ remain in bad, and bad RLQ count match, trigger scell deactive permanent. |
    ...      | 5 | Scell RLQ back to good, no scell active triggered. |
    [Setup]    Common case setup    NSA_SA=${NSA_SA}
    Modify sCell addition method to covBasedA1   cell_index=${PCELL_ID}
    ...                                          a1ThresholdSCellAddSsbRsrp_FDD=${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}

    Modify radio link monitoring parameters work on scell
    ...    badrlqcount=${SCELL_BAD_RLQ_COUNT}      period=${SCELL_CHANNEL_ESTIMATION_PERIOD}

    run keyword and continue on failure  CA L3 call tput check with UL rank1 issue ignored for T+F TDD cell
    ...    NSA_SA=${NSA_SA}        scell_addition_method=covBasedA1
    ...    check_scell_activation=${True}         duration=1200

#    run keyword and continue on failure       CA_basic_L3_call   scell_addition_method=covBasedA1
#    ...       check_scell_activation=${True}         duration=1200

    #60s timer need small than bad_rlq_count*sCellChannelEstimationPeriod/1000,80*2000ms/1000
    run keyword and continue on failure        Verify scell data suspened and not deactivated when scell rlq in bad
    ...                      pa_scell_rlq_bad=${SCELL_LOW_THAN_BAD_MCS}

    run keyword and continue on failure      Verify scell data resumed when scell rlq back to good
    ...             pa_scell_rlq_good=${SCELL_GOOD}

    ${scell_deactivate_time}  evaluate  ${SCELL_BAD_RLQ_COUNT}*(${SCELL_CHANNEL_ESTIMATION_PERIOD})/1000
    run keyword and continue on failure      Verify scell permanent deactivated when scell rlq remain in bad
    ...             pa_scell_rlq_bad=${SCELL_LOW_THAN_BAD_MCS}    scell_deactivate_time=${scell_deactivate_time}
    ...             scell_id=${SCELL_ID}    scell_operator_mode=dl_only

    run keyword and continue on failure    Verify scell not activate when rlq bad into good after scell permanent deactivated
    ...          scell_rlq_good=${SCELL_GOOD}

    [Teardown]    run keyword and ignore error  run keywords      Common case teardown    detach_ue=${True}
    ...    AND   Initialize attenuator values for testline  pa_values_mapping=${INIT_PA_F_T}


5GC002329-AB_005_B4_Single_UE_connection_setup_and_DL_UL_data_scheduling_in_SA_option2_with_BF_buff-based_activate_A1_Scell_add_A2_SCell_release
    [Tags]       CIT_TRUNK     CIT_22R1    CIT_22R2    CRT_22R1    CIT_22R3    CDRT_22R2    CIT_22R4    CDRT_22R3
    [Documentation]    author: dandan.fang@nokia-sbell.com
    ...   Precondition:  covBasedA1 configured for Pcell, A2 Meas release for Scell
    ...   Step1:A1 configured after attach with Pcell signal bad
    ...   Step2:A1 report and scell addition , inactivate when Pcell signal change to good
    ...   Step3:Scell activate when DL traffic increase from small to big for bufferbased
    ...   Step4:Scell deactivate when DL traffic stop with Bufferbased
    ...   Step5:A2 report and scell released when scell signal and pcell in bad
    ...   Step6:Scell addition again when Pcell signal change to Good
    [Setup]    Common case setup    NSA_SA=${NSA_SA}
    Modify sCell addition method to covBasedA1   cell_index=${PCELL_ID}
    ...                                         a1ThresholdSCellAddSsbRsrp_FDD=${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}

    Configure A2 Measurement For SCell Release Enabled     cell_index=${SCELL_ID}
    ...                                          a2ThresholdSCellRelSsbRsrp=${A2_THRESHOLD_SCELL_REL_SSB_RSRP}

    ${A1_configured_log_path}    Verify A1 configured and no Scell addition after attach with Pcell signal bad
    ...       exp_pa_value=${PCELL_BAD}         NSA_SA=${NSA_SA}

    ${a1ReportId}        Get reportConfigId for special measEvent in cpif log     log_path_pcap=${A1_configured_log_path}
    ...        measEvent=eventA1

    ${A2_configured_log_path}       Verify A1 report and Scell addition but in inactivate when Pcell Signal From Bad To Good
    ...        a1_rsrp_thres=${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}      meas_id=${a1ReportId}
    ...        a2_meas_for_scell_released=${True}
    ...        exp_pa_value=${PCELL_GOOD}

    ${a2ReportId}        Get reportConfigId for special measEvent in cpif log     log_path_pcap=${A2_configured_log_path}
    ...        measEvent=eventA2

    ${case_start_time_info}    Prepare for counter log

    run keyword and continue on failure    Check Scell activate when DL traffic increase from Small to Big with Bufferbased
    ...       dlTraffic_Small=${PCELL_TDD_DL_TRAFFIC_SMALL}
    ...       dlTraffic_big=${DL_TPUT}

    Check Scell deactivate when DL traffic stop with Bufferbased    scell_operator_mode=dl_only   scell_id=${SCELL_ID}

    run keyword and continue on failure       check Scell activations M55316C09000 Scell Deactivation due to Buffer M55316C09001
    ...      starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}

    A2 report and Scell released when Scell signal in bad
    ...            exp_pa_value_pcell=${PCELL_BAD}         exp_pa_value_scell=${SCELL_A2_RELEASED_PA}
    ...            a2_rsrp_thres=${A2_THRESHOLD_SCELL_REL_SSB_RSRP}       meas_id=${a2ReportId}

    Verify scell added again after released when pcell signal back to good
    ...            exp_pa_value_pcell=${INIT_PA_F_T}

    [Teardown]     run keyword and ignore error      run keywords    Common case teardown    detach_ue=${True}
    ...    AND    Initialize attenuator values for testline  pa_values_mapping=${INIT_PA_F_T}

5GC002329-AB_006_B6_UE_overheating_triggered_Scell_scheduling_suspension_with_beamforming_bufferbased_activation_TDD_100M_FDD_20M
    [Tags]         CRT_22R1    CRT_22R2
    [Documentation]    author: dandan.fang@nokia-sbell.com
    ...   Step1:UE attached on TDD and FDD as Scell peak data
    ...   Step2:5G-UE triggers overheating by sending CQI=0 for FDD SCell, Scell data suspened, and no deactivated
    ...         Pcell traffic drop to half
    ...   Step3:5G-UE stop indicating overheating by sending CQI ≠ 0 for FDD SCell. Scell data resume.
    ...   NOte:when trigger overheating, maybe ul data will be stopped , maybe caused by adb root, no need to check UL.
    [Setup]    Common case setup    NSA_SA=SA
    #ue need to be root first before UL traffic start
    wait until keyword succeeds     3X    1s    Overheat.root_ue_before_send_cqi     ue_sn=${tl.ues[${0}].serial_number}
    ...    hostname=${tl.ues[${0}].ssh_connection_details.addr}

    run keyword and continue on failure  CA L3 call tput check with UL rank1 issue ignored for T+F TDD cell
    ...    NSA_SA=${NSA_SA}     tcpdump_log_name=initial_tput

#    run keyword and continue on failure    CA_basic_L3_call    tput_duration=30    duration=3600
#     ...    tcpdump_log_name=initial_tput

    run keyword and continue on failure    Verify scell data suspend and no deactivated when overheating trigger

    run keyword and continue on failure    Verify scell data resume when overheating stop

    [Teardown]    run keyword and ignore error    run keywords     wait until keyword succeeds     3X    1s
    ...    Overheat.set_cqi_value    cqi_value=${0}   ue_sn=${tl.ues[${0}].serial_number}    hostname=${tl.ues[${0}].ssh_connection_details.addr}
    ...    AND    ssh.disconnect    connection=cygwin
    ...    AND    ssh.disconnect    connection=login_cpc
    ...    AND    Common case teardown    detach_ue=${True}

*** Keywords ***
check Scell activations M55316C09000 Scell Deactivation due to Buffer M55316C09001
    [Documentation]    author: dandan.fang@nokia-sbell.com
    ...      Following counter will be counted under Scell
    ...      M55316C09000: This counter provides the number of S-Cell activations while pegged in the secondary cell.
    ...      When an S-Cell transition to "active" is triggered
    ...      M55316C09001: This counter provides the number of S-Cell deactivations due to Buffer Status while pegged
    ...      in secondary cell. When an S-Cell transition to "inactive" is triggered.
    [Arguments]       ${starting_log_timestamp}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
    ${cell_check_list}    create list     ${SCELL_ID}
    ${list_measurement_ids}    create list    M55316C09000    M55316C09001
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${pm_files_local_path}
    ...      list_cell=${cell_check_list}          list_measurement_ids=${list_measurement_ids}

    ${scell_M55316C09000}    set variable    ${dict_measurements_value['${scell_id}']['M55316C09000']}
    ${scell_M55316C09001}    set variable    ${dict_measurements_value['${scell_id}']['M55316C09001']}
    run keyword and continue on failure   run keywords    Should be true      ${scell_M55316C09000} >= ${1}
    ...                                        AND        Should be true      ${scell_M55316C09001} >= ${1}

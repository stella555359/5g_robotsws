*** Settings ***
Documentation    CB0010630 RIMRS
Resource     CB010630_variables.robot
Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009823/Resources/CB009823_keywords.robot

*** Keywords ***
10630 case setup
    [Documentation]    10630 case setup
    ...    Author: Cheng Cathrine
    [Arguments]   ${frame_bw}
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_10630_rim_restapi.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_10630_${frame_bw}.py
    9823 case setup
    # modify pmax of aggressor for 13350 case
    # ${PARAMS_TO_MODIFY_GNB1}    combine_lists    ${MODIFY_PMAX_AGGRESSOR_13350_SCF}    ${PARAMS_TO_MODIFY_GNB1}


Recovery aggressor pMax via restAPI and Wait Cell on air
    [Documentation]    Set pMax via restAPI
    ...    Author: Catherine Cheng
    [Arguments]    ${paras}    ${timeout}=${CLASSICAL_COMMISSION_ONAIR_TIMEOUT}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${paras}
    ...    skip_parameter_relation_errors=${False}
    ...    connection=${OAM_ALIAS_GNB1}

    Wait until cluster is on cell on air status    timeout=${timeout}
    ...    is_all_cells_checking_needed=${True}    enb_index=${None}
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
    ...    connection=${OAM_ALIAS_GNB1}
    ...    gnb_index=${1}

Check there is fault 7525 fault 7527 and no fault 7535
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${alarm_check_timeout}=10min
    run keyword and continue on failure    Wait and Verify Fault Present on Cells    faultId=7525
                                                                    ...    alarm_check_timeout=${alarm_check_timeout}
                                                                    ...    alarm_check_interval=30sec
    ${supplementary}    Get Supplementary for Fault 7527    SetId_Aggressor=${CONFIGS_GNB_AGGRESSOR["rsSetId"]}
    ...    dlMuteSlotsStr=${DLMUTESLOTSSTR}    feature=9823   setId_show_in_fault=${True}
    run keyword and continue on failure    Wait and Verify Fault Present on Cells    faultId=7527
                                                        ...    alarm_check_timeout=10m
                                                        ...    alarm_check_interval=10sec
                                                        ...    supplementary=${supplementary}

    run keyword and continue on failure     Expect Fault Present on Cells or not    cell_list=@{TDD_CELL_ID_LIST}
                                        ...    faultId=7535    alarmId=7115   present=${False}
                                        ...    connection=${connection_GNB_victim}     gnb_index=0

Check there is fault 7525 no fault 7527 fault 7535
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${alarm_check_timeout}=10min    ${sleep_time}=2min
    run keyword and continue on failure    Wait and Verify Fault Present on Cells    faultId=7525
                                                                    ...    alarm_check_timeout=${alarm_check_timeout}
                                                                    ...    alarm_check_interval=30sec
    sleep    ${sleep_time}
    run keyword and continue on failure     Expect Fault Present on Cells or not    cell_list=@{TDD_CELL_ID_LIST}
                                        ...    faultId=7527    alarmId=7115   present=${False}
                                        ...    connection=${connection_GNB_victim}     gnb_index=0

    run keyword and continue on failure     Expect Fault Present on Cells or not    cell_list=@{TDD_CELL_ID_LIST}
                                        ...    faultId=7535    alarmId=7115   present=${False}
                                        ...    connection=${connection_GNB_victim}     gnb_index=0


Check PM counters for soft muting or power reduction
    [Documentation]    Author: Liu Zheng
    ...    CB013350-soft muting couners use legacy counters.
    ...    M55194C00003	DUR_DL_SPCL_MUT_RIM_MITG
    ...    M55194C00281 DUR_1ST_DL_MUT_RIM_MITG
    ...    M55194C00282 DUR_2ND_DL_MUT_RIM_MITG
    ...    CB012719-power reduction counters
    ...    M55194C00285 DUR_1ST_DL_PWR_RED_RIM_MITG. This counter provides the total duration for which power reduction criteria are
    ...    satisfied for the first DL slot preceding the special slot for RIM mitigation during the measurement interval.
    ...    M55194C00286 DUR_2ND_DL_PWR_RED_RIM_MITG. This counter provides the total duration for which power reduction criteria are
    ...    satisfied for the second DL slot preceding the special slot for RIM mitigation during the measurement interval.
    ...    M55194C00287 DUR_DL_SPCL_PWR_RED_RIM_MITG. This counter provides the total duration for which power reduction criteria are
    ...    satisfied for the special slot for RIM mitigation during the measurement interval.
    ...    M55194C00283    PRB_USED_PDSCH_MUT_HI_PRI_DATA
    ...    M55194C00284    NUM_MUT_SLOT_SCHD_HI_PRI_DATA
    ...    M55308C10001    PRB_USED_PDSCH
    ...    M55308C10003    PRB_AVAIL_PDSCH
    ...    M55308C10011    PRB_USED_PAGING
    ...    M55308C10015    PRB_USED_SIB
    ...    cell_load=(M55308C10001+M55308C10011+M55308C10015)/M55308C10003
    [Arguments]    ${pm_files_local_path}
    ...    ${cell_check_list}=${TDD_CELL_ID_LIST}    ${Check_Mitigation}=${True}    ${check_PWR}=${False}
    ...    ${is_sl_update_soft_mute}=${True}    ${is_1st_dl_update_soft_mute}=${True}    ${is_2nd_dl_update_soft_mute}=${False}
    ...    ${is_sl_update_pwr}=${False}    ${is_1st_dl_update_pwr}=${False}    ${is_2nd_dl_update_pwr}=${False}
    ...    ${check_cell_load}=${True}      ${is_high_cell_load}=${False}      ${cell_load_threshold_for_rim_mitigation}=0.5
    ...    ${Check_high_priority_data}=${False}    ${is_high_prio_data_enabled}=${False}
    ${list_measurement_ids_soft_muting}    create list    M55194C00003   M55194C00281    M55194C00282
    ${list_measurement_ids_power reduction}    create list    M55194C00285   M55194C00286    M55194C00287
    ${list_measurement_ids_high_priority}    create list    M55194C00283    M55194C00284
    ${list_measurement_ids_cell_load}    create list        M55308C10001    M55308C10003    M55308C10011    M55308C10015

    ${list_measurement_ids}     combine lists    ${list_measurement_ids_soft_muting}    ${list_measurement_ids_power reduction}
    ...    ${list_measurement_ids_high_priority}    ${list_measurement_ids_cell_load}

    ${cell_id}    set variable   ${cell_check_list[0]}
    FOR    ${file_path}    IN    @{pm_files_local_path}
        ${dict_meas_val}    counter.get_cell_counters_from_file    file_path=${file_path}
                                                        ...      list_cell=${cell_check_list}
                                                        ...      list_measurement_ids=${list_measurement_ids}
        run keyword and continue on failure    run keyword if    ${Check_Mitigation}    Check PM Counters for soft muting
                                                                                    ...    ${dict_meas_val}
                                                                                    ...    ${cell_id}
                                                                                    ...    is_sl_update=${is_sl_update_soft_mute}
                                                                                    ...    is_1st_dl_update=${is_1st_dl_update_soft_mute}
                                                                                    ...    is_2nd_dl_update=${is_2nd_dl_update_soft_mute}
        run keyword and continue on failure    run keyword if    ${Check_PWR}      Check PM counters for PWR
                                                                                    ...    ${dict_meas_val}
                                                                                    ...    ${cell_id}
                                                                                    ...    is_sl_update=${is_sl_update_pwr}
                                                                                    ...    is_1st_dl_update=${is_1st_dl_update_pwr}
                                                                                    ...    is_2nd_dl_update=${is_2nd_dl_update_pwr}

        run keyword and continue on failure    run keyword if    ${check_cell_load}==${True} and ${is_high_cell_load}==${True}
                                             ...    Check PM counters for cell load
                                             ...    ${dict_meas_val}
                                             ...    ${cell_id}
                                             ...    is_high_cell_load=${True}
                                             ...    cell_load_threshold_for_rim_mitigation=${cell_load_threshold_for_rim_mitigation}
                                             ...    ELSE IF    ${check_cell_load}==${True} and ${is_high_cell_load}==${False}
                                             ...    Check PM counters for cell load
                                             ...    ${dict_meas_val}
                                             ...    ${cell_id}
                                             ...    is_high_cell_load=${False}
                                             ...    cell_load_threshold_for_rim_mitigation=${cell_load_threshold_for_rim_mitigation}
                                             ...    ELSE    log to console    no need to check cell load

        run keyword and continue on failure    run keyword if    ${Check_high_priority_data}     Check PM counters for high priority data
                                             ...   ${dict_meas_val}
                                             ...    ${cell_id}
                                             ...    is_high_prio_data_enabled=${is_high_prio_data_enabled}
    END

Check PM counters for soft muting
    [Documentation]    Author: Liu Zheng
    [Arguments]   ${dict_meas_val}     ${cell_id}
    ...    ${is_sl_update}=${True}    ${is_1st_dl_update}=${True}    ${is_2nd_dl_update}=${False}
    ${dur_spcl_mut}    set variable     ${dict_meas_val['${cell_id}']['M55194C00003']}
    ${dur_1st_dl_mut}    set variable     ${dict_meas_val['${cell_id}']['M55194C00281']}
    ${dur_2nd_dl_mut}    set variable     ${dict_meas_val['${cell_id}']['M55194C00282']}
    run keyword and continue on failure    run keyword if    ${is_sl_update}
    ...    should be true    '${dur_spcl_mut}'=='299.0' or '${dur_spcl_mut}'=='300.0' or '${dur_spcl_mut}'=='301.0'
    ...    ELSE      should be true      '${dur_spcl_mut}'=='0.0'
    run keyword and continue on failure    run keyword if    ${is_1st_dl_update}
    ...    should be true    '${dur_1st_dl_mut}'=='299.0' or '${dur_1st_dl_mut}'=='300.0' or '${dur_1st_dl_mut}'=='301.0'
    ...    ELSE      should be true      '${dur_1st_dl_mut}'=='0.0'
    run keyword and continue on failure    run keyword if    ${is_2nd_dl_update}
    ...    should be true    '${dur_2nd_dl_mut}'=='299.0' or '${dur_2nd_dl_mut}'=='300.0' or '${dur_2nd_dl_mut}'=='301.0'
    ...    ELSE      should be true      '${dur_2nd_dl_mut}'=='0.0'

Check PM counters for PWR
    [Documentation]    Author: Liu Zheng
    [Arguments]   ${dict_meas_val}     ${cell_id}
    ...    ${is_sl_update}=${True}    ${is_1st_dl_update}=${True}    ${is_2nd_dl_update}=${False}
    ${dur_spcl_mut}    set variable     ${dict_meas_val['${cell_id}']['M55194C00287']}
    ${dur_1st_dl_mut}    set variable     ${dict_meas_val['${cell_id}']['M55194C00285']}
    ${dur_2nd_dl_mut}    set variable     ${dict_meas_val['${cell_id}']['M55194C00286']}
    run keyword and continue on failure    run keyword if    ${is_sl_update}
    ...    should be true    '${dur_spcl_mut}'=='299.0' or '${dur_spcl_mut}'=='300.0' or '${dur_spcl_mut}'=='301.0'
    ...    ELSE      should be true      '${dur_spcl_mut}'=='0.0'
    run keyword and continue on failure    run keyword if    ${is_1st_dl_update}
    ...    should be true    '${dur_1st_dl_mut}'=='299.0' or '${dur_1st_dl_mut}'=='300.0' or '${dur_1st_dl_mut}'=='301.0'
    ...    ELSE      should be true      '${dur_1st_dl_mut}'=='0.0'
    run keyword and continue on failure    run keyword if    ${is_2nd_dl_update}
    ...    should be true    '${dur_2nd_dl_mut}'=='299.0' or '${dur_2nd_dl_mut}'=='300.0' or '${dur_2nd_dl_mut}'=='301.0'
    ...    ELSE      should be true      '${dur_2nd_dl_mut}'=='0.0'

Check PM counters for cell load
    [Documentation]    Author: Liu Zheng
    ...    M55308C10001    PRB_USED_PDSCH
    ...    M55308C10003    PRB_AVAIL_PDSCH
    ...    M55308C10011    PRB_USED_PAGING
    ...    M55308C10015    PRB_USED_SIB
    ...    cell_load=(M55308C10001+M55308C10011+M55308C10015)/M55308C10003
    [Arguments]   ${dict_meas_val}     ${cell_id}
    ...      ${is_high_cell_load}=${False}      ${cell_load_threshold_for_rim_mitigation}=0.5
    ${PRB_USED_PDSCH}    set variable     ${dict_meas_val['${cell_id}']['M55308C10001']}
    ${PRB_AVAIL_PDSCH}    set variable     ${dict_meas_val['${cell_id}']['M55308C10003']}
    ${PRB_USED_PAGING}    set variable     ${dict_meas_val['${cell_id}']['M55308C10011']}
    ${PRB_USED_SIB}    set variable     ${dict_meas_val['${cell_id}']['M55308C10015']}
    ${cell_load}    evaluate      (${PRB_USED_PDSCH}+${PRB_USED_PAGING}+${PRB_USED_SIB})/${PRB_AVAIL_PDSCH}
    run keyword if    ${is_high_cell_load}    should be true    ${cell_load}>=${cell_load_threshold_for_rim_mitigation}
    ...    ELSE    should be true    ${cell_load}<${cell_load_threshold_for_rim_mitigation}

Check PM counters for high priority data
    [Documentation]    Author: Liu Zheng
    ...    M55194C00283    PRB_USED_PDSCH_MUT_HI_PRI_DATA
    ...    M55194C00284    NUM_MUT_SLOT_SCHD_HI_PRI_DATA
    [Arguments]   ${dict_meas_val}     ${cell_id}    ${is_high_prio_data_enabled}=${False}
    ${PRB_USED_PDSCH_MUT_HI_PRI_DATA}    set variable     ${dict_meas_val['${cell_id}']['M55194C00283']}
    ${NUM_MUT_SLOT_SCHD_HI_PRI_DATA}    set variable     ${dict_meas_val['${cell_id}']['M55194C00284']}
    run keyword and continue on failure    run keyword if    ${is_high_prio_data_enabled}
    ...    should be true    '${PRB_USED_PDSCH_MUT_HI_PRI_DATA}' > '0'
    ...    ELSE      should be true      '${PRB_USED_PDSCH_MUT_HI_PRI_DATA}'=='0'
    run keyword and continue on failure    run keyword if   ${is_high_prio_data_enabled}
    ...    should be true    '${NUM_MUT_SLOT_SCHD_HI_PRI_DATA}' > '0'
    ...    ELSE      should be true       '${NUM_MUT_SLOT_SCHD_HI_PRI_DATA}'=='0'


Check the special slot and DL slot preceding the special slot are not muted in BIP log
    [Documentation]    Author: Liu Zheng
    [Arguments]      ${pdsch_slot_list}=${MUTE_SLOT_LIST}    ${capture_time}=3 sec      ${target_file_name}=bip_log_dl
    run keyword and continue on failure     check slot scheculed info      pdsch_slot_list=${pdsch_slot_list}    capture_time=${capture_time}
    ...    is_pdsch_scheduled_on_related_slot=${True}    mirroring_filter=SpecificL1L2Messages
    ...    target_file_name=${target_file_name}

check slot scheculed info
    [Documentation]    Author: Liu Zheng
    [Arguments]      ${pdsch_slot_list}    ${capture_time}=3 sec
    ...    ${is_pdsch_scheduled_on_related_slot}=${False}
    ...    ${mirroring_filter}=SpecificL1L2Messages
    ...    ${target_file_name}=bip_log_dl_data
    Connect to Common Unit Master
    ${bip_log_PDSCH_RIM}    Collect Bip logs and Return Files Path    target_file_name=${target_file_name}    capture_time=${capture_time}
    ...    mirroring_filter=${mirroring_filter}    specific_message_ids=${MESSAGE_ID_PDSCH_SEND_REQ}
    sleep   3s
    run keyword and continue on failure    Check if DL and Special slot scheduled    log_path=${bip_log_PDSCH_RIM[0]}
                                                          ...    pdsch_slot_list=${pdsch_slot_list}
                                                          ...    is_pdsch_scheduled_on_s_d_slot=${is_pdsch_scheduled_on_related_slot}

Trigger RI Disappear and Check Fault 7525 7527 canceled and DL Mitigation stopped
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Steps Trigger RI Disappear and Check Fault 7525 7527 canceled and DL Mitigation stopped
    ...    1. lock victim cell, wait and verify fault 7525 & 7527 disappeared
    ...    2. check from history alarm, should contain 7525 or 7527
    ...    3. capture bip log and check Special+DL symbols all scheduled from bip log
    ...    srs_check: Value can be "exist" or "not exist" or ${False},filter uldata_srsreceivereq from BIP log,
    ...               pSRS should disable after 7525, and resume after 7525 disappear (precondition nidd:actUlSrsBm=true, actDlSrsBm=true)
    [Arguments]   ${SetId_Aggressor}    ${dlMuteSlotsStr}
    ...    ${feature}=9823    ${after_ri}=${False}    ${exp_dl_tput_gap}=5    ${exp_ul_tput_gap}=3
    ...    ${dlMuteSlotsStr}=${None}    ${7535_check}=${False}    ${7525_check_history}=${True}
    ...    ${7527_check_history}=${True}     ${should_7525_in_alarm_history}=${True}    ${should_7527_in_alarm_history}=${True}
    ...    ${setId_show_in_fault}=${True}    ${check_pcmd_setid_removed}=${False}   ${tcpdump_collector_name}=PCMD_RIMRS_AFTER_RI
    ...    ${asymmetricState}=not check    ${riState}=not check    ${rimRsSetIdType1}=not check
    ...    ${rimRsSetIdType2}=not check     ${pdcchMutingStatus}=not check    ${pdschMutingStatus}=not check
    ${supplementary}    Get Supplementary for Fault 7527    ${SetId_Aggressor}    ${dlMuteSlotsStr}    ${feature}   ${setId_show_in_fault}
    ${supplementary_7535}    Get Supplementary for Fault 7535    ${dlMuteSlotsStr}

    run keyword and continue on failure    run keyword if     ${check_pcmd_setid_removed}
    ...    Start Capture PCMD with filter port      tcpdump_collector_name=${tcpdump_collector_name}
    # lock aggressor cell, wait and verify fault 7525 & 7527 disappeared
    run keyword and continue on failure    Lock cells
    run keyword and continue on failure    coam_gnb_classical.COAM Update several parameters via rest api
                                                        ...    parameters_to_update_via_api=${RESTAPI_Cancel_RI}
                                                        ...    skip_parameter_relation_errors=${False}
                                                        ...    connection=${OAM_ALIAS_GNB1}

    run keyword and continue on failure    Wait and Verify Fault 7525 not Present on Cells
    run keyword and continue on failure    Wait and Verify Fault 7527 not Present on Cells
    run keyword and continue on failure    run keyword if   ${7535_check}
                                                        ...    Wait and Verify Fault 7535 not Present on Cells    7535_check_timeout=5min

    run keyword and continue on failure     Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    riState=${riState}    asymmetricState=${asymmetricState}    rimRsSetIdType1=${rimRsSetIdType1}    rimRsSetIdType2=${rimRsSetIdType2}
    ...    pdschMutingStatus=${pdschMutingStatus}    pdcchMutingStatus=${pdcchMutingStatus}

    run keyword and continue on failure    run keyword if     ${check_pcmd_setid_removed}
    ...    Stop Tcpdump and Check RIMRS Setid Removed from PCMD log    tcpdump_collector_name=${tcpdump_collector_name}


    # check from history alarm, should contain 7525 or 7527
    run keyword and continue on failure    run keyword if   ${7525_check_history}
    ...    Wait and Verify Expect Fault Present or not from History List on Cells
                                                        ...    faultId=7525
                                                        ...    expect_present=${should_7525_in_alarm_history}
    run keyword and continue on failure    run keyword if   ${7527_check_history}
    ...    Wait and Verify Expect Fault Present or not from History List on Cells
                                                        ...    faultId=7527
                                                        ...    expect_present=${should_7527_in_alarm_history}
	run keyword and continue on failure    run keyword if   ${7535_check}
    ...    Expect Fault Present or not from History List on Cells    faultId=7535
                                                        ...    expect_present=${True}
                                                        ...    supplementary=${supplementary_7535}

    AlarmWatchdog.remove_allow_alarms    fault_id=7525
    AlarmWatchdog.remove_allow_alarms    fault_id=7527
    AlarmWatchdog.remove_allow_alarms    fault_id=7535

    # capture bip log and check Special+DL symbols all scheduled from bip log
    run keyword and continue on failure    L3 call and check tput for each cell    cell_id=${TDD_CELL_ID}
                                                                            ...    dl_tput=${DL_TPUT}
                                                                            ...    ul_tput=${UL_TPUT}
                                                                            ...    exp_dl=${TDD_DL_EXP_TPUT}
                                                                            ...    exp_ul=${TDD_UL_EXP_TPUT}
                                                                            ...    customized_log_name=afterRI
                                                                            ...    after_ri=${after_ri}
                                                                            ...    exp_dl_tput_gap=${exp_dl_tput_gap}
                                                                            ...    exp_ul_tput_gap=${exp_ul_tput_gap}

    [Teardown]   run keywords    run keyword and continue on failure    Stop data transfer and detach UE    AND
                        ...    run keyword and continue on failure    Unlock cells

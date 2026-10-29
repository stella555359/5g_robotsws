*** Settings ***
Documentation      CB007935 common keywords
Resource     ./CB007935_variables.robot
Resource    ./verify_sync_status.robot
Variables    commissionings/HGZ/${testline_name}/__init__.py
Variables    ./../TestData/NIDD_modify_scf.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_Common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RF_module_power_reset.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ./L3Call_check.robot
Resource    ./TPS_operations.robot
Library      ./sync_info.py    WITH NAME    sync_info


*** Keywords ***
Suite preparation
    [Documentation]  Author: Ding Binmei
    Set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_DEFAULT}
    Set variables for UTE cloud
    ${stream}    ${build}     run keyword if    ${IS_UTE_ENV}    CI_commssion._Get Stream From Variable    ${ENB_BUILD}
    ...    ELSE   CI_commssion._Get Stream From Variable    ${AF_PATH}
    set suite variable     ${SCF_DEFAULT_FILE_PATH}    ${WORKSPACE_DIR}/commissionings/HGZ/${testlinename}/SCF_${stream}.xml
    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${WORKSPACE_DIR}/commissionings/HGZ/${testlinename}/swconfig.txt
    Enabe PTP ports on TPS for all RUs    tps_ports=${TPS_OUT_PORTS_FOR_ALL_RUS}
    Update ssmtrans level on TPS    ssmtrans_level=PRC    tps_ports=${TPS_OUT_PORTS_FOR_ALL_RUS}
    Suite common setup preparation
    ...    prepare_ue=${False}
    ...    is_pdl_checking_needed=${True}    scf_modify_parameters=${None}    NSA_SA=${NSA_SA}
    ${scf_file_path_for_restore}    Download SCF file and return with file path    extended_name=for_restore
    ...    local_dir=${SUITE_LOG_PATH}
    Set suite Variable    ${scf_file_path_for_restore}
    ${ru_sync_mapping}    sync_info.get_sync_info_for_all_rus    connection_alias=GNB_OAM
    Set suite variable    ${RU_SYNC_MAPPING}    ${ru_sync_mapping}
    Import Library    ${CURDIR}/../TestData/online_modify_lib_for_feature.py    WITH NAME    param_modify_lib_7935

Suite teardown
    [Documentation]  Author: Ding Binmei
    [Arguments]    ${is_log_required}=${False}
    Common suite recovery    is_log_required=${is_log_required}

Verify 7935 counter values are as expected
    [Documentation]    Author: Ding Binmei
    ...    Wait until counter file is generated and Verify Counter value for ruSynceRearrangement (M40121C0) and ruSynceEstHoldoverTime (M40122C0)
    ...    are all the same as expected for all RUs
    ...    param expression_ruSynceRearrangement: can be == , !=
    ...    param expression_ruSynceEstHoldoverTime: can be == , !=
    [Arguments]    ${ruSynceRearrangement_exp}    ${ruSynceEstHoldoverTime_exp}
    ...    ${expression_ruSynceRearrangement}===    ${expression_ruSynceEstHoldoverTime}===    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    Connect to Common Unit Master
    ${start_log_timestamp}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${start_log_timestamp['log_generator_timestamp']}

    ${list_measurement_ids}    create list    M40121C0    M40122C0
    ${dict_measurements_value}    counter.get_counters_from_file_based_on_level_identifier    file_path=${pm_files_local_path[-1]}
    ...    list_ids=${rmod_ids}    list_measurement_ids=${list_measurement_ids}    level_identifier=RMOD
    FOR    ${rmod_id}    IN    @{rmod_ids}
        ${M40121C0_value}    Set variable    ${dict_measurements_value["${rmod_id}"]["M40121C0"]}
        ${M40122C0_value}    Set variable    ${dict_measurements_value["${rmod_id}"]["M40122C0"]}
        Should be true    "${M40121C0_value}" ${expression_ruSynceRearrangement} "${ruSynceRearrangement_exp}"
        Should be true    "${M40122C0_value}" ${expression_ruSynceEstHoldoverTime} "${ruSynceEstHoldoverTime_exp}"
    END

Verify 7935 counters and check ruSynceRearrangement happen
    [Documentation]    Author: Ding Binmei
    ...    When ruSynceRearrangement happen, counter value for ruSynceRearrangement (M40121C0) should be update to 1 based on event trigger.
    ...    ruSynceEstHoldoverTime (M40122C0) should not be ${None} if ruSynceRearrangement==1
    [Arguments]    ${pm_files_local_path}
    ${list_measurement_ids}    create list    M40121C0    M40122C0
     FOR    ${rmod_id}    IN    @{RMOD_ID_WITH_7935_ENABLED}
         ${sum_ruSynceRearrangement_for_ru}    Set variable    ${0}
         FOR    ${pm_file_path}    IN    @{pm_files_local_path}
             ${dict_measurements_value}    counter.get_counters_from_file_based_on_level_identifier    file_path=${pm_file_path}
             ...    list_ids=${RMOD_ID_WITH_7935_ENABLED}    list_measurement_ids=${list_measurement_ids}    level_identifier=RMOD
             ${M40121C0_ruSynceRearrangement_value}    Set variable    ${dict_measurements_value["${rmod_id}"]["M40121C0"]}
             ${M40122C0_ruSynceEstHoldoverTime_value}    Set variable    ${dict_measurements_value["${rmod_id}"]["M40122C0"]}
             ${sum_ruSynceRearrangement_for_ru}    Run keyword if    '${M40121C0_ruSynceRearrangement_value}'!='None'
             ...    Evaluate    ${sum_ruSynceRearrangement_for_ru}+${M40121C0_ruSynceRearrangement_value}
             ...    ELSE    Set variable    ${sum_ruSynceRearrangement_for_ru}

            #  dandan.fang remove following code, because M40122C0 display rule is different with M40121C0.
            #  M40121C0 reported directly when syncE rearrangement happened;
            #  while M40122C0 not report to OAM PM when ruAssistedHoPeriod is 65535 and then displayed delayed on webEM as None.
            #  Run keyword if    '${M40121C0_ruSynceRearrangement_value}'=='1'
            #  ...    Run Keyword And Continue On Failure    Should Not Be Equal As Strings    ${M40122C0_ruSynceEstHoldoverTime_value}    ${None}
        END
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${sum_ruSynceRearrangement_for_ru}    1
    END

Power_reset_RU_based_on_exp_ruAssistedHoPeriod
    [Documentation]    Author: Ding Binmei
    ...    Power reset RU based on ruAssistedHoPeriod value
    ...    param expression: can be == , != , > , < , >= , <=
    ...    return True if power reset is needed, else return False
    [Arguments]     ${expression}===    ${exp_ruAssistedHoPeriod}=65535    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    ${dict_sync_info}    sync_info.get_sync_info_based_on_rmod_ids    rmod_ids=${rmod_ids}
    FOR    ${rmod_id}    IN    @{rmod_ids}
        ${ruAssistedHoPeriod}    Set Variable    ${dict_sync_info["${rmod_id}"]["clock_info"]["parameters"]["ruAssistedHoPeriod"]}
        ${is_rf_power_reset}    Run keyword if    ${ruAssistedHoPeriod}${expression}${exp_ruAssistedHoPeriod}    Set variable    ${True}
        ...    ELSE    Set variable    ${False}
        Exit For Loop If    ${is_rf_power_reset}
    END
    Run keyword if    ${is_rf_power_reset}    General_SiSo_RF_module_power_reset.General_SiSo_RF_module_power_reset
    ...    is_ru_power_off_checked=${False}
    Log to console    is_rf_power_reset:${is_rf_power_reset}
    Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}
    Wait until synce status become available
    [Return]    ${is_rf_power_reset}

Wait_until_ruAssistedHoPeriod_change_to_1_after_power_reset
    [Documentation]    Author: Ding Binmei
    ...    1. Verify SyncE and clock status are available
    ...    2. Wait until ruAssistedHoPeriod changes from 0 to 1
    [Arguments]    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    Log to console    Wait until ruAssistedHoPeriod changes from 0 to 1, it takes about 1 hour, please wait
    Wait Until Keyword Succeeds    5 min    30 sec    Verify value of ruAssistedHoPeriod is as expected
    ...    exp_ruAssistedHoPeriod=0    rmod_ids=${rmod_ids}
    Log to console    rf power reset happen, Wait for about 1 hour for ruAssistedHoPeriod changes from 0 to 1
    Run Keyword And Return Status    Wait Until Keyword Succeeds    50 min    10 min    Verify value of ruAssistedHoPeriod is as expected
    ...        exp_ruAssistedHoPeriod=1    rmod_ids=${rmod_ids}    fail_keyword_when_65535_triggered=${False}
    ${result}     Wait Until Keyword Succeeds    15 min    3 min    Verify value of ruAssistedHoPeriod is as expected
    ...        exp_ruAssistedHoPeriod=1    rmod_ids=${rmod_ids}    fail_keyword_when_65535_triggered=${False}
    Should Be Equal As Strings    ${result}    ${None}    msg=ruAssistedHoPeriod is not changed from 0 to 1

Update ssmAcceptanceLevel on BTS
    [Documentation]    Author: Ding Binmei
    ...    Update ssmAcceptanceLevel on BTS
    ...    param exp_ssmAcceptanceLevel: values same in webUI. E.G input: ssmPRCorPRS/ssmePRTC
    [Arguments]    ${exp_ssmAcceptanceLevel}    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    ${param_to_update}    param_modify_lib_7935.get_params_to_update_for_ssmAcceptanceLevel    list_rmod_id=${rmod_ids}
    ...    exp_ssmAcceptanceLevel=${exp_ssmAcceptanceLevel}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_to_update}    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    timeout=${TIMER_FOR_ONLINE_STATUS_CHECK}

Verify ruAssistedHoPeriod is not cleared
    [Documentation]    Author: Ding Binmei
    ...    param dict_ruAssistedHoPeriod_for_rmod_pre: should be a dict value
    ...    param rmod_ids: list of rmod ids
    [Arguments]    ${dict_ruAssistedHoPeriod_for_rmod_pre}    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    ${dict_ruAssistedHoPeriod_for_rmod_new}    Get value of ruAssistedHoPeriod for each rmod    rmod_ids=${rmod_ids}
    FOR    ${rmod_id}    IN    @{rmod_ids}
        ${ruAssistedHoPeriod_pre}    Set Variable    ${dict_ruAssistedHoPeriod_for_rmod_pre["${rmod_id}"]}
        ${ruAssistedHoPeriod_new}    Set Variable    ${dict_ruAssistedHoPeriod_for_rmod_new["${rmod_id}"]}
        Should Be True    ${ruAssistedHoPeriod_new}!=65535
        Should Be True    ${ruAssistedHoPeriod_new}>=${ruAssistedHoPeriod_pre}
        Log to console    For RMOD-${rmod_id}, ruAssistedHoPeriod is not cleared, verify passed.
    END

#################CB007935-SR-A_TC_01_US01_Assisted_SyncE_HO_Estimate_No_impairment_cMAAr7.1_Feature_Activate
CB007935-SR-A_TC_01_US01_S1_Set_feature_flag_actRuIntelligentSynceAstHoTime_to_false_and_verify_pdl
    [Documentation]    Author: Ding Binmei
    ...    Set feature flag actRuIntelligentSynceAstHoTime to false and verify pdl
    [Arguments]    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    ${RESRAPI_DISABLE_actRuIntelligentSynceAstHoTime}    param_modify_lib_7935.get_param_update_for_actRuIntelligentSynceAstHoTime
    ...    list_rmod_id=${rmod_ids}    value=false
    Set Test Variable    ${RESRAPI_DISABLE_actRuIntelligentSynceAstHoTime}
    ${dict_params_to_modify}    Create Dictionary    param_to_upd=${RESRAPI_DISABLE_actRuIntelligentSynceAstHoTime}
    ${commission_result}    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_params_to_modify}
    ...    skip_parameter_relation_errors=${True}    should_activate=${False}
    ${pdl_validation_error_num}    Get Length
    ...    ${commission_result['validationResult']['pdlValidationResult']['logs']['relationErrors']}
    Should be true    ${pdl_validation_error_num}!=0    msg=Relation error not found after set actRuIntelligentSynceAstHoTime to false

CB007935-SR-A_TC_01_US01_S2_Disable_feature_with_pdl_fixed_and_verify
    [Documentation]    Author: Ding Binmei
    ...    Before disable feature with pdl fixed. Will backup values for restore NIDD
    ...    Disable feature with pdl fixed and verify:
    ...    --2.1 SyncE lockStatus are none; Clock status are locked
    ...    --2.2 Verify MTIE file is removed and ruAssistedHoPeriod is None
    [Arguments]    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    ${RESTAPI_DISABLE_7935_COUNTERS}    param_modify_lib_7935.get_params_to_update_for_counters    value=disabled
    ${RESTAPI_DISABLE_SYNC_PARMAS}    param_modify_lib_7935.get_params_to_disable_7935_on_related_rmod_id    list_rmod_id=${rmod_ids}
    ${param_to_update}    Combine Lists    ${RESRAPI_DISABLE_actRuIntelligentSynceAstHoTime}    ${RESTAPI_DISABLE_7935_COUNTERS}
    ${RESTAPI_DISABLE_7935_ALL_PARAMS}    Create Dictionary    param_to_del=${RESTAPI_DISABLE_SYNC_PARMAS}
    ...    param_to_upd=${param_to_update}
    ${JSON_FILE_PATH_ENABLE_7935}    param_modify_lib_7935.get_params_to_enable_7935_based_on_disable_params
    ...    dict_disable_params=${RESTAPI_DISABLE_7935_ALL_PARAMS}
    Set Test variable    ${JSON_FILE_PATH_ENABLE_7935}
    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${RESTAPI_DISABLE_7935_ALL_PARAMS}
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    Run Keyword And Continue On Failure    Wait until synce status not displayed when feature is disabled
    Verify value of ruAssistedHoPeriod is as expected    exp_ruAssistedHoPeriod=${None}

CB007935-SR-A_TC_01_US01_S3_Enable_feature_again_and_verify
    [Documentation]    Author: Ding Binmei
    ...    3. Enable feature again and verify:
    ...    --3.1 SyncE and clock status are as expected
    ...    --3.2 Wait for 3 mins and check ruAssistedHoPeriod on webUI is 0
    ...    --3.3 Counter value for ruSynceRearrangement (M40121C0) and ruSynceEstHoldoverTime (M40122C0) are displayed as 0
    coam_parameter.perform_scf_delta_commission    delta_file=${JSON_FILE_PATH_ENABLE_7935}    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ...    connection=GNB_OAM    skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait until synce status become available
    Wait Until Keyword Succeeds    5 min    30 sec    Verify value of ruAssistedHoPeriod is as expected
    ...    exp_ruAssistedHoPeriod=0
    Verify 7935 counter values are as expected    ruSynceRearrangement_exp=0    ruSynceEstHoldoverTime_exp=0

###################CB007935-SR-B_TC_02_US02_Entering_HO_mode_with_Assisted_holdover_selected_then_original_PTP_restored
CB007935-SR-B_TC_02_US02_S1_Power_reset_RU
    [Documentation]    Author: Ding Binmei
    ...    1. Power reset RU as precondition
    General_SiSo_RF_module_power_reset.General_SiSo_RF_module_power_reset    is_ru_power_off_checked=${False}

CB007935-SR-B_TC_02_US02_S2_Verify_SyncE_and_clock_status_and_wait_until_ruAssistedHoPeriod_change_to_1
    [Documentation]    Author: Ding Binmei
    ...    1. Verify SyncE and clock status are available
    ...    2. Wait until ruAssistedHoPeriod changes from 0 to 1
    ...    3. Verify Counter ruSynceEstHoldoverTime (M40122C0) is 1
    Wait_until_ruAssistedHoPeriod_change_to_1_after_power_reset
    Wait Until Keyword Succeeds    2X    1sec    Verify 7935 counter values are as expected    ruSynceRearrangement_exp=0
    ...    ruSynceEstHoldoverTime_exp=1

CB007935-SR-B_TC_02_US02_S3_Start_l3_call_and_verify_traffic_is_as_expected
    [Documentation]    Author: Ding Binmei
    ...    Start L3 call and verify traffic is as expected. Not to do ue detach and stop traffic
    ${cell_id_for_attach}    Get random cell index for attach based on provided rmod ids
    Set Test Variable    ${cell_id_for_attach}
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${cell_id_for_attach}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    timeout=${TIMER_FOR_ONLINE_STATUS_CHECK}
    Start L3 call and check tput is as expected    cell_id_for_attach=${cell_id_for_attach}    tcpdump_log_name=S3_start_l3_call
    ...    tput_curve_customized_log_name=S3_start_l3_call    is_need_to_stop_traffic_and_detach=${False}    is_need_to_prepare_ue=${True}

CB007935-SR-B_TC_02_US02_S4_Disable_PTP_via_TPS_and_verify
    [Documentation]    Author: Ding Binmei
    ...    4. Disable PTP via TPS and verify:
    ...    --4.1 Fault 4298(Top reference missing)  is reported on related RU
    ...    --4.2 Check synceStatus is: parent and syncStatus for clock is: holdover
    ...    --4.3 Verfify traffic is not affectled.
    ...    --4.4 Verify ruAssistedHoPeriod changed as expected: For IntelligentHoldover, it is ruAssistedHoPeriod-1;
    ...          for ManualAssistedHoldover, it is manualSynceAssistedHoPeriod-1
    ...    --4.5 Detach UE and stop traffic
    [Arguments]    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}    ${exp_ruAssistedHoPeriod}=0
    AlarmWatchdog.add_allow_alarms    fault_id=4298
    Disable PTP ports on TPS for all RUs    tps_ports=${TPS_OUT_PORTS_FOR_ALL_RUS}
    FOR    ${rmod_id}    IN    @{rmod_ids}
        Wait until keyword succeeds    2min    10s    Expect Fault Should Present    faultId=4298  configObjectName=RMOD-${rmod_id}
    END
    Wait until sync status enter into holdover    rmod_ids=${rmod_ids}
    Run Keyword And Continue On Failure    Verify traffic is still available after disable PTP    cell_id_for_attach=${cell_id_for_attach}
    ...    tput_curve_customized_log_name=S4_disable_PTP_and_traffic_not_affected
    Wait Until Keyword Succeeds    5 min    30 sec    Verify value of ruAssistedHoPeriod is as expected
    ...    exp_ruAssistedHoPeriod=${exp_ruAssistedHoPeriod}
    [Teardown]    Stop data transfer and detach UE    data_transfer_direction=both

_verify_ru_status_is_initial_and_fault_16_is_reported
    [Arguments]    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    FOR    ${rmod_id}    IN    @{rmod_ids}
        Run Keyword And Continue On Failure    RU Should Be Offline    ru_index=${rmod_id}
        Expect Fault Should Present    faultId=16  configObjectName=RMOD-${rmod_id}
    END

Verify ruSynceRearrangement is not happened and ruSynceEstHoldoverTime updated to None eventually
    [Documentation]    Author: Ding Binmei
    ...    No ruSynceRearrangement (M40121C0) happen after ruSynceEstHoldoverTime expires
    ...    And ruSynceEstHoldoverTime (M40122C0) should be ${None} eventually
    [Arguments]    ${pm_files_local_path}
    ${list_measurement_ids}    create list    M40121C0    M40122C0
     FOR    ${rmod_id}    IN    @{RMOD_ID_WITH_7935_ENABLED}
         FOR    ${pm_file_path}    IN    @{pm_files_local_path}
             ${dict_measurements_value}    counter.get_counters_from_file_based_on_level_identifier    file_path=${pm_file_path}
             ...    list_ids=${RMOD_ID_WITH_7935_ENABLED}    list_measurement_ids=${list_measurement_ids}    level_identifier=RMOD
             ${M40121C0_ruSynceRearrangement_value}    Set variable    ${dict_measurements_value["${rmod_id}"]["M40121C0"]}
             ${M40122C0_ruSynceEstHoldoverTime_value}    Set variable    ${dict_measurements_value["${rmod_id}"]["M40122C0"]}
             Run Keyword And Continue On Failure    Should Be Equal As Strings    ${M40121C0_ruSynceRearrangement_value}    0
             Run Keyword And Continue On Failure    Run keyword if    "${pm_file_path}"== "${pm_files_local_path[0]}"
             ...    Should Be Equal As Strings    ${M40122C0_ruSynceEstHoldoverTime_value}    ${None}
        END
    END

CB007935-SR-B_TC_02_US02_S5_Wait_until_ruSynceEstHoldoverTime_expires_and_verify
    [Documentation]    Author: Ding Binmei
    ...    5. Hold for 1 h+ and verify:
    ...    --5.1: RU is in initial status and Fault 16 is reported on related RU
    ...    --5.2: ruAssistedHoPeriod is changed to 65535 and
    ...    counter value for ruSynceRearrangement (M40121C0) is 0, ruSynceEstHoldoverTime (M40122C0) is ${None}(from webUI - is displayed)
    ...    ( Check for several durations and make sure no ruSynceRearrangement happen after ruSynceEstHoldoverTime expires )
    ...    --5.3: MTIE file is removed
    AlarmWatchdog.add_allow_alarms    fault_id=16
    Log To Console    Wait for 1 hour for ruSynceEstHoldoverTime expires. If reach 65535, then continue for RU status and fault 16 check
    Run Keyword And Return Status    Wait Until Keyword Succeeds    50 min    10 min    Verify value of ruAssistedHoPeriod is as expected
    ...        exp_ruAssistedHoPeriod=65535
    Connect to Common Unit Master
    ${start_log_timestamp}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    15 min    3 min    Verify value of ruAssistedHoPeriod is as expected
    ...        exp_ruAssistedHoPeriod=65535
    Wait Until Keyword Succeeds    1min    30 sec    _verify_ru_status_is_initial_and_fault_16_is_reported
    Wait for next PM counter file is generated    reporting_interval=5
    Log to console    Wait for additional one duration to wait until counter ruSynceEstHoldoverTime (M40122C0) change to None
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${start_log_timestamp['log_generator_timestamp']}
    ${counter_check_result}    Run Keyword And Return Status
    ...    Verify ruSynceRearrangement is not happened and ruSynceEstHoldoverTime updated to None eventually
    ...        pm_files_local_path=${pm_files_local_path}
    Should Be True    ${counter_check_result}    msg=ruSynceRearrangement is not 0 or ruSynceEstHoldoverTime is not None

CB007935-SR-B_TC_02_US02_S6_Enable_PTP_and_verify
    [Documentation]    Author: Ding Binmei
    ...    6.1 Enable PTP and verify: RU is enabled and cell on air without Fault 16 and fault 4298
    ...    6.2 Sleep for 2 mins and verify clock and syncE status are as expected
    ...    6.3 Verify ruAssistedHoPeriod is as expected.
    ...        For IntelligentHoldover, it is 0, for ManualAssistedHoldover, it is same with NIDD manualSynceAssistedHoPeriod
    ...    6.4 Verify L3 call is as expected
    [Arguments]    ${exp_ruAssistedHoPeriod}=0
    Enabe PTP ports on TPS for all RUs    tps_ports=${TPS_OUT_PORTS_FOR_ALL_RUS}
    Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    is_need_to_setup_gnb_connection=${False}
    Expect Fault Should Absent    faultId=4298
    Expect Fault Should Absent    faultId=16
    AlarmWatchdog.remove_allow_alarms    fault_id=4298
    AlarmWatchdog.remove_allow_alarms    fault_id=16
    Wait until synce status become available    timeout=2min
    Wait Until Keyword Succeeds    5 min    30 sec    Verify value of ruAssistedHoPeriod is as expected
    ...    exp_ruAssistedHoPeriod=${exp_ruAssistedHoPeriod}    expression===
    Start L3 call and check tput is as expected    cell_id_for_attach=${cell_id_for_attach}    tcpdump_log_name=S6_start_l3_call_after_enable_PTP
    ...    tput_curve_customized_log_name=S6_start_l3_call_after_enable_PTP    is_need_to_stop_traffic_and_detach=${True}
    ...    is_need_to_prepare_ue=${False}

######################CB007935-SR-A_TC_10_robutness_Assist_Holdover_Period_Estimation_Continue_After_RU_Warm_Reset
CB007935-SR-A_TC_10_S1_Power_reset_RU_if_ruAssistedHoPeriod_is_65535
    [Documentation]    Author: Ding Binmei
    ...    1. Power reset RU if ruAssistedHoPeriod==65535
    ${is_rf_power_reset}    Power_reset_RU_based_on_exp_ruAssistedHoPeriod    expression===    exp_ruAssistedHoPeriod=65535
    [Return]    ${is_rf_power_reset}

CB007935-SR-A_TC_10_S2_Hold_until_ruAssistedHoPeriod_bigger_than_0_and_record_value
    [Documentation]    Author: Ding Binmei
    ...    2. Hold until ruAssistedHoPeriod >=1 and record value of ruAssistedHoPeriod
    ...    Return a dictionary with ruAssistedHoPeriod value for each RMOD. E.G. {'1': 1, '2': 1}
    [Arguments]    ${is_rf_power_reset}    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    Run keyword if    ${is_rf_power_reset}    Wait_until_ruAssistedHoPeriod_change_to_1_after_power_reset    rmod_ids=${rmod_ids}
    # If power reset not happen wait for at most 65 mins to wait until ruAssistedHoPeriod > 0
    ${result}    Wait Until Keyword Succeeds    65min    5min    Verify value of ruAssistedHoPeriod is as expected
    ...    exp_ruAssistedHoPeriod=0    expression=>     rmod_ids=${rmod_ids}    fail_keyword_when_65535_triggered=${False}
    Should Not Be Equal As Strings    ${result}    Fail    msg=ruAssistedHoPeriod equals 65535, fail this keyword
    ${dict_ruAssistedHoPeriod_for_rmod}    Get value of ruAssistedHoPeriod for each rmod    rmod_ids=${rmod_ids}
    Log to console    ruAssistedHoPeriod for all RUs: ${dict_ruAssistedHoPeriod_for_rmod}
    [Return]    ${dict_ruAssistedHoPeriod_for_rmod}

CB007935-SR-A_TC_10_S3_Warm_reset_RU_and_verify_ruAssistedHoPeriod_is_not_cleared
    [Documentation]    Author: Ding Binmei
    ...    3. Warm reset RU and verify:
    ...    --3.1 Verify SyncE and clock status are available
    ...    --3.2 Get current value of ruAssistedHoPeriod and verify value >= previous value in step 2
    [Arguments]    ${dict_ruAssistedHoPeriod_for_rmod_pre}    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    General_SiSo_RF_module_reset_from_GUI.General_SiSo_RF_module_reset_from_GUI
    Wait until synce status become available
    Wait Until Keyword Succeeds    5 min    30 sec    Verify value of ruAssistedHoPeriod is as expected
    ...    exp_ruAssistedHoPeriod=${None}    expression=!=    rmod_ids=${rmod_ids}
    Verify ruAssistedHoPeriod is not cleared    dict_ruAssistedHoPeriod_for_rmod_pre=${dict_ruAssistedHoPeriod_for_rmod_pre}
    ...    rmod_ids=${rmod_ids}

_verify_fault_4781_reported_and_counter_ruSynceRearrangement_updated_after_update_ssm_level
    [Documentation]    Author: Ding Binmei
    ...    Verify fault 4781 reported and counter ruSynceRearrangement updated after update ssm level
    ...    --4.1 Fault 4781(RU synce unusable) reported on related RMOD.
    ...    if 4781 is reported on one RU, config object will be displayed for this specific RMOD and
    ...    no supplementary info is checked in additional information part;
    ...    if 4781 is reported for two or more RUs, config object will be displayed as MRBTS level and
    ...    All RMOD ids are displayed in supplementary info in additional information part.
    ...    --4.2 ruAssistedHoPeriod displayed as 65535
    ...    --4.3 Counter check:
    ...          For first duration: M40122C0(ruSynceEstHoldoverTime) !=None, M40121C0(ruSynceRearrangement) is 1
    ...          For second duration: M40122C0(ruSynceEstHoldoverTime) ==None, M40121C0(ruSynceRearrangement) is 0
    [Arguments]    ${counter_start_log_timestamp}    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    ${rmod_ids}    string2list    input_str=${rmod_ids}
    ${RU_num}    Get Length    ${rmod_ids}
    ${exp_configObjectName}    Set variable if    ${RU_num}==1    RMOD-${rmod_ids[0]}    MRBTS
    ${exp_supplementary_pattern_multi_RUs}    Set variable    ${EMPTY}
    FOR    ${rmod_id}    IN    @{rmod_ids}
        ${exp_supplementary_pattern_multi_RUs}    Catenate    SEPARATOR=    ${exp_supplementary_pattern_multi_RUs}    RMOD_R-${rmod_id}*
    END
    ${exp_supplementary}    Set Variable If    ${RU_num}==1    ${None}    ${exp_supplementary_pattern_multi_RUs}
    Run Keyword And Continue On Failure    Wait until keyword succeeds    3min    30s    Expect Fault Should Present    faultId=4781
    ...    configObjectName=${exp_configObjectName}    supplementary=${exp_supplementary}
    Wait until keyword succeeds    1min    30s    Verify value of ruAssistedHoPeriod is as expected
    ...        exp_ruAssistedHoPeriod=65535    rmod_ids=${rmod_ids}
    ${pm_files_local_path}    Wait for PM file generated and download
    ...    starting_log_timestamp=${counter_start_log_timestamp['log_generator_timestamp']}
    Verify 7935 counters and check ruSynceRearrangement happen    pm_files_local_path=${pm_files_local_path}
    Verify 7935 counter values are as expected    ruSynceRearrangement_exp=0
    ...    ruSynceEstHoldoverTime_exp=${None}    rmod_ids=${rmod_ids}

CB007935-SR-A_TC_10_S4_Update_ssmtrans_level_on_TPS_bellow_ssmAcceptanceLevel_and_verify_RU_syncE_unusable
    [Documentation]    Author: Ding Binmei
    ...    4. Update ssmtrans level on TPS for each RU from prc to ssu_A/ssu_B and verify
    ...    --4.1 Fault 4781(RU synce unusable) reported on related RMOD
    ...    --4.2 ruAssistedHoPeriod displayed as 65535
    ...    --4.3 Counter check:
    ...          For first duration: M40122C0(ruSynceEstHoldoverTime) !=None, M40121C0(ruSynceRearrangement) is 1
    ...          For second duration: M40122C0(ruSynceEstHoldoverTime) ==None, M40121C0(ruSynceRearrangement) is 0
    [Arguments]    ${tps_ports}=${TPS_OUT_PORTS_FOR_ALL_RUS}
    AlarmWatchdog.add_allow_alarms    fault_id=4781
    ${start_log_timestamp}    Prepare for counter log
    Update ssmtrans level on TPS    ssmtrans_level=ssu_a    tps_ports=${tps_ports}
    Wait until synce status change to NOK and ssmValue updated to expected value    exp_ssmValue=ssmSSU_A
    _verify_fault_4781_reported_and_counter_ruSynceRearrangement_updated_after_update_ssm_level
    ...    counter_start_log_timestamp=${start_log_timestamp}

_verify_fault_4781_cleared_and_counter_updated_as_expected_after_ssm_level_recovered
    [Documentation]    Author: Ding Binmei
    ...    Verify fault 4781 cleared and counter updated as expected after ssm level recovered
    ...    --5.1 Fault 4781 disappeared
    ...    --5.2 ruAssistedHoPeriod displayed as 0, for manual assisted holdover, it is same with NIDD manualSynceAssistedHoPeriod
    ...    --5.3 Counter for M40122C0(ruSynceEstHoldoverTime) is 0, Counter for  M40121C0(ruSynceRearrangement) is 0
    [Arguments]    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}    ${exp_ruAssistedHoPeriod}=0
    Run Keyword And Continue On Failure    Wait until keyword succeeds    3min    30s    Expect Fault Should Absent    faultId=4781
    AlarmWatchdog.remove_allow_alarms    fault_id=4781
    Wait until keyword succeeds    3min    30s    Verify value of ruAssistedHoPeriod is as expected
    ...        exp_ruAssistedHoPeriod=${exp_ruAssistedHoPeriod}    rmod_ids=${rmod_ids}
    Wait Until Keyword Succeeds    2X    1sec    Verify 7935 counter values are as expected    ruSynceRearrangement_exp=0
    ...    ruSynceEstHoldoverTime_exp=0

CB007935-SR-A_TC_10_S5_Restore_ssmtrans_level_on_TPS_and_verify_RU_syncE_available
    [Documentation]    Author: Ding Binmei
    ...    5. Update ssmtrans level on TPS for each RU back to prc and verify
    ...    --5.1 Fault 4781 disappeared
    ...    --5.2 ruAssistedHoPeriod displayed as 0; for manual assisted holdover, it is same with NIDD manualSynceAssistedHoPeriod
    ...    --5.3 Counter for M40122C0(ruSynceEstHoldoverTime) is 0, Counter for  M40121C0(ruSynceRearrangement) is 0
    [Arguments]    ${tps_ports}=${TPS_OUT_PORTS_FOR_ALL_RUS}    ${exp_ruAssistedHoPeriod}=0
    Update ssmtrans level on TPS    ssmtrans_level=PRC    tps_ports=${tps_ports}
    Wait until synce status change to OK and ssmValue updated to expected value    exp_ssmValue=ssmPRC
    _verify_fault_4781_cleared_and_counter_updated_as_expected_after_ssm_level_recovered    exp_ruAssistedHoPeriod=${exp_ruAssistedHoPeriod}

CB007935-SR-A_TC_10_S6_Update_ssmAcceptanceLevel_to_high_level_than_TPS_ssmtrans_level_and_verify_RU_syncE_unusable
    [Documentation]    Author: Ding Binmei
    ...    6. Update NIDD SCF accep level to ssmePRTC and verify: Same with step 4
    ...    --6.1 Fault 4781(RU synce unusable) reported on related RMOD
    ...    --6.2 ruAssistedHoPeriod displayed as 65535
    ...    --6.3 Counter check:
    ...          For first duration: M40122C0(ruSynceEstHoldoverTime) !=None, M40121C0(ruSynceRearrangement) is 1
    ...          For second duration: M40122C0(ruSynceEstHoldoverTime) ==None, M40121C0(ruSynceRearrangement) is 0
    AlarmWatchdog.add_allow_alarms    fault_id=4781
    ${start_log_timestamp}    Prepare for counter log
    Update ssmAcceptanceLevel on BTS    exp_ssmAcceptanceLevel=ssmePRTC
    _verify_fault_4781_reported_and_counter_ruSynceRearrangement_updated_after_update_ssm_level
    ...    counter_start_log_timestamp=${start_log_timestamp}

CB007935-SR-A_TC_10_S7_Restore_ssmAcceptanceLevel_and_verify_RU_syncE_available
    [Documentation]    Author: Ding Binmei
    ...    7. Update NIDD SCF accep level back(ssmPRCorPRS) and verify: Same with step 5
    ...    --7.1 Fault 4781 disappeared
    ...    --7.2 ruAssistedHoPeriod displayed as 0
    ...    --7.3 Counter for M40122C0(ruSynceEstHoldoverTime) is 0, Counter for  M40121C0(ruSynceRearrangement) is 0
    Update ssmAcceptanceLevel on BTS    exp_ssmAcceptanceLevel=ssmPRCorPRS
    _verify_fault_4781_cleared_and_counter_updated_as_expected_after_ssm_level_recovered

#######################CB010630-SR-B_TC_03_Transitioning_from_Assisted_to_Off-Air_with_a_major_SyncE_impairment_for_network_rearrangement
CB010630-SR-B_TC_03_S3_Trigger_syncE_major_impairment_and_verify
    [Documentation]    Author: Ding Binmei
    ...    3. Trigger syncE major impairment by update ssmtrans level to none on TPS for more then 15s and verify:
    ...    --3.1 SyncEStatus change to NOK, ssmValue displayed as ssmQualityUnknown
    ...    --3.2 Fault 4781(RU synce unusable) reported on related RMOD
    ...    --3.3 ruAssistedHoPeriod displayed as 65535
    ...    --3.4 Counter check:
    ...          For first duration: M40122C0(ruSynceEstHoldoverTime) !=None, M40121C0(ruSynceRearrangement) is 1
    ...          For second duration: M40122C0(ruSynceEstHoldoverTime) ==None, M40121C0(ruSynceRearrangement) is 0
    [Arguments]    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    AlarmWatchdog.add_allow_alarms    fault_id=4781
    ${start_log_timestamp}    Prepare for counter log
    Update ssmtrans level on TPS    ssmtrans_level=none    tps_ports=${TPS_OUT_PORTS_FOR_7_2E_RUS}
    Sleep    15s    reason=Wait for major impairment
    Wait until synce status change to NOK and ssmValue updated to ssmQualityUnknown    rmod_ids=${rmod_ids}
    _verify_fault_4781_reported_and_counter_ruSynceRearrangement_updated_after_update_ssm_level
    ...    counter_start_log_timestamp=${start_log_timestamp}    rmod_ids=${rmod_ids}

CB010630-SR-B_TC_03_S4_Restore_ssmtrans_level_on_TPS_and_verify_RU_syncE_available
    [Documentation]    Author: Ding Binmei
    ...    4. Update ssmtrans level on TPS for each RU back to prc and verify
    ...    --4.1 Fault 4781 disappeared
    ...    --4.2 ruAssistedHoPeriod displayed as 0
    ...    --4.3 Counter for M40122C0(ruSynceEstHoldoverTime) is 0, Counter for  M40121C0(ruSynceRearrangement) is 0
    [Arguments]    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    Update ssmtrans level on TPS    ssmtrans_level=PRC    tps_ports=${TPS_OUT_PORTS_FOR_7_2E_RUS}
    _verify_fault_4781_cleared_and_counter_updated_as_expected_after_ssm_level_recovered   rmod_ids=${rmod_ids}

Update ruAstHoSyncePortNumber on BTS
    [Documentation]    Author: Ding Binmei
    ...    Update ruAstHoSyncePortNumber on BTS
    ...    param exp_ruAstHoSyncePortNumber: values same in webUI. E.G input: 1/3
    [Arguments]    ${exp_ruAstHoSyncePortNumber}    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    ${param_to_update}    param_modify_lib_7935.get_params_to_update_for_ruAstHoSyncePortNumber    list_rmod_id=${rmod_ids}
    ...    exp_ruAstHoSyncePortNumber=${exp_ruAstHoSyncePortNumber}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_to_update}    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    timeout=${TIMER_FOR_ONLINE_STATUS_CHECK}

CB010630-SR-B_TC_03_S5_Switch_ruAstHoSyncePortNumber_which_Link_Speed_is_eCpri50_to_confirm_syncE_work_normal
    [Documentation]    Author: Ding Binmei
    ...    Switch ruAstHoSyncePortNumber from 1(TPS: 25G) to 3(DC: 50G) and verify ruAssistedHoPeriod==0
    [Arguments]    ${rmod_ids}=${RMOD_ID_WITH_7935_ENABLED}
    Update ruAstHoSyncePortNumber on BTS    exp_ruAstHoSyncePortNumber=${ruAstHoSyncePortNumber_DC}    rmod_ids=${rmod_ids}
    Wait Until Keyword Succeeds    3 min    30 sec    Verify value of ruAssistedHoPeriod is as expected
    ...    exp_ruAssistedHoPeriod=0    rmod_ids=${rmod_ids}

########################CB010630-SR-B_TC_05_cMAAr7.1_Manual_Assisted_Holdover_Mode_Alt2_SyncE_short_term_phase_transient_network_rearragement_Minor
CB010630-SR-B_TC_05_S1_Verify_syncE_and_clock_status_are_as_expected_and_ruAssistedHoPeriod_equals_NIDD_manualSynceAssistedHoPeriod
    [Documentation]    Author: Ding Binmei
    ...    1. Verify syncStatus is Locked. ruAssistedHoPeriod is same as NIDD manualSynceAssistedHoPeriod
    Wait until synce status become available
    Verify value of ruAssistedHoPeriod is as expected    exp_ruAssistedHoPeriod=${MANUAL_SYNCE_ASSISTED_HO_PERIOD}

CB010630-SR-B_TC_05_S2_Start_l3_call_and_verify_traffic_is_as_expected
    [Documentation]    Author: Ding Binmei
    ...    2. Start L3 call and Verify L3 call is as expected.Not to do ue detach and stop traffic
    CB007935-SR-B_TC_02_US02_S3_Start_l3_call_and_verify_traffic_is_as_expected

CB010630-SR-B_TC_05_S3_Update_ssmtrans_level_on_TPS_bellow_ssmAcceptanceLevel_and_verify_RU_syncE_unusable
    [Documentation]    Author: Ding Binmei
    ...    3. Update ssmtrans level on TPS for each RU from prc to ssu_A and verify
    ...    --3.1 Fault 4781(RU synce unusable) reported on related RMOD
    ...    if 4781 is reported on one RU, config object will be displayed for this specific RMOD and
    ...    no supplementary info is checked in additional information part;
    ...    if 4781 is reported for two or more RUs, config object will be displayed as MRBTS level and
    ...    All RMOD ids are displayed in supplementary info in additional information part.
    ...    --3.2 ruAssistedHoPeriod displayed as 65535;
    ...    --3.3 ssmValue updated to ssmSSU_A; syncE status: NOK; SyncStatus: Locked
    ...    --3.4 Counter check:
    ...          For first duration: M40122C0(ruSynceEstHoldoverTime) !=None, M40121C0(ruSynceRearrangement) is 1
    ...          For second duration: M40122C0(ruSynceEstHoldoverTime) ==None, M40121C0(ruSynceRearrangement) is 0
    CB007935-SR-A_TC_10_S4_Update_ssmtrans_level_on_TPS_bellow_ssmAcceptanceLevel_and_verify_RU_syncE_unusable

CB010630-SR-B_TC_05_S4_Restore_ssmtrans_level_on_TPS_and_verify_RU_syncE_available
    [Documentation]    Author: Ding Binmei
    ...    4. Update ssmtrans level on TPS for each RU back to prc and verify
    ...    --4.1 Fault 4781 disappeared
    ...    --4.2 ruAssistedHoPeriod displayed as NIDD manualSynceAssistedHoPeriod
    ...    --4.3 ssmValue updated to ssmPRC; syncE status: OK; SyncStatus: Locked
    ...    --4.4 Counter for M40122C0(ruSynceEstHoldoverTime) is 0, Counter for  M40121C0(ruSynceRearrangement) is 0
    CB007935-SR-A_TC_10_S5_Restore_ssmtrans_level_on_TPS_and_verify_RU_syncE_available    exp_ruAssistedHoPeriod=${MANUAL_SYNCE_ASSISTED_HO_PERIOD}

CB010630-SR-B_TC_05_S5_Disable_PTP_via_TPS_and_verify
    [Documentation]    Author: Ding Binmei
    ...    5. Disable PTP via TPS and verify:
    ...    --5.1 Fault 4298(Top reference missing)  is reported on related RU
    ...    --5.2 Check synceStatus is: Parent and syncStatus for clock is: Holdover.
    ...    --5.3 Verfify traffic is not affected.
    ...    --5.4 Verify ruAssistedHoPeriod changed as expected: For IntelligentHoldover, it is ruAssistedHoPeriod-1;
    ...          for ManualAssistedHoldover, it is manualSynceAssistedHoPeriod-1
    ...    --5.5 Detach UE and stop traffic
    ${exp_ruAssistedHoPeriod}    Evaluate    ${MANUAL_SYNCE_ASSISTED_HO_PERIOD}-1
    CB007935-SR-B_TC_02_US02_S4_Disable_PTP_via_TPS_and_verify    exp_ruAssistedHoPeriod=${exp_ruAssistedHoPeriod}

CB010630-SR-B_TC_05_S6_Wait_until_ruSynceEstHoldoverTime_expires_and_verify
    [Documentation]    Author: Ding Binmei
    ...    6. Hold for 1 h+ and verify:
    ...    --6.1: RU is in initial status and Fault 16 is reported on related RU
    ...    --6.2: ruAssistedHoPeriod is changed to 65535 and
    ...           counter value for ruSynceRearrangement (M40121C0) is 0, ruSynceEstHoldoverTime (M40122C0) is ${None}(from webUI - is displayed)
    ...    --6.3: MTIE file is removed
    CB007935-SR-B_TC_02_US02_S5_Wait_until_ruSynceEstHoldoverTime_expires_and_verify

CB010630-SR-B_TC_05_S7_Enable_PTP_and_verify
    [Documentation]    Author: Ding Binmei
    ...    7. Enable PTP and verify:
    ...    7.1 RU is enabled and cell on airl without Fault 16 and fault 4298
    ...    7.2 Sleep for 2 mins and verify clock and syncE status are as expected:
    ...        ssmValue:ssmPRC; synceStatus: OK; lockState: OutOfLock; syncStatus: Locked
    ...    7.3 Verify ruAssistedHoPeriod is same as NIDD manualSynceAssistedHoPeriod
    ...    7.4 Verify counter M40122C0(ruSynceEstHoldoverTime) is 0
    CB007935-SR-B_TC_02_US02_S6_Enable_PTP_and_verify    exp_ruAssistedHoPeriod=${MANUAL_SYNCE_ASSISTED_HO_PERIOD}
    Wait Until Keyword Succeeds    2X    1sec    Verify 7935 counter values are as expected    ruSynceRearrangement_exp=0
    ...    ruSynceEstHoldoverTime_exp=0

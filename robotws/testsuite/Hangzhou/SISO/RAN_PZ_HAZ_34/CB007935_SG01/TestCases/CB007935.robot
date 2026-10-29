*** Settings ***
Documentation    CB007935 Intelligent SyncE assisted holdover for eCPRI RU
Resource    ../Resources/CB007935_keywords.robot
Force Tags        5G_SISO
Suite Setup        Suite preparation
Suite Teardown     run keyword and ignore error    Suite teardown


*** Test Cases ***
CB007935-SR-A_TC_01_US01_Assisted_SyncE_HO_Estimate_No_impairment_cMAAr7.1_Feature_Activate
    [Documentation]    Author: Ding Binmei
    ...    1. Set feature flag actRuIntelligentSynceAstHoTime to false and verify pdl
    ...    2. Disable feature with pdl fixed and verify(backup reverse params before disable):
    ...    --2.1 SyncE lockStatus and synceStatus are none; Clock status is locked
    ...    --2.2 Verify MTIE file is removed and ruAssistedHoPeriod is None
    ...    3. Enable feature again and verify:
    ...    --3.1 SyncE and clock status are as expected
    ...    --3.2 Wait for 3 mins and check ruAssistedHoPeriod on webUI is 0
    ...    --3.3 Counter value for ruSynceRearrangement (M40121C0) and ruSynceEstHoldoverTime (M40122C0) are displayed as 0
    [Setup]    Test case setup
    Log to console    S1_Set_feature_flag_actRuIntelligentSynceAstHoTime_to_false_and_verify_pdl
    Run Keyword And Continue On Failure    CB007935-SR-A_TC_01_US01_S1_Set_feature_flag_actRuIntelligentSynceAstHoTime_to_false_and_verify_pdl
    Log to console    S2_Disable_feature_with_pdl_fixed_and_verify
    Run Keyword And Continue On Failure    CB007935-SR-A_TC_01_US01_S2_Disable_feature_with_pdl_fixed_and_verify
    Log to console    S3_Enable_feature_again_and_verify
    CB007935-SR-A_TC_01_US01_S3_Enable_feature_again_and_verify
    [Teardown]    Run keyword and ignore error    CB007935-SR-A_TC_01_US01_Case_teardown

CB007935-SR-B_TC_02_US02_Entering_HO_mode_with_Assisted_holdover_selected_then_original_PTP_restored
    [Documentation]    Author: Ding Binmei
    ...    1. Power reset RU as precondition
    ...    2.1 Verify SyncE and clock status are available
    ...    2.2 Wait until ruAssistedHoPeriod changes from 0 to 1 (About 1hour +)
    ...    2.3 Verify Counter ruSynceEstHoldoverTime (M40122C0) is 1
    ...    3. Start L3 call and verify traffic is as expected. Not to do ue detach and stop traffic
    ...    4. Disable PTP via TPS and verify:
    ...    --4.1 Fault 4298(Top reference missing)  is reported on related RU
    ...    --4.2 Check synceStatus is: parent and syncStatus for clock is: holdover
    ...    --4.3 Verfify traffic is not affected.
    ...    --4.4 Detach UE and stop traffic
    ...    5. Hold for 1 h+ and verify:
    ...    --5.1: RU is in initial status and Fault 16 is reported on related RU
    ...    --5.2: ruAssistedHoPeriod is changed to 65535 and
    ...           counter value for ruSynceRearrangement (M40121C0) is 0, ruSynceEstHoldoverTime (M40122C0) is ${None}(from webUI - is displayed)
    ...    --5.3: MTIE file is removed
    ...    6.1 Enable PTP and verify: RU is enabled and cell on air without Fault 16 and fault 4298
    ...    6.2 Sleep for 2 mins and verify clock and syncE status are as expected
    ...    6.3 Verify L3 call is as expected
    [Setup]    Test case setup
    Log to console    S1_Power_reset_RU
    CB007935-SR-B_TC_02_US02_S1_Power_reset_RU
    Log to console    S2_Verify_SyncE_and_clock_status_and_wait_until_ruAssistedHoPeriod_change_to_1
    CB007935-SR-B_TC_02_US02_S2_Verify_SyncE_and_clock_status_and_wait_until_ruAssistedHoPeriod_change_to_1
    Log to console    S3_Start_l3_call_and_verify_traffic_is_as_expected
    Run Keyword And Continue On Failure    CB007935-SR-B_TC_02_US02_S3_Start_l3_call_and_verify_traffic_is_as_expected
    Log to console    S4_Disable_PTP_via_TPS_and_verify
    CB007935-SR-B_TC_02_US02_S4_Disable_PTP_via_TPS_and_verify
    Log to console    S5_Wait_until_ruSynceEstHoldoverTime_expires_and_verify
    CB007935-SR-B_TC_02_US02_S5_Wait_until_ruSynceEstHoldoverTime_expires_and_verify
    Log to console    S6_Enable_PTP_and_verify
    CB007935-SR-B_TC_02_US02_S6_Enable_PTP_and_verify
    [Teardown]   Run keyword and ignore error    CB007935-SR-B_TC_02_US02_Case_teardown

CB007935-SR-A_TC_10_robutness_Assist_Holdover_Period_Estimation_Continue_After_RU_Warm_Reset
    [Documentation]    Author: Ding Binmei
    ...    1. Power reset RU if ruAssistedHoPeriod==65535
    ...    2. Hold until ruAssistedHoPeriod >=1 and record value of ruAssistedHoPeriod
    ...    3. Warm reset RU and verify:
    ...    --3.1 Verify SyncE and clock status are available
    ...    --3.2 Get current value of ruAssistedHoPeriod and verify value >= previous value in step 2
    ...    4. Update ssmtrans level on TPS for each RU from prc to ssu_A/ssu_B and verify
    ...    --4.1 Fault 4781(RU synce unusable) reported on related RMOD
    ...    if 4781 is reported on one RU, config object will be displayed for this specific RMOD and
    ...    no supplementary info is checked in additional information part;
    ...    if 4781 is reported for two or more RUs, config object will be displayed as MRBTS level and
    ...    All RMOD ids are displayed in supplementary info in additional information part.
    ...    --4.2 ruAssistedHoPeriod displayed as 65535
    ...    --4.3 Counter check:
    ...          For first duration: M40122C0(ruSynceEstHoldoverTime) !=None, M40121C0(ruSynceRearrangement) is 1
    ...          For second duration: M40122C0(ruSynceEstHoldoverTime) ==None, M40121C0(ruSynceRearrangement) is 0
    ...    5. Update ssmtrans level on TPS for each RU back to prc and verify
    ...    --5.1 Fault 4781 disappeared
    ...    --5.2 ruAssistedHoPeriod displayed as 0
    ...    --5.3 Counter for M40122C0(ruSynceEstHoldoverTime) is 0, Counter for  M40121C0(ruSynceRearrangement) is 0
    ...    6. Update NIDD SCF accep level to ssmePRTC and verify: Same with step 4
    ...    7. Update NIDD SCF accep level back(ssmPRCorPRS) and verify: Same with step 5
    [Setup]    Test case setup
    Log to console    S1_Power_reset_RU_if_ruAssistedHoPeriod_is_65535
    ${is_rf_power_reset}    CB007935-SR-A_TC_10_S1_Power_reset_RU_if_ruAssistedHoPeriod_is_65535
    Log to console    S2_Hold_until_ruAssistedHoPeriod_bigger_than_0_and_record_value
    ${ruAssistedHoPeriod_for_rmod_pre}    CB007935-SR-A_TC_10_S2_Hold_until_ruAssistedHoPeriod_bigger_than_0_and_record_value
    ...    is_rf_power_reset=${is_rf_power_reset}
    Log to console    S3_Warm_reset_RU_and_verify_ruAssistedHoPeriod_is_not_cleared
    CB007935-SR-A_TC_10_S3_Warm_reset_RU_and_verify_ruAssistedHoPeriod_is_not_cleared
    ...    dict_ruAssistedHoPeriod_for_rmod_pre=${ruAssistedHoPeriod_for_rmod_pre}
    Log to console    S4_Update_ssmtrans_level_on_TPS_bellow_ssmAcceptanceLevel_and_verify_RU_syncE_unusable
    CB007935-SR-A_TC_10_S4_Update_ssmtrans_level_on_TPS_bellow_ssmAcceptanceLevel_and_verify_RU_syncE_unusable
    Log To Console    S5_Restore_ssmtrans_level_on_TPS_and_verify_RU_syncE_available
    CB007935-SR-A_TC_10_S5_Restore_ssmtrans_level_on_TPS_and_verify_RU_syncE_available
    Log to console    S6_Update_ssmAcceptanceLevel_to_high_level_than_TPS_ssmtrans_level_and_verify_RU_syncE_unusable
    CB007935-SR-A_TC_10_S6_Update_ssmAcceptanceLevel_to_high_level_than_TPS_ssmtrans_level_and_verify_RU_syncE_unusable
    Log To Console    S7_Restore_ssmAcceptanceLevel_and_verify_RU_syncE_available
    CB007935-SR-A_TC_10_S7_Restore_ssmAcceptanceLevel_and_verify_RU_syncE_available
    [Teardown]   Run keyword and ignore error    CB007935-SR-A_TC_10_Case_teardown

CB010630-SR-B_TC_03_Transitioning_from_Assisted_to_Off-Air_with_a_major_SyncE_impairment_for_network_rearrangement
    [Documentation]    Author: Ding Binmei
    ...    This is for 7935 function on 7-2e RU
    ...    Precondition: Open 7-2e params for AVQQ; Add additional cablink to cover 50G
    ...    1. Power reset RU if ruAssistedHoPeriod==65535
    ...    2. Wait until ruAssistedHoPeriod != 65535
    ...    3. Trigger syncE major impairment by update ssmtrans level to none on TPS for more then 15s and verify:
    ...    --3.1 SyncEStatus change to NOK, ssmValue displayed as ssmQualityUnknown
    ...    --3.2 Fault 4781(RU synce unusable) reported on related RMOD
    ...    --3.3 ruAssistedHoPeriod displayed as 65535
    ...    --3.4 Counter check:
    ...          For first duration: M40122C0(ruSynceEstHoldoverTime) !=None, M40121C0(ruSynceRearrangement) is 1
    ...          For second duration: M40122C0(ruSynceEstHoldoverTime) ==None, M40121C0(ruSynceRearrangement) is 0
    ...    4. Update ssmtrans level on TPS for each RU back to prc and verify
    ...    --4.1 Fault 4781 disappeared
    ...    --4.2 ruAssistedHoPeriod displayed as 0
    ...    --4.3 Counter for M40122C0(ruSynceEstHoldoverTime) is 0, Counter for  M40121C0(ruSynceRearrangement) is 0
    ...    5. Switch ruAstHoSyncePortNumber from 1 to 3 to cover 50G on AVQQ and verify ruAssistedHoPeriod==0
    [Setup]    CB010630-SR-B_TC_03_Case_setup
    Log to console    S1_Power_reset_RU_if_ruAssistedHoPeriod_is_65535
    Power_reset_RU_based_on_exp_ruAssistedHoPeriod    expression===    exp_ruAssistedHoPeriod=65535
    Log to console    S2_wait_until_ruAssistedHoPeriod_is_not_65535
    Wait until keyword succeeds    5min    30s    Verify value of ruAssistedHoPeriod is as expected
    ...        expression=!=    exp_ruAssistedHoPeriod=65535
    Log to console    S3_Trigger_syncE_major_impairment_and_verify
    Run Keyword And Continue On Failure    CB010630-SR-B_TC_03_S3_Trigger_syncE_major_impairment_and_verify
    Log to console    S4_Restore_ssmtrans_level_on_TPS_and_verify_RU_syncE_available
    CB010630-SR-B_TC_03_S4_Restore_ssmtrans_level_on_TPS_and_verify_RU_syncE_available
    Log to console    S5_Switch_ruAstHoSyncePortNumber_which_Link_Speed_is_eCpri50_to_confirm_syncE_work_normal
    CB010630-SR-B_TC_03_S5_Switch_ruAstHoSyncePortNumber_which_Link_Speed_is_eCpri50_to_confirm_syncE_work_normal
    [Teardown]    Run keyword and ignore error    CB010630-SR-B_TC_03_Case_teardown

CB010630-SR-B_TC_05_cMAAr7.1_Manual_Assisted_Holdover_Mode_Alt2_SyncE_short_term_phase_transient_network_rearragement_Minor
    [Documentation]    Author: Ding Binmei
    ...    Precondition: Open 7-2e params for AVQQ;
    ...                  synceAssistedHoldoverMode is updated as ManualHoldover; manualSynceAssistedHoPeriod set to 2h
    ...    1. Verify syncStatus is Locked. ruAssistedHoPeriod is same as NIDD manualSynceAssistedHoPeriod
    ...    2. Start L3 call and Verify L3 call is as expected.Not to do ue detach and stop traffic
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
    ...    4. Update ssmtrans level on TPS for each RU back to prc and verify
    ...    --4.1 Fault 4781 disappeared
    ...    --4.2 ruAssistedHoPeriod displayed as NIDD manualSynceAssistedHoPeriod
    ...    --4.3 ssmValue updated to ssmPRC; syncE status: OK; SyncStatus: Locked
    ...    --4.3 Counter for M40122C0(ruSynceEstHoldoverTime) is 0, Counter for  M40121C0(ruSynceRearrangement) is 0
    ...    5. Disable PTP via TPS and verify:
    ...    --5.1 Fault 4298(Top reference missing) is reported on related RU
    ...    --5.2 Check synceStatus is: Parent and syncStatus for clock is: Holdover.
    ...    --5.3 Verfify traffic is not affected.
    ...    --5.4 Verify ruAssistedHoPeriod changed as expected: For IntelligentHoldover, it is ruAssistedHoPeriod-1;
    ...          for ManualAssistedHoldover, it is manualSynceAssistedHoPeriod-1
    ...    --5.5 Detach UE and stop traffic
    ...    6. Hold for 1 h+ and verify:
    ...    --6.1: RU is in initial status and Fault 16 is reported on related RU
    ...    --6.2: ruAssistedHoPeriod is changed to 65535 and
    ...           counter value for ruSynceRearrangement (M40121C0) is 0, ruSynceEstHoldoverTime (M40122C0) is ${None}(from webUI - is displayed)
    ...    --6.3: MTIE file is removed
    ...    7. Enable PTP and verify:
    ...    7.1 RU is enabled and cell on air without Fault 16 and fault 4298
    ...    7.2 Sleep for 2 mins and verify clock and syncE status are as expected:
    ...        ssmValue:ssmPRC; synceStatus: OK; lockState: OutOfLock; syncStatus: Locked
    ...    7.3 Verify ruAssistedHoPeriod is same as NIDD manualSynceAssistedHoPeriod
    ...    7.4 Verify counter M40122C0(ruSynceEstHoldoverTime) is 0
    [Setup]    CB010630-SR-B_TC_05_Case_setup
    Log to console    S1_Verify_syncE_and_clock_status_are_as_expected_and_ruAssistedHoPeriod_equals_NIDD_manualSynceAssistedHoPeriod
    CB010630-SR-B_TC_05_S1_Verify_syncE_and_clock_status_are_as_expected_and_ruAssistedHoPeriod_equals_NIDD_manualSynceAssistedHoPeriod
    Log to console    S2_Start_l3_call_and_verify_traffic_is_as_expected
    Run Keyword And Continue On Failure    CB010630-SR-B_TC_05_S2_Start_l3_call_and_verify_traffic_is_as_expected
    Log to console    S3_Update_ssmtrans_level_on_TPS_bellow_ssmAcceptanceLevel_and_verify_RU_syncE_unusable
    CB010630-SR-B_TC_05_S3_Update_ssmtrans_level_on_TPS_bellow_ssmAcceptanceLevel_and_verify_RU_syncE_unusable
    Log to console    S4_Restore_ssmtrans_level_on_TPS_and_verify_RU_syncE_available
    CB010630-SR-B_TC_05_S4_Restore_ssmtrans_level_on_TPS_and_verify_RU_syncE_available
    Log to console    S5_Disable_PTP_via_TPS_and_verify
    CB010630-SR-B_TC_05_S5_Disable_PTP_via_TPS_and_verify
    Log to console    S6_Wait_until_ruSynceEstHoldoverTime_expires_and_verify
    CB010630-SR-B_TC_05_S6_Wait_until_ruSynceEstHoldoverTime_expires_and_verify
    Log to console    S7_Enable_PTP_and_verify
    CB010630-SR-B_TC_05_S7_Enable_PTP_and_verify
    [Teardown]    Run keyword and ignore error    CB010630-SR-B_TC_05_Case_teardown

#PR825598_case_reproduce
#    [Documentation]    Author: Ding Binmei
#    ...    Reproduce occassional issue for PR825598
#    [Setup]    Test case setup
#    repeat_keyword    50 times    PR825598_case_steps
#    [Teardown]    Run keyword and ignore error    PR825598_teardown

*** Keywords ***
Test case setup
    [Arguments]    ${dict_params_to_modify}=${None}    ${rmod_id_with_7935_enabled}=${RMOD_ID_WITH_7935_ENABLED_RF71_RF62}
    ...    ${timeout_online_modify}=${TIMER_FOR_MODIFY_VIA_API}
    Set Test Variable    ${RMOD_ID_WITH_7935_ENABLED}    ${rmod_id_with_7935_enabled}
    Log to console    RMOD_ID_WITH_7935_ENABLED: ${RMOD_ID_WITH_7935_ENABLED}
    Common case setup    NSA_SA=${NSA_SA}    is_scf_backup_needed=${False}
#    Fault 16: Unit synchronization failed. If online modify caused BTS reset, these alarm need to be ignored.
    AlarmWatchdog.add_allow_alarms    fault_id=16
    run keyword if    ${dict_params_to_modify}!=${None}
    ...    Run keywords    nidd_modify.online_modify_nidd_parameters_via_restapi    params_modify_dict=${dict_params_to_modify}
    ...        timeout=${timeout_online_modify}    AND
    ...        Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    is_need_to_setup_gnb_connection=${False}
    AlarmWatchdog.remove_allow_alarms    fault_id=16
    # download SCF file to log path for mannual rerun or mannual debug issue
    run keyword and ignore error    Download SCF file to log path
    # variable ${gNb_CuType} is needed in common siso case General_SiSo_RF_module_power_reset.General_SiSo_RF_module_power_reset and
    # case: General_SiSo_RF_module_reset_from_GUI.General_SiSo_RF_module_reset_from_GUI
    ${gNb_CuType}   Get gNB CU type    connection=GNB_OAM
    set test variable      ${gNb_CuType}
    # Variable ${Active_SW_version} is used in General_SiSo_RF_module_reset_from_GUI.General_SiSo_RF_module_reset_from_GUI for selenium login
    ${Active_SW_version}    Get Active SW Version
    set test variable      ${Active_SW_version}

CB010630-SR-B_TC_03_Case_setup
    [Documentation]    Author: Ding Binmei
    ...    This is for 7935 function on 7-2e RU
    ...    Precondition: Open 7-2e params for AVQQ; Add additional cablink to cover 50G on AVQQ
    ...    ${RMOD_ID_WITH_7935_ENABLED_7_2E}/${REST_API_ADD_CABLINK_FOR_7_2E_RMOD_AND_BB_WITH_LINKSPEED_eCpri50}: are defined in commission folder
    ...    for testline
    [Arguments]    ${rmod_id_with_7935_enabled}=${RMOD_ID_WITH_7935_ENABLED_7_2E}
    Log to console    Enable 7-2e params for RMOD: ${rmod_id_with_7935_enabled}
    Connect to gnb coam via ssl
    ${dict_enable_72e_params}    param_modify_lib_7935.get_params_to_enable_ecpri72e    list_rmod_id=${rmod_id_with_7935_enabled}
    ${dict_nidd_online_update}    Copy Dictionary    ${dict_enable_72e_params}    deepcopy=${True}
    Set To Dictionary    ${dict_nidd_online_update}    object_to_add    ${REST_API_ADD_CABLINK_FOR_7_2E_RMOD_AND_BB_WITH_LINKSPEED_eCpri50}
    Test case setup    dict_params_to_modify=${dict_nidd_online_update}    rmod_id_with_7935_enabled=${rmod_id_with_7935_enabled}
    ...    timeout_online_modify=8min
    Wait until keyword succeeds    5min    30s    Verify value of ruAssistedHoPeriod is as expected
    ...        expression=!=    exp_ruAssistedHoPeriod=65535

CB010630-SR-B_TC_05_Case_setup
    [Documentation]    Author: Ding Binmei
    ...    Precondition: Open 7-2e params for AVQQ; Update synceAssistedHoldoverMode to ManualHoldover
    [Arguments]    ${rmod_id_with_7935_enabled}=${RMOD_ID_WITH_7935_ENABLED_RF71_RF62}
    Log to console    Enable 7-2e params for RMOD: ${rmod_id_with_7935_enabled}
    Connect to gnb coam via ssl
    ${dict_enable_72e_params}    param_modify_lib_7935.get_params_to_enable_ecpri72e    list_rmod_id=${RMOD_ID_WITH_7935_ENABLED_7_2E}
    ${dict_update_to_manualHoldover}    param_modify_lib_7935.get_params_to_update_synceAssistedHoldoverMode_to_ManualHoldover
    ...    list_rmod_id=${rmod_id_with_7935_enabled}    exp_manualSynceAssistedHoPeriod=${MANUAL_SYNCE_ASSISTED_HO_PERIOD}
    ${dict_nidd_online_update}    Combine params for online modify    dict_params1=${dict_enable_72e_params}
    ...    dict_params2=${dict_update_to_manualHoldover}
    Test case setup    dict_params_to_modify=${dict_nidd_online_update}    rmod_id_with_7935_enabled=${rmod_id_with_7935_enabled}
    ...    timeout_online_modify=8min
    Wait until keyword succeeds    5min    30s    Verify value of ruAssistedHoPeriod is as expected
    ...        expression=!=    exp_ruAssistedHoPeriod=65535

Test case teardown
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${is_scf_restore}=${False}    ${scf_file_path_for_restore}=${None}    ${is_onair_check}=${False}
    ...    ${detach_ue}=${False}
    Common case teardown    detach_ue=${detach_ue}
    ...    is_scf_restore=${is_scf_restore}    scf_file_path_for_restore=${scf_file_path_for_restore}
    ...        is_btslog_required=${False}    is_onair_check=${is_onair_check}    onair_timeout=${TIMER_FOR_CELL_ON_AIR}    NSA_SA=${NSA_SA}

CB007935-SR-A_TC_01_US01_Case_teardown
    [Documentation]    Author: Ding Binmei
    FOR    ${rmod_id}    IN    @{RMOD_ID_WITH_7935_ENABLED}
        Run Keyword And Continue On Failure    PR825598_log_capture    rmod_id=${rmod_id}
    END
    ${is_scf_restore}    Set variable if    '${TEST STATUS}'=='FAIL'    ${True}    ${False}
    ${scf_file_path_for_restore}    Set variable if    ${is_scf_restore}    ${scf_file_path_for_restore}    ${None}
    ${is_onair_check}    Set variable if    ${is_scf_restore}    ${True}    ${False}
    Test case teardown    is_scf_restore=${is_scf_restore}
    ...    scf_file_path_for_restore=${scf_file_path_for_restore}    is_onair_check=${is_onair_check}

CB007935-SR-B_TC_02_US02_Case_teardown
    [Documentation]    Author: Ding Binmei
    Test case teardown    detach_ue=${True}
    Connect to gnb coam via ssl
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=all
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keywords
    ...    Enabe PTP ports on TPS for all RUs    tps_ports=${TPS_OUT_PORTS_FOR_ALL_RUS}    AND
    ...    Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    is_need_to_setup_gnb_connection=${False}    AND
    ...    Wait Until Keyword Succeeds    5 min    30 sec    Verify value of ruAssistedHoPeriod is as expected
    ...    exp_ruAssistedHoPeriod=65535    expression=!=
    COAM Teardown gnb connections

CB007935-SR-A_TC_10_Case_teardown
    Test case teardown
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keywords
    ...    Update ssmtrans level on TPS    ssmtrans_level=PRC    tps_ports=${TPS_OUT_PORTS_FOR_ALL_RUS}    AND
    ...    Connect to gnb coam via ssl    AND
    ...    Update ssmAcceptanceLevel on BTS    exp_ssmAcceptanceLevel=ssmPRCorPRS    rmod_ids=${RMOD_ID_WITH_7935_ENABLED}    AND
    ...    Wait until cluster ready based on NSA_SA type   NSA_SA=${NSA_SA}    is_need_to_setup_gnb_connection=${False}    AND
    ...    Wait Until Keyword Succeeds    5 min    30 sec    Verify value of ruAssistedHoPeriod is as expected
    ...    exp_ruAssistedHoPeriod=65535    expression=!=    AND
    ...    COAM Teardown gnb connections

CB010630-SR-B_TC_03_Case_teardown
    [Documentation]    Author: Ding Binmei
    Test case teardown    is_scf_restore=${True}
    ...    scf_file_path_for_restore=${scf_file_path_for_restore}    is_onair_check=${True}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keywords
    ...    Update ssmtrans level on TPS    ssmtrans_level=PRC    tps_ports=${TPS_OUT_PORTS_FOR_ALL_RUS}    AND
    ...    Connect to gnb coam via ssl    AND
    ...    Wait Until Keyword Succeeds    5 min    30 sec    Verify value of ruAssistedHoPeriod is as expected
    ...    exp_ruAssistedHoPeriod=65535    expression=!=    AND
    ...    COAM Teardown gnb connections

CB010630-SR-B_TC_05_Case_teardown
    [Documentation]    Author: Ding Binmei
    Test case teardown    detach_ue=${True}
    Connect to gnb coam via ssl
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=all
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keywords
    ...    Enabe PTP ports on TPS for all RUs    tps_ports=${TPS_OUT_PORTS_FOR_ALL_RUS}    AND
    ...    Update ssmtrans level on TPS    ssmtrans_level=PRC    tps_ports=${TPS_OUT_PORTS_FOR_ALL_RUS}    AND
    ...    Wait Until Keyword Succeeds    5 min    30 sec    Verify value of ruAssistedHoPeriod is as expected
    ...    exp_ruAssistedHoPeriod=65535    expression=!=
    COAM Teardown gnb connections

PR825598_case_steps
    AlarmWatchdog.add_allow_alarms    fault_id=16
    COAM Commission with scf file    scf_file_path=${scf_file_path_for_restore}    timeout=${COMMISSION_API_TIMEOUT}
    ...    is_pdl_checking_needed=${False}
    Wait cell onair classical cloud    timeout=${TIMER_FOR_CELL_ON_AIR}
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
    Log to console    S1_Set_feature_flag_actRuIntelligentSynceAstHoTime_to_false_and_verify_pdl
    Run Keyword And Continue On Failure    CB007935-SR-A_TC_01_US01_S1_Set_feature_flag_actRuIntelligentSynceAstHoTime_to_false_and_verify_pdl
    Log to console    S2_Disable_feature_with_pdl_fixed_and_verify
    CB007935-SR-A_TC_01_US01_S2_Disable_feature_with_pdl_fixed_and_verify
    Log to console    S3_Enable_feature_again_and_verify
    CB007935-SR-A_TC_01_US01_S3_Enable_feature_again_and_verify
    AlarmWatchdog.remove_allow_alarms    fault_id=16

PR825598_log_capture
    [Arguments]    ${rmod_id}    ${connection_alias}=GNB_OAM
    ${ru_alias}    Login to RU which is for MTIE file checking    rmod_id=${rmod_id}    connection_alias=${connection_alias}
    ${log_cmd}    Catenate    SEPARATOR=    echo "ls -la /var/log/\n"; sleep 2; ls -la /var/log/;
    ...    echo "ls -la /var/log/hwapi/\n"; sleep 2; ls -la /var/log/hwapi/;
    ...    echo "ls -la /var/log/hwapi/sync/\n"; sleep 2;  ls -la /var/log/hwapi/sync/;
    ...    echo "ls -la /rpram\n"; sleep 2;  ls -la /rpram;
    ...    echo "ls -la /rpram/hwapi/\n"; sleep 2; ls -la /rpram/hwapi/;
    ...    echo "ls -la /rpram/hwapi/sync\n"; sleep 2; ls -la /rpram/hwapi/sync
    ${result}    csn.execute    command=${log_cmd}    connection=${ru_alias}
    Run    command=echo "${result}"> ${TS_CASE_LOG_PATH}/RMOD_${rmod_id}_log_output.log 2>&1 &
    [Teardown]    Release RU connections    ru_alias=${ru_alias}

PR825598_teardown
    FOR    ${rmod_id}    IN    @{RMOD_ID_WITH_7935_ENABLED}
        Run Keyword And Continue On Failure    PR825598_log_capture    rmod_id=${rmod_id}
    END
    Test case teardown

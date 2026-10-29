*** Settings ***
Documentation
...   author: Adam Chamera
...   contact: adam.chamera@nokia.com
...   This is the TESTSUITE file for CB008200
...
...      == HISTORY ==
...         [16.05.2022] - Aligned CB008200-D_2 and CB008200-F_8 tests with the changes introduced in 5G_L3_FLOW_59779 for PR644597

Library    taf.ue
Library    DateTime
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/pm_counters.py
Library    testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library    taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils        WITH NAME   AdminUtils
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod   WITH NAME   TcpdumpSmod
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008200/resources/test_specific_keywords_8200.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB007564/resources/test_specific_keywords_7564.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Variables  testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008200/resources/test_specific_keywords_8200.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py


*** Variables ***
${pm_interval}                     5
${pm_interval_part6}               10
@{cell_1_gnb_2_ports}              9  10
@{cell_2_gnb_2_ports}              15  16
@{cell_1_enb_2_ports}              13  14
@{all_attenuator_ports}            9  10  13  14  15  16
${REESTABLISHMENT_SLEEP_TIME}      2.5
#TODO: ${target_phys_cell_id}             24    # podac oczekiwana dla tej linii dla check_inter_rat_ho_in_pcap_log


*** Keywords ***
Collect snapshot
    [Arguments]         ${alias}=coam
    ...                 ${snap_coverage}=Full
    ...                 ${force}=${TRUE}
    ...                 ${timeout_value}=600sec
    Log to console      __Collect snapshot.
    coam.Connect to     name=${alias}
    ${software_info}    coam.Get software info  connection=${alias}
    ${sw_version}       Set variable  ${software_info['Active SW version']}
    ${timestamp}        DateTime.Get Current Date  result_format=%Y%m%d-%H%M%S
    ${snapshot_path}    Set variable  ${LOG_PATH}/Snapshots/${TEST NAME}/Snapshot_${sw_version}_${timestamp}.zip
    coam.Get snapshot   ${snapshot_path}
    ...                 ${snap_coverage}
    ...                 ${force}
    ...                 ${timeout_value}
    ...                 ${alias}
    [Teardown]          coam.Teardown  connection=${alias}


Collect Counters For ${test_cases}
    ${pi_dir} =   Collect Counters    log_name=${test_cases}  target_dir=${OUTPUT DIR}/counters
    Log  ${pi_dir}  console=True


Make Counter Logs Path
    [Arguments]    ${logs_names}
    ${target_dir} =  Set Variable  ${OUTPUT DIR}/counters/${logs_names}
    [Return]    ${target_dir}


Get Attach Setup Time
    ${attach_setup_date} =  Get Current Date
    Set Global Variable  ${ATTACH_SETUP_DATE}  ${attach_setup_date}


Get Call Setup Time
    ${call_setup_date} =  Get Current Date
    Set Global Variable  ${SETUP_DATE}  ${call_setup_date}


Get Call Stop Time
    ${call_stop_date} =  Get Current Date
    Set Global Variable  ${STOP_DATE}  ${call_stop_date}


Get Detach Time
    ${detach_date} =  Get Current Date
    Set Global Variable  ${DETACH_DATE}  ${detach_date}


Get Call Duration
    ${call_duration} =  Subtract Date From Date  ${STOP_DATE}   ${SETUP_DATE}
    Set Global Variable  ${CALL_DURATION}  ${call_duration}


Get Attach Duration
    ${attach_duration} =  Subtract Date From Date  ${DETACH_DATE}   ${ATTACH_SETUP_DATE}
    Set Global Variable  ${ATTACH_DURATION}  ${attach_duration}


Get Cumulated Duration Of All Sessions
    ${cumulated_duration_of_all_sessions} =	Evaluate	( (${ATTACH_DURATION} * 2) + ${CALL_DURATION} )
    Set Global Variable  ${CUMULATED_DURATION_OF_ALL_SESSIONS}  ${cumulated_duration_of_all_sessions}


Next Part Setup
    Prepare Testline
    initialise_attenuator
    Set counter period parameters for all
    Detach Ues  2
    nullify_attenuation_on_all_ports


PART__1__B_6__E_1__E_3__E_4__F_1__Start_1st_VoNR_Call__and__D_7__D_8__E_2__F_14__Stop_1st_VoNR_Call
    Set parameters for PART 1
    starting_btslog  1st
    TcpdumpSmod.start_tcpdump_on_smod    filename=the_1st_call.pcap    smod_master=${true}
    Run Keyword And Ignore Error   AdminUtils.lock_cells   dist_name_list=${cells_dist_names_to_lock}
    attach_utils.Attach Ues  2
    Get Attach Setup Time
    BuiltIn.Sleep   60s
    taf.ue.Start Voice Call    vc_alias=VC_1    ue_alias=UE_1    to=UE_2
    Get Call Setup Time
    taf.ue.Await Incoming Voice Call    vc_alias=VC_1    ue_alias=UE_2     action=answer    timeout=20s
    BuiltIn.Sleep   315s
    collecting_btslog  which_time=1st  log_path=${OUTPUT_DIR}
    ${first_call_sctp}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    Move File  ${first_call_sctp}  ${OUTPUT_DIR}/source_logs_dir/the_1st_call.pcap
    GnbCounter.wait_for_next_pm_period   interval=${pm_interval}
    Collect Counters For B_6__E_1__E_3__E_4__F_1

    starting_btslog  1st_stop
    TcpdumpSmod.start_tcpdump_on_smod    filename=the_1st_stop_call.pcap    smod_master=${true}
    BuiltIn.Sleep   15s
    taf.ue.Stop Voice Call    VC_1
    Get Call Stop Time
    Get Call Duration
    Detach Ues  2
    Get Detach Time
    Get Attach Duration
    Get Cumulated Duration Of All Sessions
    collecting_btslog  which_time=1st_stop  log_path=${OUTPUT_DIR}
    ${first_call_stop_sctp}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    Move File  ${first_call_stop_sctp}  ${OUTPUT_DIR}/source_logs_dir/the_1st_stop_call.pcap
    GnbCounter.wait_for_next_pm_period   interval=${pm_interval}
    Collect Counters For D_7__D_8__E_2__F_14

    [Teardown]     Run Keywords
    ...            AdminUtils.unlock_all_cells                                                                        AND
    ...            taf.ue.Stop Voice Call        VC_1                                                                 AND
    ...            Detach Ues  2                                                                                      AND
    ...            Run Keyword And Ignore Error    collecting_btslog  which_time=1st_stop  log_path=${OUTPUT_DIR}     AND
    ...            TcpdumpSmod.teardown_tcpdump_on_smod                                                               AND
    ...            Clear parameters after PART 1


PART_2__D_2__F_8__RLF
    Next Part Setup
    Set parameters for PART 2 RLF
    starting_btslog  2nd
    TcpdumpSmod.start_tcpdump_on_smod    filename=the_2nd_call.pcap    smod_master=${true}
    Attach Ues  2
    taf.ue.Start Voice Call    vc_alias=VC_2    ue_alias=UE_1    to=UE_2
    taf.ue.Await Incoming Voice Call    vc_alias=VC_2    ue_alias=UE_2     action=answer    timeout=20s
    BuiltIn.Sleep   15s
    Set attenuation    value_string=90
    BuiltIn.Sleep   200s
    collecting_btslog  which_time=2nd  log_path=${OUTPUT_DIR}
    ${second_call_sctp}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    Move File  ${second_call_sctp}  ${OUTPUT_DIR}/source_logs_dir/the_2nd_call.pcap
    GnbCounter.wait_for_next_pm_period   interval=${pm_interval}
    Collect Counters For D_2__F_8

    [Teardown]     Run Keywords
    ...            taf.ue.Stop Voice Call        VC_2                                                            AND
    ...            Detach Ues  2                                                                                 AND
    ...            Run Keyword And Ignore Error    collecting_btslog  which_time=2nd  log_path=${OUTPUT_DIR}     AND
    ...            nullify_attenuation_on_all_ports                                                              AND
    ...            TcpdumpSmod.teardown_tcpdump_on_smod                                                          AND
    ...            Clear parameters after PART 2 RLF


PART_3__B_7__F_15__REESTABLISHMENT
    Next Part Setup
    Set parameters for PART 3 REESTABLISHMENT
    starting_btslog  3rd
    TcpdumpSmod.start_tcpdump_on_smod    filename=the_3rd_call.pcap    smod_master=${true}
    Set attenuation    value_string=90    port=${cell_2_gnb_2_ports}
    Attach Ues  2
    Show Cell ID Before Change
    BuiltIn.Sleep   60s
    taf.ue.Start Voice Call    vc_alias=VC_3    ue_alias=UE_1    to=UE_2
    taf.ue.Await Incoming Voice Call    vc_alias=VC_3    ue_alias=UE_2     action=answer    timeout=20s
    BuiltIn.Sleep   5s
    Set attenuation    value_string=90   port=${cell_1_gnb_2_ports}
    BuiltIn.Sleep   ${REESTABLISHMENT_SLEEP_TIME}
    Set attenuation    value_string=0   port=${cell_2_gnb_2_ports}
    BuiltIn.Sleep   7s
    Show Cell ID After Change
    taf.ue.Stop Voice Call    VC_3
    Detach Ues    2
    collecting_btslog  which_time=3rd  log_path=${OUTPUT_DIR}
    ${third_call_sctp}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    Move File  ${third_call_sctp}  ${OUTPUT_DIR}/source_logs_dir/the_3rd_call.pcap
    GnbCounter.wait_for_next_pm_period   interval=${pm_interval}
    Collect Counters For B_7__F_15

    [Teardown]     Run Keywords
    ...            taf.ue.Stop Voice Call        VC_3                                                            AND
    ...            Detach Ues  2                                                                                 AND
    ...            Run Keyword And Ignore Error    collecting_btslog  which_time=3rd  log_path=${OUTPUT_DIR}     AND
    ...            TcpdumpSmod.teardown_tcpdump_on_smod                                                          AND
    ...            Clear parameters after PART 3 REESTABLISHMENT


PART_4__B_1__F_2__FALLBACK
    #TODO: czy tu ma sens sprawdzanie 5QI1? czy tylko 5QI5?????????????????????
    #TODO: B_1__F_2__Step 2: Start VoNR call on UE connected to 5G cell -> VoNR call not reached
    Next Part Setup
    Set parameters for PART 4 FALLBACK
    Disable VoNR On GNB For Fallback
    starting_btslog  4th
    TcpdumpSmod.start_tcpdump_on_smod    filename=the_4th_call.pcap    smod_master=${true}
    Lock Cells   dist_name_list=${cells_dist_names_to_lock}  #TODO: ktore porty konkretnie?
    Attach Ue    UE_1      # TODO: jaka jest droga radiowa
    Attach Ue    UE_2    #TODO: ten ue musi byc do LTE zaatachowany, moze to jakis UE_3 ? w jakiej celce sa ueki?
    taf.ue.Start Voice Call    vc_alias=VC_4    ue_alias=UE_1    to=UE_2
    taf.ue.Await Incoming Voice Call    vc_alias=VC_4    ue_alias=UE_2     action=answer    timeout=20s  #TODO: odbierze w LTE po fallbacku?
    BuiltIn.Sleep   15s
    collecting_btslog  which_time=4th  log_path=${OUTPUT_DIR}
    ${fourth_call_sctp}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    Move File  ${fourth_call_sctp}  ${OUTPUT_DIR}/source_logs_dir/the_4th_call.pcap
    GnbCounter.wait_for_next_pm_period   interval=${pm_interval}
    Collect Counters For B_1__F_2

    [Teardown]     Run Keywords
    ...            AdminUtils.unlock_all_cells                                                                   AND
    ...            taf.ue.Stop Voice Call        VC_4                                                            AND
    ...            Detach Ues  2                                                                                 AND
    ...            Run Keyword And Ignore Error    collecting_btslog  which_time=4th  log_path=${OUTPUT_DIR}     AND
    ...            TcpdumpSmod.teardown_tcpdump_on_smod                                                          AND
    ...            Clear parameters after PART 4 FALLBACK                                                        AND
    ...            Enable VoNR On GNB For Fallback


PART_5__D_1__F_7__REDIRECTION
    #TODO: D_1__F_7__Step 3: Trigger an LTE redirect with the attenuator ->
    #TODO: D_1__F_7__Criteria for the configured measurement event A2 for redirection are met.
    #TODO: D_1__F_7__gNB triggers RRC Connection Release procedure with redirection information (redirectedInfoCarrier).
    #TODO: D_1__F_7__UE successfully performs a redirect to LTE cell
    Next Part Setup
    Set parameters for PART 5 REDIRECTION
    starting_btslog  5th
    TcpdumpSmod.start_tcpdump_on_smod    filename=the_5th_call.pcap    smod_master=${true}
    Lock Cells   dist_name_list=${cells_dist_names_to_lock}  #TODO: ktore porty konkretnie?
    Attach Ues  2
    taf.ue.Start Voice Call    vc_alias=VC_5    ue_alias=UE_1    to=UE_2
    taf.ue.Await Incoming Voice Call    vc_alias=VC_5    ue_alias=UE_2     action=answer    timeout=20s
    BuiltIn.Sleep   15s
    Gradually increase attenuation    init_value=0   max_value=25   step=2   interval=1   port=${cell_1_gnb_2_ports}
    BuiltIn.Sleep   5s
    Collect Logs From Source And Target BTS 5th Time
    collecting_btslog  which_time=5th  log_path=${OUTPUT_DIR}
    ${fifth_call_sctp}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    Move File  ${fifth_call_sctp}  ${OUTPUT_DIR}/source_logs_dir/the_5th_call.pcap
    GnbCounter.wait_for_next_pm_period   interval=${pm_interval}
    Collect Counters For D_1__F_7

    [Teardown]     Run Keywords
    ...            AdminUtils.unlock_all_cells                                                                   AND
    ...            taf.ue.Stop Voice Call        VC_5                                                            AND
    ...            Detach Ues  2                                                                                 AND
    ...            Run Keyword And Ignore Error    collecting_btslog  which_time=5th  log_path=${OUTPUT_DIR}     AND
    ...            TcpdumpSmod.teardown_tcpdump_on_smod                                                          AND
    ...            Clear parameters after PART 5 REDIRECTION


PART_6__B_3__D_3__F_4__F_9__INTRA__gNB__HO
    Next Part Setup
    Set parameters for PART 6 INTRA gNB HO
    starting_btslog  6th
    TcpdumpSmod.start_tcpdump_on_smod    filename=the_6th_call.pcap    smod_master=${true}
    Set attenuation    value_string=90    port=${cell_2_gnb_2_ports}
    Attach Ues  2
    Show Cell ID Before Change
    taf.ue.Start Voice Call    vc_alias=VC_6    ue_alias=UE_1    to=UE_2
    taf.ue.Await Incoming Voice Call    vc_alias=VC_6    ue_alias=UE_2     action=answer    timeout=20s
    BuiltIn.Sleep   90s
    Gradually decrease attenuation    init_value=90   min_value=0   step=5   interval=1   port=${cell_2_gnb_2_ports}
    Gradually increase attenuation    init_value=0   max_value=90   step=5   interval=1   port=${cell_1_gnb_2_ports}
    BuiltIn.Sleep   30s
    Show Cell ID After Change
    collecting_btslog  which_time=6th  log_path=${OUTPUT_DIR}
    ${sixth_call_sctp}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    Move File  ${sixth_call_sctp}  ${OUTPUT_DIR}/source_logs_dir/the_6th_call.pcap
    GnbCounter.wait_for_next_pm_period   interval=${pm_interval_part6}
    Collect Counters For B_3__D_3__F_4__F_9

    [Teardown]     Run Keywords
    ...            taf.ue.Stop Voice Call        VC_6                                                            AND
    ...            Detach Ues  2                                                                                 AND
    ...            Run Keyword And Ignore Error    collecting_btslog  which_time=6th  log_path=${OUTPUT_DIR}     AND
    ...            TcpdumpSmod.teardown_tcpdump_on_smod


PART_7__D_5__F_11__INTER__RAT__HO__From__5G__To__LTE
    #TODO: D_5__F_11__Step 3: Increase radio attenuation of cell#1 to trigger HO based on b2 measurement ->
    #TODO: D_5__F_11__Target cell selected based on b2 report
    #TODO: D_5__F_11__Check RRC RECONFIGURATION with targetPhysCellid = new Pcell (cell#2)
    #TODO: D_5__F_11__HO is successful and data traffic after HO isn?t suspended.
    Next Part Setup
    Set parameters for PART 7 INTER RAT HO
    starting_btslog  7th
    TcpdumpSmod.start_tcpdump_on_smod    filename=the_7th_call.pcap    smod_master=${true}
    Lock Cells   dist_name_list=${cells_dist_names_to_lock}  #TODO: ktore porty konkretnie?
    Attach Ues  2
    taf.ue.Start Voice Call    vc_alias=VC_7    ue_alias=UE_1    to=UE_2
    taf.ue.Await Incoming Voice Call    vc_alias=VC_7    ue_alias=UE_2     action=answer    timeout=20s
    BuiltIn.Sleep   15s
    Gradually increase attenuation    init_value=0   max_value=25   step=2   interval=1   port=${cell_1_gnb_2_ports}
    BuiltIn.Sleep   5s
    collecting_btslog  which_time=7th  log_path=${OUTPUT_DIR}
    ${seventh_call_sctp}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    Move File  ${seventh_call_sctp}  ${OUTPUT_DIR}/source_logs_dir/the_7th_call.pcap
    GnbCounter.wait_for_next_pm_period   interval=${pm_interval}
    Collect Counters For D_5__F_11

    [Teardown]     Run Keywords
    ...            AdminUtils.unlock_all_cells                                                                   AND
    ...            taf.ue.Stop Voice Call        VC_7                                                            AND
    ...            Detach Ues  2                                                                                 AND
    ...            Run Keyword And Ignore Error    collecting_btslog  which_time=7th  log_path=${OUTPUT_DIR}     AND
    ...            TcpdumpSmod.teardown_tcpdump_on_smod                                                          AND
    ...            Clear parameters after PART 7 INTER RAT HO                                                    AND
    ...            Release Attenuator


CB008200-B_1_NG_FLOW_STP_FAIL_FALLBACK_5QI1_incrementation_due_to_voice_fallback_to_LTE
    [Documentation]   Check counter M55125C09519 provided to measure number of 5QI1
                 ...  setup failed due to fallback to LTE when VoNR feature is disabled.

    #TODO:   B_1__F_2__5QI=5 already setup during PDU Session Resource Setup procedure
	Check 5QI Setup   pcap_file=${OUTPUT_DIR}/CB007564_CB008200_FALLBACK_tcpdump_SMOD_MASTER.pcap
	Check IMS Voice EPS Fallback   pcap_file=${OUTPUT_DIR}/CB007564_CB008200_FALLBACK_tcpdump_SMOD_MASTER.pcap
	Check UE Context Release Command Redirection   pcap_file=${OUTPUT_DIR}/CB007564_CB008200_FALLBACK_tcpdump_SMOD_MASTER.pcap
	Check UE Context Release Command Complete   pcap_file=${OUTPUT_DIR}/CB007564_CB008200_FALLBACK_tcpdump_SMOD_MASTER.pcap

    ${counter_ids} =  Create List    M55125C09519
    Verify PM Counters   pm_counters_list=${counter_ids}


CB008200-F_2_NG_FLOW_STP_FAIL_FALLBACK_PMQAP_incrementation_due_to_voice_fallback_to_LTE
    [Documentation]   Check counter M55163C00501 provided to measure number of 5QI1
                 ...  setup failed and when VoNR feature is disabled and fallback to LTE is possible.
                 ...  The Profile counter shall count the only for the configured Profile parameters.

    #TODO:   B_1__F_2__5QI=5 already setup during PDU Session Resource Setup procedure
    Check 5QI Setup   pcap_file=${OUTPUT_DIR}/CB007564_CB008200_FALLBACK_tcpdump_SMOD_MASTER.pcap
	Check IMS Voice EPS Fallback   pcap_file=${OUTPUT_DIR}/CB007564_CB008200_FALLBACK_tcpdump_SMOD_MASTER.pcap
	Check UE Context Release Command Redirection   pcap_file=${OUTPUT_DIR}/CB007564_CB008200_FALLBACK_tcpdump_SMOD_MASTER.pcap
	Check UE Context Release Command Complete   pcap_file=${OUTPUT_DIR}/CB007564_CB008200_FALLBACK_tcpdump_SMOD_MASTER.pcap

    ${counter_ids} =  Create List    M55163C00501
    Verify PM Counters   pm_counters_list=${counter_ids}



CB008200-D_1_NG_FLOW_REL_GNB_REDIRECT_5QI1_incrementation_due_to_redirection_of_Voice_call_to_LTE
    [Documentation]   Check counter M55125C09502 provided to measure number of 5QI1
                 ...  release when A2 measurements for redirection have been configured.
                 ...  UE sends a A2 measurement report and gNB performs RRC Connection Release
                 ...  with redirection information procedure based on the configured target carrier priority
                 ...  at gNB to the LTE cell.

    Check 5QI Setup   pcap_file=${OUTPUT_DIR}/CB007564_CB008200_REDIRECT_tcpdump_SMOD_MASTER.pcap
	Check UE Context Release Command Redirection   pcap_file=${OUTPUT_DIR}/CB007564_CB008200_REDIRECT_tcpdump_SMOD_MASTER.pcap

	GnbCounter.wait_for_next_pm_period   interval=${pm_interval}
    ${counter_ids} =  Create List    M55125C09502
    Verify PM Counters   pm_counters_list=${counter_ids}


CB008200-F_7_NG_FLOW_REL_GNB_REDIRECT_PMQAP_incrementation_due_to_redirection_of_Voice_call_to_LTE
    [Documentation]   Check counter M55163C00503 provided to measure number of 5QI1
                 ...  released for a UE for which A2 measurements for redirection have been configured.
                 ...  UE sends a A2 measurement report and gNB performs RRC Connection Release
                 ...  with redirection information procedure based on the configured target carrier priority
                 ...  at gNB to the LTE cell.
                 ...  The Profile counter shall count the only for the configured Profile parameters.


    Check 5QI Setup   pcap_file=${OUTPUT_DIR}/CB007564_CB008200_REDIRECT_tcpdump_SMOD_MASTER.pcap
	Check UE Context Release Command Redirection   pcap_file=${OUTPUT_DIR}/CB007564_CB008200_REDIRECT_tcpdump_SMOD_MASTER.pcap

	GnbCounter.wait_for_next_pm_period   interval=${pm_interval}
    ${counter_ids} =  Create List    M55163C00503
    Verify PM Counters   pm_counters_list=${counter_ids}


CB008200-B_3_NG_FLOW_STP_ATT_INC_HO_5QI1_and_NG_FLOW_STP_SUC_INC_HO_5QI1_due_to_Intra-gNB_Intra_DU_HO
    [Documentation]   Check counters M55125C09524 and M55125C09525 provided to measure number of 5QI1
                 ...  setup due to incoming Intra-frequency (inter-cell) Intra-DU Intra-gNB handover.

    Check 5qi setup in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_6th_call.pcap

    ${counter_ids} =  Create List    M55125C09524    M55125C09525
    Log to console  ${counter_ids}
    ${counter_dir} =  Make Counter Logs Path  B_3__D_3__F_4__F_9
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  test_specific_keywords_8200.Check If 5QI1 Counters Incremented   ${counter_dir}  ${counter_ids}
    Log  ${relevant_counters}  console=True


CB008200-D_3_NG_FLOW_REL_IANR_SUC_HO_5QI1_incrementation_due_to_Intra-gNB_Intra_DU_HO
    [Documentation]   Check counter M55125C09508 provided to measure number of 5QI1
                 ...  release during Intra-frequency (inter-cell) Intra-DU Intra-gNB handover (outcoming HO).

    Check 5qi setup in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_6th_call.pcap

    ${counter_ids} =  Create List    M55125C09508
    Log to console  ${counter_ids}
    ${counter_dir} =  Make Counter Logs Path  B_3__D_3__F_4__F_9
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  test_specific_keywords_8200.Check If 5QI1 Counters Incremented   ${counter_dir}  ${counter_ids}
    Log  ${relevant_counters}  console=True


CB008200-F_4_NG_FLOW_STP_ATT_INC_HO_PMQAP_and_NG_FLOW_STP_SUC_INC_HO_PMQAP_due_to_Intra-gNB_Intra_DU_HO
    [Documentation]   Check counters M55163C00513 and M55163C00514 provided to measure number of 5QI1
                 ...  setup during Intra-frequency (inter-cell) Intra-DU Intra-gNB handover (incoming HO).
                 ...  The Profile counter shall count the only for the configured Profile parameters.

    Check 5qi setup in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_6th_call.pcap

    ${counter_ids} =  Create List    M55163C00513    M55163C00514
    Log to console  ${counter_ids}
    ${counter_dir} =  Make Counter Logs Path  B_3__D_3__F_4__F_9
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  test_specific_keywords_8200.Check If 5QI1 Counters Incremented   ${counter_dir}  ${counter_ids}
    Log  ${relevant_counters}  console=True


CB008200-F_9_NG_FLOW_REL_IANR_SUC_HO_PMQAP_incrementation_due_to_Intra-gNB_Intra_DU_HO
    [Documentation]   Check counter M55163C00515 provided to measure number of 5QI1
                 ...  released from source cell during outcoming Intra-frequency (inter-cell) Intra-DU Intra-gNB HO.
                 ...  The Profile counter shall count the only for the configured Profile parameters.

    Check 5qi setup in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_6th_call.pcap

    ${counter_ids} =  Create List    M55163C00515
    Log to console  ${counter_ids}
    ${counter_dir} =  Make Counter Logs Path  B_3__D_3__F_4__F_9
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  test_specific_keywords_8200.Check If 5QI1 Counters Incremented   ${counter_dir}  ${counter_ids}
    Log  ${relevant_counters}  console=True


CB008200-D_5_NG_FLOW_REL_IRAT_SUC_HO_5QI1_incrementation_due_to_Inter-RAT_HO_from_5G
    [Documentation]   Check counter M55125C09509 provided to measure number of 5QI1
                 ...  release during Inter-RAT handover from 5G (outcoming HO).

    Check 5qi setup in pcap log       ${OUTPUT_DIR}/source_logs_dir/the_7th_call.pcap
    Check Inter RAT HO in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_7th_call.pcap

    ${counter_ids} =  Create List    M55125C09509
    Log to console  ${counter_ids}
    ${counter_dir} =  Make Counter Logs Path  D_5__F_11
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  test_specific_keywords_8200.Check If 5QI1 Counters Incremented   ${counter_dir}  ${counter_ids}
    Log  ${relevant_counters}  console=True


CB008200-F_11_NG_FLOW_REL_IRAT_SUC_HO_PMQAP_incrementation_due_to_Inter-RAT_HO_from_5G
    [Documentation]   Check counter M55163C00516 provided to measure number of 5QI1
                 ...  released during outcoming Inter-RAT handover from 5G to LTE.
                 ...  The Profile counter shall count the only for the configured Profile parameters.

    Check 5qi setup in pcap log       ${OUTPUT_DIR}/source_logs_dir/the_7th_call.pcap
    Check Inter RAT HO in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_7th_call.pcap

    ${counter_ids} =  Create List    M55163C00516
    Log to console  ${counter_ids}
    ${counter_dir} =  Make Counter Logs Path  D_5__F_11
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  test_specific_keywords_8200.Check If 5QI1 Counters Incremented   ${counter_dir}  ${counter_ids}
    Log  ${relevant_counters}  console=True


CB008200-B_7_NG_FLOW_STP_ATT_RES_IADU_5QI1_and_NG_FLOW_STP_SUC_RES_IADU_5QI1_due_to_reestablishment_to_different_cell_same_gNB
    [Documentation]   Check counters M55125C09531 and M55125C09532 provided to measure number of 5QI1
                 ...  setup during reestablishment to different cell same gNB.

    Check 5qi setup in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_3rd_call.pcap
    ${syslog_result}  ${syslog_msg}  Run Keyword And Ignore Error
    ...  Check Reestablishment In Pcap And Syslog   ${OUTPUT_DIR}/source_logs_dir/the_3rd_call.pcap
    ...                                             ${OUTPUT_DIR}/source_logs_dir/the_3rd_call_btslog

    ${counter_ids} =  Create List    M55125C09531   M55125C09532
    Log to console  ${counter_ids}
    ${counter_dir} =  Make Counter Logs Path  B_7__F_15
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  test_specific_keywords_8200.Check If 5QI1 Counters Incremented   ${counter_dir}  ${counter_ids}
    Log  ${relevant_counters}  console=True

    Run Keyword If  "${syslog_result}"=="FAIL"  Fail


CB008200-F_15_NG_FLOW_STP_ATT_RES_IADU_PMQAP_and_NG_FLOW_STP_SUC_RES_IADU_PMQAP_due_to_reestablishment_to_different_cell_same_gNB
    [Documentation]   Check counters M55163C00530 and M55163C00531 provided to measure number of 5QI1
                 ...  setup during reestablishment to different cell same gNB, acording to the configured Profile.

    Check 5qi setup in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_3rd_call.pcap
    ${syslog_result}  ${syslog_msg}  Run Keyword And Ignore Error
    ...  Check Reestablishment In Pcap And Syslog   ${OUTPUT_DIR}/source_logs_dir/the_3rd_call.pcap
    ...                                             ${OUTPUT_DIR}/source_logs_dir/the_3rd_call_btslog

    ${counter_ids} =  Create List    M55163C00530    M55163C00531
    Log to console  ${counter_ids}
    ${counter_dir} =  Make Counter Logs Path  B_7__F_15
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  test_specific_keywords_8200.Check If 5QI1 Counters Incremented   ${counter_dir}  ${counter_ids}
    Log  ${relevant_counters}  console=True

    Run Keyword If  "${syslog_result}"=="FAIL"  Fail


CB008200-B_6_NG_FLOW_SETUP_ATT_TOT_5QI1_and_NG_FLOW_SETUP_SUCC_TOT_5QI1_due_to_successful_setup_of_VoNR_call
    [Documentation]   Check counters M55125C09517 and M55125C09518 provided to measure number of 5QI1
                 ...  setup check during successful setup of VoNR call.

    Check 5qi setup in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_1st_call.pcap

    ${counter_ids} =  Create List    M55125C09517    M55125C09518
    Log to console  ${counter_ids}
    ${counter_dir} =  Make Counter Logs Path  B_6__E_1__E_3__E_4__F_1
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  test_specific_keywords_8200.Check If 5QI1 Counters Incremented  ${counter_dir}  ${counter_ids}
    Log  ${relevant_counters}  console=True


CB008200-D_2_NG_FLOW_REL_GNB_UE_LOST_5QI1_incrementation_with_gNB_resource_release_due_to_gNB_detected_RLF
    [Documentation]   Check counter M55125C09505 provided to measure number of 5QI1
                 ...  release when Radio Link Failure (RLF) is detected by gNB. The gNB initiate
                 ...  the UE context release procedure over F1 and NG interface and send UE to idle state
                 ...  by initiating the RRC Release procedure.

    Check 5qi setup in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_2nd_call.pcap
    Check RLF in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_2nd_call.pcap

    ${counter_ids} =  Create List    M55125C09505
    Log to console  ${counter_ids}
    ${counter_dir} =  Make Counter Logs Path  D_2__F_8
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  test_specific_keywords_8200.Check If 5QI1 Counters Incremented   ${counter_dir}  ${counter_ids}
    Log  ${relevant_counters}  console=True


CB008200-F_8_NG_FLOW_REL_GNB_RLF_PMQAP_incrementation_with_gNB_resource_release_due_to_gNB_detected_RLF
    [Documentation]   Check counter M55163C00506 provided to measure number of 5QI1
                 ...  released when Radio Link Failure (RLF) is detected by gNB. The gNB initiate
                 ...  the UE context release procedure over F1 and NG interface, and send UE to idle state
                 ...  by initiating the RRC Release procedure.
                 ...  The Profile counter shall count the only for the configured Profile parameters.

    Check 5qi setup in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_2nd_call.pcap
    Check RLF in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_2nd_call.pcap

    ${counter_ids} =  Create List    M55163C00506
    ${counter_dir} =  Make Counter Logs Path  D_2__F_8
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  test_specific_keywords_8200.Check If 5QI1 Counters Incremented   ${counter_dir}  ${counter_ids}
    Log  ${relevant_counters}  console=True


CB008200-D_7_NG_FLOW_REL_NORMAL_5QI1_incrementation_due_to_release_with_normal_cause
    [Documentation]   Check counter M55125C09514 provided to measure number of 5QI1
                 ...  release with normal cause.

    Check 5qi release in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_1st_stop_call.pcap

    ${counter_ids} =  Create List    M55125C09514
    ${counter_dir} =  Make Counter Logs Path  D_7__D_8__E_2__F_14
    Log to console  ${counter_ids}
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  test_specific_keywords_8200.Check If 5QI1 Counters Incremented  ${counter_dir}  ${counter_ids}
    Log  ${relevant_counters}  console=True


CB008200-D_8_NG_FLOW_SESSION_DUR_NORM_5QI1_incrementation_during_VoNR_call
    [Documentation]   Check counter M55125C09526 provided to measure number of 5QI1
                 ...  is successfully setup and then released with normal cause.

    Check 5qi release in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_1st_stop_call.pcap

    ${counter_ids} =  Create List    M55125C09526
    ${counter_dir} =  Make Counter Logs Path  D_7__D_8__E_2__F_14
    Log to console  ${counter_ids}
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  Check If 5QI1 Counters Show Proper Call Duration  ${counter_dir}  ${counter_ids}  ${CALL_DURATION}
    Log  ${relevant_counters}  console=True


CB008200-E_1_AVE_NUMBER_OF_UE_5QI1_incrementation_due_to_successful_5QI1_setup
    [Documentation]   Check counter M55125C09528 provided to measure average number of UE with 5QI1,
                 ...  connected to the same cell. Also check AVE_NUMBER_OF_UE_5QI1_DENOM (M55125C09529)
                 ...  incremented every second of period (e.g. 5 minutes makes value of 300)

    Check 5qi setup in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_1st_call.pcap

    ${counter_ids} =  Create List    M55125C09528    M55125C09529
    ${counter_dir} =  Make Counter Logs Path  B_6__E_1__E_3__E_4__F_1
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  test_specific_keywords_8200.Check If 5QI1 Counters Incremented   ${counter_dir}  ${counter_ids}
    Log  ${relevant_counters}  console=True


CB008200-E_2_PEAK_NUMBER_OF_UE_5QI1_incrementation_due_to_successful_5QI1_setup
    [Documentation]   Check counter M55125C09530 provided to measure peak number of UE?s with 5QI1
                 ...  when 5QI1 is successfully setup

    Check 5qi release in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_1st_stop_call.pcap

    ${counter_ids} =  Create List    M55125C09530
    ${counter_dir} =  Make Counter Logs Path  D_7__D_8__E_2__F_14
    Log to console  ${counter_ids}
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  test_specific_keywords_8200.Check If 5QI1 Counters Incremented  ${counter_dir}  ${counter_ids}
    Log  ${relevant_counters}  console=True


CB008200-F_14_NG_FLOW_CON_SESSION_TIME_PMQAP_incrementation_due_to_duration_of_session
    [Documentation]   Check counter M55163C00521 measuring 5QI1 session duration and counter incrementation
                 ...  when 5QI1 is successfully setup and then released with normal cause.
                 ...  also check NG_FLOW_CONNECTED_SESSION_TIME (M55125C09516) incremented by cumulated duration of all QoS Flow

    Check 5qi release in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_1st_stop_call.pcap

    ${counter_ids_1} =  Create List    M55163C00521
    ${counter_ids_2} =  Create List    M55125C09516
    ${counter_dir} =  Make Counter Logs Path  D_7__D_8__E_2__F_14

    Log to console  ${counter_ids_1}
    ${value_dict_1} =  Create Dictionary  name=value
    ${value_dict_1} =  Check If 5QI1 Counters Show Proper Call Duration  ${counter_dir}  ${counter_ids_1}  ${CALL_DURATION}
    Log  ${value_dict_1}  console=True

    Log to console  ${counter_ids_2}
    ${value_dict_2} =  Create Dictionary  name=value
    ${value_dict_2} =  Check If 5QI1 Counters Show Proper Call Duration  ${counter_dir}  ${counter_ids_2}  ${CUMULATED_DURATION_OF_ALL_SESSIONS}
    Log  ${value_dict_2}  console=True


CB008200-E_3_ACC_UE_DL_DRB_DATA_5QI1_and_ACC_UE_UL_DRB_DATA_5QI1_incrementation_due_to_UE_with_data_buffered_associated_to_5QI1
    [Documentation]   Check counters M55308C32000 and M55308C32001 provided to measure number of UE?s
                 ...  with 5QI1 data buffered in DL and UL DRB when VoNR call is successfully setup
                 ...  by comparing results with those from:
                 ...  ACC_UE_DL_DRB_DATA (M55308C02000) and ACC_UE_UL_DRB_DATA (M55308C02002)

    Check 5qi setup in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_1st_call.pcap

    ${counter_dir} =  Make Counter Logs Path  B_6__E_1__E_3__E_4__F_1

    ${dl_counter_ids} =  Create List   M55308C32000    M55308C02000
    ${dl_value_dict} =  Create Dictionary  name=value
    ${dl_value_dict} =  Check If 5QI1 Counters Work Same E3 E4   ${counter_dir}  ${dl_counter_ids}
    Log  ${dl_value_dict}  console=True

    ${ul_counter_ids} =  Create List   M55308C32001    M55308C02002
    ${ul_value_dict} =  Create Dictionary  name=value
    ${dl_value_dict} =  Check If 5QI1 Counters Work Same E3 E4   ${counter_dir}  ${dl_counter_ids}
    Log  ${ul_value_dict}  console=True


CB008200-E_4_ACC_UE_DL_DRB_DATA_PMQAP_and_ACC_UE_UL_DRB_DATA_PMQAP_incrementation_due_to_UE_with_data_buffered_associated_to_5QI1
    [Documentation]   Check counters M55356C00000 and M55356C00001 provided to measure number of UE?s, associated
                 ...  with PMQAP profile, with data buffered in DL and UL DRB when VoNR call is successfully setup
                 ...  by comparing results with those from:
                 ...  ACC_UE_DL_DRB_DATA (M55308C02000) and ACC_UE_UL_DRB_DATA (M55308C02002)
                 ...  The Profile counter shall count the only for the configured Profile parameters.

    Check 5qi setup in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_1st_call.pcap

    ${counter_dir} =  Make Counter Logs Path  B_6__E_1__E_3__E_4__F_1

    ${dl_counter_ids} =  Create List   M55356C00000    M55308C02000
    ${dl_value_dict} =  Create Dictionary  name=value
    ${dl_value_dict} =  Check If 5QI1 Counters Work Same E3 E4   ${counter_dir}  ${dl_counter_ids}
    Log  ${dl_value_dict}  console=True

    ${ul_counter_ids} =  Create List   M55356C00001    M55308C02002
    ${ul_value_dict} =  Create Dictionary  name=value
    ${dl_value_dict} =  Check If 5QI1 Counters Work Same E3 E4   ${counter_dir}  ${dl_counter_ids}
    Log  ${ul_value_dict}  console=True


CB008200-F_1_MAX_UE_DL_DRB_DATA_PMQAP_and_MAX_UE_UL_DRB_DATA_PMQAP_incrementation_due_to_UE_with_data_buffered
    [Documentation]   Check counters M55356C00002 and M55356C00003 provided to measure number of UE?s with buffered
                 ...  data when VoNR call is successfully setup and voice data is sent in both directions.
                 ...  The Profile counter shall count the only for the configured Profile parameters.

    Check 5qi setup in pcap log    ${OUTPUT_DIR}/source_logs_dir/the_1st_call.pcap

    ${counter_dir} =  Make Counter Logs Path  B_6__E_1__E_3__E_4__F_1
    ${counter_ids} =  Create List    M55356C00002    M55356C00003
    Log to console  ${counter_ids}
    ${relevant_counters} =  Create Dictionary  name=value
    ${relevant_counters} =  test_specific_keywords_8200.Check If 5QI1 Counters Incremented  ${counter_dir}  ${counter_ids}
    Log  ${relevant_counters}  console=True

*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the ROBOT KEYWORDS file for ROHC-A

Library          taf.ue
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py    WITH NAME    774_A_btslog
Library          testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/ue_logs/ue_logs.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000774/A/resources/test_specific_keywords_A.py
Variables        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000774/A/resources/test_specific_keywords_A.py
Library          taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library          testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils   WITH NAME   AdminUtils
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/pm_counters.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot

*** Variables ***
${PM_INTERVAL}                     5
@{COUNTER_ID}  M55125C09517    M55125C09518    M55356C00001    M55308C32001    M55356C00000    M55308C32000
${CELL_NOT_LOCKED}                 1

*** Keywords ***
5GC000774_A_01_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD
    Setup and check preconditions in scf   params_to_check=${scf_params_rohc_a}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    Perform and Check Simple VoNR call


5GC000774_A_03_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_FDD_with_maxCidAllowed=1
    Setup and check preconditions in scf   params_to_check=${scf_params_rohc_maxCid_1}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    Perform and Check Simple VoNR call


5GC000774_A_04_Successful_setup_of_Voice_over_NR_call_with_ROHC_enabled_with_IPv4_with_TDD_with_maxCidAllowed=1
    Setup and check preconditions in scf   params_to_check=${scf_params_rohc_maxCid_1}    bandwidth=20    skip_parameter_relation_errors=${true}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    Perform and Check Simple VoNR call


5GC000774_A_05_Successful_Intra-frequency_Intra-DU_Intra-gNB_VoNR_handover_for_5QI-1_DRB_with_ROHC_enabled_with_FDD
    Setup and check preconditions in scf   params_to_check=${scf_params_rohc_a}    bandwidth=20    skip_parameter_relation_errors=${true}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    Perform Intra HO
    Check intra handover vonr    log_path=/tmp/btslog2


5GC000774_A_08_Successful_Intra-frequency_Inter-gNB_VoNR_handover_for_5QI-1_DRB_with_ROHC_enabled_with_FDD
    Setup and check preconditions in scf   params_to_check=${scf_params_rohc_a}    bandwidth=20    skip_parameter_relation_errors=${true}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    774_A_btslog.start_btslog_on_local_machine     log_name=interGNB_HO_SOURCE
    774_A_btslog.start_btslog_on_remote_machine    log_name=interGNB_HO_TARGET    host=None    user=ute    password=ute
    Perform Inter HO
    ${source_logs_dir}=    774_A_btslog.stop_and_collect_btslog           log_name=interGNB_HO_SOURCE
    ${target_logs_dir}=    774_A_btslog.stop_and_collect_btslog           log_name=interGNB_HO_TARGET

    Check inter handover vonr    log_path=${target_logs_dir}


5GC000774_A_09_Successful_Intra-frequency_Inter-gNB_VoNR_handover_for_5QI-1_DRB_with_ROHC_enabled_with_maxCidAllowed_change_from_1_to_2
    Setup and check preconditions in scf   params_to_check=${scf_params_rohc_maxCid_1}    bandwidth=20    skip_parameter_relation_errors=${true}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
#    Setup remote BTS
    774_A_btslog.start_btslog_on_local_machine     log_name=interGNB_HO_SOURCE
    774_A_btslog.start_btslog_on_remote_machine    log_name=interGNB_HO_TARGET    host=None    user=ute    password=ute
    Perform Inter HO
    ${source_logs_dir}=    774_A_btslog.stop_and_collect_btslog           log_name=interGNB_HO_SOURCE
    ${target_logs_dir}=    774_A_btslog.stop_and_collect_btslog           log_name=interGNB_HO_TARGET

    check_inter_handover_max_cid_allowed_changed_1_to_2    ${source_logs_dir}    ${target_logs_dir}


5GC000774_A_10_Successful_Intra-frequency_Inter-gNB_VoNR_handover_for_5QI-1_DRB_with_ROHC_enabled_with_maxCidAllowed_change_from_2_to_1
    Setup and check preconditions in scf   params_to_check=${scf_params_rohc_a}    bandwidth=20    skip_parameter_relation_errors=${true}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
#    Setup remote BTS
    774_A_btslog.start_btslog_on_local_machine     log_name=interGNB_HO_SOURCE
    774_A_btslog.start_btslog_on_remote_machine    log_name=interGNB_HO_TARGET    host=None    user=ute    password=ute
    Perform Inter HO
    ${source_logs_dir}=    774_A_btslog.stop_and_collect_btslog           log_name=interGNB_HO_SOURCE
    ${target_logs_dir}=    774_A_btslog.stop_and_collect_btslog           log_name=interGNB_HO_TARGET

    check_inter_handover_max_cid_allowed_changed_2_to_1    ${source_logs_dir}    ${target_logs_dir}


5GC000774_A_14_Successful_setup_of_Emergency_(voice)_call_on_top_of_an_existing_VoNR_call_with_ROHC_enabled_FDD
    Setup and check preconditions in scf   params_to_check=${scf_params_rohc_a}    bandwidth=20    skip_parameter_relation_errors=${true}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    Perform and Check Call Over Call With ROHC Compression


Perform and Check Call Over Call With ROHC Compression
    Require Ue   UE_1   capabilities=REAL_UE_SA
    Require Ue   UE_2   capabilities=REAL_UE_SA

    Attach Ue    UE_1
    Attach Ue    UE_2

    Start UE logging    filename=VoNR_ue_log    duration=50
    774_A_btslog.start_btslog_on_local_machine     log_name=first_call_btslog

    taf.ue.Start voice call    vc_alias=VC_1    ue_alias=UE_1    to=UE_2
    taf.ue.Await Incoming Voice Call     vc_alias=VC_1    ue_alias=UE_2    action=answer    timeout=20s
    BuiltIn.Sleep   50s
    ${ue_log_path}=    Stop UE logging    filename=VoNR_ue_log
    ${first_call_btslog_dir}=    774_A_btslog.stop_and_collect_btslog           log_name=first_call_btslog
    Check gNB Side ROHC Decompressor    log_path=${first_call_btslog_dir}
    Check UE Side ROHC Decompressor     ${ue_log_path}


#    TODO: PERFORM EMERGENCY CALL OVER CALL
    Start UE logging    filename=VoNR_emergency_call_over_call
    774_A_btslog.start_btslog_on_local_machine     log_name=VoNR_emergency_call_over_call
    BuiltIn.Sleep   15s
    ${ue_log_path}=    Stop UE logging    filename=VoNR_emergency_call_over_call
    ${second_call_btslog_dir}=    774_A_btslog.stop_and_collect_btslog           log_name=VoNR_emergency_call_over_call
    Check gNB Side ROHC Decompressor    log_path=${second_call_btslog_dir}
    Check UE Side ROHC Decompressor     ${ue_log_path}


Perform and Check Simple VoNR call
    Require Ue   UE_1   capabilities=REAL_UE_SA
    Require Ue   UE_2   capabilities=REAL_UE_SA
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${CELL_NOT_LOCKED}
    Attach Ue    UE_1
    Attach Ue    UE_2
    774_A_btslog.start_btslog_on_local_machine     log_name=first_call_btslog
    GnbCounter.wait_for_next_pm_period   interval=${PM_INTERVAL}
    taf.ue.Start voice call    vc_alias=VC_1    ue_alias=UE_1    to=UE_2
    taf.ue.Await Incoming Voice Call     vc_alias=VC_1    ue_alias=UE_2    action=answer    timeout=20s
    BuiltIn.Sleep   10s
    Stop call
    ${first_call_btslog_dir}=    774_A_btslog.stop_and_collect_btslog           log_name=first_call_btslog
    GnbCounter.wait_for_next_pm_period   interval=${PM_INTERVAL}
    ${counter_dir}   keywords_774_A.Collect Counters For Voice    A1
    ${counters}  Get and verify counters  ${counter_dir}  ${COUNTER_ID}
    check_Voice_Counters_incremented    ${counters}
    Verify_counter_8200     ${counters}   1    M55356C00001    M55308C32001    M55356C00000    M55308C32000
    Check gNB Side ROHC Decompressor    log_path=${first_call_btslog_dir}

Perform Intra HO
    Require Ue   UE_1   capabilities=REAL_UE_SA
    Require Ue   UE_2   capabilities=REAL_UE_SA

    Attach Ue    UE_1
    Attach Ue    UE_2

    taf.ue.Start voice call    vc_alias=VC_1    ue_alias=UE_1    to=UE_2
    taf.ue.Await Incoming Voice Call     vc_alias=VC_1    ue_alias=UE_2    action=answer    timeout=20s
    BuiltIn.Sleep   10s
    Gradually increase attenuation      init_value=0    max_value=25    step=2    interval=1    port=${cell_2_gnb_1_ports}
    BuiltIn.Sleep   5s


Perform Inter HO
    Require Ue   UE_1   capabilities=REAL_UE_SA
    Require Ue   UE_2   capabilities=REAL_UE_SA

    Attach Ue    UE_1
    Attach Ue    UE_2

    taf.ue.Start voice call    vc_alias=VC_1    ue_alias=UE_1    to=UE_2
    taf.ue.Await Incoming Voice Call     vc_alias=VC_1    ue_alias=UE_2    action=answer    timeout=20s
    BuiltIn.Sleep   10s
    Gradually increase attenuation      init_value=0    max_value=25    step=2    interval=1    port=${cell_1_gnb_2_ports}
    BuiltIn.Sleep   5s

Collect Counters For Voice
    [Arguments]    ${test_cases}
    ${pi_dir} =   Collect Counters    log_name=${test_cases}  target_dir=${OUTPUT DIR}/counters
    Log  ${pi_dir}  console=True
    [Return]  ${pi_dir}

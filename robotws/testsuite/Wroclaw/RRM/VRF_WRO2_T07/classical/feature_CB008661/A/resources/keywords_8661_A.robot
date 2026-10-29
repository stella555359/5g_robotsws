*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the ROBOT KEYWORDS file for CB008661_A

Library            taf.ue
Library            testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod    WITH NAME    TcpdumpSmod
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_lte.TcpdumpLte      WITH NAME    TcpdumpLte
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils         WITH NAME    AdminUtils
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008661/A/resources/test_specific_keywords.py   WITH NAME    keywords_8661_A
Variables          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008661/A/resources/test_specific_keywords.py
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py


*** Variables ***
${SA_UE_CAPS_A}=                    REAL_UE_SA
${SA_PING_UE_CAPS}=                 REAL_UE_SA_PING
${SA_HO_UE_A}=                      REAL_UE_SA_HO
${NSA_UE_CAPS_A}=                   REAL_UE_NSA
${WAIT_FOR_SCTP_LOGS}=              8s
${UE_SERIAL_NUMBER}=                ${tl.ues[${UE_IDX}].serial_number}
${PING_COUNT}=                      100
${PACKET_SIZE_HIGH}=                1350
${PACKET_SIZE_LOW}=                 32
${UE_IDX}=                          0
${CORE_IP}=                         ${tl.ues[${UE_IDX}].iperf_details.network_interface_address}
${PING_DELAY_THRESHOLD}=            100
${MAX_ATTEN}=                       50


*** Keywords ***
CB008661-A_1_Unscheduled_ping_latency_for_FDD_FR1_for_feature_5GC000836__SA
    Setup and check preconditions in scf    params_to_check=${scf_params_a1}
    Perform ping test scenario    ${PING_COUNT}   ${PACKET_SIZE_LOW}   ${PACKET_SIZE_HIGH}   ${PING_DELAY_THRESHOLD}


CB008661-A_2_Scheduled_ping_latency_for_FDD_FR1_for_feature_5GC000836_SA
    Setup and check preconditions in scf    params_to_check=${scf_params_a2}
    Perform ping test scenario    ${PING_COUNT}   ${PACKET_SIZE_LOW}   ${PACKET_SIZE_HIGH}   ${PING_DELAY_THRESHOLD}


CB008661-A_3_Unscheduled_ping_latency_for_FDD_FR1_5GC000836_actAdaptiveSr_TRUE_srPeriodicityMin_5slots_SA
    Setup and check preconditions in scf    params_to_check=${scf_params_a3}
    Perform ping test scenario    ${PING_COUNT}   ${PACKET_SIZE_LOW}   ${PACKET_SIZE_HIGH}   ${PING_DELAY_THRESHOLD}


CB008661-A_4_Scheduled_ping_latency_for_FDD_FR1_5GC000836_actUlTxSkip_TRUE_ulProGrantTimerTxSkip_1000ms_SA
    Setup and check preconditions in scf    params_to_check=${scf_params_a4}
    Perform ping test scenario    ${PING_COUNT}   ${PACKET_SIZE_LOW}   ${PACKET_SIZE_HIGH}   ${PING_DELAY_THRESHOLD}


Perform ping test scenario
    [Arguments]   ${count}   ${packet_size_low}   ${packet_size_high}   ${ping_delay_threshold}
    Require UE   UE_1   capabilities=${SA_PING_UE_CAPS}

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UE    UE_1
    Sleep   ${WAIT_FOR_SCTP_LOGS}
    ${sctp_logs}=        TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    ${rntis}=   find_exactly_x_attached_rntis     ${sctp_logs}   1
    perform_ping_test_on_ue   ${UE_SERIAL_NUMBER}   ${count}   ${packet_size_low}    ${CORE_IP}   ${ping_delay_threshold}
    perform_ping_test_on_ue   ${UE_SERIAL_NUMBER}   ${count}   ${packet_size_high}   ${CORE_IP}   ${ping_delay_threshold}


CB008661_A_5__Call_setup_Call_release_latency_for_NSA
    Setup and check preconditions in scf    params_to_check=${scf_params_a5}
    Require UE   UE_1   capabilities=${NSA_UE_CAPS_A}

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${tl.smod_slave}
    TcpdumpLte.start_tcpdump_on_lte      filename=${test_name}_L3_call
    Attach UE    UE_1
    Detach UE    UE_1
    Sleep   ${WAIT_FOR_SCTP_LOGS}
    ${sctp_logs_lte}=    TcpdumpLte.stop_tcpdump_and_download_logs_from_lte
    ${sctp_logs}=        TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    ${rntis}=   find_exactly_x_attached_rntis     ${sctp_logs}   1
    analyze_call_setup_and_release_latency_nsa    ${sctp_logs}


CB008661_A_6__Call_setup_Call_release_latency_for_SA
    Setup and check preconditions in scf    params_to_check=${scf_params_a6}
    Require UE   UE_1   capabilities=${SA_UE_CAPS_A}

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UE    UE_1
    Detach UE    UE_1
    Sleep   ${WAIT_FOR_SCTP_LOGS}
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    ${rntis}=   find_exactly_x_attached_rntis    ${sctp_logs}   1
    analyze_call_setup_and_release_latency_sa    ${sctp_logs}


CB008661_A_7__VoNR_Call_setup_call_release_latency_for_SA
    Setup and check preconditions in scf    params_to_check=${scf_params_a7}
    Require UE   UE_1   capabilities=${SA_UE_CAPS_A}

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call       smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UE    UE_1
    Sleep   ${WAIT_FOR_SCTP_LOGS}
    ${sctp_logs_attach}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_VoNR_START    smod_master=${true}    smod_slave=${tl.smod_slave}
    Perform call to autoresponder   vc_alias=VC_1   ue_alias=UE_1
    Sleep   ${WAIT_FOR_SCTP_LOGS}
    ${sctp_logs_vonr_start}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_VoNR_STOP    smod_master=${true}    smod_slave=${tl.smod_slave}
    taf.ue.Stop voice call    vc_alias=VC_1
    Sleep   ${WAIT_FOR_SCTP_LOGS}
    ${sctp_logs_vonr_stop}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    analyze_latency_of_vonr_call   ${sctp_logs_vonr_start}     ${sctp_logs_vonr_stop}


CB008661_A_11_SA_Voice_call_handover_interruption_time
    Setup and check preconditions in scf    params_to_check=${scf_params_a11}
    set_attenuation   value_string=${MAX_ATTEN}    port=${tl.ho_target_ports}
    Require UE   UE_1   capabilities=${SA_HO_UE_A}

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call       smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UE    UE_1
    Sleep   ${WAIT_FOR_SCTP_LOGS}
    ${sctp_logs_attach}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Perform call to autoresponder   vc_alias=VC_1   ue_alias=UE_1

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_HO    smod_master=${true}    smod_slave=${tl.smod_slave}
    Perform handover for 8661_A_11
    Sleep   ${WAIT_FOR_SCTP_LOGS}
    ${sctp_logs_ho}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    taf.ue.Stop voice call    vc_alias=VC_1

    analyze_ho_with_vonr_interruption_time   ${sctp_logs_ho}


Perform call to autoresponder
    [Arguments]   ${vc_alias}   ${ue_alias}
    ${auto_responder_number}=     Set variable   +555800903300998
    taf.ue.Start voice call      vc_alias=${vc_alias}    ue_alias=${ue_alias}    to=${auto_responder_number}


Perform handover for 8661_A_11
#    gradually_increase_attenuation   init_value=0   max_value=10   step=1   interval=0.2   port=${tl.ho_source_ports}
    set_attenuation   value_string=${MAX_ATTEN}    port=${tl.ho_source_ports}
    set_attenuation   value_string=0               port=${tl.ho_target_ports}


TC_teardown_8661_A
    Detach UE   UE_1
    TcpdumpSmod.teardown_tcpdump_on_smod


TC_teardown_8661_A_11
    Detach UE   UE_1
    TcpdumpSmod.teardown_tcpdump_on_smod
    nullify_attenuation_on_all_ports

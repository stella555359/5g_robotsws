*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the ROBOT KEYWORDS file for CB008238_W

Library            taf.ue
Library            testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod    WITH NAME    TcpdumpSmod
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils         WITH NAME    AdminUtils
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore.DeltaStore          WITH NAME    DeltaStore
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/W/resources/test_specific_keywords.py   WITH NAME    keywords_8238_W
Variables          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/W/resources/test_specific_keywords.py
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py


*** Variables ***
${SA_PING_UE_CAPS_W}=               REAL_UE_SA_PING
${DL_TPUT_W}=                       12Mbits/sec
${PACING_TIMER_W}=                  20000
${PING_COUNT}=                      100
${PING_PACKET_SIZE}=                1350
${WAIT_FOR_SCTP_LOGS}=              8s
${CELL_ID_CB008238}=                1
${BTS_ID}=                          ${tl.gnbs[0].global_bts_id}
${NRBTS_DIST_NAME}=                 MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
${NRCELL_DIST_NAME}=                ${NRBTS_DIST_NAME}/NRCELL-${CELL_ID_CB008238}
${UE_IDX}=                          0
${UE_SERIAL_NUMBER}=                ${tl.ues[${UE_IDX}].serial_number}
${CORE_IP}=                         ${tl.ues[${UE_IDX}].data_transfer[0].app_server.bind_interface_ip}
${PING_DELAY_THRESHOLD}=            70


*** Keywords ***
CB008238-5G-W_4_Single_UE_Ping_latency_Check_SA_mode
    Require UE   UE_1   capabilities=${SA_PING_UE_CAPS_W}
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${CELL_ID_CB008238}
    Deactivate micro DTX and optimized scheduler for 8238_W
    Perform ping test scenario for 8238_W   ${PING_COUNT}   ${PING_PACKET_SIZE}   ${PING_DELAY_THRESHOLD}
    Activate micro DTX and optimized scheduler for 8238_W
    Perform ping test scenario for 8238_W   ${PING_COUNT}   ${PING_PACKET_SIZE}   ${PING_DELAY_THRESHOLD}


Perform ping test scenario for 8238_W
    [Arguments]   ${ping_count}   ${ping_packet_size}   ${ping_delay_threshold}

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UE    UE_1
    BuiltIn.Sleep   ${WAIT_FOR_SCTP_LOGS}
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                    direction=dl       duration=130s
    ...                   packet_size=1200            throughput=${DL_TPUT_W}          protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER_W}
    BuiltIn.Sleep    30s

    ${rntis}=   find_exactly_x_attached_rntis    ${sctp_logs}   1
    perform_ping_latency_test_for_8238   ${UE_SERIAL_NUMBER}   ${ping_count}   ${ping_packet_size}    ${CORE_IP}   ${ping_delay_threshold}
    Stop data transfer   dt_name=DT_DL
    Detach UE    UE_1


Activate micro DTX and optimized scheduler for 8238_W
    Log   Start delta commissioning...    console=True
    activate_micro_dtx_and_optimized_scheduler_specific_version_w   nr_delta   ${NRBTS_DIST_NAME}   ${NRCELL_DIST_NAME}
    Log   Delta commissioning finished successfully!    console=True


Deactivate micro DTX and optimized scheduler for 8238_W
    Log   Start delta commissioning...    console=True
    DeltaStore.initialise_delta_store         name=nr_delta
    DeltaStore.add_parameters_to_delta       ${NRBTS_DIST_NAME}     actMicroDTX=false
    DeltaStore.add_parameters_to_delta       ${NRCELL_DIST_NAME}    actDtxOptimizedScheduler=false

    ${delta_store}=    DeltaStore.collect_delta_store
    DeltaStore.perform_delta_recommissioning    ${delta_store}
    Log   Delta commissioning finished successfully!    console=True


TC_teardown_W
    Detach UE   UE_1
    TcpdumpSmod.teardown_tcpdump_on_smod
    AdminUtils.unlock_all_cells

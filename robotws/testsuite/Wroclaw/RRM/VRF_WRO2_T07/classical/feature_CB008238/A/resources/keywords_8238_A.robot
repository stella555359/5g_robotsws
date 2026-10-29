*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the ROBOT KEYWORDS file for CB008238_A

Library            taf.ue
Library            String
Library            OperatingSystem
Library            taf.transport.ssh   WITH NAME    taf_ssh
Library            testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod    WITH NAME    TcpdumpSmod
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/connections.py   WITH NAME   wro_6_connections
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils         WITH NAME    AdminUtils
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py   WITH NAME   TTI
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/A/resources/test_specific_keywords.py   WITH NAME   keywords_8238_A
Variables          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/A/resources/test_specific_keywords.py
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore.DeltaStore   WITH NAME   DeltaStore
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py


*** Variables ***
${DL_TPUT_LOWER}=                   20Mbits/sec
${DL_TPUT_HIGHER}=                  30Mbits/sec
${PACING_TIMER_LOWER}=              9000
${PACING_TIMER_HIGHER}=             40000
${BTS_ID}=                          ${tl.gnbs[0].global_bts_id}
${CELL_ID_CB008238}=                1
${RMOD_ID}=                         1   # ID of RMOD on SMOD, to which the call is made (starts at 0)
${RMOD_SN}=                         ${tl.gnbs[0].dus[0].rus[${RMOD_ID}].serial_number}
${NRBTS_DIST_NAME}=                 MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
${NRCELL_DIST_NAME}=                ${NRBTS_DIST_NAME}/NRCELL-${CELL_ID_CB008238}
${TTI_COLLECTION_TIME}=             15s
${SA_UE_CAPS}=                      REAL_UE_SA
${NSA_UE_CAPS}=                     REAL_UE_NSA
${BTS_USER}=                        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${BTS_IP}=                          ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${BTS_PASSWD}=                      ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${RMOD_PASSWD}=                     ${BTS_PASSWD}
${RMOD_USERNAME}=                   root


*** Keywords ***
CB008238_A_03_Single-UE_small_packet_timer_lower_than_dtxMaxRetentionDelay_on_NSA
    Require UE   UE_1   capabilities=${NSA_UE_CAPS}
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${CELL_ID_CB008238}
    Check TTI logs and radio power consumption for 8238_A   sctp_filename=L3_call_NSA            dl_tput=${DL_TPUT_LOWER}
    ...                                                     pacing_timer=${PACING_TIMER_LOWER}   condition=LOWER


CB008238_A_09_Single-UE_small_packet_timer_higher_than_dtxMaxRetentionDelay_on_NSA+SA (SA)
    Require UE   UE_1   capabilities=${SA_UE_CAPS}
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${CELL_ID_CB008238}
    Check TTI logs and radio power consumption for 8238_A   sctp_filename=L3_call_SA              dl_tput=${DL_TPUT_HIGHER}
    ...                                                     pacing_timer=${PACING_TIMER_HIGHER}   condition=HIGHER


Check TTI logs and radio power consumption for 8238_A
    [Arguments]   ${sctp_filename}   ${dl_tput}   ${pacing_timer}   ${condition}
    ${power_without_feature}=    Get power consumption before feature   ${dl_tput}   ${pacing_timer}

    Activate micro DTX and optimized scheduler for 8238_A
    ${sctp_logs}=    Attach UE and start traffic 8238_A   ${sctp_filename}   ${dl_tput}   ${pacing_timer}
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep    ${TTI_COLLECTION_TIME}
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode

    BuiltIn.Sleep  20s

    ${power_with_feature}=  RMOD power measurement  ${RMOD_SN}
    Stop data transfer   dt_name=DT_DL

    ${attached_rntis}=    find_exactly_x_attached_rntis    ${sctp_logs}   1
    check_highest_class_prio_for_optimized_dtx    ${tti_file_path}    ${attached_rntis}
    evaluate_power_consumption_benefit   ${power_without_feature}    ${power_with_feature}    ${condition}
    Deactivate micro DTX and optimized scheduler for 8238_A


Get power consumption before feature
    [Arguments]   ${dl_tput}   ${pacing_timer}
    Deactivate only optimized DTX scheduler for 8238_A
    ${sctp_logs}=    Attach UE and start traffic 8238_A   sctp_filename=L3_call    dl_tput=${dl_tput}    pacing_timer=${pacing_timer}

    ${power_without_feature}=   RMOD power measurement   ${RMOD_SN}
    Stop data transfer   dt_name=DT_DL
    Detach UE    UE_1

    [Return]   ${power_without_feature}


Attach UE and start traffic 8238_A
    [Arguments]   ${sctp_filename}   ${dl_tput}   ${pacing_timer}
    TcpdumpSmod.start_tcpdump_on_smod    filename=${sctp_filename}    smod_master=${true}    smod_slave=${false}
    Attach UE    UE_1
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                   direction=dl       duration=330s
    ...                   packet_size=1200            throughput=${dl_tput}           protocol=udp
    ...                   iperf_version=3             pacing_timer=${pacing_timer}
    BuiltIn.Sleep    10s
    check_data_transfer_is_alive    dt_name=DT_DL
    Verify average throughput    dt_name=DT_DL    tput_min=1Mbits/sec

    [Return]   ${sctp_logs}


RMOD power measurement
    [Arguments]   ${rmod_sn}   ${number_of_measurements}=300    ${interval_between_measurements}=1s
    ${smod_connection}=    wro_6_connections.connect_to_smod
    ${cmd}   taf_ssh.execute   command=cat /rom/config/FRIps.txt   connection=${smod_connection}
    ${rmod_ip}=       get_relevant_rmod_ip_from_smod   ${cmd}   ${rmod_sn}
    ${rmod_connection}=   wro_6_connections.connect_to_ru                ru_ip=${rmod_ip}
    ...                                                                  username=${RMOD_USERNAME}
    ...                                                                  password=${RMOD_PASSWD}
    ...                                                                  proxy=${smod_connection}
    ...                                                                  connection=ru
    taf_ssh.execute  echo "/ action create PsuMeasurements /psu /module"|frmonShellClient 127.0.0.1 2000    connection=${rmod_connection}
    taf_ssh.execute  echo "/psu get power_support"|frmonShellClient 127.0.0.1 2000    connection=${rmod_connection}

    ${power_measurement}=   Set variable    ${0}
    FOR   ${idx}  IN RANGE  ${number_of_measurements}
       ${output}=     taf_ssh.execute      echo "/psu action measure"|frmonShellClient 127.0.0.1 2000    connection=${rmod_connection}
       @{measure}=    Split string     ${output}
       ${power}=      Convert to number  ${measure[-3]}    2
       Log   Measurement_${idx} >> ${power}W
       ${power_measurement}=     Evaluate  ${power_measurement} + ${power}
       BuiltIn.Sleep   ${interval_between_measurements}
    END

    ${average}=    Evaluate   ${power_measurement} / ${number_of_measurements}
    ${average_measurement}=    Convert to number   ${average}    0
    Log    Avg_power: ${average_measurement}    console=True

    [Teardown]   wro_6_connections.disconnect   ${rmod_connection}
    [Return]    ${average_measurement}


Activate micro DTX and optimized scheduler for 8238_A
    Log   Start delta commissioning...    console=True
    activate_micro_dtx_and_optimized_scheduler_specific_version_a   nr_delta   ${NRBTS_DIST_NAME}   ${NRCELL_DIST_NAME}
    Log   Delta commissioning finished successfully!    console=True


Deactivate micro DTX and optimized scheduler for 8238_A
    Log   Start delta commissioning...    console=True
    deactivate_micro_dtx_and_optimized_scheduler    nr_delta   ${NRBTS_DIST_NAME}   ${NRCELL_DIST_NAME}
    Log   Delta commissioning finished successfully!    console=True


Deactivate only optimized DTX scheduler for 8238_A
    Log   Start delta commissioning...    console=True
    activate_micro_dtx_and_optimized_scheduler_specific_version     nr_delta   ${NRBTS_DIST_NAME}   ${NRCELL_DIST_NAME}
    Log   Delta commissioning finished successfully!    console=True


TC_teardown_8238_A
    Detach UE    UE_1
    TTI.teardown_tti_traces_in_streaming_mode
    TcpdumpSmod.teardown_tcpdump_on_smod
    AdminUtils.unlock_all_cells

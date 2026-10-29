*** Settings ***
Documentation
...   Max tput keywords

Library         taf.sw.reporting_portal
Library         taf.rfrl.common_resources.python.report_to_rep
Library         testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/admin_api/DeltaStore.py
Library         taf.gnb.oam.coam.admin

Resource        taf/rfrl/bts/robot/gnb.robot
Resource        taf/rfrl/ue/robot/REAL_UE.robot
Resource        ./Bi-Directional_Throughput_1-DRB_OTA.robot

Variables       ./max_tput_keywords.py


*** Variables ***

${bts_id}          50078
${nrbts_id}        50078
${capabilities}    REAL_UE
${duration}        300s
${deviation}       10%
${interval}        1
${size_packet}     10k
# downlink
${tput_dl}                44 Mbits/sec
${tput_dl_split}          69 Mbits/sec
${parallel_streams_dl}    4
${buffer_client_dl}       8M
${buffer_server_dl}       8M
# uplink
${tput_ul}                16 Mbits/sec
${parallel_streams_ul}    2
${buffer_client_ul}       4M
${buffer_server_ul}       4M


*** Keywords ***
set cell administrativeState to
    [Arguments]    ${state}    ${cell_num}    ${id_bts}    ${id_nrbts}
    # state=${state} one of "Locked" or "Unlocked"
    delete_delta_if_already_present     name=default
    initialise_delta_store
    add_parameters_to_delta
    ...    MRBTS-${id_bts}/NRBTS-${id_nrbts}/NRCELL-${cell_num}
    ...    administrativeState=${state}
    ${delta_store}=    collect delta store
    ${admin_alias}=    taf.gnb.oam.coam.admin.connect To
    taf.gnb.oam.coam.admin.Perform Delta Recommissioning
    ...    delta_file=${delta_store}
    ...    skip_parameter_relation_errors=True
#    ...    shoud_activate=True
    ...    timeout=300s
    ...    connection=${admin_alias}
    [teardown]    taf.gnb.oam.coam.admin.teardown    ${admin_alias}


unlock cell
    [Arguments]    ${cell_num}    ${id_bts}    ${id_nrbts}
    set cell administrativeState to    state=Unlocked    cell_num=${cell_num}    id_bts=${id_bts}    id_nrbts=${id_nrbts}


lock cell
    [Arguments]    ${cell_num}     ${id_bts}    ${id_nrbts}
    set cell administrativeState to    state=locked    cell_num=${cell_num}    id_bts=${id_bts}    id_nrbts=${id_nrbts}


set three cells administrativeState to
    [Arguments]    ${state}    ${id_bts}    ${id_nrbts}
    set cell administrativeState to    state=${state}    cell_num=1    id_bts=${id_bts}    id_nrbts=${id_nrbts}
    set_cell_administrativeState to    state=${state}    cell_num=2    id_bts=${id_bts}    id_nrbts=${id_nrbts}
    set cell administrativeState to    state=${state}    cell_num=3    id_bts=${id_bts}    id_nrbts=${id_nrbts}


lock three cells
    [Arguments]    ${id_bts}    ${id_nrbts}
    set three cells administrativeState to    Locked    ${id_bts}    ${id_nrbts}


unlock three cells
   [Arguments]    ${id_bts}    ${id_nrbts}
    set three cells administrativeState to    Unlocked    ${id_bts}    ${id_nrbts}


use only cell
    [Arguments]    ${cell_num}    ${id_bts}    ${id_nrbts}
    lock three cells    ${id_bts}    ${id_nrbts}
    unlock cell   ${cell_num}    ${id_bts}    ${id_nrbts}


tput_bidirectional
    [Arguments]
    ...    ${capabilities}
    ...    ${duration}
    ...    ${tput_dl}
    ...    ${tput_ul}
    ...    ${protocol}
    ...    ${deviation}
    ...    ${parallel_streams_dl}
    ...    ${parallel_streams_ul}
    ...    ${size_packet}
    ...    ${buffer_client_dl}
    ...    ${buffer_server_dl}
    ...    ${buffer_client_ul}
    ...    ${buffer_server_ul}
    ...    ${interval}
    ...    ${reboot_ue}=${False}
    ...    ${timeout_reboot_ue}=100
    ...    ${qci_dl}=${None}
    ...    ${qci_ul}=${None}
    ...    ${start_transfer_in_new_pm_period}=${False}

    Run Keyword If  ${start_transfer_in_new_pm_period}  REAL_UE.Wait for next PM period
    Prepare Ue for L3 Call
    ...    capabilities=${capabilities}
    ...    reboot_ue=${reboot_ue}
    ...    timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 Call Data Transfer DL&UL
    ...    duration=${duration}
    ...    tput_dl=${tput_dl}
    ...    tput_ul=${tput_ul}
    ...    protocol=${protocol}
    ...    deviation=${deviation}
    ...    parallel_streams_dl=${parallel_streams_dl}
    ...    parallel_streams_ul=${parallel_streams_ul}
    ...    size_packet=${size_packet}
    ...    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}
    ...    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}
    ...    qci_dl=${qci_dl}
    ...    qci_ul=${qci_ul}

    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         tput_dl=${tput_dl}  tput_ul=${tput_ul}  protocol=${protocol}  deviation=${deviation}


tput_uplink
    [Arguments]
    ...    ${capabilities}
    ...    ${duration}
    ...    ${tput}
    ...    ${protocol}
    ...    ${deviation}
    ...    ${parallel_streams}
    ...    ${size_packet}
    ...    ${buffer_client}
    ...    ${buffer_server}
    ...    ${interval}
    ...    ${reboot_ue}=${False}
    ...    ${timeout_reboot_ue}=100
    ...    ${qci}=${None}
    ...    ${start_transfer_in_new_pm_period}=${False}

    Run Keyword If  ${start_transfer_in_new_pm_period}  REAL_UE.Wait for next PM period
    Prepare Ue for L3 Call
    ...    capabilities=${capabilities}
    ...    reboot_ue=${reboot_ue}
    ...    timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 Call One Way Data Transfer
    ...    direction=UL
    ...    duration=${duration}
    ...    tput=${tput}
    ...    protocol=${protocol}
    ...    deviation=${deviation}
    ...    parallel_streams=${parallel_streams}
    ...    size_packet=${size_packet}
    ...    buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    ...    interval=${interval}
    ...    qci=${qci}

    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         tput_ul=${tput}  protocol=${protocol}  deviation=${deviation}


tput_downlink
    [Arguments]
    ...    ${capabilities}
    ...    ${duration}
    ...    ${tput}
    ...    ${protocol}
    ...    ${deviation}
    ...    ${parallel_streams}
    ...    ${size_packet}
    ...    ${buffer_client}
    ...    ${buffer_server}
    ...    ${interval}
    ...    ${reboot_ue}=${False}
    ...    ${timeout_reboot_ue}=100
    ...    ${qci}=${None}
    ...    ${start_transfer_in_new_pm_period}=${False}

    Run Keyword If  ${start_transfer_in_new_pm_period}  REAL_UE.Wait for next PM period
    Prepare Ue for L3 Call
    ...    capabilities=${capabilities}
    ...    reboot_ue=${reboot_ue}
    ...    timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 Call One Way Data Transfer
    ...    direction=DL
    ...    duration=${duration}
    ...    tput=${tput}
    ...    protocol=${protocol}
    ...    deviation=${deviation}
    ...    parallel_streams=${parallel_streams}
    ...    size_packet=${size_packet}
    ...    buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    ...    interval=${interval}
    ...    qci=${qci}

    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         tput_dl=${tput}  protocol=${protocol}  deviation=${deviation}


set tput mode to split
    [Arguments]        ${protocol}    ${sektor_number}
    setup_and_check_preconditions_in_scf    ${scf_parameters_for_tput_split_mode}
    use only cell      ${sektor_number}    ${bts_id}    ${nrbts_id}
    Verify gNB is onAir
    tput_bidirectional
    ...                capabilities=${capabilities}
    ...                duration=${duration}
    ...                tput_dl=${tput_dl_split}
    ...                tput_ul=${tput_ul}
    ...                protocol=${protocol}
    ...                deviation=${deviation}
    ...                parallel_streams_dl=${parallel_streams_dl}
    ...                parallel_streams_ul=${parallel_streams_ul}
    ...                size_packet=${size_packet}
    ...                buffer_client_dl=${buffer_client_dl}
    ...                buffer_server_dl=${buffer_server_dl}
    ...                buffer_client_ul=${buffer_client_ul}
    ...                buffer_server_ul=${buffer_server_ul}
    ...                interval=${interval}



set tput mode to 5g
    [Arguments]        ${protocol}    ${sektor_number}
    setup_and_check_preconditions_in_scf    ${scf_parameters_for_tput_5g_mode}
    use only cell      ${sektor_number}    ${bts_id}    ${nrbts_id}
    Verify gNB is onAir
    tput_bidirectional
    ...                capabilities=${capabilities}
    ...                duration=${duration}
    ...                tput_dl=${tput_dl}
    ...                tput_ul=${tput_ul}
    ...                protocol=${protocol}
    ...                deviation=${deviation}
    ...                parallel_streams_dl=${parallel_streams_dl}
    ...                parallel_streams_ul=${parallel_streams_ul}
    ...                size_packet=${size_packet}
    ...                buffer_client_dl=${buffer_client_dl}
    ...                buffer_server_dl=${buffer_server_dl}
    ...                buffer_client_ul=${buffer_client_ul}
    ...                buffer_server_ul=${buffer_server_ul}
    ...                interval=${interval}

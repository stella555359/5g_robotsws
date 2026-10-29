*** Settings ***
Library     testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME   keywords
Library      ./tools.py   WITH NAME   myTools


*** Variables ***
# -----------------------------UE-----------------------------
${capabilities}                         REAL_UE
${alias}                                UE
${bts_type}                             GNB
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${ENABLE_RACH_OBSERVER}                 False
${deviation_ul}                         40%
${deviation_dl}                         40%
${duration}                             120s
${interval}                             1
${linux_congestion}                     reno
${parallel_streams_dl}                  2
${parallel_streams_ul}                  2
${reboot_ue}                            False
${size_packet_dl}                       1320B
${size_packet_ul}                       1380B
${timeout_reboot_ue}                    100
${tput_dl}                              900 Mbits/sec
${tput_ul}                              80 Mbits/sec
${qci}                                  None
${protocol}                             tcp
${buffer_client_dl}                     None
${buffer_server_dl}                     None
${buffer_client_ul}                     None
${buffer_server_ul}                     None
${GNB_SCF_NAME}                         GNB0_SCF.xml

@{allowed_faults_asir}=                 61648    10    4480    4493
@{alarms_allowed_during_preparation}    Create List    Failure detected on assigned antennas


*** Keywords ***
Verify L3 Call Traffic
    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 Call Data Transfer DL&UL    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...    protocol=${protocol}    deviation_dl=${deviation_dl}    deviation_ul=${deviation_ul}
    ...    parallel_streams_dl=${parallel_streams_dl}    parallel_streams_ul=${parallel_streams_ul}
    ...    size_packet_dl=${size_packet_dl}    size_packet_ul=${size_packet_ul}    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}    buffer_client_ul=${buffer_client_ul}    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}    qci_dl=${qci}    qci_ul=${qci}    linux_congestion_dl=${linux_congestion}
    ...    linux_congestion_ul=${linux_congestion}


Verify Asir Configuration Verify and Commissioning
    [Arguments]   ${scf_gnb_file}    ${scf_asir_file}
    ${SCF_GNB_PATH}    keywords.Get Default Scf Path    file_name=${scf_gnb_file}
    ${SCF_ASIR_PATH}    keywords.Get Default Scf Path    file_name=${scf_asir_file}
    ${start_time}=    keywords.Get Current Time
    Perform Bts Full Commissioning    scf_file=${SCF_GNB_PATH}
    ...                               timeout=400
    Sleep    120s
    gnb_asir.Perform Asir Commissioning    scf_path=${SCF_ASIR_PATH}
    ...                                    timeout=${120}
    Sleep    120s
    gnb_asir.Wait For Asir To Be Onair    timeout=600
    Wait For Site To Be Onair
    Wait Until Keyword Succeeds    10x    30s    myTools.Check All Hubmods Status
    ...                                          operationalState=enabled
    ...                                          commissioned=Yes
    ...                                          localState=unblocked
    ...                                          hardwareState=working
    ...                                          softwareState=configured
    ...                                          activeStatusLEDColor=Green
    ...                                          faultStatusLEDColor=Off
    ...                                          powerStatusLEDColor=Green
    Wait Until Keyword Succeeds    600 sec    5 sec   Verify Setup Of All Cells
    keywords.Verify Alarm Appear In Alarm History On Asir    allowed_fault_ids=${allowed_faults_asir}
    ...                                                   start_time=${start_time}
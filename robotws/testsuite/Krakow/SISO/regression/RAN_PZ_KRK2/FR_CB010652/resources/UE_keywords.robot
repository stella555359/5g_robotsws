*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com

Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK2.FR_CB010652.resources.AttenuatorHandler    WITH NAME
...         Attenuator

Resource    taf/rfrl/ue/robot/REAL_UE.robot

*** Variables ***
${CAPABILITIES}                 REAL_UE
${REBOOT_UE}                    ${False}
${REBOOT_UE_TIMEOUT}            150
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}

${DURATION_TCP_DL}              120s
${PARAREL_STREAMS_TCP_DL}       4
${SIZE_PACKET_TCP_DL}           1400
${BUFFER_CLIENT_TCP_DL}         ${None}
${BUFFER_SERVER_TCP_DL}         ${None}
${INTERVAL_TCP_DL}              1
${QCI_TCP_DL}                   ${None}
${LINUX_CONGESTION_TCP_DL}      ${None}

${DURATION_TCP_UL}              120s
${PARAREL_STREAMS_TCP_UL}       2
${SIZE_PACKET_TCP_UL}           1400
${BUFFER_CLIENT_TCP_UL}         ${None}
${BUFFER_SERVER_TCP_UL}         ${None}
${INTERVAL_TCP_UL}              1
${QCI_TCP_UL}                   ${None}
${LINUX_CONGESTION_TCP_UL}      ${None}

${DURATION_TCP_DL_UL}           120s
${INTERVAL_TCP_DL_UL}           1

${PARAREL_STREAMS_UDP_DL}       1
${SIZE_PACKET_UDP_DL}           1400B
${BUFFER_CLIENT_UDP_DL}         ${None}
${BUFFER_SERVER_UDP_DL}         ${None}
${QCI_UDP_DL}                   ${None}
${LINUX_CONGESTION_UDP_DL}      reno

${PARAREL_STREAMS_UDP_UL}       1
${SIZE_PACKET_UDP_UL}           1400B
${BUFFER_CLIENT_UDP_UL}         ${None}
${BUFFER_SERVER_UDP_UL}         ${None}
${QCI_UDP_UL}                   ${None}
${LINUX_CONGESTION_UDP_UL}      reno

*** Keywords ***
Restore Attenuation
    [Arguments]    ${attenuators}
    FOR    ${attenuator}    IN    @{attenuators}
        Attenuator.set_attenuation    value_string=0
        ...                           att_id=${attenuator}[attenuator_id]
        ...                           selected_ports=${attenuator}[ports]
    END

Attenuate RU
    [Arguments]    ${attenuators}
    FOR    ${attenuator}    IN    @{attenuators}
        Attenuator.gradually_increase_attenuation    att_id=${attenuator}[attenuator_id]
        ...                               max_value=100
        ...                               step=10
        ...                               interval=2
        ...                               selected_ports=${attenuator}[ports]
    END

Prepare Call To Selected Cell
    [Arguments]     ${selected_cell}
    Restore Attenuation    attenuators=${selected_cell}[attenuators]

Prepare UE
    Prepare Ue for L3 Call    capabilities=${CAPABILITIES}
    ...                       reboot_ue=${REBOOT_UE}
    ...                       timeout_reboot_ue=${REBOOT_UE_TIMEOUT}

Run Two Way TCP DL And UL Data Transfer
    [Arguments]    ${deviation_dl}    ${deviation_ul}    ${selected_cell}
    Run Keyword And Continue On Failure    Verify L3 Call Data Transfer DL&UL
    ...    duration=${DURATION_TCP_DL_UL}
    ...    tput_dl=${selected_cell}[throughput_dl]
    ...    tput_ul=${selected_cell}[throughput_ul]
    ...    protocol=tcp
    ...    deviation_dl=${deviation_dl}
    ...    deviation_ul=${deviation_ul}
    ...    parallel_streams_dl=${PARAREL_STREAMS_TCP_DL}
    ...    parallel_streams_ul=${PARAREL_STREAMS_TCP_UL}
    ...    size_packet_dl=${SIZE_PACKET_TCP_DL}
    ...    size_packet_ul=${SIZE_PACKET_TCP_UL}
    ...    buffer_client_dl=${BUFFER_CLIENT_TCP_DL}
    ...    buffer_server_dl=${BUFFER_SERVER_TCP_DL}
    ...    buffer_client_ul=${BUFFER_CLIENT_TCP_UL}
    ...    buffer_server_ul=${BUFFER_SERVER_TCP_UL}
    ...    interval=${INTERVAL_TCP_DL_UL}
    ...    qci_dl=${QCI_TCP_DL}
    ...    qci_ul=${QCI_TCP_UL}
    ...    linux_congestion_dl=${LINUX_CONGESTION_TCP_DL}
    ...    linux_congestion_ul=${LINUX_CONGESTION_TCP_UL}
    [Teardown]    Attenuate RU    attenuators=${selected_cell}[attenuators]

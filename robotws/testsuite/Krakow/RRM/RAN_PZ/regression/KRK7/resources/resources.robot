*** Settings ***
Library      keywords.py
Library      taf.ue
Library      on_air_tl_preparation.testline_preparation
Library      testsuite.Krakow.RRM.RAN_PZ.regression.KRK7.resources.pcap_collector.PcapCollector    WITH NAME    pcap
Library      testsuite.Krakow.RRM.RAN_PZ.regression.KRK7.resources.ue.CallResources    WITH NAME    ue
Library      xml_parser.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
${capabilities}                         REAL_UE
${alias}                                UE
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${deviation_dl}                         100%
${duration}                             180s
${interval}                             1
${linux_congestion}                     reno
${parallel_streams_dl}                  4
${reboot_ue}                            True
${size_packet_dl}                       1400B
${timeout_reboot_ue}                    100
${tput_dl}                              500 Mbits/sec
${qci}                                  None
${begin_attenuation}                    0dB

@{NRHOIF_FR1}=     1    2    3
@{NRHOIF_FR2}=     4    5    6

@{CUSTOM_ALLOWED_ALARMS}    NG SCTP setup fail    User Account has Default Password


*** Keywords ***
Verify Tput
    ue.verify_dl_tput    capabilities=${capabilities}
    ...                  alias=${alias}
    ...                  reboot_ue=${reboot_ue}
    ...                  timeout_reboot_ue=${timeout_reboot_ue}
    ...                  duration=${duration}
    ...                  tput_dl=${tput_dl}
    ...                  deviation_dl=${deviation_dl}
    ...                  parallel_streams_dl=${parallel_streams_dl}
    ...                  size_packet_dl=${size_packet_dl}
    ...                  interval=${interval}
    ...                  linux_congestion=${linux_congestion}


Verify Tput with Attenuated Signal
    [Arguments]    ${begin_attenuation}    ${attenuator}    ${attenuation}    ${delay}    ${attenuation_duration}
    ...            ${max_react}=${None}
    ue.verify_dl_tput_with_attenuation     capabilities=${capabilities}
    ...                                    alias=${alias}
    ...                                    reboot_ue=${reboot_ue}
    ...                                    timeout_reboot_ue=${timeout_reboot_ue}
    ...                                    duration=${duration}
    ...                                    tput_dl=${tput_dl}
    ...                                    deviation_dl=${deviation_dl}
    ...                                    parallel_streams_dl=${parallel_streams_dl}
    ...                                    size_packet_dl=${size_packet_dl}
    ...                                    interval=${interval}
    ...                                    attenuator=${attenuator}
    ...                                    attenuation=${attenuation}
    ...                                    attenuation_duration=${attenuation_duration}
    ...                                    delay=${delay}
    ...                                    begin_attenuation=${begin_attenuation}
    ...                                    max_react=${max_react}


Create Suite Attenuator Instance
    [Arguments]    ${port_no}
    ${attenuator}=    Create Attenuation Interface    port_no=${port_no}
    Set Suite Variable    ${attenuator}

*** Settings ***
Documentation
...   Keywords implementing test procedures with L3 call for the feature CB009042
...   author: Agnieszka Bylica
...   contact: agnieszka.bylica@nokia.com

Library     taf/rfrl/bts/commissioning.py


*** Keywords ***
Verify L3 call
    Verify L3 Call Data Transfer DL&UL    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...                                   protocol=${protocol}    deviation_dl=${deviation_dl}    deviation_ul=${deviation_ul}
    ...    parallel_streams_dl=${parallel_streams_dl}    parallel_streams_ul=${parallel_streams_ul}
    ...    size_packet_dl=${size_packet_dl}    size_packet_ul=${size_packet_ul}    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}    buffer_client_ul=${buffer_client_ul}    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}    qci_dl=${qci_dl}    qci_ul=${qci_ul}    linux_congestion_dl=${linux_congestion_dl}
    ...    linux_congestion_ul=${linux_congestion_ul}

Load Default Swconfig
    commissioning.upload_swconfig_on_classical_gnb      sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt
    Reset gNB
    gnbcell.wait_for_cell_to_be_onair    timeout=900 sec    interval=15 sec

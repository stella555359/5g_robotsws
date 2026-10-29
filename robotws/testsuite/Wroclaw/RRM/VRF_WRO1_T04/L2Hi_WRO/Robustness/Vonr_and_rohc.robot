*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     ../5GC000774_ROHC/keywords_ROHC.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Mariusz Waczynski (mariusz.waczynski@nokia.com)
...    release: 23R1

Suite Setup    Run Keywords    Enable Vonr And Rohc TDD FDD
...            AND    Activate Intra Gnb Ho And A3 Meas TDD FDD
...            AND    Increase Number Of GBR Bearers

#Suite Setup    Run Keywords    Enable Vonr And Rohc
#...            AND      Activate Intra Gnb Ho And A3 Meas

Test Setup      Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...         AND    Reach OnAir    lua_cfg=${CURDIR}/config/basic_setup_TDD_FDD.cfg

Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TRAFFIC_DURATION_MIN}=   10m
${NUM_OF_UES}=     30

*** Test Cases ***
5GC000774-Multi_Ue
    Attach Multiple 5g Ues Capable Of Supporting Rohc    num_of_ues=${NUM_OF_UES}
    Start Dl And Ul Data Traffic For Tcp Udp And Rtp Packet Stream     num_of_ues=${NUM_OF_UES}
    Sleep    ${TRAFFIC_DURATION_MIN}
    Check If Expected Throughout Is Reached For All Ues And There Are No Packets Lost     num_of_ues=${NUM_OF_UES}

*** Keywords ***
Increase Number Of GBR Bearers
      Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_enable_VoNR_TDD_FDD.json

Attach Multiple 5g Ues Capable Of Supporting Rohc
    Execute Egate Command    cmd=sim_debug_log level=6
    [Arguments]    ${num_of_ues}=${9}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Set Internal Traffic Type To UEs    ue_id=${ue_id}    pdu_id=1
        Attach Ue    ue_id=${ue_id}
        Establish Pdu Session    ue_id=${ue_id}    pdu_id=1    gw_id=${ue_id}
        Modify Pdu Session    ue_id=${ue_id}    pdu_id=1    qos_to_add=2
        Modify Pdu Session    ue_id=${ue_id}    pdu_id=1    qos_to_add=3
    END


Start Dl And Ul Data Traffic For Tcp Udp And Rtp Packet Stream
    [Arguments]    ${num_of_ues}=${9}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 dir=dl rtp_codec=amr_wb_23_85
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 dir=ul rtp_codec=amr_wb_23_85
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=15
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=2
    END


Check If Expected Throughout Is Reached For All Ues And There Are No Packets Lost
    [Arguments]    ${num_of_ues}=${9}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Expected Throughput For Qfi Should Be Reached    ue_id=${ue_id}    pdu_id=1    qfi_id=1
         ...    expected_throughput=15    unit=mbps    margin=1    direction=dl
        Expected Throughput For Qfi Should Be Reached    ue_id=${ue_id}    pdu_id=1    qfi_id=1
         ...    expected_throughput=15    unit=mbps    margin=1    direction=dl
        Check Number Of Total Packets Lost    ue_id=${ue_id}    pdu_id=1    qfi_id=1    packet_loss=0
         ...    margin=1.0    direction=dl
        Check Number Of Total Packets Lost    ue_id=${ue_id}    pdu_id=1    qfi_id=1    packet_loss=0
         ...    margin=1.0    direction=ul
        Check Number Of Total Packets Lost    ue_id=${ue_id}    pdu_id=1    qfi_id=3    packet_loss=0
         ...    margin=1.0    direction=dl
        Check Number Of Total Packets Lost    ue_id=${ue_id}    pdu_id=1    qfi_id=3    packet_loss=0
         ...    margin=1.0    direction=ul
    END

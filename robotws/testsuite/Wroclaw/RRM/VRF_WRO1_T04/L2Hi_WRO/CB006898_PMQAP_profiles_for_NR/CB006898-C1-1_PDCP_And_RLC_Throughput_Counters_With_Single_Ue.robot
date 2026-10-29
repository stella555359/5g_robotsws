*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Library     ../resources/common_keywords.py
Library     ../resources/pm_counters_validator.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 23R3

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Keywords ***
CB006898-C1-1_PDCP_And_RLC_Throughput_Counters_With_Single_Ue
    Register Ue With Default Pdu Session
    Start Dl And Ul Data Traffic
    Display Ue And Qfi Statistics
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=10    unit=mbps    margin=0.2    direction=dl
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=1    packet_loss=0
    ...    margin=0.0    direction=bi
    ta5g_ue_mobility.Deregister Ue    ue_id=1
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Check If Values Of Pm Counters Are Equivalent    first_counter_id=${COUNTER_ID_DL_PDCP_VOL_UE_TPUT_TOT}
    ...    second_counter_id=${COUNTER_ID_DL_PDCP_VOL_UE_TPUT_QOS08}      pm_counters_file=${PM_COUNTERS}
    Check If Values Of Pm Counters Are Equivalent    first_counter_id=${COUNTER_ID_DL_PDCP_TIME_UE_TPUT}
    ...    second_counter_id=${COUNTER_ID_DL_PDCP_TIME_UE_TPUT_QOS_8}      pm_counters_file=${PM_COUNTERS}
    Check If Values Of Pm Counters Are Equivalent    first_counter_id=${COUNTER_ID_UL_RLC_VOL_UE_TPUT_TOT}
    ...    second_counter_id=${COUNTER_ID_UL_RLC_VOL_UE_TPUT_QOS_8}      pm_counters_file=${PM_COUNTERS}
    Check If Values Of Pm Counters Are Equivalent    first_counter_id=${COUNTER_ID_UL_RLC_TIME_UE_TPUT}
    ...    second_counter_id=${COUNTER_ID_UL_RLC_TIME_UE_TPUT_QOS_8}      pm_counters_file=${PM_COUNTERS}

Add Qos Group
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_qos_group.json

Start Dl And Ul Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=10
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}

Display Ue And Qfi Statistics
    Display Qfi stats    qfi_id=1
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

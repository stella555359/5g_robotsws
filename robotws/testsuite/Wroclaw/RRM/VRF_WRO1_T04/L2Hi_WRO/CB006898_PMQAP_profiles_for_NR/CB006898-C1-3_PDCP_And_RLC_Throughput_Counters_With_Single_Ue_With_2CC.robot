*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ../resources/pm_counters_validator.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 22R3

Suite Setup     Run Keywords    Enable 2CC Carrier Aggregation With Buffer Based Scell Activation
    ...         AND    Enable Syslog Info Level Prints
    ...         AND    Enable Tput Counters
    ...         AND    Add Qos Group

Test Setup      Run Keywords    Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...       AND    Set Internal Traffic Type To UEs
    ...       AND    Resources Usage At Test Begining
    ...       AND    Wait For Next Full Pm Interval
Test Teardown    Run Keywords    Resources Usage At Test End
    ...       AND    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs
    ...       AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Test Cases ***
CB006898-C1-3_PDCP_And_RLC_Throughput_Counters_With_Single_Ue_With_2CC
    Register Ue With Default Pdu Session
    Start Dl And Ul Data Traffic
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
    Display Ue Statistics
    Deregister Ue    ue_id=1

*** Keywords ***
Add Qos Group
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_qos_group.json

Start Dl And Ul Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=170 trf_id=3
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=100
    Sleep    ${TRAFFIC_DURATION_SEC}

Display Ue Statistics
    Display Qfi stats    qfi_id=1
    Execute Egate Command    cmd=ue_stats_nr id=1 type=pdsch scell=0,1
    Execute Egate Command    cmd=ue_stats_nr id=1 type=pusch scell=0,1

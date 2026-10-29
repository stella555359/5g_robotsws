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

Suite Setup     Run Keywords    Enable Syslog Info Level Prints
    ...       AND    Enable Tput Counters
    ...       AND    Add Qos Group
    ...       AND    Disable Uplane Ciphering
    ...       AND    Increase WTS Buffer Size
    ...       AND    Modify UPF And UEC Buff Size    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

Test Setup      Run Keywords    Prepare Sa Test Environement
    ...       AND    Reach Onair    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...       AND    Set External Traffic Type To UEs
    ...       AND    Resources Usage At Test Begining
    ...       AND    Wait For Next Full Pm Interval

Suite Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs

Test Teardown     Run Keywords    Deregister Ue   ue_id=20
    ...       AND    Sleep    3s   Waiting for deregister
    ...       AND    Resources Usage At Test End
    ...       AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s
${local_moid_NRCELL-3}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3

*** Test Cases ***
CB006898-C1-4_PDCP_And_RLC_Throughput_Counters_With_Single_Ue_TCP_DL_And_UL_FDD_Traffic
    Register Ue With Default Pdu Session    ue_id=20
    Prepare Iperf Environment And Start Traffic    server_cmd_options=${server_cmd_options}
    ...    iperf_service=${iperf_service}    client_cmd_options=${client_cmd_options_dl}
    ...    iperf_ue_service=${iperf_ue_1_dl}
    Display Ue Statistics
    Verify Ue Throughput    ue_id=20    expected_tput=200
    Check DL PDCP And RLC Throughput Counters
    Prepare Iperf Environment And Start Traffic    server_cmd_options=${server_cmd_options}
    ...    iperf_service=${iperf_service}    client_cmd_options=${client_cmd_options_ul}
    ...    iperf_ue_service=${iperf_ue_1_ul}
    Display Ue Statistics
    Verify Ue Throughput    ue_id=20    expected_tput=100   type=pusch
    Check UL PDCP And RLC Throughput Counters

*** Keywords ***
Display Ue Statistics
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=20
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=20 type=pusch

Add Qos Group
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_qos_group.json

Set External Traffic Type To UEs
    Execute Egate Command    cmd=set_pdu_param ue=20 pdu=1 trf_type=external

Check DL PDCP And RLC Throughput Counters
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Check If Values Of Pm Counters Are Equivalent    first_counter_id=${COUNTER_ID_DL_PDCP_VOL_UE_TPUT_TOT}
    ...    second_counter_id=${COUNTER_ID_DL_PDCP_VOL_UE_TPUT_QOS08}      pm_counters_file=${PM_COUNTERS}
    ...    LOCAL_MOID_BTS_CELL1=${local_moid_NRCELL-3}
    Check If Values Of Pm Counters Are Equivalent    first_counter_id=${COUNTER_ID_DL_PDCP_TIME_UE_TPUT}
    ...    second_counter_id=${COUNTER_ID_DL_PDCP_TIME_UE_TPUT_QOS_8}      pm_counters_file=${PM_COUNTERS}
    ...    LOCAL_MOID_BTS_CELL1=${local_moid_NRCELL-3}
    Kill Iperf Processes

Check UL PDCP And RLC Throughput Counters
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Check If Values Of Pm Counters Are Equivalent    first_counter_id=${COUNTER_ID_UL_RLC_VOL_UE_TPUT_TOT}
    ...    second_counter_id=${COUNTER_ID_UL_RLC_VOL_UE_TPUT_QOS_8}      pm_counters_file=${PM_COUNTERS}
    ...    LOCAL_MOID_BTS_CELL1=${local_moid_NRCELL-3}
    Check If Values Of Pm Counters Are Equivalent    first_counter_id=${COUNTER_ID_UL_RLC_TIME_UE_TPUT}
    ...    second_counter_id=${COUNTER_ID_UL_RLC_TIME_UE_TPUT_QOS_8}      pm_counters_file=${PM_COUNTERS}
    ...    LOCAL_MOID_BTS_CELL1=${local_moid_NRCELL-3}
    Kill Iperf Processes

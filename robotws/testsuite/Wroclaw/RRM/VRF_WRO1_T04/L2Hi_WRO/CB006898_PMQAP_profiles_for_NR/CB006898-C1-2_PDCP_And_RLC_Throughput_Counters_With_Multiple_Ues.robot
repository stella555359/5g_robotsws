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
    ...         AND    Enable Tput Counters
    ...         AND    Add Qos Group

Test Setup      Run Keywords    Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...       AND    Set Internal Traffic Type To Multiple Ues
    ...       AND    Resources Usage At Test Begining
    ...       AND    Wait For Next Full Pm Interval
Test Teardown    Run Keywords    Resources Usage At Test End
    ...       AND    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs
    ...       AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Test Cases ***
CB006898-C1-2_PDCP_And_RLC_Throughput_Counters_With_Multiple_Ues
    Attach Ue And Establish Session
    Start Data Traffic To Multiple Ues
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
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
    Deregister Multiple Ues    first_ue_id=1    last_ue_id=6

*** Keywords ***
Add Qos Group
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_qos_group.json

Attach Ue And Establish Session
    Attach Multiple Ues    first_ue_id=1    last_ue_id=6
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup ue=2 pdu=2 nwslice=1 gw=2
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup ue=3 pdu=3 nwslice=1 gw=3
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup ue=4 pdu=4 nwslice=1 gw=4
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup ue=5 pdu=5 nwslice=1 gw=5
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup ue=6 pdu=6 nwslice=1 gw=6
    Verify Tshark For Given Number Of Messages     alias=${DEFAULT_S1_MME_ALIAS}
    ...    packet_filter=${ICS_SETUP_RESP_SUCCESS}    number_of_messages=6

Display Ue Statistics
    Display Qfi stats    qfi_id=1
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     keywords_ROHC.py
Documentation
...    author: Pawel Konieczny
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO

Suite Setup     Run Keywords    Prepare Sa Test Environement And Reach Onair
...               perform_tl_reset=${RESET_TL}
...               cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
...               cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
...               cfg_filepath_tdd_fdd=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
...            AND    Enable Vonr And Rohc TDD FDD
...            AND    Set Maxcidallowed Value To 1
...            AND    Enable Syslog Debug Prints For Rohc

Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

Test Teardown    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
${UE_ID_CS12_TDD}=    255
${UE_ID_CS12_FDD}=    254
${CELL_ID_FDD}=   3

*** Test Cases ***
5GC000774-A-B1_Maxcidallowed_Value_1_Udp_Stream_With_Prefixed_Payload_Size_TDD
    Attach One 5g Ue Capable Of Supporting Rohc    ${UE_ID_CS12_TDD}
    Start Dl And Ul Data Traffic For Udp Packet Stream
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Check If Statistics For Compressed Pdus Were Incremented
    Check If With Maxidallowed Value 1 Statistics For Rohc Profile 0 Were Incremented Instead Of Profile 2
    Check If Expected Throughout Is Reached And There Are No Packets Lost
    Verify If Rohc Dl Header Pm Counters Arent Incremented
    Deregister Ue    ${UE_ID_CS12_TDD}

5GC000774-A-B1_Maxcidallowed_Value_1_Udp_Stream_With_Prefixed_Payload_Size_FDD
    Attach One 5g Ue Capable Of Supporting Rohc    ${UE_ID_CS12_FDD}
    Start Dl And Ul Data Traffic For Udp Packet Stream    ${UE_ID_CS12_FDD}
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics    ${UE_ID_CS12_FDD}    ${CELL_ID_FDD}
    Check If Statistics For Compressed Pdus Were Incremented    ${CELL_ID_FDD}
    Check If With Maxidallowed Value 1 Statistics For Rohc Profile 0 Were Incremented Instead Of Profile 2    ${CELL_ID_FDD}
    Check If Expected Throughout Is Reached And There Are No Packets Lost    ${UE_ID_CS12_FDD}
    Verify If Rohc Dl Header Pm Counters Arent Incremented
    Deregister Ue    ${UE_ID_CS12_FDD}

*** Keywords ***
Set Maxcidallowed Value To 1
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_enable_rohc_maxcidallowed_value_1.json

Display Ue Statistics
    [Arguments]    ${UE_ID}=${255}    ${CELL_ID}=${1}
    Display Qfi stats    ue_id=${UE_ID}    qfi_id=3
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=${CELL_ID} format=long

Start Dl And Ul Data Traffic For Udp Packet Stream
    [Arguments]    ${UE_ID}=${255}
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=dl trf_id=1 kbps=30
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=ul trf_id=2 kbps=30

Check If Statistics For Compressed Pdus Were Incremented
    [Arguments]    ${CELL_ID}=${1}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=0    enb_id=2    cell_id=${CELL_ID}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=size_of_compressed_pdus    mode=am    value=0    enb_id=2    cell_id=${CELL_ID}

Check If With Maxidallowed Value 1 Statistics For Rohc Profile 0 Were Incremented Instead Of Profile 2
    [Arguments]    ${CELL_ID}=${1}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_0_pdus    mode=am    value=0
    ...    enb_id=2    cell_id=${CELL_ID}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_0_bytes    mode=am    value=0
    ...    enb_id=2    cell_id=${CELL_ID}
    Rohc Statistic Equal To Given Value    rohc_statistic_prefix=decompressed_profile_2_pdus    mode=am    value=0
    ...    enb_id=2    cell_id=${CELL_ID}
    Rohc Statistic Equal To Given Value    rohc_statistic_prefix=decompressed_profile_2_bytes    mode=am    value=0
    ...    enb_id=2    cell_id=${CELL_ID}

Check If Expected Throughout Is Reached And There Are No Packets Lost
    [Arguments]    ${UE_ID}=${255}
    Expected Throughput For Qfi Should Be Reached    ue_id=${UE_ID}    pdu_id=1    qfi_id=3
    ...    expected_throughput=30    unit=kbps    margin=1    direction=bi
    Check Number Of Total Packets Lost    ue_id=${UE_ID}    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=bi

Verify If Rohc Dl Header Pm Counters Arent Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_NUM_ROHC_COMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_VOL_ROHC_COMP_HEADER}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

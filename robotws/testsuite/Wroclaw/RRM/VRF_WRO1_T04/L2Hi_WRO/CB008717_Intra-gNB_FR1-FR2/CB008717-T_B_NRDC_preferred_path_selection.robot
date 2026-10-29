*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Mariusz Waczynski (mariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

*** Variables ***
${TRAFFIC_DURATION_SEC_T_B_NRDC}=   2m

*** Keywords ***
CB008717-T_B4_NRDC_preferred_path_selection_with_dlPreferredPathNrDc_MCG_initialDLTrafficRoutingNrDc_initDLoverXxU_actPrioXxAfterInactNrDc_0
    Set Data Split Params For B4
    Register Ue With Default Pdu Session
    Send A4 Measurement
    Start SA Data Traffic 1Mbps In Dl For 100ms
    All Packets Should Be Transmitted On Scg Leg
    Start Data Traffic 10Mbps In Dl
    Dl Data Should Be Transmitted Only on Mcg Leg
    Start Data Traffic 107Mbps In Dl
    Dl Data Should Be Splited    expected_on_mcg_mbps=29    expected_on_scg_mbps=80
    Deregister Ue   ue_id=1
    Set dlDataSplitBufBldUpThreshNrDc To 0 For B4
    Register Ue With Default Pdu Session
    Send A4 Measurement
    Start SA Data Traffic 1Mbps In Dl For 100ms
    All Packets Should Be Transmitted On Scg Leg
    Start Data Traffic 107Mbps In Dl
    Dl Data Should Be Splited    expected_on_mcg_mbps=29    expected_on_scg_mbps=80

CB008717-T_B5_NRDC_preferred_path_selection_with_dlPreferredPathNrDc_SCG_initialDLTrafficRoutingNrDc_initDLoverF1U_actPrioXxAfterInactNrDc_0
    Set Data Split Params For B5
    Register Ue With Default Pdu Session
    Send A4 Measurement
    Start SA Data Traffic 1Mbps In Dl For 100ms
    All Packets Should Be Transmitted On Mcg Leg
    Start Data Traffic 10Mbps In Dl
    Dl Data Should Be Transmitted Only on Scg Leg
    Start Data Traffic 107Mbps In Dl
    Dl Data Should Be Splited    expected_on_mcg_mbps=27    expected_on_scg_mbps=80
    Deregister Ue   ue_id=1
    Set dlDataSplitBufBldUpThreshNrDc To 0 For B5
    Register Ue With Default Pdu Session
    Send A4 Measurement
    Start SA Data Traffic 1Mbps In Dl For 100ms
    All Packets Should Be Transmitted On Mcg Leg
    Start Data Traffic 107Mbps In Dl
    Dl Data Should Be Splited    expected_on_mcg_mbps=27    expected_on_scg_mbps=80

CB008717-T_B6_NRDC_preferred_path_selection_with_dlPreferredPathNrDc_SCG_initialDLTrafficRoutingNrDc_initDLoverF1U_actPrioXxAfterInactNrDc_1
    Set Data Split Params For B6
    Register Ue With Default Pdu Session
    Send A4 Measurement
    Start SA Data Traffic 1Mbps In Dl For 100ms
    All Packets Should Be Transmitted On Mcg Leg
    Start Data Traffic 10Mbps In Dl
    Dl Data Should Be Transmitted Only on Scg Leg
    Start Data Traffic 107Mbps In Dl
    Dl Data Should Be Splited    expected_on_mcg_mbps=27    expected_on_scg_mbps=80

Start SA Data Traffic 1Mbps In Dl For 100ms
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=1 packets=10 period_ms=10 burst=1

Start Data Traffic 10Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10
    Sleep    ${TRAFFIC_DURATION_SEC_T_B_NRDC}

Start Data Traffic 107Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=107 trf_id=1
    Sleep    ${TRAFFIC_DURATION_SEC_T_B_NRDC}

All Packets Should Be Transmitted On Mcg Leg
    Sleep    150ms
    Display NRDC Qfi Stats
    Expected number of packets should be recived    number_of_packets=10   dc_cell_group=mcg
    Expected number of packets should be recived    number_of_packets=0   dc_cell_group=scg

All Packets Should Be Transmitted On Scg Leg
    Sleep    150ms
    Display NRDC Qfi Stats
    Expected number of packets should be recived    number_of_packets=0   dc_cell_group=mcg
    Expected number of packets should be recived    number_of_packets=10   dc_cell_group=scg

Dl Data Should Be Transmitted Only on Scg Leg
    Display NRDC Qfi Stats
    Expected number of packets should be recived    number_of_packets=10   dc_cell_group=mcg
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
    ...    pdu_id=1    qfi_id=1    expected_throughput=10    unit=mbps
    ...    margin=0.1    direction=dl   optional_params=dc_cell_group=scg      margin=1
    Run Keyword And Continue On Failure    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1
    ...    qfi_id=1    packet_loss=0
    ...    margin=0.0    direction=dl

Dl Data Should Be Transmitted Only on Mcg Leg
    Display NRDC Qfi Stats
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
    ...    pdu_id=1    qfi_id=1    expected_throughput=10    unit=mbps
    ...    margin=0.1    direction=dl   optional_params=dc_cell_group=mcg
    Expected number of packets should be recived    number_of_packets=10   dc_cell_group=scg
    Run Keyword And Continue On Failure    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1
    ...    qfi_id=1    packet_loss=0
    ...    margin=0.0    direction=dl

Dl Data Should Be Splited
    [Arguments]    ${expected_on_mcg_mbps}=207    ${expected_on_scg_mbps}=243
    Display NRDC Qfi Stats
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
    ...    pdu_id=1    qfi_id=1    expected_throughput=${expected_on_mcg_mbps}    unit=mbps
    ...    margin=0.1    direction=dl   optional_params=dc_cell_group=mcg
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
    ...    pdu_id=1    qfi_id=1    expected_throughput=${expected_on_scg_mbps}    unit=mbps
    ...    margin=0.1    direction=dl   optional_params=dc_cell_group=scg
    Run Keyword And Continue On Failure    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1
    ...    qfi_id=1    packet_loss=0
    ...    margin=0.0    direction=dl

Expected number of packets should be recived
    [Arguments]    ${ue_id}=1   ${number_of_packets}=10   ${dc_cell_group}=mcg
    Run Keyword And Continue On Failure    Check Number Of Received Packets    ue_id=${ue_id}
    ...    pdu_id=1    qfi_id=1    packet_number=${number_of_packets}
    ...    direction=dl    optional_params=dc_cell_group=${dc_cell_group}     margin=1

Display NRDC Qfi Stats
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=dl dc_cell_group=mcg
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=dl dc_cell_group=scg

Set Data Split Params For B4
    Send Delta Commissioning   input_filepath=${DELTA_FILES_PATH}/CB008717/delta_CB008717-T_B4.json
    ...    skip_relation_errors=True

Set dlDataSplitBufBldUpThreshNrDc To 0 For B4
    Send Delta Commissioning   input_filepath=${DELTA_FILES_PATH}/CB008717/delta_CB008717-T_B4_dlDataSplitBufBldUpThreshNrDc_0.json
    ...    skip_relation_errors=True

Set Data Split Params For B5
    Send Delta Commissioning   input_filepath=${DELTA_FILES_PATH}/CB008717/delta_CB008717-T_B5.json
    ...    skip_relation_errors=True

Set dlDataSplitBufBldUpThreshNrDc To 0 For B5
    Send Delta Commissioning   input_filepath=${DELTA_FILES_PATH}/CB008717/delta_CB008717-T_B5_dlDataSplitBufBldUpThreshNrDc_0.json
    ...    skip_relation_errors=True

Set Data Split Params For B6
    Send Delta Commissioning   input_filepath=${DELTA_FILES_PATH}/CB008717/delta_CB008717-T_B6.json
    ...    skip_relation_errors=True

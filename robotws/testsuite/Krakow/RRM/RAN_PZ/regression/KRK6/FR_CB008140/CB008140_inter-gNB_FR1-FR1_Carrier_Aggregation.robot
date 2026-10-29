*** Settings ***
Documentation
...  author:  Krzysztof Michalski, Jakub Hejduk
...  contact: krzysztof.michalski@nokia.com, jakub.hejduk@nokia.com
...  description: Test Cases for inter gNB FR1-FR1 carrier aggregation

Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB008140/resources/suite_specific_keywords.robot
Variables   resources/counters.py

Force Tags    STATE_CONFIGURED    PY39
...    CLOUD_5G_CLASSICAL_QC_MULTIGNB_SA_ASIBL_2xABIOB1B2_ASIBR_2xABIOB4B5_AHEH_AHPE_AZQO_AZQS

Suite Setup      Suite Setup

*** Variables ***

@{expected_scells_4CC}   1311703041    1311703042    1311703043
@{expected_scells_3CC}   1311703041    1311703043
${4cc_pri_cell_id}    1
@{4cc_ext_cells_ids}    1    2    3
${3cc_pri_cell_id}    2
@{3cc_ext_cells_ids}    1    3

${add_delay}          0.35ms
${remove_delay}       0ms

${PING_COUNT}                10
${PACKET_SIZE_LOW}           32
${TEST_LATENCY_THRESHOLD_TC_01}      1.3

*** Test Cases ***
CB008140-CA-3_#B2_Blind_IgNB_CA_SCell_addition_PCell_with_3_candidate_SCells_in_external_gNB
    [Tags]    CRT
    [Setup]    Test Setup for 4CC Tests
    Attach UE
    Change APN with Ueproxy    apn_name=${abstract_lib_config.UE_APN.DEFAULT}
    Detach UE
    Wait For Next PM measurements
    Check Inter gNB CA    ${expected_scells_4CC}
    Wait For Next PM measurements    delay=90
    Check Inter CA PM Counters Pegged    ${ca_3_blind_ca_3_scells}    ${4cc_pri_cell_id}    ${4cc_ext_cells_ids}    ${release}
    Check Inter CA PM Counters not Pegged     ${ca_3_blind_ca_3_scells}    ${4cc_pri_cell_id}    ${4cc_ext_cells_ids}    ${release}
    Check IGNB_CA_ADD_REQ_SA_NRADJ counter incremented  ${release}
    [Teardown]  Test Teardown

CB008140-CA-6_#B4_UE_call_with_blind_SCell_activation_with_flow_control_and_DL_data_transmission_for_IgNB_3CC_(TDD_TDD_TDD)
    [Tags]    CRT
    [Setup]    Test Setup for 3CC Tests
    Attach UE
    Change APN with Ueproxy    apn_name=${abstract_lib_config.UE_APN.DEFAULT}
    Detach UE
    Wait For Next PM measurements
    Check Inter gNB CA    ${expected_scells_3CC}
    Set Test Variable    ${tput_dl}    2000 Mbits/sec
    Set Test Variable    ${tput_ul}    50 Mbits/sec
    Set Test Variable    ${duration}     60s
    Verify UL and DL data transmission    duration=${duration}     tput_dl_min=${tput_dl}    tput_ul_min=${tput_ul}    port=${None}
    Wait For Next PM measurements    delay=90
    Check Inter CA PM Counters Pegged    ${ca_6_blind_ca_2_scells}    ${3cc_pri_cell_id}    ${3cc_ext_cells_ids}    ${release}
    [Teardown]  Test Teardown

CB008140-CA-8_ #B3_#B5_UE_call_A1_event_SCell_addition_and_Buffer_Based_SCell_activation_with_flow_control_and_DL_data_transmission_IgNB_4CC
    [Tags]    CDRT
    [Setup]    Run Keywords    Test Setup for 4CC Tests    AND    Change Scell Activation To CovBasedA1
    Attach UE
    Change APN with Ueproxy    apn_name=${abstract_lib_config.UE_APN.DEFAULT}
    Detach UE
    Wait For Next PM measurements
    Check Inter gNB CA    ${expected_scells_4CC}
    Set Test Variable    ${tput_dl}    1500 Mbits/sec
    Set Test Variable    ${tput_ul}    50 Mbits/sec
    Set Test Variable    ${duration}     60s
    Verify UL and DL data transmission    duration=${duration}     tput_dl_min=${tput_dl}    tput_ul_min=${tput_ul}    port=${None}
    Wait For Next PM measurements    delay=90
    Check Inter CA PM Counters Pegged    ${ca_8_A1_addition_ca_3_scells}    ${4cc_pri_cell_id}    ${4cc_ext_cells_ids}    ${release}
    Check Inter CA PM Counters not Pegged     ${ca_8_A1_addition_ca_3_scells}    ${4cc_pri_cell_id}    ${4cc_ext_cells_ids}    ${release}
    Check IGNB_CA_ADD_REQ_SA_NRADJ counter incremented  ${release}
    [Teardown]    Run Keywords    Change Scell Activation To Blind    AND    Test Teardown


CB008140_CC_03_#B3_CA_eligible_DRB_setup_for_UE_with_inter_gNB_CA_established_without_any_CA_split_DRBs
    [Tags]    CDRT
    [Setup]    Run Keywords    Test Setup for 4CC Tests    AND    Change Scell Activation To CovBasedA1    AND
    ...                        Change 5QI9 to RLC UM
    Attach UE
    Change APN with Ueproxy    apn_name=${abstract_lib_config.UE_APN.DEFAULT}
    Detach UE
    Check Inter gNB PDU Session Removal
    Set Test Variable    ${tput_dl}    100 Mbits/sec
    Set Test Variable    ${tput_ul}    50 Mbits/sec
    Set Test Variable    ${duration}     60s
    Verify UL and DL data transmission    duration=${duration}     tput_dl_min=${tput_dl}    tput_ul_min=${tput_ul}    port=${5005}
    [Teardown]    Run Keywords     Change Scell Activation To Blind    AND    Change 5QI9 to RLC AM    AND
    ...           Test Teardown with changing APN to default


CB008140_CE_02_#B1_Delete_Non-GBR_CA_bearer_in_a_single_message_for_a_UE_configured_with_ext-SCells_with_single_PDU_session
    [Tags]    CRT
    [Setup]    Test Setup for 3CC Tests
    Check Inter gNB Bearer Deletion    expected_scells_num=${expected_scells_3CC}
    [Teardown]  Test Teardown with changing APN to default


CB008140_CK_02_DL_peak Throughput per UE for 4CC TDD IgNB CA with Xp delay measurement_FDD_FDD_TDD_TDD
    [Tags]    CRT
    [Setup]    Test Setup for 4CC Tests
    Attach UE
    Change APN with Ueproxy    apn_name=${abstract_lib_config.UE_APN.DEFAULT}
    Detach UE
    Change delay    ${add_delay}
    Perform Ping Test To Gnb   ${PING_COUNT}   ${PACKET_SIZE_LOW}   ${TEST_LATENCY_THRESHOLD_TC_01}
    Check Inter gNB CA    ${expected_scells_4CC}
    Set Test Variable    ${tput_dl}    1500 Mbits/sec
    Set Test Variable    ${tput_ul}    50 Mbits/sec
    Set Test Variable    ${duration}     60s
    Verify UL and DL data transmission    duration=${duration}     tput_dl_min=${tput_dl}    tput_ul_min=${tput_ul}
    ...                                   port=${None}
    Change delay    ${remove_delay}
    [Teardown]  Test Teardown



*** Settings ***
Library     ta5g_pm_counters
Library     keywords_CB008379.py

Documentation
...    This file contains general keywords used for testing Feature CB008379.

*** Variables ***
${DISABLED_SHORT_SN}=     nr-rrc.shortSN == 0

*** Keywords ***
Attach Ue With Gbr Am 5QI 4
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_WITHOUT_SHORT_PDCP_SN}
    Register Ue With Default Pdu Session
    Modify Pdu Session And Wait For Regexp    ue_id=1    pdu_id=1    qos_id=6    qfi_id=2    5qi_id=4
    Sleep    3s
    Verify Tshark For No Messages    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${DISABLED_SHORT_SN}

Attach Ue With Gbr Um 5QI 3
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_WITHOUT_SHORT_PDCP_SN}
    Register Ue With Default Pdu Session
    Modify Pdu Session And Wait For Regexp    ue_id=1    pdu_id=1    qos_id=5    qfi_id=2    5qi_id=3
    Sleep    3s
    Verify Tshark For No Messages    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${DISABLED_SHORT_SN}

Attach Ue With Gbr Am 5QI 4 FDD
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_WITHOUT_SHORT_PDCP_SN_FDD}
    Register Ue With Default Pdu Session
    Modify Pdu Session And Wait For Regexp    ue_id=1    pdu_id=1    qos_id=6    qfi_id=2    5qi_id=4
    Sleep    3s
    Verify Tshark For No Messages    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${DISABLED_SHORT_SN}

Attach Ue With Gbr Um 5QI 3 FDD
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_WITHOUT_SHORT_PDCP_SN_FDD}
    Register Ue With Default Pdu Session
    Modify Pdu Session And Wait For Regexp    ue_id=1    pdu_id=1    qos_id=5    qfi_id=2    5qi_id=3
    Sleep    3s
    Verify Tshark For No Messages    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${DISABLED_SHORT_SN}

Attach Ue With Gbr Am 5QI 4 FDD ORAN
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_WITHOUT_SHORT_PDCP_SN_FDD_ORAN}
    Register Ue With Default Pdu Session
    Modify Pdu Session    ue_id=1    pdu_id=1    qos_to_add=6
    Sleep    3s
    Verify Tshark For No Messages    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${DISABLED_SHORT_SN}

Attach Ue With Gbr Um 5QI 3 FDD ORAN
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_WITHOUT_SHORT_PDCP_SN_FDD_ORAN}
    Register Ue With Default Pdu Session
    Modify Pdu Session    ue_id=1    pdu_id=1    qos_to_add=5
    Sleep    3s
    Verify Tshark For No Messages    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${DISABLED_SHORT_SN}

Deteriorate Rf Condition
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=bler action=activate profile_id=1

Improve Rf Condition
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=bler action=deactivate profile_id=1
    Sleep    20s   Waiting for good rf condition

Prepare Bler Testmode For Bad Rf Condition Target Mcs 1
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 target_mcs=1 num_dl_pkts=1000

Prepare Bler Testmode For Bad Rf Condition Target Mcs 3
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 target_mcs=3 num_dl_pkts=1000

Start 30Mbps In Dl and Ul For Gbr
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=30
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=ul mbps=30

Check Traffic Statistic
    [Arguments]    ${expected_throughput_mbps}=30    ${qfi_id}=2    ${traffic_duration}=60s
    Execute Egate Command    cmd=qfi_stats_clear ue=1 pdu=1
    Sleep    ${traffic_duration}
    Display Qfi stats    qfi_id=${qfi_id}
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1
    ...    qfi_id=${qfi_id}
    ...    expected_throughput=${expected_throughput_mbps}    unit=mbps    margin=0.2    direction=dl
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1
    ...    qfi_id=${qfi_id}
    ...    expected_throughput=${expected_throughput_mbps}    unit=mbps    margin=0.2    direction=ul
    Run Keyword And Continue On Failure    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1
    ...    qfi_id=${qfi_id}    packet_loss=0
    ...    margin=0.0    direction=dl
    Run Keyword And Continue On Failure    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1
    ...    qfi_id=${qfi_id}    packet_loss=0
    ...    margin=0.0    direction=ul

Check Non Gbr Traffic Statistic
    [Arguments]    ${expected_throughput_mbps}=210    ${qfi_id}=1
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1
    ...    qfi_id=${qfi_id}
    ...    expected_throughput=${expected_throughput_mbps}    unit=mbps    margin=0.2    direction=dl

Add Profiles For GBR 5QI
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_add_NRDRB_MAC-5.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_add_NRDRB_PDCP-4.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_add_NRDRB-16.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_add_NRDRB_5QI-7.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_add_NRDRB-17.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_add_NRDRB_5QI-8.json

Add Profiles For GBR 5QI ASOE
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_add_NRDRB_MAC-5_ASOE.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_add_NRDRB_PDCP-4.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_add_NRDRB-16_ASOE.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_add_NRDRB_5QI-7_ASOE.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_add_NRDRB-17.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_add_NRDRB_5QI-8.json

Set Discard Timer To Infinity For Gbr
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_set_discardTimer_to_infinity_for_GBR.json

Set Discard Timer To 1500ms For Gbr
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_set_discardTimer_to_1500ms_for_GBR.json.json

Set Discard Timer To 100ms For Gbr
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_set_discardTimer_to_100ms_for_GBR.json.json

Enable ActPdcpRlcBufCongestionMechsm
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_enable_actPdcpRlcBufCongestionMechsm.json
    Sleep    180s
    Wait for gNB Configured state

Enable ActPrioNonVoNRGBRTraffic
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/GBR/delta_enable_actPrioNonVoNRGBRTraffic.json

Increase dlQam256PowerBackoff
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_increase_dlQam256PowerBackoff.json

*** Settings ***
Documentation
...    This file contains keywords used for testing Feature CB008379 on Cloud RINLINE TL.

*** Keywords ***
Attach AiC Ue With Gbr Um 5QI 3
    ${alias}=    Start Tshark For Custom Interface  eth_interface=eth7
    Register Ue With Default Pdu Session
    Modify Pdu Session And Wait For Regexp    ue_id=1    pdu_id=1    qos_id=6    qfi_id=2    5qi_id=3
    Verify Tshark For Single Message    alias=${alias}    packet_filter=${ICS_SETUP_RESP_SUCCESS}
    Stop Tshark    alias=${alias}
    Sleep    3s

Attach AiC Ue With Gbr Am 5QI 4
    ${alias}=    Start Tshark For Custom Interface  eth_interface=eth7
    Register Ue With Default Pdu Session
    Modify Pdu Session And Wait For Regexp    ue_id=1    pdu_id=1    qos_id=7    qfi_id=2    5qi_id=4
    Verify Tshark For Single Message    alias=${alias}    packet_filter=${ICS_SETUP_RESP_SUCCESS}
    Stop Tshark    alias=${alias}
    Sleep    3s

Add AiC Profiles For GBR 5QI
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/GBR/delta_add_NRDRB-16_17_CU.json
    Perform DU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/GBR/delta_add_NRDRB-16_17_DU.json

Enable AiC ActNonVoNRGbrService
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/GBR/delta_enable_actNonVoNRGbrService_CU.json
    Perform DU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/GBR/delta_enable_actNonVoNRGbrService_DU.json

Enable AiC ActPrioNonVoNRGBRTraffic
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/GBR/delta_enable_actPrioNonVoNRGBRTraffic_CU.json
    Perform DU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/GBR/delta_enable_actPrioNonVoNRGBRTraffic_DU.json

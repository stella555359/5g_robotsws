*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    release: 25R3

*** Variables ***
${TRAFFIC_DURATION_SEC_B105}=   10s

*** Keywords ***
CB008490-FB_B105_Inter-gNB_NR-DC_bearer_takeback_triggered_due_to_PDCP_count_rollover_in_SN
    Register Nrdc Ue With Default Pdu Session
    Send A4 Measurement And Trigger Pscell Addition
    Set Expected Message Flow For UE Context Release For UE1
    Start Udp Traffic 100Mbps In DL
    Verify PDCP Count Rollover
    Verify Expected Message Flow For UE Context Release For UE1

Start Udp Traffic 100Mbps In DL
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100
    Sleep    ${TRAFFIC_DURATION_SEC_B105}

Set KeyRefrMarg To Max Value On Gnb2 And Gnb3
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-2_keyRefrMarg_set_to_max.json
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008490/delta_GNB-3_keyRefrMarg_set_to_max.json
    ...    remote_host=${REMOTE_HOST_1_IP}

Verify PDCP Count Rollover
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextModificationRequired
    ...     device=gNB2
    ...     protocol=E1AP
    Verify That Message Fulfills Query
    ...     cause contains (radioNetwork eq 'pPDCP-Count-wrap-around')
    ...     message_alias=BearerContextModificationRequired
    ...     flow_alias=${flow_alias}

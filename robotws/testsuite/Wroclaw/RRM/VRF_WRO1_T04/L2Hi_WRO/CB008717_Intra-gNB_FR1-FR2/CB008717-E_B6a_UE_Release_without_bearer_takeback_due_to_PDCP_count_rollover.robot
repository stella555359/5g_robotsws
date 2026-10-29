*** Settings ***
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Lukasz Filipek (lukasz.filipek@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${TRAFFIC_DURATION_SEC_E_B6a}=   20s

*** Keywords ***
CB008717-E_B6a_UE_Release_without_bearer_takeback_due_to_PDCP_count_rollover
    Register Nrdc Ue With A4
    Set Expected Message Flow For UE Context Release For UE1
    Start Data Traffic for PDCP Count Rollover
    Verify Expected Message Flow For UE Context Release For UE1
    Verify PDCP Count Rollover

    Register Nrdc Ue With A4    ue_id=2    pdu_id=2
    Set Expected Message Flow For UE Context Release For UE2
    Start Data Traffic for PDCP Count Rollover    ue_id=2    pdu_id=2    trf_dir=ul
    Verify Expected Message Flow For UE Context Release For UE2
    Verify PDCP Count Rollover

Register Nrdc Ue With A4
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Set Internal Traffic Type To UEs    ${ue_id}    ${pdu_id}
    Register Ue With Default Pdu Session    ${ue_id}    ${pdu_id}
    Set expected messages flows for A4 measurement based PSCell addition for UE${ue_id}, gNB2
    Send A4 Measurement    ${ue_id}
    Verify expected messages flows for A4 measurement based PSCell addition for UE${ue_id}, gNB2

Start Data Traffic for PDCP Count Rollover
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${trf_dir}=dl
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=${trf_dir} mbps=5
    Sleep    ${TRAFFIC_DURATION_SEC_E_B6a}
    Execute Egate Command    cmd=ue_disp id=1

Set PDCP Count KeyRefrMarg To Max Value
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/CB008717/delta_PDCP_Count_keyRefrMarg_set_to_max.json

Verify PDCP Count Rollover
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextModificationRequired
    ...     device=gNB2
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     cause contains (radioNetwork eq 'pPDCP-Count-wrap-around')
    ...     message_alias=BearerContextModificationRequired
    ...     flow_alias=${flow_alias}

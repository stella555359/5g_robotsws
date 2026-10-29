*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Library    CB008367.py

*** Keywords ***
Check Allocation To Bwp For UEs
    [Arguments]    ${ue_start}    ${ue_stop}    ${bwp_type}
    FOR    ${ue_id}    IN RANGE    ${ue_start}    ${ue_stop}+1
        ${CRNTI_UE}=    Get Ue Crnti    ue_id=${ue_id}
        ${bwp_size}=    Set Variable If
        ...    "${bwp_type}" == "Large"    245
        ...    "${bwp_type}" == "Small"    217
        ${FILTER_UE}=    Catenate    f1ap.C_RNTI ==    ${CRNTI_UE}    && nr-rrc.carrierBandwidth ==${bwp_size}
        Run Keyword If    "${bwp_type}" == "Large"
        ...  Verify Tcpdump Log  packet_filter=${FILTER_UE}  number_of_messages=1
        Run Keyword If    "${bwp_type}" == "Small"
        ...  Verify Tcpdump Log  packet_filter=${FILTER_UE}  number_of_messages=2
    END

Check Successful RRC Setup Completed For UEs
    [Arguments]    ${ue_start}    ${ue_stop}
    FOR    ${ue_id}    IN RANGE    ${ue_start}    ${ue_stop}+1
        ${CRNTI_UE}=    Get Ue Crnti    ue_id=${ue_id}
        ${FILTER_UE}=    Catenate    f1ap.C_RNTI ==    ${CRNTI_UE}    && nr-rrc.rrcSetupComplete_element
        Verify Tcpdump Log  packet_filter=${FILTER_UE}  number_of_messages=1
    END

Check RRC Setup Requests For UEs
    [Arguments]    ${ue_start}    ${ue_stop}
    FOR    ${ue_id}    IN RANGE    ${ue_start}    ${ue_stop}+1
        ${CRNTI_UE}=    Get Ue Crnti    ue_id=${ue_id}
        ${FILTER_UE}=    Catenate    f1ap.C_RNTI ==    ${CRNTI_UE}    && nr-rrc.rrcSetupRequest_element
        Verify Tcpdump Log  packet_filter=${FILTER_UE}  number_of_messages=1
    END

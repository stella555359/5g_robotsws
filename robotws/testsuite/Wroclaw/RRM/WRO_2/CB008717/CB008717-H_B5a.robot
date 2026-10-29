*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS23R1
    ...    CLOUD_5G_I_BOO_AP_LOO

Resource    ../keywords/tshark_verifying.robot
Resource    feature_keywords.robot
Variables   feature_variables.py
Library     KeywordsCB008717.py
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups
Library     taf.ul.ettf.logging



Suite Setup   Run Keywords
...                 Backup And Modify Swconfig File    parameters_list=@{8717_SWCONFIG_FLAGS}
...    AND          Configure Test Environment
                       ...    iphy=${IPHY}
                       ...    scfc=${SCFC}
                       ...    egate=${EGATE}

#Test Setup        Start Default Logging
#Test Teardown     Stop Default Logging

*** Variables ***
${LOGGING_POLICY}=    FULL_POLICY
${IPHY}=              ${CURDIR}/config/CB008717_H/iphy_2c_FR1_n41_FR2_n257.xml
${SCFC}=              SCFC_CB008717_H_B1a.xml
${EGATE}=             ${CURDIR}/config/CB008717_H/2c_FR1_n66_FR2_n257_HB1.cfg

*** Test Cases ***
CB008717_H_B5a_CSI_Is_Reconfigured_When_Allocating_MeasGap_For_NR-DC_Inter-freq_A4_Measurements_After_ICS
    Prepare Flow Check For H_B5A Scenario
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=1    gw_id=1    nwslice=1
    Check If Flow occurred as expected    scenario=HB5a
    Verify F1AP Messages For H_B5A Scenario

*** Keywords ***
Prepare Flow Check For H_B5A Scenario
    feature_keywords.Create gNB And UEs Aliases
    Expect F1AP and NGAP Message Flow For H_B5A Scenario

Expect F1AP and NGAP Message Flow For H_B5A Scenario
    Expect message flow
    ...    gNB:NGAP_InitialContextSetupRequest
    ...    gNB:F1AP_UEContextSetupRequest (CUtoDURRCInformation is present) as UEContextSetupRequest
    ...    gNB:F1AP_UEContextSetupResponse
    ...    gNB:NGAP_InitialContextSetupResponse
    ...    gNB:F1AP_UEContextModificationRequest (CUtoDURRCInformation is present) as UEContextModificationRequest
    ...    gNB:F1AP_UEContextModificationResponse (csi-MeasConfig is present) as UEContextModificationResponse
    ...    gNB:F1AP_DLRRCMessageTransfer
    ...    gNB:F1AP_ULRRCMessageTransfer
    ...    UE_2:NR-RRC_RRCReconfiguration (csi-MeasConfig is present)
    ...    UE_2:NR-RRC_RRCReconfigurationComplete
    ...    alias=NR_DC_FlOW_HB5a
    ...    overall_timeout=600

Verify F1AP Messages For H_B5A Scenario
    Verify Tcpdump Log      ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE_FOR_H_B5A}
    Verify Tcpdump Log      ${F1AP_RRC_RECONFIGURATION_WITH_CSI_MEASCONFIG}


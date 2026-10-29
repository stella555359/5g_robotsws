*** Settings ***
Force Tags    RAN_5G    SBTS00    CRT
    ...    CLOUD_5G_I_BOO_AP_LOO

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/L3_Call.robot
Resource    feature_keywords.robot
Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Variables   feature_variables.py
Library     taf.ul.ettf.setups
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     ta_messaging
Library     ta5g_iphy

Suite Setup    Run Keywords
...                Backup And Modify Swconfig File    parameters_list=@{8717_SWCONFIG_FLAGS}
...    AND         Configure Test Environment
                       ...    iphy=${IPHY}
                       ...    scfc=${SCFC}
                       ...    egate=${EGATE}
...    AND    Create gNB And UEs Aliases

*** Variables ***
${LOGGING_POLICY}=    FULL_POLICY
${IPHY}=              ${CURDIR}/config/CB008717_H/iphy_n66_n257_5CC.xml
${SCFC}=              h_b1e_scf_5cells.xml
${EGATE}=             ${CURDIR}/config/CB008717_H/8717_n66_n257_5CC.cfg

*** Test Cases ***
CB008717_H_B1e_Successful_Configuration_Of_A4_Measurement_For_Any_NR_Frequency
    Prepare Flow Check For H_B1e Scenario
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1    nwslice=1
    Check If Flow occurred as expected    scenario=HB1e
    Verify F1AP Messages For H_B1e Scenario

*** Keywords ***
Prepare Flow Check For H_B1e Scenario
    Expect F1AP and NGAP Message Flow For H_B1e Scenario

Expect F1AP and NGAP Message Flow For H_B1e Scenario
    Expect message flow
    ...    gNB:NGAP_InitialContextSetupRequest
    ...    gNB:F1AP_UEContextSetupRequest (CUtoDURRCInformation is present) as UEContextSetupRequest
    ...    gNB:F1AP_UEContextSetupResponse
    ...    gNB:NGAP_InitialContextSetupResponse
    ...    gNB:F1AP_UEContextModificationRequest (CUtoDURRCInformation is present) as UEContextModificationRequest
    ...    gNB:F1AP_UEContextModificationResponse
    ...    gNB:F1AP_DLRRCMessageTransfer
    ...    gNB:F1AP_ULRRCMessageTransfer
    ...    alias=NR_DC_FlOW_HB1e
    ...    overall_timeout=600

Verify F1AP Messages For H_B1e Scenario
    Verify Tcpdump Log      ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_FOR_H_B1e}
    Verify Tcpdump Log      ${F1AP_DLRRC_MESSAGE_TRANSFER_RRC_RECONFIGURATION_FOR_H_B1e}
    Verify Tcpdump Log      ${F1AP_RRC_RECONFIGURATION_WITH_S_MEASURE_CONFIG}

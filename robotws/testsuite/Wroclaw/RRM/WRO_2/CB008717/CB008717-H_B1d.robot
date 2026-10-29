*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

Resource    ../keywords/tshark_verifying.robot
Resource    feature_keywords.robot
Variables   feature_variables.py
Library     KeywordsCB008717.py
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups
Library     taf.ul.ettf.logging


Suite Setup    Run Keywords    Backup And Modify Swconfig File    parameters_list=@{8717_SWCONFIG_FLAGS}
...            AND     Update And Put Iphy Xml        input_filepath=${CURDIR}/config/CB008717_H/iphy_n66_n257_5CC.xml
...            AND     With Gnb Configuration         commissioning=h_b1d_scf_5cells.xml
...            AND     Wait For Environment To Be Ready

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

Test Setup    With Retry Context    3
...                                 Trigger Site Reset
...                         AND     Wait For Testline Icmp Echo Replies And Ssh Services
...                         AND     Check Radios Availability
...                         AND     With Teardownable
...                                     keyword=Start Default Logging
...                                     teardown=Stop Default Logging
...                         AND     With Simulator Configuration    config=${CURDIR}/config/CB008717_H/8717_n66_n257_5CC.cfg

*** Test Cases ***
CB008717_H_B1d_Alt1_Multiple_A4s_Configured_DRX_Is_Enabled_UE_Is_Independent_Gap_Capable
    Prepare Flow Check For H_B1D Scenario
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1    nwslice=1
    Check If Flow occurred as expected    scenario=HB1d
    Verify F1AP Messages For H_B1D Scenario

*** Keywords ***
Prepare Flow Check For H_B1D Scenario
    feature_keywords.Create gNB And UEs Aliases
    Expect F1AP and NGAP Message Flow For H_B1D Scenario

Expect F1AP and NGAP Message Flow For H_B1D Scenario
    Expect message flow
    ...    gNB:NGAP_InitialContextSetupRequest
    ...    gNB:F1AP_UEContextSetupRequest (CUtoDURRCInformation is present) as UEContextSetupRequest
    ...    gNB:F1AP_UEContextSetupResponse
    ...    gNB:NGAP_InitialContextSetupResponse
    ...    gNB:F1AP_UEContextModificationRequest (CUtoDURRCInformation is present) as UEContextModificationRequest
    ...    gNB:F1AP_UEContextModificationResponse
    ...    gNB:F1AP_DLRRCMessageTransfer
    ...    gNB:F1AP_ULRRCMessageTransfer
    ...    gNB:F1AP_UEContextModificationRequest (DRXCycle is present)
    ...    gNB:F1AP_UEContextModificationResponse (drx-Config is present)
    ...    UE_1:NR-RRC_RRCReconfiguration (drx-Config is present)
    ...    UE_1:NR-RRC_RRCReconfigurationComplete
    ...    alias=NR_DC_FlOW_HB1d
    ...    overall_timeout=600

Verify F1AP Messages For H_B1D Scenario
    Verify Tcpdump Log      ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_FOR_H_B1D}
    Verify Tcpdump Log      ${F1AP_DLRRC_MESSAGE_TRANSFER_RRC_RECONFIGURATION_FOR_H_B1D}
    Verify Tcpdump Log      ${F1AP_RRC_RECONFIGURATION_WITH_S_MEASURE_CONFIG}


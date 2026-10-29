*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :author: Magdalena Mlynarska
...             :contact: magdalena.mlynarska@nokia.com

Resource    taf/ul/ettf/main.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/traffic.robot
Resource    feature_keywords.robot

Library     KeywordsCB008717.py
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups
Variables    ../resources/custom_policy.py

Suite Setup    Run Keywords
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         With Iphy Configuration         config=${iphy_xml}

Test Setup         Run Keywords
...                Enable Tshark Verification
...    AND         With Simulator Configuration    config=${cfg}
...    AND         Setup devices aliases

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B5a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_N_B3a.xml
${ue_id}=                   1
${uec_id}=                  1
${pdu_id}=                  1
${gw_id}=                   1
${pcell_id}=                1
${amf_id}=                  1
${gnb_id}=                  2
@{report_list}             13     14     21    22

*** Test Cases ***
CB008717_N_B3a_NR-DC_A4_measurements_activation_after_PDU_Session_establishment_procedure_completion

    Set expexted messages flow NR-DC A4 meas activation after PDU Session establish proc for UE1, gNB2 and AMF1
    Attach Ue    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Waiting For PDU session establishment
    Verify expexted messages flow NR-DC A4 meas activation after PDU Session establish proc for UE1, gNB2 and AMF1
    Verify messages for NR-DC A4 measurements activation after PDU Session establishment procedure completion
    [Teardown]    Verify that UE was not released for 60 seconds

*** Keywords ***

Waiting For PDU session establishment
    Sleep    2s

Verify messages for NR-DC A4 measurements activation after PDU Session establishment procedure completion
      Verify that UECtxModReq_3 out of 7 SCellToBeSetupList Contains 2 SCells With PLMN "0x134198" and starting_id 16391
      Verify in UEContextModificationResponse that csi-ReportConfigIDs Related To SCells And Bemforming Configuration Are Present in flow alias
      ...     message_alias=UEContextModificationResponse_3       report_list=${report_list}      all=7
      Verify in UECtxModResp_3 out of 7 for UE1 that sCellToAddModList contains 2 sCells with starting phys_id 57
      Verify in RRCReconfiguration that csi-ReportConfigIDs Related To SCells And Bemforming Configuration Are Present in flow alias
      ...     message_alias=RRCReconfiguration_2    report_list=${report_list}      all=3       ue=1
      Verify in RRCReconfig_2 out of 3 for UE1 that sCellToAddModList contains 2 sCells with starting phys_id 57
      Verify in UECtxModReq_4 out of 7 that RRCReconfigurationCompleteIndicator is set to true for gNB2
      Verify A4 measurement report configuration in UECtxtModReq_6 out of 7 for gNB2
      Verify in UECtxtModReq_6 out of 7 that measObjectID 1 is present
      Verify in UECtxtModReq_6 out of 7 that measObjectID 2 is present
      Verify in UECtxtModReq_6 out of 7 that measObjectID 3 is present
      Verify in UECtxtModReq_6 out of 7 that measObjectID 4 is present
      Verify in UECtxModResp_6 out of 7 that measGapConfigIE is present for gNB2
      Verify in RRCReconfig_3 out of 3 for UE1 that MeasConfig contains 4-items in measIdToAddModList
      Verify in UECtxModReq_7 out of 7 that RRCReconfigurationCompleteIndicator is set to true for gNB2

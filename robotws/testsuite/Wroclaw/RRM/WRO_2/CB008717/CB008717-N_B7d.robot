*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
   ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Emilia Godlewska-Lipka
...             :contact: emilia.godlewska-lipka@nokia.com

Resource    taf/ul/ettf/main.robot
Resource    ../keywords/logging.robot
Resource    feature_keywords.robot

Library     KeywordsCB008717.py
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups
Library     testsuite/Wroclaw/RRM/resources/scout_report.py

Variables    ../resources/custom_policy.py

Suite Setup    Run Keywords    Enable C-Plane Debug Logs      with_reboot=${false}
...    AND         Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}

Test Setup    Run Keywords
...                Trigger Site Reset
...    AND         Check Radios Availability
...    AND         Update And Put Iphy Xml         input_filepath=${iphy_xml}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         Enable Tshark Verification
...    AND         With Simulator Configuration    config=${cfg}
...    AND         Setup devices aliases
...    AND         Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}

Test Teardown        Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
...    AND         Add Scout Scf Id To Test Data

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_N_B7d_TC2_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1
${amf_id}=                  1
@{FAULT_IDS}=               6450    4383

*** Test Cases ***
CB008717-N_B7d_ALT_3.1_Releasing_Target_FR1_SCells_in_dequeued_NR-DC_Setup_after_successful_SCell_Change_with_RSRP_combined_for_mixed_mode

    Set Expected Messages Flows For SCell Rele After SCell Change From TDD2CC To FDD1CC for UE1, gNB2 and AMF1
    Attach Ue    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Waiting For PDU Session Establishment
    UE1 Sends A1 Measurement Report id=1 For SCellAddition With RSRP And SRSRP Value Lower Than FDD Threshold
    Waiting For PDU Session Establishment

    UE1 Sends A4 NRDC Measurement Just After A1 SCell Change With RSRP Value Higher Than FDD Threshold

    Verify Expected Messages Flows For SCell Rele After SCell Change From TDD2CC To FDD1CC for UE1, gNB2 and AMF1
    Verify Successfull SCell Addition With SCell Change A1 measurement
    Verify Successfull SCell Change From TDD 2CC CA to FDD 1CC CA
    Verify Successfull FR1 SCell FDD Release After A4 Recived
    Verify Successfull NR-DC Setup After FR1 SCell FDD Release

   Verify that UE was not released for 60 seconds

*** Keywords ***
Verify Successfull SCell Addition With SCell Change A1 measurement
    Verify that UECtxModReq_5 out of 15 SCellToBeSetupList Contains 2 SCells With PLMN "0x134198" and starting_id 16391
    Verify in RRCReconfig_3 out of 6 for UE1 that sCellToAddModList contains 2 sCells with starting phys_id 57
    Verify in RRCReconfiguration_3 out of 6 for UE1 that A1 measurement related to measid-1 is removed
    Verify in RRCReconfig_3 out of 6 if A1 for UE1 report id 3 with measObj 1 and measId 6
    Verify in UECtxModReq_6 out of 15 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_7 out of 15 that GNB-DUConfigurationQuery is set to true for gNB2

Verify Successfull SCell Change From TDD 2CC CA to FDD 1CC CA
    Verify that UECtxModReq_8 out of 15 SCellToBeRemovedList Contains 2 SCells With PLMN "0x134198" and starting_id 16391
    Verify that UECtxModReq_8 out of 15 SCellToBeSetupList Contains 1 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_4 out of 6 for UE1 that sCellToReleaseList contains 2 sCells
    Verify in RRCReconfig_4 out of 6 for UE1 that sCellToAddModList contains 1 sCells with starting phys_id 56
    Verify in RRCReconfiguration_4 out of 6 for UE1 that A1 measurement related to measid-6 is removed
    Verify in UECtxModReq_9 out of 15 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_10 out of 15 that GNB-DUConfigurationQuery is set to true for gNB2

Verify Successfull FR1 SCell FDD Release After A4 Recived
    Verify that UECtxModReq_11 out of 15 SCellToBeRemovedList Contains 1 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_5 out of 6 for UE1 that sCellToReleaseList contains 1 sCells & A4 does not deconfigure
    Verify in RRCReconfig_5 out of 6 if A1 for UE1 report id 4 with measObj 1 and measId 7
    Verify in UECtxModReq_12 out of 15 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_13 out of 15 that GNB-DUConfigurationQuery is set to true for gNB2

Verify Successfull NR-DC setup After FR1 SCell FDD Release
    Verify in UECtxSetupReq_2 out of 2 that PSCell PLMN-"0x134198" and NRCellID-16386 for gNB2
    Verify in UECtxSetupReq_2 out of 2 that ServCellIndex eq 1 for gNB2
    Verify in UEContextSetupRequest_2 out of 2 that 1 DRB is set according to E1AP for gNB2
    Verify in UECtxSetupResp_2 out of 2 that CellGroupID eq 1 & servCellId eq 1 for gNB2 with 1 DRB
    Verify in UEContextSetupResponse_2 out of 2 that 1 DRB is set according to E1AP for gNB2
    Verify that BearerCtxModResp_2 out of 2 with 1 DRB was success for gNB2 for MN context
    Verify in RRCReconfiguration_6 out of 6 for UE1 that MCG modification and SCG setup is present
    Verify in RRCReconfiguration_6 out of 6 for UE1 that A4 measurement related to measid-2 is removed
    Verify in RRCReconfiguration_6 out of 6 for UE1 that A4 measurement related to measid-3 is removed
    Verify in RRCReconfiguration_6 out of 6 for UE1 that A4 measurement related to measid-4 is removed
    Verify in RRCReconfiguration_6 out of 6 for UE1 that A4 measurement related to measid-5 is removed
    Verify in UECtxModReq_15 out of 15 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_15 out of 15 that GNB-DUConfigurationQuery is set to true for gNB2

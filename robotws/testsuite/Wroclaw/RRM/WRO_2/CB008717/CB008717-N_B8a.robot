*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_SA_ECPRI_CMWV_TDD_1CC+NR-DC-SN_ECPRI_MMWV_TDD_8CC

Documentation   :copyright: Nokia
...             :authors: Maciej Grzeszczak, Katarzyna Bandrowska
...             :contact: maciej.grzeszczak@nokia.com

Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource    ../keywords/logging.robot
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
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_N_B8a.xml
${ue_id1}=                  1
${ue_id2}=                  2
${pdu_id}=                  1
${gw_id1}=                  1
${gw_id2}=                  2
${pcell_id}=                1

*** Test Cases ***
CB008717_N_B8a_Blocking_measurements_during_SCell_Addition

    Set expected messages flows for A1 measurement based SCell Addition for FWA UE${ue_id1}, gNB2 and AMF1

    Attach Ue    ue_id=${ue_id1}
    Establish PDU Session    ue_id=${ue_id1}    pdu_id=${pdu_id}    gw_id=${gw_id1}
    Waiting For PDU session enstablishment
    UE1 sends A1 measurement id=1 for SCell Addition

    Verify expected messages flows for A1 measurement based SCell Addition for FWA UE${ue_id1}, gNB2 and AMF1
    Verify Successfull SCell Addition without PCell Switch A1 and PCell Change A2 measurements

    Deregister UE    ${ue_id1}



    Set expected messages flows for A1 measurement based SCell Addition for non FWA UE${ue_id2}, gNB2 and AMF1

    Attach Ue    ue_id=${ue_id2}
    Establish PDU Session    ue_id=${ue_id2}    pdu_id=${pdu_id}    gw_id=${gw_id2}
    Waiting For PDU session enstablishment
    UE2 sends A1 measurement id=1 for SCell Addition

    Verify expected messages flows for A1 measurement based SCell Addition for non FWA UE${ue_id2}, gNB2 and AMF1
    Verify Successfull SCell Addition with PCell Switch A1 and PCell Change A2 measurements

*** Keywords ***
Waiting For PDU session enstablishment
    Sleep    1s

Verify Successfull SCell Addition without PCell Switch A1 and PCell Change A2 measurements
    Verify in RRCReconf_2 out of 3 for UE1 that A4 meas was configured with reportConfigId 2
    Verify that UECtxModReq_5 out of 7 SCellToBeSetupList Contains 3 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_3 out of 3 for UE1 that sCellToAddModList contains 3 sCells with starting phys_id 56
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A1 measurement related to measid-1 is removed
    Verify in RRCReconfig_3 out of 3 if A2 for UE1 report id 3 with measObj 6 and measId 6
    Verify in RRCReconfig_3 out of 3 if A2 for UE1 report id 3 with measObj 7 and measId 7
    Verify in RRCReconfig_3 out of 3 if A2 for UE1 report id 3 with measObj 8 and measId 8
    Verify in RRCReconf_3 out of 3 for UE1 that PCell Switch A1 and PCell Change A2 meas was not configured
    Verify in UECtxModReq_6 out of 7 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_7 out of 7 that GNB-DUConfigurationQuery is set to true for gNB2

Verify Successfull SCell Addition with PCell Switch A1 and PCell Change A2 measurements
    Verify that UECtxModReq_3 out of 5 SCellToBeSetupList Contains 3 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_2 out of 2 for UE2 that sCellToAddModList contains 3 sCells with starting phys_id 56
    Verify in RRCReconfiguration_2 out of 2 for UE2 that A1 measurement related to measid-1 is removed
    Verify in RRCReconfig_2 out of 2 if A2 for UE2 report id 3 with measObj 2 and measId 3
    Verify in RRCReconfig_2 out of 2 if A2 for UE2 report id 3 with measObj 3 and measId 4
    Verify in RRCReconfig_2 out of 2 if A2 for UE2 report id 3 with measObj 4 and measId 5
    Verify in RRCReconfig_2 out of 2 if A1 for UE2 report id 2 with measObj 2 and measId 2
    Verify in RRCReconfig_2 out of 2 if A2 for UE2 report id 4 with measObj 1 and measId 6
    Verify in UECtxModReq_4 out of 5 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_5 out of 5 that GNB-DUConfigurationQuery is set to true for gNB2

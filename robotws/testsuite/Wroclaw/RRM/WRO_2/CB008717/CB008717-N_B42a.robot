*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
   ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :author: Miłosz Komarczewski
...             :contact: milosz.komarczewsk@nokia.com

Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
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

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_sameNRARFCN_n260I_N_B1a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_sameNRARFCN_n260I_BOO_LOO.xml.xml
${scfc}=                    scfc_N_B42a.xml
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1
${uec_id}=                  1

*** Test Cases ***
CB008717_N_B4.2a_Successful_FR1_SCell_Release


    Establish PDU Session With Attache UE    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Waiting For PDU Session Establishment

    Set Expexted Messages Flows For NRDC Setup After FR1 SCell Release After A1 CA On UE1, gNB2, AMF1

    Waiting For Message Flow To Set Up

    UE1 sends A1 measurement report id=1 for SCellAddition with RSRP value lower than FDD threshold
    UE1 sends A4 measurement id=2 for PSCell Addition

    Verify Expexted Messages Flows For NRDC Setup After FR1 SCell Release After A1 CA On UE1, gNB2, AMF1
    Verify Successfull A1 Measurement Based SCell Addition And CA Related Measurement Configuration
    Verify Successfull FR1 SCell Release
    Verify Successfull NRDC Setup After FR1 SCellRelease

    [Teardown]    Deregister UE    ${ue_id}

*** Keywords ***

Verify Successfull A1 Measurement Based SCell Addition And CA Related Measurement Configuration
    Verify that UECtxModReq_1 out of 8 SCellToBeSetupList Contains 1 SCells With PLMN "0x134198" and starting_id 16391
    Verify in RRCReconfig_1 out of 3 for UE1 that sCellToAddModList contains 1 sCells with starting phys_id 57
    Verify in RRCReconfiguration_1 out of 3 for UE1 that A1 for CA related to measid-1 is removed
    Verify in RRCReconfig_1 out of 3 for UE1 that SCell Change A1 and SCell Release A2 and SCell Switch A6 are configured
    Verify in UECtxModReq_2 out of 8 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_3 out of 8 that GNB-DUConfigurationQuery is set to true for gNB2

Verify Successfull FR1 SCell Release
    Verify that UECtxModReq_4 out of 8 SCellToBeRemovedList Contains 1 SCells With PLMN "0x134198" and starting_id 16391
    Verify in RRCReconfig_2 out of 3 for UE1 that sCellToReleaseList contains 1 sCells
    Verify in RRCReconfig_2 out of 3 for UE1 that SCell Addition A1 measurement is configured
    Verify in RRCReconfig_2 out of 3 for UE1 that SCell Change A1 and SCell Release A2 and SCell Switch A6 are deconfigured
    Verify in UECtxModReq_5 out of 8 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_6 out of 8 that GNB-DUConfigurationQuery is set to true for gNB2

Verify Successfull NRDC Setup After FR1 SCellRelease
    Verify that UECtxSetupReq_1 out of 1 is with expected content for PSCELL for gNB2 with 1 DRB
    Verify that UECtxSetupResp_1 out of 1 for 1 PDU session has 1 DRB for gNB2
    Verify that BearerCtxModResp_2 out of 2 with 1 DRB was success for gNB2 for MN context
    Verify that RRCReconfiguration_3 out of 3 was completed for gNB2 and UE1 containing NR-DC setup
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A1 measurement related to measid-9 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-2 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-3 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-4 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-5 is removed
    Verify in UECtxModReq_8 out of 8 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_8 out of 8 that GNB-DUConfigurationQuery is set to true for gNB2






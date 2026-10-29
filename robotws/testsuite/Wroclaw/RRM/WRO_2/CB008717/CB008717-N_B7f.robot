*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
   ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :author: Miłosz Komarczewski
...             :contact: milosz.komarczewsk@nokia.com

Resource    taf/ul/ettf/main.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/traffic.robot
Resource    feature_keywords.robot

Library     KeywordsCB008717.py
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.setups
Library     testsuite/Wroclaw/RRM/resources/scout_report.py

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
...    AND         Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}


*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n41_2xn71_n260I_nb7f.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n41_2xn71_n260I_nb7f.xml
${scfc}=                    scfc_N_B7f.xml
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1
${uec_id}=                  1
@{FAULT_IDS}=               6450    4383

*** Test Cases ***
CB008717_N_B7f_Complete_FR1_SCell_Release_upon_dequeued_NR-DC_A4_MR_handling_after_successful_SCell_Swap_T_F

    Establish PDU Session With Attache UE    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Waiting For PDU Session Establishment
    UE1 sends A1 measurement id=1 for SCell Addition

    Waiting For Message Flow To Set Up
    Set Expexted Messages Flows For NRDC Setup After SCell Swap And FR1 SCell Release On UE1, gNB2, AMF1

    Waiting For Message Flow To Set Up

    UE1 Sends A6 Meas For SCell Swap And Immediately Sends A4 Meas For NR-DC


    Verify Expexted Messages Flows For NRDC Setup After SCell Swap And FR1 SCell Release On UE1, gNB2, AMF1
    Verify Successfull A6 Measurement Based SCell Swap And CA Related Measurement Configuration
    Verify Successfull FR1 SCell Release
    Verify Successfull NRDC Setup After FR1 SCellRelease

    [Teardown]    Run Keywords
    ...           Deregister UE    ${ue_id}
    ...    AND    Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND    Add Scout Scf Id To Test Data

*** Keywords ***

Verify Successfull A6 Measurement Based SCell Swap And CA Related Measurement Configuration
    Verify that UECtxModReq_1 out of 8 SCellToBeSetupList Contains 1 SCells With PLMN "0x134198" and starting_id 16385
    Verify that UECtxModReq_1 out of 8 SCellToBeRemovedList Contains 1 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_1 out of 3 for UE1 that sCellToAddModList contains 1 sCells with starting phys_id 51
    Verify in RRCReconfig_1 out of 3 for UE1 that sCellToReleaseList contains 1 sCells
    Verify in RRCReconfig_1 out of 3 if A2 report id 3 configured for measObjId 6 and measId 6
    Verify in RRCReconfig_1 out of 3 if A6 report id 4 configured for measObjId 6 and measId 7
    Verify in UECtxModReq_2 out of 8 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_3 out of 8 that GNB-DUConfigurationQuery is set to true for gNB2

Verify Successfull FR1 SCell Release
    Verify that UECtxModReq_4 out of 8 SCellToBeRemovedList Contains 1 SCells With PLMN "0x134198" and starting_id 16385
    Verify in RRCReconfig_2 out of 3 for UE1 that sCellToReleaseList contains 1 sCells
    Verify in RRCReconfig_2 out of 3 for UE1 that SCell Addition A1 measurement is configured
    Verify in RRCReconfig_2 out of 3 for UE1 that SCell Release A2 and SCell Switch A6 are deconfigured
    Verify in UECtxModReq_5 out of 8 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_6 out of 8 that GNB-DUConfigurationQuery is set to true for gNB2

Verify Successfull NRDC Setup After FR1 SCellRelease
    Verify that UECtxSetupReq_1 out of 1 is with expected content for PSCELL for gNB2 with 1 DRB
    Verify that UECtxSetupResp_1 out of 1 for 1 PDU session has 1 DRB for gNB2
    Verify that BearerCtxModResp_2 out of 2 with 1 DRB was success for gNB2 for MN context
    Verify that RRCReconfiguration_3 out of 3 was completed for gNB2 and UE1 containing NR-DC setup
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A1 measurement related to measid-8 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-2 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-3 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-4 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-5 is removed
    Verify in UECtxModReq_8 out of 8 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_8 out of 8 that GNB-DUConfigurationQuery is set to true for gNB2

UE1 Sends A6 Meas For SCell Swap And Immediately Sends A4 Meas For NR-DC
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=7 scell=1 scell_rsrp=20 phycell_id=51 nrsrp_nr=90 event=A6
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=2 phycell_id=52 nrsrp_nr=60 event=A4

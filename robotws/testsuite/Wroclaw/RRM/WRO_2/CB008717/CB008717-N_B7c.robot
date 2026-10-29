*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Milosz Dunikowski
...             :contact: milosz.dunikowski@nokia.com

Resource    taf/ul/ettf/main.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/traffic.robot
Resource    feature_keywords.robot

Library     KeywordsCB008717.py
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
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

Test Teardown      Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
...    AND         Add Scout Scf Id To Test Data

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B7.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_n66A_n71A_n41_2A_n260I_BOO_LOO_N_B7c.xml
${ue_id}=                   1
${uec_id}=                  1
${pdu_id}=                  1
${gw_id}=                   1
${pcell_id}=                1
${amf_id}=                  1
@{FAULT_IDS}=               6450    4383

*** Test Cases ***
CB008717-N_B7c_Avoiding_Complete_FR1_SCell_Release_upon_dequeued_NR-DC_Setup_handling_after_successful_SCell_Release

    Establish PDU Session With Attache UE    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Waiting For PDU session enstablishment

    Send Data Traffic In Direction    ue_id=${ue_id}    pdu_id=${pdu_id}    dir=dl    mbps=160    wait=1s
    Send Data Traffic In Direction    ue_id=${ue_id}    pdu_id=${pdu_id}    dir=ul    mbps=160    wait=1s

    Set Expexted Messages Flows For NRDC Setup After FR1 SCell Release Triggered By A2 Measurement On UE1, gNB2, AMF1
    Waiting For Message Flow To Set Up
    UE1 sends A1 measurement id=1 for SCell Addition
    UE Sends A4 NRDC Measurement Just After A2 SCell Release Measurement
    Waiting For Message Flow To Set Up

    Verify Expexted Messages Flows For NRDC Setup After FR1 SCell Release Triggered By A2 Measurement On UE1, gNB2, AMF1
    Verify Successfull SCell Addition after sending A1 measurement
    Verify Successfull SCell Release after sending A2 measurement
    Verify Successfull NRDC Setup After FR1 SCell Release

    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=80Mbps    cell_index_min=0
        ...       direction=dl    cell_group=MCG    selection_type=Average    margin=70%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=40Mbps      cell_index_min=0
        ...       direction=ul    cell_group=MCG    selection_type=Average    margin=70%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=80Mbps    cell_index_min=1
        ...       cell_index_max=1    direction=dl    cell_group=SCG    selection_type=Average    margin=70%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=80Mbps      cell_index_min=1
        ...       cell_index_max=1    direction=ul    cell_group=SCG    selection_type=Average    margin=70%

    Verify that UE was not released for 60 seconds

*** Keywords ***
Verify Successfull SCell Addition after sending A1 measurement
    Verify that UECtxModReq_1 out of 8 SCellToBeSetupList Contains 1 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_1 out of 3 for UE1 that sCellToAddModList contains 1 sCells with starting phys_id 56
    Verify in RRCReconfiguration_1 out of 3 for UE1 that A1 measurement related to measid-1 is removed
    Verify in RRCReconf_1 out of 3 for UE1 that A2 meas was configured with reportConfigId 3
    Verify in UECtxModReq_2 out of 8 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_3 out of 8 that GNB-DUConfigurationQuery is set to true for gNB2

Verify Successfull SCell Release after sending A2 measurement
    Verify that UECtxModReq_4 out of 8 SCellToBeRemovedList Contains 1 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_2 out of 3 for UE1 that sCellToReleaseList contains 1 sCells
    Verify in RRCReconfig_2 out of 3 for UE1 that SCell Addition A1 measurement is configured
    Verify in RRCReconfiguration_2 out of 3 for UE1 that A2 measurement related to measid-6 is removed
    Verify in UECtxModReq_5 out of 8 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_6 out of 8 that GNB-DUConfigurationQuery is set to true for gNB2

Verify Successfull NRDC Setup After FR1 SCell Release
    Verify that UECtxSetupReq_1 out of 1 is with expected content for PSCELL for gNB2 with 1 DRB
    Verify that UECtxSetupResp_1 out of 1 for 1 PDU session has 1 DRB for gNB2
    Verify that BearerCtxModResp_2 out of 2 with 1 DRB was success for gNB2 for MN context
    Verify that RRCReconfiguration_3 out of 3 was completed for gNB2 and UE1 containing NR-DC setup
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A1 measurement related to measid-7 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-2 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-3 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-4 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-5 is removed
    Verify in UECtxModReq_8 out of 8 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_8 out of 8 that GNB-DUConfigurationQuery is set to true for gNB2

Waiting For PDU session enstablishment
    Sleep    2s

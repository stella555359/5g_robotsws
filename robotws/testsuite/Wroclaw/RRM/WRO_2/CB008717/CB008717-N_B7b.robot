*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
   ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Magdalena Mlynarska
...             :contact: magdalena.mlynarska@nokia.com

Resource    taf/ul/ettf/main.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/traffic.robot
Resource    feature_keywords.robot

Library     KeywordsCB008717.py
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups

Library     ta5g_testline_management
Library     ta5g_enb
Library     ta5g_iphy
Library     ute_wtssim
Library     ta5g_ue_mobility
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

Test Teardown        Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
...    AND         Add Scout Scf Id To Test Data


*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_N_B7b.xml
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1
${amf_id}=                  1
${gnb}=                     2
@{FAULT_IDS}=               6450    4383

*** Test Cases ***
CB008717-N_B7b_ALT1_Avoiding_FR1_SCell_Release_in_dequeued_NR-DC_Setup_after_unsuccessful_SCell_Addition

    Attach Ue    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Waiting For PDU Session Establishment
    Waiting For Message Flow To Set Up
    Set Expexted Messages Flows Avoiding FR1 SCellRel In Dequeued NRDC Setup After Unsuccessful SCell Add UE1, gNB2, AMF1
    UE1 sends A1 Measurement id=1 For SCell Addition
    UE1 sends A4 Measurement id=2 For NR-DC Setup Procedure
    Verify NRDC Setup Procedure After Unsuccessfull SCell Addition
    Verify Expexted Messages Flows Avoiding FR1 SCellRel In Dequeued NRDC Setup After Unsuccessful SCell Add UE1, gNB2, AMF1
    Verify A4 And A2 Measurements Reports Were Sent Successfully
    Verify that UE was not released for 60 seconds


*** Keywords ***
Verify A4 And A2 Measurements Reports Were Sent Successfully
    Verify that MeasurementReport_1 out of 2 contains A1 measurement result for UE1 and measId=1
    Verify that MeasurementReport_2 out of 2 contains A4 measurement result for UE1 and measId=2

Verify NRDC Setup Procedure After Unsuccessfull SCell Addition
    Verify in UECtxSetupReq_1 out of 1 that PSCell PLMN-"0x134198" and NRCellID-16386 for gNB2
    Verify in UECtxSetupReq_1 out of 1 that ServCellIndex eq 1 for gNB2
    Verify in UEContextSetupRequest_1 out of 1 that 1 DRB is set according to E1AP for gNB2

    Verify in UECtxSetupResp_1 out of 1 that CellGroupID eq 1 & servCellId eq 1 for gNB2 with 1 DRB
    Verify in UEContextSetupResponse_1 out of 1 that 1 DRB is set according to E1AP for gNB2

    Verify that BearerCtxModResp_2 out of 2 with 1 DRB was success for gNB2 for MN context

    Verify in RRCReconfiguration_1 out of 1 for UE1 that MCG modification and SCG setup is present
    Verify in RRCReconfiguration_1 out of 1 for UE1 that measConfig contains A1 and A4 measurements to be removed

    Verify in UECtxModReq_2 out of 2 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_2 out of 2 that GNB-DUConfigurationQuery is set to true for gNB2

*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_SA_ECPRI_CMWV_TDD_1CC+NR-DC-SN_ECPRI_MMWV_TDD_8CC

Documentation   :copyright: Nokia
...             :authors: Milosz Dunikowski
...             :contact: milosz.dunikowski@nokia.com

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
...    AND         Setup devices aliases

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B5a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_N_B5a.xml
${ue_id}=                   1
${uec_id}=                  1
${pdu_id}=                  1
${gw_id}=                   1
${pcell_id}=                1
${amf_id}=                  1

*** Test Cases ***
CB008717_N_B5a_Blind_SCell_Addition

    Attach Ue    ue_id=${ue_id}
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    Set Scg UL Dist Percent    id=${uec_id}    scg_ul_dist_percent=50
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Waiting For PDU session enstablishment
    Send A4 measurement and verify NR-DC is established after FR1 CA SCell Release    meas_id=1    rrc_id=2    rrc_all=2
    Collect MN and SN gNB IDs
    Send Data Traffic In Direction    ue_id=${ue_id}    pdu_id=${pdu_id}    dir=dl    mbps=160
    Send Data Traffic In Direction    ue_id=${ue_id}    pdu_id=${pdu_id}    dir=ul    mbps=40    wait=30s
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=30Mbps    cell_index_min=0
        ...       direction=dl    cell_group=MCG    selection_type=Average    margin=20%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=22Mbps    cell_index_min=1
        ...       direction=dl    cell_group=MCG    selection_type=Average    margin=20%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=55Mbps    cell_index_min=2
        ...       direction=dl    cell_group=MCG    selection_type=Average    margin=20%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=55Mbps    cell_index_min=3
        ...       direction=dl    cell_group=MCG    selection_type=Average    margin=20%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=40Mbps      cell_index_min=0
        ...       direction=ul    cell_group=MCG    selection_type=Average    margin=20%

    Successfull NR-DC Takeback By Addition Of QoSFlow followed by FR1 CA    SN_gnb_id=${SN_gnb_id}    MN_gnb_id=${MN_gnb_id}
    Verify that AMF1 PDUSessionResModReq_1 out of 1 was send with pDUSessionID=1 with fiveQI=5
    Verify that UECtxModReq_1 out of 1 was send to stop UL and DL DRB data transmission for gNB2 for SN
    Verify that UECtxModResp_1 out of 1 was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify that BearerCtxModReq_1 out of 4 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that BearerCtxModResp_1 out of 4 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that UECtxModReq_1 out of 4 was send with adjustment of MCG configuration upon SCG release for the UE1 for MN
    Verify that UECtxModResp_1 out of 4 was send with confirming modification of MCG for the UE1 for MN
    Verify that RRCReconfiguration_1 out of 1 was send for UE1 to release SCG and reconfigure MCG for 1-DRBs
    Verify that RRCReconfigurationComplete_1 out of 1 was send for UE1
    Verify that UECtxModReq_2 out of 4 was send with request to provide full MCG configuration for gNB2 for MN
    Verify that UECtxModResp_2 out of 4 was send with confirmation of MCG reconfiguration for gNB2 for MN
    Verify that BearerCtxModReq_2 out of 4 was send to release SCG leg with CellGroupID=1 for 1-DRBs for gNB2 for MN
    Verify that BearerCtxModResp_2 out of 4 was send with SCG leg deletion for 1-DRBs for gNB2 for MN
    Verify that UECtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:unspecified for gNB2
    Verify that UECtxReleaseComplete_1 out of 1 was send with confirmation of SCG context deletion for gNB2
    Verify that AMF1 PDUSessionResModResp_1 out of 1 was send with pDUSessionID=1
    Verify in UECtxModReq_5 that after bearer takeback SCellToBeSetupList Contains 3 SCells With PLMN "0x134198" and starting_id 16390
    Verify in MN_UEContextModificationResponse_5 that after takeback with blind FR1 CA csi-ReportConfigIDs Related To SCells And BF Cfg Are Present
    Verify in MN_UEContextModificationResponse_5 that sCellToAddModList contains 3 sCells with starting phys_id 56 after takeback
    Verify in RRCReconfiguration_3 that sCellToAddModList contains 3 sCells with starting phys_id 56 after bearer takeback
    Verify in RRCReconfiguration_3 that csi-ReportConfigIDs Related To SCells And Bemforming Configuration Are Present After Bearer Takeback
    Verify that RRCReconfigurationCompleteIndicator is set to true
    ...      message_alias=UEContextModificationRequest_6    flow_alias=blind_FR1_CA_after_bearer_takeback
    Verify that GNB-DUConfigurationQuery is set to true
    ...      message_alias=UEContextModificationRequest_7    flow_alias=blind_FR1_CA_after_bearer_takeback

    Verify that UE was not released for 60 seconds

*** Keywords ***
Trigger PDU Session Modify Procedure
    [Arguments]     ${ue_id}=1     ${qosflows}=2
    Execute Egate Command     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows}

Collect MN and SN gNB IDs
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_1 out of 5 for gNB2
    ${SN_gnb_id}=    Get SN GNB-CU-UE-F1AP-ID From UeCtxSetupRequest_1 out of 1 for gNB2
    Set Suite Variable    ${MN_gnb_id}
    Set Suite Variable    ${SN_gnb_id}

Waiting For PDU session enstablishment
    Sleep    2s

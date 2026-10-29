*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_PRIVATE_SA_ECPRI_CMWV_TDD_1CC+NR-DC-SN_ECPRI_MMWV_TDD_8CC

Documentation   :copyright: Nokia
...             :authors: Marta Klukas
...             :contact: marta.klukas@nokia.com

Resource    taf/ul/ettf/main.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/traffic.robot
Resource    feature_keywords.robot

Library     KeywordsCB008717.py
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups

Variables    ../resources/custom_policy.py

Suite Setup    Run Keywords    Enable C-Plane Debug Logs      with_reboot=${false}
...    AND         Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND         Wait For Environment To Be Ready

Test Setup      With Retry Context    3
...                Update And Put Iphy Xml         input_filepath=${iphy_xml}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         Enable Tshark Verification
...    AND         With Simulator Configuration    config=${cfg}

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_N_B7a_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1

*** Test Cases ***
CB008717_N_B7a_Complete_FR1_SCell_Release_upon_dequeued_NR-DC_A4_MR_handling_after_successful_SCell_Addition
    Setup devices aliases

    Attach Ue    ue_id=${ue_id}
    Set Scg UL Dist Percent
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    On failure    Verify correct traffic distribution

    Set expected message flow for Complete FR1 SCell Release upon dequeued NRDC A4 MR handling after successful SCell Addition
    UE1 sends A1 measurement for SCell Addition and then immediately A4 measurement for NR-DC PSCell addition

    Verify expected message flow for Complete FR1 SCell Release upon dequeued NRDC A4 MR handling after successful SCell Addition
    Verify Successfull SCell Addition
    Verify Successfull SCell Release
    Verify Successfull NRDC setup

    On failure    Verify correct traffic distribution NRDC

    Verify that UE was not released for 60 seconds

*** Keywords ***
Verify correct traffic distribution
    Send Data Traffic In Direction    ue_id=${ue_id}   pdu_id=${pdu_id}    gw_id=${gw_id}    dir=dl    mbps=160    wait=1
    Send Data Traffic In Direction    ue_id=${ue_id}   pdu_id=${pdu_id}    gw_id=${gw_id}    dir=ul    mbps=28    wait=2
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=33Mbps     cell_index_min=0
        ...       direction=dl    cell_group=MCG    selection_type=Average    margin=50%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=36Mbps     cell_index_min=0
        ...       direction=ul    cell_group=MCG    selection_type=Maximum    margin=50%

Verify correct traffic distribution NRDC
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=60Mbps     cell_index_min=0
        ...       direction=dl    cell_group=MCG    selection_type=Average    margin=60%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=18Mbps     cell_index_min=0
        ...       direction=ul    cell_group=MCG    selection_type=Average    margin=90%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=375Mbps     cell_index_min=1
        ...    cell_index_max=1    direction=dl    cell_group=SCG    selection_type=Average    margin=50%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=40Mbps     cell_index_min=1
        ...    cell_index_max=1    direction=ul    cell_group=SCG    selection_type=Average    margin=70%

UE1 sends A1 measurement for SCell Addition and then immediately A4 measurement for NR-DC PSCell addition
    Execute egate command    cmd=ue_measurement_send_nr id=1 meas_id=1 srsrp_nr=80 event=A1
    Execute egate command    cmd=ue_measurement_send_nr id=1 meas_id=2 phycell_id=52 nrsrp_nr=60 event=A4

Verify Successfull SCell Addition
    Verify that UECtxModReq_1 out of 8 SCellToBeSetupList Contains 3 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_1 out of 3 for UE1 that sCellToAddModList contains 3 sCells with starting phys_id 56
    Verify in RRCReconfig_1 out of 3 for UE1 that A1 for CA related report id 1 and 1 measids are removed
    Verify in RRCReconf_1 out of 3 for UE1 if A2 id 3 is configured for 3 measObjects with startID 6
    Verify in UECtxModReq_2 out of 8 that RRCReconfigurationCompleteIndicator is set to true for gNB2

Verify Successfull SCell Release
    Verify that UECtxModReq_4 out of 8 SCellToBeRemovedList Contains 3 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_2 out of 3 for UE1 that sCellToReleaseList contains 3 sCells & A4 does not deconfigure
    Verify in RRCReconfig_2 out of 3 for UE1 that A2 for CA related report id 3 and 3 measids are removed
    Verify in RRCReconfig_2 out of 3 for UE1 that SCell Addition A1 measurement is configured
    Verify in UECtxModReq_5 out of 8 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_6 out of 8 that GNB-DUConfigurationQuery is set to true for gNB2

Verify Successfull NRDC setup
    Verify that UECtxSetupReq_1 out of 1 is with expected content for PSCELL for gNB2 with 1 DRB
    Verify that UeContextSetupResponse has cellGroupID 1 and servCellIndex 1 and 1 DRB
    Verify that BearerCtxModResp_2 out of 2 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for MN context
    Verify that RRCReconfiguration_3 out of 3 was completed for gNB2 and UE1 containing NR-DC setup
    Verify in RRCReconfiguration_3 out of 3 for UE1 that measConfig contains A1 and A4 measurements to be removed
    Verify in UECtxModReq_8 out of 8 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_8 out of 8 that GNB-DUConfigurationQuery is set to true for gNB2

Set expected message flow for Complete FR1 SCell Release upon dequeued NRDC A4 MR handling after successful SCell Addition
    Set expected message flow     bearerCtxMod=2    uECtxSet=1    uECtxMod=8    rrcReconf=3    rrcReconfCompl=3

Verify expected message flow for Complete FR1 SCell Release upon dequeued NRDC A4 MR handling after successful SCell Addition
    Verify expected message flow    bearerCtxMod=2    uECtxSet=1    uECtxMod=8    rrcReconf=3    rrcReconfCompl=3

Verify that UECtxSetupReq_${msg_num:\d+} out of ${all:\d+} is with expected content for PSCELL for gNB${gnb_id:\d+} with ${drb:\d+} DRB
    Verify in UECtxSetupReq_${msg_num} out of ${all} that ServCellIndex eq 1 for gNB${gnb_id}
    Verify in UECtxSetupReq_${msg_num} out of ${all} that PSCell PLMN-"0x134198" and NRCellID-16386 for gNB${gnb_id}
    Verify in UEContextSetupRequest_${msg_num} out of ${all} that ${drb} DRB is set according to E1AP for gNB${gnb_id}

Verify that UeContextSetupResponse has cellGroupID 1 and servCellIndex 1 and 1 DRB
    Verify in UECtxSetupResp_1 out of 1 that CellGroupID eq 1 for gNB2
    Verify in UECtxSetupResp_1 out of 1 servCellIndex 1, 2 MIMO in UL and 2 MIMO in DL for gNB2
    Verify in UEContextSetupResponse_1 out of 1 that 1 DRB is set according to E1AP for gNB2

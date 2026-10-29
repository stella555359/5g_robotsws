*** Settings ***
Force Tags    CIT    RAN_5G    SBTS00    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation   :copyright: Nokia
...             :authors: Joanna Kutrowska-Girzycka
...             :contact: joanna.kutrowska-girzycka@nokia.com

Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/traffic.robot
Resource    ../keywords/tshark_verifying.robot
Resource    feature_keywords.robot

Library     KeywordsCB008717.py
Library     ta5g_testline_management
Library     ta5g_enb
Library     ta5g_iphy
Library     ute_wtssim
Library     ta5g_ue_mobility
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups

Variables    ../resources/custom_policy.py


Suite Setup    Run Keywords    Enable C-Plane Debug Logs      with_reboot=${false}
...    AND         Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND         Update And Put Iphy Xml         input_filepath=${iphy_xml}
...    AND         With Gnb Configuration          commissioning=${scfc}
Test Setup    Run Keywords
...                Enable Tshark Verification
...    AND         With Simulator Configuration    config=${CURDIR}/config/CB008717_K/TDD_n78A_n257I_K_B1a.cfg

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${iphy_xml}=                ${CURDIR}/config/CB008717_K/iphy_n78_n257_4CC_BOO_LOO.xml
${scfc}=                    scfc_n78_n257_4CC_BOO_LOO.xml
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${current_gw_id}=           1
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1
${capabilityRequestFilter_hex_n78_n257}=    '0x800C04D82000'

*** Test Cases ***
CB008717_K_B1a_Successful_4CC_SCell_Addition_For_FR2_PSCell_During_NR-DC_Establishment_A4_Meas_Based
    Setup devices aliases
    Set expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod

    Attach Ue    ue_id=${ue_id}
    Set Scg UL Dist Percent
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions with only non-GBR QoS flows
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n78, band:n257

    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod

    Verify that BearerCtxModReq_2 out of 3 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for SN context
    Verify that BearerCtxModResp_2 out of 3 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for SN context
    Verify that UECtxSetupReq_2 out of 2 was send for 3-SCells with 1 DRB, BandCombIdx=1 for gNB2
    Verify that UECtxSetupResp_2 out of 2 with 1 DRB, BandCombIdx=1, 3-SCells, MIMO-2 for gNB2

    Verify that BearerCtxModReq_3 out of 3 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for MN context
    Verify that BearerCtxModResp_3 out of 3 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for MN context
    Verify that UECtxModReq_5 out of 6 was completed with BandCombinationIndex=1, allowedFeatureSetsList=1 for gNB2
    Verify that UECtxModResp_5 out of 6 that 2 MIMO in UL and 2 MIMO in DL for gNB2

    Verify that RRCReconfiguration_3 out of 3 was completed for gNB2, UE1, 3-SCells, 2-MIMO and 1 DRB

    Send Data Traffic In Direction    ue_id=${ue_id}    pdu_id=${pdu_id}    dir=dl    mbps=160
    Send Data Traffic In Direction    ue_id=${ue_id}    pdu_id=${pdu_id}    dir=ul    mbps=28
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=150Mbps     cell_index_min=0
        ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=30Mbps     cell_index_min=0
        ...       direction=ul    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=30Mbps   cell_index_min=1
        ...    cell_index_max=4    direction=dl    cell_group=SCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=30Mbps    cell_index_min=1
        ...    cell_index_max=1    direction=ul    cell_group=SCG    selection_type=Average    margin=10%


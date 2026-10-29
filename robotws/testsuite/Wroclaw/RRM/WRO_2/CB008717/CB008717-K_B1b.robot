*** Settings ***
Force Tags    CIT    RAN_5G    SBTS00    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation   :copyright: Nokia
...             :authors: Magdalena Mlynarska
...             :contact: magdalena.mlynarska@nokia.com

Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/tshark_verifying.robot
Resource    feature_keywords.robot
Resource    ../keywords/traffic.robot
Resource    ../keywords/L3_Call.robot

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

Test Setup         Run Keywords
...                Enable Tshark Verification
...    AND         With Simulator Configuration    config=${CURDIR}/config/CB008717_K/FDD_n1A_n257M_K_B1b.cfg


*** Variables ***
${LOGGING_POLICY}=    BASIC_POLICY
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${iphy_xml}=                ${CURDIR}/config/CB008717_K/iphy_n1A_n258M_8CC_BOO_LOO.xml
${scfc}=                    scfc_K_B1b_n1_n257_8CC_BOO_LOO.xml
${current_gw_id}=           1
${ue_id}=     1
${pdu_id}=    1
${gw_id}=     1
${capabilityRequestFilter_hex_n1_n257}=    '0x800C00082000'

*** Test Cases ***
CB008717_K_B1b_Successful_8CC_SCell_Addition_For_FR2_PSCell_During_NR-DC_Establishment_A4_Meas_Based
    Setup devices aliases
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1 with 2-DRB & 8*UECtxMod

    Attach Ue    ue_id=${ue_id}

    Set Scg UL Dist Percent
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}

    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions with only non-GBR QoS flows
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n1, band:n257

    Trigger PDU Session Modify Procedure

    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1 with 2-DRB & 8*UECtxMod

    Verify that BearerCtxModReq_4 out of 5 for PDU-Session-ID-1 with 2 DRB was success for gNB2 for SN context
    Verify that BearerCtxModResp_4 out of 5 for PDU-Session-ID-1 with 2 DRB was success for gNB2 for SN context

    Verify that UECtxSetupReq_2 out of 2 was send for 7-SCells with 2 DRB, BandCombIdx=3 for gNB2
    Verify that UECtxSetupResp_2 out of 2 with 2 DRB, BandCombIdx=3, 7-SCells, MIMO-2 for gNB2

    Verify that BearerCtxModReq_5 out of 5 for PDU-Session-ID-1 with 2 DRB was success for gNB2 for MN context
    Verify that BearerCtxModResp_5 out of 5 for PDU-Session-ID-1 with 2 DRB was success for gNB2 for MN context

    Verify that UECtxModReq_7 out of 8 was completed with BandCombinationIndex=3, allowedFeatureSetsList=1 for gNB2
    Verify that UECtxModResp_7 out of 8 that 2 MIMO in UL and 2 MIMO in DL for gNB2

    Verify that RRCReconfiguration_4 out of 4 was completed for gNB2, UE1, 7-SCells, 2-MIMO and 2 DRB

    On failure    Verify correct traffic distribution

*** Keywords ***
Trigger PDU Session Modify Procedure
    [Arguments]     ${ue_id}=1     ${qosflows}=3
    Wait For Data
    Execute Egate Command     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows}
    Wait For Data

Verify correct traffic distribution
    Send Data Traffic In Direction    ue_id=${ue_id}   pdu_id=${pdu_id}    gw_id=${gw_id}    dir=dl    mbps=160
    Send Data Traffic In Direction    ue_id=${ue_id}   pdu_id=${pdu_id}    gw_id=${gw_id}    dir=ul    mbps=28
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Mbps     cell_index_min=0
        ...       direction=dl    cell_group=MCG    selection_type=Minimum    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Mbps     cell_index_min=0
        ...       direction=ul    cell_group=MCG    selection_type=Minimum    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Mbps     cell_index_min=1
        ...    cell_index_max=8    direction=dl    cell_group=SCG    selection_type=Minimum
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Mbps    cell_index_min=1
        ...    cell_index_max=1    direction=ul    cell_group=SCG    selection_type=Minimum

Wait For Data
    Sleep    3s

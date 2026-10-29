*** Settings ***
Force Tags    RAN_5G    SBTS00    NoResUsage    CRT
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Kornel Dluzniewski
...             :contact: kornel.dluzniewski@nokia.com

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

Suite Setup    Run Keywords
...                Backup And Modify Swconfig File    parameters_list=@{8717_SWCONFIG_FLAGS}
...    AND         Configure Test Environment
                       ...    iphy=${IPHY}
                       ...    scfc=${SCFC}
                       ...    egate=${EGATE}

*** Variables ***
${LOGGING_POLICY}=      BASIC_POLICY
${IPHY}=                ${CURDIR}/config/CB008717_F/iphy_n78A_n257A_BOO_AP_LOO_FB2a.xml
${SCFC}=                scfc_FB1h_BOO_LOO.xml
${EGATE}=               ${CURDIR}/config/CB008717_F/BOO_LOO_FB2_n78_n257.cfg
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${current_gw_id}=           1
${ue_id}=                   1
${uec_id}=                  1
${pdu_id}=                  1
${gw_id}=                   1
${capabilityRequestFilter_hex_n78_n257}=    '0x800C04D82000'


*** Test Cases ***
CB008717_F_B1h_add_modify_QoS_flow_in_PDU_Session_Modification_Request_by_AMF_Partial_RAC_failure

    NRDC Setup
    Prepare A4 measurement based PSCell addition
    Collect GND-IDs from flow to use in parallel execution of bearer takeback
    Send Data Traffic and Verify Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}
    NR-DC Takeback By Adding QoS by AMF Partial RAC failure
        ...    ue_id=1   gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    MN_gnb_id=${MN_gnb_id}
    Verify PDU session is established with one QoS flow and successful A4-based NR-DC etsablishment with FR2
    Execute Egate Command     cmd=ue_deregister id=1 ue_deregister_type=switch_off

    Send Delta Commissioning with maxNumOfNonGBRBearersSA set to 1
    Attach Ue With Establish Pdu Session With Traffic
    Verify UECapability and send A4 measurement
    Send Data Traffic and Verify Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}
    NR-DC Takeback By Adding QoS by AMF Partial RAC failure with 2 Qos Flow
    Verify Modify PDUSession With Cause Radio Resources Not Available

*** Keywords ***
Modify PDU Session with adding 2 Qos
    Execute Egate Command     cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=3,4 by=amf

Collect GND-IDs from flow to use in parallel execution of bearer takeback
    ${SN_gnb_id}=    Get SN GNB-CU-UE-F1AP-ID From UeCtxSetupRequest_2 out of 2 for gNB2
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_6 out of 6 for gNB2
    Set Suite Variable    ${SN_gnb_id}
    Set Suite Variable    ${MN_gnb_id}

Send Delta Commissioning with maxNumOfNonGBRBearersSA set to 1
    Find Scfc and Send Delta Commissioning   scfc_filename=delta_FB1g.json

NRDC Setup
    [Arguments]     ${ue_id}=1     ${uec_id}=1     ${pdu_id}=1     ${gw_id}=1
    Setup devices aliases
    Set expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod
    Attach Ue    ue_id=${ue_id}
    Set Scg UL Dist Percent    id=${uec_id}    scg_ul_dist_percent=50
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}

Attach Ue With Establish Pdu Session With Traffic
    [Arguments]     ${ue_id}=1     ${uec_id}=1     ${pdu_id}=1     ${gw_id}=1
    Attach Ue    ue_id=${ue_id}
    Set Scg UL Dist Percent    id=${uec_id}    scg_ul_dist_percent=50
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}

Prepare A4 measurement based PSCell addition
    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions with only non-GBR QoS flows
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n78, band:n257
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod

Verify UECapability and send A4 measurement
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n78, band:n257
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition

Verify PDU session is established with one QoS flow and successful A4-based NR-DC etsablishment with FR2
    Verify that AMF1 PDUSessionResModReq_1 out of 1 was send with pDUSessionID=1 and fiveQI=5
    Verify that UECtxModReq_1 out of 1 was send to stop UL and DL DRB data transmission for gNB2 for SN
    Verify that UECtxModResp_1 out of 1 was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify that BearerCtxModReq_1 out of 1 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that BearerCtxModResp_1 out of 1 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that UECtxModReq_1 out of 1 was send with adjustment of MCG configuration upon SCG release for the UE1 for MN
    Verify that UECtxModResp_1 out of 1 was send with confirming modification of MCG for the UE1 for MN
    Verify that RRCReconfiguration_1 out of 1 was send for UE1 to release SCG and reconfigure MCG for 1-DRBs
    Verify that RRCReconfigurationComplete_1 out of 1 was send for UE1
    Verify that UECtxModReq_2 out of 4 was send with request to provide full MCG configuration for gNB2 for MN
    Verify that UECtxModResp_2 out of 4 was send with confirmation of MCG reconfiguration for gNB2 for MN
    Verify that BearerCtxModReq_2 out of 4 was send to release SCG leg with CellGroupID=1 for 1-DRBs for gNB2 for MN
    Verify that BearerCtxModResp_2 out of 4 was send with SCG leg deletion for 1-DRBs for gNB2 for MN
    Verify that UECtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:unspecified for gNB2
    Verify that AMF1 PDUSessionResModResp_1 out of 1 was send with pDUSessionID=1

Verify Modify PDUSession With Cause Radio Resources Not Available
    Verify that AMF1 PDUSessionResoModResp_1 out of 1 was send with pDUSessionID=1 and cause:radio-resources-not-available

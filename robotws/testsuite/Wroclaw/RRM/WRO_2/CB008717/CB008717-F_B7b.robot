*** Settings ***
Force Tags    RAN_5G    SBTS00    NoResUsage    CRT
    ...    CLOUD_5G_I_BOO_AP_LOO


Documentation   :copyright: Nokia
...             :authors: Piotr Wisniewski
...             :contact: piotr.wisniewski@nokia.com

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
...    AND    Setup devices aliases

*** Variables ***
${LOGGING_POLICY}=      SYSLOG_POLICY
${IPHY}=                ${CURDIR}/config/CB008717_F/iphy_FB7b_n78A_n257A_1xAEQE_1xAWEUB.xml
${SCFC}=                scfc_n78_n257_F_B7b.xml
${EGATE}=               ${CURDIR}/config/CB008717_F/wts_CB008717_FB7b_n78_n257.cfg
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${current_gw_id}=           1
${ue_id}=                   1
${uec_id}=                  1
${pdu_id}=                  1
${gw_id}=                   1
${qosflows}=                3
${capabilityRequestFilter_hex_n78_n257}=    '0x800C04D82000'

*** Test Cases ***
CB008717_F_B7b_Unsuccessful_reconfiguration_of_BeamRefinement_in_MCG_leg_after_successful_SCG_release_via_takeback
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1 with 2-DRB & 8*UECtxMod
    Establish PDU Session With Attache UE    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Trigger PDU Session Modify Procedure
    Sends A4 measurement for NR-DC PSCell addition
    Verify ICS Procedure with added UECapabilty
    Send Data Traffic and Verify Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}
    Successfull NR-DC Takeback By Deletion of QoS Flow   ue_id=${ue_id}    gnb_id=2    amf_id=1    UeCtxModReq_id=8
    Verify request to delete one of QoS flow and suspends Data Transmission Over SCG
    Verify requests to reconfigure MCG and to release SCG and confirms modification
    Verify MCG and UE reconfiguration and release SCG and confirms modification
    Verify confirms SCG context deletion by sending Radio Network casue and resumes PDU session modification to delete QoS flow
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Mbps    cell_index_min=0
        ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%

*** Keywords ***
Trigger PDU Session Modify Procedure
    [Arguments]     ${ue_id}=1     ${qosflows}=3
    Execute Egate Command     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows}

Trigger PDU Session Modify Procedure By Deletion of QoS Flow
    [Arguments]     ${ue_id}=1     ${qosflows}=3
    Execute Egate Command     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qosflows}

Sends A4 measurement for NR-DC PSCell addition
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1 with 2-DRB & 8*UECtxMod

Verify ICS Procedure with added UECapabilty
    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions with only non-GBR QoS flows
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n78, band:n257

Verify request to delete one of QoS flow and suspends Data Transmission Over SCG
    Verify that AMF1 PDUSessionResModReq_1 out of 1 was send with pDUSessionID=1 and cause:unspecified
    Verify that UECtxModReq_1 out of 1 was send to stop UL and DL DRB data transmission for gNB2 for SN
    Verify that UECtxModResp_1 out of 1 was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify that BearerCtxModReq_1 out of 4 for pDUSessionID=1 with 2 DRBs were send for gNB2 for MN
    Verify that BearerCtxModResp_1 out of 4 for pDUSessionID=1 with 2 DRBs were send for gNB2 for MN

Verify requests to reconfigure MCG and to release SCG and confirms modification
    Verify that UECtxModReq_1 out of 4 was send with adjustment of MCG configuration upon SCG release for the UE1 for MN
    Verify that UECtxModResp_1 out of 4 was send with confirming modification of MCG for the UE1 for MN F_B7b
    Verify that RRCReconfiguration_1 out of 1 was send for UE1 to release SCG&reconfigure MCG for 2-DRBs F_B7b
    Verify that RRCReconfigurationComplete_1 out of 1 was send for UE1

Verify MCG and UE reconfiguration and release SCG and confirms modification
    Verify that UECtxModReq_2 out of 4 was send with request to provide full MCG configuration for gNB2 for MN
    Verify that UECtxModResp_2 out of 4 was send with confirmation of MCG reconfiguration for gNB2 for MN
    Verify that BearerCtxModReq_2 out of 4 was send to release SCG leg with CellGroupID=1 for 2-DRBs for gNB2 for MN
    Verify that BearerCtxModResp_2 out of 4 was send with SCG leg deletion for 2-DRBs for gNB2 for MN

Verify confirms SCG context deletion by sending Radio Network casue and resumes PDU session modification to delete QoS flow
    Verify that UECtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:unspecified for gNB2
    Verify that UECtxReleaseComplete_1 out of 1 was send with confirmation of SCG context deletion for gNB2
    Verify that AMF1 PDUSessionResModResp_1 out of 1 was send with pDUSessionID=1

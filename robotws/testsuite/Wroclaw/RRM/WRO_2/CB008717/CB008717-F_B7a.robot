*** Settings ***
Force Tags    RAN_5G    SBTS00    NoResUsage    CRT
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Piotr Wisniewski
...             :contact: piotr.wisniewski@nokia.com

Resource    testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/reporting_portal.robot
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

Test Teardown     Add Scout External Execution ID To Reporting Portal


*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${LOGS_COMPRESSION}=        ${False}
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${IPHY}=                    ${CURDIR}/config/CB008717_F/iphy_n78A_n257A_AWEUB_BOO_AP_LOO_FS.xml
${SCFC}=                    scfc_F_B7a_n78A_n257A.xml
${EGATE}=                   ${CURDIR}/config/CB008717_F/BOO_LOO_FB7a_n78_n257.cfg
${current_gw_id}=           1
${ue_id}=                   1
${uec_id}=                  1
${pdu_id}=                  1
${gw_id}=                   1
${qosflows}=                3
${capabilityRequestFilter_hex_n78_n257}=    '0x800C04D82000'

*** Test Cases ***
CB008717_F_B7a_Successful_reconfiguration_of_BeamRefinement_in_MCG_leg_after_successful_SCG_release_via_takeback
    Set expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod
    Establish PDU Session With Attache UE    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    NR-DC PSCell addition triggered due to received A4 measurement
    Verify ICS Procedure
    Send Data Traffic and Verify Throughput   ue_id=${ue_id}    pdu_id=${pdu_id}
    Successfull NR-DC Takeback By Addition Of QoSFlow    ue_id=${ue_id}    gnb_id=2    amf_id=1    UeCtxModReq_id=5
    Verify request to add one QoS flow and suspended Data Transmission Over SCG And Confirms Modifications for SN and MN
    Verify requests to reconfigure MCG and to release SCG and confirms modification for MN
    Verify MCG and UE reconfiguration and release SCG and confirms modification for MN
    Verify confirmation of SCG context deletion by sending Radio Network cause and resumes PDU session modification to add QoS flow

*** Keywords ***
NR-DC PSCell addition triggered due to received A4 measurement
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n78, band:n257

Verify ICS Procedure
    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions with only non-GBR QoS flows

Trigger PDU Session Modify Procedure
    [Arguments]     ${ue_id}=1     ${qosflows}=3
    Execute Egate Command     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows}

Verify request to add one QoS flow and suspended Data Transmission Over SCG And Confirms Modifications for SN and MN
    Verify that AMF1 PDUSessionResModReq_1 out of 1 was send with pDUSessionID=1 with fiveQI=5
    Verify that UECtxModReq_1 out of 1 was send to stop UL and DL DRB data transmission for gNB2 for SN
    Verify that UECtxModResp_1 out of 1 was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify that BearerCtxModReq_1 out of 4 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that BearerCtxModResp_1 out of 4 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN

Verify requests to reconfigure MCG and to release SCG and confirms modification for MN
    Verify that UECtxModReq_1 out of 4 was send with adjustment of MCG configuration upon SCG release for the UE1 for MN
    Verify that UECtxModResp_1 out of 4 was sent with confirming modification of MCG for the UE1 for MN with csi-measConfig
    Verify that RRCReconfiguration_FB7a_1 out of 1 was sent for UE1 to release SCG&reconfigure MCG for 1-DRBs
    Verify that RRCReconfigurationComplete_1 out of 1 was send for UE1

Verify MCG and UE reconfiguration and release SCG and confirms modification for MN
    Verify that UECtxModReq_2 out of 4 was send with request to provide full MCG configuration for gNB2 for MN
    Verify that UECtxModResp_2 out of 4 was send with confirmation of MCG reconfiguration for gNB2 for MN
    Verify that BearerCtxModReq_2 out of 4 was send to release SCG leg with CellGroupID=1 for 1-DRBs for gNB2 for MN
    Verify that BearerCtxModResp_2 out of 4 was send with SCG leg deletion for 1-DRBs for gNB2 for MN

Verify confirmation of SCG context deletion by sending Radio Network cause and resumes PDU session modification to add QoS flow
    Verify that UECtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:unspecified for gNB2
    Verify that UECtxReleaseComplete_1 out of 1 was send with confirmation of SCG context deletion for gNB2
    Verify that AMF1 PDUSessionResModResp_1 out of 1 was send with pDUSessionID=1

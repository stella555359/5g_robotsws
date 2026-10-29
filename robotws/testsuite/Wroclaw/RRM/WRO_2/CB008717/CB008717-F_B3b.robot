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
Library     ta5g_pm_counters

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
${LOGGING_POLICY}=      BASIC_POLICY
${IPHY}=                ${CURDIR}/config/CB008717_F/iphy_n78A_n257A_BOO_AP_LOO_FB2a.xml
${SCFC}=                scfc_F_B3a_n78_n257.xml
${EGATE}=               ${CURDIR}/config/CB008717_F/BOO_LOO_FB2_n78_n257.cfg
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${current_gw_id}=           1
${ue_id}=                   1
${uec_id}=                  1
${pdu_id}=                  1
${gw_id}=                   1
${qosflows}=                3
${capabilityRequestFilter_hex_n78_n257}=    '0x800C04D82000'


*** Test Cases ***
CB008717_F_B3b_EXC1_NR-DC_Bearer_Takeback_Triggered_Due_To_Reception_Of_RRC_SCGFailureInformation_interrupted_by_lack_of_RRCReconfigurationComplete
    Set expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod
    Establish PDU Session With Attache UE    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    NR-DC PSCell addition triggered due to received A4 measurement
    Verify ICS Procedure with added UECapabilty
    Send Data Traffic and Verify Throughput   ue_id=${ue_id}    pdu_id=${pdu_id}
    Delay RRCReconfiguration
    Error case NR-DC Bearer Takeback Triggered Due To Reception Of RRC  ue_id=${ue_id}    gnb_id=2    amf_id=1    UeCtxModReq_id=6
    Verify suspended Data Transmission Over SCG And Confirms Modifications for SN and MN
    Verify requests to reconfigure MCG and to release SCG and confirms modification
    Verify UE Context Release procedure triggered by AMF

*** Keywords ***
Triggered RRC By Random Access Problem
    Execute Egate Command     cmd=ue_dc_rlf ue=1 failure_type=random_access_problem at=gnb

Delay RRCReconfiguration
    Execute Egate Command     cmd=ue_nr_rrc_reconf_param id=1 if_contains=any delay=10000

NR-DC PSCell addition triggered due to received A4 measurement
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n78, band:n257

Verify ICS Procedure with added UECapabilty
    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions with only non-GBR QoS flows

Verify suspended Data Transmission Over SCG And Confirms Modifications for SN and MN
    Verify that UECtxModReq_1 out of 1 was send to stop UL and DL DRB data transmission for gNB2 for SN
    Verify that UECtxModResp_1 out of 1 was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify that BearerCtxModReq_1 out of 4 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that BearerCtxModResp_1 out of 4 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN

Verify requests to reconfigure MCG and to release SCG and confirms modification
    Verify that UECtxModReq_1 out of 1 was send to stop UL and DL DRB data transmission for gNB2 for SN
    Verify that UECtxModResp_1 out of 1 was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify that RRCReconfiguration_1 out of 1 was send for UE1 to release SCG and reconfigure MCG for 1-DRBs
    Verify that SCGFailureInformation_1 out of 1 was completed RLF in SCG

Verify UE Context Release procedure triggered by AMF
    Verify that UECtxReleaseRequest_1 out of 1 was send with cause:radioNetwork:radio-connection-with-ue-lost for gNB2
    Verify that UECtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:normal-release for gNB2
    Verify that RRCRelase_1 out of 1 was send for UE1
    Verify that UECtxReleaseComplete_1 out of 2 was send with confirmation of SCG context deletion for gNB2
    Verify that BearerCtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:normal-release for gNB2
    Verify that BearerCtxReleaseComplete_1 out of 1 was send with confirmation of SCG context deletion for gNB2
    Verify that UECtxReleaseComplete_2 out of 2 was send with confirmation of SCG context deletion for gNB2

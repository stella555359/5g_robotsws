*** Settings ***
Force Tags    RAN_5G    SBTS00    NoResUsage    CRT
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD


Documentation   :copyright: Nokia
...             :authors: Dariusz Maciocha
...             :contact: dariusz.maciocha@nokia.com

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
${IPHY}=                    ${CURDIR}/config/CB008717_F/iphy_BOO_AP_LOO_n1_n257.xml
${SCFC}=                    scfc_n1_n257_BOO_LOO_F_B6a.xml
${EGATE}=                   ${CURDIR}/config/CB008717_F/8717_n1_n257_BOO_LOO.cfg
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${current_gw_id}=           1
${ue_id}=                   1
${uec_id}=                  1
${pdu_id}=                  1
${gw_id}=                   1
${capabilityRequestFilter_hex_n1_n257}=    '0x800C00082000'

*** Test Cases ***
CB008717_F_B6b_Exc_NR_DC_Bearer_Takeback_Triggered_Due_To_Lack_Of_Nr_SCG-Response_interrupted_by_external_problem_related_to_MN_context
    Set expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 7*UECtxMod
    Attach Ue    ue_id=${ue_id}
    Set Scg UL Dist Percent
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Verify that PDU session is established and triggered Lack of Nr-SCG-Response IE
    Prepare unsuccessful NR-DC Bearer Takeback By Lack Of Nr-SCG-Response IE
    ...  ue_id=${ue_id}    gnb_id=2    amf_id=1
    Verify expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 7*UECtxMod
    Verify successful NR-DC Bearer takeback by Lack 0f nr-SCG-Response IE in RRCReconfigurationComplete


*** Keywords ***
Trigger Lack of Nr-SCG_Response IE During PSCell Addition Procedure
    Execute Egate Command    cmd=${EGATE_CMD}

Verify that PDU session is established and triggered Lack of Nr-SCG-Response IE
    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions with only non-GBR QoS flows
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n1, band:n257
    Trigger Lack of Nr-SCG_Response IE During PSCell Addition Procedure
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition

Verify successful NR-DC Bearer takeback by Lack 0f nr-SCG-Response IE in RRCReconfigurationComplete
    Unsuccessful NR-DC Bearer Takeback By Lack Of Nr-SCG-Response IE
    Verify that UECtxModReq_1 out of 1 was send to stop UL and DL DRB data transmission for gNB2 for SN
    Verify that UECtxModResp_1 out of 1 was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify that BearerCtxModReq_1 out of 4 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that BearerCtxModResp_1 out of 4 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that UECtxModReq_1 out of 4 was send with adjustment of MCG configuration upon SCG release for the UE1 for MN
    Verify that UECtxModResp_1 out of 4 was send with confirming modification of MCG for the UE1 for MN
    Verify that RRCReconfiguration_1 out of 1 was send for UE1 to release SCG and reconfigure MCG for 1-DRBs
    Verify that UECtxReleaseRequest_1 out of 1 was send with cause:radioNetwork:radio-connection-with-ue-lost for gNB2
    Verify that UECtxReleaseCommand_1 out of 2 was send with cause:radioNetwork:normal-release for gNB2
    Verify that RRCRelase_1 out of 1 was send for UE1
    Verify that Additional UECtxReleaseCommand_2 out of 2 was send with cause:radioNetwork:unspecified to gNB2
    Verify that UECtxReleaseComplete_1 out of 2 was send with confirmation of SCG context deletion for gNB2
    Verify that BearerCtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:normal-release for gNB2
    Verify that BearerCtxReleaseComplete_1 out of 1 was send with confirmation of SCG context deletion for gNB2
    Verify that UECtxReleaseComplete_2 out of 2 was send with confirmation of SCG context deletion for gNB2

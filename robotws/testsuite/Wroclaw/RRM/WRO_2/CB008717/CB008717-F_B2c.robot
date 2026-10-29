*** Settings ***
Force Tags    RAN_5G    SBTS00    NoResUsage    CRT
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Marika Przyleck
...             :contact: marika.przylecka@nokia.com

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
${LOGGING_POLICY}=          SYSLOG_POLICY
${IPHY}=                    ${CURDIR}/config/CB008717_F/iphy_n78A_n257A_BOO_AP_LOO_FB2a.xml
${SCFC}=                    scfc_n78A_n257A_FB2a.xml
${EGATE}=                   ${CURDIR}/config/CB008717_F/BOO_LOO_FB2_n78_n257.cfg
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${current_gw_id}=           1
${ue_id}=                   1
${uec_id}=                  1
${pdu_id}=                  1
${gw_id}=                   1
${capabilityRequestFilter_hex_n78_n257}=    '0x800C04D82000'


*** Test Cases ***
CB008717_F_B2c_EXC3_NRDC_Bearer_Takeback_Triggered_Due_To_RLF_In_SCG_Interruped_By_External_Problem_With_MN_Context
    NRDC Setup
    Prepare Flow Check For FB2c Scenario
    ${SN_gnb_id}=    Get SN GNB-CU-UE-F1AP-ID From UeCtxSetupRequest_2 out of 2 for gNB2
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_6 out of 6 for gNB2
    Send Data Traffic and Verify Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}
    Delay RRCReconfiguration
    NR-DC Takeback RLF With Delay In Sending RRCReconfigurationComplete
        ...    ue_id=1   gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    MN_gnb_id=${MN_gnb_id}
    FB2c Verify Messages

*** Keywords ***
Create RLF Profile
    Execute Egate Command     cmd=rlf_testmode_nr profile_id=6 num_stop_csi_report=1000 num_stop_dlharq_tx=2000

Activation RLF With Delay
    Execute Egate Command     cmd=ue_testmode_set_nr id=1 testmode=rlf action=activate profile_id=6 cell_group=SCG

Delay RRCReconfiguration
    Execute Egate Command     cmd=ue_nr_rrc_reconf_param id=1 if_contains=any delay=10000

NRDC Setup
    [Arguments]     ${ue_id}=1     ${uec_id}=1     ${pdu_id}=1     ${gw_id}=1
    Set expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod
    Create RLF Profile
    Attach Ue    ue_id=${ue_id}
    Set Scg UL Dist Percent    id=${uec_id}    scg_ul_dist_percent=50
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}

Prepare Flow Check For FB2c Scenario
    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions with only non-GBR QoS flows
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n78, band:n257
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod

FB2c Verify Messages
    Verify that UECtxModReq_1 out of 1 was send to stop UL and DL DRB data transmission for gNB2 for SN
    Verify that UECtxModResp_1 out of 1 was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify that BearerCtxModReq_1 out of 1 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that BearerCtxModResp_1 out of 1 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that UECtxModReq_1 out of 1 was send with adjustment of MCG configuration upon SCG release for the UE1 for MN
    Verify that UECtxModResp_1 out of 1 was send with confirming modification of MCG for the UE1 for MN
    Verify that RRCReconfiguration_1 out of 1 was send for UE1 to release SCG and reconfigure MCG for 1-DRBs
    Verify that UECtxReleaseRequest_1 out of 1 was send with cause:radioNetwork:radio-connection-with-ue-lost for gNB2
    Verify that UECtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:normal-release for gNB2
    Verify that RRCRelase_1 out of 1 was send for UE1
    Verify that UECtxReleaseComplete_1 out of 2 was send with confirmation of SCG context deletion for gNB2
    Verify that BearerCtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:normal-release for gNB2
    Verify that BearerCtxReleaseComplete_1 out of 1 was send with confirmation of SCG context deletion for gNB2
    Verify that UECtxReleaseComplete_2 out of 2 was send with confirmation of SCG context deletion for gNB2
    Verify that UECtxModRequired_1 out of 1 was send with cause:radioNetwork:rl-failure-others for gNB2

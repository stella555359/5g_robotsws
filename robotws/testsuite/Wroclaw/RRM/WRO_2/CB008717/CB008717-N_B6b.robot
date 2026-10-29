*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO      VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

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


Suite Setup    Run Keywords
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         With Iphy Configuration         config=${iphy_xml}

Test Setup         Run Keywords
...                Enable Tshark Verification
...    AND         With Simulator Configuration    config=${cfg}
...    AND         Setup devices aliases

Suite Teardown    Run Keyword And Ignore Error    Deregister UE    ${ue_id}


*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_N_B6b.xml
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1
${capabilityRequestFilter_hex_n66_n260}=    '0x801C0418207011A01400'
${ON_FAILURE}=           IGNORE


*** Test Cases ***
CB008717_N_B6b_Starting_DL_data_buffer_monitoring
    Register UE and establish PDU session with one QoS flow
    Collect MN GND-ID from flow to use in parallel execution of bearer takeback
    Verify that PDU session is established with one QoS flow
    Trigger Lack of Nr-SCG_Response IE During PSCell Addition Procedure
    Perform NR-DC setup procedure without nr-SCG response and the following NR-DC bearer takeback
    Verify successful A4-based NR-DC etsablishment with FR2 4CC CA and without nr-SCG response
    Verify successful NR-DC Bearer takeback by lack of nr-SCG-Response IE in RRCReconfigurationComplete and A1 meas addition
    Verify that A1 measurement and BufferMonitoringNotification were sent correctly
    Verify that SCell Addition A1 meas is kept active for UE
    Verify that UE was not released for 60 seconds

*** Keywords ***
Perform NR-DC setup procedure without nr-SCG response and the following NR-DC bearer takeback
    Set expected A4 measurement based PSCell addition messages flows for UE1 gNB2, A1 and A4 meas deconfig
    Set expected message flows for successfull NR-DC Bearer Takeback by lack of nr-SCG-response IE
        ...  ue_id=${ue_id}    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}
    UE1 sends A4 measurement id=2 for NR-DC PSCell addition
    Verify expected A4 measurement based PSCell addition messages flows for UE1 gNB2, A1 and A4 meas deconfig
    Verify expected message flows for successfull NR-DC Bearer Takeback by lack of nr-SCG-response IE

Verify that PDU session is established with one QoS flow
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions with only non-GBR QoS flows
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n66, band:n260
    Verify that RRCReconfiguration_1 out of 2 was correctly sent for band n66, UE1, 1 DRB
    Verify that RRCReconfigurationcomplete_1 out of 2 was send for UE1 in step-by-step message flow
    Verify that BearerCtxSetupReq_1 out of 1 was sent with setup of first DRB for gNB2
    Verify that BearerCtxSetupResp_1 out of 1 was sent with setup of first DRB for gNB2
    Verify that RRCReconfiguration_2 out of 2 was completed for band n260 and UE1
    Verify that RRCReconfigurationcomplete_2 out of 2 was send for UE1 in step-by-step message flow

Trigger Lack of Nr-SCG_Response IE During PSCell Addition Procedure
    Execute Egate Command
    ...  cmd=nr_rrc_reconf_ue_param id=1 if_contains=mrdc_scg_setup action=donot_send_scgNrResponse

Verify successful A4-based NR-DC etsablishment with FR2 4CC CA and without nr-SCG response
    Verify that RRCReconfiguration_1 out of 1 was sent for UE1, 1-DRBs
    Verify that RRCReconfigurationComplete_1 out of 1 for UE1 that message does not contain nr-SCG response

Verify successful NR-DC Bearer takeback by lack of nr-SCG-Response IE in RRCReconfigurationComplete and A1 meas addition
    Verify that UECtxModReq_1 out of 3 was send to stop UL and DL DRB data transmission for gNB2 for SN
    Verify that UECtxModResp_1 out of 3 was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify that BearerCtxModReq_1 out of 2 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that BearerCtxModResp_1 out of 2 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that UECtxModReq_1 out of 3 was send with adjustment of MCG configuration upon SCG release for the UE1 for MN
    Verify that UECtxModResp_1 out of 3 was sent with modification of MCG for the UE1 for MN
    Verify that RRCReconfiguration_1 out of 1 was sent for UE1 for 1-DRB with reconfigured A1 measurement
    Verify that RRCReconfigurationComplete_1 out of 1 was send for UE1
    Verify that UECtxModReq_3 out of 3 was send with request to provide full MCG configuration for gNB2 for MN
    Verify that UECtxModResp_3 out of 3 was send with confirmation of MCG reconfiguration for gNB2 for MN
    Verify that BearerCtxModReq_2 out of 2 was send to release SCG leg with CellGroupID=1 for 1-DRBs for gNB2 for MN
    Verify that BearerCtxModResp_2 out of 2 was send with SCG leg deletion for 1-DRBs for gNB2 for MN
    Verify that UECtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:unspecified for gNB2
    Verify that UECtxReleaseComplete_1 out of 1 was send with confirmation of SCG context deletion for gNB2

Collect MN GND-ID from flow to use in parallel execution of bearer takeback
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_4 out of 4 for gNB2
    Set Suite Variable    ${MN_gnb_id}

Verify that A1 measurement and BufferMonitoringNotification were sent correctly
    Set expected flow for starting DL data buffer monitoring for gNB2
    UE1 sends A1 measurement id=6 for SCell Addition
    Verify expected flow for starting DL data buffer monitoring for gNB2

Verify that SCell Addition A1 meas is kept active for UE
    [Arguments]    ${ue_id}=1  ${EventType}=EventA1
        Execute Egate Command And Wait For Data
        ...          cmd=ue_meas_cfg_disp id=${ue_id}
        ...          pass_regexp=${EventType}

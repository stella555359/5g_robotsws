*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD


Documentation   :copyright: Nokia
...             :authors: Joanna Kutrowska-Girzycka
...             :contact: joanna.kutrowska-girzycka@nokia.com

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

Test Setup         With Retry Context    3
...                Trigger Site Reset
...    AND         Check Radios Availability
...    AND         Enable Tshark Verification
...    AND         With Simulator Configuration    config=${cfg}
...    AND         Setup devices aliases

Suite Teardown    Run Keyword And Ignore Error    Deregister UE    ${ue_id}

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_FK/cfg_FK_n78A_n257M.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_K/iphy_n78_n257_8CC_BOO_LOO.xml
${scfc}=                    scfc_FK_n78A_n257M_BOO_LOO.xml
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1
${capabilityRequestFilter_hex_n78_n257}=    '0x800C04D82000'

*** Test Cases ***
CB008717_FK_B1a_ALT1_NR-DC_Bearer_Takeback_Due_To_Lack_Of_nr-SCG-Response_During_PSCell_Addition_With_CA_In_SCG_And_aCSI_And_Dynamic_BetaOffsets
    Register UE and establish PDU session with one QoS flow
    Verify correct traffic distribution
    Collect MN GND-ID from flow to use in parallel execution of bearer takeback
    Verify that PDU session is established with one QoS flow

    Trigger Lack of Nr-SCG_Response IE During PSCell Addition Procedure
    Perform NR-DC setup procedure without nr-SCG response and the following NR-DC bearer takeback

    Verify successful A4-based NR-DC etsablishment with FR2 8CC CA and without nr-SCG response
    Verify successful NR-DC Bearer takeback by lack of nr-SCG-Response IE in RRCReconfigurationComplete and with aperCSI configuration

    Verify correct traffic distribution after NR-DC takeback
    Verify that UE was not released for 60 seconds

*** Keywords ***
Perform NR-DC setup procedure without nr-SCG response and the following NR-DC bearer takeback
    Set expected A4 measurement based PSCell addition messages flows for UE1 gNB2
    Set expected message flows for successfull NR-DC Bearer Takeback by lack of nr-SCG-response IE
        ...  ue_id=${ue_id}    gnb_id=2    amf_id=1    MN_gnb_id=${MN_gnb_id}
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected A4 measurement based PSCell addition messages flows for UE1 gNB2
    Verify expected message flows for successfull NR-DC Bearer Takeback by lack of nr-SCG-response IE

Verify that PDU session is established with one QoS flow
    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions with only non-GBR QoS flows
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n78, band:n257
    Verify that RRCReconfiguration_1 out of 2 was sent for band n78, UE1, 1 DRB, aperCSi and dynamic betaOffsets
    Verify that RRCReconfigurationcomplete_1 out of 2 was send for UE1 in step-by-step message flow
    Verify that BearerCtxSetupReq_1 out of 1 was sent with setup of first DRB for gNB2
    Verify that BearerCtxSetupResp_1 out of 1 was sent with setup of first DRB for gNB2
    Verify that RRCReconfiguration_2 out of 2 was completed for band n257 and UE1
    Verify that RRCReconfigurationcomplete_2 out of 2 was send for UE1 in step-by-step message flow

Trigger Lack of Nr-SCG_Response IE During PSCell Addition Procedure
    Execute Egate Command
    ...  cmd=nr_rrc_reconf_ue_param id=1 if_contains=mrdc_scg_setup action=donot_send_scgNrResponse

Verify successful A4-based NR-DC etsablishment with FR2 8CC CA and without nr-SCG response
    Verify that BearerCtxModReq_1 out of 2 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for SN context
    Verify that BearerCtxModResp_1 out of 2 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for SN context
    Verify that UECtxSetupReq_1 out of 1 was send for 7-SCells with 1 DRB, BandCombIdx=1 for gNB2
    Verify that UECtxSetupResp_1 out of 1 with 1 DRB, BandCombIdx=1, 7-SCells, MIMO-2 for gNB2
    Verify that BearerCtxModReq_2 out of 2 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for MN context
    Verify that BearerCtxModResp_2 out of 2 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for MN context
    Verify that UECtxModReq_1 out of 2 was completed with BandCombinationIndex=1, allowedFeatureSetsList=1 for gNB2
    Verify that UECtxModResp_1 out of 2 was completed succesfully for gNB2 for aperCSI and semiStatic betaOffsets
    Verify that RRCReconfiguration_1 out of 1 was sent for UE1 7-SCells 1-DRBs aperCSI release semiStatic betaOffsets
    Verify that RRCReconfigurationComplete_1 out of 1 for UE1 that message does not contain nr-SCG response

Verify successful NR-DC Bearer takeback by lack of nr-SCG-Response IE in RRCReconfigurationComplete and with aperCSI configuration
    Verify that UECtxModReq_1 out of 3 was send to stop UL and DL DRB data transmission for gNB2 for SN
    Verify that UECtxModResp_1 out of 3 was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify that BearerCtxModReq_1 out of 2 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that BearerCtxModResp_1 out of 2 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that UECtxModReq_1 out of 3 was send with adjustment of MCG configuration upon SCG release for the UE1 for MN
    Verify that UECtxModResp_1 out of 3 was sent with modification of MCG for the UE1 for MN with aperCSI and dynamic betaOffsets
    Verify that RRCReconfiguration_1 out of 1 was sent for UE1 for 1-DRBs with aperCSI and dynamic betaOffsets
    Verify that RRCReconfigurationComplete_1 out of 1 was send for UE1
    Verify that UECtxModReq_3 out of 3 was send with request to provide full MCG configuration for gNB2 for MN
    Verify that UECtxModResp_3 out of 3 was send with confirmation of MCG reconfiguration for gNB2 for MN
    Verify that BearerCtxModReq_2 out of 2 was send to release SCG leg with CellGroupID=1 for 1-DRBs for gNB2 for MN
    Verify that BearerCtxModResp_2 out of 2 was send with SCG leg deletion for 1-DRBs for gNB2 for MN
    Verify that UECtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:unspecified for gNB2
    Verify that UECtxReleaseComplete_1 out of 1 was send with confirmation of SCG context deletion for gNB2

Verify correct traffic distribution
    Send Data Traffic In Direction    ue_id=${ue_id}   pdu_id=${pdu_id}    dir=dl    mbps=160    wait=1s
    Send Data Traffic In Direction    ue_id=${ue_id}   pdu_id=${pdu_id}    dir=ul    mbps=28     wait=1s
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=1Mbps     cell_index_min=0
        ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=1Mbps     cell_index_min=0
        ...       direction=ul    cell_group=MCG    selection_type=Average    margin=10%

Collect MN GND-ID from flow to use in parallel execution of bearer takeback
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_4 out of 4 for gNB2
    Set Suite Variable    ${MN_gnb_id}

Verify correct traffic distribution after NR-DC takeback
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=100Mbps    cell_index_min=0
        ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Mbps      cell_index_min=0
        ...       direction=ul    cell_group=MCG    selection_type=Average    margin=10%

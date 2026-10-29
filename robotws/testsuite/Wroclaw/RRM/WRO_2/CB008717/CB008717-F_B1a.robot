*** Settings ***
Force Tags    RAN_5G    SBTS00    NoResUsage    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

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
...    AND         Backup And Modify Swconfig File    parameters_list=@{8717_SWCONFIG_FLAGS}

Test Setup    With Retry Context    2
...                Trigger Site Reset
...    AND         Check Radios Availability
...    AND         Update And Put Iphy Xml         input_filepath=${iphy_xml}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         Enable Tshark Verification
...    AND         With Simulator Configuration    config=${CURDIR}/config/CB008717_F/BOO_LOO_FB2_n78_n257.cfg

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${iphy_xml}=                ${CURDIR}/config/CB008717_F/iphy_n78A_n257A_BOO_AP_LOO_FB2a.xml
${scfc}=                    scfc_n78A_n257A_FB2a.xml
&{session_name_to_pdu}=     initial=1       first=1      second=2      third=3      fourth=4
${current_gw_id}=           1
${ue_id}=                   1
${uec_id}=                  1
${pdu_id}=                  1
${gw_id}=                   1
${qosflows}=                3
${capabilityRequestFilter_hex_n78_n257}=    '0x800C04D82000'

*** Test Cases ***
CB008717_F_B1a_NR-DC_Bearer_Takeback_Triggered_Due_To_Modification_Of_PDU_Session_Containing_Split_Bearers
    Setup devices aliases
    Set expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod

    Attach Ue    ue_id=${ue_id}
    Set Scg UL Dist Percent    id=${uec_id}    scg_ul_dist_percent=50
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}

    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions with only non-GBR QoS flows
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n78, band:n257

    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod

    Send Data Traffic In Direction    ue_id=${ue_id}    pdu_id=${pdu_id}    dir=dl    mbps=160
    Send Data Traffic In Direction    ue_id=${ue_id}    pdu_id=${pdu_id}    dir=ul    mbps=28
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=250Mbps    cell_index_min=0
        ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=90Mbps      cell_index_min=1
        ...    cell_index_max=1    direction=dl    cell_group=SCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=40Mbps      cell_index_min=0
        ...       direction=ul    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}   expected_throughput=40Mbps     cell_index_min=1
        ...    cell_index_max=1    direction=ul    cell_group=SCG    selection_type=Average    margin=10%

    Successfull NR-DC Takeback By Addition Of QoSFlow    ue_id=${ue_id}    gnb_id=2    amf_id=1    UeCtxModReq_id=5
    Verify that AMF1 PDUSessionResModReq_1 out of 1 was send with pDUSessionID=1 with fiveQI=5
    Verify that UECtxModReq_1 out of 1 was send to stop UL and DL DRB data transmission for gNB2 for SN
    Verify that UECtxModResp_1 out of 1 was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify that BearerCtxModReq_1 out of 4 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that BearerCtxModResp_1 out of 4 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that UECtxModReq_1 out of 4 was send with adjustment of MCG configuration upon SCG release for the UE1 for MN
    Verify that UECtxModResp_1 out of 4 was send with confirming modification of MCG for the UE1 for MN
    Verify that RRCReconfiguration_1 out of 1 was send for UE1 to release SCG and reconfigure MCG for 1-DRBs
    Verify that RRCReconfigurationComplete_1 out of 1 was send for UE1
    Verify that UECtxModReq_2 out of 4 was send with request to provide full MCG configuration for gNB2 for MN
    Verify that UECtxModResp_2 out of 4 was send with confirmation of MCG reconfiguration for gNB2 for MN
    Verify that BearerCtxModReq_2 out of 4 was send to release SCG leg with CellGroupID=1 for 1-DRBs for gNB2 for MN
    Verify that BearerCtxModResp_2 out of 4 was send with SCG leg deletion for 1-DRBs for gNB2 for MN
    Verify that UECtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:unspecified for gNB2
    Verify that UECtxReleaseComplete_1 out of 1 was send with confirmation of SCG context deletion for gNB2
    Verify that AMF1 PDUSessionResModResp_1 out of 1 was send with pDUSessionID=1


*** Keywords ***
Trigger PDU Session Modify Procedure
    [Arguments]     ${ue_id}=1     ${qosflows}=3
    Execute Egate Command     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows}

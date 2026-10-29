*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage    CLOUD_5G_I_BOO_AP_LOO

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
...    AND         Update And Put Iphy Xml         input_filepath=${iphy_xml}
...    AND         With Gnb Configuration          commissioning=${scfc}

Test Setup         Run Keywords
...                Enable Tshark Verification
...    AND         With Simulator Configuration    config=${cfg}
...    AND         Setup devices aliases

Suite Teardown    Run Keyword And Ignore Error    Deregister UE    ${ue_id}

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_N_B6c.xml
${ue_id}=                   1
${pdu_id}=                  1
${gw_id}=                   1
${gnb_id}=                  2
${amf_id}=                  1
${capabilityRequestFilter_hex_n66_n260}=    '0x801C0418207011A01400'
${ON_FAILURE}=           IGNORE

*** Test Cases ***
CB008717_N_B6c_Handling_of_dequeued_A1_measurement_after_NR-DC_bearer_takeback
    Register UE and establish PDU session with one QoS flow
    Send A4 measurement and verify NR-DC is established    meas_id=2    rrc_id=1    rrc_all=1
    Collect MN and SN gNB IDs
    Send and verify correct traffic distribution
    Trigger sending A1 meas during upcoming takeback
    Successfull NR-DC Takeback RLF followed by FR1 SCell Addition
    ...   ue_id=${ue_id}    gnb_id=${gnb_id}    amf_id=${amf_id}    SN_gnb_id=${SN_gnb_id}    MN_gnb_id=${MN_gnb_id}
    Verify Successfull NR-DC Takeback RLF followed by FR1 SCell Addition
    Verify That Traffic Is Scheduled On All SCells
    Verify that UE was not released for 60 seconds

*** Keywords ***
Verify Successfull NR-DC Takeback RLF followed by FR1 SCell Addition
    Verify that UECtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:rl-failure-others for gNB2
    Verify in UECtxModReq_3 that SCellToBeSetupList Contains 3 SCells With PLMN "0x134198" and starting_id 16390
    Verify in MN_UEContextModificationResponse_3 that sCellToAddModList contains 3 sCells with starting phys_id 56
    Verify in RRCReconfiguration_2 that A1 meas related to measid-6 is removed
    Verify in RRCReconfiguration_2 that measObjToAddModList contains 2 measObj with n41 and startID 7
    Verify in RRCReconfiguration_2 that measObjToAddModList contains 1 measObj with n71 and startID 6
    Verify in RRCReconfiguration_2 if A2 report with id 4 is configured for measObjectId 6 and measId 7
    Verify in RRCReconfiguration_2 if A2 report with id 4 is configured for measObjectId 7 and measId 8
    Verify in RRCReconfiguration_2 if A2 report with id 4 is configured for measObjectId 8 and measId 9
    Verify that RRCReconfigurationCompleteIndicator is set to true
    ...      message_alias=MN_UEContextModificationRequest_4    flow_alias=takeback_and_CA_MN_F1AP
    Verify that GNB-DUConfigurationQuery is set to true
    ...      message_alias=MN_UEContextModificationRequest_5    flow_alias=takeback_and_CA_MN_F1AP

Collect MN and SN gNB IDs
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_1 out of 2 for gNB2
    ${SN_gnb_id}=    Get SN GNB-CU-UE-F1AP-ID From UeCtxSetupRequest_1 out of 1 for gNB2
    Set Suite Variable    ${MN_gnb_id}
    Set Suite Variable    ${SN_gnb_id}

Send and verify correct traffic distribution
    Send Data Traffic In Direction
    Send Data Traffic In Direction    dir=ul   mbps=57
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=1Mbps     cell_index_min=0
        ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=1Mbps     cell_index_min=0
        ...       direction=ul    cell_group=MCG    selection_type=Average    margin=10%
   Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=30Mbps   cell_index_min=1
        ...    direction=dl    cell_group=SCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=30Mbps    cell_index_min=1
        ...    direction=ul    cell_group=SCG    selection_type=Average    margin=10%

Trigger sending A1 meas during upcoming takeback
    Execute Egate Command    cmd=nr_rrc_reconf_param id=1 if_contains=any action=send_complete_and_hex hex=0005000433D2D40400

RLF Profile Activation Trigger Takeback
    Execute Egate Command    cmd=rlf_testmode_nr profile_id=6 num_stop_csi_report=1000 num_stop_dlharq_tx=2000
    Execute Egate Command    cmd=rlf_testmode_nr profile_id=7 num_stop_csi_report=0 num_stop_dlharq_tx=0
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=rlf action=activate profile_id=6 cell_group=SCG
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=rlf action=activate profile_id=7 cell_group=DEFAULT

Successfull NR-DC Takeback RLF followed by FR1 SCell Addition
    [Arguments]    ${ue_id}    ${gnb_id}    ${amf_id}    ${SN_gnb_id}    ${MN_gnb_id}
    Expect Messages for NR-DC Bearer Takeback RLF SN_F1AP
    ...    ue_id=${ue_id}    gnb_id=${gnb_id}    amf_id=${amf_id}    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP_RLF
    Expect Messages for NR-DC Bearer Takeback SN_F1AP
    ...    ue_id=${ue_id}     gnb_id=${gnb_id}    amf_id=1${amf_id}    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback Followed By Scell Addition MN_F1AP
    ...    ue_id=${ue_id}    gnb_id=${gnb_id}    amf_id=${amf_id}    MN_gnb_id=${MN_gnb_id}    alias=takeback_and_CA_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerContextModification
    ...    ue_id=${ue_id}     gnb_id=${gnb_id}    amf_id=${amf_id}    alias=takeback_bearerContextModification
    Expect Messages for RRCReconfiguration in NR-DC Bearer Takeback followed by FR1 SCell Addition
    ...    ue_id=${ue_id}    gnb_id=${gnb_id}    amf_id=${amf_id}     alias=takeback_and_CA_RRCReconfiguration

    RLF Profile Activation Trigger Takeback

    Flow Occurred As Expected    alias=takeback_SN_F1AP_RLF
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_and_CA_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_and_CA_RRCReconfiguration

*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Miłosz Komarczewski
...             :contact: milosz.komarczewski@nokia.com

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
Library     taf.ul.ettf.setups
Library     testsuite/Wroclaw/RRM/resources/scout_report.py

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
...    AND         Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}

Test Teardown    Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
...    AND         Add Scout Scf Id To Test Data

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${iphy_xml}=                ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${scfc}=                    scfc_N_B5b.xml
${ue_id}=                   1
${uec_id}=                  1
${pdu_id}=                  1
${gw_id}=                   1
${gnb_id}=                  2
${amf_id}=                  1
${capabilityRequestFilter_hex_n66_n260}=    '0x801C0418207011A01400'
${ON_FAILURE}=           IGNORE
@{FAULT_IDS}=               6450    4383

*** Test Cases ***
CB008717_N_B5b_Buffer-based_one_shot_SCell_Addition
    Establish PDU Session With Attache UE    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Sleep    2s
    Send A4 measurement and verify NR-DC is established    meas_id=1    rrc_id=1    rrc_all=1
    Collect MN and SN gNB IDs
    Successfull NR-DC Takeback RLF followed by FR1 SCell Addition
    ...   ue_id=${ue_id}    gnb_id=${gnb_id}    amf_id=${amf_id}    SN_gnb_id=${SN_gnb_id}    MN_gnb_id=${MN_gnb_id}
    Verify Successfull NR-DC Takeback RLF followed by FR1 SCell Addition
    Verify that UE was not released for 60 seconds

*** Keywords ***
Verify Successfull NR-DC Takeback RLF followed by FR1 SCell Addition
    Verify that UECtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:rl-failure-others for gNB2
    Verify in UECtxModReq_3 that SCellToBeSetupList Contains 3 SCells With PLMN "0x134198" and starting_id 16390
    Verify in MN_UEContextModificationResponse_3 that csi-ReportConfigIDs Related To SCells And Bemforming Configuration Are Present
    Verify in MN_UEContextModificationResponse_3 that sCellToAddModList contains 3 sCells with starting phys_id 56
    Verify that RRCReconfigurationCompleteIndicator is set to true
    ...      message_alias=MN_UEContextModificationRequest_4    flow_alias=takeback_and_CA_MN_F1AP
    Verify that GNB-DUConfigurationQuery is set to true
    ...      message_alias=MN_UEContextModificationRequest_5    flow_alias=takeback_and_CA_MN_F1AP
    Verify in RRCReconfiguration_2 that csi-ReportConfigIDs Related To SCells And Bemforming Configuration Are Present
    Verify in RRCReconfiguration_2 that sCellToAddModList contains 3 sCells with starting phys_id 56

Collect MN and SN gNB IDs
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_1 out of 2 for gNB2
    ${SN_gnb_id}=    Get SN GNB-CU-UE-F1AP-ID From UeCtxSetupRequest_1 out of 1 for gNB2
    Set Suite Variable    ${MN_gnb_id}
    Set Suite Variable    ${SN_gnb_id}

Trigger RLF For Takeback Purposes
    Execute Egate Command    cmd=rlf_testmode_nr profile_id=6 num_stop_csi_report=1000 num_stop_dlharq_tx=2000
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=rlf action=activate profile_id=6 cell_group=SCG

Successfull NR-DC Takeback RLF followed by FR1 SCell Addition
    [Arguments]    ${ue_id}    ${gnb_id}    ${amf_id}    ${SN_gnb_id}    ${MN_gnb_id}
    Expect Messages for NR-DC Bearer Takeback RLF SN_F1AP
    ...    ue_id=${ue_id}    gnb_id=${gnb_id}    amf_id=${amf_id}    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP_RLF
    Expect Messages for NR-DC Bearer Takeback SN_F1AP
    ...    ue_id=${ue_id}     gnb_id=${gnb_id}    amf_id=1${amf_id}    SN_gnb_id=${SN_gnb_id}    alias=takeback_SN_F1AP
    Expect Messages for NR-DC Bearer Takeback Followed By Buffered Based Scell Addition MN_F1AP
    ...    ue_id=${ue_id}    gnb_id=${gnb_id}    amf_id=${amf_id}    MN_gnb_id=${MN_gnb_id}    alias=takeback_and_CA_MN_F1AP
    Expect Messages for NR-DC Bearer Takeback BearerContextModification
    ...    ue_id=${ue_id}     gnb_id=${gnb_id}    amf_id=${amf_id}    alias=takeback_bearerContextModification
    Expect Messages for RRCReconfiguration in NR-DC Bearer Takeback followed by FR1 SCell Addition
    ...    ue_id=${ue_id}    gnb_id=${gnb_id}    amf_id=${amf_id}     alias=takeback_and_CA_RRCReconfiguration

    Trigger RLF For Takeback Purposes

    Send Data Traffic In Direction For Buffer Filling And Wait For Buffer Filling

    Flow Occurred As Expected    alias=takeback_SN_F1AP_RLF
    Flow Occurred As Expected    alias=takeback_SN_F1AP
    Flow Occurred As Expected    alias=takeback_and_CA_MN_F1AP
    Flow Occurred As Expected    alias=takeback_bearerContextModification
    Flow Occurred As Expected    alias=takeback_and_CA_RRCReconfiguration

Send Data Traffic In Direction For Buffer Filling And Wait For Buffer Filling
    [Arguments]    ${ue_id}=1    ${pdu_id}=1   ${dir}=dl    ${mbps}=160
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=1 dir=${dir} mbps=${mbps}
    Sleep                    10s

*** Settings ***
Force Tags    RAN_5G    SBTS00    NoResUsage    CRT
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Kornel Dluzniewski
...             :contact: kornel.dluzniewski@nokia.com

Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/traffic.robot
Resource    ../keywords/tshark_verifying.robot
Resource    feature_keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/reporting_portal.robot


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
Resource    testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/reporting_portal.robot

Variables    ../resources/custom_policy.py

Suite Setup    Run Keywords
...                Backup And Modify Swconfig File    parameters_list=@{8717_SWCONFIG_FLAGS}
...    AND         Configure Test Environment
                       ...    iphy=${IPHY}
                       ...    scfc=${SCFC}
                       ...    egate=${EGATE}

Test Teardown     Add Scout External Execution ID To Reporting Portal


*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
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
CB008717_F_B1e_Exc3_DC_Bearer_Takeback_Triggered_Due_To_Modifi_Of_PDU_Sess_Containing_Split_Bearer_Interrupted_By_Lack_Of_RRCReconComplet
    Verify Initial PM Counters Before UE Attach
    NRDC Setup
    Prepare A4 measurement based PSCell addition
    ${SN_gnb_id}=    Get SN GNB-CU-UE-F1AP-ID From UeCtxSetupRequest_2 out of 2 for gNB2
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_6 out of 6 for gNB2
    Verify PM Counters Before PDU Session Modify
    Send Data Traffic and Verify Throughput     ue_id=${ue_id}    pdu_id=${pdu_id}
    Drop RRC Message
    Modify PDU Session
    NR-DC Takeback By Adding QoS With Drop RRC Message
        ...    ue_id=1   gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    MN_gnb_id=${MN_gnb_id}
    Verify PM Counters For KF_B2a scenario
    FB1e Verify Messages

*** Keywords ***
Drop RRC Message
    Execute Egate Command     cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=drop

Modify PDU Session
    Execute Egate Command     cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=3


NRDC Setup
    [Arguments]     ${ue_id}=1     ${uec_id}=1     ${pdu_id}=1     ${gw_id}=1
    Setup devices aliases
    Set expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod
    Attach Ue    ue_id=${ue_id}
    Set Scg UL Dist Percent    id=${uec_id}    scg_ul_dist_percent=50
    Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}

Prepare A4 measurement based PSCell addition
    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions with only non-GBR QoS flows
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n78, band:n257
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod

FB1e Verify Messages
    Verify that AMF1 PDUSessionResModReq_1 out of 1 was send with pDUSessionID=1 with fiveQI=5
    Verify that UECtxModReq_1 out of 1 was send to stop UL and DL DRB data transmission for gNB2 for SN
    Verify that UECtxModResp_1 out of 1 was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify that BearerCtxModReq_1 out of 1 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that BearerCtxModResp_1 out of 1 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that UECtxModReq_1 out of 1 was send with adjustment of MCG configuration upon SCG release for the UE1 for MN
    Verify that UECtxModResp_1 out of 1 was send with confirming modification of MCG for the UE1 for MN
    Verify that RRCRelase_1 out of 1 was send for UE1
    Verify that AMF1 PDUSessionResoModResp_1 out of 1 was send with pDUSessionID=1 and cause:radio-connection-with-ue-lost
    Verify that UECtxReleaseRequest_1 out of 1 was send with cause:radioNetwork:radio-connection-with-ue-lost for gNB2
    Verify that UECtxReleaseCommand_1 out of 2 was send cause:radioNetwork:radio-connection-with-ue-lost for gNB2
    Verify that UECtxReleaseCommand_2 out of 2 was send with cause:radioNetwork:normal-release for gNB2
    Verify that UECtxReleaseComplete_1 out of 2 was send with confirmation of SCG context deletion for gNB2
    Verify that UECtxReleaseCommand_2 out of 2 was send with cause:radioNetwork:normal-release for gNB2
    Verify that UECtxReleaseComplete_2 out of 2 was send with confirmation of SCG context deletion for gNB2
    Verify that BearerCtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:normal-release for gNB2
    Verify that BearerCtxReleaseComplete_1 out of 1 was send with confirmation of SCG context deletion for gNB2
    Verify that UECtxReleaseComplete_2 out of 2 was send with confirmation of SCG context deletion for gNB2

Verify PM Counters For KF_B2a scenario
        ${FETCHED_COUNTERS_FILE}=    Get Next Unpacked Raw Pm Counters File
        Verify Last Counters In File
        ...    M55125C09005    1    NG_FLOW_REL_GNB_UE_LOST
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55125C08503    1    NG_FLOW_REL
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55124C03006    1    NRRCC_RRC_RECONF_CMP_TMR
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55113C00001    1    F1_UE_CTXT_MOD_REQ_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55113C00002    1    F1_UE_CTXT_MOD_RESP_RECEIVED
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55113C00501    1    NF1CC_DL_RRC_MSG_TRANSFER
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55113C00502    1    NF1CC_UL_RRC_MSG_TRANSFER
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55124C03001    1    NRRCC_RRC_RECONF_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55135C00505    1    NE1CS_CTXT_MOD_REQ_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55135C00506    1    NE1CS_CTXT_MOD_RSP_RECD
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55117C00001    2    F1_UE_CTXT_MOD_REQ_RECEIVED
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55117C00002    2    F1_UE_CTXT_MOD_RESP_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55117C02001    1    NF1CD_DL_RRC_MSG_TRANSFER
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55117C02002    1    NF1CD_UL_RRC_MSG_TRANSFER
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55133C01004    1    NE1US_CTXT_MOD_REQ_RECD
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55133C01005    1    NE1US_CTXT_MOD_RSP_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
        ...    file_path=${FETCHED_COUNTERS_FILE}

Verify Initial PM Counters Before UE Attach
        ${FETCHED_COUNTERS_FILE}=    Get Next Unpacked Raw Pm Counters File
        Verify Last Counters In File
        ...    M55125C09005    0    NG_FLOW_REL_GNB_UE_LOST
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55125C08503    0    NG_FLOW_REL
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55124C03006    0    NRRCC_RRC_RECONF_CMP_TMR
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55113C00001    0    F1_UE_CTXT_MOD_REQ_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55113C00002    0    F1_UE_CTXT_MOD_RESP_RECEIVED
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55113C00501    0    NF1CC_DL_RRC_MSG_TRANSFER
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55113C00502    0    NF1CC_UL_RRC_MSG_TRANSFER
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55124C03001    0    NRRCC_RRC_RECONF_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55124C03002    0    NRRCC_RRC_RECONF_CMP_RECD
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55135C00505    0    NE1CS_CTXT_MOD_REQ_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55135C00506    0    NE1CS_CTXT_MOD_RSP_RECD
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55117C00001    0    F1_UE_CTXT_MOD_REQ_RECEIVED
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55117C00002    0    F1_UE_CTXT_MOD_RESP_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55117C02001    0    NF1CD_DL_RRC_MSG_TRANSFER
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55117C02002    0    NF1CD_UL_RRC_MSG_TRANSFER
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55133C01004    0    NE1US_CTXT_MOD_REQ_RECD
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55133C01005    0    NE1US_CTXT_MOD_RSP_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
        ...    file_path=${FETCHED_COUNTERS_FILE}

Verify PM Counters Before PDU Session Modify
        ${FETCHED_COUNTERS_FILE}=    Get Next Unpacked Raw Pm Counters File
        Verify Last Counters In File
        ...    M55125C09005    0    NG_FLOW_REL_GNB_UE_LOST
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55125C08503    0    NG_FLOW_REL
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55124C03006    0    NRRCC_RRC_RECONF_CMP_TMR
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55113C00001    6    F1_UE_CTXT_MOD_REQ_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55113C00002    6    F1_UE_CTXT_MOD_RESP_RECEIVED
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55113C00501    9    NF1CC_DL_RRC_MSG_TRANSFER
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55113C00502    11    NF1CC_UL_RRC_MSG_TRANSFER
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55124C03001    3    NRRCC_RRC_RECONF_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55124C03002    3    NRRCC_RRC_RECONF_CMP_RECD
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55135C00505    3    NE1CS_CTXT_MOD_REQ_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55135C00506    3    NE1CS_CTXT_MOD_RSP_RECD
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55117C00001    6    F1_UE_CTXT_MOD_REQ_RECEIVED
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55117C00002    6    F1_UE_CTXT_MOD_RESP_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55117C02001    9    NF1CD_DL_RRC_MSG_TRANSFER
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55117C02002    11    NF1CD_UL_RRC_MSG_TRANSFER
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55133C01004    3    NE1US_CTXT_MOD_REQ_RECD
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
        ...    file_path=${FETCHED_COUNTERS_FILE}
        Verify Last Counters In File
        ...    M55133C01005    3    NE1US_CTXT_MOD_RSP_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
        ...    file_path=${FETCHED_COUNTERS_FILE}


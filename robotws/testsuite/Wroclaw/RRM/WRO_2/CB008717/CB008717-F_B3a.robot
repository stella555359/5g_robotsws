*** Settings ***
Force Tags    RAN_5G    SBTS00    NoResUsage    CRT
    ...    CLOUD_5G_I_BOO_AP_LOO


Documentation   :copyright: Nokia
...             :authors: Kornel Dluzniewski
...             :contact: kornel.dluzniewski@nokia.com

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
${LOGGING_POLICY}=      SYSLOG_POLICY
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
CB008717_F_B3a_Bearer_Takeback_After_Reception_Of_RRC_SCGFailureInformation
    Set expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod
    Establish PDU Session With Attached UE
    Verify ICS Procedure with added UECapabilty
    Sends A4 measurement for NR-DC PSCell addition
    Collect GND-IDs From Flow To Use In Parallel Execution Of Bearer Takeback
    Send Data Traffic and Verify Throughput
    Successfull Expiry Random Access Problem   ue_id=${ue_id}    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    MN_gnb_id=${MN_gnb_id}
    Verify BTS Counters
    Verify Suspends Data Transmission Over SCG And Confirms Modification
    Verify requests to reconfigure MCG and to release SCG and confirms modification
    Verify MCG and UE reconfiguration and release SCG and confirms modification
    Verify confirms SCG context deletion by sending Radio Network cause

*** Keywords ***
Triggered RRC By Random Access Problem
     Execute Egate Command     cmd=ue_dc_rlf ue=1 failure_type=random_access_problem at=gnb

Establish PDU Session With Attached UE
     Attach Ue    ue_id=${ue_id}
     Set Scg UL Dist Percent    id=${uec_id}    scg_ul_dist_percent=50
     Establish Pdu Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}

Sends A4 measurement for NR-DC PSCell addition
     UE1 sends A4 measurement id=1 for NR-DC PSCell addition
     Verify expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod

Verify ICS Procedure with added UECapabilty
     Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
     Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions with only non-GBR QoS flows
     Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n78, band:n257

Collect GND-IDs From Flow To Use In Parallel Execution Of Bearer Takeback
    ${SN_gnb_id}=    Get SN GNB-CU-UE-F1AP-ID From UeCtxSetupRequest_2 out of 2 for gNB2
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_6 out of 6 for gNB2
    Set Suite Variable    ${SN_gnb_id}
    Set Suite Variable    ${MN_gnb_id}

Send Data Traffic and Verify Throughput
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

Verify Suspends Data Transmission Over SCG And Confirms Modification
    Verify that UECtxModReq_1 out of 1 was send to stop UL and DL DRB data transmission for gNB2 for SN
    Verify that UECtxModResp_1 out of 1 was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify that BearerCtxModReq_1 out of 4 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that BearerCtxModResp_1 out of 4 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN

Verify requests to reconfigure MCG and to release SCG and confirms modification
    Verify that UECtxModReq_1 out of 4 was send with adjustment of MCG configuration upon SCG release for the UE1 for MN
    Verify that UECtxModResp_1 out of 4 was send with confirming modification of MCG for the UE1 for MN
    Verify that RRCReconfiguration_1 out of 1 was send for UE1 to release SCG and reconfigure MCG for 1-DRBs
    Verify that SCGFailureInformation_1 out of 1 was completed RLF in SCG
    Verify that RRCReconfigurationComplete_1 out of 1 was send for UE1

Verify MCG and UE reconfiguration and release SCG and confirms modification
    Verify that UECtxModReq_2 out of 4 was send with request to provide full MCG configuration for gNB2 for MN
    Verify that UECtxModResp_2 out of 4 was send with confirmation of MCG reconfiguration for gNB2 for MN
    Verify that BearerCtxModReq_2 out of 4 was send to release SCG leg with CellGroupID=1 for 1-DRBs for gNB2 for MN
    Verify that BearerCtxModResp_2 out of 4 was send with SCG leg deletion for 1-DRBs for gNB2 for MN

Verify confirms SCG context deletion by sending Radio Network cause
    Verify that UECtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:action-desirable-for-radio-reasons for gNB2
    Verify that UECtxReleaseComplete_1 out of 1 was send with confirmation of SCG context deletion for gNB2

Verify BTS Counters
    ${release}    get enb active release name
    IF    '${release}'=='SBTS25R1'
        Verify RD Counters
    ELSE
        Verify Published Counters
    END

Verify RD Counters
    Verify RD PM Counters After NRDC Bearer Takeback

Verify Published Counters
    Verify RD PM Counter After NRDC Bearer Takeback
    Verify PM Counters After SCell Release Due to NRDC Setup


Verify RD PM Counters After NRDC Bearer Takeback
    ${rd_counter_file}=    Get Next Unpacked Raw RD Counters File
    Verify If Latest RD Counter Has Exact Value
        ...    counter_id=SCH_SUBCELL_PUSCH_NRT
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${rd_counter_file}
    Verify If Latest RD Counter Has Exact Value
        ...    counter_id=SCH_SUBCELL_PUSCH_NRT
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${rd_counter_file}
    Verify If Latest RD Counter Has Exact Value
        ...    counter_id=NRDC_MN_CU_SCG_FAIL_RACH
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${rd_counter_file}
    Verify If Latest RD Counter Has Exact Value
        ...    counter_id=NRDC_MN_CU_SCG_FAIL_ALL
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${rd_counter_file}
    Verify If Latest RD Counter Has Exact Value
        ...    counter_id=NRDC_FLOW_MN_INIT_TKBCK_RACH
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${rd_counter_file}
    Verify If Latest RD Counter Has Exact Value
        ...    counter_id=NRDC_IA_MN_CU_REL_REQ
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${rd_counter_file}
    Verify If Latest RD Counter Has Exact Value
        ...    counter_id=NRDC_FLOW_MN_INIT_TKBCK
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${rd_counter_file}

Verify RD PM Counter After NRDC Bearer Takeback
    ${rd_counter_file}=    Get Next Unpacked Raw RD Counters File
    Verify If Latest RD Counter Has Exact Value
        ...    counter_id=SCH_SUBCELL_PUSCH_NRT
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${rd_counter_file}

Verify PM Counters After SCell Release Due to NRDC Setup
    ${pm_counter_file}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55116C00021
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55116C00027
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55116C00032
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55116C00029
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55116C00030
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}


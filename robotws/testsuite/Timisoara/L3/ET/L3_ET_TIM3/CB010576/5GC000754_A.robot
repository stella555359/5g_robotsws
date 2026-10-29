*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    CONFIGURED    CRT
...             RAN_5G_TDD    RAN_5G    PY36
...             NoResUsage

Documentation    :copyright: Nokia
...              :authors: Maciej Katra, Michal Fluder
...              :contact: maciej.katra@nokia.com, michal.fluder@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_testline_management
Library      ta5g_pm_counters
Library      ta5g_iperf_traffic
Variables    ./config/variables.py

Suite Setup    Run Keywords     Reach Onair And Collect Logs
...            lua_cfg=${CURDIR}/../resources/egate_2c_tdd_sansa_FR2_n257.lua
...            output_dirpath=${OUTPUT_DIR}/suite_setup_logs
...            AND              Set Counter Collecting Interval To Five Minutes
...            AND              Wait For Next Full Pm Interval

Suite Teardown    Run Keywords     Stop All Traffics
...               AND              Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords    Deregister Ue Without Confirmation    ue_id=1-3
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Variables ***
${PDU_MOD_FAIL_RADIO_RESOURCES_NOT_AVAILABLE}=    ${RADIO_RESOURCES_NOT_AVAILABLE} && ${NGAP_PDU_SESSION_RESOURCE_MODIFY_RESPONSE}
${PDU_MOD_FAIL_MULTI_PDU_ID_INSTANCES}=    ${MULTIPLE_PDU_SESSION_ID_INSTANCES} && ${NGAP_PDU_SESSION_RESOURCE_MODIFY_RESPONSE}
${PDU_MOD_FAIL_NOT_SUPPORTED_5GQI_VALUE}=     ${NOT_SUPPORTED_5GQI_VALUE} && ${NGAP_PDU_SESSION_RESOURCE_MODIFY_RESPONSE}

*** Test Cases ***
5GC000754_A_Corner_Case_PDU_Session_Modification_Failure_one_or_more_nonGBR_QoS_Flows_couldnt_be_admitted_in_gNB_CU
    [Documentation]     New scenario introduced based on https://jiradc.ext.net.nokia.com/browse/MNRCA-54540
    ...                 Scope of this scenarios is to test PDU session modification failures where there were AMBR modification
    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=1
    ...           AND             Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...                           parameter=maxNumOfNonGBRBearersSA    value=500
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=maxNumOfNonGBRBearersSA    value=3
    Attach UE    ue_id=1
    Establish PDU Session    pdu_id=1    gw_id=1
    Establish PDU Session    pdu_id=2    gw_id=2
    Start Traffic And Check If Average Throughput Is Reached    pdu_gw_id=1    margin=10%
    Stop All Traffics
    Execute Egate Command  cmd=send_hex source=amf:1 target=enb:2 hex=${HEX_SOURCE}
    Verify Ngap Messages   packet_filter=${PDU_MOD_FAIL_RADIO_RESOURCES_NOT_AVAILABLE}
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55125C03503   1    NNGCC_PDUSESMODRSP_FAIL_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

*** Keywords ***
Modify PDU Sessions And Expect Failure
    Modify PDU Session Multi PDU    ue_id=1    pdu_matrix=${PDU_MATRIX_754A_7}
    ...                             pass_regexp=PDU Session Resource Modify Unsuccessful Transfer

Establish Two PDU Sessions For UE
    Establish PDU Session    pdu_id=1    gw_id=1
    Establish PDU Session    pdu_id=2    gw_id=2

Trigger PDU Session Modification Failure And Verify Error
    [Arguments]    ${ue_id}    ${pdu_id}    ${qos_flows}    ${pcap_filter}    ${validation}=off
    Start Traffic And Check If Average Throughput Is Reached    pdu_gw_id=${${ue_id}+1}    margin=10%
    Stop All Traffics
    Modify PDU Session    qos_to_add=${qos_flows}    ue_id=${ue_id}    pdu_id=${pdu_id}    validation=${validation}
    ...                   pass_regexp=PDU Session Resource Modify Unsuccessful Transfer
    Verify Ngap Messages   packet_filter=${pcap_filter}
    Start Traffic And Check If Average Throughput Is Reached    pdu_gw_id=${${ue_id}+1}    margin=10%
    Stop All Traffics

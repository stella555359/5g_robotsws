# *** Settings ***
# Suite Setup    Suite Setup For Aic BTS Env
# Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
# Test Setup    Common Test Setup And Start To Capture Logs Aic
# Test Teardown    Common Test Teardown And Stop Capture Logs Aic
# 
# Documentation    Suite description
# ...   Author: Shen Jianfen
# ...   Contact: jianfen.shen@nokia-sbell.com
# ...   Squad Group: MMW_SG7
# ...   Feature:     CB013052
# 
# Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/resources_aic/DevHZ5_resource_aic_ST.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot
# 
# *** Variables ***
# ${Golden_VDU_SCF_Path}    /home/ute/MN/UTE/robotws/commissionings/HGZ/7_5_UTE5G401T2461/vDU/SCF_vDUCNF00.xml
# ${testline_name}    7_5_UTE5G401T2461
# @{ue_index_list}    0
# 
# ${FAULTS_EXCLUDED_CHECKING}    7311
# 
# ${MRBTS}    ${tl.gnbs[0].dus[0].global_bts_id}
# ${NRBTS}    ${tl.gnbs[0].dus[0].global_bts_id}
# 
# ${EMIL_FLAG}    ${False}
# ${AUTO_ANALYSIS_FLAG}    ${False}
# ${SNAPSHOT_FLAG}    pass:False,fail:False
# 
# ${DEBUG}    ${False}
# 
# @{PM_Counters_CU_Check}
# ...    MRBTS-37440/NRBTS-37440/MCC-262/MNC-03/SST-128/SD-1:${SA_NGBR_DRB_REQ_SLICE}=2
# ...    MRBTS-37440/NRBTS-37440/MCC-262/MNC-03/SST-128/SD-1:${SA_NGBR_DRB_SUCC_SLICE}=2
# ...    MRBTS-37440/NRBTS-37440/MCC-262/MNC-03/SST-128/SD-1:${SA_NGBR_DRB_CU_SUCC_SLICE}=2
# ...    MRBTS-37440/NRBTS-37440/MCC-262/MNC-03/SST-128/SD-1:${NUMBER_OF_SA_SLICE_USERS}=1
# 
# 
# ${SA_NGBR_DRB_REQ_SLICE}    M55149C00002    #The number of non-GBR DRB radio admission requests for SA user, per PLMN, per slice
# ${SA_NGBR_DRB_SUCC_SLICE}    M55149C00003    #The number of radio-admitted non-GBR DRBs for SA user, per PLMN, per slice
# ${SA_NGBR_DRB_CU_SUCC_SLICE}    M55149C00020    #Number of non-GBR DRBs established on successful PDU session establishment for SA user
# ${NUMBER_OF_SA_SLICE_USERS}    M55149C00022
# 
# @{Delta_Disable_13052}
# ...    NRBTS:actSliceSwitchToDefault=false
# 
# @{Delta_Enable_13052}
# ...    NRBTS:actSliceSwitchToDefault=true
# 
# *** Test Cases ***
# CB013052-A-B1_01_Verify_Cloud_SA_TDD_cmWave_initial_context_setup_Succeed_with_unspported_S-NSSAI_when_actSliceSwitchToDefault_enable
#     [Documentation]
#     ...    1. The purpose of this test case is to check following scenarios:
#     ...    This test case is to check SLICE_FALLBACK_SUC which is incremented by 1 at the Step 2 of the RRM user scenario,
#     ...    when gNB-CU-CP shall switch to use default S-NSSAI for the requested PDU session.
#     ...    Configuration:
#     ...    UE:
#     ...        IMSI:262033100010791    SLICE: 0x01:0xd143a5
#     ...    gNB: NRBTS.actSliceSwitchToDefault=true
#     ...        NRPLMN-1:26203; NRPLMN-2:46002; NRPLMN-3:310260
#     ...        SNSSAI-1: 0x01:0xd143a5   NRPLMN-2&NRPLMN-3
#     ...        SNSSAI-2: 0x80:0x1        NRPLMN-2&NRPLMN-1    --default S-NSSAI
#     ...    2. Test Case Steps:
#     ...         a. Make UE-1 Register and Pdu Session Setup with slice-1 0x01:0xd143a5 with PLMN-1 to cell-1, and start DL&UL traffic
#     ...         b. Check wireshark log
#     ...         c. Check counter
#     ...         d. online change NRBTS.actSliceSwitchToDefault to false
#     ...         e. Make UE-1 Register and Pdu Session Setup with slice-1 0x01:0xd143a5 with PLMN-1 to cell-1
#     ...         f. online change NRBTS.actSliceSwitchToDefault to true
#     ...         g. Make UE-1 Register and Pdu Session Setup with slice-1 0x01:0xd143a5 with PLMN-1 to cell-1
#     ...    3. Expected Results:
#     ...         a. UE registers and PDU session is setup successfully.
#     ...         b. check InitialContextSetupRequest and PDUSessionResourceSetupRequest message,
#     ...            the s-NSSAI is not the default SNSSAI-2: 0x80:0x1, is SNSSAI-1: 0x01:0xd143a5.
#     ...         c. M55149C00002, M55149C00003, M55149C00020 value =2, because the UE setup 2 PDU sesssions.
#     ...         d. online change successfully.
#     ...         e. PDU session setup is failure.Check InitialContextSetupFailure message with cause ‘Slice not supported’.
#     ...         f. online change successfully.
#     ...         g. UE registers and PDU session is setup successfully, and the check points are the same as step b.
#     [Tags]    QC_
#     Clear counter file
#     UE Attach And Check Wireshark Log
#     Check Counters Cu Aic    ${PM_Counters_CU_Check}
#     UE Attach And Check Wireshark Log When Disable_13052
#     UE Attach And Check Wireshark Log When Enable_13052
# 
# *** Keywords ***
# Suite Setup For Aic BTS Env
#     [Arguments]    ${scf}=SCF_SBTS00.xml
#     Set Library Search Order     admin
#     Setup BTS Env Aic   scf=${scf}
# 
# Aic Cells Should Be Onair
#     ${onair_status}  Wait Aic BTS Onair And Return Status
#     Run Keyword If  '${onair_status}'=='${False}'    Fail
# 
# Prepare Cell Params
#     Set Test Variable    ${SAVE_LOG_DIRECTORY}     ${TEST_LOG_DIR}
#     ${cell_list}    Get CellsIdList For vDU
#     ${cell_and_peak_info}    Cloud Generate Peak Information with Given Params    cell_id=${cell_list[0]}
#     ...    dl_tp=${100}    ul_tp=${10}    duration=${120}
#     ...    target_avg_percent=0.8    min_percent=0.5
#     [Return]    ${cell_and_peak_info}
# 
# Get CellsIdList For vDU
#     ${cells_id}  create list
#     Get Aic Config Ip And Account Info For Vdu
#     ${du_cells_info}    get_vdu_cells
#     Log    ${du_cells_info}
#     FOR    ${cell}    IN    @{du_cells_info}
#         append to list    ${cells_id}    ${cell}[id]
#     END
#     [Return]    ${cells_id}
# 
# Clear counter file
#     Clear Counter Files Cu Aic    wait=False
#     Clear Counter Files Du Aic    wait=False
# 
# SA Attach UE And Verify Tput
#     ${cell_and_peak_info}    Prepare Cell Params
#     Cloud UE L3 CAll Procedure    ue_index_list=${ue_index_list}    cell_and_peak_info=${cell_and_peak_info}
#     ...    check_wait_time=60    duration=${120}
# 
# Disable 13052
#     Delta Commission Parameters Cu    ${Delta_Disable_13052}
#     object should exist in cu    NRBTS:actSliceSwitchToDefault=false
# 
# Enable 13052
#     Delta Commission Parameters Cu    ${Delta_Enable_13052}
#     object should exist in cu    NRBTS:actSliceSwitchToDefault=true
# 
# Check Wireshark Log When Enable 13052
#     [Arguments]    ${pcap}=cu_cpif_wireshark.pcap
#     BuiltIn.Log To Console    Check Slice in InitialContextSetupRequest message
#     ${filter_ms1}    catenate
#     ...    "ngap.procedureCode == 14 and ngap.pLMNIdentity == 62:f2:30 and ngap.sST == 01 and ngap.sD == d1:43:a5"
#     ${output}    Execute Cmd On Pc    tshark -r ${SAVE_LOG_DIRECTORY}${/}${pcap} -Y ${filter_ms1} | wc -l
#     should be true    ${output}==1
#     BuiltIn.Log To Console    Check Slice in PDUSessionResourceSetupRequest message
#     ${filter_ms2}    catenate
#     ...    "ngap.procedureCode == 29 and ngap.sST == 01 and ngap.sD == d1:43:a5"
#     ${output}    Execute Cmd On Pc    tshark -r ${SAVE_LOG_DIRECTORY}${/}${pcap} -Y ${filter_ms2} | wc -l
#     should be true    ${output}==1
#     BuiltIn.Log To Console    Check Slice in BearerContextSetupRequest message
#     ${filter_ms3}    catenate
#     ...    "e1ap.procedureCode == 8 and e1ap.PLMN_Identity == 62:f2:30 and e1ap.sST == 80 and e1ap.sD == 00:00:01"
#     ${output}    Execute Cmd On Pc    tshark -r ${SAVE_LOG_DIRECTORY}${/}${pcap} -Y ${filter_ms3} | wc -l
#     should be true    ${output}==1
#     BuiltIn.Log To Console    Check Slice in UEContextSetupRequest message
#     ${filter_ms4}    catenate
#     ...    "f1ap.procedureCode == 5 and f1ap.pLMN_Identity == 62:f2:30 and f1ap.sST == 80 and f1ap.sD == 00:00:01"
#     ${output}    Execute Cmd On Pc    tshark -r ${SAVE_LOG_DIRECTORY}${/}${pcap} -Y ${filter_ms4} | wc -l
#     should be true    ${output}==1
# 
# Check Wireshark Log When Disable 13052
#     [Arguments]    ${pcap}=cu_cpif_wireshark_disable_13052.pcap
#     BuiltIn.Log To Console    Check Slice in InitialContextSetupRequest message
#     ${filter_ms1}    catenate
#     ...    "ngap.procedureCode == 14 and ngap.pLMNIdentity == 62:f2:30 and ngap.sST == 01 and ngap.sD == d1:43:a5"
#     ${output}    Execute Cmd On Pc    tshark -r ${SAVE_LOG_DIRECTORY}${/}${pcap} -Y ${filter_ms1} | wc -l
#     should be true    ${output}==2
#     BuiltIn.Log To Console    Check InitialContextSetupFailure,cause=radioNetwork: slice-not-supported(39)
#     ${filter_ms2}    catenate
#     ...    "ngap.procedureCode == 14 and ngap.radioNetwork == 39"
#     ${output}    Execute Cmd On Pc    tshark -r ${SAVE_LOG_DIRECTORY}${/}${pcap} -Y ${filter_ms2} | wc -l
#     should be true    ${output}==2
# 
# UE Attach And Check Wireshark Log
#     Start To Capture Wireshark Log Aic    tag=enbale_13052_via_full
#     SA Attach UE And Verify Tput
#     Stop Capture Wireshark Log Aic    tag=enbale_13052_via_full
# #    Check Wireshark Log Aic    ${CURDIR}${/}a2a_B1_01${/}a2a.ini    wait_string=UEContextReleaseComplete::4
#     Check Wireshark Log When Enable 13052    pcap=cu_cpif_wireshark_enbale_13052_via_full.pcap
# 
# UE Attach And Check Wireshark Log When Disable_13052
#     Disable 13052
#     Start To Capture Wireshark Log Aic    tag=disable_13052
#     #below step "SA Attach UE And Verify Tput" should be failed due to unsupport slice
#     Run Keyword And Ignore Error    SA Attach UE And Verify Tput
#     Stop Capture Wireshark Log Aic    tag=disable_13052
# #    Check Wireshark Log Aic    ${CURDIR}${/}a2a_B1_01${/}a2a_disable.ini    name=disable_13052    wait_string=UEContextReleaseComplete::8
#     Check Wireshark Log When Disable 13052    pcap=cu_cpif_wireshark_disable_13052.pcap
#     Simple Ue Detach    ue_index_list=${ue_index_list}
# 
# UE Attach And Check Wireshark Log When Enable_13052
#     Enable 13052
#     Start To Capture Wireshark Log Aic    tag=enable_13052
#     SA Attach UE And Verify Tput
#     Stop Capture Wireshark Log Aic    tag=enable_13052
# #    Check Wireshark Log Aic    ${CURDIR}${/}a2a_B1_01${/}a2a_enable.ini    name=enable_13052    wait_string=UEContextReleaseComplete::4
#     Check Wireshark Log When Enable 13052    pcap=cu_cpif_wireshark_enable_13052.pcap

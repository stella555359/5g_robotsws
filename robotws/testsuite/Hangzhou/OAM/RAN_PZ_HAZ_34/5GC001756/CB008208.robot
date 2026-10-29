*** Settings ***
Documentation
...  author: Jiang Shengyuan
...  contact: shengyuan.jiang@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   ./Resource/Common.robot

Force Tags   SG_07   CA_5G_OAM   CRT   master_classicalbts_all
...   5G_RAN_TDD   STATE_SW_UPLOADED
...    PY36
...   AUTHOR_yin.4.chen@nokia-sbell.com

Test Timeout   16h

Suite Setup   Common Suite Setup
Suite Teardown   Common Suite Teardown

Test Setup   Case Common Setup
Test Teardown   Case Common Teardown

*** Variables ***
${NSA_INTRA_gNB_HO_FILE}   NSA_INTRA_gNB_HO.pcap
${NSA_INTER_gNB_HO_TARGET_FILE}   NSA_INTER_gNB_HO_TARGET.pcap
${NSA_INTER_gNB_HO_SOURCE_FILE}   NSA_INTER_gNB_HO_SOURCE.pcap
${INTRA_MeNB_HO_gNB_FILE}   INTRA_MeNB_HO_gNB.pcap
${SA_INTRA_gNB_HO_FILE}   SA_INTRA_gNB_HO.pcap
${SA_INTER_gNB_HO_TARGET_FILE}   SA_INTER_gNB_HO_TARGET.pcap
${SA_INTER_gNB_HO_SOURCE_FILE}   SA_INTER_gNB_HO_SOURCE.pcap
${NSA_Normal_Call_FILE}   NSA_Normal_Call.pcap
${NSA_INTER_MeNB_HO_FILE}   NSA_INTER_MeNB_HO.pcap

${NSA_INTRA_gNB_HO_PATH}   ${OUTPUT_DIR}/${NSA_INTRA_gNB_HO_FILE}
${NSA_INTER_gNB_HO_TARGET_PATH}   ${OUTPUT_DIR}/${NSA_INTER_gNB_HO_TARGET_FILE}
${NSA_INTER_gNB_HO_SOURCE_PATH}   ${OUTPUT_DIR}/${NSA_INTER_gNB_HO_SOURCE_FILE}
${INTRA_MeNB_HO_gNB_PATH}   ${OUTPUT_DIR}/${INTRA_MeNB_HO_gNB_FILE}
${SA_INTRA_gNB_HO_PATH}   ${OUTPUT_DIR}/${SA_INTRA_gNB_HO_FILE}
${SA_INTER_gNB_HO_TARGET_PATH}   ${OUTPUT_DIR}/${SA_INTER_gNB_HO_TARGET_FILE}
${SA_INTER_gNB_HO_SOURCE_PATH}   ${OUTPUT_DIR}/${SA_INTER_gNB_HO_SOURCE_FILE}
${NSA_Normal_Call_PATH}   ${OUTPUT_DIR}/${NSA_Normal_Call_FILE}
${NSA_INTER_MeNB_HO_PATH}   ${OUTPUT_DIR}/${NSA_INTER_MeNB_HO_FILE}

${NSA_ue_index}   1
${SA_ue_index}    0
${eNB_ue_index}   1
*** Test Cases ***
CB008208-5G-A_Classical_PCMD_for_SA_and_NSA
    [Documentation]   case contain all 8208 cases
    Run Keyword And Continue On Failure   CB008208-5G-A-12_Classical_gNB-CU_Bearer_record_for_SA_Initial_Context_Setup
    Run Keyword And Continue On Failure
    ...   CB008208-5G-A-19_Classical_DU_UE_context_setup_and_bearer_data_reporting_on_target_cell_during_NSA_Intra-DU_handover
    Run Keyword And Continue On Failure   CB008208-5G-A-20_Classical_DU_gNB-HO-SRC_and_DU_gNB-HO-TGT_reporting_during_SA_Intra-DU_handover
    Run Keyword And Continue On Failure   CB008208-5G-A-21_Classical_DU-Bearer_reporting_for_SA_UE_Context_Setup_scenarios_Initial_Context_Setup
    Run Keyword And Continue On Failure   CB008208-5G-A-22_Classical_DU-Bearer_reporting_for_SA_Intra-DU_handover_scenarios
    Run Keyword And Continue On Failure   CB008208-5G-A-23_Classical_DU-Bearer_reporting_for_SA_UE_Context_Setup_scenarios-Inter-gNB_handover
    Run Keyword And Continue On Failure   CB008208-5G-A-01_Classical_DU-Bearer_reporting_for_SA_PDU_Session_Resource_Setup_subsequent
    Run Keyword And Continue On Failure   CB008208-5G-A-02_Classical_gNB_CU_Bearers_in_NSA_Intra-MeNB_HO_gNB-CU_Bearer_record_should_not_recorded
    Run Keyword And Continue On Failure
    ...   CB008208-5G-A-03_Classical_gNB_CU_Bearers_in_NSA_Intra_en-gNB_mobility_gNB-CU_Bearer_record_not_recorded_on_source_cell
    Run Keyword And Continue On Failure   CB008208-5G-A-04_Classical_gNB_CU_Bearers_in_NSA_Intra_en_gNB_mobility
    Run Keyword And Continue On Failure
    ...   CB008208-5G-A-05_Classical_gNB_connectivity_information_in_eNB_initiated_SgNB_Modification_record_for_Intra-MeNB_HO
    Run Keyword And Continue On Failure
    ...   CB008208-5G-A-06_Classical_gNB_connectivity_information_in_gNB_initiated_SgNB_Modification_record_for_NSA_Intra_en-gNB_mobility
    Run Keyword And Continue On Failure   CB008208-5G-A-07_Classical_gNB_MeNB_Connectivity_record_for_NSA_Intra_en-gNB_mobility
    Run Keyword And Continue On Failure   CB008208-5G-A-08_Classical_gNB_SgNB_Change_PCMD_Trace_record_for_NSA_Inter_en-gNB_mobility
    Run Keyword And Continue On Failure   CB008208-5G-A-09_Classical_gNB-CU_Bearer_record_for_SA_intra-gNB_mobility
    Run Keyword And Continue On Failure   CB008208-5G-A-13_Classical_gNB-CU_Bearer_record_for_SA_PDU_Session_Resource_Setup
    Run Keyword And Continue On Failure   CB008208-5G-A-15_Classical_gNB-CU_Bearer_record_for_SA_PDU_Session_Resource_Release
    Check Extra Reset From Blackbox

5GC001097_CB_01_PCMD_Record_classical_NSA_SgNBAdditionTraceRecord_normal_call_scenario
    [Documentation]   Author: liping.hong@nokia-sbell.com
    [Setup]   Case Setup: 5GC001097_CB_01
    5GC001097_CB_01_PCMD_Record_classical_NSA_SgNBAdditionTraceRecord_normal_call_scenario
    [Teardown]   Case Teardown: 5GC001097_CB_01

CB009225 PCMD cases
    [Documentation]   Author: Jing.Qu@nokia-sbell.com
    Run Keyword And Continue On Failure   CB009225_A_01_e2e_B01_Successful_SA_intra_gNB_intra_DU_handover_A3_trigger
    Run Keyword And Continue On Failure
    ...    CB009225_B_01_B01_e2e_gNB_CU_UeDuConectivity_PCMD_record_from_target_cell_during_intra_gNB_intra_DU_mobility_NSA

5GC001097_costomer02183839_PCMD_Enhance
    [Documentation]   This case for verify customer PR02183839 which new scenario about in inter_MeNB handover
    ...    which come from 5GC001097
    Log To Console     Case 1: SgNBReleaseRecord Verify Inter_MeNB handover Without PScell Change
    SgNBReleaseRecord Verify Inter_MeNB handover Without PScell Change
#    [Teardown]  Log To Console    this case Will pass


#CB008208-5G-A-12_Classical_gNB-CU_Bearer_record_for_SA_Initial_Context_Setup
#    [Documentation]   Author: liping.hong@nokia-sbell.com
#    [Setup]   Case Setup: CB008208-5G-A-12
#    CB008208-5G-A-12_Classical_gNB-CU_Bearer_record_for_SA_Initial_Context_Setup
#    [Teardown]   Case Teardown: CB008208-5G-A-12

#CB008208-5G-A-19_Classical_DU_UE_context_setup_and_bearer_data_reporting_on_target_cell_during_NSA_Intra-DU_handover
#    [Documentation]   Author: liping.hong@nokia-sbell.com
#    [Setup]   Case Setup: CB008208-5G-A-19
#    CB008208-5G-A-19_Classical_DU_UE_context_setup_and_bearer_data_reporting_on_target_cell_during_NSA_Intra-DU_handover
#    [Teardown]   Case Teardown: CB008208-5G-A-19

#CB008208-5G-A-20_Classical_DU_gNB-HO-SRC_and_DU_gNB-HO-TGT_reporting_during_SA_Intra-DU_handover
#    [Documentation]   Author: liping.hong@nokia-sbell.com
#    [Setup]   Case Setup: CB008208-5G-A-20
#    CB008208-5G-A-20_Classical_DU_gNB-HO-SRC_and_DU_gNB-HO-TGT_reporting_during_SA_Intra-DU_handover
#    [Teardown]   Case Teardown: CB008208-5G-A-20

#CB008208-5G-A-21_Classical_DU-Bearer_reporting_for_SA_UE_Context_Setup_scenarios_Initial_Context_Setup
#    [Documentation]   Author: liping.hong@nokia-sbell.com
#    [Setup]   Case Setup: CB008208-5G-A-21
#    CB008208-5G-A-21_Classical_DU-Bearer_reporting_for_SA_UE_Context_Setup_scenarios_Initial_Context_Setup
#    [Teardown]   Case Teardown: CB008208-5G-A-21

#CB008208-5G-A-22_Classical_DU-Bearer_reporting_for_SA_Intra-DU_handover_scenarios
#    [Documentation]   Author: liping.hong@nokia-sbell.com
#    [Setup]   Case Setup: CB008208-5G-A-22
#    CB008208-5G-A-22_Classical_DU-Bearer_reporting_for_SA_Intra-DU_handover_scenarios
#    [Teardown]   Case Teardown: CB008208-5G-A-22

#CB008208-5G-A-23_Classical_DU-Bearer_reporting_for_SA_UE_Context_Setup_scenarios-Inter-gNB_handover
#    [Documentation]   Author: liping.hong@nokia-sbell.com
#    [Setup]   Case Setup: CB008208-5G-A-23
#    CB008208-5G-A-23_Classical_DU-Bearer_reporting_for_SA_UE_Context_Setup_scenarios-Inter-gNB_handover
#    [Teardown]   Case Teardown: CB008208-5G-A-23

#CB008208-5G-A-01_Classical_DU-Bearer_reporting_for_SA_PDU_Session_Resource_Setup_subsequent
#    [Documentation]   Author: liping.hong@nokia-sbell.com
#    [Setup]   Case Setup: CB008208-5G-A-01
#    CB008208-5G-A-01_Classical_DU-Bearer_reporting_for_SA_PDU_Session_Resource_Setup_subsequent
#    [Teardown]   Case Teardown: CB008208-5G-A-01

#CB008208-5G-A-02_Classical_gNB_CU_Bearers_in_NSA_Intra-MeNB_HO_gNB-CU_Bearer_record_should_not_recorded
#    [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
#    [Setup]   Case Setup: CB008208-5G-A-02
#    CB008208-5G-A-02_Classical_gNB_CU_Bearers_in_NSA_Intra-MeNB_HO_gNB-CU_Bearer_record_should_not_recorded
#    [Teardown]   Case Teardown: CB008208-5G-A-02

#CB008208-5G-A-03_Classical_gNB_CU_Bearers_in_NSA_Intra_en-gNB_mobility_gNB-CU_Bearer_record_not_recorded_on_source_cell
#    [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
#    [Setup]   Case Setup: CB008208-5G-A-03
#    CB008208-5G-A-03_Classical_gNB_CU_Bearers_in_NSA_Intra_en-gNB_mobility_gNB-CU_Bearer_record_not_recorded_on_source_cell
#    [Teardown]   Case Teardown: CB008208-5G-A-03

#CB008208-5G-A-04_Classical_gNB_CU_Bearers_in_NSA_Intra_en_gNB_mobility
#    [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
#    [Setup]   Case Setup: CB008208-5G-A-04
#    CB008208-5G-A-04_Classical_gNB_CU_Bearers_in_NSA_Intra_en_gNB_mobility
#    [Teardown]   Case Teardown: CB008208-5G-A-04

#CB008208-5G-A-05_Classical_gNB_connectivity_information_in_eNB_initiated_SgNB_Modification_record_for_Intra-MeNB_HO
#    [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
#    [Setup]   Case Setup: CB008208-5G-A-05
#    CB008208-5G-A-05_Classical_gNB_connectivity_information_in_eNB_initiated_SgNB_Modification_record_for_Intra-MeNB_HO
#    [Teardown]   Case Teardown: CB008208-5G-A-05

#CB008208-5G-A-06_Classical_gNB_connectivity_information_in_gNB_initiated_SgNB_Modification_record_for_NSA_Intra_en-gNB_mobility
#    [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
#    [Setup]   Case Setup: CB008208-5G-A-06
#    CB008208-5G-A-06_Classical_gNB_connectivity_information_in_gNB_initiated_SgNB_Modification_record_for_NSA_Intra_en-gNB_mobility
#    [Teardown]   Case Teardown: CB008208-5G-A-06

#CB008208-5G-A-07_Classical_gNB_MeNB_Connectivity_record_for_NSA_Intra_en-gNB_mobility
#    [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
#    [Setup]   Case Setup: CB008208-5G-A-07
#    CB008208-5G-A-07_Classical_gNB_MeNB_Connectivity_record_for_NSA_Intra_en-gNB_mobility
#    [Teardown]   Case Teardown: CB008208-5G-A-07

#CB008208-5G-A-08_Classical_gNB_SgNB_Change_PCMD_Trace_record_for_NSA_Inter_en-gNB_mobility
#    [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
#    [Setup]   Case Setup: CB008208-5G-A-08
#    CB008208-5G-A-08_Classical_gNB_SgNB_Change_PCMD_Trace_record_for_NSA_Inter_en-gNB_mobility
#    [Teardown]   Case Teardown: CB008208-5G-A-08

[1]5GC000376_CB_22_PCMD_Record_Successful_InterSgNBHo_SgNB_Ho_Successful_gNB_Classical
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [Setup]   Case Setup: 5GC000376_CB_22
    5GC000376_CB_22_PCMD_Record_Successful_InterSgNBHo_SgNB_Ho_Successful_gNB_Classical_enhance
    [Teardown]   Case Teardown: 5GC000376_CB_22

[1]5GC000376_CB_29_PCMD_Measurement_Successful_IntraMeNB_Lte_Ho_InterCell_PSCell_Change_gNB_Classical
    [Documentation]   Author: liangliang.heng@nokia-sbell.com
    [Setup]   Case Setup: 5GC000376_CB_29
    5GC000376_CB_29_PCMD_Measurement_Successful_IntraMeNB_Lte_Ho_InterCell_PSCell_Change_gNB_Classical_enhance
    [Teardown]   Case Teardown: 5GC000376_CB_29

#[1]CB008208-5G-A-09_Classical_gNB-CU_Bearer_record_for_SA_intra-gNB_mobility
#    [Documentation]   Author: Jing.Qu@nokia-sbell.com
#    CB008208-5G-A-09_Classical_gNB-CU_Bearer_record_for_SA_intra-gNB_mobility

#[1]CB008208-5G-A-15_Classical_gNB-CU_Bearer_record_for_SA_PDU_Session_Resource_Release
#    [Documentation]   Author: Jing.Qu@nokia-sbell.com
#    CB008208-5G-A-15_Classical_gNB-CU_Bearer_record_for_SA_PDU_Session_Resource_Release

#CB008208-5G-A-13_Classical_gNB-CU_Bearer_record_for_SA_PDU_Session_Resource_Setup
#    [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
#    [Setup]   Case Setup: CB008208-5G-A-13
#    CB008208-5G-A-13_Classical_gNB-CU_Bearer_record_for_SA_PDU_Session_Resource_Setup
#    [Teardown]   Case Teardown: CB008208-5G-A-13

CB008187_PCMD_and_call_trace_RAN_UE_ID_ALL_CASES
    Run Keyword And Continue On Failure   Check PCMD RAN UE ID   pcmd_file_path=${TCPDUMP_PATH}
    Run Keyword And Continue On Failure   Check PCMD RAN UE ID   pcmd_file_path=${NSA_Normal_Call_PATH}

    Run Keyword And Continue On Failure   Check PCMD RAN UE ID   pcmd_file_path=${NSA_INTRA_gNB_HO_PATH}
    Run Keyword And Continue On Failure   Check PCMD RAN UE ID   pcmd_file_path=${NSA_INTER_gNB_HO_SOURCE_PATH}
    Run Keyword And Continue On Failure   Check PCMD RAN UE ID   pcmd_file_path=${NSA_INTER_gNB_HO_TARGET_PATH}

    Run Keyword And Continue On Failure   Check PCMD RAN UE ID   pcmd_file_path=${NSA_INTER_MeNB_HO_PATH}
    Run Keyword And Continue On Failure   Check PCMD RAN UE ID   pcmd_file_path=${INTRA_MeNB_HO_gNB_PATH}

    Run Keyword And Continue On Failure   Check PCMD RAN UE ID   pcmd_file_path=${SA_INTRA_gNB_HO_PATH}
    Run Keyword And Continue On Failure   Check PCMD RAN UE ID   pcmd_file_path=${SA_INTER_gNB_HO_SOURCE_PATH}   HO_file_type=source
    Run Keyword And Continue On Failure   Check PCMD RAN UE ID   pcmd_file_path=${SA_INTER_gNB_HO_TARGET_PATH}   HO_file_type=target

*** Keywords ***
Common Suite Setup
    robot_common_operations.Common Suite Setup
    Run Keyword And Ignore Error   Check Extra Reset From Blackbox
    Common Setup 1756
    Get HO Suite Variables
#    Start BTS LOG Collection On Gnb And Rus
    Remove And Add PCMD Object
    Run Keyword And Ignore Error   COAM Logout

#    ${source_cell_identity_filter}   Get CellIdentity and Convert it to Filter   ${TL_cellid['${MRBTS_ID}']['source_cellid']}
#    ${target_cell_identity_filter}   Get CellIdentity and Convert it to Filter   ${TL_cellid['${MRBTS_ID}']['target_cellid']}
    ${source_cell_identity_filter}   convert_cellidentity_to_tcpdump_filter   ${nrcellid_source}
    ${target_cell_identity_filter}   convert_cellidentity_to_tcpdump_filter   ${nrcellid_target}
    set suite variable   ${source_cell_identity_filter}
    set suite variable   ${target_cell_identity_filter}

    Run Keyword And Ignore Error   Initialize PA
    Run Keyword And Ignore Error   Make L3CALL And Get ALL PCMD TCPDUMP File
    Run Keyword And Ignore Error   Make L3CALL And Get ALL PCMD TCPDUMP File   ${NSA_ue_index}   ${NSA_Normal_Call_PATH}

#    Trigger NSA INTRA HO
    Trigger INTRA gNB HO   ${NSA_ue_index}    ${NSA_INTRA_gNB_HO_FILE}   NSA
    ${status}   run keyword and return status   File Should Not Be Empty   ${NSA_INTRA_gNB_HO_PATH}
#    ${NSA_INTRA_target_crnti_HO_list}   ${NSA_INTRA_source_crnti_HO_list}  run keyword if  ${status}   Get nrcti of Target and Source HO
#    ...   ${NSA_INTRA_gNB_HO_PATH}   nsetapx.CuVendorExtensionRecordDataType == 9   nsetapx.CuVendorExtensionRecordDataType == 8
    ${NSA_INTRA_target_crnti_HO_list}   ${NSA_INTRA_source_crnti_HO_list}   run keyword if  ${status}
    ...   Get nrcti of Target and Source in NSA intra HO   ${NSA_INTRA_gNB_HO_PATH}
    set suite variable   ${NSA_INTRA_source_crnti_HO_list}
    set suite variable   ${NSA_INTRA_target_crnti_HO_list}

#    Trigger NSA INTER HO
    Trigger INTER gNB HO   ${NSA_ue_index}    ${NSA_INTER_gNB_HO_TARGET_FILE}   ${NSA_INTER_gNB_HO_SOURCE_FILE}   NSA
    ${status}   run keyword and return status   File Should Not Be Empty   ${NSA_INTER_gNB_HO_TARGET_PATH}
    ${NSA_INTER_target_crnti_HO_list}   run keyword if  ${status}   Get nrcti of HO
    ...   ${NSA_INTER_gNB_HO_TARGET_PATH}   nsetapx.CuVendorExtensionRecordDataType == 9
    set suite variable   ${NSA_INTER_target_crnti_HO_list}

    ${status}   run keyword and return status   File Should Not Be Empty   ${NSA_INTER_gNB_HO_SOURCE_PATH}
    ${NSA_INTER_source_crnti_HO_list}   run keyword if  ${status}   Get nrcti of HO
    ...   ${NSA_INTER_gNB_HO_SOURCE_PATH}   nsetapx.CuVendorExtensionRecordDataType == 8
    set suite variable   ${NSA_INTER_source_crnti_HO_list}

#    Trigger eNB INTRA HO
    Trigger INTRA eNB HO   ${NSA_ue_index}    ${INTRA_MeNB_HO_gNB_FILE}
    ${status}   run keyword and return status   File Should Not Be Empty   ${INTRA_MeNB_HO_gNB_PATH}
    ${INTRA_MeNB_crnti_HO_list}  run keyword if  ${status}   Get nrcti of HO
    ...   ${INTRA_MeNB_HO_gNB_PATH}   nsetapx.CuVendorExtensionRecordDataType == 7
    set suite variable   ${INTRA_MeNB_crnti_HO_list}

#    Trigger SA INTRA HO
    Trigger INTRA gNB HO   ${SA_ue_index}    ${SA_INTRA_gNB_HO_FILE}   SA
    ${status}   run keyword and return status   File Should Not Be Empty   ${SA_INTRA_gNB_HO_PATH}
#    ${SA_INTRA_crnti_HO_list}   run keyword if  ${status}   Get nrcti of HO    ${SA_INTRA_gNB_HO_PATH}
#    ...   nsetapx.CuVendorExtensionRecordDataType==14 && nsetapx.trigger==2
#    set suite variable   ${SA_INTRA_crnti_HO_list}
    ${SA_INTRA_target_crnti_HO_list}   ${SA_INTRA_source_crnti_HO_list}  run keyword if  ${status}   Get nrcti of Target and Source HO
    ...   ${SA_INTRA_gNB_HO_PATH}   nsetapx.CuVendorExtensionRecordDataType==14 && nsetapx.trigger==2
    ...   nsetapx.CuVendorExtensionRecordDataType==14 && nsetapx.trigger==3
    set suite variable   ${SA_INTRA_crnti_HO_list}   ${SA_INTRA_target_crnti_HO_list}

#    Trigger SA INTER HO
    Trigger INTER gNB HO   ${SA_ue_index}    ${SA_INTER_gNB_HO_TARGET_FILE}   ${SA_INTER_gNB_HO_SOURCE_FILE}   SA
    ${status}   run keyword and return status   File Should Not Be Empty   ${SA_INTER_gNB_HO_TARGET_PATH}
    ${SA_INTER_crnti_HO_list}   run keyword if  ${status}   Get nrcti of HO    ${SA_INTER_gNB_HO_TARGET_PATH}
    ...   nsetapx.CuVendorExtensionRecordDataType==14 && nsetapx.trigger==2
    set suite variable   ${SA_INTER_crnti_HO_list}

##    Trigger Inter_MeNB Handover Without PScell Change
#    Trigger Inter_MeNB Handover Without Pscell Change    ${NSA_ue_index}    ${NSA_INTER_MeNB_HO_FILE}
#    ${status}   run keyword and return status   File Should Not Be Empty   ${NSA_INTER_MeNB_HO_PATH}

    Run Keyword And Ignore Error   Initialize PA

Common Suite Teardown
    Run Keyword And Ignore Error   Initialize PA
#    Create Directory   ${OUTPUT_DIR}/dir
#    ${errandpcmd_status}   Check Error PCMD Print in Btslog
#    Run Keyword If Any Tests Failed   Stop And Download And Remove BTS LOG Collection On Gnb And Rus   dir
#    Run Keyword If All Tests Passed   run keyword if   ${errandpcmd_status}   run keywords
#    ...   Stop And Download And Remove BTS LOG Collection On Gnb And Rus   dir
#    ...   AND   Fail
#    ...   ELSE   Stop And Remove BTS LOG Collection On Gnb And Rus
#    Should Not Be Empty   ${NSA_INTRA_target_crnti_HO_list}
#    Should Not Be Empty   ${NSA_INTRA_source_crnti_HO_list}
#    Should Not Be Empty   ${NSA_INTER_target_crnti_HO_list}
#    Should Not Be Empty   ${NSA_INTER_source_crnti_HO_list}
#    Should Not Be Empty   ${INTRA_MeNB_crnti_HO_list}
#    Should Not Be Empty   ${SA_INTRA_crnti_HO_list}
#    Should Not Be Empty   ${SA_INTER_crnti_HO_list}
    Run Keyword And Ignore Error   Run Keyword If Any Tests Failed   Run keywords   Save gNB Snapshot   host=${LOCAL_SSH_ADDR}   alias=master
    ...   AND   Save gNB Snapshot   host=${PEER_SSH_ADDR}   alias=PEER
    Run Keyword And Ignore Error   Run Keyword If All Tests Passed   run keywords
    ...   RUN   rm -rf ${NSA_INTRA_gNB_HO_PATH}
    ...   AND   RUN   rm -rf ${NSA_INTER_gNB_HO_TARGET_PATH}
    ...   AND   RUN   rm -rf ${NSA_INTER_gNB_HO_SOURCE_PATH}
    ...   AND   RUN   rm -rf ${INTRA_MeNB_HO_gNB_PATH}
    ...   AND   RUN   rm -rf ${SA_INTRA_gNB_HO_PATH}
    ...   AND   RUN   rm -rf ${SA_INTER_gNB_HO_TARGET_PATH}
    ...   AND   RUN   rm -rf ${TCPDUMP_PATH}
    ...   AND   RUN   rm -rf ${NSA_INTER_MeNB_HO_PATH}
    Common Teardown 1756
    robot_common_operations.Common Suite Teardown

Case Common Setup
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000

Case Common Teardown
    robot_common_operations.Common Case Teardown

*** Settings ***
Documentation
...   author: liping.hong@nokia-sbell.com
...   This case can cover case 12, case 15, case 17, case 24 in QC
#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot

Suite Setup   Common Suite Setup
Suite Teardown   Common Suite Teardown

Test Setup   Case Setup
Test Teardown   Case Teardown

*** Variables ***
${dcap_server_port}     49148
${source_VCU_CPIF_file}   cpif.pcap
${source_VCU_OAMAGENT_file}   cuoamext.pcap
${source_VDU_OCP_file}   duoamext.pcap
${SA_InterDU_HO_VCU_CPIF_file}    SA_InterDU_HO_cpif.pcap
${SA_InterDU_HO_VCU_OAMAGENT_file}    SA_InterDU_HO_cuoamext.pcap
${nsa_source_VCU_CPIF_file}   nsa_cpif.pcap
${nsa_source_VCU_OAMAGENT_file}   nsa_cuoamext.pcap
${nsa_source_VDU_OCP_file}   nsa_duoamext.pcap
${sa_ue_index}        0
${nsa_ue_index}        1
${TCPDUMP_PATH}     ${OUTPUT_DIR}/${source_VCU_OAMAGENT_file}
${f1_file_path}     ${OUTPUT_DIR}/${source_VCU_CPIF_file}
${du_file_path}   ${OUTPUT_DIR}/${source_VDU_OCP_file}
${vcu_oam_ssh_IP}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${vcu_oam_ssh_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${vcu_oam_ssh_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

*** Test Cases ***
CB007227 PCMD cases
    Run Keyword And Continue On Failure   CB007227-SR-A_RAN_UE_ID_Sent_by_gNB-CU-UP_during_SgNB_Addition_NSA_or_initial_access_SA
    ...   ${source_VCU_OAMAGENT_file}
    Run Keyword And Continue On Failure   CB007227-SR-A_RAN_UE_ID_Sent_by_gNB-CU-UP_during_SgNB_Addition_NSA_or_initial_access_SA
    ...   ${nsa_source_VCU_OAMAGENT_file}
    Run Keyword And Continue On Failure   CB007227-SR-E_gNB_Cplan_and_Uplan_PCMD_record_in_scenario_Initial_Context_Setup
#    Run Keyword And Continue On Failure   CB007227-SR-E_gNB_Cplan_record_in_scenario_Intra-gNB_Intra_DU_handover_SA
#    Run Keyword And Continue On Failure   CB007227-SR-C_varify_content_of_PCMD_measurements_for_U-Plane_DU_RLC_layer_DL_IP_Latency
    Run Keyword And Continue On Failure   CB007227-SR-B_PCMD_measurements_for_U-Plane_CU-UP_PDCP_layer_report_content_verify
    Run Keyword And Continue On Failure   CB007227-SR-F_varify_content_of_PCMD_measurements_for_RLC_layer_UL

CB008340-17_gNB_CU_RRCSetup_Record_SA_Cloud
    Run Keyword And Continue On Failure   Check Real Fields for CU-RRCSetup Record
    Run Keyword And Continue On Failure   Check Real Fields for DU-RRCSetup Record

CB009881 for CB008208 and CB009225
    Run Keyword And Continue On Failure   CB008208-5G-A-12_Classical_gNB-CU_Bearer_record_for_SA_Initial_Context_Setup
    Run Keyword And Continue On Failure   CB008208-5G-A-13_Classical_gNB-CU_Bearer_record_for_SA_PDU_Session_Resource_Setup
    Run Keyword And Continue On Failure   CB008208-5G-A-15_Classical_gNB-CU_Bearer_record_for_SA_PDU_Session_Resource_Release
    Run Keyword And Continue On Failure
    ...   CB008208-5G-A-21_Classical_DU-Bearer_reporting_for_SA_UE_Context_Setup_scenarios_Initial_Context_Setup
    ...   ${f1_file_path}   ${du_file_path}
    Run Keyword And Continue On Failure   CB009881-CB009225_A_03_e2e_B02_Successful_SA_intra_gNB_inter_DU_handover_A3_trigger_cloud
    Run Keyword And Continue On Failure   Check PCMD Record In vDU   ${file_list_vDU}
    Run Keyword And Continue On Failure   Check PCMD Record In vCU   ${file_list_vCU}

CB008187_PCMD_and_call_trace_RAN_UE_ID_ALL_CASES
    Run Keyword And Continue On Failure   Cloud Check PCMD RAN UE ID   pcmd_file_path=${OUTPUT_DIR}/${source_VCU_OAMAGENT_file}
    Run Keyword And Continue On Failure   Cloud Check PCMD RAN UE ID   pcmd_file_path=${OUTPUT_DIR}/${nsa_source_VCU_OAMAGENT_file}


*** Keywords ***
Common Suite Setup
#    Download wireshark plugin For 1756
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    robot_common_operations.Common Suite Setup
    Log To Console    Suite Setup TBD...
    Trigger SA Call And Get ALL Tcpdump
    Get ALL Suite Variables on VCU
    Trigger NSA Call And Get ALL Tcpdump
    ${emil_last_file_vDU}  Get Latest Trace File Name By IP   ip=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ${emil_last_file_vCU}  Get Latest Trace File Name By IP   ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    Set Suite variable  ${emil_last_file_vDU}
    Set Suite variable  ${emil_last_file_vCU}
    Trigger SA Intra-gNB Inter-DU HO And Get ALL Tcpdump
    ${file_list_vDU}   Get Newest Trace Files By IP
    ...   ip=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}   latest_skip_file=${emil_last_file_vDU}   local_dir=${OUTPUT_DIR}
    ${file_list_vCU}   Get Newest Trace Files By IP
    ...   ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}   latest_skip_file=${emil_last_file_vCU}   local_dir=${OUTPUT_DIR}
    Set Suite variable  ${file_list_vDU}
    Set Suite variable  ${file_list_vCU}
    Log To Console    Suite Setup Finshed.

Common Suite Teardown
    robot_common_operations.Common Suite Teardown
    Log To Console    TearDown TBD...
#    Wait Until Keyword Succeeds   15m   1m   CU Verify All Cells Status Are Onair

Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    robot_common_operations.Common Case Setup

Case Teardown
    robot_common_operations.Common Case Teardown

Trigger SA Call And Get ALL Tcpdump
    ${pavalue_879cell1}   Create List   0   0   127   127   127   127   127   127   127   127   127   127   127   127   127   127
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=0   value=${pavalue_879cell1}
    SA UE Preparation At Case Setup
#    Start Tcpdump for VDU OCP   ${source_VDU_OCP_file}   alias=sourceOCP
    Enable Tcpdump on vCU Container   pod_abbr=cpif   file_name=${source_VCU_CPIF_file}
    Enable Tcpdump on vCU Container   pod_abbr=oamext   file_name=${source_VCU_OAMAGENT_file}
    Enable Tcpdump on vDU Container   pod_abbr=oamext   file_name=${source_VDU_OCP_file}
    Log To Console    Start UE Attach ...
    new_power_UE.UE Attach    ue_index=${sa_ue_index}
    Sleep    5s
    Log To Console    Start Disable Tcpdump
    Disable Tcpdump on vDU And Download The File   pod_abbr=oamext   file_name=${source_VDU_OCP_file}
    Disable Tcpdump on vCU And Download The File    pod_abbr=cpif    file_name=${source_VCU_CPIF_file}
    Disable Tcpdump on vCU And Download The File    pod_abbr=oamext    file_name=${source_VCU_OAMAGENT_file}
#    Stop Tcpdump for VDU OCP   ${source_VDU_OCP_file}   alias=sourceOCP
    Log To Console    Finshed Disable Tcpdump
    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...    Log To Console    Start UE detach ...
    ...   AND   New Commercial UE detach    ue_index=${sa_ue_index}
    ...   AND   Modify All Attenuation Ports Value For Specific RU For Cloud   gnb_id=0   RU_id=0   value=127

Trigger NSA Call And Get ALL Tcpdump
    ${pavalue_879cell1_nsa}   Create List   0   0   127   127   127   127   127   127   0   0   127   127   127   127   127   127
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=0   value=${pavalue_879cell1_nsa}
#    SA UE Preparation At Case Setup     ue_index=1
    NSA UE Preparation At Case Setup
#    Start Tcpdump for VDU OCP   ${source_VDU_OCP_file}   alias=sourceOCP
    Enable Tcpdump on vCU Container   pod_abbr=cpif   file_name=${nsa_source_VCU_CPIF_file}
    Enable Tcpdump on vCU Container   pod_abbr=oamext   file_name=${nsa_source_VCU_OAMAGENT_file}
    Enable Tcpdump on vDU Container   pod_abbr=oamext   file_name=${nsa_source_VDU_OCP_file}
    Log To Console    Start UE Attach ...
    new_power_UE.UE Attach    ue_index=${nsa_ue_index}
    Sleep    5s
    Log To Console    Start Disable Tcpdump
    Disable Tcpdump on vDU And Download The File   pod_abbr=oamext   file_name=${nsa_source_VDU_OCP_file}
    Disable Tcpdump on vCU And Download The File    pod_abbr=cpif    file_name=${nsa_source_VCU_CPIF_file}
    Disable Tcpdump on vCU And Download The File    pod_abbr=oamext    file_name=${nsa_source_VCU_OAMAGENT_file}
#    Stop Tcpdump for VDU OCP   ${source_VDU_OCP_file}   alias=sourceOCP
    Log To Console    Finshed Disable Tcpdump
    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...    Log To Console    Start UE detach ...
    ...   New Commercial UE detach    ue_index=${nsa_ue_index}
    ...   AND   Modify All Attenuation Ports Value For Specific RU For Cloud   gnb_id=0   RU_id=0   value=127

Trigger SA Intra-gNB Inter-DU HO And Get ALL Tcpdump
    ${pavalue_879cell1}   Create List   0   0   127   127   127   127   127   127   127   127   127   127   127   127   127   127
    Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=0   value=${pavalue_879cell1}
    SA UE Preparation At Case Setup
    Enable Tcpdump on vCU Container   pod_abbr=cpif   file_name=${SA_InterDU_HO_VCU_CPIF_file}
    Enable Tcpdump on vCU Container   pod_abbr=oamext   file_name=${SA_InterDU_HO_VCU_OAMAGENT_file}
    new_power_UE.UE Attach    ue_index=${sa_ue_index}
    Modify All Attenuation Ports Value For Specific RU For Cloud   gnb_id=0   RU_id=2   value=0
    Modify All Attenuation Ports Value For Specific RU For Cloud   gnb_id=0   RU_id=1   value=20
    Sleep    5s
    Disable Tcpdump on vCU And Download The File    pod_abbr=cpif    file_name=${SA_InterDU_HO_VCU_CPIF_file}
    Disable Tcpdump on vCU And Download The File    pod_abbr=oamext    file_name=${SA_InterDU_HO_VCU_OAMAGENT_file}
    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   New Commercial UE detach    ue_index=${sa_ue_index}
    ...   AND   Modify All Attenuation Ports Value For Specific RU For Cloud   gnb_id=0   RU_id=0   value=127
# # #*** Settings ***
# # #Documentation
# # #...   author: Shi Ming
# # #...   contact: ming.shi@nokia-sbell.com
# # #...   squad group: SG_03
# # #...   feature : 5GC0001927-T
# # #
# # #Force Tags      5G_SISO    9.1800    10.1800    CRT_21A    CRT_20B    CRT_TRUNK    RAN_5G    RAN_5G_TDD
# # #...    PY36
# # #...    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AWHHI_ENB    SBTS00    5G_RAN_TDD
# # #
# # #Suite Setup    Run Keywords
# # #...            Get gnb release info    AND
# # #...            run keyword if   '${enb_instance}'=='35621'    CI_interface.Common Suite Setup    AND
# # #...            5GC001927-T_coam_common_keywords.Pre Condition    AND
# # #...            Preparation UE on setup    AND
# # #...            Enb use EPCsim    AND
# # #...            Enb use Multi-DRB
# # #
# # #Suite Teardown    Run Keywords
# # #...               5GC000738_common_keywords.gNB connections    AND
# # #...               Run Keyword And Ignore Error    Tests Recover    ${x2logname1}    AND
# # #...               Run Keyword And Ignore Error    Tests Recover    ${x2logname2}    AND
# # #...               Run Keyword And Ignore Error    Tests Recover    ${x2logname3}    AND
# # #...               teardown for UE detach    AND
# # #...               Enb use RealEPC    AND
# # #...               Enb use Single-DRB    AND
# # #...               Disconnect connections
# # #
# # #Resource    ./Resources/5GC001927-T_coam_common_keywords.robot
# # #
# # #*** Variables ***
# # #${x2logname1}    738A17_Samsungx201.pcap
# # #${x2logname2}    738A17_Samsungx202.pcap
# # #${x2logname3}    738A17_Samsungx203.pcap
# # #${acterror}    False
# # #${ue_atplmn}    at+cops=1,2,45005,7
# # #${ue_plmn}    45005
# # #${x2ap_filter}    x2ap
# # #${epc_log_path}    /tmp/
# # #${SCF_path}    /opt/workspace/CRT/Master/SCF_file/
# # #${SCF_file_name}    Full_Configuration_SCF_1881_886_7657.xml
# # #@{counter_id}    M55326C00001    M55145C00005    M55145C00006
# # #@{full_path}    BTS/NRBTS-38/MCC-244_MNC-09/NRASU/PDCP_SDU_USDAT_VOL_DL_NSA_PLMN
# # #...    CELLS/NRCELL-1/MCC-244_MNC-09/NRANS/RA_UE_NSA_PLMN
# # #...    CELLS/NRCELL-1/MCC-244_MNC-09/NRANS/RA_NGBR_DRB_NSA_PLMN
# # #@{diffTL_enb_ID}    35621    35921    36921
# # 
# # #*** Test Cases ***
# # #[1]5GC000738_A_17_PLMN_selection_during_Intra_gNB_HO_initiated_by_SgNB_withmultidrb
# # #    [Documentation]
# # #    ...    The purpose of this test case is to check Multi PLMN are validated and selected the strongest cell
# # #    ...    match with the PLMN list during the HO when multidrb was established for UE.
# # #    [Tags]     5GC001927-T    CRT_22R2    RAN_5G    RAN_5G_TDD
# # #    [Timeout]    1 hour
# # #    [Setup]
# # #    EPCsim load cfg file
# # #    Prepare the classical COAM BTS cell onair on 1927
# # #    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare the classical COAM BTS cell onair on 1927
# # #    should be equal    ${cell_status}    PASS
# # #    lock gnb1 cell2 on TL369
# # #    check type of system board on gnb1
# # #    Check device exist with UE
# # #    Prepare ue attach on 5G
# # #    reboot ue for TL349
# # #    check time to execute below steps
# # #    Start Capture Classical Logs    x2logname=${x2logname1}    interface=${gnb1_interface_name}
# # #    UE attach on 5G
# # #    Stop and Save classical Logs    x2logname=${x2logname1}
# # #    Analysis wireshark log for case 738A17_01
# # #    create additional drb for UE
# # #    Start Capture Classical Logs    x2logname=${x2logname3}    interface=${gnb1_interface_name}
# # ##    start traffic on 5G
# # #    delete 2nd drb for UE
# # #    Stop and Save classical Logs    x2logname=${x2logname3}
# # #    Analysis wireshark log for case 738A17_03
# # #    [Teardown]    Run Keywords    unlock gnb1 cell2 on TL369    AND
# # #    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# # 
# # 
# # #[1]5GC000738_B_07_PM_counters_updated_per_PLMN_when_NR_RAN_sharing_for_MultiDRB_by_Sgnb_modify
# # #    [Documentation]
# # #    ...    The purpose of this test case is to verify the PM counters updated Per PLMN when RAN sharing enabled.
# # #    [Tags]     5GC001927-T
# # #    [Timeout]    1 hour
# # #    [Setup]
# # #    Check PM counter updated with M55326C00001 M55145C00005 M55145C00006
# # #    [Teardown]
# # 
# # 
# # #*** Keywords ***
# # #Analysis wireshark log for case 738A17_01
# # #    run keyword if    '${enb_instance}'=='35921'    Analysis wireshark log for case 738A17_01 on TL38
# # #    run keyword if    '${enb_instance}'=='30'    Analysis wireshark log for case 738A17_01 on TL30
# # #    run keyword if    '${enb_instance}'=='37'    Analysis wireshark log for case 738A17_01 on TL349
# # #    run keyword if    '${enb_instance}'=='35621'    Analysis wireshark log for case 738A17_01 on TL349
# # #
# # #Analysis wireshark log for case 738A17_01 on TL30
# # #    cap.read_cap      cap_file=${epc_log_path}${x2logname1}    display_filter=${x2ap_filter}
# # #    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 27
# # #    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 0 and e212.mcc ==450 and e212.mnc == 5
# # #    ${CP_plmnlist} =    Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 27
# # #    ...    and e212.mcc ==450 and e212.mnc == 5
# # #    ${plmn_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${CP_plmnlist}
# # #    should be equal    ${plmn_status}    ${True}
# # #
# # #Analysis wireshark log for case 738A17_01 on TL38
# # #    cap.read_cap      cap_file=${epc_log_path}${x2logname1}    display_filter=${x2ap_filter}
# # #    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 27
# # #    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 0 and e212.mcc ==${tl.core.mcc} and e212.mnc == ${tl.core.mnc}
# # #    ${CP_plmnlist} =    Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 27
# # #    ...    and e212.mcc ==${tl.core.mcc} and e212.mnc == ${tl.core.mnc}
# # #    ${plmn_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${CP_plmnlist}
# # #    should be equal    ${plmn_status}    ${True}
# # #
# # #Analysis wireshark log for case 738A17_01 on TL349
# # #    cap.read_cap      cap_file=${epc_log_path}${x2logname1}    display_filter=${x2ap_filter}
# # #    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 27
# # #    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 0 and e212.mcc ==${tl.core.mcc} and e212.mnc == ${tl.core.mnc}
# # #    ${CP_plmnlist} =    Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 27
# # #    ...    and e212.mcc ==${tl.core.mcc} and e212.mnc == ${tl.core.mnc}
# # #    ${plmn_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${CP_plmnlist}
# # #    should be equal    ${plmn_status}    ${True}
# # #
# # #Analysis wireshark log for case 738A17_01 on TL233
# # #    cap.read_cap      cap_file=${epc_log_path}${x2logname1}    display_filter=${x2ap_filter}
# # #    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 27
# # #    cap.Check Expression
# # #    ...    condition_expression=x2ap.X2AP_PDU == 0 and e212.mcc ==${tl.core.mcc} and e212.mnc == ${tl.core.mnc}
# # #    ${CP_plmnlist} =    Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 27
# # #    ...    and e212.mcc ==${tl.core.mcc} and e212.mnc == ${tl.core.mnc}
# # #    ${plmn_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${CP_plmnlist}
# # #    should be equal    ${plmn_status}    ${True}
# # #
# # #Analysis wireshark log for case 738A17_03
# # #    cap.read_cap      cap_file=${epc_log_path}${x2logname3}    display_filter=${x2ap_filter}
# # #    ${CP_mdrb} =    Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 38
# # #    ...    and x2ap.e_RAB_ID == 5 and x2ap.e_RAB_ID == 6
# # #    ${mdrb_status} =    run_keyword_and_return_status    cap.Check Expression    condition_expression=${CP_mdrb}
# # #    should be equal    ${mdrb_status}    ${False}
# # 
# # #    ${usageCountDL_0} =    cap.get_element_value    element_expression=x2ap.usageCountDL    element_idx=${0}
# # #    ...    default_value=${True}
# # #    ...    condition_expression=x2ap.e_RAB_ID == 6 and x2ap.procedureCode == 38
# # #    ${counter_value_0}=    Get couter value    counter_result=${usageCountDL_0}
# # #    ${counter_value_0}=    Convert To Integer    ${counter_value_0}
# # ##    Should Not Be Equal    ${counter_value_0}    ${0}
# # #    Set Suite Variable    ${last_usageCountDL}     ${counter_value_0}
# # 
# # 
# # 
# # 
# # 
# # Check PM counter updated with M55326C00001 M55145C00005 M55145C00006
# #     sleep    120s
# #     selenium_coam.enable_virtual_display
# #     selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
# #     wait until keyword succeeds    5min    1min    Get counter1
# #     ${result0}    get dictionary values   ${res0}
# #     ${counter_value0}=    Get couter value    counter_result=${result0}
# #     ${counter_value0}=    Convert To Integer    ${counter_value0}500
# #     ${passed}=    Run Keyword And Return Status    ${last_usageCountDL} > ${counter_value0}
# #     Get counter2
# #     ${result1}    get dictionary values   ${res1}
# #     ${counter_value1}=    Get couter value    counter_result=${result1}
# #     ${counter_value1}=    Convert To Integer    ${counter_value1}
# #     should be equal    ${counter_value1}    ${1}
# #     Get counter3
# #     ${result2}    get dictionary values   ${res2}
# #     ${counter_value2}=    Get couter value    counter_result=${result2}
# #     ${counter_value2}=    Convert To Integer    ${counter_value2}
# #     should be equal    ${counter_value2}    ${3}
# #     selenium_coam.logout
# #     selenium_coam.disable_virtual_display

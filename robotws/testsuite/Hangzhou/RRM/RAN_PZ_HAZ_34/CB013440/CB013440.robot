*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04


Resource    ./Resources/CB013440_common_keyword.robot
Variables   ./Resources/TLConfigration_13440.py

Suite Setup    CB013440 Suite Setup

*** Test Cases ***
[1]CB013440_A_010_FDD_SA_2TX_For_SSB_TRS_And_Cell_specific_PDSCH_with_ant_remaping
    [Setup]    Case Setup
#    Case10 Step    du_para=${case10_du_para1}    cu_para=${case10_cu_para1}    enb_para=${case10_enb_para1}
#    ...    PA_value_list=${case10_PA_value_list1}    counter_id_dict=${case10_counter1}    pcap_filename=tcpdump_cplane_cu_cell6

    Case10 Step    du_para=${case10_du_para1}    cu_para=${case10_cu_para1}    enb_para=${case10_enb_para2}
    ...    PA_value_list=${case10_PA_value_list2}    counter_id_dict=${case10_counter2}    pcap_filename=tcpdump_cplane_cu_cell2
    [Teardown]    Case Teardown    du_para=${case10_du_para3}

[1]CB013440_A_015_DlData_SsBlockSendReqL1sw_message_check
    [Setup]    Case Setup
    Case15 Step    du_para=${case15_du_para1}    cu_para=${case15_cu_para1}    bip_log=open_2tx    filter_list=${filter_list_2tx}
    ...    check_cell_list=${cell_info_list_2tx}    check_field_list=${field_name_list_2tx}    expect_value_list=${check_value_open_2tx}
    ...    pdml_name_list=${pdml_name_list_2tx}    normal_field_list=${normal_field_list_2tx}    abnormal_field_list=${abnormal_field_list_2tx}

    Case15 Step    du_para=${case15_du_para2}    cu_para=${case15_cu_para1}    bip_log=close_2tx    filter_list=${filter_list_2tx}
    ...    check_cell_list=${cell_info_list_2tx}    check_field_list=${field_name_list_2tx}    expect_value_list=${check_value_close_2tx}
    ...    pdml_name_list=${pdml_name_list_2tx}    normal_field_list=${normal_field_list_2tx}    abnormal_field_list=${abnormal_field_list_2tx}

    Case15 Step    du_para=${case15_du_para3}    cu_para=${case15_cu_para3}    bip_log=close_legcy    filter_list=${filter_list_2tx}
    ...    check_cell_list=${cell_info_list_2tx}    check_field_list=${field_name_list_legacy}    expect_value_list=${check_value_list_legacy}
    ...    pdml_name_list=${pdml_name_list_2tx}    normal_field_list=${normal_field_list_legacy}    abnormal_field_list=${abnormal_field_list_legacy}
     [Teardown]    Case Teardown


[1]CB013440_A_007_FDD_NSA_2TX_For_SSB_TRS_And_Cell_specific_PDSCH_with_closed_loop_mode
    [Setup]    Case Setup
    Modify Parameter And Adjust PA    PA_value_list=${case7_PA_value_list}    du_para=${case7_du_para1}    cu_para=${case7_cu_para1}
    ...    enb_para=${case7_enb_para1}
    Single UE Attach    ue_index=${0}    ue_type=samsung_ue
    UE Start Traffic    ue_index=${0}    ue_type=samsung_ue    ul_throughput=100M    dl_throughput=300M
    ${log_path}    Start Capture SYSLOG And Download    file_name=L2RT_SYSLOG    syslog_time=1min
    ${tti_path}    Capture TTi Log    cell_dn_list=${cell_list}    time=3s
    UE Stop Traffic    ue_index=${0}    ue_type=samsung_ue
    ${ul_bler}    ${dl_bler}    Check Bler From Ttilog    tti_path=${tti_path}    except_dl_bler=9    except_ul_bler=9
    ${ul_avg_tp}    ${dl_avg_tp}    Check TP From Aasyslog    ul_list=${dl_cell_list}    dl_list=${dl_cell_list}
    ...    exp_ul_tp=65    exp_dl_tp=200    log_path=${log_path}
    [Teardown]    Run Keywords    Case Teardown    AND    Single UE detach    ue_index=${0}    ue_type=samsung_ue


[1]CB013440_A_008_TDD_SA_2TX_For_SSB_TRS_And_Cell_specific_PDSCH_with_closed_loop_mode
    [Setup]    Case Setup
    Modify Parameter And Adjust PA    PA_value_list=${case8_PA_value_list}    du_para=${case8_du_para1}    cu_para=${case8_cu_para1}
    MTK UE Click on airplane mode    ue_mode=Attach    ue_index=${1}
    UE Start Traffic    ue_index=${1}    ue_type=samsung    ul_throughput=220M    dl_throughput=1500M
    ${log_path}    Start Capture SYSLOG And Download    file_name=L2RT_SYSLOG    syslog_time=1min
    ${tti_path}    Capture TTi Log    cell_dn_list=${cell_list}    time=3s
    UE Stop Traffic    ue_index=${1}    ue_type=samsung
    ${ul_bler}    ${dl_bler}    Check Bler From Ttilog    tti_path=${tti_path}    except_dl_bler=1    except_ul_bler=3
    ${ul_avg_tp}    ${dl_avg_tp}    Check TP From Aasyslog    ul_list=${dl_cell_list}    dl_list=${dl_cell_list}
    ...    exp_ul_tp=170    exp_dl_tp=1100    log_path=${log_path}
    [Teardown]    Run Keywords    Case Teardown    AND    MTK UE Click on airplane mode    ue_mode=Dettach    ue_index=${1}

[1]CB013440_A_001_online_enable_and_disable_Broadcast_and_cell specific_channels_only
    Log To Console    PASS

[1]CB013440_A_003_FDD_NSA_2TX_For_SSB_TRS_And_Cell_specific_PDSCH_with_open_loop_mode
    Log To Console    PASS

[1]CB013440_A_004_TDD_SA_2TX_For_SSB_TRS_And_Cell_specific_PDSCH_with_open_loop_mode
    Log To Console    PASS

[1]CB013440_A_016_Robustness_TDD_NSA_attach_success_rate_with_feature_enabled
    Log To Console    PASS

[1]CB013440_B_004_TDD_SA_4TX_transmission_of_UE_specific_PDCCH
    [Setup]    Case Setup
    Case4_B_Step    du_para=${case4_B_du_para1}    cu_para=${case4_B_cu_para1}    bip_log=l1up_pmi    tti_name=tcpdump_ttitrace_pmi
    ...    sys_log=L2RT_SYSLOG_pmi    except_bler=${1}    filter_list=${filter_name_list_case4_B1}    check_cell_list=${cell_info_list_case4_B}
    ...    check_field_list=${field_name_list_case4_B}    pdml_name_list=${pdml_name_list_case4_B}    expect_value_list=${check_value_case4_B_1}
    ...    normal_field_list=${normal_field_case4_B}    abnormal_field_list=${abnormal_field_case4_B}    exp_ul_tp=170    exp_dl_tp=1100

    Case4_B_Step    du_para=${case4_B_du_para2}    cu_para=${case4_B_cu_para2}    bip_log=l1up_pmi_2tx    tti_name=tcpdump_ttitrace_pmi_2tx
    ...    sys_log=L2RT_SYSLOG_pmi_2tx    except_bler=${1}    filter_list=${filter_name_list_case4_B2}    check_cell_list=${cell_info_list_case4_B}
    ...    check_field_list=${field_name_list_case4_B}    pdml_name_list=${pdml_name_list_case4_B}    expect_value_list=${check_value_case4_B_2}
    ...    normal_field_list=${normal_field_case4_B}    abnormal_field_list=${abnormal_field_case4_B}    exp_ul_tp=170    exp_dl_tp=1100
    [Teardown]    Case Teardown

[1]CB013440_B_007_TDD_SA_single_UE_tput_curves
    [Setup]    Case Setup
     Modify Parameter And Adjust PA    du_para=${case4_B_du_para2}    cu_para=${case4_B_cu_para2}    PA_value_list=${case8_PA_value_list}
     MTK UE Click on airplane mode    ue_mode=Attach    ue_index=${1}
     UE Start Traffic    ue_index=${1}    ue_type=samsung    ul_throughput=200M    dl_throughput=1500M
     ${tti_path1}    ${bip_log_path1}    ${asyslog_path1}    Capture Log And Check TP    bip_log_name=BipLog_PA_0    sys_log=SYSLOG_PA_0
     ...    tti_name=tcpdump_ttitrace_PA0   exp_ul_tp=170    exp_dl_tp=1400    PA_value_list=None
     ${tti_path2}    ${bip_log_path2}    ${asyslog_path2}    Capture Log And Check TP    bip_log_name=BipLog_PA_35    sys_log=SYSLOG_PA_35
     ...    tti_name=tcpdump_ttitrace_PA35   exp_ul_tp=100    exp_dl_tp=1200    PA_value_list=${caseB7_PA_value_list1}
     ${tti_path3}    ${bip_log_path3}    ${asyslog_path3}    Capture Log And Check TP    bip_log_name=BipLog_PA_50    sys_log=SYSLOG_PA_50
     ...    tti_name=tcpdump_ttitrace_PA50   exp_ul_tp=50    exp_dl_tp=500    PA_value_list=${caseB7_PA_value_list2}
     UE Stop Traffic    ue_index=${1}    ue_type=samsung
     [Teardown]    Run Keywords    MTK UE Click on airplane mode    ue_mode=Dettach    ue_index=${1}
     ...    AND    Case Teardown    PA_value_list=${case8_PA_value_list}

[1]CB013440_B_003_FDD_NSA_4TX_transmission_of_UE_specific_PDCCH
    [Setup]    Case Setup
     Modify Parameter And Adjust PA    du_para=${case3_B_du_para1}    cu_para=${case3_B_cu_para1}    PA_value_list=${case7_PA_value_list}
     Single UE Attach    ue_index=${0}    ue_type=samsung_ue
     UE Start Traffic    ue_index=${0}    ue_type=samsung_ue    ul_throughput=80M    dl_throughput=300M
     ${tti_path1}    ${bip_log_path1}    ${asyslog_path1}    Capture Log And Check TP    bip_log_name=BipLog_PA_0    sys_log=SYSLOG_PA_0
     ...    tti_name=tcpdump_ttitrace_PA0   exp_ul_tp=50    exp_dl_tp=260    PA_value_list=None
     ${tti_path2}    ${bip_log_path2}    ${asyslog_path2}    Capture Log And Check TP    bip_log_name=BipLog_PA_15    sys_log=SYSLOG_PA_15
     ...    tti_name=tcpdump_ttitrace_PA15   exp_ul_tp=40    exp_dl_tp=180    PA_value_list=${caseB3_PA_value_list1}
     ${tti_path3}    ${bip_log_path3}    ${asyslog_path3}    Capture Log And Check TP    bip_log_name=BipLog_PA_35    sys_log=SYSLOG_PA_35
     ...    tti_name=tcpdump_ttitrace_PA35   exp_ul_tp=30    exp_dl_tp=80    PA_value_list=${caseB3_PA_value_list2}
     UE Stop Traffic    ue_index=${0}    ue_type=samsung_ue
     [Teardown]    Run Keywords    Single UE detach    ue_index=${0}    ue_type=samsung_ue
     ...    AND    Case Teardown    PA_value_list=${case7_PA_value_list}

*** Keywords ***
Test Code
    ## Check TP
    ${log_path}    Set Variable    ${OUTPUT_DIR}/${TEST NAME}/L2RT_SYSLOG_2tx.txt
    ${ul_avg_tp}    ${dl_avg_tp}    Check TP From Aasyslog    ul_list=${dl_cell_list}    dl_list=${dl_cell_list}
    ...    exp_ul_tp=2    exp_dl_tp=2    log_path=${log_path}

    ## Get pdml xpath
    ${2tx_file}    Set Variable    ${OUTPUT_DIR}/${TEST NAME}/l1up_2tx_coo.pcap
    ${legacy_file}    Set Variable    ${OUTPUT_DIR}/${TEST NAME}/open_2tx.pcap
    ${log_full_path_ute}    Set Variable    ${legacy_file}
    ${log_full_path_ute}    Split String    ${log_full_path_ute}    separator=.
    ${log_path}    Set Variable     ${log_full_path_ute[${0}]}
    Covert Pcap To Pdml    pcap_file=${log_path}.pcap   output_file=${log_path}.pdml   filter='(dldata_ssblocksendreql1sw) && (3gpp.subcellid == 0)'
    ${key_list}    ${path_list}    Get_all_packey_Xpath_Keys    file_path=${log_path}_csirssendreql1sw_0.pdml
    ${result}    Extract_Pdlm_Message    filename=${log_path}_pdschsendreql1sw_2.pdml


[1]CB013440_A_001
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}
    OperatingSystem.Empty Directory    ${OUTPUT_DIR}/${TEST NAME}
    ${bip_tti_log_time}    set variable    ${5}
    ${other_log_time}    set variable    ${10}
    Start SYSLOG On DU And Tcpdump On CU
    ${tti_log_path}    Get L2stream logs using cOAM cli from Cloud DU    component=L2Ps    cell_dn_list=${cell_list}
    Start L1L2bip log for Cloud DU
    sleep    ${bip_tti_log_time}s
    Stop L1L2bip log for Cloud DU
    ${tti_path}    Stop Capture L2TTI Trace for Cloud DU
    sleep    ${other_log_time}s
    Stop SYSLOG On DU And Tcpdump On CU
    ${bip_path}    Download L1L2bip log for Cloud DU
    ${du_l2rt_syslog_path}    ${txt_path}    Dowload SYSLOG And Tcpdump
    ${decoded_csv_files}    Decode TTI Traces from PCAP or BIN for Cloud DU
    ...    input_filepath=${OUTPUT_DIR}/${TEST NAME}/l2stream/tcpdump/tcpdump.pcap
    ...    output_path=${OUTPUT_DIR}/${TEST NAME}    output_name=l2trace_du
    Format tti decoder
    [Teardown]    Common case teardown
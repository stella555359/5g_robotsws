*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04


Resource    ./Resources/CB010636_common_keyword.robot
Resource    ./Resources/CB010636_common.robot
Variables   ./Resources/TLConfigration_10636.py
Library     ./Resources/CB010636_counter_in_logs.py
Library     CB010636_counter_in_logs.DealCounter    WITH NAME    dealCounter

Suite Setup    CB010636 Suite Setup
Suite Teardown    CB010636 Suite Teardown

*** Test Cases ***
[1]CB008484_CR_L_07_IPv4CPRI_and_IPv6eCPRI_mix_configuration
    [Tags]    CB008484_CR_L    CRT
    [Setup]    robot_common_operations.Common case Setup
    Log To Console    disable eCPRI M-Plane IPv6 start
    VDU Online Change Parameters Activate    updated_paras_list=${disable_fhm_ipv6_para}
    Log To Console    start to check cell on-air
    Wait Until Keyword Succeeds    10min   30s    Check vDU And CU On Air    if_X2_check=${False}
    Wait Until Keyword Succeeds    5min   30s    VDU IPv6 Number Should Be Expected    expected_ipv6_num=${0}
    Log To Console    cell on-air after vdu reset
    Log To Console    enable eCPRI M-Plane IPv6 start
    VDU Online Change Parameters Activate    updated_paras_list=${enable_fhm_ipv6_para}
    Log To Console    start to check cell on-air
    Wait Until Keyword Succeeds    10min   30s    Check vDU And CU On Air    if_X2_check=${False}
    Wait Until Keyword Succeeds    5min   30s    VDU IPv6 Number Should Be Expected    expected_ipv6_num=${2}
    Log To Console    cell on-air after vdu reset
    [Teardown]    Case common Teardown

[1]CB010636_A_001_NonCA_RLC_PDU_volume_counters_for_NSA_and_SA
    [Tags]    1CC    NSA    SA
    [Setup]    robot_common_operations.Common case Setup
    VDU Online Change Parameters Activate    updated_paras_list=${case1_para}
    Start SYSLOG On DU And Tcpdump On CU
    ${tti_log_path}    Get L2stream logs using cOAM cli from Cloud DU    component=L2Lo    cell_dn_list=${cell_list}
    ${last_period_time}    Get VDU PM Counters Latest period time    counter_id_dict=${A_UL_Counters}
    ${ue_info}    Change The parameter of UE    new_ue_dict=${case1_ue_info}    org_UE_dict=${PC1_TLCommonConfig['MultiUECFG']}
    Start Traffic By Spark    ul_tp_list=${case1_ul_tp_list}    duration=10    process=${1}    multiue_config_direction=${ue_info}
    Stop SYSLOG On DU And Tcpdump On CU
    ${tti_path}    Stop Capture L2TTI Trace for Cloud DU
    ${du_l2rt_syslog_path}    ${du_l2hi_syslog_path}    ${txt_path}    Dowload SYSLOG And Tcpdump
    ${ca_info}    Analysis SYSLOG And Tcpdump    du_l2rt_syslog_path=${du_l2rt_syslog_path}    du_l2hi_syslog_path=${du_l2hi_syslog_path}
    ...    txt_path=${txt_path}
    ${decoded_csv_files}    Decode TTI Traces from PCAP or BIN for Cloud DU
    ...    input_filepath=${OUTPUT_DIR}/${TEST NAME}/l2stream/tcpdump/tcpdump.pcap
    ...    output_path=${OUTPUT_DIR}/${TEST NAME}    output_name=l2trace_du
    log to console    sleep 6min to wait for counter update
    sleep   6min
    Check CB010636_A Counter between Log and Webui    csv_path=${decoded_csv_files}[MacSubPduTxAm18]    ca_info=${ca_info}
    ...    counter_dict=${A_DL_Counters}    direction=dl    before_counter_time=${last_period_time}
    Check CB010636_A Counter between Log and Webui    csv_path=${decoded_csv_files}[MacSubPduRxAm18]    ca_info=${ca_info}
    ...    counter_dict=${A_UL_Counters}    direction=ul    before_counter_time=${last_period_time}
    [Teardown]    Case common Teardown


[1]CB010636_A_003_RLC_PDU_volume_counters_with_CA_TFFF
    [Tags]    4CC    SA
    [Setup]    robot_common_operations.Common case Setup
    VDU Online Change Parameters Activate    updated_paras_list=${case3_para}
    Start SYSLOG On DU And Tcpdump On CU
    ${tti_log_path}    Get L2stream logs using cOAM cli from Cloud DU    component=L2Lo    cell_dn_list=${cell_list}
    ${last_period_time}    Get VDU PM Counters Latest period time    counter_id_dict=${A_UL_Counters}
    ${ue_info}    Change The parameter of UE    new_ue_dict=${case3_ue_info}    org_UE_dict=${PC2_TLCommonConfig['MultiUECFG']}
    Start Traffic By Spark    ul_tp_list=${case1_ul_tp_list}    duration=10    process=${1}    multiue_config_direction=${ue_info}
    Stop SYSLOG On DU And Tcpdump On CU
    ${tti_path}    Stop Capture L2TTI Trace for Cloud DU
    ${du_l2rt_syslog_path}    ${du_l2hi_syslog_path}    ${txt_path}    Dowload SYSLOG And Tcpdump
    ${ca_info}    Analysis SYSLOG And Tcpdump    du_l2rt_syslog_path=${du_l2rt_syslog_path}    du_l2hi_syslog_path=${du_l2hi_syslog_path}
    ...    txt_path=${txt_path}
    ${decoded_csv_files}    Decode TTI Traces from PCAP or BIN for Cloud DU
    ...    input_filepath=${OUTPUT_DIR}/${TEST NAME}/l2stream/tcpdump/tcpdump.pcap
    ...    output_path=${OUTPUT_DIR}/${TEST NAME}    output_name=l2trace_du
    log to console    sleep 6min to wait for counter update
    sleep   6min
    Check CB010636_A Counter between Log and Webui    csv_path=${decoded_csv_files}[MacSubPduTxAm18]    ca_info=${ca_info}
    ...    counter_dict=${A_DL_Counters}    direction=dl    before_counter_time=${last_period_time}
    Check CB010636_A Counter between Log and Webui    csv_path=${decoded_csv_files}[MacSubPduRxAm18]    ca_info=${ca_info}
    ...    counter_dict=${A_UL_Counters}    direction=ul    before_counter_time=${last_period_time}
    [Teardown]    Case common Teardown


[1]CB010636_A_007_RLC_PDU_volume_counters_for_CA_and_NonCA_DRBs_with_CA_FFT
    [Tags]    DRB    NonCA eligble
    [Setup]    robot_common_operations.Common case Setup
    VDU Online Change Parameters Activate    updated_paras_list=${case7_du_para}
    CU Online Change Parameters Activate    updated_paras_list=${case7_cu_para}
    Start SYSLOG On DU And Tcpdump On CU
    ${tti_log_path}    Get L2stream logs using cOAM cli from Cloud DU    component=L2Lo    cell_dn_list=${cell_list}
    ${last_period_time}    Get VDU PM Counters Latest period time    counter_id_dict=${A_UL_Counters}
    ${ue_info}    Change The parameter of UE    new_ue_dict=${case7_ue_info}    org_UE_dict=${PC1_TLCommonConfig['MultiUECFG']}
    Start Traffic By Spark    if_ul=${False}    multiue_config_direction=${ue_info}
    Stop SYSLOG On DU And Tcpdump On CU
    ${tti_path}    Stop Capture L2TTI Trace for Cloud DU
    ${du_l2rt_syslog_path}    ${du_l2hi_syslog_path}    ${txt_path}    Dowload SYSLOG And Tcpdump
    ${ca_info}    Analysis SYSLOG And Tcpdump    du_l2rt_syslog_path=${du_l2rt_syslog_path}    du_l2hi_syslog_path=${du_l2hi_syslog_path}
    ...    txt_path=${txt_path}
    ${decoded_csv_files}    Decode TTI Traces from PCAP or BIN for Cloud DU
    ...    input_filepath=${OUTPUT_DIR}/${TEST NAME}/l2stream/tcpdump/tcpdump.pcap
    ...    output_path=${OUTPUT_DIR}/${TEST NAME}    output_name=l2trace_du
    log to console    sleep 6min to wait for counter update
    sleep   6min
    Check CB010636_A Counter between Log and Webui    csv_path=${decoded_csv_files}[MacSubPduTxAm18]    ca_info=${ca_info}
    ...    counter_dict=${A_DL_Counters}    direction=dl    before_counter_time=${last_period_time}    isDefaultCA=${False}
    [Teardown]    Run keywords    Case7 Teardown    AND    Case common Teardown

[1]CB010636_D_001_UE_TPUT_per_Mhz_BW_For_SA
    [Tags]    4CC    SA
    [Setup]    robot_common_operations.Common case Setup
    VDU Online Change Parameters Activate    updated_paras_list=${case3_para}
    Start SYSLOG On DU And Tcpdump On CU
    ${tti_log_path}    Get L2stream logs using cOAM cli from Cloud DU    component=L2Lo    cell_dn_list=${cell_list}
    ${last_period_time}    Get VDU PM Counters Latest period time    counter_id_dict=${D_DL_Counters}
    ${ue_info}    Change The parameter of UE    new_ue_dict=${case_D_ue_info}    org_UE_dict=${PC2_TLCommonConfig['MultiUECFG']}
    Start Traffic By Spark    if_ul=${False}    multiue_config_direction=${ue_info}    process=${2}    need_spark_log=${False}
    Stop SYSLOG On DU And Tcpdump On CU
    ${tti_path}    Stop Capture L2TTI Trace for Cloud DU
    ${du_l2rt_syslog_path}    ${du_l2hi_syslog_path}    ${txt_path}    Dowload SYSLOG And Tcpdump
    ${ca_info}    Analysis SYSLOG And Tcpdump    du_l2rt_syslog_path=${du_l2rt_syslog_path}    du_l2hi_syslog_path=${du_l2hi_syslog_path}
    ...    txt_path=${txt_path}
    ${decoded_csv_files}    Decode TTI Traces from PCAP or BIN for Cloud DU
    ...    input_filepath=${OUTPUT_DIR}/${TEST NAME}/l2stream/tcpdump/tcpdump.pcap
    ...    output_path=${OUTPUT_DIR}/${TEST NAME}    output_name=l2trace_du
    log to console    sleep 6min to wait for counter update
    sleep   6min
#    Check DL TP And Bler From Spark Log    expect_tp=1200    expect_bler=3
    Check CB010636_C Counter between Log and Webui    csv_path=${decoded_csv_files}[MacPduMuxReq]    ca_info=${ca_info}
    ...    counter_dict=${C_DL_Counters}    direction=dl    before_counter_time=${last_period_time}    percc_flag=${True}
    Check CB010636_D Counter between Log and Webui    csv_path=${decoded_csv_files}[MacPduMuxReq]    ca_info=${ca_info}
    ...    counter_dict=${D_DL_Counters}    direction=dl    before_counter_time=${last_period_time}
    [Teardown]    Case common Teardown

[1]CB008927-N-iwk2-02_dynamic_switch_IWK_with_3FDD_3TDD_interband_CA_with_TDD_as_Pcell
    [Setup]    robot_common_operations.Common case Setup
    Log To Console    PASS
    [Teardown]    Case common Teardown

[1]CB008927-N-iwk3-02_dynamic_switch_IWK_with_3FDD_3TDD_interband_CA_with_FDD_as_Pcell
    [Setup]    robot_common_operations.Common case Setup
    Log To Console    PASS
    [Teardown]    Case common Teardown

[1]CB010636_C_003_Downlink_PerCC_Combination_UE_TPUT_SA_counters_1_3_5CC
    [Tags]    5CC    SA
    [Setup]    robot_common_operations.Common case Setup
    VDU Online Change Parameters Activate    updated_paras_list=${case_C_para}
    Start SYSLOG On DU And Tcpdump On CU
    ${tti_log_path}    Get L2stream logs using cOAM cli from Cloud DU    component=L2Lo    cell_dn_list=${cell_list}
    ${last_period_time}    Get VDU PM Counters Latest period time    counter_id_dict=${C_DL_Counters}
    ${ue_info}    Change The parameter of UE    new_ue_dict=${case3_C_ue_info}    org_UE_dict=${PC2_TLCommonConfig['MultiUECFG']}
    Start Traffic By Spark    if_ul=${False}    multiue_config_direction=${ue_info}    process=${3}
    Stop SYSLOG On DU And Tcpdump On CU
    ${tti_path}    Stop Capture L2TTI Trace for Cloud DU
    ${du_l2rt_syslog_path}    ${du_l2hi_syslog_path}    ${txt_path}    Dowload SYSLOG And Tcpdump
    ${ca_info}    Analysis SYSLOG And Tcpdump    du_l2rt_syslog_path=${du_l2rt_syslog_path}    du_l2hi_syslog_path=${du_l2hi_syslog_path}
    ...    txt_path=${txt_path}
    ${decoded_csv_files}    Decode TTI Traces from PCAP or BIN for Cloud DU
    ...    input_filepath=${OUTPUT_DIR}/${TEST NAME}/l2stream/tcpdump/tcpdump.pcap
    ...    output_path=${OUTPUT_DIR}/${TEST NAME}    output_name=l2trace_du
    log to console    sleep 6min to wait for counter update
    sleep   6min
    Check CB010636_C Counter between Log and Webui    csv_path=${decoded_csv_files}[MacPduMuxReq]    ca_info=${ca_info}
    ...    counter_dict=${C_DL_Counters}    direction=dl    before_counter_time=${last_period_time}
    Check CB010636_C UL Counter between Log and Webui    before_counter_time=${last_period_time}
    Run keyword and ignore error    Check CB010636_D Counter between Log and Webui
    ...    csv_path=${decoded_csv_files}[MacPduMuxReq]    ca_info=${ca_info}
    ...    counter_dict=${D_DL_Counters}    direction=dl    before_counter_time=${last_period_time}
    [Teardown]    Case common Teardown

[1]CB010636_C_005_Uplink_PerCC_Combination_UE_TPUT_SA_counters_with_TF
    [Tags]    2CC    SA
    [Setup]    robot_common_operations.Common case Setup
    VDU Online Change Parameters Activate    updated_paras_list=${case_C_para}
    Start SYSLOG On DU And Tcpdump On CU
    ${tti_log_path}    Get L2stream logs using cOAM cli from Cloud DU    component=L2Lo    cell_dn_list=${cell_list}
    ${last_period_time}    Get VDU PM Counters Latest period time    counter_id_dict=${C_UL_Counters}
    ${ue_info}    Change The parameter of UE    new_ue_dict=${case3_C_ue_info}    org_UE_dict=${PC2_TLCommonConfig['MultiUECFG']}
    Start Traffic By Spark    if_dl=${False}    ul_tp_list=${case3_ul_tp_list}    duration=10    process=${1}   multiue_config_direction=${ue_info}
    Stop SYSLOG On DU And Tcpdump On CU
    ${tti_path}    Stop Capture L2TTI Trace for Cloud DU
    ${du_l2rt_syslog_path}    ${du_l2hi_syslog_path}    ${txt_path}    Dowload SYSLOG And Tcpdump
    ${ca_info}    Analysis SYSLOG And Tcpdump    du_l2rt_syslog_path=${du_l2rt_syslog_path}    du_l2hi_syslog_path=${du_l2hi_syslog_path}
    ...    txt_path=${txt_path}
    ${decoded_csv_files}    Decode TTI Traces from PCAP or BIN for Cloud DU
    ...    input_filepath=${OUTPUT_DIR}/${TEST NAME}/l2stream/tcpdump/tcpdump.pcap
    ...    output_path=${OUTPUT_DIR}/${TEST NAME}    output_name=l2trace_du
    log to console    sleep 6min to wait for counter update
    sleep   6min
    Check CB010636_C UL Counter between Log and Webui    before_counter_time=${last_period_time}
    [Teardown]    Case common Teardown

[1]CB010636_C_007_Downlink_PerCC_Combination_UE_TPUT_NSA_counters_with_TF
    [Tags]    1CC    SA    2CC    NSA
    [Setup]    robot_common_operations.Common case Setup
    VDU Online Change Parameters Activate    updated_paras_list=${case1_para}
    Start SYSLOG On DU And Tcpdump On CU
    ${tti_log_path}    Get L2stream logs using cOAM cli from Cloud DU    component=L2Lo    cell_dn_list=${cell_list}
    ${last_period_time}    Get VDU PM Counters Latest period time    counter_id_dict=${C_UL_Counters}
    ${ue_info2}    Change The parameter of UE    new_ue_dict=${case7_C_ue_info_pc2}    org_UE_dict=${PC2_TLCommonConfig['MultiUECFG']}
    Start Traffic By Spark    ul_tp_list=${case3_ul_tp_list}    duration=10    process=${1}
    ...    multiue_config_direction=${ue_info2}    ue_alias=Spark_PC2_UE
    Stop SYSLOG On DU And Tcpdump On CU
    ${tti_path}    Stop Capture L2TTI Trace for Cloud DU
    ${du_l2rt_syslog_path}    ${du_l2hi_syslog_path}    ${txt_path}    Dowload SYSLOG And Tcpdump
    ${ca_info}    Analysis SYSLOG And Tcpdump    du_l2rt_syslog_path=${du_l2rt_syslog_path}    du_l2hi_syslog_path=${du_l2hi_syslog_path}
    ...    txt_path=${txt_path}
    ${decoded_csv_files}    Decode TTI Traces from PCAP or BIN for Cloud DU
    ...    input_filepath=${OUTPUT_DIR}/${TEST NAME}/l2stream/tcpdump/tcpdump.pcap
    ...    output_path=${OUTPUT_DIR}/${TEST NAME}    output_name=l2trace_du
    log to console    sleep 6min to wait for counter update
    sleep   6min
    Check CB010636_C UL Counter between Log and Webui    before_counter_time=${last_period_time}    nsa_ul_cell=NRCELL-4
    Check CB010636_C Counter between Log and Webui    csv_path=${decoded_csv_files}[MacPduMuxReq]    ca_info=${ca_info}
    ...    counter_dict=${C_DL_Counters}    direction=dl    before_counter_time=${last_period_time}
    [Teardown]    Case common Teardown
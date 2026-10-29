*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04


Library     ./Resources/CB008927_common_keyword.py
Resource    ./Resources/CB008927_common_keyword.robot
Variables   ./Resources/CB008927_modify_para.py

Suite Setup       Common Suit Setup
Suite Teardown    robot_common_operations.Common Suite Teardown


*** Test Cases ***
### use case469 scf and basic.cfg and iphy.xml
[1]CB008927-N-iwk4-01_sub-band_TRS_and_cell_specific_CSI-RS_IWK_with_RAT1_dynrat0_BF
    [Setup]    Test Case Setup
    ${aasyslog_path}    ${tti_path}    ${output_list}    Common Case UE start Traffic    ue_info_dict=${case4_ue_info}
    ...    tti_log_name=ttitrace_streaming    excpet_element_list=${all_cell_list[4:5]}    block_flag=${True}    log_time=180s
    ...    ignore_time=60s
    Check Aasyslog And TTI    nr_cell_list=${all_nr_cell_list[4:5]}    aasyslog_path=${aasyslog_path}    tti_path=${tti_path}
    ...    exp_ul_tp=130    exp_dl_tp=990    bler=${1}    check_numOfPrb=${True}    except_rat0Bitmap_invaild_len=${0}    ssb_slot=${True}
    [Teardown]    Test Case Teardown    unblock_cell_list=${output_list}

[1]CB008927-N-iwk9-01_dynamic_switch_iwk_with_2_dedicated_BWPs_shared_extended_and_legency
    [Setup]    robot_common_operations.Common case Setup
    Log to Console    PASS
    [Teardown]    Common Case Teardown

[1]CB008927-N-iwk6-01_FDD_Slim_carrier_20Mhz_iwk_with_RAT1_Ues_dynamicswitch
    [Setup]    Test Case Setup
    ${aasyslog_path}    ${tti_path}    ${output_list}    Common Case UE start Traffic    ue_info_dict=${case6_ue_info}
    ...    tti_log_name=ttitrace_streaming    excpet_element_list=${all_cell_list[1:2]}    block_flag=${True}    log_time=90s
    Check Aasyslog And TTI    nr_cell_list=${all_nr_cell_list[1:2]}    aasyslog_path=${aasyslog_path}    tti_path=${tti_path}
    ...    exp_ul_tp=65    exp_dl_tp=185    startPrb=${9}    bler=${2}    except_rat0Bitmap_invaild_len=${-1}
    [Teardown]    Test Case Teardown    unblock_cell_list=${output_list}

[1]CB008927-N-iwk11-01_mutiple_Ues_under_FDD_asymmetric_30DL_10UL
    [Setup]    Test Case Setup
    ${aasyslog_path}    ${tti_path}    ${output_list}    Common Case UE start Traffic    ue_info_dict=${case11_ue_info}
    ...    tti_log_name=ttitrace_streaming    excpet_element_list=${all_cell_list[0:1]}    block_flag=${True}    log_time=90s
    Check Aasyslog And TTI    nr_cell_list=${all_nr_cell_list[0:1]}    aasyslog_path=${aasyslog_path}    tti_path=${tti_path}
    ...    exp_ul_tp=40    exp_dl_tp=324    bler=${2}    except_rat0Bitmap_invaild_len=${-1}
    [Teardown]    Test Case Teardown    unblock_cell_list=${output_list}

[1]CB008927-N-iwk5-02_DMRS_Type2_iwk_with_RAT1_and_dynamicswitch_RAT0_Ues_TDD_BF_Multi_UE
    [Setup]    Test Case Setup
    ${output_list}    UE attach And Start Traffic    ue_info_dict=${case8_ue_info}    excpet_element_list=${all_cell_list[3:4]}
    ...    block_flag=${True}
    Case 05 Capture log And Check    exp_ul_tp=160    exp_dl_tp=1200    tti_log_name=ttitrace_streaming    actDlDynSwitchAlloc=${True}
    ...    nr_cell_list=${all_nr_cell_list[3:4]}    bler=${1}
    Modify Parameters with json    input_list=${case5_para}
    Case 05 Capture log And Check    exp_ul_tp=160    exp_dl_tp=1200    tti_log_name=ttitrace_streaming1    actDlDynSwitchAlloc=${False}
    ...    nr_cell_list=${all_nr_cell_list[3:4]}    bler=${1}
    [Teardown]    run keywords    X80 Stop Traffic and release UE    ue_info_dict=${case8_ue_info}    AND
    ...    Test Case Teardown    unblock_cell_list=${output_list}    input_list=${case5_para_recover}

[1]CB008927-N-iwk2-02_dynamic_switch_IWK_with_3FDD_3TDD_interband_CA_with_TDD_as_Pcell
    [Setup]    robot_common_operations.Common Case Setup
    Log To Console   PASS
    [Teardown]    Common Case Teardown

[1]CB008927-N-iwk3-02_dynamic_switch_IWK_with_3FDD_3TDD_interband_CA_with_FDD_as_Pcell
    [Setup]    robot_common_operations.Common Case Setup
    Log To Console   PASS
    [Teardown]    Common Case Teardown

[1]CB008927-N-iwk-08_ET_01_Interworking_with_CB008370_PDSCH_Shared_Symbol_with_PDCCH_100Mhz
    [Setup]    Test Case Setup
    Modify Parameters with json    input_list=${case8_para}
    ${befor_counter}    Wait Until Keyword Succeeds    5min   1min    get_bts_counters    counter_ids=M55335C02019
    ...    counter_name_list=${case8_counter_name}    NRCELL_ID=${NRCELL4_ID}
    ${aasyslog_path}    ${output_list}    Case 08 UE start Traffic    ue_info_dict=${case8_ue_info}    block_flag=${True}
    ...    excpet_element_list=${all_cell_list[3:4]}
    Case 08 check point    log_path=${Test_case_log_dir}    pcap_file=l1l2bip_log    aasyslog_path=${aasyslog_path}    NRCELL_ID=${NRCELL4_ID}
    ...    befor_counter=${befor_counter}    nr_cell_list=${all_nr_cell_list[3:4]}    exp_ul_tp=160    exp_dl_tp=1200
    [Teardown]    Test Case Teardown    unblock_cell_list=${output_list}    input_list=${case8_para_recover}

[1]CB008927-N-iwk10-01_micro-DTX_optimized_scheduler_and_ enhance_Dyn_ slice-aware_IWK_with_RAT1
    [Documentation]    befor only check dl bler
    [Setup]     Test Case Setup
    Modify Parameters with json    input_list=${case10_para}
    ${befor_counter}    Wait Until Keyword Succeeds    5min   1min   get_bts_counters    counter_name_list=${case10_counter_name}
    ...    counter_ids=M55308C33000,M55308C33001    NRCELL_ID=${NRCELL7_ID}
    ${tti_path}    ${output_list}    Case 10 UE start Traffic    excpet_element_list=${all_cell_list[4:5]}    block_flag=${True}
    Run Keyword And Continue On Failure    Case 10 check Counter    befor_counter=${befor_counter}    NRCELL_ID=${NRCELL7_ID}
    Run Keyword And Continue On Failure    Case 10 Check TTI Log    tti_path=${tti_path}
    [Teardown]    Test Case Teardown    unblock_cell_list=${output_list}    input_list=${case10_para_recover}

[1]CB008927-N-iwk7-01_2RX_Redcap_Ues_RAT1_iwk_with_Dynamics_on_Rat0_UE_different_TDD_conifguration
    [Setup]    Test Case Setup
    ${befor_counter}    Wait Until Keyword Succeeds    5min   1min   get_bts_counters    counter_ids=M55138C00057,M55308C36003,M55308C36004
    ...    counter_name_list=${case7_counter_name}    NRCELL_ID=${NRCELL5_ID}
    ${aasyslog_path}    ${tti_path}    ${output_list}    Case 07 UE start Traffic    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}
    ...    excpet_element_list=${all_cell_list[5:6]}    ul_tp_list=${readcap_ue_ul_tp}
    ...    tcpdump_name=redcap_ue_tcpdump.pcap    tti_log_name=ttitrace_streaming    duration=60s
    Case 07 check Bip And Tcpdump    tcpdump_name=redcap_ue_tcpdump   tcpdump_check_value=1    aasyslog_path=${aasyslog_path}
    ...    tti_path=${tti_path}    nr_cell_list=${all_nr_cell_list[5:6]}    exp_ul_tp=10    exp_dl_tp=115
    Case 07 check Counter    befor_counter=${befor_counter}    NRCELL_ID=${NRCELL5_ID}
    [Teardown]    Test Case Teardown    unblock_cell_list=${output_list}

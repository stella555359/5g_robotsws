*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04


Library     ./Resources/CB008927_common_keyword.py
Resource    ./Resources/CB008927_common_keyword.robot
Variables   ./Resources/CB008927_modify_para.py

Suite Setup       CB008927 Suit Setup
Suite Teardown    CB008927 Suit Teardown


*** Variables ***
@{all_ue_list}      1    2    3    4    5    6    7    8    9    10    21    23    22  24   25   26   27   28   29   30



*** Test Cases ***
### use case469 scf and basic.cfg and iphy.xml
[1]CB008927-N-iwk4-01_sub-band_TRS_and_cell_specific_CSI-RS_IWK_with_RAT1_dynrat0_BF
    [Setup]    Case469 Setup
    ${aasyslog_path}    ${tti_path}    Case 04 UE start Traffic    dl_mbps=170    ul_mbps=130    tti_log_name=ttitrace_streaming
    Case 04 check Point    aasyslog_path=${aasyslog_path}    tti_path=${tti_path}    exp_ul_tp=100    exp_dl_tp=1380
    [Teardown]    Case Teardown

[1]CB008927-N-iwk9-01_dynamic_switch_iwk_with_2_dedicated_BWPs_shared_extended_and_legency
    [Setup]    Case469 Setup
    Modify Parameter And Wait On Air    input_list=${case9_para}
    ${aasyslog_path}    ${tti_path}    Case 04 UE start Traffic    dl_mbps=170    ul_mbps=130    tti_log_name=ttitrace_streaming
    Case 04 check Point    aasyslog_path=${aasyslog_path}    tti_path=${tti_path}    exp_ul_tp=100    exp_dl_tp=1300
    [Teardown]    run keywords    Modify Parameter And Wait On Air    input_list=${case9_para_recover}    AND    Case Teardown

[1]CB008927-N-iwk6-01_FDD_Slim_carrier_20Mhz_iwk_with_RAT1_Ues_dynamicswitch
    [Setup]    Case469 Setup
    ${aasyslog_path}    ${tti_path}    Case 06 UE start Traffic    tti_log_name=ttitrace_streaming
    Case 06 check Point    aasyslog_path=${aasyslog_path}    tti_path=${tti_path}    exp_ul_tp=130    exp_dl_tp=160
    [Teardown]    Case Teardown

[1]CB008927-N-iwk11-01_mutiple_Ues_under_FDD_asymmetric_30DL_10UL
    [Setup]    Case469 Setup
    ${aasyslog_path}    ${tti_path}    Case 02 UE start Traffic    dl_mbps=170    ul_mbps=30    ue_id_list=${all_ue_list[4:8]}
    ...    tti_log_name=ttitrace_streaming    trf_num=${2}
    Case 04 check Point    aasyslog_path=${aasyslog_path}    tti_path=${tti_path}    exp_ul_tp=45    exp_dl_tp=300
    ...    cell_list=${dl_cell_list1[1:2]}    check_numOfPrb=${False}    exp_bler=${0}
    [Teardown]    Case Teardown

## use normal scf and basic.cfg and iphy.xml
[1]CB008927-N-iwk2-02_dynamic_switch_IWK_with_3FDD_3TDD_interband_CA_with_TDD_as_Pcell
    [Setup]    Case Normal Setup
    ${aasyslog_path}    ${tti_path}    Case 02 UE start Traffic    dl_mbps=170    ul_mbps=130    ue_id_list=${all_ue_list[14:18]}
    ...    tti_log_name=ttitrace_streaming
    Case 02 check Point    aasyslog_path=${aasyslog_path}    tti_path=${tti_path}    exp_dl_tp=670
    [Teardown]    Case Teardown

[1]CB008927-N-iwk3-02_dynamic_switch_IWK_with_3FDD_3TDD_interband_CA_with_FDD_as_Pcell
    [Setup]    robot_common_operations.Common case Setup
    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS
    [Teardown]    robot_common_operations.Common case Teardown

[1]CB008927-N-iwk5-02_DMRS_Type2_iwk_with_RAT1_and_dynamicswitch_RAT0_Ues_TDD_BF_Multi_UE
    [Setup]    Case Normal Setup
    Modify Parameter And Wait On Air    input_list=${case5_para}
    SA UE Attach on cell    if_ul=${True}    if_dl=${True}    trf_num=${7}    ue_id_list=${all_ue_list[2:3]}    dl_mbps=170    ul_mbps=130
    Case 05 Capture log And Check    exp_ul_tp=102    exp_dl_tp=880    tti_log_name=ttitrace_streaming    actDlDynSwitchAlloc=${True}
    Modify Parameters with json    input_list=${case5_para2}
    Case 05 Capture log And Check    exp_ul_tp=102    exp_dl_tp=865    tti_log_name=ttitrace_streaming1    actDlDynSwitchAlloc=${False}
    [Teardown]    run keywords    Stop Traffic and release UE    ue_id_list=${all_ue_list[2:3]}    AND
    ...    Modify Parameter And Wait On Air    input_list=${case5_para_recover}    AND    Case Teardown

[1]CB008927-N-iwk7-01_2RX_Redcap_Ues_RAT1_iwk_with_Dynamics_on_Rat0_UE_different_TDD_conifguration
     [Setup]    Case Normal Setup
     ${befor_counter}    Wait Until Keyword Succeeds    5min   1min   get_bts_counters    counter_ids=M55138C00057,M55308C36003,M55308C36004
     ...    NRCELL_ID=${NRCELL3_ID}
     ${tti_path}    Case 07 UE start Traffic    trf_num=${1}    dl_mbps=38    ul_mbps=7    ue_id_list=${all_ue_list[4:8]}    exp_ul_tp=1.4
     ...    exp_dl_tp=28    tcpdump_name=redcap_ue_tcpdump.pcap    tti_log_name=ttitrace_streaming    duration=10s
     Case 07 check Bip And Tcpdump    tti_path=${tti_path}    tcpdump_name=redcap_ue_tcpdump   tcpdump_check_value=1    check_value=0
     ${tti_path1}    Case 07 UE start Traffic    trf_num=${5}    dl_mbps=170    ul_mbps=100    ue_id_list=${all_ue_list[2:3]}    exp_ul_tp=95
     ...    exp_dl_tp=675    tcpdump_name=normal_ue_tcpdump.pcap    tti_log_name=ttitrace_streaming1    duration=10s
     Case 07 check Bip And Tcpdump    tti_path=${tti_path1}    tcpdump_name=normal_ue_tcpdump   tcpdump_check_value=2    check_value=2
     Case 07 check Counter    befor_counter=${befor_counter}
     [Teardown]    Case Teardown

[1]CB008927-N-iwk-08_ET_01_Interworking_with_CB008370_PDSCH_Shared_Symbol_with_PDCCH_100Mhz
     [Setup]    Case Normal Setup
     Modify Parameter And Wait On Air    input_list=${case8_para}
     ${befor_counter}    Wait Until Keyword Succeeds    5min   1min    get_bts_counters    counter_ids=M55335C02019
     ...    NRCELL_ID=${NRCELL3_ID}
     ${aasyslog_path}    Case 08 UE start Traffic
     Case 08 check point    log_path=${Test_case_log_dir}    pcap_file=l1l2bip_log    aasyslog_path=${aasyslog_path}
     ...    befor_counter=${befor_counter}
     [Teardown]    run keywords    Modify Parameter And Wait On Air    input_list=${case8_para_recover}    AND    Case Teardown

[1]CB008927-N-iwk10-01_micro-DTX_optimized_scheduler_and_ enhance_Dyn_ slice-aware_IWK_with_RAT1
    [Setup]    Case Normal Setup
    Modify Parameter And Wait On Air    input_list=${case10_para}
    ${befor_counter}    Wait Until Keyword Succeeds    5min   1min   get_bts_counters
    ...    counter_ids=M55308C33000,M55308C33001,M55308C11001,M55308C11002    NRCELL_ID=${NRCELL3_ID}
    ${tti_path}    Case 10 UE start Traffic
    Run Keyword And Continue On Failure    Case 10 check Counter    befor_counter=${befor_counter}
    Run Keyword And Continue On Failure    Case 10 Check TTI Log    tti_path=${tti_path}
    [Teardown]    run keywords    Modify Parameter And Wait On Air    input_list=${case10_para_recover}    AND    Case Teardown


[1]CB008927_N_5G_RACH_setup_success_ratio_while_thoughput_testing
    [Setup]  EDA Case Setup
    EDA Case Test    counter_list=${EDA_case1_counter_id_list}    ue_number=${110}    cycles=${7}    step=${10}
    [Teardown]    Case Teardown


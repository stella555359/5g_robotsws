# *** Settings ***
# Resource    ./../Resources/CB008294_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/case_keywords.robot
# 
# Force Tags      5G_RRM    PY36
# Suite Setup     8294 suite preparation
# Suite Teardown  run keyword and ignore error    Common suite recovery
# 
# *** Test Cases ***
# [1]CB008294_A_B3_006_FR2_CA_for_SA_GNB-8CCDL_4CCUL_maxScell7DL3UL_contiguous_set_maxNumScellsDlFr2Sa_3_4_5_6_7_with_maxNumScellUL_3
#     [Documentation]    Author: Wang Yixiang
#     ...    Precondition:sCellActivationMethod for CA is set to blind.
#     ...        actCarrierAggregationFr2Sa=false
#     ...        NRBTS/maxNumScellsDlFr2Sa is set to 6.
#     ...        NRBTS/maxNumScellsUlFr2Sa is set to 2.
#     ...        NRBTS/maxNumOf3To4CCUsersFr2Sa=10
#     ...        NRBTS/maxNumOf5To8CCUsersFr2Sa=10
#     ...    Step1. UE attach
#     ...    Step2. Start UL&DL traffic, check 1CCUL&1CCDL TP OK
#     ...    Step3. UE dettach
#     ...    Step4. actCarrierAggregationFr2Sa=true
#     ...    Step5. UE attach
#     ...    Step6. Start UL&DL traffic, check 3CCUL&7CCDL TP OK
#     ...    Step7. UE dettach
#     ...    Step8. NRBTS/maxNumOf5To8CCUsersFr2Sa=0, NRBTS/maxNumScellsDlFr2Sa is set to 7, NRBTS/maxNumScellsUlFr2Sa is set to 3
#     ...    Step9. UE attach
#     ...    Step10. Start UL&DL traffic, check 4CCUL&4CCDL TP OK
#     ...    Step11. UE dettach
#     ...    Step12. NRBTS/maxNumOf5To8CCUsersFr2Sa=1
#     ...    Step13. UE attach
#     ...    Step14. Start UL&DL traffic, check 4CCUL&8CCDL TP OK
#     ...    Step15. UE dettach
#     [Setup]    8294 case setup    nidd_modify_via_api=${A_B3_006_PRE_API}    NSA_SA=SA    require_UE=${False}
#     log to console   \nUE attach, Start UL&DL traffic, check 1CCUL&1CCDL TP
#     ${tcpdump_log}    CPE UE attach and collect tcpdump log    tcpdump_log_name=1CCDL_1CCUL
#     ...    nr_cell_id=${pcell_nrCellIdentity}    prepare_ue_needed=${True}
#     Check NO CA in tcpdump log    log_path_pcap=${tcpdump_log}
#     Run keyword and continue on failure    Start traffic and verify tput for CPE
#     ...   cell_index=0     dl_tput=${DL_TPUT_1CC_COMMON}    ul_tput=${UL_TPUT_COMMON}
#     ...   exp_ul=${EXP_UL_1CC}    exp_dl=${EXP_DL_1CC}    target_avg_percent=0.9
# 
#     CPE UE detach
# 
#     log to console   \nactCarrierAggregationFr2Sa=true, UE attach, Start UL&DL traffic, check 3CCUL&7CCDL TP
#     Modify NIDD via rest api and wait onair    parameters=${ACT_CA_API}
#     ${tcpdump_log}    CPE UE attach and collect tcpdump log    tcpdump_log_name=7CCDL_3CCUL    nr_cell_id=${pcell_nrCellIdentity}
#     Check DL and UL CA in tcpdump log    log_path_pcap=${tcpdump_log}    DL_CC=${7}    UL_CC=${3}
#     Run keyword and continue on failure    Start traffic and verify tput for CPE
#     ...   cell_index=0,1,2,3,4,5,6,7     dl_tput=${DL_TPUT_7CC_COMMON}    ul_tput=${UL_TPUT_COMMON}
#     ...   exp_ul=${EXP_UL_3CC}    exp_dl=${EXP_DL_7CC}    target_avg_percent=0.9    appserver_num=2
# 
#     CPE UE detach
# 
#     log to console   \nmaxNumOf5To8CCUsersFr2Sa=0, maxNumScellsDlFr2Sa=7, maxNumScellsUlFr2Sa=3, UE attach and start traffic, check 4CCUL&4CCDL TP
#     Modify NIDD via rest api and wait onair    parameters=${CA_4CCDL_4CCUL_API}
#     ${tcpdump_log}    CPE UE attach and collect tcpdump log    tcpdump_log_name=4CCDL_4CCUL    nr_cell_id=${pcell_nrCellIdentity}
#     Check DL and UL CA in tcpdump log    log_path_pcap=${tcpdump_log}    DL_CC=${4}    UL_CC=${4}
#     Run keyword and continue on failure    Start traffic and verify tput for CPE
#     ...   cell_index=0,1,2,3,4,5,6,7     dl_tput=${DL_TPUT_4CC_COMMON}    ul_tput=${UL_TPUT_COMMON}
#     ...   exp_ul=${EXP_UL_4CC}    exp_dl=${EXP_DL_4CC}   target_avg_percent=0.9   appserver_num=2
# 
#     CPE UE detach
# 
#     log to console    \nmaxNumOf5To8CCUsersFr2Sa=1, UE attach, Start UL&DL traffic, check 4CCUL&8CCDL TP
#     Modify NIDD via rest api and wait onair    parameters=${CA_8CCDL_4CCUL_API}
#     ${tcpdump_log}    CPE UE attach and collect tcpdump log    tcpdump_log_name=8CCDL_4CCUL    nr_cell_id=${pcell_nrCellIdentity}
#     Check DL and UL CA in tcpdump log    log_path_pcap=${tcpdump_log}    DL_CC=${8}    UL_CC=${4}
#     Run keyword and continue on failure    Start traffic and verify tput for CPE
#     ...   cell_index=0,1,2,3,4,5,6,7    direction=dl    dl_tput=${DL_TPUT_LOW}    exp_dl=${EXP_DL_8CC}    target_avg_percent=0.9    process_num=2
# 
#     [Teardown]     Run Keyword And Ignore Error   Run Keywords
#     ...   CPE UE detach    AND
#     ...   Modify NIDD via rest api and wait onair    parameters=${CA_CASE_TEARDOWN_API}   AND
#     ...   8294 case teardown
# 
# [1]CB008294_A_PMO1_001_check_counter_GNB-8CCDL_4CCUL_maxScell7DL3UL_contiguous_freq_with_SA_FR2_CA_enabled
#     [Documentation]    Author: Wang Yixiang
#     ...    Precondition:
#     ...       sCellActivationMethod=bufferAndRLQualityBased
#     ...       NRBTS.actIpThpt=true
#     ...       NRBTS.actMacUserThpt=true
#     ...    Step1. UE attach
#     ...    Step2. start UL TP, 4 cells activated, check UL TP with 4CC OK
#     ...    Step3. start DL TP, other 4 cells activated, check DL TP with 8CC OK
#     ...    Step4. check counters
#     [Setup]    Common case setup    nidd_modify_via_api=${A_PMO1_001_API}    timeout_restapi=8min    NSA_SA=SA
#     ${case_start_time_info}    Prepare for counter log    reporting_interval=5
# 
#     ${tcpdump_log}    CPE UE attach and collect tcpdump log    tcpdump_log_name=8CCDL_4CCUL
#     ...    nr_cell_id=${pcell_nrCellIdentity}    prepare_ue_needed=${True}
#     Check DL and UL CA in tcpdump log    log_path_pcap=${tcpdump_log}    DL_CC=${8}    UL_CC=${4}
# 
#     Run keyword and continue on failure    Start traffic and verify tput for CPE    cell_index=0,1,2,3,4,5,6,7
#     ...    ul_tput=${UL_TPUT_COMMON}   dl_tput=${DL_TPUT_COMMON}
#     ...    exp_ul=${EXP_UL_4CC_B4}    exp_dl=${EXP_DL_8CC_B4}
#     ...    log_duration=30s    ignore_time=10s    target_avg_percent=0.9   appserver_num=2
# 
#     log to console    \nCheck counters
#     Check PM counter A_PMO1_001    starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}
#     [Teardown]     run keyword and ignore error    8294 case teardown
# 
# #test_keyword
# #    [Setup]    Common case setup    NSA_SA=SA
# #    ${tcpdump_log}    CPE UE attach and collect tcpdump log    tcpdump_log_name=8CCDL_4CCUL
# #    ...    nr_cell_id=${pcell_nrCellIdentity}    prepare_ue_needed=${True}
# #
# #    Run keyword and continue on failure    Start traffic and verify tput for CPE
# #    ...   cell_index=0     dl_tput=${DL_TPUT_COMMON}    ul_tput=${UL_TPUT_COMMON}
# #    ...   exp_ul=${EXP_UL_1CC}    exp_dl=${EXP_DL_1CC}    target_avg_percent=0.9
# #
# #    CPE UE detach
# #    [Teardown]     run keyword and ignore error    8294 case teardown
# 
# 
# [1]CB008294_A_B3_002_FR2_CA_for_SA_GNB-8CCDL_4CCUL_maxScell7DL3UL_contiguous_UL_DL_data_UDP_Peak
#     [Documentation]    Author: Fang ludan
#     ...    check UL and DL UDP Peak with 90% percent
#     ...    Step1. UE attach
#     ...    Step2. start UL TP, 4 cells activated, check UL TP with 4CC OK
#     ...    Step3. start DL TP, other 4 cells activated, check DL TP with 8CC OK
#     [Setup]    Common case setup      timeout_restapi=8min    NSA_SA=SA
#     ${tcpdump_log}   CPE UE attach and collect tcpdump log    tcpdump_log_name=8CCDL_4CCUL  nr_cell_id=${pcell_nrCellIdentity}
#      ...   prepare_ue_needed=${True}
#     Check DL and UL CA in tcpdump log    log_path_pcap=${tcpdump_log}    DL_CC=${8}    UL_CC=${4}
# 
#     Run keyword and continue on failure    Start traffic and verify tput for CPE    cell_index=0,1,2,3,4,5,6,7
#     ...    ul_tput=${UL_TPUT_COMMON}   dl_tput=${DL_TPUT_COMMON}
#     ...    exp_ul=${EXP_UL_4CC}    exp_dl=${EXP_DL_8CC}
#     ...    log_duration=30s    ignore_time=10s    target_avg_percent=0.90   appserver_num=2
#     [Teardown]     run keyword and ignore error    8294 case teardown

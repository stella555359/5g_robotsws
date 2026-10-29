# # # *** Settings ***
# # # Documentation
# # # ...    author: shenrao
# # # ...    contact: shengrong.rao@nokia-sbell.com
# # # ...    squad group: 5G_PZ_MMW_HZ_3_SG
# # # ...    Feature 5GC001937_OTA program
# # # ...    modify by LiuNing at 2021.4.27
# # # ...    modify by LiuNing at 2021.5.27
# # # 
# # # Resource    ./resources/5GC001937_utecloud_keywords.robot
# # # 
# # # Force Tags             5G_RAN_TDD    STATE_GNB_NOT_COMMISSIONED    master_pDU    CIT_21B    CRT_UTE
# # # ...    PY36
# # # ...    CLOUD_5G_SAMSUNG_ASOD_AEWD_ENB
# # # Suite Setup    Suite Precondition
# # # Suite Teardown
# # # 
# # # *** Variables ***
# # # ${ue_type}    ${tl.ues[0].capabilities[1]}
# # # #${du_8cc_scf_name}    DU_8CC_AEWD.xml
# # # ${4cc_ul_send}    250M
# # # ${4cc_ul_exp_udp}    220
# # # ${4cc_ul_exp_tcp}    220
# # # ${4cc_dl_send}    2100M
# # # #${4cc_dl_exp_udp}    1950
# # # #${4cc_dl_exp_tcp}    1950
# # # ${4cc_dl_exp_udp}    2052
# # # ${4cc_dl_exp_tcp}    2052
# # # ${8cc_ul_send}    250M
# # # ${8cc_ul_exp_udp}    220
# # # ${8cc_ul_exp_tcp}    220
# # # ${8cc_dl_send}    4200M
# # # #${8cc_dl_exp_udp}    3900
# # # #${8cc_dl_exp_tcp}    3900
# # # ${8cc_dl_exp_udp}    4053
# # # ${8cc_dl_exp_tcp}    4053
# # # ${deviation}    5%
# # # @{list_of_cell_8CC}    	14991361    14991362    14991363    
# # # ...        	14991364    14991365    14991366    14991367    14991368
# # # @{list_of_cell_4CC}     14991361    14991362    14991363    14991364
# # # ${4cc_duration}    7m
# # # ${8cc_duration}    22m
# # # ${4cc_UDP_process_num}    1
# # # ${8cc_UDP_process_num}    1
# # # ${target_avg_percent}    0.8
# # # ${min_percent}    0.7
# # # ${Check_interval}    30s
# # # *** Test Cases ***
# # # 
# # # 
# # # #Test Case5
# # # [1]5GC001937_OTA_8111_NSA_L3_Call_ULDL_UDP_Cloud_8CC_1DRB_AEWD-E_Contiguous
# # #     [Documentation]
# # #     ...    The purpose of this test is to verify basic configuration of RU RAU OAM configures RU,
# # #     ...    configuration not related to synchronization, transport and U-plane.
# # #     #[Tags]    CIT_TRUNK    CIT_20B     CIT    master_cloudbts_cuoam_int    5G_RAN
# # #     [Tags]    master_cloudbts_cuoam_int    5G_RAN    CIT	
# # #     [Setup]
# # #     Set Suite Variable   @{all_tp}    0.0    0.0    0.0    0.0    0.0    0.0
# # # 	Check if do recommission    expected_cell_numbers=8   scf_name=${du_8cc_scf_name}   
# # #     step2:Prepare UE
# # #     step3:UE Attach
# # #     step4:start traffic    protocol=udp    tp_direction=both    ul_throughput=${8cc_ul_send}    dl_throughput=${8cc_dl_send}
# # # 	...    duration=1800
# # #     ${log}    Run keyword and continue on failure     power_ue.Collect Tput
# # # 	...    Teardown_after_finished=False  ue_type=${ue_type}    duration=${Check_interval}    filter=L2Lo
# # # 	...    ignore_time=5ms
# # #     ${log}  Run keyword and continue on failure     Get TP log from aasylog file    TP_log=${log}
# # #      ...    Max_duration=${8cc_duration}    Traffic_Direction=both    Max_fail_number=${2}
# # #      ...    Check_interval=${Check_interval}
# # #      ...    log_path_GNB=/tmp/aasyslog_tput.txt    Continuous_failure=${True}    target_avg_percent=0.7
# # #      ...    min_percent=0.5
# # # 	    
# # # 	${all_tp}    Run keyword and continue on failure    power_ue.Check Bi Tput    
# # # 	...    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_8CC}
# # #     ...    ultarget_throughput=${8cc_ul_exp_tcp}    dltarget_throughput=${8cc_dl_exp_tcp}    actCarrierAggregation=${True}
# # #     ...    target_avg_percent=0.7    min_percent=0.5
# # #     [Teardown]    run keywords    Set Suite Variable    ${all_tp}    ${all_tp}
# # #             ...    AND    Case Teardown for TL915
# # #             ...    AND    run keyword and ignore error    KPI Report    protocol=udp    tp_direction=both
# # #             ...    deviation=${deviation}    exp_ul=${8cc_ul_exp_udp} Mbits/sec   exp_dl=${8cc_dl_exp_udp} Mbits/sec
# # #             ...    dl_avg=${all_tp[1][0]['average']} Mbits/sec
# # #             ...    dl_max=${all_tp[1][0]['peak']} Mbits/sec
# # #             ...    dl_min=${all_tp[1][0]['minimum']} Mbits/sec
# # #             ...    ul_avg=${all_tp[0][0]['average']} Mbits/sec
# # #            ...    ul_max=${all_tp[0][0]['peak']} Mbits/sec
# # #             ...    ul_min=${all_tp[0][0]['minimum']} Mbits/sec
# # #            ...    AND    run keywords     CaseTeardown
# # # 
# # # *** Test Cases ***
# # # 
# # # 
# # # 

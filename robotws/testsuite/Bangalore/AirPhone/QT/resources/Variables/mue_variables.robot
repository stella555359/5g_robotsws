*** Variables ***
#4G5G COMBO MUltiUE Variables
${lte_multi_ue_six_operator_value}    1,4,5,8,9,14,15,17,18,19,20,20,1,1,3,234:77,234:78,234:79,234:80,234:81,234:82,LTE
${lte_ue_range}    1,20
${ue_register_mue_value}   51,54,55,58,59,64,65,67,68,69,70,70,1,internal,234:77,234:78,234:79,234:80,234:81,234:82
${nsa_multi_ue_six_operator_value}    21,24,25,28,29,34,35,37,38,39,40,40,1,1,3,234:77,234:78,234:79,234:80,234:81,234:82,NSA
${nsa_ue_step_value}    21,40,1
${sa_ue_step_value}    51,70,1
${nsa_ue_range}    21,40
${sa_ue_range}    51,70
${sa_dl_traffic_range}    51,70,1,1,1,0,2000000,dl,86400
${sa_ul_traffic_range}    51,70,1,1,1,2000000,0,ul,86400
${nsa_traffic_range}    21,40,3
${lte_traffic_range}    1,20,3
${ap_iphy_range_value}    21,40,3,100
${multi_ue_script_NSA}    ${CURDIR}${/}../scripts/multi_ue_script_NSA.lua
${multi_ue_script_SA}    ${CURDIR}${/}../scripts/multi_ue_script_SA.lua
${sudo_ips_for_multi_ues}    ${CURDIR}${/}../scripts/sudo_ips_mue.sh
${sudo_ips_for_cus_multi_ues}    ${CURDIR}${/}../scripts/sudo_ips_mue_cus.sh
${lte_attach_stop_string}    LTE UE Attach is completed for 6 operators
${nsa_attach_stop_string}    NSA UE Attach is completed for 6 operators
${traffic_start_string}    Traffic is started successfully
${sa_traffic_start_string}    Traffic is started for SA UEs successfully
${ue_register_stop_string}    SA UE Register is over for 6 operators
${ue_attach_stop_string}    5G Attach is completed successfully
${sa_handover_params_1}    51,54,1,A3,57,10,10,20,20,5
${sa_handover_params_2}    55,58,1,A3,58,10,10,20,20,5
${sa_handover_params_3}    59,64,1,A3,59,10,10,20,20,5
${sa_handover_params_4}    65,67,1,A3,60,10,10,20,20,5
${sa_handover_params_5}    68,69,1,A3,61,10,10,20,20,5
${sa_handover_params_6}    70,70,1,A3,62,10,10,20,20,5
${nsa_handover_params_1}    21,24,2,51,1,A3,10,10,20,20
${nsa_handover_params_2}    25,28,2,52,1,A3,10,10,20,20
${nsa_handover_params_3}    29,34,2,53,1,A3,10,10,20,20
${nsa_handover_params_4}    35,37,2,54,1,A3,10,10,20,20
${nsa_handover_params_5}    38,39,2,55,1,A3,10,10,20,20
${nsa_handover_params_6}    40,40,2,56,1,A3,10,10,20,20
${ue_history_1}    51,54,234:77,22
${ue_history_2}    55,58,234:78,23
${ue_history_3}    59,64,234:79,24
${ue_history_4}    65,67,234:80,25
${ue_history_5}    68,69,234:81,26
${ue_history_6}    70,70,234:82,27
${reverse_sa_handover_params_1}    51,54,3,A3,50,11,11,30,30,5
${reverse_sa_handover_params_2}    55,58,3,A3,50,11,11,30,30,5
${reverse_sa_handover_params_3}    59,64,3,A3,50,11,11,30,30,5
${reverse_sa_handover_params_4}    65,67,3,A3,50,11,11,30,30,5
${reverse_sa_handover_params_5}    68,69,3,A3,50,11,11,30,30,5
${reverse_sa_handover_params_6}    70,70,3,A3,50,11,11,30,30,5
${reverse_nsa_handover_params}    21,40,2,50,1,A3,11,11,30,30
${SA_HO_Message}    Inter-eNB handover
${NSA_HO_Success}    Successfully reconfigured dual connectivity
${Reverse_NSA_HO_Success}    === Inter Sgnb Handover is successful ===
${Duration_before_HO}    2 min
${Duration_after_reverse_HO}    2 min
${Duration_post_HO}    2 min
${WTS_DIR}             /opt/wts/latest
${egate_file}          ${WTS_DIR}/egate_console.log
${ue_registeration_completion}    UE performed Registration type INITIAL_REGIS
${ue_context_setup_pattern}    Established PDU session ID
@{dl_data_rates}
@{ul_data_rates}
${TRS_COMBO_LOGS}    False
@{Counter_List_combo}    M55313C11009    M55314C04009
${testconfig}    ${EXECDIR}/testconfigs
${topology-config}    ${EXECDIR}/topology-configs
${custom-path}    ${EXECDIR}/custom_configs
${config-path}    ${EXECDIR}/robotws/testsuite/Bangalore/AirPhone/QT/resources/scripts
${scf_file_path}    ${EXECDIR}/robotws/testsuite/Bangalore/AirPhone/AP_P1Perf/resources/scripts/config_update.py
${cus_script_path}    /home/ute/scripts

#4G5G CUS MUltiUE Variables
${multi_ue_script_LTE_NSA}    ${CURDIR}${/}../scripts/multi_ue_script_LTE_NSA.exs
${lte_multi_ue_cus_six_operator_value}    1,4,5,8,9,11,12,14,15,17,18,20,500,128,234:77,234:78,234:79,234:80,234:81,234:82
${lte_dl_traffic_range}    1,20,6,dl,1,2000
${lte_ul_traffic_range}    1,20,6,ul,2,2000
${nsa_multi_ue_cus_six_operator_value}    21,24,25,28,29,34,35,37,38,39,40,40,500,128,234:77,234:78,234:79,234:80,234:81,234:82,1,11,50,100
${nsa_ul_traffic_range}    21,40,6,ul,2,2000
${nsa_dl_traffic_range}    21,40,6,dl,1,2000
${BEARER_ID_CUS}    6
${ul_rate_multiue}    2
${dl_rate_multiue}    2
${lte_ul_traffic_stop}    1,20,6,1
${lte_dl_traffic_stop}    1,20,6,2
${nsa_ul_traffic_stop}    21,40,6,1
${nsa_dl_traffic_stop}    21,40,6,2
${nsa_ue}    21,40
${lte_ue}    1,20
${nsa_multi_ue_split_traffic_cus}      21,24,25,28,29,34,35,37,38,39,40,40,500,128,234:77,234:78,234:79,234:80,234:81,234:82,1,11,50,50
@{Counter_List_cus}    M55326C00001    M55326C00002

${NSA_HO_params_1}    21,24,51,A3,636576,34,34,127,127
${NSA_HO_params_2}    25,28,52,A3,636576,34,34,127,127
${NSA_HO_params_3}    29,34,53,A3,636576,34,34,127,127
${NSA_HO_params_4}    35,37,54,A3,636576,34,34,127,127
${NSA_HO_params_5}    38,39,55,A3,636576,34,34,127,127
${NSA_HO_params_6}    40,40,56,A3,636576,34,34,127,127
${NSA_RO_param}    21,40,50,A3,636576,34,34,127,127
${NSA_HO_pattern}    === Bearer-type change from MCG to SCG-split is successful ===
@{gnb_values}    4    14    6    2    12    8    10

#IPV4 Config Variables for CUS
${lte_multi_ue_cus_operator_value}    1,20,500,128,234:77
${nsa_multi_ue_cus_operator_value}    21,40,1,11,1000,128,234:77,50,100
${testline_file}    /home/ute/.ute-ca/executions/1/configs/testline_configuration/__init__.py
${dist_VLANIF-3}    MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-3
${dist_VLANIF-1}    MRBTS-1/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-1/VLANIF-1

${NSA_HO_params_DS}    21,40,51,A3,636576,34,34,127,127

#IPv4 Config Variables
${lte_multi_ue_operator_value}    1,20,1,1,3,234:77
${attach_stop_string}    Attach is completed successfully
${nsa_multi_ue_operator_value}    21,40,1,1,3,234:77

${ue_register_mue_sa_value}   51,70,1,internal
${ue_register_string}    SA UE Register is over

${sa_handover_params}    51,70,1,A3,57,10,10,20,20,5
${ue_history}    51,70,234:77,22
${reverse_sa_handover_params}    51,70,3,A3,50,11,11,30,30,5

${nsa_handover_params}    21,40,2,51,1,A3,10,10,20,20

${testline_resuls_path}    /home/ute/testline_update_results/configs
${dist}    MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${ID}   vlanId

#Split Traffic Variables
${lte_detach_string}    detach for all UEs successful
${sa_deregister_string}    SA UE Deregister is over
${nsa_multi_ue_split_traffic}   21,24,25,28,29,34,35,37,38,39,40,40,1,1,2,234:77,234:78,234:79,234:80,234:81,234:82,NSA
${ap_iphy_split_range}    21,40,2,50
${nsa_traffic_split_range}    21,40,2
${lte_nsa_ue_range}    1,40

#GTPU Related Variables
${ECHO_Req1}    gtp.message == 0x01 && ip.src == 10.0.1.111 && ip.dst == 10.0.1.115
${ECHO_Req2}    gtp.message == 0x01 && ip.src == 10.0.1.115 && ip.dst == 10.0.1.111
${ECHO_Req3}    gtp.message == 0x01 && ipv6.src == fc00::a00:111 && ipv6.dst == fc00::a00:133
${ECHO_Req4}    gtp.message == 0x01 && ipv6.src == fc00::a00:133 && ipv6.dst == fc00::a00:111
${ECHO_Req5}    gtp.message == 0x01 && ipv6.src == fc00::a00:111 && ipv6.dst == fc00::a00:115
${ECHO_Req6}    gtp.message == 0x01 && ipv6.src == fc00::a00:115 && ipv6.dst == fc00::a00:111

${ECHO_Resp7}   gtp.message == 0x02 && ip.src == 10.0.1.111 && ip.dst == 10.0.1.115
${ECHO_Resp8}   gtp.message == 0x02 && ip.src == 10.0.1.115 && ip.dst == 10.0.1.111
${ECHO_Resp9}    gtp.message == 0x02 && ipv6.src == fc00::a00:111 && ipv6.dst == fc00::a00:133
${ECHO_Resp10}    gtp.message == 0x02 && ipv6.src == fc00::a00:133 && ipv6.dst == fc00::a00:111
${ECHO_Resp11}    gtp.message == 0x02 && ipv6.src == fc00::a00:111 && ipv6.dst == fc00::a00:115
${ECHO_Resp12}    gtp.message == 0x02 && ipv6.src == fc00::a00:115 && ipv6.dst == fc00::a00:111


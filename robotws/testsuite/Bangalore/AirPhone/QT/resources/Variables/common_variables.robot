*** Settings ***
Documentation     This contains common keywords which are needed to run P1 L3 Calls.
...               :author Anil

*** Variables ***
${Ng_link_pattern}    NG primary peer address.*up
${Ng_link_pattern_dual_stack}    NG link is Up
${Address_distribution_pattern}    Address Distribution is complete
${Cell_setup_complete_pattern}    Cell Setup completed
${UE_SIB_decoding_pattern}    SystemInformationBlockType1
${UE_SIB_decoding_pattern_eNB}    SystemInformationBlockType2
${UE_register_complete_pattern}    .*REGISTRATION COMPLETE.*
${Register_complete_pattern}    REGISTRATION COMPLETE
${Initial_context_setup_pattern}    Initial Context Setup Successful
${Initial_UE_message_pattern}    I\nnitial UE Message Success
${Initial_UE_success_pattern}    .*Initial UE Message Success.*
${Initial_UE_success_message}    Initial UE Message Success
${UE_deregister_pattern}    UE Context Release Complete
${X2_link_pattern}    ENB-1: X2AP Link with GNB-2 .* is up
${X2_link_pattern_2}    ENB-1: X2AP Link with GNB-3 .* is up
${LTE_attach_pattern}    UE IS ACTIVE
${UE_attach_pattern}    reported successful RA
${UE_5GDetach_pattern}    Bearer-type change from SCG-split to MCG
${UE_detach_pattern}    detached
${UE_reattach_pattern}    UE IS ACTIVE
${UE_SIB_pattern_startup_l3_log}    SIB1 received for
${Trf_type}    internal
${GUI_Snapshot}    False
${S1_link_pattern_dual_stack}    S1 link is Up
${test_pc}    2
${btslog_collector_name}    btslog
${CA_Verification_pattern}    SCellIndex 9 activated successfully at airphone
${CARR_AGGR}    False
${ca_ag}    False
${enb_endc_param_id}    1
${serving_cell_range}    8:15
${custom_cell}    False
${counter_directory}    /home/ute/gnb_pm_counters/
${COUNTER_VALIDATION}    False
${Timeout_SA}    300
${Timeout_NSA}    300
${Total_Timeout}    5 min
${Retry_Timeout}    15 sec
${UE_Reattach_sleep}    5 sec
${UE_Reregister_sleep}    20 sec
${Pdu_session_ID}    1
${UE_ID}    1
${UE_ID_SANSA}    101
@{UE_IDs_NSA}    101    151
@{UE_IDs_SA}     1    51
${nwslice_ID}    1
${gw_ID}    1
${eNB_target}    2
${enb_target_2}    3
${Target_gNB}    2
${Target_gNB_2}    3
${Target_Cells}    1
${Target_Cell_2}    2
${Target_Cell_3}    3
${min_cell_id}    0
${max_cell_id}    8
${Bearer_ID}    2
${Traffic_ul_rate_SA}    3
${Traffic_ul_rate_FDD}    3
${Traffic_ul_rate_TDD}    5
${Traffic_ul_rate}    3
${Traffic_dl_rate}    5
${Traffic_ul_rate_TDD_mmwv}    2
${START_TCP_TRAFFIC}    True
${DATA_TCP_ENABLE_FLAG}    False
${vRAN_Snapshot_Flag}    False
${DL_TCP_data_rate}    5
${UL_TCP_data_rate}    3
${duration}    600sec
${P0_duration}    5 min
${ap_log}    startup_l3.log
${Multi_gNB}    0
${UE_ID_NSA}    11
${sa_offset}    20
${nsa_offset}    20
${sa_start_id}    1
${nsa_start_id}    101
${CUS_SA_DL}    80
${CUS_SA_UL}    20
${CUS_NSA_DL}    80
${CUS_NSA_UL}    20
${CUS_LTE_DL}    5
${CUS_LTE_UL}    5
${BF_RU_RESET}    4
${JUMP_HOST}    10.63.67.175
${JUMP_USERNAME}     ute
${JUMP_PASSWORD}     App1@k_zxc2022
${JUMP_PORT}         22
${AP_DIR}       /user/egate
@{gscns}    8228    8158
@{arfcs}    670000    663332
${temp_install_pip}    false

#Below are the vaiables to support HO
${HO_pattern_SA}    Intra-eNB handover
${HO_pattern_NSA1}    reported successful RA
${HO_pattern_NSA2}    Sending SgNB Modification Confirm
${HO_flag}    False
@{sa_ueids_HO}    1    51
@{meas_id_A2_TDD_FDD_HO}    1    6
@{meas_id_A3_TDD_FDD_HO}    5    10
@{nsa_ueids_HO}    101    151
@{nsa_meas_id_A2_TDD_FDD_HO}    2    5
@{nsa_meas_id_A3_TDD_FDD_HO}    4    3
@{phy_id_TDD_FDD_HO}    52    50
@{meas_id_A3_FDD_HO}    1
@{phy_id_FDD_HO}    53    52
${event_A2}    A2
${event_A3}    A3
${srsrp_nr}    30
${srsrq_nr}    30
${nrsrp_nr}    50
${nrsrq_nr}    45
${meas_gap}    gp0:0
${mgta}    ms0

#Multi Beam Forming Vars For Stability Suite
@{profile_id_multi_BF}    1   2    3    4    5    6
@{gw_ids_multi_BF}    1    1    1    1    1    1
@{targetcell_ids_multi_BF}    1    1    1    1    1    1
${ueBeamIndexInitial_1}    1,0,2,3,4,5
${ueBeamIndexInitial_2}    2,0,1,3,4,5
${ueBeamIndexInitial_3}    3,0,1,2,4,5
${ueBeamIndexInitial_4}    4,0,1,2,3,5
${ueBeamIndexInitial_5}    5,0,1,2,3,4
${ueBeamIndexInitial_6}    0,1,2,3,4,5
@{ssbeam_bestbeam_id_multi_BF}    1    2    3    4    5    0
@{ssbeam_rsrp_best_id_multi_BF}    -44    -45    -50    -55    -60    -65
@{ssbeam_rsrp_avg_id_multi_BF}    -50    -120    -125    -120    -139    -70
@{sa_ueids_multi_BF}    1    2    3    4    5    6
@{nsa_ueids_multi_BF}    101    102    103    104    105    106
@{ueBeamIndexInitial_vals}    ${ueBeamIndexInitial_1}    ${ueBeamIndexInitial_2}    ${ueBeamIndexInitial_3}
...    ${ueBeamIndexInitial_4}    ${ueBeamIndexInitial_5}    ${ueBeamIndexInitial_6}

#General BF in FR1 QT
#for NSA
${ueBIndex_Initial_1}    1,0,2,3,4,5
${ssbeam_bestbeam_1}       1
${ssbeam_rsrp_best_1}      -45
${ssbeam_rsrp_avg_1}       -120
${profile_id_1}            2

#for SA
${ueBIndex_Initial_2}    2,0,1,3,4,5
${ssbeam_bestbeam_2}       2
${ssbeam_rsrp_best_2}      -44
${ssbeam_rsrp_avg_2}       -50
${profile_id_2}            1

#Please dont change the index , append the new data in next line
@{HTpCfg}    fs_tdd_sansa_eCpri_cmwv_LO_AP_LO_ORAN
...          fs_tdd_sansa_eCpri_cmwv_LO_AP_LO
...          fs_tdd_sansa_eCpri_cmwv_ASOE_AP_LO
...          fs_tdd_sansa_ecpri_cmwv_MP_AP_LO_2S_1CC_CIT_GMC
...          fs_fdd_sansa_cpri_cmwv_MP_AP_LO_2S_1CC_CIT_GMC
...          fs_fdd_sansa_cpri_cmwv_LO_AP_LO
...          fs_fdd_sansa_ecpri_dRNIC_1vDU_P_AP_LO_SWFH_cmwv
...          fs_tdd_sansa_eCpri_cmwv_MP_AP_LOOO_GMC
...          fs_tdd_sansa_eCpri_cmwv_LO_AP_LO_4G_CUS
...          fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_AZQJ_GMC
...          fs_tdd_sansa_eCpri_cmwv_LN_AP_LO
...          fs_sansa_ecpri_cmwv_tdd_LO_AP_LO_AQQL_16DL8UL

${HTp}    False
${HighTput_ul_rate}    20
${HighTput_dl_rate}    80
${TP_eval_min}    2
${TP_eval_sec}    120
${HIGH_THROUGHPUT_FLAG}    False
${tcp_dump_dur_HTp}    2m
${HIGH_THROUGHPUT_TCPDUMP}    True
${WTS_Config_update_Flag}    False
${TRF_DL}    True
${TRF_UL}    True
${DEV_TEST}    False

#Flags for Enabling Bip logs for LOKI SA and NSA Traffic Sequential suite
${SA_Traffic_BIP}    False
${NSA_Traffic_BIP}    False

# Flag for TTI Traces collection
${TTI_TRACE}    False
${phy_cell_id}    50,51,52,53
${phy_cell_id_fr1}    50,52,53
${phy_cellid_mp}    50
${phy_cell_id_oran}    50,51

#Variables for InterfaceMirroring gNB BIP log collection via GUI
${interface_case}    L1-L2
${destination}    Local
${mirroring_time}    600
${mirroring_timeout}    120

@{TCP_Data_Variants}    fs_fdd_sansa_ASIB_ABIO_cmwv
${AP_L1_Log}    False
${AP_L1_Log_Folder}    L3call
${single_run_info_file}    /home/ute/testline_init_results/logs/INFO_log.txt
${single_run_info_for_common_agent}    /home/ute/testline_init_results/agent.log
${single_run_info_for_ca}    /home/ute/.ute-ca/executions/1/logs/agent.log
${single_run_info_path_for_ca}    /home/ute/.ute-ca/executions/logs/agent.log
${testline_results_file}    /home/ute/testline_update_results/logs/INFO_log.txt
${testline_config_path}       /home/ute/testline_configuration
${testline_results_path}    /home/ute/testline_update_results/
${testline_results_file_common_agent}   /home/ute/testline_update_results/agent.log
${testline_init_path}       /home/ute/testline_init_results/
${ute_ca_logs_path}    /home/ute/.ute-ca/executions/1/configs/testline_configuration
${ute_ca_singlerun_path}    /home/ute/testline_init_results/execution/configs/testline_configuration
${Init_Path}    /home/ute/testline_init_results/execution/logs/agent.log
${ute_logs_path}    /home/ute/ute_ca_logs/execution/logs/agent.log
${workspace_path}    ${EXECDIR}/logs/agent.log
${test_property_file}    ${EXECDIR}/test.properties
${AMF_ID}    1
${run_script_log_set}    ${CURDIR}${/}../scripts/run_script_log_set.lua
${EXTEND_ORAN}     False
${oran_user}    xranuser
${oran_pwd}    xran-password
${max_data_rate}    160
${qfi_id_1}    1
${qfi_id_2}    2
${burst_size}    1350
${FR1_TDD_FDD}    False    #Common Variable for fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC config
${ORAN_TDD_FDD}    False    #Common Variable for fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_ORAN config
#OAM Related Variables
${OPERATION_ITERATION}    1
#Operations varaiables
&{operation_keyword}    fs_tdd_fdd_sansa_cpri_eCpri_cmwv_BOO_AP_LOO_CIT=Perform Cell Block Unblock for Classical gNB
...                     fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_GMC=Perform Soft Cell Reset via Param Update for Classical gNB
...                     fs_fdd_tdd_sansa_cmwv_h_ap_loo_GMC=Perform NR Cell Lock and Unlock
...                     fs_fdd_tdd_sansa_cpri_ecpri_cmwv_MP_AP_LO_AZHL_GMC=Perform RU Lock and Unlock for Classical gNB
...                     fs_tdd_fdd_sansa_eCpri_cmwv_MP_AP_LOOO_GMC=Perform NR Cell Lock and Unlock
...                     fs_sansa_cpri_cmwv_fdd_eCpri_cmwv_tdd_LOO_AP_LOOO=Perform NR Cell Lock and Unlock
...                     fs_sa_Cpri_cmwv_fdd_eCpri_cmwv_tdd_ASOE_AP_LOOO=Perform RU Lock and Unlock for Classical gNB
...                     fs_sansa_ecpri_cmwv_tdd_LO_AP_LO_AQQL_16DL8UL=Perform Soft Cell Reset via Param Update for Classical gNB


#Max Throughput Variables for QT

@{MTpCfg}    fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO    fs_tdd_nsa_eCpri_mmwv_LO_AP_LO
...          fs_fdd_sansa_cpri_cmwv_LO_AP_LO_2S_1CC    fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC
...          fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF
...          fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_2S_4CC
...          fs_tdd_sansa_ecpri72e_cmwv_MP_AP_LO
...          fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_AZQJ_GMC
...          fs_tdd_sa_eCpri_cmwv_E_AP_E_6G
...          fs_tdd_sansa_ecpri_dRNIC_1vDU_P_AP_LO_SWFH_cmwv
...          fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_CA_HO
...          fs_tdd_sansa_ecpri72e_cmwv_MP_AP_LO_CIT
...          fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_HO
...          fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_GMC
...          fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_GMC
...          fs_fdd_sansa_eCpri_cmwv_LO_AP_LO_ORAN_DCM
...          fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_HO_GMC
...          fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_APQT_REG
...          fs_sansa_ecpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_ORAN_GMC

@{BFCfg}    fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF
...         fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_HO
...    		fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_HO_GMC
...         fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_APQT_REG

@{QT_stability_cfg}    fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_APQT_REG

${sa_ueid_tdd_HTpQT}    1
${sa_ueid_tdd_HTpQT_Cell2}    21
${sa_ueid_fdd_HTpQT}    51
${sa_ueid_fdd_HTpQT_Cell4}    71
${nsa_ueid_tdd_HTpQT}    101
${nsa_ueid_tdd_HTpQT_Cell2}    121
${nsa_ueid_fdd_HTpQT}    151
${nsa_ueid_fdd_HTpQT_Cell4}    171
@{Multi_UE_TDD_FDD_Configs}    fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC
...                            fs_tdd_fdd_sansa_dRNIC_1vDU_P_AP_LO_DC_cmwv
...                            fs_fdd_tdd_sansa_cmwv_h_ap_loo_GMC
...                            fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_AZQJ_GMC
...                            fs_sansa_ecpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_ORAN_GMC
...                            fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_GMC
...                            fs_fdd_tdd_sansa_cpri_ecpri_cmwv_MP_AP_LO_AZHL_GMC

@{sa_ueids_HTpQT}    1
@{nsa_ueids_HTpQT}    101

${MaxTp_QT}    True

${MTp_FR1_TDD_SA_dl}    1000                 #CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
${MTp_FR1_TDD_SA_ul}    200
${MTp_FR1_TDD_NSA_dl}    400
${MTp_FR1_TDD_NSA_ul}    200

${MTp_VRAN_TDD_SA_dl}    1400                 # CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
${MTp_VRAN_TDD_SA_ul}    200
${MTp_VRAN_TDD_NSA_dl}    800
${MTp_VRAN_TDD_NSA_ul}    200

${MTp_6G_TDD_SA_dl}    1400                 #CLOUD_6G_E_AP_E
${MTp_6G_TDD_SA_ul}    180

${MTp_MP_AP_LO_TDD_SA_dl}    1000                 #MP_AP_LO_TDD_ECPRI72E
${MTp_MP_AP_LO_TDD_SA_ul}    150

${MTp_FR2_TDD_NSA_dl}    550                 #CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
${MTp_FR2_TDD_NSA_ul}    110

${MTp_FR1_FDD_SA_dl}     200
${MTp_FR1_FDD_SA_ul}     200
${MTp_FR1_FDD_NSA_dl}    200
${MTp_FR1_FDD_NSA_ul}    200                 #CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

&{GNB_BTS}     Ip=192.168.255.129    Username=Nemuadmin    Password=nemuuser    Port=443
&{AP_ASIK}     Ip=192.168.200.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=ApAsik
&{GNB_ASIK}    Ip=192.168.255.129    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=GnbAsik
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
&{ENB_BTS}     Ip=192.168.255.129    Username=Nemuadmin    Password=nemuuser    Port=443

#4G5G_Combo Specific Variables
${4G5G_phycellid}   50
${nrsrp}    127
${event}    B1_NR
${scg_ul_dist_percent}  100
${nr_cgi_plmn_ident_info_id}    1
${nr_cgi_cell_ident}    010011100
${nr_cgi_plmns_ident}   234:77
${4G5G_Combo}     0
${4G5G_Combo_GNB_IP}    192.168.255.119
${GNB_BTS_IP}    192.168.255.129
${enb_cell_id}    11
${enb_id}    1
${variant_name}    ${EMPTY}
${QCI}    128
${Bearer_CUS}    UE-initiated Bearer Creation
${dl_rate_CUS}    5
${ul_rate_CUS}    5
${UE_Detach}    UE IS OFF
${4G5G_CUS}    0
&{CUS_VAR}    nrsrp=97    srsrp=97    srsrq=34    nrsrq=30    nsinr=0
${daemon}    -daemon
${GTPU_port}    2152
${tput_per}    99
${cus_logs_path}    /home/cus/logs
${cus_iptable}    sudo iptables -D INPUT -p tcp -d 0/0 -j ACCEPT
${AP_Pattern}    5G_4

#variables for BOAM_ET_CONF
${BOAM_ET_CONF}    0

#wts vm statistics variables
${WTS_VM_Statistics}    False
${wts_vm_process_suitesetup}   wts_vm_process_suite_setup.txt
${wts_vm_process_suiteteardown}   wts_vm_process_suite_teardown.txt
${wts_vm_system_info}   wts_vm_system_info.txt
${wts_vm_top_results}   wts_vm_top_results.txt

${Auto_NIDD_Update_Flag}   False
${gNB_P1_NIDD_Update_Flag}    False
${gNB_P1_Run}                 false
${SKIP_WTS_CONFIG_DOWNLOAD}    False

#LOG SYNC Variables
${LOG_SYNC}                false
${LOG_SYNC_FILE}           logsync_logs_folder.txt
${vm_logdir}               ${EXECDIR}/logs
${test_state}              false
${RUN_LOGSYNC}             false
${Collect_Sosreport}       True
${QT_CONFIG}               false
#IQ Log Capture
@{IQ_Variants}    fs_tdd_nsa_eCpri_mmwv_LO_AP_LO    fs_tdd_sansa_eCpri_cmwv_LO_AP_LO    fs_fdd_sansa_cpri_cmwv_LO_AP_LO_2S_1CC
...               fs_tdd_sansa_ecpri72e_cmwv_MP_AP_LO    fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF
...               fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_AZQJ    fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_AZQJ_GMC
...               fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_HO     fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_HO_GMC
...               fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_GMC    fs_sansa_ecpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_ORAN
...               fs_sansa_ecpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_ORAN_GMC

${Suspicious_IQ1}    confmgmtbrowser write NrUlPhy phyEventEnable 2147483648
${Suspicious_IQ2}    confmgmtbrowser write NrUlPhy phyEventEnableExt 8589934592
${IQ_Path}    scp /etc/snapshot.conf /usr/lib64/python/
${IQ_sed1}    sed -i 's/numUlSubCellId = 0/numUlSubCellId = 1/g' /usr/lib64/python/snapshot.conf
${IQ_sed2}    sed -i 's/ulSubCellId1 = 1/ulSubCellId1 = 0/g' /usr/lib64/python/snapshot.conf
${IQ_sed3}    sed -i 's/numDlSubCellId = 0/numDlSubCellId =0/g' /usr/lib64/python/snapshot.conf
${IQ_sed4}    sed -i 's/dlSubCellId1 = 0/dlSubCellId1 = 0/g' /usr/lib64/python/snapshot.conf
${IQ_etcpath}    cd /usr/lib64/python/ ; cp snapshot.conf /etc
${IQ_Start}    cd /usr/lib64/python/ ; syscomctl node_id list | grep local | awk '{print $3}'|xargs -l -I [] python3 syscom_msgsend.py [] 2
${IQ_Stop}    cd /usr/lib64/python/ ; syscomctl node_id list | grep local | awk '{print $3}'|xargs -l -I [] python3 syscom_msgsend.py [] 1
${IQ_copy}    cp /ram/L1Log/Snapshot/slot_*/soc_*/*bin /tmp
${IQ_Stop_Time}    20s
${IQ_ENABLE_FLAG}    False
${IQ_SYS}    False

#AP P1 Perf variable
${AP_P1Perf}    False
${test_label}    Perf_Mue
${Perf_Testsuite}    False
${perf_mue}    False
${Fdd_Perf}    False
${AP_P1Perf_ABIL}    False
${IWF_ENABLED}    False
${AP_P1Perf_mmwv}    False
${STRACE_ENABLE}    False
${IWF_FR1_LOO_LOOO}    False

# SosReport Options Variable
${sosreport_options_ABIP} =     SEPARATOR=
   ...                          -exclude=enableFPGAMirroringOnGnb,enablePortMirroringFSOnGnb,startTcpDumpOnGnb,
   ...                          wait_for_interfacesOnGnb,wait_for_interfacesonAP

# Auto NIDD Related params
@{Auto_NIDD_Update_Branch_Variants}    fs_tdd_sansa_cmwv    fs_fdd_sansa_cmwv    fs_fdd_sansa_ASIB_cmwv
@{Auto_NIDD_Update_Trunk_Variants}    fs_tdd_sansa_eCpri_cmwv_LO_AP_LO_4G_CUS
...                                   fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF
...                                   fs_tdd_fdd_sansa_cpri_eCpri_cmwv_BOO_AP_LOO_CIT
...                                   fs_tdd_sansa_eCpri_cmwv_LO_AP_LO_ORAN_GMC
...                                   fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_GMC
...                                   fs_tdd_sansa_ecpri72e_cmwv_MP_AP_LO
...                                   fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_GMC
${topology_config_base_url}           https://gitlabe2.ext.net.nokia.com
${ca_5gair_token}                     glpat-Vy_N4xxybtKJzp35UXUF
${topology_config_project_id}         39803
${auto_merge_flag}                    true

${SAVE_WTS_PCAP_FLAG}    True
${WTS_UDP_LOG}    False    #Flag to enable collection of UDP tcpdump in wts
${L2PS_TTI_TRACE}    True    #Flag to enable L2ps TTI traces via taf collectors

#Crash Detection related params
${ENABLE_CRASH_DETECTION}    True
${crash_detection_complete_flag}    False

#Perform Cell Block Unblock for all cells
${CELL_BLOCK_UNBLOCK}    False
${CELL_BLOCK_UNBLOCK_ITERATION}    1

#RU Lock and Unlock test on ORAN
${RU_LOCK_UNLOCK}    False
${RU_LOCK_UNLOCK_ITERATION}    1


#Card reset variables
${ABIO_CARD}    MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1
${BBMOD_RESET_ITERATION}    1

#Perform NG Link Lock Unlock
${NG_LOCK_UNLOCK}    False
${NG_LOCK_UNLOCK_ITERATION}    1
${Fault_ID}    7107
${Alarm_id}    7114
${Alarm_detail}   Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability

@{AP_QT_ALLOWED_ALARMS}
...    4654    #Ethernet port security is disabled
...    4655    #Service account root access is enabled
...    61524   #SSH enabled
...    7300    #No X2 link available
...    61649   #LMP access via port 443
...    7523    #Cell Activation timeout at gNB-DU
...    7107    #Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...    7304    #NG SCTP endpoint broken
...    4592    #BTS Reset Cause
...    61652   #R&D Service Port enabled
...    7305    #NG SCTP setup fail
...    4681    #Sanity Check Error
...    2002    #Receiving failure in optical interface
...    4334    #Serial console activated
...    4657    #Nokia MN BTS SFP validation failure
...    4641    #SSH client authentication failure
...    49      #Alarm Cell blocked

# RINLINE configuaration
@{RINLINE}    fs_tdd_sansa_ecpri_dRNIC_1vDU_cmwv
...           fs_tdd_sansa_ecpri_dRNIC_1vDU_P_AP_LO_SWFH_cmwv
...           fs_fdd_sansa_ecpri_dRNIC_1vDU_P_AP_LO_SWFH_cmwv
...           fs_tdd_fdd_sansa_dRNIC_1vDU_P_AP_LO_DC_cmwv
...           fs_tdd_fdd_sansa_dRNIC_1vDU_P_AP_LOO_DC_cmwv

# AP P1 Configuration
@{AP_P1_CONFIGURATION}    fs_tdd_sansa_eCpri_cmwv_LO_AP_LO_4G_CUS
...                       fs_tdd_fdd_sansa_cpri_eCpri_cmwv_BOO_AP_LOO_CIT
...                       fs_tdd_sansa_ecpri_dRNIC_1vDU_P_AP_LO_SWFH_cmwv
...                       fs_fdd_sansa_ecpri_dRNIC_1vDU_P_AP_LO_SWFH_cmwv
...                       fs_tdd_sa_eCpri_cmwv_E_AP_E_6G
...                       fs_tdd_fdd_sansa_dRNIC_1vDU_P_AP_LO_DC_cmwv
...                       fs_tdd_fdd_sansa_dRNIC_1vDU_P_AP_LOO_DC_cmwv

# AP P0 Configuration
@{AP_P0_CONFIGURATION}    fs_tdd_sansa_eCpri_cmwv_LO_AP_LO_ORAN
...                       fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO
...                       fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_GMC
...                       fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF
...                       fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_GMC
...                       fs_sansa_ecpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_ORAN_GMC
...                       fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_HO
...                       fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_HO_GMC
...                       fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_CA_HO
...                       fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_AZQJ_GMC
...                       fs_tdd_sansa_ecpri72e_cmwv_MP_AP_LO
...                       fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC
...                       fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_GMC

# EGEN Servers
@{egen_server_tl}    7-2-CLOUDCLASSTL99
${egen_tl_IP}        10.53.191.183
${egen_tl_Passwd}    UTE.debian12

${egen_tl}    False
${egen_port_1}    0000:03:00.0
${egen_port_2}    0000:82:00.0
${egen_port_3}    0000:82:00.1


&{CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_CMWV_TDD}    SUITE_WTS_CFG=wts_config_LO_AP_LO_TDD_eCPRI_cmwv_NSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_nsa_eCpri_cmwv_LO_AP_LO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_nsa_eCpri_cmwv_LO_AP_LO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=NSA
   ...    l1=FS    RU_type=AEQN    COMPONENT_CARRIER=1

&{CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD}    SUITE_WTS_CFG=wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_eCpri_cmwv_LO_AP_LO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_eCpri_cmwv_LO_AP_LO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AEQE    COMPONENT_CARRIER=2

&{CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD}    SUITE_WTS_CFG=wts_config_LO_AP_LO_FDD_CPRI_cmwv_SANSA_FS_2S_1CC.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sansa_cpri_cmwv_LO_AP_LO_2S_1CC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_sansa_cpri_cmwv_LO_AP_LO_2S_1CC
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=FDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AHLOA    COMPONENT_CARRIER=2

&{CLOUD_5G_I_E_AP_E_SA_FS_ECPRI_CMWV_TDD_6G}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_eCpri_cmwv_E_AP_E
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sa_eCpri_cmwv_E_AP_E_6G
   ...    gnb_sm_hardware=ASOE    gnb_cp_hardware=[]    ap_sm_hardware=ASOE    ap_cp_hardware=[]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SA
   ...    l1=FS    RU_type=AWHQX    COMPONENT_CARRIER=1    SKIP_WTS_CONFIG_DOWNLOAD=True    SKIP_WTS_CONFIG_DL=True

&{CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD}    SUITE_WTS_CFG=wts_config_LO_AP_LO_TDD_eCPRI_mmwv_NSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_nsa_eCpri_mmwv_LO_AP_LO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_nsa_eCpri_mmwv_LO_AP_LO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=mmwv    deployment=NSA
   ...    l1=FS    RU_type=AWEUA    COMPONENT_CARRIER=2

&{CLOUD_5G_I_LO_AP_LO_SA+NSA_FS_ECPRI_MMWV_TDD}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_nsa_eCpri_mmwv_LO_AP_LO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=mmwv    deployment=SA_NSA
   ...    l1=FS    RU_type=AWEUA    COMPONENT_CARRIER=1        SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LO_AP_LO_SA+NSA_FS_ECPRI_MMWV_TDD_GMC}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_nsa_eCpri_mmwv_LO_AP_LO_GMC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_GMC
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=mmwv    deployment=SA_NSA
   ...    l1=FS    RU_type=AWEUA    COMPONENT_CARRIER=1        SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ_GMC}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_AZQJ_GMC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_AZQJ_GMC
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA    l1=FS    RU_type=[AHLOA, AZQJ]    COMPONENT_CARRIER=4
   ...    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LO_AP_LO_PRIVATE_SA+NSA_FS_ECPRI_MMWV_TDD_CA_HO}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_CA_HO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_CA_HO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=mmwv    deployment=SA_NSA
   ...    l1=FS    RU_type=AWEUA    COMPONENT_CARRIER=1        SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LO_AP_LO_PRIVATE_SA+NSA_FS_ECPRI_MMWV_TDD}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_2S_4CC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sa_nsa_eCpri_mmwv_LO_AP_LO_2S_4CC
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=mmwv    deployment=SA_NSA
   ...    l1=FS    RU_type=AWEUA    COMPONENT_CARRIER=1        SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_BL_AP_KL_SANSA_L1B_CPRI_CMWV_FDD-4G_I_BA_IPHY_F}    SUITE_WTS_CFG=basic.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/l1b_fdd_sansa_ASIB_ABIL_cmwv
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=l1b_fdd_sansa_ASIB_ABIL_cmwv
   ...    gnb_sm_hardware=ASIB    gnb_cp_hardware=ABIL    ap_sm_hardware=ASIK    ap_cp_hardware=ABIL    duplexing=FDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=L1b    RU_type=AHLOA    4G5G_Combo=1    variant_name=4G5G_COMBO    COMPONENT_CARRIER=1

&{CLOUD_5G_I_BOO_AP_KL_NSA_FS_CPRI_CMWV_FDD}    SUITE_WTS_CFG=wts_config_BOO_AP_KL_FDD_CPRI_cmwv_NSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_nsa_Cpri_cmwv_BOO_AP_KL
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_nsa_Cpri_cmwv_BOO_AP_KL
   ...    gnb_sm_hardware=ASIB    gnb_cp_hardware=[ABIO, ABIO]    ap_sm_hardware=ASIK    ap_cp_hardware=ABIL
   ...    duplexing=FDD    RF_type=CPRI    wavelength=cmwv    deployment=NSA
   ...    l1=FS    RU_type=AHLOA    BOAM_ET_CONF=1

&{CLOUD_5G_I_BOOO_AP_KLL_NSA_L1B_ECPRI_CMWV_TDD}    SUITE_WTS_CFG=wts_config_BOOO_AP_KLL_TDD_eCPRI_cmwv_NSA_L1B.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/l1b_tdd_nsa_eCpri_cmwv_BOOO_AP_KLL
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=l1b_tdd_nsa_eCpri_cmwv_BOOO_AP_KLL
   ...    gnb_sm_hardware=ASIB    gnb_cp_hardware=[ABIO, ABIO, ABIO]    ap_sm_hardware=ASIK    ap_cp_hardware=[ABIL, ABIL]
   ...    duplexing=TDD    RF_type=eCPRI    wavelength=cmwv    deployment=NSA
   ...    l1=L1b    RU_type=AZHL    BOAM_ET_CONF=1    COMPONENT_CARRIER=1

&{CLOUD_5G_O_E_AP_LOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_sansa_Cpri_cmwv_fdd_eCpri_cmwv_tdd_ASOE_AP_LOO_GMC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_sansa_Cpri_cmwv_fdd_eCpri_cmwv_tdd_ASOE_AP_LOO_GMC
   ...    gnb_sm_hardware=ASOE    gnb_cp_hardware=[]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO, ABIO]    duplexing=TDD
   ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AEQE    COMPONENT_CARRIER=8

&{CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD_ORAN_GMC}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_eCpri_cmwv_LO_AP_LO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_eCpri_cmwv_LO_AP_LO_ORAN
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]
   ...    COMPONENT_CARRIER=1    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LO_AP_LO_PRIVATE_SANSA_FS_ECPRI_CMWV_FDD_ORAN_DCM}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sansa_eCpri_cmwv_LO_AP_LO_ORAN_DCM
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_sansa_eCpri_cmwv_LO_AP_LO_ORAN_DCM
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]
   ...    COMPONENT_CARRIER=1    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA    l1=FS    RU_type=[AHLOA, AEQE]    COMPONENT_CARRIER=4
   ...    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_GMC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_GMC
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA    l1=FS    RU_type=[AHLOA, AEQE]    COMPONENT_CARRIER=4
   ...    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD_AQQL_16DL8UL}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_sansa_ecpri_cmwv_tdd_LO_AP_LO_AQQL_16DL8UL
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_sansa_ecpri_cmwv_tdd_LO_AP_LO_AQQL_16DL8UL
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA    l1=FS    RU_type=[AQQL]    COMPONENT_CARRIER=1
   ...    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_MP_AP_LO_PRIVATE_SANSA_FS_ECPRI72e_CMWV_TDD}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_ecpri72e_cmwv_MP_AP_LO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_ecpri72e_cmwv_MP_AP_LO
   ...    gnb_sm_hardware=ASIM    gnb_cp_hardware=[ABIP]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]
   ...    SKIP_WTS_CONFIG_DOWNLOAD=True    COMPONENT_CARRIER=1

&{CLOUD_5G_I_LO_AP_LO_PRIVATE_SANSA_FS_ECPRI_CMWV_FDD+ECPRI_CMWV_TDD_ORAN_GMC}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_sansa_ecpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_ORAN_GMC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_sansa_ecpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_ORAN_GMC
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI+eCPRI    wavelength=cmwv    deployment=SANSA    l1=FS    RU_type=[ORAN, ORAN]    COMPONENT_CARRIER=4
   ...    SKIP_WTS_CONFIG_DOWNLOAD=True    ute_ca_label=CLOUD_5G_I_LO_AP_LO
   ...    ute_ca_variant=PRIVATE_SANSA_FS_ECPRI_CMWV_FDD+ECPRI_CMWV_TDD_ORAN_GMC

&{CLOUD_5G_I_LO_AP_LO_PRIVATE_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_8DL4UL_AEQE_GMC}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA    l1=FS    RU_type=[AHLOA, AEQE]    COMPONENT_CARRIER=4
   ...    SKIP_WTS_CONFIG_DOWNLOAD=True
   ...    ute_ca_label=CLOUD_5G_I_LO_AP_LO    ute_ca_variant=PRIVATE_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_8DL4UL_AEQE

&{CLOUD_5G_I_LO_AP_LO_PRIVATE_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_8DL4UL_AEQE_APQT_REG}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_APQT_REG
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_APQT_REG
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA    l1=FS    RU_type=[AHLOA, AEQE]    COMPONENT_CARRIER=4
   ...    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LO_AP_LO_PRIVATE_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_8DL4UL_AEQE_HO}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_HO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_HO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA    l1=FS    RU_type=[AHLOA, AEQE]    COMPONENT_CARRIER=4
   ...    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LO_AP_LO_PRIVATE_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_8DL4UL_AEQE_HO_GMC}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_HO_GMC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_3S_1CC_BF_HO_GMC
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA    l1=FS    RU_type=[AHLOA, AEQE]    COMPONENT_CARRIER=4
   ...    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD}    SUITE_WTS_CFG=wts_config_BOO_AP_KLLL_TDD_FDD_CPRI_eCPRI_cmwv_SANSA_L1b_6cell.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/l1b_tdd_fdd_sansa_cpri_eCpri_cmwv_BOO_AP_KLLL
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=l1b_tdd_fdd_sansa_cpri_eCpri_cmwv_BOO_AP_KLLL
   ...    gnb_sm_hardware=ASIB    gnb_cp_hardware=[ABIO, ABIO]    ap_sm_hardware=ASIK    ap_cp_hardware=[ABIL, ABIL, ABIL]
   ...    duplexing=TDD    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=L1b    RU_type=[AHFIB, AHFIB, AEQE, AHCA]    COMPONENT_CARRIER=6

&{CLOUD_5GC_dRNIC_1vDU_O_AP_LO}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_ecpri_dRNIC_1vDU_cmwv
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_ecpri_dRNIC_1vDU_cmwv
   ...    gnb_sm_hardware=${EMPTY}    gnb_cp_hardware=[]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AEQP    COMPONENT_CARRIER=2    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5GC_dRNIC_1vDU_O_AP_LO_SANSA_FS_ECPRI_CMWV_TDD_AEQP}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_ecpri_dRNIC_1vDU_cmwv
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_ecpri_dRNIC_1vDU_cmwv
   ...    gnb_sm_hardware=${EMPTY}    gnb_cp_hardware=[]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AEQP    COMPONENT_CARRIER=2    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5GC_dRNIC_1vDU_O_AP_LO_SA_FS_CPRI_CMWV_FDD}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sa_cpri_dRNIC_1vDU_cmwv
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_sa_cpri_dRNIC_1vDU_cmwv
   ...    gnb_sm_hardware=${EMPTY}    gnb_cp_hardware=[]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=FDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SA
   ...    l1=FS    RU_type=AHCA    COMPONENT_CARRIER=2    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH_SANSA_FS_ECPRI_CMWV_TDD}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_ecpri_dRNIC_1vDU_P_AP_LO_SWFH_cmwv
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_ecpri_dRNIC_1vDU_P_AP_LO_SWFH_cmwv
   ...    gnb_sm_hardware=${EMPTY}    gnb_cp_hardware=[]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AEQP    COMPONENT_CARRIER=2    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH_SANSA_FS_ECPRI_CMWV_FDD}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sansa_ecpri_dRNIC_1vDU_P_AP_LO_SWFH_cmwv
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_sansa_ecpri_dRNIC_1vDU_P_AP_LO_SWFH_cmwv
   ...    gnb_sm_hardware=${EMPTY}    gnb_cp_hardware=[]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=FDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AHCA    COMPONENT_CARRIER=2    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD}    SUITE_WTS_CFG=wts_config_MO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_ecpri_cmwv_MO_AP_LO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_ecpri_cmwv_MO_AP_LO
   ...    gnb_sm_hardware=ASIM    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA    l1=FS    RU_type=AEQE    COMPONENT_CARRIER=2

&{CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD_GMC}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_ecpri_cmwv_MP_AP_LO_2S_1CC_CIT_GMC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_ecpri_cmwv_MP_AP_LO_2S_1CC_CIT_GMC
   ...    gnb_sm_hardware=ASIM    gnb_cp_hardware=[ABIP]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]
   ...    SKIP_WTS_CONFIG_DOWNLOAD=True    COMPONENT_CARRIER=2

&{CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI72E_CMWV_TDD}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_ecpri72e_cmwv_MP_AP_LO_CIT
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_ecpri72e_cmwv_MP_AP_LO_CIT
   ...    gnb_sm_hardware=ASIM    gnb_cp_hardware=[ABIP]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]
   ...    SKIP_WTS_CONFIG_DOWNLOAD=True    COMPONENT_CARRIER=1

&{CLOUD_5G_I_MP_AP_LO_SANSA_FS_CPRI_CMWV_FDD_GMC}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sansa_cpri_cmwv_MP_AP_LO_2S_1CC_CIT_GMC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_sansa_cpri_cmwv_MP_AP_LO_2S_1CC_CIT_GMC
   ...    gnb_sm_hardware=ASIM    gnb_cp_hardware=[ABIP]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]
   ...    SKIP_WTS_CONFIG_DOWNLOAD=True    COMPONENT_CARRIER=2

&{CLOUD_5G_I_LO_AP_LO-4G_I_LA_CUS_BA_SANSA_FS_ECPRI_CMWV_TDD}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_eCpri_cmwv_LO_AP_LO
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_eCpri_cmwv_LO_AP_LO_4G_CUS
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AEQE    4G5G_CUS=1    variant_name=4G5G_CUS    COMPONENT_CARRIER=1    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LO_AP_LO-4G_I_LA_CUS_BA_PRIVATE_SANSA_FS_ECPRI_CMWV_TDD_MULTIUE}    SUITE_WTS_CFG=basic.lua
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_eCpri_cmwv_LO_AP_LO
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_eCpri_cmwv_LO_AP_LO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AEQE    4G5G_CUS=1    variant_name=4G5G_CUS_MultiUE    COMPONENT_CARRIER=1    SKIP_WTS_CONFIG_DOWNLOAD=True
   ...    ute_ca_label=CLOUD_5G_I_LO_AP_LO-4G_I_LA_CUS_BA    ute_ca_variant=PRIVATE_SANSA_FS_ECPRI_CMWV_TDD_MULTIUE

&{CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD_GMC}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_fdd_sansa_cpri_eCpri_cmwv_BOO_AP_LOO_CIT
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_fdd_sansa_cpri_eCpri_cmwv_BOO_AP_LOO_CIT
   ...    gnb_sm_hardware=ASIB    gnb_cp_hardware=[ABIO, ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO, ABIO]
   ...    duplexing=FDD+TDD    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=[AHFIB, AHCA, AEQE]    COMPONENT_CARRIER=6    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD_QT}    SUITE_WTS_CFG=wts_config_LO_AP_LO_FDD_CPRI_cmwv_SANSA_FS_2S_1CC.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sansa_cpri_cmwv_LO_AP_LO_2S_2CC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_sansa_cpri_cmwv_LO_AP_LO_2S_2CC
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=FDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AHLOA    COMPONENT_CARRIER=4

&{CLOUD_5G_I_LOLO_AP_LOO}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_tdd_sansa_cmwv_LOLO_AP_LOO_CIT
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_tdd_sansa_cmwv_LOLO_AP_LOO_CIT
   ...    gnb_sm_hardware=[ASIL,ASIL]    gnb_cp_hardware=[ABIO,ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO, ABIO]    duplexing=FDD+TDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AHLOA    COMPONENT_CARRIER=4    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LOLO_AP_LOOO}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_tdd_sansa_cmwv_LOLO_AP_LOOO_CIT
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_tdd_sansa_cmwv_LOLO_AP_LOOO_CIT
   ...    gnb_sm_hardware=[ASIL,ASIL]    gnb_cp_hardware=[ABIO,ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO, ABIO, ABIO]    duplexing=FDD+TDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AHLOA    COMPONENT_CARRIER=4    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD_TEMP}    SUITE_WTS_CFG=basic.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sansa_cpri_cmwv_LO_AP_LO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_sansa_cpri_cmwv_LO_AP_LO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=FDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AHLOA    COMPONENT_CARRIER=2    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_O_H_AP_LOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC}    SUITE_WTS_CFG=basic.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_tdd_sansa_cmwv_h_ap_loo_GMC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_tdd_sansa_cmwv_h_ap_loo_GMC
   ...    gnb_sm_hardware=ASOH    gnb_cp_hardware=[]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO,ABIO]    duplexing=FDD+TDD
   ...    RF_type=CPRI+eCPRI   wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=[AHEH,AQQL]    COMPONENT_CARRIER=4    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD_TEMP}    SUITE_WTS_CFG=wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_eCpri_cmwv_LO_AP_LO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_eCpri_cmwv_LO_AP_LO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AEQE    COMPONENT_CARRIER=2

&{CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD_GMC}    SUITE_WTS_CFG=wts_config_LN_AP_LO_TDD_eCPRI_cmwv_SANSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_eCpri_cmwv_LN_AP_LO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_eCpri_cmwv_LN_AP_LO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIN]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AEQE    COMPONENT_CARRIER=2

&{CLOUD_5G_I_MP_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD_GMC}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_eCpri_cmwv_MP_AP_LOOO_GMC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_eCpri_cmwv_MP_AP_LOOO_GMC
   ...    gnb_sm_hardware=[ASIM]    gnb_cp_hardware=[ABIP]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO, ABIO, ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AEQE    COMPONENT_CARRIER=6    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_MP_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_fdd_sansa_eCpri_cmwv_MP_AP_LOOO_GMC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_fdd_sansa_eCpri_cmwv_MP_AP_LOOO_GMC
   ...    gnb_sm_hardware=[ASIM]    gnb_cp_hardware=[ABIP]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO, ABIO, ABIO]    duplexing=TDD+FDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AEQE    COMPONENT_CARRIER=6    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_O_E_AP_LOOO_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_sa_Cpri_cmwv_fdd_eCpri_cmwv_tdd_ASOE_AP_LOOO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_sa_Cpri_cmwv_fdd_eCpri_cmwv_tdd_ASOE_AP_LOOO
   ...    gnb_sm_hardware=[ASIL]    gnb_cp_hardware=[ABIO, ABIO, ABIO]    ap_sm_hardware=ASOE    ap_cp_hardware=[]    duplexing=TDD+FDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SA
   ...    l1=FS    RU_type=AQQJ    COMPONENT_CARRIER=6    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_fdd_sansa_dRNIC_1vDU_P_AP_LO_DC_cmwv
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_fdd_sansa_dRNIC_1vDU_P_AP_LO_DC_cmwv
   ...    gnb_sm_hardware=${EMPTY}    gnb_cp_hardware=[]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD+FDD
   ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=[AZQJ, AHCA, AHCA]    COMPONENT_CARRIER=4    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5GC_dRNIC_1vDU_P_AP_LOO_DC_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_fdd_sansa_dRNIC_1vDU_P_AP_LOO_DC_cmwv
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_fdd_sansa_dRNIC_1vDU_P_AP_LOO_DC_cmwv
   ...    gnb_sm_hardware=${EMPTY}    gnb_cp_hardware=[]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO, ABIO]    duplexing=TDD+FDD
   ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=[AZQJ, AZQJ, AHCA, AHCA]    COMPONENT_CARRIER=6    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_LOO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_sansa_cpri_cmwv_fdd_eCpri_cmwv_tdd_LOO_AP_LOOO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_sansa_cpri_cmwv_fdd_eCpri_cmwv_tdd_LOO_AP_LOOO
   ...    gnb_sm_hardware=[ASIL]    gnb_cp_hardware=[ABIO,ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO,ABIO,ABIO]    duplexing=FDD+TDD
   ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=[ AEHC, AHFIG, AHLOA]     COMPONENT_CARRIER=12    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_MP_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZHL_GMC}    SUITE_WTS_CFG=basic_setup.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_tdd_sansa_cpri_ecpri_cmwv_MP_AP_LO_AZHL_GMC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_tdd_sansa_cpri_ecpri_cmwv_MP_AP_LO_AZHL_GMC
   ...    gnb_sm_hardware=ASIM    gnb_cp_hardware=[ABIP]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]
   ...    SKIP_WTS_CONFIG_DOWNLOAD=True    COMPONENT_CARRIER=4


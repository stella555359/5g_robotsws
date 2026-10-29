*** Settings ***
Documentation    This file Contains Common Variable used across the Feature folder

*** Variables ***
${Ng_link_pattern}                      NG primary peer address.*up
${Ng_link_pattern_dual_stack}           NG link is Up
${Address_distribution_pattern}         Address Distribution is complete
${Cell_setup_complete_pattern}          Cell Setup completed
${UE_SIB_decoding_pattern}              SystemInformationBlockType1
${UE_SIB_decoding_pattern_eNB}          SystemInformationBlockType2
${UE_register_complete_pattern}         .*REGISTRATION COMPLETE.*
${Register_complete_pattern}            REGISTRATION COMPLETE
${UE_rrc_reestablish_complete_pattern}      .*UE CONTEXT RELEASE COMPLETE.*
${Rrc_reestablish_complete_pattern}        UE CONTEXT RELEASE COMPLETE
${Initial_context_setup_pattern}        Initial Context Setup Successful
${Initial_UE_message_pattern}           I\nnitial UE Message Success
${Initial_UE_success_pattern}           .*Initial UE Message Success.*
${UE_deregister_pattern}    UE Context Release Complete
${X2_link_pattern}         ENB-1: X2AP Link with GNB-2 .* is up
${LTE_attach_pattern}      UE IS ACTIVE
${UE_attach_pattern}       reported successful RA
${UE_5GDetach_pattern}     Bearer-type change from SCG-split to MCG
${UE_detach_pattern}       detached
${UE_reattach_pattern}     UE IS ACTIVE
${Trf_type}                internal
${GUI_Snapshot}            False
${S1_link_pattern_dual_stack}    S1 link is Up
${gNB_Check_Timeout}    5min
${Timeout_SA}        180
${Timeout_NSA}       300
${Total_Timeout}     5 min
${Retry_Timeout}     15 sec
${UE_Reattach_sleep}      20 sec
${UE_Reregister_sleep}    20 sec
${Pdu_session_ID}         1
${UE_ID}                  1
${UE_ID_NSA}                101
${UE_ID51}        51
${UE_ID_SANSA}    11
${nwslice_ID}     1
${gw_ID}          1
${eNB_ID}         1
${eNB_target}     2
${Target_gNB}     2
${Target_Cells}   1
${Bearer_ID}      2
${Traffic_ul_rate_SA}     3
${Traffic_ul_rate_FDD}    3
${Traffic_ul_rate_TDD}    5
${Traffic_dl_rate}        5
${Traffic_ul_rate_TDD_mmwv}    2
${AP_L1_Log}           False
${AP_L1_Log_Folder}    L3call
${single_run_info_file}     /home/ute/testline_init_results/logs/INFO_log.txt
${testline_results_file}    /home/ute/testline_update_results/logs/INFO_log.txt
${testline_results_path}    /home/ute/testline_update_results/
${test_property_file}    ${EXECDIR}/test.properties
${AMF_ID}    1
${run_script_log_set}    ${CURDIR}${/}../scripts/run_script_log_set.lua

&{GNB_BTS}     Ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}
...            Username=${tl.gnbs[0].cu.oam_http_connection_details.username}
...            Password=${tl.gnbs[0].cu.oam_http_connection_details.password}
...            Port=${tl.gnbs[0].cu.oam_http_connection_details.port}
&{AP_ASIK}     Ip=192.168.200.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=ApAsik
&{GNB_ASIK}    Ip=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
...            Username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
...            Password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
...            Connection=GnbAsik
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
&{ENB_BTS}     Ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}
...            Username=${tl.gnbs[0].cu.oam_http_connection_details.username}
...            Password=${tl.gnbs[0].cu.oam_http_connection_details.password}
...            Port=${tl.gnbs[0].cu.oam_http_connection_details.port}

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
${enb_cell_id}    11
${variant_name}    ${EMPTY}
#variables for BOAM_ET_CONF
${BOAM_ET_CONF}    0

#wts vm statistics variables
${wts_vm_process_suitesetup}   wts_vm_process_suite_setup.txt
${wts_vm_process_suiteteardown}   wts_vm_process_suite_teardown.txt
${wts_vm_system_info}   wts_vm_system_info.txt
${wts_vm_top_results}   wts_vm_top_results.txt

${Auto_NIDD_Update_Flag}   False
${gNB_P1_NIDD_Update_Flag}    False
@{Auto_NIDD_Update_Branch_Variants}    fs_tdd_sansa_cmwv    fs_fdd_sansa_cmwv
@{Auto_NIDD_Update_Trunk_Variants}    fs_fdd_sansa_ASIB_cmwv

&{CLOUD_5G_I_LO_AP_LO}    SUITE_WTS_CFG=basic_setup.cfg
  ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_eCpri_cmwv_LO_AP_LO
  ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_eCpri_cmwv_LO_AP_LO
  ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL
  ...    ap_cp_hardware=[ABIO]    duplexing=[TDD,FDD]
  ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA
  ...    l1=FS    RU_type=[AHLOA,AZQJ]
  ...    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_BOO_AP_LOO}    SUITE_WTS_CFG=basic_setup_I_BOO_AP_LOO.cfg
  ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sansa_Cpri_cmwv_BOO_AP_LOO
  ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_sansa_Cpri_cmwv_BOO_AP_LOO
  ...    gnb_sm_hardware=ASIB    gnb_cp_hardware=[ABIO, ABIO]    ap_sm_hardware=ASIL
  ...    ap_cp_hardware=[ABIO, ABIO]    duplexing=[TDD,FDD]
  ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA
  ...    l1=FS    RU_type=[AHEGG,AHEGHA,AHLOA,AZQJ]
  ...    SKIP_WTS_CONFIG_DOWNLOAD=True

&{CLOUD_5G_I_MP_AP_LO}    SUITE_WTS_CFG=basic_setup_I_MP_AP_LO.cfg
  ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sansa_Cpri_cmwv_MP_AP_LO
  ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_fdd_sansa_Cpri_cmwv_MP_AP_LO
  ...    gnb_sm_hardware=ASIM    gnb_cp_hardware=[ABIP]    ap_sm_hardware=ASIL
  ...    ap_cp_hardware=[ABIO]    duplexing=[TDD,FDD]
  ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA
  ...    l1=FS    RU_type=[AEQE,AHEGG,AHEGHA,AHLOA,AZQJ]
  ...    SKIP_WTS_CONFIG_DOWNLOAD=True

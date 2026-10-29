*** Settings ***
Documentation   This library shall contain the keywords common variables
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
${UE_deregister_pattern}    UE Context Release Complete
${X2_link_pattern}    ENB-1: X2AP Link with GNB-2 .* is up
${LTE_attach_pattern}    UE IS ACTIVE
${UE_attach_pattern}    reported successful RA
${UE_5GDetach_pattern}    Bearer-type change from SCG-split to MCG
${UE_detach_pattern}    detached
${UE_reattach_pattern}    UE IS ACTIVE
${Trf_type}    internal
${GUI_Snapshot}    False
${S1_link_pattern_dual_stack}    S1 link is Up
${reestablishment_pattern}      setup/reestablishment complete
${pucchprecoding_7103}      transformPrecoder enabled
${pucchr16_7103}        dmrs-UplinkTransformPrecodingPUCCH-r16 enabled
${pusch16_7103}     dmrs-UplinkTransformPrecoding-r16 setup
${CB010887TC3_codebook}     usage codebook
${r17_12544_1}       hyperSFN-r17
${r17_12544_2}       eDRX-AllowedIdle-r17 true
${r17_12544_3}       eDRX-AllowedInactive-r17 true
${12544_ueidle}      UE1: IS IDLE
${12544_ueactive}      ACTIVE
${12544_ueinactive}     UE1: Is INACTIVE
${12544_resumecomplete}      rrcResumeComplete
${11123_nomwithgrant}     .*NominalWithGrant.*
${11123_nominal}     .*nominal.*

${Timeout_SA}    180
${Timeout_NSA}    300
${Total_Timeout}    5 min
${Retry_Timeout}    15 sec
${UE_Reattach_sleep}    20 sec
${UE_Reregister_sleep}    20 sec
${Pdu_session_ID}    1
${UE_ID}    1
${UE_ID51}    51
${UE_ID_SANSA}    11
${nwslice_ID}    1
${gw_ID}    1
${eNB_ID}    1
${eNB_target}    2
${Target_gNB}    2
${Target_Cells}    1
${Bearer_ID}    2
${Traffic_ul_rate_SA}    3
${Traffic_ul_rate_FDD}    3
${Traffic_ul_rate_TDD}    5
${Traffic_dl_rate}    5
${Traffic_ul_rate_TDD_mmwv}    2
${AP_L1_Log}    False
${AP_L1_Log_Folder}    L3call
${single_run_info_file}    /home/ute/testline_init_results/logs/INFO_log.txt
${testline_results_file}    /home/ute/testline_update_results/logs/INFO_log.txt
${testline_results_path}    /home/ute/testline_update_results/
${test_property_file}    ${EXECDIR}/test.properties
${AMF_ID}    1
${run_script_log_set}    ${CURDIR}${/}../scripts/run_script_log_set.lua

&{GNB_BTS}     Ip=192.168.255.1    Username=Nemuadmin    Password=nemuuser    Port=443
&{AP_ASIK}     Ip=192.168.200.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=ApAsik
&{GNB_ASIK}    Ip=192.168.255.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=GnbAsik
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
&{ENB_BTS}     Ip=192.168.255.1    Username=Nemuadmin    Password=nemuuser    Port=443

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

&{CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD}    SUITE_WTS_CFG=wts_config_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_cmwv
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_cmwv
   ...    gnb_sm_hardware=ASIK    gnb_cp_hardware=[ABIL]    ap_sm_hardware=ASIK    ap_cp_hardware=[ABIL]    duplexing=TDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AEQA

&{CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD}    SUITE_WTS_CFG=wts_config_ASIK_ABIL_FDD_CPRI_cmwv_SANSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sansa_ASIK_cmwv
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_sansa_cmwv
   ...    gnb_sm_hardware=ASIK    gnb_cp_hardware=[ABIL]    ap_sm_hardware=ASIK    ap_cp_hardware=[ABIL]    duplexing=FDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AHLOA

&{CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD}    SUITE_WTS_CFG=wts_config_ASIB_ABIL_TDD_CPRI_cmwv_SANSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_ASIB_cmwv
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_ASIB_cmwv
   ...    gnb_sm_hardware=ASIB    gnb_cp_hardware=[ABIL]    ap_sm_hardware=ASIK    ap_cp_hardware=[ABIL]    duplexing=TDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AEQA

&{CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD}    SUITE_WTS_CFG=wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sansa_ASIB_ABIO_cmwv
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_sansa_ASIB_ABIO_cmwv
   ...    gnb_sm_hardware=ASIB    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIK    ap_cp_hardware=[ABIL]    duplexing=FDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AHLOA

&{CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD}    SUITE_WTS_CFG=wts_config_ASIB_ABIL_FDD_CPRI_cmwv_SANSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sansa_ASIB_cmwv
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_sansa_ASIB_cmwv
   ...    gnb_sm_hardware=ASIB    gnb_cp_hardware=[ABIL]    ap_sm_hardware=ASIK    ap_cp_hardware=[ABIL]    duplexing=FDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AHLOA

&{CLOUD_5G_I_KL_AP_KL_SANSA_L1B_CPRI_CMWV_TDD}    SUITE_WTS_CFG=wts_config_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_L1b.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/l1b_tdd_sansa_cmwv
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=l1b_tdd_sansa_cmwv
   ...    gnb_sm_hardware=ASIK    gnb_cp_hardware=[ABIL]    ap_sm_hardware=ASIK    ap_cp_hardware=[ABIL]    duplexing=TDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=L1b    RU_type=AEQA

&{CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD}    SUITE_WTS_CFG=wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/l1b_tdd_sansa_eCpri_cmwv_ASIB_ABIO
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=l1b_tdd_sansa_eCpri_cmwv_ASIB_ABIO
   ...    gnb_sm_hardware=ASIB    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIK    ap_cp_hardware=[ABIL]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=L1b    RU_type=AEQE

&{CLOUD_5G_I_LO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD}    SUITE_WTS_CFG=wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/l1b_tdd_sansa_eCpri_cmwv_ASIL_ABIO
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=l1b_tdd_sansa_eCpri_cmwv_ASIL_ABIO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIK    ap_cp_hardware=[ABIL]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=L1b    RU_type=AEQE

&{CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_CMWV_TDD}    SUITE_WTS_CFG=wts_config_LO_AP_LO_TDD_eCPRI_cmwv_NSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_nsa_eCpri_cmwv_LO_AP_LO
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_nsa_eCpri_cmwv_LO_AP_LO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=NSA
   ...    l1=FS    RU_type=AEQN

&{CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD}    SUITE_WTS_CFG=wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_eCpri_cmwv_LO_AP_LO
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_eCpri_cmwv_LO_AP_LO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=[AHFII,AHLOA,AEHC,AEQE]

&{CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD}    SUITE_WTS_CFG=wts_config_LO_AP_LO_TDD_eCPRI_mmwv_NSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_nsa_eCpri_mmwv_LO_AP_LO
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_nsa_eCpri_mmwv_LO_AP_LO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=mmwv    deployment=NSA
   ...    l1=FS    RU_type=AWEUA

&{CLOUD_5G_I_BO_AP_KL_NSA_L1B_ECPRI_MMWV_TDD}    SUITE_WTS_CFG=wts_config_ASIB_ABIO_TDD_eCPRI_mmwv_NSA_L1b.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/l1b_tdd_nsa_eCpri_mmwv_BO_AP_KL
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=l1b_tdd_nsa_eCpri_mmwv_BO_AP_KL
   ...    gnb_sm_hardware=ASIB    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIK    ap_cp_hardware=[ABIL]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=mmwv    deployment=NSA
   ...    l1=L1b    RU_type=AEUD

&{CLOUD_5G_I_BL_AP_KL_SANSA_L1B_CPRI_CMWV_FDD-4G_I_BA_IPHY_F}    SUITE_WTS_CFG=basic.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/l1b_fdd_sansa_ASIB_ABIL_cmwv
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=l1b_fdd_sansa_ASIB_ABIL_cmwv
   ...    gnb_sm_hardware=ASIB    gnb_cp_hardware=ABIL    ap_sm_hardware=ASIK    ap_cp_hardware=ABIL    duplexing=FDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=L1b    RU_type=AHLOA    4G5G_Combo=1    variant_name=4G5G_COMBO

&{CLOUD_5G_I_BOO_AP_KL_NSA_FS_CPRI_CMWV_FDD}    SUITE_WTS_CFG=wts_config_BOO_AP_KL_FDD_CPRI_cmwv_NSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_nsa_Cpri_cmwv_BOO_AP_KL
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_nsa_Cpri_cmwv_BOO_AP_KL
   ...    gnb_sm_hardware=ASIB    gnb_cp_hardware=[ABIO, ABIO]    ap_sm_hardware=ASIK    ap_cp_hardware=ABIL
   ...    duplexing=FDD    RF_type=CPRI    wavelength=cmwv    deployment=NSA
   ...    l1=FS    RU_type=AHLOA    BOAM_ET_CONF=1

&{CLOUD_5G_I_BOOO_AP_KLL_NSA_L1B_ECPRI_CMWV_TDD}    SUITE_WTS_CFG=wts_config_BOOO_AP_KLL_TDD_eCPRI_cmwv_NSA_L1B.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/l1b_tdd_nsa_eCpri_cmwv_BOOO_AP_KLL
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=l1b_tdd_nsa_eCpri_cmwv_BOOO_AP_KLL
   ...    gnb_sm_hardware=ASIB    gnb_cp_hardware=[ABIO, ABIO, ABIO]    ap_sm_hardware=ASIK    ap_cp_hardware=[ABIL, ABIL]
   ...    duplexing=TDD    RF_type=eCPRI    wavelength=cmwv    deployment=NSA
   ...    l1=L1b    RU_type=AZHL    BOAM_ET_CONF=1

&{CLOUD_5G_I_BN_AP_KL_SANSA_FS_CPRI_CMWV_FDD}    SUITE_WTS_CFG=wts_config_ASIB_ABIN_FDD_CPRI_cmwv_SANSA_FS.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sansa_cpri_cmwv_ASIB_ABIN
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_sansa_cpri_cmwv_ASIB_ABIN
   ...    gnb_sm_hardware=ASIB    gnb_cp_hardware=[ABIN]    ap_sm_hardware=ASIK    ap_cp_hardware=[ABIL]    duplexing=FDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AHLOA    component_carrier=2

&{CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD}    SUITE_WTS_CFG=wts_config_O_E_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_eCpri_cmwv_ASOE_AP_LO
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_eCpri_cmwv_ASOE_AP_LO
   ...    gnb_sm_hardware=ASOE    gnb_cp_hardware=[]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=TDD
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=[AEQE,AHFII,AEHC,AHLOA]

&{CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD}    SUITE_WTS_CFG=wts_config_LO_AP_LO_FDD_CPRI_cmwv_SANSA_FS_2S_1CC.cfg
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sansa_cpri_cmwv_LO_AP_LO_2S_1CC
   ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_sansa_cpri_cmwv_LO_AP_LO_2S_1CC
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]    duplexing=FDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=[AEQE,AHFII,AEHC,AHLOA]      COMPONENT_CARRIER=4


&{CLOUD_5G_I_LO_AP_LO}    SUITE_WTS_CFG=basic_setup.cfg
  ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_eCpri_cmwv_LO_AP_LO
  ...    DURATION=600s    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_eCpri_cmwv_LO_AP_LO
  ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL
  ...    ap_cp_hardware=[ABIO]    duplexing=[TDD,FDD]
  ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA
  ...    l1=FS    RU_type=[AHLOA,AZQJ]
  ...    SKIP_WTS_CONFIG_DOWNLOAD=True

*** Settings ***
Documentation    This file Contains Common Variable used across the Feature folder


*** Variables ***
${NG_LINK_PATTERN}                      NG primary peer address.*up
${NG_LINK_PATTERN_DUAL_STACK}           NG link is Up
${ADDRESS_DISTRIBUTION_PATTERN}         Address Distribution is complete
${CELL_SETUP_COMPLETE_PATTERN}          Cell Setup completed
${UE_SIB_DECODING_PATTERN}              SystemInformationBlockType1
${UE_SIB_DECODING_PATTERN_ENB}          SystemInformationBlockType2
${UE_REGISTER_COMPLETE_PATTERN}         .*REGISTRATION COMPLETE.*
${REGISTER_COMPLETE_PATTERN}            REGISTRATION COMPLETE
${UE_RRC_REESTABLISH_COMPLETE_PATTERN}      .*UE CONTEXT RELEASE COMPLETE.*
${RRC_REESTABLISH_COMPLETE_PATTERN}     UE CONTEXT RELEASE COMPLETE
${INITIAL_CONTEXT_SETUP_PATTERN}        Initial Context Setup Successful
${INITIAL_UE_MESSAGE_PATTERN}           I\nnitial UE Message Success
${INITIAL_UE_SUCCESS_PATTERN}           .*Initial UE Message Success.*
${UE_DEREGISTER_PATTERN}    UE Context Release Complete
${X2_LINK_PATTERN}          ENB-1: X2AP Link with GNB-2 .* is up
${LTE_ATTACH_PATTERN}       UE IS ACTIVE
${UE_ATTACH_PATTERN}        reported successful RA
${UE_5GDETACH_PATTERN}      Bearer-type change from SCG-split to MCG
${UE_DETACH_PATTERN}        detached
${UE_REATTACH_PATTERN}      UE IS ACTIVE
${TRF_TYPE}                 internal
${GUI_SNAPSHOT}             False
${S1_LINK_PATTERN_DUAL_STACK}    S1 link is Up
${GNB_CHECK_TIMEOUT}      5min
${TIMEOUT_SA}             180
${TIMEOUT_NSA}            300
${TOTAL_TIMEOUT}          5 min
${RETRY_TIMEOUT}          15 sec
${UE_REATTACH_SLEEP}      20 sec
${UE_REREGISTER_SLEEP}    20 sec
${PDU_SESSION_ID}         1
${UE_ID}                  1
${UE_ID_NSA}              101
${UE_ID51}                51
${UE_ID_SANSA}            11
${NWSLICE_ID}             1
${GW_ID}                  1
${ENB_ID}                 1
${ENB_TARGET}             2
${TARGET_GNB}             2
${TARGET_CELLS}           1
${BEARER_ID}              2
${TRAFFIC_UL_RATE_SA}     3
${TRAFFIC_UL_RATE_FDD}    3
${TRAFFIC_UL_RATE_TDD}    5
${TRAFFIC_DL_RATE}        5
${TRAFFIC_UL_RATE_TDD_MMWV}    2
${AP_L1_LOG}              False
${AP_L1_LOG_FOLDER}       L3call
${SINGLE_RUN_INFO_FILE}     /home/ute/testline_init_results/logs/INFO_log.txt
${TESTLINE_RESULTS_FILE}    /home/ute/testline_update_results/logs/INFO_log.txt
${TESTLINE_RESULTS_PATH}    /home/ute/testline_update_results/
${TEST_PROPERTY_FILE}       ${EXECDIR}/test.properties
${AMF_ID}                   1
${RUN_SCRIPT_LOG_SET}     ${CURDIR}${/}../scripts/run_script_log_set.lua

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

# 4G5G_Combo Specific Variables
${4G5G_PHYCELLID}   50
${NRSRP}            127
${EVENT}            B1_NR
${SCG_UL_DIST_PERCENT}  100
${NR_CGI_PLMN_IDENT_INFO_ID}    1
${NR_CGI_CELL_IDENT}    010011100
${NR_CGI_PLMNS_IDENT}   234:77
${4G5G_COMBO}           0
${4G5G_COMBO_GNB_IP}    192.168.255.119
${ENB_CELL_ID}          11
${VARIANT_NAME}    ${EMPTY}
# variables for BOAM_ET_CONF
${BOAM_ET_CONF}         0

# wts vm statistics variables
${WTS_VM_PROCESS_SUITESETUP}       wts_vm_process_suite_setup.txt
${WTS_VM_PROCESS_SUITETEARDOWN}    wts_vm_process_suite_teardown.txt
${WTS_VM_SYSTEM_INFO}              wts_vm_system_info.txt
${WTS_VM_TOP_RESULTS}              wts_vm_top_results.txt

${AUTO_NIDD_UPDATE_FLAG}           False
${GNB_P1_NIDD_UPDATE_FLAG}         False
@{AUTO_NIDD_UPDATE_BRANCH_VARIANTS}        fs_tdd_sansa_cmwv    fs_fdd_sansa_cmwv
@{AUTO_NIDD_UPDATE_TRUNK_VARIANTS}         fs_fdd_sansa_ASIB_cmwv

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

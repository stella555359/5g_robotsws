# *** Settings ***
# Suite Setup       Qualcomm Common Suite Setup
# #Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# #Test Teardown     Qualcomm Common Test Teardown
# Force Tags        qualcomm    owner_l3gao    SBTS00    CRT
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# Library           taf.sbts.oam.coam.admin
# Library           taf.pdu
# 
# 
# Documentation     gNB10692
# ...    c2d07079    qualcomm8450   1 2 3 4
# ...    2cdcf49b    qualcomm8450   5 6 7 8
# ...    733cc94b    qualcomm8550   9 10 11 12    bler
# ...    83fe0001    qualcomm8550   13 14 15 16   MTP8550   com10
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE1_ID}         c2d07079    #8450  1 2 3 4
# ${UE2_ID}         2cdcf49b    #8450  5 6 7 8
# ${UE3_ID}         733cc94b    #8550   9 10 11 12    bler
# ${UE4_ID}         83fe0001  #MCS B13-14-15-16   MTP8550   com10
# 
# ${UE_DL_PORT1}    5001
# ${UE_DL_PORT2}    5002
# ${UE_DL_PORT3}    5003
# ${UE_DL_PORT4}    5004
# ${UE_UL_PORT}    5002
# ${DL_LOG}    /tmp/iperf_server_on_ue_log.txt
# ${UL_LOG}    /tmp/iperf_server_on_pc_log.txt
# ${DL_SEND_DATA_CMD}    -u -t 8000 -i 1 -P 1 -f m -b 1200.00M -l 1400B -T 64
# ${UL_SEND_DATA_CMD}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 200M -t 600
# ${DL_SEND_DATA_CMD_100mhz_rank4}    -u -t 8000 -i 1 -P 1 -f m -b 1010.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_100mhz_rank3}    -u -t 8000 -i 1 -P 1 -f m -b 760.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_100mhz_rank2}    -u -t 8000 -i 1 -P 1 -f m -b 510.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_100mhz_rank1}    -u -t 8000 -i 1 -P 1 -f m -b 260.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_100mhz_rank0}    -u -t 8000 -i 1 -P 1 -f m -b 100 -l 1400B -T 64
# 
# ${EXPORT_GRID_TP}    Common Displays;Events and Debug Msgs vs. Time
# ${EXPORT_GRID}    ${None}
# &{GNBMIRRORINGCONFIGS}     L2HI_MIRRORING='false'   L2RT_MIRRORING='true'     NUMBER_OF_FILES=10    FILE_SIZE_MBYTES=300
# ${SCFC_NAME}     CB008322_case35.xml
# ${GNB_SWCONFIG_QUAL_NAME}     gnb_swconfig.txt
# ${4G_S1_local_IP}    10.108.175.74
# 
# @{Rdparameter}    0x340000:15    0x580776:1    0x5901E6:80
# 
# ${MCS_FREQUENCY}    3550
# ${ATT_FILE_PATH_0}    ${CONFIG_DIR_PATH}/qualcomm_config/8322_E1_case35_att_0db.csv
# ${ATT_FILE_PATH_1}    ${CONFIG_DIR_PATH}/qualcomm_config/8322_E1_case35_att_5db.csv
# ${ATT_FILE_PATH_2}    ${CONFIG_DIR_PATH}/qualcomm_config/8322_E1_case35_att_10db.csv
# ${ATT_FILE_PATH_3}    ${CONFIG_DIR_PATH}/qualcomm_config/8322_E1_case35_att_15db.csv
# ${ATT_FILE_PATH_4}    ${CONFIG_DIR_PATH}/qualcomm_config/8322_E1_case35_att_15db.csv
# ${PHASE_FILE_PATH_0}    ${CONFIG_DIR_PATH}/qualcomm_config/8322_E1_case35_phase_UE1_48_42.csv
# ${PHASE_FILE_PATH_1}    ${CONFIG_DIR_PATH}/qualcomm_config/8322_E1_case35_phase_UE1_25_23.csv
# ${PHASE_FILE_PATH_2}    ${CONFIG_DIR_PATH}/qualcomm_config/8322_E1_case35_phase_UE1_23_20.csv
# ${PHASE_FILE_PATH_3}    ${CONFIG_DIR_PATH}/qualcomm_config/8322_E1_case35_phase_UE1_15_12.csv
# ${PHASE_FILE_PATH_4}    ${CONFIG_DIR_PATH}/qualcomm_config/8322_E1_case35_phase_UE1_30_27.csv
# 
# ${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
# @{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
# ...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
# ${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
# ...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
# @{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID
# 
# ${FIX_RANK4}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x04
# ${FIX_RANK3}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x03
# ${FIX_RANK2}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x02
# ${FIX_RANK1}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x01
# ${dmc_file}    ${CONFIG_DIR_PATH}/qualcomm_config/NR5G_Debugging_TP.dmc
# ${UE_NUM}   4
# ${iperfpc_ip}   10.108.183.187  #10.106.164.21
# 
# *** Test Cases ***
# CNI92510_case01_EDA_4UE_DL_pairing_KPI_NR_5055b_5054a_5108d_CB008701_ideal_line
#     step1:get ready for gnb
# #    step2:Move UE1 postion to check 4UEs pairing TP and KPI 8322enable
#     step3:Move UE1 postion to check 4UEs pairing TP and KPI 8322false
# 
# 
# *** Keywords ***
# step1:get ready for gnb
#     Log To Console   \n-------------step1:get ready for gnb---------------
# #    Modify Qualcomm gNB Swconfig
#     detach all UEs
# #    Qualcomm prepare gnb onair
# #    Prepare 4UE for SA env
#     MCS setting
# #    Start QXDM trace      ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}  #for debug
# ##	Start capture gnb and ap syslog in 'after_onair' file
# 
# 
# step2:Move UE1 postion to check 4UEs pairing TP and KPI 8322enable
#     Log To Console   \n-------------step2:Move UE1 postion to check 4UEs pairing TP and KPI 8322enable---------------
# #    online change parameters    delta_8322    actDlSrsSubbandBm=true    bfSubbandSize=8 PRBs   #iniParameter setting
#     ${UE_TP_list}   create list
#     attach 4 UES with full buffer for stable    100mhz
#     Start capture only gnb syslog in 'step2' file
#     Start QXDM trace      ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
#     : FOR    ${num}    IN RANGE    0    5
# #    \    Log To Console   \n-------------step2:set att ${num}---------------
#     \    Log To Console   \n-------------step2:set phase ${PHASE_FILE_PATH_${num}}---------------
#     \    ${KPI_list}   create list
# #    \    Set Mcs3 Channel Attenuation continus    ${ATT_FILE_PATH_${num}}
#     \    Set Mcs3 Channel Phase continus    ${PHASE_FILE_PATH_${num}}
#     \    Wait '15s' for stable
#     \    Check 4UE pairing and TP_bler based TTi     TP=480    cellBW=100mhz
#     ...    ttifile_tag=8322true_att_${num}db    UE1_rank=2    UE2_rank=2    UE3_rank=2    UE4_rank=2    8322_tag=true
#     \    ${PM_counter_file}   Get PM counter file
#     \    ${NR_5055b_MUtrue}    ${NR_5054a_MUtrue}    ${NR_5108d_MUtrue}    ${NR_5109d_MUtrue}    KPI 5055b_5054a_5108d counter check
#     ...   ${PM_counter_file}    tag=phase_change_8322_true_${num}    #tag
#     \    append to list    ${KPI_list}    ${NR_5055b_MUtrue}    ${NR_5054a_MUtrue}    ${NR_5108d_MUtrue}    ${NR_5109d_MUtrue}
#     \    set suite variable   ${KPI_lists_8322_true_${num}}    ${KPI_list}
#     Log To Console   \n-------------done-----step2:Move UE1 postion to check 4UEs pairing TP and KPI 8322enable---------------
#     Log To Console    8322_true_KPI_lists_0 ${KPI_lists_8322_true_0}
#     Log To Console    8322_true_KPI_lists_1 ${KPI_lists_8322_true_1}
#     Log To Console    8322_true_KPI_lists_2 ${KPI_lists_8322_true_2}
#     Log To Console    8322_true_KPI_lists_3 ${KPI_lists_8322_true_3}
#     Log To Console    8322_true_KPI_lists_4 ${KPI_lists_8322_true_4}
# #    Set Mcs3 Channel Attenuation continus    ${ATT_FILE_PATH_0}   #reset then do next attach
#     Set Mcs3 Channel Phase continus    ${PHASE_FILE_PATH_0}   #reset then do next attach
#     Stop capture only gnb syslog in 'step2' file
#     detach all UEs
# #    Stop capture only gnb syslog in 'step2' file
# #    Stop QXDM trace    ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
# #    MCS Teardown
# 
# step3:Move UE1 postion to check 4UEs pairing TP and KPI 8322false
#     Log To Console   \n-------------step3:Move UE1 postion to check 4UEs pairing TP and KPI 8322false---------------
# #    online change parameters    delta_8322    actDlSrsSubbandBm=false    bfSubbandSize=8 PRBs
#     ${UE_TP_list}   create list
#     attach 4 UES with full buffer for stable    100mhz
#     Start capture only gnb syslog in 'step3' file
# #    Start QXDM trace      ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
#     : FOR    ${num}    IN RANGE    0    5
# #    \    Log To Console   \n-------------step3:set att ${num}---------------
#     \    Log To Console   \n-------------step3:set phase ${PHASE_FILE_PATH_${num}}---------------
#     \    ${KPI_list}   create list
# #    \    Set Mcs3 Channel Attenuation continus    ${ATT_FILE_PATH_${num}}
#     \    Set Mcs3 Channel Phase continus    ${PHASE_FILE_PATH_${num}}
#     \    Wait '15s' for stable
#     \    Check 4UE pairing and TP_bler based TTi     TP=480    cellBW=100mhz
#     ...    ttifile_tag=8322false_att_${num}db    UE1_rank=2    UE2_rank=2    UE3_rank=2    UE4_rank=2    8322_tag=false
#     \    ${PM_counter_file}   Get PM counter file
#     \    ${NR_5055b_MUtrue}    ${NR_5054a_MUtrue}    ${NR_5108d_MUtrue}    ${NR_5109d_MUtrue}    KPI 5055b_5054a_5108d counter check
#     ...   ${PM_counter_file}    tag=phase_change_8322_false_${num}   #tag
#     \    append to list    ${KPI_list}    ${NR_5055b_MUtrue}    ${NR_5054a_MUtrue}    ${NR_5108d_MUtrue}    ${NR_5109d_MUtrue}
#     \    set suite variable   ${KPI_lists_8322_false_${num}}    ${KPI_list}
#     Log To Console   \n---------done-----step3:Move UE1 postion to check 4UEs pairing TP and KPI 8322false-------------
#     Log To Console    8322_false_KPI_lists_0 ${KPI_lists_8322_false_0}
#     Log To Console    8322_false_KPI_lists_1 ${KPI_lists_8322_false_1}
#     Log To Console    8322_false_KPI_lists_2 ${KPI_lists_8322_false_2}
#     Log To Console    8322_false_KPI_lists_3 ${KPI_lists_8322_false_3}
#     Log To Console    8322_false_KPI_lists_4 ${KPI_lists_8322_false_4}
#     Stop capture only gnb syslog in 'step3' file
#     detach all UEs
# #    Set Mcs3 Channel Attenuation continus    ${ATT_FILE_PATH_0}   #reset then do next attach
#     Set Mcs3 Channel Phase continus    ${PHASE_FILE_PATH_0}   #reset then do next attach
# #    Stop capture only gnb syslog in 'step3' file
# #    Stop QXDM trace    ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
# #    MCS Teardown
# 
# step4:Move UEs to check 4UEs pairing TP and KPI 8322enable
#     Log To Console   \n-------------step4:Move UEs to check 4UEs pairing TP and KPI 8322enable---------------
#     online change parameters    delta_8322    actDlSrsSubbandBm=true    bfSubbandSize=8 PRBs
#     ${UE_TP_list}   create list
#     attach 4 UES with full buffer for stable    100mhz
#     Start capture only gnb syslog in 'step4' file
# #    Start QXDM trace      ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
#     : FOR    ${num}    IN RANGE    0    20    5
#     \    Log To Console   \n-------------step3:set att ${num}DB---------------
#     \    ${KPI_list}   create list
#     \    Set Mcs3 Channel Attenuation continus    ${ATT_FILE_PATH_${num}db}
#     \    Wait '15s' for stable
#     \    Check 4UE pairing and TP_bler based TTi     TP=480    cellBW=100mhz
#     ...    ttifile_tag=mu_true_4rank4_att_${num}db    UE1_rank=2    UE2_rank=2    UE3_rank=2    UE4_rank=2    8322_tag=true
#     \    ${PM_counter_file}   Get PM counter file
#     \    ${NR_5055b_MUtrue}    ${NR_5054a_MUtrue}    ${NR_5108d_MUtrue}    ${NR_5109d_MUtrue}    KPI 5055b_5054a_5108d counter check
#     ...   ${PM_counter_file}    tag=8322_false_${num}
#     \    append to list    ${KPI_list}    ${NR_5055b_MUtrue}    ${NR_5054a_MUtrue}    ${NR_5108d_MUtrue}    ${NR_5109d_MUtrue}
#     \    set suite variable   ${KPI_lists_${num}}    ${KPI_list}
#     Log To Console    8322_false_KPI_lists_0 ${KPI_lists_0}
#     Log To Console    8322_false_KPI_lists_5 ${KPI_lists_5}
#     Log To Console    8322_false_KPI_lists_10 ${KPI_lists_10}
#     Log To Console    8322_false_KPI_lists_15 ${KPI_lists_15}
#     detach all UEs
#     Set Mcs3 Channel Attenuation continus    ${ATT_FILE_PATH_0db}   #reset then do next attach
#     Stop capture only gnb syslog in 'step4' file
# #    Stop QXDM trace    ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
# #    MCS Teardown
# 
# 
# 
# Online change parameters
#     [Arguments]    ${delta_8322}    ${actDlSrsSubbandBm}    ${bfSubbandSize}
#     ${template}    OperatingSystem.Get File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_8322}.json
#     log to console    ${template}
#     ${message} =    Replace Variables    ${template}
#     Create File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_8322}_modified.json    ${message}
#     Online recommissioning with delta json file
#     ...   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_8322}_modified.json
#     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
# 
# 
# MCS setting
#     Set Mcs3 Channel Phase And Attenuation    ${ATT_FILE_PATH_0}   ${PHASE_FILE_PATH_0}
# 
# Set Mcs3 Channel Phase And Attenuation
#     [Arguments]    ${att_csv}    ${phase_csv}    ${frequency}=3550_1_ALL
#     Obtain MCS Info
#     MCS Setup    host_ip=${host_ip}    device_ip=${device_ip}    db_path=${db_path}    username=${UE_PC_USER}    password=${UE_PC_PASS}
#     ...    mcs_port=28888
#     ${version}    MCS Query Idn
#     log    ${version}
#     ${file_name}    Mcs Get Calibration File Name
#     log    ${file_name}
#     run keyword and continue on failure    MCS Apply Channel For Resource    1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16
#     run keyword and continue on failure    MCS Set Frequency    frequency=${frequency}
#     run keyword and continue on failure    Mcs Set Attenuation    att=${att_csv}
#     run keyword and continue on failure    Mcs Set Phase    phase=${phase_csv}
#     ${all_channel_info}=    MCS Query Channel Phase And Attenuation    channel=ALL
#     Log    ${all_channel_info}
# #    MCS Teardown
# 
# Set Mcs3 Channel Attenuation continus
#     [Arguments]    ${att_csv}
#     run keyword and continue on failure    Mcs Set Attenuation    att=${att_csv}
#     ${all_channel_info}=    MCS Query Channel Phase And Attenuation    channel=ALL
#     Log    ${all_channel_info}
# 
# Set Mcs3 Channel Phase continus
#     [Arguments]    ${phase_csv}
#     run keyword and continue on failure    Mcs Set Phase    phase=${phase_csv}
#     ${all_channel_info}=    MCS Query Channel Phase And Attenuation    channel=ALL
#     Log    ${all_channel_info}
# 
# Add RD
# 	Add GNB swconfig    0x340000:15    #counter
#     Add GNB swconfig    0x580776:1   #rdDlMuSbBfMode
#     Add GNB swconfig    0x5901E6:80    #rdMinSrsUePeriodicity  default=80 slot(0x50)
# #    Add GNB swconfig    0x580434:0     	#pdcch use best beam
# #    Add GNB swconfig    0x5805ae:1       #rdEnableSrsSwitchScheduler
# #    Add GNB swconfig    0x580763:1  	#rdWbSrsRankTresh
# #    Add GNB swconfig    0x800070:1  	#rdRtBwvDowngradeMethod
# #    Add GNB swconfig    0x58076C:0x1  	#rdWbSrsPrbTresh
# #    Add GNB swconfig    0x5805B5:0x28  	#rdNumSrsCheck
# #    Add GNB swconfig    0x5805ba:0x21   #The minimum PRB of PDSCH to allow the transmission with subband beams.
# #    Add GNB swconfig    0x5805bb:0x2   #The maximum distance between startPRB of each PDSCH PRB and mid-PRB
# #    Add GNB swconfig    0x580785:0x64   #The maximum distance between startPRB of each PDSCH PRB and mid-PRB
# 
# Modify Qualcomm gNB Swconfig
# 	Add Qualcomm GNB swconfig    @{Rdparameter}
# 
# Add Qualcomm GNB swconfig
#     [Arguments]    @{Rdparameter}
#     Backup Swconfig    ${CURDIR}    gnb_swconfig.txt
#     setup_txt    src_file=${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_QUAL_NAME}
#     ...     save_path=${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_QUAL_NAME}
#     :FOR    ${parameter}    IN    @{Rdparameter}
#     \    ${key}    ${value}    Split String    ${parameter}    :
#     \    run keyword and ignore error    delete txt node    ${key}
#     \    add txt node    ${parameter}
#     teardown txt
# 
# Get PM counter file
#     Wait '60s' for stable
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     log to console    ${remaining_time}
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
#     log to console    ${PM_counter_file}
#     [Return]    ${PM_counter_file}
# 
# Ideal line PRB_mulayer counter check
#     [Arguments]    ${16layer_full_pair_PRB_counter}    ${PM_counter_file}
#     ${8701_pair_counter}   create list
#     : FOR    ${num}    IN RANGE    1    30
#     \    ${counter_1}   evaluate   4000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C3${counter_1}    cell_id=1
#     \    append to list    ${8701_pair_counter}    ${result}
#     log to console    8701_pair_counter all is ${8701_pair_counter}
#     log to console    PRB_DL_SU_MIMO_layer_1_2_3_4 are ${8701_pair_counter[0:4]}
#     log to console    PRB_DL_MU_MIMO_layer2_3_4_5_6_7_8 are ${8701_pair_counter[4:11]}
#     log to console    PRB_DL_MU_MIMO_paired_UE_0_2_3_4_5_7_8 are ${8701_pair_counter[11:15]} ${8701_pair_counter[23:27]}
#     log to console    PRB_DL_MU_MIMO_layer_9_10_11_12_13_14_15_16 are ${8701_pair_counter[15:23]}
#     log to console    TOT_MU_MIMO_PAIR_UE and TOT_MU_MIMO_ELIG_UE are ${8701_pair_counter[27]} ${8701_pair_counter[28]}
# 
#     ${PRB_DL_SU_MIMO_layer_total}    evaluate    sum(${8701_pair_counter[0:4]})
#     ${PRB_DL_MU_MIMO_layer_total}    evaluate    sum(${8701_pair_counter[4:11]})+sum(${8701_pair_counter[15:23]})
#     ${PRB_DL_MU_paired_UE_total}    evaluate    sum(${8701_pair_counter[12:15]})+sum(${8701_pair_counter[23:27]})
# #    ${pair_to_muelig}    evaluate    ${8701_pair_counter[27]}/${8701_pair_counter[28]}
#     run keyword and continue on failure   should be true   ${PRB_DL_MU_MIMO_layer_total}==${PRB_DL_MU_paired_UE_total}
#     run keyword and continue on failure   should be true   ${PRB_DL_SU_MIMO_layer_total}==${8701_pair_counter[11]}
#     run keyword and continue on failure   should be true   ${8701_pair_counter[22]}>${16layer_full_pair_PRB_counter}
#     run keyword and continue on failure   should be true   ${PRB_DL_MU_MIMO_layer_total}==${PRB_DL_MU_paired_UE_total}
# #    run keyword and continue on failure   should be true   ${pair_to_muelig}>0.98
#     log to console    PRB_DL_SU_MIMO_layer_total is ${PRB_DL_SU_MIMO_layer_total}
#     log to console    PRB_DL_MU_MIMO_layer_total is ${PRB_DL_MU_MIMO_layer_total}
#     log to console    PRB_DL_MU_paired_UE_total is ${PRB_DL_MU_paired_UE_total}
#     log to console    16layer_full_pair_PRB_counter is ${8701_pair_counter[22]} target is ${16layer_full_pair_PRB_counter}
#     set global variable    ${8701_pair_counter}
# 
# KPI 5055b_5054a_5108d counter check
#     [Arguments]    ${PM_counter_file}    ${tag}
#     ${PDSCH_UNSUCC_64TBL_MCS}    create list
#     ${PDSCH_SUCC_ANY_64TBL_MCS}    create list
#     ${PDSCH_UNSUCC_256TBL_MCS}    create list
#     ${PDSCH_SUCC_ANY_256TBL_MCS}    create list
#     : FOR    ${num}    IN RANGE    0    32
#     \    ${counter_2}   evaluate   2000+${num}
#     \    ${counter_3}   evaluate   3000+${num}
#     \    ${counter_6}   evaluate   6000+${num}
#     \    ${counter_7}   evaluate   7000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_2}    cell_id=1
#     \    append to list    ${PDSCH_SUCC_ANY_64TBL_MCS}    ${result}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_3}    cell_id=1
#     \    append to list    ${PDSCH_UNSUCC_64TBL_MCS}    ${result}
# 
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_6}    cell_id=1
#     \    append to list    ${PDSCH_SUCC_ANY_256TBL_MCS}    ${result}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_7}    cell_id=1
#     \    append to list    ${PDSCH_UNSUCC_256TBL_MCS}    ${result}
# 
# #    log to console    PDSCH_SUCC_ANY_64TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_64TBL_MCS}
# #    log to console    PDSCH_UNSUCC_64TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_64TBL_MCS}
# #    log to console    PDSCH_SUCC_ANY_256TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_256TBL_MCS}
# #    log to console    PDSCH_UNSUCC_256TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_256TBL_MCS}
#     ${unsucc}    evaluate    sum(${PDSCH_UNSUCC_64TBL_MCS})+sum(${PDSCH_UNSUCC_64TBL_MCS})
#     ${SUCC_ANY}    evaluate    sum(${PDSCH_SUCC_ANY_64TBL_MCS})+sum(${PDSCH_SUCC_ANY_256TBL_MCS})
#     ${NR_5055b}    evaluate    ${unsucc}/(${SUCC_ANY}+${unsucc})
#     run keyword and continue on failure   should be true   ${NR_5055b}<0.001
#     log to console    \n---------------KPI NR_5055b residual bler is ${NR_5055b}
# 
#     ${PDSCH_INITX_64TBL_MCS}    create list
#     ${PDSCH_SUCC_INI_64TBL_MCS}    create list
#     ${PDSCH_INI_256TBL_MCS}    create list
#     ${PDSCH_SUCC_INI_256TBL_MCS}    create list
# 
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${counter_0}   evaluate   0+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0000${counter_0}    cell_id=1
#     \    append to list    ${PDSCH_INITX_64TBL_MCS}    ${result}
#     : FOR    ${num}    IN RANGE    10    29
#     \    ${counter_0}   evaluate   0+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C000${counter_0}    cell_id=1
#     \    append to list    ${PDSCH_INITX_64TBL_MCS}    ${result}
#     : FOR    ${num}    IN RANGE    0    29
#     \    ${counter_1}   evaluate   1000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_1}    cell_id=1
#     \    append to list    ${PDSCH_SUCC_INI_64TBL_MCS}    ${result}
#     : FOR    ${num}    IN RANGE    0    28   #256qam mcs max 28
#     \    ${counter_4}   evaluate   4000+${num}
#     \    ${counter_5}   evaluate   5000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_4}    cell_id=1
#     \    append to list    ${PDSCH_INI_256TBL_MCS}    ${result}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_5}    cell_id=1
#     \    append to list    ${PDSCH_SUCC_INI_256TBL_MCS}    ${result}
# 
# #    log to console    PDSCH_INITX_64TBL_MCS 0_to_28 is ${PDSCH_INITX_64TBL_MCS}
# #    log to console    PDSCH_SUCC_INI_64TBL_MCS 0_to_28 is ${PDSCH_SUCC_INI_64TBL_MCS}
# #    log to console    PDSCH_INI_256TBL_MCS 0_to_27 is ${PDSCH_INI_256TBL_MCS}
# #    log to console    PDSCH_SUCC_INI_256TBL_MCS 0_to_27 is ${PDSCH_SUCC_INI_256TBL_MCS}
# 
#     ${ini_tx}    evaluate    sum(${PDSCH_INITX_64TBL_MCS})+sum(${PDSCH_INI_256TBL_MCS})
#     ${ini_SUCC}    evaluate    sum(${PDSCH_SUCC_INI_64TBL_MCS})+sum(${PDSCH_SUCC_INI_256TBL_MCS})
#     ${NR_5054a}    evaluate    (${ini_tx}-${ini_SUCC})/${ini_tx}
# #    run keyword and continue on failure   should be true   ${NR_5054a}<0.001
#     log to console    \n---------------KPI NR_5054a iniBler is ${NR_5054a}
# 
# 
#     ${PDSCH_INIRE_VOL_64TBL_MCS}    create list
#     ${PDSCH_INIRE_VOL_256TBL_MCS}    create list
#     : FOR    ${num}    IN RANGE    0    32
#     \    ${counter_22}   evaluate   2000+${num}
#     \    ${counter_6}   evaluate   6000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0${counter_22}    cell_id=1
#     \    append to list    ${PDSCH_INIRE_VOL_64TBL_MCS}    ${result}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0${counter_6}    cell_id=1
#     \    append to list    ${PDSCH_INIRE_VOL_256TBL_MCS}    ${result}
#     log to console    PDSCH_INIRE_VOL_64TBL_MCS 0_to_31 is ${PDSCH_INIRE_VOL_64TBL_MCS}
#     log to console    PDSCH_INIRE_VOL_256TBL_MCS 0_to_31 is ${PDSCH_INIRE_VOL_256TBL_MCS}
# 
#     ${rt1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C03005    cell_id=1
#     ${rt2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C10001    cell_id=1
#     ${rt3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00008    cell_id=1
#     ${rt4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00016    cell_id=1
#     ${rt5}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00018    cell_id=1
#     ${NR_5108d_numerato}    evaluate    8*(sum(${PDSCH_INIRE_VOL_64TBL_MCS})+sum(${PDSCH_INIRE_VOL_256TBL_MCS}))
#     ${NR_5108d}    evaluate    ${NR_5108d_numerato}/(${rt1}*180*(${rt2}/(${rt3}+${rt4}+${rt5})))
#     log to console    \n---------------KPI NR_5108d SE_downlink is ${NR_5108d}
# 
#     ${L_M55304C0400X}   create list
#     ${M55304C0400X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0400${num}    cell_id=1
#     \    ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
#     \    append to list    ${L_M55304C0400X}    ${result}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C040${num}    cell_id=1
#     \    ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
#     \    append to list    ${L_M55304C0400X}    ${result}
# 
#     ${L_M55304C0800X}   create list
#     ${M55304C0800X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0800${num}    cell_id=1
#     \    ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
#     \    append to list    ${L_M55304C0800X}    ${result}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C080${num}    cell_id=1
#     \    ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
#     \    append to list    ${L_M55304C0800X}    ${result}
# 
#     ${L_M55304C1000X}   create list
#     ${M55304C1000X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C1000${num}    cell_id=1
#     \    ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
#     \    append to list    ${L_M55304C1000X}    ${result}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C100${num}    cell_id=1
#     \    ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
#     \    append to list    ${L_M55304C1000X}    ${result}
# 
#     ${top_counter}    Evaluate    (${M55304C0400X}+${M55304C0800X}+${M55304C1000X})*8
#     ${L_M55308}   create list
#     ${M55308C03006}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C03006    cell_id=1
#     ${M55308C10002}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C10002    cell_id=1
#     ${M55308C00009}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00009    cell_id=1
#     ${M55308C00011}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00011    cell_id=1
#     append to list    ${L_M55308}    ${M55308C03006}
#     append to list    ${L_M55308}    ${M55308C10002}
#     append to list    ${L_M55308}    ${M55308C00009}
#     append to list    ${L_M55308}    ${M55308C00011}
#     ${bottom_counter}    Evaluate    ${M55308C03006}*180*(float(${M55308C10002})/(${M55308C00009}+${M55308C00011}))
#     ${NR_5109d}    Evaluate    float(${top_counter}/${bottom_counter})
# #    log to console    64qam:${L_M55304C0400X}
# #    log to console    dft_s_ofdm:${L_M55304C0800X}
# #    log to console    256qam:${L_M55304C1000X}
# #    log to console    PUSCH_OFDM_SYMBOLS_TIME:${L_M55308}
#     log to console    \n-------------set ${tag}--------------------------------------
#     log to console    KPI NR_5109d SE_downlink=${NR_5109d}
#     log to console    KPI NR_5108d SE_downlink is ${NR_5108d}
#     log to console    KPI NR_5055b residual bler is ${NR_5055b}
#     log to console    KPI NR_5054a iniBler is ${NR_5054a}
#     log to console    ---------------set ${tag}--------------------------------------
#     [Return]    ${NR_5055b}    ${NR_5054a}    ${NR_5108d}    ${NR_5109d}
# 
# 
# attach 4 UES with full buffer for stable
#     [Arguments]    ${tag}
#     Start capture only gnb syslog in 'rrc_${tag}' file
# #    Attach qualcomm ue and make call stable    ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${tag}
#     Attach 2SA2NSA UEs anc check RRC logs   ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
#     Start UE full buffer with UErank'2''2''2''2''${tag}'
#     Wait '10s' for stable
#     Stop capture only gnb syslog in 'rrc_${tag}' file
# 
# Check 4UE pairing and TP_bler based TTi
#     [Arguments]    ${TP}    ${cellBW}    ${ttifile_tag}    ${UE1_rank}    ${UE2_rank}    ${UE3_rank}    ${UE4_rank}    ${8322_tag}
#     log to console  check 4UE pairing and TP_bler_${ttifile_tag}
# #    Start capture only gnb syslog in '${ttifile_tag}_4UE' file
#     Stop UE data
#     Start UE full buffer with UErank'${UE1_rank}''${UE2_rank}''${UE3_rank}''${UE4_rank}''${cellBW}'
#     Wait '10s' for stable
# #    run keyword and continue on failure    Start collect bip log
# #    run keyword and continue on failure    Wait for '0.5s' to stop bip log with name'bip_MU${layer}layer_4UE'
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'${ttifile_tag}'
#     run keyword and continue on failure     Check TP and bler with rank by ttitrace    ${TP}    1    ${ttifile_tag}
#     ...    tti_case15_pair_power   ${UE1_rank}   ${UE2_rank}   ${UE3_rank}   ${UE4_rank}    ${8322_tag}
# #    Stop capture only gnb syslog in '${ttifile_tag}_4UE' file
# 
# Attach qualcomm ue and make call stable
#     [Arguments]    ${UE1_ID}    ${UE2_ID}   ${UE3_ID}    ${UE4_ID}    ${cell_bandwith}
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
#     \     Qualcomm detach ue    ${UE${num}_ID}
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
#     \     Qualcomm attach ue hardly    ${UE${num}_ID}
#     Start UE full buffer with UErank'2''2''2''2''${cell_bandwith}'
#     Wait '5s' for stable
#     Stop UE data
# 
# attach UE '${attach_time}' times
#     : for    ${num_x}   IN RANGE  1   ${attach_time}+1
#     \     Start capture only gnb syslog in 'attach_multi_time_${num_x}' file
#     \     Attach qualcomm ue and make call stable     ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}
#     \     Stop capture only gnb syslog in 'attach_multi_time_${num_x}' file
# 
# detach all UEs
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
#     \     Qualcomm detach ue    ${UE${num}_ID}
# 
# Start UE full buffer with UErank'${UE1_rank}''${UE2_rank}''${UE3_rank}''${UE4_rank}''${cell_bandwith}'
#     csn.connect to  ${iperfpc_ip}    username=ute  password=%EjvHVvvkQD6  alias=serve
#     ${ret}   csn.execute  ps -ef | grep iperf   connection=serve
#     ${ret}   csn.send command   pkill -9 iperf    connection=serve
#     ${ret}   csn.execute  ps -ef | grep iperf   connection=serve
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
#     \     run keyword if  ${UE${num}_rank}!=0    Qualcomm Start DL Data    ${UE${num}_ID}    ${UE_DL_PORT${num}}
#           ...   ${DL_LOG}    ${DL_SEND_DATA_CMD_${cell_bandwith}_rank${UE${num}_rank}}
#     \     Qualcomm Start UL Data    ${UE${num}_ID}    ${UE_UL_PORT}   ${UL_LOG}    ${UL_SEND_DATA_CMD}
#     \     log to console     iperf data to UE${num}
# 
# Stop UE data
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
#     \     Qualcomm Stop DL Data    ${UE${num}_ID}    ${UE_DL_PORT${num}}
#     \     Qualcomm Stop UL Data    ${UE${num}_ID}    ${UE_UL_PORT}
#     \     log to console     iperf stop data to UE${num}
# 
# Check TP and bler with rank by ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}   ${UE1_rank}   ${UE2_rank}   ${UE3_rank}   ${UE4_rank}
#     ...    ${8322_tag}
#     ${UE_TP_list}   create list
#     ${UE_ackrate_list}   create list
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}_tti/tti_dl.csv
#     ...        ${test_log_directory()}/All/${tti_file}_tti/tti_dl_new.csv   ${time_avg}    ratio=0    filter=dlFdSchedData.ackNack\=ACK
# #    run keyword if  '${8322_tag}'=='true'     split_8322_tti    ${test_log_directory()}/All/${tti_file}_tti/tti_dl.csv
#     check_cdm_group_and_dmrs_port_by_antenna_port_value     ${test_log_directory()}/All/${tti_file}_tti/tti_dl.csv
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR   ${num}   IN RANGE   1   ${UE_NUM}+1     #check tp based on given crnti
#     \    ${result1}  evaluate   ${a[${rnti_list_suite[${num}-1]}]}/${time_avg}/1024/1000
#     \    ${target_tp}  evaluate   ${throughput}
# #    \    should be true  ${result1}>${target_tp}
#     \    append to list   ${UE_TP_list}   ${result1}
#     \    log to console   UE rnti ${rnti_list_suite[${num}-1]} TP is ${result1} target is ${target_tp}
#     : FOR    ${T_rnti}   IN    @{rnti_list_suite}     #check bler
#     \    ${ackNack}    read_csv_columns    ${test_log_directory()}/All/${tti_file}_tti/tti_dl.csv
#     ...   dlFdSchedData.ackNack    filter=rnti=${T_rnti}
#     \    ${ret1}    evaluate  ${ackNack}.count('ACK')/len(${ackNack})
#     \    run keyword and continue on failure    should be true  ${ret1}>0.89
#     \    append to list   ${UE_ackrate_list}   ${ret1}
#     \    log to console   UE rnti ${T_rnti} ACK rate is ${ret1} target is 0.98
#     run keyword if    '${tti_file}'=='mu_true_4UE'    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini
#     ...   log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}_tti/
#     log to console    UE_TP_list is ${UE_TP_list}
#     log to console    UE_ackrate_list is ${UE_ackrate_list}
#     check_cdm_group_and_dmrs_port_by_antenna_port_value     ${test_log_directory()}/All/${tti_file}_tti/tti_dl.csv
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}_tti/tti
# 
# 
# Start QXDM trace
#     [Arguments]    ${UE1_ID}    ${UE2_ID}   ${UE3_ID}    ${UE4_ID}     ${dmc}
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
#     \    Qualcomm Start Qxdm Trace    ${UE${num}_ID}    dmc_file=${dmc}
#     \    log to console    Qualcomm Start Qxdm Trace for ${UE${num}_ID}
# 
# Stop QXDM trace
#     [Arguments]    ${UE1_ID}    ${UE2_ID}   ${UE3_ID}    ${UE4_ID}     ${dmc}
#     : for    ${num}   IN RANGE  1   ${UE_NUM}
#     \     ${ue_absolutely_path}    Qualcomm Stop Qxdm Trace    ${UE${num}_ID}    ${log_path}    quit_app=false
#     \     sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${ue_absolutely_path}.hdf    ${test_log_directory()}/
#     ${ue_absolutely_path}    Qualcomm Stop Qxdm Trace    ${UE4_ID}    ${log_path}
#     sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${ue_absolutely_path}.hdf    ${test_log_directory()}/
# 
# Download qualcomm log
#     [Arguments]    ${UE_trace_file}    ${export_grid}    ${name}    ${txt_file_path}=${TXT_DEF_PATH}
#     ${qc_log}    qualcomm export to txt with qcat    ${UE_trace_file}    ${txt_file_path}    filter=${export_grid}
#     sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${UE_trace_file}    ${test_log_directory()}/
#     sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${qc_log}
#     ...              ${test_log_directory()}/${name}
# 
# Prepare 4UE for SA env
# #    lock one 4G cell    289    ${4G_S1_local_IP}
#     Set ue to SA simple    ${UE1_ID}
#     Wait '5s' for stabible
#     Set ue to SA simple   ${UE2_ID}
#     Wait '5s' for stabible
#     Set ue to SA simple   ${UE3_ID}
#     Wait '5s' for stabible
#     Set ue to SA simple   ${UE4_ID}
#     Wait '35s' for stabible    #wait for UE4 come back
# 
# Set ue to SA simple
#     [Arguments]    ${ue_id}
#     ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
#     Wait '10s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    80000    64
#     Wait '5s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    74213    0
#     Qualcomm Write Nvitem    ${ue_id}    74087    1099511627776,8256
#     Wait '10s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    reboot
# 
# Prepare 4UE for NSA env
# #    unlock one 4G cell    289    ${4G_S1_local_IP}
#     Set ue to NSA simple    ${UE1_ID}
#     Wait '5s' for stabible
#     Set ue to NSA simple   ${UE2_ID}
#     Wait '5s' for stabible
#     Set ue to NSA simple   ${UE3_ID}
#     Wait '5s' for stabible
#     Set ue to NSA simple   ${UE4_ID}
#     Wait '35s' for stabible    #wait for UE4 come back
# 
# Set ue to NSA simple
#     [Arguments]    ${ue_id}
#     ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
#     Wait '10s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    80000    80
#     Wait '5s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    74213    1099511627776,8256   #n78
#     Qualcomm Write Nvitem    ${ue_id}    74087    0
#     Wait '10s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    reboot
# 
# Unlock one 4G cell
#     [Arguments]    ${phy_cell_id}    ${bts_id}=192.168.255.129    ${alias}=unblock
#     TAF_ADMIN.connect to    bts_host=${bts_id}    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}    TAF_ADMIN.Get Parameters For All    LNCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.phyCellId}'=='${phy_cell_id}' and '${nrcel.blockingState}'=='Blocked'
#     ...  TAF_ADMIN.unblock cell    ${nrcel.id}    timeout=60    connection=${alias}
#     TAF_ADMIN.teardown    connection=${alias}
# 
# lock one 4G cell
#     [Arguments]    ${phy_cell_id}    ${bts_id}=192.168.255.129    ${alias}=block
#     TAF_ADMIN.connect to    bts_host=${bts_id}    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}    TAF_ADMIN.Get Parameters For All    LNCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.phyCellId}'=='${phy_cell_id}' and '${nrcel.blockingState}'=='Unblocked'
#     ...   TAF_ADMIN.block cell    ${nrcel.id}    timeout=60    connection=${alias}
#     TAF_ADMIN.teardown    connection=${alias}
# 
# 
# #get F1AP and UE id for test start
# Start collect UE f1ap
#     [Arguments]     ${bip_file}
#     Log To Console    Start collect '${bip_file}' tcpdump
#     ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
#     Start Tcpdump    name=${bip_file}    options= -i any -C 300    remote_info=${executor_oam_vm}
# 
# Stop collect UE f1ap
#     [Arguments]     ${bip_file}
#     Log To Console    Stop collect '${bip_file}' tcpdump
#     Stop Tcpdump    ${bip_file}    ${TEST_LOG_DIRECTORY()}/All/${bip_file}
# 
# Get col_values from bip csv
#     [Arguments]    ${csv_file}    ${col_name}
#     ${col_values}    read_csv_columns    ${csv_file}    ${col_name}
#     ${col_value_list}    Remove Duplicates    ${col_values}
#     [return]     ${col_value_list}
# 
# Check UE srs_switch from s1ap
#     [Arguments]     ${bip_file}    ${ini_path}
#     Log To Console   Check '${bip_file}' srs_switch
#     Run Keyword And ignore error    Convert BIP To CSV
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/${bip_file}.pcap
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_srsModify}    ${titles_tasSrsResourceInd}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/${ini_path}.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_file}/
# 
# Get Crnti and gnb_du_id from f1ap
#     [Arguments]     ${bip_file}    ${ue_id}
#     Log To Console   Check '${bip_file}' Crnti and gnb_du_id
#     Run Keyword And ignore error    Convert BIP To CSV
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/${bip_file}.pcap
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_rrc_itl_l2ps}    ${titles_duID_Crnti}
#     ${gnb_du_id_list}    Get col_values from bip csv    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    f1ap.GNB_DU_UE_F1AP_ID
#     Set Test Variable    ${ue${ue_id}_gnb_du_id}    ${gnb_du_id_list[0]}
#     ${ue_rnti}    Get col_values from bip csv    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    3gpp.rnti
#     set suite variable     ${ue${ue_id}_rnti}    ${ue_rnti[0]}
#     Log To Console   \n------UE${ue_id} gnb_du_id is ${ue${ue_id}_gnb_du_id},crnti is ${ue${ue_id}_rnti}-----
#     [Return]    ${ue${ue_id}_gnb_du_id}    ${ue${ue_id}_rnti}
# #get F1AP and UE id for test end
# 
# 
# Attach 2SA2NSA UEs anc check RRC logs
#     [Arguments]    ${UE1_ID}    ${UE2_ID}   ${UE3_ID}    ${UE4_ID}     ${dmc}
#     ${rnti_list}   create list
#     ${gnb_du_list}   create list
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
# #    \     Qualcomm Start Qxdm Trace    ${UE${num}_ID}    dmc_file=${dmc}
#     \     Qualcomm detach ue    ${UE${num}_ID}
#     \     ${gnb_du_id_r}    ${ue_rnti_r}    Qualcomm attach ue hardly    ${UE${num}_ID}
#     \     append to list    ${rnti_list}    ${ue_rnti_r}
#     \     append to list    ${gnb_du_list}    ${gnb_du_id_r}
# #    \     ${ue_absolutely_path}    Qualcomm Stop Qxdm Trace    ${UE${num}_ID}    ${log_path}
# #    \     Download qualcomm log    ${ue_absolutely_path}.hdf     ${EXPORT_GRID}    ${UE${num}_ID}_rrc_raw.txt
# #    \     ${ret}    Get_Rach_Msg4_Crnti   ${test_log_directory()}${/}${UE${num}_ID}_rrc_raw.txt
# #    \     set suite variable     ${UE${num}_rnti}     ${ret}
# #    \     append to list    ${rnti_list}    ${UE${num}_rnti}
# #    \     run keyword and continue on failure    filter_qcat_message
# #          ...       ${test_log_directory()}${/}${UE${num}_ID}_rrc_raw.txt      ::=    ${test_log_directory()}${/}RRC_UE${num}.txt
# #    \     set global variable  ${num}
# #    \     run keyword if   ${num}>2  check_log_with_au2anlysis
# #          ...        ${CURDIR}/ini/8701_case15_rrclog_SA.ini    p    save_log_directory=${test_log_directory()}
# #    \     run keyword if   ${num}<3  check_log_with_au2anlysis
# #          ...        ${CURDIR}/ini/8701_case15_rrclog_NSA.ini    p    save_log_directory=${test_log_directory()}
# #    \     log to console     check  UE_${UE${num}_ID} RRC logs
# #    set suite variable   ${rnti_list_suite}    ${rnti_list}
#     set suite variable   ${rnti_list_suite}    ${rnti_list}
#     set suite variable   ${gnb_du_list_suite}    ${gnb_du_list}
# 
# Qualcomm attach ue hardly
#     [Arguments]    ${ue_id}
#     : FOR    ${reboot_count}    IN RANGE    1    4
#     \    Start collect UE f1ap    UE${ue_id}_attach_f1ap
#     \    ${out}    ${attach_status}     Run Keyword And Ignore Error   Qualcomm Attach With Adb    ${ue_id}
#     \    Run Keyword if    '${attach_status}'=='True'    Stop collect UE f1ap    UE${ue_id}_attach_f1ap
#     \    Run Keyword if    '${attach_status}'=='True'    Exit For Loop
#     \    Stop collect UE f1ap    UE${ue_id}_attach_f1ap
#     \    Qualcomm Execute Adb Cmd     ${ue_id}    reboot
#     \    Sleep    60
#     \    ${reboot_count}    Set Variable    ${reboot_count}+1
#     \    Qualcomm Detach With Adb      ${ue_id}
#     Log To Console   attach UE${ue_id} successfully
#     ${gnb_du_id_r}    ${ue_rnti_r}    Get Crnti and gnb_du_id from f1ap    UE${ue_id}_attach_f1ap    ${ue_id}
#     [Return]    ${gnb_du_id_r}    ${ue_rnti_r}

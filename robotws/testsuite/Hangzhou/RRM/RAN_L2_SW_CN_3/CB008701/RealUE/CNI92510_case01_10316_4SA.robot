# *** Settings ***
# Suite Setup       Qualcomm Common Suite Setup
# #Suite Teardown    Qualcomm Common Suite Teardown
# Test Setup        Qualcomm Common Test Setup
# #Test Teardown     Qualcomm Common Test Teardown
# Force Tags        qualcomm    owner_l3gao    SBTS00   SBTS22R4   CRT
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# Library           taf.sbts.oam.coam.admin
# Library           taf.pdu
# 
# 
# Documentation     gNB10316  @{Rdparameter}
# ...    PMcounter 0x340000:15
# ...    UE1 UE2 NSA traffic    UE3 UE4 SA traffic
# ...    cell bandwith 60mhz
# ...    KPI_NR_5055b_5054a_5108d check in ideal line
# ...    pdsch cdm group and dmrs port check
# ...    pdsch and pdcch antport check
# ...    EDA_02880350_02843103
# ...    64QAM
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE1_ID}         10a5c6e6  #MCS B1-2-3-4   MTP8450   com23
# ${UE2_ID}         ca3e3465  #MCS B5-6-7-8   MTP8450   com36
# ${UE3_ID}         f19fafe0  #MCS B9-10-11-12   MTP8350   com32
# ${UE4_ID}         95fe0e6e  #MCS B13-14-15-16   MTP8350   com9
# ${UE_DL_PORT1}    5001
# ${UE_DL_PORT2}    5002
# ${UE_DL_PORT3}    5003
# ${UE_DL_PORT4}    5004
# ${UE_UL_PORT}    5005
# ${DL_LOG}    /tmp/iperf_server_on_ue_log.txt
# ${UL_LOG}    /tmp/iperf_server_on_pc_log.txt
# ${DL_SEND_DATA_CMD}    -u -t 8000 -i 1 -P 1 -f m -b 600.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_60mhz_rank4}    -u -t 8000 -i 1 -P 1 -f m -b 600.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_60mhz_rank3}    -u -t 8000 -i 1 -P 1 -f m -b 450.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_60mhz_rank2}    -u -t 8000 -i 1 -P 1 -f m -b 300.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_60mhz_rank1}    -u -t 8000 -i 1 -P 1 -f m -b 150.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_60mhz_rank0}    -u -t 8000 -i 1 -P 1 -f m -b 100 -l 1400B -T 64
# ${DL_SEND_DATA_CMD_100mhz_rank4}    -u -t 8000 -i 1 -P 1 -f m -b 1010.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_100mhz_rank3}    -u -t 8000 -i 1 -P 1 -f m -b 760.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_100mhz_rank2}    -u -t 8000 -i 1 -P 1 -f m -b 510.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_100mhz_rank1}    -u -t 8000 -i 1 -P 1 -f m -b 260.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_100mhz_rank0}    -u -t 8000 -i 1 -P 1 -f m -b 100 -l 1400B -T 64
# ${DL_SEND_DATA_CMD_40mhz_rank4}    -u -t 8000 -i 1 -P 1 -f m -b 400.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_40mhz_rank3}    -u -t 8000 -i 1 -P 1 -f m -b 300.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_40mhz_rank2}    -u -t 8000 -i 1 -P 1 -f m -b 200.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_40mhz_rank1}    -u -t 8000 -i 1 -P 1 -f m -b 100.00M -l 1400B -T 64
# ${DL_SEND_DATA_CMD_40mhz_rank0}    -u -t 8000 -i 1 -P 1 -f m -b 100 -l 1400B -T 64
# ${UL_SEND_DATA_CMD}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 200M -t 600
# ${EXPORT_GRID_TP}    Common Displays;Events and Debug Msgs vs. Time
# ${EXPORT_GRID}    ${None}
# &{GNBMIRRORINGCONFIGS}     L2HI_MIRRORING='false'   L2RT_MIRRORING='true'     NUMBER_OF_FILES=10    FILE_SIZE_MBYTES=300
# ${SCFC_NAME}     CNI92510_case1_2_60mhz.xml
# ${GNB_SWCONFIG_QUAL_NAME}     gnb_swconfig.txt
# ${4G_S1_local_IP}    10.108.175.74
# @{Rdparameter}    0x340000:15    0x580264:3   # 0x5806d7:1    0x580430:1  83499 enable  0x420062:1  8701 enable &0x340000 pm counter 1min
# ${ATT_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/4QC_16layer_2NSA_2SA_att.csv
# ${PHASE_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/4QC_16layer_2NSA_2SA_phase.csv
# ${PHASE_att_FILE_PATH}   ${CONFIG_DIR_PATH}/qualcomm_config/4QC_16layer_2NSA_2SA.csv
# ${FIX_RANK4}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x04
# ${FIX_RANK3}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x03
# ${FIX_RANK2}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x02
# ${FIX_RANK1}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x01
# ${FIX_RANK0}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x04
# ${dmc_file}    ${CONFIG_DIR_PATH}/qualcomm_config/NR5G_Debugging_TP.dmc
# ${UE_NUM}   4
# ${iperfpc_ip}   10.108.183.187  #10.106.164.21
# 
# *** Test Cases ***
# CNI92510_case01_EDA_4UE_DL_pairing_KPI_NR_5055b_5054a_5108d_CB008701_ideal_line
# #    Modify Qualcomm gNB Swconfig
# #    detach all UEs
# #    Qualcomm prepare gnb onair
#     Prepare 4UE for SA env
# #    Set Mcs Channel Phase And Attenuation same time    ${PHASE_att_FILE_PATH}
# #    Set Mcs Channel Phase And Attenuation    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
#     online change parameters    delta_92510    true    false    true   disabled       #4UE ran4
#     attach 4 UES with full buffer for stable    60mhz
#     Start QXDM trace      ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
#     check 4UE pairing and TP_bler     TP=570    counter=12000000    cellBW=60mhz
#     ...    tag=mu_true_4rank4    UE1_rank=4    UE2_rank=4    UE3_rank=4    UE4_rank=4
#     ${PM_counter_file}    Get 8701 PRB_mulayer and KPI counter file
#     Ideal line PRB_mulayer counter check    12000000    ${PM_counter_file}
#     ${NR_5055b_MUtrue}    ${NR_5054a_MUtrue}    ${NR_5108d_MUtrue}    ${NR_5109d_MUtrue}    KPI 5055b_5054a_5108d counter check
#     ...   ${PM_counter_file}
#     detach all UEs
#     Stop QXDM trace    ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
# #
#     attach 4 UES with full buffer for stable    60mhz   #2UEran4_2UEranK
#     Start QXDM trace      ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
#     check 4UE pairing and TP_bler     TP=570    counter=12000000    cellBW=60mhz
#     ...    tag=mu_true_ran2_2_4_4    UE1_rank=2    UE2_rank=2    UE3_rank=4    UE4_rank=4
#     ${PM_counter_file}    Get 8701 PRB_mulayer and KPI counter file
#     Ideal line PRB_mulayer counter check    12000000    ${PM_counter_file}
#     ${NR_5055b_MUtrue}    ${NR_5054a_MUtrue}    ${NR_5108d_MUtrue}    ${NR_5109d_MUtrue}    KPI 5055b_5054a_5108d counter check
#     ...    ${PM_counter_file}
#     detach all UEs
#     Stop QXDM trace    ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
# 
#     attach 4 UES with full buffer for stable    60mhz   #rank1_3_4_4
#     Start QXDM trace      ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
#     check 4UE pairing and TP_bler     TP=570    counter=12000000    cellBW=60mhz
#     ...    tag=mu_true_ran1_3_4_4   UE1_rank=1    UE2_rank=3    UE3_rank=4    UE4_rank=4
#     ${PM_counter_file}    Get 8701 PRB_mulayer and KPI counter file
#     Ideal line PRB_mulayer counter check    12000000    ${PM_counter_file}
#     ${NR_5055b_MUtrue}    ${NR_5054a_MUtrue}    ${NR_5108d_MUtrue}    ${NR_5109d_MUtrue}    KPI 5055b_5054a_5108d counter check
#     ...    ${PM_counter_file}
#     detach all UEs
#     Stop QXDM trace    ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
# 
#     online change parameters    delta_92510    false    false    true   disabled
#     attach 4 UES with full buffer for stable    60mhz
#     Start QXDM trace      ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
#     check 4UE pairing and TP_bler     TP=142    counter=12000000    cellBW=60mhz
#     ...    tag=mu_false_rank4_4_4_4    UE1_rank=4    UE2_rank=4    UE3_rank=4    UE4_rank=4
#     ${PM_counter_file}    Get 8701 PRB_mulayer and KPI counter file
#     ${NR_5055b_MUfalse}    ${NR_5054a_MUfalse}    ${NR_5108d_MUfalse}    ${NR_5109d_MUfalse}    KPI 5055b_5054a_5108d counter check
#     ...    ${PM_counter_file}
#     detach all UEs
#     Stop QXDM trace    ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
# 
#     attach 4 UES with full buffer for stable    60mhz
#     Start QXDM trace      ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
#     check 4UE pairing and TP_bler     TP=142    counter=12000000    cellBW=60mhz
#     ...    tag=mu_false_rank2_2_4_4    UE1_rank=2    UE2_rank=2    UE3_rank=4    UE4_rank=4
#     ${PM_counter_file}    Get 8701 PRB_mulayer and KPI counter file
#     ${NR_5055b_MUfalse}    ${NR_5054a_MUfalse}    ${NR_5108d_MUfalse}    ${NR_5109d_MUfalse}    KPI 5055b_5054a_5108d counter check
#     ...    ${PM_counter_file}
#     detach all UEs
#     Stop QXDM trace    ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
# 
#     attach 4 UES with full buffer for stable    60mhz   #rank1_3_4_4
#     Start QXDM trace      ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
#     check 4UE pairing and TP_bler     TP=570    counter=12000000    cellBW=60mhz
#     ...    tag=mu_false_rank1_3_4_4   UE1_rank=1    UE2_rank=3    UE3_rank=4    UE4_rank=4
#     ${PM_counter_file}    Get 8701 PRB_mulayer and KPI counter file
#     ${NR_5055b_MUtrue}    ${NR_5054a_MUtrue}    ${NR_5108d_MUtrue}    ${NR_5109d_MUfalse}    KPI 5055b_5054a_5108d counter check
#     ...    ${PM_counter_file}
#     detach all UEs
#     Stop QXDM trace    ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
# 
# *** Keywords ***
# Online change parameters
#     [Arguments]    ${delta_92510}    ${actDlMuMimoEnh}    ${actUlMuMimo}    ${actDl256Qam}    ${dlMuMimoRankAdaption}
#     ${template}    OperatingSystem.Get File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_92510}.json
#     log to console    ${template}
#     ${message} =    Replace Variables    ${template}
#     Create File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_92510}_modified.json    ${message}
#     Online recommissioning with delta json file
#     ...   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_92510}_modified.json
#     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
# 
# Get 8701 PRB_mulayer and KPI counter file
#     Wait '60s' for stable
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     log to console    ${remaining_time}
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
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
# 
#     set global variable    ${8701_pair_counter}
# 
# KPI 5055b_5054a_5108d counter check
#     [Arguments]    ${PM_counter_file}
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
#     log to console    PDSCH_SUCC_ANY_64TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_64TBL_MCS}
#     log to console    PDSCH_UNSUCC_64TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_64TBL_MCS}
#     log to console    PDSCH_SUCC_ANY_256TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_256TBL_MCS}
#     log to console    PDSCH_UNSUCC_256TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_256TBL_MCS}
#     ${unsucc}    evaluate    sum(${PDSCH_UNSUCC_64TBL_MCS})+sum(${PDSCH_UNSUCC_64TBL_MCS})
#     ${SUCC_ANY}    evaluate    sum(${PDSCH_SUCC_ANY_64TBL_MCS})+sum(${PDSCH_SUCC_ANY_256TBL_MCS})
#     ${NR_5055b}    evaluate    ${unsucc}/(${SUCC_ANY}+${unsucc})
#     run keyword and continue on failure   should be true   ${NR_5055b}<0.001
#     log to console    KPI NR_5055b residual bler is ${NR_5055b}
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
#     log to console    PDSCH_INITX_64TBL_MCS 0_to_28 is ${PDSCH_INITX_64TBL_MCS}
#     log to console    PDSCH_SUCC_INI_64TBL_MCS 0_to_28 is ${PDSCH_SUCC_INI_64TBL_MCS}
#     log to console    PDSCH_INI_256TBL_MCS 0_to_27 is ${PDSCH_INI_256TBL_MCS}
#     log to console    PDSCH_SUCC_INI_256TBL_MCS 0_to_27 is ${PDSCH_SUCC_INI_256TBL_MCS}
# 
#     ${ini_tx}    evaluate    sum(${PDSCH_INITX_64TBL_MCS})+sum(${PDSCH_INI_256TBL_MCS})
#     ${ini_SUCC}    evaluate    sum(${PDSCH_SUCC_INI_64TBL_MCS})+sum(${PDSCH_SUCC_INI_256TBL_MCS})
#     ${NR_5054a}    evaluate    (${ini_tx}-${ini_SUCC})/${ini_tx}
#     run keyword and continue on failure   should be true   ${NR_5054a}<0.001
#     log to console    KPI NR_5054a iniBler is ${NR_5054a}
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
#     log to console    KPI NR_5108d SE_downlink is ${NR_5108d}
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
#     log to console    64qam:${L_M55304C0400X}
#     log to console    dft_s_ofdm:${L_M55304C0800X}
#     log to console    256qam:${L_M55304C1000X}
#     log to console    ${L_M55308}
#     log to console    SE_KPI_Value=${NR_5109d}
#     [Return]    ${NR_5055b}    ${NR_5054a}    ${NR_5108d}    ${NR_5109d}
# 
# 
# 
# Wait '${ct}' get NR_5109d counter${vv}
# 
# 
#     [Return]    ${SE_KPI_Value}
# 
# 
# #   ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}
# #	${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}
# #	${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}
# #	${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}
# #	${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}
# #	${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}
# 
# #	${M55308C34023_PRB_DL_MU_MIMO_16LAYER}
# #	${M55308C34022_PRB_DL_MU_MIMO_15LAYER}
# #	${M55308C34021_PRB_DL_MU_MIMO_14LAYER}
# #	${M55308C34020_PRB_DL_MU_MIMO_13LAYER}
# #	${M55308C34019_PRB_DL_MU_MIMO_12LAYER}
# #	${M55308C34018_PRB_DL_MU_MIMO_11LAYER}
# #	${M55308C34017_PRB_DL_MU_MIMO_10LAYER}
# #	${M55308C34016_PRB_DL_MU_MIMO_9LAYER}
# 
# #	${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}
# #	${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}
# #	${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}
# #	${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}
# 
# #	${M55308C34011_PRB_DL_MU_MIMO_8LAYER}
# #	${M55308C34010_PRB_DL_MU_MIMO_7LAYER}
# #	${M55308C34009_PRB_DL_MU_MIMO_6LAYER}
# #	${M55308C34008_PRB_DL_MU_MIMO_5LAYER}
# # 	${M55308C34007_PRB_DL_MU_MIMO_4LAYER}
# #  	${M55308C34006_PRB_DL_MU_MIMO_3LAYER}
# #  	${M55308C34005_PRB_DL_MU_MIMO_2LAYER}
# 
# #  	${M55308C34004_PRB_DL_SU_MIMO_4LAYER}
# #  	${M55308C34003_PRB_DL_SU_MIMO_3LAYER}
# #   ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}
# #   ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}
# 
# 
# check 8701 counter with MUlayer 16 and theresh '${counter_check}'
#     Get 8701 counters
#     run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}>${counter_check}
# 
# Prepare UE for SA_NSA env
#     unlock one 4G cell    287    ${4G_S1_local_IP}
#     Set ue to NSA simple    ${UE1_ID}
#     Wait '5s' for stabible
#     Set ue to NSA simple   ${UE2_ID}
#     Wait '5s' for stabible
#     Set ue to SA simple   ${UE3_ID}
#     Wait '5s' for stabible
#     Set ue to SA simple   ${UE4_ID}
#     Wait '35s' for stabible    #wait for UE4 come back
# 
# Prepare 4UE for SA env
#     lock one 4G cell    287    ${4G_S1_local_IP}
#     Set ue to SA simple    ${UE1_ID}
#     Wait '5s' for stabible
#     Set ue to SA simple   ${UE2_ID}
#     Wait '5s' for stabible
#     Set ue to SA simple   ${UE3_ID}
#     Wait '5s' for stabible
#     Set ue to SA simple   ${UE4_ID}
#     Wait '35s' for stabible    #wait for UE4 come back
# 
# Set ue to NSA simple
#     [Arguments]    ${ue_id}
#     ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
#     Wait '10s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    80000    80
#     Wait '5s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    74213    1099511627776
#     Qualcomm Write Nvitem    ${ue_id}    74087    0
#     ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
#     Wait '10s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    reboot
# 
# Set ue to SA simple
#     [Arguments]    ${ue_id}
#     ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
#     Wait '10s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    80000    64
#     Wait '5s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    74213    0
#     Qualcomm Write Nvitem    ${ue_id}    74087    1099511627776
#     Wait '10s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    reboot
# 
# Set ue to NSA   #may not used
#     [Arguments]    ${ue_id}
#     ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
#     Wait '5s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    80000    80
#     Wait '5s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    74213    1099511627776
#     Qualcomm Write Nvitem    ${ue_id}    74087    0
#     qualcomm_execute_adb_cmd    ${ue_id}    root
#     Wait '5s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    wait-for-device
#     Wait '5s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.radio.multisim.config ssss
#     Wait '1s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    shell sync
#     Wait '1s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    shell rm -rf /data/user_de/0/com.android.providers.telephony/databases/telephony.db
#     Wait '1s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref 1
#     Wait '1s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_0 1
#     Wait '1s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_1 1
#     Wait '1s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    shell sync
#     Wait '1s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    reboot
#     Wait '70s' for stable
#     Qualcomm Set Apn    ${ue_id}    NSA     stdata3
#     Wait '5s' for stable
# 
# Set ue to SA
#     [Arguments]    ${ue_id}
#     ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
#     Wait '5s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    80000    64
#     Wait '5s' for stable
#     Qualcomm Write Nvitem    ${ue_id}    74213    0
#     Qualcomm Write Nvitem    ${ue_id}    74087    1099511627776
#     Qualcomm Write Nvitem    ${ue_id}    67218    1
#     Qualcomm Write Nvitem    ${ue_id}    73991    0
#     Wait '2s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    root
#     Wait '5s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    wait-for-device
#     Wait '5s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    setprop persist.radio.multisim.config ssss
#     Wait '1s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    shell sync
#     Wait '1s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    shell rm -rf /data/user_de/0/com.android.providers.telephony/databases/telephony.db
#     Wait '1s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref 2
#     Wait '1s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_0 2
#     Wait '1s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_1 2
#     Wait '1s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    shell sync
#     Wait '1s' for stable
#     qualcomm_execute_adb_cmd    ${ue_id}    reboot
#     Wait '70s' for stable
#     Qualcomm Set Apn    ${ue_id}    SA    stdata3
#     Wait '5s' for stable
# 
# Unlock one 4G cell
#     [Arguments]    ${phy_cell_id}    ${bts_id}=192.168.255.129    ${alias}=block
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
# attach 4 UES with full buffer for stable
#     [Arguments]    ${cell_bandwith}
#     Start capture only gnb syslog in 'rrc_${cell_bandwith}' file
#     Attach qualcomm ue and make call stable    ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${cell_bandwith}
#     Attach 2SA2NSA UEs anc check RRC logs   ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
#     Start UE full buffer with UErank'4''4''4''4''${cell_bandwith}'
#     Wait '10s' for stable
#     Stop capture only gnb syslog in 'rrc_${cell_bandwith}' file
# 
# check 4UE pairing and TP_bler
#     [Arguments]    ${TP}    ${counter}    ${cellBW}    ${tag}    ${UE1_rank}    ${UE2_rank}    ${UE3_rank}=4    ${UE4_rank}=4
#     log to console  check 4UE pairing and TP_bler_${tag}
#     Stop UE data
#     Start UE full buffer with UErank'${UE1_rank}''${UE2_rank}''4''4''${cellBW}'
#     Start capture only gnb syslog in '${tag}_4UE' file
#     qualcomm_send_qxdm_command    ${UE1_ID}    ${FIX_RANK${UE1_rank}}
#     qualcomm_send_qxdm_command    ${UE2_ID}    ${FIX_RANK${UE2_rank}}
# #    run keyword and continue on failure    Start collect bip log
# #    run keyword and continue on failure    Wait for '3s' to stop bip log with name'bip_MU${layer}layer_4UE'
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'${tag}_4UE'
#     run keyword and continue on failure     Check TP and bler with rank by ttitrace    ${TP}    1    ${tag}_4UE
#     ...    tti_case15_pair_power   ${UE1_rank}   ${UE2_rank}   4   4
#     Stop capture only gnb syslog in '${tag}_4UE' file
# 
# Attach qualcomm ue and make call stable
#     [Arguments]    ${UE1_ID}    ${UE2_ID}   ${UE3_ID}    ${UE4_ID}    ${cell_bandwith}
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
#     \     Qualcomm detach ue    ${UE${num}_ID}
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
#     \     Qualcomm attach ue hardly    ${UE${num}_ID}
#     Start UE full buffer with UErank'4''4''4''4''${cell_bandwith}'
#     Wait '5s' for stabible
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
# Attach 2SA2NSA UEs anc check RRC logs
#     [Arguments]    ${UE1_ID}    ${UE2_ID}   ${UE3_ID}    ${UE4_ID}     ${dmc}
#     ${rnti_list}   create list
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
#     \     Qualcomm Start Qxdm Trace    ${UE${num}_ID}    dmc_file=${dmc}
#     \     Qualcomm detach ue    ${UE${num}_ID}
#     \     Qualcomm attach ue hardly    ${UE${num}_ID}
#     \     ${ue_absolutely_path}    Qualcomm Stop Qxdm Trace    ${UE${num}_ID}    ${log_path}
#     \     Download qualcomm log    ${ue_absolutely_path}.hdf     ${EXPORT_GRID}    ${UE${num}_ID}_rrc_raw.txt
#     \     ${ret}    Get_Rach_Msg4_Crnti   ${test_log_directory()}${/}${UE${num}_ID}_rrc_raw.txt
#     \     set suite variable     ${rnti}     ${ret}
#     \     append to list    ${rnti_list}    ${rnti}
#     \     run keyword and continue on failure    filter_qcat_message
#           ...       ${test_log_directory()}${/}${UE${num}_ID}_rrc_raw.txt      ::=    ${test_log_directory()}${/}RRC_UE${num}.txt
#     \     set global variable  ${num}
# #    \     run keyword if   ${num}>2  check_log_with_au2anlysis
# #          ...        ${CURDIR}/ini/8701_case15_rrclog_SA.ini    p    save_log_directory=${test_log_directory()}
# #    \     run keyword if   ${num}<3  check_log_with_au2anlysis
# #          ...        ${CURDIR}/ini/8701_case15_rrclog_NSA.ini    p    save_log_directory=${test_log_directory()}
# #    \     log to console     check  UE_${UE${num}_ID} RRC logs
#     set suite variable   ${rnti_list_suite}    ${rnti_list}
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
# 
# Stop UE data
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
#     \     Qualcomm Stop DL Data    ${UE${num}_ID}    ${UE_DL_PORT${num}}
#     \     Qualcomm Stop UL Data    ${UE${num}_ID}    ${UE_UL_PORT}
# 
# Download QC logs and check rrc
#     : for    ${num}   IN RANGE  1   ${NUM}+1
#     \     Download qualcomm log    ${ue${num}_logs_path}.hdf     ${EXPORT_GRID}    ${UE${num}_ID}_rrc_raw.txt
#     \     Qualcomm Start DL Data    ${UE${num}_ID}    ${UE_DL_PORT}+${num}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     \     Qualcomm Start UL Data    ${UE${num}_ID}    ${UE_UL_PORT}+${num}    ${UL_LOG}    ${UL_SEND_DATA_CMD}
#     \     log to console     comment check RRC logs
#     \     run keyword and continue on failure    filter_qcat_message
#           ...       ${test_log_directory()}${/}${UE${num}_ID}_rrc_raw.txt      ::=    ${test_log_directory()}${/}RRC_UE${num}.txt
#     \     run keyword and continue on failure    check_log_with_au2anlysis
#     ...        ${CURDIR}/ini/8701_case15_rrclog_UE${num}.ini    p    save_log_directory=${test_log_directory()}
# 
# Check TP and bler with rank by ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}   ${UE1_rank}   ${UE2_rank}   ${UE3_rank}   ${UE4_rank}
#     ${UE_TP_list}   create list
#     ${UE_ackrate_list}   create list
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}_tti/tti_dl.csv
#     ...        ${test_log_directory()}/All/${tti_file}_tti/tti_dl_new.csv   ${time_avg}    ratio=0    filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR   ${num}   IN RANGE   1   ${UE_NUM}+1     #check tp based on given crnti
#     \    ${result1}  evaluate   ${a[${rnti_list_suite[${num}-1]}]}/${time_avg}/1024/1000
#     \    ${target_tp}  evaluate   ${throughput}*${UE${num}_rank}/4
#     \    should be true  ${result1}>${target_tp}
#     \    append to list   ${UE_TP_list}   ${result1}
#     \    log to console   UE rnti ${rnti_list_suite[${num}-1]} TP is ${result1} target is ${target_tp}
#     : FOR    ${T_rnti}   IN    @{rnti_list_suite}     #check bler
#     \    ${ackNack}    read_csv_columns    ${test_log_directory()}/All/${tti_file}_tti/tti_dl.csv
#     ...   dlFdSchedData.ackNack    filter=rnti=${T_rnti}
#     \    ${ret1}    evaluate  ${ackNack}.count('ACK')/len(${ackNack})
#     \    run keyword and continue on failure    should be true  ${ret1}>0.98
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
# Qualcomm attach ue hardly
#     [Arguments]    ${ue_id}
#     : FOR    ${reboot_count}    IN RANGE    1    5
#     \    ${out}    ${attach_status}     Run Keyword And Ignore Error   Qualcomm Attach With Adb    ${ue_id}
#     \    Run Keyword if    '${attach_status}'=='True'    Exit For Loop
#     \    Qualcomm Execute Adb Cmd     ${ue_id}    reboot
#     \    Sleep    60
#     \    ${reboot_count}    Set Variable    ${reboot_count}+1
#     \    Qualcomm Detach With Adb      ${ue_id}
# 
# Start QXDM trace
#     [Arguments]    ${UE1_ID}    ${UE2_ID}   ${UE3_ID}    ${UE4_ID}     ${dmc}
#     : for    ${num}   IN RANGE  1   ${UE_NUM}+1
#     \     Qualcomm Start Qxdm Trace    ${UE${num}_ID}    dmc_file=${dmc}
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
# Add GNB swconfig
#     [Arguments]    @{Rdparameter}
#     Backup Swconfig    ${CURDIR}    gnb_swconfig.txt
#     setup_txt    src_file=${CURDIR}/gnb_swconfig.txt    save_path=${CURDIR}/gnb_swconfig_modify.txt
#     :FOR    ${parameter}    IN    @{Rdparameter}
#     \    ${key}    ${value}    Split String    ${parameter}    :
#     \    run keyword and ignore error    delete txt node    ${key}
#     \    add txt node    ${parameter}
#     teardown txt
#     GNB Upload Swconfig    ${CURDIR}/gnb_swconfig_modify.txt
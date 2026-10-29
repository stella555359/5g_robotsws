# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BLLL_AP_LOO    AP    owner_l3gao    CRT    SBTS00
# ...      RAN_5G_TDD    RAN_5G
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# Documentation
# ...     AdditionalDMRS_Auto   --change to one additional with ulptrs false
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}    CB009198_CASE09_BLLL.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_2CELL_2BLLL_AP_LOO.xml
# ${WTS_NAME}      WTS_SANSA_n78_8SA_32NSA_8DL4UL_2CELL_MU_APLO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    # ap_snapshot    egatelog
# ${FILTER_1}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# @{titles_1}    DlData_PdschGrant.bestBeamPowerOffset
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_1='false'    BB_SLOT_2='false'    BB_SLOT_5='true'    L2_L1_BIP='true'
# ...    NUMBER_OF_FILES=10    FILE_SIZE_MBYTES=100
# ...    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='false'   L2RT_MIRRORING='false'    CPRT_MIRRORING='false'
# @{Rdparameter}    0x340000:15
# ${UE_NUM}         12
# ${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
# @{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch
# ${9198_SinrThresh}    ${CONFIG_DIR_PATH}/SBTS23R3/JSON/Delta_9198_UL_TPSinrThresh.json
# ${sinr_start}    -350
# ${sinr_end}    -200
# ${sinr_step}   50
# ${sinr_start_lower}    -600
# ${sinr_end_lower}    -500
# ${sinr_step_lower}   50
# 
# *** Test Cases ***
# CB009198_B_B9_case09_NSA_PUSCH_typeA_DMRSpos3_PTRSOFF_AdditionalDMRS_1_And_DFT_S_OFDM
#     step1:prepare gNB line
#     step2:change ulTransPrecodeSinrThresh to upper bund and check DFTS
#     step3:change ulTransPrecodeSinrThresh to lower bund and check DFTS
# 
# *** Keywords ***
# step1:prepare gNB line
#     Add GNB swconfig    @{Rdparameter}
#     Prepare gnb onair
# 
# step2:change ulTransPrecodeSinrThresh to upper bund and check DFTS
#     Start capture gnb and ap syslog in 'case09_all_step2' file
# #    online change ulTransPrecodeSinrThresh    200    180   200   180
#     Attach '${UE_NUM}' NSA UE and data buffer sent
#     Wait '5s' for stable
#     run keyword and continue on failure    Check throughput    710000  55000
#     run keyword and continue on failure    online change ulTransPrecodeSinrThresh    200    180   200   180
#     run keyword and continue on failure    set sinr to UE step by step upper bund
#     run keyword and continue on failure    Airphone NSA Stop Data Traffic And Detach UE
#     log to console   start to check btslog
# #    delete all file id upper
#     Stop capture gnb and ap syslog in 'case09_all_step2' file
# 
# step3:change ulTransPrecodeSinrThresh to lower bund and check DFTS
#     Start capture gnb and ap syslog in 'case09_all_step3' file
#     online change ulTransPrecodeSinrThresh    -50    -100   -50   -100
#     Attach '${UE_NUM}' NSA UE and data buffer sent
#     Wait '5s' for stable
#     run keyword and continue on failure    Check throughput    710000  55000
#     run keyword and continue on failure    set sinr to UE step by step lower bund
#     run keyword and continue on failure    Airphone NSA Stop Data Traffic And Detach UE
#     log to console   start to check btslog
#     delete all file id lower
#     Stop capture gnb and ap syslog in 'case09_all_step3' file
# 
# online change ulTransPrecodeSinrThresh
#     [Arguments]    ${ulTransPrecodeOffSinrThresh}    ${ulTransPrecodeOnSinrThresh}    ${ulTransPrecodeOffSinrThrRedCap}
#     ...    ${ulTransPrecodeOnSinrThrRedCap}
#     log to console    ${9198_SinrThresh}
#     ${template}    OperatingSystem.Get File    ${9198_SinrThresh}
#     ${message} =    Replace Variables    ${template}
#     Create File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/Delta_9198_UL_TPSinrThresh_modified.json    ${message}
#     Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/Delta_9198_UL_TPSinrThresh_modified.json
# 
# Attach '${UE_NUM}' NSA UE and data buffer sent
#     : FOR    ${num}    IN RANGE    12    18
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num}------
#     \   Airphone Nsa Attach    ue_id=${num}    cell_id=1
#     \   Wait '1s' for stable
#     \   Log To Console   -----UE ${num} check rrc ------
#     \   run keyword and continue on failure     Check rrc log for precoder DFT_S    rrc_9198_case09_attach_NSA_precoder_disable    ${num}   rrclogs
#     \   Log To Console   -----UE ${num} buffer sent ------
#     \   NSA send dl and ul data    ue_id=${num}    number=1    dl_data=175M    ul_data=15M   protocol=tcp
#     \   Wait '1s' for stable
#     : FOR    ${num}    IN RANGE    18    24
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
#     \   Airphone Nsa Attach    ue_id=${num}    cell_id=2
#     \   Wait '2s' for stable
#     \   Log To Console   -----UE ${num} check rrc ------
#     \   run keyword and continue on failure     Check rrc log for precoder DFT_S    rrc_9198_case09_attach_NSA_precoder_disable   ${num}    rrclogs
#     \   Log To Console   -----UE ${num} buffer sent ------
#     \   NSA send dl and ul data    ue_id=${num}    number=1    dl_data=175M    ul_data=15M   protocol=tcp
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode    name=${tti_tag}
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/${tti_tag}
#     log to console   cb009198 check mcs sinr
#     run keyword and continue on failure    cb009198 check mcs sinr    ${test_log_directory()}/All/${tti_tag}/${tti_tag}_ul.csv   19
# 
# SA '${UE_NUM}' UE Data buffer send
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   SA send mutiple trf dl data    ${num}    7   175M    ${num}    tcp
#     \   SA send mutiple trf ul data    ${num}    2   150M    ${num}    tcp
# 
# Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   Airphone SA Stop Data Traffic     ${num}     BI    ${num}
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
# 
# Check throughput
#     [Arguments]    ${cell_peak_dl_tput}    ${cell_peak_ul_tput}
#     Wait until keyword succeeds    60s    5s    Verify throughput    ${cell_peak_dl_tput}    ${cell_peak_ul_tput}
# 
# Verify throughput
#     [Arguments]    ${cell_peak_dl_tput}    ${cell_peak_ul_tput}
#     ${ue_dl_tput_target}    evaluate    ${cell_peak_dl_tput}/${UE_NUM}*2
#     ${ue_ul_tput_target}   evaluate    ${cell_peak_ul_tput}/${UE_NUM}*2
#     ${UEs_TP_DL_list}   create list
#     ${UEs_TP_UL_list}   create list
#     log to console    UEs dl_target_tp is ${ue_dl_tput_target}
#     log to console    UEs ul_target_tp is ${ue_ul_tput_target}
#     : FOR    ${num}    IN RANGE    12    24
#     \    ${dl_throughput_ue}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    ${ul_throughput_ue}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pusch    tput_type=ave
#     \    append to list    ${UEs_TP_DL_list}    ${dl_throughput_ue}
#     \    append to list    ${UEs_TP_UL_list}    ${ul_throughput_ue}
#     \    log to console    UEs dl_tp are ${UEs_TP_DL_list}
#     \    log to console    UEs ul_tp are ${UEs_TP_UL_list}
#     \    run keyword and continue on failure     should_be_true    ${dl_throughput_ue}>${ue_dl_tput_target}
#     \    run keyword and continue on failure     should_be_true    ${ul_throughput_ue}>${ue_ul_tput_target}
# 
# set sinr to UE step by step upper bund
#     log to console    \n set UE SINR step by step
#     : FOR    ${sinr}    IN RANGE    ${sinr_start}    ${sinr_end}    ${sinr_step}
#     \    log to console    \n set UE SINR ${sinr}
#     \    ${file_id}   evaluate    int((${sinr}+800)/50)
#     \    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=${file_id} sinr_target_pusch\=${sinr}
#     \    set UE sinr loop upper bund    ${file_id}    ${sinr}
# 
# set UE sinr loop upper bund
#     [Arguments]    ${file_id}    ${sinr}
#     : FOR    ${num}    IN RANGE    12    24
#     \    airphone_cleanup_egate_console_log
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_sinr action\=activate profile_id\=${file_id}
#     \    Wait '2s' for stable
#     \    log to console   ue${num} sinr setted    #ulTransPrecodeSinrThresh    200    180   35   15
#     \    run keyword if   ${sinr}==-350    Check rrc log for precoder DFT_S    9198_case09_precoder_enable    ${num}   upper_bun
#     \    run keyword if   ${sinr}==-250    Check rrc log for precoder DFT_S    9198_case09_precoder_disable    ${num}   upper_bun
#     \    log to console   check ue${num} rrc logs done
#     Wait '2s' for stable
#     Start collect ttitrace    name=NSA_UE_sinr_${sinr}
#     log to console    decode tti start
#     Wait for '1s' to stop ttitrace with name'NSA_UE_sinr_${sinr}'
#     Get 9198 counter
# 
# set sinr to UE step by step lower bund
#     log to console    \n set UE SINR step by step
#     : FOR    ${sinr}    IN RANGE    ${sinr_start_lower}    ${sinr_end_lower}    ${sinr_step_lower}
#     \    log to console    \n set UE SINR ${sinr}
#     \    ${file_id}   evaluate    int((${sinr}+800)/50)
#     \    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=${file_id} sinr_target_pusch\=${sinr}
#     \    set UE sinr loop lower bund    ${file_id}    ${sinr}
# 
# set UE sinr loop lower bund
#     [Arguments]    ${file_id}    ${sinr}
#     : FOR    ${num}    IN RANGE    12    24
# #    \    airphone_cleanup_egate_console_log
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_sinr action\=activate profile_id\=${file_id}
#     \    Wait '2s' for stable
#     \    log to console   ue${num} sinr setted    #ulTransPrecodeSinrThresh    200    180   35   15
# #    \    Check rrc log for precoder DFT_S    9198_case09_precoder_enable_lowerBund    ${num}   lower_bun
#     \    log to console   check ue${num} rrc logs done
#     Wait '2s' for stable
#     Start collect ttitrace    name=NSA_UE_sinr_${sinr}
#     log to console    decode tti start
#     Wait for '1s' to stop ttitrace with name'NSA_UE_sinr_${sinr}'
#     Get 9198 counter
# 
# delete all file id upper
#     : FOR    ${num}    IN RANGE    ${sinr_start}    ${sinr_end}    ${sinr_step}
#     \    ${file_id}   evaluate    int((${num}+800)/50)
#     \    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=${file_id} delete\=1
# 
# delete all file id lower
#     : FOR    ${num}    IN RANGE    ${sinr_start_lower}    ${sinr_end_lower}    ${sinr_step_lower}
#     \    ${file_id}   evaluate    int((${num}+800)/50)
#     \    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=${file_id} delete\=1
# 
# print UE dl and ul tp
#     Wait '5s' for stable
#     ${ul_throughput_pcell_ue}    airphone_get_throughput_on_specific_scell    1    0    type=pusch    tput_type=ave
#     ${dl_throughput_pcell_ue}    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#     log to console    \n ue ul_throughput_pcell_ue ${ul_throughput_pcell_ue}
#     log to console    \n ue dl_throughput_pcell_ue ${dl_throughput_pcell_ue}
# 
# 
# Check rrc log for precoder DFT_S
#     [Arguments]    ${egate tag}    ${ue_id}    ${file_name}
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_${egate tag}_${ue_id}_${file_name}    unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/${egate tag}.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_${egate tag}_${ue_id}_${file_name}
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    12    ${UE_NUM}+12
#     \    log to console    stop data and detach UE${num}
#     \    Airphone NSA Stop Data Traffic   ${num}    BI
#     \    Airphone NSA Detach    ${num}
#     \    Check rrc log for precoder DFT_S    9198_case09_precoder_enable_lowerBund    ${num}   lower_bun
# 
# Get 9198 counter
# #    log to console    ${\n}---wait for 60s for counter---
# #    Wait '60s' for stable
# #    log to console    ${\n}---capture counter start---
# #    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
# #    log to console    counter remianing time is ${remaining_time}
# #    Wait Throughput Timer    ${remaining_time}
#     : FOR    ${cell_id}    IN RANGE    1    3
#     \    check cell 9198 counter   ${cell_id}
# 
# check cell 9198 counter
#     [Arguments]    ${cell_id}
#     ${PUSCH_DFT_INI_64TBL_MCS_0_to_27}   create list
#     ${PUSCH_DFT_UNSUCC_64TBL_MCS_0_to_27}   create list
#     ${PUSCH_DFT_SUCC_INI_64TBL_MCS_0_to_27}   create list
#     ${PUSCH_DFT_SUCC_ANY_64TBL_MCS_0_to_27}   create list
#     ${PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27}   create list
#     ${PUSCH_DFT_INRE_VOL_64TBL_MCS_0_to_27}   create list
#     ${PUSCH_DFT_RANK1_PMI_0_to_5}   create list
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
#     : FOR    ${num}    IN RANGE    0    28
#     \    ${counter_1}   evaluate   6000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55302C0${counter_1}    cell_id=${cell_id}
#     \    set suite variable     ${PUSCH_DFT_INI_64TBL_MCS${num}}     ${result}
#     \    append to list    ${PUSCH_DFT_INI_64TBL_MCS_0_to_27}    ${PUSCH_DFT_INI_64TBL_MCS${num}}
# #    \    log to console    PUSCH_DFT_INI_64TBL_MCS_0_to_27 are ${PUSCH_DFT_INI_64TBL_MCS_0_to_27}
# 
#     \    ${counter_2}   evaluate   7000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55302C0${counter_2}    cell_id=${cell_id}
#     \    set suite variable     ${PUSCH_DFT_UNSUCC_64TBL_MCS${num}}     ${result}
#     \    append to list    ${PUSCH_DFT_UNSUCC_64TBL_MCS_0_to_27}    ${PUSCH_DFT_UNSUCC_64TBL_MCS${num}}
# #    \    log to console    PUSCH_DFT_UNSUCC_64TBL_MCS_0_to_27 are ${PUSCH_DFT_UNSUCC_64TBL_MCS_0_to_27}
# 
#     \    ${counter_3}   evaluate   8000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55302C0${counter_3}    cell_id=${cell_id}
#     \    set suite variable     ${PUSCH_DFT_SUCC_INI_64TBL_MCS${num}}     ${result}
#     \    append to list    ${PUSCH_DFT_SUCC_INI_64TBL_MCS_0_to_27}    ${PUSCH_DFT_SUCC_INI_64TBL_MCS${num}}
# #    \    log to console    PUSCH_DFT_SUCC_INI_64TBL_MCS_0_to_27 are ${PUSCH_DFT_SUCC_INI_64TBL_MCS_0_to_27}
# 
#     \    ${counter_4}   evaluate   9000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55302C0${counter_4}    cell_id=${cell_id}
#     \    set suite variable     ${PUSCH_DFT_SUCC_ANY_64TBL_MCS${num}}     ${result}
#     \    append to list    ${PUSCH_DFT_SUCC_ANY_64TBL_MCS_0_to_27}    ${PUSCH_DFT_SUCC_ANY_64TBL_MCS${num}}
# #    \    log to console    PUSCH_DFT_SUCC_ANY_64TBL_MCS_0_to_27 are ${PUSCH_DFT_SUCC_ANY_64TBL_MCS_0_to_27}
# 
#     \    ${counter_5}   evaluate   7000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0${counter_5}    cell_id=${cell_id}
#     \    set suite variable     ${PUSCH_DFT_INI_VOL_64TBL_MCS${num}}     ${result}
#     \    append to list    ${PUSCH_DFT_INRE_VOL_64TBL_MCS_0_to_27}    ${PUSCH_DFT_INI_VOL_64TBL_MCS${num}}
# #    \    log to console    PUSCH_DFT_INRE_VOL_64TBL_MCS_0_to_27 are ${PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27}
# 
#     \    ${counter_6}   evaluate   8000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0${counter_6}    cell_id=${cell_id}
#     \    set suite variable     ${PUSCH_DFT_INRE_VOL_64TBL_MCS${num}}     ${result}
#     \    append to list    ${PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27}    ${PUSCH_DFT_INI_VOL_64TBL_MCS${num}}
# #    \    log to console    PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27 are ${PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27}
# 
#     : FOR    ${num}    IN RANGE    0    6
#     \    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55303C2100${num}    cell_id=${cell_id}
#     \    set suite variable     ${PUSCH_DFT_RANK1_PMI${num}}     ${result}
#     \    append to list    ${PUSCH_DFT_RANK1_PMI_0_to_5}    ${PUSCH_DFT_RANK1_PMI${num}}
# #    \    log to console    PUSCH_DFT_RANK1_PMI_0_to_5 are ${PUSCH_DFT_RANK1_PMI_0_to_5}
# 
#     log to console    cell${cell_id} PUSCH_DFT_INI_64TBL_MCS_0_to_27 are ${PUSCH_DFT_INI_64TBL_MCS_0_to_27}
#     log to console    cell${cell_id} PUSCH_DFT_SUCC_INI_64TBL_MCS_0_to_27 are ${PUSCH_DFT_SUCC_INI_64TBL_MCS_0_to_27}
#     log to console    cell${cell_id} PUSCH_DFT_SUCC_ANY_64TBL_MCS_0_to_27 are ${PUSCH_DFT_SUCC_ANY_64TBL_MCS_0_to_27}
#     log to console    cell${cell_id} PUSCH_DFT_UNSUCC_64TBL_MCS_0_to_27 are ${PUSCH_DFT_UNSUCC_64TBL_MCS_0_to_27}
#     log to console    cell${cell_id} PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27 are ${PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27}
#     log to console    cell${cell_id} PUSCH_DFT_INRE_VOL_64TBL_MCS_0_to_27 are ${PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27}
#     log to console    cell${cell_id} PUSCH_DFT_RANK1_PMI_0_to_5 are ${PUSCH_DFT_RANK1_PMI_0_to_5}
# 
#     ${MAC_DTCH_CELL_THP_DL_MAX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55309C12001    cell_id=${cell_id}
#     ${MAC_DTCH_CELL_THP_UL_MAX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55309C12002    cell_id=${cell_id}
#     ${Cell1_DL_TP_total}    evaluate    ${MAC_DTCH_CELL_THP_DL_MAX}*8/1024/1024
#     log to console    Cell${cell_id}_TP_total is ${Cell1_DL_TP_total}
# 
# check TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
#     ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR      ${key}     IN     @{keys}
#     \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
#     \    log to console   result is ${result}
#     \    log to console   TP is ${throughput}
#     \    should be true  ${result}>${throughput}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
# 
# 

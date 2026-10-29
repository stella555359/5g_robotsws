# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang    SBTS00    SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# 
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_B_case2.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_2subcell_case2.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${COMAVALUE}    ${CURDIR}/coma/case4.txt
# ${WTS_NAME}    wts_8360_case1.cfg
# ${UE_ID}          1
# ${UE_ID2}          2
# ${BIP_TAG}    srs
# ${FILTER}           uldata_puschreceivereq&&!(3gpp.rnti==65535)
# @{titles}   UlData.patternId_item
# @{Rdparameter}    0x58037C:1    0x58054D:1    0x58054B:A
# ${phr_override_profile_1_CMD}    phr_override_testmode_nr profile_id\=1 phr_mode\=Fixed phr_start\=2
# ...    phr_min\=2 phr_max\=40 phr_step_size\=1 phr_period\=20 pc_max\=30
# ${phr_activate_p1_CMD}    ue_testmode_set_nr id\=1,2,4 scell\=primary testmode\=phr_override profile_id\=1 action\=activate
# 				  
# *** Test Cases ***
# CB008360_B_B1a_case02_two_rank2_Ues_8DL8UL_Max_4Layer_without_tapering
#     Prepare test
#     Prepare gnb onair
# 	#Online change ulMaxMuMimoLayer to 4
#     #Start WTS And Wait BTS Until Onair   ${WTS_NAME}  reload=${False}
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach SA ue to 5g cell    t2r4_n2_pusch_2layer    ${UE_ID}
#     Attach SA ue to 5g cell    t2r4_n2_pusch_2layer    ${UE_ID2}    PDU_ID=2    GW_ID=2
#     SA send dl and ul data    ${UE_ID}    number=2    dl_data=10M    ul_data=150M
#     SA send dl and ul data    ${UE_ID2}    number=2    dl_data=10M    ul_data=150M    pdu_id=2
# 	Wait '5s' for stabible
# 	run keyword and continue on failure    Check throughput
#     Start collect bip log
#     Start collect ttitrace
#     Wait for '4s' to stop ttitrace with name'tti'
#     Wait for '0s' to stop bip log with name'bip'
# 	#Check counter value
#     Detach '2' UE
#     Stop egate log and unzip with name'pair'
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     run keyword and continue on failure    check bler and pair is correct in ttitrace 
# 
# *** Keywords ***
# Wait time to stable
#     sleep    2s
# Prepare test
#     #Active GNB L2 feature debug traces
#     Modify l1bypass
#     Modify 8360 Swconfig
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 	
# check bler and pair is correct in ttitrace                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_B_case02.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     ${extra_modify}    create list
# 	#...    text|0|//enable_5GC002396
#     ...    text|26|//*[@TestProfile\="Profile-1"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|26|//*[@TestProfile\="Profile-1"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|26|//*[@TestProfile\="Profile-2"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|26|//*[@TestProfile\="Profile-2"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|0|//*[@TestProfile\="Profile-1"]//PuschTestParams//puschNumCountSwitchProfile
#     ...    text|0|//*[@TestProfile\="Profile-2"]//PuschTestParams//puschNumCountSwitchProfile
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex19}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex8}    ${Vindex0}
#     ...    srsNumCountSwitchProfile1=10    p1_rank=2    p2_rank=2    p1_sinr=26    p2_sinr=26
#     ...    extra_modify=${extra_modify}
# 
# Modify 8360 Swconfig
#     Add AP swconfig    0x70690:1
# 	Add GNB swconfig    0x58037C:1    
#     #Add GNB swconfig    @{Rdparameter}
# Check ue tput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    ${UE_ID2}    pdu_id=2
#     run keyword and continue on failure    Should be true    ${ul_tput1}+${ul_tput2}>250000
# Verify throughput
#      ${ue1_tp}=    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}     scell_id=0    type=pusch    tput_type=ave
#      ${ue2_tp}=    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}     scell_id=0    type=pusch    tput_type=ave    
#      should be true    ${ue1_tp}>200000
#      should be true    ${ue2_tp}>200000  
# Online change ulMaxMuMimoLayer to 4
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-2    ulMaxMuMimoLayer    4    online
#     Wait '2s' for stabible
#     TAF_ADMIN.teardown admin    connection=online
# counter value
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=4PAIR_UE     cell_id=1
# 	${PM_counter_value_Pcell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=4LAYER      cell_id=1
# 	${PM_counter_value_Pcell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=subset4LAYER    cell_id=1
#     should be true    ${PM_counter_value_Pcell}==2
# 	should be true    ${PM_counter_value_Pcell1}==2
# 	should be true    ${PM_counter_value_Pcell2}==2
# Check counter value
#     Wait until keyword succeeds    120s    30s    counter value			
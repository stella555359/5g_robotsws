# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang    SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# 
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_case02.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_case02.xml
# ${WTS_NAME}    case02.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${COMAVALUE}    ${CURDIR}/coma/case4.txt
# ${UE_ID}          1
# ${UE_ID2}          2
# ${X2_CMD}         enb_x2_link_up enb\=1 target\=2
# ${BIP_TAG}    srs
# ${FILTER}           uldata_puschreceivereq&&!(3gpp.rnti==65535)
# @{titles}   UlData.patternId_item
# @{Rdparameter}    0x58037C:1    0x58054D:1
# ${phr_override_profile_1_CMD}    phr_override_testmode_nr profile_id\=1 phr_mode\=Fixed phr_start\=2
# ...    phr_min\=2 phr_max\=40 phr_step_size\=1 phr_period\=20 pc_max\=30
# ${phr_activate_p1_CMD}    ue_testmode_set_nr id\=1,2,4 scell\=primary testmode\=phr_override profile_id\=1 action\=activate
# 				  
# *** Test Cases ***
# CB008360_A_B2c_case02_two_rank1_Ues_blindly_paired_and_MU_SINR_estimation
#     Prepare test
#     Prepare gnb onair
#     Wait '30s' for stabible
#     #Start WTS And Wait BTS Until Onair   ${WTS_NAME}  reload=${False}
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
# 	  Execute AP Command before attach
#     Attach LTE 2UE	
# 	  NSA send ue 100M UL data 100M DL data
#    	Start collect ttitrace
# 	  Wait for '1s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    check throughput
# 	check bler and pair is correct in ttitrace                   
#     Online change ulMuMimoSinrThd to 40
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'ttilowsinr'
#     Airphone NSA Detach    ${UE_ID}
#     Airphone NSA Detach    ${UE_ID_2}
#   	run keyword and continue on failure    airphone_cleanup_egate_console_log
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     check lowsinr in ttitrace                   
# 
# *** Keywords ***
# NSA send ue 100M UL data 100M DL data
#     airphone_execute_egate_command     trf_data_start ue\=1,2 id\=2 dir\=ul mbps\=100 trf_id\=1
# 	airphone_execute_egate_command     trf_data_start ue\=1,2 id\=2 dir\=dl mbps\=100 trf_id\=1
# Prepare test
#     #Active GNB L2 feature debug traces
#     Modify l1bypass
#     #Modify 8360 Swconfig
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# Verify throughput
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pusch    tput_type=ave
#     should_be_true    ${ul_throughput_pcell}>50000
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=8    type=pusch    tput_type=ave
#     should_be_true    ${ul_throughput_pcell}>50000	
# Wait '${time}' for stabible
#     sleep    ${time}
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${X2_CMD}
# Attach LTE 2UE
#     Airphone Nsa Attach    ${UE_ID}	
# 	Airphone Nsa Attach    ${UE_ID2}	
# check bler and pair is correct in ttitrace                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_case02.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# check lowsinr in ttitrace                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_case02_lowsinr.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 		
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     ${extra_modify}    create list
# 	...    text|1|//enable_5GC002396
#     ...    text|4|//*[@TestProfile\="Profile-1"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|4|//*[@TestProfile\="Profile-1"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|30|//*[@TestProfile\="Profile-2"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|30|//*[@TestProfile\="Profile-2"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|200|//*[@TestProfile\="Profile-1"]//PuschTestParams//puschNumCountSwitchProfile
#     ...    text|0|//*[@TestProfile\="Profile-2"]//PuschTestParams//puschNumCountSwitchProfile
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex1}    ${Vindex0}    ${Hindex1}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex6}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex8}    ${Vindex0}
#     ...    srsNumCountSwitchProfile1=200    p1_rank=1    p2_rank=1    p1_sinr=4    p2_sinr=30
#     ...    extra_modify=${extra_modify}
# 
# Modify 8360 Swconfig
#     Add AP swconfig    0x70690:1
# 	Add GNB swconfig    0x58037C:1  
#     #Add GNB swconfig    @{Rdparameter}
# Online change ulMuMimoSinrThd to ${value}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0   ulMuMimoSinrThd    ${value}    online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '10s' for stabible
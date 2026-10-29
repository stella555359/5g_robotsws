# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang     SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# 
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC8360_C_B3_case01_1116_100M.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_2subcell_case5.xml
# ${WTS_NAME}    wts_8360_C_case1.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${COMAVALUE}    ${CURDIR}/coma/case4.txt
# ${UE_TOTALNUM}    8
# ${UE_NUM}         8
# ${UE_ID}          1
# ${UE_ID2}          2
# ${UE_ID3}          3
# ${UE_ID4}          4
# ${UE_ID5}          5
# ${UE_ID6}          6
# ${UE_ID7}          7
# ${UE_ID8}          8
# ${SLICE_ID}       1
# ${EGATE_TAG}      egate
# *** Test Cases ***
# CB008360_C_B3_case01_CB006062_8_UEs_without_Aperiodic_CSI_TypeB
#     Prepare test
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Set multiue traffic type to internal
#     Attach '8' ue to 5g cell
# 	Airphone SA Start Data Traffic    1    UL    100M    pdu_id=1    duration=6000s
#     Internal send data
# 	run keyword and continue on failure    check throughput	
#     Start collect ttitrace
#     #Start collect bip log
# 	Wait for '2s' to stop ttitrace with name'ttifdmfalseinit'
# 	#Wait for '0s' to stop bip log with name'bip'
# 	run keyword and continue on failure    check bler and pair is correct in ttitrace1                    
#     Online change actUlDataDmrsFdm to true
# 	Online change ulDMRSAdditionalPosition
#     Online change actUlDataDmrsFdm to false
# 	DeRegister UE from '1' to '8'
# 	Collect AP egate log    ${EGATE_TAG}
# 	run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
# *** Keywords ***
# Prepare test
#     #Active GNB L2 feature debug traces
#     Modify l1bypass
#     Modify 8360 Swconfig
# Verify throughput
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID3}    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell3}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID4}    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell4}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID5}    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell5}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID6}    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell6}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID7}    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell7}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID8}    scell_id=0    type=pusch    tput_type=ave
#     should_be_true     ${ul_throughput_pcell1}+${ul_throughput_pcell2}+${ul_throughput_pcell3}+${ul_throughput_pcell4}+${ul_throughput_pcell5}
# 	...    +${ul_throughput_pcell6}+${ul_throughput_pcell7}>120000
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# Internal send data
#     : FOR    ${num}    IN RANGE    2    ${UE_NUM}+1
#     \    Airphone SA Start Data Traffic    ${num}    UL    7M    pdu_id=${num}    duration=6000s
#     \    ...    trf_id=${num}
#     #\    Wait '5s' for stabible
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     ${extra_modify}    create list
# 	#...    text|0|//enable_5GC002396
#     ...    text|4|//*[@TestProfile\="Profile-1"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|4|//*[@TestProfile\="Profile-1"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|26|//*[@TestProfile\="Profile-2"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|26|//*[@TestProfile\="Profile-2"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|0|//*[@TestProfile\="Profile-1"]//PuschTestParams//puschNumCountSwitchProfile
#     ...    text|0|//*[@TestProfile\="Profile-2"]//PuschTestParams//puschNumCountSwitchProfile
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex8}    ${Vindex0}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex8}    ${Vindex0}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex8}    ${Vindex0}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex8}    ${Vindex0}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex8}    ${Vindex0}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex8}    ${Vindex0}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex8}    ${Vindex0}    ${Hindex8}    ${Vindex0}
#     ...    srsNumCountSwitchProfile1=0    p1_rank=2    p2_rank=2    p1_sinr=26    p2_sinr=26
#     ...    extra_modify=${extra_modify}
# Modify 8360 Swconfig
#         Add AP swconfig    0x70690:1
# 	#control UE rank reported by pusch
# 	Add GNB swconfig    0x58037C:1
# 	#enble 8360-B
# 	#Add GNB swconfig    0x590192:1
# 	# enable_rdNewTddCellSlotModel of CB008940
# 	Add GNB swconfig    0x420062:1
# 	#enable simple reTx pair
# 	#Add GNB swconfig	 0x580550:1
# 	#enable rdactUlMuMimoEnhance
# 	Add GNB swconfig     0x58054F:1	
# Attach '${uenum}' ue to 5g cell
#     : FOR    ${num}    IN RANGE    1    ${uenum}+1
#     \    Airphone SA Attach    ue_id=${num}
#     \    Wait '2s' for stabible
#     \    Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}
#     \    Wait '3s' for stabible	
# 
# Set multiue traffic type to internal
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone Set Traffic Type    ${num}    ${num}    internal
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# Online change actUlDataDmrsFdm to true
#     Online recommissioning with delta json file    ${CURDIR}/JSON/delta_actUlDataDmrsFdm_true.json	
# 	Wait '30s' for stabible
# 	run keyword and continue on failure    check throughput	
#     Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'actUlDataDmrsFdmtrue'
# 	run keyword and continue on failure    check bler and pair is correct in ttitrace2
# Online change actUlDataDmrsFdm to false
#     Online recommissioning with delta json file    ${CURDIR}/JSON/delta_actUlDataDmrsFdm_false.json
# 	Wait '30s' for stabible
# 	run keyword and continue on failure    check throughput	
#     Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'actUlDataDmrsFdmfalse'	
# 	run keyword and continue on failure    check bler and pair is correct in ttitrace4
# Online change ulDMRSAdditionalPosition
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1    ulDMRSAdditionalPosition     One additional DMRS    online
#     TAF_ADMIN.teardown admin    connection=online   
# 	Wait '20s' for stabible
# 	run keyword and ignore error    airphone_execute_egate_command    	ue_deregister id\=1-8 by\=ue ue_deregister_type\=switch_off
# 	Attach '8' ue to 5g cell
# 	Airphone SA Start Data Traffic    1    UL    100M    pdu_id=1    duration=6000s
#     Internal send data
# 	Wait '5s' for stabible
# 	run keyword and continue on failure    check throughput	
#     Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'ulDMRSAdditionalPosition'
# 	run keyword and continue on failure    check bler and pair is correct in ttitrace3
# check bler and pair is correct in ttitrace1                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_C_case01_1.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All	
# check bler and pair is correct in ttitrace2                  
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_C_case01_6062on_2.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All		
# check bler and pair is correct in ttitrace3                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_C_case01_6062on_pos_3.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All	
# check bler and pair is correct in ttitrace4                  
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_C_case01_6062fdmfalse_4.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All		
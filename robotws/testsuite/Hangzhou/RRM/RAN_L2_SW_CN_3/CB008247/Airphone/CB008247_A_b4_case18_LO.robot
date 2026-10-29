# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_BO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# 
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8247_case18_LO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_1CELL_LO.xml
# ${WTS_NAME}    wts_1086_7_TAS_ue1_t2r4_nsa_LO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${COMAVALUE}    ${CURDIR}/coma/case18.txt
# ${UE_ID}          12
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${X2_CMD}         enb_x2_link_up enb\=1 target\=2
# ${DTX_CMD5}        ue_srs_beam_pos_nr profile_id\=3 srsMode\=fixed init_pos\=1
# ${DTX_CMD6}       ue_testmode_set_nr id\=12 testmode\=ue_srs_beam_pos action\=activate profile_id\=3
# ${DTX_CMD3}        cell_srs_beam_pos_nr profile_id\=1 num_of_ue_positions\=4 azimuth\=0,30,-30,60
# ${DTX_CMD4}       cell_testmode_set_nr cell_id\=1 gnb\=2 testmode\=cell_srs_beam_pos profile_id\=1 action\=activate
# ${DTX_CMD}        ue_srs_beam_pos_nr profile_id\=2 srsMode\=fixed init_pos\=1 dtx_start\=10 num_dtx\=50
# ${DTX_CMD1}       ue_testmode_set_nr id\=12 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
# ${SINR_1}         ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=50 noise_srs\=-1053
# ${SINR_2}         ue_testmode_set_nr id\=12 testmode\=ul_sinr action\=activate profile_id\=5
# ${DELETE}       ue_srs_beam_pos_nr profile_id\=2 delete=true
# ${BIP_TAG}    srs
# ${FILTER}           dldata_pdcchsendreq&&!(3gpp.rnti==65535)
# @{titles}   DlData_DciInfo.patternId_item
# 
# 				  
# *** Test Cases ***
# CB008247_A_b4_case18_CL_4x4_Single_UE_t2r4_adaptation_SRS_and_GOB_beam_NSA
#     Prepare test
#     Prepare gnb onair
#     #Start WTS And Wait BTS Until Onair   ${WTS_NAME}  reload=${False}
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
# 	airphone_execute_egate_command    ${SINR_1}
#     airphone_execute_egate_command    ${SINR_2}	
# 	Execute AP Command before attach
# 	Start collect ttitrace
# 	#airphone_execute_egate_command    ${DTX_CMD3}
#     #airphone_execute_egate_command    ${DTX_CMD4}
#     Attach LTE UE1
#     airphone_execute_egate_command    ${DTX_CMD5}
#   	airphone_execute_egate_command    ${DTX_CMD6}	
#     #Start collect bip log
#     airphone_execute_egate_command    ${DTX_CMD}
#   	airphone_execute_egate_command    ${DTX_CMD1}	
#     NSA send ue '${UE_ID}' mutiple trf '2' for each '175M' DL data
#    # Wait for '0s' to stop bip log with name'${BIP_TAG}'
# 	Wait for '0s' to stop ttitrace with name'tti'
# 	check throughput
# 	#airphone_execute_egate_command    ${DELETE}
#     Airphone NSA Detach    ${UE_ID}
# 	run keyword and continue on failure    airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
#     Stop capture gnb and ap syslog in 'after_onair' file
#     #check patter id is correct in bip
#     check bler is correct in ttitrace                    
#     
# 
# *** Keywords ***
# Prepare test
#     #Modify l1bypass
#     #pdcch dftbeam
#     Add GNB swconfig    0x580434:0
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>200000
# Wait '${time}' for stabible
#     sleep    ${time}
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${X2_CMD}
# 	Wait '2s' for stabible
# Attach LTE UE1
#     Airphone Nsa Attach    ${UE_ID}	
# check bler is correct in ttitrace                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case22.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for four profile eight ue
#     ...    ${Hindex0}    ${Vindex2}    ${Hindex10}    ${Vindex10}    ${Hindex0}    ${Vindex2}     ${Hindex10}    ${Vindex10}
#     ...    ${Hindex1}    ${Vindex0}    ${Hindex1}    ${Vindex0}    ${Hindex0}    ${Vindex1}     ${Hindex0}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex6}    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex1}     ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex8}    ${Vindex0}    ${Hindex0}    ${Vindex1}     ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex1}     ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex1}     ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex1}     ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex8}    ${Vindex0}    ${Hindex0}    ${Vindex1}     ${Hindex0}    ${Vindex0}
#     ...    srsNumCountSwitchProfile1=10    srsNumCountSwitchProfile2=40    srsNumCountSwitchProfile3=10    srsNumCountSwitchProfile4=40    
# 	...    p1_rank=2    p2_rank=2    p2_rank=2    p4_rank=2
# 
# check patter id is correct in bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_TAG}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/${BIP_TAG}/bip_case18.csv    ${FILTER}    ${titles}
#     Check Log With Au2anlysis    ${CURDIR}/ini/bip_case18_LO.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${BIP_TAG}	
# 

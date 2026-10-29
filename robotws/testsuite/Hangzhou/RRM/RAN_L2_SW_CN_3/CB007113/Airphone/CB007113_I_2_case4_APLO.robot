# *** Settings ***
# Test Timeout    80 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_changyli    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# ...   CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_7113_case4-80M_APLO.xml
# #${SCFC_NAME}      SCFC_7113_case4.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_3CELL_ABIO.xml
# ${COMAVALUE}    ${CURDIR}/coma/case4.txt
# ${WTS_NAME}    wts_7113_case04.cfg
# ${UE_ID}          1
# ${UE_ID2}          2
# ${UE_ID3}          3
# ${UE_ID4}          4
# ${UE_ID5}          5
# ${UE_ID6}          6
# ${UE_ID7}          7
# ${UE_ID8}          8
# #@{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:273    maxNumStreamPrbL1Sp:546    maxNumWbStreamPrbL1Sp:546
# #@{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:780    maxNumStreamPrbL1Sp:1560    maxNumWbStreamPrbL1Sp:780
# #@{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:546    maxNumStreamPrbL1Sp:1092    maxNumWbStreamPrbL1Sp:1092
# #@{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:1092    maxNumStreamPrbL1Sp:2184    maxNumWbStreamPrbL1Sp:1092
# #@{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:273    maxNumStreamPrbL1Sp:546    maxNumWbStreamPrbL1Sp:546
# #@{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:400    maxNumStreamPrbL1Sp:800    maxNumWbStreamPrbL1Sp:400
# #@{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:197    maxNumStreamPrbL1Sp:394    maxNumWbStreamPrbL1Sp:394
# #@{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:400    maxNumStreamPrbL1Sp:800    maxNumWbStreamPrbL1Sp:400
# @{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:197    maxNumStreamPrbL1Sp:394    maxNumWbStreamPrbL1Sp:394
# @{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:650    maxNumStreamPrbL1Sp:1300    maxNumWbStreamPrbL1Sp:650
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${par_of_bsr_name}       BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 
#    ...    step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 
#    ...    step\=5 trigger_puxch_update\=0
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 
#    ...    step\=5 trigger_puxch_update\=0
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 
#    ...    step\=5 trigger_puxch_update\=0
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 
#    ...    step\=5 trigger_puxch_update\=0
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 
#    ...    step\=5 trigger_puxch_update\=0
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 
#    ...    step\=5 trigger_puxch_update\=0
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 
#    ...    step\=5 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# #${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# 
# *** Test Cases ***
# CB007113_I_2_case4_MUMIMO_3layers_with_UL_PRB_pooling_activated_3rank1ue
#    step1:gnb ready for onair and check cellsetup log
#    step2:block cell2-3 attach 3UEs start full ul data and check logs
#    step3:unlock cell2-3 and check logs
#    step4:decrease low buffer to cell2-3
#    step5:attach UE6-7 to cell2-3 and check logs
#    step6:block cell2-3 and check logs
#    step7:unlock cell2-3 and decrease UE tput
#    step8:stop all UEs and capture logs
# 
# 
# *** Keywords ***
# step1:gnb ready for onair and check cellsetup log
#     Log To Console   \n-------------step1:get ready for gnb---------------
#     Prepare test
#     Get and Update BSR File    ${par_of_bsr_name}
#     Modify vendor file and full commission for onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
# 
# step2:block cell2-3 attach 3UEs start full ul data and check logs
#     Log To Console   \n-------------step2:block cell2-3 attach 3UEs start full ul data and check logs---------------
#     Block cell    51    gnb
#     Block cell    52    gnb
#     Attach UE from '${UE_ID}' to '${UE_ID3}' amd start full ul data
#     Wait '15s' for stabible
#     Start collect ttitrace    lcr_cell_id=50
#     Wait for '3s' to stop ttitrace with name'case4_lock'
#     check bler pair and prb in lock ttitrace
#     run keyword and continue on failure    Check SA UE throughput
#    # run keyword and continue on failure    check PM counter PRB_UL_MU_MIMO_3_PairUE_M55308C35008_1
#     #run keyword and continue on failure    check PM counter PRB_UL_MU_MIMO_3LAYER_M55308C35004_1
# 	run keyword and continue on failure    check PM counter PRB_UL_MU_MIMO_3_PairUE_M55308C35008_1
#     check PM counter PRB_UL_MU_MIMO_3LAYER_M55308C35004_1
# 
# step3:unlock cell2-3 and check logs
#     Log To Console   \n-------------step3:unlock cell2-3 and check logs---------------
#     Unblock cell    51    gnb
#     Unblock cell    52    gnb
#     Wait '5s' for stabible
#     Start collect ttitrace    lcr_cell_id=50
#     Wait for '2s' to stop ttitrace with name'case4_unlock'
#     check bler pair and prb in unlock ttitrace
#     run keyword and continue on failure    check lock prb
# 
#     airphone_execute_egate_command	ue_change_location cell\=2 id\=5
#     airphone_execute_egate_command	ue_change_location cell\=3 id\=6
# 
# 	Wait '2s' for stabible
# 
# 	Attach UE from '${UE_ID5}' to '${UE_ID6}' amd start full ul data
#     Wait '5s' for stabible
#     run keyword and continue on failure    Check SA UE throughput decrease
#     run keyword and continue on failure    Verify multi SA UEs throughput2
#     Start collect ttitrace    lcr_cell_id=50
#     Wait for '2s' to stop ttitrace with name'case4_bg2_high'
#     check bler pair and prb in bg2 high ttitrace
# #    run keyword and continue on failure    check PM counter PRB_UL_MU_MIMO_3_PairUE_M55308C35008_1
# #    run keyword and continue on failure    check PM counter PRB_UL_MU_MIMO_3LAYER_M55308C35004_1
# 
# step4:decrease low buffer to cell2-3
#     Log To Console   \n-------------step4:decrease low buffer to cell2-3---------------
#     send ue5toue6 low tput
#     run keyword and continue on failure    Check SA UE throughput increase
#     Start collect ttitrace    lcr_cell_id=50
#     Wait for '2s' to stop ttitrace with name'case4_bg2_low'
#     check bler pair and prb in bg2 low ttitrace
# 
# step5:attach UE6-7 to cell2-3 and check logs
#     Log To Console   \n-------------step5:attach UE6-7 to cell2-3 and check logs---------------
#     airphone_execute_egate_command	ue_change_location cell\=2 id\=7
#     airphone_execute_egate_command	ue_change_location cell\=3 id\=8
#     Wait '2s' for stabible
#     Attach UE from '${UE_ID7}' to '${UE_ID8}' amd start full ul data
# 
# 	send ue5toue6 high tput
# 	run keyword and continue on failure    Check SA UE throughput continue decrease
# 	Start collect ttitrace    lcr_cell_id=50
#     Wait for '3s' to stop ttitrace with name'case4_bg4'
#     check bler pair and prb in bg4 high ttitrace
#     run keyword and continue on failure    check PM counter PRB_UL_MU_MIMO_2_PairUE_M55308C35007_1
#     run keyword and continue on failure    check PM counter PRB_UL_MU_MIMO_2LAYER_M55308C35003_1
# 
# step6:block cell2-3 and check logs
#     Log To Console   \n-------------step6:block cell2-3 and check logs---------------
#     Block cell    51    gnb
#     Block cell    52    gnb
# 
#     Start collect ttitrace    lcr_cell_id=50
#     Wait for '3s' to stop ttitrace with name'case4_lock2'
#     check bler pair and prb in lock2 ttitrace
# 
# step7:unlock cell2-3 and decrease UE tput
#     Log To Console   \n-------------step7:unlock cell2-3 and decrease UE tput---------------
#     Unblock cell    51    gnb
#     Unblock cell    52    gnb
#     Wait '10s' for stabible
# 
#     send ue1toue3 low tput
# 
#     Start collect ttitrace    lcr_cell_id=50
#     Wait for '3s' to stop ttitrace with name'case4_unlock2'
#     check bler pair and prb in unlock2 ttitrace
# 
# step8:stop all UEs and capture logs
#     DeRegister UE from '1' to '3'
#     Stop egate log and unzip with name'pair'
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# Attach UE from '${lo}' to '${hi}' amd start full ul data
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id=${num}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '3s' for stabible
#     \   airphone_execute_egate_command    ${PROFILE${num}}
#     \   airphone_execute_egate_command    ${SET_PROFILE${num}}
#     \   Send SA UE high tput '${num}'
#     \   Wait '3s' for stabible
# 
# Prepare test
# #    Active GNB L2 feature debug traces
#     Add RD param
# 
# Add RD param
# #	Add GNB swconfig	 0x420068:6
# #	#act inter subpool
# #	Add GNB swconfig	 0x580612:1
# #
# #	#enable ADMIN developer
# #	Add GNB swconfig	 0x450027:1
# #	# Admin developement account
# #	Add GNB swconfig	 0x45000A:1
# 	Add GNB swconfig    0x9D0000:15
# 
# 
# Check ue tput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    ${UE_ID2}    pdu_id=2
#     ${dl_tput3}    ${ul_tput3}    Obtain one sa ue dl and ul throught    3    pdu_id=3
#     ${dl_tput4}    ${ul_tput4}    Obtain one sa ue dl and ul throught    4    pdu_id=4
#     should be true    ${ul_tput1}>25000
#     should be true    ${ul_tput2}>25000
#     should be true    ${ul_tput3}>25000
#     should be true    ${ul_tput4}>25000
# 
# Check SA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput
# 
# Verify multi SA UEs throughput
#     : FOR    ${num}    IN RANGE    1    3+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    
#    ...    scell_id=0    type=pusch    tput_type=ave
#     \    log to console    ${dl_throughput_pcell}
#     \    should be true    ${dl_throughput_pcell}>120000
# 
# Check SA UE throughput decrease
#     Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput decrease
# 
# Verify multi SA UEs throughput decrease
#     : FOR    ${num}    IN RANGE    1    3+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    
#    ...    scell_id=0    type=pusch    tput_type=ave
#     \    log to console    ${dl_throughput_pcell}
#     \    should be true    65<${dl_throughput_pcell}<105000
# 
# 
# Check SA UE throughput increase
#     Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput increase
# 
# Verify multi SA UEs throughput increase
#     : FOR    ${num}    IN RANGE    1    3+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    
#    ...    scell_id=0    type=pusch    tput_type=ave
#     \    log to console    ${dl_throughput_pcell}
#     \    should be true    90<${dl_throughput_pcell}<130000
# 
# 
# Check SA UE throughput continue decrease
#     Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput decrease
# 
# Verify multi SA UEs throughput continue decrease
#     : FOR    ${num}    IN RANGE    1    3+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    
#    ...    scell_id=0    type=pusch    tput_type=ave
#     \    log to console    ${dl_throughput_pcell}
#     \    should be true    30000<${dl_throughput_pcell}<70000
# 
# 
# Verify multi SA UEs throughput2
#     : FOR    ${num}    IN RANGE    5    5+2
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    
#    ...    scell_id=0    type=pusch    tput_type=ave
#     \    log to console    ${dl_throughput_pcell}
#     \    should be true    ${dl_throughput_pcell}>0
# 
# Check pair funcition is correct
#     Check Log With Au2anlysis    ${CURDIR}/ini/tti_case4.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Change ulMuMimoLinkAdaptionSwitch
#     Online change ulMuMimoLinkAdaptionSwitch to 'MCS compensation'
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'MCS_compensation'
#     run keyword and continue on failure    Check ue tput is correct
# 
# Online change ulMuMimoLinkAdaptionSwitch to '${value}'
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    ulMuMimoLinkAdaptionSwitch    
#    ...    ${value}    online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# Block cell
#     [Arguments]    ${phy_cell_id}    ${alias}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '
#    ...    ${nrcel.administrativeState}'=='Unlocked'    Run Keywords
#     \    ...    TAF_ADMIN.block    ${nrcel.id}    timeout=60    connection=${alias}
#     \    ...    AND    sleep    60
#     TAF_ADMIN.teardown    connection=${alias}
# 
# Unblock cell
#     [Arguments]    ${phy_cell_id}    ${alias}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}'    Run Keywords    TAF_ADMIN.unblock    
#    ...    ${nrcel.id}    timeout=60
#     \    ...    connection=${alias}
#     \    ...    AND    sleep    60
#     TAF_ADMIN.teardown    connection=${alias}
# 
# check bler pair and prb in lock ttitrace
#     run keyword and continue on failure    check_log_with_au2anlysis    
#    ...    ini_path=${CURDIR}/ini/tti_case4_lock.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     run keyword and continue on failure    7113_check_file.Check 7113 Cell Rachslot    
#    ...     ${TEST_LOG_DIRECTORY()}/All/case4_lock_ul.csv    50    19
# 
# check bler pair and prb in unlock ttitrace
#     run keyword and continue on failure    check_log_with_au2anlysis    
#    ...    ini_path=${CURDIR}/ini/tti_case4_unlock.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     run keyword and continue on failure    7113_check_file.Check 7113 Cell Rachslot     
#    ...    ${TEST_LOG_DIRECTORY()}/All/case4_unlock_ul.csv    50    19
# 
# check bler pair and prb in bg2 high ttitrace
#     run keyword and continue on failure    check_log_with_au2anlysis    
#    ...    ini_path=${CURDIR}/ini/tti_case4_bg2_high.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     run keyword and continue on failure    7113_check_file.Check 7113 Cell Rachslot     
#    ...    ${TEST_LOG_DIRECTORY()}/All/case4_bg2_high_ul.csv    50    19
# 
# check bler pair and prb in bg2 low ttitrace
#     run keyword and continue on failure    check_log_with_au2anlysis   
#    ...    ini_path=${CURDIR}/ini/tti_case4_bg2_low.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     run keyword and continue on failure    7113_check_file.Check 7113 Cell Rachslot     
#    ...    ${TEST_LOG_DIRECTORY()}/All/case4_bg2_low_ul.csv    50    19
# 
# 
# check bler pair and prb in bg4 high ttitrace
#     run keyword and continue on failure    check_log_with_au2anlysis    
#    ...    ini_path=${CURDIR}/ini/tti_case4_bg4.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     run keyword and continue on failure    7113_check_file.Check 7113 Cell Rachslot     
#    ...    ${TEST_LOG_DIRECTORY()}/All/case4_bg4_ul.csv    50    19
# 
# check bler pair and prb in lock2 ttitrace
#     run keyword and continue on failure    check_log_with_au2anlysis    
#    ...    ini_path=${CURDIR}/ini/tti_case4_lock.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     run keyword and continue on failure    7113_check_file.Check 7113 Cell Rachslot     
#    ...    ${TEST_LOG_DIRECTORY()}/All/case4_lock2_ul.csv    50    19
# 
# check bler pair and prb in unlock2 ttitrace
#     run keyword and continue on failure    check_log_with_au2anlysis    
#    ...    ini_path=${CURDIR}/ini/tti_case4_unlock2.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# #    run keyword and continue on failure    7113_check_file.Check 7113 Cell Rachslot    
#    ...     ${TEST_LOG_DIRECTORY()}/All/case4_unlock2_ul.csv    50    19
# 
# send ue1toue3 high tput
#     SA send mutiple trf ul data    1    number=1    ul_data=160M
# 	Wait '1s' for stabible
#     SA send mutiple trf ul data    2    number=1    ul_data=160M    pdu_id=2
# 	Wait '1s' for stabible
#     SA send mutiple trf ul data    3    number=1    ul_data=160M    pdu_id=3
# 	Wait '5s' for stabible
# 
# Send SA UE high tput '${UE_ID}'
#     SA send mutiple trf ul data    ${UE_ID}    number=1    ul_data=160M    pdu_id=${UE_ID}
# 	Wait '1s' for stabible
# 
# send ue1toue3 low tput
#     SA send mutiple trf ul data    1    number=1    ul_data=10M
# 	Wait '1s' for stabible
#     SA send mutiple trf ul data    2    number=1    ul_data=10M    pdu_id=2
# 	Wait '1s' for stabible
#     SA send mutiple trf ul data   3    number=1    ul_data=10M    pdu_id=3
# 	Wait '5s' for stabible
# 
# send ue5toue6 high tput
#     SA send mutiple trf ul data   5    number=1    ul_data=160M    pdu_id=5
# 	Wait '1s' for stabible
#     SA send mutiple trf ul data    6    number=1   ul_data=160M    pdu_id=6
#     Wait '5s' for stabible
# 
# send ue5toue6 low tput
#     SA send mutiple trf ul data    5    number=1    ul_data=1M    pdu_id=5
# 	Wait '1s' for stabible
#     SA send mutiple trf ul data    6    number=1    ul_data=1M    pdu_id=6
#     Wait '5s' for stabible
# 
# send ue7toue8 high tput
#     SA send mutiple trf ul data    7    number=1    ul_data=160M    pdu_id=7
# 	Wait '1s' for stabible
#     SA send mutiple trf ul data    8    number=1    ul_data=160M    pdu_id=8
#     Wait '5s' for stabible
# 
# check lock prb
#     ${lock_alloc_prb}    read_csv_columns    ${test_log_directory()}/All/case4_lock_ul.csv
#     ...   ulAllocatedPooledResourcesData.numAllocCellPrbUl    filter=physCellId=50
#     ${unlock_alloc_prb1}    read_csv_columns    ${test_log_directory()}/All/case4_unlock_ul.csv
#     ...   ulAllocatedPooledResourcesData.numAllocCellPrbUl    filter=physCellId=51
#     ${unlock_alloc_prb2}    read_csv_columns    ${test_log_directory()}/All/case4_unlock_ul.csv
#     ...   ulAllocatedPooledResourcesData.numAllocCellPrbUl    filter=physCellId=52
#     ${lock_alloc_prb2}    read_csv_columns    ${test_log_directory()}/All/case4_unlock_ul.csv
#     ...   ulAllocatedPooledResourcesData.numAllocCellPrbUl    filter=physCellId=50
#     ${unlock_prb}    evaluate    ${unlock_alloc_prb1}[0]+${unlock_alloc_prb2}[0] +${lock_alloc_prb2}[0]
#     Should Be True    ${lock_alloc_prb}[0]<=${unlock_prb}
#     Should Be True    ${lock_alloc_prb}[0]>${lock_alloc_prb2}[0]
# 
# check counter value
#     Wait until keyword succeeds    180s    30s    check prb counter
# 
# check prb counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${CURDIR}${/}
#     ${PM_counter_10002}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10002    cell_id=1
#     ${PM_counter_10006}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10006    cell_id=1
#     ${value}    Evaluate    float(${PM_counter_10002})/float(${PM_counter_10006})
#     should be true    ${value}>0.9
#     should be true    ${value}<1.1
# 
# check PM counter PRB_UL_MU_MIMO_2LAYER_M55308C35003_1
# 	Check pm counter M55308C35003 in cell 1 is expected > 0
# 
# check PM counter PRB_UL_MU_MIMO_3LAYER_M55308C35004_1
# 	Check pm counter M55308C35004 in cell 1 is expected > 0
# 
# check PM counter PRB_UL_MU_MIMO_2_PairUE_M55308C35007_1
# 	Check pm counter M55308C35007 in cell 1 is expected > 0
# 
# check PM counter PRB_UL_MU_MIMO_3_PairUE_M55308C35008_1
# 	Check pm counter M55308C35008 in cell 1 is expected > 0
# 
# Check pm counter ${counter} in cell ${cell_id} is expected ${symbol} ${expected_value}
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${cpath}    set variable    ${test_log_directory()}/All/counter_${counter}/
#     ${counter_value}    Get pm counter value    ${counter}    ${cell_id}    ${cpath}
#     should be true    ${counter_value} ${symbol} ${expected_value}
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \	Log To Console   ${\n}deRegister UE${num}
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
# 
# Set 1-3UEs different pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE1}
#      airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE3}
# 
# Set 5-6UEs different pos
#     airphone_execute_egate_command    ${PROFILE5}
#     airphone_execute_egate_command    ${SET_PROFILE5}
#     airphone_execute_egate_command    ${PROFILE6}
#     airphone_execute_egate_command    ${SET_PROFILE6}
# 
# Set 7-8UEs different pos
#     airphone_execute_egate_command    ${PROFILE7}
#     airphone_execute_egate_command    ${SET_PROFILE7}
#     airphone_execute_egate_command    ${PROFILE8}
#     airphone_execute_egate_command    ${SET_PROFILE8}

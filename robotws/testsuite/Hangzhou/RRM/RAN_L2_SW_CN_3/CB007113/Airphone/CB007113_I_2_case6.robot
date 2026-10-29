# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G   owner_l10wang		SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${COMAVALUE}    ${CURDIR}/coma/case4.txt
# ${SCFC_NAME}    SCFC_CB007113_case6.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_3CELL.xml
# ${VENDOR_XML}    vendor.xml
# ${L1BYP_XML}    L1By_7113_I_case789.xml	
# ${WTS_NAME}    3cell_ue1layer.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# @{VENDOR_PARAMETER_C32}    maxNumLayerPrbL1Sp:528    maxNumStreamPrbL1Sp:692
# @{VENDOR_PARAMETER_C64}    maxNumLayerPrbL1Sp:428    maxNumStreamPrbL1Sp:900
# ${UE_NUM}        6
# ${UE_ID1}          1
# ${UE_ID2}          2
# *** Test Cases ***
# CB007113_I_2_case6_MUMIMO_3layers_with_UL_PRB_pooling_activated_1rank2ue_1rank1ue
#     Modify l1bypass
# 	Add RD param
# 	Modify vendor file and full commission for onair
# 	Start capture gnb and ap syslog in '1' file
#     Set multiue traffic type to internal
#     Attach Rank2 UE and Rank1 UE to cell1
#     Attach UE3 and UE4 to cell2 and cell3
#     Attach UE7 and UE8 to cell2 and cell3
#     Block Cell2 and Cell3
# 	Stop capture gnb and ap syslog in '1' file
# 	
# *** Keywords ***
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     ${extra_modify}    create list
#     ...    text|28|//*[@TestProfile\="Profile-1"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|28|//*[@TestProfile\="Profile-1"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|28|//*[@TestProfile\="Profile-2"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|28|//*[@TestProfile\="Profile-2"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|0|//*[@TestProfile\="Profile-1"]//PuschTestParams//puschNumCountSwitchProfile
#     ...    text|0|//*[@TestProfile\="Profile-2"]//PuschTestParams//puschNumCountSwitchProfile
#     ...    text|16|//ComaMultiplier
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex10}    ${Vindex9}    ${Hindex9}    ${Vindex8}
#     ...    ${Hindex12}    ${Vindex6}    ${Hindex8}    ${Vindex3}
#     ...    ${Hindex17}    ${Vindex6}    ${Hindex17}    ${Vindex6}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex24}    ${Vindex9}
# #    ...    ${Hindex0}    ${Vindex0}    ${Hindex9}    ${Vindex8}
# #    ...    ${Hindex5}    ${Vindex0}    ${Hindex8}    ${Vindex3}
# #    ...    ${Hindex6}    ${Vindex4}    ${Hindex17}    ${Vindex6}
# #    ...    ${Hindex10}    ${Vindex8}    ${Hindex24}    ${Vindex9}
#     ...    ${Hindex9}    ${Vindex8}    ${Hindex24}    ${Vindex9}
#     ...    ${Hindex8}    ${Vindex3}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex6}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex8}    ${Vindex0}
#     ...    srsNumCountSwitchProfile1=0    p1_rank=1    p2_rank=1    p1_sinr=33    p2_sinr=33
#     ...    extra_modify=${extra_modify}
# Add RD param
#    Add AP swconfig    0x1003F:2
#    Add AP swconfig    0x10042:0xC0A8C87E
#    Add GNB swconfig    0x420068:6 # rdTddPoolingFeaturesEnable
#    Add GNB swconfig    0x580612:1
#    Add GNB swconfig    0x340000:15
#    #Add GNB swconfig    0x58054D:8
#    #enable ADMIN developer
#    Add GNB swconfig     0x450027:1
#    #Admin developement account
#    Add GNB swconfig     0x45000A:1
# 
# Set multiue traffic type to internal
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone Set Traffic Type    ${num}    ${num}    internal
# 
# Attach UE '${ue_id}' to cell '${cell_id}'
#     airphone_execute_egate_command	ue_change_location cell\=${cell_id} id\=${ue_id}
#     Airphone SA Attach    ue_id=${ue_id}
#     Airphone Set Traffic Type    ${ue_id}    ${ue_id}    internal
#     Wait '5s' for stabible
#     Airphone Pdu Session Setup   ${ue_id}    ${ue_id}    1    ${ue_id}
#     Wait '5s' for stabible
# 
# Attach Rank2 UE and Rank1 UE to cell1
#     Block cell    51    gnb
#     Block cell    52    gnb
#     Wait '5s' for stabible
#     Attach UE '1' to cell '1'
#     #Attach UE '4' to cell '1'
#     Attach UE '5' to cell '1'
#     Airphone SA Start Data Traffic    1    UL   10M   pdu_id=1   duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    5    UL   10M   pdu_id=5  duration=7200   trf_id=1
#     Wait '5s' for stabible
#     Start collect ttitrace     50
# 	Wait for '3s' to stop ttitrace with name'block_tti1_lowtp'
# 	${ul_throughput_pcell_ue1}    airphone_get_throughput_on_specific_scell    1    0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell_ue5}    airphone_get_throughput_on_specific_scell    5    0    type=pusch    tput_type=ave
#     #Check ttitrace for UE No Pair for RequiredPrb lessthan availablePrb
#     Airphone SA Start Data Traffic    1    UL   175M   pdu_id=1   duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    5    UL   175M   pdu_id=5  duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    5    UL   175M   pdu_id=5  duration=7200   trf_id=2
#     Wait '5s' for stabible
#     Start collect ttitrace     50
# 	Wait for '3s' to stop ttitrace with name'block_tti1_fulltp'
#     ${ul_throughput_pcell_ue1}    airphone_get_throughput_on_specific_scell    1    0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell_ue5}    airphone_get_throughput_on_specific_scell    5    0    type=pusch    tput_type=ave
#     #run keyword and continue on failure    check_7113_cell_rachslot     ${TEST_LOG_DIRECTORY()}/All/block_tti1_fulltp_ul.csv       50      19
#     Unblock cell    51    gnb
#     Unblock cell    52    gnb
#     Wait '5s' for stabible
#     ${ul_throughput_pcell_ue1}    airphone_get_throughput_on_specific_scell    1    0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell_ue5}    airphone_get_throughput_on_specific_scell    5    0    type=pusch    tput_type=ave
#     Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'unblock_tti1_fulltp'
# 	#run keyword and continue on failure    check_7113_cell_rachslot     ${TEST_LOG_DIRECTORY()}/All/unblock_tti1_fulltp_ul.csv       50      19
# 
# 
# Check ttitrace for UE No Pair for RequiredPrb lessthan availablePrb
# 	Check Log With Au2anlysis    ${CURDIR}/ini/block_tti1_lowtp.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# Check ttitrace for UE Pair for RequiredPrb morethan availablePrb
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/block_tti1_fulltp.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
# 	${PRB_UL_MU_MIMO_3LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C35004    cell_id=1
#     run keyword and continue on failure    should_be_true     ${PRB_UL_MU_MIMO_3LAYER}>0
#     ${PRB_UL_MU_MIMO_2PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C35007    cell_id=1
#     run keyword and continue on failure    should_be_true     ${PRB_UL_MU_MIMO_2PAIR_UE}>0
# Check ttitrace for UE Pair for unblock cell2 and cell3
#     	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/unblock_tti1_fulltp.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Attach UE3 and UE4 to cell2 and cell3
#     #Attach UE '6' to cell '1'
#     Attach UE '2' to cell '2'
#     Attach UE '3' to cell '3'
#     #Attach UE '7' to cell '2'
# 	#Attach UE '8' to cell '3'
# 	Airphone SA Start Data Traffic    2    UL   175M   pdu_id=2   duration=7200   trf_id=1
# 	Airphone SA Start Data Traffic    3    UL   175M   pdu_id=3   duration=7200   trf_id=1
# 	#Airphone SA Start Data Traffic    7    UL   175M   pdu_id=7   duration=7200   trf_id=1
# 	#Airphone SA Start Data Traffic    8    UL   175M   pdu_id=8   duration=7200   trf_id=1
# 	Wait '5s' for stabible
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=1    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=5    scell_id=0    type=pusch    tput_type=ave
#     Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'unblock_tti2_fulltp'
#     #check_7113_cell_rachslot     ${TEST_LOG_DIRECTORY()}/All/unblock_tti2_fulltp_ul.csv       50      19
#     Airphone SA Start Data Traffic    1    UL   20M   pdu_id=1   duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    5    UL   10M   pdu_id=5  duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    5    UL   10M   pdu_id=5  duration=7200   trf_id=2
#     Wait '5s' for stabible
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=1    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=5    scell_id=0    type=pusch    tput_type=ave
#     Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'unblock_tti2_lowtp'
# 	#Check ttitrace for UE NoPair with cell2 and cell3 low tp
# 
# 
# 
# Attach UE7 and UE8 to cell2 and cell3
#     Attach UE '7' to cell '2'
# 	Attach UE '8' to cell '3'
# 	Airphone SA Start Data Traffic    1    UL   160M   pdu_id=1   duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    5    UL   160M   pdu_id=5  duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    5    UL   160M   pdu_id=5  duration=7200   trf_id=2
#     Airphone SA Start Data Traffic    7    UL   175M   pdu_id=7   duration=7200   trf_id=1
# 	Airphone SA Start Data Traffic    8    UL   175M   pdu_id=8   duration=7200   trf_id=1
# 	Wait '5s' for stabible
# 	${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=1    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=5    scell_id=0    type=pusch    tput_type=ave
#     Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'unblock_tti3_fulltp'
# 	#check_7113_cell_rachslot     ${TEST_LOG_DIRECTORY()}/All/unblock_tti3_fulltp_ul.csv       50      19
# 	Airphone SA Start Data Traffic    1    UL   20M   pdu_id=1   duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    5    UL   10M   pdu_id=5  duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    5    UL   10M   pdu_id=5  duration=7200   trf_id=2
#     Wait '5s' for stabible
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=1    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=5    scell_id=0    type=pusch    tput_type=ave
#     Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'unblock_tti3_lowtp'
# 	Attach UE '4' to cell '1'
# 	Airphone SA Start Data Traffic    4   UL   175M   pdu_id=4   duration=7200   trf_id=1
# 	Airphone SA Start Data Traffic    1    UL   160M   pdu_id=1   duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    5    UL   160M   pdu_id=5  duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    5    UL   160M   pdu_id=5  duration=7200   trf_id=2
# 	Wait '5s' for stabible
# 	${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=1    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=5    scell_id=0    type=pusch    tput_type=ave
#     Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'unblock_tti3_fulltp_moreue'
# 	#check_7113_cell_rachslot     ${TEST_LOG_DIRECTORY()}/All/unblock_tti3_fulltp_moreue_ul.csv       50      19
# 
# Block Cell2 and Cell3
#     Block cell    51    gnb
#     Block cell    52    gnb
#     Wait '5s' for stabible
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=1    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=5    scell_id=0    type=pusch    tput_type=ave
#     Start collect ttitrace     50
# 	Wait for '3s' to stop ttitrace with name'block_tti4_fulltp'
# 	#check_7113_cell_rachslot     ${TEST_LOG_DIRECTORY()}/All/block_tti4_fulltp_ul.csv       50      19
#     Airphone SA Start Data Traffic    1    UL   30M   pdu_id=1   duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    4   UL   30M   pdu_id=4   duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    5    UL   15M   pdu_id=5  duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    5    UL   15M   pdu_id=5  duration=7200   trf_id=2
#     Start collect ttitrace     50
# 	Wait for '3s' to stop ttitrace with name'block_tti4_middletp'
# 	#check_7113_cell_rachslot     ${TEST_LOG_DIRECTORY()}/All/block_tti4_middletp_ul.csv       50      19
# 	Unblock cell    51    gnb
# 	Unblock cell    52    gnb
# Check ttitrace for UE Pair with cell2 and cell3 full tp
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/unblock_tti2_fulltp.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# Check ttitrace for UE NoPair with cell2 and cell3 low tp
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/unblock_tti2_lowtp.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# Check ttitrace for UE No Pair
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/unblock_tti3_fulltp.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# Check ttitrace for UE Pair
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/block_tti4_fulltp.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# Check 2 rank1 UEs pair for US2
#      run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/unblock_tti3_fulltp_moreue.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# Send UL data for multiUE '${ue}' to ${ue_num}
#     :FOR    ${ue}    IN RANGE    1    ${ue_num}+1
#     \    Airphone SA Start Data Traffic    ${ue}    UL   160M   pdu_id=${ue}   duration=7200   trf_id=1
#     \    Airphone SA Start Data Traffic    ${ue}    UL   160M   pdu_id=${ue}   duration=7200   trf_id=2
#     Wait '5s' for stabible
# Verify throughput
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pusch    tput_type=ave
# 
# 
# Block cell
#     [Arguments]    ${phy_cell_id}    ${alias}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Unlocked'    Run Keywords
#     \    ...    TAF_ADMIN.block    ${nrcel.id}    timeout=60    connection=${alias}
#     \    ...    AND    sleep    60
#     TAF_ADMIN.teardown    connection=${alias}
# 
# Unblock cell
#     [Arguments]    ${phy_cell_id}    ${alias}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}'    Run Keywords    TAF_ADMIN.unblock    ${nrcel.id}    timeout=60
#     \    ...    connection=${alias}
#     \    ...    AND    sleep    60
#     TAF_ADMIN.teardown    connection=${alias}
# 
# 
# 
#     
# get UE '${ue_id}' rnti in RRC log
#     Log To Console   ${\n}===get UE'${ue_id}' rnti===
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
# 
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   crnti: (\\d+)
#     run keyword if    ${ue_id}==1   Set test Variable	 ${rnti_1} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==2   Set test Variable	 ${rnti_2} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==3   Set test Variable	 ${rnti_3} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==4   Set test Variable	 ${rnti_4} 	${rnti_list[0]}
# 

# *** Settings ***
# Suite Setup    common suite setup
# Suite Teardown    common suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    LTE2068    CLOUD_R4A_CUS    CIT    CDRT
# ...    wennan.deng@nokia-sbell.com
# #Resource          ${CURDIR}/../../../../../resource/ET/SG11/common_resource_ABIO.robot
# Resource          ${CURDIR}/../../resources/KISS/robot/common_resource_ABIO.robot
# Library     ta_kiss_enb_ttitrace
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config/
# ${scfc_name}   SCFC_1.xml
# ${cus_yaml}    cus.yaml
# ${category_9_4Layer}     C9BFF041034410381FF834620000A006A30307A000107A0001241E800041E80004107A000107A0001240E80104D3FC00000164280200
# ${cat_R12}    
#    ...    D1BFF441A010102013F834627000A617E2A307060740002003D000080D01000E80004803A00413018100804023E7D00000BF58010020478CBCD2440B907F34053C00081C
# ${inactivityTimer}    text|3000|//*[@name\="inactivityTimer"]
# @{earfcn}    text|40742|//*[contains(@distName, 'LNCEL-1')]/*[@name='earfcn']    text|40940|//*[contains(@distName, 'LNCEL-2')]/*[@name='earfcn']
# ...    text|41138|//*[contains(@distName, 'LNCEL-3')]/*[@name='earfcn']
# @{tdd_configuration}    text|2|//*[@name\="tddFrameConf"]    text|7|//*[@name\="tddSpecSubfConf"]    
# ${TM_mode}    text|Closed Loop MIMO (8x4)|//*[@name\="dlMimoMode"]
# ${FastMimoSwitch}    text|true|//*[@name\="actFastMimoSwitch"]
# ${RIenable}    text|true|//*[@name\="riEnable"]
# @{prachFreqOff}    text|11|//*[@name\="prachFreqOff"]    text|6|//*[@name\="prachConfIndex"]    text|2|//*[@name\="siMessageRepetition"]
# ...    text|40ms|//*[@name\="siWindowLen"]
# ${mbrSelector}    text|ueCapability|//*[@name\="mbrSelector"]
# @{dlSectorBFWeight}    text|100|//*[@name\="modulusOfWeighforAntGrp0"]    text|50|//*[@name\="modulusOfWeighforAntGrp1"]
# ...    text|100|//*[@name\="modulusOfWeighforAntGrp2"]    text|50|//*[@name\="modulusOfWeighforAntGrp3"]
# ...    text|customized profile 1|//*[@name\="dlSectorBFWeightProfName"]    text|0|//*[@name\="phaseOfWeighforAntGrp0"]
# ...    text|180|//*[@name\="phaseOfWeighforAntGrp1"]
# ...    text|0|//*[@name\="phaseOfWeighforAntGrp2"]    text|180|//*[@name\="phaseOfWeighforAntGrp3"]
# @{riSet}    text|1|//*[@name\="riPerM"]    text|-1|//*[@name\="riPerOffset"]
# @{UL_CarAggr}    text|UL_CA_with_smartSched|//*[@name\="actULCAggr"]    text|blind|//*[@name\="sCellActivationMethod"]
# ...    text|infinity|//*[@name\="sCellDeactivationTimereNB"]    text|0.001s|//*[@name\="sCellActivationCyclePeriod"]
# @{modify_list}    ${inactivityTimer}    @{earfcn}    @{tdd_configuration}    ${TM_mode}    ${FastMimoSwitch}    ${RIenable}    ${mbrSelector}
# ...    @{dlSectorBFWeight}    @{riSet}    @{prachFreqOff}   @{UL_CarAggr}
# ${swconfig_path}    ${CURDIR}/swconfig.txt
# 
# *** Test Cases ***
# LTE2068-A-c-01_Fast_Adaptive_MIMO_Switch_up_to_Four_Layers_in_TM9_Closed_Loop
#     [Tags]    QC_22696
#     Step1:The eNB is configured with 'Closed Loop MIMO 8x4' and OnAir
#     Step2:4Layer UE attach,verify no scell added and TM9
#     Step3:Push THP from all UE
#     Step4:override 4Layer UE RI to 4
#     Step5:override 4Layer UE RI to 2
#     Step6:check_4layer_PM_counter
# 
# *** Keywords ***
# Step1:The eNB is configured with 'Closed Loop MIMO 8x4' and OnAir
#     Start enb and cus syslog'1'
#     Establish cell with bandwidth 20M 2 7 dl continuous
#     Stop and collect enb and cus syslog
#     collect procotol log '1' from egate
# 
# Establish cell with bandwidth 20M 2 7 dl continuous
#     ${scfc_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}scfc.xml
#     ${cus_yaml_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}cus_1.yaml
#     copy_file    ${CONFIG_DIR_PATH}/${scfc_name}    ${scfc_path}
#     copy_file    ${CONFIG_DIR_PATH}/${cus_yaml}    ${cus_yaml_path}
#     Modify SCFC into 3cc CA    ${scfc_path}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Load CUS config Files And Wait BTS Onair    ${scfc_path}    ${cus_yaml_path}    enb_swconfig=${eNB_swconfig_path}
#     
# Step2:4Layer UE attach,verify no scell added and TM9
#     Start enb and cus syslog'2'
#     #start_capture_ttitrace'2'
#     Run UEx command    ue_attach    id=1    ue_eutra_capabilities=${cat_R12}    cell=1
#     #iphy_create_bearer                           ue_id_list=1     bearer_id_list=2
#     #run_keyword_and_ignore_error    Run UEx command    bearer_add    ue=1    qci=1    mbr_ul=31    mbr_dl=31    gbr_ul=31    gbr_dl=31
#     #run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1    qci=8    kbps=80000    trf_id=1    dir=dl    protocol=udp
#     #run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1    qci=1    kbps=1000    trf_id=1    dir=ul    protocol=udp
#     wait_throughput_stable   20s
#     #${ue1_ul_qci1_throughput}                    cus_get_ul_throughput_ave        ue_id=1    type=ul_mac
#     #${ue1_dl_bear1_throughput}                   cus_get_dl_throughput_ave        ue_id=1    type=dl_mac
#     #Save_and_Decode_ttitrace_'2'
#     Stop and collect enb and cus syslog
#     collect procotol log '2' from egate
# 
# Step3:Push THP from all UE
#     #start_capture_ttitrace'3'
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1    qci=8    kbps=100000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1    qci=8    kbps=100000    trf_id=2    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1    qci=8    kbps=100000    trf_id=3    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1    qci=8    kbps=50000    trf_id=1    dir=ul    protocol=udp    
#     wait_throughput_stable    10s
#     ${ue1_dl_throughput}    cus_get_dl_throughput_ave    ue_id=1    type=dl_mac
#     ${ue1_ul_throughput}    cus_get_ul_throughput_ave    ue_id=1    type=ul_mac 
#     #Save_and_Decode_ttitrace_'3'
#     run_keyword_and_ignore_error    should_be_true    ${ue1_dl_throughput}>=270000
#     run_keyword_and_ignore_error    should_be_true    ${ue1_ul_throughput}>=7400    
# 
# Step4:override 4Layer UE RI to 4
#     #start_capture_ttitrace'4'
#     #Attach assign number single_UE'2' of category'${category_9_4Layer}' into cell'1'
#     Run UEx command    ue_attach    id=2    ue_eutra_capabilities=${category_9_4Layer}    cell=1
#     wait_throughput_stable    10s
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=2    qci=8    kbps=100000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=2    qci=8    kbps=100000    trf_id=2    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=2    qci=8    kbps=100000    trf_id=3    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=2    qci=8    kbps=50000    trf_id=1    dir=ul    protocol=udp
#     #run_keyword_and_ignore_error    run_uex_command    trf_data_start ue\=2 id\=1 dir\=dl mbps\=175 trf_id\=1 seconds\=60000
#     #run_keyword_and_ignore_error    run_uex_command    trf_data_start ue\=2 id\=1 dir\=dl mbps\=175 trf_id\=2 seconds\=60000	
#     #run_keyword_and_ignore_error    run_uex_command    trf_data_start ue\=2 id\=1 dir\=dl mbps\=175 trf_id\=3 seconds\=60000    
#     #run_keyword_and_ignore_error    run_uex_command    trf_data_start ue\=2 id\=1 dir\=ul mbps\=50 trf_id\=1 seconds\=60000    
#     run_keyword_and_ignore_error    run_uex_command    ue_cqi_param    id=2    rank=4    scell=0,1,2
#     wait_throughput_stable    10
#     ${ue1_dl_throughput_1}    cus_get_dl_throughput_ave    ue_id=2    type=dl_mac
#     ${ue1_ul_throughput}    cus_get_ul_throughput_ave    ue_id=2    type=ul_mac
#     #${ue1_dl_throughput_2}    iphy_get_throughput_on_specific_scell    ue_id=1    direction=dl    scell_id=0
#     #${ue1_dl_throughput_2}    cus_get_throughput_on_specific_scell    ue_id=1    direction=dl    scell_id=0
#     #Save_and_Decode_ttitrace_'4'    
#         
# Step5:override 4Layer UE RI to 2    
#     #start_capture_ttitrace'5'        
#     run_keyword_and_ignore_error    run_uex_command    ue_cqi_param    id=2    rank=2    scell=0,1,2
#     wait_throughput_stable    10
#     ${ue1_dl_throughput}    cus_get_dl_throughput_ave    ue_id=1    type=dl_mac
#     ${ue1_ul_throughput}    cus_get_ul_throughput_ave    ue_id=1    type=ul_mac
#     #Save_and_Decode_ttitrace_'5'        
# 
# Step6:check_4layer_PM_counter
#     : FOR    ${times}    IN RANGE    1    0    -1    
#     #\    ${remain_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     \    ${remain_time}=    get_counter_file_remaining_time    
#     \    set test variable    ${remain_time}    
#     \    run_uex_command    ue_cqi_param    id=2    rank=1    scell=0,1,2
#     \    wait_throughput_stable    10s
#     \    run_uex_command    ue_cqi_param    id=2    rank=2    scell=0,1,2
#     \    wait_throughput_stable    10s
#     \    run_uex_command    ue_cqi_param    id=2    rank=3    scell=0,1,2
#     \    wait_throughput_stable    10s
#     \    run_uex_command    ue_cqi_param    id=2    rank=4    scell=0,1,2
#     \    wait_throughput_stable    10s
#     \    check_4layer_PM_counter    
# 
# Step7:UE detach    
#     #start_capture_ttitrace'6'
#     Run UEx command    ue_detach    id=1
#     Run UEx command    ue_detach    id=2	
#     #Save_and_Decode_ttitrace_'6'
# 
# 
# 
# ftp_upload_swconfig2
#     [Arguments]    ${file_path} 
#     #run    curl -T ${CURDIR}/configuration_file/swconfig.txt ftp://192.168.255.1/ffs/run/ --user toor4nsn:oZPS0POrRieRtu  
#     setup_enb_fsm_access    alias=enb1
#     put_enb_file    ${file_path}     /ffs/run/swconfig.txt    alias=enb1
#     execute_command_on_enb    rm -rf /ffs/run/swconfig.txt.p7    alias=enb1
#     execute_command_on_enb    crasign /ffs/run/swconfig.txt    alias=enb1
#     teardown_enb_fsm_access    alias=enb1
#     
#     
# check_4layer_PM_counter
#     #PM counter 3min update set in swconfig.txt
#     #MIMO Closed Loop Single Codeword Single Layer TM9 (M8010C95)
#     #MIMO Closed Loop Single Codeword Two Layer TM9 (M8010C96)
#     #MIMO Closed Loop Double Codeword Two Layer TM9 (M8010C97)
#     #MIMO Closed Loop Double Codeword Three Layer TM9 (M8010C98)
#     #MIMO Closed Loop Double Codeword Four Layer TM9 (M8010C99)
#     #MIMO TM9 Fallback to TxDiversity (M8010C100)
#     #${remain_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     #set test variable    ${remain_time}
#     wait_throughput_stable    ${remain_time}
#     Get counter
#     ${counter_file}    list files in directory    ${TEST LOG DIRECTORY()}/    pattern=*.ANY.*
#     set test variable    ${counter_file}
#     ${Count_M8010C95}    get_counter_value_from_counter_file    ${TEST LOG DIRECTORY()}/${counter_file[0]}    M8010C95    1
#     ${Count_M8010C96}    get_counter_value_from_counter_file    ${TEST LOG DIRECTORY()}/${counter_file[0]}    M8010C96    1
#     ${Count_M8010C97}    get_counter_value_from_counter_file    ${TEST LOG DIRECTORY()}/${counter_file[0]}    M8010C97    1
#     ${Count_M8010C98}    get_counter_value_from_counter_file    ${TEST LOG DIRECTORY()}/${counter_file[0]}    M8010C98    1
#     ${Count_M8010C99}    get_counter_value_from_counter_file    ${TEST LOG DIRECTORY()}/${counter_file[0]}    M8010C99    1
#     ${Count_M8010C100}    get_counter_value_from_counter_file    ${TEST LOG DIRECTORY()}/${counter_file[0]}    M8010C100    1
#     Log    ${Count_M8010C95}
#     Log    ${Count_M8010C96}
#     Log    ${Count_M8010C97}
#     Log    ${Count_M8010C98}
#     Log    ${Count_M8010C99}
#     Log    ${Count_M8010C100}
#     ${sum_count}    Evaluate     ${Count_M8010C95}+${Count_M8010C97}+${Count_M8010C98}+${Count_M8010C99}
#     should_be_true    ${sum_count}>136000
# 
# Get counter
#     ${passed}=    Run Keyword And Return Status    Download Latest Pmcounter    local_path=${TEST LOG DIRECTORY()}${/}    source_path=/tmp/
#     ...    suffix=xz
#     Run Keyword If    not ${passed}    Download Latest Pmcounter    local_path=${TEST LOG DIRECTORY()}${/}    source_path=/tmp/    suffix=gz
#     ${pattern}=    Run Keyword If    '${passed}'=='True'    remove_file    ${TEST LOG DIRECTORY()}/*.xz
#     ...    ELSE    remove_file    ${TEST LOG DIRECTORY()}/*.gz
# 
# wait_throughput_stable
#     [Arguments]    ${time}
#     sleep    ${time}

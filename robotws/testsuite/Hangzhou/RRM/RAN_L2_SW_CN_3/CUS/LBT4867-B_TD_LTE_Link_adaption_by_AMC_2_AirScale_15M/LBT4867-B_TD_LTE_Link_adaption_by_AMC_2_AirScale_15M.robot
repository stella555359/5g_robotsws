# *** Settings ***
# Suite Setup       common suite setup
# Suite Teardown    common suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        QCD_MN_RAN    QCP_RAN_ET     SBTS00    RAN_4G    RAN_4G_TDD    SRAN_TDD    wennan.deng@nokia-sbell.com    CLOUD_R4P6    CIT
# #Resource          ${CURDIR}/../../../../../resource/ET/SG11/common_resource_ABIO.robot
# Resource          ${CURDIR}/../../resources/KISS/robot/common_resource_ABIO.robot
# Library           ta_kiss_enb_ttitrace
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config/
# ${scfc_name}   SCFC_1.xml
# ${cus_yaml}    cus.yaml
# @{earfcn}    text|40590|//*[contains(@distName, 'LNCEL-1')]/*[@name='earfcn']
# ...    text|40740|//*[contains(@distName, 'LNCEL-2')]/*[@name='earfcn']    text|40938|//*[contains(@distName, 'LNCEL-3')]/*[@name='earfcn']
# @{tdd_configuration}     text|2|//*[@name\='tddFrameConf']    text|7|//*[@name\='tddSpecSubfConf']    text|3000|//*[@name\='inactivityTimer']
# @{TM_mode}    text|Dynamic Open Loop MIMO|//*[@name\='dlMimoMode']
# @{chBw}    text|15 MHz|//*[contains(@distName, 'LNCEL-1')]/*[@name='chBw']    text|20 MHz|//*[contains(@distName, 'LNCEL-2')]/*[@name='chBw']
# ...    text|20 MHz|//*[contains(@distName, 'LNCEL-3')]/*[@name='chBw']
# @{maxUEcofig}   text|4|//*[@name\='maxNumUeDl']    text|4|//*[@name\='maxNumUeUl']    text|4|//*[@name\='maxNumUeDlDwPTS']
# ...    text|3|//*[@name\='maxNrSymPdcch']
# @{LdPdcch}    text|true|//*[@name\='actLdPdcch']    text|true|//*[@name\='dlamcEnable']    text|true|//*[@name\='dlOlqcEnable']
# @{UL_CarAggr}    text|UL_CA_with_smartSched|//*[@name\="actULCAggr"]    text|blind|//*[@name\="sCellActivationMethod"]
# ...    text|infinity|//*[@name\="sCellDeactivationTimereNB"]    text|0.001s|//*[@name\="sCellActivationCyclePeriod"]
# @{dlSectorBFWeight}    text|customized profile 1|//*[@name\="dlSectorBFWeightProfName"]    text|0|//*[@name\="phaseOfWeighforAntGrp0"]
# ...    text|0|//*[@name\="phaseOfWeighforAntGrp1"]    text|0|//*[@name\="phaseOfWeighforAntGrp2"]    text|0|//*[@name\="phaseOfWeighforAntGrp3"]
# @{modify_list}    @{earfcn}    @{tdd_configuration}    @{TM_mode}    @{chBw}    @{maxUEcofig}    @{LdPdcch}    @{UL_CarAggr}    @{dlSectorBFWeight}
# ${UE_NUMBER}      2
# ${UE_ID_LIST}     1
# ${category_professional}    CA3FF041034410381DF834620000A006810303A0040207A00000680001D0000103D010003A000000
# ${ue_dl_tp_threshold}     160000
# ${ue_ul_tp_threshold}     8800
# ${swconfig_path}    ${CURDIR}/swconfig.txt
# ${host_ip}     127.0.0.1
# ${enb_ip}    192.168.255.1
# 
# *** Test Cases ***
# LBT4867-B_TD_LTE_Link_adaption_by_AMC_2_AirScale_15M
# ####This cases check point change to check 15M throughput####
#     [Tags]    QC_349841
#     Step1:Set parameters as pre-condition
#     Step2:iphy attach and start traffic
#     Step3:Get and verify DL and UL throughput for ue1
#     Step4:Throughput PM counter check 
#     Step5:Detach ue
# 
# *** Keywords ***      Action               Action             Action          
#  
# Step1:Set parameters as pre-condition
#     Start enb and cus syslog'1'
#     Establish cell with bandwidth 15M and frameconfigure 2 7
#     Stop and collect enb and cus syslog
#     collect procotol log '1' from egate
#     #open debug log of log level'FID_UL_CA'set'DEBUG'on'UL'for'1'
#     #open debug log of log level'FID_DL_CA'set'DEBUG'on'DL'for'1'
# 
# Establish cell with bandwidth 15M and frameconfigure 2 7
#     ${scfc_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}scfc.xml
#     ${cus_yaml_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}cus_1.yaml
#     copy_file    ${CONFIG_DIR_PATH}/${scfc_name}    ${scfc_path}
#     copy_file    ${CONFIG_DIR_PATH}/${cus_yaml}    ${cus_yaml_path}
#     #check_scfc_and_adaption_enb_positionInSubrack        ${scfc_path}
#     Modify SCFC into 3cc CA    ${scfc_path}
#     #Add UL_CA_with_smartSched extend parameter    ${scfc_path}
#     #Add dlSectorBFWeightCusProf extend parameter    ${scfc_path}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Load CUS config Files And Wait BTS Onair    ${scfc_path}    ${cus_yaml_path}    enb_swconfig=${eNB_swconfig_path}
# 
# Step2:iphy attach and start traffic
#     #start_capture_ttitrace'2'
#     #Attach assign number single_UE'1' of category'${category_professional}' into cell'1'
#     Run UEx command    ue_attach    id=1    ue_eutra_capabilities=${category_professional}    cell=1
#     #iphy_execute_egate_command    trf_data_start ue\=1 id\=1 dir\=ul mbps\=50 trf_id\=1 seconds\=80000
#     #iphy_execute_egate_command    trf_data_start ue\=1 id\=1 dir\=dl mbps\=150 trf_id\=1 seconds\=80000
#     #iphy_execute_egate_command    trf_data_start ue\=1 id\=1 dir\=dl mbps\=150 trf_id\=2 seconds\=80000
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1    qci=8    kbps=50000    trf_id=1    dir=ul    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1    qci=8    kbps=150000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1    qci=8    kbps=150000    trf_id=2    dir=dl    protocol=udp
#     wait_throughput_stable    20s
#     ${ue1_ul_throughput}                         cus_get_ul_throughput_ave        ue_id=1    type=ul_mac
#     ${ue1_dl_throughput}                         cus_get_dl_throughput_ave        ue_id=1    type=dl_mac
#     #Save_and_Decode_ttitrace_'2'
# 
# Step3:Get and verify DL and UL throughput for ue1
#     #start_capture_ttitrace'3'
#     ${ue1_dl_throughput}        cus_get_dl_throughput_ave        ue_id=1    type=dl_mac
#     ${ue1_ul_throughput}        cus_get_ul_throughput_ave        ue_id=1    type=ul_mac
#     #should_be_true      ${ue1_ul_throughput}>=${ue_ul_tp_threshold}
#     #should_be_true      ${ue1_dl_throughput}>=${ue_dl_tp_threshold}
#     #Save_and_Decode_ttitrace_'3'
# 
# Step4:Throughput PM counter check
#     #PM counter 1min update set in swconfig.txt,check 5min
#     : FOR    ${times}    IN RANGE    1    0    -1
#     \    ${remain_time}=    get_counter_file_remaining_time
#     \    set test variable    ${remain_time}
#     \    wait_throughput_stable    ${remain_time}
#     \    Get counter
#     \    #${counter_file}=    Download Latest Pmcounter    local_path=${TEST LOG DIRECTORY()}/    source_path=/tmp/    suffix=gz
#     \    ${counter_file}    list files in directory    ${TEST LOG DIRECTORY()}/    pattern=*.ANY.*
#     \    set test variable    ${counter_file}
#     \    ${Count_M8012C26}    get_counter_value_from_counter_file    ${TEST LOG DIRECTORY()}/${counter_file[0]}    M8012C26    1
#     \    ${Count_M8012C25}    get_counter_value_from_counter_file    ${TEST LOG DIRECTORY()}/${counter_file[0]}    M8012C25    1
#     \    ${Count_M8012C23}    get_counter_value_from_counter_file    ${TEST LOG DIRECTORY()}/${counter_file[0]}    M8012C23    1
#     \    ${Count_M8012C22}    get_counter_value_from_counter_file    ${TEST LOG DIRECTORY()}/${counter_file[0]}    M8012C22    1
#     \    Log    ${Count_M8012C26}
#     \    Log    ${Count_M8012C25}
#     \    Log    ${Count_M8012C23}
#     \    Log    ${Count_M8012C22}
#     \    #should_be_true    ${Count_M8012C26}>160000
#     \    #should_be_true    ${Count_M8012C23}>8800
# 
# Get counter
#     ${passed}=    Run Keyword And Return Status    Download Latest Pmcounter    local_path=${TEST LOG DIRECTORY()}${/}    source_path=/tmp/
#     ...    suffix=xz
#     Run Keyword If    not ${passed}    Download Latest Pmcounter    local_path=${TEST LOG DIRECTORY()}${/}    source_path=/tmp/    suffix=gz
#     ${pattern}=    Run Keyword If    '${passed}'=='True'    remove_file    ${TEST LOG DIRECTORY()}/*.xz
#     ...    ELSE    remove_file    ${TEST LOG DIRECTORY()}/*.gz
# 
# Step5:Detach ue
#     #start_capture_ttitrace'4'
#     Run UEx command    ue_detach    id=1
#     #Save_and_Decode_ttitrace_'4'
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
# wait_throughput_stable
#     [Arguments]    ${time}
#     sleep    ${time}

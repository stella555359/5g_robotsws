# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        QCD_MN_RAN    QCP_RAN_ET     SBTS00    RAN_4G    RAN_4G_TDD    LTE829    CLOUD_R4BN9_CUS    CRT    wennan.deng@nokia-sbell.com
# #Resource          ${CURDIR}/../../../../../resource/ET/SG11/common_resource_ABIO.robot
# Resource          ${CURDIR}/../../resources/KISS/robot/common_resource_ABIO.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config/
# ${scfc_name}   SCFC_1.xml
# ${cus_yaml}    cus_R4BO9.yaml
# ${inactivityTimer}    text|3000|//*[@name\="inactivityTimer"]
# @{earfcn}         text|38950|//*[contains(@distName, 'LNCEL-1')]/*[@name='earfcn']
# ...    text|39150|//*[contains(@distName, 'LNCEL-2')]/*[@name='earfcn']    text|39350|//*[contains(@distName, 'LNCEL-3')]/*[@name='earfcn']
# @{tdd_configuration}    text|1|//*[@name\="tddFrameConf"]    text|7|//*[@name\="tddSpecSubfConf"]
# ${TM_mode}        text|Dynamic Open Loop MIMO|//*[@name\="dlMimoMode"]
# @{LTE829_Increased_Uplink_Mcs_Range_Parameter}    text|16QAMHighMCS|//*[@name\="actModulationSchemeUL"]    text|4|//*[@name\="iniMcsUl"]
# ...    text|false|//*[@name\="cqiAperEnable"]
# @{modify_list}    ${inactivityTimer}    @{earfcn}    @{tdd_configuration}    ${TM_mode}    @{LTE829_Increased_Uplink_Mcs_Range_Parameter}
# @{counter_list}    M8001C37    M8001C38    M8001C39    M8001C40    M8001C95    M8001C96    M8001C97
# ...               M8001C98    M8001C435    M8001C436    M8001C437    M8001C438    M8001C439    M8001C440
# ...               M8001C441    M8001C442    M8001C443    M8001C444    M8001C445    M8001C446    M8001C447
# ...               M8001C448    M8001C449    M8001C450    M8001C451    M8001C452    M8001C453    M8001C454
# ...               M8001C455    M8001C456    M8001C457    M8001C458    M8001C459    M8001C460    M8001C461
# ...               M8001C462    M8001C463    M8001C464    M8001C465    M8001C466    M8001C467    M8001C468
# ...               M8001C469    M8001C470    M8001C471    M8001C472    M8001C473    M8001C474    M8001C475
# ...               M8001C476    M8001C477    M8001C478    M8001C479    M8001C480    M8001C481    M8001C482
# ...               M8001C483    M8001C484    M8001C485    M8001C486    M8001C487    M8001C488    M8012C144
# ...               M8012C145    M8012C146    M8012C147
# ${ue_ul_tp_threshold}    15700
# 
# *** Test Cases ***
# TD_LTE829 verification for related PM Counter_AirScale
#     [Tags]    QC_349717
#     Step1:Set parameters as pre-condition
#     Step2:iphy attach and start traffic
#     Step3:increase Nack step by step of cell
#     Step4:Detach ue
#     Step5:Get PM_counter
# 
# *** Keywords ***
# Step1:Set parameters as pre-condition
#     Start enb and cus syslog'1'
#     Establish cell with bandwidth 20M 1 7 dl continuous
#     Stop and collect enb and cus syslog
#     collect procotol log '1' from egate
# 
# Establish cell with bandwidth 20M 1 7 dl continuous
#     ${scfc_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}scfc.xml
#     ${cus_yaml_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}cus_1.yaml
#     copy_file    ${CONFIG_DIR_PATH}/${scfc_name}    ${scfc_path}
#     copy_file    ${CONFIG_DIR_PATH}/${cus_yaml}    ${cus_yaml_path}
#     Modify SCFC into 3cc CA    ${scfc_path}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Load CUS config Files And Wait BTS Onair    ${scfc_path}    ${cus_yaml_path}    enb_swconfig=${eNB_swconfig_path}
# 
# Step2:iphy attach and start traffic
#     Start enb and cus syslog'2'
#     cus_attach    ue_id_list=1 cell_id_list=1
#     run_uex_command    trf_data_start ue\=1 Mbps\=50 dir\=ul protocol\=udp trf_id\=1
#     Start_capture_ttitrace'2'
#     wait_throughput_stable    20s
#     ${ue1_dl_throughput}    cus_get_dl_throughput_ave    ue_id=1    type=dl_mac
#     ${ue1_ul_throughput}    cus_get_ul_throughput_ave    ue_id=1    type=ul_mac
#     Save_and_Decode_ttitrace_'2'
#     collect procotol log '2' from egate
#     Stop and collect enb and cus syslog
#     should_be_true    ${ue1_ul_throughput}>=${ue_ul_tp_threshold}
# 
# Step3:increase Nack step by step of cell
#     Start enb and cus syslog'3'
#     Start_capture_ttitrace'3'
#     : FOR    ${i}    IN RANGE    0    50    10
#     \    iphy_execute_egate_command    ue_harq_error id\=1 ul_err_ratio\=0-6:100:${i}:0
#     \    wait_throughput_stable    5s
#     Save_and_Decode_ttitrace_'3'
#     collect procotol log '3' from egate
#     Stop and collect enb and cus syslog
# 
# Step4:Detach ue
#     Start enb and cus syslog'4'
#     cus_detach    ue_id_list=1
#     collect procotol log '4' from egate
#     Stop and collect enb and cus syslog
# 
# Step5:Get PM_counter
#     ${remain_time}=    get_counter_file_remaining_time
#     set test variable    ${remain_time}
#     sleep    ${remain_time}
#     ${passed}=    Run Keyword And Return Status    Download Latest Pmcounter    local_path=${TEST LOG DIRECTORY()}/    source_path=/tmp/    
#    ...    suffix=xz
#     Run Keyword If    not ${passed}    Download Latest Pmcounter    local_path=${TEST LOG DIRECTORY()}/    source_path=/tmp/    suffix=gz
#     ${counter_file}    list files in directory    ${TEST LOG DIRECTORY()}/    pattern=*.ANY.*
#     set test variable    ${counter_file}
#     : FOR    ${PM_counter}    IN    @{counter_list}
#     \    get_counter_value_from_counter_file    ${TEST LOG DIRECTORY()}/${counter_file[0]}    ${PM_counter}
#     \    sleep    1s
# 
# wait_throughput_stable
#     [Arguments]    ${time}
#     sleep    ${time}

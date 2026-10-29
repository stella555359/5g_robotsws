# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        QCD_MN_RAN    QCP_RAN_ET     SBTS00    RAN_4G    RAN_4G_TDD    LTE2479    CLOUD_R4BN9_CUS    CIT    wennan.deng@nokia-sbell.com
# #Resource          ${CURDIR}/../../../../../resource/ET/SG11/common_resource_ABIO.robot
# Resource          ${CURDIR}/../../resources/KISS/robot/common_resource_ABIO.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config/
# ${scfc_name}   SCFC_1.xml
# ${cus_yaml}    cus_R4BO9.yaml
# ${category_professional}    D23FF041033C10381DF83462000080068302039C0002079C0000670001CE02018A60081084A6008073A0    #dl_3cc&continus
# ${inactivityTimer}    text|3000|//*[@name\="inactivityTimer"]
# @{earfcn}         text|38952|//*[contains(@distName, 'LNCEL-1')]/*[@name='earfcn']
# ...    text|39150|//*[contains(@distName, 'LNCEL-2')]/*[@name='earfcn']    text|39348|//*[contains(@distName, 'LNCEL-3')]/*[@name='earfcn']
# ${TM_mode}        text|Dynamic Open Loop MIMO|//*[@name\="dlMimoMode"]
# @{tdd_configure}    text|2|//*[@name\="tddFrameConf"]    text|9|//*[@name\="tddSpecSubfConf"]
# ${actModula}      text|256QAM|//*[@name\='actModulationSchemeDl']
# ${ULCA}           text|UL_CA_with_smartSched|//*[@name\='actULCAggr']
# ${prachFreqOff}    text|11|//*[@name\="prachFreqOff"]
# @{dlSectorBFWeight}    text|customized profile 1|//*[@name\="dlSectorBFWeightProfName"]    text|0|//*[@name\="phaseOfWeighforAntGrp0"]
# ...    text|0|//*[@name\="phaseOfWeighforAntGrp1"]    text|0|//*[@name\="phaseOfWeighforAntGrp2"]    text|0|//*[@name\="phaseOfWeighforAntGrp3"]
# @{modify_list}    @{tdd_configure}    ${actModula}    ${ULCA}    ${inactivityTimer}    @{earfcn}    ${TM_mode}
# ...    @{dlSectorBFWeight}    ${prachFreqOff}
# ${ue1_dl_throughput_threshold}    385000
# ${ue1_ul_throughput_threshold}    12000
# 
# *** Test Cases ***
# LTE2479-T-e_ET_03_Peak_Tput_3CC_TM3
#     [Tags]    QC_22875
#     Step1:Set parameter as precondition ,reset bts and iphy
#     Step2:Attach 1UE with 256QAM capability
#     Step3:Send DL/UL 450M/20M data
#     Step4:Detach UE
# 
# *** Keywords ***
# Step1:Set parameter as precondition ,reset bts and iphy
#     Start enb and cus syslog'1'
#     Establish cell with bandwidth 20M and frameconfigure 2 9
#     Stop and collect enb and cus syslog
#     collect procotol log '1' from egate
# 
# Establish cell with bandwidth 20M and frameconfigure 2 9
#     ${scfc_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}scfc.xml
#     ${cus_yaml_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}cus_1.yaml
#     copy_file    ${CONFIG_DIR_PATH}/${scfc_name}    ${scfc_path}
#     copy_file    ${CONFIG_DIR_PATH}/${cus_yaml}    ${cus_yaml_path}
#     Modify SCFC into 3cc CA    ${scfc_path}
#     Add UL_CA_with_smartSched extend parameter    ${scfc_path}
#     Add parameter in all cell level    ${scfc_path}    <p name="actDl256QamChQualEst">false</p>
#     Add tmSwitchThresholdDef256Qam element in TMSWPR    ${scfc_path}
#     Add dlSectorBFWeightCusProf extend parameter    ${scfc_path}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Load CUS config Files And Wait BTS Onair    ${scfc_path}    ${cus_yaml_path}    enb_swconfig=${eNB_swconfig_path}
# 
# Step2:Attach 1UE with 256QAM capability
#     Start enb and cus syslog'2'
#     cus_attach    ue_id_list=1 cell_id_list=1 ue_eutra_capabilities=${category_professional}
#     wait_throughput_stable    2s
#     collect procotol log '2' from egate
#     Stop and collect enb and cus syslog
# 
# Step3:Send DL/UL 450M/20M data
#     Start enb and cus syslog'3'
#     Start_capture_ttitrace'3'
#     run_uex_command    trf_data_start ue\=1 Mbps\=50 dir\=ul protocol\=udp trf_id\=1
#     run_uex_command    trf_data_start ue\=1 Mbps\=150 dir\=dl protocol\=udp trf_id\=1
#     run_uex_command    trf_data_start ue\=1 Mbps\=150 dir\=dl protocol\=udp trf_id\=2
#     run_uex_command    trf_data_start ue\=1 Mbps\=150 dir\=dl protocol\=udp trf_id\=3
#     wait_throughput_stable    20s
#     ${ue1_dl_throughput}    cus_get_dl_throughput_ave    ue_id=1    type=dl_mac
#     ${ue1_ul_throughput}    cus_get_ul_throughput_ave    ue_id=1    type=ul_mac
#     collect procotol log '3' from egate
#     Stop and collect enb and cus syslog
#     Save_and_Decode_ttitrace_'3'
#     should_be_true    ${ue1_dl_throughput}>=${ue1_dl_throughput_threshold}
#     should_be_true    ${ue1_ul_throughput}>=${ue1_ul_throughput_threshold}
# 
# Step4:Detach UE
#     Start enb and cus syslog'4'  
#     cus_detach    ue_id_list=1
#     collect procotol log '4' from egate
#     Stop and collect enb and cus syslog
# 
# wait_throughput_stable
#     [Arguments]    ${time}
#     sleep    ${time}
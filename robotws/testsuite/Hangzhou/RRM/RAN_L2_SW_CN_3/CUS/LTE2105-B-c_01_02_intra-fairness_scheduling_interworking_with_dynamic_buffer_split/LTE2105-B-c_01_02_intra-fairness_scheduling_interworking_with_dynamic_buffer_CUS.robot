# *** Settings ***
# Suite Setup       common suite setup
# Suite Teardown    common suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    wennan.deng@nokia-sbell.com    CLOUD_R4BN9_CUS    CIT
# #Resource          ${CURDIR}/../../../../../resource/ET/SG11/common_resource_ABIO.robot
# Resource          ${CURDIR}/../../resources/KISS/robot/common_resource_ABIO.robot
#
# *** Variables ***
# #${CONFIG_DIR_PATH}    ${CURDIR}/../../../../../resource/ET/SG11/configuration_file/T111_R4BO9/
# ${CONFIG_DIR_PATH}    ${CURDIR}/config/
# ${scfc_name}   SCFC_1.xml
# ${cus_yaml}    cus_R4BO9.yaml
# ${eNB_swconfig}    swconfig_eNB.txt
# ${category_8}     CA3FF041033C10381FF834626800A006A107039C0403039C0402079C0402670003CE02003380C0E70000C1E70000B000000079C0000670001CE0001001C00000
# ${category_6_NCA}    C9BFF041034410381DF834620000A0068007039C0403039C0402079C0402670003CE0200338080E70000C1E70000900000F380000CE00039C00020
# ${inactivityTimer}    text|3000|//*[@name\="inactivityTimer"]
# @{earfcn}         text|38952|//*[contains(@distName, 'LNCEL-1')]/*[@name='earfcn']
#    ...    text|39150|//*[contains(@distName, 'LNCEL-2')]/*[@name='earfcn']
# ...    text|39350|//*[contains(@distName, 'LNCEL-3')]/*[@name='earfcn']
# @{tdd_configuration}    text|1|//*[@name\="tddFrameConf"]    text|7|//*[@name\="tddSpecSubfConf"]
# ${TM_mode}        text|Dynamic Open Loop MIMO|//*[@name\="dlMimoMode"]
# @{UL_CarAggr}     text|UL_CA_with_smartSched|//*[@name\="actULCAggr"]    text|nonGBRBufferBased|//*[@name\="sCellActivationMethod"]
# ...    text|infinity|//*[@name\="sCellDeactivationTimereNB"]    text|2s|//*[@name\="sCellActivationCyclePeriod"]
# ${MCS}            text|16QAMHighMCS|//*[@name\="actModulationSchemeUL"]
# @{Admission Control}    text|2|//*[@name\="maxNumCaConfUe"]    text|2|//*[@name\="maxNumCaConfUe3c"]    text|2|//*[@name\="maxNumCaConfUeDc"]
# ...    text|2|//*[@name\="maxNumActUE"]    text|2|//*[@name\="maxNumQci1Drb"]    text|2|//*[@name\="maxNumRrc"]    
# ...    text|8|//*[@name\="maxNumActDrb"]
# ...    text|0|//*[@name\="aPucchMinNumRrc"]
# ${caSchedFairFact}    text|0|//*[@name\="caSchedFairFact"]
# @{srs_close}      text|false|//*[@name\="srsActivation"]    text|false|//*[@name\="srsSimAckNack"]    
# ...    text|PuschCLPucchCL|//*[@name\="actUlpcMethod"]
# ...    text|channel unaware|//*[@name\="ulsSchedMethod"]
# @{dlSectorBFWeight}    text|customized profile 1|//*[@name\="dlSectorBFWeightProfName"]    text|0|//*[@name\="phaseOfWeighforAntGrp0"]
# ...    text|0|//*[@name\="phaseOfWeighforAntGrp1"]    text|0|//*[@name\="phaseOfWeighforAntGrp2"]    text|0|//*[@name\="phaseOfWeighforAntGrp3"]
# @{modify_list}    ${inactivityTimer}    @{earfcn}    @{tdd_configuration}    ${TM_mode}    @{UL_CarAggr}    ${MCS}    @{Admission Control}
# ...               ${caSchedFairFact}    @{srs_close}    @{dlSectorBFWeight}
#
# *** Test Cases ***
# LTE2105-B-c_01_02_intra-fairness_scheduling_interworking_with_dynamic_buffer_split
#     [Tags]    QC_22874
#     Step1:Set parameter as precondition
#     Step2:CA UE-1 attach to cell1,NCA UE2 attach to cell1.UE1&UE2 use same no-GBR QCI with same scheduling weight
#     Step3:Fetch the TTI trace check UE1 and UE2's TP
#     Step4:Detach UE1 and UE2
#     Step5:CA UE-1 and NCA UE2 attach to cell1.UE1 and UE2 use same no-GBR QCI with same scheduling weight
#     Step6:Fetch the TTI trace check UE1 and UE2's TP
#     Step7:Detach UE1 and UE2
#
# *** Keywords ***      Action
# Step1:Set parameter as precondition
#     Start enb and cus syslog'1'
#     Establish cell with bandwidth 20M 1 7 dl continuous
#     Stop and collect enb and cus syslog
#     collect procotol log '1' from egate
#
# Establish cell with bandwidth 20M 1 7 dl continuous
#     ${scfc_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}scfc.xml
#     ${cus_yaml_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}cus_1.yaml
#     ${eNB_swconfig_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}swconfig.txt
#     copy_file    ${CONFIG_DIR_PATH}/${scfc_name}    ${scfc_path}
#     copy_file    ${CONFIG_DIR_PATH}/${cus_yaml}    ${cus_yaml_path}
#     copy_file    ${CONFIG_DIR_PATH}/${eNB_swconfig}    ${eNB_swconfig_path}
#     Modify SCFC into 3cc CA                       ${scfc_path}
#     Add UL_CA_with_smartSched extend parameter    ${scfc_path}
#     Add dlSectorBFWeightCusProf extend parameter    ${scfc_path}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Load CUS config Files And Wait BTS Onair    ${scfc_path}    ${cus_yaml_path}    enb_swconfig=${eNB_swconfig_path}
#
#
# Step2:CA UE-1 attach to cell1,NCA UE2 attach to cell1.UE1&UE2 use same no-GBR QCI with same scheduling weight
#     Start enb and cus syslog'2'
#     Attach assign number single_UE'1' of category'${category_8}' into cell'1'
#     Attach assign number single_UE'2' of category'${category_6_NCA}' into cell'1'
#     wait_throughput_stable   10s
#     collect procotol log '2' from egate
#     Stop and collect enb and cus syslog
#
# Step3:Fetch the TTI trace check UE1 and UE2's TP
#     Start enb and cus syslog'3'
#     start_capture_ttitrace'3'
#     cus_start_dl_udp_data_traffic    ue_id_list=1    through_put=175M    trf_id=1
#     cus_start_ul_udp_data_traffic    ue_id_list=1    through_put=50M    trf_id=1
#     cus_start_dl_udp_data_traffic    ue_id_list=2    through_put=175M    trf_id=1
#     cus_start_ul_udp_data_traffic    ue_id_list=2    through_put=50M    trf_id=1
#     wait_throughput_stable    20s
#     ${ue1_ul_tp}                  cus_get_ul_throughput_ave    ue_id=1    type=ul_mac
#     ${ue1_ul_pcellthroughput}     cus_get_throughput_on_specific_scell    ue_id=1    type=ul_mac    scell_id=0
#     ${ue1_ul_scellthroughput}     cus_get_throughput_on_specific_scell    ue_id=1    type=ul_mac    scell_id=1
#     ${ue1_dl_tp}                  cus_get_dl_throughput_ave    ue_id=1    type=dl_mac
#     ${ue1_dl_pcellthroughput}    cus_get_throughput_on_specific_scell    ue_id=1    type=dl_mac    scell_id=0
#     ${ue1_dl_scellthroughput1}    cus_get_throughput_on_specific_scell    ue_id=1    type=dl_mac    scell_id=1
#      ${ue1_dl_scellthroughput2}    cus_get_throughput_on_specific_scell    ue_id=1    type=dl_mac    scell_id=2
#     ${ue2_dl_tp}          cus_get_dl_throughput_ave    ue_id=2    type=dl_mac
#     ${ue2_ul_tp}          cus_get_ul_throughput_ave    ue_id=2    type=ul_mac
#     Save_and_Decode_ttitrace_'3'
#     Stop and collect enb and cus syslog
#     collect procotol log '3' from egate
#     ${result_1}        evaluate            float(${ue1_ul_pcellthroughput}/${ue2_ul_tp})
#     ${result_1}        Convert To Number    ${result_1}    0
#     log                ${result_1}
#     should_be_true     ${result_1}==1
#     should_be_true     ${ue1_ul_pcellthroughput}>=8000
#     should_be_true     ${ue1_ul_scellthroughput}>=14000
#
# Step4:Detach UE1 and UE2
#     Start enb and cus syslog'4'
#     cus_detach    ue_id_list=1
#     cus_detach    ue_id_list=2
#     Stop and collect enb and cus syslog
#     collect procotol log '4' from egate
#
# Step5:CA UE-1 and NCA UE2 attach to cell1.UE1 and UE2 use same no-GBR QCI with same scheduling weight
#     Start enb and cus syslog'5'
#     Attach assign number single_UE'1' of category'${category_8}' into cell'1'
#     Attach assign number single_UE'2' of category'${category_6_NCA}' into cell'1'
#     wait_throughput_stable    10s
#     Stop and collect enb and cus syslog
#     collect procotol log '5' from egate
#
# Step6:Fetch the TTI trace check UE1 and UE2's TP
#     Start enb and cus syslog'6'
#     start_capture_ttitrace'6'
#     cus_start_dl_udp_data_traffic    ue_id_list=1    through_put=175M    trf_id=1
#     cus_start_ul_udp_data_traffic    ue_id_list=1    through_put=20M    trf_id=1
#     cus_start_dl_udp_data_traffic    ue_id_list=2    through_put=175M    trf_id=1
#     cus_start_ul_udp_data_traffic    ue_id_list=2    through_put=5M    trf_id=1
#     wait_throughput_stable    20s
#     #Mack some bler in UL
#     run_uex_command    ue_harq_error id\=1 cell\=current ul_err_ratio\=0-6:100:8:0
#     wait_throughput_stable    10s
#     ${ue1_ul_tp}                  cus_get_ul_throughput_ave    ue_id=1    type=ul_mac
#     ${ue1_ul_pcellthroughput}     cus_get_throughput_on_specific_scell    ue_id=1    type=ul_mac    scell_id=0
#     ${ue1_ul_scellthroughput}     cus_get_throughput_on_specific_scell    ue_id=1    type=ul_mac    scell_id=1
#     ${ue1_dl_tp}                  cus_get_dl_throughput_ave    ue_id=1    type=dl_mac
#     ${ue1_dl_pcellthroughput}    cus_get_throughput_on_specific_scell    ue_id=1    type=dl_mac    scell_id=0
#     ${ue1_dl_scellthroughput1}    cus_get_throughput_on_specific_scell    ue_id=1    type=dl_mac    scell_id=1
#      ${ue1_dl_scellthroughput2}    cus_get_throughput_on_specific_scell    ue_id=1    type=dl_mac    scell_id=2
#     ${ue2_dl_tp}          cus_get_dl_throughput_ave    ue_id=2    type=dl_mac
#     ${ue2_ul_tp}          cus_get_ul_throughput_ave    ue_id=2    type=ul_mac
#     Save_and_Decode_ttitrace_'6'
#     Stop and collect enb and cus syslog
#     collect procotol log '6' from egate
#     should_be_true       ${ue1_ul_scellthroughput}>0
#     should_be_true       ${ue1_ul_pcellthroughput}>0
#     should_be_true      ${ue1_ul_tp}>0
#
# Step7:Detach UE1 and UE2
#     Start enb and cus syslog'7'
#     cus_detach    ue_id_list=1
#     cus_detach    ue_id_list=2
#     Stop and collect enb and cus syslog
#     collect procotol log '7' from egate
#
# wait_throughput_stable
#     [Arguments]    ${time}
#     sleep    ${time}

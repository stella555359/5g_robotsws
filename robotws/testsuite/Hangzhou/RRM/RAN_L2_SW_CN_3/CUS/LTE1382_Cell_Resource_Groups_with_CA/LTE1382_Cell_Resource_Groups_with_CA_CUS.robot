# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    wennan.deng@nokia-sbell.com    CLOUD_R4BO9_CUS    CIT
# #Resource          ${CURDIR}/../../../../../resource/ET/SG11/common_resource_ABIO.robot
# Resource          ${CURDIR}/../../resources/KISS/robot/common_resource_ABIO.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config/
# ${scfc_name}    SCFC_1.xml
# ${cus_yaml}    cus_R4BO9_2plmn.yaml
# ${swconfig_path}    swconfig_eNB.txt
# ${inactivityTimer}    text|3000|//*[@name\="inactivityTimer"]
# @{earfcn}    text|38952|//*[contains(@distName, 'LNCEL-1')]/*[@name='earfcn']    text|39150|//*[contains(@distName, 'LNCEL-2')]/*[@name='earfcn']
# ...    text|39350|//*[contains(@distName, 'LNCEL-3')]/*[@name='earfcn']
# @{tdd_configuration}    text|1|//*[@name\="tddFrameConf"]    text|7|//*[@name\="tddSpecSubfConf"]    text|154|//*[@name\="prsConfigurationIndex"]
# ${TM_mode}    text|Dynamic Open Loop MIMO|//*[@name\="dlMimoMode"]
# @{UL_CarAggr}    text|UL_CA_with_smartSched|//*[@name\="actULCAggr"]    text|nonGBRBufferBased|//*[@name\="sCellActivationMethod"]
# ...    text|infinity|//*[@name\="sCellDeactivationTimereNB"]   text|2s|//*[@name\="sCellActivationCyclePeriod"]
# @{CRG}    text|false|//*[@name\="actLdPdcch"]    text|16|//*[@name\="drxRetransT"]    text|10|//*[@name\="drxOnDuratT"]
# ...    text|10|//*[@name\='drxProfile2']/item/*[@name\='drxInactivityT']    text|10|//*[@name\='drxProfile6']/item/*[@name\='drxInactivityT']
# ...    text|0|//*[@name\="crgSkipThreshold"]
# @{cellResourceSharingMode}    text|DLandUL|//*[contains(@distName, 'LNCEL-1')]/*[@name='cellResourceSharingMode']
# ...    text|none|//*[contains(@distName, 'LNCEL-2')]/*[@name='cellResourceSharingMode']
# ...    text|none|//*[contains(@distName, 'LNCEL-3')]/*[@name='cellResourceSharingMode']
# @{dlSectorBFWeightPr_BTS}    text|0|//*[@name\="phaseOfWeighforAntGrp0"]    text|0|//*[@name\="phaseOfWeighforAntGrp1"]
# ...    text|0|//*[@name\="phaseOfWeighforAntGrp2"]    text|0|//*[@name\="phaseOfWeighforAntGrp3"]
# @{maxNrSymPdcch}       text|1|//*[@name\="maxNrSymPdcch"]    text|1|//*[@name\="maxNumScells"]
# @{modify_list}    ${inactivityTimer}    @{earfcn}    @{tdd_configuration}    ${TM_mode}    @{UL_CarAggr}    @{CRG}    @{cellResourceSharingMode}
# ...     @{dlSectorBFWeightPr_BTS}    @{maxNrSymPdcch}
# @{PLMN_List}    666:653
# ${category_8}    CA3FF041033C10381FF834626800A006A107039C0403039C0402079C0402670003CE02003380C0E70000C1E70000900000F380000CE00039C0002003800000
# @{counter_list}    M8011C70    M8011C71    M8011C74    M8011C75    M8011C76    M8011C79
# 
# *** Test Cases ***
# LTE1382_Cell_Resource_Groups_with_CA
#     [Tags]    QC_22878
#     Step1:Set parameters as pre-condition. All cells with same modulation scheme and without any background load, and any pre-add attenuation
#     Step2:Attach UE1 with contiguous CA capability with category 8 default PLMN
#     Step3:Send DL only traffic on UE1
#     Step4:Attach UE2 with contiguous CA capability with category 8 shared PLMN
#     Step5:Send DL only traffic on UE2
#     Step6:Waiting for at least 15min and get PM counter
#     Step7:Detach ue
# 
# *** Keywords ***
# Step1:Set parameters as pre-condition. All cells with same modulation scheme and without any background load, and any pre-add attenuation
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
#     ${xml}=     Parse XML    source=${scfc_path}
#     remove_element       ${xml}     xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-1/CAREL-3"]     remove_tail=yes
#     Save xml    source=${xml}     path=${scfc_path}
#     Add UL_CA_with_smartSched extend parameter    ${scfc_path}
#     Add dlSectorBFWeightCusProf extend parameter    ${scfc_path}
#     Add CRGPR element in LNBTS    ${scfc_path}
#     Add furtherPlmnIdL config in LNCEL    ${scfc_path}
#     Add parameter in all cell level    ${scfc_path}    <p name="cellResourceGroupPrId">0</p>
#     Add parameter in CRGPR    ${scfc_path}    <p name="defaultGroupId">0</p>
#     Add parameter in bts level    ${scfc_path}    <p name="cellResourceSharingType">plmnBased</p>
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Load CUS config Files And Wait BTS Onair    ${scfc_path}    ${cus_yaml_path}    enb_swconfig=${swconfig_path}
# 
# 
# Step2:Attach UE1 with contiguous CA capability with category 8 default PLMN
#     Start enb and cus syslog'2'
#     Cus Execute Uex Command    ue_attach id=1 cell=1 ue_eutra_capabilities=${category_8} selected_plmn=666:652
#     wait_throughput_stable    5s
#     collect procotol log '2' from egate
#     Stop and collect enb and cus syslog
# 
# Step3:Send DL only traffic on UE1
#     Start enb and cus syslog'3'
#     start_capture_ttitrace'3'
#     cus_start_dl_udp_data_traffic    ue_id_list=1    through_put=150M    trf_id=1
#     cus_start_dl_udp_data_traffic    ue_id_list=1    through_put=150M    trf_id=2
#     cus_start_ul_udp_data_traffic    ue_id_list=1    through_put=50M    trf_id=1
#     wait_throughput_stable    30s
#     ${ue1_ul_throughput}      cus_get_ul_throughput_ave    ue_id=1    type=ul_mac
#     ${ue1_dl_throughput}      cus_get_dl_throughput_ave    ue_id=1    type=dl_mac
#     Save_and_Decode_ttitrace_'3'
#     Stop and collect enb and cus syslog
#     collect procotol log '3' from egate
#     should_be_true    ${ue1_dl_throughput}>144000
#     should_be_true    ${ue1_ul_throughput}>20000
# 
# Step4:Attach UE2 with contiguous CA capability with category 8 shared PLMN
#     Start enb and cus syslog'4'
#     Cus Execute Uex Command    ue_attach id=2 cell=1 ue_eutra_capabilities=${category_8} selected_plmn=666:653
#     wait_throughput_stable    5s
#     Stop and collect enb and cus syslog
#     collect procotol log '4' from egate
# 
# Step5:Send DL only traffic on UE2
#     Start enb and cus syslog'5'
#     start_capture_ttitrace'5'
#     cus_start_dl_udp_data_traffic    ue_id_list=2    through_put=100M    trf_id=1
#     cus_start_dl_udp_data_traffic    ue_id_list=2    through_put=100M    trf_id=2
#     cus_start_ul_udp_data_traffic    ue_id_list=2    through_put=20M    trf_id=1
#     wait_throughput_stable    20s
#     ${ue1_dl_throughput}          cus_get_dl_throughput_ave    ue_id=1    type=dl_mac
#     ${ue1_dl_throughput_pcell}    cus_get_throughput_on_specific_scell    ue_id=1    type=dl_mac    scell_id=0    tput_type=avg
#     ${ue1_dl_throughput_scell}    cus_get_throughput_on_specific_scell    ue_id=1    type=dl_mac    scell_id=1    tput_type=avg
#     ${ue1_ul_throughput}          cus_get_ul_throughput_ave    ue_id=1    type=ul_mac
#     ${ue2_dl_throughput}          cus_get_dl_throughput_ave    ue_id=1    type=dl_mac
#     ${ue2_dl_throughput_pcell}    cus_get_throughput_on_specific_scell    ue_id=2    type=dl_mac    scell_id=0    tput_type=avg
#     ${ue2_dl_throughput_scell}    cus_get_throughput_on_specific_scell    ue_id=2    type=dl_mac    scell_id=1    tput_type=avg
#     ${ue2_ul_throughput}          cus_get_ul_throughput_ave    ue_id=2    type=ul_mac
#     Save_and_Decode_ttitrace_'5'
#     Stop and collect enb and cus syslog
#     collect procotol log '5' from egate
#     ${ue1_dl_cell_throughput}    evaluate    float(${ue1_dl_throughput_pcell} + ${ue1_dl_throughput_scell})
#     should_be_true    ${ue1_dl_cell_throughput}>90000
#     should_be_true    ${ue1_ul_throughput}>17500
#     ${ue2_dl_cell_throughput}    evaluate    float(${ue2_dl_throughput_pcell} + ${ue2_dl_throughput_scell})
#     should_be_true    ${ue2_dl_cell_throughput}>60000
#     should_be_true    ${ue2_ul_throughput}>7500
# 
# Step6:Waiting for at least 15min and get PM counter
#     ${remain_time}=    get_counter_file_remaining_time
#     set test variable    ${remain_time}
#     sleep    ${remain_time}
#     ${passed}=    Run Keyword And Return Status    Download Latest Pmcounter    local_path=${TEST LOG DIRECTORY()}/    source_path=/tmp/    
#    ...    suffix=xz
#     Run Keyword If    not ${passed}    Download Latest Pmcounter    local_path=${TEST LOG DIRECTORY()}/    source_path=/tmp/    suffix=gz
#     ${counter_file}    list files in directory    ${TEST LOG DIRECTORY()}/    pattern=*.ANY.*
#     set test variable    ${counter_file}
#     : FOR    ${PM_counter}    IN    @{counter_list}
#     \    ${Count_pcell}    get_counter_value_from_counter_file    ${TEST LOG DIRECTORY()}/${counter_file[0]}    ${PM_counter}    1
#     \    sleep    1s
#     \    should_be_true    ${Count_pcell}>0
# 
# Step7:Detach ue
#     Start enb and cus syslog'6'
#     cus_detach    ue_id_list=1
#     cus_detach    ue_id_list=2
#     Stop and collect enb and cus syslog
#     collect procotol log '6' from egate
# 
# wait_throughput_stable
#     [Arguments]    ${time}
#     sleep    ${time}

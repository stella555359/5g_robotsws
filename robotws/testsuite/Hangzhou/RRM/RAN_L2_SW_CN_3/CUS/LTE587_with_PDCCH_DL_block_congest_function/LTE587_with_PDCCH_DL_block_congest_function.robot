# *** Settings ***
# Suite Setup       common suite setup
# Suite Teardown    common suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    SRAN_TDD    LTE587    CLOUD_R4A_CUS    CIT    CDRT
# ...    wennan.deng@nokia-sbell.com
# #Resource          ${CURDIR}/../../../../../resource/ET/SG11/common_resource_ABIO.robot
# Resource          ${CURDIR}/../../resources/KISS/robot/common_resource_ABIO.robot
# Library     ta_kiss_enb_ttitrace
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config/
# ${scfc_name}    SCFC_1.xml
# ${cus_yaml}     cus.yaml
# ${bts_host}     192.168.255.1
# ${bts_port}     443
# ${inactivityTimer}    text|50000|//*[@name\='inactivityTimer']
# @{tdd_configuration}    text|1|//*[@name\="tddFrameConf"]    text|7|//*[@name\="tddSpecSubfConf"]
# @{TM_mode}        text|Dynamic Open Loop MIMO|//*[@name\="dlMimoMode"]    text|15 MHz|//*[@name\='chBw']
# @{earfcn}    text|40540|//*[contains(@distName, 'LNCEL-1')]/*[@name='earfcn']    text|40740|//*[contains(@distName, 'LNCEL-2')]/*[@name='earfcn']
# ...    text|40940|//*[contains(@distName, 'LNCEL-3')]/*[@name='earfcn']
# ${actDLCAggr}    text|false|//*[@name\="actDLCAggr"]
# ${actULCAggr}    text|false|//*[@name\="actULCAggr"]
# @{PDCCH_congest}    text|true|//*[@name\='enableAmcPdcch']    text|false|//*[@name\='enableLowAgg']    text|false|//*[@name\='actLdPdcch']
# ...                 text|1|//*[@name\='maxNrSymPdcch']    text|true|//*[@name\='enablePcPdcch']    text|8|//*[@name\='maxPhyCces']
# @{gbr_relation}    text|true|//*[@name\='actMultGbrBearers']    text|true|//*[@name\='actMultBearers']   
#    ...     text|true|//*[@name\='actNonGbrServiceDiff']
# ...    text|true|//*[@name\='actEnhAcAndGbrServices']    text|true|//*[@name\='actPdcpRohc']    text|4|//*[@name\='ulsMaxPacketAgg']
# ...    text|true|//*[@name\='actDlsVoicePacketAgg']    text|true|//*[@name\='actDlsOldtc']
# ...    text|MixedFD|//*[contains(@distName, 'LNCEL-1')]/*[@name\='ulsFdPrbAssignAlg']
# ...    text|256|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab1']/item/*[@name='maxGbrDl']
# ...    text|256|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab1']/item/*[@name='maxGbrUl']
# ...    text|2|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab1']/item/*[@name='schedulPrio']
# ...    text|1|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab1']/item/*[@name='lcgid']
# ...    text|2048|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab2']/item/*[@name='maxGbrDl']
# ...    text|512|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab2']/item/*[@name='maxGbrUl']
# ...    text|3|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab2']/item/*[@name='schedulPrio']
# ...    text|2|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab2']/item/*[@name='lcgid']
# ...    text|2048|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab3']/item/*[@name='maxGbrDl']
# ...    text|512|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab3']/item/*[@name='maxGbrUl']
# ...    text|4|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab3']/item/*[@name='schedulPrio']
# ...    text|1|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab3']/item/*[@name='lcgid']
# ...    text|2048|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab4']/item/*[@name='maxGbrDl']
# ...    text|512|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab4']/item/*[@name='maxGbrUl']
# ...    text|5|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab4']/item/*[@name='schedulPrio']
# ...    text|2|//*[contains(@distName, 'LNBTS-1')]/*[@name='qciTab4']/item/*[@name='lcgid']
# @{dlSectorBFWeight_BTS}    text|0|//*[@name\="phaseOfWeighforAntGrp0"]     text|0|//*[@name\="phaseOfWeighforAntGrp1"]
# ...    text|0|//*[@name\="phaseOfWeighforAntGrp2"]    text|0|//*[@name\="phaseOfWeighforAntGrp3"]
# @{modify_list}    ${inactivityTimer}    @{tdd_configuration}    @{TM_mode}    @{earfcn}    ${actDLCAggr}    ${actULCAggr}    @{PDCCH_congest}
# ...    @{gbr_relation}    @{dlSectorBFWeight_BTS} 
# ${lua_bearer1}    trf_type=internal default=on qci=6
# ${lua_bearer7}    qci=8
# @{UE_QCI_BEARER}    0    2    3    4    5    6    1    7    8    9
# 
# *** Test Cases ***
# LTE587_with_PDCCH_DL_block_congest_function
#     [Tags]    QC_22700
#     Step1:Set parameter as precondition ,reset bts and iphy
#     Step2:12UE attached with QCI6 bearer and transmit DL data
#     Step3:UE1/2/3/4/5/6 establish QCI2/3
#     Step4:Transmit DL data on the with the following rate
#     Step5:Decrease radio condition or override CQI for these UEs
#     Step6:Change pdcchAggDefUe to 8
# 
# *** Keywords ***
# Step1:Set parameter as precondition ,reset bts and iphy
#     #enableAmcPdcch AND enablePcPdcch cannot change to false from SRAN20C,so change case to 12UE and add pathloss
#     Start enb and cus syslog'1'
#     Establish cell with bandwidth 20M and frameconfigure 1 7
#     Stop and collect enb and cus syslog
#     collect procotol log '1' from egate
# 
# Establish cell with bandwidth 20M and frameconfigure 1 7
#     ${scfc_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}scfc.xml
#     ${cus_yaml_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}cus_1.yaml
#     copy_file    ${CONFIG_DIR_PATH}/${scfc_name}    ${scfc_path}
#     copy_file    ${CONFIG_DIR_PATH}/${cus_yaml}    ${cus_yaml_path}
#     Modify SCFC into 3cc CA       ${scfc_path}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Load CUS config Files And Wait BTS Onair    ${scfc_path}    ${cus_yaml_path}    enb_swconfig=${eNB_swconfig_path}
# 
# Step2:12UE attached with QCI6 bearer and transmit DL data
#     Start enb and cus syslog'2'
#     #start_capture_ttitrace'2'
#     Run UEx command    ue_attach    id=1..12    ue_eutra_capabilities=CDBFF041034410381DF834624000A006830007A0000068010B210010    cell=1
#     Wait Throughput Timer    10s
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1..12    qci=6    kbps=40000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1..12    qci=6    kbps=10000    trf_id=1    dir=ul    protocol=udp
#     Wait Throughput Timer    10s
#     ${ue1_dl_throughput}    cus_get_dl_throughput_ave    ue_id=1    type=dl_mac
#     ${ue2_dl_throughput}    cus_get_dl_throughput_ave    ue_id=2    type=dl_mac
#     ${ue3_dl_throughput}    cus_get_dl_throughput_ave    ue_id=3    type=dl_mac
#     ${ue4_dl_throughput}    cus_get_dl_throughput_ave    ue_id=4    type=dl_mac
#     #Save_and_Decode_ttitrace_'2'
#     Stop and collect enb and cus syslog
#     collect procotol log '2' from egate
# 
# Step3:UE1/2/3/4/5/6 establish QCI2/3
#     #start_capture_ttitrace'3'
#     run_keyword_and_ignore_error    Run UEx command    bearer_add    ue=1..6    qci=2    mbr_ul=512    mbr_dl=2048    gbr_ul=512    gbr_dl=2048
#     run_keyword_and_ignore_error    Run UEx command    bearer_add    ue=1..6    qci=3    mbr_ul=512    mbr_dl=2048    gbr_ul=512    gbr_dl=2048
#     Wait Throughput Timer    10s
#     #Save_and_Decode_ttitrace_'3'
# 
# Step4:Transmit DL data on the with the following rate
#     #start_capture_ttitrace'4'
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1    qci=2    kbps=1000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1    qci=3    kbps=1000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=2    qci=2    kbps=1000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=2    qci=3    kbps=1000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=3    qci=2    kbps=2000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=3    qci=3    kbps=2000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=4    qci=2    kbps=2000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=4    qci=3    kbps=2000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=5    qci=2    kbps=2000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=5    qci=3    kbps=2000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=6    qci=2    kbps=2000    trf_id=1    dir=dl    protocol=udp
#     run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=6    qci=3    kbps=2000    trf_id=1    dir=dl    protocol=udp
#     Wait Throughput Timer    10s
#     #${ue1_dl_bearer2_throughput}    iphy_get_dl_throughput_ave    ue_id=1    bearer_id=2
#     #${ue2_dl_bearer2_throughput}    iphy_get_dl_throughput_ave    ue_id=2    bearer_id=2
#     #${ue3_dl_bearer2_throughput}    iphy_get_dl_throughput_ave    ue_id=3    bearer_id=2
#     #${ue4_dl_bearer2_throughput}    iphy_get_dl_throughput_ave    ue_id=4    bearer_id=2
#     #${ue5_dl_bearer2_throughput}    iphy_get_dl_throughput_ave    ue_id=5    bearer_id=2
#     #${ue6_dl_bearer2_throughput}    iphy_get_dl_throughput_ave    ue_id=6    bearer_id=2
#     #${ue1_dl_bearer3_throughput}    iphy_get_dl_throughput_ave    ue_id=1    bearer_id=3
#     #${ue2_dl_bearer3_throughput}    iphy_get_dl_throughput_ave    ue_id=2    bearer_id=3
#     #${ue3_dl_bearer3_throughput}    iphy_get_dl_throughput_ave    ue_id=3    bearer_id=3
#     #${ue4_dl_bearer3_throughput}    iphy_get_dl_throughput_ave    ue_id=4    bearer_id=3
#     #${ue5_dl_bearer3_throughput}    iphy_get_dl_throughput_ave    ue_id=5    bearer_id=3
#     #${ue6_dl_bearer3_throughput}    iphy_get_dl_throughput_ave    ue_id=6    bearer_id=3
#     #Save_and_Decode_ttitrace_'4'
# 
# Step5:Decrease radio condition or override CQI for these UEs
#     #start_capture_ttitrace'5'
#     iphy_execute_egate_command     ue_ul_power_control id\=1 pathloss\=120
#     iphy_execute_egate_command     ue_ul_power_control id\=2 pathloss\=120
#     iphy_execute_egate_command     ue_ul_power_control id\=3 pathloss\=120
#     iphy_execute_egate_command     ue_ul_power_control id\=4 pathloss\=120
#     iphy_execute_egate_command     ue_ul_power_control id\=5 pathloss\=120
#     iphy_execute_egate_command     ue_ul_power_control id\=6 pathloss\=120
#     iphy_execute_egate_command     ue_ul_power_control id\=7 pathloss\=120
#     iphy_execute_egate_command     ue_ul_power_control id\=8 pathloss\=120
#     iphy_execute_egate_command     ue_ul_power_control id\=9 pathloss\=120
#     iphy_execute_egate_command     ue_ul_power_control id\=10 pathloss\=120
#     iphy_execute_egate_command     ue_ul_power_control id\=11 pathloss\=120
#     iphy_execute_egate_command     ue_ul_power_control id\=12 pathloss\=120
#     iphy_execute_egate_command     ue_harq_error cell\=current id\=1 ul_err_ratio\=0-6:100:12:5
#     iphy_execute_egate_command     ue_harq_error cell\=current id\=2 ul_err_ratio\=0-6:100:12:5 
#     iphy_execute_egate_command     ue_harq_error cell\=current id\=3 ul_err_ratio\=0-6:100:12:5 
#     iphy_execute_egate_command     ue_harq_error cell\=current id\=4 ul_err_ratio\=0-6:100:12:5 
#     iphy_execute_egate_command     ue_harq_error cell\=current id\=5 ul_err_ratio\=0-6:100:12:5
#     iphy_execute_egate_command     ue_harq_error cell\=current id\=6 ul_err_ratio\=0-6:100:12:5 
#     iphy_execute_egate_command     ue_harq_error cell\=current id\=7 ul_err_ratio\=0-6:100:12:5 
#     iphy_execute_egate_command     ue_harq_error cell\=current id\=8 ul_err_ratio\=0-6:100:12:5
#     iphy_execute_egate_command     ue_harq_error cell\=current id\=9 ul_err_ratio\=0-6:100:12:5
#     iphy_execute_egate_command     ue_harq_error cell\=current id\=10 ul_err_ratio\=0-6:100:12:5 
#     iphy_execute_egate_command     ue_harq_error cell\=current id\=11 ul_err_ratio\=0-6:100:12:5 
#     iphy_execute_egate_command     ue_harq_error cell\=current id\=12 ul_err_ratio\=0-6:100:12:5
#     iphy_execute_egate_command      ue_cqi_param id\=1 wb\=2:2:1
#     iphy_execute_egate_command      ue_cqi_param id\=2 wb\=2:2:1
#     iphy_execute_egate_command      ue_cqi_param id\=3 wb\=2:2:1
#     iphy_execute_egate_command      ue_cqi_param id\=4 wb\=2:2:1
#     iphy_execute_egate_command      ue_cqi_param id\=5 wb\=2:2:1
#     iphy_execute_egate_command      ue_cqi_param id\=6 wb\=2:2:1
#     iphy_execute_egate_command      ue_cqi_param id\=7 wb\=2:2:1
#     iphy_execute_egate_command      ue_cqi_param id\=8 wb\=2:2:1
#     iphy_execute_egate_command      ue_cqi_param id\=9 wb\=2:2:1
#     iphy_execute_egate_command      ue_cqi_param id\=10 wb\=2:2:1
#     iphy_execute_egate_command      ue_cqi_param id\=11 wb\=2:2:1
#     iphy_execute_egate_command      ue_cqi_param id\=12 wb\=2:2:1
#     Wait Throughput Timer    10s
#     #Save_and_Decode_ttitrace_'5'
# 
# Step6:Change pdcchAggDefUe to 8
#     Start enb and cus syslog'6'
#     #start_capture_ttitrace'6'
#     #open debug log of log level'FID_PDCCH'set'DEBUG'on'DL'for'1'
#     #open debug log of log level'FID_DL_CONGESTION'set'DEBUG'on'DL'for'1'
#     #open debug log of log level'FID_UL_CONGESTION'set'DEBUG'on'UL'for'1'
#     setup admin    bts_host=${bts_host}    bts_port=${bts_port}    use_ssl=True    alias=delta_commission
#     perform_delta_recommissioning    delta_file=${CURDIR}/pdcchAggDefUe.json    skip_parameter_relation_errors=${True}    alias=delta_commission
#     teardown admin    alias=delta_commission
#     Wait Throughput Timer    40s
#     #Save_and_Decode_ttitrace_'6'
#     Stop and collect enb and cus syslog
#     collect procotol log '6' from egate
#     ${file_name}=    list_directory    ${TEST LOG DIRECTORY()}/procotol_6
#     ${qci2_release_num}    Grep File    ${TEST LOG DIRECTORY()}/procotol_6/${file_name[0]}/egate_console.log.001
#     ...    Bearer-3 (EBI=6) deleted in result of MME or eNB-Initiated Bearer Deletion procedure
#     ${qci2_release_Count}    Get Line Count    ${qci2_release_num}
#     #should_be_true    ${qci2_release_Count} > 0
# 
# Wait Throughput Timer
#     [Arguments]    ${time}
#     Sleep    ${time}

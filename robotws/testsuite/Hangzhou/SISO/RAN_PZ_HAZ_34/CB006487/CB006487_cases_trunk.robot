# *** Settings ***
# Documentation
# ...               author: Steven Liu
# ...               contact: steven.liu@nokia-sbell.com
# ...               squad group: MMW_SG_04
# Suite Setup       Case Suite Setup
# Suite Teardown
# Resource          ./resources/CB006487_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource          ../../../RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/5GC001937_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Variables         ./resources/6487_scf_modify.py
# Library         ./resources/get_du_version.py
# 
# Force Tags    SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABILB1_2xAWHHF    STATE_SW_UPLOADED
# ...    PY36
# 
# *** Variables ***
# ${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
# ${server_port_ul_hon}       ${tl.ues[1].iperf_details.ports[0]}
# ${server_port_dl_hon}       ${tl.ues[1].iperf_details.ports[1]}
# ${server_port_ul_sam}       ${tl.ues[1].iperf_details.ports[2]}
# ${server_port_dl_sam}       ${tl.ues[1].iperf_details.ports[3]}
# ${server_ip}                ${tl.ues[1].iperf_details.network_interface_address}
# ${scf_22R1}       SCF_SBTS22R1_60_100M.xml
# ${scf_trunk}      SCF_SBTS00_60_100M.xml
# ${scf_21B}        SCF_SBTS21B_60_100M.xml
# ${scf_21A}        SCF_11.800_DU_60_100M.xml
# ${scf_path}             ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T700/
# ${ul_throughput1}              100M
# ${dl_throughput1}              1024M
# ${dl_throughput2}              1024M
# ${ul_peak_100M_h}              52
# ${dl_peak_100M_h}              1260
# ${ul_peak_100M_s}              60
# ${dl_peak_100M_s}              1320
# ${ul_peak_80M_s}               47
# ${dl_peak_80M_s}               1029
# ${ul_peak_60M_s}               32
# ${dl_peak_60M_s}               779
# ${ul_peak_50M_s}               26
# ${dl_peak_50M_s}               630
# ${ul_peak_80M_h}               43
# ${dl_peak_80M_h}               1005
# ${ul_peak_40M_s}               21
# ${dl_peak_40M_s}               501
# ${ul_peak_50M_h}               26
# ${dl_peak_50M_h}               614
# ${ul_peak_20M_h}               10
# ${dl_peak_20M_h}               240
# 
# 
# *** Test Cases ***
# [1]CB006487_A_018_TD_2S_1CC_4DL_4UL_FR1_CPRI_NBF_AWHQM_General_SiSo_E2E_system_setup_with_data_transfer_conducted_2SFP_BW1_20M_BW2_40M
#     [Tags]    CRT_TRUNK   CRT_21B    CRT_22R1     CRT_22R2
#     [Setup]    Modify SCFfile and Commissioning    PARAMS_TO_MODIFY_SCF=${config_18}    default_scf=${scf_path}${scf_name}
#     COAM Wait for gnb ready and cell setup    gnb_type='SA'    timeout=15 min
#     Delete object    objName=${CABLINK_5_distname}
#     Delete object    objName=${CABLINK_3_distname}
#     COAM Wait for gnb ready and cell setup    gnb_type='SA'    timeout=15 min
#     sleep    5 min
#     Make Up Peak and Down Peak    ul_peak_hon=${ul_peak_20M_h}    dl_peak_hon=${dl_peak_20M_h}
#     ...    ul_peak_sam=${ul_peak_40M_s}    dl_peak_sam=${dl_peak_40M_s}
#     ...    ul_throughput=${ul_throughput1}    dl_throughput1=${dl_throughput1}    dl_throughput2=${dl_throughput2}
#     [Teardown]    CB006487_common_keyword.case teardown
# 
# [1]CB006487_A_019_TD_2S_1CC_4DL_4UL_FR1_CPRI_NBF_AWHQM_General_SiSo_E2E_system_setup_with_data_transfer_conducted_2SFP_BW1_40M_BW2_50M
#     [Tags]    CRT_TRUNK   CRT_21B    CRT_22R1     CRT_22R2
#     [Setup]    Modify SCFfile and Commissioning    PARAMS_TO_MODIFY_SCF=${config_19}    default_scf=${scf_path}${scf_name}
#     COAM Wait for gnb ready and cell setup    gnb_type='SA'    timeout=15 min
#     Delete object    objName=${CABLINK_5_distname}
#     Delete object    objName=${CABLINK_3_distname}
#     COAM Wait for gnb ready and cell setup    gnb_type='SA'    timeout=15 min
#     sleep    5 min
#     Make Up Peak and Down Peak    ul_peak_hon=${ul_peak_50M_h}    dl_peak_hon=${dl_peak_50M_h}
#     ...    ul_peak_sam=${ul_peak_40M_s}    dl_peak_sam=${dl_peak_40M_s}
#     ...    ul_throughput=${ul_throughput1}    dl_throughput1=${dl_throughput1}    dl_throughput2=${dl_throughput2}
#     [Teardown]    CB006487_common_keyword.case teardown
# 
# [1]CB006487_A_020_TD_2S_1CC_4DL_4UL_FR1_CPRI_NBF_AWHQM_General_SiSo_E2E_system_setup_with_data_transfer_conducted_2SFP_1QSFP_BW1_40M_BW2_80M
#     [Tags]    CRT_TRUNK   CRT_21B    CRT_22R1     CRT_22R2
#     [Setup]    Modify SCFfile and Commissioning    PARAMS_TO_MODIFY_SCF=${config_20}    default_scf=${scf_path}${scf_name}
#     COAM Wait for gnb ready and cell setup    gnb_type='SA'    timeout=15 min
#     Delete object    objName=${CABLINK_5_distname}
#     COAM Wait for gnb ready and cell setup    gnb_type='SA'    timeout=15 min
#     sleep    5 min
#     Make Up Peak and Down Peak    ul_peak_hon=${ul_peak_80M_h}    dl_peak_hon=${dl_peak_80M_h}
#     ...    ul_peak_sam=${ul_peak_40M_s}    dl_peak_sam=${dl_peak_40M_s}
#     ...    ul_throughput=${ul_throughput1}    dl_throughput1=${dl_throughput1}    dl_throughput2=${dl_throughput2}
#     [Teardown]    CB006487_common_keyword.case teardown
# 
# *** Keywords ***
# Prepare default scf
#     ${connection}    coam.connect_to    bts_host=${DU_IP}     name=GNB_OAM
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${scf_name}     Covert_BTS_Version     ${version}
#     set suite variable    ${scf_name}
#     log to console   ${scf_name}
#     [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
# 
# Case Setup ready
#     COAM Create log directory
# 
# Make Up Peak and Down Peak
#     [Arguments]    ${ul_peak_hon}    ${dl_peak_hon}    ${ul_peak_sam}    ${dl_peak_sam}
#     ...    ${ul_throughput}    ${dl_throughput1}    ${dl_throughput2}
#     honor attach
#     samsung attach
#     log to console    honor start traffic
#     UE start traffic hon       ue_index=${0}    tp_direction=both    time=100s
#     ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput1}    ue_type=huawei
#     ...    iperf_port_ul=${server_port_ul_hon}    iperf_port_dl=${server_port_dl_hon}
#     sleep    5s
#     log to console    samsung start traffic
#     UE start traffic sam       ue_index=${2}    tp_direction=both    time=100s
#     ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput2}    ue_type=samsung
#     ...    iperf_port_ul=${server_port_ul_sam}    iperf_port_dl=${server_port_dl_sam}
# #    UE check throughput     tp_direction=both    exp_ul=${ul_peak_hon}    exp_dl=${dl_peak_hon}    cell_id=11468801
# #    UE check throughput     tp_direction=both    exp_ul=${ul_peak_sam}    exp_dl=${dl_peak_sam}    cell_id=11468802
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=huawei    direction=dl    throughput=${dl_peak_hon}     cellid=11468801
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=huawei    direction=ul    throughput=${ul_peak_hon}     cellid=11468801
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=samsung    direction=dl    throughput=${dl_peak_sam}     cellid=11468802
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=samsung    direction=ul    throughput=${ul_peak_sam}     cellid=11468802
#     power_ue.Stop traffic    ue_index=${0}    ue_type=huawei    direction=ul    iperf_type=via_command
#     ...    iperf_port=${server_port_ul_hon}
#     power_ue.Stop traffic    ue_index=${2}    ue_type=samsung    direction=ul    iperf_type=via_command
#     ...    iperf_port=${server_port_ul_sam}
#     power_ue.Stop traffic    ue_index=${0}    ue_type=huawei    direction=dl    iperf_type=via_command
#     ...    iperf_port=${server_port_dl_hon}
#     power_ue.Stop traffic    ue_index=${2}    ue_type=samsung    direction=dl    iperf_type=via_command
#     ...    iperf_port=${server_port_dl_sam}
# 
# Case Suite Setup
#     [Arguments]
#     CI_interface.Common Suite Setup
#     Prepare default scf

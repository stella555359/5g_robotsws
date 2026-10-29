# *** Settings ***
# Documentation     author: Chen Xiaodong
# ...               contact: xiaodong.d.chen@nokia-sbell.com
# ...               squad group: SG_02
# Suite Setup       679 Suite Setup
# Suite Teardown    679 Suite TearDown
# Force Tags        5G_RRM        5GC000679
# ...    PY36
# Library           OperatingSystem
# Library           Collections
# Library           BuiltIn
# Library           String
# Resource          Resources/5GC000679_common_keyword.robot
# Variables         Resources/CB005892_phase2_FDM_modify_para.py
# 
# *** Variables ***
# ${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
# ${679_Korea_default_scf}    ${tmp_swconfig_dir}/679_900_Korea_A_scf.xml
# ${E500_5892_phase2_10UEs_loop}    ${tmp_swconfig_dir}/E500_scripts_5892_phase2_10UEs_loop
# 
# *** Test Cases ***
# [1]CB005892_FDM_UL_DL_Phase2_10UEs_100MHz_cmW_Loop
#     [Tags]    5GC000679    CIT_20A    
#     [Setup]    Case Setup ready
#     GNB ready
#     : FOR    ${j}    IN RANGE    50
#     \    UEs attach and start DL UL traffic one by one
#     \    sleep    10s
#     \    Check throughput on gNB    direction=dl    throughput=20
#     \    Check throughput on gNB    direction=ul    throughput=5
#     \    Cobham UE detach    e500_script_path=${E500_5892_phase2_10UEs_loop}
#     \    COAM Check GNB cell on air
#     [Teardown]    test case teardown
# 
# *** Keywords ***
# GNB ready
#     [Arguments]    ${PARAMS_TO_MODIFY_SCF}=${PARAMS_TO_MODIFY_Korea_conf_B}    ${679_default_scf}=${679_Korea_default_scf}
#     Modify SCF File and Commissioning    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_SCF}    679_default_scf=${679_default_scf}
#     COAM Wait for gnb ready and cell setup    timeout=15 min
#     Synchron gNB and VIAVI
# 
# Start DL and UL data for one UE
#     [Arguments]    ${index}    ${ul_throughput}=10M    ${dl_throughput}=50M    ${dl_time}=${9999}    
#     ...    ${dl_port}=${52300}    ${dl_length}=${1400}
#     Start DL traffic via iperf on Appserver for one UE    ue_addr=${UE_IP}    dl_time=${dl_time}    dl_port=${dl_port}
#     ...     dl_throughput=${dl_throughput}    dl_length=${dl_length}
#     Start UL traffic via iperf on VIAVI to single UE    traffic_time=300    throughput=${ul_throughput}
#     ...    E500_upload_ip=${E500_upload_ip}    port=@{ul_port_list}[${index}]
# 
# UEs attach and start DL UL traffic one by one
#     : FOR    ${i}    IN RANGE    10
#     \    Cobham UE attach    ue_num=${i}    e500_script_path=${E500_5892_phase2_10UEs_loop}    BW=${100}
#     \    Start DL and UL data for one UE    index=${i}
# 
# test case teardown
#     COAM Save snapshot via rest api
#     Run Keyword And Ignore Error    Recover test ENV
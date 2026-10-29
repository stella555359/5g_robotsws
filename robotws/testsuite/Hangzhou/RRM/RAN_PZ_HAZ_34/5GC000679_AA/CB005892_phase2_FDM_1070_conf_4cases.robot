# *** Settings ***
# Documentation     author: Chen Xiaodong
# ...               contact: xiaodong.d.chen@nokia-sbell.com
# ...               squad group: SG_02
# Suite Setup       679 Suite Setup
# Suite Teardown    679 Suite TearDown
# Force Tags        5G_RRM            5GC000679
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
# ${E500_5892_phase2_Muti_UEs}    ${tmp_swconfig_dir}/E500_scripts_5892_phase2_Muti_UEs
# 
# 
# *** Test Cases ***
# [1][1.0] CB005892_AD_DL_10_Phase2_10UEs_1070_60MHZ_config2_different_granularity_same_SU_MIMO_modes
#     [Tags]    5GC000679    CRT_22R3
#     [Setup]    Case Setup ready
#     GNB is ready and UE attach    ue_num=10    BW=60    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_1070_60MHz}
#     Start DL and UL data for Muti UEs    ue_num=10    ul_throughput=50M    dl_throughput=500M
#     sleep    30s
#     Check throughput on gNB    direction=dl    throughput=400
#     Common Capture BIP log and download
#     Check FDM schedlue two UEs in one slot on DL traffic
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV
# 
# [1][1.0] CB005892_AE_DL_10_Phase2_10UEs_1070_60MHZ_config2_different_granularity_same_SU_MIMO_modes
#     [Tags]    5GC000679
#     [Setup]    Case Setup ready
#     GNB is ready and UE attach    ue_num=10    type=SA    BW=60    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_1070_60MHz}
#     Start DL and UL data for Muti UEs    ue_num=10    ul_throughput=50M    dl_throughput=500M
#     sleep    30s
#     Check throughput on gNB    direction=dl    throughput=400
#     Common Capture BIP log and download
#     Check FDM schedlue two UEs in one slot on DL traffic
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV
# 
# [1][1.0] CB005892_AE_DL_12_Phase2_10UEs_1070_20MHZ_PDCCH_1xRA_UE_1xDRB_perSlotwithoutDCI1_1
#     [Tags]    5GC000679    CRT_22R3
#     [Setup]    Case Setup ready
#     GNB is ready and UE attach    ue_num=10    type=SA    BW=20    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_1070_20MHz}
#     Start DL and UL data for Muti UEs    ue_num=10    ul_throughput=50M    dl_throughput=500M
#     sleep    30s
#     Check throughput on gNB    direction=dl    throughput=400
#     Common Capture BIP log and download
#     Check FDM schedlue two UEs in one slot on DL traffic
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV
# 
# #[1][1.0] CB005892_BI_UL_08_Phase2_10UEs_1070_60MHZ_config2_different_granularity
# #    [Tags]    5GC000679
# #    [Setup]    Case Setup ready
# #    GNB is ready and UE attach    ue_num=10    type=SA    BW=60    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_1070_60MHz}    
# #    Start DL and UL data for Muti UEs    ue_num=10    ul_throughput=140M    dl_throughput=500M
# #    sleep    30s
# #    Common Capture BIP log and download
# #    Check throughput on gNB    direction=ul    throughput=40
# #    Check FDM schedlue two UEs in one slot on UL traffic
# #    [Teardown]    Run Keyword And Ignore Error    Recover test ENV

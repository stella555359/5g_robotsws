# *** Settings ***
# Documentation     author: Chen Xiaodong
# ...               contact: xiaodong.d.chen@nokia-sbell.com
# ...               squad group: SG_02
# Suite Setup       679 Suite Setup
# Suite Teardown    679 Suite TearDown
# Force Tags        5G_RRM            FGCR_8181
# ...    PY36
# Library           OperatingSystem
# Library           Collections
# Library           BuiltIn
# Library           String
# Resource          Resources/5GC000679_common_keyword.robot
# Variables         Resources/FGCR_8181_modify_para.py
# 
# *** Variables ***
# ${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
# ${679_Korea_default_scf}    ${tmp_swconfig_dir}/8181_2subcell_default_scf.xml
# ${E500_8181_Muti_UEs_SA}    ${tmp_swconfig_dir}/E500_scripts_8181_Muti_UEs_SA
# 
# ${pdsch_rnti_dl}    DlData_PdschSendReq.grants_item_15.rnti
# 
# *** Test Cases ***
# [1][1.0] FGCR_8181_AB_02_SA_TDD_DL_scheduling_config2_10UEs_with_2subcell_80MHz_cmW(Full_buffer_all_UEs_all_in_goodRC)
#     [Tags]    FGCR_8181    CRT_22R3
#     [Setup]    Case Setup ready
#     GNB is ready and UE attach    ue_num=10    e500_script_path=${E500_8181_Muti_UEs_SA}
#     ...    BW=${80}    type=SA    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_80MHz}
#     Start DL and UL data for Muti UEs    ue_num=10    ul_throughput=10M    dl_throughput=300M
#     sleep    60s
#     Check throughput on gNB    direction=dl    throughput=200
#     Common Capture BIP log and download
#     Check FDM schedlue two UEs in one slot on DL traffic    crnti_expression=${pdsch_rnti_dl}
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    E500_Muti_UEs=${E500_8181_Muti_UEs_SA}    type=SA
# 
# [1][1.0] FGCR_8181_AB_05_SA_TDD_DL_scheduling_config1_10UEs_with_2subcell_based_on_776_different_beamset_100MHz_cmW(different_QCI)
#     [Tags]    FGCR_8181
#     [Setup]    Case Setup ready
#     GNB is ready and UE attach    ue_num=10    e500_script_path=${E500_8181_Muti_UEs_SA}
#     ...    BW=${100}    type=SA    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_100MHz}
#     Start DL and UL data for Muti UEs    ue_num=10    ul_throughput=10M    dl_throughput=300M
#     sleep    60s
#     Check throughput on gNB    direction=dl    throughput=200
#     Common Capture BIP log and download
#     Check FDM schedlue two UEs in one slot on DL traffic    crnti_expression=${pdsch_rnti_dl}
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    E500_Muti_UEs=${E500_8181_Muti_UEs_SA}    type=SA
# 
# #[1][1.0] FGCR_8181_BB_01_SA_TDD_UL_scheduling_10UEs_with_2subcell_100MHz_cmW(Full_buffer_all_UEs_half_in_goodRC)
# #    [Tags]    FGCR_8181
# #    [Setup]    Case Setup ready
# #    GNB is ready and UE attach    ue_num=10    e500_script_path=${E500_8181_Muti_UEs_SA}
# #    ...    BW=${80}    type=SA    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_80MHz}
# #    Start DL and UL data for Muti UEs    ue_num=10    ul_throughput=150M    dl_throughput=100M
# #    sleep    60s
# #    Check throughput on gNB    direction=ul    throughput=30
# #    Common Capture BIP log and download
# #    Check FDM schedlue two UEs in one slot on UL traffic    item=${rnti_5}
# #    [Teardown]    Run Keyword And Ignore Error    Recover test ENV    E500_Muti_UEs=${E500_8181_Muti_UEs_SA}    type=SA
# 
# [1][1.0] FGCR_8181_BB_04_SA_TDD_DLandUL_scheduling_10UEs_100MHz_cmW
#     [Tags]    FGCR_8181    CIT_20B
#     [Setup]    Case Setup ready
#     GNB is ready and UE attach    ue_num=10    e500_script_path=${E500_8181_Muti_UEs_SA}
#     ...    BW=${100}    type=SA    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_100MHz}
#     Start DL and UL data for Muti UEs    ue_num=10    ul_throughput=150M    dl_throughput=300M
#     sleep    16min
#     Check throughput on gNB    direction=dl    throughput=200
#     Common Capture BIP log and download
#     Check FDM schedlue two UEs in one slot on DL traffic    crnti_expression=${pdsch_rnti_dl}
#     ${counter_allPRB}    Get BTS Counters from webUI    counter_id=M55308C20001
#     Should Contain    ${counter_allPRB}    273
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    E500_Muti_UEs=${E500_8181_Muti_UEs_SA}    type=SA
# 
# #[1][1.0] FGCR_8181_BB_05_SA_TDD_DLandUL_scheduling_10UEs_with_2subcell_based_on_776_different_beamset_100MHz_cmW(different_QCI)
# #    [Tags]    FGCR_8181
# #    [Setup]    Case Setup ready
# #    GNB is ready and UE attach    ue_num=10    e500_script_path=${E500_8181_Muti_UEs_SA}
# #    ...    BW=${100}    type=SA    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_100MHz}
# #    Start DL and UL data for Muti UEs    ue_num=10    ul_throughput=150M    dl_throughput=300M
# #    sleep    60s
# #    Check throughput on gNB    direction=dl    throughput=200
# #    Check throughput on gNB    direction=ul    throughput=30
# #    Common Capture BIP log and download
# #    Check FDM schedlue two UEs in one slot on UL traffic    item=${rnti_5}
# #    Check FDM schedlue two UEs in one slot on DL traffic    crnti_expression=${pdsch_rnti_dl}
# #    [Teardown]    Run Keyword And Ignore Error    Recover test ENV    E500_Muti_UEs=${E500_8181_Muti_UEs_SA}    type=SA

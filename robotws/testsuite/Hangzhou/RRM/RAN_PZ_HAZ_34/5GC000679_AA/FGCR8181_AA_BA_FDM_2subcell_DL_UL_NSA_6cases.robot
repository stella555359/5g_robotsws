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
# ${E500_8181_Muti_UEs}    ${tmp_swconfig_dir}/E500_scripts_8181_Muti_UEs_NSA
# 
# ${pdsch_rnti_dl}    DlData_PdschSendReq.grants_item_15.rnti
# 
# *** Test Cases ***
# [1][1.0] FGCR_8181_AA_01_NSA_TDD_DL_scheduling_config1_10UEs_with_2subcell_100MHz_cmW(Full_buffer_all_UEs_all_in_goodRC)
#     [Tags]    FGCR_8181    CIT_20B
#     [Setup]    Case Setup ready
#     GNB is ready and UE attach    ue_num=10    e500_script_path=${E500_8181_Muti_UEs}
#     ...    BW=${100}    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_100MHz}
#     Start DL and UL data for Muti UEs    ue_num=10    ul_throughput=10M    dl_throughput=300M
#     sleep    16min
#     Check throughput on gNB    direction=dl    throughput=400
#     ${counter_scheUE_DL}    Get BTS Counters from webUI    counter_id=M55308C17002
#     Should Contain    ${counter_scheUE_DL}    8
#     ${counter_allPRB}    Get BTS Counters from webUI    counter_id=M55308C20001
#     Should Contain    ${counter_allPRB}    273
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    E500_Muti_UEs=${E500_8181_Muti_UEs}
# 
# [1][1.0] FGCR_8181_AA_02_NSA_TDD_DL_scheduling_config2_10UEs_with_2subcell_80MHz_cmW(Full_buffer_all_UEs_all_in_goodRC)
#     [Tags]    FGCR_8181    CIT_20B
#     [Setup]    Case Setup ready
#     GNB is ready and UE attach    ue_num=10    e500_script_path=${E500_8181_Muti_UEs}
#     ...    BW=${80}    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_80MHz}
#     Start DL and UL data for Muti UEs    ue_num=10    ul_throughput=10M    dl_throughput=300M
#     sleep    16min
#     Common Capture BIP log and download
#     Check throughput on gNB    direction=dl    throughput=300
#     Check FDM schedlue two UEs in one slot on DL traffic    crnti_expression=${pdsch_rnti_dl}
#     ${counter_allPRB}    Get BTS Counters from webUI    counter_id=M55308C20001
#     Should Contain    ${counter_allPRB}    217
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    E500_Muti_UEs=${E500_8181_Muti_UEs}
# 
# [1][1.0] FGCR_8181_AA_04_NSA_TDD_DL_scheduling_config2_2UEs_alongside_a_dummy_load_80MHz_cmW
#     [Tags]    FGCR_8181
#     [Setup]    Case Setup ready
#     GNB is ready and UE attach    ue_num=2    e500_script_path=${E500_8181_Muti_UEs}
#     ...    BW=${80}    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_80MHz}
#     Start DL and UL data for Muti UEs    ue_num=2    ul_throughput=10M    dl_throughput=800M
#     sleep    40s
#     Common Capture BIP log and download
#     Check throughput on gNB    direction=dl    throughput=300
#     Check FDM schedlue two UEs in one slot on DL traffic    crnti_expression=${pdsch_rnti_dl}
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    E500_Muti_UEs=${E500_8181_Muti_UEs}
# 
# [1][1.0] FGCR_8181_BA_01_NSA_TDD_UL_scheduling_10UEs_with_2subcell_100MHz_cmW(Full_buffer_all_UEs_half_in_goodRC)
#     [Tags]    FGCR_8181    CIT_20B
#     [Setup]    Case Setup ready
#     GNB is ready and UE attach    ue_num=10    e500_script_path=${E500_8181_Muti_UEs}
#     ...    BW=${100}    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_100MHz}
#     Start DL and UL data for Muti UEs    ue_num=10    ul_throughput=150M    dl_throughput=100M
#     sleep    40s
#     Check throughput on gNB    direction=ul    throughput=30
#     sleep    15min
#     ${counter_scheUE_UL}    Get BTS Counters from webUI    counter_id=M55308C18002
#     Should Contain    ${counter_scheUE_UL}    8
#     ${counter_allPRB_UL}    Get BTS Counters from webUI    counter_id=M55308C20002
#     Should Contain    ${counter_allPRB_UL}    273
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    E500_Muti_UEs=${E500_8181_Muti_UEs}
# 
# [1][1.0] FGCR_8181_BA_04_NSA_TDD_DLAndUL_scheduling_10UEs_100MHz_cmW
#     [Tags]    FGCR_8181
#     [Setup]    Case Setup ready
#     GNB is ready and UE attach    ue_num=10    e500_script_path=${E500_8181_Muti_UEs}
#     ...    BW=${100}    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_100MHz}
#     Start DL and UL data for Muti UEs    ue_num=10    ul_throughput=150M    dl_throughput=300M
#     sleep    16min
#     Check throughput on gNB    direction=ul    throughput=30
#     Check throughput on gNB    direction=dl    throughput=200
#     ${counter_scheUE_DL}    Get BTS Counters from webUI    counter_id=M55308C17002
#     Should Contain    ${counter_scheUE_DL}    8
#     ${counter_allPRB_DL}    Get BTS Counters from webUI    counter_id=M55308C20001
#     Should Contain    ${counter_allPRB_DL}    273
#     ${counter_scheUE_UL}    Get BTS Counters from webUI    counter_id=M55308C18002
#     Should Contain    ${counter_scheUE_UL}    8
#     ${counter_allPRB_UL}    Get BTS Counters from webUI    counter_id=M55308C20002
#     Should Contain    ${counter_allPRB_UL}    273
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    E500_Muti_UEs=${E500_8181_Muti_UEs}
# 
# [1][1.0] FGCR_8181_BA_05_NSA_TDD_DLandUL_scheduling_10UEs_with_2subcell_based_on_776_different_beamset_100MHz_cmW(different_QCI)
#     [Tags]    FGCR_8181
#     [Setup]    Case Setup ready
#     GNB is ready and UE attach    ue_num=10    e500_script_path=${E500_8181_Muti_UEs}
#     ...    BW=${100}    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_100MHz}
#     Start DL and UL data for Muti UEs    ue_num=10    ul_throughput=150M    dl_throughput=300M
#     sleep    16min
#     Common Capture BIP log and download
#     Check throughput on gNB    direction=ul    throughput=30
#     Check throughput on gNB    direction=dl    throughput=200
#     ${counter_scheUE_DL}    Get BTS Counters from webUI    counter_id=M55308C17002
#     Should Contain    ${counter_scheUE_DL}    8
#     ${counter_allPRB_DL}    Get BTS Counters from webUI    counter_id=M55308C20001
#     Should Contain    ${counter_allPRB_DL}    273
#     ${counter_scheUE_UL}    Get BTS Counters from webUI    counter_id=M55308C18002
#     Should Contain    ${counter_scheUE_UL}    8
#     ${counter_allPRB_UL}    Get BTS Counters from webUI    counter_id=M55308C20002
#     Should Contain    ${counter_allPRB_UL}    273
#     [Teardown]    Run Keyword And Ignore Error    Recover test ENV    E500_Muti_UEs=${E500_8181_Muti_UEs}
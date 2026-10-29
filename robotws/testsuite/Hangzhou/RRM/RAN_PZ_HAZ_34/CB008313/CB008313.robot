# # # @Time    : 2022/1/10 10:32
# # # @Author  : Jian.1.Chen
# # # @Email   : jian.1.chen@nokia-sbell.com
# # # @File    : CB008313.robot
# # # @Software: PyCharm
# # # @Doc     : Some Description
# # *** Settings ***
# # Documentation
# # ...    author: Chen Jian
# # ...    contact: jian.1.chen@nokia-sbell.com
# # ...    squad group: 5G_PZ_MMW_HZ_3_SG05
# # ...    Feature CB008313_B_5GC000938-C
# # 
# # Suite Setup    CI_interface.Common Suite Setup
# # 
# # Resource    CB008313_precondition.robot
# # Resource    CB008313_keywords.robot
# # Force Tags    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4
# # ...    PY36
# # 
# # *** Variables ***
# # # Local Pcap Path
# # ${LOCAL_PCAP_PATH}    /home/ute/MMW_SG5/CB008313
# # # GNB info
# # ${NR_CELL_ID}    178520065
# # # chBwDl = 20M & chBwUl = 20M, the through put stand
# # ${20M_UL_TP}            150M
# # ${20M_UL_TP_THRESHOLD}  80
# # ${20M_DL_TP}            300M
# # ${20M_DL_TP_THRESHOLD}  150
# # # chBwDl = 15M & chBwUl = 15M, the through put stand
# # ${15M_UL_TP}            100M
# # ${15M_UL_TP_THRESHOLD}  50
# # ${15M_DL_TP}            200M
# # ${15M_DL_TP_THRESHOLD}  120
# # # chBwDl = 5M & chBwUl = 5M, the through put stand
# # ${5M_UL_TP}             50M
# # ${5M_UL_TP_THRESHOLD}   10
# # ${5M_DL_TP}             100M
# # ${5M_DL_TP_THRESHOLD}   40
# # # Prach index
# # ${PRACH_INDEX_9}    9
# # ${PRACH_INDEX_12}  12
# # ${PRACH_INDEX_36}  36
# # ${PRACH_INDEX_37}  37
# # ${PRACH_INDEX_38}  38
# # ${PRACH_INDEX_40}  40
# # ${PRACH_INDEX_41}  41
# # ${PRACH_INDEX_42}  42
# # 
# # *** Test Cases ***
# # [1]CB008313_B_201_5GC000938-C_01_Enable_Disable_20ms_PRACH_Format_1_SA_FDD_FR1_20MHz
# #     [Documentation]    Author: jian.1.chen@nokia-sbell.com
# #     [Tags]    case201
# #     Case 201 Precondition
# #     ${local_pcap_path}    Set Variable    ${LOCAL_PCAP_PATH}/case201.pcap
# #     @{prach_configuration_index_list}    Create List    ${PRACH_INDEX_12}
# #     ...    ${PRACH_INDEX_40}    ${PRACH_INDEX_41}    ${PRACH_INDEX_42}
# #     Verify Target Prach List Available    prach_configuration_index_list=@{prach_configuration_index_list}
# #     ...    ul_tp=${20M_UL_TP}    ul_tp_threshold=${20M_UL_TP_THRESHOLD}
# #     ...    dl_tp=${20M_DL_TP}    dl_tp_threshold=${20M_DL_TP_THRESHOLD}
# #     ...    cellid=${NR_CELL_ID}    local_pcap_path=${local_pcap_path}    attach_mode=SA
# # 
# # [1]CB008313_B_202_5GC000938-C_08_Enable_Disable_40ms_PRACH_Format_1_SA_FDD_FR1_5MHz
# #     [Documentation]    Author: jian.1.chen@nokia-sbell.com
# #     [Tags]    case202
# #     Case 202 Precondition
# #     ${local_pcap_path}    Set Variable    ${LOCAL_PCAP_PATH}/case202.pcap
# #     @{prach_configuration_index_list}    Create List    ${PRACH_INDEX_12}
# #     ...    ${PRACH_INDEX_36}    ${PRACH_INDEX_37}    ${PRACH_INDEX_38}
# #     Verify Target Prach List Available    prach_configuration_index_list=@{prach_configuration_index_list}
# #     ...    ul_tp=${5M_UL_TP}    ul_tp_threshold=${5M_UL_TP_THRESHOLD}
# #     ...    dl_tp=${5M_DL_TP}    dl_tp_threshold=${5M_DL_TP_THRESHOLD}
# #     ...    cellid=${NR_CELL_ID}    local_pcap_path=${local_pcap_path}    attach_mode=SA
# # 
# # [1]CB008313_B_206_5GC000938-C_29_Enable_Disable_20ms_PRACH_Format_1_NSA_FDD_FR1_20MHz
# #     [Documentation]    Author: jian.1.chen@nokia-sbell.com
# #     [Tags]    case206
# #     Case 206 Precondition
# #     ${local_pcap_path}    Set Variable    ${LOCAL_PCAP_PATH}/case206.pcap
# #     @{prach_configuration_index_list}    Create List    ${PRACH_INDEX_12}
# #     ...    ${PRACH_INDEX_40}    ${PRACH_INDEX_41}    ${PRACH_INDEX_42}
# #     Verify Target Prach List Available    prach_configuration_index_list=@{prach_configuration_index_list}
# #     ...    ul_tp=${20M_UL_TP}    ul_tp_threshold=${20M_UL_TP_THRESHOLD}
# #     ...    dl_tp=${20M_DL_TP}    dl_tp_threshold=${20M_DL_TP_THRESHOLD}
# #     ...    cellid=${NR_CELL_ID}    local_pcap_path=${local_pcap_path}    attach_mode=NSA
# #     Convert BTS Mode To SA
# # 
# # [1]CB008313_B_207_5GC000938-C_30_Enable_Disable_20ms_PRACH_Format_1_NSA_FDD_FR1_15MHz
# #     [Documentation]    Author: jian.1.chen@nokia-sbell.com
# #     [Tags]    case207
# #     Case 207 Precondition
# #     ${local_pcap_path}    Set Variable    ${LOCAL_PCAP_PATH}/case207.pcap
# #     @{prach_configuration_index_list}    Create List    ${PRACH_INDEX_9}
# #     ...    ${PRACH_INDEX_40}    ${PRACH_INDEX_41}    ${PRACH_INDEX_42}
# #     Verify Target Prach List Available    prach_configuration_index_list=@{prach_configuration_index_list}
# #     ...    ul_tp=${15M_UL_TP}    ul_tp_threshold=${15M_UL_TP_THRESHOLD}
# #     ...    dl_tp=${15M_DL_TP}    dl_tp_threshold=${15M_DL_TP_THRESHOLD}
# #     ...    cellid=${NR_CELL_ID}    local_pcap_path=${local_pcap_path}    attach_mode=NSA
# #     Convert BTS Mode To SA
# # 
# # [1]CB008313_B_208_5GC000938-C_32_Enable_Disable_20ms_PRACH_Format_1_NSA_FDD_FR1_5MHz
# #     [Documentation]    Author: jian.1.chen@nokia-sbell.com
# #     [Tags]    case208
# #     Case 208 Precondition
# #     ${local_pcap_path}    Set Variable    ${LOCAL_PCAP_PATH}/case208.pcap
# #     @{prach_configuration_index_list}    Create List    ${PRACH_INDEX_12}
# #     ...    ${PRACH_INDEX_40}    ${PRACH_INDEX_41}    ${PRACH_INDEX_42}
# #     Verify Target Prach List Available    prach_configuration_index_list=@{prach_configuration_index_list}
# #     ...    ul_tp=${5M_UL_TP}    ul_tp_threshold=${5M_UL_TP_THRESHOLD}
# #     ...    dl_tp=${5M_DL_TP}    dl_tp_threshold=${5M_DL_TP_THRESHOLD}
# #     ...    cellid=${NR_CELL_ID}    local_pcap_path=${local_pcap_path}    attach_mode=NSA
# #     Convert BTS Mode To SA
# # 
# # [1]CB008313_B_209_5GC000938-C_36_Enable_Disable_40ms_PRACH_Format_1_NSA_FDD_FR1_5MHz
# #     [Documentation]    Author: jian.1.chen@nokia-sbell.com
# #     [Tags]    case209
# #     Case 209 Precondition
# #     ${local_pcap_path}    Set Variable    ${LOCAL_PCAP_PATH}/case209.pcap
# #     @{prach_configuration_index_list}    Create List    ${PRACH_INDEX_36}
# #     ...    ${PRACH_INDEX_37}    ${PRACH_INDEX_38}
# #     Verify Target Prach List Available    prach_configuration_index_list=@{prach_configuration_index_list}
# #     ...    ul_tp=${5M_UL_TP}    ul_tp_threshold=${5M_UL_TP_THRESHOLD}
# #     ...    dl_tp=${5M_DL_TP}    dl_tp_threshold=${5M_DL_TP_THRESHOLD}
# #     ...    cellid=${NR_CELL_ID}    local_pcap_path=${local_pcap_path}    attach_mode=NSA
# #     Convert BTS Mode To SA

# *** Settings ***
# Documentation
# ...   author: zheyuan.chen@nokia-sbell.com/ruizhi.zhang@nokia-sbell.com
# ...   contact: ruizhi.zhang@nokia-sbell.com
# ...   SISO
# 
# Resource    ./resources/comm_9181.robot
# Resource    ../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# Suite Setup       CB009181 Suite Setup
# 
# *** Test Cases ***
# [1]CB009181-SR-B_002_L3_call_on_WB_configurationg_FDD_TDD_cells_simultaneously
#     [Documentation]
#     ...    The purpose of this user scenario is to test full ABIP deployment in NR TDD and NR FDD concurrent mode
#     ...    -28.06.2023,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_24R1    CRT_TRUNK    CB009181
#     [Setup]      robot_common_operations.Common Case Setup
#     Check BTS Should Be Normal
#     check unexpected alarm
#     Xiaomi_UE_Attach    ue_sn=${UE0_SN}    ue_index=${0}
#     Xiaomi_UE_Attach    ue_sn=${UE1_SN}    ue_index=${1}
#     UEs Start Traffic Together    tp_ul1=70M    tp_dl1=1600M    tp_ul2=120M    tp_dl2=900M
#     sleep    30s
#     Check UE Throughput    target_tp_ul=50    target_tp_dl=1420    nrcell_id=${593411}    target_avg_percent=${1}
#     Check UE Throughput    target_tp_ul=100    target_tp_dl=810    nrcell_id=${593414}    target_avg_percent=${1}
#     Stop Traffic And UE Detach    ue_index=${0}    port1=${0}    port2=${1}
#     Stop Traffic And UE Detach    ue_index=${1}    port1=${2}    port2=${3}
#     [Teardown]    Run Keyword And Ignore Error    SBTS Logout       CI_interface.Common Case Teardown
# 
# [1]CB009181-SR-E_006_General_SiSo_SBTS_reset_without_HWF_in_loop
#     [Documentation]
#     ...    The purpose of this user scenario is to test full ABIP deployment in NR TDD and NR FDD concurrent mode
#     ...    set the cell band with as below: Configure intra-baseband board 2 or 3 CC CA
#     ...    -13.06.2023,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_24R1    CRT_TRUNK    CB009181
#     [Setup]      robot_common_operations.Common Case Setup
#     FOR    ${item}    IN RANGE    ${1}
#         Reset without HWF
#     END
#     [Teardown]    Run Keyword And Ignore Error    SBTS Logout      CI_interface.Common Case Teardown
# 
# [1]CB009181-SR-B_009_SiSo_RF_module_Web_reset_and_power_reset
#     [Documentation]
#     ...    The purpose of this user scenario is to test full ABIP deployment in NR TDD and NR FDD concurrent mode
#     ...    set the cell band with as below: Configure intra-baseband board 2 or 3 CC CA
#     ...    -28.06.2023,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_24R1    CRT_TRUNK    CB009181
#     [Setup]      robot_common_operations.Common Case Setup
#     Check BTS Should Be Normal
#     check unexpected alarm
#     Reset TDD/FDD RMOD   RU1_index=${7}    RU2_index=${5}
#     Check BTS Should Be Normal
#     sleep    2min
#     UE Start Traffic And Check Throughput New
#     Power OFF/ON TDD/FDD RMOD
#     Check BTS Should Be Normal
#     sleep    3min
#     UE Start Traffic And Check Throughput New
#     [Teardown]    Run Keyword And Ignore Error    SBTS Logout      CI_interface.Common Case Teardown
# 
# [1]CB009181-SR-E_001_L3_call_on_NB_configurationg_FDD_TDD_cells_simultaneously
#     [Documentation]
#     ...    The purpose of this user scenario is to test full ABIP deployment in NR TDD and NR FDD concurrent mode
#     ...    -27.06.2023,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_24R1    CRT_TRUNK    CB009181
#     [Setup]      robot_common_operations.Common Case Setup
#     Input SCF    SBTS_scf_name=SCF_SBTS00_case01.xml    Branch_scf_name=SCF_SBTS24R1_case01.xml
#     Check BTS Should Be Normal
#     check unexpected alarm
#     block_cell        cell_idx=${1}
#     Xiaomi_UE_Attach    ue_sn=${UE0_SN}    ue_index=${0}
#     Xiaomi_UE_Attach    ue_sn=${UE1_SN}    ue_index=${1}
#     UEs Start Traffic Together    tp_ul1=70M    tp_dl1=1600M    tp_ul2=120M    tp_dl2=430M
#     sleep    30s
#     Check UE Throughput    target_tp_ul=50    target_tp_dl=1420    nrcell_id=${593411}    target_avg_percent=${1}
#     Check UE Throughput    target_tp_ul=100    target_tp_dl=390    nrcell_id=${593414}    target_avg_percent=${1}
#     Stop Traffic And UE Detach    ue_index=${0}    port1=${0}    port2=${1}
#     Stop Traffic And UE Detach    ue_index=${1}    port1=${2}    port2=${3}
#     unblock_cell       cell_idx=${1}
#     Check BTS Should Be Normal
#     block_cell        cell_idx=${6}
#     Xiaomi_UE_Attach    ue_sn=${UE0_SN}    ue_index=${0}
#     Xiaomi_UE_Attach    ue_sn=${UE1_SN}    ue_index=${1}
#     UEs Start Traffic Together    tp_ul1=70M    tp_dl1=1600M    tp_ul2=120M    tp_dl2=430M
#     sleep    30s
#     Check UE Throughput    target_tp_ul=50    target_tp_dl=1420    nrcell_id=${593411}    target_avg_percent=${1}
#     Check UE Throughput    target_tp_ul=100    target_tp_dl=390    nrcell_id=${593409}    target_avg_percent=${1}
#     Stop Traffic And UE Detach    ue_index=${0}    port1=${0}    port2=${1}
#     Stop Traffic And UE Detach    ue_index=${1}    port1=${2}    port2=${3}
#     unblock_cell       cell_idx=${6}
#     Check BTS Should Be Normal
#     [Teardown]    Run Keyword And Ignore Error    SBTS Logout        CI_interface.Common Case Teardown
# 
# *** Keywords ***

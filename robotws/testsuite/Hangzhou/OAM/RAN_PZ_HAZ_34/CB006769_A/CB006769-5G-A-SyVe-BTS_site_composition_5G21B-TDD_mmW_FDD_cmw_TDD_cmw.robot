# *** Settings ***
# Force Tags    PY36
# Documentation
# ...   author: zheyuan.chen@nokia-sbell.com
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   mix module
# 
# Suite Setup          robot_common_operations.Common Suite Setup
# Suite Teardown       robot_common_operations.Common Suite Teardown
# 
# Resource    resources/comm_6769A.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Test Cases ***
# [1]CB006769-5G-A-2 SyV_test_Use_IPV4_to_build_ASIB+ABIL_TDD+FDD_mix_modle_NSA_site
#     [Documentation]
#     ...    The purpose of this case is to verify the mix of supported configuration blocks,
#     ...    and to verify whether the BTS IPV4 configuration is successful when using the ASIB public card.
#     ...    -03.06.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_21B    CIT_TRUNK    CB006769-A
#     [Setup]    case_setup
#     Check BTS Should Be Normal
#     UEs Attach Start Traffic And Check Throughput
#     Start Catch BTS Log
#     Reset BTS And Wait Until On Air
#     Stop and collect btslog on local machine
#     Check CA Point
#     ${status1}    run keyword and return status    Check if Unexpected History Alarm Exist
#     run keyword unless    ${status1}    Save Snapshot Log
#     UEs Attach Start Traffic And Check Throughput
#     Power Off BTS And Wait Until On Air
#     ${status2}    run keyword and return status     Check if Unexpected History Alarm Exist
#     UEs Attach Start Traffic And Check Throughput
#     run keyword unless    ${status2}    Save Snapshot Log
#     [Teardown]    case teardown
# 
# [1]CB006769-5G-A-3_SyV_test_Use_IPV6_to_build_ASIB+ABIL_TDD+FDD_mix_modle_NSA_site
#     [Documentation]
#     ...    The purpose of this case is to verify the mix of supported configuration blocks,
#     ...    and to verify whether the BTS IPV6 configuration is successful when using the ASIB public card.
#     ...    -14.05.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_21B    CB006769-A
#     [Setup]    case_setup
#     Check BTS Should Be Normal
#     UEs Attach Start Traffic And Check Throughput
# #    Reset BTS And Wait Until On Air
# #    run keyword and continue on failure    Check if Unexpected History Alarm Exist
# #    UEs Attach Start Traffic And Check Throughput
#     Power Off BTS And Wait Until On Air
#     run keyword and continue on failure    Check if Unexpected History Alarm Exist
#     UEs Attach Start Traffic And Check Throughput
#     [Teardown]    CI_interface.Common Case Teardown
# 
# [1]CB006769-5G-A-4 SyV_Test the impact of restarting BMOD on the base station
#     [Documentation]
#     ...    The purpose of this situation is to verify the mix of supported configuration blocks,
#     ...    and to verify that restarting BBMOD alone when using the ASIB public card will not affect the remaining cells.
#     ...    -21.05.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R2    CRT_21B    CIT_TRUNK    CB006769-A
#     [Setup]    case_setup
#     Check BTS Should Be Normal
#     #UEs Attach Start Traffic And Check Throughput
#     Restart BBMOD And Check UEs Attatch    BBMOD_idx=${1}    ue_index=${0}
#     run keyword and continue on failure    Check if Unexpected History Alarm Exist
#     Restart BBMOD And Check UEs Attatch    BBMOD_idx=${2}    ue_index=${1}
#     run keyword and continue on failure    Check if Unexpected History Alarm Exist
#     Restart BBMOD And Check UEs Attatch    BBMOD_idx=${3}    ue_index=${2}
#     run keyword and continue on failure    Check if Unexpected History Alarm Exist
#     [Teardown]    case teardown
# 
# [1]CB006769-5G-A-6 SyV_Test lock and unlock cell NSA site
#     [Documentation]
#     ...    The purpose of this case is to verify the mix of supported configuration blocks,
#     ...    and to verify whether the BTS IPV4 configuration is successful when using the ASIB public card.
#     ...    -14.05.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_21B    CRT_TRUNK    CB006769-A
#     [Setup]    case_setup
#     Check BTS Should Be Normal
#     UEs Attach Start Traffic And Check Throughput
#     Lock Cell And Check UE Attach    cell_idx=${5}    ue_index1=${0}    ue_index2=${1}    port2=${1}    ue_index3=${2}
#     ...    port3=${2}    cell_list2=${1}    cell_list3=${2}    physcell_ID2=@{PCI_list}[1]    physcell_ID3=@{PCI_list}[2]
#     Lock Cell And Check UE Attach    cell_idx=${7}    ue_index1=${1}    ue_index2=${0}    port2=${0}    ue_index3=${2}
#     ...    port3=${2}    cell_list2=${0}    cell_list3=${2}    physcell_ID2=@{PCI_list}[0]    physcell_ID3=@{PCI_list}[2]
#     Lock Cell-group And Check UE Attach    ue_index1=${2}    ue_index2=${0}    port2=${0}    ue_index3=${1}    port3=${1}
#     ...    cell_list2=${0}    cell_list3=${1}    physcell_ID2=@{PCI_list}[0]    physcell_ID3=@{PCI_list}[1]
#     run keyword and continue on failure    Lock BTS And Check UE Attach Failed
#     Unlock BTS And Check UE Attach Success
#     run keyword and continue on failure    Check if Unexpected History Alarm Exist
#     [Teardown]    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Restart BBMOD And Check UEs Attatch
#     [Arguments]    ${BBMOD_idx}    ${ue_index}
#     Restart BBMOD    BBMOD_idx=${BBMOD_idx}
#     #UEs Attach Start Traffic And Check Throughput
#     Single UE Attach Start Traffic And Check Throughput    ue_index=${ue_index}
# 
# Lock Cell And Check UE Attach
#     [Arguments]    ${cell_idx}    ${ue_index1}    ${ue_index2}    ${port2}    ${ue_index3}     ${port3}
#     ...    ${cell_list2}    ${cell_list3}    ${physcell_ID2}    ${physcell_ID3}
#     Lock Cell    cell_idx=${cell_idx}
#     Single UE Attach Failed    ue_index=${ue_index1}
#     Single UE Attach And Check Attach Request    ue_index=${ue_index2}    cell_list=${cell_list2}
#     Single UE Start Traffic And Check Throughput    physcell_ID=${physcell_ID2}    ue_index=${ue_index2}    port=${port2}
#     Single UE Attach And Check Attach Request    ue_index=${ue_index3}    cell_list=${cell_list3}
#     Single UE Start Traffic And Check Throughput    physcell_ID=${physcell_ID3}    ue_index=${ue_index3}    port=${port3}
#     [Teardown]    Unlock Cell    cell_idx=${cell_idx}
# 
# Lock Cell-group And Check UE Attach
#     [Arguments]    ${ue_index1}    ${ue_index2}    ${port2}    ${ue_index3}     ${port3}    ${cell_list2}    ${cell_list3}
#     ...    ${physcell_ID2}    ${physcell_ID3}
#     Lock Cellgroup
#     sleep    15s
#     run keyword and ignore error    Single UE Attach Failed    ue_index=${ue_index1}
#     Single UE Attach And Check Attach Request    ue_index=${ue_index2}    cell_list=${cell_list2}
#     Single UE Start Traffic And Check Throughput    physcell_ID=${physcell_ID2}    ue_index=${ue_index2}    port=${port2}
#     Single UE Attach And Check Attach Request    ue_index=${ue_index3}    cell_list=${cell_list3}
#     Single UE Start Traffic And Check Throughput    physcell_ID=${physcell_ID3}    ue_index=${ue_index3}    port=${port3}
#     [Teardown]    Unlock Cellgroup
# 
# Lock BTS And Check UE Attach Failed
#     Lock BTS
#     UEs Attach Failed
# 
# Unlock BTS And Check UE Attach Success
#     Unlock BTS
#     UEs Attach Start Traffic And Check Throughput
# 
# case_setup
#     [Arguments]
#     robot_common_operations.Common Case Setup
#     ${default_scf1}    suite setup to prepare default scf    DU_OAM_IP=${DU_OAM_IP}
#     Commission Default SCF    ip_address=${DU_OAM_IP}    default_scf=${default_scf1}
# #    ${default_scf2}    suite setup to prepare default scf    DU_OAM_IP=${ENB_OAM_IP}    SBTS_scf_name=${eNB_SBTS_scf}
# #    ...    Branch_scf_name=${eNB_Branch_scf}
# #    Commission Default SCF    ip_address=${ENB_OAM_IP}    default_scf=${default_scf2}
# 
# case teardown
#     robot_common_operations.Common Case Teardown
#     CI_interface.Common Case Teardown

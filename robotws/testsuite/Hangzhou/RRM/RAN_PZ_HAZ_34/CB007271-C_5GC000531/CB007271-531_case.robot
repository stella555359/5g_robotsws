# *** Settings ***
# Documentation    author:x1liu
# ...              contact:xiaojing.2.liu@nokia-sbell.com
# ...              aquad group：MMW_SG_04
# 
# Resource    resources/CB007271-531_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# *** Variable ***
# @{rdflags_rank1_TPMI1}    0x580017=1
# ${cell_1}    ${176529}
# ${7432_eNB_PB_ASIK_IP}         ${tl.enbs[1].airscale.common_units[0].pdu_port.pdu.addr}
# ${7432_eNB_PB_ASIK_PORT}       ${tl.enbs[1].airscale.common_units[0].pdu_port.port_no}
# ${model}    HBTE
# ${CURDIR_path}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/
# ${swconfig_path}          ${CURDIR}/resources/
# ${gNB_ip}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# @{counter_mcs_rank1}    M55301C15026    M55301C15027    M55301C04003
# 
# *** Test Cases ***
# CB007271-C_5GC000531_004_Close loop rank2 PDSCH transmission with adaptive PMI below6Ghz
#     [Documentation]
#     ...    This case is tested under rank2, use an empty swconfig file to replace setting rank2.
#     [Tags]    CRT_22R2    CRT_TRUNK    7271_531_classical_SA
#     [Setup]
#     replace rdflag Swconfig File
#     ${cell_id}    create list    ${cell_1}
#     Single UE Attach
#     ${tput_result}    Start Traffic and Get Tput    cell_id=${cell_id}
#     Single UE Attach
#     Start Traffic And Capture BIP Log
#     Check CSI And RANK Message
#     get and check total tput    tput_result=${tput_result}[0]
#     [Teardown]    case_teardown
# 
# CB007271-C_5GC000531_007__Counter_PDSCH transmission in rank1 with MSC xx
#     [Documentation]
#     ...    This test scenario is used to verify the 5gNB schedules CSI-RS transmissions
#     ...    and schedules PDSCH transmissions rank 1 with PMI_3 .
#     ...    cotain CB007271-C_5GC000531_007__Counter_PDSCH transmission in rank1 with MSC xx
#     ...    cotain CB007271-C_5GC000531_008__Counter_PDSCH transmission in rank1 with PMI xx
#     ...    modified according to case
#     ...    CB007403-C_5GC000531_003_Closelooprank_1_PDSCH_transmission_with_adaptive_PMI_above6Ghz
#     [Tags]    CRT_TRUNK    CRT_22R3   7271_531_classical_SA    CRT_22R4
#     [Setup]  case_setup    params=@{rdflags_rank1_TPMI1}
#     Single UE Attach
#     Start Traffic And Capture BIP Log
#     Check RANK And TPMI Message
#     ${counter_result_list}    Check PUSCH Counter    counter_rank=@{counter_mcs_rank1}
#     Check MCS Counter    counter_result_list=${counter_result_list}
#     Check PMI Counter    counter_result_list=${counter_result_list}
#     [Teardown]    case_teardown
# 
# [1]CB007271-C_5GC000531_008__Counter_PDSCH transmission in rank1 with PMI xx
#     [Tags]    CRT_TRUNK    CRT_22R3   7271_531_classical_SA    CRT_22R4
#     [Setup]    robot_common_operations.Common case Setup
#     Single UE Attach
# #    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS
#     [Teardown]    robot_common_operations.Common Case Teardown

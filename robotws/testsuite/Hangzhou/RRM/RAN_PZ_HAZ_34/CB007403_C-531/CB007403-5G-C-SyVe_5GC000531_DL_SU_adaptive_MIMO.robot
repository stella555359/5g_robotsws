# *** Settings ***
# Force Tags    PY36
# 
# #Suite Setup     Suite Setup
# #Suite Teardown    Suite Teardown
# Suite Setup        robot_common_operations.Common Suite Setup
# Suite Teardown     robot_common_operations.Common Suite Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    resources/comm_7403-531.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variable ***
# @{counter_mcs_rank1}    M55301C00027    M55301C00028    M55301C04001    M55301C04002    M55301C04003
# 
# *** Test Cases ***
# [1]CB007403-C_5GC000531_003_Closelooprank_1_PDSCH_transmission_with_adaptive_PMI_above6Ghz
#     [Documentation]
#     ...    This test scenario is used to verify the 5gNB schedules CSI-RS transmissions and schedules PDSCH transmissions rank 1 with PMI_1 .
#     ...    cotain CB007403-C_5GC000531_007_Counter_PDSCH transmission in rank1 with MSC xx
#     ...    cotain CB007403-C_5GC000531_008__Counter_PDSCH transmission in rank1 with PMI xx
#     ...    -30.08.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CB007403-C
#     [Setup]    case_setup    params=@{rdflags_rank1_TPMI1}
#     Check BTS Should Be Normal
#     Single UE Attach
#     Start Traffic And Capture BIP Log
#     Check RANK And TPMI Message
# #    ${if_22R1_version}    Judge Version
# #    ${counter_result_list}    run keyword if    '${if_22R1_version}' == 'True'    Check PUSCH Counter    counter_rank=@{counter_mcs_rank1}
# #    run keyword if    '${if_22R1_version}' == 'True'    Check MCS Counter    counter_result_list=${counter_result_list}
# #    run keyword if    '${if_22R1_version}' == 'True'    Check PMI Counter    counter_result_list=${counter_result_list}
#     [Teardown]    case_teardown
# 
# #[1]CB007403-C_5GC000531_007_Counter_PDSCH_transmission_in_ran_1_with_MSC_xx
# #    [Tags]    CB007403-C
# #    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS
# 
# #[1]CB007403-C_5GC000531_008_Counter_PDSCH_transmission_in_ran_1_with_PMI_xx
# #    [Tags]    CB007403-C
# #    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS
# 
# [1]CB007403-C_5GC000531_004_Close_loop_rank_2_PDSCHtransmission_with_fixed PMI_1_above6Ghz
#     [Documentation]
#     ...    This test scenario is used to verify the 5gNB schedules CSI-RS transmissions and schedules PDSCH transmissions rank 2 with PMI_1.
#     ...    -10.09.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CB007403-C
#     [Setup]    case_setup    params=@{rdflags_rank2_TPMI1}
#     Check BTS Should Be Normal
#     Single UE Attach
#     Start Traffic And Capture BIP Log And Check Throughput
#     Check RANK2 And TPMI Message
#     comm_7403-531.Check Peak Throughput
#     [Teardown]    case_teardown
# 
# [1]CB007403-C_5GC000531_005_Open_loop_rank_1_PDSCH_transmission_with_no_precoding_scheme_above6Ghz
#     [Documentation]
#     ...    This test scenario is used to verify Open Loop (OL) rank 1 PDSCH transmission with no precoding scheme.
#     ...    -10.09.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CB007403-C
#     [Setup]    case_setup    params=@{rdflags_rank1}
#     Modify Mimomode Parameter    Actual_value=2x2 Open Loop Spatial Multiplexing
#     Single UE Attach
#     Start Traffic And Capture BIP Log And Check Throughput
#     Check RANK1
#     comm_7403-531.Check Peak Throughput
#     [Teardown]    case_teardown
# 
# *** Keywords ***
# Check RANK And TPMI Message
#     [Arguments]    ${item1}=numOfLayers (Uint8)    ${item2}=codebookIndex    ${item3}=NUM_OF_PUCCH_LAYERS_VAL_1    ${flayer_num}=${1}
#     ...    ${layer_num}=NUM_OF_PUCCH_LAYERS_VAL_1(1)
#     Log To Console    Check Rank In Pdsch
#     ${value_list1}    Grep Message From TXT To List    filter1=DlData_PdschGrant.numOfLayers    txt_filename=PdschSendReq.txt     item=${item1}
#     FOR    ${item_value}    IN    @{value_list1}
#         should be equal as numbers    ${item_value}    ${flayer_num}
#     END
#     Log To Console    Check TPMI
#     ${value_list2}    Grep Message From TXT To List    filter1=DlData_PdschGrant.codebookIndex    txt_filename=PdschSendReq2.txt
#     ...    item=${item2}
#     should not be empty    ${value_list2}
#     ${stauts1}    ${stauts2}    ${stauts3}    Check PMI1&2&3
#     run keyword and ignore error    should be true    ${stauts1} or ${stauts2} or ${stauts3}
#     Log To Console    Check Rank In Pucch
#     ${value_list3}    Grep Message From TXT To List    filter1=UlData_pucchReceiveReqPucchResource_t.numOfLayers
#     ...    txt_filename=PucchReceiveReq.txt     item=${item3}
#     FOR    ${item_value}    IN    @{value_list3}
#         should be equal as strings    ${item_value}    ${layer_num}    ignore_case=${True}
#     END
# 
# Check PMI1&2&3
#     Log To Console    Check TPMI
#     ${value_list1}    Grep Message From TXT To List    filter1=DlData_PdschGrant.codebookIndex == 1
#     ...    txt_filename=PdschSendReq2.txt     item=codebookIndex
#     ${stauts1}    run keyword and return status    should not be empty    ${value_list1}
#     ${value_list2}    Grep Message From TXT To List    filter1=DlData_PdschGrant.codebookIndex == 2
#     ...    txt_filename=PdschSendReq2.txt     item=codebookIndex
#     ${stauts2}    run keyword and return status    should not be empty    ${value_list2}
#     ${value_list3}    Grep Message From TXT To List    filter1=DlData_PdschGrant.codebookIndex == 3
#     ...    txt_filename=PdschSendReq2.txt     item=codebookIndex
#     ${stauts3}    run keyword and return status    should not be empty    ${value_list3}
#     [Return]    ${stauts1}    ${stauts2}    ${stauts3}
# 
# Count Signalling In BIP Log
#     [Arguments]    ${filter1}    ${item}
#     ${connection}    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
#     ...    password=${UTE_PASSWORD}    alias=UTE
#     ${final_list}    create list
#     FOR    ${biplog}    IN    @{biplog_list}
#         ${filter1}=    CATENATE    ${filter1}
#         Convert Pcap To Text    source=${LOG_PATH}/${biplog}    target=${LOG_PATH}/PdschSendReq.txt
#         ...    filter="${filter1}"    connection=${connection}
#         ${result}    Grep Text Content    txt_filename=PdschSendReq.txt     item=${item}    connection=${connection}
#         ${result_list}    set variable    ${result.split('\n')}
#         ${not_empty}   run keyword and return status    should not be empty    ${result_list}
#         ${final_list}     run keyword if    ${not_empty}    evaluate    ${final_list}+${result_list}
#     END
#     ${counter_log}    get length    ${final_list}
#     [Teardown]    ssh.Disconnect    connection=${connection}
#     [Return]    ${counter_log}
# 
# Check PUSCH Counter
#     [Arguments]    ${counter_rank}
#     Log To Console    Check PUSCH Counter
#     Log To Console    sleep 15min
#     sleep    15min
#     ${counter_list1}    create list
#     FOR    ${item}    IN    @{counter_rank}
#         ${counter_list2}    Get NR_CELL PUSCH Counter    counter_id=${item}
#         append to list    ${counter_list1}    ${counter_list2[-1]}
#     END
#     ${status}    run keyword and return status    list should contain value    ${counter_list1}    0
#     run keyword if    ${status}   sleep   15min
#     ${counter_result_list}    create list
#     FOR    ${item}    IN    @{counter_rank}
#         ${counter_list}    Get NR_CELL PUSCH Counter    counter_id=${item}
#         ${counter_list_length}    get length    ${counter_list}
#         ${counter}    run keyword if    ${counter_list_length}>=2    evaluate    ${counter_list[-1]} + ${counter_list[-2]}
#         ...    ELSE     evaluate    ${counter_list[-1]} + ${0}
#         append to list    ${counter_result_list}    ${counter}
#     END
#     [Return]    ${counter_result_list}
# 
# Check MCS Counter
#     [Arguments]    ${counter_result_list}
#     Log To Console    Check MCS Counter
#     ${counter_log_27}    Count Signalling In BIP Log    filter1=DlData_PdschGrant.mcs    item=mcs (Uint8): 27
#     ${status_27}    run keyword and return status    should be true    ${counter_log_27} > ${0}
#     ${counter_log_28}    Count Signalling In BIP Log    filter1=DlData_PdschGrant.mcs    item=mcs (Uint8): 28
#     ${status_28}    run keyword and return status    should be true    ${counter_log_28} > ${0}
#     should be true    ${status_27} or ${status_28}
#     should be true    abs(${counter_log_27}-${counter_result_list[0]}) < ${10}
#     should be true    abs(${counter_log_28}-${counter_result_list[1]}) < ${10}
# 
# Check PMI Counter
#     [Arguments]    ${counter_result_list}
#     Log To Console    Check PMI Counter
#     ${counter_PMI1}    Count Signalling In BIP Log    filter1=DlData_PdschGrant.codebookIndex == 1    item=codebookIndex
#     ${counter_PMI2}    Count Signalling In BIP Log    filter1=DlData_PdschGrant.codebookIndex == 2    item=codebookIndex
#     ${counter_PMI3}    Count Signalling In BIP Log    filter1=DlData_PdschGrant.codebookIndex == 3    item=codebookIndex
#     should be true    abs(${counter_PMI1}-${counter_result_list[2]}) < ${300}
#     should be true    abs(${counter_PMI2}-${counter_result_list[3]}) < ${300}
#     should be true    abs(${counter_PMI3}-${counter_result_list[4]}) < ${300}
# 
# Check RANK2 And TPMI Message
#     [Arguments]    ${item1}=numOfLayers (Uint8)    ${item2}=codebookIndex    ${flayer_num}=${2}    ${PMI_num}=VAL_1(1)
#     Log To Console    Check Rank In Pdsch
#     ${value_list1}    Grep Message From TXT To List    filter1=dldata_pdschsendreq    txt_filename=PdschSendReq.txt     item=${item1}
#     ${rank1_sum}    set variable    ${0}
#     ${rank_sum}    get length    ${value_list1}
#     FOR    ${item_value}    IN    @{value_list1}
#         should be true    ${item_value}==${flayer_num} or ${item_value}==${1}
#         run keyword if    ${item_value}==${1}    evaluate    ${rank1_sum}+1
#     END
#     ${rank_proportion}    evaluate    float(${rank1_sum}/${rank_sum})
#     should be true    ${rank_proportion} < 0.005
#     Log To Console    Check TPMI
#     ${value_list2}    Grep Message From TXT To List    filter1=dldata_pdschsendreq    txt_filename=PdschSendReq2.txt    item=${item2}
#     ${TPMI0_sum}    set variable    ${0}
#     ${TPMI_sum}    get length    ${value_list2}
#     FOR    ${item_value}    IN    @{value_list2}
#         should be true    '${item_value}'=='${PMI_num}' or '${item_value}'=='VAL_0(0)'
#         run keyword if    '${item_value}'=='VAL_0(0)'    evaluate    ${TPMI0_sum}+1
#     END
#     ${TPMI_proportion}    evaluate    float(${TPMI0_sum}/${TPMI_sum})
#     should be true    ${TPMI_proportion} < 0.005
# 
# Check RANK1
#     [Arguments]    ${item1}=numOfLayers (Uint8)    ${item2}=codebookIndex    ${flayer_num}=${1}    ${PMI_num}=VAL_255(255)
#     Log To Console    Check Rank In Pdsch
#     ${value_list1}    Grep Message From TXT To List    filter1=dldata_pdschsendreq    txt_filename=PdschSendReq.txt     item=${item1}
#     FOR    ${item_value}    IN    @{value_list1}
#         should be equal as numbers    ${item_value}    ${flayer_num}
#     END
#     Log To Console    Check TPMI
#     ${value_list2}    Grep Message From TXT To List    filter1=dldata_pdschsendreq    txt_filename=PdschSendReq2.txt    item=${item2}
#     ${TPMI0_sum}    set variable    ${0}
#     ${TPMI_sum}    get length    ${value_list2}
#     FOR    ${item_value}    IN    @{value_list2}
#         should be true    '${item_value}'=='${PMI_num}' or '${item_value}'=='VAL_0(0)'
#         run keyword if    '${item_value}'=='VAL_0(0)'    evaluate    ${TPMI0_sum}+1
#     END
#     ${TPMI_proportion}    evaluate    float(${TPMI0_sum}/${TPMI_sum})
#     should be true    ${TPMI_proportion} < 0.005
# 
# case_setup
#     [Arguments]    ${params}
#     Modify rdflag Swconfig File    params=${params}
#     wait until keyword succeeds    10min    10s    Rest Login DU
#     Wait Until BTS Should Be Normal
#     [Teardown]    Rest Logout DU
# 
# case_teardown
#     Log To Console    case teardown
#     ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
#     ...    password=${UTE_PASSWORD}    alias=UTE
#     ssh.send_command    command=cp ${output_dir}/swconfig_backup.txt ${output_dir}/swconfig.txt    connection=UTE
#     sleep    3s
#     ssh.Disconnect    connection=UTE
#     ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}    alias=DU
#     swconf.Upload_swConfig_file_to_asik_and_crasign    localFilePath=${output_dir}/swconfig.txt    asik_alias=DU
#     sleep    5s
#     CI_interface.Common Case Teardown
#     [Teardown]    ssh.Disconnect    connection=DU
# 
# back_up swconfig file
#     Log To Console    back_up swconfig file
#     ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}    alias=DU
#     swconf.Download_swConfig_file_from_asik_to_test_pc    localFilePath=${output_dir}/swconfig.txt    asik_alias=DU
#     sleep    5s
#     ssh.Disconnect    connection=DU
#     ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
#     ...    password=${UTE_PASSWORD}    alias=UTE
#     ssh.send_command    command=cp ${output_dir}/swconfig.txt ${output_dir}/swconfig_backup.txt    connection=UTE
#     sleep    3s
#     ssh.Disconnect    connection=UTE
# 
# recover_swconfig
#     Log To Console    recover_swconfig
#     ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
#     ...    password=${UTE_PASSWORD}    alias=UTE
#     ssh.send_command    command=cp ${output_dir}/swconfig_backup.txt ${output_dir}/swconfig.txt    connection=UTE
#     sleep    3s
#     ssh.Disconnect    connection=UTE
#     ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}    alias=DU
#     swconf.Upload_swConfig_file_to_asik_and_crasign    localFilePath=${output_dir}/swconfig.txt    asik_alias=DU
#     sleep    5s
#     ssh.send_command    command=reboot    connection=DU
#     sleep    5s
#     ssh.Disconnect    connection=DU
#     wait until keyword succeeds    10min    10s    Rest Login DU
#     Wait Until BTS Should Be Normal
#     [Teardown]    Rest Logout DU
# 
# Modify ENB Default GnbCellID
#     Log To Console    Modify ENB Default GnbCellID
#     Rest Login DU    ip_address=${ENB_OAM_IP}
#     ${dict}    create dictionary    parameterName=defaultLnRelGnbCellId    operation=update    value=${5}
#     ${list}    create list    ${dict}
#     coam.perform_object_recommissioning    dist_name=MRBTS-${ENB_BTS_ID}/LNBTS-${ENB_BTS_ID}/LNCEL-1
#     ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
#     sleep    10s
#     [Teardown]    Rest Logout DU
# 
# Suite Setup
#     ${default_scf}    suite setup to prepare default scf    SBTS_scf_name=SCF_SBTS00_531.xml    Branch_scf_name=SCF_SBTS22R1_531.xml
#     Commission Default SCF    default_scf=${default_scf}
#     back_up swconfig file
#     Modify ENB Default GnbCellID
# 
# Suite Teardown
#     recover_swconfig
#     remove files    ${LOG_PATH}/*.txt

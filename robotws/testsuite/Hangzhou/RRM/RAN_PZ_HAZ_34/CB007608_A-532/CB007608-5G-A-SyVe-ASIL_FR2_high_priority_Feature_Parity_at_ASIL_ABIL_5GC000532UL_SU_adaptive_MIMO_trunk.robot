# *** Settings ***
# Documentation     author: zheyuan.chen
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   RRM
# 
# Suite Setup    Run keywords    Case Suite Setup    AND    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# Force Tags    SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE    CLOUD_5G_CLASSICAL_ANDROID_ASILL_ABILB1_AEWD_ENB    STATE_SW_UPLOADED
# ...   PY36
# 
# Resource    resources/comm_7608A.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Variable ***
# @{counter_rank1}    M55303C00000    M55303C00025    M55303C00026    M55303C00027
# @{counter_rank2}    M55303C01000    M55303C01025    M55303C01026    M55303C01027
# ${LOG_PATH}    ${OUTPUT DIR}
# ${luashark_path}    /opt/luashark/luashark.lua
# ${TS_LOG_PATH_BASE}    ${OUTPUT DIR}
# ${TS_CASE_LOG_PATH}    ${OUTPUT DIR}
# ${default_scf_path}     ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T715/
# 
# *** Test Cases ***
# [1]CB007608-A_5GC000532_001_PUSCH transmission with rank 1 and TPMI 0above6Ghz
#     [Documentation]
#     ...    This test scenario is used to check that 5gNB is able to schedule and decode an UL transmission with Rank 1 and TPMI 0.
#     ...    contain CB007608-A_5GC000532_008_Counter_PUSCH transmission in rank 1 using MCSxx
#     ...    -28.07.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2
#     [Setup]    case_setup    params=@{rdflags_rank1_TPMI0}    Actual_value=0
#     Check BTS Should Be Normal
#     Single UE Attach
#     Single UE Start Traffic And Check Throughput
# #    Capture BIP Logs
#     Single UE Stop Traffic And Detach
# #    Check DCI Message
# #    Check RANK1 And TPMI0 Message
# #    ${if_22R1_version}    Judge Version
# #    run keyword if    '${if_22R1_version}' == 'True'    Check PUSCH Counter    counter_rank=@{counter_rank1}
#     [Teardown]    case_teardown
# 
# [1]CB007608-A_5GC000532_002_PUSCH transmission with rank 1 and TPMI 1above6Ghz
#     [Documentation]
#     ...    This test scenario is used to check that 5gNB is able to schedule and decode an UL transmission with Rank 1 and TPMI 1 .
#     ...    -28.07.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_TRUNK
#     [Setup]    robot_common_operations.Common case Setup
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
#     [Teardown]    CI_interface.Common Case Teardown
# #    [Setup]    case_setup    params=@{rdflags_rank1_TPMI1}    Actual_value=25
# #    Check BTS Should Be Normal
# #    Single UE Attach
# #    Single UE Start Traffic And Check Throughput
# #    Capture BIP Logs
# #    Single UE Stop Traffic And Detach
# #    Check DCI Message
# #    Check RANK1 And TPMI1 Message
# #    Check UE Peak Throughput
# #    [Teardown]    case_teardown
# 
# [1]CB007608-A_5GC000532_016_PUSCH transmission with rank 2 and TPMI 0 above6Ghz
#     [Documentation]
#     ...    This test scenario is used to check that 5gNB is able to schedule and decode an UL transmission with Rank 2 and TPMI 0.
#     ...    contain CB007608-A_5GC000532_008_Counter_PUSCH transmission in rank 1 using MCSxx
#     ...    -28.07.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_TRUNK    CRT_22R2
#     [Setup]    robot_common_operations.Common case Setup
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
#     [Teardown]    CI_interface.Common Case Teardown
# #    [Setup]    case_setup    params=@{rdflags_rank2_TPMI0}    Actual_value=0
# #    Check BTS Should Be Normal
# #    Single UE Attach
# #    Single UE Start Traffic And Check Throughput
# #    Capture BIP Logs
# #    Single UE Stop Traffic And Detach
# #    Check DCI Message
# #   Check RANK2 And TPMI0 Message
# #    ${if_22R1_version}    Judge Version
# #    run keyword if    '${if_22R1_version}' == 'True'    Check PUSCH Counter    counter_rank=@{counter_rank2}
# #    [Teardown]    case_teardown
# 
# [1]CB007608-A_5GC000721_TC02_Cell2 selected as pScell in the SgNB addition when cell1 is exceed ccLoadThreshold
#     [Documentation]
#     [Tags]     CRT_22R1   CRT_TRUNK    CRT_22R2
#     [Setup]    robot_common_operations.Common case Setup
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
#     [Teardown]    CI_interface.Common Case Teardown
# 
# 
# *** Keywords ***
# Check DCI Message
#     [Arguments]    ${item1}=POINT_A    ${item2}=firstPolarization    ${point_num}=POINT_A(1)    ${Polarization_num}=firstPolarization(0)
#     ${result_list1}    Grep Message From TXT For List    filter1=dldata_pdcchsendreq    txt_filename=PdcchSendReq.txt     item=${item1}
#     Log To Console    Check POINT
#     FOR    ${value_item1}    IN    @{result_list1}
#         should be equal as strings    ${value_item1}    ${point_num}    ignore_case=${True}
#     END
#     ${result_list2}    Grep Message From TXT For List    filter1=dldata_pdcchsendreq    txt_filename=PdcchSendReq2.txt     item=${item2}
#     Log To Console    Check Polarization
#     FOR    ${value_item2}    IN    @{result_list2}
#         should be equal as strings    ${value_item2}    ${Polarization_num}    ignore_case=${True}
#     END
# 
# Check RANK1 And TPMI0 Message
#     [Arguments]    ${item1}=numOfLayers (Uint8)    ${item2}=mcs (Uint8)   ${item3}=codebookIndex    ${flayer_num}=${1}
#     ...    ${mcs_num}=${10}    ${TPMI_num}=VAL_0(0)
#     Log To Console    Check Rank
#     ${result_list1}    Grep Message From TXT For List    filter1=uldata_puschreceivereq    txt_filename=PuschReceiveReq.txt    item=${item1}
#     FOR    ${value_item1}    IN    @{result_list1}
#         should be equal as numbers    ${value_item1}    ${flayer_num}
#     END
#     Log To Console    Check mcs
#     ${result_list2}    Grep Message From TXT For List    filter1=uldata_puschreceivereq    txt_filename=PuschReceiveReq2.txt     item=${item2}
#     FOR    ${value_item2}    IN    @{result_list2}
#         continue for loop if    ${value_item2}==${0}
#         should be true    ${value_item2} > ${mcs_num}
#     END
#     Log To Console    Check TPMI
#     ${result_list3}    Grep Message From TXT For List    filter1=uldata_puschreceivereq    txt_filename=PuschReceiveReq3.txt     item=${item3}
#     FOR    ${value_item3}    IN    @{result_list3}
#         continue for loop if    '${value_item3}'=='VAL_1(1)'
#         should be equal as strings    ${value_item3}    ${TPMI_num}    ignore_case=${True}
#     END
# 
# Check RANK1 And TPMI1 Message
#     [Arguments]    ${item1}=numOfLayers (Uint8)    ${item2}=mcs (Uint8)   ${item3}=codebookIndex    ${flayer_num}=${1}
#     ...    ${mcs_num}=${10}    ${TPMI_num}=VAL_1(1)
#     Log To Console    Check Rank
#     ${result_list1}    Grep Message From TXT For List    filter1=uldata_puschreceivereq    txt_filename=PuschReceiveReq.txt    item=${item1}
#     FOR    ${value_item1}    IN    @{result_list1}
#         should be equal as numbers    ${value_item1}    ${flayer_num}
#     END
#     Log To Console    Check mcs
#     ${result_list2}    Grep Message From TXT For List    filter1=uldata_puschreceivereq    txt_filename=PuschReceiveReq2.txt     item=${item2}
#     FOR    ${value_item2}    IN    @{result_list2}
#         continue for loop if    ${value_item2}==${0}
#         should be true    ${value_item2} > ${mcs_num}
#     END
#     Log To Console    Check TPMI
#     ${result_list3}    Grep Message From TXT For List    filter1=uldata_puschreceivereq    txt_filename=PuschReceiveReq3.txt     item=${item3}
#     ${TPMI0_sum}    set variable    ${0}
#     ${TPMI_sum}    get length    ${result_list3}
#     FOR    ${value_item3}    IN    @{result_list3}
#         should be true    '${value_item3}'=='${TPMI_num}' or '${value_item3}'=='VAL_0(0)'
#         run keyword if    '${value_item3}'=='VAL_0(0)'    evaluate    ${TPMI0_sum}+1
#     END
#     ${TPMI_proportion}    evaluate    float(${TPMI0_sum}/${TPMI_sum})
#     should be true    ${TPMI_proportion} < 0.005
# 
# Check RANK2 And TPMI0 Message
#     [Arguments]    ${item1}=numOfLayers (Uint8)    ${item2}=mcs (Uint8)   ${item3}=codebookIndex    ${flayer_num}=${2}
#     ...    ${mcs_num}=${5}    ${TPMI_num}=VAL_0(0)
#     Log To Console    Check Rank
#     ${result_list1}    Grep Message From TXT For List    filter1=uldata_puschreceivereq    txt_filename=PuschReceiveReq.txt    item=${item1}
#     ${rank1_sum}    set variable    ${0}
#     ${rank_sum}    get length    ${result_list1}
#     FOR    ${value_item1}    IN    @{result_list1}
#         should be true    ${value_item1}==${flayer_num} or ${value_item1}==${1}
#         run keyword if    ${value_item1}==${1}    evaluate    ${rank1_sum}+1
#     END
#     ${rank_proportion}    evaluate    float(${rank1_sum}/${rank_sum})
#     should be true    ${rank_proportion} < 0.005
#     Log To Console    Check mcs
#     ${result_list2}    Grep Message From TXT For List    filter1=uldata_puschreceivereq    txt_filename=PuschReceiveReq2.txt     item=${item2}
#     FOR    ${value_item2}    IN    @{result_list2}
#         continue for loop if    ${value_item2}==${0}
#         should be true    ${value_item2} > ${mcs_num}
#     END
#     Log To Console    Check TPMI
#     ${result_list3}    Grep Message From TXT For List    filter1=uldata_puschreceivereq    txt_filename=PuschReceiveReq3.txt     item=${item3}
#     FOR    ${value_item3}    IN    @{result_list3}
#         should be equal as strings    ${value_item3}    ${TPMI_num}    ignore_case=${True}
#     END
# 
# Check PUSCH Counter
#     [Arguments]    ${counter_rank}
#     Log To Console   sleep 15min
#     sleep    15min
#     ${counter_list1}    create list
#     FOR    ${item}    IN    @{counter_rank}
#         ${counter_list2}    Get NR_CELL PUSCH Counter    counter_id=${item}
#         append to list    ${counter_list1}    ${counter_list2[-1]}
#     END
#     ${status}    run keyword and return status    list should contain value    ${counter_list1}    0
#     run keyword if    ${status}   sleep   15min
#     FOR    ${item}    IN    @{counter_rank}
#         ${counter_list}    Get NR_CELL PUSCH Counter    counter_id=${item}
#         ${counter_list_length}    get length    ${counter_list}
#         ${counter}    run keyword if    ${counter_list_length}>=2    evaluate    ${counter_list[-1]} + ${counter_list[-2]}
#         ...    ELSE     evaluate    ${counter_list[-1]}
#         should be true    ${counter} > ${0}
#     END
# 
# case_setup
#     [Arguments]    ${params}    ${Actual_value}
#     robot_common_operations.Common case Setup
#     Modify rdflag Swconfig File    params=${params}
#     Modify ullaIniMcs Parameter    Actual_value=${Actual_value}
# 
# case_teardown
#     Log To Console    case teardown
#     ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
#     ...    password=${UTE_PASSWORD}    alias=UTE
#     ssh.send_command    command=cp ${OUTPUT DIR}/swconfig_backup.txt ${OUTPUT DIR}/swconfig.txt    connection=UTE
#     sleep    3s
#     ssh.Disconnect    connection=UTE
#     ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}    alias=DU
#     swconf.Upload_swConfig_file_to_asik_and_crasign    localFilePath=${OUTPUT DIR}/swconfig.txt    asik_alias=DU
#     sleep    5s
# #    CI_interface.Common Case Teardown
#     robot_common_operations.Common Case Teardown
#     [Teardown]    ssh.Disconnect    connection=DU
# 
# back_up swconfig file
#     Log To Console    back_up swconfig file
#     ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}    alias=DU
#     swconf.Download_swConfig_file_from_asik_to_test_pc    localFilePath=${OUTPUT DIR}/swconfig.txt    asik_alias=DU
#     sleep    5s
#     ssh.Disconnect    connection=DU
#     ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
#     ...    password=${UTE_PASSWORD}    alias=UTE
#     ssh.send_command    command=cp ${OUTPUT DIR}/swconfig.txt ${OUTPUT DIR}/swconfig_backup.txt    connection=UTE
#     sleep    3s
#     ssh.Disconnect    connection=UTE
# 
# recover_swconfig
#     Log To Console    recover_swconfig
#     ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
#     ...    password=${UTE_PASSWORD}    alias=UTE
#     ssh.send_command    command=cp ${OUTPUT DIR}/swconfig_backup.txt ${OUTPUT DIR}/swconfig.txt    connection=UTE
#     sleep    3s
#     ssh.Disconnect    connection=UTE
#     ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}    alias=DU
#     swconf.Upload_swConfig_file_to_asik_and_crasign    localFilePath=${OUTPUT DIR}/swconfig.txt    asik_alias=DU
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
#     ${dict}    create dictionary    parameterName=defaultLnRelGnbCellId    operation=update    value=${1}
#     ${list}    create list    ${dict}
#     coam.perform_object_recommissioning    dist_name=MRBTS-${ENB_BTS_ID}/LNBTS-${ENB_BTS_ID}/LNCEL-1
#     ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
#     sleep    10s
#     [Teardown]    Rest Logout DU
# 
# Suite Setup
#     ${default_scf}    suite setup to prepare default scf    SBTS_scf_name=SCF_SBTS00_532.xml    Branch_scf_name=SCF_SBTS22R1_532.xml
#     Commission Default SCF    default_scf=${default_scf}
#     back_up swconfig file
#     Modify ENB Default GnbCellID
# 
# Suite Teardown
#     recover_swconfig
#     remove files    ${LOG_PATH}/*.txt
# 
# Case Suite Setup
#     CI_interface.Common Suite Setup
#     Suite Setup

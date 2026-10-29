# # @Time    : 2022/5/27
# # @Author  : zhang yinhua
# # @Email   : yinhua.zhang@nokia-sbell.com
# # @File    : SBTS1960_RP002771_LTE3036_LTE2735_LTE5625.robot
# # @Software: PyCharm
# # @Doc     : migrate LTE script to robotws frame
# *** Settings ***
# Documentation
# ...    author: zhang yinhua, chen jian
# ...    contact: yinhua.zhang@nokia-sbell.com, jian.1.chen@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_3_SG05
# ...    Feature SBTS1960_RP002771_LTE3036_LTE2735_LTE5625
# 
# Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup          robot_common_operations.Common Suite Setup
# Suite Teardown       robot_common_operations.Common Suite Teardown
# Test Setup           Run Keywords    robot_common_operations.Common Case Setup 
# ...    AND     Connect to gnb coam via ssl    connection=GNB_OAM    bts_host=${ENB_HOST}
# Test Teardown        Run Keywords    robot_common_operations.Common Case Teardown
# ...    AND     Run Keyword And Ignore Error    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM
# 
# Force Tags        CRT_22R3    CRT_TRUNK    PY36    CRT_22R4    CRT_23R1
# 
# *** Variables ***
# ${CELL1_DISTNAME}    MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_LNBTS_ID}/LNCEL-1
# ${CELL1_SIB0_DISTNAME}    MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_LNBTS_ID}/LNCEL-1/SIB-0
# ${ENB_HOST}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# 
# ${TC06_COUNTER_PATH}    BTS/CELLS/LNCEL-1/MCC-262_MNC-03/LTE_Pwr_and_Qual_DL
# ${TC06_COUNTER_ID}    M8010C94
# 
# ${TC14_COUNTER_PATH}    BTS/CELLS/LNCEL-3/MCC-262_MNC-03/LTE_Cell_Throughput
# ${TC14_COUNTER_ID_1}    M8012C188
# ${TC14_COUNTER_ID_2}    M8012C192
# ${TC14_THROUGHPUT}    380
# &{TC14_PA_CHANNELS}    1=3    2=16    3=22    4=18    5=8    6=12    7=16    8=20
# ...    9=120    10=120    11=120    12=120    13=120    14=120    15=120    16=120
# 
# ${TC16_COUNTER_PATH}    BTS/CELLS/LNCEL-1/MCC-262_MNC-03/LTE_Cell_Throughput
# ${TC16_COUNTER_ID_1}    M8012C189
# ${TC16_COUNTER_ID_2}    M8012C193
# ${TC16_THROUGHPUT}    650
# &{TC16_PA_CHANNELS}    1=6    2=16    3=22    4=19    5=10    6=14    7=12    8=20
# ...    9=120    10=120    11=120    12=120    13=120    14=120    15=120    16=120
# 
# ${TC18_COUNTER_PATH}    BTS/CELLS/LNCEL-3/MCC-262_MNC-03/LTE_Cell_Throughput
# ${TC18_COUNTER_ID_1}    M8012C189
# ${TC18_COUNTER_ID_2}    M8012C193
# ${TC18_THROUGHPUT_1}    430
# ${TC18_THROUGHPUT_2}    480
# &{TC18_PA_CHANNELS}    1=3    2=17    3=22    4=17    5=8    6=11    7=16    8=18
# ...    9=120    10=120    11=120    12=120    13=120    14=120    15=120    16=120
# 
# ${TC19_COUNTER_PATH}    BTS/CELLS/LNCEL-1/MCC-262_MNC-03/LTE_Cell_Throughput
# ${TC19_COUNTER_ID_1}    M8012C188
# ${TC19_COUNTER_ID_2}    M8012C192
# ${TC19_COUNTER_ID_3}    M8012C264
# ${TC19_COUNTER_ID_4}    M8012C268
# ${TC19_THROUGHPUT}    80
# &{TC19_PA_CHANNELS}    1=5    2=20    3=25    4=23    5=23    6=17    7=23    8=24
# ...    9=120    10=120    11=120    12=120    13=120    14=120    15=120    16=120
# 
# ${TC07_COUNTER_PATH}    BTS/CELLS/LNCEL-3/MCC-262_MNC-03/LTE_Cell_Throughput
# ${TC07_COUNTER_ID_1}    M8012C187
# ${TC07_COUNTER_ID_2}    M8012C191
# ${TC07_COUNTER_ID_3}    M8012C263
# ${TC07_COUNTER_ID_4}    M8012C267
# ${TC07_THROUGHPUT}    125
# 
# ${SCF_DIR}    ${CURDIR}/scf
# ${TC06_SCF}    RP002771_TC06_LTE3036.xml
# ${TC14_SCF}    RP002771_TC14_LTE2735.xml
# ${TC16_SCF}    RP002771_TC16_LTE2735.xml
# ${TC18_SCF}    RP002771_TC18_LTE2735.xml
# ${TC19_SCF}    RP002771_TC19_TC01.xml
# ${TC07_SCF}    LTE5625_TC07.xml
# 
# *** Test Cases ***
# [3.0] RP002771_TC01_LTE2511_EI&EV_CA Band Combination 3A_41A (10MHz+20MHz)
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    TC01
#     Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${TC19_SCF}
#     Set PA and check SBTS status    channels_to_modify=&{TC19_PA_CHANNELS}
#     LOG    \n UE attach \n    console=yes
#     UE Attach And Verify 4G    ue_index=0
#     LOG    \n Start UDP-traffic \n    console=yes
#     UE Start DL Traffic   throughput=800M    ue_index=0    dl_time=100    dl_port=45009
# 	${counter_value_188}    ${counter_value_192}    Wait Until Keyword Succeeds    4x    60s    Check Double PM Counters
# 	...    counter1_id=${TC19_COUNTER_ID_1}    counter2_id=${TC19_COUNTER_ID_2}    counter_path=${TC19_COUNTER_PATH}
#     ${counter_value_264}    ${counter_value_268}    Wait Until Keyword Succeeds    4x    60s    Check Double PM Counters
# 	...    counter1_id=${TC19_COUNTER_ID_3}    counter2_id=${TC19_COUNTER_ID_4}    counter_path=${TC19_COUNTER_PATH}
#     Check T-put Via Two Counters    ${counter_value_188}    ${counter_value_192}    except_throughput=${TC19_THROUGHPUT}
# 
# [1.0] RP002771_TC06_LTE3036-A-a-01-Active MicroDTX entension
#     [Documentation]    Author: yinhua.zhang@nokia-sbell.com
#     [Tags]    TC06
#     Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${TC06_SCF}
#     Modify Params actMicroDtx and siWindowLen
#     Lock And Unlock Cell
#     Wait Until Keyword Succeeds    5x    60s    Check Single PM Counter
#     Recover Params actMicroDtx and siWindowLen
# 
# [3.0] RP002771_TC14_LTE2735_TC1_Intra CA 2CC(B1a and B41a) with 64QAM
#     [Documentation]    Author: yinhua.zhang@nokia-sbell.com, jian.1.chen@nokia-sbell.com
#     [Tags]    CDRT_22R3    CDRT_TRUNK    TC14    CDRT_22R4
#     Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${TC14_SCF}
#     Set PA and check SBTS status    channels_to_modify=&{TC14_PA_CHANNELS}
#     LOG    \n UE attach \n    console=yes
#     UE Attach And Verify 4G    ue_index=0
#     LOG    \n Start UDP-traffic \n    console=yes
#     UE Start DL Traffic   throughput=800M    ue_index=0    dl_time=100    dl_port=45009
# 	${counter_value_188}    ${counter_value_192}    Wait Until Keyword Succeeds    3x    60s    Check Double PM Counters
# 	...    counter1_id=${TC14_COUNTER_ID_1}    counter2_id=${TC14_COUNTER_ID_2}    counter_path=${TC14_COUNTER_PATH}
# 	Check T-put Via Two Counters    ${counter_value_188}    ${counter_value_192}    except_throughput=${TC14_THROUGHPUT}
# 
# [3.0] RP002771_TC16_LTE2735_TC3_Intra CA 3CC(B3c and B3c and B41a) with 64QAM
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    TC16
#     Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${TC16_SCF}
#     Set PA and check SBTS status    channels_to_modify=&{TC16_PA_CHANNELS}
#     LOG    \n UE attach \n    console=yes
#     UE Attach And Verify 4G    ue_index=0
#     LOG    \n Start UDP-traffic \n    console=yes
#     UE Start DL Traffic   throughput=800M    ue_index=0    dl_time=100    dl_port=45009
# 	${counter_value_189}    ${counter_value_193}    Wait Until Keyword Succeeds    3x    60s    Check Double PM Counters
# 	...    counter1_id=${TC16_COUNTER_ID_1}    counter2_id=${TC16_COUNTER_ID_2}    counter_path=${TC16_COUNTER_PATH}
#     Check T-put Via Two Counters    ${counter_value_189}    ${counter_value_193}    except_throughput=${TC16_THROUGHPUT}
# 
# [3.0] RP002771_TC18_LTE2735_TC5_Intra CA 3CC(B1a+B40c+B40c) with 64QAM and LTE RAT reset
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    CDRT_22R3    CDRT_TRUNK    TC18    CDRT_22R4
#     Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${TC18_SCF}
#     Set PA and check SBTS status    channels_to_modify=&{TC18_PA_CHANNELS}
#     LOG    \n UE attach \n    console=yes
#     UE Attach And Verify 4G    ue_index=0
#     LOG    \n Start UDP-traffic \n    console=yes
#     UE Start DL Traffic   throughput=800M    ue_index=0    dl_time=100    dl_port=45009
# 	${first_counter_value_189}    ${first_counter_value_193}    Wait Until Keyword Succeeds    3x    60s    Check Double PM Counters
# 	...    counter1_id=${TC18_COUNTER_ID_1}    counter2_id=${TC18_COUNTER_ID_2}    counter_path=${TC18_COUNTER_PATH}
#     Check T-put Via Two Counters    ${first_counter_value_189}    ${first_counter_value_193}    except_throughput=${TC18_THROUGHPUT_1}
#     LOG    \n Start UDP-traffic \n    console=yes
#     UE Start DL Traffic   throughput=800M    ue_index=0    dl_time=100    dl_port=45009
# 	${second_counter_value_189}    ${second_counter_value_193}    Wait Until Keyword Succeeds    3x    60s    Check Double PM Counters
# 	...    counter1_id=${TC18_COUNTER_ID_1}    counter2_id=${TC18_COUNTER_ID_2}    counter_path=${TC18_COUNTER_PATH}
#     Check T-put Via Two Counters    ${second_counter_value_189}    ${second_counter_value_193}    except_throughput=${TC18_THROUGHPUT_2}
# 
# [2.0] RP002771_TC19_LTE5625_TC01_nonGBR_related counters_for_2CC
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    CDRT_22R3    CDRT_TRUNK    TC19    CDRT_22R4
#     Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${TC19_SCF}
#     Set PA and check SBTS status    channels_to_modify=&{TC19_PA_CHANNELS}
#     LOG    \n UE attach \n    console=yes
#     UE Attach And Verify 4G    ue_index=0
#     LOG    \n Start UDP-traffic \n    console=yes
#     UE Start DL Traffic   throughput=800M    ue_index=0    dl_time=100    dl_port=45009
# 	${counter_value_188}    ${counter_value_192}    Wait Until Keyword Succeeds    4x    60s    Check Double PM Counters
# 	...    counter1_id=${TC19_COUNTER_ID_1}    counter2_id=${TC19_COUNTER_ID_2}    counter_path=${TC19_COUNTER_PATH}
#     ${counter_value_264}    ${counter_value_268}    Wait Until Keyword Succeeds    4x    60s    Check Double PM Counters
# 	...    counter1_id=${TC19_COUNTER_ID_3}    counter2_id=${TC19_COUNTER_ID_4}    counter_path=${TC19_COUNTER_PATH}
#     Check T-put Via Two Counters    ${counter_value_188}    ${counter_value_192}    except_throughput=${TC19_THROUGHPUT}
#     Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${TC06_SCF}
# 
# [2.0] LTE5625_TC07_nonGBR_related counters_for_without CA
#     [Tags]    TC07
#     [Documentation]    [1]LTE5625_TC07_nonGBR_related counters_for_without CA
#     Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${TC07_SCF}
#     LOG    \n UE attach \n    console=yes
#     UE Attach And Verify 4G    ue_index=0
#     LOG    \n Start UDP-traffic \n    console=yes
#     UE Start DL Traffic   throughput=300M    ue_index=0    dl_time=100    dl_port=45009
# 	${counter_value_187}    ${counter_value_191}    Wait Until Keyword Succeeds    4x    60s    Check Double PM Counters
# 	...    counter1_id=${TC07_COUNTER_ID_1}    counter2_id=${TC07_COUNTER_ID_2}    counter_path=${TC07_COUNTER_PATH}
#     ${counter_value_263}    ${counter_value_267}    Wait Until Keyword Succeeds    4x    60s    Check Double PM Counters
# 	...    counter1_id=${TC07_COUNTER_ID_3}    counter2_id=${TC07_COUNTER_ID_4}    counter_path=${TC07_COUNTER_PATH}
#     Check T-put Via Two Counters    ${counter_value_187}    ${counter_value_191}    except_throughput=${TC07_THROUGHPUT}
#     Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${TC06_SCF}
# 
# 
# *** Keywords ***
# Modify Params actMicroDtx and siWindowLen
#     [Arguments]    ${connection}=GNB_OAM
# 	LOG    \n Modify Params actMicroDtx and siWindowLen    console=yes
# 	Modify Parameter On BTS With Activate       dist_name=${CELL1_DISTNAME}
# 	...    parameter=actMicroDtx    value=true    connection=${connection}
# 	Modify Parameter On BTS With Activate       dist_name=${CELL1_SIB0_DISTNAME}
# 	...    parameter=siWindowLen    value=40ms    connection=${connection}
# 
# Lock And Unlock Cell
#     [Arguments]    ${connection}=GNB_OAM
#     LOG    \n Lock And Unlock Cell    console=yes
#     Run Keyword And Ignore Error    coam.lock    dist_name=${CELL1_DISTNAME}    connection=${connection}
#     Run Keyword And Ignore Error    coam.unlock    dist_name=${CELL1_DISTNAME}    connection=${connection}
#     Run Keyword And Ignore Error    Modify Parameter On BTS With Activate       dist_name=${CELL1_DISTNAME}
# 	...    parameter=administrativeState    value=locked    connection=${connection}
# 	Run Keyword And Ignore Error    Modify Parameter On BTS With Activate       dist_name=${CELL1_DISTNAME}
# 	...    parameter=administrativeState    value=unlocked    connection=${connection}
# 
# Check Single PM Counter
#     [Arguments]    ${connection}=GNB_OAM
#     LOG    \n Check Single PM Counter \n    console=yes
#     ${countervalue}    get_pm_counter_values    counter_id=${TC06_COUNTER_ID}
#     ...    connection=${connection}    dic_path=${TC06_COUNTER_PATH}
#     should be true      ${countervalue[0]} > 0
# 
# Recover Params actMicroDtx and siWindowLen
#     [Arguments]    ${connection}=GNB_OAM
#     LOG    \n Recover Params actMicroDtx and siWindowLen \n    console=yes
#     Modify Parameter On BTS With Activate       dist_name=${CELL1_DISTNAME}
# 	...    parameter=actMicroDtx    value=false    connection=${connection}
# 	Modify Parameter On BTS With Activate       dist_name=${CELL1_SIB0_DISTNAME}
# 	...    parameter=siWindowLen    value=10ms    connection=${connection}
# 
# Set PA and check SBTS status
#     [Arguments]    ${channels_to_modify}
#     LOG    \n Set PA and check SBTS status \n    console=yes
#     gnb_classical_hangzhou.Get Initial Attenuation Values For RU
#     &{channels_to_modify}    create dictionary
#     ...    1=3    2=16    3=22    4=18    5=8    6=12    7=16    8=20
#     ...    9=120    10=120    11=120    12=120    13=120    14=120    15=120    16=120
#     gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}
# 
# Check Double PM Counters
#     [Arguments]    ${counter1_id}    ${counter2_id}    ${counter_path}    ${connection}=GNB_OAM
#     LOG    \n Check Double PM Counters \n    console=yes
#     ${counter1_value_list}    get_pm_counter_values    counter_id=${counter1_id}
#     ...    dic_path=${counter_path}    connection=${connection}
#     ${counter2_value_list}    get_pm_counter_values    counter_id=${counter2_id}
#     ...    dic_path=${counter_path}    connection=${connection}
#     ${length}    Get Length    ${counter1_value_list}
#     FOR    ${index}    IN RANGE  ${length}
#         ${back_index}    Evaluate    ${index} - ${length}
#         ${counter1_value}    Set Variable    ${counter1_value_list}[${back_index}]
#         ${counter2_value}    Set Variable    ${counter2_value_list}[${back_index}]
#         Exit For Loop If    ${counter1_value} > 0
#     END
#     should be true      ${counter1_value} > 0
#     should be true      ${counter2_value} > 0
#     [Return]    ${counter1_value}    ${counter2_value}
# 
# Check T-put Via Two Counters
#     [Arguments]    ${counter1_value}    ${counter2_value}    ${except_throughput}
#     LOG    \n Check T-put Via Two Counters \n    console=yes
#     ${throughput}    Evaluate    ${counter1_value}/(${counter2_value}*1000)
#     should be true       ${throughput} > ${except_throughput}
# 
# Scf Uploading And Commissioning For Enb
#     [Documentation]    perform commissioning scf for enb
#     [Arguments]    ${Log_directory}    ${SCF_Filename}
#     LOG    \nCommissioning eNodeB with ${Log_directory}/${SCF_Filename}
#     COAM Commission with scf file    connection=GNB_OAM
#     ...    scf_file_path=${Log_directory}/${SCF_Filename}
#     ...    is_pdl_checking_needed=${False}    timeout=900
#     wait until keyword succeeds    1200      5    coam_gnb_classical.COAM Check GNB cell on air
#     ${alarms}    Get BTS Active Alarms ID List
#     List Should Not Contain Value    ${alarms}    ${7319}
#     List Should Not Contain Value    ${alarms}    ${7300}

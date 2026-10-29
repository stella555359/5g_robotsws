# # @Time    : 2022/6/14 14:16
# # @Author  : Jian.1.Chen
# # @Email   : jian.1.chen@nokia-sbell.com
# # @File    : SBTS1956_LTE4613_LTE4054_LTE3605.robot
# # @Software: PyCharm
# # @Doc     : migrate LTE script to robotws frame
# *** Settings ***
# Documentation
# ...    author: chen jian
# ...    contact: jian.1.chen@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_3_SG05
# ...    Feature SBTS1956_LTE4613_LTE4054_LTE3605
# 
# Resource    LTE_common_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup          robot_common_operations.Common Suite Setup
# Suite Teardown       robot_common_operations.Common Suite Teardown
# Test Setup           Run Keywords    robot_common_operations.Common Case Setup
# ...    AND     Connect to gnb coam via ssl    connection=GNB_OAM    bts_host=${ENB_HOST}
# Test Teardown        Run Keywords    robot_common_operations.Common Case Teardown
# ...    AND     Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
# ...    AND     Run Keyword And Ignore Error    Unlock BTS All 5G Cells    cell_type=lte
# ...    AND     Run Keyword And Ignore Error    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM
# 
# Force Tags        CRT_TRUNK    PY36
# 
# *** Variables ***
# ${ENB_HOST}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${LNBTS_DISTNAME}    MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_LNBTS_ID}
# ${CELL1_DISTNAME}    MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_LNBTS_ID}/LNCEL-1
# ${CELL2_DISTNAME}    MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_LNBTS_ID}/LNCEL-2
# 
# ${CELL1_RESOURCE_COUNTER_PATH}    BTS/CELLS/LNCEL-1/MCC-262_MNC-03/LTE_Cell_Resource
# ${CELL1_PWR_AND_QUAL_DL_COUNTER_PATH}    BTS/CELLS/LNCEL-1/MCC-262_MNC-03/LTE_Pwr_and_Qual_DL
# ${CELL1_THROUGHPUT_COUNTER_PATH}    BTS/CELLS/LNCEL-1/MCC-262_MNC-03/LTE_Cell_Throughput
# 
# ${SCF_DIR}    ${CURDIR}/scf
# ${4613_SCF}    LTE4613.xml
# ${3605_64QAM_SCF}    LTE3605_64QAM.xml
# ${3605_256QAM_SCF}    LTE3605_256QAM.xml
# ${3605_ENHANCEMENT_JSON}    LTE3605_ENHANCEMENT.json
# ${4054_SCF}    LTE4054.xml
# ${ue_index}    0
# ${ue_type}    qct_dx50
# 
# *** Test Cases ***
# [2.0] Scheduling of TM9-capable UE which configured as TM9 with 4x4 MIMO and 256QAM
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    CDRT_TRUNK    4613-1
#     Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${4613_SCF}
# 	Modify Parameter On BTS With Activate       dist_name=${LNBTS_DISTNAME}
# 	...    parameter=actDLUnicastMbsfn    value=true    connection=GNB_OAM
#     Modify Parameter On BTS With Activate       dist_name=${CELL1_DISTNAME}
# 	...    parameter=actModulationSchemeDl    value=256QAM    connection=GNB_OAM
#     UE Attach 4G And Start DL Traffic    throughput=800M    dl_time=200
#     sleep    120s
#     ${counter_value_288}    ${counter_value_291}    Wait Until Keyword Succeeds    4x    60s    Check Double PM Counters
# 	...    counter1_id=M8011C288    counter2_id=M8011C291    counter_path=${CELL1_RESOURCE_COUNTER_PATH}
# 	Should Be True    ${counter_value_288} > 50
# 	Should Be True    ${counter_value_291} > 100000
# 
# [2.0] Scheduling of TM9-capable UE which configured as TM9 with 4x4 MIMO and 64QAM
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    CDRT_TRUNK    4613-2
#     Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${4613_SCF}
# 	Modify Parameter On BTS With Activate       dist_name=${LNBTS_DISTNAME}
# 	...    parameter=actDLUnicastMbsfn    value=true    connection=GNB_OAM
#     Modify Parameter On BTS With Activate       dist_name=${CELL1_DISTNAME}
# 	...    parameter=actModulationSchemeDl    value=64QAM    connection=GNB_OAM
#     UE Attach 4G And Start DL Traffic    throughput=800M    dl_time=200
#     sleep    120s
#     ${counter_value_288}    ${counter_value_291}    Wait Until Keyword Succeeds    4x    60s    Check Double PM Counters
# 	...    counter1_id=M8011C288    counter2_id=M8011C291    counter_path=${CELL1_RESOURCE_COUNTER_PATH}
# 	Should Be True    ${counter_value_288} > 50
# 	Should Be True    ${counter_value_291} > 100000
# 
# [2.0] Activation and configuration of feature LTE4613 by BTS SiteManager or NetAct
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     [Tags]    CDRT_TRUNK    4613-3
#     Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${4613_SCF}
# 	Modify Parameter On BTS With Activate       dist_name=${LNBTS_DISTNAME}
# 	...    parameter=actDLUnicastMbsfn    value=true    connection=GNB_OAM
# 	Aasyslog precondition    host=${ENB_HOST}
#     Start the Aasyslog save progress    host=${ENB_HOST}    log_name=syslog_LTE4613.log
#     UE Attach And Verify 4G    ue_index=0
#     power_ue.UE Detach    ue_type=qct_dx50
#     Teardown the Aasyslog save progress    host=${ENB_HOST}
#     Download aasyslog file from gNB    log_path=/tmp/syslog_LTE4613.log
#     ...    local_path=${TS_CASE_LOG_PATH}/syslog_LTE4613.log    host=${ENB_HOST}
#     ${ret}    Grep File    ${TS_CASE_LOG_PATH}/syslog_LTE4613.log    TM9 will be chosen.uMbsfn is enabled
#     ...    encoding_errors=ignore
#     Should Not Be Empty    ${ret}
# 
# ######################Optimazation FB2219###############################
# #[2.0] [LTE4054][TC03]Counter test(M8010C148) Number of TTIs with dynamic power backoff applied
# #   [Tags]    CDRT_TRUNK    4054-1
# #    Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${4054_SCF}
# #	UE Attach 4G And Start DL Traffic    throughput=200M
# #    Wait Until Keyword Succeeds    3x    60s    Check Single PM Counter
# #    ...    counter_id=M8010C148    counter_path=${CELL1_PWR_AND_QUAL_DL_COUNTER_PATH}    except_value=1000
# #
# #[2.0] [LTE4054][TC06]Counter test(M8010C149) Sum of power reduction due to applied dynamic power backoff
# #    [Tags]    CDRT_TRUNK    4054-2
# #    Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${4054_SCF}
# #	UE Attach 4G And Start DL Traffic    throughput=200M
# #    Wait Until Keyword Succeeds    3x    60s    Check Single PM Counter
# #    ...    counter_id=M8010C149    counter_path=${CELL1_PWR_AND_QUAL_DL_COUNTER_PATH}    except_value=30
# 
# [2.0] DL UDP peak throughput for 4CC with 12 layers and 64QAM
#     [Tags]    CDRT_TRUNK    3605-1
#     Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${3605_64QAM_SCF}
#     UE Attach 4G And Start DL Traffic    throughput=800M    dl_time=200
#     sleep    120s
#     ${counter_value_190}    ${counter_value_194}    Wait Until Keyword Succeeds    4x    60s    Check Double PM Counters
# 	...    counter1_id=M8012C190    counter2_id=M8012C194    counter_path=${CELL1_THROUGHPUT_COUNTER_PATH}
# 	Should Be True    ${counter_value_190} > 0
# 	Should Be True    ${counter_value_194} > 0
# ######################Optimazation FB2219###############################
# #[2.0] DL UDP peak throughput for 3CC with 12 layers and 256QAM
# #    [Tags]    CDRT_TRUNK    3605-2
# #    Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${3605_256QAM_SCF}
# #    UE Attach 4G And Start DL Traffic    throughput=800M
# #    ${counter_value_189}    ${counter_value_193}    Wait Until Keyword Succeeds    4x    60s    Check Double PM Counters
# #	...    counter1_id=M8012C189    counter2_id=M8012C193    counter_path=${CELL1_THROUGHPUT_COUNTER_PATH}
# #	Should Be True    ${counter_value_189} > 0
# #	Should Be True    ${counter_value_193} > 0
# 
# [2.0] Deactivation of LTE3605 DL 4x4 MIMO with Carrier Aggregation - 12 layers at Element Manager
#     [Tags]    3605-3
#     Scf Uploading And Commissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${3605_256QAM_SCF}
#     Modify Parameter On BTS With Activate       dist_name=MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_LNBTS_ID}/CADPR-0
# 	...    parameter=maxNumMimoLayerFdd    value=10    connection=GNB_OAM
#     Aasyslog precondition    host=${ENB_HOST}
#     Start the Aasyslog save progress    host=${ENB_HOST}    log_name=syslog_LTE3605.log
#     UE Attach 4G And Start DL Traffic    throughput=900M
#     Teardown the Aasyslog save progress    host=${ENB_HOST}
#     Download aasyslog file from gNB    log_path=/tmp/syslog_LTE3605.log
#     ...    local_path=${TS_CASE_LOG_PATH}/syslog_LTE3605.log    host=${ENB_HOST}
#     ${ret1}    Grep File    ${TS_CASE_LOG_PATH}/syslog_LTE3605.log    assignedNumOfLayers for eutraCelId: 1232897 changed from: 4 to: 2    
#     ...    encoding_errors=ignore
#     ${ret2}    Grep File    ${TS_CASE_LOG_PATH}/syslog_LTE3605.log    assignedNumOfLayers for eutraCelId: 1232900 changed from: 4 to: 2
#     ...    encoding_errors=ignore
#     ${ret3}    Grep File    ${TS_CASE_LOG_PATH}/syslog_LTE3605.log    assignedNumOfLayers for eutraCelId: 1232899 changed from: 4 to: 2
#     ...    encoding_errors=ignore
#     ${rets}    Catenate    SEPARATOR=${EMPTY}    ${ret1}    ${ret2}    ${ret3}
#     Should Not Be Empty    ${rets}
# 
# [2.0] Throughput check enhancement
#     [Tags]    3605-4
#     Perform Delta Recommissioning For Enb     Log_directory=${SCF_DIR}    SCF_Filename=${3605_ENHANCEMENT_JSON}
#     Modify Parameter On BTS With Activate       dist_name=${CELL1_DISTNAME}
# 	...    parameter=actModulationSchemeDl    value=QPSK    connection=GNB_OAM
# 	Modify Parameter On BTS With Activate       dist_name=${CELL2_DISTNAME}
# 	...    parameter=actModulationSchemeDl    value=QPSK    connection=GNB_OAM
#     Aasyslog precondition    host=${ENB_HOST}
#     Start the Aasyslog save progress    host=${ENB_HOST}    log_name=syslog_LTE3605_4.log
#     UE Attach 4G And Start DL Traffic    throughput=300M
#     Teardown the Aasyslog save progress    host=${ENB_HOST}
#     Download aasyslog file from gNB    log_path=/tmp/syslog_LTE3605_4.log
#     ...    local_path=${TS_CASE_LOG_PATH}/syslog_LTE3605_4.log    host=${ENB_HOST}

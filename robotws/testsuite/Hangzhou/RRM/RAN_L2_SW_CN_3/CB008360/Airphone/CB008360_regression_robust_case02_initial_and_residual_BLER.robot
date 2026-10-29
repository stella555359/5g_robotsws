# *** Settings ***
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        qualcomm    owner_jiangzhaona
# Library           taf.sbts.oam.coam.admin
# Library           taf.pdu
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_log_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_QC_operate.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}           ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}                 gnb_scf_eda_8360_qc.xml
# ${ATT_FILE_PATH}             ${CURDIR}/log_check/att_case02_2rank2.csv
# ${PHASE_FILE_PATH}           ${CURDIR}/log_check/phase_case02_2rank2.csv
# ${PORT}                      5001
# ${UE1_ID}                    b1a74f66
# ${UE2_ID}                    854e0cfe
# #${UE3_ID}                    92683215
# #${UE4_ID}                    92683215
# ${UE1_UL_PORT}               5001
# ${UE2_UL_PORT}               5002
# #${UE3_UL_PORT}               5003
# #${UE4_DL_PORT}               5004
# ${iperfpc1}                  10.108.184.42
# ${iperfpc2}                  10.108.184.197
# ${UE1_UL_SERVER_LOG}         /tmp/iperf_server_on_pc_log1.txt
# ${UE2_UL_SERVER_LOG}         /tmp/iperf_server_on_pc_log2.txt
# ${UE3_UL_SERVER_LOG}         /tmp/iperf_server_on_pc_log3.txt
# ${DL_LOG}                    /tmp/iperf_server_on_ue_log.txt
# ${UL_SEND_DATA_CMD}          -u -P 1 -t 99999 -i 1 -f m -b 100.00M -w 41M -l 1024B -T 64
# ${DL_SEND_DATA_CMD}          -u -t 8000 -i 1 -P 1 -f m -b 900.00M -l 1400B -T 64
# ${iperf_path}                /data/data/com.nextdoordeveloper.miperf.miperf/files/iperf
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL8UL|//*[@name\="nrCellType"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|4|//*[@name\="ulMaxMuMimoLayer"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${ulMuMimoTaperingH}                            text|20dB|//*[@name\="ulMuMimoTaperingH"]
# ${ulMuMimoTaperingV}                            text|0dB|//*[@name\="ulMuMimoTaperingV"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|3ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${prbThreshRangeOne}                            text|20|//*[@name\="prbThreshRangeOne"]
# ${prbThreshRangeTwo}                            text|20|//*[@name\="prbThreshRangeTwo"]
# ${prbThreshRangeThree}                          text|20|//*[@name\="prbThreshRangeThree"]
# 
# ${ulMuMimoCorrThd}                              text|50|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoCorrThd2}                             text|15|//*[@name\="ulMuMimoCorrThd2"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${actUlDataDmrsFdm}                             text|true|//*[@name\="actUlDataDmrsFdm"]
# ${ulDataDmrsFdmThres64QamMcs}                   text|20|//*[@name\="ulDataDmrsFdmThres64QamMcs"]
# ${ulDataDmrsFdmThres256QamMcs}                  text|20|//*[@name\="ulDataDmrsFdmThres256QamMcs"]
# #${bwpDN1}                     text|MRBTS-573/NRBTS-573/BWP_PROFILE-8|//item[1]/*[@name\='bwpDN']
# #${bwpDN2}                     text|MRBTS-573/NRBTS-573/BWP_PROFILE-87|//item[2]/*[@name\='bwpDN']
# 
# 
# *** Test Cases ***
# CB008360_regression_robust_case02_initial and residual BLER
#     Step1:Set parameter and wait for onair
#     Step2:Attach 2 UE pairing, UL full buffer
#     Step3:Check
#     Step4:Detach all UE
#     Step5:Disable actUlMuMimo
#     Step6:Check again
# 
# 
# *** Keywords ***
# Step1:Set parameter and wait for onair
#     Start Collecting GNB Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...    ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${actUlMuMimoTapering}
#     ...    ${actUlMuMimoTapering}    ${ulMuMimoTaperingH}    ${ulMuMimoTaperingV}    ${frameStructureType}    ${guardPeriodLength}
#     ...    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${prbThreshRangeOne}    ${prbThreshRangeOne}    ${prbThreshRangeOne}
#     ...    ${ulMuMimoCorrThd}    ${srsUePeriodicity}    ${ulMuMimoCorrThd2}    ${actUlDataDmrsFdm}    ${ulDataDmrsFdmThres64QamMcs}
# 	...    ${ulDataDmrsFdmThres256QamMcs}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Perform Full Commission     ${scfc_path}
#     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
#     [Teardown]    Stop Collecting GNB Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 2 UE pairing, UL full buffer
#     Start Collecting GNB Syslog in 'Step2' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
#     Set Mcs3 Phase And Attenuation by CSV    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
#     Attach Mutli QC UEs    ${UE1_ID}   ${UE2_ID}
#     Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UE1_UL_SERVER_LOG}    ${UL_SEND_DATA_CMD}    ${iperf_path}
#     Qualcomm Start UL Data    ${UE2_ID}    ${UE2_UL_PORT}    ${UE2_UL_SERVER_LOG}    ${UL_SEND_DATA_CMD}    ${iperf_path}
# #    Qualcomm Start UL Data    ${UE3_ID}    ${UE3_UL_PORT}    ${UE3_UL_SERVER_LOG}    ${UL_SEND_DATA_CMD}    ${iperf_path}
# #    Send Dl Data By iperfPc    ${UE1_DL_PORT}    ${UE1_ID}    ${DL_SEND_DATA_CMD}    ${iperfpc1}
# #    Send Dl Data By iperfPc    ${UE2_DL_PORT}    ${UE2_ID}    ${DL_SEND_DATA_CMD}    ${iperfpc1}
# #    Send Dl Data By iperfPc    ${UE3_DL_PORT}    ${UE3_ID}    ${DL_SEND_DATA_CMD}    ${iperfpc1}
# #    Send Dl Data By iperfPc    ${UE4_DL_PORT}    ${UE4_ID}    ${DL_SEND_DATA_CMD}    ${iperfpc2}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     [Teardown]    Stop Collecting GNB Syslog in 'Step2' File
# 
# Step3:Check
#     Start Collecting GNB Syslog in 'Step3' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     ${counter_file}    download PM counter file    ${save_log}
#     ${5057c_on}=    check_counter_5057c    ${counter_file}
#     ${5057b_on}=    check_counter_5056b    ${counter_file}
#     Set Test Variable    ${5057c_on}
#     Set Test Variable    ${5057b_on}
#     [Teardown]    Stop Collecting GNB Syslog in 'Step3' File
# 
# Step4:Detach all UE
#     Stop UEs UL Data
#     Detach UEs    ${UE1_ID}    ${UE2_ID}
# 
# Step5:Disable actUlMuMimo
#     Start Collecting GNB Syslog in 'Step4_change_nidd' File
#     Online recommissioning with delta json file    ${CURDIR}/JSON/delta_actUlMuMimo_false.json
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5
#     Set Mcs3 Phase And Attenuation by CSV    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
#     Attach Mutli QC UEs    ${UE1_ID}   ${UE2_ID}
#     Qualcomm Start UL Data    ${UE1_ID}    ${UE1_UL_PORT}    ${UE1_UL_SERVER_LOG}    ${UL_SEND_DATA_CMD}    ${iperf_path}
#     Qualcomm Start UL Data    ${UE2_ID}    ${UE2_UL_PORT}    ${UE2_UL_SERVER_LOG}    ${UL_SEND_DATA_CMD}    ${iperf_path}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     [Teardown]    Stop Collecting GNB Syslog in 'Step5' File
# 
# Step6:Check again
#     Start Collecting GNB Syslog in 'Step6' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     ${counter_file}    download PM counter file    ${save_log}
#     ${5057c_off}=    check_counter_5057c    ${counter_file}
#     ${5057b_off}=    check_counter_5056b    ${counter_file}
#     run keyword if    ${5057c_on}!=0    should be true    0.99<${5057c_off}/${5057c_on}<1.11
#     ...    ELSE    should be true    0<=${5057c_off}<0.1
#     should be true    0.99<${5057b_off}/${5057b_on}<1.11
#     [Teardown]    Stop Collecting GNB Syslog in 'Step6' File
# 
# 
# Send Dl Data By Pc0
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Qualcomm Start DL Data    ${UE2_ID}    ${UE2_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
# 
# Stop UEs DL Data
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}
#     Qualcomm Stop DL Data    ${UE2_ID}    ${UE2_DL_PORT}
# 
# 
# Stop UEs UL Data
#     Qualcomm Stop UL Data    ${UE1_ID}    ${UE1_UL_PORT}
#     Qualcomm Stop UL Data    ${UE2_ID}    ${UE2_UL_PORT}
# 
# Wait For '${time}' Make Tput Steady
#     sleep   ${time}
# 
# check_counter_5057c
#     [Arguments]    ${counter_file}
#     #counters_unsucc_64_256_mcs     create list
#     ${PUSCH_CP_UNSUCC_64TBL_MCS_0_31}     Set Variable    0
#     ${PUSCH_DFT_UNSUCC_64TBL_MCS_0_31}    Set Variable    0
#     ${PUSCH_CP_UNSUCC_256TBL_MCS_0_31}    Set Variable    0
#     ${PUSCH_CP_SUCC_64TBL_MCS_0_31}       Set Variable    0
#     ${PUSCH_DFT_SUCC_64TBL_MCS_0_31}      Set Variable    0
#     ${PUSCH_CP_SUCC_256TBL_MCS_0_31}      Set Variable    0
#     @{list1}=    Create list    @{EMPTY}
#     @{list2}=    Create list    @{EMPTY}
#     @{list3}=    Create list    @{EMPTY}
#     @{list4}=    Create list    @{EMPTY}
#     @{list5}=    Create list    @{EMPTY}
#     @{list6}=    Create list    @{EMPTY}
# 
#     :For    ${i}    IN RANGE    3000    3032
#     \    ${counter1}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C0${i}   cell_id=1
#     \    ${PUSCH_CP_UNSUCC_64TBL_MCS_0_31}    evaluate    int(${PUSCH_CP_UNSUCC_64TBL_MCS_0_31}+${counter1})
#     \    Append To List    ${list1}    ${counter1}
# 
#     :For    ${i}    IN RANGE    7000    7032
#     \    ${counter2}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C0${i}   cell_id=1
#     \    ${PUSCH_DFT_UNSUCC_64TBL_MCS_0_31}    evaluate    int(${PUSCH_DFT_UNSUCC_64TBL_MCS_0_31}+${counter2})
#     \    Append To List    ${list2}    ${counter2}
# 
#     :For    ${i}    IN RANGE    2000    2032
#     \    ${counter3}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C1${i}   cell_id=1
#     \    ${PUSCH_CP_UNSUCC_256TBL_MCS_0_31}    evaluate    int(${PUSCH_CP_UNSUCC_256TBL_MCS_0_31}+${counter3})
#     \    Append To List    ${list3}    ${counter3}
# 
#     :For    ${i}    IN RANGE    5000    5032
#     \    ${counter4}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C0${i}   cell_id=1
#     \    ${PUSCH_CP_SUCC_64TBL_MCS_0_31}    evaluate    int(${PUSCH_CP_SUCC_64TBL_MCS_0_31}+${counter4})
#     \    Append To List    ${list4}    ${counter4}
# 
#     :For    ${i}    IN RANGE    9000    9032
#     \    ${counter5}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C0${i}   cell_id=1
#     \    ${PUSCH_DFT_SUCC_64TBL_MCS_0_31}    evaluate    int(${PUSCH_DFT_SUCC_64TBL_MCS_0_31}+${counter5})
#     \    Append To List    ${list5}    ${counter5}
# 
#     :For    ${i}    IN RANGE    4000    4032
#     \    ${counter6}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C1${i}   cell_id=1
#     \    ${PUSCH_CP_SUCC_256TBL_MCS_0_31}    evaluate    int(${PUSCH_CP_SUCC_256TBL_MCS_0_31}+${counter6})
#     \    Append To List    ${list6}    ${counter6}
# 
#     log    ${list1}
#     log    ${list2}
#     log    ${list3}
#     log    ${list4}
#     log    ${list5}
#     log    ${list6}
#     ${UNSUCC_counter}    evaluate    ${PUSCH_CP_UNSUCC_64TBL_MCS_0_31}+${PUSCH_DFT_UNSUCC_64TBL_MCS_0_31}+${PUSCH_CP_UNSUCC_256TBL_MCS_0_31}
#     ${SUCC_counter}      evaluate    ${PUSCH_CP_SUCC_64TBL_MCS_0_31}+${PUSCH_DFT_SUCC_64TBL_MCS_0_31}+${PUSCH_CP_SUCC_256TBL_MCS_0_31}
#     ${NR_5057c}          evaluate    100*${UNSUCC_counter}/(${UNSUCC_counter}+${SUCC_counter})
#     [Return]    ${NR_5057c}
# 
# check_counter_5056b
#     [Arguments]    ${counter_file}
# #    ${counter_file}    download PM counter file    ${save_log}
#     #counters_unsucc_64_256_mcs     create list
#     ${PUSCH_CP_INIT_64TBL_MCS_0_28}     Set Variable    0
#     ${PUSCH_DFT_INIT_64TBL_MCS_0_27}    Set Variable    0
#     ${PUSCH_CP_INIT_256TBL_MCS_0_27}    Set Variable    0
#     ${PUSCH_CP_SUCC_INIT_64TBL_MCS_0_28}       Set Variable    0
#     ${PUSCH_DFT_SUCC_INIT_64TBL_MCS_0_27}      Set Variable    0
#     ${PUSCH_CP_SUCC_INIT_256TBL_MCS_0_27}      Set Variable    0
#     @{list11}=    Create list    @{EMPTY}
#     @{list12}=    Create list    @{EMPTY}
#     @{list13}=    Create list    @{EMPTY}
#     @{list14}=    Create list    @{EMPTY}
#     @{list15}=    Create list    @{EMPTY}
#     @{list16}=    Create list    @{EMPTY}
#     @{list17}=    Create list    @{EMPTY}
# 
#     :For    ${i}    IN RANGE    0    10
#     \    ${counter_5056b1}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C0000${i}   cell_id=1
#     \    ${PUSCH_CP_INIT_64TBL_MCS_0_28}    evaluate    int(${PUSCH_CP_INIT_64TBL_MCS_0_28}+${counter_5056b1})
#     \    Append To List    ${list11}    ${counter_5056b1}
# 
#     :For    ${i}    IN RANGE    10    29
#     \    ${counter_5056b2}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C000${i}   cell_id=1
#     \    ${PUSCH_CP_INIT_64TBL_MCS_0_28}    evaluate    int(${PUSCH_CP_INIT_64TBL_MCS_0_28}+${counter_5056b2})
#     \    Append To List    ${list12}    ${counter_5056b2}
# 
#     :For    ${i}    IN RANGE    6000    6028
#     \    ${counter_5056b3}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C0${i}   cell_id=1
#     \    ${PUSCH_DFT_INIT_64TBL_MCS_0_27}    evaluate    int(${PUSCH_DFT_INIT_64TBL_MCS_0_27}+${counter_5056b3})
#     \    Append To List    ${list13}    ${counter_5056b3}
# 
#     :For    ${i}    IN RANGE    1000    1028
#     \    ${counter_5056b4}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C1${i}   cell_id=1
#     \    ${PUSCH_CP_INIT_256TBL_MCS_0_27}    evaluate    int(${PUSCH_CP_INIT_256TBL_MCS_0_27}+${counter_5056b4})
#     \    Append To List    ${list14}    ${counter_5056b4}
# 
#     :For    ${i}    IN RANGE    4000    4029
#     \    ${counter_5056b5}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C0${i}   cell_id=1
#     \    ${PUSCH_CP_SUCC_INIT_64TBL_MCS_0_28}    evaluate    int(${PUSCH_CP_SUCC_INIT_64TBL_MCS_0_28}+${counter_5056b5})
#     \    Append To List    ${list15}    ${counter_5056b5}
# 
#     :For    ${i}    IN RANGE    8000    8028
#     \    ${counter_5056b6}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C0${i}   cell_id=1
#     \    ${PUSCH_DFT_SUCC_INIT_64TBL_MCS_0_27}    evaluate    int(${PUSCH_DFT_SUCC_INIT_64TBL_MCS_0_27}+${counter_5056b6})
#     \    Append To List    ${list16}    ${counter_5056b6}
# 
#     :For    ${i}    IN RANGE    3000    3028
#     \    ${counter_5056b7}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C1${i}   cell_id=1
#     \    ${PUSCH_CP_SUCC_INIT_256TBL_MCS_0_27}    evaluate    int(${PUSCH_CP_SUCC_INIT_256TBL_MCS_0_27}+${counter_5056b7})
#     \    Append To List    ${list17}    ${counter_5056b7}
# 
#     log    ${list11}
#     log    ${list12}
#     log    ${list13}
#     log    ${list14}
#     log    ${list15}
#     log    ${list16}
#     log    ${list17}
#     ${init_tran_sent}    evaluate    ${PUSCH_CP_INIT_64TBL_MCS_0_28}+${PUSCH_DFT_INIT_64TBL_MCS_0_27}+${PUSCH_CP_INIT_256TBL_MCS_0_27}
#     ${init_tran_succ}    evaluate   
#    ...     ${PUSCH_CP_SUCC_INIT_64TBL_MCS_0_28}+${PUSCH_DFT_SUCC_INIT_64TBL_MCS_0_27}+${PUSCH_CP_SUCC_INIT_256TBL_MCS_0_27}
#     ${NR_5056b}          evaluate    100*(${init_tran_sent}-${init_tran_succ})/${init_tran_sent}
#     [Return]    ${NR_5056b}

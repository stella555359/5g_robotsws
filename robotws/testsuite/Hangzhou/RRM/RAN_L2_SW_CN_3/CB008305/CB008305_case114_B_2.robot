# *** Settings ***
# Test Timeout      90 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        qualcomm    owner_jiangzhaona
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_log_operate.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_QC_operate.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_spark.robot
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_capture_log.robot
# #Library           ta_kiss_qualcomm
# #Library           ta_kiss_files
# #Library           taf.transport.ssh    WITH NAME    TAF_SSH
# #Library           ta_a2a
# #Library           ta_kiss_pa
# #Library           ta_kiss_mcs
# #Library           DateTime
# #Library           Collections
# #Library           OperatingSystem
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}           ${CURDIR}/../resources/sg11/internal_resource/config/
# ${SCFC_NAME}                 gNB_scf_ASIB_ABIO_AEHC_TDD_eCPRI_cmwv_SANSA_1CC_BTS573_8305.xml
# ${ATT_FILE_PATH_step2}             ${CURDIR}/mcs_set/att_case114_step2.csv
# ${PHASE_FILE_PATH_step2}           ${CURDIR}/mcs_set/phase.csv
# ${ATT_FILE_PATH_step3}             ${CURDIR}/mcs_set/att_case114_step3.csv
# ${PHASE_FILE_PATH_step3}           ${CURDIR}/mcs_set/phase.csv
# @{sa_ue_list}    1    2    5    6    3    7
# @{ip_list}
# ${PORT}    5001
# ${DL_LOG}                    /tmp/iperf_server_on_ue_log.txt
# ${DL_SEND_DATA_CMD}          -u -t 8000 -i 1 -P 1 -f m -b 900.00M -l 1400B -T 64
# ${chBw}                      text|100MHz|//*[@name\="chBw"]
# ${bSRS}                      text|2|//*[@name\="bSRS"]
# ${cSRS}                      text|49|//*[@name\="cSRS"]
# ${actDlSrsBm}                text|true|//*[@name\="actDlSrsBm"]
# ${nrCellType}                text|8DL4UL|//*[@name\="nrCellType"]
# ${actDlMuMimoEnh}            text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}           text|33|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}            text|0|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoSpectralEffThd}    text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${maxNumLayerPerMuRbg}       text|8|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${dlMuMimoRankAdaption}      text|always|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoTaperingH}         text|25dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}         text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${actBeamforming}            text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}              text|beamSet_6|//*[@name\="basicBeamSet"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${actDl256Qam}               text|true|//*[@name\="actDl256Qam"]
# ${dlMimoMode}                text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${frameStructureType}        text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}         text|6Symbols|//*[@name\="guardPeriodLength"]
# ${prachConfigurationIndex}   text|98|//*[@name\="prachConfigurationIndex"]
# ${lteToNrFrameShift}         text|3ms|//*[@name\="lteToNrFrameShift"]
# ${ulDlDataSlotRatio}         text|1/4|//*[@name\="ulDlDataSlotRatio"]
# #${bwpDN1}                     text|MRBTS-573/NRBTS-573/BWP_PROFILE-8|//item[1]/*[@name\='bwpDN']
# #${bwpDN2}                     text|MRBTS-573/NRBTS-573/BWP_PROFILE-87|//item[2]/*[@name\='bwpDN']
# @{modify_list}               ${chBw}    ${actDlSrsBm}    ${bSRS}    ${cSRS}    ${nrCellType}    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}
# ...                          ${dlMuMimoCqiThd}    ${dlMuMimoSpectralEffThd}    ${maxNumLayerPerMuRbg}    ${dlMuMimoRankAdaption}
# ...                          ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}    ${actBeamforming}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}
# ...                          ${actDl256Qam}    ${dlMimoMode}    ${frameStructureType}    ${guardPeriodLength}    ${prachConfigurationIndex}
# ...                          ${lteToNrFrameShift}    ${ulDlDataSlotRatio}
# #...                          ${bwpDN1}    ${bwpDN2}
# 
# *** Test Cases ***
# CB008305_case114_B_2_multiple_UEs_mixed_scheduling_with_more_than_4UEs_single_layers
#     Start capture only gnb syslog in 'after_onair' file
#     Step1:Set parameter and wait for onair
#     Step2:6 UEs attach to cell and traffic
#     Step3:Make any three UEs report rank = 2
#     Step4:Detach all UE
#     Stop capture only gnb syslog in 'after_onair' file
# 
# *** Keywords ***
# Step1:Set parameter and wait for onair
#     #Start Collecting GNB Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Perform Full Commission     ${scfc_path}
#     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
#     #[Teardown]    Stop Collecting GNB Syslog in 'Step1_before_onair' File
# 
# Step2:6 UEs attach to cell and traffic
#     #Start capture only gnb syslog in 'Step2' file
#     Set Mcs3 Phase And Attenuation by CSV    ${ATT_FILE_PATH_step2}    ${PHASE_FILE_PATH_step2}
#     @{ip_list}    Attach SA ue list    @{sa_ue_list}
#     Start spark dl traffic    ${ip_list}    ${PORT}    2000    1400
#     : FOR    ${i}    IN    @{sa_ue_list}
#     \    Start spark ul traffic    ${i}
#     @{dl}    Create List
#     @{ul}    Create List
#     Wait For '10s' Make Tput Steady
#     ${dl}    ${ul}    Get mutiple ues instant throughput    ${sa_ue_list}    ${dl}    ${ul}
#     ${j}    Get Length    ${dl}
#     : FOR    ${i}    IN RANGE    ${j}
#     \    run keyword and continue on failure    should_be_true    ${dl}[${i}] > 80
#     : FOR    ${i}    IN RANGE   ${j}
#     \    run keyword and continue on failure    should_be_true    ${ul}[${i}] >= 0
#     run keyword and continue on failure    Check Step2 Logs
#     #[Teardown]    Stop capture only gnb syslog in 'Step2' file
# 
# Step3:Make any three UEs report rank = 2
#     Set Mcs3 Phase And Attenuation by CSV    ${ATT_FILE_PATH_step3}    ${PHASE_FILE_PATH_step3}
#     run keyword and continue on failure    Check Step3 Logs
#     #Check PM counter In Step2
#     #[Teardown]    Stop capture only gnb syslog in 'Step2' file
# 
# Step4:Detach all UE
#     Stop spark Ues dl and ul traffic    ${sa_ue_list}     ${ip_list}    ${PORT}
#     Detach spark ues    ${sa_ue_list}
# 
# 
# Send Dl Data By Pc0
#     Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
#     Qualcomm Start DL Data    ${UE2_ID}    ${UE2_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
# 
# Stop UEs DL Data
#     Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}
#     Qualcomm Stop DL Data    ${UE2_ID}    ${UE2_DL_PORT}
#     Qualcomm Stop DL Data    ${UE3_ID}    ${UE3_DL_PORT}
#     Qualcomm Stop DL Data    ${UE4_ID}    ${UE4_DL_PORT}
# 
# modify_swconfig_for_CB008305
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            QC Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
#     ta_kiss_files.setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	ta_kiss_files.add_txt_node   0x340000:15        #as PM counter period update to 15/15=1min
# 	ta_kiss_files.add_txt_node   0x580267:0         #8305 opt1
# 	ta_kiss_files.add_txt_node   0x580477:1         #print beam calc log
#     ta_kiss_files.teardown_txt
#     GNB Upload Sconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 
# Wait For '${time}' Make Tput Steady
#     sleep   ${time}
# 
# Check Step2 Logs
#     #Start Collecting GNB Syslog in 'Step2' File
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case114_Step2.ini    log_need_to_check=i    save_log_directory=${save_log}
#     ${DL_throughput}    get tput from PM counter    ${save_log}    M55309C12001
#     should be true    ${DL_throughput}>1000
#     #[Teardown]    Stop Collecting GNB Syslog in 'Step2' File
# 
# Check Step3 Logs
#     #Start Collecting GNB Syslog in 'Step2' File
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case114_Step3.ini    log_need_to_check=i    save_log_directory=${save_log}
#     ${DL_throughput}    get tput from PM counter    ${save_log}    M55309C12001
#     should be true    ${DL_throughput}>1200
#     #[Teardown]    Stop Collecting GNB Syslog in 'Step2' File
# 
# Attach other SA ues list
#     [Arguments]    @{ue_index_list}
#     : FOR    ${i}    IN    @{ue_index_list}
#     \    cpe attach	    fGSACTR=1    GTACT=14    ue_index=${i}
#     \    Wait '30s' for stabible
#     \    ${ip}   cpe_get_attach_ip      ue_index=${i}     start_test=${True}
#     \    Append To List    ${ip_list_step3}    ${ip}[0]
#     ${j}    Get Length    ${ue_index_list}
#     : FOR    ${i}    IN RANGE    ${j}
#     \    Log To Console    @{ip_list_step3}[${i}]
#     \    run keyword if    '@{ip_list_step3}[${i}]'=='None'     fail
#     [Return]    @{ip_list_step3}

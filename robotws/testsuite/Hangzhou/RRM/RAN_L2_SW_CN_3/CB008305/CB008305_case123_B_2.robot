# *** Settings ***
# Test Timeout      120 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
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
# ${SCFC_NAME}                 gNB_scf_ASIB_ABIO_AEHC_TDD_eCPRI_cmwv_SANSA_1CC_BTS573_8305_case123.xml
# ${ATT_FILE_PATH}             ${CURDIR}/mcs_set/att.csv
# ${PHASE_FILE_PATH}           ${CURDIR}/mcs_set/phase_chbw60M.csv
# @{sa_ue_list}    1    2    5    6
# @{sa_ue_list_step5}    1    2
# @{ip_list}
# @{ip_list_step5}
# ${ip}
# ${PORT}    5001
# ${DL_LOG}                    /tmp/iperf_server_on_ue_log.txt
# ${DL_SEND_DATA_CMD}          -u -t 8000 -i 1 -P 1 -f m -b 900.00M -l 1400B -T 64
# ${chBw}                      text|60MHz|//*[@name\="chBw"]
# ${miNrCellUtilPerPLMN}        text|15min|//*[@name\="miNrCellUtilPerPLMN"]
# #${bSRS}                      text|2|//*[@name\="bSRS"]
# #${cSRS}                      text|33|//*[@name\="cSRS"]
# #${actDlSrsBm}                text|true|//*[@name\="actDlSrsBm"]
# #${nrCellType}                text|8DL4UL|//*[@name\="nrCellType"]
# #${actDlMuMimoEnh}            text|true|//*[@name\="actDlMuMimoEnh"]
# #${dlMuMimoCorrThd}           text|33|//*[@name\="dlMuMimoCorrThd"]
# #${dlMuMimoCqiThd}            text|0|//*[@name\="dlMuMimoCqiThd"]
# #${dlMuMimoSpectralEffThd}    text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${maxNumLayerPerMuRbg}       text|8|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# #${dlMuMimoRankAdaption}      text|always|//*[@name\="dlMuMimoRankAdaption"]
# #${dlMuMimoTaperingH}         text|25dB|//*[@name\="dlMuMimoTaperingH"]
# #${dlMuMimoTaperingV}         text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# #${actBeamforming}            text|true|//*[@name\="actBeamforming"]
# #${basicBeamSet}              text|beamSet_6|//*[@name\="basicBeamSet"]
# #${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# #${actDl256Qam}               text|true|//*[@name\="actDl256Qam"]
# #${dlMimoMode}                text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# #${frameStructureType}        text|tdLte|//*[@name\="frameStructureType"]
# #${guardPeriodLength}         text|6Symbols|//*[@name\="guardPeriodLength"]
# #${prachConfigurationIndex}   text|98|//*[@name\="prachConfigurationIndex"]
# #${lteToNrFrameShift}         text|3ms|//*[@name\="lteToNrFrameShift"]
# #${ulDlDataSlotRatio}         text|1/4|//*[@name\="ulDlDataSlotRatio"]
# #${bwpDN1}                     text|MRBTS-573/NRBTS-573/BWP_PROFILE-8|//item[1]/*[@name\='bwpDN']
# #${bwpDN2}                     text|MRBTS-573/NRBTS-573/BWP_PROFILE-87|//item[2]/*[@name\='bwpDN']
# @{modify_list}               ${chBw}    ${miNrCellUtilPerPLMN}    ${maxNumLayerPerMuRbg}
# #...                          ${actDlSrsBm}    ${bSRS}    ${cSRS}    ${nrCellType}    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}
# #...                          ${dlMuMimoCqiThd}    ${dlMuMimoSpectralEffThd}    ${dlMuMimoRankAdaption}
# #...                          ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}    ${actBeamforming}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}
# #...                          ${actDl256Qam}    ${dlMimoMode}
# #...                          ${frameStructureType}    ${guardPeriodLength}    ${prachConfigurationIndex}
# #...                          ${lteToNrFrameShift}    ${ulDlDataSlotRatio}
# #...                          ${bwpDN1}    ${bwpDN2}
# 
# *** Test Cases ***
# CB008305_case123_B_4_PM counters for DL MU-MIMO
#     #Start capture only gnb syslog in 'after_onair' file
#     Step1:Set parameter and wait for onair
#     Step2:UEs attach to cell and traffic
#     Step3:Online change maxNumLayerPerMuRbg to 6
#     Step4:Online change maxNumLayerPerMuRbg to 4
#     #Step5:Make 5QI1 Call
#     Step6:Detach all UE
#     #Stop capture only gnb syslog in 'after_onair' file
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
# Step2:UEs attach to cell and traffic
#     #Start capture only gnb syslog in 'Step2' file
#     Set Mcs3 Phase And Attenuation by CSV    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
#     @{ip_list}    Attach SA ue list    @{sa_ue_list}
#     Start spark dl traffic    ${ip_list}    ${PORT}    800    1400
#     : FOR    ${i}    IN    @{sa_ue_list}
#     \    Start spark ul traffic    ${i}
#     @{dl}    Create List
#     @{ul}    Create List
#     Wait For '10s' Make Tput Steady
#     ${dl}    ${ul}    Get mutiple ues instant throughput    ${sa_ue_list}    ${dl}    ${ul}
#     ${j}    Get Length    ${dl}
#     : FOR    ${i}    IN RANGE    ${j}
#     \    run keyword and continue on failure    should_be_true    ${dl}[${i}] > 100
#     : FOR    ${i}    IN RANGE   ${j}
#     \    run keyword and continue on failure    should_be_true    ${ul}[${i}] >= 0
#     run keyword and continue on failure    Check MU8layer and 4PairUE PM counter
#     #[Teardown]    Stop capture only gnb syslog in 'Step2' file
# 
# Step3:Online change maxNumLayerPerMuRbg to 6
#     COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-573/NRBTS-573/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuMaxNumLayerPerMuRbg
#     ...    operation=update    value=6    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     COAM.teardown admin    connection=online
#     Wait '30s' for stabible
#     Check MU6layer and 3PairUE PM counter
# 
# Step4:Online change maxNumLayerPerMuRbg to 4
#     COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-573/NRBTS-573/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuMaxNumLayerPerMuRbg
#     ...    operation=update    value=4    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     COAM.teardown admin    connection=online
#     Wait '30s' for stabible
#     Check MU4layer and 2PairUE PM counter
#     Stop spark Ues dl and ul traffic    ${sa_ue_list}     ${ip_list}    ${PORT}
# 
# Step5:Make 5QI1 Call
#     #Append To List    ${ip_list_step5}    ${ip_list}[2]
#     #run keyword and continue on failure    cpe_execute_at_command    AT+CGDCONT=1,"IP","ims",,,,,,,,,,,,,,0
#     ${at_cmd}    BuiltIn.Create Dictionary    SuccStr    ${EMPTY}    Command    AT+CGDCONT=1,"IP","ims",,,,,,,,,,,,,,0
#     run keyword and continue on failure    cpe_execute_at_command    at_cmd=${at_cmd}    index=1
#     ${para}    BuiltIn.Create Dictionary    SuccStr    ${EMPTY}    Command    AT+GTRNDIS=1,1
#     run keyword and continue on failure    Execute Command    "SendAT"    ${para}    1
# 
# Step6:Detach all UE
#     #Stop spark Ues dl and ul traffic    ${sa_ue_list}     ${ip_list}    ${PORT}
#     Detach spark ues    ${sa_ue_list}
# 
# Start spark dl traffic
#     [Arguments]    ${ip}    ${port}    ${band_width}    ${packet_size}
#     ${iperf_related_info}    Create list   10.106.164.180    ute    %EjvHVvvkQD6    22
#     ${len}    evaluate     len(${ip})
#     :FOR    ${i}     IN RANGE      0    ${len}
#     \    ${p}    evaluate     5001+${i}
#     \    ${alias}    catenate    ${ip}[${i}]    ${i}
#     \    start_udp_iperf_client    ${iperf_related_info}
#     ...    ${ip[${i}]}    port=${p}    band_width=${band_width}
#     ...    packet_size=${packet_size}   conn_num=1    ttl=64    output_format=m    alias=${alias}
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
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case121_Step2.ini    log_need_to_check=i    save_log_directory=${save_log}
#     ${DL_throughput}    get tput from PM counter    ${save_log}    M55309C12001
#     should be true    ${DL_throughput}>2000
#     #[Teardown]    Stop Collecting GNB Syslog in 'Step2' File
# 
# Check MU8layer and 4PairUE PM counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${remaining_time}     evaluate    ${remaining_time}+10
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step2${/}
#     ${PM_counter_8layer_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34011
#     ...   cell_id=1
#     ${PM_counter_4pairUE_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34015
#     ...   cell_id=1
#     ${PM_counter_usedPrb_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C10001
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_8layer_value} > 8000000
#     run keyword and continue on failure    Should Be True    ${PM_counter_4pairUE_value} > 8000000
#     run keyword and continue on failure    Should Be True    ${PM_counter_8layer_value} > ${PM_counter_usedPrb_value}*0.7
#     run keyword and continue on failure    Should Be True    ${PM_counter_4pairUE_value} > ${PM_counter_usedPrb_value}*0.7
#     ${PM_counter_availPrb_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C10003
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_availPrb_value} > 8000000
#     ${PM_counter_MaxAllocPrb_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C20001
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_availPrb_value} > 8000000
#     ${PM_counter_usedPrbPlmn_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55338C00001
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_availPrb_value} > 8000000
#     [Return]    ${PM_counter_8layer_value}    ${PM_counter_4pairUE_value}
# 
# Check MU6layer and 3PairUE PM counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${remaining_time}     evaluate    ${remaining_time}+10
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3${/}
#     ${PM_counter_6layer_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34009
#     ...   cell_id=1
#     ${PM_counter_3pairUE_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34014
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_6layer_value} > 8000000
#     run keyword and continue on failure    Should Be True    ${PM_counter_3pairUE_value} > 8000000
#     [Return]    ${PM_counter_6layer_value}    ${PM_counter_3pairUE_value}
# 
# Check MU4layer and 2PairUE PM counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${remaining_time}     evaluate    ${remaining_time}+10
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step4${/}
#     ${PM_counter_4layer_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34007
#     ...   cell_id=1
#     ${PM_counter_2pairUE_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34013
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_4layer_value} > 8000000
#     run keyword and continue on failure    Should Be True    ${PM_counter_2pairUE_value} > 8000000
#     [Return]    ${PM_counter_4layer_value}    ${PM_counter_2pairUE_value}
# 
# Robustly Attach SA ue list
#     [Arguments]    @{ue_index_list}
#     : FOR    ${i}    IN    @{ue_index_list}
#     \    cpe attach	    fGSACTR=1    GTACT=14    ue_index=${i}
#     \    Wait '30s' for stabible
#     \    ${ip}   Detach And Attach 5 Times      ue_index=${i}
#     \    Append To List    ${ip_list}    ${ip}[0]
#     ${j}    Get Length    ${ue_index_list}
#     : FOR    ${i}    IN RANGE    ${j}
#     \    Log To Console    @{ip_list}[${i}]
#     \    run keyword if    '@{ip_list}[${i}]'=='None'     fail
#     [Return]    @{ip_list}
# 
# Detach And Attach 5 Times
#     [Arguments]    ${ue_index}
#     : FOR    ${j}    IN RANGE    5
#     \    Detach spark ue    ${ue_index}
#     \    cpe attach	    fGSACTR=1    GTACT=14    ue_index=${ue_index}
#     \    Wait '30s' for stabible
#     \    ${ip}   cpe_get_attach_ip      ue_index=${ue_index}     start_test=${True}
#     \    Exit For Loop If    ${ip}[0]!=None
#     [Return]    ${ip}

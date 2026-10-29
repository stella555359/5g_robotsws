*** Settings ***
Documentation    Author: zhaona.jiang@nokia-sbell.com
...              \n 8322 case use powerue kw test.


Test Timeout      120 minutes
Suite Setup       SG13 Common Suite Setup
Suite Teardown    SG13 Common Suite Teardown
Test Setup         SG13 Common Test Setup
Test Teardown     SG13 Common Test Teardown
Force Tags        qualcomm    owner_jiangzhaona
#Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot

*** Variables ***
#${CONFIG_DIR_PATH}           ${CURDIR}/../../../../resources/RAN_PZ_HAZ_34/lines/SG13/config/
${CONFIG_DIR_PATH}           /home/ute/case/config/
#${SCFC_NAME}                 scfc_AQQL_8360_base.xml
${scfc_configuration}      ${CURDIR}/config/scfc_8322_base.xml
${ATT_FILE_PATH}             att_aqql
${PHASE_FILE_PATH}           phase_aqql
#8322
${actDlSrsSubbandBm}              text|true|//*[@name\="actDlSrsSubbandBm"]
${bfSubbandSize}                  text|32 PRBs|//*[@name\="bfSubbandSize"]
${srsQualityThreshold}            text|-1200|//*[@name\="srsQualityThreshold"]
${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]
${srsPowerThreshold}              text|-1250|//*[@name\="srsPowerThreshold"]
${wbSrsPowerThreshold}            text|-1100|//*[@name\="wbSrsPowerThreshold"]
#E2
${actCDrx}                        text|true|//*[@name\="actCDrx"]
${actUlClosedLoopPwrCtrl}         text|puschSrs|//*[@name\="actUlClosedLoopPwrCtrl"]
#${cellid}                        9201
${cellid}                        9420801
*** Test Cases ***
CB008322_E2_case01_Coexistence_with_cDRX_CLPC_01
    Step1:Commission the above configuration on WebUI
    Step2:UE with attach to cell-1
    Step3:Send DL full buffer to UE-1
#    Step4:Stop Data transfer to UE-1


*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Collecting GNB Syslog in 'Step1_before_onair' File
    Set Suite Variable    ${CONFIG_FILE}    /home/ute/testline_configuration/${TL_NAME}/mcs_config.yml
    modify_swconfig_by_CB008322
#    ${Golden_SCF_Path}=    CI_commssion.Get SCF File Path    testline=${TL_NAME}    stream=${SW_VERSION}
#    Set Test Variable    ${Golden_SCF_Path}
#    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#    copy_file    ${Golden_SCF_Path}    ${scfc_path}

    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}/SCFC_newest.xml
    copy_file       ${scfc_configuration}    ${scfc_path}
    Perform Full Commission     ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    ${dl_peak_tput}   Get theoretical throughput from nrdim    SCF_Path=${scfc_path}
    set suite variable    ${dl_peak_tput}
    Log To Console   \n-------------Theoretical thp is ${dl_peak_tput}---------------
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
    [Teardown]    Stop Collecting GNB Syslog in 'Step1_before_onair' File

Step2:UE with attach to cell-1
    Start Collecting GNB Syslog in 'Step2' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
  #  set ue pos    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
#    Start GNB BIP Log
#    Set Mcs3 Channel Phase And Attenuation    ${parent_dir}/TestData/${ATT_FILE_PATH}    ${parent_dir}/TestData/${PHASE_FILE_PATH}
#    set ue pos    ${ATT_FILE_PATH}    ${PHASE_FILE_PATH}
    start l3 call
#    Stop Gnb BIP Log    log_dir=${save_log}

    [Teardown]    Stop Collecting GNB Syslog in 'Step2' File

Step3:Send DL full buffer to UE-1
    Start Collecting GNB Syslog in 'Step3' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
    start send full data
    Wait '10s' for stabible
    Log To Console    ----check tput with nrcellid----
    check the thp
    Start GNB Ttitrace With Streaming Mode
    Wait '3s' for stabible
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#    run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
#   ${counter_file}    download PM counter file    ${save_log}
#   ${PM_counter_M55308C11001_3}=    get_counter_value_from_counter_file    counter_file=${counter_file}
#   ...    counter_id=M55308C11001     cell_id=1
#   ${DL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
#   run keyword and continue on failure
#	...    check_log_with_au2anlysis    ini_path=${CURDIR}/../TestData/E2_01_step3_tti.ini    log_need_to_check=i
#   ...    save_log_directory=${save_log}
#   Run Keyword And Ignore Error    should be true     ${PM_counter_M55308C11001_3} == 120000
#   Run Keyword And Ignore Error    should be true    ${DL_thp_counter} > 1000
    [Teardown]    Stop Collecting GNB Syslog in 'Step3' File

Step4:Stop Data transfer to UE-1
   Start Collecting GNB Syslog in 'Step4' File
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4
    Stop traffic
    Wait '1s' for stabible
    start send small data
    Start GNB Ttitrace With Streaming Mode
    Wait '3s' for stabible
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#    run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
    ${counter_file}    download PM counter file    ${save_log}
    ${PM_counter_M55308C11001_4}=    get_counter_value_from_counter_file    counter_file=${counter_file}
    ...    counter_id=M55308C11001     cell_id=1
    ${DL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
    run keyword and continue on failure
	...    check_log_with_au2anlysis    ini_path=${CURDIR}/../TestData/E2_01_step4_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
    Run Keyword And Ignore Error    should be true     ${PM_counter_M55308C11001_4} < 120000
    #    Run Keyword And Ignore Error    should be true    ${DL_thp_counter} > 1000
    [Teardown]    Stop Collecting GNB Syslog in 'Step4' File

set ue pos
    [Arguments]    ${ATT}    ${PHASE}
#    Run    cp ${ATT} ${TEST_LOG_DIRECTORY()}/att; mv ${TEST_LOG_DIRECTORY()}/att ${TEST_LOG_DIRECTORY()}/att.csv
#    Run    cp ${PHASE} ${TEST_LOG_DIRECTORY()}/phase; mv ${TEST_LOG_DIRECTORY()}/phase ${TEST_LOG_DIRECTORY()}/phase.csv
    Run    cp ${parent_dir}/TestData/${ATT} ${TEST_LOG_DIRECTORY()}/att.csv
    Run    cp ${parent_dir}/TestData/${PHASE} ${TEST_LOG_DIRECTORY()}/phase.csv
    Set Mcs3 Phase And Attenuation by CSV    ${TEST_LOG_DIRECTORY()}/att.csv    ${TEST_LOG_DIRECTORY()}/phase.csv

start l3 call
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    translate power ue type from testline    ${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

start send full data
    [Arguments]    ${ue_index}=${0}    ${duration}=1500
    Log To Console    \n ###UE Start traffic and check TP ###
    ${UE_TYPE}    translate power ue type from testline    ${ue_index}
    power_ue.Start traffic   ue_index=${ue_index}    ue_type=${UE_TYPE}   direction=dl   throughput=1220M    duration=${duration}
#    power_ue.Start traffic   ue_index=${ue_index}    ue_type=${UE_TYPE}   direction=dl   throughput=610M    duration=${duration}
#    ...    iperf_port=${tl.appserver.iperf_details.port}
   # power_ue.Start traffic   ue_index=${ue_index}    ue_type=${UE_TYPE}   direction=ul   throughput=200M    duration=${duration}

start send small data
    [Arguments]    ${ue_index}=${0}    ${duration}=1500
    Log To Console    \n ###UE Start traffic and check TP ###
    ${UE_TYPE}    translate power ue type from testline    ${ue_index}
    power_ue.Start traffic   ue_index=${ue_index}    ue_type=${UE_TYPE}   direction=dl   throughput=1M    duration=${duration}

#capture wiresharklog with new way
#    [Arguments]    ${wiresharklog}    ${UE_mode}=${SA_attach_mode}    ${nettpye}=0     ${options}=-i any sctp -s 0
#    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog}    options=${options}
#    Wait Throughput Timer    3
#    MultiUE one Attach with client    UE_mode=${UE_mode}    nettype=${nettpye}
#    [Teardown]       Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}    target_dir=${epc_log_path}
#    [Return]     ${cpif_log_path}

#Capture Biplog with new way
#    [Arguments]     ${dlexpect_tp}=${Expect_dl_enable}    ${bbmod_slots}=1    ${aa_sys_addr}=${aa_sys_addr}
#    ...             ${dl_throughput}=${dl_tput_multiue}
#    log to console    start to cpature biplog
#    ${bip}=    Capture biplog and download    bbmod_slots=${bbmod_slots}
#    [Return]     ${bip}

Stop traffic
    [Arguments]    ${ue_index}=${0}
    log to console      Stop traffic
    ${ue_type}    translate power ue type from testline    ${ue_index}
    #power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}

modify_swconfig_by_CB008322
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#    [Arguments]    ${scfc_file}
#    ${local_save_path}=     Download All Common Config Files From Golden Server
#    ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
    ${cur_relative_dir}    set variable    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/Non_Feature_SG13/TestCases
    ${sw_relative_dir}    set variable    commissionings/HGZ
    ${swconfig_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${sw_relative_dir}
    Log To Console    ${swconfig_base_path}
    setup_txt    src_file=${swconfig_base_path}/${TL_NAME}/swconfig.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    add_txt_node    0x9D0000:15             #as PM counter period update to 15/15=1min
    add_txt_node    0x58076b:0x64          #rdNumWbSrsCorrExpiry=100(Defalut Value is 60)
    #add_txt_node    0x5901EA:1            #fake DRX
    add_txt_node    0x580717:0             #rdPdcchApplyToSeparateStreams
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt

Get theoretical throughput from nrdim
    [Arguments]    ${SCF_Path}
    ${dl_expect_pcell}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=1
    [Return]    ${dl_expect_pcell}[0]

check the thp
    ${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=5m    check_source=aasyslog
    ${cellsid}    create list    ${cellid}
#    power_ue.Check Tput     ue_type=${UE_TYPE}     direction=ul     cells=1    log=${tput_log}
#    ...                     target_throughput=${Expected_Throughput_UL}
    power_ue.Check Tput     ue_type=${UE_TYPE}     direction=dl     cells=${cellsid}    log=${tput_log}    target_throughput=${dl_peak_tput}
    ...    target_avg_percent=0.98    min_percent=0.8    check_source=aasyslog

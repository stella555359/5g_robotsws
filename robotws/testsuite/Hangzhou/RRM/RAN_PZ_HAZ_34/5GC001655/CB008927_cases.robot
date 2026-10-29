*** Settings ***
Documentation     author: Yu Lu
...               contact: lu.1.yu@nokia-sbell.com
...               squad group: SG_02
Suite Setup       Common Suite Setup for COAM
Suite Teardown    Common Suite Teardown
Force Tags        5G_RRM
...    PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/Resource_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          Resources/1347_common_keyword.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          Resources/common_keyword_RRM_SG2.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_logs_Capture.robot

*** Variables ***
${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs

${pdschsendreq_msg}     \"dldata_pdschsendreql1sw||dldata_csirssendreqL1sw\"

${pdschsendreq_template}     {tshark_path} -r {pcap_file} -Y ${pdschsendreq_msg} -T pdml

@{check_print}    ERR/

*** Test Cases ***
[1]CB008927-M_46_based on 2 Ues check wide band and sub-band SRS status with dynamicswitch enable
    [Setup]    Case Setup
    Load Case SCF and Commission SCF for 8927    scf_file=commissionings/HGZ/7_5_CLOUD402T215/${version}_CB008927.xml
    Reboot cpe for test    ue_index=${5}
    Sleep    5min
    Single UE GBR Call And Send Traffic
    ${ProposedMCS_ave}    ${UsedMCS_ave}    Check TTI Log
    ...         TTI_path=${tti_log_path_GBR}/format_output_dl.csv    filte_item=dlFdSchedData
#    Set Test Variable    ${UsedMCS_ave_1}    ${UsedMCS_ave}
#    Run keyword IF      '${ProposedMCS_ave}[0]'=='P'    Set Test Variable    ${UsedMCS_ave}    ${UsedMCS_ave_1}[1]
#    Run keyword IF      '${ProposedMCS_ave}[0]'=='P'    Set Test Variable    ${ProposedMCS_ave}    ${UsedMCS_ave_1}[0]
    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    COAM Update several parameters via rest api
    ...                       parameters_to_update_via_api=${PARAM_8927_PERCREDSEDLRATLVONR}
    Single UE GBR Call And Send Traffic
    Run keyword and ignore error    recover ue apn
    ${ProposedMCS_ave99}    ${UsedMCS_ave99}    Check TTI Log
    ...        TTI_path=${tti_log_path_GBR}/format_output_dl.csv    filte_item=dlFdSchedData
#    Set Test Variable    ${UsedMCS_ave99_1}    ${UsedMCS_ave99}
#    Run keyword IF      '${ProposedMCS_ave99}[0]'=='P'    Set Test Variable    ${UsedMCS_ave99}    ${UsedMCS_ave99_1}[1]
#    Run keyword IF      '${ProposedMCS_ave99}[0]'=='P'    Set Test Variable    ${ProposedMCS_ave99}    ${UsedMCS_ave99_1}[0]
    Single UE Attach And Send Traffic    need_catch_bip=${true}     need_check_counter=${true}
    should be true    ${ProposedMCS_ave99}<${ProposedMCS_ave}
    should be true    ${UsedMCS_ave99}<${UsedMCS_ave}
    [Teardown]    Case Teardown

[1]CB008927-M_53_check EIRP meansurement full buffer with signal UE with an active antenna array in digital beamforming with dynamicswitch
    [Setup]  Case Setup
    Load Case SCF and Commission SCF for 8927    scf_file=commissionings/HGZ/7_5_CLOUD402T215/${version}_CB008927_eirp_polling_off.xml
    Reboot cpe for test    ue_index=${5}
    Sleep    5min
    Single UE Attach And Send Traffic    need_catch_bip=${true}     need_check_counter=${true}
    check bip log for 8927
    [Teardown]  Case Teardown

[1]CB008927-M_46_based on 2 Ues check wide band and sub-band SRS status with dynamicswitch enable_2
    [Setup]  Case Setup
    Load Case SCF and Commission SCF for 8927    scf_file=commissionings/HGZ/7_5_CLOUD402T215/${version}_CB008927_8322.xml
    Reboot cpe for test    ue_index=${4}
    Reboot cpe for test    ue_index=${6}
    Sleep    5min
    Double UE Attach And Send Traffic
    Check BIP Log
    [Teardown]  Case Teardown

*** Keywords ***
Common Suite Setup for COAM
    Connect to gnb coam via ssl
    robot_common_operations.Common Suite Setup
    check pdl after sw update    download_dir=/home/ute/Downloads
    ${version}     get software version
    Set suite variable    ${version}    ${version}
    Get SCF path for T215    version=${version}
    Recover swconfig file for T215     swconfig_file=${SCF_PATH}/commissionings/HGZ/7_5_CLOUD402T215/swconfig.txt

Common Suite Teardown
    robot_common_operations.Common Suite Teardown

Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    robot_common_operations.Common Case Setup

Load Case SCF and Commission SCF for 8927
    [Arguments]    ${scf_file}
    COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min

Recover swconfig file for T215
    [Arguments]  ${swconfig_file}
    Connect to Common Unit Master
    Upload_swConfig_file_to_asik_and_crasign    localFilePath=${swconfig_file}    asik_alias=ASIK Master
    Csn.Disconnect    connection=ASIK Master

Get SCF path for T215
    [Arguments]  ${version}
    Selenium Login And Disable Screen Lock    version=${version}
    log to console  ${CURDIR}
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -47
    Set suite variable    ${SCF_PATH}    ${SCF_PATH}
    log to console    ${SCF_PATH}

Case Teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run keyword and ignore error    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

recover ue apn
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${5}
	ute_ue.set apn    UE_${5}    apn_name=dxdata2

get software version
    COAM Navigate to login page via webUI
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    Set suite Variable    ${current_version}    ${current_version['Active']}
    COAM selenium logout
    ${stream}    String.Get Substring    ${current_version}    0    8
    [Return]     ${stream}

Single UE GBR Call And Send Traffic
    [Arguments]    ${ul_tp}=50M    ${dl_tp}=50M    ${duration}=3000    ${apn}=mdrb.nokia.com
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[1]
    log to console    \n***Prepare UE_5***
	${ue_type}    translate_power_ue_type_from_testline    ue_index=${5}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${5}
	ute_ue.set apn    UE_${5}    apn_name=${apn}
	${apn}    ute_ue.get apn    UE_${5}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${5}     log_type=Iperf    pci=483
    power_ue.Start traffic   ue_type=${ue_type}   direction=dl   throughput=${dl_tp}   duration=${duration}   ue_index=${5}   apn_address=${apn}
	power_ue.Start traffic   ue_type=${ue_type}   direction=ul   throughput=${ul_tp}   duration=${duration}   ue_index=${5}   apn_address=${apn}
#	&{tti_log_path_GBR}    Capture TTI log
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Test Variable    ${timestamp}
    Connect to gnb coam via ssl
    TTI_logs_Capture.Start Ttitrace With Streaming Mode    collector_names=l2stream3_ttitrace    eth_port_on_ute=eth0
    Sleep    2s    reason=Wait for logs
    TTI_logs_Capture.Stop Ttitrace    collector_names=l2stream3_ttitrace     log_dir=${TS_CASE_LOG_PATH}/ttitrace_streaming_${timestamp}
    ${tti_log_path_GBR}    TTI_logs_Capture.Decode Ttitrace Logs    collector_names=l2stream3_ttitrace    by_filter=${False}
    ...    except_filter=${False}    filter=None    format_tti_log=${True}    log_dir=${TS_CASE_LOG_PATH}/ttitrace_streaming_${timestamp}
	Set Test Variable    ${tti_log_path_GBR}
    Run keyword and ignore error    Check DL UL Throughput On Site    cells=${cell1}    ue_type=${ue_type}    dl_target=15    ul_target=15
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${5}
	Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${5}

Check DL UL Throughput On Site
    [Arguments]    ${cells}    ${ue_type}    ${dl_target}=2700    ${ul_target}=120
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m    ignore_time=0min    check_source=Aasyslog
    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log_path}    cells=${cells}    target_throughput=${dl_target}
    ...      check_source=Aasyslog
    power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${log_path}    cells=${cells}    target_throughput=${ul_target}
    ...      check_source=Aasyslog

Single UE Attach And Send Traffic
    [Arguments]    ${ul_tp}=200M    ${dl_tp}=2000M    ${duration}=3000
    ...        ${need_check_counter}=${false}
    ...        ${need_catch_bip}=${false}
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[1]
    log to console    \n***Prepare UE_5***
	${ue_type}    translate_power_ue_type_from_testline    ue_index=${5}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${5}
    ${status}    Run keyword and return status    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${5}
    ...    log_type=Iperf    pci=483
    Run keyword if    '${status}'=='False'    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${5}
    ...    log_type=Iperf    pci=483
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${duration}    ue_index=${5}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${duration}    ue_index=${5}
    ...    process_num=5
    Run keyword and continue on failure    Run Keyword If    ${need_catch_bip} == ${true}    Capture L2L1 BIP log and download for 8927
    Run keyword and continue on failure    Run Keyword If    ${need_check_counter} == ${true}    check counter for 8927 eirp
    Run keyword and ignore error    Check DL UL Throughput On Site    cells=${cell1}    ue_type=${ue_type}    dl_target=1400    ul_target=150
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${5}
	Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${5}

check counter for 8927 eirp
    sleep    2s

Check TTI Log
    [Arguments]    ${TTI_path}    ${filte_item}
    ${rrmDlUsedMcs_values}    check_newformat_tti_by_value_2    file_path=${TTI_path}    filte_item=${filte_item}    find_value=rrmDlUsedMcs
    ${rrmDlProposedMcs_values}    check_newformat_tti_by_value_2    file_path=${TTI_path}    filte_item=${filte_item}    find_value=rrmDlProposedMcs
    ${rrmDlUsedMcs_avge}    get_avge_2    gap_list=${rrmDlUsedMcs_values}
    ${rrmDlProposedMcs_avge}    get_avge_2    gap_list=${rrmDlProposedMcs_values}
    [Return]  ${rrmDlProposedMcs_avge}    ${rrmDlUsedMcs_avge}

Capture L2L1 BIP log and download for 8927
    [Arguments]     ${duration}=3s
    Start Bip Logs Capture for 8927
    Sleep    ${duration}
    ${log_path_local}    Stop Bip Logs Capture and Download Logs for 8927
    set test variable    ${bip_log_path}    ${log_path_local}

Start Bip Logs Capture for 8927
    ${8927_timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Test Variable    ${8927_timestamp}
    Start Bip Log with Suitable Means    target_file_name=l1l2bip_log_${8927_timestamp}

Stop Bip Logs Capture and Download Logs for 8927
    ${bip_log_local}    Stop Bip Log with Suitable Means    target_file_name=l1l2bip_log_${8927_timestamp}
    set test variable    ${bip_log}    ${bip_log_local}[0]
    [Return]    ${bip_log}

Check bip log for 8927
    Check L2L1 BIp Log by Luashark for 8927     bip_log=${bip_log_path}

Load BIP with Luashark for 8927
    [Arguments]     ${bip_file}      ${command_template}     ${alias}
    ${packets}    pcap.load_pcap_file   pcap_file=${bip_file}
	...                                 tshark_path=${tshark_path}
    ...                                 command_template=${command_template}
    ...                                 alias=${alias}
    [Return]   ${packets}

Check L2L1 BIp Log by Luashark for 8927
    [Arguments]  ${bip_log}
    ${packets}    Load BIP with Luashark for 8927    bip_file=${bip_log}
    ...          command_template=${pdschsendreq_template}
    ...          alias=8927_eirp
    ${value1}    Get value from Bip Log    field_name=DlData_PdschGrantL1sw.rat0Bitmap    pcap_parser=8927_eirp
    ${lenth}    get length    ${value1}
    FOR  ${len}  IN RANGE  ${lenth}
        should be true    ${value1}[${len}] == 0
    END

Double UE Attach And Send Traffic
    [Arguments]    ${duration}=600
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[1]
    log to console    \n***Prepare UE_1***
	${ue_type}    translate_power_ue_type_from_testline    ue_index=${4}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${4}     log_type=Iperf
	log to console    \n***begin to traffic***
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1500M    duration=${duration}    ue_index=${4}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=150M    duration=${duration}    ue_index=${4}
    ...    process_num=5
    log to console    \n***Prepare UE_2***
	${ue_type}    translate_power_ue_type_from_testline    ue_index=${6}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${6}     log_type=Iperf
	log to console    \n***begin to traffic***
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1500M    duration=${duration}    ue_index=${6}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=150M    duration=${duration}    ue_index=${6}
    Common Capture BIP log and download    duration=1s
    #&{tti_log_path}    Capture TTI log
    Run keyword and ignore error    Check DL UL Throughput On Site    cells=${cell1}    ue_type=${ue_type}    dl_target=15    ul_target=15
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${4}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${4}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${6}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${6}

Check BIP Log
    Load BIP Log
    ${value1}    Get value from Bip Log    field_name=UlData_srsBwvReport_t.result    pcap_parser=8927_8322
	${value2}    Get value from Bip Log    field_name=UlData_srsBwvReport_t.numBwvPerSubband    pcap_parser=8927_8322
	${value3}    Get value from Bip Log    field_name=UlData_srsBwvReport_t.startPatternId    pcap_parser=8927_8322
	${value4}    Get value from Bip Log    field_name=UlData_srsBwvReport_t.correlation_item    pcap_parser=8927_8322
	${lenth}    get length    ${value1}
    FOR  ${len}  IN RANGE  ${lenth}
        should be true    ${value1}[${len}] == 0
		should be true    ${value2}[${len}] == 4
		should be true    ${value3}[${len}] > 2000
		should be true    ${value4}[${len}] > 0.9
    END
    Check bip log for 8927

Load BIP Log
    [Arguments]    ${bip_file}=${bip_log_path}     ${alias}=8927_8322
    ${packets}    pcap.load_pcap_file   pcap_file=${bip_file}
	...                                 tshark_path=${tshark_path}
    ...                                 command_template={tshark_path} -r ${bip_file} -Y 'uldata_srsreceiverespbwvps' -T pdml
    ...                                 alias=${alias}
    [Return]   ${packets}

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

${tshark_path}    /usr/bin/tshark

${command_template}      {tshark_path} -r {pcap_file} -T pdml

${pdschsendreq_msg}     \"(dldata_pdschsendreql1sw)&&!(3gpp.rnti == 65535)\"

${command_template_cpif}      {tshark_path} -r {pcap_file} -Y "nr-rrc.rrcReconfiguration_element" -T pdml

${dmrs_AdditionalPosition}    nr-rrc.dmrs_AdditionalPosition



${DL_THROUGHPUT}    2000M
${DL_EXPECT}    500

@{check_print}    ERR/

${dmrsStatus_txt}       'dmrsStatus': '(.*?)'
${rnti_txt}       'rnti': (.*?),

${srsState_txt}     'srsState': '(.*?)'

*** Test Cases ***
[1]CB011117_E_40_Enhanced_Algorithm_DMRS_switch_monitor_One_PDSCH_DMRS_UE_with_subband BF_32TRX_1116-0ms_and_8406
    [Setup]    Case Setup
    Reboot cpe for test    ue_index=${0}
    Sleep    5min
    Run Keyword And Ignore Error     UE Attach and collect log
    ...                           throughput_dl=${DL_THROUGHPUT}
    ...                           target_throughput_dl=${DL_EXPECT}
    Connect to gnb coam via ssl
#    Recover swconfig file for T215     swconfig_file=${SCF_PATH}/commissionings/HGZ/7_5_CLOUD402T215/swconfig_11117.txt
    Load Case SCF and Commission SCF for 11117    scf_file=commissionings/HGZ/7_5_CLOUD402T215/${version}_CB011117_E.xml
    power_ue.UE Detach    ue_type=nokia_fastmile    ue_index=${0}    power_reset=True
    sleep    5min
    Run Keyword And Ignore Error     UE Attach and collect log
    ...                           throughput_dl=${DL_THROUGHPUT}
    ...                           target_throughput_dl=${DL_EXPECT}
    ...                           need_catch_bip=${true}
    ...                           need_start_cpif=${true}
    ...                           need_stop_cpif=${true}
    ...                           need_catch_tti=${true}
    Run Keyword And Continue On Failure    Check bip log for 11117
    Run Keyword And Continue On Failure    check tti log for 11117    TTI_path=${tti_log_path}/format_output_dl.csv
    Run Keyword And Continue On Failure    Check cpif log for 11117    cpif_log=${cpif_log}
    ${rate}=  Evaluate  (${tuput_result_open}[0][average]-${tuput_result_no_open}[0][average])/${tuput_result_no_open}[0][average]
    should be true    ${rate}>=0.05
    [Teardown]    Case Teardown

[1]CB011117_A_10_SingleUE_Handover_with_SRS_for_SB_BF_actHoWithSbBf_true_Inter-Frequency_HO_measurement_gap_intra-gNB_32TRX_1116-0ms_and_8406
    [Setup]  Case Setup
    Load Case SCF and Commission SCF for 11117    scf_file=commissionings/HGZ/7_5_CLOUD402T215/${version}_CB011117_E_polling_off.xml
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
#    Recover swconfig file for T215     swconfig_file=${SCF_PATH}/commissionings/HGZ/7_5_CLOUD402T215/swconfig.txt
    Load Case SCF and Commission SCF for 11117    scf_file=commissionings/HGZ/7_5_CLOUD402T215/${version}_CB011117_no_open.xml
    sleep    60s
    robot_common_operations.Common Case Setup
    Run Keyword And Continue On Failure    Check for unexpected alarms

Load Case SCF and Commission SCF for 11117
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

get software version
    COAM Navigate to login page via webUI
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    Set suite Variable    ${current_version}    ${current_version['Active']}
    COAM selenium logout
    ${stream}    String.Get Substring    ${current_version}    0    8
    [Return]     ${stream}

UE Attach and collect log
    [Arguments]  ${throughput_dl}    ${target_throughput_dl}    ${du_index}=${0}
    ...          ${need_catch_bip}=${false}    ${need_stop_cpif}=${false}    ${need_catch_tti}=${false}
    ...          ${need_start_cpif}=${false}
    ...          ${wireshark_capture_interface}=-p -i any sctp -s 0
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[2]
    log to console    \n***Prepare UE_1***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
#    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}

    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Connect to Common Unit Master     alias=ASIK Master
    run keyword and continue on failure    Run Keyword If    ${need_start_cpif} == ${true}    Start CP-IF Log Collection
    ...                             tcpdump_collector_name=ulTxSwithch_${timestamp}
    ...                            asik_connection_alias=ASIK Master
    ...                            du_index=${du_index}
    ...                            options=${wireshark_capture_interface}

    ${5Grach_ed}     wait until keyword succeeds    4x    3s    power_ue.UE Attach     ue_type=${ue_type}    pci=484
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${throughput_dl}     duration=2000
    Sleep   5sec

    ${cpif_log}    run keyword and continue on failure    Run Keyword If    ${need_stop_cpif} == ${true}    Stop tcpdump log collection
    ...                                                        tcpdump_collector_name=ulTxSwithch_${timestamp}
    ...                                                        target_dir=${TS_CASE_LOG_PATH}
    Set Test Variable    ${cpif_log}
    Run Keywords    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master    AND
    ...                           Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master

    run keyword and continue on failure    Run Keyword If    ${need_catch_bip} == ${true}    Capture L2L1 BIP log and download for 11117

    Connect to gnb coam via ssl

#    &{tti_log_path}    run keyword and continue on failure    Run Keyword If    ${need_catch_tti} == ${true}    Capture TTI log
    ${tti_log_path}    run keyword and continue on failure    Run Keyword If    ${need_catch_tti} == ${true}    Capture And Decode TTitrace Log
    ...            duration=2    format_tti_log=${True}
	Set Test Variable    ${tti_log_path}

    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=10m    check_source=Aasyslog
    ${tput_result}    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${cell1}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}    check_source=Aasyslog
    Run Keyword If    ${need_catch_bip} == ${true}    Set Test Variable    ${tuput_result_open}    ${tput_result}
    ...      ELSE        Set Test Variable    ${tuput_result_no_open}    ${tput_result}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl

Capture L2L1 BIP log and download for 11117
    [Arguments]     ${duration}=3s
    Start Bip Logs Capture for 11117
    Sleep    ${duration}
    ${log_path_local}    Stop Bip Logs Capture and Download Logs for 11117
    set test variable    ${bip_log_path}    ${log_path_local}

Start Bip Logs Capture for 11117
    ${11117_timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Test Variable    ${11117_timestamp}
    Start Bip Log with Suitable Means    target_file_name=l1l2bip_log_${11117_timestamp}

Stop Bip Logs Capture and Download Logs for 11117
    ${bip_log_local}    Stop Bip Log with Suitable Means    target_file_name=l1l2bip_log_${11117_timestamp}
    set test variable    ${bip_log}    ${bip_log_local}[0]
    [Return]    ${bip_log}

Load BIP with Luashark for 11117
    [Arguments]     ${bip_file}      ${command_template}     ${alias}
    ${packets}    pcap.load_pcap_file   pcap_file=${bip_file}
	...                                 tshark_path=${tshark_path}
    ...                                 command_template=${command_template}
    ...                                 alias=${alias}
    [Return]   ${packets}

Check bip log for 11117
    Check L2L1 BIp Log by Luashark for 11117     bip_log=${bip_log_path}

Get need pdml from bip
    [Arguments]    ${pcap_file}   ${search_msg}    ${output}
    Set Test Variable    ${outpdml_command}    ${tshark_path} -r ${pcap_file} -Y ${search_msg} -T pdml > ${output}
    Run    ${outpdml_command}

Check L2L1 BIp Log by Luashark for 11117
    [Arguments]  ${bip_log}
    Get need pdml from bip    pcap_file=${bip_log}    search_msg=${pdschsendreq_msg}    output=${OUTPUT DIR}/11117.pdml
    ${dlDmrsAddPos_value_list}    get_need_info_from_pdml_for_11117    file_path=${OUTPUT DIR}/11117.pdml
    ${find_count}    count_kpi_value_in_list    gap_list=${dlDmrsAddPos_value_list}    find_value=${0}
    ${count}    get length    ${dlDmrsAddPos_value_list}
    ${laste_index}=  Evaluate    ${count}-1
    ${find_rate}=  Evaluate    ${find_count}/${count}
    should be true    ${find_rate}>0.95
    Should Be Equal    ${dlDmrsAddPos_value_list}[${laste_index}]    ${0}

check tti log for 11117
    [Arguments]    ${TTI_path}
    ${dmrsStatus}    find_gap_value    file_path=${TTI_path}    filte_item=dlNoAddDmrsSwitchMeasData    txt=${dmrsStatus_txt}
    ${cell_id_1}    check_newformat_tti_by_value    file_path=${TTI_path}    filte_item=dlNoAddDmrsSwitchMeasData    find_value=lcrId
    ${ue_id_1}    find_gap_value    file_path=${TTI_path}    filte_item=dlNoAddDmrsSwitchMeasData    txt=${rnti_txt}
    ${lenth1}    get length    ${dmrsStatus}
    FOR    ${i}    IN RANGE    ${lenth1}
        Run Keyword if    '${cell_id_1}[${i}]'=='${601}'    Should Be Equal    ${dmrsStatus}[${i}][0]    NOADDITIONAL
        Run Keyword if    '${dmrsStatus}[${i}][0]'=='NOADDITIONAL'    Set Test Variable    ${ue_id}    ${ue_id_1}[${i}][0]
    END
    ${ssrsState}    find_gap_value    file_path=${TTI_path}    filte_item=srsSwitchMeasData    txt=${srsState_txt}
    ${cell_id_2}    check_newformat_tti_by_value    file_path=${TTI_path}    filte_item=srsSwitchMeasData     find_value=lcrId
    ${ue_id_2}    find_gap_value    file_path=${TTI_path}    filte_item=srsSwitchMeasData    txt=${rnti_txt}
    ${lenth2}    get length    ${ssrsState}
    FOR    ${i}    IN RANGE    ${lenth2}
        Run Keyword if    '${cell_id_2}[${i}]'=='${601}' and '${ue_id_2}[${i}][0]'=='${ue_id}'
        ...                    Should Be Equal    ${ssrsState}[${i}][0]    WBSRS
    END

Check cpif log for 11117
    [Arguments]    ${cpif_log}
    ${packets}    Load BIP with Luashark for 11117    bip_file=${cpif_log}
    ...                                 command_template=${command_template_cpif}
    ...                                 alias=cpif_rrc
    ${AdditionalPosition_value_list}    pcap.get_field_value_by_name    pdml_list=${packets}
        ...      field_name=${dmrs_AdditionalPosition}
        ...      pcap_parser=cpif_rrc
    ${AdditionalPosition_value_list}    list_to_repeat    old_list=${AdditionalPosition_value_list}
    ${result}    check_list_accrod_gap_value    gap_list=${AdditionalPosition_value_list}
    ...                                         first_value=${1}
    ...                                         last_value=${0}
    ${result}    Convert To String    ${result}
    Should Be Equal    ${result}    True

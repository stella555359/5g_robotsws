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

*** Variables ***
${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs

${tshark_path}    /usr/bin/tshark

${command_template}      {tshark_path} -r {pcap_file} -T pdml

${csirssendreq_msg}      \"dldata_csirssendreql1sw and DlData_CsiRsResourceL1sw_t.trsInfo==1\"


${csirssendreq_msg_2}    \"dldata_csirssendreql1sw and
...                      DlData_CsiRsResourceL1sw_t.trsInfo == 0 and
...                      DlData_CsiRsResourceL1sw_t.patternId_item == 1 and
...                      DlData_CsiRsResourceL1sw_t.startSymbol == 13 and
...                      DlData_CsiRsResourceL1sw_t.startSymbol != 10\"


${csirssendreq_msg_3}    \"dldata_csirssendreql1sw and
...                      DlData_CsiRsResourceL1sw_t.trsInfo == 0 and
...                      DlData_CsiRsResourceL1sw_t.patternId_item == 1 and
...                      DlData_CsiRsResourceL1sw_t.startSymbol == 10 and
...                      DlData_CsiRsResourceL1sw_t.startSymbol !=13\"


${csirssendreq_msg_4_1}    \"dldata_pdschsendreql1sw and
...                        DlData_PdschGrantL1sw.rateMatchingOption == 4 and
...                        DlData_PdschGrantL1sw.symbolRateMatchingPositions == 816 and
...                        DlData_PdschGrantL1sw.numRateMatchingRes == 13104\"


${csirssendreq_msg_4_2}    \"dldata_pdschsendreql1sw and
...                        DlData_PdschGrantL1sw.rateMatchingOption == 4 and
...                        DlData_PdschGrantL1sw.symbolRateMatchingPositions == 272 and
...                        DlData_PdschGrantL1sw.numRateMatchingRes == 6552\"


${csirssendreq_msg_4_3}    \"dldata_pdschsendreql1sw and
...                        DlData_PdschGrantL1sw.rateMatchingOption ==1 and
...                        DlData_PdschGrantL1sw.numRateMatchingRes == 1092\"

${csirssendreq_msg_C_4_1}    \"dldata_pdschsendreql1sw and
...                        DlData_PdschGrantL1sw.rateMatchingOption == 4 and
...                        DlData_PdschGrantL1sw.symbolRateMatchingPositions == 816 and
...                        (DlData_PdschGrantL1sw.numRateMatchingRes == 9984 || DlData_PdschGrantL1sw.numRateMatchingRes == 11520)\"


${csirssendreq_msg_C_4_2}    \"dldata_pdschsendreql1sw and
...                        DlData_PdschGrantL1sw.rateMatchingOption == 4 and
...                        DlData_PdschGrantL1sw.symbolRateMatchingPositions == 272 and
...                        (DlData_PdschGrantL1sw.numRateMatchingRes == 4992 || DlData_PdschGrantL1sw.numRateMatchingRes == 5760)\"


${csirssendreq_msg_C_4_3}    \"dldata_pdschsendreql1sw and
...                        DlData_PdschGrantL1sw.rateMatchingOption ==1 and
...                        (DlData_PdschGrantL1sw.numRateMatchingRes == 832 || DlData_PdschGrantL1sw.numRateMatchingRes == 960)\"

${pdschsendreq_msg}    \"dldata_pdschsendreql1sw\"

${command_template_pdschsendreq_msg}     {tshark_path} -r {pcap_file} -Y ${pdschsendreq_msg} -T pdml

${numOfPdschSymbols_filed_name}    DlData_PdschGrantL1sw.numOfPdschSymbols

${startSymbol_filed_name}     DlData_PdschGrantL1sw.startSymbol

${csirssendreq_msg_C}    \"dldata_csirssendreql1sw and 3gpp.slot == 5\"


${UL_THROUGHPUT}    200M
${DL_THROUGHPUT}    1500M
${UL_EXPECT}    50
${DL_EXPECT}    500

@{check_print}    ERR/

*** Test Cases ***
[1][1.0] CB012269_A_10_Sub-band TRS Rate Matching_actSubTrsRateMatch_true
    [Setup]    Case Setup for CB012269_A
    Run keyword and ignore error    Check RMOD runtime log by radios
    Reboot cpe for test    ue_index=${0}
    Sleep    5min
    Run Keyword And Ignore Error     UE Attach and collect biplog   throughput_ul=${UL_THROUGHPUT}
    ...                           throughput_dl=${DL_THROUGHPUT}
    ...                           target_throughput_ul=${UL_EXPECT}
    ...                           target_throughput_dl=${DL_EXPECT}
    Check bip log for 12269
    [Teardown]    Case Teardown

[1][1.0] CB012269_B_2_UE specific CSI-RS optimization_coexist_with_cell_specific_csirs_Ues
    [Setup]  Case Setup for CB012269_B

    ${gap_slot_index}    ${gap_slot}    Check SysLog Result and get no 8192 slot for 12269_B    file_path=${file_path_gap}
    Set Test Variable    ${gap_slot_1}    ${gap_slot}
    Run keyword IF      '${gap_slot_index}[0]'=='P'    Set Test Variable    ${gap_slot}    ${gap_slot_1}[1]
    Run keyword IF      '${gap_slot_index}[0]'=='P'    Set Test Variable    ${gap_slot_index}    ${gap_slot_1}[0]

    Run keyword and ignore error    Check RMOD runtime log by radios
    Reboot cpe for test    ue_index=${0}
    Reboot cpe for test    ue_index=${4}
    Sleep    5min
    Run Keyword And Ignore Error     MUTI UE Attach and collect biplog
#    ${xz_file}    Download File From ASIK To TestPC    log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
#    Run keyword IF      '${xz_file}[0]'=='PASS'    Set Test Variable    ${xz_file}    ${xz_file}[1]
#    Set Test Variable    ${unxz_command}    unxz ${xz_file}[0]
#    Run    ${unxz_command}
#    ${gap_slot_index}    ${gap_slot}    Check CPRT Log Result and get no 8192 slot for 12269_B    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
#    Set Test Variable    ${gap_slot_1}    ${gap_slot}
#    Run keyword IF      '${gap_slot_index}[0]'=='P'    Set Test Variable    ${gap_slot}    ${gap_slot_1}[1]
#    Run keyword IF      '${gap_slot_index}[0]'=='P'    Set Test Variable    ${gap_slot_index}    ${gap_slot_1}[0]
    Check bip log for 12269_B    gap_slot_index=${gap_slot_index}    gap_slot=${gap_slot}
    [Teardown]  Case Teardown

[1][1.0] CB012269_C_7_Interworking with CB008662 Adaptive re-transmission
    [Setup]    Case Setup for CB012269_C
    Reboot cpe for test    ue_index=${0}
    Reboot cpe for test    ue_index=${4}
    Reboot cpe for test    ue_index=${9}
    Sleep    5min
    Run Keyword And Ignore Error     Three UE Attach and collect biplog
    Check bip log for 12269_C
    [Teardown]    Case Teardown

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

Case Setup for CB012269_A
    COAM Create log directory
    Connect to gnb coam via ssl
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Test Variable    ${timestamp}
    Load Case SCF and Commission SCF for 12269    scf_file=commissionings/HGZ/7_5_CLOUD402T215/${version}_CB012269.xml
    sleep    60s
    robot_common_operations.Common Case Setup

Case Setup for CB012269_B
    COAM Create log directory
    Connect to gnb coam via ssl
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Test Variable    ${timestamp}
    Run keyword and ignore error    Start Btslog Collect
    Load Case SCF and Commission SCF for 12269    scf_file=commissionings/HGZ/7_5_CLOUD402T215/${version}_CB012269_B.xml
    sleep    10s
    Run keyword and ignore error    Stop Btslog Collect    target_dir=${OUTPUT DIR}/${timestamp}
    Run keyword and ignore error    check syslog print    log_prefix=syslog_files    path=${OUTPUT DIR}/${timestamp}/btslog
    ...     log_path=${OUTPUT DIR}/${timestamp}    need_fail_case=${False}    target_print=${check_print}
    sleep    60s
    csn.Connect to     hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...                username=${tl.test_pc.default_ssh_connection_details.username}
    ...                password=${tl.test_pc.default_ssh_connection_details.password}
    ...                alias=test_pc
    @{list_log_names_2}    ssh_common_commands.get_file_names_under_directory    directory=${OUTPUT DIR}/${timestamp}/btslog    connection=test_pc
        ...    file_indicator=SYSLOG_*
    should not be empty  ${list_log_names_2}    msg=No file found with log prefix SYSLOG* under folde
    ${count_log}    Get length    ${list_log_names_2}
    Run Keyword If    ${count_log} >= ${2}
    ...    Set Test Variable    ${file_path1}    ${OUTPUT DIR}/${timestamp}/btslog/${list_log_names_2}[0]
    Run Keyword If    ${count_log} >= ${2}
    ...   Set Test Variable    ${file_path2}    ${OUTPUT DIR}/${timestamp}/btslog/${list_log_names_2}[1]
    Run Keyword If    ${count_log} >= ${2}
    ...    csn.execute    command=cat ${file_path1} ${file_path2} > ${OUTPUT DIR}/${timestamp}/btslog/gap_file_0.txt    connection=test_pc
    Run Keyword If    ${count_log} >= ${2}
    ...    Set Test Variable    ${file_path}    ${OUTPUT DIR}/${timestamp}/btslog/gap_file_0.txt
    Run Keyword If    ${count_log} == ${1}
    ...    Set Test Variable    ${file_path}    ${OUTPUT DIR}/${timestamp}/btslog/${list_log_names_2}[0]
    ${alllines}=    csn.execute    command=grep -n 'availablePucchAndCsiRsResources' ${file_path}    connection=test_pc
    ${gap_line}    get_gap_line    gobal_info=${alllines}
    csn.execute    command=awk 'NR>=${gap_line}' ${file_path} > ${OUTPUT DIR}/${timestamp}/btslog/gap_file.txt    connection=test_pc
    Set Test Variable    ${file_path_gap_1}    ${OUTPUT DIR}/${timestamp}/btslog/gap_file.txt
    csn.execute    command=grep 'cp_rt/L2PsSetup' ${file_path_gap_1} > ${OUTPUT DIR}/${timestamp}/btslog/gap_file_1.txt
    ...      connection=test_pc
    Set Test Variable    ${file_path_gap}    ${OUTPUT DIR}/${timestamp}/btslog/gap_file_1.txt
    robot_common_operations.Common Case Setup

Case Setup for CB012269_C
    COAM Create log directory
    Connect to gnb coam via ssl
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Test Variable    ${timestamp}
    Recover swconfig file for T215     swconfig_file=${SCF_PATH}/commissionings/HGZ/7_5_CLOUD402T215/swconfig_12269_C.txt
    Load Case SCF and Commission SCF for 12269    scf_file=commissionings/HGZ/7_5_CLOUD402T215/${version}_CB012269_C.xml
    sleep    60s
    robot_common_operations.Common Case Setup

Recover swconfig file for T215
    [Arguments]  ${swconfig_file}
    Connect to Common Unit Master
    Upload_swConfig_file_to_asik_and_crasign    localFilePath=${swconfig_file}    asik_alias=ASIK Master
    Csn.Disconnect    connection=ASIK Master

Check RMOD runtime log by radios
    [Arguments]    ${connection}=GNB_OAM      ${alias}=ASIK Master
    Run Keyword And Ignore Error      COAM Teardown gnb connections    connection=${connection}
    Run Keyword And Ignore Error      csn.disconnect      connection=${alias}
    Connect to gnb coam via ssl
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    FOR      ${i}      IN RANGE      ${count_RUs}
        ${ru_idx}      Evaluate      ${i}+1
        &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_idx}   connection=${connection}
        ${productName}      Set Variable    ${ru_info['productName']}
        Run keyword IF      "${productName}"=="AEHC"      Check RMOD runtime      ru_index=${ru_idx}
    END
    [Teardown]      Run keywords      Run Keyword And Ignore Error      csn.disconnect      connection=${alias}
    ...      AND      COAM Teardown gnb connections    connection=${connection}

Check RMOD runtime
    [Arguments]    ${ru_index}      ${download_dir}=${TS_CASE_LOG_PATH}
    ...      ${timeout}=300      ${alias}=ASIK Master
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    ${rfsw_log_path_on_ru}   Capture RFSW Log On RU    connection=RU_${ru_index}    timeout=${timeout}
    Sleep   10 sec
    ${rfsw_log_path_on_testPC}    Download RU File To TestPC    ru_file_path=${rfsw_log_path_on_ru}
    ...                                                         connection=RU_${ru_index}
    ...                                                         download_dir=${download_dir}
    Set Task Variable      ${rfsw_log_path_on_testPC}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_unzip_file_path}    Join Path    ${TS_CASE_LOG_PATH}    RFSW_${timestamp}
    Run   rm -rf ${snapshot_unzip_file_path}
    extract zip file    ${rfsw_log_path_on_testPC}    ${snapshot_unzip_file_path}
    ${RFSW_runtime_file_path}    Join Path    ${snapshot_unzip_file_path}    1011_runtime
    Run   rm -rf ${RFSW_runtime_file_path}
    extract zip file    ${snapshot_unzip_file_path}/1011_runtime.zip    ${RFSW_runtime_file_path}
    ${output}      run     xzcat ${RFSW_runtime_file_path}/runtime_DEFAULT.log.xz|grep 'Invalid prach config'
    should be empty      ${output}
    [Teardown]      Run Keyword And Ignore Error      csn.disconnect      connection=${alias}

Get SCF path for T215
    [Arguments]  ${version}
    Selenium Login And Disable Screen Lock    version=${version}
    log to console  ${CURDIR}
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -47
    Set suite variable    ${SCF_PATH}    ${SCF_PATH}
    log to console    ${SCF_PATH}

Download File From ASIK To TestPC
    [Arguments]   ${log_prefix}    ${path}    ${log_path}=${TS_CASE_LOG_PATH}    ${connection}=ASIK Master
    Connect to Common Unit Master
    @{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
    ...    file_indicator=${log_prefix}*
    should not be empty  ${list_log_names}    msg=No file found with log prefix ${log_prefix} under asik tmp folde
    @{list_log_path_local}    Create list
    FOR  ${log_name}  IN  @{list_log_names}
        Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
        ...   remote_path=${path}/${log_name}
        ...   local_path=${log_path}/${log_name}
        ...   connection=${connection}
        Append to list    ${list_log_path_local}    ${log_path}/${log_name}
    END
    [Return]    ${list_log_path_local}

Check CPRT Log Result and get no 8192 slot for 12269_B
    [Arguments]  ${file_path}
#    ${slot_list_1}  ${slot_list_2}  ${slot_list_3}  ${slot_list_4}  Run Keyword If  '${version}'=='SBTS25R1'
#    ...               get_value_from_cprt  file_path=${file_path}
#    ...       ELSE     get_value_from_cprt_log    file_path=${file_path}
    ${value_list_1}  ${value_list_2}  ${value_list_3}  ${value_list_4}    get_value_from_cprt  file_path=${file_path}
    Should Be Equal    ${value_list_1}    ${value_list_2}
    Should Be Equal    ${value_list_3}    ${value_list_4}
    Should Be Equal    ${value_list_1}    ${value_list_3}
    ${gap_list_1}    get_target_list    gap_list=${value_list_1}
    ${no_8192_list}    get_no_8192_slot_list    slot=${gap_list_1}     value_list=${value_list_1}
    ${lenth}    get length    ${no_8192_list}
    ${need_check_slot_index}    get_random_num    count=${4}    range_value=${lenth}
    [Return]  ${need_check_slot_index}    ${no_8192_list}

Check SysLog Result and get no 8192 slot for 12269_B
    [Arguments]  ${file_path}
    ${value_list_1}  ${value_list_2}  ${value_list_3}  ${value_list_4}    get_value_from_syslog  file_path=${file_path}
    Should Be Equal    ${value_list_1}    ${value_list_2}
    Should Be Equal    ${value_list_3}    ${value_list_4}
    Should Be Equal    ${value_list_1}    ${value_list_3}
    ${gap_list_1}    get_target_list    gap_list=${value_list_1}
    ${no_8192_list}    get_no_8192_slot_list    slot=${gap_list_1}     value_list=${value_list_1}
    ${lenth}    get length    ${no_8192_list}
    ${need_check_slot_index}    get_random_num    count=${4}    range_value=${lenth}
    [Return]  ${need_check_slot_index}    ${no_8192_list}

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

Load Case SCF and Commission SCF for 12269
    [Arguments]    ${scf_file}
    COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min

UE Attach and collect biplog
    [Arguments]  ${throughput_ul}    ${throughput_dl}    ${target_throughput_ul}    ${target_throughput_dl}
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[3]
    log to console    \n***Prepare UE_1***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
#    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${throughput_ul}     duration=2000    process_num=5
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${throughput_dl}     duration=2000
    Capture L2L1 BIP log and download for 12269
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m    check_source=Aasyslog
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${cell1}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}    check_source=Aasyslog
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${cell1}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}    check_source=Aasyslog
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul

MUTI UE Attach and collect biplog
    UE1 Attach and start traffic     throughput_ul=${UL_THROUGHPUT}
    ...                           throughput_dl=${DL_THROUGHPUT}
    UE5 Attach and start traffic     throughput_ul=${UL_THROUGHPUT}
    ...                           throughput_dl=${DL_THROUGHPUT}
    Capture L2L1 BIP log and download for 12269
    UE1 Check tuput and Stop traffic    target_throughput_ul=${UL_EXPECT}
    ...                           target_throughput_dl=${DL_EXPECT}
    UE5 Check tuput and Stop traffic    target_throughput_ul=${UL_EXPECT}
    ...                           target_throughput_dl=${DL_EXPECT}

Three UE Attach and collect biplog
    UE1 Attach and start traffic     throughput_ul=${UL_THROUGHPUT}
    ...                           throughput_dl=${DL_THROUGHPUT}
    UE5 Attach and start traffic     throughput_ul=${UL_THROUGHPUT}
    ...                           throughput_dl=${DL_THROUGHPUT}
    UE8 Attach and start traffic     throughput_ul=${UL_THROUGHPUT}
    ...                           throughput_dl=${DL_THROUGHPUT}
    Capture L2L1 BIP log and download for 12269
    UE1 Check tuput and Stop traffic    target_throughput_ul=${UL_EXPECT}
    ...                           target_throughput_dl=${DL_EXPECT}
    UE5 Check tuput and Stop traffic    target_throughput_ul=${UL_EXPECT}
    ...                           target_throughput_dl=${DL_EXPECT}
    UE8 Check tuput and Stop traffic    target_throughput_ul=${UL_EXPECT}
    ...                           target_throughput_dl=${DL_EXPECT}

UE1 Attach and start traffic
    [Arguments]  ${throughput_ul}    ${throughput_dl}
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[3]
    Set Test Variable      ${cell1_1}      ${cell1}
    log to console    \n***Prepare UE_1***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Set Test Variable      ${ue_type_1}      ${ue_type}
#    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type_1}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type_1}
    power_ue.Start traffic     ue_type=${ue_type_1}     direction=ul     throughput=${throughput_ul}     duration=2000    process_num=5
    power_ue.Start traffic     ue_type=${ue_type_1}     direction=dl     throughput=${throughput_dl}     duration=2000

UE5 Attach and start traffic
    [Arguments]  ${throughput_ul}    ${throughput_dl}
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[2]
    Set Test Variable      ${cell1_5}      ${cell1}
    log to console    \n***Prepare UE_5***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${4}
    Set Test Variable      ${ue_type_5}      ${ue_type}
#    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type_5}    ue_index=${4}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type_5}    ue_index=${4}
    power_ue.Start traffic     ue_type=${ue_type_5}     direction=ul     throughput=${throughput_ul}     duration=2000    process_num=5
    ...     ue_index=${4}
    power_ue.Start traffic     ue_type=${ue_type_5}     direction=dl     throughput=${throughput_dl}     duration=2000
    ...     ue_index=${4}

UE8 Attach and start traffic
    [Arguments]  ${throughput_ul}    ${throughput_dl}
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[0]
    Set Test Variable      ${cell1_8}      ${cell1}
    log to console    \n***Prepare UE_8***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${9}
    Set Test Variable      ${ue_type_8}      ${ue_type}
#    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type_8}    ue_index=${9}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type_8}    ue_index=${9}
    power_ue.Start traffic     ue_type=${ue_type_8}     direction=ul     throughput=${throughput_ul}     duration=2000    process_num=5
    ...    ue_index=${9}
    power_ue.Start traffic     ue_type=${ue_type_8}     direction=dl     throughput=${throughput_dl}     duration=2000
    ...    ue_index=${9}

UE1 Check tuput and Stop traffic
    [Arguments]  ${target_throughput_ul}    ${target_throughput_dl}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type_1}    duration=5m    check_source=Aasyslog
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type_1}
    ...                     direction=ul     cells=${cell1_1}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}    check_source=Aasyslog
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type_1}
    ...                     direction=dl     cells=${cell1_1}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}    check_source=Aasyslog
    power_ue.Stop traffic     ue_type=${ue_type_1}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type_1}     direction=ul

UE5 Check tuput and Stop traffic
    [Arguments]  ${target_throughput_ul}    ${target_throughput_dl}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type_5}    duration=5m    check_source=Aasyslog    ue_index=${4}
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type_5}
    ...                     direction=ul     cells=${cell1_5}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}    check_source=Aasyslog
    ...                     ue_index=${4}
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type_5}
    ...                     direction=dl     cells=${cell1_5}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}    check_source=Aasyslog
    ...                     ue_index=${4}
    power_ue.Stop traffic     ue_type=${ue_type_5}     direction=dl    ue_index=${4}
    power_ue.Stop traffic     ue_type=${ue_type_5}     direction=ul    ue_index=${4}

UE8 Check tuput and Stop traffic
    [Arguments]  ${target_throughput_ul}    ${target_throughput_dl}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type_8}    duration=5m    check_source=Aasyslog    ue_index=${9}
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type_8}
    ...                     direction=ul     cells=${cell1_8}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}    check_source=Aasyslog
    ...                     ue_index=${9}
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type_8}
    ...                     direction=dl     cells=${cell1_8}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}    check_source=Aasyslog
    ...                     ue_index=${9}
    power_ue.Stop traffic     ue_type=${ue_type_8}     direction=dl    ue_index=${9}
    power_ue.Stop traffic     ue_type=${ue_type_8}     direction=ul    ue_index=${9}

Capture L2L1 BIP log and download for 12269
    [Arguments]     ${duration}=3s
    Start Bip Logs Capture for 12269
    Sleep    ${duration}
    ${log_path_local}    Stop Bip Logs Capture and Download Logs for 12269
    set test variable    ${bip_log_path}    ${log_path_local}

Start Bip Logs Capture for 12269
    ${12269_timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Test Variable    ${12269_timestamp}
    Start Bip Log with Suitable Means    target_file_name=l1l2bip_log_${12269_timestamp}

Stop Bip Logs Capture and Download Logs for 12269
    ${bip_log_local}    Stop Bip Log with Suitable Means    target_file_name=l1l2bip_log_${12269_timestamp}
    set test variable    ${bip_log}    ${bip_log_local}[0]
    [Return]    ${bip_log}

Check bip log for 12269
    Check L2L1 BIp Log by Luashark for 12269     bip_log=${bip_log_path}

Check bip log for 12269_B
    [Arguments]  ${gap_slot_index}    ${gap_slot}
    Check L2L1 BIp Log by Luashark for 12269_B     bip_log=${bip_log_path}    check_slot=${gap_slot}    check_index=${gap_slot_index}

Check bip log for 12269_C
    Check L2L1 BIp Log by Luashark for 12269_C     bip_log=${bip_log_path}

Check L2L1 BIp Log by Luashark for 12269_C
    [Arguments]     ${bip_log}
    Get need pdml from bip    pcap_file=${bip_log}    search_msg=${csirssendreq_msg}    output=${OUTPUT DIR}/12269_C.pdml
    Check pdml for startSymbol and startPRB and numofPRB for 12269_C
    Get need pdml from bip    pcap_file=${bip_log}    search_msg=${csirssendreq_msg_2}    output=${OUTPUT DIR}/12269_2.pdml
    Check bip log for pwrReductionPerCsiRsResource_dB for slot 2
    Get need pdml from bip    pcap_file=${bip_log}    search_msg=${csirssendreq_msg_3}    output=${OUTPUT DIR}/12269_3.pdml
    Check bip log for pwrReductionPerCsiRsResource_dB
    Get need pdml from bip    pcap_file=${bip_log}    search_msg=${pdschsendreq_msg}     output=${OUTPUT DIR}/12269_4.pdml
    check bip log for Symbols
    Check SFN and Slot for 12269_C    bip_log=${bip_log}

check bip log for Symbols
    ${sfn}  ${slot}  ${numOfPdschSymbols}  ${startSymbol}  ${subcellId}    get_need_info_from_pdml_for_check_3  file_path=${OUTPUT DIR}/12269_4.pdml
    ${sfn_index}    get_sfn_index_list_by_mod    sfn_list=${sfn}    mod_num=${16}    remainder=${1}
    ${lenth}    get length    ${sfn_index}
    FOR  ${index}   IN RANGE   ${lenth}
        ${slot_num}    Set variable     ${sfn_index}[${index}]
        Run Keyword If    ${slot}[${slot_num}]==${5}    Should Be Equal    ${numOfPdschSymbols}[${slot_num}]    ${9}
    END
    Get need pdml from bip    pcap_file=${bip_log_path}    search_msg=${csirssendreq_msg_C}     output=${OUTPUT DIR}/12269_5.pdml
    ${sfn_c}  ${slot_c}  ${subcellId_c}    get_need_info_from_pdml_for_check_4  file_path=${OUTPUT DIR}/12269_5.pdml
    ${sfn_index_c}    get_sfn_index_list_by_mod    sfn_list=${sfn_c}    mod_num=${16}    remainder=${1}
    ${gap_subcellid}   get_target_list_value    target_list=${subcellId_c}  target_index=${sfn_index_c}
    ${gap_id}      list_to_repeat    old_list=${gap_subcellid}
    ${lenth_c}   get length    ${gap_id}
    Should Be Equal    ${lenth_c}    ${1}
    FOR  ${index}   IN RANGE   ${lenth}
        ${slot_num}    Set variable     ${sfn_index}[${index}]
        Run Keyword If    ${slot}[${slot_num}]==${6} and ${subcellId}[${slot_num}]!=${gap_id}[0]
        ...     Should Be Equal    ${startSymbol}[${slot_num}]    ${1}
    END

Check pdml for startSymbol and startPRB and numofPRB for 12269_C
    ${sfn}  ${slot}  ${startSymbol}  ${startPrb}  ${numOfPrb}  get_need_info_from_pdml_for_check_1  file_path=${OUTPUT DIR}/12269_C.pdml
    ${sfn_index}    get_sfn_index_list_by_mod    sfn_list=${sfn}    mod_num=${8}    remainder=${1}
    ${lenth}    get length    ${sfn_index}
    FOR  ${index}   IN RANGE   ${lenth}
        ${slot_status}    judge_num   gap=${slot}[${index}]    num1=${0}   num2=${1}
        ${slot_status}    Convert To String    ${slot_status}
        Should Be Equal    ${slot_status}    True
        ${startSymbol_status}    judge_num   gap=${startSymbol}[${index}]   num1=${4}   num2=${8}
        ${startSymbol_status}   Convert To String    ${startSymbol_status}
        Should Be Equal    ${startSymbol_status}    True
        ${startPrb_status}    judge_num_three   gap=${startPrb}[${index}]    num1=${6}   num2=${7}    num3=${56}
        ${startPrb_status}    Convert To String    ${startPrb_status}
        Should Be Equal    ${startPrb_status}    True
        Should Be Equal    ${numOfPrb}[${index}]    ${52}
    END

Check SFN and Slot for 12269_C
    [Arguments]  ${bip_log}
    Get need pdml from bip    pcap_file=${bip_log}    search_msg=${csirssendreq_msg_C_4_1}    output=${OUTPUT DIR}/12269_C_4_1.pdml
    ${sfn_list}    ${slot_list}    get_sfn_slo_from_pdml    file_path=${OUTPUT DIR}/12269_C_4_1.pdml
    ${sfn_index}    get_sfn_index_list_by_mod    sfn_list=${sfn_list}    mod_num=${8}    remainder=${1}
    Should Not Be Empty     ${sfn_index}
    ${slot_list}      list_to_repeat    old_list=${slot_list}
    Should Contain Any    ${slot_list}    ${0}    ${1}
    Should Not Be Empty    ${slot_list}
    ${lenth}    get length    ${slot_list}
    FOR  ${index}   IN RANGE   ${lenth}
        ${slot_status}    judge_num   gap=${slot_list}[${index}]   num1=${0}   num2=${1}
        ${slot_status}   Convert To String    ${slot_status}
        Should Be Equal    ${slot_status}    True
    END
    Get need pdml from bip    pcap_file=${bip_log}    search_msg=${csirssendreq_msg_C_4_2}    output=${OUTPUT DIR}/12269_C_4_2.pdml
    ${sfn_list_2}    ${slot_list_2}    get_sfn_slo_from_pdml    file_path=${OUTPUT DIR}/12269_C_4_2.pdml
    ${sfn_index_2}    get_sfn_index_list_by_mod    sfn_list=${sfn_list_2}    mod_num=${8}    remainder=${0}
    Should Not Be Empty     ${sfn_index_2}
    ${slot_list_2}      list_to_repeat    old_list=${slot_list_2}
    Should Contain Any    ${slot_list_2}    ${16}    ${17}
    Should Not Be Empty    ${slot_list_2}
    ${lenth_2}    get length    ${slot_list_2}
    FOR  ${index}   IN RANGE   ${lenth_2}
        ${slot_status}    judge_num   gap=${slot_list_2}[${index}]   num1=${16}   num2=${17}
        ${slot_status}   Convert To String    ${slot_status}
        Should Be Equal    ${slot_status}    True
    END
    Get need pdml from bip    pcap_file=${bip_log}    search_msg=${csirssendreq_msg_C_4_3}    output=${OUTPUT DIR}/12269_C_4_3.pdml
    ${sfn_list_3}    ${slot_list_3}    get_sfn_slo_from_pdml    file_path=${OUTPUT DIR}/12269_C_4_3.pdml
    Should Not Be Empty     ${sfn_list_3}
    Should Not Be Empty     ${slot_list_3}

Check L2L1 BIp Log by Luashark for 12269_B
    [Arguments]  ${bip_log}    ${check_slot}    ${check_index}
    ${packets_Csirs}    Load BIP with Luashark for 12269    bip_file=${bip_log}
        ...    command_template=${command_template_pdschsendreq_msg}
        ...    alias=Csir_12269_B
    ${lenth}    get length    ${check_index}
    FOR  ${index}  IN RANGE   ${lenth}
        ${slot_index}    Set variable     ${check_index}[${index}]
        ${expression}    Catenate    SEPARATOR=${SPACE}and${SPACE}
        ...                      dldata_pdschsendreql1sw
        ...                      3gpp.slot==${check_slot}[${slot_index}]
        Filter Packets By Expression    filter_expression=${expression}    pcap_parser=Csir_12269_B
        ${numOfPdschSymbols_value_list}    pcap.get_field_value_by_name    pdml_list=${packets_Csirs}
        ...      field_name=${numOfPdschSymbols_filed_name}
        ...      pcap_parser=Csir_12269_B
        ${startSymbol_value_list}    pcap.get_field_value_by_name    pdml_list=${packets_Csirs}
        ...      field_name=${startSymbol_filed_name}
        ...      pcap_parser=Csir_12269_B
        ${result}    check_list_by_gap_value    list1=${numOfPdschSymbols_value_list}    list2=${startSymbol_value_list}
        ...                               gap_value=${13}
        ${result}    Convert To String    ${result}
        Should Be Equal    ${result}    True
    END

Check L2L1 BIp Log by Luashark for 12269
    [Arguments]     ${bip_log}
    Get need pdml from bip    pcap_file=${bip_log}    search_msg=${csirssendreq_msg}    output=${OUTPUT DIR}/12269.pdml
    Check pdml for startSymbol and startPRB and numofPRB
    Get need pdml from bip    pcap_file=${bip_log}    search_msg=${csirssendreq_msg_2}    output=${OUTPUT DIR}/12269_2.pdml
    Check bip log for pwrReductionPerCsiRsResource_dB for slot 2
    Get need pdml from bip    pcap_file=${bip_log}    search_msg=${csirssendreq_msg_3}    output=${OUTPUT DIR}/12269_3.pdml
    Check bip log for pwrReductionPerCsiRsResource_dB
    Check SFN and Slot     bip_log=${bip_log}

Load BIP with Luashark for 12269
    [Arguments]     ${bip_file}      ${command_template}     ${alias}
    ${packets}    pcap.load_pcap_file   pcap_file=${bip_file}
	...                                 tshark_path=${tshark_path}
    ...                                 command_template=${command_template}
    ...                                 alias=${alias}
    [Return]   ${packets}

Get need pdml from bip
    [Arguments]    ${pcap_file}   ${search_msg}    ${output}
    Set Test Variable    ${outpdml_command}    ${tshark_path} -r ${pcap_file} -Y ${search_msg} -T pdml > ${output}
    Run    ${outpdml_command}

Check pdml for startSymbol and startPRB and numofPRB
    ${sfn}  ${slot}  ${startSymbol}  ${startPrb}  ${numOfPrb}  get_need_info_from_pdml_for_check_1  file_path=${OUTPUT DIR}/12269.pdml
    ${sfn_index}    get_sfn_index_list_by_mod    sfn_list=${sfn}    mod_num=${8}    remainder=${1}
    ${lenth}    get length    ${sfn_index}
    FOR  ${index}   IN RANGE   ${lenth}
        ${slot_status}    judge_num   gap=${slot}[${index}]    num1=${0}   num2=${1}
        ${slot_status}    Convert To String    ${slot_status}
        Should Be Equal    ${slot_status}    True
        ${startSymbol_status}    judge_num   gap=${startSymbol}[${index}]   num1=${4}   num2=${8}
        ${startSymbol_status}   Convert To String    ${startSymbol_status}
        Should Be Equal    ${startSymbol_status}    True
        Should Be Equal    ${startPrb}[${index}]    ${0}
        Should Be Equal    ${numOfPrb}[${index}]    ${52}
    END

Check bip log for pwrReductionPerCsiRsResource_dB for slot 2
    ${sfn_list_2}    ${slot_list_2}    ${pwrReduction}    get_need_info_from_pdml_for_check_2    file_path=${OUTPUT DIR}/12269_2.pdml
    ${sfn_index}    get_sfn_index_list_by_mod    sfn_list=${sfn_list_2}    mod_num=${16}    remainder=${1}
    ${lenth}    get length    ${sfn_index}
    ${sfn_index_3}    get_sfn_index_list_by_mod    sfn_list=${sfn_list_2}    mod_num=${16}    remainder=${3}
    ${lenth_3}    get length    ${sfn_index_3}
    ${sfn_index_5}    get_sfn_index_list_by_mod    sfn_list=${sfn_list_2}    mod_num=${16}    remainder=${5}
    ${lenth_5}    get length    ${sfn_index_5}
    FOR  ${index}   IN RANGE   ${lenth}
        ${slot_num}    Set variable     ${sfn_index}[${index}]
        Should Be Equal    ${slot_list_2}[${slot_num}]    ${2}
        Should Be Equal    ${pwrReduction}[${slot_num}]    ${255}
    END
    FOR  ${index}   IN RANGE   ${lenth_3}
        ${slot_num_3}    Set variable     ${sfn_index_3}[${index}]
        Should Be Equal    ${slot_list_2}[${slot_num_3}]    ${2}
        Should Be Equal    ${pwrReduction}[${slot_num_3}]    ${255}
    END
    FOR  ${index}   IN RANGE   ${lenth_5}
        ${slot_num_5}    Set variable     ${sfn_index_5}[${index}]
        Should Be Equal    ${slot_list_2}[${slot_num_5}]    ${2}
        Should Be Equal    ${pwrReduction}[${slot_num_5}]    ${255}
    END

Check bip log for pwrReductionPerCsiRsResource_dB
    ${sfn_list_3}    ${slot_list_3}    ${pwrReduction_3}    get_need_info_from_pdml_for_check_2    file_path=${OUTPUT DIR}/12269_3.pdml
    ${sfn_index}    get_sfn_index_list_by_mod    sfn_list=${sfn_list_3}    mod_num=${16}    remainder=${1}
    ${lenth}    get length    ${sfn_index}
    ${sfn_index_3}    get_sfn_index_list_by_mod    sfn_list=${sfn_list_3}    mod_num=${16}    remainder=${3}
    ${lenth_3}    get length    ${sfn_index_3}
    ${sfn_index_5}    get_sfn_index_list_by_mod    sfn_list=${sfn_list_3}    mod_num=${16}    remainder=${5}
    ${lenth_5}    get length    ${sfn_index_5}
    FOR  ${index}   IN RANGE   ${lenth}
        ${slot_num}    Set variable     ${sfn_index}[${index}]
        ${slot_status}    judge_num   gap=${slot_list_3}[${slot_num}]    num1=${6}   num2=${7}
        ${slot_status}    Convert To String    ${slot_status}
        Should Be Equal    ${slot_status}    True
        Should Be Equal    ${pwrReduction_3}[${slot_num}]    ${255}
    END
    FOR  ${index}   IN RANGE   ${lenth_3}
        ${slot_num_3}    Set variable     ${sfn_index_3}[${index}]
        ${slot_status_3}    judge_num   gap=${slot_list_3}[${slot_num_3}]    num1=${5}   num2=${7}
        ${slot_status_3}    Convert To String    ${slot_status_3}
        Should Be Equal    ${slot_status_3}    True
        Should Be Equal    ${pwrReduction_3}[${slot_num_3}]    ${255}
    END
    FOR  ${index}   IN RANGE   ${lenth_5}
        ${slot_num_5}    Set variable     ${sfn_index_5}[${index}]
        ${slot_status_5}    judge_num   gap=${slot_list_3}[${slot_num_5}]    num1=${5}   num2=${6}
        ${slot_status_5}    Convert To String    ${slot_status_5}
        Should Be Equal    ${slot_status_3}    True
        Should Be Equal    ${pwrReduction_3}[${slot_num_5}]    ${255}
    END

Check SFN and Slot
    [Arguments]  ${bip_log}
    Get need pdml from bip    pcap_file=${bip_log}    search_msg=${csirssendreq_msg_4_1}    output=${OUTPUT DIR}/12269_4_1.pdml
    ${sfn_list}    ${slot_list}    get_sfn_slo_from_pdml    file_path=${OUTPUT DIR}/12269_4_1.pdml
    ${sfn_index}    get_sfn_index_list_by_mod    sfn_list=${sfn_list}    mod_num=${8}    remainder=${1}
    Should Not Be Empty     ${sfn_index}
    ${slot_list}      list_to_repeat    old_list=${slot_list}
    Should Contain Any    ${slot_list}    ${0}    ${1}
    ${slot_length}    get length    ${slot_list}
    Should Be Equal    ${slot_length}    ${2}
    Get need pdml from bip    pcap_file=${bip_log}    search_msg=${csirssendreq_msg_4_2}    output=${OUTPUT DIR}/12269_4_2.pdml
    ${sfn_list_2}    ${slot_list_2}    get_sfn_slo_from_pdml    file_path=${OUTPUT DIR}/12269_4_2.pdml
    ${sfn_index_2}    get_sfn_index_list_by_mod    sfn_list=${sfn_list_2}    mod_num=${8}    remainder=${0}
    Should Not Be Empty     ${sfn_index_2}
    ${slot_list_2}      list_to_repeat    old_list=${slot_list_2}
    Should Contain Any    ${slot_list_2}    ${16}    ${17}
    ${slot_length_2}    get length    ${slot_list_2}
    Should Be Equal    ${slot_length_2}    ${2}
    Get need pdml from bip    pcap_file=${bip_log}    search_msg=${csirssendreq_msg_4_3}    output=${OUTPUT DIR}/12269_4_3.pdml
    ${sfn_list_3}    ${slot_list_3}    get_sfn_slo_from_pdml    file_path=${OUTPUT DIR}/12269_4_3.pdml
    Should Not Be Empty     ${sfn_list_3}
    Should Not Be Empty     ${slot_list_3}

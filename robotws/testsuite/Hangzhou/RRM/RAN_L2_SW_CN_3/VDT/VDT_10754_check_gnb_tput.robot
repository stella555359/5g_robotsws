*** Settings ***
Documentation    Author: shatang
...              \n used for quick download gNB package and auto upgrade gNb,now only support tl00

Resource    ../resources/KISS/robot/internal_upgrade.robot
Resource    ../resources/KISS/robot/common_gnb.robot
Resource    ../resources/KISS/robot/common_logs_operate.robot
Resource    ../resources/KISS/robot/common_resource.robot
Resource    ../resources/sg10/internal_resource/internal_resource.robot
#Library    ${CURDIR}/../resources/VRF3_T05/internal_resource/python/get_gnb_package.py
Library           String

*** Variables ***
${TARGET_FILE_NAME}         /tmp
${COVERAGE}                 Full
${FORCE}                    ${True}
${TIMEOUT}                  300
${REGEXP_FILTER}            None
${REASON}                   None
${CELLS}                    None
${DETAILED_OUTPUT}          ${False}

*** Test Cases ***
check tput and get snapshot
    run keyword and continue on failure    Step1:Check Cell Tput
    run keyword and continue on failure    Step2:Get gNB Snapshot

*** Keywords ***
Wait '${time}' for stabible
    sleep    ${time}

Step2:Get gNB Snapshot
    Get GNB Software Version
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    Log To Console    \r\n start get snapshot
    Collect GNB SnapShot    target_file_name=${CURDIR}${/}${/}Snapshot_${SW_VERSION_TOTAL}_${timestamp}.zip
    Log To Console    \r\n get snapshot done

Step1:Check Cell Tput
    #Start capture GNB and AP Syslog in 'Step3_100UE' File
    #Wait '600s' for stable running2
    Build excel table for 10754 KPI vs
    ${DL_tput_cell1}    ${non_CA_num_1}    ${CA_num_1}    ${Max_non_CA_num_1}    ${Max_CA_num_1}    ${SCell_act_1}
    ...    ${DL_tput_cell2}    ${non_CA_num_2}    ${CA_num_2}    ${Max_non_CA_num_2}    ${Max_CA_num_2}    ${SCell_act_2}
    ...    ${UL_tput_cell1}
    ...    get CA UE numbers from PM counter
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    1    1    ${DL_tput_cell1}
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    1    2    ${non_CA_num_1}
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    1    3    ${CA_num_1}
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    1    4    ${Max_non_CA_num_1}
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    1    5    ${Max_CA_num_1}
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    1    6    ${SCell_act_1}
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    1    7    ${DL_tput_cell2}
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    1    8    ${non_CA_num_2}
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    1    9    ${CA_num_2}
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    1    10    ${Max_non_CA_num_2}
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    1    11    ${Max_CA_num_2}
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    1    12    ${SCell_act_2}
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    1    13    ${UL_tput_cell1}
    run keyword and continue on failure    should be true    ${DL_tput_cell1}>1800
    run keyword and continue on failure    should be true    ${DL_tput_cell2}>1500
    run keyword and continue on failure    should be true    ${CA_num_1}>=0
    run keyword and continue on failure    should be true    ${CA_num_2}>=0
    run keyword and continue on failure    should be true    ${UL_tput_cell1}>10
    #[Teardown]    Stop capture GNB and AP Syslog in 'Step3_100UE' File


get CA UE numbers from PM counter
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
    ${DL_tput_1}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=1
    ${DL_tput_cell1}    evaluate    ${DL_tput_1}*8/1024/1024
    ${non_CA_num_1}=        get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C03000    cell_id=1
    ${CA_num_1}=            get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C03001    cell_id=1
    ${Max_non_CA_num_1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C05000    cell_id=1
    ${Max_CA_num_1}=        get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C05001    cell_id=1
    ${SCell_act_1}=         get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C09000    cell_id=1
    ${DL_tput_2}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=2
    ${DL_tput_cell2}    evaluate    ${DL_tput_2}*8/1024/1024
    ${non_CA_num_2}=        get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C03000    cell_id=2
    ${CA_num_2}=            get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C03001    cell_id=2
    ${Max_non_CA_num_2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C05000    cell_id=2
    ${Max_CA_num_2}=        get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C05001    cell_id=2
    ${SCell_act_2}=         get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55316C09000    cell_id=2
    ${UL_tput_1}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12002    cell_id=1
    ${UL_tput_cell1}    evaluate    ${UL_tput_1}*8/1024/1024
    [Return]    ${DL_tput_cell1}    ${non_CA_num_1}    ${CA_num_1}    ${Max_non_CA_num_1}    ${Max_CA_num_1}    ${SCell_act_1}
    ...         ${DL_tput_cell2}    ${non_CA_num_2}    ${CA_num_2}    ${Max_non_CA_num_2}    ${Max_CA_num_2}    ${SCell_act_2}
    ...         ${UL_tput_cell1}

Build excel table for 10754 KPI vs
    Get GNB Software Version
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    1    0    ${SW_VERSION_TOTAL}
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    0    1    tput_M55309C12001_cell1
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    0    2    PSCell_UEs_0_activated_SCells_cell1
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    0    3    PSCell_UEs_1_activated_SCells_cell1
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    0    4    Max_PSCell_UEs_0_activated_SCells_cell1
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    0    5    Max_PSCell_UEs_0_activated_SCells_cell1
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    0    6    SCell_activations_cell1
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    0    7    tput_M55309C12001_cell2
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    0    8    PSCell_UEs_0_activated_SCells_cell2
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    0    9    PSCell_UEs_1_activated_SCells_cell2
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    0    10    Max_PSCell_UEs_0_activated_SCells_cell2
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    0    11    Max_PSCell_UEs_0_activated_SCells_cell2
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    0    12    SCell_activations_cell2
    modify_excel_cell    ${CURDIR}/10754_kpi.xls    Sheet1    0    13    UL_tput_cell1

Start capture gnb and ap syslog in '${file_name}' file2
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/${file_name}/syslog_${file_name}
    ...    log_name=${file_name}_gnb    ip=${GNB_SYSLOG.ip}    alias=collect_gnb
    ute_syslog.Start Syslog    file_limit=${AP_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/${file_name}/syslog_${file_name}
    ...    log_name=${file_name}_ap    ip=${AP_SYSLOG.ip}    alias=collect_ap

Stop capture gnb and ap syslog in '${file_name}' file2
    #check_err_wrn_in_btslog    ${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}    syslog_${file_name}
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}${file_name}   unzip=TRUE
    ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}${file_name}_gnb.tar.gz
    ute_syslog.Collect Syslog Results    alias=collect_ap    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}syslog_${file_name}${/}${file_name}_ap.tar.gz
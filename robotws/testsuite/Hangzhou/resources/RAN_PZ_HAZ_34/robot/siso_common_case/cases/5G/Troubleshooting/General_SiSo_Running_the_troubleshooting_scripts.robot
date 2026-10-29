*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot

*** Variables ***
@{CELLS_VIA_WEBEM}            NRCELL-1
@{RMODS_VIA_WEBEM}            RMOD-1/RMOD_R-1 (AEQY)
@{CELLS_VIA_ADMIN_CLI}        MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
@{RMODS_VIA_ADMIN_CLI}        MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
@{RMODS_SCRIPTS_LIST}         RU_Common_capture_IQ_data    RU_Common_capture_L1low_data    RU_Common_capture_register_dump

*** Keywords ***
General_SiSo_Running_the_troubleshooting_scripts
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of the case is to check trouble shooting scripts
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 13.07.2019 - - Created
    ...    - 07.08.2023 - - Modify https://jiradc.ext.net.nokia.com/browse/LEOPARD-1374
    ...    - 25.09.2023 - - Modify https://jiradc.ext.net.nokia.com/browse/LEOPARD-1440
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]    ${iq_data_file_num}=${4}
    ${all_scripts}    coam.get_all_troubleshooting_scripts    script_owner_module=RMOD    connection=GNB_OAM
    FOR    ${script}    IN    @{all_scripts}
        Builtin.Log    ${script}
        run keyword and continue on failure    Launch and Check Troubleshooting Script    script=${script}
        ...    iq_data_file_num=${iq_data_file_num}    iq_data_file_num=${iq_data_file_num}
    END

Launch and Check Troubleshooting Script
    [Arguments]  ${script}    ${iq_data_file_num}=${4}
    ${ret}    coam.launch_troubleshooting_script    script_name=${script['scriptName']}
    ...    output_file_name=${TS_CASE_LOG_PATH}/script_result_011_${script['scriptName']}.zip
    ...    cell_list=${CELLS_VIA_ADMIN_CLI}    rmod_list=${RMODS_VIA_ADMIN_CLI}
    ...    free_parameters=${EMPTY}    timeout=900    connection=GNB_OAM
    Should Be Equal    ${ret}    Launching succeeded. Snapshot has been successfully created.
    File Should Exist    ${TS_CASE_LOG_PATH}/script_result_011_${script['scriptName']}.zip
    check troubleshooting scripts log    script_name=${script['scriptName']}    BASE_PATH=${TS_CASE_LOG_PATH}
    ...    iq_data_file_num=${iq_data_file_num}

check troubleshooting scripts log
    [Arguments]  ${script_name}    ${BASE_PATH}=${TS_CASE_LOG_PATH}    ${iq_data_file_num}=${4}
    ${BASE_PATH}    Get Substring    ${BASE_PATH}    0    -1
    run keyword if    '${script_name}'=='RU_Common_capture_IQ_data'    check RU Common capture IQ data log
    ...    BASE_PATH=${BASE_PATH}    iq_data_file_num=${iq_data_file_num}
    ...    ELSE IF    '${script_name}'=='RU_Common_capture_register_dump'    check RU Common capture register dump log
    ...    BASE_PATH=${BASE_PATH}
    ...    ELSE IF    '${script_name}'=='RU_Common_capture_L1low_data'    check RU Common capture L1low data log
    ...    BASE_PATH=${BASE_PATH}

check RU Common capture IQ data log
    [Arguments]  ${BASE_PATH}=${TS_CASE_LOG_PATH}    ${file_num}=${4}    ${iq_data_file_num}=${4}
    log to console    \n check RU Common capture IQ data log
    ${check_file}    set variable     script_result_011_RU_Common_capture_IQ_data
    Extract Zip File    ${BASE_PATH}/${check_file}.zip
    ...                 ${BASE_PATH}/${check_file}
    ${trblshoot_flag_1}    Check Trblshoot in IQ Data    path=${BASE_PATH}/${check_file}
    ${BTS_part1_Exist}    run keyword and return status    File Should Exist     ${BASE_PATH}/${check_file}/BTS_part1.zip
    run keyword if  ${BTS_part1_Exist}   Extract Zip File    ${BASE_PATH}/${check_file}/BTS_part1.zip
    ...    ${BASE_PATH}/${check_file}/BTS_part1
    ${trblshoot_flag_2}    run keyword if    ${BTS_part1_Exist}    Check Trblshoot in IQ Data    path=${BASE_PATH}/${check_file}/BTS_part1
    ...    ELSE    set variable    ${False}
    should be true    ${trblshoot_flag_1} or ${trblshoot_flag_2}    msg=sm0 is not exsit!
    ${all_file_dict}    create dictionary
    Check Cap File in IQ Data    path=${BASE_PATH}/${check_file}    all_file_dict=${all_file_dict}
    Check Cap File in BTS part    path=${BASE_PATH}/${check_file}    all_file_dict=${all_file_dict}
    Check All Files Cap Num Dict    all_file_dict=${all_file_dict}    num=4
    ${keys}    get dictionary keys    ${all_file_dict}
    ${num}    get length    ${keys}
    should be equal as numbers    ${num}    ${iq_data_file_num}

Check Trblshoot in IQ Data
    [Arguments]  ${path}
    ${trblshoot_flag}    set variable    ${False}
    @{files}    List Files In Directory    path=${path}    pattern=*l1low_i1*.tar.gz    absolute=${True}
    FOR    ${file}    IN    @{files}
        ${path}    ${get_file}    Split Path    path=${file}
        ${out_info}    Run    command=tar -zxvf ${file} -C ${path}
        Should Contain    ${out_info}    trblshoot/DL/sm0
        Should Contain    ${out_info}    trblshoot/UL/sm0
        ${trblshoot_flag}    set variable    ${True}
    END
    [Return]  ${trblshoot_flag}

Check Cap File in BTS part
    [Arguments]  ${path}    ${all_file_dict}    ${pattern}=*L_*_1*.zip
    @{files}    List Files In Directory    path=${path}    pattern=BTS_part*.zip    absolute=${True}
    FOR    ${file}    IN    @{files}
        ${basepath}    ${extension}    Split Extension    path=${file}
        Extract Zip File    ${file}
        ...                 ${basepath}
        Check Cap File in IQ Data    path=${basepath}    all_file_dict=${all_file_dict}    pattern=${pattern}
    END

Check Cap File in IQ Data
    [Arguments]  ${path}    ${all_file_dict}    ${pattern}=*L_*_1*.zip
    @{files}    List Files In Directory    path=${path}    pattern=${pattern}    absolute=${True}
    FOR    ${file}    IN    @{files}
        ${cap_dict}    create dictionary    cap_84=0    cap_85=0    cap_2=0    cap_4=0
        ${basepath}    ${extension}    Split Extension    path=${file}
        ${path}    ${get_file}    Split Path    path=${file}
        ${key}    Get Substring    ${get_file}    0    -5
        Extract Zip File    ${file}
        ...                 ${basepath}
        ${status}    run keyword and return status    dictionary should contain key    ${all_file_dict}    ${key}
        run keyword if    not ${status}    set to dictionary    ${all_file_dict}    ${key}=${cap_dict}
        Generate Cap Num Dict    cap_dict=${all_file_dict}[${key}]    path=${basepath}
    END

Generate Cap Num Dict
    [Arguments]  ${cap_dict}    ${path}
    FOR    ${cap_name}    IN    @{cap_dict.keys()}
        @{files}    List Files In Directory    path=${path}    pattern=*${cap_name}*
        ${file_len}    get length    ${files}
        ${cap_num}    evaluate    ${cap_dict}[${cap_name}]+${file_len}
        set to dictionary    ${cap_dict}    ${cap_name}=${cap_num}
    END

Check All Files Cap Num Dict
    [Arguments]  ${all_file_dict}    ${num}
    FOR    ${cap_dict}    IN    @{all_file_dict.values()}
        Check Cap Num Dict    cap_dict=${cap_dict}    num=${num}
    END

Check Cap Num Dict
    [Arguments]  ${cap_dict}    ${num}
    FOR    ${cap_name}    IN    @{cap_dict.keys()}
        should be equal as numbers    ${cap_dict}[${cap_name}]    ${num}
    END

check RU Common capture register dump log
    [Arguments]  ${BASE_PATH}=${TS_CASE_LOG_PATH}
    log to console    \n check RU Common capture register dump log
    ${check_file}    set variable     script_result_011_RU_Common_capture_register_dump
    Extract Zip File    ${BASE_PATH}/${check_file}.zip
    ...                 ${BASE_PATH}/${check_file}
    Extract Zip File    ${BASE_PATH}/${check_file}/BTS_part1.zip
    ...                 ${BASE_PATH}/${check_file}/BTS_part1
    ${file_info}    Run    command=ls ${BASE_PATH}/${check_file}/BTS_part1
    ${out_info}    Run    command=tar -zxvf ${BASE_PATH}/${check_file}/BTS_part1/${file_info}
    Should Contain    ${out_info}    ethss

check RU Common capture L1low data log
    [Arguments]  ${BASE_PATH}=${TS_CASE_LOG_PATH}
    log to console    \n check RU Common capture L1low data log
    ${check_file}    set variable     script_result_011_RU_Common_capture_L1low_data
    Extract Zip File    ${BASE_PATH}/${check_file}.zip
    ...                 ${BASE_PATH}/${check_file}
    ${BTS_part1_Exist}    run keyword and return status    File Should Exist     ${BASE_PATH}/${check_file}/BTS_part1.zip
    run keyword if  ${BTS_part1_Exist}   Extract Zip File    ${BASE_PATH}/${check_file}/BTS_part1.zip
    ...    ${BASE_PATH}/${check_file}/BTS_part1
    ${file_info_1}    Run    command=ls ${BASE_PATH}/${check_file}/BTS_part1 | grep "capture_L1low_data" | grep 1.tar.gz
    ${file_info_2}    Run    command=ls ${BASE_PATH}/${check_file} | grep "capture_L1low_data" | grep 1.tar.gz
    ${file_info_1_length}    get length    ${file_info_1}
    ${out_info_path}    set variable if    ${file_info_1_length}>0    BTS_part1/${file_info_1}
    ...    ${file_info_2}
    ${out_info}    Run    command=tar -zxvf ${BASE_PATH}/${check_file}/${out_info_path}
    Should Contain    ${out_info}    l1lowtrblshoot

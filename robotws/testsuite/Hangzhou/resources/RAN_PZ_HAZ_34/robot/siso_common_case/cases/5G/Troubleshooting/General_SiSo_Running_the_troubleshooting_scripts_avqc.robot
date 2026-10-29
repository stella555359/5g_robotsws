*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot

*** Variables ***
@{allowed_file_list}        thor_avql_ip_macsec_show.log
@{RMODS_SCRIPTS_LIST}         RU_Common_capture_IQ_data    RU_Common_capture_L1low_data    RU_Common_capture_register_dump

*** Keywords ***
General_SiSo_Running_the_troubleshooting_scripts_avqc
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of the case is to check trouble shooting scripts
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 11.03.2024 - - Created  https://jiradc.ext.net.nokia.com/browse/LEOPARD-1657
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM   ${script_owner_module}=RMOD    ${l1low_file_num}=${3}   ${IQ_file_num}=${NONE}
    ${all_scripts}    coam.get_all_troubleshooting_scripts    script_owner_module=${script_owner_module}    connection=${connection}
    FOR    ${script}    IN    @{all_scripts}
        Builtin.Log    ${script}
        run keyword and continue on failure    Launch and Check Troubleshooting Script    script=${script}
        ...   l1low_file_num=${l1low_file_num}   IQ_file_num=${IQ_file_num}   connection=${connection}
    END

Launch and Check Troubleshooting Script
    [Arguments]  ${script}   ${l1low_file_num}=${3}   ${IQ_file_num}=${NONE}  ${connection}=GNB_OAM
    log to console   \n collect troubleshooting script ${script['scriptName']}
    ${ru_index_list}  Get All RU Index   connection=${connection}
    ${cell_index_list}   Get All Cell Id   connection=${connection}
    # Calculate IQ_file_num if not provided: each MARS should have cell_count * 16 files
    ${cell_count}   Get Length   ${cell_index_list}
    ${IQ_file_num}=   Run Keyword If   '${IQ_file_num}' == '${NONE}'   Evaluate   ${cell_count} * 16
    ...   ELSE   Set Variable   ${IQ_file_num}
    log to console   \n Cell count: ${cell_count}, Expected IQ file number per MARS: ${IQ_file_num}
    ${RMODS_VIA_ADMIN_CLI}   Create List
    ${CELLS_VIA_ADMIN_CLI}   Create List
    ${ru_num}   Get Length   ${ru_index_list}
    FOR   ${ru_index}  IN  @{ru_index_list}
        ${RMOD_VIA_ADMIN_CLI}    Set Variable   MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}
        Append To List  ${RMODS_VIA_ADMIN_CLI}  ${RMOD_VIA_ADMIN_CLI}
    END
    FOR   ${cell_index}  IN  @{cell_index_list}
        ${CELL_VIA_ADMIN_CLI}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
        Append To List  ${CELLS_VIA_ADMIN_CLI}  ${CELL_VIA_ADMIN_CLI}
    END
    ${ret}    coam.launch_troubleshooting_script    script_name=${script['scriptName']}
    ...    output_file_name=${TS_CASE_LOG_PATH}/script_result_${script['scriptName']}.zip
    ...    cell_list=${CELLS_VIA_ADMIN_CLI}   rmod_list=${RMODS_VIA_ADMIN_CLI}
    ...    free_parameters=${EMPTY}    timeout=600    connection=${connection}
    Should Be Equal    ${ret}    Launching succeeded. Snapshot has been successfully created.
    File Should Exist    ${TS_CASE_LOG_PATH}/script_result_${script['scriptName']}.zip
    check troubleshooting scripts log AVQC    script_name=${script['scriptName']}    BASE_PATH=${TS_CASE_LOG_PATH}
    ...   l1low_file_num=${l1low_file_num}   IQ_file_num=${IQ_file_num}

check troubleshooting scripts log AVQC
    [Arguments]  ${script_name}    ${BASE_PATH}=${TS_CASE_LOG_PATH}   ${l1low_file_num}=${3}   ${IQ_file_num}=${NONE}
    run keyword if    '${script_name}'=='RU_Common_capture_IQ_data'    check RU Common capture IQ data log AVQC
    ...    BASE_PATH=${BASE_PATH}   IQ_file_num=${IQ_file_num}
    ...    ELSE IF    '${script_name}'=='RU_Common_capture_register_dump'    check RU Common capture register dump log AVQC
    ...    BASE_PATH=${BASE_PATH}
    ...    ELSE IF    '${script_name}'=='RU_Common_capture_L1low_data'    check RU Common capture L1low data log AVQC
    ...    BASE_PATH=${BASE_PATH}   l1low_file_num=${l1low_file_num}

check RU Common capture IQ data log AVQC
    [Arguments]  ${BASE_PATH}=${TS_CASE_LOG_PATH}   ${IQ_file_num}=${NONE}
    log to console    \n check RU Common capture IQ data log
    ${check_file}    set variable     script_result_RU_Common_capture_IQ_data
    Extract Zip File    ${BASE_PATH}/${check_file}.zip
    ...                 ${BASE_PATH}/${check_file}
    @{files}    List Files In Directory    path=${BASE_PATH}/${check_file}    pattern=BTS_part*.zip    absolute=${True}
	FOR  ${file}  IN   @{files}
        Extract Zip File    ${file}
        ...    ${BASE_PATH}/${check_file}
	END
    log to console   \n check cap file in mars0
    Check Cap File in IQ Data    path=${BASE_PATH}/${check_file}    pattern=*L_1_SCRIPT*.zip   IQ_file_num=${IQ_file_num}
    log to console   \n check cap file in mars1
    Check Cap File in IQ Data    path=${BASE_PATH}/${check_file}    pattern=*L_1_1111_SCRIPT*.zip  IQ_file_num=${IQ_file_num}
    log to console   \n check cap file in thor
    @{Thor_files_tar}    List Files In Directory    path=${BASE_PATH}/${check_file}    pattern=*L_1_2011*.tar.gz   absolute=${True}
    ${Thor_size}   Get Length   ${Thor_files_tar}
    Should Be True   ${Thor_size}>=0
    # sometimes the bin files in thor folder equal to zero not a issue.
    ${l1_low_file_num}   Set Variable  0
    FOR   ${file}  IN  @{Thor_files_tar}
        ${file_basepath}    ${extension}    Split Extension    path=${file}
        ${path}    ${get_file}    Split Path    path=${file}
        ${key}    Get Substring    ${get_file}    0    -14
        Run    command=mkdir ${path}/${key}
        ${out_info}    Run    command=tar -zxvf ${file} -C ${path}/${key}
        ${file_num}   Generate Cap Num And Check Cap Size   path=${path}/${key}  pattern=l1low_iq*
        ${l1_low_file_num}=   Evaluate    ${l1_low_file_num}+${file_num}
    END

Check Cap File in IQ Data
    [Arguments]  ${path}    ${pattern}=*L_1_1*.zip  ${file_pattern}=*cap*   ${IQ_file_num}=${NONE}
    @{files}    List Files In Directory    path=${path}    pattern=${pattern}    absolute=${True}
    ${mars_file_num}   Set Variable  0
    FOR    ${file}    IN    @{files}
        ${zip_basepath}    ${extension}    Split Extension    path=${file}
        ${path}    ${get_file}    Split Path    path=${file}
        ${key}    Get Substring    ${get_file}    0    -11
        Run    command=mkdir ${path}/${key}
        ${out_info_mars}    run keyword and continue on failure  Run   command=unzip ${file} -d ${path}/${key}
        ${file_num}   Generate Cap Num And Check Cap Size   path=${path}/${key}   pattern=${file_pattern}
        ${mars_file_num}=   Evaluate    ${mars_file_num}+${file_num}
    END
    Should Be Equal As Strings   ${IQ_file_num}   ${mars_file_num}

Generate Cap Num And Check Cap Size
    [Arguments]   ${path}  ${pattern}=cap*
    @{caps}    List Files In Directory    path=${path}    pattern=${pattern}
    FOR    ${cap}    IN    @{caps}
        ${actual_size}    OperatingSystem.Get File Size    ${path}/${cap}
        ${allowed_status}    Run Keyword And Return Status   Should Contain   ${allowed_file_list}   ${cap}
        run keyword if  not ${allowed_status}    Should Be True   ${actual_size}>0
    END
    ${file_len}    get length    ${caps}
    [Return]    ${file_len}

check RU Common capture register dump log AVQC
    [Arguments]  ${BASE_PATH}=${TS_CASE_LOG_PATH}   ${pattern}=*L_1_2011*.tar.gz
    log to console    \n check Thor File in RU Common capture register dump log
    ${check_file}    set variable     script_result_RU_Common_capture_register_dump
    Extract Zip File    ${BASE_PATH}/${check_file}.zip
    ...                 ${BASE_PATH}/${check_file}
    @{btspart_info}    List Files In Directory    path=${BASE_PATH}/${check_file}    pattern=*BTS_part*    absolute=${True}
    FOR   ${btspart}  IN  @{btspart_info}
        Extract Zip File    ${btspart}
        ...                 ${BASE_PATH}/${check_file}
    END
    @{files}    List Files In Directory    path=${BASE_PATH}/${check_file}    pattern=${pattern}    absolute=${True}
    ${register_dump_size}   Get Length   ${files}
    Should Be True   ${register_dump_size}>0
    FOR   ${file}  IN  @{files}
        ${tar_basepath}    ${extension}    Split Extension    path=${file}
        ${path}    ${get_file}    Split Path    path=${file}
        ${key}    Get Substring    ${get_file}    0    -14
        Run    command=mkdir ${path}/${key}
        ${out_info}    Run    command=tar -zxvf ${file} -C ${path}/${key}
        Generate Cap Num And Check Cap Size   path=${path}/${key}  pattern=thor*
    END

check RU Common capture L1low data log AVQC
    [Documentation]    This keyword fixes the issue where tar.gz files cannot be extracted in L1LOW data.
    ...    *Author* zhendong.chen@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    The thor files collected by the L1LOW script are split into multiple tar.gz files,
    ...    causing extraction issues.
    ...    For more information, please see ticket: https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10381
    [Arguments]  ${BASE_PATH}=${TS_CASE_LOG_PATH}    ${pattern_mars1}=*L_1_1111*.tar.gz  ${pattern_mars0}=*L_1_l1*.tar.gz
    ...   ${l1low_file_num}=${3}
    log to console    \n check RU Common capture L1low data log
    ${check_file}    set variable     script_result_RU_Common_capture_L1low_data
    Extract Zip File    ${BASE_PATH}/${check_file}.zip
    ...                 ${BASE_PATH}/${check_file}
    @{btspart_info}    List Files In Directory    path=${BASE_PATH}/${check_file}    pattern=*BTS_part*    absolute=${True}
    FOR   ${btspart}  IN  @{btspart_info}
        Extract Zip File    ${btspart}
        ...                 ${BASE_PATH}/${check_file}
    END
    log to console   \n  Generate Mars Path And Check L1low Size for mars1
    Generate Mars Path And Check L1low Size  path_l1low_log=${BASE_PATH}/${check_file}  pattern_mars=${pattern_mars1}
    ...   merged_name=merged_L_1_1111.tar.gz   l1low_file_num=${l1low_file_num}
    log to console   \n  Generate Mars Path And Check L1low Size for mars0
    Generate Mars Path And Check L1low Size  path_l1low_log=${BASE_PATH}/${check_file}  pattern_mars=${pattern_mars0}
    ...   merged_name=merged_L_1_l1.tar.gz   l1low_file_num=${l1low_file_num}

Generate Mars Path And Check L1low Size
    [Arguments]   ${path_l1low_log}   ${pattern_mars}=*L_1_1111*.tar.gz   ${merged_name}=merged_L_1_1111.tar.gz   ${l1low_file_num}=${3}
    @{files_mars}    List Files In Directory    path=${path_l1low_log}    pattern=${pattern_mars}    absolute=${True}
    Run Keyword If    len(${files_mars}) > 0    Builtin.Log    Files_mars is not empty
    FOR   ${file}  IN  @{files_mars}
        ${mars_basepath}    ${extension}    Split Extension    path=${file}
        Log To Console  mars_basepath:${mars_basepath}
        Log To Console    extension:${extension}
        ${path}    ${get_file}    Split Path    path=${file}
        Log To Console    path:${path}
        Log To Console    get_file:${get_file}
        ${key}    Get Substring    ${get_file}    0    -14
        Log To Console    key:${key}
    END
    ${merged_dir}    Set Variable    ${path}/${key}
    Log To Console    merged_dir:${merged_dir}
    Run    command=mkdir ${merged_dir}
    Run    command=cd ${path_l1low_log} && cat ${pattern_mars} >${key}/${merged_name}
    ${out_info_mars}    Run    command=tar -zxvf ${merged_dir}/${merged_name} -C ${merged_dir}
    @{l1low_file_list}    Create List    l1low_ulebdump.tar.gz    l1low_prachdump.tar.gz    l1low_dlebdump.tar.gz
    Log To Console    \n Expected l1low file number: ${l1low_file_num}
    FOR   ${l1low_file}  IN  @{l1low_file_list}
        ${l1low_file_size}    OperatingSystem.Get File Size    ${merged_dir}/${l1low_file}
        Should Be True   ${l1low_file_size}>0
    END

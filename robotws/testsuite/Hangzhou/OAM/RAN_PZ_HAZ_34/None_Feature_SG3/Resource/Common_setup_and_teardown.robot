*** Settings ***
Documentation    This is for common setup and teardown keywords
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Library    taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf


*** Variables ***
${SCF_PATH_ON_UTE}    /home/ute/SCF
${LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs


*** Keywords ***
Common Suite Setup
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               1. If ${is_commission}=True, will do commission for gnb
    ...               2. If two gnbs are exist for this testline and ${is_commission_for_second_gnb}=True, will do commission for gnb2
    [Arguments]     ${scf_name}=None    ${scf_name_for_second_gnb}=None
    ...             ${connection}=GNB_OAM0    ${is_commission}=True
    ...             ${connection_for_second_gnb}=GNB_OAM1    ${is_commission_for_second_gnb}=False
    ...             ${timeout_for_commission}=900    ${wait_gnb_up_timeout}=20 min     ${is_pdl_checking_needed}=${True}
    Run Keyword If    ${is_commission}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}    AND
    ...    COAM Commission with scf file    scf_file_path=${SCF_PATH_ON_UTE}/${scf_name}
    ...                                     connection=${connection}
    ...                                     timeout=${timeout_for_commission}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If    ${is_commission_for_second_gnb}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection_for_second_gnb}    gnb_index=${1}    AND
    ...    COAM Commission with scf file    scf_file_path=${SCF_PATH_ON_UTE}/${scf_name_for_second_gnb}
    ...                                     connection=${connection_for_second_gnb}
    ...                                     timeout=${timeout_for_commission}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If    ${is_commission}    Wait Gnb Ready And Cell On Air    gnb_id=${0}
    ...                                                                     timeout=${wait_gnb_up_timeout}
    ...                                                                     connection=${connection}
    Run Keyword If    ${is_commission_for_second_gnb}    Wait Gnb Ready And Cell On Air    gnb_id=${1}
    ...                                                                                    timeout=${wait_gnb_up_timeout}
    ...                                                                                    connection=${connection_for_second_gnb}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}    AND
    ...                           Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection_for_second_gnb}

Common Case Setup
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               1. If ${is_commission}=True, will do commission for gnb
    ...               2. If two gnbs are exist for this testline and ${is_commission_for_second_gnb}=True, will do commission for gnb2
    [Arguments]     ${scf_name}=None    ${scf_name_for_second_gnb}=None
    ...             ${connection}=GNB_OAM0    ${is_commission}=False
    ...             ${connection_for_second_gnb}=GNB_OAM1    ${is_commission_for_second_gnb}=False
    ...             ${timeout_for_commission}=900    ${wait_gnb_up_timeout}=20 min     ${is_pdl_checking_needed}=${True}
    Create Case Log Path
    Run Keyword If    ${is_commission}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}    AND
    ...    COAM Commission with scf file    scf_file_path=${SCF_PATH_ON_UTE}/${scf_name}
    ...                                     connection=${connection}
    ...                                     timeout=${timeout_for_commission}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If    ${is_commission_for_second_gnb}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection_for_second_gnb}    gnb_index=${1}    AND
    ...    COAM Commission with scf file    scf_file_path=${SCF_PATH_ON_UTE}/${scf_name_for_second_gnb}
    ...                                     connection=${connection_for_second_gnb}
    ...                                     timeout=${timeout_for_commission}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If    ${is_commission}    Wait Gnb Ready And Cell On Air    gnb_id=${0}
    ...                                                                     timeout=${wait_gnb_up_timeout}
    ...                                                                     connection=${connection}
    Run Keyword If    ${is_commission_for_second_gnb}    Wait Gnb Ready And Cell On Air    gnb_id=${1}
    ...                                                                                    timeout=${wait_gnb_up_timeout}
    ...                                                                                    connection=${connection_for_second_gnb}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}    AND
    ...                           Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection_for_second_gnb}

Common Case Teardown
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]     ${is_save_snapshot}=True    ${is_save_snapshot_for_second_gnb}=False
    ...             ${connection}=GNB_OAM0    ${connection_for_second_gnb}=GNB_OAM1
    ...             ${timeout}=900    ${alais}=ASIK Master0    ${alais_for_second_gnb}=ASIK Master1
    Run Keyword If    ${is_save_snapshot}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}    AND
    ...    Connect to Common Unit Master    alias=${alais}    gnb_index=${0}    AND
    ...    Run Keyword And Ignore Error    csn.execute    command=killall tcpdump    connection=${alais}    AND
    ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api    connection=${connection}
    ...                                                                                                     timeout=${timeout}
    Run Keyword If    ${is_save_snapshot_for_second_gnb}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection_for_second_gnb}    gnb_index=${1}    AND
    ...    Connect to Common Unit Master    alias=${alais_for_second_gnb}    gnb_index=${1}    AND
    ...    Run Keyword And Ignore Error    csn.execute    command=killall tcpdump    connection=${alais_for_second_gnb}    AND
    ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api
    ...                                                                  connection=${connection_for_second_gnb}
    ...                                                                  timeout=${timeout}
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=ps -ef | grep admin_api |awk '{print $2}' | xargs kill -9
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}    AND
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection_for_second_gnb}    AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=${alais}    AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=${alais_for_second_gnb}    AND
    ...    csn.Reset Cache    AND    CI_interface.Common Case Teardown

Wait Gnb Ready And Cell On Air
    [Timeout]    30 min
    [Documentation]    Description: Wait GNB cell on air , and each single cell status in cell on air status
    [Arguments]    ${gnb_id}=0    ${timeout}=20 min    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                                                                                   gnb_index=${gnb_id}
    Wait Until Keyword Succeeds    ${timeout}    20 sec    COAM Check GNB ABIL status    connection=${connection}
    Wait Until Keyword Succeeds    ${timeout}    20 sec    COAM Check GNB ASIK status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    Verify all cells should be onair    connection=${connection}
    ${gnb_type}    Get gNbType SA or NSA via rest api    connection=${connection}
    Run Keyword If    'NSA' in '${gnb_type}'
    ...    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check X2 link status from GNB    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Create Case Log Path
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Description: Create log directory with test case level and open a common variable ${TS_CASE_LOG_PATH}
    ${tc_name}=    Replace String    string=${TEST NAME}    search_for=${SPACE}    replace_with=_
    ${case_log_path}    Join path    ${LOG_PATH_BASE}    TC_${tc_name}
    Set Test Variable    ${TS_CASE_LOG_PATH}    ${case_log_path}
    Create Directory    ${TS_CASE_LOG_PATH}

Suite Common SetUp
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]     ${scf_path}=/home/ute/SCF
    ...             ${is_commission}=${True}
    ...             ${timeout_for_commission}=900
    ...             ${wait_gnb_up_timeout}=20 min
    ...             ${is_pdl_checking_needed}=${True}
    ...             ${gnb_index}=0
    ${stream_version}    gnb_classical_hangzhou.Get program version based on stream version
    Set Suite Variable    ${STREAM_VERSION}    ${stream_version}
    ${basic_golden_scf_name}    join path    ${scf_path}    GNB${gnb_index}_BASIC_GOLDEN_SCF_${stream_version}.xml
    Run Keyword If    ${is_commission}    Perform Commission    scf_file_path=${basic_golden_scf_name}
    ...                                                         gnb_index=${gnb_index}
    ...                                                         timeout_for_commission=${timeout_for_commission}
    ...                                                         wait_gnb_up_timeout=${wait_gnb_up_timeout}
    ...                                                         is_pdl_checking_needed=${is_pdl_checking_needed}
    Set Suite Variable    ${BASIC_SCF_PATH}    ${basic_golden_scf_name}

Case Common SetUp
    [Documentation]   stella.lin@nokia-sbell.com
    ...      this keyword is uesed to modify all the scf paramters and perform commission.
    ...      framestructure, chbw, prachConfigurationIndex, type0CoresetConfigurationIndex and so on.
    ...      it is recommended to use data.py to modify all the paramters.
    ...      param ${is_dynamic_pdcch_update},${is_case_level_update_params_exist} are deprecated.
    [Arguments]    ${update_param_name}=${None}
    ...            ${timeout_for_commission}=900
    ...            ${wait_gnb_up_timeout}=20 min
    ...            ${is_pdl_checking_needed}=${True}
    ...            ${gnb_index}=0
    ...            ${scf_file_path}=${BASIC_SCF_PATH}
    ...            ${is_dynamic_pdcch_update}=${True}
    ...            ${is_case_level_update_params_exist}=${True}
    Create Case Log Path
    ${STREAM_VERSION}    gnb_classical_hangzhou.Get program version based on stream version
    copy file    ${scf_file_path}     ${TS_CASE_LOG_PATH}/GNB${gnb_index}_SCF_SBTS${STREAM_VERSION}.xml
    ${scf_file_path}    Set Variable    ${TS_CASE_LOG_PATH}/GNB${gnb_index}_SCF_SBTS${STREAM_VERSION}.xml
    ${empty_dict}    Create Dictionary
    ${update_param_name}    Set Variable If   ${update_param_name}    ${update_param_name}    ${empty_dict}
    ${cell_chbw}    Set Variable    ${update_param_name.get('cell_chbw')}
    ${framestructure}    Set Variable    ${update_param_name.get('framestructure')}
    ${addition_params}    Set Variable    ${update_param_name.get('addition_params')}
    ${case_level_params}    Set Variable    ${update_param_name.get('case_level_params')}
    ${scf_with_2197}    Generate Commission File With Chbw Framestructure Dynamic Pdcch
    ...                 modify_cell_chbw_dict=${cell_chbw}
    ...                 framestructure=${framestructure}
    ...                 addition_params_dict=${addition_params}
    ...                 scf_file_path=${scf_file_path}
    ${scf_name_prefix}    Set Variable    ${scf_file_path.split('.xm')[0]}
    ${scf_with_case_level_params}    Generate Commission File With TestCase Level Params
    ...                              case_updata_params_list=${case_level_params}
    ...                              scf_file_path=${scf_with_2197}
    ${frame_status}    ${type}    Run Keyword And Ignore Error    Evaluate   isinstance('${framestructure}',str)
    ${framestructure_condition}    Set Variable If    '${frame_status}'=='PASS'    '${framestructure}'    ${framestructure}
    ${chbw_status}    ${type}    Run Keyword And Ignore Error    Evaluate   isinstance('${cell_chbw}',str)
    ${chbw_condition}    Set Variable If    '${chbw_status}'=='PASS'    '${cell_chbw}'    ${cell_chbw}
    ${commission_condition}    Catenate    ${chbw_condition} or ${framestructure_condition} or ${case_level_params}
    Run Keyword If    ${commission_condition}    Perform Commission    scf_file_path=${scf_with_case_level_params}
    ...                                                                gnb_index=${gnb_index}
    ...                                                                timeout_for_commission=${timeout_for_commission}
    ...                                                                wait_gnb_up_timeout=${wait_gnb_up_timeout}
    ...                                                                is_pdl_checking_needed=${is_pdl_checking_needed}

Perform Commission
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${scf_file_path}    ${gnb_index}=0    ${timeout_for_commission}=900
    ...            ${wait_gnb_up_timeout}=20 min    ${is_pdl_checking_needed}=${True}
    Connect to gnb coam via ssl    connection=GNB_OAM${gnb_index}   gnb_index=${gnb_index}
    COAM Commission with scf file    scf_file_path=${scf_file_path}
    ...                              connection=GNB_OAM${gnb_index}
    ...                              timeout=${timeout_for_commission}
    ...                              is_pdl_checking_needed=${is_pdl_checking_needed}
    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}    timeout=${wait_gnb_up_timeout}    connection=GNB_OAM${gnb_index}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM${gnb_index}

Generate Commission File With Chbw Framestructure Dynamic Pdcch
    [Documentation]   stella.lin@nokia-sbell.com
    ...                this keyword is used modify chbw and  Framestructure.
    ...                modify_cell_chbw_dict:  1.modify all tdd cell chbw --> 80MHz
    ...                                        2. modify partly tdd cell chbw --> {'1':'80MHz','2':'50MHz'}
    ...                                        3.not set. default is {}. will not modify chbw for all cell.
    ...               framestructure: valid input -->  1.modify same framestructure for all cell  , 11160ms,11163ms,1070,1208.
    ...                                                2. modify different framestructure --> {'1':'11160ms','2':'1070','3':'1208'}
    [Arguments]    ${modify_cell_chbw_dict}=${None}
    ...            ${framestructure}=${None}
    ...            ${addition_params_dict}=${None}
    ...            ${scf_file_path}=${None}
    ${scf_name_prefix}    Set Variable    ${scf_file_path.split('.xm')[0]}
    ${update_scf_with_2197}    update_framestructure_chbw_pdcch_params
    ...                        modify_cell_chbw_dict=${modify_cell_chbw_dict}
    ...                        framestructure=${framestructure}
    ...                        addition_params_dict=${addition_params_dict}
    ...                        basic_scf_path=${scf_file_path}
    ...                        update_scf_path=${scf_name_prefix}_UPDATE_WITH_2197.xml
    [Return]    ${update_scf_with_2197}

Generate Commission File With TestCase Level Params
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${case_updata_params_list}=${None}
    ...            ${scf_file_path}=${None}
    ${scf_name_prefix}    Set Variable    ${scf_file_path.split('.xm')[0]}
    ${update_scf_with_case_params}    perform_update_scf_params
    ...                               update_params=${case_updata_params_list}
    ...                               basic_scf_path=${scf_file_path}
    ...                               update_scf_path=${scf_name_prefix}_UPDATE.xml
    [Return]    ${update_scf_with_case_params}

Update Chbw Dynamic Pdcch And Wait Gnb On Air
    [Documentation]   Author: lei.jia@nokia-sbell.com
    ...                this keyword is used only to modify chbw, please note Framestructure not changed!
    ...                modify_cell_ids: can be a list for cell index, and also can be a string, like 1;
    ...                   Deafult to all: all cells on GNB will be updated
    ...               modify_cell_chbw_dict: dict, use this as example: { '2': '100MHz','4': '20MHz'}
    [Arguments]    ${modify_cell_chbw_dict}=${None}
    ...            ${scf_file_path}=${Golden_SCF_Path}
    ...            ${modify_cell_ids}=all
    ...            ${bandwidth}=100MHz
    ...            ${gnb_index}=0    ${timeout_for_commission}=900
    ...            ${wait_gnb_up_timeout}=20 min    ${is_pdl_checking_needed}=${True}
    copy file    ${scf_file_path}     ${TS_CASE_LOG_PATH}/SCF_origin.xml
    ${scf_file_path}    Set Variable    ${TS_CASE_LOG_PATH}/SCF_origin.xml
    ${modify_all_cell_chbw_dict}    create dictionary  all_tdd_cell=${bandwidth}
    ${modify_cell_chbw_dict}    set variable if    '${modify_cell_ids}'=='all'
    ...    ${modify_all_cell_chbw_dict}    ${modify_cell_chbw_dict}
    ${scf_with_2197}    Generate Commission File With Chbw Framestructure Dynamic Pdcch
    ...    modify_cell_chbw_dict=${modify_cell_chbw_dict}
    ...    scf_file_path=${scf_file_path}
    Perform Commission           scf_file_path=${scf_with_2197}
    ...                          gnb_index=${gnb_index}
    ...                          timeout_for_commission=${timeout_for_commission}
    ...                          wait_gnb_up_timeout=${wait_gnb_up_timeout}
    ...                          is_pdl_checking_needed=${is_pdl_checking_needed}
    [Teardown]  run keyword and ignore error   COAM Teardown gnb connections

Backup and Modify swconfig file
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                Description：backup swconfig and modify swconfig.
    ...              ${swconfig_modify}: Can be a list for the modified R&D parameters, example input with python format:
    ...                                 ['0x580002=0', '0x580121=0']
    ...              ${is_called_in_test_case_level}: available values: ${True} ${False},
    ...                                               default to ${False} which means keyword is called in test suite setup phase
    ...              ${SWCONFIG_DEFAULT_FILE_PATH}: refers to the template swconfig file path in test pc,
    ...                                             should be defined before calling this keyword
    [Arguments]    ${is_called_in_test_case_level}=${False}
    ...    ${swconfig_modify}=${None}
    ...    ${ASIK_MASTER_ALIAS}=ASIK Master
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    ${local_log_file_folder}    set variable if  ${is_called_in_test_case_level}==${True}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    swconf.Download swConfig file from asik to test pc    localFilePath=${local_log_file_folder}/swconfig.txt
    ...                                                   asik_alias=${ASIK_MASTER_ALIAS}
    ...                                                   remoteFilePath=/ffs/run/swconfig.txt
    Run keyword if    ${swconfig_modify}!=${None}
    ...    Run keywords    Log to console    Swconfig file modification is needed.    AND
    ...    swconf.Modify swConfig file    parametersList=${swconfig_modify}    filePath=${local_log_file_folder}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${local_log_file_folder}/swconfig.txt    asik_alias=ASIK Master
    csn.disconnect    connection=${ASIK_MASTER_ALIAS}











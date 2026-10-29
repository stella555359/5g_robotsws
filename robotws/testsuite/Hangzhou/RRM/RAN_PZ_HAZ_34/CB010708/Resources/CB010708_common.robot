*** Settings ***
Documentation    This is for feature CB010708 elated common keywords.
...              Please do not modify the file without notification to author
...              Author:xiaoxia.hao@nokia-sbell.com
...              Squard: HZ SG6

Library    taf.config.scf    WITH NAME    scf
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Variables   CB010708_variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/For_feature/Keywords_for_9915_10249.robot


*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
@{SWCONFIG_rdSuSinrFlag16RX}    0x580816=0
${7_5_UTE5G402T273_HW_TYPE}    GUANGHETONG
${7_5_UTE5G402T272_HW_TYPE}    YIYUAN

*** Keywords ***
10708_Suite_SetUp
    robot_common_operations.Common Suite Setup
    Run Keyword And Ignore Error    clear vm pid before run case
    @{ue_num}    Set Variable    ${tl.ues}
    ${ue_length}    Get Length    ${ue_num}
    Set Suite Variable    ${UE_LENGTH}    ${ue_length}
    FOR    ${ue_index}    IN RANGE    ${UE_LENGTH}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        Set Suite Variable    ${UE${ue_index}_TYPE}    ${ue_type}
    END
    ${stream_version}    Get Active SW Version Based On Stream Version
    Set Suite Variable    ${STREAM_VERSION}    ${stream_version}
    ${SCF_Path}    ${result}    Split String From Right    ${CURDIR}    testsuite     1
    ${ute_env}    Run Keyword And Return Status    Run Keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${tmp_testline}   Run Keyword If    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    Set Variable     ${testline_name}
    ${stream}    ${build}     Run Keyword If    ${ute_env}    CI_commssion._Get Stream From Variable    ${ENB_BUILD}
    ...    ELSE   CI_commssion._Get Stream From Variable    ${AF_PATH}
    Set Suite Variable    ${tmp_testline}
    Set Suite Variable    ${stream}
    Set Suite Variable    ${SCF_PATH}
    ${Golden_SCF_Path}    Set Variable    ${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}_1S-1CC_10708.xml
    Set Suite Variable    ${Golden_SCF_Path}
    Suite Log Path Create
    Upload Swconfig File And Reset Site
    DingLi_Client.UE Prepare    HW_TYPE=${${testline_name}_HW_TYPE}
#    DingLi_Client.SA And NSA Mode Change
#    Run Keyword And Ignore Error    client.detach     ue=${uegroup}    until_timeout=${300}     withpdu=1
    Sleep    5sec

10708_Suite_Teardown
    Run Keyword And Ignore Error    DingLi_Client.Teardown
    ${1CC_SCF_Path}    Set Variable    ${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}_3S-1CC.xml
    Act Ecpri Mode Switch    scf_path=${1CC_SCF_Path}    switch_to_mode=72a    log_path=${SUITE_LOG_PATH}
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    robot_common_operations.Common Suite Teardown

10708_Case_SetUp
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${swconfig_flag}=${None}
    ...            ${MOsToAdd}='NULL'
    ...            ${ParamterToModify}=${PARAMS_TO_MODIFY_For_72e}
    ...            ${ListParamterToModify}=${LIST_PARAMS_TO_MODIFY_For_2T8R}
    ...            ${ListToAdd}=${LIST_TO_ADD_SYNC_SOURCE_FRAME}
    ...            ${ParameterToDelete}=${PARAMS_TO_DELETE_TOPP_PARAMS}
    ...            ${scf_path}=${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}.xml
    ...            ${is_pdl_checking_needed}=${True}
    ...            ${modify_scf_file_needed}=${True}
    Log To Console    \n***start to case setup***
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    Create Case Log Path
    Run Keyword If    '${swconfig_flag}'!='${None}'     Backup and Modify swconfig file
    ...                                                 swconfig_modify=@{SWCONFIG_${swconfig_flag}}
    ${modified_scf_file_path}    Run Keyword If    ${modify_scf_file_needed}
    ...                          Modify and Save SCF
    ...                                                 MOsToAdd=${MOsToAdd}
    ...                                                 ParamterToModify=${ParamterToModify}
    ...                                                 ListParamterToModify=${ListParamterToModify}
    ...                                                 ListToAdd=${ListToAdd}
    ...                                                 ParameterToDelete=${ParameterToDelete}
    ...                                                 scf_path=${scf_path}
     ${scf_file_path}    Set Variable If    ${modify_scf_file_needed}    ${modified_scf_file_path}    ${scf_path}
#    Act Ecpri Mode Switch    scf_path=${modified_scf_file_path}    switch_to_mode=72e    log_path=${TS_CASE_LOG_PATH}
    Perform Commission    scf_file_path=${scf_file_path}
    ...                   timeout_for_commission=900
    ...                   wait_gnb_up_timeout=30 min
    ...                   is_pdl_checking_needed=${is_pdl_checking_needed}
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
    ${allowed_faults_list}    Combine Current Active Alarm With White List Alarm List
    Set Test Variable    ${ALLOWED_FAULTS_LIST}    ${allowed_faults_list}
    Run Keyword If    '${stream}'=='SBTS00'    Set MCS Phase And ATT For 10708    ELSE    Set MCS Phase And ATT For 10708 Branch

10708_Case_Teardown
    [Arguments]    ${is_recover_swconfig}=${False}    ${ASIK_MASTER_ALIAS}=ASIK Master
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_index=${1}     mcs_type=${mcs_type}
    ${ues_index}    Set Variable IF    '${stream}'=='SBTS00'    ${${0},${1},${2},${3},${4},${5},${6},${7}}    ${${0},${1},${2},${3}}
    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer    ues_index=${ues_index}
    Run Keyword And Ignore Error    DingLi_Client.Detach    ues_index=${ues_index}
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    Run Keyword And Continue On Failure    Check Whether New Alarm Happened During Running Case    alarm_info_before=${summary_alarm_info}
    Run Keyword And Ignore Error    Capture Snapshot If Case Failed
    run keyword if    ${is_recover_swconfig}    run keywords
    ...               run keyword and ignore error    COAM Teardown gnb connections    AND
    ...               run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl    AND
    ...               Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}    AND
    ...               swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=${ASIK_MASTER_ALIAS}    AND
    ...               robot_common_operations.Common Case Teardown

#Upload Swconfig File And Reset Site
#    [Documentation]    Author: jun.8.chen@nokia-sbell.com
#    [Arguments]    ${swconfig_path}=${CURDIR}/swconfig.txt    ${connection}=GNB_OAM
#    ...            ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=swconfig
#    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
#    ssh.Force Reconnect    connection=${alias}
#    Log To Console    Start update Swconfig file.
#    swconf.Upload swConfig file to asik and crasign    localFilePath=${swconfig_path}    asik_alias=${alias}
#    Do gNB Reset site and Wait Onair
#    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${alias}

Modify and Save SCF
    [Arguments]    ${MOsToAdd}='NULL'
    ...            ${ParamterToModify}=${PARAMS_TO_MODIFY_Channels_For_2T8R}
    ...            ${ListParamterToModify}=${LIST_PARAMS_TO_MODIFY_For_2T8R}
    ...            ${ListToAdd}=${LIST_TO_ADD_SYNC_SOURCE_FRAME}
    ...            ${ParameterToDelete}=${PARAMS_TO_DELETE_TOPP_PARAMS}
    ...            ${scf_path}=${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}_1S-1CC_10708.xml
    ${modified_scf_file_path}    Load SCF and Define modified scf path    scf_path=${scf_path}
    Delete Objects in SCF    parameters_lists=${ParameterToDelete}
    Run Keyword If    not ${MOsToAdd}=='NULL'    Add MOs To SCF with Given version    parameters_lists=${MOsToAdd}
    Add and Modify elements to scf    parameters_lists=${ParamterToModify}
    Modify ListElements to scf    parameters_lists=${ListParamterToModify}
    AddLists to SCF    parameters_lists=${ListToAdd}
    scf.Save scf    ${modified_scf_file_path}
    [Return]    ${modified_scf_file_path}

Load SCF and Define modified scf path
    [Documentation]   Author: lei.jia@nokia-sbell.com
    ...              Description: This keyword load scf and return modified scf path for future use.
    [Arguments]      ${scf_file_name}=${None}
    ...               ${scf_path}=${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}_1S-1CC_10708.xml
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${default_scf_file_path}    Copy file    source=${scf_path}    destination=${TS_CASE_LOG_PATH}
    ${scf_file_name}    Fetch from right    ${scf_path}    /
    ${scf_dir_path}    String.Replace string    ${scf_path}    /${scf_file_name}    ${EMPTY}
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}    _${timestamp}_updated.xml
    ${modified_scf_file_path}    set variable    ${TS_CASE_LOG_PATH}/${scf_file_name_after_modify}
    scf.Load scf    ${default_scf_file_path}
    [Return]    ${modified_scf_file_path}

Add and Modify elements to scf
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_element_in_object    dist_name=${item}[dist_name]    p_name=${item}[p_name]
        Run Keyword If    '${res}'=='True'     scf.modify_scf_element    value=${item}[value]   &{item}
        ...      ELSE                          scf.add element to scf
        ...                                    value=${item}[value]   dist_name=${item}[dist_name]    p_name=${item}[p_name]
    END

Add MOs To SCF with Given version
    [Documentation]   Add Mos for given version, used for add channels
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${item}[version]
    END

Modify ListElements to scf
    [Documentation]   Modify List element. report error If not present
    [Arguments]   ${parameters_lists}
     FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_list_in_object    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        Run Keyword If    '${res}'=='True'  Modify SCF ListElements   dist_name=${item}[dist_name]  list_name=${item}[list_name]
        ...        elements=${item}[elements]
     END

Modify SCF ListElements
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]   ${dist_name}    ${list_name}    ${elements}
     FOR    ${item}   IN    @{elements}
        scf.modify_scf_element    value=${item}[value]   dist_name=${dist_name}  list_name=${list_name}
        ...    p_name=${item}[p_name]    index=${item}[index]
     END

Delete Objects in SCF
    [Documentation]   Remove object , Mo, List, Element with p_name.
    [Arguments]     ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res_dist_name}=    Run Keyword And Ignore error    set suite variable    ${dist_name_to_delete}   ${item}[dist_name]
        ${res_list_name}=    Run Keyword And Ignore error    set suite variable    ${list_name_to_delete}   ${item}[list_name]
        ${res_p_name}=    Run Keyword And Ignore error    set suite variable    ${p_name_to_delete}   ${item}[p_name]
        Run Keyword If   ${res_p_name}== ('PASS', None)
        ...              Run Keyword And Ignore error    scf.Remove Element From Scf    &{item}
        Run Keyword If   ${res_list_name}== ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_list_from_scf    dist_name=${item}[dist_name]   list_name=${item}[list_name]
        Run Keyword If   ${res_list_name}!= ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END

AddLists to SCF
    [Documentation]   add List items and elements, if the items are present, remove it first.
    [Arguments]    ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_list_in_object    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        Run Keyword If    '${res}'!='True'     scf.add_list_to_scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        ${res}=    Run Keyword And Ignore error    scf.add item to list
        ...        dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
        Run keyword if    ${res} != ('PASS', None)    scf.add_elements_to_list
        ...        dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END

Set MCS Phase And ATT For 10708
    ${mcs_type}    mcs_common.Get MCS Type    mcs_index=${1}
    Set Test Variable    ${mcs_type}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=${None}    mcs_index=${1}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-35}    second_beam_horizontal_angle=${-50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=5
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${35}    second_beam_horizontal_angle=${50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=25
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${-15}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=23
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=22
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}    end_input_port=${32}

    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
    ...    begin_input_port=${33}    end_input_port=${64}

Set MCS Phase And ATT For 10708 Branch
    ${mcs_type}    mcs_common.Get MCS Type    mcs_index=${1}
    Set Test Variable    ${mcs_type}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=${None}    mcs_index=${1}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-30}    second_beam_horizontal_angle=${-45}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=17
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${35}    second_beam_horizontal_angle=${50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=22
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${-22}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=23
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=23
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}    end_input_port=${32}

    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
    ...    begin_input_port=${33}    end_input_port=${64}

Check PatternId In uldata_puschreceivereql1ru
    [Arguments]    ${file_path}    ${subcell_id}    ${force_count_of_value}=${NULL}
    ${numberOfRxBeamforming}    Get numberOfRxBeamforming Via SCF
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    ${count_of_value}    Set Variable If    '${force_count_of_value}'!='${NULL}'    ${force_count_of_value}
    ...                                     '${numberOfRxBeamforming}'=='8Rx'    ${4}    ${8}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceivereql1ru && 3gpp.rnti != 65535 && 3gpp.rnti != 65521
    ${patternId_values_list}    Get Field Value From PCAP    field_name=UlData_puschReceiveReqGrantL1ru_t.patternId_item
    ...                                                      filter_expression=${filter_with_subcell}
    ${patternId_values_length}    Get Length    ${patternId_values_list}
    Should Be True    ${patternId_values_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${patternId_invalid}    Set Variable    ${0}
    FOR    ${patternId_values}   IN    @{patternId_values_list}
        ${patternId_equal_to_zero}    Evaluate    [x for x in ${patternId_values} if int(x)==${0} or len(${patternId_values})!=${count_of_value}]
        ${length}    Get Length    ${patternId_equal_to_zero}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${0}    msg=${length} items of the patternId is equal to 0.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${patternId_invalid}    Evaluate    ${patternId_invalid}+${flag}
    END
    ${patternId_invalid_ratio}    Evaluate    ${patternId_invalid}/${patternId_values_length}
    Run Keyword And Continue On Failure    Should Be True    ${patternId_invalid_ratio}<=${0.01}
    ...    msg=${patternId_invalid_ratio} percent of the patternId is invalid ,equal to 0

Check UL Rank On UlData_PuschReceiveRespPs
    [Arguments]    ${file_path}    ${subcell_id}    ${expect_rank}=2
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceiverespps && 3gpp.rnti != 65535
    ${ul_rank_list}    Get Field Value From PCAP    field_name=UlData_UePuschReceiveRespPs_t.ulRank
    ...                                             filter_expression=${filter_with_subcell}
    ${ul_rank_length}    Get Length    ${ul_rank_list}
    Should Be True    ${ul_rank_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${rank_invalid}    Set Variable    ${0}
    FOR    ${ul_rank}   IN    @{ul_rank_list}
        ${error_rank}    Evaluate    [x for x in ${ul_rank} if int(x)!=int(${expect_rank})]
        ${length}    Get Length    ${error_rank}
        ${status}     Run Keyword And Return Status     Should Be True    ${length}==${0}
        ...    msg=not all the rank is equal to rank${expect_rank} on UlData_PuschReceiveRespPs.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${rank_invalid}    Evaluate    ${rank_invalid}+${flag}
    END
    ${rank_invalid_ratio}    Evaluate    ${rank_invalid}/${ul_rank_length}
    Run Keyword And Continue On Failure    Should Be True    ${rank_invalid_ratio}<=0.01
    ...    msg=${rank_invalid_ratio} percent of the rank is not rank${expect_rank}

Check UL Rank On uldata_puschreceivereql1ru
    [Arguments]    ${file_path}    ${subcell_id}    ${expect_rank}=2
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceivereql1ru
    ${ul_rank_list}    Get Field Value From PCAP    field_name=uldata_puschreceivereql1ruGrant_t.numOfLayers
    ...                                             filter_expression=${filter_with_subcell}
    ${ul_rank_length}    Get Length    ${ul_rank_list}
    Should Be True    ${ul_rank_length}>${1}    msg=no valid data filter out.please check the bip log.
    FOR    ${ul_rank}   IN    @{ul_rank_list}
        ${error_rank}    Evaluate    [x for x in ${ul_rank} if int(x)!=int(${expect_rank})]
        ${length}    Get Length    ${error_rank}
        Run Keyword And Continue On Failure    Should Be True    ${length}==${0}
        ...    msg=ul rank is not ${expect_rank} on uldata_puschreceivereql1ru, actual is ${ul_rank}.
    END

Check Rxpower And Sinr In UlData_PuschReceiveRespPs
    [Arguments]    ${file_path}    ${subcell_id}    ${rxpower_ie_item}=${8}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceiverespps
    ${rxpower_values_list}    Get Field Value From PCAP    field_name=UlData_puschAntMeas_t.rxPowerOfAnt
    ...                                                    filter_expression=${filter_with_subcell}
    ${sinr_values_list}    Get Field Value From PCAP    field_name=UlData_puschAntMeas_t.sinrOfAnt
    ...                                                 filter_expression=${filter_with_subcell}
    ${rxpower_values_length}    Get Length    ${rxpower_values_list}
    Should Be True    ${rxpower_values_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${rx_power_invalid}    Set Variable    ${0}
    ${ant_sinr_invalid}    Set Variable    ${0}
    FOR    ${rxpower_values}   IN    @{rxpower_values_list}
        ${length}    Get Length    ${rxpower_values}
        Run Keyword And Continue On Failure    Should Be True    ${length}==${rxpower_ie_item}    msg=rxpower IE not have 8 items.
        ${rxpower_below_110}    Evaluate    [x for x in ${rxpower_values} if abs(float(x))>abs(float(-120))]
        ${length}    Get Length    ${rxpower_below_110}
#        Run Keyword And Continue On Failure    Should Be True    ${length}==${0}    msg=${length} items of the rxpower is below -110.
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${0}
        ...     msg=${length} items of the rxpower is below -120.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${rx_power_invalid}    Evaluate    ${rx_power_invalid}+${flag}
    END
    FOR    ${sinr_values}   IN    @{sinr_values_list}
        ${length}    Get Length    ${sinr_values}
        Run Keyword And Continue On Failure    Should Be True    ${length}==${rxpower_ie_item}    msg=rxpower IE not have 8 items.
        ${sinr_below_zero}    Evaluate    [x for x in ${sinr_values} if float(x)<=${0}]
        ${length}    Get Length    ${sinr_below_zero}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${0}    msg=${length} items of the sinr is below zero.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${ant_sinr_invalid}    Evaluate    ${ant_sinr_invalid}+${flag}
    END
    ${rx_power_invalid_ratio}    Evaluate    ${rx_power_invalid}/${rxpower_values_length}
    ${ant_sinr_invalid_ratio}    Evaluate    ${ant_sinr_invalid}/${rxpower_values_length}
    Run Keyword And Continue On Failure    Should Be True   ${rx_power_invalid_ratio}<=0.015
    ...    msg=${rx_power_invalid_ratio} percent of the rxpower is invalid ,below -110.
    Run Keyword And Continue On Failure    Should Be True    ${ant_sinr_invalid_ratio}<=0.015
    ...    msg=${ant_sinr_invalid_ratio} percent of the ant sinr is invalid, below zero.

Check Values On UlData_SrsReceiveRespPs
    [Arguments]    ${file_path}    ${subcell_id}    ${value_infor_length}=${8}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_srsreceiverespps
    ${rxpower_values_list}    Get Field Value From PCAP    field_name=UlData_srsAntMeas_t.rxPowerOfAnt
    ...                                                    filter_expression=${filter_with_subcell}
    ${ant_sinr_values_list}    Get Field Value From PCAP    field_name=UlData_srsAntMeas_t.sinrOfAnt
    ...                                                     filter_expression=${filter_with_subcell}
    ${ul_rank_list}    Get Field Value From PCAP    field_name=UlData_srsReceiveRespPsUes_t.ulRank
    ...                                             filter_expression=${filter_with_subcell}
    ${rxpower_values_length}    Get Length    ${rxpower_values_list}
    Should Be True    ${rxpower_values_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${rx_power_invalid}    Set Variable    ${0}
    ${ant_sinr_invalid}    Set Variable    ${0}
    ${rank_invalid}    Set Variable    ${0}
    FOR    ${rxpower_values}   IN    @{rxpower_values_list}
        ${length}    Get Length    ${rxpower_values}
        Run Keyword And Continue On Failure    Should Be True    ${length}==${value_infor_length}
        ...                                                      msg=rxpower IE not have ${value_infor_length} items.
        ${invalid_rxpower}    Evaluate    [x for x in ${rxpower_values} if abs(float(x))==abs(float(-255))]
        ${length}    Get Length    ${invalid_rxpower}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${value_infor_length}
        ...     msg=${value_infor_length} items of the rxpower is invalid -255
        ${flag}    Set Variable If    '${status}'=='${True}'    ${1}    ${0}
        ${rx_power_invalid}    Evaluate    ${rx_power_invalid}+${flag}
    END
    FOR    ${ant_sinr_values}   IN    @{ant_sinr_values_list}
        ${length}    Get Length    ${ant_sinr_values}
        Run Keyword And Continue On Failure    Should Be True    ${length}==${value_infor_length}
        ...                                                      msg=rxpower IE not have ${value_infor_length} items.
        ${invalid_sinr}    Evaluate    [x for x in ${ant_sinr_values} if abs(float(x))==abs(float(-255))]
        ${length}    Get Length    ${invalid_sinr}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${value_infor_length}
        ...                                    msg=${value_infor_length} items of the sinr is invalid -255
        ${flag}    Set Variable If    '${status}'=='${True}'    ${1}    ${0}
        ${ant_sinr_invalid}    Evaluate    ${ant_sinr_invalid}+${flag}
    END
    FOR    ${ul_rank}   IN    @{ul_rank_list}
        ${ul_not_rank1}    Evaluate    [x for x in ${ul_rank} if int(x)!=${1}]
        ${length}    Get Length    ${ul_not_rank1}
        ${status}     Run Keyword And Return Status     Should Be True    ${length}==${0}
        ...    msg=not all the rank is equal to rank1 on UlData_SrsReceiveRespPs.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${rank_invalid}    Evaluate    ${rank_invalid}+${flag}
    END
    ${rx_power_invalid_ratio}    Evaluate    ${rx_power_invalid}/${rxpower_values_length}
    ${ant_sinr_invalid_ratio}    Evaluate    ${ant_sinr_invalid}/${rxpower_values_length}
    ${rank_invalid_ratio}    Evaluate    ${rank_invalid}/${rxpower_values_length}
    Run Keyword And Continue On Failure    Should Be True     ${rx_power_invalid_ratio}<=0.015
    ...    msg=${rx_power_invalid_ratio} percent of the rxpower is invalid -255
    Run Keyword And Continue On Failure    Should Be True    ${ant_sinr_invalid_ratio}<=0.015
    ...    msg=${ant_sinr_invalid_ratio} percent of the ant sinr is invalid -255
    Run Keyword And Continue On Failure    Should Be True    ${rank_invalid_ratio}<=0.8
    ...    msg=${rank_invalid_ratio} percent of the rank is not rank1

Check UlData_SrsReceiveReq Exist
    [Arguments]    ${file_path}    ${subcell_id}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_srsreceivereq
    ${test_value_list}    Get Field Value From PCAP    field_name=UlData_srsReceiveReqUes_t.startPrb
    ...                                             filter_expression=${filter_with_subcell}
    ${test_length}    Get Length    ${test_value_list}
    Should Be True    ${test_length}>${1}    msg=no message : UlData_SrsReceiveReq

Check Pattern ID In uldata_srsreceivereq
    [Arguments]    ${file_path}    ${subcell_id}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_srsreceivereq
    ${patternId_values_list}    Get Field Value From PCAP    field_name=UlData_srsReceiveReqUes_t.patternId_item
    ...                                                      filter_expression=${filter_with_subcell}
    ${patternId_values_length}    Get Length    ${patternId_values_list}
    Should Be True    ${patternId_values_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${patternId_invalid}    Set Variable    ${0}
    FOR    ${patternId_values}   IN    @{patternId_values_list}
        ${patternId_equal_to_zero}    Evaluate    [x for x in ${patternId_values[0:4]} if int(x)==${0}]
        ${length}    Get Length    ${patternId_equal_to_zero}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${0}    msg=${length} items of the patternId is equal to 0.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${patternId_invalid}    Evaluate    ${patternId_invalid}+${flag}
    END
    ${patternId_invalid_ratio}    Evaluate    ${patternId_invalid}/${patternId_values_length}
    Run Keyword And Continue On Failure    Should Be True    ${patternId_invalid_ratio}<=${0.01}
    ...    msg=${patternId_invalid_ratio} percent of the patternId is invalid ,equal to 0

Check PBoost Value On Cell Edge
    [Arguments]    ${file_path}    ${subcell_id}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceivereql1ru
    ${pboost_list}    Get Field Value From PCAP    field_name=UlData_puschReceiveReqGrantL1ru_t.pBoost
    ...                                             filter_expression=${filter_with_subcell}
    ${pboost_length}    Get Length    ${pboost_list}
    Should Be True    ${pboost_length}>${1}    msg=no valid data filter out.please check the bip log.
    FOR    ${pboost}   IN    @{pboost_list}
        ${pboost_not_above_zero}    Evaluate    [x for x in ${pboost} if float(x)<=${0}]
        ${length}    Get Length    ${pboost_not_above_zero}
        Run Keyword And Continue On Failure    Should Be True    ${length}==${0}
        ...    msg=pBoost is not above zero ,actual is ${pboost}.
    END

Check UL Rank On UlData_PuschReceiveReq
    [Arguments]    ${file_path}    ${subcell_id}    ${expect_rank}=2
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceivereql1ru
    ${ul_rank_list}    Get Field Value From PCAP    field_name=UlData_puschReceiveReqGrantL1ru_t.numOfLayers
    ...                                             filter_expression=${filter_with_subcell}
    ${ul_rank_length}    Get Length    ${ul_rank_list}
    Should Be True    ${ul_rank_length}>${1}    msg=no valid data filter out.please check the bip log.
    FOR    ${ul_rank}   IN    @{ul_rank_list}
        ${error_rank}    Evaluate    [x for x in ${ul_rank} if int(x)!=int(${expect_rank})]
        ${length}    Get Length    ${error_rank}
        Run Keyword And Continue On Failure    Should Be True    ${length}==${0}
        ...    msg=ul rank is not ${expect_rank} on uldata_puschreceivereql1ru, actual is ${ul_rank}.
    END

Check StartPrb For SRS
    [Arguments]    ${file_path}    ${subcell_id}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_srsreceivereq
    ${srsBmSubbandId}    Get Field Value From PCAP    field_name=UlData_srsBmResource_t.srsBmSubbandId
    ...                                               filter_expression=${filter_with_subcell}
    ${startPrb}    Get Field Value From PCAP    field_name=UlData_srsBmResource_t.startPrb
    ...                                         filter_expression=${filter_with_subcell}
    ${srsBmSubbandId_length}    Get Length    ${srsBmSubbandId}
    Should Be True    ${srsBmSubbandId_length}>${1}    msg=no valid data filter out.please check the bip log.
    FOR    ${index}    IN RANGE   len(${srsBmSubbandId})
        Run Keyword And Continue On Failure    Should Be Equal As Integers    ${startPrb[${index}][0]}
        ...    ${startprb_mapping_table['${srsBmSubbandId[${index}][0]}']}
        ...    msg=srs startprb is not correct.
    END

Modify Parameter cSRS
    [Arguments]    ${cell_index}=1    ${cSRS}=56    ${startRB}=8
    Log To Console    \n***start to update cSRS***
    ${update_param_branch}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'srsForBeamMgmt','value':[{'cSRS':'${cSRS}'}]}
    ${update_param_SBTS00}    catenate
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'srsForBeamMgmt','value':[{'cSRS':'${cSRS}'}]},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'csirsForTracking','value':[{'startRB':'${startRB}'}]}
    ${update_param}    run keyword if    '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'   Evaluate     [${update_param_SBTS00}]
    ...                                                   ELSE    Evaluate    [${update_param_branch}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    ...                                          skip_parameter_relation_errors=False

Activate PRB Blank For CB0010708
    [Arguments]    ${skip_parameter_relation_errors}=True
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Activate PRB Blank For 9915    cell_index=1
    ...                            bwpDN_index_common=16
    ...                            bwpDN_index_dedicate=167
    ...                            bwpDN_index_powersaving=10167
    ...                            nbrOfBlankedPRBsHighEdgeDL=9
    ...                            nbrOfBlankedPRBsHighEdgeUL=9
    ...                            nbrOfBlankedPRBsLowEdgeDL=9
    ...                            nbrOfBlankedPRBsLowEdgeUL=9
    ...                            skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Modify Parameter cSRS

Used BIP File Rename
    [Arguments]    ${bip_file_path}
    ${path_prefix}    Fetch From Left    ${bip_file_path}    fct_L2L1
    ${new_bip_file_path}    Join Path    ${path_prefix}    l2l2_Bip_used.pcap
    copy file    ${bip_file_path}    ${new_bip_file_path}
    [Return]    ${new_bip_file_path}

Cycle UPdate ATT Value
    [Arguments]    ${att_value}=40    ${target_att_Value}=54
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${att_value}
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Sleep    5sec
    FOR    ${i}    IN RANGE    1    10
        ${new_att_value}    evaluate    int(${att_value})+5
        Log To Console    update ATT value to ${new_att_value}
        Mcs.Set ATT Value For Four Output Ports
        ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${new_att_value}
        ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
        Sleep  5sec
        ${att_value}    Set Variable    ${new_att_value}
        exit for loop if    int(${new_att_value})>${target_att_Value}
    END


Update_Param_For_CB010708_C
    [Documentation]     nrcelltype: 16D4U
    ...                 numberOfRxBeamforming: 16RX
    ...                 actUlMuMimo: true
    ...                 ulSinrDiffThreshold: 10
    [Arguments]    ${cell_index}=1    ${update_value}=10   ${qrxlevmin_value}=-40    ${ulMuMimoCorrThd2_value}=80
    ...            ${skip_parameter_relation_errors}=False
    Log To Console    \n***start to nrcelltype and numberOfRxBeamforming***
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${update_param}    catenate
#   ...{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'nrCellType','value':'16DL4UL'},
#    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'numberOfRxBeamforming','value':'16Rx'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actUlMuMimo','value':'true'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actAdaptiveReTxResMcsEnh','value':'true'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'qRxLevMin','value':'${qrxlevmin_value}'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actHighSpeedCell','value':'false'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actPmiSinrUlMuMimo','value':'false'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'prachSequenceType','value':'Unrestricted'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...                 'parameter':'ulDMRSAdditionalPosition','value':'One additional DMRS'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...                 'parameter':'dlDMRSAdditionalPosition','value':'One additional DMRS'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0',
    ...                 'parameter':'ulSinrDiffThreshold','value':'${update_value}'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0',
    ...                 'parameter':'ulMuMimoCorrThd2','value':'${ulMuMimoCorrThd2_value}'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    ...                                          skip_parameter_relation_errors=${skip_parameter_relation_errors}

Update_Param_For_CB010708_C_trunk
    [Documentation]     nrcelltype: 16D4U
    ...                 numberOfRxBeamforming: 16RX
    ...                 actUlMuMimo: true
    ...                 ulSinrDiffThreshold: 10
    [Arguments]    ${master_cell_index}=1    ${second_cell_index}=4    ${update_value}=10   ${qrxlevmin_value}=-40    ${ulMuMimoCorrThd2_value}=80
    ...            ${skip_parameter_relation_errors}=False
    Log To Console    \n***start to nrcelltype and numberOfRxBeamforming***
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${update_param}    catenate
#   ...{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'nrCellType','value':'16DL4UL'},
#    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'numberOfRxBeamforming','value':'16Rx'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${master_cell_index}',
    ...                 'parameter':'actUlMuMimo','value':'true'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${master_cell_index}',
    ...                 'parameter':'actAdaptiveReTxResMcsEnh','value':'true'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${master_cell_index}',
    ...                 'parameter':'qRxLevMin','value':'${qrxlevmin_value}'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${master_cell_index}',
    ...                 'parameter':'actHighSpeedCell','value':'false'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${master_cell_index}',
    ...                 'parameter':'actPmiSinrUlMuMimo','value':'false'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${master_cell_index}',
    ...                 'parameter':'prachSequenceType','value':'Unrestricted'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${master_cell_index}',
    ...                 'parameter':'ulDMRSAdditionalPosition','value':'One additional DMRS'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${master_cell_index}',
    ...                 'parameter':'dlDMRSAdditionalPosition','value':'One additional DMRS'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${master_cell_index}/NRULMUMIMO-0',
    ...                 'parameter':'ulSinrDiffThreshold','value':'${update_value}'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${master_cell_index}/NRULMUMIMO-0',
    ...                 'parameter':'ulMuMimoCorrThd2','value':'${ulMuMimoCorrThd2_value}'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${second_cell_index}',
    ...                 'parameter':'actUlMuMimo','value':'true'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${second_cell_index}',
    ...                 'parameter':'actAdaptiveReTxResMcsEnh','value':'true'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${second_cell_index}',
    ...                 'parameter':'qRxLevMin','value':'${qrxlevmin_value}'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${second_cell_index}',
    ...                 'parameter':'actHighSpeedCell','value':'false'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${second_cell_index}',
    ...                 'parameter':'actPmiSinrUlMuMimo','value':'false'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${second_cell_index}',
    ...                 'parameter':'prachSequenceType','value':'Unrestricted'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${second_cell_index}',
    ...                 'parameter':'ulDMRSAdditionalPosition','value':'One additional DMRS'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${second_cell_index}',
    ...                 'parameter':'dlDMRSAdditionalPosition','value':'One additional DMRS'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${second_cell_index}/NRULMUMIMO-0',
    ...                 'parameter':'ulSinrDiffThreshold','value':'${update_value}'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${second_cell_index}/NRULMUMIMO-0',
    ...                 'parameter':'ulMuMimoCorrThd2','value':'${ulMuMimoCorrThd2_value}'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    ...                                          skip_parameter_relation_errors=${skip_parameter_relation_errors}

Update_Param_numberOfRxBeamforming_To_16Rx
    [Documentation]     nrcelltype: 16D4U
    ...                 numberOfRxBeamforming: 16RX
    ...                 actUlMuMimo: true
    ...                 ulSinrDiffThreshold: -5
    [Arguments]    ${cell_index}=1
    Log To Console    \n***start to nrcelltype and numberOfRxBeamforming***
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${update_param}    catenate
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'numberOfRxBeamforming','value':'16Rx'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    ...                                          skip_parameter_relation_errors=True

Update_numberOfRxPucch To 8RX and Add Channels For 2T8R
    [Documentation]    numberOfRxPucch: 8RX
    [Arguments]    ${cell_index}=1
    Log To Console    \n***start to numberOfRxPucch to 8Rx***
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${update_param}    catenate
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'numberOfRxPucch','value':'8Rx'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    ...                                          skip_parameter_relation_errors=True
#    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
#    ${add_channel}    catenate
##    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'numberOfRxPucch','value':'8Rx'},
#    ...               {'dist_name':'MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_index}/CHANNELGROUP-1/CHANNEL-9',
#    ...                'parameter':'direction','value':'RX'},
#    ...               {'dist_name':'MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_index}/CHANNELGROUP-1/CHANNEL-9',
#    ...                'parameter':'resourceDN','value':'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/PHYANT-1'},
#    ...               {'dist_name':'MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_index}/CHANNELGROUP-1/CHANNEL-10',
#    ...                'parameter':'direction','value':'RX'},
#    ...               {'dist_name':'MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_index}/CHANNELGROUP-1/CHANNEL-10',
#    ...                'parameter':'resourceDN','value':'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/PHYANT-1'},
#    ...               {'dist_name':'MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_index}/CHANNELGROUP-1/CHANNEL-11',
#    ...                'parameter':'direction','value':'RX'},
#    ...               {'dist_name':'MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_index}/CHANNELGROUP-1/CHANNEL-11',
#    ...                'parameter':'resourceDN','value':'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/PHYANT-1'},
#    ...               {'dist_name':'MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_index}/CHANNELGROUP-1/CHANNEL-12',
#    ...                'parameter':'direction','value':'RX'},
#    ...               {'dist_name':'MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_index}/CHANNELGROUP-1/CHANNEL-12',
#    ...                'parameter':'resourceDN','value':'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/PHYANT-1'}
#    ${add_channel}     evaluate    [${add_channel}]
#    ${update_numberOfRxPucch}    catenate
#    ...                {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'numberOfRxPucch','value':'8Rx'},
#    ${Active_SW_version}    Get Active SW Version
#    set test variable    ${Active_SW_version}
#    Selenium Login And Disable Screen Lock
#    log to console  update numberOfRxPucch to 8Rx
#    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
#    ...    filter_param=Number of Rx PUCCH    abbr=numberOfRxPucch    new_value=8Rx
##    @{channel_list}    Create List    9    10    11    12
##    FOR    ${channel_id}   IN    @{channel_list}
##        log to console  add CHANNEL-${channel_id}
##        selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_index}/CHANNELGROUP-1
##        ...    object_class_name=CHANNEL
##        ...    plan_to_copy_from=CURRENT_BTS_CONF-1
##        ...    copy_from=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_index}/CHANNELGROUP-1/CHANNEL-8
##        ...    include_subobject=${True}   id_value=${channel_id}    timeout=15
##    END
#    selenium_coam.validate_plan
#    Run Keyword And Continue On Failure    COAM check validation errors from webui    is_need_to_check_validation_errors=${False}
#    selenium_coam.activate_plan   download_plan_without_activation=${False}    activate_plan_despite_errors=${True}
#    ...   execute=${True}   timeout=600
#    sleep  30s
#    Close Start Up View    timeout=60
#    Wait Gnb Ready And Cell On Air    gnb_id=0
#    [Teardown]    run keyword and ignore error    selenium logout and close browser

Update_UlMuMimo_Values
    [Documentation]     actUlMuMimoGroupPairing: true
    ...                 actUlMuMimoTapering: true
    [Arguments]    ${cell_index}=1    ${skip_parameter_relation_errors}=False
    Log To Console    \n***start to nrcelltype and numberOfRxBeamforming***
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${update_param}    catenate
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0',
    ...                 'parameter':'actUlMuMimoGroupPairing','value':'true'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0',
    ...                 'parameter':'actUlMuMimoTapering','value':'true'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    ...                                          skip_parameter_relation_errors=${skip_parameter_relation_errors}

Update_HighSpeedCell_Values
    [Documentation]     actHighSpeedCell: true
    ...                 ulDMRSAdditionalPosition: Two additional DMRS
    [Arguments]    ${cell_index}=1    ${skip_parameter_relation_errors}=False
    Log To Console    \n***start to actHighSpeedCell and ulDMRSAdditionalPosition***
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${update_param}    catenate
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...                 'parameter':'actHighSpeedCell','value':'true'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...                 'parameter':'ulDMRSAdditionalPosition','value':'Two additional DMRS'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    ...                                          skip_parameter_relation_errors=${skip_parameter_relation_errors}

#Get numberOfRxBeamforming Via SCF
#    [Arguments]      ${cell_idx}=1    ${connection}=GNB_OAM    ${timeout}=600
#    Run Keyword And Ignore Error    COAM Teardown gnb connections
#    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    gnb_index=0
#    ${numberOfRxBeamforming}    coam_parameter.get_single_value_from_scf_file
#    ...                         parameter=numberOfRxBeamforming
#    ...                         dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}
#    ...                         connection=${connection}
#    ...                         timeout=${timeout}
#    [Return]    ${numberOfRxBeamforming}
#    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

#Check AVQL Err and WRN Log On RF
#    [Documentation]  Author: Hao Xiaoxia
#    [Arguments]  ${connection}=GNB_OAM    ${ru_dfe_ip}=192.168.100.17    ${asik_connection}=ASIK Master    ${ru_index}=${1}
#    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
#    run keyword and ignore error    COAM Teardown gnb connections
#    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
#    Connect to Common Unit Master    alias=${asik_connection}
#    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
#    ${connection}    csn.get connection by alias    alias=RU_${ru_index}
#    ${channel}    Call Method    ${connection}    invoke_shell
#    Call Method    ${channel}    send     ssh ${ru_dfe_ip}\n
#    Call Method    ${channel}    send     cat /var/log/l1_runtime.log |grep -i "/ERR"\n
#    sleep  2sec
#    Call Method    ${channel}    send     cat /var/log/l1_runtime.log |grep -i "/WRN"\n
#    sleep  2sec
#    ${error_output}    Call Method    ${channel}    recv    ${65535}
#    Log    ${error_output}
#    ${error_output}    convert to string    ${error_output}
#    ${error_infor_regexp}    set variable    .*ERR.*
#    ${wrn_infor_regexp}    set variable    .*WRN.*
#    ${error_infor_value}    Get Regexp Matches    ${error_output}    ${error_infor_regexp}
#    ${err_len}   Get Length   ${error_infor_value}
#    Run Keyword And Continue On Failure    should be true    ${err_len}<4
#    log    ${error_infor_value}
#    ${exp_error_infor_regexp}    set variable    WRN.*Got stop notification without collection request, ignored
#    ${wrn_infor_value}    Get Regexp Matches    ${error_output}    ${wrn_infor_regexp}
#    ${wrn_len}   Get Length   ${wrn_infor_value}
#    ${exp_wrn_infor_value}    Get Regexp Matches    ${error_output}    ${exp_error_infor_regexp}
#    ${exp_wrn_infor_len}   Get Length   ${exp_wrn_infor_value}
#    ${need_checked_wrn_len}    Evaluate    ${wrn_len}-${exp_wrn_infor_len}
#    Run Keyword And Continue On Failure    should be true    ${need_checked_wrn_len}<2
#     log    ${wrn_infor_value}
#    [Teardown]  Call Method    ${channel}    close

#Start To Attach And Capture Cpif File
#    [Arguments]    ${ues_index}=${${0},${1}}    ${UE_mode}=5G_SA
#    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
#    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=1    connection=GNB_OAM    timeout=300
#    Connect to Common Unit Master     alias=ASIK Master   gnb_index=0
#    Run Keyword And Continue On Failure    Start CP-IF Log Collection    tcpdump_collector_name=cpif_wireshark
#    ...                                                                  asik_connection_alias=ASIK Master
#    ...                                                                  gnb_index=0
#    ...                                                                  du_index=0
#    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach With Retry    ues_index=${ues_index}    5G_band=78
#    ...                                                                                        is_restart_ue=${True}    UE_mode=${UE_mode}
#    ${expect_pci}    Set Variable    721
#    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info    ues_index=${ues_index}
#    ...                                                                                          expect_pci=${expect_pci}
#    ${cpif_log_on_testPC}    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=cpif_wireshark
#    ...                                                                                            target_dir=${TS_CASE_LOG_PATH}
#    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
#    [Return]    ${expect_pci}    ${cpif_log_on_testPC}

Get BIP log For CB010708
    [Arguments]    ${expect_pci}    ${target_file_name}    ${duration}=30sec
    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
    ...                                                                                 target_file_name=${target_file_name}
    Sleep    ${duration}
    ${bip_log_full_path}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ...                                                             target_file_name=${target_file_name}
    [Return]    ${bip_log_full_path[0]}

Update MCS Phase And ATT For 4NSA
    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-30}    second_beam_horizontal_angle=${-45}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${30}    second_beam_horizontal_angle=${50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${2}    second_beam_horizontal_angle=${-15}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${24}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}

Update MCS Phase And ATT For 4NSA Branch
    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-35}    second_beam_horizontal_angle=${-50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${35}    second_beam_horizontal_angle=${50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${-22}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}

Check PatternId In uldata_puschreceivereql1ru For NSA
    [Arguments]    ${file_path}    ${subcell_id}
    ${numberOfRxBeamforming}    Get numberOfRxBeamforming Via SCF
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    ${count_of_value}    Set Variable If    '${numberOfRxBeamforming}'=='8Rx'    ${1}    ${2}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceivereql1ru && 3gpp.rnti != 65535 && 3gpp.rnti != 65521
    ${patternId_values_list}    Get Field Value From PCAP    field_name=UlData_puschReceiveReqGrantL1ru_t.patternId_item
    ...                                                      filter_expression=${filter_with_subcell}
    ${patternId_values_length}    Get Length    ${patternId_values_list}
    Should Be True    ${patternId_values_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${patternId_invalid}    Set Variable    ${0}
    FOR    ${patternId_values}   IN    @{patternId_values_list}
        ${patternId_equal_to_zero}    Evaluate    [x for x in ${patternId_values} if int(x)==${0} or len(${patternId_values})!=${count_of_value}]
        ${length}    Get Length    ${patternId_equal_to_zero}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${0}    msg=${length} items of the patternId is equal to 0.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${patternId_invalid}    Evaluate    ${patternId_invalid}+${flag}
    END
    ${patternId_invalid_ratio}    Evaluate    ${patternId_invalid}/${patternId_values_length}
    Run Keyword And Continue On Failure    Should Be True    ${patternId_invalid_ratio}<=${0.01}
    ...    msg=${patternId_invalid_ratio} percent of the patternId is invalid ,equal to 0

UPdate All ATT Value
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=25
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=45
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}    end_input_port=${32}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=43
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}    end_input_port=${32}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=42
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}    end_input_port=${32}

Restore All ATT Value
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=5
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=25
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}    end_input_port=${32}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=23
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}    end_input_port=${32}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=22
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}    end_input_port=${32}

UPdate All ATT Value FOR RSRP 85
  ${att_value}    Set Variable    3
   FOR    ${i}    IN RANGE    10
        ${new_att_value}    evaluate    int(${att_value})+2
        Log To Console    update ATT value to ${new_att_value}
        Mcs.Set ATT Value For Four Output Ports
        ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${new_att_value}
        ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
        Sleep  2sec
        ${att_value}    Set Variable    ${new_att_value}
    END
   ${att_value}    Set Variable    25
   FOR    ${i}    IN RANGE    10
        ${new_att_value}    evaluate    int(${att_value})+2
        Log To Console    update ATT value to ${new_att_value}
        Mcs.Set ATT Value For Four Output Ports
        ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${new_att_value}
        ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}    end_input_port=${32}
        Sleep  2sec
        ${att_value}    Set Variable    ${new_att_value}
   END
   ${att_value}    Set Variable    23
   FOR    ${i}    IN RANGE    10
        ${new_att_value}    evaluate    int(${att_value})+2
        Log To Console    update ATT value to ${new_att_value}
        Mcs.Set ATT Value For Four Output Ports
        ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${new_att_value}
        ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}    end_input_port=${32}
        Sleep  2sec
        ${att_value}    Set Variable    ${new_att_value}
   END
   ${att_value}    Set Variable    20
   FOR    ${i}    IN RANGE    10
        ${new_att_value}    evaluate    int(${att_value})+2
        Log To Console    update ATT value to ${new_att_value}
        Mcs.Set ATT Value For Four Output Ports
        ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${new_att_value}
        ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}    end_input_port=${32}
        Sleep  2sec
        ${att_value}    Set Variable    ${new_att_value}
   END

UPdate All ATT Value FOR RSRP 85 For Branch
  ${att_value}    Set Variable    17
   FOR    ${i}    IN RANGE    10
        ${new_att_value}    evaluate    int(${att_value})+2
        Log To Console    update ATT value to ${new_att_value}
        Mcs.Set ATT Value For Four Output Ports
        ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${new_att_value}
        ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
        Sleep  2sec
        ${att_value}    Set Variable    ${new_att_value}
    END
   ${att_value}    Set Variable    22
   FOR    ${i}    IN RANGE    10
        ${new_att_value}    evaluate    int(${att_value})+2
        Log To Console    update ATT value to ${new_att_value}
        Mcs.Set ATT Value For Four Output Ports
        ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${new_att_value}
        ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}    end_input_port=${32}
        Sleep  2sec
        ${att_value}    Set Variable    ${new_att_value}
   END
   ${att_value}    Set Variable    23
   FOR    ${i}    IN RANGE    10
        ${new_att_value}    evaluate    int(${att_value})+2
        Log To Console    update ATT value to ${new_att_value}
        Mcs.Set ATT Value For Four Output Ports
        ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${new_att_value}
        ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}    end_input_port=${32}
        Sleep  2sec
        ${att_value}    Set Variable    ${new_att_value}
   END
   ${att_value}    Set Variable    23
   FOR    ${i}    IN RANGE    10
        ${new_att_value}    evaluate    int(${att_value})+2
        Log To Console    update ATT value to ${new_att_value}
        Mcs.Set ATT Value For Four Output Ports
        ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${new_att_value}
        ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}    end_input_port=${32}
        Sleep  2sec
        ${att_value}    Set Variable    ${new_att_value}
   END

UPdate All ATT Value For Branch
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=38
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=43
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}    end_input_port=${32}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=44
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}    end_input_port=${32}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=45
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}    end_input_port=${32}


Check startAntIndex In uldata_puschreceivereql1ru
    [Arguments]    ${file_path}    ${subcell_id}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceivereql1ru && 3gpp.rnti != 65535 && 3gpp.rnti != 65521
    ${startAntIndex_values_list}    Get Field Value From PCAP    field_name=UlData_puschReceiveReqGrantL1ru_t.startAntIndex
    ...                                                      filter_expression=${filter_with_subcell}
    ${startAntIndex_values_length}    Get Length    ${startAntIndex_values_list}
    Should Be True    ${startAntIndex_values_length}>${1}    msg=no valid data filter out.please check the bip log.
    @{target_startAntIndex_list}    Create List    0    4    8    12
    sort list    ${target_startAntIndex_list}
    FOR    ${startAntIndex_values}   IN    @{startAntIndex_values_list}
#        ${startAntIndex_values_new}    Evaluate   list(map(int,@{startAntIndex_values}))
        sort list    ${startAntIndex_values}
        Run Keyword And Continue On Failure    Should Be Equal    ${target_startAntIndex_list}    ${startAntIndex_values}
    END

Check antPort In uldata_puschreceivereql1ru
    [Arguments]    ${file_path}    ${subcell_id}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceivereql1ru && 3gpp.rnti != 65535 && 3gpp.rnti != 65521
    ${startAntIndex_values_list}    Get Field Value From PCAP    field_name=UlData_puschReceiveReqGrantL1ru_t.antPort
    ...                                                      filter_expression=${filter_with_subcell}
    ${startAntIndex_values_length}    Get Length    ${startAntIndex_values_list}
    Should Be True    ${startAntIndex_values_length}>${1}    msg=no valid data filter out.please check the bip log.
#    @{target_antPort_list}    Create List    32768    16384    8192    4096
    @{target_antPort_list}    Create List    4096    8192    16384    32768
    sort list    ${target_antPort_list}
    FOR    ${antPort_values}   IN    @{startAntIndex_values_list}
#         ${antPort_values_new}    Evaluate   list(map(int,@{antPort_values}))
        sort list    ${antPort_values}
        Run Keyword And Continue On Failure    Should Be Equal    ${target_antPort_list}    ${antPort_values}
    END

Check MUGroup Paried Status Via TTITrace
    [Documentation]   Auther:xiaoxia.hao@nokia-sbell.com
    [Arguments]     ${ttitrace_filt_path}
    ...             ${group_paird_percent_exp}=0.1
    calculate_ul_ulmugroup_status     file_path=${ttitrace_filt_path}
    ...                                   group_paird_percent_exp=${group_paird_percent_exp}

Check DL MUGroup Paried Status Via TTITrace
    [Documentation]   Auther:xiaoxia.hao@nokia-sbell.com
    [Arguments]     ${ttitrace_filt_path}
#    ...             ${group_paird_percent_exp}=0.1
    ${beamType}    ${beamType_value_count}    calculate_dl_beamtype_Counter     file_path=${ttitrace_filt_path}
    ${mupair}    ${muStatus_value_count}    calculate_dl_muStatus_mupair_Counter    file_path=${ttitrace_filt_path}    muStatus_value=ZFMUPAIR
    ${beamType_rate}    evaluate    ${beamType}/${beamType_value_count}
    ${mupair_rate}    evaluate    ${mupair}/${muStatus_value_count}
    run keyword and continue on failure    Should Be True    ${beamType_rate}>0.98
    run keyword and continue on failure    Should Be True    ${mupair_rate}>0.98

Update_Param_For_CB008235
    [Documentation]     Auther:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${cell_index}=1    ${update_value}=10    ${qrxlevmin_value}=-40    ${ulMuMimoCorrThd_value}=80
    ...            ${ulMuMimoCorrThd2_value}=80    ${skip_parameter_relation_errors}=True
    Log To Console    \n***start to mmdify for CB008235***
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${update_param}    catenate    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}','parameter':'actRtwpMeasurement','value':'false'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'nrCellType','value':'16DL8UL'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actUlMuMimo','value':'true'},
#    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actAdaptiveReTxResMcsEnh','value':'true'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'qRxLevMin','value':'${qrxlevmin_value}'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actAdaptiveReTxResMcs','value':'false'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actAdaptiveReTxResMcsEnh','value':'false'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actEnhancedPDSCHSchSplSlot','value':'false'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actNrRim','value':'disabled'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actUlClosedLoopPwrCtrl','value':'disabled'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'puschMappingType','value':'TypeB'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0',
    ...                 'parameter':'actUlMuMimoGroupPairing','value':'false'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0',
    ...                 'parameter':'ulMaxMuMimoLayer','value':'8'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0',
    ...                 'parameter':'ulMuMimoCorrThd','value':'${ulMuMimoCorrThd_value}'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0',
    ...                 'parameter':'ulMuMimoCorrThd2','value':'${ulMuMimoCorrThd2_value}'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0',
    ...                 'parameter':'ulMuMimoLinkAdaptionSwitch','value':'MCS compensation'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0',
    ...                 'parameter':'ulSinrDiffThreshold','value':'${update_value}'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0',
    ...                 'parameter':'actUlMuMimoTapering','value':'true'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...                 'parameter':'ulDataDmrsFdm','value':[{'actUlDataDmrsFdm':'false'}]},
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    ...                                          skip_parameter_relation_errors=${skip_parameter_relation_errors}

Update_Param_For_CB013394
    [Arguments]    ${cell_index}=1    ${skip_parameter_relation_errors}=True
    Log To Console    \n***start to mmdify for CB013394***
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${update_param}    catenate
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actDlMuMimoEnh','value':'true'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actDlSrsSubbandBm','value':'true'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actMulSrsInSplSlot','value':'true'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actNrRim','value':'disabled'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'mulSrsPositions','value':'twoSrsPos1'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'srsForBeamMgmt',
    ...                                                                                              'value':[{'srsPowerThresholdForDlBm':'-1270',
    ...                                                                                                       'srsTypeAllocForDlBm':'codebook'}]},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRDLMUMIMO-1',
    ...                 'parameter':'actDlMuPairingGroup','value':'true'},
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    ...                                          skip_parameter_relation_errors=${skip_parameter_relation_errors}

Update_Param_For_CB009527
    [Arguments]    ${cell_index}=1    ${skip_parameter_relation_errors}=True
    Log To Console    \n***start to mmdify for CB009527***
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${update_param}    catenate
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actDlMuMimoEnh','value':'true'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actDlSrsSubbandBm','value':'true'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actMulSrsInSplSlot','value':'true'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actNrRim','value':'disabled'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'mulSrsPositions','value':'twoSrsPos1'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'srsForBeamMgmt',
    ...                                                                                              'value':[{'srsPowerThresholdForDlBm':'-1270',
    ...                                                                                                       'srsTypeAllocForDlBm':'codebook'}]},
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    ...                                          skip_parameter_relation_errors=${skip_parameter_relation_errors}

Wait Until Next Counter Update
    [Arguments]    ${counter_period}=5    ${asik_alais}=ASIK Master
    [Documentation]    Author:xiaoxia.hao@nokia.com
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${asik_alais}
    ${period}    Evaluate    ${counter_period}*60
    ${current}     csn.execute    command=date +%s    connection=${asik_alais}
    ${current}    Get Line    ${current}    -1
    ${sleep}    Evaluate    ${period}+${period}-${current}+int(${current}/${period})*${period}
    Sleep    ${sleep}
    sleep    30

Cycle Fallback ATT Value
    [Arguments]    ${att_value}=40    ${target_att_Value}=5
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${att_value}
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Sleep    5sec
    FOR    ${i}    IN RANGE    1    10
        ${new_att_value}    evaluate    int(${att_value})-5
        Log To Console    update ATT value to ${new_att_value}
        Mcs.Set ATT Value For Four Output Ports
        ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${new_att_value}
        ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
        Sleep  5sec
        ${att_value}    Set Variable    ${new_att_value}
        exit for loop if    int(${new_att_value})<${target_att_Value}
    END

Update MCS Phase For 8SA
    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-40}    second_beam_horizontal_angle=${-50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${40}    second_beam_horizontal_angle=${50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${-13}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set Phases According To Angles For Two Output Groups
    ...    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${15}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}

Start L3 Call On Second Cell
    [Arguments]    ${list_cell_ids}=4    ${expect_sceond_pci}=731
    Restore All ATT Value
    sleep    30sec
    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File    ues_index=${${0},${1},${2},${3}}
    DingLi_Client.Start Data Transfer    ues_index=${${0},${1},${2},${3}}   ul_throughput=15000    dl_throughput=400M
    ...                                  refine_ue_port=56660
    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File    ues_index=${${4},${5}}
    ...                                       list_cell_ids=${list_cell_ids}    expect_sceond_pci=${expect_sceond_pci}
    #--- low ul traffic --- #
    DingLi_Client.Start Data Transfer    ues_index=${${4},${5}}    ul_throughput=250000    dl_throughput=800M
    sleep    30sec
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=400
    ...                                                                expect_dl_tput=1450
    ...                                                                cellid=${list_cell_ids}
    ...                                                                target_avg_percent=0.95
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF

BTS Counters List For 8235 On Trunk
    ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ${counters}    Catenate
    ...    {'M55308C36012': '${dis_name_dir}/NRCELL-1/NCELA/PRB_UL_MU_MIMO_8LAYER'},
    ...    {'M55330C00051': '${dis_name_dir}/NRCELL-1/NRBF2/NUM_SCHD_UE_ZF_MU_PAIR'},
    ...    {'M55330C00052': '${dis_name_dir}/NRCELL-1/NRBF2/NUM_SCHD_PRB_ZF_MU_PAIR'}
    ${counter_info_dict_list}    Evaluate    [${counters}]
    [Return]    ${counter_info_dict_list}

BTS Counters List For 8235 On Branch
    ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ${counters}    Catenate
    ...    {'M55308C36012': '${dis_name_dir}/NRCELL-1/NCELA/PRB_UL_MU_MIMO_8LAYER'},
    ${counter_info_dict_list}    Evaluate    [${counters}]
    [Return]    ${counter_info_dict_list}

Get And Check counters latest value For 8235
    [Arguments]    ${counter_info_dict_list}    ${BTS_or_TRS}=BTS    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=0
    ${counters_info}    coam.get_counters_info    connection=${connection}
    ${laster_Counters_infor}    create dictionary
    ${counter_groups} =    Get From Dictionary    ${counters_info}    ${BTS_or_TRS}
    FOR    ${counter_infor}    IN     @{counter_info_dict_list}
#        ${counter_groups}    Get From Dictionary    ${counter_groups}    ${counter_infor}
        ${counter_name}    Get Dictionary Keys    ${counter_infor}
        ${counter_group_keys} =    Split String    ${counter_infor}[${counter_name}[0]]    /
        ${counter_groups_length} =    Get Length    ${counter_group_keys}
        Remove From List    ${counter_group_keys}    ${counter_groups_length-1}
        ${latest_value}    Get counter latest value For 8235    counter_id=${counter_name}[0]    counter_group_keys=${counter_group_keys}
        ...                                                                      counter_groups=${counter_groups}
        Set To Dictionary    ${laster_Counters_infor}    ${counter_name}[0]=${latest_value}
    END
    log    ${laster_Counters_infor}
    Check counter latest value For 8235    laster_Counters_infor=${laster_Counters_infor}

Get counter latest value For 8235
    [Arguments]    ${counter_id}    ${counter_group_keys}    ${counter_groups}
    FOR    ${group}    IN     @{counter_group_keys}
        ${counter_groups} =    Get From Dictionary    ${counter_groups}    ${group}
    END
    ${counter_values} =    Get From Dictionary    ${counter_groups}    ${counter_id}
    ${key_list} =     Get Dictionary Keys    ${counter_values}
    Reverse List    ${key_list}
    ${latest_value} =    Get From Dictionary    ${counter_values}    ${key_list[0]}
    [Return]    ${latest_value}

Check counter latest value For 8235
    [Arguments]    ${laster_Counters_infor}
    ${M55308C36012_value} =    Get From Dictionary    ${laster_Counters_infor}    M55308C36012
    ${M55308C36012_value}    convert to integer     ${M55308C36012_value}
    should be true    ${M55308C36012_value}>1
    return from keyword if    '${stream}'!='SBTS00' or '${stream}'!='SBTS26R2'
    ${M55330C00051_value} =    Get From Dictionary    ${laster_Counters_infor}    M55330C00051
    ${M55330C00051_value}    convert to integer     ${M55330C00051_value}
    should be true    ${M55330C00051_value}>1830000
    ${M55330C00052_value} =    Get From Dictionary    ${laster_Counters_infor}    M55330C00052
    ${M55330C00018_value}    convert to integer     ${M55330C00052_value}
    should be true    ${M55330C00052_value}>115000000

Update The Second RF ATT Value
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=28
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    ...    begin_input_port=${1}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${65}    second_beam_horizontal_angle=${70}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=28
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${-55}    second_beam_horizontal_angle=${-50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    begin_input_port=${17}    end_input_port=${32}

Restore The Second RF ATT Value
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${0}    second_beam_horizontal_angle=${0}    vertical_angle=${0}
    ...    vertical_distance=${2}    begin_input_port=${17}    end_input_port=${32}

Update The First RF ATT Value For 2 interferers
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${55}    second_beam_horizontal_angle=${45}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}

BTS Counters List For 10708_L On Trunk
    ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ${counters}    Catenate
    ...    {'M55196C00010': '${dis_name_dir}/NRCELL-1/NBFC/ACC_UE_CONF_SB_BF_TAS_SRS'},
    ...    {'M55196C00012': '${dis_name_dir}/NRCELL-1/NBFC/MAX_UE_CONF_SB_BF_TAS_SRS'},
    ...    {'M55330C00017': '${dis_name_dir}/NRCELL-1/NRBF2/SLOT_UE_SCHD_SB_BF'},
    ...    {'M55330C00018': '${dis_name_dir}/NRCELL-1/NRBF2/NUM_UE_SCHD_SB_BF'},
    ...    {'M55330C00020': '${dis_name_dir}/NRCELL-1/NRBF2/MAX_PDSCH_PRB_SCHD_SB_BF'},
    ...    {'M55330C00021': '${dis_name_dir}/NRCELL-1/NRBF2/ACC_PDSCH_PRB_SCHD_SB_BF'},
    ...    {'M55330C00042': '${dis_name_dir}/NRCELL-1/NRBF2/NUM_SB_BF_UE_SCHD_LEG_BF'},
    ${counter_info_dict_list}    Evaluate    [${counters}]
    [Return]    ${counter_info_dict_list}

Get And Check counters latest value For 10708_L
    [Arguments]    ${counter_info_dict_list}    ${BTS_or_TRS}=BTS    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=0
    ${counters_info}    coam.get_counters_info    connection=${connection}
    ${laster_Counters_infor}    create dictionary
    ${counter_groups} =    Get From Dictionary    ${counters_info}    ${BTS_or_TRS}
    FOR    ${counter_infor}    IN     @{counter_info_dict_list}
#        ${counter_groups}    Get From Dictionary    ${counter_groups}    ${counter_infor}
        ${counter_name}    Get Dictionary Keys    ${counter_infor}
        ${counter_group_keys} =    Split String    ${counter_infor}[${counter_name}[0]]    /
        ${counter_groups_length} =    Get Length    ${counter_group_keys}
        Remove From List    ${counter_group_keys}    ${counter_groups_length-1}
        ${latest_value}    Get counter latest value For 8235    counter_id=${counter_name}[0]    counter_group_keys=${counter_group_keys}
        ...                                                                      counter_groups=${counter_groups}
        Set To Dictionary    ${laster_Counters_infor}    ${counter_name}[0]=${latest_value}
    END
    log    ${laster_Counters_infor}
    Check counter latest value For 10708_L    laster_Counters_infor=${laster_Counters_infor}

Check counter latest value For 10708_L
    [Arguments]    ${laster_Counters_infor}
    ${M55196C00010_value} =    Get From Dictionary    ${laster_Counters_infor}    M55196C00010
    ${M55196C00010_value}    convert to integer     ${M55196C00010_value}
    Run Keyword And Continue On Failure    should be true    ${M55196C00010_value}==300
    ${M55196C00012_value} =    Get From Dictionary    ${laster_Counters_infor}    M55196C00012
    ${M55196C00012_value}    convert to integer     ${M55196C00012_value}
    Run Keyword And Continue On Failure    should be true    ${M55196C00012_value}==1
    ${M55330C00017_value} =    Get From Dictionary    ${laster_Counters_infor}    M55330C00017
    ${M55330C00017_value}    convert to integer     ${M55330C00017_value}
    Run Keyword And Continue On Failure    should be true    ${M55330C00017_value}>450000
    ${M55330C00018_value} =    Get From Dictionary    ${laster_Counters_infor}    M55330C00018
    ${M55330C00018_value}    convert to integer     ${M55330C00018_value}
    Run Keyword And Continue On Failure    should be true    ${M55330C00018_value}==${M55330C00017_value}
    ${M55330C00020_value} =    Get From Dictionary    ${laster_Counters_infor}    M55330C00020
    ${M55330C00020_value}    convert to integer     ${M55330C00020_value}
    Run Keyword And Continue On Failure    should be true    ${M55330C00020_value}==273
    ${M55330C00021_value} =    Get From Dictionary    ${laster_Counters_infor}    M55330C00021
    ${M55330C00021_value}    convert to integer     ${M55330C00021_value}
    Run Keyword And Continue On Failure    should be true    ${M55330C00021_value}>120000000
    ${M55330C00042_value} =    Get From Dictionary    ${laster_Counters_infor}    M55330C00042
    ${M55330C00042_value}    convert to integer     ${M55330C00042_value}
    Run Keyword And Continue On Failure    should be true    ${M55330C00042_value}<=5

Check DL beamType Status Via TTITrace
    [Documentation]   Auther:xiaoxia.hao@nokia-sbell.com
    [Arguments]     ${ttitrace_filt_path}    ${beamType_value}=SUBBAND
    ${beamType}    ${beamType_value_count}    calculate_dl_beamtype_Counter     file_path=${ttitrace_filt_path}    beamType_value=${beamType_value}
    ${beamType_rate}    evaluate    ${beamType}/${beamType_value_count}
    run keyword and continue on failure    Should Be True    ${beamType_rate}>0.98

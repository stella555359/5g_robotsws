*** Settings ***
Documentation    Auther:xiaoxia.hao@nokia-sbell.com

Library    BuiltIn
Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem
Library    taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library    taf.config.scf    WITH NAME    scf
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/fiberswitch_common.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot
Resource    5GC000702_M_case_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/UEs/MTK_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/UEs/Spark_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Variables   5GC000702_variables.py

*** Variables ***
${BTS_ID}    ${tl.gnbs[0].instance_id}
&{fault_6450}    faultId=${6450}
&{fault_10}    faultId=${10}
&{fault_1901}    faultId=${1901}
&{fault_23}    faultId=${23}
&{fault_4681}    faultId=${4681}
&{fault_16}    faultId=${16}
&{fault_4298}    faultId=${4298}
&{fault_4547}    faultId=${4547}
&{fault_7312}    faultId=${7312}
&{fault_7313}    faultId=${7313}
@{FAULT_ID_LIST}   &{fault_6450}    &{fault_4681}
@{HISTORY_FAULT_ID_LIST}    &{fault_10}    &{fault_1901}    &{fault_23}
@{ALLOWED_HISTORY_FAULT_IN_UTE}    &{fault_23}
${TS_LOG_PATH_BASE}   ${OUTPUT DIR}
@{SWCONFIG_PARA_DLRANK_4_1Pol}    0x580195=0
@{invalid_ru1_fiber_port}    2.3.5    2.3.6
@{invalid_ru2_fiber_port}    5.4.7    5.4.8

*** Keywords ***
Suite Setup For RFS On UTE Cloud
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${is_x2_check_from_gnb_needed}=${True}
    Uplaod Default Swconfig File
    run keyword and ignore error    CI_interface.Common Suite Setup
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    Set Suite Variable    ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    Upgrade Enb For RFS
    Power Reset eNB After gNB Upgrade for RFS
    Perform gNB Restart And Check on air via rest api
    COAM Wait for gnb ready and cell setup    timeout=30 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    ${gnb_status_by_sommon_scf}    Run Keyword And Return Status
    ...                                                          Wait until keyword succeeds    30 min    20 sec   verify all cells should be onair
    Set Suite Variable    ${gnb_status_by_sommon_scf}
    robot_common_operations.Common Suite Setup
    Generate Suite Log Path
    Connect to gnb coam via ssl
#    ${Active_SW_version}    Get Active SW Version
#    Set Suite Variable    ${Active_SW_version}
#    ${stream}    get stream from version    ${Active_SW_version}
#    set suite variable      ${stream}
#    Upgrade Enb For RFS
    Get gNb Cu Type Value
    @{ALLOWED_FAULT}    Combine Lists    ${ALLOWED_FAULT}    ${FAULT_ID_LIST}
    Set Suite Variable    ${ALLOWED_FAULT}
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    Run Keyword And Ignore Error    Clear Temp File Of ELT For MTK

Uplaod Default Swconfig File
    [Documentation]    Auther:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${ASIK_MASTER_ALIAS}=ASIK Master
    Cloud DU connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    Get SCF File Path
    swconf.Upload swConfig file to asik and crasign    localFilePath=${scf_full_path}/swconfig.txt    asik_alias=ASIK Master
    csn.disconnect    connection=${ASIK_MASTER_ALIAS}

702 Suite Setup For UTE
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${is_x2_check_from_gnb_needed}=${True}    ${is_reset_all_RF}=${False}
    ...             ${is_need_upload_swconfig_file}=${True}
    run keyword if    ${is_need_upload_swconfig_file}    Uplaod Default Swconfig File
    run keyword and ignore error    Check And Power on RUs
    robot_common_operations.Common Suite Setup
    ${gnb_status_by_sommon_scf}    Run Keyword And Return Status    CI_interface.Common Suite Setup
    run keyword if    not ${gnb_status_by_sommon_scf}    run keywords
    ...    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl    AND
    ...    Run Keyword And Ignore Error    COAM Save snapshot via rest api    log_path=${OUTPUT DIR}/Case_Logs    timeout=${600}
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    Set Suite Variable    ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    Set Suite Variable    ${stream}
    run keyword if  not ${gnb_status_by_sommon_scf}   run keywords    Power Reset All RF    is_reset_all_RF=${is_reset_all_RF}    AND
    ...                                                               Upgrade RF Version For Gnb
    Perform gNB Restart And Check on air via rest api    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    Set Suite Variable    ${gnb_status_by_sommon_scf}
    Generate Suite Log Path
#    Set Suite Variable    ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Get gNb Cu Type Value
    @{ALLOWED_FAULT}    Combine Lists    ${ALLOWED_FAULT}    ${FAULT_ID_LIST}
    Set Suite Variable    ${ALLOWED_FAULT}
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    Run Keyword And Ignore Error    Clear Temp File Of ELT For MTK

702 Suite TearDown For UTE
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${scf_file_name}=${None}    ${is_pdl_checking_needed}=${False}    ${is_need_enable_uboot}=${False}
    robot_common_operations.Common Suite Teardown
    run keyword if    "${scf_file_name}" != "${None}" and 'SBTS00' in '${stream}'
    ...    Recommission With Backup SCF File And Wait Gnb On Air
    ...                                                                 scf_file_name=${scf_file_name}
    ...                                                                 is_pdl_checking_needed=${is_pdl_checking_needed}
    run keyword if    ${is_need_enable_uboot}    Set Uboot For Netboot
    Run Keyword And Ignore Error    COAM Teardown gnb connections

702 Case SetUp For UTE
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${scf_file_name}=${None}    ${is_pdl_checking_needed}=${False}    ${asik_alais}=ASIK Master    ${hw_slot}=${1}
    ...            ${update_param_name}=${None}    ${swconfig_modify}=${None}    ${ParameterToDelete}=${None}    ${ParamterToModify}=${None}
    ...            ${ListToAdd}=${None}    ${is_need_check_rf_version}=${False}
    robot_common_operations.Common Case Setup
    Generate Test Case Log Path
    ${time_stamp}    Get Current Date    result_format=%Y%m%d%H%M%S
    Set Test Variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    Create Directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    ${old_scf_file_name}    Get Variable Value    ${old_scf_file_name}
    Get SCF File Path
    ${scf_file_full_name}    set variable    ${scf_file_name}.xml
    ${scf_file}    Join Path    ${scf_full_path}    ${scf_file_full_name}
    ${modified_scf_file_path}    run keyword if    "${ParamterToModify}" != "${None}"    Modify and Save SCF    scf_file_name=${scf_file_name}
    ...                                                                                         ParameterToDelete=${ParameterToDelete}
    ...                                                                                         ListToAdd=${ListToAdd}
    ...                                                                                         ParamterToModify=${ParamterToModify}
    ...                                                                                         scf_path=${scf_file}
    run keyword if    "${swconfig_modify}" != "${None}"    Backup and Modify swconfig file    is_called_in_test_case_level=${True}
    ...                                                       swconfig_modify=${swconfig_modify}
    run keyword if    "${update_param_name}" != "${None}" or "${ParamterToModify}" != "${None}"
    ...    Update Framestructure And CHBW    scf_file_name=${scf_file_name}
    ...                                                                                        scf_file_path=${modified_scf_file_path}
    ...                                                                                       update_param_name=${update_param_name}
    ...    ELSE IF    "${scf_file_name}" != "${old_scf_file_name}" and "${scf_file_name}" != "${None}" and "${update_param_name}" == "${None}"
    ...    Recommission With Backup SCF File And Wait Gnb On Air
    ...                                                                 scf_file_name=${scf_file_name}
    ...                                                                 is_pdl_checking_needed=${is_pdl_checking_needed}
    ...                                                                 is_need_check_rf_version=${is_need_check_rf_version}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${asik_alais}
    Connect to Capacity Unit Master    hw_slot=${hw_slot}
    Connect to Capacity Unit Slave    hw_slot=${hw_slot}

702 Case TearDown For UTE
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${case_contain_special_operation}=${False}    ${is_recover_env}=${False}    ${is_recover_swconfig}=${False}    ${timeout}=900
    ...            ${connection}=GNB_OAM    ${is_x2_check_from_gnb_needed}=${True}    ${ASIK_MASTER_ALIAS}=ASIK Master
#    robot_common_operations.Common Case Teardown
    run keyword and ignore error    COAM Teardown gnb connections
    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    @{ALLOWED_FAULT}    Combine Lists    ${ALLOWED_FAULT}    ${FAULT_ID_LIST}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Run Keyword And Ignore Error    Unexpect History Alarm Should Not Exist    allowed_faults=${ALLOWED_HISTORY_FAULT}
    run keyword if test failed    Run Keyword And Ignore Error
    ...                                                        COAM Save snapshot via rest api    connection=${connection}    timeout=${timeout}
    robot_common_operations.Common Case Teardown
    run keyword if    ${is_recover_env}    run keywords
    ...               run keyword if    ${is_recover_swconfig}    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master    AND
    ...               COAM Commission with scf file    scf_file_path=${Golden_SCF_Path}    timeout=600    AND
    ...               COAM Wait For Gnb Ready And Cell Setup    timeout=25 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}    AND
    ...               Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error   csn.disconnect    connection=RU
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Slave
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master
    run keyword and ignore error   COAM Teardown gnb connections
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
#   Run Keyword Unless    ${gnb_status_by_sommon_scf}    Run Keyword And Continue On Failure    Fail    gNB setup fail by golden scf
#    set suite variable    ${gnb_status_by_sommon_scf}    ${True}
    run keyword if    not ${case_contain_special_operation}    CI_interface.Common Case Teardown

Check And Power on RUs
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    ${ru_numbers}    get length    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    log to console    ru_numbers: ${ru_numbers}
    FOR    ${index}    IN RANGE    0    ${ru_numbers}
        ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.__class__.__name__}
        ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.addr}
        ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.port_no}
        ${ru_index}    evaluate    ${index}+1
        log to console    for ru ${ru_index}, model is ${model}, pb ip is ${address}, pb port is ${port}
        pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_${ru_index}
        ${port_status}    pdu.Get Port Status    port=${port}    pdu_device=pdu_ru_${ru_index}
        log to console    port status of ru ${ru_index} is ${port_status}
        run keyword if    '${port_status}'=='off'    pdu.power on    port=${port}    pdu_device=pdu_ru_${ru_index}
        sleep    5s
    END

6915 Case TearDown For UTE
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${case_contain_special_operation}=${False}    ${swconfig_modify}=${None}
    run keyword and ignore error    COAM Teardown gnb connections
    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    @{ALLOWED_FAULT}    Combine Lists    ${ALLOWED_FAULT}    ${FAULT_ID_LIST}
    run keyword and continue on failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    run keyword if    ${case_contain_special_operation}
    ...              Run Keyword And Ignore Error   Unexpect History Alarm Should Not Exist    allowed_faults=${ALLOWED_HISTORY_FAULT}
    ...              ELSE
    ...              run keyword and continue on failure    Unexpect History Alarm Should Not Exist    allowed_faults=${ALLOWED_HISTORY_FAULT}
    run keyword if    ${swconfig_modify}!=${None}    run keywords
    ...    Connect to Common Unit Master    AND
    ...    Run Keyword And Ignore Error    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master    AND
    ...    Run Keyword And Ignore Error    COAM gNB Reset site    AND
    ...    Run Keyword And Ignore Error    sleep    60s
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error   csn.disconnect    connection=RU
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Slave
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master
    run keyword and ignore error   COAM Teardown gnb connections
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    run keyword if  not ${gnb_status_by_sommon_scf}    Run Keyword And Continue On Failure    Fail    gNB setup fail by golden scf
    set suite variable    ${gnb_status_by_sommon_scf}    ${True}
    run keyword if    not ${case_contain_special_operation}    CI_interface.Common Case Teardown

Get SCF File Path
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    ${scf_full_path}    Get Variable Value    ${scf_full_path}
    return from keyword if    '${scf_full_path}' != 'None'
    ${SCF_Path}    ${result}    Split String From Right  ${CURDIR}    testsuite     1
    ${testline_name}  Get Variable Value    ${testline_name}
    ${TL_NAME}   set variable if    '${testline_name}' == 'None' or '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME}[0]
    set suite variable    ${scf_full_path}    ${SCF_PATH}commissionings/HGZ/${testlinename}

Recommission With Backup SCF File
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${backup_scf_file}    ${is_pdl_checking_needed}=${True}    ${timeout}=900    ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status     COAM Commission with scf file
    ...                                            scf_file_path=${backup_scf_file}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    ...                                            is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If  ${status}==${False}    Fail    recovery with backup scf file failed.

Update Framestructure And CHBW
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${scf_file_name}=${None}
    ...            ${scf_file_path}=${None}
    ...            ${is_dynamic_pdcch_update}=${True}
    ...            ${is_case_level_update_params_exist}=${True}
    ...            ${is_pdl_checking_needed}=${True}
    ...            ${update_param_name}=${None}
    Get SCF File Path
    ${scf_file_name}    set variable if    "${scf_file_name}"=="${None}"    SCF_${stream}.xml    ${scf_file_name}.xml
    ${scf_file_path}    run keyword if    "${scf_file_path}"=="${None}"    Join Path    ${scf_full_path}    ${scf_file_name}    ELSE
    ...                 Set Variable    ${scf_file_path}
    case common setup    update_param_name=${update_param_name}    scf_file_path=${scf_file_path}
    ...                  is_dynamic_pdcch_update=${is_dynamic_pdcch_update}
    ...                  is_case_level_update_params_exist=${is_case_level_update_params_exist}
    ...                  is_pdl_checking_needed=${is_pdl_checking_needed}
    Set Suite Variable    ${old_scf_file_name}    ${scf_file_name}
    [Teardown]  run keyword and ignore error   COAM Teardown gnb connections

Recommission With Backup SCF File And Wait Gnb On Air
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${scf_file_name}    ${is_pdl_checking_needed}=${True}    ${asik_alais}=ASIK Master    ${is_x2_check_from_gnb_needed}=${True}
    ...            ${is_need_check_rf_version}=${False}
    Get SCF File Path
#    Get gNB Stream Version
#    ${scf_file_full_name}    set variable    ${scf_file_name}_${stream}.xml
    ${scf_file_full_name}    set variable    ${scf_file_name}.xml
    ${scf_file}    Join Path    ${scf_full_path}    ${scf_file_full_name}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${asik_alais}
    Recommission With Backup SCF File    backup_scf_file=${scf_file}
    ...                                                   is_pdl_checking_needed=${is_pdl_checking_needed}
    run keyword if    ${is_need_check_rf_version}    Upgrade RF Version For Gnb
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Set Suite Variable    ${old_scf_file_name}    ${scf_file_name}
    [Teardown]  run keyword and ignore error   COAM Teardown gnb connections

Get GSCN Value
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${nrcell_id}=NRCELL-1    ${connection}=GNB_OAM
    ${gscn}    coam_parameter.get_single_value_from_scf_file    parameter=gscn    dist_name=NRBTS-${nr_bts_id}/${nrcell_id}
    ...                                                               connection=${connection}
    ${gscn_length}    Get Length    ${gscn}
    ${gscn}    run keyword if    "${gscn_length}"=="0"    coam_parameter.get_single_value_from_scf_file    parameter=gscnOrSsPbchArfcn
    ...                                                                                                    dist_name=NRBTS-${nr_bts_id}/${nrcell_id}
    ...                                                                                                    connection=${connection}
    ...    ELSE
    ...    set variable    ${gscn}
    ${gscn_value}    Evaluate    ${gscn}+${1}
    ${gscn_value}    Convert To String    ${gscn_value}
    [Return]  ${gscn_value}

Modify Slot Ratio Para
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]   ${slotRatio}=1/4    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${connection}=GNB_OAM
    &{slotRatio_value}    Create Dictionary    ulDlDataSlotRatio=${slotRatio}
    ${nrcell_list}    Get Cell ID list via Admin CLI    connection=${connection}
    ${modify_param}    Create List
    FOR    ${nrcell}    IN    @{nrcell_list}
        &{slotRatio_param}    Evaluate
        ...                  {'dist_name': 'NRBTS-${nr_bts_id}/${nrcell}', 'parameter': 'tddFrameStructure','value':[&{slotRatio_value}]}
        Append To List    ${modify_param}    ${slotRatio_param}
    END
    [Return]    @{modify_param}

Modify NR Cell Type
    [Arguments]   ${nrcelltype}=4DL2UL    ${actTddPrePooling}=false    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${connection}=GNB_OAM
    ${cell_num}    RRH_common_keyword.COAM Get GNB CELL Number    connection=${connection}
    &{actTddPrePooling_value}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}    parameter=actTddPrePooling    value=${actTddPrePooling}
    ${modify_param}    Create List    ${actTddPrePooling_value}
    ${nrcell_list}    Get Cell ID list via Admin CLI    connection=${connection}
    FOR    ${nrcell}    IN    @{nrcell_list}
        &{nrcelltype_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}/${nrcell}    parameter=nrCellType    value=${nrcelltype}
        Append To List    ${modify_param}    ${nrcelltype_param}
    END
    [Return]    @{modify_param}

Update CHBW And Wait Gnb On Air
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${bandwidth}=100MHz    ${slotRatio}=1/4    ${is_update_solt_ratio}=${False}    ${is_x2_check_from_gnb_needed}=${True}
    ${gscn_value}    Run keyword If  "${bandwidth}" =="20MHz"    Get GSCN Value  ELSE    set variable    none
    ${chbw_param}    Modify All Chbw Para    bandwidth=${bandwidth}    gscn=${gscn_value}
    ${slot_ratio_param}    Run Keyword If  ${is_update_solt_ratio}    Modify Slot Ratio Para    slotRatio=${slotRatio}
    ${modify_param_list}    Run Keyword If  ${is_update_solt_ratio}    combine lists    ${chbw_param}     ${slot_ratio_param}
    ...                                      ELSE    Set Variable    ${chbw_param}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param_list}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    [Teardown]  run keyword and ignore error   COAM Teardown gnb connections

Start L3 Call And Verify Throughput
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]   ${ul_data_transfer}
    ...           ${dl_data_transfer}
    ...           ${expect_ul_tput}
    ...           ${expect_dl_tput}
    ...           ${expect_ul_bler}=0.03
    ...           ${duration}=240
    ...           ${download_dir}=${TS_CASE_LOG_PATH}
    ...           ${hw_slot}=${1}
    ...           ${is_ulbler_calcu}=${False}
    ...           ${reset_sol}=${none}
    ...           ${connection}=ASIK Master
    ...           ${ue_index}=${0}
    ...           ${4G_check}=True
    ...           ${is_wireshark_log_capture}=${True}
    ...           ${ignore_time}=1min
    ...           ${target_avg_percent}=1.0
    ...           ${actCarrierAggregation}=${False}
    ...           ${list_all_cell_ids}=${False}
    ...           ${is_do_require_ue}=${True}
    ...           ${cellid}=1
    ...           ${throuput_duration}=900
    ...           ${is_need_stop_traffic}=${True}
    ...           ${min_percent}=0.3
    ...           ${wireshark_log_prefix}=ue_attach
    ...           ${mode}=SA
    ...           ${ue_iperf_path}=/data/local/tmp/iperf
    ...           ${check_source}=aasyslog
    ...           ${dl_process_num}=2
    ${duration}    Convert To Integer    ${duration}
    ${expect_ul_tput}    Convert To Number    ${expect_ul_tput}
    ${expect_dl_tput}    Convert To Number    ${expect_dl_tput}
    ${expect_bler}    Convert To Number    ${expect_ul_bler}
    ${direction_component_list}=  Create List    UL_L2LO    DL_L2LO
    run keyword and ignore error    csn.disconnect    connection=${connection}
    connection_alias_store.Connect to Common Unit Master
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_path_on_testPC}   Run keyword if    '${ue_type}' == 'mtk'    Make_L3_Call_With_MTK_UE
    ...                                                               wireshark_log_prefix=${wireshark_log_prefix}_${attach_timestamp}
    ...                                                               ul_data_transfer=${ul_data_transfer}
    ...                                                               dl_data_transfer=${dl_data_transfer}
    ...                                                               duration=${throuput_duration}
    ...                                                               ue_iperf_path=${ue_iperf_path}
    ...                                                               ue_index=${ue_index}
    ...                                                               is_do_require_ue=${is_do_require_ue}
    ...                                                               dl_process_num=${dl_process_num}
    ...            ELSE IF   '${ue_type}' == 'huawei_sigspark'       Make_L3_Call_With_spark_UE
    ...                                                               wireshark_log_prefix=${wireshark_log_prefix}_${attach_timestamp}
    ...                                                               mode=${mode}
    ...                                                               ul_data_transfer=${ul_data_transfer}
    ...                                                               dl_data_transfer=${dl_data_transfer}
    ...                                                               start_keep_on_duration=${throuput_duration}
    ...                                                               ue_index=${ue_index}
    ...                                                               is_do_require_ue=${is_do_require_ue}
    ...                                                               dl_process_num=${dl_process_num}
    ...             ELSE                Make_L3_Call_With_Power_UE    reset_sol=${reset_sol}
    ...                                                               ue_index=${ue_index}
    ...                                                               4G_check=${4G_check}
    ...                                                               is_wireshark_log_capture=${is_wireshark_log_capture}
    ...                                                               is_do_require_ue=${is_do_require_ue}
    ...                                                               ul_data_transfer=${ul_data_transfer}
    ...                                                               dl_data_transfer=${dl_data_transfer}
    ...                                                               throuput_duration=${throuput_duration}
    ...                                                               dl_process_num=${dl_process_num}
    Check Tput With Power UE    direction_component_list=${direction_component_list}
    ...                         expect_ul_tput=${expect_ul_tput}
    ...                         expect_dl_tput=${expect_dl_tput}
    ...                         expect_ul_bler=${expect_ul_bler}
    ...                         duration=${duration}
    ...                         download_dir=${download_dir}
    ...                         hw_slot=${hw_slot}
    ...                         is_ulbler_calcu=${is_ulbler_calcu}
    ...                         ignore_time=${ignore_time}
    ...                         target_avg_percent=${target_avg_percent}
    ...                         actCarrierAggregation=${actCarrierAggregation}
    ...                         list_all_cell_ids=${list_all_cell_ids}
    ...                         cellid=${cellid}
    ...                         min_percent=${min_percent}
    ...                         check_source=${check_source}
    [Return]     ${wireshark_log_path_on_testPC}
    [Teardown]    run keyword if    ${is_need_stop_traffic}    Run Keyword And Ignore Error    Stop Traffic In Teardown    ue_index=${ue_index}


Make_L3_Call_With_MTK_UE
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${is_do_require_ue}=${True}
    ...            ${wireshark_log_prefix}=ue_attach
    ...            ${ul_data_transfer}=50M
    ...            ${dl_data_transfer}=600M
    ...            ${duration}=1800
    ...            ${ue_index}=${0}
    ...            ${enb_index}=${1}
    ...            ${coam_connection}=GNB_OAM
    ...            ${ue_iperf_path}=/data/local/tmp/iperf
    ...            ${dl_process_num}=2
    Log To Console    \n***start ue attach for MTK ***\n
    ${attach_info}    MTK_common_keywords.Start UE Attach With MTK    wireshark_log_prefix=${wireshark_log_prefix}
    ...                                                               sleep_interval=60 sec
    ...                                                               coam_connection=${coam_connection}
    ...                                                               ue_index=${ue_index}
    ...                                                               enb_index=${enb_index}
    ...                                                               is_do_require_ue=${is_do_require_ue}
#    ${attach_wireshark}    Set Variable If    '${mode}'=='NSA'
#        ...    ${attach_info['enb_wireshark_log_path']}    ${attach_info['cpif_log_path']}
    Log To Console    \n***start ue transfer traffic ***\n
    Start L3 Call Data Transfer With MTK                              ul_data_transfer=${ul_data_transfer}
    ...                                                               dl_data_transfer=${dl_data_transfer}
    ...                                                               duration=${duration}
    ...                                                               ue_iperf_path=${ue_iperf_path}
    ...                                                               ue_index=${ue_index}
    ...                                                               dl_process_num=${dl_process_num}
    ${wireshark_log_path_on_testPC}    Set Variable    ${attach_info['cpif_log_path']}
    [Return]    ${wireshark_log_path_on_testPC}

Start L3 Call Data Transfer With MTK
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...                For senario : 1. without attach  2. multi-PDU
    [Arguments]    ${ue_index}    ${dl_data_transfer}=180M    ${ul_data_transfer}=50M    ${duration}=600
    ...            ${ue_iperf_path}=iperf
    ...             ${dl_process_num}=2
    ${DL_PORT}=    Get Variable Value    ${DL_PORT}    default
    ${UL_PORT}=    Get Variable Value    ${UL_PORT}    default
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${dl_data_value}    get regexp matches    ${dl_data_transfer}    \\d+.*\\d+
    ${dl_data_unit}    get regexp matches    ${dl_data_transfer}    [^\\d+]+
    ${target_dl_data_value}    Evaluate    int(${dl_data_value}[0]/${dl_process_num})
    ${dl_data_transfer}     Set Variable     ${target_dl_data_value}${dl_data_unit}[0]
    Connect to control pc via cygwin    ue_index=${ue_index}
    Get Commercial UE IP with first UE
    Run Keyword And Continue On Failure    Start UL traffic via iperf from andriod UE    ue_index=${ue_index}
    ...                                                                                  ul_time=${DATA_TIME}
    ...                                                                                  ul_port=${UL_PORT}
    ...                                                                                  ul_throughput=${ul_data_transfer}
    ...                                                                                  ul_length=${DATA_LENGTH}
    ...                                                                                  iperf_path=${ue_iperf_path}
    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
    Run Keyword And Continue On Failure    csn.send command
    ...    command=iperf -c ${UE_IP} -u -t ${duration} -i 1 -p ${DL_PORT} -P ${dl_process_num} -f m -b ${dl_data_transfer} -l ${DATA_LENGTH} -T 64 &
    ...    connection=APPserver
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=APPserver

Make_L3_Call_With_Power_UE
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]   ${ul_data_transfer}
    ...           ${dl_data_transfer}
    ...           ${reset_sol}=ue_reboot
    ...           ${ue_index}=${0}
    ...           ${4G_check}=True
    ...           ${is_wireshark_log_capture}=${True}
    ...           ${is_do_require_ue}=${True}
    ...           ${throuput_duration}=600
    ...           ${dl_process_num}=2
    ...           ${filter_ports}=port 38472 or port 38412 or port 38462 or port 36422 or port 38422 or port 29211
    ...           ${interface}=-p -i any ${filter_ports} -s 0
    ${wireshark_log_path_on_testPC}    Start UE Attach With Power UE    reset_sol=${reset_sol}
    ...                                 ue_index=${ue_index}
    ...                                 4G_check=${4G_check}
    ...                                 is_wireshark_log_capture=${is_wireshark_log_capture}
    ...                                 is_do_require_ue=${is_do_require_ue}
    ...                                 interface=${interface}
    ${iperf_type}    Set Variable If    '${ue_type}' == 'samsung'     via_command    via_app
    Run Keyword And Ignore error    Check Iperf Progress on APP server
    Start L3 Call With Power UE    ul_data_transfer=${ul_data_transfer}
    ...                            dl_data_transfer=${dl_data_transfer}
    ...                            ue_index=${ue_index}
    ...                            iperf_type=${iperf_type}
    ...                            duration=${throuput_duration}
    ...                            dl_process_num=${dl_process_num}
    [Return]    ${wireshark_log_path_on_testPC}

Check Iperf Progress on APP server
    Log to console    \nCheck Iperf Progress on APP server
    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    csn.send_command    command=ps -ef | grep iperf     connection=APPserver    timeout=120
    ${output}    csn.read_output    size=1000    connection=APPserver
    ${iperf_tput} =    get regexp matches    ${output}    \\b(\\d+)M\\b
    ${tput_num}=      get length     ${iperf_tput}
    ${total_iperf_traffic}    run keyword if    ${tput_num}
    ...    Get Total Iperf traffic on Appserver    iperf_tput=${iperf_tput}
    ...    ELSE    set variable    0
    Log to console    \nTotal traffic on Appserver is: ${total_iperf_traffic}M!
    [Teardown]    csn.disconnect    connection=APPserver

Get Total Iperf traffic on Appserver
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]       ${iperf_tput}
    @{iperf_value_list}    create list
    FOR  ${item}  IN   @{iperf_tput}
        ${item}    Remove String    ${item}    M
        ${integer_item}    convert to integer    ${item}
        append to list    ${iperf_value_list}    ${integer_item}
    END
    ${total_iperf_traffic} =    evaluate    sum(${iperf_value_list})
    [Return]    ${total_iperf_traffic}

Stop Traffic In Teardown
    [Arguments]     ${ue_index}=${0}
    run keyword if    'mtk' in '${ue_type}'    Run Keyword And Ignore Error    Stop Traffic With MTK UE    ue_index=${ue_index}
    ...    ELSE     Run Keyword And Ignore Error    5GC000702_common_ute.Stop Traffic With Power UE    ue_index=${ue_index}
    run keyword if    '${ue_type}' == 'huawei_sigspark'    Run Keyword And Ignore Error
    ...               Spark_common_keywords.Start UE Detach    ue_index=${ue_index}
    run keyword if    '${ue_type}' == 'huawei_sigspark'    Run Keyword And Ignore Error
    ...               Spark_common_keywords.Spark Stop UE Log    ue_index=${ue_index}
    run keyword if    '${ue_type}' == 'huawei_sigspark'    Run Keyword And Ignore Error     Spark_common_keywords.Stop L3 Traffic
    ...                                              ue_index=${ue_index}    apn_address=${tl.core.pdns[0].apn}
    run keyword if    '${ue_type}' == 'huawei_sigspark'    Run Keyword And Ignore Error     Close the iperf process on APPserver
    ...                port=${tl.ues[${ue_index}].iperf_details.port}

Stop Traffic With Power UE
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    ...                this keyword stop ul/dl traffic and detach ue
    [Arguments]    ${ue_index}=${0}
    FOR    ${direction}    IN    @{data_direction_list}
        ${iperf_port}    Set variable if    '${direction}'=='ul'    ${UL_PORT}    ${DL_PORT}
        run keyword and continue on failure    power_ue.Stop traffic    ue_type=${ue_type}
        ...                                                             direction=${direction}
        ...                                                             dt_name=dt_${direction}
        ...                                                             iperf_port=${iperf_port}
    END
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Stop Traffic With MTK UE
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  this keyword stop ul/dl traffic, never detach mtk ue!
    [Arguments]     ${ue_index}=${0}
    ...             ${iperf_type}=via_app
    ...             ${apn_address}=wap1nokiacom
    ...             ${protocol}=udp
    ${data_direction_list}    create list    ul    dl
    FOR    ${direction}    IN    @{data_direction_list}
        run keyword and continue on failure    power_ue.Stop traffic    ue_type=qct_dx50
        ...                                                             direction=${direction}
        ...                                                             dt_name=dt_${direction}
        ...                                                             protocol=${protocol}
        ...                                                             iperf_port=default
        ...                                                             iperf_type=${iperf_type}
        ...                                                             ue_index=${ue_index}
        ...                                                             apn_address=${apn_address}
    END
    MTK_common_keywords.Do UE Detach    ue_index=${ue_index}
#    Run keyword if    '${ue_type}' == 'mtk'    MTK_common_keywords.Get UE Airmode status and Turnon Airplane Mode    ue_index=${ue_index}

Check PBCH BlockPower From X2 Log
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${wireshark_log_path_on_testPC}    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${nrcell_id}=NRCELL-1
    ...            ${connection}=GNB_OAM
    Convert CPIF Pcap To Pdml    file_path=${wireshark_log_path_on_testPC}    filter=x2ap
    ${ss_pbch_block_power_list}    Get Field Value From Pdml
    ...    filter_expression=x2ap and nr-rrc.ss_PBCH_BlockPower == 9
    ...    xpath=.//nr-rrc.ss_PBCH_BlockPower
    ${ss_pbch_block_power}    get from list    ${ss_pbch_block_power_list}    0
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    ${ss_power_in_scf}    coam_parameter.get_single_value_from_scf_file    parameter=ssPbchBlockPower
    ...                                                                    dist_name=NRBTS-${nr_bts_id}/${nrcell_id}
    ...                                                                    connection=${connection}
    ${expected_ss_power_value}    Evaluate    ${ss_power_in_scf}+${6}
    ${expected_ss_power_value}    Convert To String    ${expected_ss_power_value}
    run keyword and continue on failure     should be equal    ${expected_ss_power_value}    ${ss_pbch_block_power}

#Convert Pcap File To Pdml
#    [Documentation]    author:xiaoxia.hao@nokia-sbell.com
#    ...    Description: convert to pcap file to pdml format, pdml can be used for value check.
#    [Arguments]    ${file_path}
#    cap.load_pcap_file    pcap_file=${file_path}
#    ...    command_template={tshark_path} -Y "x2ap" -r {pcap_file} -X lua_script:{luashark_path} -T pdml
#
#Get Field Value From Pdml
#    [Documentation]    author:xiaoxia.hao@nokia-sbell.com
#    ...    Description: get field value from pdml file.
#    [Arguments]    ${filter_expression}    ${xpath}    ${attribute_name}=show
#    cap.filter_packets_by_expression    filter_expression=${filter_expression}
#    ${field_value}=    cap.get_field_value_by_xpath    xpath=${xpath}    attribute_name=${attribute_name}
#    [Return]    ${field_value}

Modify DL MIMO Mode
    [Documentation]    author:xiaoxia.hao@nokia-sbell.com
    [Arguments]   ${dlmimomode}=4x4 or 4x2 Open Loop Spatial Multiplexing    ${connection}=GNB_OAM
    ${nrcell_list}    Get Cell ID list via Admin CLI    connection=${connection}
    ${modify_param}    Create List
    FOR    ${nrcell}    IN    @{nrcell_list}
        &{dlmimomode_param}  Create Dictionary    dist_name=NRBTS-${nr_bts_id}/${nrcell}    parameter=dlMimoMode    value=${dlmimomode}
        Append To List    ${modify_param}    ${dlmimomode_param}
    END
    [Return]    @{modify_param}

Update MIMO Mode And Wait On Air
    [Documentation]    author:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${bandwidth}=100MHz    ${slotRatio}=1/4    ${nrcelltype}=4DL2UL    ${actTddPrePooling}=false
    ...            ${dlmimomode}=4x4 or 4x2 Open Loop Spatial Multiplexing    ${is_x2_check_from_gnb_needed}=${True}
    ${gscn_value}    Run keyword If  "${bandwidth}" =="20MHz"    Get GSCN Value  ELSE    set variable    none
    ${chbw_param}    Modify All Chbw Para    bandwidth=${bandwidth}    gscn=${gscn_value}
    ${slot_ratio_param}    Modify Slot Ratio Para    slotRatio=${slotRatio}
    ${nr_cell_param}    Modify NR Cell Type    nrcelltype=${nrcelltype}    actTddPrePooling=${actTddPrePooling}
    ${mimo_mode}    Modify DL MIMO Mode    dlmimomode=${dlmimomode}
    ${modify_param_list}    combine lists    ${chbw_param}    ${slot_ratio_param}    ${nr_cell_param}    ${mimo_mode}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param_list}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    [Teardown]  run keyword and ignore error   COAM Teardown gnb connections

###Modify SCF####
Modify SCF and Perform Commission
    [Documentation]   Author: lei.jia@nokia-sbell.com
    ...              Description: This keyword can only support to modify elements parameter and list elements in scf
    ...              Element under MOs, Add if element not present
    ...              Element under List/Items match by index
    [Arguments]      ${scf_file_name}=${None}
    ...               ${scf_path}=/home/ute/SCF
    ...               ${is_pdl_checking_needed}=${True}
    ...               ${ParameterToDelete}='NULL'
    ...               ${MOsToAdd}='NULL'
    ...               ${ParamterToModify}='NULL'
    ...               ${ListParamterToModify}='NULL'
    ...               ${ListToAdd}='NULL'
    ...               ${is_x2_check_from_gnb_needed}=${True}
    ${modified_scf_file_path}    Modify and Save SCF
    ...               scf_file_name=${scf_file_name}
    ...               scf_path=${scf_path}
    ...               ParameterToDelete=${ParameterToDelete}
    ...               MOsToAdd=${MOsToAdd}
    ...               ParamterToModify=${ParamterToModify}
    ...               ListParamterToModify=${ListParamterToModify}
    ...               ListToAdd=${ListToAdd}
    COAM Commission with scf file    scf_file_path=${modified_scf_file_path}    timeout=900
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}
    sleep    60s
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

Modify and Save SCF
    [Documentation]   Author: lei.jia@nokia-sbell.com
    ...              Description: This keyword can only support to modify elements parameter and list elements in scf
    ...              Element under MOs, Add if element not present
    ...              Element under List/Items match by index
    [Arguments]      ${scf_file_name}=${None}
    ...               ${scf_path}=/home/ute/SCF/SCF_SBTS00.xml
    ...               ${ParameterToDelete}='NULL'
    ...               ${MOsToAdd}='NULL'
    ...               ${ParamterToModify}='NULL'
    ...               ${ListParamterToModify}='NULL'
    ...               ${ListToAdd}='NULL'
    ${modified_scf_file_path}    Run keyword if    '${scf_file_name}'=='${None}'    Load Current SCF And Define modified scf path
    ...                          ELSE              Load SCF and Define modified scf path    scf_file_name=${scf_file_name}    scf_path=${scf_path}
    run keyword if  not ${ParameterToDelete}=='NULL'     Delete Objects in SCF    parameters_lists=${ParameterToDelete}
    run keyword if  not ${MOsToAdd}=='NULL'    Add MOs To SCF with Given version
    ...                                                   parameters_lists=${MOsToAdd}
    run keyword if  not ${ParamterToModify}=='NULL'     Add and Modify elements to scf
    ...                                                   parameters_lists=${ParamterToModify}
    run keyword if  not ${ListParamterToModify}=='NULL'     Modify ListElements to scf
    ...                                                       parameters_lists=${ListParamterToModify}
    run keyword if  not ${ListToAdd}=='NULL'     AddLists to SCF    parameters_lists=${ListToAdd}
    scf.Save scf    ${modified_scf_file_path}
    [Return]    ${modified_scf_file_path}

Load SCF and Define modified scf path
    [Documentation]   Author: lei.jia@nokia-sbell.com
    ...              Description: This keyword load scf and return modified scf path for future use.
    [Arguments]      ${scf_file_name}=${None}
    ...               ${scf_path}=/home/ute/SCF/SCF_SBTS00.xml
    Connect to gnb coam via ssl
#    ${scf_file_path}    Join Path    ${scf_path}    ${scf_file_name}
    ${default_scf_file_path}    Copy file    source=${scf_path}    destination=${TS_CASE_LOG_PATH}
    ${scf_file_name}    Fetch from right    ${scf_path}    /
    ${scf_dir_path}    String.Replace string    ${scf_path}    /${scf_file_name}    ${EMPTY}
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}    _${timestamp}_updated.xml
    ${modified_scf_file_path}    set variable    ${TS_CASE_LOG_PATH}/${scf_file_name_after_modify}
    scf.Load scf    ${default_scf_file_path}
    [Return]    ${modified_scf_file_path}

Load Current SCF And Define modified scf path
    ${default_scf_file_path}    COAM Download scf from cluster   scf_dir_path=${TS_CASE_LOG_PATH}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${modified_scf_file_path}    set variable    ${TS_CASE_LOG_PATH}/${timestamp}_updated.xml
    scf.Load scf    ${default_scf_file_path}
    [Return]    ${modified_scf_file_path}

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

Add and Modify elements to scf
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_element_in_object    dist_name=${item}[dist_name]    p_name=${item}[p_name]
        Run Keyword If    '${res}'=='True'     scf.modify_scf_element    value=${item}[value]   &{item}
        ...      ELSE                          scf.add element to scf
        ...                                    value=${item}[value]   dist_name=${item}[dist_name]    p_name=${item}[p_name]
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

Add MOs To SCF with Given version
    [Documentation]   Add Mos for given version, used for add channels
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${item}[version]
    END

#Add MOs To SCF with Given version
#    [Documentation]   Add Mos for given version, used for add channels
#    [Arguments]   ${parameters_lists}
#    ${channel_version}=    scf.get_mo_attribute    MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/CELLMAPPING-1    version
#    FOR    ${item}    IN    @{parameters_lists}
#        scf.add object to scf  class_name=&{item}[class_name]    dist_name=&{item}[dist_name]   version=${channel_version}
#    END
###### Modify SCF End######

Get gNb Cu Type Value
    ${gNbCuType}    Get Variable Value    ${gNbCuType}
    return from keyword if    '${gNbCuType}' != 'None'
#    ${gNbCuType}    Get gNbCuType From SCF
    Set Suite Variable    ${gNbCuType}    SA+NSA

Check AZGX RU Power on DFE
    [Documentation]  Author: haoxiaoxia
    [Arguments]    ${ru_alias}    ${ru_dfe_ip}=192.168.100.3    ${all_attenna_ports}=8
    ${connection}    csn.get connection by alias    alias=${ru_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send     ssh ${ru_dfe_ip}\n
    FOR    ${index}    IN RANGE    ${all_attenna_ports}
        Call Method    ${channel}    send     dapd -stat ${index}\n
        sleep  2s
        ${dfe_power_output}    Call Method    ${channel}    recv    ${65535}
        Log    ${dfe_power_output}
        ${dfe_power_output}    convert to string    ${dfe_power_output}
        ${tx_power_regexp}    set variable    TX.=.(\\d+\.?\\d*)
        ${tx_power_value}    Get Regexp Matches    ${dfe_power_output}    ${tx_power_regexp}    1
        ${status}     Run Keyword And Return Status     Should Be True    ${0}<=${tx_power_value}[0]<=${45}
        ...           msg=${tx_power_value}[0] is out of range.
    END
    [Teardown]  Call Method    ${channel}    close

Check AEHC RU Power on DFE
    [Documentation]  Author: Jia Lei
    [Arguments]    ${ru_alias}    ${ru_dfe_ip}=192.168.100.10    ${ru_dfe_alias}=ru_dfe
    ...    ${all_attenna_ports}=8
    csn.connect to    hostname=${ru_dfe_ip}
    ...               username=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
    ...               password=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
    ...               alias=${ru_dfe_alias}
    ...               proxy=${ru_alias}
    FOR    ${index}    IN RANGE    ${all_attenna_ports}
        ${dfe_power_output}    csn.execute    command=dapd -stat ${index}    connection=${ru_dfe_alias}
        ${tx_power_regexp}    set variable    TX.=.(\\d+\.?\\d*)
        ${tx_power_value}    Get Regexp Matches    ${dfe_power_output}    ${tx_power_regexp}    1
        ${status}     Run Keyword And Return Status     Should Be True    ${0}<=${tx_power_value}[0]<=${45}
        ...           msg=${tx_power_value}[0] is out of range.
    END
    [Teardown]  csn.Disconnect  connection=${ru_dfe_alias}

Check RU Calibration Status And Power
    [Documentation]  Author: Jia Lei
    [Arguments]  ${connection}=GNB_OAM    ${ru_dfe_ip}=192.168.100.10    ${asik_connection}=ASIK Master    ${retry_time}=3
    ...          ${radio_id}=${None}
    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    connection_alias_store.Connect to Common Unit Master    alias=${asik_connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    ${ru_list}    set variable if    "${radio_id}"=="${None}"    ${ru_list}    ${radio_id}
    FOR    ${ru_index}    IN    @{ru_list}
            Connect to RU With Allocated IP    ru_index=${ru_index}   ru_alias=RU${ru_index}
            ...    asik_alias=${asik_connection}   connection=${connection}
           Run Keyword And Continue On Failure    Wait until keyword succeeds    ${retry_time}X    30 s
           ...    Check RU Calibration Status    ru_alias=RU${ru_index}
           run keyword if    "AZQ" in "${tl.gnbs[0].dus[0].rus[0].radio_type.value}"    Check AZGX RU Power on DFE   ru_alias=RU${ru_index}
           ...    ELSE
           ...             Check AEHC RU Power on DFE    ru_alias=RU${ru_index}    ru_dfe_ip=${ru_dfe_ip}
           csn.Disconnect  connection=RU${ru_index}
    END
   [Teardown]  COAM Teardown gnb connections

Check RU Calibration Status
    [Documentation]  Author: Jia Lei
    [Arguments]    ${ru_alias}
    ${calibration_output}    csn.execute    command=bfcali -stat    connection=${ru_alias}
    ${nr_calibration}    Split String From RU Calibration Output    calibration_output=${calibration_output}
    Get RU Calibration Value And Compare    nr_calibration=${nr_calibration}

Split String From RU Calibration Output
    [Documentation]  Author: Jia Lei
    [Arguments]    ${calibration_output}    ${carrier_name}=NR
    @{nr_calibration}    create list
    @{calibrations}    split string    ${calibration_output}    \r\n\r\n
    FOR    ${latest_cali}    IN    @{calibrations}
           ${status}    run keyword and return status    should contain    ${latest_cali}    ${carrier_name}
           run keyword if    '${status}'=='${True}'    append to list      ${nr_calibration}    ${latest_cali}
    END
    [Return]    ${nr_calibration}

Get RU Calibration Value And Compare
    [Documentation]  Author: Jia Lei
    [Arguments]    ${nr_calibration}
    FOR    ${each_cali}    IN    @{nr_calibration}
           ${attempt_regexp}    set variable    Calibration attempts: (\\d+)
           ${success_regexp}    set variable    Successful calibrations: (\\d+)
           ${attempt_count}    Get Regexp Matches    ${each_cali}    ${attempt_regexp}    1
           ${success_count}    Get Regexp Matches    ${each_cali}    ${success_regexp}    1
           should be equal   ${attempt_count}    ${success_count}
    END

Perform gNB Restart And Check on air via rest api
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                <<Keyword>> is to restart gnb one time and check gnb on air status.
    ...                Recommend to use this keywoed in TEST SETUP.
    [Arguments]    ${timeout}=600   ${connection}=GNB_OAM    ${is_x2_check_from_gnb_needed}=${True}
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    connection=${connection}
    coam.reset_site    wait_for_reconnection=${True}    timeout=${timeout}    connection=${connection}
    COAM Wait for gnb ready and cell setup    timeout=20 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

Get Nr Cell Type Vaule
    [Documentation]  Author: Hao Xiaoxia
    [Arguments]    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${nrcell_id}=NRCELL-1
    ...            ${connection}=GNB_OAM
     ${nrCellType_Value}    coam_parameter.get_single_value_from_scf_file    parameter=nrCellType
    ...                                                                    dist_name=NRBTS-${nr_bts_id}/${nrcell_id}
    ...                                                                    connection=${connection}
    set suite variable    ${nrCellType_Value}

Modify To 2056 Config
    [Documentation]  Author: Hao Xiaoxia
    ${nrCellType_Value}    Get Variable Value    ${nrCellType_Value}
    return from keyword if    '${nrCellType_Value}' == '4DL4UL'
    Modify SCF and Perform Commission    ParameterToDelete=${PARAMS_TO_DELETE_FOR_2056}
    ...                                  ParamterToModify=${PARAMS_TO_MODIFY_FOR_2056}
    Get Nr Cell Type Vaule

Recover Test Env In Case Teardown
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    Run Keyword And Ignore Error    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=${ASIK_MASTER_ALIAS}
    Run Keyword And Ignore Error    Perform BTS Site Reset
    Run Keyword And Ignore Error    sleep    60
    Wait Until Keyword Succeeds    15 min    30 sec    connection_alias_store.Connect to Capacity Unit Master
    Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air via WebUI

Change To Closeloop 256QAM And Change CHBW
    [Arguments]    ${is_x2_check_from_gnb_needed}=${True}
    ...            ${swconfig_modify}=${SWCONFIG_PARA_DLRANK_4_1Pol}
    ...            ${modify_value}=${UPDATE_ACTDL256QAM_PARAM}
    Connect to Common Unit Master    alias=ASIK Master
    swconf.Download swConfig file from asik to test pc    localFilePath=${TS_CASE_LOG_PATH}/swconfig.txt
    ...                                                   asik_alias=ASIK Master
    ...                                                   remoteFilePath=/ffs/run/swconfig.txt
    swconf.Modify swConfig file    parametersList=${swconfig_modify}    filePath=${TS_CASE_LOG_PATH}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${TS_CASE_LOG_PATH}/swconfig.txt    asik_alias=ASIK Master
    csn.disconnect    connection=ASIK Master
#    ${chbw_param}    Modify All Chbw Para    bandwidth=${bandwidth}    gscn=${gscn}
#    ${modify_param_list}    combine lists    ${chbw_param}    ${modify_value}
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${modify_value}    timeout=900
    Coam Wait For Gnb Ready And Cell Setup    timeout=15 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}

5G_Site_eCPRI_link_failure_break_2mins_recovery_non_RFS
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...                Descrition; Performing ecpri link failure on gNB side with single mode
    ...                           step1: Gnb cell on air
    ...                           step2: cable link break, Check alarm �� faultid 10 should be in active alarm, ru auto reset.
    ...                           step3: Wait for 3 minutes, Cable link recover, cells are onair with No unexpected active alarms
    [Arguments]    ${gnb_connection}=GNB_OAM    ${ru_index}=${1}    ${is_x2_check_from_gnb_needed}=${True}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}
    ${ru_index_list}  Get All RU Index
    Set Test Variable    ${ru_index_list}
    Set Fiber Switch Into link_failure For All RU    ru_index_list=${ru_index_list}
    ${GNB_ALLOWED_FAULT}   Create List   ${ALLOWED_FAULT}   ${fault_10}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${GNB_ALLOWED_FAULT}    connection=${gnb_connection}
    sleep    60 sec
    Set Fiber Switch Into linkup For All RU    ru_index_list=${ru_index_list}
    Wait Until Keyword Succeeds    600 sec    3 sec    RU Should Be Online    ru_index=${ru_index}    connection=${gnb_connection}
    COAM Wait for gnb ready and cell setup    timeout=15 min
    ...                                       connection=${gnb_connection}
    ...                                       is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}    connection=${gnb_connection}
    ${ALLOWED_HISTORY_FAULT}   Create List   ${ALLOWED_HISTORY_FAULT}   ${fault_10}    ${fault_7300}
    Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=${gnb_connection}
    [Teardown]    run keywords    Run Keyword And Ignore Error    Set Fiber Switch Into linkup For All RU    ru_index_list=${ru_index_list}    AND
                   ...             Run Keyword And Ignore Error    COAM Teardown gnb connections

Set Fiber Switch Into linkup For All RU
    [Documentation]  Author: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${ru_index_list}    ${gnb_connection}=GNB_OAM
    FOR  ${ru_index}  IN  @{ru_index_list}
        Log To Console    \n\tSet RU ${ru_index} Fiber Switch Into link_up
        Set Fiber Switch Into linkup For RU    ru_id=${ru_index}-${1}
    END
    Wait For Expect Fault To Disappear   faultId=${10}    timeout=600    connection=${gnb_connection}

Set Fiber Switch Into link_failure For All RU
    [Documentation]  Author: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${ru_index_list}    ${optical_switch_id}=0    ${gnb_index}=${0}
    ...            ${optical_switch}=${tl.optical_switches[${optical_switch_id}].__class__.__name__}    ${gnb_connection}=GNB_OAM
    FOR  ${ru_index}  IN  @{ru_index_list}
        Log To Console    \n\tSet RU ${ru_index} Fiber Switch Into link_failure
        Run Keyword If    'Mitron' in '${optical_switch}'
        ...          Set Fiber Switch Into link_failure For RU on Mitron    ru_id=${ru_index}-${1}
        ...          ELSE IF    'Calient' in '${optical_switch}'
        ...          Set Fiber Switch Into link_failure For RU On Calient    dummy_output_channel=@{invalid_ru1_fiber_port}    ru_id=${ru_index}-${1}
    END
    FOR  ${ru_index}  IN  @{ru_index_list}
           Run Keyword And Continue On Failure    Wait For Expect Fault Present   faultId=${10}    timeout=300
        ...              source=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}   connection=${gnb_connection}
    END

5G_Site_eCPRI_link_failure_break_2mins_recovery 10 times with L3 call
    [Documentation]  Author: Jia Lei
    ...               This case is used to test link failure and recovery 10 times
    ...               loop 10 TIMES link up and down, then L2 call
    FOR    ${count}    IN RANGE    10
        run keyword and continue on failure    5G_Site_eCPRI_link_failure_break_2mins_recovery_non_RFS
    END
    Start L3 Call And Verify Throughput    ul_data_transfer=90M
    ...                                    dl_data_transfer=1000M
    ...                                    expect_ul_tput=70
    ...                                    expect_dl_tput=800
    ...                                    4G_check=${False}
    ...                                    cellid=${cell_index}
    ...                                    target_avg_percent=0.95
    ...                                    is_do_require_ue=${False}

Unlock All Cell For Recover Env
    [Documentation]  Author: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=120
    ${cell_num}    RRH_common_keyword.COAM Get GNB CELL Number    connection=${connection}
    @{cell_list}    Create List
    FOR    ${cell_index}    IN RANGE    1    ${cell_num}+${1}
        Append To List    ${cell_list}    ${cell_index}
    END
    FOR    ${cell_idx}    IN    @{cell_list}
        ${cell_group_idx}    Evaluate    ${cell_idx}-1
        Run Keyword And Ignore Error    Perform cell unlock via rest api    cell_idx=${cell_idx}    timeout=${timeout}
        Run Keyword And Ignore Error    Perform cell group unlock via rest api    cellgrp_idx=${cell_group_idx}
    END

Update Mix Band With Multi Cells And Wait Gnb OnAir
    [Documentation]  Author: xiaoxia.hao
    [Arguments]    ${frames_info}
    ${status}   Run Keyword And Return Status    Check Mix Band With Multi Cells Correction    frames_info=${frames_info}
    run keyword if    ${status}==${False}    Modify Band Frame Structure Multi CC With Different Bandwith On Gnb    frames_info=${frames_info}

Modify Band Frame Structure Multi CC With Different Bandwith On Gnb
    [Documentation]  Author: xiaoxia.hao
    [Arguments]    ${frames_info}    ${is_x2_check_from_gnb_needed}=${True}
    ${status}   Run Keyword And Return Status    Modify_Band_Frame_Structure_multi_cc_with_different_bandwith    frames_info=${frames_info}
    return from keyword if    ${status}==${True}
    Perform gNB Restart And Check on air via rest api    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    Modify_Band_Frame_Structure_multi_cc_with_different_bandwith    frames_info=${frames_info}

Check Mix Band With Multi Cells Correction
    [Documentation]  Author: xiaoxia.hao
    [Arguments]    ${frames_info}
    FOR    ${item}    IN    @{frames_info}
        ${chbw_value}    Get Single Cell CHBW Value    cell_id=${item}[cellid]
        ${chbw_value_on_scf}    ${result}    Split String From Right  ${chbw_value}    MHz     1
        Should Be True    "${chbw_value_on_scf}"=="${item}[band]"
    END

Get Single Cell CHBW Value
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]   ${cell_id}=1    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${connection}=GNB_OAM
    ${chbw_value}    coam_parameter.get_single_value_from_scf_file    parameter=chBw    dist_name=NRBTS-${nr_bts_id}/NRCELL-${cell_id}
    ...                                                               connection=${connection}
    [Return]  ${chbw_value}

Start Mix Band L3 Call And Verify Throughput
    [Arguments]     ${frames_info}
    Update UE Attach Cell Index on SA Mode    attach_cell_index=1
    Run Keyword And Continue On Failure
    ...    Start L3 Call And Verify Throughput     ul_data_transfer=${frames_info[0]}[ul_data_transfer]
    ...                                     dl_data_transfer=${frames_info[0]}[dl_data_transfer]
    ...                                     expect_ul_tput=${frames_info[0]}[expect_ul_tput]
    ...                                     expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                     4G_check=${False}
    ...                                     reset_sol=${none}
    Update UE Attach Cell Index on SA Mode    attach_cell_index=2
    Start L3 Call And Verify Throughput    ul_data_transfer=${frames_info[1]}[ul_data_transfer]
    ...                                    dl_data_transfer=${frames_info[1]}[dl_data_transfer]
    ...                                    expect_ul_tput=${frames_info[1]}[expect_ul_tput]
    ...                                    expect_dl_tput=${frames_info[1]}[expect_dl_tput]
    ...                                    is_do_require_ue=${False}
    ...                                    4G_check=${False}
    ...                                    cellid=2
    ...                                    reset_sol=${none}

Update UE Attach Cell Index on SA Mode
    [Documentation]    Author: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${attach_cell_index}    ${connection}=GNB_OAM    ${timeout}=300
    run keyword and ignore error   COAM Teardown gnb connections
    run keyword and ignore error    Connect to gnb coam via ssl
    @{expected_cell_list}    create list    ${attach_cell_index}
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${expected_cell_list}    connection=${connection}
    ...                                              timeout=${timeout}
    Sleep    30sec
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

Get UE IP Address
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               get pdu ip addr in message <InitialContextSetupRequest,DL NAS transport,pdu session establishment accept>
    ...               message filter: ngap.procedureCode == 14 && nas_5gs.sm.pdu_addr_inf_ipv4
    ...               If MultiPdu is configured, second pdu ip addr can be get from message <PDUSessionResourceSetupRequest>
    ...               message filter: ngap.procedureCode == 29 &&  nas_5gs.sm.pdu_addr_inf_ipv4
    [Arguments]    ${cpif_log_path}
    ${ue_ip_list}    Create List
    ${first_pdu_ip}    Check Target Item Value on CPIF Tcpdump
    ...                file_path=${cpif_log_path}
    ...                filter_expression=ngap.procedureCode == 14 && nas_5gs.sm.pdu_addr_inf_ipv4
    ...                xpath=.//nas_5gs.sm.pdu_addr_inf_ipv4
    ...                filter=f1ap||nr-rrc||ngap
    ${ue_ip}    Set Variable    ${first_pdu_ip}[0]
    Should Not Be Empty    ${ue_ip}    msg=get ue ip failed from attach log.
    [Return]    ${ue_ip}

Check Target Item Value on CPIF Tcpdump
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                Description:check target item value on CPIF tcpdump log.
    [Arguments]    ${file_path}
    ...            ${filter_expression}
    ...            ${xpath}
    ...            ${tshark_path}=/usr/bin/tshark
    ...            ${filter}=f1ap||nr-rrc||ngap
    ...            ${command_template}={tshark_path} -r {pcap_file} -Y \"${filter}\" -T pdml
    ...            ${attribute_name}=show
    Convert CPIF Pcap To Pdml    file_path=${file_path}
    ...                                          tshark_path=${tshark_path}
    ...                                          filter=${filter}
    ...                                          command_template=${command_template}
    ${filter_output}    Get Field Value From Pdml    filter_expression=${filter_expression}
    ...                                              xpath=${xpath}
    ...                                              attribute_name=${attribute_name}
    [Return]    ${filter_output}

#Convert CPIF Pcap To Pdml
#    [Documentation]    author:jun.8.chen@nokia-sbell.com
#    ...    Description: convert to cpif pcap to pdml format, pdml can be used for value check.
#    [Arguments]    ${file_path}
#    ...            ${tshark_path}=/usr/bin/tshark
#    ...            ${filter}=nr-rrc
#    ...            ${command_template}={tshark_path} -r {pcap_file} -Y \"${filter}\" -T pdml
#    cap.load_pcap_file    pcap_file=${file_path}    command_template=${command_template}

Update PA Value For Tput
    [Arguments]    ${PA_value}=0    ${AEHC_PA_value}=20
    ${stream}    get stream from version    ${Active_SW_version}
    Run Keyword If    '${stream}'=='SBTS00'
    ...                Adjust Attenuation To Trigger Peak Tput    PA1_value=${AEHC_PA_value}
    ...       ELSE     Modify All Attenuation Ports Value For All RU   value=${PA_value}

Modify All Attenuation Ports Value For All RU
    [Documentation]   lei.jia@nokia-sbell.com
    ...           Modify all atteuation ports for all RUs defined in init.py
    ...           :param ${value}: <list> or <string>, it can be several values or only one.
    ...           for example:
    ...           if ${value} = [10, 20, 20, 30], it means port 5=10, 6=20, 7=20, 9=30.
    ...           if ${value} = 10, it will set all ports under RU to value 10.
    [Arguments]    ${value}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
       ${RU_id}    evaluate    ${ru_index} - 1
       gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU
        ...    value=${value}   RU_id=${RU_id}
    END

Adjust Attenuation To Trigger Peak Tput
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]       ${PA0_value}=0   ${PA1_value}=0
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA0_value}   RU_id=0
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA0_value}   RU_id=1
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA0_value}   RU_id=2
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA1_value}   RU_id=3
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA1_value}   RU_id=4
    Sleep  2sec

Update Chbw And Dynamic Pdcch Wait Gnb On Air
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${modify_cell_chbw_dict}=${None}
    ...            ${scf_file_name}=${None}
    ...            ${modify_cell_ids}=all
    ...            ${bandwidth}=100MHz
    ...            ${gnb_index}=0
    ...            ${is_pdl_checking_needed}=${True}
    Get SCF File Path
    ${scf_file_name}    set variable if    "${scf_file_name}"=="${None}"    SCF_${stream}.xml    ${scf_file_name}.xml
    ${scf_file_path}    Join Path    ${scf_full_path}    ${scf_file_name}
    Update Chbw Dynamic Pdcch And Wait Gnb On Air    bandwidth=${bandwidth}    scf_file_path=${scf_file_path}
    ...                                              modify_cell_chbw_dict=${modify_cell_chbw_dict}
    ...                                              modify_cell_ids=${modify_cell_ids}
    ...                                              gnb_index=${gnb_index}
    ...                                              is_pdl_checking_needed=${is_pdl_checking_needed}

Update x2LinkSupervisionTmr Value
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${x2LinkSupervisionTmr}=1    ${is_x2_check_from_gnb_needed}=${True}
    @{modify_list}    create list
    &{x2LinkSupervisionTmr_value}    Create Dictionary    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${nr_bts_id}
    ...                                                   parameter=x2LinkSupervisionTmr    value=${x2LinkSupervisionTmr}
    Append To List    ${modify_list}    ${x2LinkSupervisionTmr_value}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_list}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}

COAM Check GNB with sleeping cell
    [Documentation]   Author: xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${cells_info}    coam.get_cells_info    connection=${connection}
    FOR  ${item}  IN  @{cells_info}
        ${cell_index}    Set Variable    ${item['globalCellId']}
        ${cell_status}=    coam.get_cell_specific_info  cell_id=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_index}    connection=${connection}
        ${sw_version}     coam.get_sw_version    connection=${connection}
        ${result}    run keyword and return status    should contain any
        ...    ${sw_version}
        ...    12.400    14.400    22R1    22R2    21B
        ${enabled}    Set Variable If    ${result}    Enabled    enabled
        ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
        Should Be Equal As Strings  ${cell_status['status']["operationalState"]}    ${enabled}
        Should Be Equal As Strings  ${cell_status['status']["administrativeState"]}    ${unlocked}
        run keyword if    ${result}    Should be equal as strings    ${cell_status['status']["availabilityStatus"]}    Degraded
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

Verify ABIL Restart
    [Documentation]   Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${bts_info}    coam.get_bts_info    connection=${connection}
    ${baseband_status}   Set Variable   ${bts_info['basebandModules']}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${offline}    Set Variable If    ${result}    Offline    off line
    FOR    ${item}  IN    @{baseband_status}
        Should be equal as strings    ${item['status']['availabilityStatus']}    ${offline}
        Should be equal as strings   ${item['status']['operationalState']}    ${disabled}
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

Recover Cell If Test Case Failed
    [Arguments]    ${connection}=GNB_OAM    ${is_x2_check_from_gnb_needed}=${True}
    ${cell_num}    RRH_common_keyword.COAM Get GNB CELL Number    connection=${connection}
    @{cell_list}    Create List
    FOR    ${cell_index}    IN RANGE    1    ${cell_num}+${1}
        Append To List    ${cell_list}    ${cell_index}
    END
    FOR    ${cell_idx}    IN    @{cell_list}
        ${cell_group_idx}    Evaluate    ${cell_idx}-1
        ${subcell_status}    Get Cell Status    cell_idx=${cell_idx}   cell_group_idx= ${cell_group_idx}
        ${subcell_admin_status}    Set Variable    ${subcell_status['administrativeState']}
        Run Keyword If    '${subcell_admin_status}'== 'Locked'    Run keywords
        ...       Perform cell unlock via rest api    cell_idx=${cell_idx}    AND
        ...       Wait Until Keyword Succeeds    600 sec    3 sec    Cell Should Be Unlocked    cell_idx=${cell_idx}
        ...       cell_group_idx=${cell_group_idx}    connection=${connection}
    END
    COAM Wait for gnb ready and cell setup    timeout=10 min    connection=${connection}    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}

Get Transport Counters
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${counter_id}
    ...            ${full_path}
    ...            ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${counters}    selenium_coam.get_transport_counters    counter_id=${counter_id}
    ...                                         full_path=${full_path}
    ${values}    Get Dictionary Values   ${counters}
#    log  The latest one is: ${values[-1]}
    COAM selenium logout
    [Return]    ${values[-1]}

Get Bts Counters Info
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${counter_id}
    ...            ${full_path}
    ...            ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${counters}    wait until keyword succeeds    10min    10s      selenium_coam.get_bts_counters_info    counter_id=${counter_id}
    ...                                                                                                    full_path=${full_path}
    ${values}    Get Dictionary Values   ${counters}
    COAM selenium logout
    [Return]    ${values[-1]}

Precondition Env for 5GC002510
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${scf_file_name}=${None}    ${pdate_param_name}=${FRAME_TO_11160ms_60MHz_4Symbols_cell3}
    ...            ${is_x2_check_from_gnb_needed}=${True}
    ${pre_tl_env}    Get Variable Value    ${pre_tl_env}
    return from keyword if    '${pre_tl_env}' == '${True}'
    Update Framestructure And CHBW    scf_file_name=${scf_file_name}    update_param_name=${pdate_param_name}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_index}
    ${delete_param_22R4}    Catenate         {'dist_name': '${dis_name_dir}/NRREL-0'},
    ...                                 {'dist_name': '${dis_name_dir}/NRREL-1'},
    ...                                 {'dist_name': '${dis_name_dir}/NRREL-2'},
    ...                                 {'dist_name': '${dis_name_dir}/NRREL-3'}
     ${delete_param}    Catenate         {'dist_name': '${dis_name_dir}/NRREL-1'},
    ...                                 {'dist_name': '${dis_name_dir}/NRREL-2'},
    ...                                 {'dist_name': '${dis_name_dir}/NRREL-3'},
    ...                                 {'dist_name': '${dis_name_dir}/NRREL-4'}
    ${delete_nrcell_infor}    run keyword if    '${stream}'=='SBTS22R4'    Evaluate     [${delete_param_22R4}]    ELSE
    ...                                                                    Evaluate     [${delete_param}]
    COAM delete objects via rest api    objects_to_delete_via_api=${delete_nrcell_infor}    timeout=300
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${cell_index}
    run keyword and ignore error    Connect to gnb coam via ssl
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Set Suite Variable    ${pre_tl_env}    ${True}

Wait Until Next Counter Update
    [Arguments]    ${counter_period}=5    ${gnb_connection}=ASIK Master
    [Documentation]    Author:xiaoxia.hao@nokia.com
    ...
    ...    Owner:yangyang.zhou@nokia-sbell.com
    ${period}    Evaluate    ${counter_period}*60
    ${current}     csn.execute    command=date +%s    connection=${gnb_connection}
    ${current}    Get Line    ${current}    -1
    ${sleep}    Evaluate    ${period}+${period}-${current}+int(${current}/${period})*${period}
    Sleep    ${sleep}
    sleep    30

PDLruleverification
    [Documentation]    Feature_ID:CNI-81699, no traffic, OAM feature
    Log To Console    \n*****checkpoint1: make actChannelMapVal ShowAsWarning, and Channel group1: 8Tx, 4Rx to verify pdl error
    Modify actChannelMapVal and Validate PDL Rule    actChannelMapVal=ShowAsWarning
    Log To Console    \n*****checkpoint2: make actChannelMapVal ShowAsError, and Channel group1: 8Tx, 4Rx to verify pdl error
    Modify actChannelMapVal and Validate PDL Rule    actChannelMapVal=ShowAsError
    Log To Console    \n*****checkpoint3: make actChannelMapVal Disabled, and Channel group1: 8Tx, 4Rx to verify pdl error
    Modify actChannelMapVal and Validate PDL Rule    actChannelMapVal=Disabled

Modify actChannelMapVal and Validate PDL Rule
    [Documentation]    Author:lei.jia@nokia.com
    [Arguments]    ${connection}=GNB_OAM
    ...             ${actChannelMapVal}=ShowAsWarning
    ${ParamterToModify} =    run keyword if
    ...               '${actChannelMapVal}' == 'ShowAsWarning'    set variable    ${PARAMS_TO_MODIFY_Two_Channels_actChannelMapVal_Warning}
    ...    ELSE IF    '${actChannelMapVal}' == 'ShowAsError'    set variable    ${PARAMS_TO_MODIFY_Two_Channels_actChannelMapVal_Error}
    ...    ELSE       set variable    ${PARAMS_TO_MODIFY_Two_Channels_actChannelMapVal_Disabled}
     ${modified_scf_path}    Modify and Save SCF
    ...    MOsToAdd=${Mos_TO_ADD_Two_Channels}
    ...    ParamterToModify=${ParamterToModify}
    ...    ParameterToDelete=${CNI81699_PARAMS_TO_DELETE_1CELL_ChannelGroup2}
    ...    scf_path=${Golden_SCF_Path}
    ...    scf_file_name=SCF_${stream}.xml
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    ${pdlValidationResult}    coam.validate_scf    scf_file=${modified_scf_path}
    ...    skip_parameter_relation_errors=True    connection=${connection}
    ${pdlValidationseverity}    set variable if     '${actChannelMapVal}' == 'Disabled'
    ...    ${pdlValidationResult['pdlValidationResult']['status']}
    ...    ${pdlValidationResult['pdlValidationResult']['logs']['relationErrors'][0]['severity']}
    ${PDLerror_type} =    run keyword if
    ...               '${actChannelMapVal}' == 'ShowAsWarning'    set variable    Warning
    ...    ELSE IF    '${actChannelMapVal}' == 'ShowAsError'    set variable    Error
    ...    ELSE       set variable    OK
    should be equal    ${pdlValidationseverity}    ${PDLerror_type}

Update msg1FrequencyStart Value
    [Documentation]    Author:xiaoxia.hao@nokia.com
    [Arguments]    ${cell_id}=${None}    ${msg1FrequencyStart}=3    ${connection}=GNB_OAM    ${is_x2_check_from_gnb_needed}=${True}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    ${nrcell_list}    Get Cell ID list via Admin CLI    connection=${connection}
    ${nrcell_list}    Run keyword if    '${cell_id}'=='${None}'    set variable    ${nrcell_list}    ELSE    Create List    NRCELL-${cell_id}
    ${para_to_modify}    Create List
    FOR    ${nrcell}    IN    @{nrcell_list}
        &{msg1FrequencyStart_param}    Create Dictionary    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/${nrcell}
        ...                                                 parameter=msg1FrequencyStart
        ...                                                 value=${msg1FrequencyStart}
        Append To List    ${para_to_modify}    ${msg1FrequencyStart_param}
    END
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${para_to_modify}    timeout=900
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

Lock Cell
    [Arguments]    ${cell_id}=4    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    Log To Console    Cell ${cell_id} Locked
    perform_cell_lock_via_admin    cell_id=${cell_id}    connection=${connection}    lock_timeout=300
    sleep    60s    #wait for cell locked

Unlock Cell
    [Arguments]    ${cell_id}=4    ${connection}=GNB_OAM
    Log To Console    Cell ${cell_id} Unlocked
    Connect to gnb coam via ssl
    perform_cell_unlock_via_admin    cell_id=${cell_id}    connection=${connection}    lock_timeout=300
    sleep    60s    #wait for cell unlocked

RF_Module_Stability_Run
    [Arguments]    ${radio_id}=${1}    ${RF_temperature_high_threshold}=${90}    ${outcome}=Pass
    ...          ${min_temperature}=40    ${max_temperature}=90
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Delete RFTHLD If Exist
    Set default value for RFTHLD If Feature 956 Enabled
#    Modify targetTotalLoad    new_value=${100}
    ${bts_thresholds}    create dictionary    RF temperature high threshold=${RF_temperature_high_threshold}
    RF statistics diagnostic test setup    bts_thresholds=${bts_thresholds}    radio_id=${radio_id}
    selenium logout and close browser
    FOR    ${i}    IN RANGE   1    7
        sleep    10min
        log to console    check RF status : ${i}
        Selenium Login And Disable Screen Lock    version=${stream}
        Delete RFTHLD If Exist
        Set default value for RFTHLD If Feature 956 Enabled
        ${bts_thresholds}    create dictionary    RF temperature high threshold=${RF_temperature_high_threshold}
        RF statistics diagnostic test setup    bts_thresholds=${bts_thresholds}    radio_id=${radio_id}
        sleep  30
        Check Statistics General Information    radio_id=${radio_id}    outcome=${outcome}
        Check RF Temperature Supervision    radio_id=${radio_id}    min_temperature=${min_temperature}    max_temperature=${max_temperature}
        selenium logout and close browser
        ${rf_id}    create list    ${radio_id}
        Check RU Calibration Status And Power    radio_id=${rf_id}
    END
    [Teardown]    selenium logout and close browser

Modify targetTotalLoad
    [Arguments]    ${new_value}    ${cell_id}=1
    ${modify_params}    create list
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
	...    filter_param=Target total load with artificial load
    ...    p_name=targetTotalLoad    value=${new_value}
    append to list  ${modify_params}  ${item}
	Modify Parameters On Webem  ${modify_params}    despite_errors=${False}

Modify To 1Sector 3CC 4DL4UL Config
    [Documentation]  Author: Hao Xiaoxia
    [Arguments]    ${scf_file_name}
    ${nrCellType_Value}    Get Variable Value    ${nrCellType_Value}
    return from keyword if    '${nrCellType_Value}' == '4DL4UL'
    Get SCF File Path
    ${scf_file_full_name}    set variable    ${scf_file_name}.xml
    ${scf_file}    Join Path    ${scf_full_path}    ${scf_file_full_name}
    Modify SCF and Perform Commission    ParameterToDelete=${PARAMS_TO_DELETE_FOR_1SECTOR_3CC_4DL_4UL}
    ...                                  ParamterToModify=${PARAMS_TO_MODIFY_FOR_1SECTOR_3CC_4DL_4UL}
    ...                                  scf_file_name=${scf_file_name}
    ...                                  scf_path=${scf_file}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Sleep 	90s 	Wait for calibration setup
    Get Nr Cell Type Vaule

COAM gNB Reset site
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${timeout}=600   ${connection}=GNB_OAM    ${asik_alais}=ASIK Master
    ...            ${is_x2_check_from_gnb_needed}=${True}
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    connection=${connection}
    coam.reset_site    wait_for_reconnection=${True}    timeout=${timeout}    connection=${connection}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${asik_alais}
    COAM Wait For Gnb Ready And Cell Setup    timeout=10 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    Wait until keyword succeeds    5 min    20 sec   verify all cells should be onair

Online Update Second Cell CHBW And Wait Gnb On Air
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${bandwidth}=50MHz    ${cell_id}=5    ${is_x2_check_from_gnb_needed}=${True}
    ${cells_id}    create list    ${cell_id}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    ${chbw_param}    Modify All Chbw Para    bandwidth=${bandwidth}    modify_cell_ids=${cells_id}
    ${para_modify}    Catenate    {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-3',
    ...                            'parameter': 'nrarfcn',
    ...                            'value': '510000'},
    ...                           {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-5',
    ...                            'parameter': 'nrarfcn',
    ...                            'value': '525558'},
    ...                           {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-6',
    ...                            'parameter': 'nrarfcn',
    ...                            'value': '533106'}
    ${para_modify_list}    Evaluate    [${para_modify}]
    ${modify_param_list}    combine lists    ${chbw_param}     ${para_modify_list}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param_list}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    Wait until keyword succeeds    10 min    20 sec   verify all cells should be onair
    [Teardown]  run keyword and ignore error   COAM Teardown gnb connections

Update prachConfigurationIndex Value For All Cellls
    [Arguments]    ${prachConfigurationIndex_value}    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    ${nrcell_list}    Get Cell ID list via Admin CLI    connection=${connection}
    ${modify_param}    Create List
    FOR    ${nrcell}    IN    @{nrcell_list}
        &{prachConfigurationIndex_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}/${nrcell}
        ...                                                      parameter=prachConfigurationIndex    value=${prachConfigurationIndex_value}
        Append To List    ${modify_param}    ${prachConfigurationIndex_param}
    END
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${modify_param}    timeout=900
    Wait until keyword succeeds    10 min    20 sec   verify all cells should be onair
    [Teardown]  run keyword and ignore error   COAM Teardown gnb connections

Update prachConfigurationIndex Value For All Cellls For Trunk
    [Arguments]    ${prachConfigurationIndex_value}    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    ${gnb_nr_cell_id_mapping}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
    ${all_cell_ids}    Get dictionary keys    ${gnb_nr_cell_id_mapping}
    ${all_cell_ids}    Evaluate    list(map(lambda x: int(x), ${all_cell_ids}))
    ${modify_param}    Create List
    FOR    ${nrcell}    IN    @{all_cell_ids}
        &{prachConfigurationIndex_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}/NRCELL-${nrcell}
        ...                                                      parameter=prachConfigurationIndex    value=${prachConfigurationIndex_value}
        Append To List    ${modify_param}    ${prachConfigurationIndex_param}
    END
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${modify_param}    timeout=900
    Wait until keyword succeeds    10 min    20 sec   verify all cells should be onair
    [Teardown]  run keyword and ignore error   COAM Teardown gnb connections

Lock eNB Cell For Multiple Rat
    [Arguments]    ${cell_index}    ${cell_type}=lte    ${timeout}=300    ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${gnb_connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR   ${cell_dist_name}    IN     @{cell_list}
         ${distname}     Set Variable If    '${cell_index}' in '${cell_dist_name}'    ${cell_dist_name}    ${None}
         Exit For Loop If 	'${distname}' != '${None}'
    END
    coam.lock    dist_name=${distname}    timeout=${timeout}    connection=${gnb_connection}
    Sleep    60s

Unlock eNB Cell For Multiple Rat
    [Arguments]    ${cell_index}    ${cell_type}=lte    ${timeout}=300    ${gnb_index}=0    ${gnb_connection}=GNB_OAM
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${gnb_connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR   ${cell_dist_name}    IN     @{cell_list}
         ${distname}     Set Variable If    '${cell_index}' in '${cell_dist_name}'    ${cell_dist_name}    ${None}
         Exit For Loop If 	'${distname}' != '${None}'
    END
    coam.unlock    dist_name=${distname}    timeout=${timeout}    connection=${gnb_connection}
    Sleep    60s

Power Reset eNB After gNB Upgrade for RFS
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${unit_index}=${0}
    ...    ${model}=${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
    ${enb_pdu_ip}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
    ${enb_pdu_port}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.port_no}
    BuiltIn.Log    Reset eNB via Power off and On
    pdu.setup_pdu    model=${model}   host=${enb_pdu_ip}    alias=enb_pdu
    pdu.power_off    port=${enb_pdu_port}    pdu_device=enb_pdu
    Sleep    5sec
    pdu.power_on    port=${enb_pdu_port}    pdu_device=enb_pdu

Upgrade Enb For RFS
    [Arguments]    ${timeout}=${1800}     ${connection}=enblte
    ${status}    Run Keyword And Return Status    Connect to eNB via ssl
    run keyword if     not ${status}    run keywords    Power Reset eNB After gNB Upgrade for RFS    AND    Sleep    5min   AND
    ...                                                 Connect to eNB via ssl
    ${enb_active_version}    Get Active SW Version    connection=${connection}
    return from keyword if    '${enb_active_version}' == '${Active_SW_version}'
    LOG TO CONSOLE    ${SPACE*2}try to upgrade eNB again.
    ${bts_stream}    ${bts_version}    Split String From Right    ${Active_SW_version}    ENB     1
    ${sw_path}    CI_commssion.Get SW file Path    build=${stream}_ENB${bts_version}    stream=${stream}
    Sleep    5s
    taf.sbts.oam.coam.admin.update_software     sw_package=${sw_path}     should_activate=True    timeout=${timeout}   connection=${connection}
    Sleep    30s
    LOG TO CONSOLE   ${SPACE*2}eNB upgrade is done.

Power Reset All RF
    [Arguments]    ${is_reset_all_RF}=${False}
    return from keyword if    not ${is_reset_all_RF}
    ${rus}   Set Variable   ${tl.gnbs[0].dus[0].rus}
    ${ru_count}   Get Length   ${rus}
    FOR   ${index}    IN RANGE    ${ru_count}
        ${pb_host}   Set Variable   ${rus[${index}].pdu_port.pdu.addr}
        ${pb_port}   Set Variable   ${rus[${index}].pdu_port.port_no}
        ${pb_model}   Set Variable   ${rus[${index}].pdu_port.pdu.__class__.__name__}
        pdu.setup_pdu    model=${pb_model}   host=${pb_host}   alias=ru_${index}
        pdu.power_off    port=${pb_port}    pdu_device=ru_${index}
        Sleep    5sec
        pdu.power_on    port=${pb_port}    pdu_device=ru_${index}
    END

Power Off RF
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${rf_index}=${0}
    ${rus}   Set Variable   ${tl.gnbs[0].dus[0].rus}
    ${pb_host}   Set Variable   ${rus[${rf_index}].pdu_port.pdu.addr}
    ${pb_port}   Set Variable   ${rus[${rf_index}].pdu_port.port_no}
    ${pb_model}   Set Variable   ${rus[${rf_index}].pdu_port.pdu.__class__.__name__}
    pdu.setup_pdu    model=${pb_model}   host=${pb_host}   alias=ru_${rf_index}
    pdu.power_off    port=${pb_port}    pdu_device=ru_${rf_index}
    BuiltIn.Log    RF Power off

Power On RF
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${rf_index}=${0}
    ${rus}   Set Variable   ${tl.gnbs[0].dus[0].rus}
    ${pb_host}   Set Variable   ${rus[${rf_index}].pdu_port.pdu.addr}
    ${pb_port}   Set Variable   ${rus[${rf_index}].pdu_port.port_no}
    ${pb_model}   Set Variable   ${rus[${rf_index}].pdu_port.pdu.__class__.__name__}
    pdu.setup_pdu    model=${pb_model}   host=${pb_host}   alias=ru_${rf_index}
    pdu.power_on    port=${pb_port}    pdu_device=ru_${rf_index}
    BuiltIn.Log    RF Power on

Upgrade RF Version For Gnb
    ${bts_stream}    ${bts_version}    Split String From Right    ${Active_SW_version}    ENB     1
    ${testline_name}  Get Variable Value    ${testline_name}
    WAIT UNTIL KEYWORD SUCCEEDS    15min    30s    CI_commssion.All Hw Should Be Detected    testline=${testline_name}
    ...                                                                  build=${stream}_ENB${bts_version}    stream=${stream}    ute_env=${True}

Change CHBW and Frame related params with WebUI
    [Arguments]    ${updated_params}
    ${paramlist_len}    get length   ${updated_params}
    Selenium Login And Disable Screen Lock
    log to console    --- start to modify parameters via webui---
    FOR  ${i}  IN RANGE  ${paramlist_len}
        ${new_value}    Set Variable    ${updated_params[${i}].get('new_value', ${None})}
        ${new_value}    Set Variable if    '${new_value}'=='FALSE' or '${new_value}'=='TRUE'    ${new_value.lower()}    ${new_value}
        ${node_index}    Set Variable    ${updated_params[${i}].get('node_index', ${None})}
        ${abbr}    Set Variable    ${updated_params[${i}].get('abbr', ${None})}
        ${dist_name}    Set Variable If    'NRCELL' in '${updated_params[${i}]['dist_name']}'
        ...    ${updated_params[${i}]['dist_name'].split('/')[-1]}    ${updated_params[${i}]['dist_name']}
        log to console    “try ${i}, modify ${abbr} to ${new_value} for ${updated_params[${i}]['dist_name']}”
        WEBUI Set Param And Remove Element
        ...   dist_name=${dist_name}
        ...   filter_param=${updated_params[${i}]['filter_param']}
        ...   abbr=${abbr}
        ...   new_value=${new_value}
        ...   node_index=${node_index}
    END
    log to console    --- start to validate and activate plan---
    selenium_coam.validate_plan
    Run Keyword And Continue On Failure    webui COAM check validation errors
    selenium_coam.activate_plan   download_plan_without_activation=${False}    activate_plan_despite_errors=${True}
    ...   execute=${True}   timeout=600
    sleep  30s
    Close Start Up View    timeout=60
    [Teardown]    run keyword and ignore error    selenium logout and close browser

webui COAM check validation errors
    @{errors} =    create list
    ${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
#    ${hardware_errors}    run keyword if   'SBTS00' not in '${stream}'    selenium_coam.get_hardware_errors
    ${errors}    combine lists    ${defination_errors}   ${relation_errors}
#    ${errors}    combine lists    ${defination_errors}   ${relation_errors}    ${hardware_errors}
    Log to console    The current BTS exist errors as ${errors}.
    Should be empty    ${errors}

WEBUI Set Param And Remove Element
    [Arguments]   ${dist_name}   ${filter_param}   ${abbr}   ${new_value}    ${node_index}=${0}
    run keyword if   '${new_value}'=='${None}'    Wait Until Keyword Succeeds    2x    5sec    WebUI Get AND Delete Parameter
    ...   dist_name=${dist_name}
    ...   filter_param=${filter_param}
    ...   abbr=${abbr}
    ...   node_index=${node_index}
    ...    ELSE    Wait Until Keyword Succeeds    2x    5sec    WEBUI Set Parameter Value
    ...   dist_name=${dist_name}
    ...   filter_param=${filter_param}
    ...   abbr=${abbr}
    ...   new_value=${new_value}
    ...   node_index=${node_index}

WEBUI Set Parameter Value
    [Documentation]   Set Parameter Value
    [Arguments]   ${dist_name}   ${filter_param}   ${abbr}   ${new_value}    ${node_index}=${0}
    ${value}    Run Keyword And Return Status    selenium_coam.get_parameter_value    dist_name=${dist_name}
     ...                filter_param=${filter_param}    node_index=${node_index}    abbr=${abbr}    timeout=${300}
    run keyword if   '${new_value}'!='${value}'    selenium_coam.set_parameter_value
    ...   dist_name=${dist_name}
    ...   filter_param=${filter_param}
    ...   abbr=${abbr}
    ...   new_value=${new_value}
    ...   node_index=${node_index}
    ...   timeout=${300}

WebUI Get AND Delete Parameter
     [Arguments]    ${dist_name}    ${filter_param}   ${abbr}    ${node_index}
     ${value_status}    Run Keyword And Return Status    selenium_coam.get_parameter_value    dist_name=${dist_name}
     ...                filter_param=${filter_param}    node_index=${node_index}    abbr=${abbr}    timeout=${300}
     run keyword if    ${value_status}    selenium_coam.delete_parameter
     ...   dist_name=${dist_name}
     ...   filter_param=${filter_param}
     ...   abbr=${abbr}
     ...   node_index=${node_index}

Modify to 3S3CC 16DL4UL
    [Arguments]    ${scf_file_name}
    ${nrCellType_Value}    Get Variable Value    ${nrCellType_Value}
    return from keyword if    '${nrCellType_Value}' == '16DL4UL'
    Get SCF File Path
    ${scf_file_full_name}    set variable    ${scf_file_name}.xml
    ${scf_file}    Join Path    ${scf_full_path}    ${scf_file_full_name}
    Modify SCF and Perform Commission    ParameterToDelete=${PARAMS_TO_DELETE_FOR_CELL1_CELL4_16DL_4UL}
    ...                                  ParamterToModify=${PARAMS_TO_MODIFY_FOR_CELL1_CELL4_16DL_4UL}
    ...                                  scf_file_name=${scf_file_name}
    ...                                  scf_path=${scf_file}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Sleep 	90s 	Wait for calibration setup
    Get Nr Cell Type Vaule

Set MCS Phase And ATT For 10744
    ${mcs_type}    mcs_common.Get MCS Type    mcs_index=${1}
    Set Test Variable    ${mcs_type}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=${None}    mcs_index=${1}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-35}    second_beam_horizontal_angle=${-50}    vertical_angle=${-6}
    ...    vertical_distance=${2}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=10
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${35}    second_beam_horizontal_angle=${50}    vertical_angle=${-6}
    ...    vertical_distance=${2}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=35
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${-15}    vertical_angle=${-6}
    ...    vertical_distance=${2}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=32
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}    vertical_angle=${-6}
    ...    vertical_distance=${2}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=32
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}

Start L3 Call And Verify Throughput With NRDIM
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]   ${ul_data_transfer}
    ...           ${dl_data_transfer}
    ...           ${duration}=360
    ...           ${download_dir}=${TS_CASE_LOG_PATH}
    ...           ${hw_slot}=${1}
    ...           ${is_ulbler_calcu}=${False}
    ...           ${reset_sol}=ue_reboot
    ...           ${connection}=ASIK Master
    ...           ${ue_index}=${0}
    ...           ${4G_check}=True
    ...           ${is_wireshark_log_capture}=${False}
    ...           ${ignore_time}=1min
    ...           ${target_avg_percent}=0.98
    ...           ${actCarrierAggregation}=${False}
    ...           ${list_all_cell_ids}=${False}
    ...           ${is_do_require_ue}=${True}
    ...           ${cellid}=1
    ...           ${throuput_duration}=900
    ...           ${is_need_stop_traffic}=${True}
    ...           ${min_percent}=0.85
    ...           ${wireshark_log_prefix}=ue_attach
    ...           ${ue_iperf_path}=/data/local/tmp/iperf
    ...           ${ue_ul_layer}=${2}
    ...           ${expect_ul_bler}=0.03
    ...           ${pucchprb}=${None}
    ...           ${dl_process_num}=2
    ${cells_id}    create list    ${cellid}
    ${expect_bler}    Convert To Number    ${expect_ul_bler}
    ${direction_component_list}=  Create List    UL_L2LO    DL_L2LO
    run keyword and ignore error    csn.disconnect    connection=${connection}
    connection_alias_store.Connect to Common Unit Master
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
#    ${cell_and_peak_info}    Generate Peak Information    cell_list=${cells_id}    ue_ul_layer=${ue_ul_layer}
#    ...                                                   l3_avg_rate=${target_avg_percent}    l3_min_rate=${min_percent}
#    ${dl_data_transfer_from_nrdim}  ${ul_data_transfer_from_nrdim}  ${throuput_duration}
#    ...                                                             get_start_traffic_information    cell_id=${cell_id}
#    ...                                                                                              ue_number=${ue_number}
#    ...                                                                                              duration=${throuput_duration}
#    ...                                                                                              cell_and_peak_info=${cell_and_peak_info}
#    ...                                                                                              check_wait_time=${check_wait_time}
#    ${expect_dl_tput}  ${expect_ul_tput}  ${target_avg_percent}  ${min_percent}    ${duration}
#    ...                                                           get_verify_traffic_information     cell_id=${cell_id}
#    ...                                                                                              duration=${duration}
#    ...                                                                                              avg_expect_rate=${target_avg_percent}
#    ...                                                                                              min_expect_rate=${min_percent}
#    ...                                                                                              cell_and_peak_info=${cell_and_peak_info}
#    ${ul_data_transfer}   set variable if    '${ul_data_transfer}' == 'NULL'    ${ul_data_transfer_from_nrdim}    ${ul_data_transfer}
#    ${dl_data_transfer}   set variable if    '${ul_data_transfer}' == 'NULL'    ${dl_data_transfer_from_nrdim}    ${dl_data_transfer}

    ${scf_path_nrdim}    coam_gnb_classical.COAM Download scf from cluster    scf_dir_path=${SAVE LOG DIRECTORY}
    ...                                                                       connection=GNB_OAM
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    ${expect_dl_tput}    ${expect_ul_tput}    get_theoretical_throughput    scf_path=${scf_path_nrdim}
    ...                                                                     cell_id=${cellid}
    ...                                                                     ue_ul_layer=${ue_ul_layer}
    ...                                                                     pucchprb=${pucchprb}
    ${wireshark_log_path_on_testPC}   Run keyword if    '${ue_type}' == 'mtk'    Make_L3_Call_With_MTK_UE
    ...                                                               wireshark_log_prefix=${wireshark_log_prefix}_${attach_timestamp}
    ...                                                               ul_data_transfer=${ul_data_transfer}
    ...                                                               dl_data_transfer=${dl_data_transfer}
    ...                                                               duration=${throuput_duration}
    ...                                                               ue_iperf_path=${ue_iperf_path}
    ...                                                               ue_index=${ue_index}
    ...                                                               is_do_require_ue=${is_do_require_ue}
    ...                                                               dl_process_num=${dl_process_num}
    ...             ELSE                Make_L3_Call_With_Power_UE    reset_sol=${reset_sol}
    ...                                                               ue_index=${ue_index}
    ...                                                               4G_check=${4G_check}
    ...                                                               is_wireshark_log_capture=${is_wireshark_log_capture}
    ...                                                               is_do_require_ue=${is_do_require_ue}
    ...                                                               ul_data_transfer=${ul_data_transfer}
    ...                                                               dl_data_transfer=${dl_data_transfer}
    ...                                                               throuput_duration=${throuput_duration}
    ...                                                               dl_process_num=${dl_process_num}
    Check Tput With Power UE    direction_component_list=${direction_component_list}
    ...                         expect_ul_tput=${expect_ul_tput}
    ...                         expect_dl_tput=${expect_dl_tput}
    ...                         expect_ul_bler=${expect_ul_bler}
    ...                         duration=${duration}
    ...                         download_dir=${download_dir}
    ...                         hw_slot=${hw_slot}
    ...                         is_ulbler_calcu=${is_ulbler_calcu}
    ...                         ignore_time=${ignore_time}
    ...                         target_avg_percent=${target_avg_percent}
    ...                         actCarrierAggregation=${actCarrierAggregation}
    ...                         list_all_cell_ids=${list_all_cell_ids}
    ...                         cellid=${cellid}
    ...                         min_percent=${min_percent}
    [Return]     ${wireshark_log_path_on_testPC}
    [Teardown]    run keyword if    ${is_need_stop_traffic}    Run Keyword And Ignore Error    Stop Traffic In Teardown    ue_index=${ue_index}

Start L3 Call in spark And Verify Throughput With NRDIM
    [Documentation]   Auther: xiangsheng.chu@nokia-sbell.com
    [Arguments]   ${ul_data_transfer}
    ...           ${dl_data_transfer}
    ...           ${duration}=360
    ...           ${download_dir}=${TS_CASE_LOG_PATH}
    ...           ${hw_slot}=${1}
    ...           ${is_ulbler_calcu}=${False}
    ...           ${connection}=ASIK Master
    ...           ${ue_index}=${1}
    ...           ${ignore_time}=1min
    ...           ${target_avg_percent}=0.98
    ...           ${actCarrierAggregation}=${False}
    ...           ${list_all_cell_ids}=${False}
    ...           ${is_do_require_ue}=${True}
    ...           ${cellid}=1
    ...           ${throuput_duration}=600
    ...           ${min_percent}=0.85
    ...           ${wireshark_log_prefix}=ue_attach
    ...           ${mode}=SA
    ...           ${ue_ul_layer}=${2}
    ...           ${expect_ul_bler}=0.03
    ...           ${pucchprb}=${None}
    ...           ${check_source}=aasyslog
    ${cells_id}    create list    ${cellid}
    ${expect_bler}    Convert To Number    ${expect_ul_bler}
    ${direction_component_list}=  Create List    UL_L2LO    DL_L2LO
    run keyword and ignore error    csn.disconnect    connection=${connection}
    connection_alias_store.Connect to Common Unit Master
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scf_path_nrdim}    coam_gnb_classical.COAM Download scf from cluster    scf_dir_path=${SAVE LOG DIRECTORY}
    ...                                                                       connection=GNB_OAM
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    ${expect_dl_tput}    ${expect_ul_tput}    get_theoretical_throughput    scf_path=${scf_path_nrdim}
    ...                                                                     cell_id=${cellid}
    ...                                                                     ue_ul_layer=${ue_ul_layer}
    ...                                                                     pucchprb=${pucchprb}
    ${wireshark_log_path_on_testPC}   Make_L3_Call_With_spark_UE
    ...                                                               wireshark_log_prefix=${wireshark_log_prefix}_${attach_timestamp}
    ...                                                               mode=${mode}
    ...                                                               ul_data_transfer=${ul_data_transfer}
    ...                                                               dl_data_transfer=${dl_data_transfer}
    ...                                                               start_keep_on_duration=${throuput_duration}
    ...                                                               ue_index=${ue_index}
    ...                                                               is_do_require_ue=${is_do_require_ue}
    Check Tput With Power UE    direction_component_list=${direction_component_list}
    ...                         expect_ul_tput=${expect_ul_tput}
    ...                         expect_dl_tput=${expect_dl_tput}
    ...                         expect_ul_bler=${expect_ul_bler}
    ...                         duration=${duration}
    ...                         download_dir=${download_dir}
    ...                         hw_slot=${hw_slot}
    ...                         is_ulbler_calcu=${is_ulbler_calcu}
    ...                         ignore_time=${ignore_time}
    ...                         target_avg_percent=${target_avg_percent}
    ...                         actCarrierAggregation=${actCarrierAggregation}
    ...                         list_all_cell_ids=${list_all_cell_ids}
    ...                         cellid=${cellid}
    ...                         min_percent=${min_percent}
    ...                         check_source=${check_source}
    [Return]     ${wireshark_log_path_on_testPC}
    [Teardown]    run keywords    Run Keyword And Ignore Error     Spark_common_keywords.Start UE Detach    ue_index=${ue_index}
    ...    AND      Run Keyword And Ignore Error     Spark_common_keywords.Spark Stop UE Log    ue_index=${ue_index}
    ...    AND      Run Keyword And Ignore Error     Spark_common_keywords.Stop L3 Traffic
    ...                                              ue_index=${ue_index}    apn_address=${tl.core.pdns[0].apn}
    ...    AND      Run Keyword And Ignore Error     Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.port}

Make_L3_Call_With_spark_UE
    [Documentation]    Author:xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${is_do_require_ue}=${True}
    ...            ${wireshark_log_prefix}=ue_attach
    ...            ${ul_data_transfer}=160MKbits/sec
    ...            ${dl_data_transfer}=600M
    ...            ${ue_index}=${0}
    ...            ${filter_ports}=((port 38472) or (port 38412)or (port 38462) or (port 36422) or (port 38422))
    ...            ${wireshark_capture_interface}=-i any '((sctp) and ${filter_ports})' -s 0
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${gnb_index}=${0}
    ...            ${mode}=SA    ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${start_keep_on_duration}=1200
    ...            ${buffer_size}=1400B    ${appserver}=APPserver    ${protocol}=udp
    ...            ${dl_process_num}=2    ${seg_size}=${1372}    ${window}=2M
    Run Keyword If    ${is_do_require_ue}    Run Keyword And Continue On Failure    Spark_common_keywords.Start Prepare UE    ue_index=${ue_index}
    Run Keyword And Continue On Failure    Spark_common_keywords.Spark Start UE Log    ue_index=${ue_index}
    kill DL iperf port     dl_port=${tl.ues[${ue_index}].iperf_details.port}
    Run Keyword And Continue On Failure    Start CP-IF Log Collection     tcpdump_collector_name=${wireshark_log_prefix}
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    ...    options=${wireshark_capture_interface}
    Sleep   5s
    Log To Console    ${\n}INFO:-- start to attach --
    Spark_common_keywords.Start UE Attach in X65 multi UE x65    ue_index=${ue_index}
    Log To Console    ${\n}INFO:-- start to DL call --
    Sleep   10s
    ${cpif_attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...    tcpdump_collector_name=${wireshark_log_prefix}
    ${ue_ip_dict}    Get ALL PDU IP Address From Wireshark     cpif_log_path=${cpif_attach_log_on_testPC}    mode=${mode}
#    ${process_num}    Set Variable If    '${protocol}'=='udp'     1     ${process_num}
    ${dl_data_value}    get regexp matches    ${dl_data_transfer}    \\d+.*\\d+
    ${dl_data_unit}    get regexp matches    ${dl_data_transfer}    [^\\d+]+
    ${target_dl_data_value}    Evaluate    int(${dl_data_value}[0]/${dl_process_num})
    ${dl_data_transfer}     Set Variable     ${target_dl_data_value}${dl_data_unit}[0]
    Start DL traffic via iperf on Appserver    ue_addr=${ue_ip_dict['data']}
    ...                                                       dl_time=${start_keep_on_duration}
    ...                                                       dl_port=${tl.ues[${ue_index}].iperf_details.port}
    ...                                                       dl_throughput=${dl_data_transfer}
    ...                                                       dl_length=${buffer_size}
    ...                                                       appserver=${appserver}
    ...                                                       protocol=${protocol}
    ...                                                       ue_index=${ue_index}
    ...                                                       process_num=${dl_process_num}
    ...                                                       seg_size=${seg_size}
    ...                                                       window=${window}
    Spark_common_keywords.Start UL Traffic with spark UE   ul_throughput=${ul_data_transfer}
    ...        duration=${start_keep_on_duration}
    ...        apn_address=${apn_address}
    ...        ue_mode=${mode}
    ...        ue_index=${ue_index}
    [Return]     ${cpif_attach_log_on_testPC}

Check AEHC Detailed Antenna
    [Arguments]    ${cell_id}=1
    ...    ${RSSI_low}=-180    ${RSSI_high}=-30    ${SINR_low}=-21    ${SINR_high}=41
    ${detail_result}    selenium_coam.get_detailed_result_for_each_antenna    cell_id=${cell_id}
    FOR    ${item}    IN    @{detail_result}
        ${value_VSWR}    get from dictionary    ${item}    VSWR
        should be equal    ${value_VSWR}     0
        ${value_RSSI}    get from dictionary    ${item}    RSSI (dBm)
        should be true    ${RSSI_low} < ${value_RSSI} <= ${RSSI_high}
        ${value_SINR}    get from dictionary    ${item}    SINR (dB)
        should be true    ${SINR_low} <= ${value_SINR} < ${SINR_high}
    END

Set Uboot For Netboot
    [Arguments]    ${ASIK_MASTER_ALIAS}=ASIK Master
    Cloud DU connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}

    Run Keyword And Continue On Failure    csn.execute    command=uboot_env set netboot=netboot_first
    ...                                                        connection=${ASIK_MASTER_ALIAS}
    Sleep   10sec
    [Teardown]    csn.disconnect    connection=${ASIK_MASTER_ALIAS}

#Cell Should Be Locked For WR
#    [Arguments]  ${cell_id}=${1}   ${connection}=GNB_OAM
#    ${subcell_status}=  Get Cell Status For WR    cell_id=${cell_id}
#    ${sw_version}     coam.get_sw_version    connection=${connection}
#    ${result}    run keyword and return status    should contain any
#    ...    ${sw_version}
#    ...    12.400    14.400    22R1    22R2    21B
#    ${disabled}    Set Variable If    ${result}    Disabled    disabled
#    ${offline}    Set Variable If    ${result}    Offline    off line
#    ${locked}    Set Variable If    ${result}    Locked    Locked
#    Should Be Equal As Strings  ${subcell_status["operationalState"]}   ${disabled}
#    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  ${offline}
#    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  ${locked}
#    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser
#
#Cell Should Be Unlocked For WR
#    [Arguments]  ${cell_id}=${1}    ${connection}=GNB_OAM
#    ${subcell_status}=  Get Cell Status For WR    cell_id=${cell_id}
#    ${sw_version}     coam.get_sw_version    connection=${connection}
#    ${result}    run keyword and return status    should contain any
#    ...    ${sw_version}
#    ...    12.400    14.400    22R1    22R2    21B
#    ${enabled}    Set Variable If    ${result}    Enabled    enabled
#    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
#    Should Be Equal As Strings  ${subcell_status["operationalState"]}    ${enabled}
#    Should Be Equal As Strings  ${subcell_status["administrativeState"]}    ${unlocked}
#    run keyword if    ${result}    Should be equal as strings    ${subcell_status["availabilityStatus"]}    Online
#    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser
#
#Get Cell Status For WR
#    [Arguments]    ${cell_id}=${1}    ${technology}=NR
#    Selenium Login And Disable Screen Lock
#    ${cell_info}    selenium_coam.get_cell_info    cell_idx=${cell_id}    technology=${technology}
#    ${status_dict}   Catenate
#    ...                         'operationalState':
#    ...                         '${cell_info["Status"]["Operational state"]}',
#    ...                         'administrativeState':
#    ...                         '${cell_info["Status"]["Administrative state"]}',
#    ...                         'blockingState':
#    ...                         '${cell_info["Status"]["Blocking state"]}',
#    ...                         'availabilityStatus':
#    ...                         '${cell_info["Status"]["Availability status"]}',
#    ${subcell_status}    Evaluate   {${status_dict}}
#    [Return]   ${subcell_status}
#    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser
*** Settings ***
Documentation
...   author: Liu Zheng
...   contact: zheng.4.liu@nokia-sbell.com
...   squad group: SG_04
...   Feature 2169_LA, 1581_DA, 2376_IA, 1911_AA, 1911_CA, 1581_AA, 2569_A feature

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002169/Resources/merge_case_to_one_kw.robot
Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001581_DA/Resources/5GC001581_DA_keywords.robot
Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002376-IA/resources/merge_case_to_one_kw.robot
Resource     ./2169_1581_2376_1911_2569_Variables.robot


*** Variables ***
# tl name variables
${testline_name}      null
${CONFIGURATION}      ${None}


*** Keywords ***
Suite preparation
    [Documentation]    Author: Liu Zheng
    ...    This keyword will modify swconfig file(default is not to modify swconfig) and commission gnb and verify
    ...    gnb cell on air status.
    ...    ${CONFIGURATION} is the variable that imported robot command by -v .
    [Timeout]    20 min
#    ${SCF_PATH}     Get Substring    ${CURDIR}  0  -88
#    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
#    ${pattern}   Set Variable    7_5(.*)
#    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
#    ${testlinename}   Set Variable    7_5@{TLNAME}[0]
#    ${CONFIGURATION}    Get Variable Value    ${CONFIGURATION}
#    set suite variable     ${CONFIGURATION}
#    set suite variable     ${SCF_PATH}
#    set suite variable     ${testlinename}
#    Connect to Common Unit Master    alias=ASIK Master
#    run keyword if    '${CONFIGURATION}' != '${None}' and '${CONFIGURATION}' != 'null'
#    ...    Create default directory for ute cloud and commission
#    ...    ELSE    Create default directory for lightweight ci
#    Get the ru index list and cell index list and cell group index list and set to suite variable
#    Do prepare UE return status
    log    update later


Do prepare UE return status
    [Documentation]    Author: Liu Zheng
    ${PREPARE_UE_STATUS}    run keyword and return status   Get UE type and prepare UE
    set suite variable     ${PREPARE_UE_STATUS}
    [Return]    ${PREPARE_UE_STATUS}

Get UE type and prepare UE
    [Documentation]    Author: Liu Zheng
    ${UE_TYPE}     ue.translate_power_ue_type_from_testline
    set suite variable     ${UE_TYPE}
    power_ue.Prepare UE    ue_type=${UE_TYPE}

Create default directory for ute cloud and commission
    [Documentation]    Author: Liu Zheng
    ...    Description: default dir scf and swconfig and log dir for ute cloud.
    ...    scf used by commission /home/ute/Auto5G/commissionings/HGZ/7_5_UTE5G402T043/SCF_0.800.xml
    log    output dir is ${OUTPUT DIR}
    ${cur_dir}    run    pwd
    set suite variable     ${TS_LOG_PATH_BASE}       ${cur_dir}/../test_results
    coam create log directory      is_set_to_test_case_level=${False}
    set suite variable     ${TS_LOG_PATH_BASE}       ${cur_dir}/../test_results
    set suite variable     ${GOLDEN_FULL_SCF_8CC}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_0.800_8cc.xml
    set suite variable     ${GOLDEN_FULL_SCF_4CC}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_0.800_4cc.xml
    set suite variable     ${ENB_SCF_DEFAULT_FILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_0.800_ENB.xml
    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/swconfig.txt
    set suite variable     ${luashark_path}        /opt/luashark/luashark.lua
    coam create log directory      is_set_to_test_case_level=${False}
#    Commission on LTE    enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}    is_called_in_test_case_level=${False}
    CI_interface.Common Suite Setup

Create default directory for lightweight ci
    [Documentation]    Author: Liu Zheng
    ...     Description: default dir scf and swconfig for lightweight ci.
    set suite variable     ${SCF_DEFAULT_FILE_PATH}          /opt/ute/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}_4cc.xml
    set suite variable     ${ENB_SCF_DEFAULT_FILE_PATH}    /opt/ute/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}_ENB.xml
    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    /opt/ute/swconfig/swconfig_MMW1_TL${tl.gnbs[0].instance_id}.txt
    coam create log directory      is_set_to_test_case_level=${False}
    Suite common setup preparation    is_pdl_checking_needed=${True}      enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}

Suite env recovery
    [Documentation]    author: Liu Zheng
    [Timeout]    10 min
#    Connect to gnb coam via ssl
#    Connect to Common Unit Master    alias=${ASIK_ALIAS}
#    Run keyword and continue on failure      swconf.Restore swConfig file on asik and crasign    asik_alias=${ASIK_ALIAS}
#    Run keyword if    '${SUITE STATUS}' == 'FAIL'    COAM Save snapshot via webUI    download_dir=${SUITE_LOG_PATH}
#    Tear down all SISO connections
    log    update later

Case preparation
    [Documentation]    Author: Liu Zheng
    ...                makesure the log_dir have the correct user name and user group.
    ...                e.g. sudo chown -R ute:ute /tmp
    [Arguments]    ${is_l3_call_case}=${False}
    ...    ${is_log_required}=${True}
    ...    ${scf_modify_parameters}=${PARAMS_TO_MODIFY_SCF}    ${swconfig_modify}=${None}
    ...    ${is_pdl_checking_needed}=${True}    ${cluster_start_up_timeout}=${CLASSICAL_COMMISSION_ONAIR_TIMEOUT}
    ...    ${is_alias_created}=${False}
#    Common case setup    is_log_required=${is_log_required}
#    ...    scf_modify_parameters=${scf_modify_parameters}    swconfig_modify=${swconfig_modify}
#    ...    is_pdl_checking_needed=${is_pdl_checking_needed}    cluster_start_up_timeout=${cluster_start_up_timeout}
#    ...    scf_template_path=${scf_template_path}    is_alias_created=${is_alias_created}
    log    update later

#    #need updated after scf process done
##    ${lncelid_enb}    run keyword if    '${is_l3_call_case}' == '${False}'    Get lncelid on enb
##    run keyword if    '${is_l3_call_case}' == '${True}'    Set test variable    ${LNCELID}    ${lncelid_enb}
##    run keyword if    '${is_l3_call_case}' == '${True}'
##    ...    Get the ENB actDynTrigLteNrDualConnectivity and defaultLnRelGnbCellId and set them to test variable
#    run keyword if    '${is_l3_call_case}' == '${True}'    Run keyword and ignore error    Close iperf progress
#    run keyword if    '${is_l3_call_case}' == '${True}' and '${PREPARE_UE_STATUS}'==${False}    Do prepare UE return status

Case env recovery
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${operation}=${None}    ${para_update_timeout}=${TIMEOUT_MODIFY_PARA}
    ...    ${is_l3_call_case}=${False}
    ...    ${is_log_required}=${True}
    ...    ${detach_ue}=${False}
    ...    ${is_onair_check}=${False}
    ...    ${onair_timeout}=${DEFAULT_ONAIR_TIMEOUT}
    ...    ${is_close_connection}=${False}
    [Timeout]    15 min
#    Common case teardown    is_log_required=${is_log_required}
#    ...    detach_ue=${is_l3_call_case}
#    ...    is_onair_check=${is_log_required}
#    ...    is_close_connection=${is_close_connection}
#    Recovery env for many sectors if case failed with operations    operation=${operation}
#    Run keyword if    '${is_l3_call_case}' == '${True}' and '${TEST STATUS}' == 'FAIL'
#    ...    Recover the ENB actDynTrigLteNrDualConnectivity and defaultLnRelGnbCellId back to default
#    Recovery env if case failed with operations    operation=${operation}    ru_index=${1}    cell_index=${1}    cell_group_index=${0}
#    Wait cell onair classical cloud    timeout=${onair_timeout}
#    Run keyword and ignore error    Tear down all SISO connections
    log    update later

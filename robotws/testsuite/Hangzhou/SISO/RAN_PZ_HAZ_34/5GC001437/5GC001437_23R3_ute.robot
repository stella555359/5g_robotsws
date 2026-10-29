# *** Settings ***
# Documentation     author: Zhang Lusha
# ...               contact: lusha.zhang@nokia-sbell.com
# ...               squad group: MMW_02
# Suite Setup       Common Setup 1437
# Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
# Force Tags        5G_RAN    5G_RAN_TDD    RAN_5G    RAN_5G_TDD    SBTS23R3    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQP    STATE_SW_UPLOADED
# ...   PY36
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_addition_in_BIM_and_WebUI.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot
# 
# 
# Variables    Resources/variables.py
# 
# 
# *** Variables ***
# ${TS_CASE_LOG_PATH}    ${OUTPUT DIR}
# @{GNB_PS_CELL_INDEX_LIST}    1
# ${Tdanger_init}       107
# ${AEQP_product_code}    475238A
# ${AEQP_I_product_code}    475654A
# ${pro_code_file}    /mnt/factory/configs/unit/core_assembly_product_code.txt
# 
# *** Test Cases ***
# [1][1.0] General_SiSo_Commissioning_BTS_Template_Commissioning
#     [Documentation]    The purpose of this test case is to check if not commissioned gNB can
#     ...    be correctly configured using BTS Template, verify Managed Object Class in WebUI
#     ...    and update parameters via WebUI. bandwith is 100mhz
#     [Tags]    CIT
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_Commissioning_BTS_Template_Commissioning
#     [Teardown]    SISO Coam Test Teardown
# 
# [2][2.0] General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
#     [Tags]    CIT
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
#     [Teardown]    SISO Coam Test Teardown
# 
# [2][1.0] General_SiSo_RF_module_addition_in_BIM_and_WebUI
#     [Documentation]    General_SiSo_RF_module_addition_in_BIM_and_WebUI
#     [Tags]    CIT
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_RF_module_addition_in_BIM_and_WebUI
#     [Teardown]    SISO Coam Test Teardown
# 
# [1]General_SiSo_RF_alarms_with_recovery
#     [Tags]    CIT
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_RF_alarms_with_recovery
#     [Teardown]    SISO Coam Test Teardown
# 
# [2][2.0] General_SiSo_NR-ARFCN_check
#     [Documentation]    General_SiSo_NR-ARFCN_check
#     [Tags]    CIT
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_NR-ARFCN_check
#     [Teardown]    SISO Coam Test Teardown
# 
# [1][1.0] General_SiSo_RF_module_power_reset
#     [Documentation]    change RU from AEQP to  AEQP_I and recopvery,
#     ...    verify whether AEQP_I can run normally
#     [Tags]    CIT
#     [Setup]    SISO Coam Test Setup
#     log to console    \n run AEQP_I case....
#     csn.reset_cache
#     change_product_code    origin_product_code=${AEQP_product_code}   target_product_code=${AEQP_I_product_code}
#     General_SiSo_RF_module_power_reset
#     [Teardown]    Run Keywords
#     ...    change_product_code    origin_product_code=${AEQP_I_product_code}   target_product_code=${AEQP_product_code}
#     ...    AND    SISO Coam Test Teardown
# 
# *** Keywords ***
# Common Setup 1437
#     Sleep    600s
#     SISO Coam Suite Setup
# 
# Recovery Alarm 1937
#     [Arguments]   ${Tdanger_target}   ${ru_index}=1
#     log to console    \n Recovery Alarm 1937
#     Modify Tdanger Value In Json File    init_value=${Tdanger_trriger}    target_value=${Tdanger_target}    cmd=rm -rf    ru_index=${ru_index}
#     Perform RU Reset    download_dir=${SAVE LOG DIRECTORY}
#     sleep    60s
#     log to console    \n Check Alarm 1937 Disappear On WebEM
#     Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1937
#     coam wait gnb and cells ready    timeout=10min    gnb_type='${gNb_CuType}'
# 
# change_product_code
#     [Arguments]    ${origin_product_code}    ${target_product_code}    ${ru_index}=1
#     change_product_code_on_RU    origin_product_code=${origin_product_code}   target_product_code=${target_product_code}    ru_index=${ru_index}
#     set_RU_prodCodePlanned    prodc=${target_product_code}
#     sleep    10s
#     Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
#     log to console    \n Performed BTS Site Reset
#     sleep    60s
#     coam wait gnb and cells ready    timeout=20min    gnb_type='${gNb_CuType}'
# 
# change_product_code_on_RU
#     [Arguments]    ${origin_product_code}    ${target_product_code}    ${ru_index}=1
#     Connect to Common Unit Master
#     Wait Until Keyword Succeeds    5min    1min    Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}
#     ${modify_cmd}    Set Variable    echo ${target_product_code}.102 > ${pro_code_file};md5sum ${pro_code_file} > ${pro_code_file}.md5
#     log to console    \n *** change_product_code from ${origin_product_code} to ${target_product_code} ***
#     check_current_product_code    expect_product_code=${origin_product_code}    connection=RU_${ru_index}
#     csn.send_command    command=${modify_cmd}    connection=RU_${ru_index}
#     check_current_product_code    expect_product_code=${target_product_code}    connection=RU_${ru_index}
#     [Teardown]    run keywords   run keyword and ignore error    csn.disconnect    connection=RU_${ru_index}    AND
#     ...                          run keyword and ignore error    csn.disconnect    connection=ASIK Master
# 
# check_current_product_code
#     [Arguments]    ${expect_product_code}    ${connection}=RU
#     csn.send_command    command=cat ${pro_code_file}    connection=${connection}
#     ${result}    csn.read_output    connection=${connection}
#     Should contain   ${result}   ${expect_product_code}
# 
# set_RU_prodCodePlanned
#     [Arguments]    ${prodc}    ${ru_index}=1
#     selenium login and disable screen lock
#     sleep    2s
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${MRBTS_id}/EQM-1/APEQM-1/RMOD-${ru_index}    filter_param=Product code planned    new_value=${prodc}
#     sleep    2s
#     selenium_coam.validate_plan
#     sleep    2s
#     selenium_coam.activate_plan    activate_plan_despite_errors=${True}
#     sleep    2s
#     log to console  \n *** RU prodCodePlanned has been changed to ${prodc} ***
#     [Teardown]  Selenium Logout And Close Browser

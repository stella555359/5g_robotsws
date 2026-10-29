*** Settings ***
Documentation
...    author: zhang lusha
...    contact: lusha.zhang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_2_SG


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_addition_in_BIM_and_WebUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_without_recovery.robot

Variables    variables.py


*** Variables ***
${TS_CASE_LOG_PATH}    ${OUTPUT DIR}
@{GNB_PS_CELL_INDEX_LIST}    1
${Tdanger_init}       107
${AEQP_product_code}    475238A
${AEQP_I_product_code}    475654A
${pro_code_file}    /mnt/factory/configs/unit/core_assembly_product_code.txt

*** Keywords ***

Recovery Alarm 1937
    [Arguments]   ${Tdanger_target}   ${ru_index}=1
    log to console    \n Recovery Alarm 1937
    Modify Tdanger Value In Json File    init_value=${Tdanger_trriger}    target_value=${Tdanger_target}    cmd=rm -rf    ru_index=${ru_index}
    Perform RU Reset    download_dir=${SAVE LOG DIRECTORY}
    sleep    60s
    log to console    \n Check Alarm 1937 Disappear On WebEM
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1937
    coam wait gnb and cells ready    timeout=10min    gnb_type='${gNb_CuType}'

change_product_code
    [Arguments]    ${origin_product_code}    ${target_product_code}    ${ru_index}=1
    change_product_code_on_RU    origin_product_code=${origin_product_code}   target_product_code=${target_product_code}    ru_index=${ru_index}
    set_RU_prodCodePlanned    prodc=${target_product_code}
    sleep    10s
    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
    log to console    \n Performed BTS Site Reset
    sleep    150s
    coam wait gnb and cells ready    timeout=20min    gnb_type='${gNb_CuType}'

change_product_code_on_RU
    [Arguments]    ${origin_product_code}    ${target_product_code}    ${ru_index}=1
    Connect to Common Unit Master
    Wait Until Keyword Succeeds    5min    1min    Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}
    ${mount_RW_cmd}    Set Variable    sudo mount -o remount,rw /mnt/factory
    ${mount_RO_cmd}    Set Variable    sudo mount -o remount,ro /mnt/factory
    ${chown_serviceuser_cmd}    Set Variable    sudo chown serviceuser:serviceuser /mnt/factory/configs/unit/core_assembly_product_code.txt*
    ${chown_rfsw_cmd}    Set Variable    sudo chown rfsw:rfsw /mnt/factory/configs/unit/core_assembly_product_code.txt*
    ${modify_cmd}    Set Variable    sudo echo ${target_product_code}.102 > ${pro_code_file};md5sum ${pro_code_file} > ${pro_code_file}.md5;
    log to console    \n *** change_product_code from ${origin_product_code} to ${target_product_code} ***
    check_current_product_code    expect_product_code=${origin_product_code}    connection=RU_${ru_index}
    csn.send_command    command=${mount_RW_cmd}    connection=RU_${ru_index}
    sleep    2s
    csn.send_command    command=${chown_serviceuser_cmd}    connection=RU_${ru_index}
    sleep    2s
    csn.send_command    command=${modify_cmd}    connection=RU_${ru_index}
    sleep    2s
    csn.send_command    command=${chown_rfsw_cmd}    connection=RU_${ru_index}
    sleep    2s
    csn.send_command    command=${mount_RO_cmd}    connection=RU_${ru_index}
    sleep    2s
    check_current_product_code    expect_product_code=${target_product_code}    connection=RU_${ru_index}
    [Teardown]    run keywords   run keyword and ignore error    csn.disconnect    connection=RU_${ru_index}    AND
    ...                          run keyword and ignore error    csn.disconnect    connection=ASIK Master

check_current_product_code
    [Arguments]    ${expect_product_code}    ${connection}=RU
    csn.send_command    command=cat ${pro_code_file}    connection=${connection}
    ${result}    csn.read_output    connection=${connection}
    Should contain   ${result}   ${expect_product_code}

set_RU_prodCodePlanned
    [Arguments]    ${prodc}    ${ru_index}=1
    selenium login and disable screen lock
    sleep    2s
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${MRBTS_id}/EQM-1/APEQM-1/RMOD-${ru_index}    filter_param=Product code planned    new_value=${prodc}
    sleep    2s
    selenium_coam.validate_plan
    sleep    2s
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep    2s
    log to console  \n *** RU prodCodePlanned has been changed to ${prodc} ***
    [Teardown]  Selenium Logout And Close Browser

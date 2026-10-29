# # @Time    : 2022/5/31 14:24
# # @Author  : Jian.1.Chen
# # @Email   : jian.1.chen@nokia-sbell.com
# # @File    : CB007045.robot
# # @Software: PyCharm
# # @Doc     : Some Description
# *** Settings ***
# Documentation
# ...    author: Chen Jian
# ...    contact: jian.1.chen@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_3_SG05
# ...    Feature CB007045-SR-C-B1_ST_OAM
# 
# 
# Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND     SISO Coam Suite Setup
# ...    AND      CB007042 CB007045 Precondition    old_password=${COMMON_USER_OLD_PASSWORD}    new_password=${COMMON_USER_NEW_PASSWORD}
# Suite Teardown       robot_common_operations.Common Suite Teardown
# Test Setup           Run Keywords    robot_common_operations.Common Case Setup 
# ...    AND    Connect to gnb coam via ssl
# Test Teardown        Run Keywords    robot_common_operations.Common Case Teardown
# ...    AND    Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# Force Tags      CRT_TRUNK    PY36    CRT_22R4    CRT_23R1
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CB007042_CB007045_common_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Variables ***
# ${RU_TYPE}                      ${tl.gnbs[0].dus[0].rus[0].radio_type.value}
# ${if_commissioning}             True
# ${COMMON_USER_OLD_PASSWORD}     whatever
# ${COMMON_USER_NEW_PASSWORD}     !Dct183CM.
# @{CELLS_VIA_WEBEM}              NRCELL-1
# @{BBMODS_VIA_WEBEM}             BBMOD-1/BBMOD_R-2 (ABIL)
# @{CELLS_VIA_ADMIN_CLI}          MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
# @{BBMODS_VIA_ADMIN_CLI}         MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
# @{SYSTEM_MODULE_SCRIPTS_LIST}   l1_lnr_col_bun    l1_lnr_col_hdr    l1_lnr_col_reg
# 
# @{SYSTEM_MODULE_SCRIPTS_LIST_CB009027}    l2_lte_col_cell
# @{CELLS_VIA_WEBEMC_B009027}               LNCEL-21
# @{BBMODS_VIA_WEBEM_B009027}
# 
# *** Test Cases ***
# [1]CB007045_B_001_ASIK_ABIL_Nemuadmin_List_SMOD_troubleshooting_scripts_and_check_descriptions_from_WebEM
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Selenium Login With Version And Account
#     ${scripts_details}    selenium_sbts.get_troubleshooting_scripts_details
#     ${scripts_names}    Get Dictionary Keys    ${scripts_details}
#     Lists Should Be Equal    ${scripts_names}    ${SYSTEM_MODULE_SCRIPTS_LIST}    ignore_order=True
#     FOR    ${script_name}    IN    @{scripts_names}
#     \    Check Troubleshooting Script Details From WebEM    ${scripts_details['${script_name}']}
#     \    ...    script_name=${script_name}    script_owner_module=System module
#     [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
# [1]CB007045_B_002_ASIK_ABIL_BTSApplication_List_SMOD_troubleshooting_scripts_and_check_descriptions_from_WebEM
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Selenium Login With Version And Account    username=BTSApplication    password=${COMMON_USER_NEW_PASSWORD}
#     ${scripts_details}    selenium_sbts.get_troubleshooting_scripts_details
#     ${scripts_names}    Get Dictionary Keys    ${scripts_details}
#     Lists Should Be Equal    ${scripts_names}    ${SYSTEM_MODULE_SCRIPTS_LIST}    ignore_order=True
#     FOR    ${script_name}    IN    @{scripts_names}
#     \    Check Troubleshooting Script Details From WebEM    ${scripts_details['${script_name}']}
#     \    ...    script_name=${script_name}    script_owner_module=System module
#     [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
# [1]CB007045_B_003_ASIK_ABIL_BTSSecurity_and_BTSRead_check_SMOD_troubleshooting_scripts_from_WebEM
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Selenium Login With Version And Account    username=BTSSecurity    password=${COMMON_USER_NEW_PASSWORD}
#     ${security_status}    Run Keyword And Return Status    selenium_sbts.get_troubleshooting_scripts_details
#     Should Be True    '${security_status}'=='False'
#     Run Keyword And Ignore Error    Selenium Logout And Close Browser
#     Selenium Login With Version And Account    username=BTSRead    password=${COMMON_USER_NEW_PASSWORD}
#     ${read_status}    Run Keyword And Return Status    selenium_sbts.get_troubleshooting_scripts_details
#     Should Be True    '${read_status}'=='False'
#     [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
# [1]CB007045_B_004_ASIK_ABIL_Nemuadmin_Execute_SMOD_troubleshooting_scripts_from_WebEM
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Selenium Login With Version And Account
#     ${all_scripts}    coam.get_all_troubleshooting_scripts    script_owner_module=SMOD    connection=GNB_OAM
#     FOR    ${script}    IN    @{all_scripts}
#     \    ${launch_script}    selenium_sbts.launch_troubleshooting_script    script_name=${script['scriptName']}
#     \    ...    cells_name=${CELLS_VIA_WEBEM}    mods_name=${BBMODS_VIA_WEBEM}    timeout=${120}
#     \    log    ${launch_script}
#     \    Should Be Equal    ${launch_script['Launching status']}    Launching succeeded
#     \    Should Be Equal    ${launch_script['Collection status']}    Collection completed
#     \    Should Not Be Empty    ${launch_script['Collection file']}
#     \    File Should Exist    ${launch_script['Collection file']}
#     [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
# [1]CB007045_B_006_ASIK_ABIL_Nemuadmin_List_SMOD_troubleshooting_scripts_and_check_descriptions_from_Admin_CLI
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     ${all_scripts}    coam.get_all_troubleshooting_scripts    script_owner_module=SMOD    connection=GNB_OAM
#     FOR    ${script}    IN    @{all_scripts}
#     \    Check Troubleshooting Script Details From Admin CLI    details=${script}    script_owner_module=System module
# 
# [1]CB007045_B_011_ASIK_ABIL_BTSApplication_Execute_SMOD_troubleshooting_scripts_from_Admin_CLI
#     [Documentation]    Author: jian.1.chen@nokia-sbell.com
#     Connect to gnb coam via ssl    connection=bts_application
#     ${all_scripts}    coam.get_all_troubleshooting_scripts    script_owner_module=SMOD    connection=GNB_OAM
#     FOR    ${script}    IN    @{all_scripts}
#     \    log    ${script}
#     \    ${ret}    coam.launch_troubleshooting_script    script_name=${script['scriptName']}
#     \    ...    output_file_name=${TS_CASE_LOG_PATH}/script_result_011_${script['scriptName']}.zip
#     \    ...    cell_list=${CELLS_VIA_ADMIN_CLI}    bbmod_list=${BBMODS_VIA_ADMIN_CLI}
#     \    ...    free_parameters=${EMPTY}    timeout=300    connection=bts_application
#     \    Should Be Equal    ${ret}    Launching succeeded. Snapshot has been successfully created.
#     \    File Should Exist    ${TS_CASE_LOG_PATH}/script_result_011_${script['scriptName']}.zip
#     Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=bts_application
# 
# [1]CB007045_B_014_Execute_LTEL2CellConfigurationCollector_script_with_local_accounts_from_WebEM
#     [Documentation]    Author:  xudong.1.li@nokia-sbell.com
#     ...    feature:  CB009027 ABIP_CB007045
#     ...    HW_Type:  ASIL*2+ABIP*4+AHIB+ AZQG*2+AZQR+AEQY
#     ...    UE:       NA
#     [Tags]    c014
#     log to console    ${\n}======Step1-2 Login WebEM with Nemuadmin account And======
#     log to console    ======Open Diagnostic- Troubleshooting Scripts view in Web Element Manager======
#     Selenium Login With Version And Account
#     ${scripts_details}    selenium_sbts.get_troubleshooting_scripts_details
#     ${scripts_names}    Get Dictionary Keys    ${scripts_details}
#     Lists Should Be Equal    ${scripts_names}    ${SYSTEM_MODULE_SCRIPTS_LIST_CB009027}    ignore_order=True
#     FOR    ${script_name}    IN    @{scripts_names}
#     \    Check Troubleshooting Script Details From WebEM    ${scripts_details['${script_name}']}
#     \    ...    script_name=${script_name}    script_owner_module=System module
#     Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
#     log to console   ${\n}======Step3: excute scripts======
#     Selenium Login With Version And Account
#     FOR    ${script}    IN    @{scripts_names}
#     \    ${launch_script}    selenium_sbts.launch_troubleshooting_script    script_name=${script}
#     \    ...    cells_name=${CELLS_VIA_WEBEMC_B009027}    mods_name=${BBMODS_VIA_WEBEM_B009027}    timeout=${120}
#     \    log    ${launch_script}
#     \    Should Be Equal    ${launch_script['Launching status']}    Launching succeeded
#     \    Should Be Equal    ${launch_script['Collection status']}    Collection completed
#     \    Should Not Be Empty    ${launch_script['Collection file']}
#     \    File Should Exist    ${launch_script['Collection file']}
#     Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
#     log to console    ${\n}======Step4-5 Login WebEM with BTSApplication account And======
#     log to console    ======Open Diagnostic- Troubleshooting Scripts view in Web Element Manager======
#     Selenium Login With Version And Account    username=BTSApplication    password=${COMMON_USER_NEW_PASSWORD}
#     ${scripts_details_BTSApplication}    selenium_sbts.get_troubleshooting_scripts_details
#     ${scripts_names_BTSApplication}    Get Dictionary Keys    ${scripts_details_BTSApplication}
#     Lists Should Be Equal    ${scripts_names_BTSApplication}    ${SYSTEM_MODULE_SCRIPTS_LIST_CB009027}    ignore_order=True
#     FOR    ${script_name}    IN    @{scripts_names_BTSApplication}
#     \    Check Troubleshooting Script Details From WebEM    ${scripts_details_BTSApplication['${script_name}']}
#     \    ...    script_name=${script_name}    script_owner_module=System module
#     Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
#     log to console    ${\n}======Step6: excute scripts======
#     Selenium Login With Version And Account    username=BTSApplication    password=${COMMON_USER_NEW_PASSWORD}
#     FOR    ${script}    IN    @{scripts_names_BTSApplication}
#     \    ${launch_script}    selenium_sbts.launch_troubleshooting_script    script_name=${script}
#     \    ...    cells_name=${CELLS_VIA_WEBEMC_B009027}    mods_name=${BBMODS_VIA_WEBEM_B009027}    timeout=${120}
#     \    log    ${launch_script}
#     \    Should Be Equal    ${launch_script['Launching status']}    Launching succeeded
#     \    Should Be Equal    ${launch_script['Collection status']}    Collection completed
#     \    Should Not Be Empty    ${launch_script['Collection file']}
#     \    File Should Exist    ${launch_script['Collection file']}
#     Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
#     log to console  ${\n}======Step7-8: Login WebEM with BTSSecurity account======
#     Selenium Login With Version And Account    username=BTSSecurity    password=${COMMON_USER_NEW_PASSWORD}
#     ${security_status}    Run Keyword And Return Status  selenium_sbts.get_troubleshooting_scripts_details
#     Should Be True    '${security_status}'=='False'
#     Run Keyword And Ignore Error    Selenium Logout And Close Browser
# 
#     log to console  ${\n}======Step9-10: Login WebEM with BTSRead account======
#     Selenium Login With Version And Account    username=BTSRead    password=${COMMON_USER_NEW_PASSWORD}
#     ${read_status}    Run Keyword And Return Status    selenium_sbts.get_troubleshooting_scripts_details
#     Should Be True    '${read_status}'=='False'
#     [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

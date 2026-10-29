# @Time    : 2022/8/1 10:44
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB007042-5G-B.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB007042-5G-B AEHC

Suite Setup          Run Keywords     SISO Coam Suite Setup
...    AND     CB007042 CB007045 Precondition    old_password=${COMMON_USER_OLD_PASSWORD}    new_password=${COMMON_USER_NEW_PASSWORD}
Suite Teardown       robot_common_operations.Common Suite Teardown
Test Setup           Run Keywords    robot_common_operations.Common Case Setup
...    AND     Connect to gnb coam via ssl
Test Teardown        Run Keywords    robot_common_operations.Common Case Teardown
...    AND     Run Keyword And Ignore Error    COAM Teardown gnb connections

# Flag added only to generate a report to Reporting Portal.
Force Tags    SBTS00    SBTS23R1    RAN_5G    PY39
...           RAN_5G_TDD    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASILR_ABIOB4_2xAEHC_ENB


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CB007042_CB007045_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library     launch_troubleshooting_script.py

*** Variables ***
#${RU_TYPE}                          ${tl.gnbs[0].dus[0].rus[0].radio_type.value}
${if_commissioning}                 False
${COMMON_USER_OLD_PASSWORD}         whatever
${COMMON_USER_NEW_PASSWORD}         !Dct183CM.
${COMMON_SCF}          ${CURDIR}/COMMON_10823_2006.xml
${COMMON_SCF_LTE}          ${CURDIR}/COMMON_7042_2006.xml
@{RADIO_MODULE_SCRIPTS_LIST}        RU_Common_capture_IQ_data    RU_Common_capture_L1low_data    RU_Common_capture_register_dump
@{NR_CELLS_WEBEM}    NRCELL-303 (NRCELL_303)
@{NR_CELLS_ADMIN_CLI}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-303
@{LTE_CELLS_WEBEM}    LNCEL-201 (LNCEL_201)    LNCEL-202 (LNCEL_202)    LNCEL-203 (LNCEL_203)
@{LTE_CELLS_ADMIN_CLI}    MRBTS-${MRBTS_ID}/LNBTS-10786/LNCEL-201
@{NR_RMODS_WEBEM}    RMOD-1/RMOD_R-1 (AEHC)
@{LTE_RMODS_WEBEM}    RMOD-2/RMOD_R-2 (AEHC)
@{NR_RMODS_ADMIN_CLI}    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
@{NR_LTE_RMODS_ADMIN_CLI}    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2
@{LTE_RMODS_ADMIN_CLI}    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2
@{ALL_CELLS_WEBEM}    NRCELL-303 (NRCELL_303)    LNCEL-201 (LNCEL_201)    LNCEL-202 (LNCEL_202)    LNCEL-203 (LNCEL_203)
@{ALL_RMODS_WEBEM}    RMOD-1/RMOD_R-1 (AEHC)    RMOD-2/RMOD_R-2 (AEHC)

*** Test Cases ***
CB007042_B_101_AEHC_List_RU_troubleshooting_scripts_and_check_descriptions_from_WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c101
    Selenium Login With Version And Account    download_dir=${TS_LOG_PATH_BASE}/selenium_logs
    ${scripts_details}    selenium_sbts.get_troubleshooting_scripts_details    script_owner_module=Radio module
    ${scripts_names}    Get Dictionary Keys    ${scripts_details}
    Lists Should Be Equal    ${scripts_names}    ${RADIO_MODULE_SCRIPTS_LIST}    ignore_order=True
    FOR    ${script_name}    IN    @{scripts_names}
        Check Troubleshooting Script Details From WebEM    ${scripts_details['${script_name}']}
        ...    script_name=${script_name}    script_owner_module=Radio module
    END
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND     Run Keyword And Ignore Error    Selenium Logout And Close Browser

CB007042_B_102_AEHC_Execute_IQ_data_capture_and_register_dump_scripts_from_WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c102
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    COAM Commission with scf file    ${COMMON_SCF_LTE}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    AlarmWatchdog.remove_allow_alarms    fault_id=6327
    Selenium Login With Version And Account    download_dir=${TS_LOG_PATH_BASE}/selenium_logs
    ${ue_type}    translate power ue type from testline    ue_index=0
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=0
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    Verify Script Launched Successfully From WebEM    launch_script=RU_Common_capture_IQ_data    script_owner_module=Radio module
    ...    cells=${NR_CELLS_WEBEM}    mods=${EMPTY}
    Verify Script Launched Successfully From WebEM    launch_script=RU_Common_capture_IQ_data    script_owner_module=Radio module
    ...    cells=${LTE_CELLS_WEBEM}    mods=${LTE_RMODS_WEBEM}
    Verify Script Launched Successfully From WebEM    launch_script=RU_Common_capture_register_dump    script_owner_module=Radio module
    ...    cells=${NR_CELLS_WEBEM}    mods=${NR_RMODS_WEBEM}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}   ue_index=0
    [Teardown]    Run Keywords    COAM Commission with scf file    ${COMMON_SCF}
    ...    is_pdl_checking_needed=${False}    timeout=900
    ...    AND    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND    Run Keyword And Ignore Error    Selenium Logout And Close Browser

CB007042_B_103_AEHC_List_RU_troubleshooting_scripts_and_check_descriptions_from_Admin_CLI
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c103
    ${all_scripts}    coam.get_all_troubleshooting_scripts    script_owner_module=RMOD    connection=GNB_OAM
    FOR    ${script}    IN    @{all_scripts}
        Check Troubleshooting Script Details From Admin CLI    details=${script}    script_owner_module=Radio module
    END

CB007042_B_104_AEHC_Eexecute_IQ_data_capture_and_register_dump_scripts_from_Admin_CLI
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c104
    ${ue_type}    translate power ue type from testline    ue_index=0
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=0
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    Verify Script Launched Successfully From Admin CLI    launch_script=RU_Common_capture_IQ_data
    ...    script_owner_module=RMOD    output_file_name=${TS_LOG_PATH_BASE}/104_IQ_data_for_NR.zip
    ...    cells=${NR_CELLS_ADMIN_CLI}    mods=${NR_RMODS_ADMIN_CLI}
    Verify Script Launched Successfully From Admin CLI    launch_script=RU_Common_capture_IQ_data
    ...    script_owner_module=RMOD    output_file_name=${TS_LOG_PATH_BASE}/104_IQ_data_for_LTE.zip
    ...    cells=${LTE_CELLS_ADMIN_CLI}    mods=${LTE_RMODS_ADMIN_CLI}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}   ue_index=0
    Verify Script Launched Successfully From Admin CLI    launch_script=RU_Common_capture_register_dump
    ...    script_owner_module=RMOD    output_file_name=${TS_LOG_PATH_BASE}/104_register_dump.zip
    ...    cells=${NR_CELLS_ADMIN_CLI}    mods=${NR_RMODS_ADMIN_CLI}

CB007042_B_105_AEHC_verify_wrong_parameters_value_for_IQ data capture script_from_WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c105
    Selenium Login With Version And Account    download_dir=${TS_LOG_PATH_BASE}/selenium_logs
    ${launch_result}    Run Keyword And Ignore Error    selenium_sbts.launch_troubleshooting_script
    ...    script_name=RU_Common_capture_IQ_data    script_owner_module=Radio module
    ...    cells_name=${NR_CELLS_WEBEM}    mods_name=${LTE_RMODS_WEBEM}    free_text=${EMPTY}    timeout=${30}
    Should Be Equal    ${launch_result[1]['Launching status']}
    ...    Launching failed, all selected fixed parameter values do not intersect
    Verify Script Launched Successfully From WebEM    launch_script=RU_Common_capture_IQ_data    script_owner_module=Radio module
    ...    cells=@{EMPTY}    mods=${ALL_RMODS_WEBEM}    free_text=!@#$%)
    ${launch_result}    concurrent_between_IQ_data_and_RU_disconnect
    ...    script_name=RU_Common_capture_IQ_data    cell_list=@{EMPTY}    rmod_list=@{ALL_RMODS_WEBEM}
    Should Be Equal    ${launch_result['Launching status']}
    ...    Launching partially succeeded, the following script owner(s) failed to execute script due to 'Timeout': RMOD_R-1(Unknown)
    Modify Parameter On BTS With Activate    dist_name=MRBTS-2006/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1
    ...    parameter=administrativeState    value=Unlocked
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    [Teardown]    Run Keywords     robot_common_operations.Common Case Teardown
    ...    AND    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    ...    AND    SISO Coam Suite Setup

CB007042_B_108_AEHC_concurrent_operations_between_RU_restart_and_IQ_data_capture_script_execution_from_webEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c108
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    COAM Commission with scf file    ${COMMON_SCF_LTE}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    AlarmWatchdog.remove_allow_alarms    fault_id=6327
    Selenium Login With Version And Alia    sbts1
    Selenium Login With Version And Alia    sbts2
    Selenium Login With Version And Alia    sbts3
    ${result1}    ${result2}    ${result3}    concurrent_between_IQ_data_and_RU_restart
    ...    cell_list=@{LTE_CELLS_WEBEM}    rmod_list=@{LTE_RMODS_WEBEM}
    Should Contain    ${result1['Launching status']}
    ...    the following script owner(s) failed to execute script due to 'Timeout': RMOD-2/RMOD_R-2 (AEHC)
    Should Contain    ${result3['Launching status']}
    ...    the selected script does not support all selected fixed parameter values
    Run Keyword And Ignore Error    Selenium Logout And Close Browser With Alia    sbts1
    Run Keyword And Ignore Error    Selenium Logout And Close Browser With Alia    sbts2
    Run Keyword And Ignore Error    Selenium Logout And Close Browser With Alia    sbts3
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    ${ue_type}    translate power ue type from testline    ue_index=0
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=0
    Selenium Login With Version And Account
    Verify Script Launched Successfully From WebEM    launch_script=RU_Common_capture_IQ_data    script_owner_module=Radio module
    ...    cells=${LTE_CELLS_WEBEM}    mods=${LTE_RMODS_WEBEM}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}   ue_index=0
    [Teardown]    Run Keywords    COAM Commission with scf file    ${COMMON_SCF}
    ...    is_pdl_checking_needed=${False}    timeout=900
    ...    AND    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND     Run Keyword And Ignore Error    Selenium Logout And Close Browser

CB007042_B_111_AEHC_concurrent_operations_between_regular_snapshot_and_IQ_data_capture_script_execution_from_Admin_CLI
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c111
    Selenium Login With Version And Account    download_dir=${TS_LOG_PATH_CLOUD}/selenium_logs
    Connect to gnb coam via ssl    connection=admin1
    Connect to gnb coam via ssl    connection=admin2
    ${result1}    ${result2}    ${result3}    concurrent_between_regular_shapshot_and_IQ_data_and_register_dump
    ...    script_name_1=RU_Common_capture_IQ_data
    ...    output_file_name_1=${TS_LOG_PATH_CLOUD}/111_IQ_data.zip
    ...    script_name_2=RU_Common_capture_register_dump
    ...    output_file_name_2=${TS_LOG_PATH_CLOUD}/111_register_dump.zip
    ...    cell_list=@{NR_CELLS_ADMIN_CLI}    rmod_list=@{NR_RMODS_ADMIN_CLI}
    ...    connection1=admin1    connection2=admin2
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=admin1
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=admin2
    File Should Exist    ${result1}
    Should Contain    ${result2}    Launching failed, the operation conflicts due to snapshot is ongoing
    Should Contain    ${result3}    Launching failed, the operation conflicts due to snapshot is ongoing
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Selenium Login With Version And Account    download_dir=${TS_LOG_PATH_CLOUD}/selenium_logs
    Connect to gnb coam via ssl    connection=admin3
    ${result4}    ${result5}    concurrent_between_IQ_data_and_regular_shapshot
    ...    script_name=RU_Common_capture_IQ_data
    ...    output_file_name=${TS_LOG_PATH_CLOUD}/111_IQ_data_2.zip
    ...    cell_list=@{EMPTY}    rmod_list=@{NR_LTE_RMODS_ADMIN_CLI}
    ...    connection=admin3
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=admin3
    Should Contain    ${result4}    Launching succeeded. Snapshot has been successfully created.
    File Should Exist    ${result5}
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND     Run Keyword And Ignore Error    Selenium Logout And Close Browser

CB007042_B_112_AEHC_concurrent_operations_between_IQ_data_capture_and_L1low_dump_script_executions_from_WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c112
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    COAM Commission with scf file    ${COMMON_SCF_LTE}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    AlarmWatchdog.remove_allow_alarms    fault_id=6327
    Selenium Login With Version And Alia    sbts1
    Selenium Login With Version And Alia    sbts2
    ${first_script_result}    ${second_script_result}    concurrent_two_scripts_form_webem
    ...    first_script=RU_Common_capture_L1low_data    second_script=RU_Common_capture_IQ_data
    ...    cell_list=${NR_CELLS_WEBEM}    rmod_list=${NR_RMODS_WEBEM}
    Should Be Equal    ${first_script_result['Launching status']}    Launching succeeded
    Should Be Equal    ${second_script_result['Launching status']}    Launching failed, the operation conflicts due to launch script is ongoing
    Run Keyword And Ignore Error    Selenium Logout And Close Browser With Alia    sbts1
    Run Keyword And Ignore Error    Selenium Logout And Close Browser With Alia    sbts2
    Selenium Login With Version And Alia    sbts1
    Selenium Login With Version And Alia    sbts2
    ${first_script_result}    ${second_script_result}    concurrent_two_scripts_form_webem
    ...    first_script=RU_Common_capture_IQ_data    second_script=RU_Common_capture_L1low_data
    ...    cell_list=${NR_CELLS_WEBEM}    rmod_list=${NR_RMODS_WEBEM}
    Should Be Equal    ${first_script_result['Launching status']}    Launching succeeded
    Should Be Equal    ${second_script_result['Launching status']}    Launching failed, the operation conflicts due to launch script is ongoing
    Run Keyword And Ignore Error    Selenium Logout And Close Browser With Alia    sbts1
    Run Keyword And Ignore Error    Selenium Logout And Close Browser With Alia    sbts2
    [Teardown]    Run Keywords    COAM Commission with scf file    ${COMMON_SCF}
    ...    is_pdl_checking_needed=${False}    timeout=900
    ...    AND    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND     Run Keyword And Ignore Error    COAM Teardown gnb connections

CB007042_B_114_AEHC_concurrent_operations_between_NE_Reset_and_RU_troubleshooting_script_execution_from_WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c114
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    COAM Commission with scf file    ${COMMON_SCF_LTE}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    AlarmWatchdog.remove_allow_alarms    fault_id=6327
    coam.reset_site    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    5s    Verify BTS RUs Status Is Normal State
    ${result}    Run Keyword And Ignore Error    coam.launch_troubleshooting_script    script_name=RU_Common_capture_IQ_data
    ...    output_file_name=${TS_LOG_PATH_BASE}/114_iq_data.zip    cell_list=${EMPTY}    rmod_list=${LTE_RMODS_ADMIN_CLI}
    ...    free_parameters=${EMPTY}    timeout=${60}    connection=GNB_OAM
    log    ${result}
    Should Contain    ${result[1]}
    ...    Launching failed, the following script owner(s) failed to execute script due to 'Capture has failed and cannot be completed'
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    coam.reset_site    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    Selenium Login With Version And Account    download_dir=${TS_LOG_PATH_BASE}/selenium_logs
    Verify Script Launched Successfully From WebEM    launch_script=RU_Common_capture_L1low_data
    ...    script_owner_module=Radio module    cells=${LTE_CELLS_WEBEM}    mods=${LTE_RMODS_WEBEM}
    [Teardown]    Run Keywords    COAM Commission with scf file    ${COMMON_SCF}
    ...    is_pdl_checking_needed=${False}    timeout=900
    ...    AND    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND     Run Keyword And Ignore Error    Selenium Logout And Close Browser

CB007042_B_116_AEHC_Launch_and_execute_troubleshooting_script_with_local_user_accounts_Nemuadmin_and_BTSApplication_from_WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c116
    Verify Account And Script Valid From WebEM    username=Nemuadmin    password=nemuuser
    ...    scripts=${RADIO_MODULE_SCRIPTS_LIST}    launch_script=RU_Common_capture_IQ_data
    ...    script_owner_module=Radio module    cells=${ALL_CELLS_WEBEM}    mods=${ALL_RMODS_WEBEM}
    Verify Account And Script Valid From WebEM    username=BTSApplication    password=${COMMON_USER_NEW_PASSWORD}
    ...    scripts=${RADIO_MODULE_SCRIPTS_LIST}    launch_script=RU_Common_capture_IQ_data
    ...    script_owner_module=Radio module    cells=${ALL_CELLS_WEBEM}    mods=${ALL_RMODS_WEBEM}

CB007042_B_117_AEHC_Launch_and_execute_troubleshooting_script_with_local_user_accounts_BTSSecurity_and_BTSRead_from_WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c117
    Verify Account Invalid From WebEM    username=BTSSecurity    password=${COMMON_USER_NEW_PASSWORD}
    Verify Account Invalid From WebEM    username=BTSRead    password=${COMMON_USER_NEW_PASSWORD}

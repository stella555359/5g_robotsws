# @Time    : 2022/6/28 19:20
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB007042.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB007042-5G-MVP-B

Suite Setup          Run Keywords     SISO Coam Suite Setup
...    AND     CB007042 CB007045 Precondition    old_password=${COMMON_USER_OLD_PASSWORD}    new_password=${COMMON_USER_NEW_PASSWORD}
Suite Teardown       robot_common_operations.Common Suite Teardown
Test Setup           MMW5 Common Case Setup
Test Teardown        Run Keywords    MMW5 Common Case Teardown
...    AND     Run Keyword And Ignore Error    COAM Teardown gnb connections

Force Tags    SBTS00    RAN_5G    PY39
...           RAN_5G_TDD    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASILL_ABIOB1_AEQY_ENB

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CB007042_CB007045_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
#${RU_TYPE}                      ${tl.gnbs[0].dus[0].rus[0].radio_type.value}
${if_commissioning}             True
${COMMON_USER_OLD_PASSWORD}     whatever
${COMMON_USER_NEW_PASSWORD}     !Dct183CM.
@{RADIO_MODULE_SCRIPTS_LIST}    RU_Common_capture_IQ_data    RU_Common_capture_L1low_data    RU_Common_capture_register_dump
&{CELLS_WEBEM}    PRIMARY=NRCELL-1    SECONDARY=NRCELL-3
&{RMODS_WEBEM}    PRIMARY=RMOD-1/RMOD_R-1 (AEQY)    SECONDARY=RMOD-2/RMOD_R-2 (AEQY)
&{CELLS_ADMIN_CLI}    PRIMARY=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
...    SECONDARY=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
&{RMODS_ADMIN_CLI}    PRIMARY=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
...    SECONDARY=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2

*** Test Cases ***
CB007042_MVP_B_001_List_L1low_dump_and_register_dump_scripts_and_check_descriptions_from_WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Selenium Login With Version And Account    download_dir=${TS_LOG_PATH_CLOUD}/selenium_logs
    ${scripts_details}    selenium_sbts.get_troubleshooting_scripts_details    script_owner_module=Radio module
    ${scripts_names}    Get Dictionary Keys    ${scripts_details}
    Lists Should Be Equal    ${scripts_names}    ${RADIO_MODULE_SCRIPTS_LIST}    ignore_order=True
    FOR    ${script_name}    IN    @{scripts_names}
        Check Troubleshooting Script Details From WebEM    ${scripts_details['${script_name}']}
        ...    script_name=${script_name}    script_owner_module=Radio module
    END
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND     Run Keyword And Ignore Error    Selenium Logout And Close Browser

CB007042_MVP_B_002_Execute_L1low_dump_script_from_WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Selenium Login With Version And Account    download_dir=${TS_LOG_PATH_CLOUD}/selenium_logs
    ${ue_type}    translate power ue type from testline    ue_index=0
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=0
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    Verify Script Launched Successfully From WebEM    launch_script=RU_Common_capture_L1low_data    script_owner_module=Radio module
    ...    cells=${CELLS_WEBEM['PRIMARY']}    mods=${RMODS_WEBEM['PRIMARY']}
    Verify Script Launched Successfully From WebEM    launch_script=RU_Common_capture_L1low_data    script_owner_module=Radio module
    ...    cells=${CELLS_WEBEM['SECONDARY']}    mods=${RMODS_WEBEM['SECONDARY']}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}   ue_index=0
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND     Run Keyword And Ignore Error    Selenium Logout And Close Browser

CB007042_MVP_B_003_List_L1low_dump_and_register_dump_scripts_and_check_descriptions_from_Admin_CLI
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ${all_scripts}    coam.get_all_troubleshooting_scripts    script_owner_module=RMOD    connection=GNB_OAM
    FOR    ${script}    IN    @{all_scripts}
        Check Troubleshooting Script Details From Admin CLI    details=${script}    script_owner_module=Radio module
    END

CB007042_MVP_B_004_Execute_L1low_dump_script_from_Admin_CLI
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ${ue_type}    translate power ue type from testline    ue_index=0
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=0
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    Verify Script Launched Successfully From Admin CLI    launch_script=RU_Common_capture_L1low_data
    ...    script_owner_module=RMOD    output_file_name=${TS_LOG_PATH_CLOUD}/004_L1low_data_SECONDARY.zip
    ...    cells=${CELLS_ADMIN_CLI['SECONDARY']}    mods=${RMODS_ADMIN_CLI['SECONDARY']}
    Verify Script Launched Successfully From Admin CLI    launch_script=RU_Common_capture_L1low_data
    ...    script_owner_module=RMOD    output_file_name=${TS_LOG_PATH_CLOUD}/004_L1low_data_PRIMARY.zip
    ...    cells=${CELLS_ADMIN_CLI['PRIMARY']}    mods=${RMODS_ADMIN_CLI['PRIMARY']}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}   ue_index=0
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND     Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM

#CB007042_MVP_B_015_Concurrent_operations_between_L1low_dump_and_register_dump_script_executions_from_WebEM
#    [Documentation]    Author: jian.1.chen@nokia-sbell.com
#    Concurrent Operations Between Two Scripts From WebEM    first_script=RU_Common_capture_L1low_data
#    ...    second_script=RU_Common_capture_register_dump    cells=${CELLS_WEBEM['PRIMARY']}
#    ...    rmods=${RMODS_WEBEM['PRIMARY']}
#    Concurrent Operations Between Two Scripts From WebEM    first_script=RU_Common_capture_register_dump
#    ...    second_script=RU_Common_capture_L1low_data    cells=${CELLS_WEBEM['SECONDARY']}
#    ...    rmods=${RMODS_WEBEM['SECONDARY']}
#
#CB007042_MVP_B_018_Launch_and_execute_troubleshooting_script_with_local_user_accounts_BTSSecurity_and_BTSRead_from_WebEM
#    [Documentation]    Author: jian.1.chen@nokia-sbell.com
#    Selenium Login With Version And Account    username=BTSSecurity    password=${COMMON_USER_NEW_PASSWORD}
#    ${security_status}    Run Keyword And Return Status    selenium_sbts.get_troubleshooting_scripts_details
#    ...    script_owner_module=Radio module
#    Should Be True    '${security_status}'=='False'
#    Run Keyword And Ignore Error    Selenium Logout And Close Browser
#    Selenium Login With Version And Account    username=BTSRead    password=${COMMON_USER_NEW_PASSWORD}
#    ${read_status}    Run Keyword And Return Status    selenium_sbts.get_troubleshooting_scripts_details
#    ...    script_owner_module=Radio module
#    Should Be True    '${read_status}'=='False'
#    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

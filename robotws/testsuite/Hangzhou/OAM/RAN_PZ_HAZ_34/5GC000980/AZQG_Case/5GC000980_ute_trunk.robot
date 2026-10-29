# *** Settings ***
# Suite Setup    Suite SetUp For UTE Case    scf_file_name=Configuration_ALD    is_pdl_checking_needed=${False}
# Suite Teardown    980 Suite TearDown
# Force Tags            5G_RAN_TDD    STATE_SW_UPLOADED    master_classicalbts_all    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_2xAZQH
# ...    PY39
# ...           CRT_UTE    SBTS00    SBTS24R1    RAN_5G    RAN_5G_TDD
# Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC000980/Resources/5GC000980_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Documentation
# ...   author: xiangyue.zhou@nokia-sbell.com
# ...   feature_owner: weidong.qiu@nokia-sbell.com
# ...   squad group: SG_06
# ...   Feature 5GC000980 AZQL in 5G19B program
# ...   Current implementation requies ASIK and ABIL HW
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC000980_A_001_AZQG_Radio_start_up_Antenna_line_management_general_startup
#     [Timeout]    45m
#     [Setup]    Case SetUp
#     ALD Should Be Online    ald_index=1
#     RETU Should Be Online    retu_index=1
#     Check ALD Status    administrative_state=Unlocked    availability_status=Online
#     ...    operational_state=Enabled    procedural_status=-
#     Check RETU Status    administrative_state=Unlocked    availability_status=Online
#     ...    operational_state=Enabled    procedural_status=-
#     Reset ALD via webUI    reset_type=hardware
#     Wait Until Keyword Succeeds   3 min  5 sec    Check ALD Status    administrative_state=Unlocked    availability_status=Online
#     ...    operational_state=Enabled    procedural_status=-
#     Check RETU Status    administrative_state=Unlocked    availability_status=Online
#     ...    operational_state=Enabled    procedural_status=-
#     [Teardown]    Case TearDown
# 
# #[1]5GC000980_C_005_AZQG_ALD_Configuration_Management_ALD_reset_operation
# #    [Timeout]    45m
# #    [Setup]    Case SetUp
# #    Check ALD Status    administrative_state=Unlocked    availability_status=Online
# #    ...    operational_state=Enabled    procedural_status=-
# #    Check RETU Status    administrative_state=Unlocked    availability_status=Online
# #    ...    operational_state=Enabled    procedural_status=-
# #    Reset ALD via webUI    reset_type=hardware
# #    Wait Until Keyword Succeeds   3 min  5 sec    Check ALD Status    administrative_state=Unlocked    availability_status=Online
# #    ...    operational_state=Enabled    procedural_status=-
# #    Check RETU Status    administrative_state=Unlocked    availability_status=Online
# #    ...    operational_state=Enabled    procedural_status=-
# #    [Teardown]    Case TearDown
# 
# *** Keywords ***
# Suite SetUp For UTE Case
#     [Arguments]    ${scf_file_name}=${None}    ${is_pdl_checking_needed}=${False}    ${asik_alais}=ASIK Master    ${hw_slot}=${1}
#     robot_common_operations.Common Suite Setup
#     CI_interface.Common Suite Setup
#     Generate Suite Log Path
#     Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
#     ${Active_SW_version}    Get Active SW Version
#     Set Suite Variable    ${Active_SW_version}
#     ${stream}    get stream from version    ${Active_SW_version}
#     Set Suite Variable    ${stream}
#     Set Suite Variable    ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
#     Run Keyword And Ignore Error    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
#     ...                                                               file_path=${SUITE_LOG_PATH}
#     Recommission With SCF File And Wait On Air    scf_file_name=${scf_file_name}_${stream}
#     ...                                                      is_pdl_checking_needed=${is_pdl_checking_needed}
#     Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
#     Connect to Common Unit Master    alias=${asik_alais}
#     Connect to Capacity Unit Master    hw_slot=${hw_slot}
#     Connect to Capacity Unit Slave    hw_slot=${hw_slot}
# 
# Get gNB Stream Version
#     ${stream}    Get Variable Value    ${stream}
#     return from keyword if    '${stream}' != 'None'
#     ${stream}    ${build}    CI_commssion._Get Stream From Variable    ${Active_SW_version}
#     ${stream}    Set variable if    "SBTS" in "${stream}"    SBTS00    ${stream}
#     Set Suite Variable    ${stream}
# 
# Recommission With SCF File And Wait On Air
#     [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
#     [Arguments]    ${scf_file_name}    ${is_pdl_checking_needed}=${True}    ${asik_alais}=ASIK Master
#     ${scf_path}    Get SCF File Path
# #    Get gNB Stream Version
# #    ${scf_file_full_name}    set variable    ${scf_file_name}_${stream}.xml
#     ${scf_file_full_name}    set variable    ${scf_file_name}.xml
#     ${scf_file}    Join Path    ${scf_path}    ${scf_file_full_name}
#     Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
#     Connect to Common Unit Master    alias=${asik_alais}
#     Recommission With Backup SCF File    backup_scf_file=${scf_file}
#     ...                                                   is_pdl_checking_needed=${is_pdl_checking_needed}
#     COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
#     Set Suite Variable    ${old_scf_file_name}    ${scf_file_name}
#     [Teardown]  run keyword and ignore error   COAM Teardown gnb connections
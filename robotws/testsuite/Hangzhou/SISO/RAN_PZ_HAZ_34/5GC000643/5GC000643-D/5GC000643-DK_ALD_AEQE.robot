# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         90 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# #Resource    ${BASIC_PATH_5G}/ALD/General_SiSo_ALD_Configuration_Management_ALD_site_commissioning.robot
# #Resource    ${BASIC_PATH_5G}/ALD/General_SiSo_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization.robot
# #Resource    ${BASIC_PATH_5G}/ALD/General_SiSo_ALD_State_Management_ALD_state_management_handling_and_visibility.robot
# #Resource    ${BASIC_PATH_5G}/ALD/General_SiSo_ALD_FM_Antenna_Line_Device_faulty_notification_recovery_action_indication_and_visualization.robot
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ald_operation.robot
# Variables    TestData/variables.py
# 
# Documentation
# ...    Author: jeffrey shi
# ...    Contact: jeffrey.shi@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature 5GC000643-DK in 5G21A program
# 
# Force Tags            5G_RAN_TDD    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# #[1]5GC001932_A_001_Radio_start_up_Antenna_line_management_general_startup
# #   [Tags]    master_classicalbts_all
# #    General_SiSo_ALD_State_Management_ALD_state_management_handling_and_visibility
# 
# #[1]5GC001932_C_002_ALD_Configuration_Management_ALD_online_recommissioning
# #   [Tags]    master_classicalbts_all
# #    General_SiSo_ALD_Configuration_Management_ALD_site_commissioning
# 
# [1][1.0] 5GC001932_A_003_Radio_start_up_ALD_detection_and_setup
#    [Tags]    master_classicalbts_all    CRT_TRUNK
# #    General_SiSo_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization
#     _AEQE SISO ALD Test Setup
#     _AEQE ALD Details Info Check
#     [Teardown]    _AEQE SISO ALD ENV Recover
# 
# #[1]#5GC001932_008_SiSo_ALD_FM_Antenna_Line_Device_faulty_notification_recovery_action_indication_and_visualizat#ion
# #   [Tags]    master_classicalbts_all
# #    General_SiSo_ALD_FM_Antenna_Line_Device_faulty_notification_recovery_action_indication_and_visualization
# 
# *** Keywords ***
# _AEQE SISO ALD Test Setup
#     Log to console    \n***SISO ALD Test Setup***
#     Connect to gnb coam via ssl
#     ${scf_file_backup}    COAM Download scf from cluster  scf_dir_path=${SAVE LOG DIRECTORY}
#     Set Test Variable    ${scf_file_backup}
#     ${scf_file_delete}    Delete ALD Infomation If Exist    ${scf_file_backup}
#     ${scf_file_add}    Add ALD information to scf    ${scf_file_delete}
#     COAM Commission with scf file    scf_file_path=${scf_file_add}    is_pdl_checking_needed=${if_pdl_check}
#     ${status}    run keyword and return status    Wait until ALD AND RAEU status normal    timeout=10 min
#     ...    download_dir=${SAVE LOG DIRECTORY}
#     Wait until cluster is on cell on air status    is_enb_status_check_needed=${False}
# 
# _AEQE ALD Details Info Check
#     Log to console    \n***ALD Details Info Check***
#     ${ald_info} =    Get ALD RAEU Information via webUI    download_dir=${SAVE LOG DIRECTORY}
#     Run keyword and continue on failure    Should be equal
#     ...    ${ald_info["Product code"]}    &{DICT_ALD_INFO}[PRODUCT_CODE]     msg=There is error Product code for ALD
#     Run keyword and continue on failure    Should be equal
#     ...    ${ald_info["Serial number"]}    &{DICT_ALD_INFO}[SERIAL_NUMBER]     msg=There is error Serial number for ALD
#     Run keyword and continue on failure    Should be equal
#     ...    ${ald_info["Vendor code"]}     &{DICT_ALD_INFO}[VENDOR_CODE]    msg=There is error Vendor code for ALD
#     Run keyword and continue on failure    Should be equal
#     ...    ${ald_info["HW version"]}    &{DICT_ALD_INFO}[HW_VERSION]    msg=There is error HW version for ALD
#     Run keyword and continue on failure    Should be equal
#     ...    ${ald_info["SW version"]}    &{DICT_ALD_INFO}[SW_VERSION]    msg=There is error SW version for ALD
# 
# _AEQE SISO ALD ENV Recover
#     Log to console    \n***SISO ALD ENV Recover***
#     COAM Commission with scf file    scf_file_path=${scf_file_backup}    is_pdl_checking_needed=${if_pdl_check}
#     Wait until cluster is on cell on air status    is_enb_status_check_needed=${False}

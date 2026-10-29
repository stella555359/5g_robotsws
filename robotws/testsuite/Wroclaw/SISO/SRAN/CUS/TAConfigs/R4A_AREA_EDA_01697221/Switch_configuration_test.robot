*** Settings ***
Documentation    responsible tester: slawomir.jastrzebski@nokia.com

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ./variables.robot

Suite Setup       CUS Setup Test Set    ${SCFC_REFERENCE_FILE_PATH}    log_steps=True
Suite Teardown    CUS Teardown Test Set    log_steps=True

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            ${CURDIR}/config/SCFC_SBTS00_CUS_IQC_dual.xml
${SCFC_REFERENCE_FILE_PATH_2}=          ${CURDIR}/config/SCFC_SBTS00_CUS_IQC_single.xml
${SCFC_REFERENCE_FILE_PATH_3}=          ${CURDIR}/config/SCFC_SBTS00_CUS_IQC_none.xml
@{SCFC_FILE_PATH_LIST}=                 ${SCFC_REFERENCE_FILE_PATH}  ${SCFC_REFERENCE_FILE_PATH_2}  ${SCFC_REFERENCE_FILE_PATH_3}
${CUSINI_FILE_PATH}=                    ${CURDIR}/config/cus_IQC_dual.ini
${EPCSIM_FILE_PATH}=                    ${CONFIG_DIR}/epc.lua
${JSON_DELTA_FILE}=                     ${CURDIR}/config/IQC_none_to_dual.json
${JSON_DELTA_FILE_2}=                   ${CURDIR}/config/IQC_dual_to single.json
${JSON_DELTA_FILE_3}=                   ${CURDIR}/config/IQC_single_to_none.json
@{JSON_DELTA_FILE_LIST}=                ${JSON_DELTA_FILE_2}  ${JSON_DELTA_FILE_3}  ${JSON_DELTA_FILE}
${CONFIGURATION_NAME}=                  AREA
${BASIC_CALL}=                          True
@{LCR_ID_CELL_BLOCK_LIST}=              ALL

*** Test Cases ***
Automated__SiSo__I-PHY_Template_Commissioning
    CUS Template Commissioning  ${SCFC_REFERENCE_FILE_PATH}    ${LIST_OF_IPHY_IPS}
    ...    ${CONFIGURATION_NAME}    ${ALLOWED_ALARMS_ONAIR}    log_steps=True
    [Teardown]    CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS}    log_steps=True

#[1][1.0] Automated__SiSo__I-PHY_Configuration_Testing_Basic_Call
#    CUS Basic Call When Onair Reached    ${SCFC_REFERENCE_FILE_PATH}    ${CONFIGURATION_NAME}
#    ...    ${ALLOWED_ALARMS_ONAIR}    log_steps=True
#    [Teardown]    CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS_ONAIR}    log_steps=True

#Automated__SiSo__I-PHY_IQC_Recommissioning
#    CUS IQC Recommissioning  ${SCFC_FILE_PATH_LIST}  ${LIST_OF_IPHY_IPS}  ${JSON_DELTA_FILE_LIST}
#    ...  ${CONFIGURATION_NAME}  ${ALLOWED_ALARMS_ONAIR}  log_steps=True
#    [Teardown]    CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS}    log_steps=True

#[1][1.0] Automated__SiSo__I-PHY_Cells_Block_and_Unblock_with_Basic_Call
#    CUS Cell Block Unblock And Call    ${SCFC_REFERENCE_FILE_PATH}      ${LCR_ID_CELL_BLOCK_LIST}    ${BASIC_CALL}
#    ...    ${CONFIGURATION_NAME}    ${ALLOWED_ALARMS_ONAIR}    log_steps=True
#    [Teardown]    CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS_BLOCK_UNBLOCK}    log_steps=True

#*** Keywords ***
#
#CUS IQC Recommissioning
#    [Arguments]  ${scfc_file_path_list}  ${list_of_cus_ips}  ${json_delta_file_list}  ${hw_configuration}=${EMPTY}
#    ...  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}  ${log_steps}=False
#    [Documentation]  Keyword (test case) performs BTS delta recommissioning.
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#    ...  Description:
#    ...  Keyword (test case) performs BTS delta recommissioning.
#    ...
#    ...  Arguments:
#    ...  +======================+======+==================================================================+
#    ...  | Argument             | Man. | Description                                                      |
#    ...  +======================+======+==================================================================+
#    ...  | scfc_file_path       | Yes  | Path to the scfc file                                            |
#    ...  +----------------------+------+------------------------------------------------------------------+
#    ...  | list_of_cus_ips      | Yes  | List of CUS IP                                                   |
#    ...  +----------------------+------+------------------------------------------------------------------+
#    ...  | json_delta_file      | Yes  | Delta JSON or path to JSON file                                  |
#    ...  +----------------------+------+------------------------------------------------------------------+
#    ...  | hw_configuration     | Yes  | eNB configuration                                                |
#    ...  +----------------------+------+------------------------------------------------------------------+
#    ...  | allowed_alarms       | Yes  | List of allowed_alarms                                           |
#    ...  +----------------------+------+------------------------------------------------------------------+
#    ...  | log_steps            | No   | Logs the given message to console                                |
#    ...  +----------------------+------+------------------------------------------------------------------+
#    ...
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#
#    Report Enb Hardware Configuration  configuration=${hw_configuration}
#    Log  \n${start_prefix_green}Test Case: IQC Delta Recommissioning  console=${log_steps}
#
#    BTS Perform Delta Recommissioning  scfc_file_path=${scfc_file_path_list[0]}  list_of_cus_ips=${list_of_cus_ips}
#    ...  json_delta_file=${json_delta_file_list[0]}  log_steps=${log_steps}
#
#    CUS Call With Throughput Measurement  ${scfc_file_path_list[0]}
#    Run Keyword And Ignore Error
#    ...  Move Directory    ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach   ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach_1
#
#    BTS Perform Delta Recommissioning  scfc_file_path=${scfc_file_path_list[1]}  list_of_cus_ips=${list_of_cus_ips}
#    ...  json_delta_file=${json_delta_file_list[1]}  log_steps=${log_steps}
#
#    CUS Call With Throughput Measurement  ${scfc_file_path_list[1]}
#    Run Keyword And Ignore Error
#    ...  Move Directory    ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach   ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach_2
#
#    BTS Perform Delta Recommissioning  scfc_file_path=${scfc_file_path_list[2]}  list_of_cus_ips=${list_of_cus_ips}
#    ...  json_delta_file=${json_delta_file_list[2]}  log_steps=${log_steps}
#
#    CUS Call With Throughput Measurement  ${scfc_file_path_list[2]}
#    Run Keyword And Ignore Error
#    ...  Move Directory    ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach   ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach_3
#
#    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
#    Log  ${ok_prefix_green}(Done) Checking active alarms  console=${log_steps}
#    Log  ${done_prefix_green}Test Case: IQC Delta Reommissioning\n  console=${log_steps}

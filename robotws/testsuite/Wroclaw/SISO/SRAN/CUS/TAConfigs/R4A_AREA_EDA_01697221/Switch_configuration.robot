*** Settings ***
Documentation    responsible tester: slawomir.jastrzebski@nokia.com

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ./variables.robot

#Force Tags      CLOUD_R4A_CUS   CA_GVe   SBTS00   RAN_4G    RAN_4G_FDD     CRT

Suite Setup       CUS Setup Test Set    ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            ${CURDIR}/config/SCFC_SBTS00_CUS_IQC_dual.xml
${SCFC_REFERENCE_FILE_PATH_2}=          ${CURDIR}/config/SCFC_SBTS00_CUS_IQC_single.xml
${SCFC_REFERENCE_FILE_PATH_3}=          ${CURDIR}/config/SCFC_SBTS00_CUS_IQC_none.xml
@{SCFC_FILE_PATH_LIST}=                 ${SCFC_REFERENCE_FILE_PATH}  ${SCFC_REFERENCE_FILE_PATH_2}  ${SCFC_REFERENCE_FILE_PATH_3}
${JSON_DELTA_FILE}=                     ${CURDIR}/config/IQC_none_to_dual.json
${JSON_DELTA_FILE_2}=                   ${CURDIR}/config/IQC_dual_to single.json
${JSON_DELTA_FILE_3}=                   ${CURDIR}/config/IQC_single_to_none.json
@{JSON_DELTA_FILE_LIST}=                ${JSON_DELTA_FILE_2}  ${JSON_DELTA_FILE_3}  ${JSON_DELTA_FILE}
${CUSINI_FILE_PATH}=                    ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                    ${CONFIG_DIR}/epc.lua
${CONFIGURATION_NAME}=                  CLOUD_R4A_CUS_EDA_01697221
${BASIC_CALL}=                          True
@{LCR_ID_CELL_BLOCK_LIST}=              ALL
${POWER_RESET_COUNT}=                   2

*** Test Cases ***
Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning  ${SCFC_REFERENCE_FILE_PATH}  ${LIST_OF_CUS_IPS}
    ...  ${CONFIGURATION_NAME}  ${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case  ${SUITE_LOGS_DIR_PATH}  ${ALLOWED_ALARMS}

Automated_SiSo_CALL_LTE_CUS_Basic_Call
    [Setup]  CUS Check And Perform Template Commissioning If Needed  ${SCFC_REFERENCE_FILE_PATH}
    ...  ${LIST_OF_CUS_IPS}
    CUS Basic Call When Onair Reached  ${SCFC_REFERENCE_FILE_PATH}  ${CONFIGURATION_NAME}
    ...  ${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case  ${SUITE_LOGS_DIR_PATH}  ${ALLOWED_ALARMS_ONAIR}

Automated_SiSo_CM_CUS_IQ_Compression_Recommissioning
    [Setup]  CUS Check And Perform Template Commissioning If Needed  ${SCFC_REFERENCE_FILE_PATH}
    ...  ${LIST_OF_CUS_IPS}
    CUS IQ Compression Recommissioning  ${SCFC_FILE_PATH_LIST}  ${LIST_OF_CUS_IPS}  ${JSON_DELTA_FILE_LIST}
    ...  ${CONFIGURATION_NAME}  ${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case  ${SUITE_LOGS_DIR_PATH}  ${ALLOWED_ALARMS}

Automated_SiSo_CALL_LTE_CUS_Cells_Block_and_Unblock_with_Basic_Call
    [Setup]  CUS Check And Perform Template Commissioning If Needed  ${SCFC_REFERENCE_FILE_PATH}
    ...  ${LIST_OF_CUS_IPS}
    CUS Cell Block Unblock And Call  ${SCFC_REFERENCE_FILE_PATH}  ${LCR_ID_CELL_BLOCK_LIST}  ${BASIC_CALL}
    ...  ${CONFIGURATION_NAME}  ${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case  ${SUITE_LOGS_DIR_PATH}  ${ALLOWED_ALARMS_BLOCK_UNBLOCK}

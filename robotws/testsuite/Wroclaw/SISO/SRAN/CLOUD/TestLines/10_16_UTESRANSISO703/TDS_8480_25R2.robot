*** Settings ***
Documentation  To be done
...  Author: wojciech.bodzek@nokia.com
...  Maintainer: wojciech.bodzek@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/aic_test_cases.robot
Resource    ../../resources/Robot/aic_test_cases_loop.robot
Resource    ../../TestCases/TEST/Cloud_TEST_TDS_RF_Scanning.robot

Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown    get_logs=False

*** Variables ***
${VCU_SCF_PATH}     ${CURDIR}/SCF/vCU/tds_25R2_scfc_cu.xml
${VDU_SCF_PATH}     ${CURDIR}/SCF/vDU/tds_25R2_scfc_du.xml
${FHGW_IP}=          10.42.185.164
${FHGW_USERNAME}=    toor4nsn
${FHGW_PASSWORD}=    Fhgw@nokia1243
${FHGW_PORT}=        22
${TEST_RUN_COUNT}=      3
#${vDU_OAM_password}  Nokia@123
#${VDU_URL}           https://10.42.126.118/
${CELLS_YAML_PATH}  ${CURDIR}/cells.yaml


*** Test Cases ***

[AHPMDG][1.0] Automated_AIC_TDS_RF_Scanning
    [Setup]  AiC Test Setup
    TC__Cloud_TEST_TDS_RF_Scanning   scfc_file_path=${VDU_SCF_PATH}    rmod_sn=BL2331C62X6
    [Teardown]   AiC Test Teardown



